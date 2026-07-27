#!/usr/bin/env python3
"""Independent replay of the two-row transport census for q < 10^6.

The finite-field implementation is imported from the already shipped
`fibre_size` certificate.  This verifier adds no algebraic formula for the
order: it uses that independent exact order computation, enumerates every
remaining final-row product, factors it below q^2, and applies both the
multiplier-free transport and the exact linear lift.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import math
import sys
import time
from pathlib import Path
from typing import Any

from sympy import factorint


HERE = Path(__file__).resolve().parent
REPLAY = HERE.parent / "fibre_size" / "verifica_fibre_taglia.py"
EXPECTED_1E6 = {
    "inert_q": 39_286,
    "excluded_by_Tq_ge_q2": 36_009,
    "products_tested": 76_530,
    "semiprime_candidates": 415,
    "both_rows_transport_pass": 24,
    "triangle_crt_pass_after_two_transports": 17,
    "size_pass_after_two_transports": 1,
    "triangle_and_size_pass": 0,
    "first_row_exact_pass": 0,
    "both_rows_exact_pass": 0,
}


def load_replay() -> Any:
    spec = importlib.util.spec_from_file_location("fibre_size_replay", REPLAY)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {REPLAY}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def row_data(
    replay: Any,
    p: int,
    other: int,
    q: int,
    branch: int,
    nu: int,
    h: int,
    tq: int,
) -> dict[str, Any]:
    exponent = 0 if p % 5 == nu else 2
    tp = replay.t_order(p)
    transport_modulus = math.gcd(tp, tq)
    transport_pass = (
        pow(q, 1 if branch == 0 else 3, transport_modulus)
        == pow(p, exponent + 1, transport_modulus)
    )

    coefficient = q * tq
    target = (
        (pow(p, exponent + 1, tp) - q) % tp
        if branch == 0
        else (pow(q, 3, tp) - pow(p, exponent + 1, tp)) % tp
    )
    divisor = math.gcd(coefficient, tp)
    solvable = target % divisor == 0
    modulus = tp // divisor
    if not solvable:
        residue = None
        h_matches = False
    elif modulus == 1:
        residue = 0
        h_matches = True
    else:
        residue = (
            target // divisor
            * pow((coefficient // divisor) % modulus, -1, modulus)
        ) % modulus
        h_matches = h % modulus == residue

    original = (other * q - pow(p, exponent, tp)) % tp == 0
    if h_matches != original:
        raise AssertionError(f"linear lift mismatch at {(p, other, q)}")
    return {
        "p": p,
        "T_p": tp,
        "exponent": exponent,
        "transport_modulus": transport_modulus,
        "transport_pass": transport_pass,
        "linear_solvable": solvable,
        "reduced_modulus": modulus,
        "required_h_residue": residue,
        "original_row": original,
    }


def replay_census(limit: int) -> dict[str, Any]:
    exact = load_replay()
    started = time.perf_counter()
    inert = exact.inert_primes(limit)
    excluded = 0
    products = 0
    semiprimes = 0
    transport_survivors: list[dict[str, Any]] = []
    first_exact = 0
    both_exact = 0
    triangle_passes = 0
    size_passes = 0
    triangle_and_size = 0

    for q in inert:
        tq = exact.t_order(q)
        if tq >= q * q:
            excluded += 1
            continue
        for branch in (0, 2):
            product = exact.first_above_one(pow(q, branch, tq), tq)
            while product < q * q:
                products += 1
                if product % 5 == (1 if branch == 0 else 4):
                    factors = factorint(product)
                    if len(factors) == 2 and all(
                        int(exponent) == 1 for exponent in factors.values()
                    ):
                        p, r = sorted(int(prime) for prime in factors)
                        if (
                            2 < p < r < q
                            and p % 5 in (2, 3)
                            and r % 5 in (2, 3)
                        ):
                            semiprimes += 1
                            h = (
                                (product - 1) // tq
                                if branch == 0
                                else (q * q - product) // tq
                            )
                            nu = product * q % 5
                            rows = [
                                row_data(exact, p, r, q, branch, nu, h, tq),
                                row_data(exact, r, p, q, branch, nu, h, tq),
                            ]
                            first_exact += int(rows[0]["original_row"])
                            both_exact += int(
                                all(row["original_row"] for row in rows)
                            )
                            if all(row["transport_pass"] for row in rows):
                                triangle_modulus = math.gcd(
                                    rows[0]["T_p"], rows[1]["T_p"]
                                )
                                triangle = (
                                    pow(
                                        p,
                                        rows[0]["exponent"] + 1,
                                        triangle_modulus,
                                    )
                                    == pow(
                                        r,
                                        rows[1]["exponent"] + 1,
                                        triangle_modulus,
                                    )
                                )
                                size = (
                                    rows[0]["T_p"] <= max(p * p, r * q)
                                    and rows[1]["T_p"] <= max(r * r, p * q)
                                )
                                triangle_passes += int(triangle)
                                size_passes += int(size)
                                triangle_and_size += int(triangle and size)
                                h_bound = (q * q - 2) // tq
                                first = rows[0]
                                if not (
                                    first["linear_solvable"]
                                    and h_bound < first["required_h_residue"]
                                    < first["reduced_modulus"]
                                ):
                                    raise AssertionError(
                                        f"bounded-lift certificate failed at {(p, r, q)}"
                                    )
                                transport_survivors.append(
                                    {
                                        "primes": [p, r, q],
                                        "branch": branch,
                                        "h": h,
                                        "H_q": h_bound,
                                        "first_row_required_h": first[
                                            "required_h_residue"
                                        ],
                                        "first_row_modulus": first["reduced_modulus"],
                                        "triangle_modulus": triangle_modulus,
                                        "triangle_pass": triangle,
                                        "size_pass": size,
                                    }
                                )
                product += tq

    result = {
        "limit_q_exclusive": limit,
        "inert_q": len(inert),
        "excluded_by_Tq_ge_q2": excluded,
        "products_tested": products,
        "semiprime_candidates": semiprimes,
        "both_rows_transport_pass": len(transport_survivors),
        "triangle_crt_pass_after_two_transports": triangle_passes,
        "size_pass_after_two_transports": size_passes,
        "triangle_and_size_pass": triangle_and_size,
        "first_row_exact_pass": first_exact,
        "both_rows_exact_pass": both_exact,
        "transport_survivors": transport_survivors,
        "elapsed_seconds": round(time.perf_counter() - started, 6),
        "provenance": {
            "script_sha256": sha256(Path(__file__)),
            "fibre_size_replay_sha256": sha256(REPLAY),
            "python": sys.version,
        },
    }
    if limit == 1_000_000:
        observed = {key: result[key] for key in EXPECTED_1E6}
        if observed != EXPECTED_1E6:
            raise AssertionError(
                f"frozen census mismatch: expected {EXPECTED_1E6}, got {observed}"
            )
    result["status"] = "PASS"
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=1_000_000)
    parser.add_argument(
        "--output",
        type=Path,
        default=HERE / "VERIFICA_TRASPORTO_DUE_RIGHE_1E6.json",
    )
    args = parser.parse_args()
    result = replay_census(args.limit)
    args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps({key: value for key, value in result.items()
                      if key != "transport_survivors"}, indent=2, sort_keys=True))
    print(f"transport_survivors: {len(result['transport_survivors'])}")


if __name__ == "__main__":
    main()
