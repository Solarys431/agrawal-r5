# Exact dyadic triangle audit

Status date: 2026-07-30.

This note records a completed binary analysis of the inert quartic
three-row system. It deliberately separates a structural classification
from a candidate-eliminating obstruction.

## 1. Exact order depth

Let \(p\) be an odd prime with \(p\equiv\pm2\pmod5\), let
\(u=\zeta_5-1\), and write

\[
T_p=\operatorname{ord}(u),\qquad b_p=v_2(p^2-1).
\]

The Frobenius identity

\[
u^{p^2-1}=-\zeta_5^{-1}
\]

has right-hand side of exact order \(10\). The general order-of-a-power
formula therefore gives

\[
\boxed{v_2(T_p)=b_p+1.}
\]

This is proved in Lean by
`localCyclotomicUnit_order_factorization_two`. The version for the complete
row modulus \(\operatorname{lcm}(T_p,5)\) is
`quarticOrderModulus_factorization_two`.

## 2. Exact target normal forms

At the first level above \(b_p\),

\[
p^2\equiv1+2^{b_p}\pmod{2^{b_p+1}}.
\]

Consequently the two allowed transported row targets satisfy

\[
p^1\equiv p,\qquad
p^3\equiv p+2^{b_p}\pmod{2^{b_p+1}}.
\]

The kernel declarations are
`square_modEq_one_add_exactTwoPower`,
`cube_modEq_base_add_exactTwoPower`, and
`rowTarget_modEq_base_add_bit`.

## 3. Complete three-row classification

Suppose a complete three-row triangle has primes \(p,q,r\), transported
exponents \(e_x\in\{1,3\}\), and put

\[
\delta(1)=0,\qquad\delta(3)=1.
\]

Then

\[
b_p=b_q=b_r=:b
\]

and

\[
\boxed{
p+\delta(e_p)2^b
\equiv q+\delta(e_q)2^b
\equiv r+\delta(e_r)2^b
\pmod{2^{b+1}}.}
\]

In particular,

\[
p\equiv q\equiv r\pmod{2^b}.
\]

The literal arithmetic-row interface is
`quarticThreeRows_exact_dyadicRays`; the weaker common-depth and
unlabelled-ray forms are
`quarticThreeRows_common_dyadicDepth` and
`quarticThreeRows_single_dyadicRay`.

## 4. What this does and does not prove

This closes the **binary projection** of the complete CRT triangle. It is
not an extra sieve on a candidate that has already passed that triangle:
the ray law is an exact consequence of its rows.

Combining the final binary row with the ray law says that the number of
twisted labels is odd. The residue-determined mod-\(5\) skeleton already
has precisely that parity for three inert factors. Therefore this
consequence is compatible with, rather than contradictory to, the mod-\(5\)
profile.

The remaining obstruction must use an odd component of the order moduli.
The kernel theorem `sharedOddSupport_dvd_gap` already shows that an odd
prime-power shared by two row moduli divides the corresponding prime gap.
What is still missing is a universal reason why all three odd Kummer tails
cannot be arranged simultaneously, or an independent theorem that empties
every explicit resultant fiber.

## Claim status

| Statement | Status |
|---|---|
| Exact binary order law | **LEAN** |
| Exact labelled dyadic rays | **LEAN** |
| Binary-only contradiction | **FALSE AS A STRATEGY**: the exact binary condition is compatible with the mod-\(5\) skeleton |
| Universal odd-tail incompatibility | **OPEN** |
| Universal terminal-fiber emptiness | **OPEN** |
