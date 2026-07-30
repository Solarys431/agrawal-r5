# UNICO/NOUS pipeline audit

Audit date: 2026-07-30. Pipeline specification:
[`PIPELINE.md`](https://github.com/Solarys431/unico-lean-proofs/blob/main/PIPELINE.md),
version 1.1.

This document maps every gate of the two-judge pipeline to reproducible
evidence in this repository. It audits the process; it does not upgrade a
paper proof to a Lean theorem or turn an open hypothesis into a result.

## First judge: truth

| Requirement | Evidence | Status |
|---|---|---|
| Pinned kernel build | `lean-toolchain`, `lake-manifest.json`, GitHub Actions | complete |
| Per-theorem axiom measurement | `AxiomAudit.lean` on 147 headline declarations | complete |
| Comparator axiom measurement | `ComparatorAxiomAudit.lean` on seven exported declarations | complete |
| No hidden trust shortcuts | `tools/check_release_surface.sh` rejects `sorry`, `admit`, `native_decide`, project `axiom` and `opaque` in the implementation | complete |
| Statement/solution separation | Four Mathlib-only `Challenge.lean` files and separate `Solution.lean` files | complete |
| Independent statement identity | Pinned `leanprover/comparator` plus `lean4export`, run under pinned Landrun | complete |
| Computational certificates | Checksums, primality, reconstruction, detector and census replay in CI | complete for every shipped certificate |

The expensive full reconstruction of every census value is available through
`python3 tools/verify_certificates.py --full` and the manual GitHub Actions
workflow. Ordinary push CI verifies the shipped manifest and all its rows but
does not silently claim to regenerate the complete census.

## Second judge: taste canon

### 1. Study first

[`NOVELTY_AND_PRIOR_ART.md`](NOVELTY_AND_PRIOR_ART.md) records the dated,
result-by-result prior-art boundary, including primary mathematical sources,
the existing Lean statement in `google-deepmind/formal-conjectures`, and
negative search claims phrased relative to the sources examined.
`formalization.yaml` records source fidelity and the correction of an earlier
false novelty claim.

Status: **complete for this release**, subject to the explicitly invited
specialist/database review. “Complete” means that the prescribed search was
performed and documented, not that an absolute priority theorem is possible.

### 2. Strongest form

The formal core separates reusable algebra from fixed arithmetic:

- the golden factorization is stated over an arbitrary commutative ring;
- the moment obstruction is stated over an arbitrary finite field;
- order-through-a-power results are stated in general finite-order monoids;
- project-specific residue classes remain explicit where the source theorem
  genuinely fixes them.

The mechanical instance-hypothesis test in
[`AssumptionAudit.lean`](AssumptionAudit.lean) inspects every public theorem in
the `AgrawalCore` namespace. It compares binders absent from the proposition
body with an exact, declared proof-route-debt inventory. The companion
`lake --wfail build` checks Lean's proof-aware `unusedSectionVars` linter.
The detailed interpretation and complete counts are in
[`ASSUMPTION_AUDIT.md`](ASSUMPTION_AUDIT.md).

Status: **complete, measured, and mechanically enforced in CI**.

### 3. Invariant route preferred

For the principal developments, two routes were compared before the public
boundary was fixed:

- golden moment: direct cyclotomic-ring factorization versus classical
  cyclotomic-number/Dickson coordinates;
- H4: the scalar Fibonacci–Lucas support formulation versus the intrinsic
  four-coefficient primitive-support formulation;
- global fibers: resultant/finite-fiber elimination versus order-and-size
  transport with meet-in-the-middle uniqueness.

The public Lean core uses coordinates only where they expose the exact
computable object, and the paper states the corresponding intrinsic or
field-theoretic interpretation.

Status: **complete for the published headline routes**.

### 4. Library dividend

[`upstream_candidates.json`](upstream_candidates.json) classifies all 57
tracked modules. [`UPSTREAM_CANDIDATES.md`](UPSTREAM_CANDIDATES.md) explains
the triage, including candidates requiring generalization, semantic
deduplication, or coordination with an existing project. The inventory is
checked by `tools/check_upstream_inventory.py`.

Status: **complete and fail-closed for module coverage**. No upstream proposal
is made without later human maintainer review.

### 5. Hypothesis minimality

`AssumptionAudit.lean` uses Mathlib's elaborated-type dependency analysis on
every public theorem. The audit inspected 534 public theorems and 361 instance
binders. Two assumptions were genuinely generalized away; 59 binders remain
dependencies of the present proof route although their instance terms do not
occur in the proposition body. Those 59 are explicitly declared in 56
allowlist entries, and CI fails on inventory drift. They are not silently
advertised as logically minimal.

Status: **complete, debt-declaring, and mechanically enforced**.

### 6. Prior art searched in-language

The audit covered the pinned Mathlib source and public Lean code search. A
positive canary query (`Nat.Coprime`, restricted to Mathlib) verified that the
remote search surface was live. Exact identifier searches are recorded only
as deduplication signals, never as proofs of semantic novelty. They found, for
example, that `modEq_cancel_left_of_coprime` already existed in Mathlib 3; the
local wrapper therefore carries no originality claim.

Status: **complete for the dated search scope**.

### 7. Originality honestly graded

[`CLAIM_STATUS.md`](CLAIM_STATUS.md) separates Lean theorems, Comparator
statements, paper proofs, certified computations, conditional results and open
problems. [`NOVELTY_AND_PRIOR_ART.md`](NOVELTY_AND_PRIOR_ART.md) grades each
substantive result and identifies the proposed new move: the bridge from
Agrawal's quadratic moment to the classical golden-unit character. Priority is
explicitly provisional.

Status: **complete**.

## Adversarial gates and human boundary

Model-based adversarial pre-review found and repaired substantive errors,
including a false novelty claim and a source-hypothesis mismatch. Those
repairs are encoded in the fidelity log and regression checks. No human
specialist review is claimed. Publication and any future upstream proposal
remain decisions of the human maintainer.

## Reproduction

```console
lake exe cache get
lake --wfail build
lake env lean AxiomAudit.lean
lake env lean AssumptionAudit.lean
lake build Comparator.GoldenMoment.Challenge Comparator.GoldenMoment.Solution
lake build Comparator.FermatShadow.Challenge Comparator.FermatShadow.Solution
lake build Comparator.PrimitiveSupport.Challenge Comparator.PrimitiveSupport.Solution
lake build Comparator.FinalRowSize.Challenge Comparator.FinalRowSize.Solution
lake env lean ComparatorAxiomAudit.lean
tools/check_release_surface.sh
python3 tools/check_upstream_inventory.py
python3 tools/verify_certificates.py
```

The external Comparator and full-census commands are documented in
[`COMPARATOR.md`](COMPARATOR.md) and the main
[`README.md`](README.md).
