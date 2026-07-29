# Novelty and prior-art map

Public conservative assessment — updated 2026-07-30. “Potentially new” means
that a targeted search did not find the statement; it does not replace review
by a specialist in cyclotomy or primality testing. Corrections and earlier
references are explicitly welcome.

## Verified source-level audit (updated 2026-07-29)

The following boundaries were checked against primary texts, not inferred
from titles or secondary summaries.

| Source | What the source actually contains | Consequence for this project |
|---|---|---|
| Lenstra–Pomerance, AIM notes (2003) | The conjugation identity for \(\zeta _5-1\), the divisibility of its order by \(10(p^2-1)\), and the sufficient paired conditions \(p_i-1\mid n-1\), \(p_i+1\mid n+1\) | None of these ingredients is claimed as new |
| Váňa (2009), Lemmas 3.3–3.4 | Multiplicative relations among the residue exponents, the ring-level bound \(\rho\mid10(\lambda^2-1)\), and a CRT-combinable Korselt system | The field-component localization, exact decomposition and necessity results are presented as refinements, not as the first CRT reduction |
| Popovych (2009) | The subgroup-growth paradigm in the cyclotomic quotient and a generalization of Lenstra’s construction | The use of cyclotomic subgroups is prior art |
| Williams–Hardy (1985), Theorem 5 and Remark 2 | The exact quintic index of the golden unit in Dickson coordinates and its fifth-power criterion | Only the bridge from Agrawal’s quadratic moment to that classical character is a candidate new contribution |
| Breuer (2020/2021) | Multiplicative orders of Gauss periods and their relation with units of real quadratic fields, including the \(p=5\) quadratic field | Adjacent prior art for the general cyclotomic/quadratic-unit theme; it uses the Gauss period and an inert-prime order problem, not the split-prime identity \(M_2=3\operatorname{ind}_5(\varepsilon)\) |
| Corrales-Rodrigáñez–Schoof (1997) | A support theorem whose hypothesis quantifies over every exponent and almost all primes | It does not directly settle the moving-exponent, finite-support problem here |
| Bilu–Hanrot–Voutier (2001) | Primitive divisors for Lucas and Lehmer sequences beyond the uniform exceptional range | The fourth-order norm sequences used in the fiber analysis are outside that direct Lucas/Lehmer hypothesis; the BHV threshold is not imported |

The exact golden-index formula is attributed to Williams–Hardy rather than
to Dickson alone. Dickson’s cyclotomy supplies classical coordinates, but a
change of conventions is not treated as an attribution of the later unit
index theorem.

The formalization search found the current
[`FormalConjectures/Wikipedia/Agrawal.lean`](https://github.com/google-deepmind/formal-conjectures/blob/main/FormalConjectures/Wikipedia/Agrawal.lean),
which states Agrawal’s conjecture and Popovych’s variant with proof holes.
It is a benchmark of statements, not prior proof formalization. Targeted
GitHub and literature searches found no exact match for the golden-moment
bridge, but this is negative search evidence only. The release therefore
makes no absolute claim such as “first formalization” or “first theorem”.

Publication-safe wording:

> Williams and Hardy computed the classical quintic character of the golden
> unit. We formalize an exact factorization showing that Agrawal’s quadratic
> moment realizes that character. We did not find this bridge in the
> targeted literature search and welcome prior-art corrections.

## The result to lead with

| Result | Kernel status | Prior art | Current novelty assessment |
|---|---|---|---|
| `U₂ = (√5)⁵ ε³` and `M₂ = 3 ind₅(ε)` | Factorization Lean-checked in `GoldenMoment.lean`; exact product-to-sum interface in `GoldenMomentBridge.lean`; concrete `LocalS5` row-to-same-character covariance and obstruction in `LocalMomentBridge.lean` | Williams–Hardy (1985), Theorem 5, computes `ind₅(ε)` in Dickson coordinates; Breuer is adjacent but studies a different period/order problem | **Potentially new bridge.** The classical side is the golden-unit character; the proposed new content is that Agrawal’s quadratic moment is exactly that character. Specialist priority check required. |

This is the scientifically strongest release narrative because it has all
four properties at once:

1. a short exact statement;
2. a transparent four-line algebraic proof;
3. a direct connection between two previously separate theories;
4. a kernel-checked implementation that starts from the literal
   quotient-ring predicate `LocalS5` and uses one actual quintic character
   on both the local rows and the golden unit, not two independently
   normalized indices.

As an external normalization check, the reproducible script
`certificates/verifica_tabella5_williams_hardy.py` compares the directly
computed \(M_2\) with three times every one of the 22 golden-unit indices in
Williams--Hardy Table 5 and obtains 22/22 agreement.  This is not a premise of
the Lean theorem, not a universal proof and not evidence of historical
priority.

The public claim must remain:

> We formalize the factorization of the quadratic moment unit, the exact
> product-to-sum interface with Agrawal's additive moment, and its consequence
> for every quintic index. We did not find this explicit identification in the
> targeted literature search and welcome prior-art corrections.

It must **not** become:

> We discovered the quintic character of the golden unit.

That character is classical.

## Results whose value is primarily formal

| Result | Mathematical ownership | Formalization value |
|---|---|---|
| Lenstra–Pomerance proposition under its original hypotheses | Lenstra–Pomerance, AIM notes (2003) | A complete Lean verification of a proposition used in the literature and, in the targeted search, not previously machine-checked |
| Agrawal congruence implies \(r^n\equiv r\pmod n\) | Lenstra, AIM Problems, Remark 5 (2003) | End-to-end Lean verification of the squarefree \(r=5\) specialization |
| Korselt implication to Fermat pseudoprimality | Classical | Fills a Mathlib-facing infrastructure gap needed by the development |
| Bounded order of `ζ−1` | Lenstra–Pomerance for the relevant class | Division-free formal proof; the second inert class is a small extension, not a headline |

These results are worth publishing as formalization, but no mathematical
novelty should be claimed for their underlying arguments.

## New-looking but elementary consequences

| Result | Status | Release posture |
|---|---|---|
| Abstract moment covariance and obstruction | Lean-checked | This is the exact finite-sum engine behind `im_r(S) ⊆ T`; the full interface to `S(p,r)` is not yet in the public core |
| Agrawal congruence at `r=5` forces the base-5 Fermat congruence for squarefree `n` | Lean-checked | Classical consequence due to Lenstra; claim novelty only for the Lean formalization |
| Exact squarefree ingress at `r=5` | Lean-checked end to end | `squarefree_ingress_iff` proves the global congruence equivalent to the complementary local rows `LocalS5 p (n/p)`. This is the classical CRT/Frobenius reduction specialized and formalized, not a new mathematical claim. |
| Two-prime candidates reduce to a split order-four witness | Lean-checked end to end | `two_prime_candidate_has_splitOrderFourWitness` is an unconditional formal assembly of the mod-5 partition, the squarefree ingress and local transport closure. `no_two_prime_candidate_of_localH4` then closes the branch under explicitly stated local H4. No claim of mathematical priority is made; H4 itself remains open. |
| Two-adic jaw on inert prime factors | Lean-checked | Useful corollary and good formal theorem; no priority claim |
| Canonical inert support witness for `H_n` | Lean-checked | Useful exact explanation of the census; no broad novelty claim |
| Golden–cyclotomic entanglement identity | Lean-checked | Structural identity supporting the main story; priority unassessed |
| Forced odd-\(q\) partition for simultaneous Carmichael/Lucas–Carmichael conditions | Lean-checked | **Classical mathematics, new formalization.** McIntosh (2014) explicitly records the Williams-set compatibility \(\gcd(p_i-1,p_j+1)=2\); Leng (2017) records \(n\equiv p\bmod (p^2-1)/2\) and the mod-12 consequence. The present contribution is a reusable kernel proof, including the arbitrary-common-divisor form `common_divisor_forced` and the named mod-3 corollary. |
| Cubic Lenstra signature versus the strong complementary row | Lean-checked | Elementary equivalence, included as a negative result of orientation: the cubic parameters repackage the row and must not be counted as an independent obstruction |
| Arithmetic profile of \(H_n\) and the 2-adic saturation wall | Lean-checked | Exact formal reduction, not a proof of H4: `dvd_goldenH_iff_scalar_profile` identifies divisibility by \(H_n\) with the two negative scalar semiperiods, and `dvd_goldenH_nonsquare_iff_two_adic_saturation` proves that inertia is equivalent to saturation of \(v_2(p-1)\). Priority for the elementary reduction is unassessed; no novelty claim beyond this explicit formal package should be made. |
| Local order-four transport is equivalent to support of \(H_n\) | Lean-checked end to end | `LocalTransport.lean` proves the necessary direction from the literal row. `ScalarCompleteness.lean` proves the converse existentially: a common defect is globally `+1` or `−1`; the negative sign is repaired by an explicit index shift. The precise declaration is `hasOrderFourTransport_iff_goldenH_support`. This proves the scalar-completeness reduction, **not H4**: excluding split prime factors from every \(H_n\) remains open. Priority is unassessed. |
| Four-coefficient primitive support and the \(p-1=8q^e\) exclusion | Intrinsic bridge and universal single-support exclusion Lean-checked; original integral \(G_{r,s}\)-bridge paper-audited | The kernel defines the exact support \(\gcd(c_{r,s},d_{r,s},U_k+1,U_{k-1}+1)\), checks both components above a split prime, and derives the exact scalar orders from its good divisors. `SingleSupportExclusion.lean` proves the complete \(p-1=8q^e\) exclusion. The remaining formal boundary is the paper's aurean integer \(B_s\) and its exact-level identification with the original cyclotomic gcd \(G_{r,s}\). No exact match was found in the targeted sources, but priority remains provisional pending specialist review and a complete database search. This is a reduction of H4, not a proof of H4. |
| Level reciprocity for primitive H4 divisors | Lean-checked | For \(p-1=4rs\,h\), the kernel proves \(h\) even iff \(p\equiv1\pmod5\), and in the good range iff \(5\mid h\). For fixed \(rs\bmod5=1,2,3,4\), the \(p\equiv4\) branch forces \(h\bmod10=7,1,9,3\), so only two classes remain for each level. The square criterion is a Gaussian-period calculation and should not be advertised as new in isolation. The application to the mobile H4 level may be new, but priority is unassessed. This is a genuine class-specific restriction and does **not** prove H4. |
| Residual power depth at primitive H4 levels | Lean-checked | For every positive \(d\mid4rs\), the kernel proves \(-\gamma\in(\mathbb F_p^\times)^d\iff d\mid h\); for even \(d\), level reciprocity strengthens this to \(\operatorname{lcm}(d,5)\mid h\). The underlying power-map criterion is standard cyclic-group mathematics, and the exact H4 application has not undergone a dedicated priority search. It is presented as a formal structural refinement, not as a proof of H4 or an absolute novelty claim. |

## Computational results

The seven empty fibers and the `n ≤ 100000` census are finite theorems about
the shipped data. Their value is reproducibility and falsification pressure,
not a proof of either open conjecture. A release must distinguish:

- exact certificate replay;
- full recomputation;
- hash-only provenance for corpora not shipped.

No statistical sentence should be allowed to migrate into a universal
theorem.

## Open results from the wider campaign

The following are potentially more important than the current Lean core, but
are not yet represented by end-to-end kernel statements in this repository:

- exact local classification by the golden and binary locks;
- the full local interface that instantiates the now formalized abstract
  moment obstruction and derives `im_r(S) ⊆ T` directly from `S(p,r)`;
- finite-fiber/resultant reductions in the three-factor case;
- Kummer-tower density statements.

They should enter the public theorem table only after each has:

1. a stable paper statement;
2. a prior-art paragraph with primary sources;
3. an independent proof audit;
4. a Lean declaration or a sharply delimited certificate.

## Primary references checked

- H. W. Lenstra, Jr. and C. Pomerance,
  [Remarks on Agrawal’s conjecture](https://aimath.org/WWN/primesinp/articles/html/50a/),
  AIM notes, 2003.
- H. W. Lenstra, Jr. and C. Pomerance,
  [Problems concerning Agrawal’s conjecture](https://aimath.org/WWN/primesinp/articles/html/38a/),
  AIM notes, 2003; Remark 5 records \(r^n\equiv r\pmod n\).
- K. S. Williams and K. Hardy,
  [A congruence for the index of a unit of a real abelian number field](https://doi.org/10.4064/aa-46-1-57-72),
  *Acta Arith.* 46 (1985), 57–72; Theorem 5 and Remark 2 are the exact
  golden-unit reference.
- T. Váňa,
  [Agrawal’s conjecture and Carmichael numbers](https://web.ics.upjs.sk/svoc2009/prace/7/Vana.pdf),
  student scientific conference paper, Comenius University, 2009;
  Lemmas 3.3–3.4 and the subsequent CRT reduction are the closest direct
  precursors to the order and Korselt layers.
- R. Popovych,
  [A note on Agrawal conjecture](https://eprint.iacr.org/2009/008.pdf),
  IACR ePrint 2009/008.
- A. Leng,
  [Independence of the Miller–Rabin and Lucas probable prime tests](https://math.mit.edu/research/highschool/primes/materials/2016/Leng.pdf),
  2017.
- H. C. Williams,
  [On numbers analogous to the Carmichael numbers](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/23629FB455C460AE7626ACE4486A3274/S0008439500065024a.pdf/on-numbers-analogous-to-the-carmichael-numbers.pdf),
  *Canadian Mathematical Bulletin* 20 (1977), 133–143.
- R. J. McIntosh,
  [Carmichael numbers with \(p+1\mid n-1\)](https://ftp.icm.edu.pl/packages/EMIS/journals/INTEGERS/papers/o59/o59.pdf),
  *Integers* 14 (2014), Paper A59; Section 4 explicitly
  records \(\gcd(p_i-1,p_j+1)=2\).
- R. J. McIntosh and M. Dipra,
  [Carmichael numbers with \(p+1\mid n+1\)](https://www.sciencedirect.com/science/article/pii/S0022314X14002108),
  *Journal of Number Theory* 147 (2015), 81–91.
- F. Breuer,
  [Multiplicative orders of Gauss periods and the arithmetic of real
  quadratic fields](https://arxiv.org/abs/2006.10344), 2020.
- P. M. Voutier,
  [Primitive divisors of Lucas and Lehmer sequences, II](https://doi.org/10.5802/jtnb.168),
  *Journal de Théorie des Nombres de Bordeaux* 8 (1996), 251–274.
- C. Corrales-Rodrigáñez and R. Schoof,
  [The support problem and its elliptic analogue](https://doi.org/10.1006/jnth.1997.2114),
  *Journal of Number Theory* 64 (1997), 276–290.
- Y. Bilu, G. Hanrot and P. M. Voutier,
  [Existence of primitive divisors of Lucas and Lehmer numbers](https://doi.org/10.1515/crll.2001.080),
  *Journal für die reine und angewandte Mathematik* 539 (2001), 75–122.
- The current Formal Conjectures entry contains the statement of Agrawal’s
  conjecture with `sorry`; it does not contain this verified core.
