#!/usr/bin/env python3
"""Replay indipendente del ponte aureo al livello split r=5.

Per tutti i primi p < LIMIT con p = 1 mod 5:
  * sceglie una radice primitiva g e zeta = g^((p-1)/5);
  * costruisce il carattere quintico chi;
  * verifica U2 = sqrt(5)^5 * epsilon^3;
  * verifica M2 = chi(U2) = 3 chi(epsilon);
  * enumera esaustivamente le classi m modulo p-1;
  * per ogni riga locale verifica la covarianza
        e(t a) = t e(a);
  * per t != 1 verifica chi(5)=chi(epsilon)=0.

Usa soltanto la libreria standard.
"""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path


def sieve(limit: int) -> list[int]:
    is_prime = bytearray(b"\x01") * limit
    if limit > 0:
        is_prime[0] = 0
    if limit > 1:
        is_prime[1] = 0
    for q in range(2, math.isqrt(limit - 1) + 1):
        if is_prime[q]:
            start = q * q
            is_prime[start:limit:q] = b"\x00" * (((limit - 1 - start) // q) + 1)
    return [n for n in range(2, limit) if is_prime[n]]


def prime_factors(n: int) -> list[int]:
    out: list[int] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            out.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out.append(n)
    return out


def primitive_root(p: int) -> int:
    factors = prime_factors(p - 1)
    for g in range(2, p):
        if all(pow(g, (p - 1) // q, p) != 1 for q in factors):
            return g
    raise AssertionError(f"nessuna radice primitiva trovata modulo {p}")


def audit_prime(p: int) -> dict[str, object]:
    g = primitive_root(p)
    fifth = (p - 1) // 5
    zeta = pow(g, fifth, p)
    assert zeta != 1 and pow(zeta, 5, p) == 1

    zeta_index: dict[int, int] = {}
    value = 1
    for index in range(5):
        zeta_index[value] = index
        value = value * zeta % p

    def chi(value: int) -> int:
        return zeta_index[pow(value % p, fifth, p)]

    units = {a: (pow(zeta, a, p) - 1) % p for a in range(1, 5)}
    assert all(units.values())

    sqrt5 = (1 + 2 * (zeta + pow(zeta, 4, p))) % p
    epsilon = (1 + zeta + pow(zeta, 4, p)) % p
    assert sqrt5 * sqrt5 % p == 5 % p
    assert (2 * epsilon - 1) % p == sqrt5

    weights = {a: (a * a) % 5 for a in range(1, 5)}
    u2 = 1
    product_u = 1
    for a in range(1, 5):
        u2 = u2 * pow(units[a], weights[a], p) % p
        product_u = product_u * units[a] % p

    assert product_u == 5 % p
    assert u2 == pow(sqrt5, 5, p) * pow(epsilon, 3, p) % p

    e = {a: chi(units[a]) for a in range(1, 5)}
    m0 = sum(e.values()) % 5
    m2 = sum(weights[a] * e[a] for a in range(1, 5)) % 5

    assert m0 == chi(product_u) == chi(5)
    assert m2 == chi(u2)
    assert m2 == (3 * chi(epsilon)) % 5

    local_members: list[dict[str, int]] = []
    tested = 0
    for m in range(1, p):
        if m % 5 == 0:
            continue
        tested += 1
        is_local = all(
            pow(units[a], m, p) == units[(a * m) % 5]
            for a in range(1, 5)
        )
        if not is_local:
            continue

        t = m % 5
        assert all(
            (t * e[a] - e[(t * a) % 5]) % 5 == 0
            for a in range(1, 5)
        )

        if t != 1:
            assert pow(t, 3, 5) != 1
            assert m0 == 0
            assert m2 == 0
            assert chi(5) == 0
            assert chi(epsilon) == 0

        local_members.append(
            {
                "m": m,
                "t_mod_5": t,
                "chi_5": chi(5),
                "chi_epsilon": chi(epsilon),
                "M0": m0,
                "M2": m2,
            }
        )

    return {
        "p": p,
        "primitive_root": g,
        "zeta": zeta,
        "tested_exponent_classes": tested,
        "local_members": local_members,
        "nontrivial_members": [
            row for row in local_members if row["t_mod_5"] != 1
        ],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=10_000)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    rows = []
    total_tested = 0
    total_members = 0
    nontrivial = []

    for p in sieve(args.limit):
        if p % 5 != 1:
            continue
        row = audit_prime(p)
        rows.append(row)
        total_tested += int(row["tested_exponent_classes"])
        total_members += len(row["local_members"])
        nontrivial.extend(
            {"p": p, **member} for member in row["nontrivial_members"]
        )

    result = {
        "schema": 1,
        "limit_exclusive": args.limit,
        "primes_p_eq_1_mod_5": len(rows),
        "tested_exponent_classes": total_tested,
        "local_members": total_members,
        "nontrivial_local_members": nontrivial,
        "failures": [],
        "status": "PASS",
        "rows": rows,
    }
    args.output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        json.dumps(
            {
                "status": "PASS",
                "primes": len(rows),
                "tested_exponent_classes": total_tested,
                "local_members": total_members,
                "nontrivial_local_members": nontrivial,
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
