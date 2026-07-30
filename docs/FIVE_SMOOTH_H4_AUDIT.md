# Five-smooth split H4 exclusion

Status date: 2026-07-30.

This note records an unconditional infinite-family exclusion for the open
H4 wall.  The complete statement is kernel-checked in
`AgrawalCore/FiveSmoothSupportExclusion.lean`.

## Statement

Let \(p\ne2,5\) be a good split primitive H4 divisor in the branch
\(p\equiv1\pmod5\).  Write the exact scalar orders as

\[
\operatorname{ord}_p(5)=2r,\qquad
\operatorname{ord}_p(\varepsilon^2)=2s,
\]

where the primitive level \(4rs\) is prime to five and \(r+s\) is odd.
Then

\[
\boxed{p-1\ne2^b5^f}
\]

for every \(b,f\ge0\).

The end-to-end declaration is
`no_split_five_smooth_primitive_support`.

## Proof

If \(p-1=2^b5^f\), both exact orders divide \(p-1\).  Since
\(5\nmid4rs\), cancellation of the \(5\)-part gives

\[
r\mid2^b,\qquad s\mid2^b.
\]

The parity condition \(r+s\) odd says that one of \(r,s\) is odd.  An odd
divisor of a power of two equals one.

If \(r=1\), then \(5\) has order two, hence \(5=-1\pmod p\) and \(p\mid6\),
incompatible with \(p\equiv1\pmod5\).

If \(s=1\), then the coordinated golden square \(x=\varepsilon^2\) has
order two, hence \(x=-1\).  But \(x^2-3x+1=0\), which at \(x=-1\) gives
\(5=0\), contradicting \(p\ne5\).

The two order-two exclusions and the intrinsic quadratic relation for
`goldenSquareFromGamma` are separately exposed in the same Lean module.

## Scope

This removes the complete \(5\)-smooth family in the \(p\equiv1\pmod5\)
branch.  It complements, but does not subsume, the four-depth theorem
excluding
\[
p-1=2^bq^e,\qquad b\in\{3,4,5,6\},
\]
recorded in
[`SINGLE_SUPPORT_DEPTH_AUDIT.md`](SINGLE_SUPPORT_DEPTH_AUDIT.md).

It does **not** exclude:

- \(p-1\) containing another odd prime;
- the full \(p\equiv4\pmod5\) branch;
- H4 in general.

No claim of historical priority is made before specialist review.
