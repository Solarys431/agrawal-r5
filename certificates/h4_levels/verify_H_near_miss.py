#!/usr/bin/env python3
"""Independent replay of the closest H-profile candidate below 10^10.

This script uses only Python's standard library.  Primality is checked by
the deterministic Miller--Rabin basis for unsigned 64-bit integers, and
the two multiplicative orders are reconstructed from the certified
factorization of p-1.
"""

from __future__ import annotations

import json
from math import gcd


P = 1_368_322_369
SQRT5 = 216_130_103
P_MINUS_ONE_FACTORIZATION = {2: 6, 3: 1, 7: 1, 1_018_097: 1}
EXPECTED_ORDER_5 = 6_108_582
EXPECTED_ORDER_EPSILON2 = 672


def is_prime_64(n: int) -> bool:
    if n < 2:
        return False
    for prime in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % prime == 0:
            return n == prime
    shift = 0
    odd_part = n - 1
    while odd_part % 2 == 0:
        shift += 1
        odd_part //= 2
    for base in (2, 325, 9375, 28178, 450775, 9780504, 1795265022):
        if base % n == 0:
            continue
        value = pow(base, odd_part, n)
        if value in (1, n - 1):
            continue
        for _ in range(1, shift):
            value = value * value % n
            if value == n - 1:
                break
        else:
            return False
    return True


def factorback(factorization: dict[int, int]) -> int:
    result = 1
    for prime, exponent in factorization.items():
        result *= prime**exponent
    return result


def exact_order(element: int, modulus: int) -> int:
    order = modulus - 1
    for prime, exponent in P_MINUS_ONE_FACTORIZATION.items():
        for _ in range(exponent):
            candidate = order // prime
            if pow(element, candidate, modulus) != 1:
                break
            order = candidate
    return order


def main() -> None:
    assert is_prime_64(P)
    assert is_prime_64(1_018_097)
    assert factorback(P_MINUS_ONE_FACTORIZATION) == P - 1
    assert SQRT5 * SQRT5 % P == 5

    inverse_two = pow(2, -1, P)
    epsilon_square = (3 + SQRT5) * inverse_two % P
    assert (epsilon_square * epsilon_square
            - 3 * epsilon_square + 1) % P == 0

    order_5 = exact_order(5, P)
    order_epsilon_square = exact_order(epsilon_square, P)
    assert order_5 == EXPECTED_ORDER_5
    assert order_epsilon_square == EXPECTED_ORDER_EPSILON2

    r = order_5 // 2
    s = order_epsilon_square // 2
    result = {
        "schema": 1,
        "p": P,
        "p_is_prime": True,
        "p_minus_one_factorization": [
            [prime, exponent]
            for prime, exponent in P_MINUS_ONE_FACTORIZATION.items()
        ],
        "sqrt5": SQRT5,
        "epsilon_square": epsilon_square,
        "ord_5": order_5,
        "ord_epsilon2": order_epsilon_square,
        "r": r,
        "s": s,
        "gcd_r_s": gcd(r, s),
        "opposite_two_adic_profile": (
            (order_5 % 4 == 2 and order_epsilon_square % 4 == 0)
            or (order_epsilon_square % 4 == 2 and order_5 % 4 == 0)
        ),
        "full_H_profile": gcd(r, s) == 1,
        "status": "PASS",
    }
    assert result["gcd_r_s"] == 3
    assert result["opposite_two_adic_profile"]
    assert not result["full_H_profile"]
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
