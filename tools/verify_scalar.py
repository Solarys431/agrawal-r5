#!/usr/bin/env python3
"""Independent finite-quotient regression for scalar completeness.

This deliberately does not reuse the Lean implementation.  Arithmetic is
performed on four-tuples in F_p[z]/(z^4+z^3+z^2+z+1).
"""

from __future__ import annotations


LIMIT_P = 5_000
LIMIT_N = 1_000


def primes_below(limit: int) -> list[int]:
    sieve = bytearray(b"\x01") * limit
    sieve[:2] = b"\x00\x00"
    for q in range(2, int(limit**0.5) + 1):
        if sieve[q]:
            sieve[q * q : limit : q] = b"\x00" * (
                (limit - 1 - q * q) // q + 1
            )
    return [q for q in range(limit) if sieve[q]]


def add(x: tuple[int, ...], y: tuple[int, ...], p: int) -> tuple[int, ...]:
    return tuple((a + b) % p for a, b in zip(x, y))


def neg(x: tuple[int, ...], p: int) -> tuple[int, ...]:
    return tuple((-a) % p for a in x)


def sub(x: tuple[int, ...], y: tuple[int, ...], p: int) -> tuple[int, ...]:
    return add(x, neg(y, p), p)


def mul(x: tuple[int, ...], y: tuple[int, ...], p: int) -> tuple[int, ...]:
    raw = [0] * 7
    for i, a in enumerate(x):
        for j, b in enumerate(y):
            raw[i + j] = (raw[i + j] + a * b) % p
    # z^k = -z^(k-1)-z^(k-2)-z^(k-3)-z^(k-4), descending in k.
    for k in range(6, 3, -1):
        c = raw[k] % p
        for j in range(1, 5):
            raw[k - j] = (raw[k - j] - c) % p
    return tuple(raw[:4])


def power(x: tuple[int, ...], exponent: int, p: int) -> tuple[int, ...]:
    out = (1, 0, 0, 0)
    base = x
    e = exponent
    while e:
        if e & 1:
            out = mul(out, base, p)
        base = mul(base, base, p)
        e >>= 1
    return out


def main() -> None:
    scalar_hits = 0
    same_index_hits = 0
    repaired_hits = 0
    negative_defects = 0

    for p in primes_below(LIMIT_P):
        if p in (2, 5):
            continue
        one = (1, 0, 0, 0)
        minus_one = neg(one, p)
        zeta = (0, 1, 0, 0)
        u1 = sub(zeta, one, p)
        zeta2 = power(zeta, 2, p)
        u2 = sub(zeta2, one, p)
        zeta4 = power(zeta, 4, p)
        eps = add(add(one, zeta, p), zeta4, p)
        five = (5 % p, 0, 0, 0)

        for n in range(4, LIMIT_N + 1, 5):
            if power(eps, 2 * n, p) != minus_one:
                continue
            if power(five, n - 1, p) != minus_one:
                continue
            scalar_hits += 1
            m = 2 * n - 1
            target = sub(power(zeta, m, p), one, p)
            lhs = power(u1, m, p)
            if lhs == target:
                same_index_hits += 1
                repaired_hits += 1
                continue
            if lhs != neg(u2, p):
                raise AssertionError(
                    f"mixed defect at p={p}, n={n}: {lhs!r}"
                )
            negative_defects += 1
            d = (m * m) // 2
            shifted_n = n + 5 * d
            shifted_m = 2 * shifted_n - 1
            if shifted_n % 5 != 4:
                raise AssertionError("repair changed the residue class")
            if power(u1, shifted_m, p) != sub(
                power(zeta, shifted_m, p), one, p
            ):
                raise AssertionError(
                    f"repair failed at p={p}, n={n}, n'={shifted_n}"
                )
            repaired_hits += 1

    expected = (144, 110, 34, 144)
    observed = (
        scalar_hits,
        same_index_hits,
        negative_defects,
        repaired_hits,
    )
    if observed != expected:
        raise AssertionError(f"regression mismatch: {observed} != {expected}")
    print(
        "SCALAR COMPLETENESS CHECK PASSED: "
        f"{scalar_hits} scalar hits, {same_index_hits} same-index, "
        f"{negative_defects} negative defects, {repaired_hits} repaired"
    )


if __name__ == "__main__":
    main()
