# Independent golden-bridge audit

This directory preserves, byte for byte, an independent audit and finite
replay produced against commit
`5e894ab98bc7f6c89969d83e52d8b2493031a3e1`.

The audit found the factorization and exact product-to-sum theorem correct,
and identified one then-missing formal seam: the passage from the literal
local quotient-ring row to the same quintic character used in the moment.
That historical observation is intentionally left unchanged in
`AUDIT_PONTE_AUREO.md`.

The current release closes precisely that seam in
`AgrawalCore/LocalMomentBridge.lean`:

- `localS5_unit_rows` derives all four unit rows from `LocalS5`;
- `localS5_quintic_covariance` applies one character to those rows;
- `localS5_canonical_golden_moment_obstruction` constructs every unit
  internally and composes covariance with the exact product-to-sum and
  golden factorization;
- `localS5_canonical_golden_order_constraint` extracts the residue-order
  obstruction without user-supplied unit lifts;
- `localS5_canonical_quintic_locks_of_ne_one` gives the direct two-lock
  conclusion for the same character when the residue coordinate is nontrivial.

The finite replay is an independent regression, not a proof premise. It
enumerates all relevant exponent classes for the 306 primes
`p ≡ 1 (mod 5)`, `p < 10000`: 1,158,464 classes, 387 local members, one
nontrivial local member, and zero failures.

Run:

```console
(cd certificates/golden_bridge &&
  shasum -a 256 -c SHA256_PONTE_AUREO.txt)

python3 certificates/golden_bridge/verify_golden_bridge_end_to_end.py \
  --limit 10000 \
  --output /tmp/VERIFICA_PONTE_AUREO_10K.json

cmp certificates/golden_bridge/VERIFICA_PONTE_AUREO_10K.json \
  /tmp/VERIFICA_PONTE_AUREO_10K.json
```
