#!/usr/bin/env python3
"""Fail-closed structural checker for upstream_candidates.json."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
INVENTORY = ROOT / "upstream_candidates.json"
MODULE_ROOT = ROOT / "AgrawalCore"
ALLOWED_DISPOSITIONS = {
    "candidate",
    "certificate_specific",
    "coordinate_with_existing_project",
    "deduplicate_semantically",
    "generalize_first",
    "literature_specific",
    "mixed",
    "project_specific",
}
ALLOWED_CANDIDATE_STATUSES = {
    "candidate",
    "deduplicate_semantically",
    "generalize_first",
}
DECL_RE = re.compile(
    r"(?m)^(?:theorem|lemma|def|abbrev)\s+([A-Za-z0-9_'.\u2080-\u2089]+)"
)


def fail(message: str) -> None:
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    data = json.loads(INVENTORY.read_text(encoding="utf-8"))
    if data.get("schema") != 1:
        fail("unsupported inventory schema")

    manifest = json.loads((ROOT / "lake-manifest.json").read_text(encoding="utf-8"))
    mathlib = next(
        (package for package in manifest["packages"] if package["name"] == "mathlib"),
        None,
    )
    if mathlib is None:
        fail("mathlib is absent from lake-manifest.json")
    pinned = data["scope"].get("pinned_mathlib_commit")
    if pinned != mathlib["rev"]:
        fail(f"inventory mathlib commit {pinned} != manifest {mathlib['rev']}")

    searches = data["scope"].get("searches", [])
    if not searches or any(search.get("status") != "passed" for search in searches):
        fail("search provenance is absent or contains a non-passing entry")

    actual_modules = {
        str(path.relative_to(ROOT))
        for path in MODULE_ROOT.glob("*.lean")
        if path.is_file()
    }
    rows = data.get("modules", [])
    listed_modules = [row.get("module") for row in rows]
    if len(listed_modules) != len(set(listed_modules)):
        fail("a module occurs more than once")
    if set(listed_modules) != actual_modules:
        fail(
            "module coverage mismatch: "
            f"missing={sorted(actual_modules - set(listed_modules))}, "
            f"extra={sorted(set(listed_modules) - actual_modules)}"
        )

    seen_candidates: set[str] = set()
    candidate_count = 0
    for row in rows:
        module = row["module"]
        disposition = row.get("disposition")
        if disposition not in ALLOWED_DISPOSITIONS:
            fail(f"{module}: invalid disposition {disposition!r}")
        if not row.get("note"):
            fail(f"{module}: missing review note")
        source = (ROOT / module).read_text(encoding="utf-8")
        declared = {f"AgrawalCore.{name}" for name in DECL_RE.findall(source)}
        for candidate in row.get("candidates", []):
            name = candidate.get("declaration")
            status = candidate.get("status")
            if name in seen_candidates:
                fail(f"duplicate candidate {name}")
            seen_candidates.add(name)
            candidate_count += 1
            if name not in declared:
                fail(f"{module}: candidate {name} is not declared in that module")
            if status not in ALLOWED_CANDIDATE_STATUSES:
                fail(f"{name}: invalid candidate status {status!r}")
            if not candidate.get("note"):
                fail(f"{name}: missing candidate note")

    print("Upstream-candidate inventory: PASS")
    print(f"  modules classified: {len(rows)}")
    print(f"  declarations flagged for possible upstream work: {candidate_count}")
    print("  unclassified modules: 0")


if __name__ == "__main__":
    main()
