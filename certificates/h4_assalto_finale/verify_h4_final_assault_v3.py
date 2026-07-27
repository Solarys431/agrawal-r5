#!/usr/bin/env python3
"""Independent, standard-library verifier for the finite H4 assault.

This program verifies the *reported certificates*.  It does not prove H4 and
does not replace replaying the two C++ enumerators.  In particular:

* the non-canonical witness is rechecked arithmetically from scratch;
* both DONE lines are parsed and compared with the frozen scopes/counts;
* sources and frozen outputs are hashed;
* no compiler-dependent binary hash is part of the portable certificate.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
from pathlib import Path

P = 18_251_687
R = 158
E = 99_736
R_FACTORS = (2, 79)
E_FACTORS = (2, 7, 13, 137)
PM1_FACTORIZATION = {2: 1, 71: 1, 79: 1, 1627: 1}
PP1_FACTORIZATION = {2: 3, 3: 1, 7: 1, 13: 1, 61: 1, 137: 1}

EXPECTED_SCAN = {
    "N": 50_000_000,
    "inert": 1_500_789,
    "admissible": 1_500_789,
    "p_gt_m": 1,
    "minp": P,
    "R": R,
    "E": E,
}
EXPECTED_TWO_SUPPORT = {
    "Q": 5000,
    "primes_base": 667,
    "PMAX": 10**18,
    "variants": 159_265_017,
    "primes": 8_406_178,
    "dyad": 268_541,
    "hits": 0,
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def product(factorization: dict[int, int]) -> int:
    result = 1
    for q, exponent in factorization.items():
        result *= q**exponent
    return result


def is_prime_64(n: int) -> bool:
    if n < 2:
        return False
    small = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
    for q in small:
        if n % q == 0:
            return n == q
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 325, 9375, 28178, 450775, 9780504, 1795265022):
        if a % n == 0:
            continue
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(1, s):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


Matrix = tuple[int, int, int, int]
IDENTITY: Matrix = (1, 0, 0, 1)
D_MATRIX: Matrix = (2, 1, 1, 1)


def matrix_mul(x: Matrix, y: Matrix, modulus: int) -> Matrix:
    a, b, c, d = x
    e, f, g, h = y
    return (
        (a * e + b * g) % modulus,
        (a * f + b * h) % modulus,
        (c * e + d * g) % modulus,
        (c * f + d * h) % modulus,
    )


def matrix_pow(x: Matrix, exponent: int, modulus: int) -> Matrix:
    result = IDENTITY
    while exponent:
        if exponent & 1:
            result = matrix_mul(result, x, modulus)
        x = matrix_mul(x, x, modulus)
        exponent >>= 1
    return result


def has_exact_scalar_order(value: int, order: int, prime_factors: tuple[int, ...]) -> bool:
    return pow(value, order, P) == 1 and all(
        pow(value, order // q, P) != 1 for q in prime_factors
    )


def has_exact_matrix_order(order: int, prime_factors: tuple[int, ...]) -> bool:
    return matrix_pow(D_MATRIX, order, P) == IDENTITY and all(
        matrix_pow(D_MATRIX, order // q, P) != IDENTITY for q in prime_factors
    )


def parse_done(path: Path) -> tuple[str, dict[str, int]]:
    lines = [line.strip() for line in path.read_text().splitlines() if line.startswith("DONE ")]
    if len(lines) != 1:
        raise ValueError(f"{path}: expected exactly one DONE line, found {len(lines)}")
    values: dict[str, int] = {}
    for key, raw in re.findall(r"([A-Za-z_]+)=([0-9]+)", lines[0]):
        values[key] = int(raw)
    return lines[0], values


def require_equal(actual: object, expected: object, label: str, failures: list[str]) -> None:
    if actual != expected:
        failures.append(f"{label}: expected {expected!r}, found {actual!r}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    failures: list[str] = []

    paths = {
        "scan_source": root / "scan_inert_pk.cpp",
        "scan_log": root / "INERT_PK_5E7_REPLAY.log",
        "scan_hits": root / "INERT_PK_5E7_REPLAY.txt",
        "two_source": root / "search_H_two_support_powers.cpp",
        "two_log": root / "H_TWO_SUPPORT_POWERS_Q5K_1E18_REPLAY.log",
    }
    for label, path in paths.items():
        if not path.is_file():
            failures.append(f"missing artifact {label}: {path}")

    if failures:
        report = {"schema": 3, "status": "FAIL", "failures": failures}
        args.output.write_text(json.dumps(report, indent=2) + "\n")
        raise SystemExit(json.dumps(report, indent=2))

    require_equal(product(PM1_FACTORIZATION), P - 1, "factorization p-1", failures)
    require_equal(product(PP1_FACTORIZATION), P + 1, "factorization p+1", failures)
    require_equal(is_prime_64(P), True, "deterministic primality", failures)
    require_equal(pow(5, (P - 1) // 2, P), P - 1, "Legendre(5/p)=-1", failures)
    require_equal(
        has_exact_scalar_order(5, R, R_FACTORS),
        True,
        "ord_p(5)=158",
        failures,
    )
    require_equal(
        has_exact_matrix_order(E, E_FACTORS),
        True,
        "ord_p([[2,1],[1,1]])=99736",
        failures,
    )

    r, s = R // 2, E // 2
    m = 4 * r * s
    k = P % m
    require_equal(math.gcd(r, s), 1, "gcd(r,s)", failures)
    require_equal((r + s) % 2, 1, "opposite parity", failures)
    require_equal((r * s) % 5 != 0, True, "5∤rs", failures)
    require_equal(math.gcd(k - 1, m), 2 * r, "gcd(k-1,m)=2r", failures)
    require_equal(math.gcd(k + 1, m), 2 * s, "gcd(k+1,m)=2s", failures)
    require_equal(P, k + m, "non-canonical relation p=k+m", failures)
    require_equal(R * E < P, True, "counterexample to R*E>p", failures)

    hit_line = paths["scan_hits"].read_text().strip()
    expected_hit = f"p={P} R={R} E={E} r={r} s={s} m={m} k={k}"
    require_equal(hit_line, expected_hit, "frozen non-canonical hit", failures)

    scan_line, scan_values = parse_done(paths["scan_log"])
    for key, expected in EXPECTED_SCAN.items():
        require_equal(scan_values.get(key), expected, f"scan count {key}", failures)

    two_line, two_values = parse_done(paths["two_log"])
    for key, expected in EXPECTED_TWO_SUPPORT.items():
        require_equal(two_values.get(key), expected, f"two-support count {key}", failures)

    report = {
        "schema": 3,
        "status": "PASS" if not failures else "FAIL",
        "scope_warning": (
            "Finite replay only. Zero hits in the declared domains neither proves H4 "
            "nor the universal inert-support conjecture."
        ),
        "failures": failures,
        "noncanonical_inert_prime": {
            "p": P,
            "prime": is_prime_64(P),
            "factor_p_minus_1": PM1_FACTORIZATION,
            "factor_p_plus_1": PP1_FACTORIZATION,
            "legendre_5": -1,
            "ord_p_5": R,
            "ord_p_epsilon_squared_matrix": E,
            "r": r,
            "s": s,
            "m": m,
            "k": k,
            "relation": "p = k + m",
            "scan_done_line": scan_line,
        },
        "two_odd_support_family": {
            "scope": (
                "p-1=2^b*q^a*t^c for p≡4 mod 5, or "
                "p-1=2^b*5^f*q^a*t^c for p≡1 mod 5; "
                "q<t≤5000, positive exponents, p<10^18"
            ),
            **EXPECTED_TWO_SUPPORT,
            "scan_done_line": two_line,
        },
        "portable_artifacts": {
            label: {"path": str(path.relative_to(root)), "sha256": sha256(path)}
            for label, path in paths.items()
        },
        "binary_hash_policy": (
            "Compiled executables are deliberately excluded: their bytes depend on "
            "compiler, flags and platform. Reproducibility is source+command+output based."
        ),
    }
    args.output.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print(json.dumps({"status": report["status"], "failures": failures}, indent=2))
    if failures:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
