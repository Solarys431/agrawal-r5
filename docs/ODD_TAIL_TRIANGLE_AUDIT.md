# Canonical odd-tail triangle audit

Status date: 2026-07-30.

This note records the exact odd projection of the inert quartic three-row
system. It closes a former formalization gap in the paper's
branch-independent odd shadow. It does **not** prove that the three rows are
universally incompatible.

## 1. Canonical tail

For a good inert prime \(p\), let

\[
T_p=\operatorname{lcm}\bigl(\operatorname{ord}(\zeta_5-1),5\bigr)
\]

and remove its complete \(2\)- and \(5\)-primary parts:

\[
D_p=\operatorname{ordCompl}_5(\operatorname{ordCompl}_2(T_p)).
\]

The kernel first proves

\[
T_p\mid 10(p^2-1).
\]

Since \(\gcd(D_p,10)=1\), Euclidean cancellation gives

\[
\boxed{D_p\mid p^2-1.}
\]

The declarations are
`quarticOrderModulus_dvd_ten_mul_sq_sub_one`,
`quarticOddTail_coprime_ten`, and
`quarticOddTail_dvd_sq_sub_one`.

## 2. Branch-independent shadow

Every quartic row is in one of the two branches

\[
P\equiv1\pmod{T_p},
\qquad
P\equiv p^2\pmod{T_p}.
\]

Both reduce to the same congruence modulo \(D_p\):

\[
\boxed{P\equiv1\pmod{D_p}.}
\]

This is kernel-checked as `quarticRow_oddTailShadow`, with the divisibility
form `quarticRow_oddTail_dvd_sub_one`.

## 3. Complete incidence triangle

Let \(p<r<q\) be good inert primes and assume all three literal rows:

\[
r q\equiv1\text{ or }p^2\pmod{T_p},\qquad
p q\equiv1\text{ or }r^2\pmod{T_r},
\]

\[
p r\equiv1\text{ or }q^2\pmod{T_q}.
\]

Their odd shadows imply

\[
D_p\mid rq-1,\qquad D_r\mid pq-1,\qquad D_q\mid pr-1.
\]

Cancelling the complementary prime gives the exact incidence matrix

\[
\boxed{
\gcd(D_p,D_r)\mid r-p,\quad
\gcd(D_p,D_q)\mid q-p,\quad
\gcd(D_r,D_q)\mid q-r.}
\]

Therefore

\[
\boxed{
\gcd(D_p,D_r)\le r-p,\quad
\gcd(D_p,D_q)\le q-p,\quad
\gcd(D_r,D_q)\le q-r.}
\]

The full statements are
`quarticOddTail_incidenceTriangle` and
`quarticOddTail_incidenceBounds`. A reversed strict inequality in any one
entry is an exact rejection certificate, formalized as
`quarticOddTail_oversize_exclusion`.

## 4. Adversarial conclusion

This is a genuine deterministic sieve, not a probabilistic heuristic.
However, the three inequalities do not by themselves yield a universal
contradiction. The present theory supplies no unconditional lower bound
forcing one of the three shared gcds to exceed its prime gap. In particular,
multiplying the three upper bounds only repackages the same incidence data.

The remaining theorem would have to control the **joint distribution or
size of the odd order tails**, not merely rewrite the three row congruences.
Equivalently, one still needs either:

1. a class-specific lower bound forcing an oversized shared tail in every
   prospective triangle; or
2. a theorem emptying every explicit terminal resultant fiber.

## Claim status

| Statement | Status |
|---|---|
| \(T_p\mid10(p^2-1)\) for the concrete quartic modulus | **LEAN** |
| Canonical tail \(D_p\mid p^2-1\) | **LEAN** |
| Three pairwise support-gap incidences | **LEAN** |
| Oversized-tail exclusion | **LEAN** |
| A universal oversized-tail theorem | **OPEN** |
| Universal terminal-fiber emptiness | **OPEN** |
