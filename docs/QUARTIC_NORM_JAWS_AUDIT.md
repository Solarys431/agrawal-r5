# Exact quartic norm-jaw audit

Status date: 2026-07-30.

This note records the exact decomposition of the canonical odd quartic
tail into its two field sides. Every universal statement below is checked
by Lean in `AgrawalCore/QuarticNormJaw.lean`. The final section explains
precisely why the decomposition is not, by itself, a proof that the
quartic row system is empty.

## 1. Literal norm identity

For a good inert prime \(p\), put

\[
u=\zeta_5-1,\qquad
S=1+p+p^2+p^3.
\]

The four Frobenius conjugates of \(u\) are exactly the four nontrivial
cyclotomic units. Their product is \(\Phi_5(1)=5\). Hence

\[
\boxed{u^S=5.}
\]

This is kernel-checked as
`localCyclotomicUnit_pow_normExponent_eq_five`; it is not an assumed
finite-field norm formula.

Consequently,

\[
\operatorname{ord}(5)\mid\operatorname{ord}(u),
\qquad
\operatorname{ord}(5)\mid p-1.
\]

## 2. Exact two-jaw decomposition

Let

\[
T_p=\operatorname{lcm}(\operatorname{ord}(u),5)
\]

and let \(D_p\) be the part of \(T_p\) prime to \(10\). Define

\[
D_{p,-}
  =\operatorname{ordCompl}_2(\operatorname{ord}(5)),
\qquad
D_{p,+}
  =\gcd(D_p,p+1).
\]

The norm exponent factors as

\[
S=(p+1)(p^2+1).
\]

Every odd divisor of \(p-1\) is coprime to \(S\). Therefore taking the
\(S\)-th power cannot erase any odd \(p-1\)-component of
\(\operatorname{ord}(u)\). This proves the exact identity

\[
\boxed{D_{p,-}=\gcd(D_p,p-1).}
\]

Since \(D_p\mid(p-1)(p+1)\) and \(D_p\) is odd, the complementary factor
lies wholly on the other side:

\[
\boxed{
D_p=D_{p,-}D_{p,+},\qquad
D_{p,-}\mid p-1,\qquad
D_{p,+}\mid p+1,\qquad
\gcd(D_{p,-},D_{p,+})=1.}
\]

The declarations are
`quarticMinusJaw_eq_gcd_oddTail_sub_one`,
`quarticOddTail_eq_mul_jaws`, and `quarticJaws_coprime`.

## 3. Forced cross-sign partition

Assume two compatible rows attached to ordered primes \(p\le r\). The
odd-tail incidence theorem gives

\[
\gcd(D_p,D_r)\mid r-p.
\]

If an integer \(\ell\) divides \(D_{p,-}\) and \(D_{r,+}\), then it also
divides \(p-1\), \(r+1\), and \(r-p\). Subtracting these relations gives

\[
\ell\mid2.
\]

The reverse orientation is identical:

\[
\boxed{
\ell\mid D_{p,-},D_{r,+}\Longrightarrow\ell\mid2,
\qquad
\ell\mid D_{p,+},D_{r,-}\Longrightarrow\ell\mid2.}
\]

Thus every shared odd prime support has one globally consistent sign.
The incidence form and the literal two-row form are kernel-checked as
`quarticCrossJaws_partition_of_incidence` and
`quarticCrossJaw_dvd_two`.

This mechanism is closely related to the classical forced support
partition for simultaneous Carmichael/Lucas--Carmichael conditions. No
historical-priority claim is made for the abstract partition principle.
The new formal content here is its exact realization inside the
canonical quartic order modulus through the literal norm identity.

## 4. Adversarial stopping point

The theorem is structural, but it is not a universal contradiction.
Nothing in the two-jaw identities forces:

1. two different rows to share an odd prime at all; or
2. a shared prime to occur with opposite signs.

The numerical shadow

\[
(p,r,q)=(7,43,103),\qquad
D_p=D_r=D_q=3,\qquad
D_{x,-}=3,\quad D_{x,+}=1
\]

satisfies all displayed field-side divisibilities and all three
support-gap incidences:

\[
3\mid43-7,\qquad3\mid103-7,\qquad3\mid103-43.
\]

This is only a countermodel to a proposed deduction from the *shadow
axioms*; it is not asserted to be a system of literal local rows or to
give the actual values of their cyclotomic orders.

Therefore a proof of emptiness still needs a genuinely new lower-bound
or mixing statement, for example:

- a theorem forcing a nontrivial cross-sign collision;
- a joint lower bound forcing an oversized shared jaw; or
- a theorem emptying every explicit terminal resultant fiber.

The exact two-jaw factorization improves the deterministic sieve and
removes an earlier paper-level interface. It does not prove H4, empty the
global fibers, or settle the Agrawal conjecture.
