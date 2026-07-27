# All-inert three-factor census up to \(q<10^7\)

This directory freezes the sharded exact census used in the paper.  Its
scope is the all-inert branch \(p<r<q<10^7\).  It does **not** prove H4 and
does **not** assert a universal exclusion.

The merged result is:

```text
inert final primes                 332441
excluded by T_q >= q^2             304979
residual final-row products        993466
admissible semiprimes                4429
passing both final-small transports   254
passing the complete CRT triangle     194
passing both local size bounds          14
passing triangle and size                10
excluded by the quantized gap             2
excluded by the odd shadow               10
passing both exact small rows             0
status                                PASS
```

The four JSON shards are contiguous.  Every shard records the exact source
hash, an empty `exact_hits` list, and any structural survivors.  The merged
manifest verifies contiguity, common source hash, and the totals above.

The `replay_root/` directory preserves the exact source layout used by the
search script.  From this certificate directory, replay the merge with:

```bash
python3 replay_root/motore/unisci_censimenti_triangolo.py \
  fast_triangle_3_3m_final.json \
  fast_triangle_3m_5m.json \
  fast_triangle_5m_7p5m.json \
  fast_triangle_7p5m_10m.json \
  --output /tmp/TRIANGLE_K3_10M_MANIFEST.json
```

The ten structural survivors can then be replayed through the two new
theorem-backed projections:

```bash
cd ../../
python3 certificates/triangle_k3_10m/replay_root/motore/verifica_gap_quantizzato_k3.py \
  certificates/triangle_k3_10m/TRIANGLE_K3_10M_MANIFEST.json \
  --output /tmp/QUANTIZED_GAP_K3_10M.json
cmp certificates/triangle_k3_10m/QUANTIZED_GAP_K3_10M.json \
  /tmp/QUANTIZED_GAP_K3_10M.json
```

The quantized gap alone removes two survivors.  The branch-independent odd
shadow removes all ten.  This is a finite statement on the frozen box, not a
universal proof of the all-inert branch.

A full rerun of a shard uses, for example:

```bash
cd replay_root
python3 motore/caccia_triangolo_k3.py \
  --lower 3000000 --limit 5000000 --crosscheck-limit 100000 \
  --output /tmp/fast_triangle_3m_5m.json
```

The search uses the proved bound \(T_p\mid10(p^2-1)\) to compute the exact
order and cross-checks the prefix \(p<10^5\) against the independent
finite-field implementation in `verifica_fibre_taglia.py`.
