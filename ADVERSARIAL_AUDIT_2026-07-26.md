# Adversarial audit — 2026-07-26

Private working document. This audit was instructed to reject unsupported
claims, not to confirm the project. It is a model audit, not a substitute for
review by a human specialist.

## Verdict

**Mechanical core: PASS after repairs.**

**Mathematical novelty claim: HOLD pending human specialist review.**

No counterexample was found to a Lean theorem, no paper theorem was found to
be stronger than its cited declaration, and the independent finite checks
reproduced the flagship identity. The audit did find three real
reproducibility defects. All three were repaired before this verdict:

1. the first private CI run omitted the Python dependency and failed before
   certificate replay;
2. primality above \(2^{64}\) was screened by BPSW rather than reproved;
3. the fiber verifier trusted embedded level hashes instead of independently
   recomputing the universal level norms.

The release remains private because priority for the golden-moment bridge has
not been certified by a human expert in cyclotomy and because no independent
human mathematician has yet read the paper end to end.

## 1. Remote and kernel audit

- Private remote verified: `Solarys431/agrawal-r5`, visibility `PRIVATE`.
- Pushed baseline audited: `eb8f6b8b9eb57b091c515e422a708d079d15437b`.
- Remote and local `main` agreed exactly at the start of the audit.
- Repaired commit pushed: `e51cd1601520ba69d7cf698b16e09b11767f08af`.
- Clean-clone private CI: **PASS**, run `30201970510` (7m48s).
- `lake build --wfail`: **PASS**, 2,866 jobs.
- Scan for `sorry`, `admit`, `axiom` and `opaque`: no project escape hatch.
- The flagship declarations use only ordinary Mathlib/Lean foundations
  (`propext`, `Quot.sound`, and, where the construction is noncomputable,
  `Classical.choice`); no project axiom is introduced.

The first GitHub Actions run built the entire Lean project successfully but
failed at certificate replay with:

```text
please install sympy (pip install sympy)
```

This was a real CI defect. The workflow now installs pinned
`sympy==1.14.0` and PARI/GP before replay.

## 2. Flagship theorem: independent semantic check

The Lean proof was not treated as the only line of evidence. An independent
prime-field calculation was run for every prime
\(p\equiv1\pmod5\), \(p<20000\): 563 primes.

For each prime the audit independently:

1. found a primitive generator of \(\mathbf F_p^\times\);
2. constructed a primitive fifth root \(\zeta\);
3. rebuilt the full discrete-log table;
4. computed
   \[
   M_2=\sum_{a=1}^4(a^2\bmod5)\,
       \operatorname{ind}_5(\zeta^a-1);
   \]
5. computed
   \[
   U_2=(\zeta-1)(\zeta^2-1)^4(\zeta^3-1)^4(\zeta^4-1);
   \]
6. checked
   \[
   U_2=s^5\varepsilon^3,\qquad
   \operatorname{ind}_5(U_2)=M_2
   =3\,\operatorname{ind}_5(\varepsilon).
   \]

Result:

```text
checked_primes=563; max_p=20000;
factorization=M2=3ind(eps): PASS
```

This closes the most obvious semantic attack: the Lean object called
`quadraticMomentUnit` has exactly the weights used by the quadratic moment,
and its character is the stated moment.

## 3. Paper-to-Lean statement audit

The theorem environments in `paper/agrawal-r5.tex` were compared against the
actual declaration types, not only their names.

### Passes

- `moment_covariance`, `moment_obstruction`, and
  `pow_succ_eq_one_of_moment_ne_zero` match the abstract finite-field
  statements in the paper.
- `golden_moment_factorization` is division-free and holds in every
  commutative ring under the displayed \(\Phi_5\) relation.
- `golden_moment_index` and `zmod_golden_moment_index` prove the stated
  quintic-character consequence; the prime-field construction is an actual
  multiplicative discrete index modulo five.
- `agrawal_fermat_shadow`, the two-adic jaw, bounded order, box identity, and
  the Lenstra–Pomerance proposition have the hypotheses stated in the paper.
- The Lenstra–Pomerance result is correctly attributed as classical
  mathematics whose contribution here is formal verification.
- The two open statements are typeset as conjectures and are not smuggled
  into theorem statements.

### Deliberate scope boundary

`MomentObstruction.lean` formalizes the algebraic covariance engine. It does
**not** yet formalize the complete local definition of \(S(p,r)\) and derive
the full inclusion \(\operatorname{im}_r(S)\subseteq T\) end to end. The paper
and novelty map disclose this boundary explicitly. It is therefore a
limitation, not a mismatch.

## 4. Certificate audit and repairs

### Full replay

The repaired verifier produced:

```text
7/7 certified-empty fibers: PASS
20,000 indices: replayed
9,725 nontrivial H_n: reproduced
4,522 distinct prime factors: reproduced
split factors: 0
```

### Repair A — proven primality

There are 4,666 distinct listed factors and 22 exceed \(2^{64}\); the largest
has 149 bits. The previous verifier used `sympy.isprime` alone. Its large-input
BPSW path is excellent evidence but is not a primality proof.

The verifier now:

- uses deterministic `sympy.isprime` below \(2^{64}\);
- batches every larger factor through PARI `isprime`;
- fails if `gp` is absent or any large factor is not proved.

Result:

```text
PARI proved 22 factors above 2^64: PASS
```

### Repair B — independent level reconstruction

The old replay reconstructed factors against hashes stored in the same JSON
certificate. That detects corruption but does not independently identify the
integer being factored.

The verifier now derives each level integer from the fixed algebraic datum
\[
\operatorname{Tr}(U)=-625,\qquad N(U)=3125,
\]
whose minimal polynomial is
\[
X^2+625X+3125.
\]
For every level \(d\) it computes
\[
N(\Phi_d(U))
=\left|\operatorname{Res}
  (X^2+625X+3125,\Phi_d(X))\right|
\]
and compares that integer with the exact listed factorization, digit count and
hash. All 139 shipped level pieces passed. Schema-1 scope products are also
rebuilt from the independently recomputed pieces.

This changes the fiber files from self-consistent data packages into
independently replayed arithmetic certificates for their stated universal
level values.

### Remaining certificate boundary

The verifier checks the embedded detector classes, exact multiplicative
orders, level coverage and absence of surviving factors. The general theorem
that these detector classes exhaust a mathematical fiber belongs to the
wider paper argument; it is not itself a Lean theorem in this release core.
The certificates therefore prove the finite claims under the displayed
detector reduction, not the two universal open conjectures.

## 4-bis. H4 arithmetic bridge audit

The new module `AgrawalCore/H4Core.lean` was audited against the actual
types rather than the surrounding narrative.

- `goldenA` uses Lucas numbers for even indices and Fibonacci numbers for
  odd indices, exactly as in the paper.
- `goldenH` is the literal natural-number gcd
  `gcd(goldenA n, 5^(n-1)+1)`.
- `dvd_goldenH_iff_scalar_profile` proves both directions of
  \[
  p\mid H_n\iff \varepsilon^{2n}=-1\ \land\ 5^{n-1}=-1.
  \]
  The reverse Fibonacci and Lucas implications are separate kernel proofs;
  no numerical characterization is imported.
- `dvd_goldenH_order_factorization_two` proves the exact identity
  \(v_2(\operatorname{ord}_p5)=v_2(n-1)+1\).
- `dvd_goldenH_nonsquare_iff_two_adic_saturation` proves, under
  \(p\mid H_n\), that non-squareness of \(5\) modulo \(p\) is equivalent to
  \(v_2(p-1)=v_2(n-1)+1\).

Adversarial boundary: the module does **not** prove that the last equality
always holds and therefore does not prove H4. The safe claim is an exact
arithmetic reduction of the golden-inertia conjecture, not a proof of the
full local classification.

An independent implementation represented
\(\mathbf F_p[X]/(X^2-X-1)\) by coefficient pairs, recomputed Fibonacci and
Lucas numbers from their recurrence, and calculated multiplicative orders
by factoring \(p-1\). For every prime \(p<2000\), \(p\ne5\), and
\(2\le n\le400\), it found 205 instances of \(p\mid H_n\). All 205 passed:

```text
eps^(2n) = -1;
5^(n-1) = -1;
v2(ord_p(5)) = v2(n-1)+1;
non-square(5 mod p) iff v2(p-1)=v2(n-1)+1.
```

All 205 were inert and none split, consistently with—but not proving—the
open conjecture.

## 4-ter. Local transport interface audit

The new module `AgrawalCore/LocalTransport.lean` closes one of the scope
boundaries recorded above.

- `LocalS5 p m` is the literal equality
  \[
  (\zeta-1)^m=\zeta^m-1
  \quad\text{in }(\mathbf Z/p\mathbf Z)[X]/\Phi_5,
  \]
  not a scalar proxy.
- `localS5_row` first converts that equality back to divisibility by
  \(\Phi_5\), then evaluates at a conjugate root. The four root proofs are
  separate kernel declarations.
- `orderFourTransport_rows` derives the complete labelled cycle for
  \(m=2n-1\), \(n\equiv4\pmod5\).
- `orderFourTransport_cyclo_scalar` derives
  \(\varepsilon^{2n}=-1\) and \(5^{n-1}=-1\) inside the cyclotomic quotient.
- `orderFourTransport_dvd_goldenH` proves the end-to-end necessary direction
  \[
  \text{local residue-2 transport}\Longrightarrow p\mid H_n.
  \]
  The descent to integer divisibility is reproved in the cyclotomic ring;
  it does not assume that the quotient is a field.

This was the boundary at the end of the `LocalTransport.lean` audit. It is
superseded by the separately audited converse in §4-quater below. H4 itself
remains open.

An independent implementation of
\((\mathbf Z/p\mathbf Z)[X]/\Phi_5\), with its own degree-four reduction
and binary exponentiation, tested every prime \(p<2000\), \(p\ne5\), and
all \(n\le800\), \(n\equiv4\pmod5\). It found 140 positive local
transport witnesses on 65 distinct primes. Every witness satisfied all
four labelled rows and \(p\mid H_n\); there were zero violations. This is
a falsification check, not part of the proof.

## 4-quater. Scalar-completeness converse audit

The module `AgrawalCore/ScalarCompleteness.lean` closes the converse at the
correct logical strength. The initially tempting same-index statement is
false: an independent quotient-ring implementation found scalar hits whose
literal local row has common defect `-1`. The theorem is therefore
existential in the index.

The kernel proof establishes:

- the four labelled defects coincide (`scalar_common_defect_cross`);
- the common defect is fixed by `ζ ↦ ζ²`;
- its square is one;
- a trace calculation prevents componentwise mixed signs even when `Φ₅`
  splits, so the common defect is globally `+1` or `−1`;
- the positive branch is already a literal local row;
- in the negative branch, for `m=2n-1` and
  `d=⌊m²/2⌋=(m²-1)/2`, the shifted index `n'=n+5d` is a literal local
  witness in the same residue class modulo five.

The end-to-end declaration is
`hasOrderFourTransport_iff_goldenH_support`. Its right-hand side and
left-hand side both quantify existentially over an admissible index.
No same-index converse is claimed.

The independent regression
`tools/verify_scalar.py` implements the quotient arithmetic
from four-tuples rather than importing any Lean result. For all primes
`p < 5000`, `p ≠ 2,5`, and all admissible `n ≤ 1000`, it found 144 scalar
hits: 110 already worked at the same index and 34 had negative defect.
All 34 negative cases passed the explicit shifted-index repair; there were
zero mixed signs and zero failed repairs.

Adversarial boundary: this equivalence proves the reduction of local
order-four transport to the support of `Hₙ`; it does **not** establish
that all prime factors in that support are inert. Golden inertia/H4
therefore remains an open universal assertion.

## 5. Prior-art attack

Primary sources checked:

- Lenstra–Pomerance, *Remarks on Agrawal's conjecture* (AIM, 2003);
- Williams–Hardy, *A congruence for the index of a unit of a real abelian
  number field*, Acta Arith. 46 (1985), especially Theorem 5;
- Popovych, *On a subgroup generated by a polynomial in a finite field*
  (2009);
- the current `google-deepmind/formal-conjectures` Agrawal file.

Findings:

- Williams–Hardy already compute the quintic index of the golden unit. That
  character is **not new** and the repository says so.
- Lenstra–Pomerance already contain the relevant bounded-order mechanism and
  proposition. The project claims formalization value, not ownership of that
  mathematics.
- Formal Conjectures contains the open Agrawal statement with `sorry`; the
  targeted search found neither this verified Lenstra–Pomerance core nor the
  golden-moment bridge in another Lean development.
- The targeted literature search did not find the identification
  \[
  \text{Agrawal quadratic moment}
  =3\,\operatorname{ind}_5(\varepsilon).
  \]

The last sentence is a search result, not a priority theorem. The only safe
public wording remains “to our knowledge,” followed by explicit specialist
review.

## 6. Scientific value

### Formalization value: high

The repository is a nontrivial, pinned, warning-clean Lean development with
28 substantive modules, 4,241 source lines and 218 named declarations. Its
strongest formal contribution is not line count but the end-to-end
organization of:

- a genuine prime-field quintic index;
- the division-free golden factorization;
- the polynomial-quotient Agrawal bridge;
- the Lenstra–Pomerance proposition under its original hypotheses;
- independent finite certificates separated from kernel theorems.

### Mathematical novelty: concentrated and provisional

The strongest plausible new result is the short bridge from the Agrawal
quadratic moment to the classical golden-unit character. The moment
covariance lemma is elementary, and much of the remaining mathematical core
is classical or a clean structural consequence. This concentration is a
strength: one exact new bridge is more defensible than a long list of inflated
novelty claims.

## 7. Release decision

### Ready now

- continued work in the private repository;
- private specialist circulation;
- a private Lean/formalization review;
- reproduction from a clean clone (now confirmed by private CI).

### Not authorized yet

- a public Zulip announcement;
- a public priority claim;
- wording that suggests Agrawal's conjecture or H4 is proved;
- wording that calls model audits “external human review.”

### Gates still required

1. human specialist priority review of the golden-moment bridge;
2. independent human mathematical reading of the paper;
3. final authorship and AI-disclosure decision.
