# Single-odd-support depth audit

## Status

**LEAN.** The following universal statement is kernel-checked:

> Let \(p\) be a good split prime carrying the exact primitive H-profile
> \[
> \operatorname{ord}_p(5)=2r,\qquad
> \operatorname{ord}_p(\varepsilon^2)=2s,\qquad
> \gcd(r,s)=1.
> \]
> If
> \[
> p-1=2^bq^e
> \]
> with \(q\) an odd prime and \(b\in\{3,4,5,6\}\), then a contradiction
> follows.

The end-to-end four-coefficient entry points are:

- `no_split_single_odd_support_sixteen_primitive`;
- `no_split_single_odd_support_thirtytwo_primitive`;
- `no_split_single_odd_support_sixtyfour_primitive`.

The depth-three theorem is
`no_split_single_odd_support`; its conclusion is directly that \(p\) is
inert.

## Common support lemma

`one_order_dvd_two_pow_succ_of_single_odd_prime` proves the reusable
combinatorial core. If coprime semiorders \(r,s\) both divide
\(2^bq^e\), then one of the complete orders \(2r,2s\) divides
\(2^{b+1}\). Thus each fixed dyadic depth reduces to the prime divisors
of two explicit integers:

\[
5^{2^{b+1}}-1,\qquad
\left|N_{\mathbf Q(\sqrt5)/\mathbf Q}
\bigl((\varepsilon^2)^{2^{b+1}}-1\bigr)\right|.
\]

## The exceptional depth-five factor

At \(p-1=32q^e\), the scalar-five side has one compatible split factor:

\[
p=11489,\qquad q^e=359.
\]

The kernel proves

\[
\operatorname{ord}_{11489}(5)=16
\]

from \(5^8=-1\) and \(5^{16}=1\). Hence \(r=8\). Coprimality and the
single odd support force \(s=1\) or \(s=359\). The first value would give
order \(2\) to a root of \(X^2-3X+1\), which is impossible away from
characteristic \(5\). The second contradicts the exact certificate

\[
x^{718}=-1
\]

for both roots modulo \(11489\).

## Depth six

At \(p-1=64q^e\), all split candidates are disposed of arithmetically.
The only odd cofactor requiring more than a parity check is

\[
\frac{29423041-1}{64}
=459735=3\cdot5\cdot30649,
\]

which is not a prime power. This non-prime-power assertion is itself
proved in Lean as `prime_power_ne_459735`.

## Boundary

No theorem is claimed here for \(b\ge7\). A trial certificate for the
next factorization was deliberately stopped when its large primality
subcertificate exceeded the resource budget. The result is therefore a
four-depth universal exclusion, not an induction over all dyadic
depths and not a proof of H4.
