# Independent theorem surfaces

This repository ships four trusted statement surfaces for
[`leanprover/comparator`](https://github.com/leanprover/comparator).
Each `Challenge.lean` imports only Mathlib and contains the exact statement
with a proof hole.  Its paired `Solution.lean` imports the project proof.
Comparator checks that:

1. every declaration used by the theorem statement is identical;
2. the submitted proof uses only the permitted standard axioms;
3. the proof replays in Lean's kernel.

| Surface | Checked declarations |
|---|---|
| `Comparator/GoldenMoment` | `GoldenMomentChallenge.golden_moment_factorization` |
| `Comparator/FermatShadow` | `FermatShadowChallenge.agrawal_fermat_shadow` |
| `Comparator/PrimitiveSupport` | `four_coefficient_bridge`, `scalar_profile`, `single_support_exclusion` |
| `Comparator/FinalRowSize` | `three_factor_exclusion`, `second_product_unique` |

The universal H4 inertia statement is not among them: it remains open.

## Pinned verifier

The project uses:

- Comparator tag `v4.32.0-rc1`, commit
  `1b82ba006811f7e25d53858252372e4d85fd3921`;
- `lean4export` commit
  `3de59f10bc4b4a0f2de698597aeb1246caa0df0a`, pinned by Comparator;
- Landrun commit
  `c91b41ac6cb180e2fdcb989408dcde34449bd8b0` (the last compatible
  `urfave/cli` v2 revision, including the January 2026 Landlock fix);
- Go `1.24.0` for the CI build;
- the Lean and Mathlib revisions pinned by this repository.

GitHub Actions builds those exact tools and runs all four configurations
with real Landrun.  For a local Linux replay, build Comparator and Landrun,
then run:

```bash
COMPARATOR_ROOT=/path/to/comparator \
COMPARATOR_LANDRUN=/path/to/landrun \
tools/run_comparator.sh
```

On macOS, Comparator's upstream repository provides `scripts/fake-landrun.sh`
for development.  That shim does **not** sandbox the solution.  It must be
enabled explicitly:

```bash
COMPARATOR_ROOT=/path/to/comparator \
COMPARATOR_LANDRUN=/path/to/comparator/scripts/fake-landrun.sh \
ALLOW_UNSANDBOXED_COMPARATOR=1 \
tools/run_comparator.sh
```

The macOS command still checks statement identity, axiom use, export and
kernel replay; it does not provide Landrun's adversarial sandbox guarantee.

## Trust boundary

The challenge files and `lakefile.toml` are part of the trusted input.
Solutions, generated `.olean` files and prose are not.  A reviewer who wants
the strongest sandbox guarantee should follow Comparator's current
`systemd-run` guidance in its upstream README.
