#!/usr/bin/env python3
"""
Falsificatore mirato del triangolo CRT per il ramo tutto-inerte, k = 3.

Questo programma usa il teorema strutturale

    T_p | 10 (p^2 - 1)

per calcolare l'ordine di zeta_5 - 1 senza fattorizzare p^2 + 1.  Per ogni
prodotto semiprimo della fibra finale verifica, nell'ordine:

  1. i due trasporti finale--riga piccola;
  2. il terzo lato del triangolo CRT fra le due righe piccole;
  3. i due bound locali T_p <= max(p^2, n/p);
  4. le tre righe originali.

La versione indipendente e più lenta in
`teoremi/agrawal/verifica_fibre_taglia.py` non usa il bound strutturale.
Il presente script confronta i due calcoli dell'ordine su un prefisso
configurabile prima di iniziare la ricerca estesa.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import math
import sys
import time
from collections import Counter
from functools import lru_cache
from pathlib import Path
from typing import Any

from sympy import factorint, primerange


ROOT = Path(__file__).resolve().parents[1]
REPLAY_PATH = ROOT / "teoremi" / "agrawal" / "verifica_fibre_taglia.py"


def load_replay() -> Any:
    spec = importlib.util.spec_from_file_location("fibre_replay", REPLAY_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"impossibile caricare {REPLAY_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


REPLAY = load_replay()


@lru_cache(maxsize=None)
def structural_order(p: int) -> int:
    """Ordine esatto usando il bound dimostrato T_p | 10(p^2-1)."""
    if p % 5 not in (2, 3):
        raise ValueError(f"{p} non è inerte modulo 5")
    order = 10 * (p * p - 1)
    element = (p - 1, 1, 0, 0)
    if REPLAY.field_pow(element, order, p) != REPLAY.ONE:
        raise AssertionError(f"bound strutturale falso per p={p}")
    prime_divisors = {2, 5}
    prime_divisors.update(int(ell) for ell in factorint(p - 1))
    prime_divisors.update(int(ell) for ell in factorint(p + 1))
    for ell in sorted(prime_divisors):
        while order % ell == 0:
            candidate = order // ell
            if REPLAY.field_pow(element, candidate, p) != REPLAY.ONE:
                break
            order = candidate
    for ell in factorint(order):
        if REPLAY.field_pow(element, order // int(ell), p) == REPLAY.ONE:
            raise AssertionError(f"ordine non esatto per p={p}, ell={ell}")
    return order


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def exact_semiprime(value: int) -> tuple[int, int] | None:
    factors = factorint(value)
    if len(factors) != 2 or any(int(exponent) != 1 for exponent in factors.values()):
        return None
    p, r = sorted(int(prime) for prime in factors)
    return p, r


def exponent_for(prime: int, nu: int) -> int:
    return 0 if prime % 5 == nu else 2


def run(lower: int, limit: int, crosscheck_limit: int) -> dict[str, Any]:
    started = time.perf_counter()
    crosschecked = 0
    for p in primerange(3, min(limit, crosscheck_limit)):
        p = int(p)
        if p % 5 not in (2, 3):
            continue
        fast = structural_order(p)
        independent = REPLAY.t_order(p)
        if fast != independent:
            raise AssertionError(
                f"ordini discordi per p={p}: {fast} != {independent}"
            )
        crosschecked += 1

    counts: Counter[str] = Counter()
    by_branch: Counter[int] = Counter()
    structural_survivors: list[dict[str, Any]] = []
    exact_hits: list[dict[str, Any]] = []

    for q_raw in primerange(max(3, lower), limit):
        q = int(q_raw)
        if q % 5 not in (2, 3):
            continue
        counts["inert_q"] += 1
        tq = structural_order(q)
        if tq >= q * q:
            counts["excluded_by_Tq_ge_q2"] += 1
            continue
        defect = 10 * (q * q - 1) // tq
        if tq * defect != 10 * (q * q - 1) or defect % 2 == 0:
            raise AssertionError(f"difetto incoerente per q={q}")
        H = (defect - 1) // 10
        for branch in (0, 2):
            for h in range(1, H + 1):
                product = 1 + h * tq if branch == 0 else q * q - h * tq
                counts["products"] += 1
                expected_mod_five = 1 if branch == 0 else 4
                if product <= 1 or product >= q * q:
                    raise AssertionError(f"intervallo incoerente per q={q}, h={h}")
                if product % 5 != expected_mod_five:
                    continue
                pair = exact_semiprime(product)
                if pair is None:
                    continue
                p, r = pair
                if not (
                    2 < p < r < q
                    and p % 5 in (2, 3)
                    and r % 5 in (2, 3)
                ):
                    continue
                counts["semiprimes"] += 1
                by_branch[branch] += 1
                nu = product * q % 5
                jp = exponent_for(p, nu)
                jr = exponent_for(r, nu)
                tp = structural_order(p)
                tr = structural_order(r)
                ap = pow(p, jp + 1)
                ar = pow(r, jr + 1)
                final_residue = 1 if branch == 0 else q * q

                transport_p = (final_residue * q - ap) % math.gcd(tp, tq) == 0
                transport_r = (final_residue * q - ar) % math.gcd(tr, tq) == 0
                if not (transport_p and transport_r):
                    continue
                counts["two_transports"] += 1

                triangle = (ap - ar) % math.gcd(tp, tr) == 0
                if triangle:
                    counts["triangle"] += 1

                size = (
                    tp <= max(p * p, r * q)
                    and tr <= max(r * r, p * q)
                )
                if size:
                    counts["size"] += 1

                if not (triangle and size):
                    continue
                counts["triangle_and_size"] += 1

                rows = (
                    (r * q - pow(p, jp)) % tp == 0,
                    (p * q - pow(r, jr)) % tr == 0,
                    (product - pow(q, branch)) % tq == 0,
                )
                record = {
                    "primes": [p, r, q],
                    "branch": branch,
                    "h": h,
                    "defect_q": defect,
                    "orders": [tp, tr, tq],
                    "triangle": triangle,
                    "size": size,
                    "rows": list(rows),
                }
                structural_survivors.append(record)
                if all(rows):
                    exact_hits.append(record)

    return {
        "status": "COUNTEREXAMPLE" if exact_hits else "PASS",
        "scope": (
            "all-inert triples p<r<q with "
            f"{max(3, lower)}<=q<{limit}"
        ),
        "lower_q_inclusive": max(3, lower),
        "limit_q_exclusive": limit,
        "crosscheck_limit_exclusive": min(limit, crosscheck_limit),
        "orders_crosschecked": crosschecked,
        "counts": dict(sorted(counts.items())),
        "branch_counts": {str(k): v for k, v in sorted(by_branch.items())},
        "structural_survivors": structural_survivors,
        "exact_hits": exact_hits,
        "elapsed_seconds": round(time.perf_counter() - started, 6),
        "provenance": {
            "script_sha256": sha256(Path(__file__)),
            "independent_replay_sha256": sha256(REPLAY_PATH),
            "python": sys.version,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--lower", type=int, default=3)
    parser.add_argument("--limit", type=int, default=1_000_000)
    parser.add_argument("--crosscheck-limit", type=int, default=100_000)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = run(args.lower, args.limit, args.crosscheck_limit)
    rendered = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    print(rendered)
    if result["exact_hits"]:
        raise SystemExit(2)


if __name__ == "__main__":
    main()
