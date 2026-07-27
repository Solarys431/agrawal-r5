# Two-row transport census

This certificate replays the all-inert three-factor branch with largest
prime \(q<10^6\). It is a finite computation, not a proof of H4 and not an
unconditional exclusion of every three-factor counterexample.

Run from the repository root:

```bash
python3 certificates/two_row_transport/verify_two_row_transport.py
```

The verifier imports only the independently shipped exact finite-field order
implementation in `certificates/fibre_size/verifica_fibre_taglia.py`. It:

1. enumerates every inert \(q<10^6\);
2. computes the exact order \(T_q\);
3. enumerates every final-row product \(1<P<q^2\);
4. factors every product and retains the admissible semiprimes;
5. applies the multiplier-free transport modulo \(\gcd(T_p,T_q)\);
6. solves the exact reduced linear congruence in the multiplier \(h\);
7. checks that the linear normal form agrees with the original row.

Frozen result:

```text
inert q                         39,286
excluded by Tq >= q^2           36,009
residual final-row products     76,530
admissible semiprimes              415
pass both transport rows            24
pass the first complete row          0
pass both complete rows               0
status                            PASS
```

Under H4 this excludes every squarefree three-factor counterexample whose
largest prime is below \(10^6\). Without H4 it excludes exactly the
all-inert arm of the unconditional dichotomy.
