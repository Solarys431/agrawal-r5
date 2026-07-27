# Final-row size replay

This directory contains the independent replay for the reverse-fibre size
sieve. It does not import campaign code.

The deterministic Lean statements are:

- `AgrawalCore.threeFactor_finalRow_size_exclusion`;
- `AgrawalCore.mitm_secondProduct_unique`.

The tracked JSON has two deliberately different scopes:

- `k3`: exhaustive for all triples `p1 < p2 < q` with inert
  `q < 100000`;
- `k5`: exhaustive only for inert `q < 3000` satisfying `T_q >= q^2`.
  The remaining 13 values of `q` are recorded as undecided and are not
  represented as empty fibres.

Replay:

```bash
python3 certificates/fibre_size/verifica_fibre_taglia.py \
  --k3-limit 100000 \
  --k5-limit 3000 \
  --expected certificates/fibre_size/VERIFICA_FIBRE_TAGLIA.json \
  --output /tmp/VERIFICA_FIBRE_TAGLIA.json
```

The computation recomputes every multiplicative order in
`F_p[X]/(X^4+X^3+X^2+X+1)` and tests every remaining local row. Timing fields
are excluded from certificate comparison; every mathematical counter and
every undecided-prime record is binding.
