#!/usr/bin/env python3
"""Censimento certificato della congettura d'inerzia per H_n.

Miglioramenti rispetto al prototipo:
- default(factor_proven,1) in PARI/GP;
- isprime su ogni fattore;
- factorback e ricostruzione Python;
- controllo del return code e degli errori GP;
- conteggio esplicito di timeout/incompleti;
- manifest JSON atomico con SHA-256 dello script;
- separazione fra fattori canonici p=2n-1 e fattori non canonici.

H_n = gcd(A_n, 5^(n-1)+1), con
A_n = L_n se n è pari, F_n se n è dispari, n=4 mod 5.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
import shutil
import subprocess
import sys
import tempfile

sys.stdout.reconfigure(line_buffering=True)
import time
from collections import Counter
from datetime import datetime, timezone
from math import gcd
from pathlib import Path
from typing import Any

sys.set_int_max_str_digits(2_000_000)


def fib_pair(n: int) -> tuple[int, int]:
    if n == 0:
        return 0, 1
    a, b = fib_pair(n >> 1)
    c = a * (2 * b - a)
    d = a * a + b * b
    return (d, c + d) if n & 1 else (c, d)


def strip_2_5(n: int) -> int:
    while n % 2 == 0:
        n //= 2
    while n % 5 == 0:
        n //= 5
    return n


def script_sha256() -> str:
    path = Path(__file__)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def prime_sieve(limit: int) -> list[int]:
    """Primi <= limit, usati solo per il controllo canonico p=2n-1."""
    if limit < 2:
        return []
    sieve = bytearray(b"\x01") * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    bound = int(limit**0.5)
    for p in range(2, bound + 1):
        if sieve[p]:
            sieve[p * p : limit + 1 : p] = b"\x00" * (
                (limit - p * p) // p + 1
            )
    return [p for p in range(2, limit + 1) if sieve[p]]


def gp_version(gp: str) -> str:
    completed = subprocess.run(
        [gp, "--version"],
        capture_output=True,
        text=True,
        check=True,
    )
    # gp scrive la versione su stderr in alcuni ambienti: si accetta
    # il primo dei due flussi non vuoto.
    return completed.stdout.strip() or completed.stderr.strip()


def pari_factor_proven(n: int, gp: str, timeout: int) -> dict[int, int]:
    # NB: gp via stdin legge riga per riga: il programma DEVE stare su una
    # sola riga (trappola nota del 22 lug, colpita di nuovo il 24).
    program = (
        f'default(factor_proven,1);N={n};F=factor(N);'
        'if(factorback(F)!=N,error("factorback mismatch"));'
        'for(i=1,matsize(F)[1],if(!isprime(F[i,1]),error("unproven factor"));'
        'print(F[i,1],":",F[i,2]));quit;\n'
    )
    completed = subprocess.run(
        [gp, "-q", "-f"],
        input=program,
        capture_output=True,
        text=True,
        timeout=timeout,
    )
    if completed.returncode != 0:
        raise RuntimeError(
            f"GP return code {completed.returncode}: {completed.stderr.strip()}"
        )
    if completed.stderr.strip():
        # GP può scrivere warning non fatali; li rendiamo comunque visibili.
        raise RuntimeError(f"GP stderr non vuoto: {completed.stderr.strip()}")

    factors: dict[int, int] = {}
    for raw in completed.stdout.splitlines():
        line = raw.strip()
        if not line:
            continue
        if ":" not in line:
            raise RuntimeError(f"output GP inatteso: {line!r}")
        p_text, e_text = line.split(":", 1)
        p, e = int(p_text), int(e_text)
        if p <= 1 or e <= 0:
            raise RuntimeError(f"fattore/esponente non valido: {line}")
        factors[p] = e

    reconstructed = 1
    for p, e in factors.items():
        reconstructed *= p**e
    if reconstructed != n:
        raise RuntimeError(
            f"ricostruzione Python fallita: ottenuto {reconstructed}, atteso {n}"
        )
    return factors


def atomic_json_dump(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", dir=path.parent, delete=False
    ) as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2, sort_keys=True)
        handle.write("\n")
        tmp_name = handle.name
    os.replace(tmp_name, path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--n-max", type=int, default=100_000)
    parser.add_argument("--timeout", type=int, default=600)
    parser.add_argument(
        "--manifest",
        type=Path,
        default=Path("manifest_censimento_Hn_certificato.json"),
    )
    parser.add_argument("--checkpoint-every", type=int, default=250)
    args = parser.parse_args()

    gp = shutil.which("gp")
    if gp is None:
        raise SystemExit("PARI/GP non trovato nel PATH")

    started = time.monotonic()
    canonical_expected = {
        p
        for p in prime_sieve(2 * args.n_max - 1)
        if p not in (2, 5) and p % 5 == 2
    }

    state: dict[str, Any] = {
        "schema": 2,
        "script_sha256": script_sha256(),
        "started_at_utc": datetime.now(timezone.utc).isoformat(),
        "python_version": platform.python_version(),
        "platform": platform.platform(),
        "gp_command": "gp",
        "gp_version": gp_version(gp),
        "n_max": args.n_max,
        "tested_indices": 0,
        "nontrivial_H": 0,
        "complete_factorizations": 0,
        "timeouts": [],
        "errors": [],
        "split_factors": [],
        "distinct_factors": {},
        "factorizations": [],
        "canonical_occurrences": 0,
        "noncanonical_occurrences": 0,
        "status": "running",
    }

    for n in range(4, args.n_max + 1, 5):
        f_n, f_np1 = fib_pair(n)
        A_n = 2 * f_np1 - f_n if n % 2 == 0 else f_n
        residue = (pow(5, n - 1, A_n) + 1) % A_n
        H_n = strip_2_5(gcd(A_n, residue))

        state["tested_indices"] += 1
        if H_n > 1:
            state["nontrivial_H"] += 1
            try:
                factors = pari_factor_proven(H_n, gp, args.timeout)
            except subprocess.TimeoutExpired:
                state["timeouts"].append(
                    {"n": n, "digits": len(str(H_n)), "H": str(H_n)}
                )
                factors = None
            except Exception as exc:  # il manifest conserva l'errore preciso
                state["errors"].append(
                    {"n": n, "digits": len(str(H_n)), "error": repr(exc)}
                )
                factors = None

            if factors is not None:
                state["complete_factorizations"] += 1
                factorization_record = {
                    "n": n,
                    "H": str(H_n),
                    "factors": [
                        {"p": p, "exponent": exponent}
                        for p, exponent in sorted(factors.items())
                    ],
                }
                state["factorizations"].append(factorization_record)
                for p, exponent in factors.items():
                    key = str(p)
                    record = state["distinct_factors"].setdefault(
                        key,
                        {
                            "p": p,
                            "class_mod_5": p % 5,
                            "occurrences": 0,
                            "total_multiplicity": 0,
                            "first_n": n,
                            "canonical": False,
                        },
                    )
                    record["occurrences"] += 1
                    record["total_multiplicity"] += exponent
                    if p == 2 * n - 1:
                        state["canonical_occurrences"] += 1
                        record["canonical"] = True
                    else:
                        state["noncanonical_occurrences"] += 1
                    if p % 5 in (1, 4):
                        state["split_factors"].append(
                            {"n": n, "p": p, "exponent": exponent}
                        )

        if (
            state["tested_indices"] % args.checkpoint_every == 0
            or state["split_factors"]
        ):
            atomic_json_dump(args.manifest, state)
            print(
                f"  ... n={n}: testati {state['tested_indices']}, "
                f"H non banali {state['nontrivial_H']}, "
                f"fattorizzazioni complete {state['complete_factorizations']}, "
                f"timeout {len(state['timeouts'])}, errori {len(state['errors'])}, "
                f"split {len(state['split_factors'])}",
                flush=True,
            )

        if state["split_factors"]:
            state["status"] = "split_factor_found"
            atomic_json_dump(args.manifest, state)
            raise SystemExit(
                f"FATTORE SPLIT TROVATO: {state['split_factors'][-1]}"
            )

    state["status"] = (
        "complete"
        if not state["timeouts"] and not state["errors"]
        else "incomplete"
    )
    state["distinct_factor_count"] = len(state["distinct_factors"])
    state["split_factor_count"] = len(state["split_factors"])
    factor_set = {int(p) for p in state["distinct_factors"]}
    canonical_observed = {
        int(p)
        for p, record in state["distinct_factors"].items()
        if record["canonical"]
    }
    state["distinct_by_class_mod_5"] = dict(
        sorted(Counter(p % 5 for p in factor_set).items())
    )
    state["max_distinct_factor"] = max(factor_set, default=None)
    state["canonical_expected_count"] = len(canonical_expected)
    state["canonical_observed_count"] = len(canonical_observed)
    state["canonical_missing"] = sorted(canonical_expected - canonical_observed)
    state["canonical_unexpected"] = sorted(canonical_observed - canonical_expected)
    state["factors_above_2n_max"] = sorted(
        p for p in factor_set if p > 2 * args.n_max - 1
    )
    state["finished_at_utc"] = datetime.now(timezone.utc).isoformat()
    state["elapsed_seconds"] = round(time.monotonic() - started, 6)
    atomic_json_dump(args.manifest, state)

    print(
        json.dumps(
            {
                key: state[key]
                for key in (
                    "status",
                    "tested_indices",
                    "nontrivial_H",
                    "complete_factorizations",
                    "distinct_factor_count",
                    "split_factor_count",
                    "canonical_occurrences",
                    "noncanonical_occurrences",
                    "distinct_by_class_mod_5",
                    "max_distinct_factor",
                    "canonical_expected_count",
                    "canonical_observed_count",
                    "canonical_missing",
                    "canonical_unexpected",
                    "factors_above_2n_max",
                    "timeouts",
                    "errors",
                    "script_sha256",
                    "elapsed_seconds",
                )
            },
            ensure_ascii=False,
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
