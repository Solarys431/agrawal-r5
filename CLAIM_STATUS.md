# Claim-by-claim verification status

This file is the public trust boundary for the project. It distinguishes
mathematical novelty, formal verification, paper proofs, finite
certification and open conjectures. A Lean check establishes that a formal
statement follows from its formal hypotheses; it does not establish
historical priority or automatically validate a stronger prose statement.

Status date: 2026-07-28.

## Verification tiers

| Tier | Meaning |
|---|---|
| **LEAN** | The named declaration is proved by Lean 4 over the pinned Mathlib revision, with no `sorry`, `admit`, `native_decide` or project-defined axiom |
| **COMPARATOR** | In addition to **LEAN**, a separate Mathlib-only `Challenge.lean` statement is matched to its submitted solution by pinned `leanprover/comparator` and replayed in the kernel |
| **PAPER** | A mathematical argument is given at paper or audit level, but the complete theorem is not represented end to end by a Lean declaration |
| **CERTIFIED FINITE** | A finite domain is checked by replayable code and certificates; this is not a universal theorem |
| **CONDITIONAL** | The result explicitly assumes H4, GRH, or another named hypothesis |
| **OPEN** | No proof is claimed |

The implementation currently contains 42 `AgrawalCore` modules and 6,056
kernel-source lines. `AxiomAudit.lean` prints the axioms of 54 headline
declarations. Four independent Comparator surfaces export seven statements.

## Headline mathematical claims

| Claim | Verification | Prior-art / novelty posture |
|---|---|---|
| \(U_2=(\sqrt5)^5\varepsilon^3\) and \(\operatorname{ind}_5(U_2)=3\operatorname{ind}_5(\varepsilon)\) | Factorization: **LEAN**, **COMPARATOR** (`golden_moment_factorization`). Index consequence: **LEAN** (`zmod_golden_moment_index`) | Williams–Hardy computed the classical golden-unit index. Only its identification with Agrawal's quadratic moment is a candidate new bridge; priority is provisional |
| Agrawal's congruence at \(r=5\) implies the base-5 Fermat congruence for squarefree \(n\) | **LEAN**, **COMPARATOR**: `agrawal_fermat_shadow` | Underlying implication is classical (Lenstra); the contribution is the end-to-end formalization |
| An odd prime cannot occur simultaneously in a \(p-1\) and a \(p'+1\) Korselt support | **LEAN**: `partition_forced` | The compatibility mechanism is present in Williams/McIntosh/Leng; this is a reusable formal extraction, not a claimed new discovery |
| Local order-four transport is equivalent to support of the mixed Fibonacci–Lucas sequence \(H_n\) | **LEAN**: `hasOrderFourTransport_iff_goldenH_support` | Exact reduction; it does not prove H4 |
| Intrinsic primitive support is equivalent to simultaneous divisibility of four canonical coefficients | Equivalence: **LEAN** (`primitiveFourVanish_iff_dvd_D`). Its exact-order consequence is independently **COMPARATOR**-checked as `four_coefficient_bridge` | Candidate new reduction; the paper-level bridge to the original integral \(G_{r,s}\) remains outside the kernel |
| No split H-profile prime has \(p-1=8q^e\) | **LEAN** (`no_split_single_odd_support`); independently **COMPARATOR**-checked as `single_support_exclusion` | Universal excluded family; priority unassessed |
| Deterministic final-row size bounds and meet-in-the-middle uniqueness | **LEAN**; independently **COMPARATOR**-checked as `three_factor_exclusion` and `second_product_unique` | Exact arithmetic lemmas; no asymptotic multiplicative-order lower bound is claimed |
| Two-row transport, CRT triangle, odd shadow and quantized gaps | **LEAN**: declarations in `TwoRowTransport.lean` | Exact consequences of the row congruences; mathematical priority unassessed |

## Paper-level results not fully represented end to end in Lean

The following are **PAPER** claims. Some have Lean-checked algebraic
sublemmas, but their complete finite-field, Kummer, analytic or global
interfaces are not kernel theorems in this repository:

- the full moment interface \(\operatorname{im}_r(S)\subseteq T\);
- the complete two-lock classification of local exceptions at \(r=5\);
- the lifted golden tower and its per-floor Kummer density;
- the exact order decomposition of \(\zeta_5-1\) and the Kummer
  interpretation of its tail;
- the general-\(s\) finite-fiber reduction;
- density-zero and GRH counting statements;
- the full tail-anomaly Euler-product density.

These claims require ordinary mathematical review of the paper. They must
not be described merely as “Lean verified”.

## Certified finite statements

The repository ships replayable certificates for:

- seven explicitly empty three-factor fibers;
- the \(H_n\) census through its stated index bound;
- the final-row size experiments for the stated \(k=3\) and \(k=5\)
  domains;
- the two-row transport census;
- the sharded three-row triangle census for its stated \(q\)-range;
- the portable H4 audit packages included under `certificates/`.

Each certificate proves only its declared finite statement. Hash-only
provenance files are labelled as such and are not treated as replayable
certificates.

## Open statements

1. **H4 / golden inertia.** It remains open whether every good prime divisor
   of the canonical four-coefficient support is inert in
   \(\mathbb Q(\sqrt5)\).
2. **Global fiber union.** Even under H4, pointwise finiteness of every fiber
   does not prove that their union is empty.
3. **Full Agrawal conjecture.** This project does not prove or disprove it.
4. **Historical priority.** The golden-moment bridge and the newer
   reductions have passed targeted searches, not a definitive specialist
   priority review.

## Reproduction

The release-critical commands are listed in `README.md`. The default CI:

1. builds the pinned Lean project with warnings as errors;
2. prints the axioms of the headline declarations;
3. audits the theorem surface for forbidden escape hatches;
4. runs all four Comparator surfaces;
5. replays the shipped finite certificates.

The authoritative novelty boundary is `NOVELTY_AND_PRIOR_ART.md`.
