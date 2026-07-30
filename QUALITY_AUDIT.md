# Formalization quality audit

This note records structural evidence about the Lean implementation. It is
not a mathematical review, a novelty assessment, or a substitute for kernel
checking.

## Scope and method

The exact dependency graph was extracted from the pinned build environment
at source commit `5dad3f7754cc39beef5ca3a6dccb985327783bbe`,
with `lean-code-reuse` at commit
`aeeb9bb8fc873e46d54d2debedbe77d307037917`. The analyzer was extended
locally only to register this checkout and the `AgrawalCore`
namespace. Its exact-tier name-resolution join rate was 99.07%.

These statistics describe that pinned 40-module snapshot. The current
release has 56 modules and 10,847 kernel-source lines; the sixteen later modules
are covered by the kernel, axiom, Comparator and CI checks, but are not
silently folded into the older dependency-graph measurements below.

Because statistical code-quality metrics are sensitive to project size and
can be gamed, no composite score or rank is reported. We use the measurements
only to find concrete review targets. Mathematical trust is instead handled
by the kernel build, `#print axioms`, the independent Challenge/Solution
surface, the official comparator, and certificate replay.

## Exact-environment findings

| Property | Measurement | Interpretation |
|---|---:|---|
| Snapshot modules / declarations | 40 / 323 | Scope of the pinned analyzed namespace |
| Exact dependency edges | 29,678 | Fully elaborated environment graph |
| Dependency depth / cycles | 15 / 0% | Layered, acyclic declaration graph |
| Internal edges crossing files | 50.37% | Modules are used across boundaries |
| Declarations reused at least twice | 35.91% | Nontrivial internal reuse |
| Mean reuse degree | 2.944 | Definitions are not predominantly isolated |
| Statement duplicate rate | 0% | No duplicated theorem statements detected |
| Proof-body duplicate rate | 0.85% | Low syntactic proof duplication |
| Public declaration documentation | 76.04% | Good but not complete; an improvement target |
| Distinct Mathlib declarations used | 762 | Broad use of the pinned library |
| Project axioms / `native_decide` users | 0 / 0 | No project trust shortcut detected |
| `sorry` rate in `AgrawalCore` | 0% | All implementation declarations are filled |

The most reused project objects are the cyclotomic quotient
`AgrawalCore.Phi5Ring`, its root `zeta5`, the golden quotient
`AgrawalCore.GoldenRing`, and the definitions `phi5`, `goldenPoly`,
`cycloEps`, and `eps`. This agrees with the intended architecture: later
theorems reuse a small algebraic core rather than rebuilding it.

## Actions taken from the audit

1. The four implementation files that imported all of `Mathlib` were changed
   to named data/algebra modules plus the tactic bundle. A fresh textual scan
   now finds no exact `import Mathlib` in `AgrawalCore`.
2. Four independent Mathlib-only Challenge surfaces were added, with
   solutions compiled separately and replayed through a pinned official
   comparator.
3. Comparator declarations received their own tracked `#print axioms` audit.
4. Release checks distinguish deliberate `sorry` placeholders in trusted
   `Challenge.lean` statements from the sorry-free submitted implementation.
5. The final-row size module was added only after its deterministic core was
   separated from asymptotic and finite-computation claims; the exact-tier
   audit above was then regenerated on external scratch storage.
6. The public-instance audit inspected 515 theorems and 340 instance binders.
   Two assumptions were generalized away; the remaining 59 proof-route
   dependencies are declared in 56 exact entries and checked fail-closed in
   CI.
7. Every one of the 56 modules is classified in the tracked upstream-candidate
   inventory; 40 declarations are flagged for possible generalization,
   semantic deduplication, or later maintainer review.

## Resource options

Resource overrides are confined to difficult proof modules and finite
kernel evaluation:

| Module | Override | Reason |
|---|---|---|
| `PrimitiveScalarBridge.lean` | `maxHeartbeats 200000` | symbolic scalar bridge |
| `LocalTransport.lean` | `maxHeartbeats 2000000` | four-row transport algebra |
| `ScalarCompleteness.lean` | `maxHeartbeats 3000000` | constructive sign repair |
| `NoncanonicalWitness.lean` | local `maxRecDepth 100000` | two explicit `decide` certificates |

These settings affect elaboration resources, not the trusted proof rules.
There is no `native_decide`.

## Remaining human-review targets

- Raise public declaration documentation coverage where a declaration is
  intended as a reusable API.
- Review the longest proofs (the exact-tier maximum was 130 lines) for
  explanatory intermediate lemmas.
- Have a specialist compare the golden-moment bridge with the primary
  cyclotomy literature.
- Have an independent mathematician compare every paper-level statement with
  its exact Lean declaration or mark it explicitly as non-formalized.

The raw analyzer output was produced on external scratch storage and is not
part of the release artifact. This document records only stable,
human-readable findings; all release-critical checks are reproducible from
the repository itself.
