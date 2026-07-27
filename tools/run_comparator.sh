#!/usr/bin/env bash
set -euo pipefail

readonly EXPECTED_COMPARATOR_COMMIT="1b82ba006811f7e25d53858252372e4d85fd3921"

if [[ -z "${COMPARATOR_ROOT:-}" ]]; then
  echo "COMPARATOR_ROOT must point to leanprover/comparator at v4.32.0-rc1" >&2
  exit 2
fi

readonly comparator_bin="${COMPARATOR_ROOT}/.lake/build/bin/comparator"
readonly lean4export_bin="${COMPARATOR_ROOT}/.lake/packages/lean4export/.lake/build/bin/lean4export"
readonly landrun_bin="${COMPARATOR_LANDRUN:-}"

if [[ ! -x "${comparator_bin}" ]]; then
  echo "Comparator binary not found: ${comparator_bin}" >&2
  exit 2
fi
if [[ ! -x "${lean4export_bin}" ]]; then
  echo "lean4export binary not found: ${lean4export_bin}" >&2
  exit 2
fi
if [[ -z "${landrun_bin}" || ! -x "${landrun_bin}" ]]; then
  echo "COMPARATOR_LANDRUN must name an executable Landrun binary" >&2
  exit 2
fi

if command -v git >/dev/null 2>&1 && [[ -d "${COMPARATOR_ROOT}/.git" || -f "${COMPARATOR_ROOT}/.git" ]]; then
  actual_commit="$(git -C "${COMPARATOR_ROOT}" rev-parse HEAD)"
  if [[ "${actual_commit}" != "${EXPECTED_COMPARATOR_COMMIT}" ]]; then
    echo "Comparator commit mismatch: ${actual_commit}" >&2
    echo "Expected: ${EXPECTED_COMPARATOR_COMMIT}" >&2
    exit 2
  fi
fi

if grep -q "NOT REAL LANDRUN" "${landrun_bin}" 2>/dev/null; then
  if [[ "${ALLOW_UNSANDBOXED_COMPARATOR:-0}" != "1" ]]; then
    echo "Refusing fake Landrun without ALLOW_UNSANDBOXED_COMPARATOR=1" >&2
    exit 2
  fi
  echo "WARNING: running Comparator without a sandbox (explicitly allowed)." >&2
fi

readonly configs=(
  "Comparator/GoldenMoment/config.json"
  "Comparator/FermatShadow/config.json"
  "Comparator/PrimitiveSupport/config.json"
)

for config in "${configs[@]}"; do
  echo "==> comparator ${config}"
  COMPARATOR_LANDRUN="${landrun_bin}" \
  COMPARATOR_LEAN4EXPORT="${lean4export_bin}" \
    lake env "${comparator_bin}" "${config}"
done
