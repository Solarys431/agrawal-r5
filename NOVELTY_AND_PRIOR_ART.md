# Novelty and prior-art map

Private working document — 2026-07-26. This file is deliberately more
conservative than a release announcement. “Potentially new” means that a
targeted search did not find the statement; it does not replace review by a
specialist in cyclotomy or primality testing.

## The result to lead with

| Result | Kernel status | Prior art | Current novelty assessment |
|---|---|---|---|
| `U₂ = (√5)⁵ ε³` and `ind₅(U₂) = 3 ind₅(ε)` | Lean-checked in `GoldenMoment.lean` | Williams–Hardy (1985), Theorem 5, computes `ind₅(ε)` in Dickson coordinates | **Potentially new bridge.** The classical side is the golden-unit character; the proposed new content is that Agrawal’s quadratic moment is exactly that character. Specialist priority check required. |

This is the scientifically strongest release narrative because it has all
four properties at once:

1. a short exact statement;
2. a transparent four-line algebraic proof;
3. a direct connection between two previously separate theories;
4. a kernel-checked implementation using an actual quintic index on
   `(ZMod p)ˣ`, not only a symbolic placeholder.

The public claim must remain:

> We formalize the factorization of the quadratic moment unit and its
> consequence for every quintic index. To our knowledge, the identification
> with the Agrawal moment has not appeared previously.

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
| Two-adic jaw on inert prime factors | Lean-checked | Useful corollary and good formal theorem; no priority claim |
| Canonical inert support witness for `H_n` | Lean-checked | Useful exact explanation of the census; no broad novelty claim |
| Golden–cyclotomic entanglement identity | Lean-checked | Structural identity supporting the main story; priority unassessed |
| Forced odd-\(q\) partition for simultaneous Carmichael/Lucas–Carmichael conditions | Lean-checked | **Classical mathematics, new formalization.** McIntosh (2014) explicitly records the Williams-set compatibility \(\gcd(p_i-1,p_j+1)=2\); Leng (2017) records \(n\equiv p\bmod (p^2-1)/2\) and the mod-12 consequence. The present contribution is a reusable kernel proof, including the arbitrary-common-divisor form `common_divisor_forced` and the named mod-3 corollary. |
| Cubic Lenstra signature versus the strong complementary row | Lean-checked | Elementary equivalence, included as a negative result of orientation: the cubic parameters repackage the row and must not be counted as an independent obstruction |
| Arithmetic profile of \(H_n\) and the 2-adic saturation wall | Lean-checked | Exact formal reduction, not a proof of H4: `dvd_goldenH_iff_scalar_profile` identifies divisibility by \(H_n\) with the two negative scalar semiperiods, and `dvd_goldenH_nonsquare_iff_two_adic_saturation` proves that inertia is equivalent to saturation of \(v_2(p-1)\). Priority for the elementary reduction is unassessed; no novelty claim beyond this explicit formal package should be made. |
| Local order-four transport is equivalent to support of \(H_n\) | Lean-checked end to end | `LocalTransport.lean` proves the necessary direction from the literal row. `ScalarCompleteness.lean` proves the converse existentially: a common defect is globally `+1` or `−1`; the negative sign is repaired by an explicit index shift. The precise declaration is `hasOrderFourTransport_iff_goldenH_support`. This proves the scalar-completeness reduction, **not H4**: excluding split prime factors from every \(H_n\) remains open. Priority is unassessed. |

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
  [A congruence for the index of a unit of a real abelian number field](https://people.math.carleton.ca/~williams/papers/pdf/139.pdf),
  *Acta Arith.* 46 (1985), 57–72.
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
- R. J. McIntosh and S. Mitra Dipra,
  [Carmichael numbers with \(p+1\mid n+1\)](https://www.sciencedirect.com/science/article/pii/S0022314X14002108),
  *Journal of Number Theory* 147 (2015), 81–91.
- The current Formal Conjectures entry contains the statement of Agrawal’s
  conjecture with `sorry`; it does not contain this verified core.
