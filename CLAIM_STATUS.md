# Claim-by-claim verification status

This file is the public trust boundary for the project. It distinguishes
mathematical novelty, formal verification, paper proofs, finite
certification and open conjectures. A Lean check establishes that a formal
statement follows from its formal hypotheses; it does not establish
historical priority or automatically validate a stronger prose statement.

Status date: 2026-07-30.

## Verification tiers

| Tier | Meaning |
|---|---|
| **LEAN** | The named declaration is proved by Lean 4 over the pinned Mathlib revision, with no `sorry`, `admit`, `native_decide` or project-defined axiom |
| **COMPARATOR** | In addition to **LEAN**, a separate Mathlib-only `Challenge.lean` statement is matched to its submitted solution by pinned `leanprover/comparator` and replayed in the kernel |
| **PAPER** | A mathematical argument is given at paper or audit level, but the complete theorem is not represented end to end by a Lean declaration |
| **CERTIFIED FINITE** | A finite domain is checked by replayable code and certificates; this is not a universal theorem |
| **CONDITIONAL** | The result explicitly assumes H4, GRH, or another named hypothesis |
| **OPEN** | No proof is claimed |

The implementation currently contains 59 `AgrawalCore` modules and 12,528
kernel-source lines. `AxiomAudit.lean` prints the axioms of 156 headline
declarations. Four independent Comparator surfaces export seven statements.

## Headline mathematical claims

| Claim | Verification | Prior-art / novelty posture |
|---|---|---|
| \(U_2=(\sqrt5)^5\varepsilon^3\) and \(M_2=3\operatorname{ind}_5(\varepsilon)\) | Factorization: **LEAN**, **COMPARATOR** (`golden_moment_factorization`). Product-to-sum and the concrete \(r=5\) row-to-character interface: **LEAN** (`cyclotomic_quadratic_moment_eq_three_golden_index`, `localS5_canonical_golden_moment_obstruction`, `localS5_canonical_quintic_locks_of_ne_one`) | Williams–Hardy computed the classical golden-unit index. Only its explicit identification with the Agrawal quadratic moment is a candidate new bridge; priority is provisional. Their 22 published Table 5 rows are replayed independently, 22/22, as a normalization check—not as a proof premise or novelty test |
| Agrawal's congruence at \(r=5\) implies the base-5 Fermat congruence for squarefree \(n\) | **LEAN**, **COMPARATOR**: `agrawal_fermat_shadow` | Underlying implication is classical (Lenstra); the contribution is the end-to-end formalization |
| Exact squarefree ingress at \(r=5\): the global congruence is equivalent to `LocalS5 p (n/p)` at every prime factor | **LEAN**: `squarefree_ingress_iff` | Kernel completion of the arithmetic interface used by the paper's structure theorem; no novelty claim is made for the classical Frobenius reduction |
| A good local row of residue \(2\) or \(3\bmod5\) is automatically odd and therefore yields the normalized order-four witness | **LEAN**: `localS5_orderFour_odd`, `hasOrderFourTransport_of_local` | Removes a previously implicit parity seam by comparing the rows at \(\zeta\) and \(\zeta^{-1}\); priority unassessed |
| Every squarefree counterexample candidate has either a split order-four witness or an odd inert quartic skeleton with at least three prime factors | **LEAN**: `squarefree_counterexample_concrete_dichotomy`, `quarticSkeleton_card_ge_three` | The global-to-quartic reduction is kernel-checked. `explicitResultantRows_of_skeleton` now continues every skeleton factor to its literal pure/twisted resultant row; compatible-prefix CRT assembly and universal fiber emptiness remain **PAPER/OPEN** |
| Every literal quartic row is congruent to the corresponding Frobenius power modulo \(\operatorname{lcm}(\operatorname{ord}(\zeta_5-1),5)\); at every inert skeleton factor the residue determines \(j=0\) when \(p\equiv n\pmod5\) and \(j=2\) otherwise | **LEAN**: `localS5_modEq_frobenius_power_lcm`, `inertQuotient_residue_determined`, `determinedQuarticOrderRows_of_skeleton`, `squarefree_counterexample_order_dichotomy` | This kernel-checks the exact labelled order-rigidity interface used by the explicit CRT system. It does not construct or empty the terminal resultant fibers |
| For an inert prime \(q\), a literal pure or twisted final `LocalS5` row forces \(q^4\) to divide a fixed nonzero explicit integer resultant and satisfies \(q^4\le|\operatorname{Res}|\le16\cdot5^A\) | **LEAN**: `prime_pow_natDegree_dvd_resultant_of_common_root`, `pure_row_pow_four_dvd_resultant`, `twisted_row_pow_four_dvd_resultant`, `pure_resultant_ne_zero`, `twisted_resultant_ne_zero`, `pure_resultant_natAbs_le`, `twisted_resultant_natAbs_le`, `pure_row_pow_four_le_sixteen_mul_five_pow`, `twisted_row_pow_four_le_sixteen_mul_five_pow` | The full inert-degree contribution, nonvanishing certificate \(\operatorname{Res}\equiv1\pmod5\), and exact closed-form archimedean estimate are kernel-checked |
| Every quartic skeleton factor lands in the correct explicit pure/twisted resultant fiber, with fourth-power divisibility and the closed-form size bound | **LEAN**: `quotient_gt_one_of_quarticSkeleton`, `explicitResultantRows_of_skeleton`, `squarefree_counterexample_explicit_resultant_dichotomy`, `no_squarefree_counterexample_of_no_split_and_no_explicit_rows` | This closes the formerly abstract skeleton-to-terminal-resultant interface for every number of factors and packages the exact two-wall closure. It does **not** prove either open wall or that any terminal fiber is empty |
| Every two-prime candidate violating \(n^2\equiv1\pmod5\) has a split local order-four witness; local H4 therefore excludes it | **LEAN**: `two_prime_candidate_has_splitOrderFourWitness`, `no_two_prime_candidate_of_localH4` | Unconditional reduction of the bifactor case to H4, followed by an explicitly conditional closure. It does not prove H4 and therefore does not settle the bifactor case unconditionally |
| An odd prime cannot occur simultaneously in a \(p-1\) and a \(p'+1\) Korselt support | **LEAN**: `partition_forced` | The compatibility mechanism is present in Williams/McIntosh/Leng; this is a reusable formal extraction, not a claimed new discovery |
| Local order-four transport is equivalent to support of the mixed Fibonacci–Lucas sequence \(H_n\) | **LEAN**: `hasOrderFourTransport_iff_goldenH_support` | Exact reduction; it does not prove H4 |
| Intrinsic primitive support is equivalent to simultaneous divisibility of four canonical coefficients | Equivalence: **LEAN** (`primitiveFourVanish_iff_dvd_D`). Its exact-order consequence is independently **COMPARATOR**-checked as `four_coefficient_bridge` | Candidate new reduction; the paper-level bridge to the original integral \(G_{r,s}\) remains outside the kernel |
| Level reciprocity for a good split primitive divisor: if \(p-1=4rs\,h\), then \(h\) is even iff \(p\equiv1\pmod5\), and (since \(5\nmid4rs\)) iff \(5\mid h\) | **LEAN** (`dvd_D_residual_multiplier_even_iff_mod_five_one`, `dvd_D_residual_multiplier_even_iff_five_dvd`, `dvd_D_residual_multiplier_mod_ten_table`, `dvd_D_class_specific_lower_bounds`) | Universal restriction eliminating five of the ten residual classes; for fixed \(rs\bmod5\), only two classes remain, the odd one is explicitly \(7,1,9,3\), and the resulting four lower bounds are kernel-checked. It does not prove H4. The Gaussian-period core is classical; priority of this H4 application is unassessed |
| Residual power depth: for \(d>0\), \(d\mid4rs\), one has \(-\gamma\in(\mathbb F_p^\times)^d\iff d\mid h\); for even \(d\), equivalently \(\operatorname{lcm}(d,5)\mid h\) | **LEAN** (`shifted_generator_isPower_iff`, `neg_isPower_iff_residual_multiplier_dvd`, `dvd_D_neg_gamma_isPower_iff_dvd`, `dvd_D_neg_gamma_isPower_iff_lcm_five_dvd`) | The cyclic-group core is classical in spirit; its exact primitive-H4 specialization and priority are unassessed. The quartic corollary is \(-\gamma\in(\mathbb F_p^\times)^4\iff20\mid h\). This refines level reciprocity but does not prove H4 |
| Order-product compression in the \(p\equiv1\pmod5\) branch: \(10\,\operatorname{ord}_p(5)\operatorname{ord}_p(\varepsilon^2)\mid p-1\) | **LEAN** (`dvd_D_order_product_residual_factorization`, `dvd_D_ten_mul_order_product_dvd_card_sub_one`) | Exact repackaging of the primitive scalar orders and level reciprocity. It isolates the missing multiplicative-order lower bound but does not supply it and does not prove H4 |
| No split H-profile prime has \(p-1=2^bq^e\) for \(b\in\{3,4,5,6\}\) | **LEAN** (`no_split_single_odd_support`, `no_split_single_odd_support_sixteen_primitive`, `no_split_single_odd_support_thirtytwo_primitive`, `no_split_single_odd_support_sixtyfour_primitive`); the \(b=3\) core is independently **COMPARATOR**-checked as `single_support_exclusion` | Four universal excluded families. No claim is made for \(b\ge7\); priority unassessed |
| Deterministic final-row size bounds, their sharp pure/twisted quartic-skeleton application, and meet-in-the-middle uniqueness | **LEAN**: `quarticSkeleton_orderModulus_le_max`, `quarticSkeleton_orderModulus_le_gap`, `quarticSkeleton_factor_size_exclusion`; the arithmetic core is independently **COMPARATOR**-checked as `three_factor_exclusion` and `second_product_unique` | The exact displayed gap bound and universal size exclusion are now connected to the literal skeleton modulus. No asymptotic multiplicative-order lower bound or universal fiber emptiness is claimed |
| Canonical odd tail and complete support-gap incidence triangle | **LEAN**: `quarticOrderModulus_dvd_ten_mul_sq_sub_one`, `quarticOddTail_dvd_sq_sub_one`, `quarticOddTail_incidenceTriangle`, `quarticOddTail_incidenceBounds`, `quarticOddTail_oversize_exclusion` | The component of the concrete row modulus away from \(2,5\) divides \(p^2-1\); every pairwise shared tail divides, and hence is bounded by, the corresponding prime gap. This is a deterministic rejection criterion, not a universal incompatibility theorem; a lower bound forcing one oversized shared tail remains **OPEN** |
| Exact norm-visible two-jaw decomposition of the canonical odd tail | **LEAN**: `localCyclotomicUnit_pow_normExponent_eq_five`, `quarticMinusJaw_eq_gcd_oddTail_sub_one`, `quarticOddTail_eq_mul_jaws`, `quarticJaws_coprime`, `quarticCrossJaws_partition_of_incidence`, `quarticCrossJaw_dvd_two` | The literal norm identity \(u^{1+p+p^2+p^3}=5\) yields \(D_p=D_{p,-}D_{p,+}\), with \(D_{p,-}=\gcd(D_p,p-1)\), \(D_{p,+}\mid p+1\), and coprime jaws. Under row incidence, a shared odd prime cannot change sign between two rows. This realizes the classical support-partition mechanism inside the exact quartic modulus; it still does not force a shared prime or a sign change, so universal incompatibility remains **OPEN** |
| Exact norm-kernel and signed-incidence refinements | **LEAN**: `orderOf_localFiveUnit_eq_cyclotomic_div_gcd_normExponent`, `cyclotomic_order_eq_five_order_mul_normKernelFactor`, `quarticSharedTail_gcd_eq_sameSignProduct_of_incidence`, `quarticSignedIncidenceTriangle` | The full order satisfies \(T_p=\operatorname{ord}_p(5)\gcd(T_p,1+p+p^2+p^3)\). Every shared odd tail is exactly the product of its same-sign overlaps, and that product divides the prime gap. No lower bound forcing either overlap to be nontrivial or large is claimed |
| No 5-smooth split H-profile | **LEAN**: `no_split_five_smooth_primitive_support` | In the branch \(p\equiv1\pmod5\), no good primitive H4 divisor has \(p-1=2^b5^f\). This is an unconditional infinite-family exclusion, not a proof of H4 |
| Exact binary law \(v_2(T_p)=v_2(p^2-1)+1\), common depth, and exact labelled dyadic rays for the complete three-row system | **LEAN**: `localCyclotomicUnit_order_factorization_two`, `quarticOrderModulus_factorization_two`, `quarticThreeRows_common_dyadicDepth`, `quarticThreeRows_exact_dyadicRays` | This classifies the complete binary projection of the quartic CRT triangle. It is a consequence of the exact rows, not an additional sieve after them, and it does not constrain or empty the remaining odd Kummer tails; priority unassessed |

## Paper-level results not fully represented end to end in Lean

The following are **PAPER** claims. Some have Lean-checked algebraic
sublemmas, but their complete finite-field, Kummer, analytic or global
interfaces are not kernel theorems in this repository:

- the general-\(r\) moment interface
  \(\operatorname{im}_r(S)\subseteq T\) from the complete external
  definition of \(S(p,r)\); the concrete \(r=5\) `LocalS5` row-to-character
  seam is **LEAN**;
- the complete two-lock classification of local exceptions at \(r=5\);
- the lifted golden tower and its per-floor Kummer density;
- the Kummer-field interpretation and distribution of the two exact odd
  jaws. Their norm-visible decomposition and coprimality are **LEAN** in
  `QuarticNormJaw.lean`, and the exact binary law is **LEAN** in
  `CyclotomicDyadic.lean`;
- compatible-prefix CRT assembly and the complete global fiber-emptiness
  theorem. The skeleton-to-terminal-resultant assembly, the literal
  implications \(q^4\mid\operatorname{Res}\ne0\), and the closed estimate
  \(q^4\le|\operatorname{Res}|\le16\cdot5^A\) are **LEAN**;
- density-zero and GRH counting statements;
- the full tail-anomaly Euler-product density.

These claims require ordinary mathematical review of the paper. They must
not be described merely as “Lean verified”.

## Certified finite statements

The repository ships replayable certificates for:

- an independent end-to-end finite audit of the golden bridge for every
  \(p\equiv1\pmod5\), \(p<10\,000\), including all relevant exponent
  classes;
- seven explicitly empty three-factor fibers;
- the \(H_n\) census through its stated index bound;
- the final-row size experiments for the stated \(k=3\) and \(k=5\)
  domains;
- the two-row transport census;
- the sharded three-row triangle census for its stated \(q\)-range;
- the portable H4 audit packages included under `certificates/`.
- the complete H4 prime-first interval \(10^9\le p<10^{10}\), with
  202,100,126 split primes, 9,622,566 exactly factored dyadic
  candidates, zero full profiles, and an independently replayed
  minimum-gcd witness.

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
