#!/usr/bin/env python3
"""Merge and validate contiguous `caccia_triangolo_k3.py` census shards."""

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


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("shards", nargs="+", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    loaded: list[tuple[Path, dict[str, Any]]] = []
    for path in args.shards:
        data = json.loads(path.read_text(encoding="utf-8"))
        if data["status"] not in {"PASS", "COUNTEREXAMPLE"}:
            raise AssertionError(f"stato ignoto in {path}")
        loaded.append((path, data))
    loaded.sort(key=lambda item: item[1]["lower_q_inclusive"])

    expected_lower = loaded[0][1]["lower_q_inclusive"]
    total_counts: dict[str, int] = {}
    structural: list[dict[str, Any]] = []
    exact_hits: list[dict[str, Any]] = []
    shard_manifest: list[dict[str, Any]] = []
    script_hashes: set[str] = set()

    for path, data in loaded:
        lower = data["lower_q_inclusive"]
        upper = data["limit_q_exclusive"]
        if lower != expected_lower:
            raise AssertionError(
                f"intervallo non contiguo: atteso {expected_lower}, trovato {lower}"
            )
        expected_lower = upper
        for key, value in data["counts"].items():
            total_counts[key] = total_counts.get(key, 0) + int(value)
        structural.extend(data["structural_survivors"])
        exact_hits.extend(data["exact_hits"])
        script_hashes.add(data["provenance"]["script_sha256"])
        shard_manifest.append(
            {
                # Store a portable name rather than the machine-local DATIAI path.
                "path": path.name,
                "sha256": sha256(path),
                "lower_q_inclusive": lower,
                "limit_q_exclusive": upper,
                "status": data["status"],
            }
        )

    if len(script_hashes) != 1:
        raise AssertionError(f"versioni script discordi: {sorted(script_hashes)}")

    result = {
        "status": "COUNTEREXAMPLE" if exact_hits else "PASS",
        "scope": (
            "all-inert triples p<r<q with "
            f"{loaded[0][1]['lower_q_inclusive']}<=q<{expected_lower}"
        ),
        "lower_q_inclusive": loaded[0][1]["lower_q_inclusive"],
        "limit_q_exclusive": expected_lower,
        "counts": dict(sorted(total_counts.items())),
        "structural_survivors": structural,
        "exact_hits": exact_hits,
        "shards": shard_manifest,
        "provenance": {
            "search_script_sha256": next(iter(script_hashes)),
            "merge_script_sha256": sha256(Path(__file__)),
        },
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(result, indent=2, sort_keys=True))
    if exact_hits:
        raise SystemExit(2)


if __name__ == "__main__":
    main()
