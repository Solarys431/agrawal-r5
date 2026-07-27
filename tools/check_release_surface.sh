#!/usr/bin/env bash
set -euo pipefail

status=0

if rg -n '\b(sorry|admit|native_decide)\b|^[[:space:]]*(axiom|opaque)[[:space:]]' \
    AgrawalCore AgrawalCore.lean Comparator/*/Solution.lean; then
  echo "Forbidden proof escape hatch found in the verified implementation." >&2
  status=1
fi

while IFS= read -r challenge; do
  if rg -n '^import ' "${challenge}" | rg -v '^.*:import Mathlib([.]|$)'; then
    echo "Challenge imports something outside Mathlib: ${challenge}" >&2
    status=1
  fi
done < <(find Comparator -name Challenge.lean -type f | sort)

if rg -n '^[[:space:]]*import[[:space:]]+(AgrawalCore|Comparator[.].*[.]Solution)' \
    Comparator/*/Challenge.lean; then
  echo "A trusted challenge imports the submitted implementation." >&2
  status=1
fi

challenge_count="$(find Comparator -name Challenge.lean -type f | wc -l | tr -d ' ')"
solution_count="$(find Comparator -name Solution.lean -type f | wc -l | tr -d ' ')"
config_count="$(find Comparator -name config.json -type f | wc -l | tr -d ' ')"

if [[ "${challenge_count}" != "3" || "${solution_count}" != "3" || "${config_count}" != "3" ]]; then
  echo "Comparator surface is incomplete: challenge=${challenge_count}, solution=${solution_count}, config=${config_count}" >&2
  status=1
fi

if [[ "${status}" -ne 0 ]]; then
  exit "${status}"
fi

echo "Release surface audit: PASS"
echo "  implementation: no sorry/admit/native_decide/project axiom/opaque"
echo "  challenges: Mathlib-only and solution-independent"
echo "  comparator triples: 3"
