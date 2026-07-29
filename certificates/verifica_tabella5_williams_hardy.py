#!/usr/bin/env python3
"""Replay indipendente della Tabella 5 di Williams--Hardy (1985).

Fonte primaria:
  K. S. Williams, K. Hardy,
  "A congruence for the index of a unit of a real abelian number field",
  Acta Arith. 46 (1985), Theorem 5, equation (6.5), Table 5.

Per ogni riga pubblicata:
  * ricostruisce zeta = g^((p-1)/5);
  * ricostruisce la stessa sqrt(5) scelta da Williams--Hardy;
  * verifica il loro ind_5(epsilon) = -u + 3v;
  * calcola direttamente il prodotto U_2 del momento aureo;
  * verifica U_2 = sqrt(5)^5 epsilon^3;
  * verifica M_2 = ind_5(U_2) = 3 ind_5(epsilon).

Usa soltanto la libreria standard di Python.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Row:
    p: int
    g: int
    x: int
    u: int
    v: int
    w: int
    epsilon_index: int


# Trascrizione della Tabella 5, colonne p, g, x, u, v, w,
# ind( (1 + sqrt(5))/2 ) modulo 5.
TABLE_5 = (
    Row(11, 2, 1, 0, 1, 1, 3),
    Row(31, 3, 11, -2, -1, -1, 4),
    Row(41, 6, -9, 0, 3, -1, 4),
    Row(61, 2, 1, -4, 1, 1, 2),
    Row(71, 7, -19, 2, 3, 1, 2),
    Row(101, 2, -29, 2, -3, -1, 4),
    Row(131, 2, 11, -6, 1, -1, 4),
    Row(151, 6, -4, -2, 2, -4, 3),
    Row(181, 2, 11, -2, -7, -1, 1),
    Row(191, 19, 41, -4, 3, 1, 3),
    Row(211, 2, 1, 2, -1, 5, 0),
    Row(241, 7, 16, 4, 4, -4, 3),
    Row(251, 6, -4, 2, 6, 4, 1),
    Row(271, 6, 31, -8, 1, -1, 1),
    Row(281, 3, 11, -4, -3, -5, 0),
    Row(311, 17, -49, 7, 0, 1, 3),
    Row(331, 3, 61, 2, -5, 1, 3),
    Row(401, 3, -29, 10, -3, -1, 1),
    Row(421, 2, -19, 8, 1, 5, 0),
    Row(431, 7, 36, 6, 6, -4, 2),
    Row(461, 2, 1, -2, -9, 5, 0),
    Row(491, 2, -9, -12, 3, -1, 1),
)


def prime_factors(n: int) -> set[int]:
    factors: set[int] = set()
    divisor = 2
    while divisor * divisor <= n:
        while n % divisor == 0:
            factors.add(divisor)
            n //= divisor
        divisor += 1
    if n > 1:
        factors.add(n)
    return factors


def is_primitive_root(g: int, p: int) -> bool:
    return all(pow(g, (p - 1) // ell, p) != 1 for ell in prime_factors(p - 1))


def check_row(row: Row) -> tuple[int, int, int]:
    p, g = row.p, row.g
    assert p % 5 == 1
    assert is_primitive_root(g, p), f"g={g} non primitiva modulo p={p}"

    f = (p - 1) // 5
    zeta = pow(g, f, p)
    assert pow(zeta, 5, p) == 1 and zeta != 1

    # Williams--Hardy, Theorem 5:
    # sqrt(5) = g^f - g^(2f) - g^(3f) + g^(4f).
    sqrt5 = (
        zeta
        - pow(zeta, 2, p)
        - pow(zeta, 3, p)
        + pow(zeta, 4, p)
    ) % p
    assert sqrt5 * sqrt5 % p == 5 % p
    epsilon = (1 + sqrt5) * pow(2, -1, p) % p

    # Se value = g^d, allora value^f = zeta^d e questo recupera d modulo 5.
    zeta_indices: dict[int, int] = {}
    value = 1
    for index in range(5):
        zeta_indices[value] = index
        value = value * zeta % p

    def ind5(value: int) -> int:
        return zeta_indices[pow(value % p, f, p)]

    published_index = row.epsilon_index % 5
    dickson_index = (-row.u + 3 * row.v) % 5
    computed_epsilon_index = ind5(epsilon)

    assert dickson_index == published_index, (
        f"Tabella/Dickson non concordano per p={p}: "
        f"{published_index=} {dickson_index=}"
    )
    assert computed_epsilon_index == published_index, (
        f"Indice epsilon non concorde per p={p}: "
        f"{published_index=} {computed_epsilon_index=}"
    )

    weights = {a: (a * a) % 5 for a in range(1, 5)}
    pieces = {a: (pow(zeta, a, p) - 1) % p for a in range(1, 5)}

    u2 = 1
    for a in range(1, 5):
        u2 = u2 * pow(pieces[a], weights[a], p) % p

    factorized_u2 = pow(sqrt5, 5, p) * pow(epsilon, 3, p) % p
    assert u2 == factorized_u2, f"Fattorizzazione U2 fallita per p={p}"

    moment_from_product = ind5(u2)
    moment_from_sum = sum(weights[a] * ind5(pieces[a]) for a in range(1, 5)) % 5
    predicted_moment = 3 * published_index % 5

    assert moment_from_product == moment_from_sum, f"Due M2 discordi per p={p}"
    assert moment_from_product == predicted_moment, (
        f"Ponte aureo fallito per p={p}: "
        f"{moment_from_product=} {predicted_moment=}"
    )

    return published_index, moment_from_product, predicted_moment


def main() -> None:
    print("Williams--Hardy Table 5 vs golden moment")
    print("p    ind5(epsilon)    M2 direct    3*ind5(epsilon)")
    print("-" * 58)

    for row in TABLE_5:
        epsilon_index, moment, predicted = check_row(row)
        print(f"{row.p:3d}         {epsilon_index}              {moment}               {predicted}")

    print("-" * 58)
    print(f"PASS: {len(TABLE_5)}/{len(TABLE_5)} righe pubblicate concordano.")
    print("Controllati: radice primitiva, scelta di sqrt(5), formula di Dickson,")
    print("indice di epsilon, fattorizzazione U2 e identita M2 = 3*ind5(epsilon).")


if __name__ == "__main__":
    main()
