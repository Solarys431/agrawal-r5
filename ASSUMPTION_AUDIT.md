# Public-instance assumption audit

Audit date: 2026-07-30.

This audit implements gate 5 of the
[UNICO/NOUS two-judge pipeline](https://github.com/Solarys431/unico-lean-proofs/blob/main/PIPELINE.md).
It distinguishes three facts which must not be conflated:

1. an instance binder is part of a theorem's quantified statement;
2. the proposition following that binder may not mention the instance term;
3. the current proof can nevertheless depend on the corresponding
   mathematical structure.

`AssumptionAudit.lean` inspects the kernel-elaborated type of every public
theorem in `AgrawalCore`. The ordinary `lake --wfail build` simultaneously
checks Lean's `unusedSectionVars` linter against the elaborated proof terms.
Together they give a reproducible boundary:

- 579 public theorems inspected;
- 394 instance binders inspected;
- two genuinely removable assumptions eliminated from
  `golden_pow_of_sq` and `golden_pow_pred`;
- 59 instance binders absent from the proposition body but still used by the
  present proof route;
- zero unrecorded debts.

The 59 binders are deliberately retained in 56 exact allowlist entries inside
`AssumptionAudit.lean`. They consist of:

- 49 uses of `[Fact p.Prime]` in finite-field and quotient-ring arguments;
- seven uses of `[Finite G]` in order and power-map arguments;
- three uses of `[IsCyclic G]` in the residual power-depth lemmas.

These are not hidden axioms, `sorry`s, or claims that the hypotheses are
logically minimal. They are a measured limitation of the current
generalization boundary. CI fails if this inventory changes without an
explicit update.

Reproduce the audit with:

```bash
lake --wfail build
lake env lean AssumptionAudit.lean
```

Expected final lines:

```text
Public hypothesis-minimality audit: PASS
  theorems inspected: 579
  instance binders inspected: 394
  generalized assumptions removed in this audit: 2
  declared proof-route debt entries: 56
  declared proof-route binders: 59
  unrecorded debts: 0
```
