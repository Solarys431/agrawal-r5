#!/usr/bin/env python3
"""Independent replay of the final-row size sieve for r = 5.

This program deliberately does not import any campaign module.  It recomputes
the order of zeta_5 - 1 in F_p[X]/(Phi_5), enumerates the remaining products,
and checks every local row through exact divisibility by the corresponding
order.

The k=3 replay is exhaustive for triples whose largest prime q is below the
chosen limit.  The k=5 replay is exhaustive only for q with T_q >= q^2; the
other q are reported as undecided, never as empty fibers.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import tempfile
import time
from functools import lru_cache
from pathlib import Path
from typing import Any

from sympy import factorint, primerange

ONE = (1, 0, 0, 0)


def field_mul(a: tuple[int, ...], b: tuple[int, ...], p: int) -> tuple[int, ...]:
    """Multiply in F_p[X]/(X^4+X^3+X^2+X+1)."""
    raw = [0] * 7
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                raw[i + j] = (raw[i + j] + ai * bj) % p
    for degree in range(6, 3, -1):
        coefficient = raw[degree]
        if coefficient:
            raw[degree] = 0
            for offset in range(4):
                raw[degree - 4 + offset] = (
                    raw[degree - 4 + offset] - coefficient
                ) % p
    return tuple(raw[:4])


def field_pow(a: tuple[int, ...], exponent: int, p: int) -> tuple[int, ...]:
    result = ONE
    while exponent:
        if exponent & 1:
            result = field_mul(result, a, p)
        exponent >>= 1
        if exponent:
            a = field_mul(a, a, p)
    return result


@lru_cache(maxsize=None)
def t_order(p: int) -> int:
    """Exact order of X-1 in F_p[X]/(Phi_5), for p = +/-2 mod 5."""
    if p % 5 not in (2, 3):
        raise ValueError(f"{p} is not inert modulo 5")
    group_order = p**4 - 1
    prime_factors: dict[int, int] = {}
    for part in (p - 1, p + 1, p * p + 1):
        for ell, exponent in factorint(part).items():
            ell_i, exponent_i = int(ell), int(exponent)
            prime_factors[ell_i] = prime_factors.get(ell_i, 0) + exponent_i
    element = (p - 1, 1, 0, 0)
    if field_pow(element, group_order, p) != ONE:
        raise AssertionError(f"field/order sanity failed at p={p}")
    order = group_order
    for ell, exponent in sorted(prime_factors.items()):
        for _ in range(exponent):
            if field_pow(element, order // ell, p) == ONE:
                order //= ell
            else:
                break
    if group_order % order:
        raise AssertionError(f"computed order does not divide p^4-1 at p={p}")
    for ell in factorint(order):
        if field_pow(element, order // int(ell), p) == ONE:
            raise AssertionError(f"computed order is not exact at p={p}, ell={ell}")
    return order


def inert_primes(limit: int) -> list[int]:
    return [int(p) for p in primerange(3, limit) if p % 5 in (2, 3)]


def branch_exponent(product_without_q: int) -> int:
    residue = product_without_q % 5
    if residue == 1:
        return 0
    if residue == 4:
        return 2
    raise AssertionError("an odd number of inert factors must give residue +/-1")


def all_local_rows(primes: tuple[int, ...]) -> bool:
    n = math.prod(primes)
    nu = n % 5
    for p in primes:
        j = 0 if p % 5 == nu else 2
        if p % 5 not in (nu, (-nu) % 5):
            return False
        if (n // p - p**j) % t_order(p):
            return False
    return True


def first_above_one(residue: int, modulus: int) -> int:
    residue %= modulus
    if residue > 1:
        return residue
    return residue + ((2 - residue + modulus - 1) // modulus) * modulus


def replay_k3(limit: int) -> dict[str, Any]:
    started = time.perf_counter()
    primes = inert_primes(limit)
    excluded = 0
    undecided_q: list[dict[str, int]] = []
    products_tested = 0
    semiprime_candidates = 0
    survivors: list[dict[str, Any]] = []

    for q in primes:
        tq = t_order(q)
        if tq >= q * q:
            excluded += 1
            continue
        undecided_q.append({"q": q, "T_q": tq})
        bound = q * q
        for j in (0, 2):
            residue = pow(q, j, tq)
            product = first_above_one(residue, tq)
            while product < bound:
                products_tested += 1
                if product % 5 == (1 if j == 0 else 4):
                    factors = factorint(product)
                    if (
                        len(factors) == 2
                        and all(int(exponent) == 1 for exponent in factors.values())
                    ):
                        p1, p2 = sorted(int(p) for p in factors)
                        if (
                            2 < p1 < p2 < q
                            and p1 % 5 in (2, 3)
                            and p2 % 5 in (2, 3)
                        ):
                            semiprime_candidates += 1
                            triple = (p1, p2, q)
                            if branch_exponent(p1 * p2) != j:
                                raise AssertionError("branch classification mismatch")
                            if all_local_rows(triple):
                                survivors.append(
                                    {"primes": list(triple), "n": math.prod(triple)}
                                )
                product += tq

    return {
        "scope": f"all triples p1<p2<q with q<{limit}",
        "limit_q_exclusive": limit,
        "inert_q": len(primes),
        "excluded_by_Tq_ge_q2": excluded,
        "undecided_q_count": len(undecided_q),
        "undecided_q": undecided_q,
        "products_tested": products_tested,
        "semiprime_candidates": semiprime_candidates,
        "survivors": survivors,
        "elapsed_seconds": round(time.perf_counter() - started, 6),
    }


def replay_k5(limit: int) -> dict[str, Any]:
    started = time.perf_counter()
    q_values = inert_primes(limit)
    decidable = 0
    undecided_q: list[dict[str, int]] = []
    first_pairs_scanned = 0
    branch_pair_tests = 0
    residues_below_q2 = 0
    residue_pair_hits = 0
    ordered_quadruples_checked = 0
    survivors: list[dict[str, Any]] = []

    for q in q_values:
        tq = t_order(q)
        if tq < q * q:
            undecided_q.append({"q": q, "T_q": tq})
            continue
        decidable += 1
        smaller = [p for p in q_values if p < q]
        pairs: list[tuple[int, int, int]] = []
        by_product: dict[int, list[tuple[int, int]]] = {}
        for index, p1 in enumerate(smaller):
            for p2 in smaller[index + 1 :]:
                product = p1 * p2
                pairs.append((product, p1, p2))
                by_product.setdefault(product, []).append((p1, p2))
        first_pairs_scanned += len(pairs)

        for a, p1, p2 in pairs:
            if math.gcd(a, tq) != 1:
                # A valid final row has gcd(A*B,T_q)=gcd(q^j,T_q)=1.
                continue
            inverse = pow(a, -1, tq)
            for j in (0, 2):
                branch_pair_tests += 1
                b = (pow(q, j, tq) * inverse) % tq
                if not (1 < b < q * q):
                    continue
                residues_below_q2 += 1
                for p3, p4 in by_product.get(b, []):
                    residue_pair_hits += 1
                    if not (p2 < p3):
                        continue
                    quadruple_product = a * b
                    if branch_exponent(quadruple_product) != j:
                        continue
                    ordered_quadruples_checked += 1
                    quintuple = (p1, p2, p3, p4, q)
                    if all_local_rows(quintuple):
                        survivors.append(
                            {"primes": list(quintuple), "n": math.prod(quintuple)}
                        )

    return {
        "scope": (
            f"all quintuples p1<p2<p3<p4<q with q<{limit}, "
            "restricted to q satisfying T_q>=q^2"
        ),
        "limit_q_exclusive": limit,
        "inert_q": len(q_values),
        "decidable_q_Tq_ge_q2": decidable,
        "undecided_q_count": len(undecided_q),
        "undecided_q": undecided_q,
        "first_pairs_scanned": first_pairs_scanned,
        "branch_pair_tests": branch_pair_tests,
        "residues_below_q2": residues_below_q2,
        "residue_pair_hits": residue_pair_hits,
        "ordered_quadruples_checked": ordered_quadruples_checked,
        "survivors": survivors,
        "elapsed_seconds": round(time.perf_counter() - started, 6),
    }


def atomic_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", dir=path.parent, delete=False
    ) as handle:
        json.dump(payload, handle, indent=2, sort_keys=True)
        handle.write("\n")
        temporary = Path(handle.name)
    os.replace(temporary, path)


def normalized_for_comparison(value: Any) -> Any:
    """Drop only timing fields; every mathematical counter remains binding."""
    if isinstance(value, dict):
        return {
            key: normalized_for_comparison(item)
            for key, item in value.items()
            if key != "elapsed_seconds"
        }
    if isinstance(value, list):
        return [normalized_for_comparison(item) for item in value]
    return value


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--k3-limit", type=int, default=100_000)
    parser.add_argument("--k5-limit", type=int, default=3_000)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument(
        "--expected",
        type=Path,
        help="compare every non-timing field with a tracked certificate",
    )
    args = parser.parse_args()

    script_hash = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    result = {
        "schema": "agrawal-r5-fibre-size-replay-v1",
        "script_sha256": script_hash,
        "k3": replay_k3(args.k3_limit),
        "k5": replay_k5(args.k5_limit),
    }
    result["status"] = (
        "PASS"
        if not result["k3"]["survivors"] and not result["k5"]["survivors"]
        else "SURVIVOR_FOUND"
    )
    if args.expected is not None:
        expected = json.loads(args.expected.read_text(encoding="utf-8"))
        if normalized_for_comparison(result) != normalized_for_comparison(expected):
            raise SystemExit("replay differs from the expected certificate")
    atomic_json(args.output, result)
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
