# Upstream-candidate inventory

This release classifies every tracked `AgrawalCore` module in
[`upstream_candidates.json`](upstream_candidates.json). The inventory records
which auxiliary declarations might repay Mathlib review, which first need a
more invariant or general statement, which must be deduplicated semantically,
and which are intentionally project-specific.

The word **candidate** is deliberately weak. It is not a novelty claim, an
upstream proposal, or evidence that a Mathlib maintainer would accept the
current statement or name. No upstream issue or pull request has been opened.

## Reproducible scope

- Audit date: 2026-07-29.
- Mathlib: pinned commit
  `4a7edd35ec64de7117995da659e9d4d80e6cca19`.
- Every one of the 49 tracked `AgrawalCore/*.lean` modules has exactly one
  disposition.
- Candidate identifiers were searched in the pinned source and through
  GitHub's Lean code search. A positive canary query against
  `Nat.Coprime` verified that the remote search surface was working.
- Exact-name absence is not treated as semantic novelty. Entries marked
  `deduplicate_semantically` require a maintainer-level API comparison.
- That search found one concrete historical duplicate:
  `modEq_cancel_left_of_coprime` already existed in Mathlib 3's
  `data/nat/modeq.lean`. The local Lean 4 wrapper therefore carries no
  originality claim.

Run the fail-closed coverage check with:

```console
python3 tools/check_upstream_inventory.py
```

The check verifies the pinned Mathlib revision, complete module coverage,
candidate existence and uniqueness, permitted status vocabulary, and recorded
search provenance.

## Triage summary

The strongest self-contained candidates are:

- the commutative-ring box identity
  `prod_pairs_sub_prod_squares`;
- the generic character calculation
  `quintic_index_of_fifth_mul_cube`;
- the four order-through-a-power declarations in `NormOrder.lean`;
- the generic cyclic-group power-map criterion and residual-index depth
  principle in `DyadicDepth.lean`, pending semantic deduplication and a more
  invariant statement;
- elementary `Nat.ModEq` interval and bounded-representative lemmas.

Several other declarations are mathematically reusable but should first be
generalized out of the fixed golden/cyclotomic setting. The complete,
module-by-module judgment and the reason for every non-candidate module live in
the JSON inventory so that additions cannot silently escape review.
