#!/usr/bin/env python3
"""
Replay del gap quantizzato sulle terne strutturali del censimento k = 3.

Per una riga locale con prodotto complementare P e primo x:

  ramo puro:     T_x | P - 1       => T_x <= P - 1;
  ramo twisted:  T_x | |P - x^2|  => T_x <= |P - x^2|.

Sulla parte di T_x coprima con 10 vale inoltre x^2 = 1. I due rami
collassano quindi nella singola ombra dispari

  odd10(T_x) | P - 1.

Il programma non ricostruisce il censimento e non modifica il suo dominio:
legge un manifest congelato, verifica le identita' registrate e misura
quanti superstiti di triangolo CRT + taglia cadono gia' nella zona proibita.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def exponent_for(prime: int, nu: int) -> int:
    return 0 if prime % 5 == nu else 2


def prime_to_ten_part(value: int) -> int:
    while value % 2 == 0:
        value //= 2
    while value % 5 == 0:
        value //= 5
    return value


def row_gap(prime: int, other: int, q: int, order: int, nu: int) -> dict[str, Any]:
    exponent = exponent_for(prime, nu)
    complement = other * q
    target = 1 if exponent == 0 else prime * prime
    distance = abs(complement - target)
    odd_core = prime_to_ten_part(order)
    if (prime * prime - 1) % odd_core:
        raise AssertionError(
            f"la parte dispari di T_{prime} non divide {prime}^2-1"
        )
    return {
        "prime": prime,
        "exponent": exponent,
        "order": order,
        "complement": complement,
        "target": target,
        "distance": distance,
        "inside_forbidden_annulus": 0 < distance < order,
        "distance_mod_order": distance % order,
        "odd_core": odd_core,
        "odd_shadow_remainder": (complement - 1) % odd_core,
        "odd_shadow_pass": (complement - 1) % odd_core == 0,
    }


def run(manifest_path: Path) -> dict[str, Any]:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    survivors = manifest["structural_survivors"]
    rows = []
    excluded_by_gap = 0
    excluded_by_odd_shadow = 0
    remaining = 0

    for item in survivors:
        p, r, q = (int(value) for value in item["primes"])
        tp, tr, _ = (int(value) for value in item["orders"])
        nu = p * r * q % 5
        local_rows = [
            row_gap(p, r, q, tp, nu),
            row_gap(r, p, q, tr, nu),
        ]
        gap_pass = not any(row["inside_forbidden_annulus"] for row in local_rows)
        odd_shadow_pass = all(row["odd_shadow_pass"] for row in local_rows)
        if not gap_pass:
            excluded_by_gap += 1
        if not odd_shadow_pass:
            excluded_by_odd_shadow += 1
        if gap_pass and odd_shadow_pass:
            remaining += 1
        rows.append(
            {
                "primes": [p, r, q],
                "branch": int(item["branch"]),
                "h": int(item["h"]),
                "gap_pass": gap_pass,
                "odd_shadow_pass": odd_shadow_pass,
                "rows": local_rows,
            }
        )

    return {
        "status": "PASS",
        "scope": manifest["scope"],
        "input_manifest": str(manifest_path),
        "input_manifest_sha256": sha256(manifest_path),
        "structural_survivors": len(survivors),
        "excluded_by_quantized_gap": excluded_by_gap,
        "remaining_after_quantized_gap": len(survivors) - excluded_by_gap,
        "excluded_by_odd_shadow": excluded_by_odd_shadow,
        "remaining_after_gap_and_odd_shadow": remaining,
        "rows": rows,
        "provenance": {
            "script_sha256": sha256(Path(__file__)),
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = run(args.manifest)
    rendered = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    print(rendered)


if __name__ == "__main__":
    main()
