# H4 final assault — portable certificate v3

This directory contains two finite censuses and an independent verifier.
It does **not** contain a proof of H4.

## Lightweight verification

```bash
python3 verify_h4_final_assault_v3.py \
  --root . \
  --output VERIFICA_H4_ASSALTO_FINALE_v3.json
```

The verifier uses only Python's standard library. It independently checks
the primality, factorisations, quadratic character, scalar order certificate,
matrix order certificate, canonical gcd signature and all frozen counters.

## Full replay

On macOS with Homebrew GCC:

```bash
/opt/homebrew/bin/g++-15 -O3 -std=c++17 scan_inert_pk.cpp -o scan_inert_pk.replay
/opt/homebrew/bin/g++-15 -O3 -std=c++17 -fopenmp \
  search_H_two_support_powers.cpp -o search_H_two_support_powers.replay
```

On a GNU/Linux system, replace `/opt/homebrew/bin/g++-15` with `g++`.

```bash
./scan_inert_pk.replay 50000000 INERT_PK_5E7_REPLAY.txt \
  2> INERT_PK_5E7_REPLAY.log

./search_H_two_support_powers.replay 5000 \
  H_TWO_SUPPORT_POWERS_Q5K_1E18_REPLAY.txt \
  1000000000000000000 \
  2> H_TWO_SUPPORT_POWERS_Q5K_1E18_REPLAY.log
```

The timing suffix in a log is environment-dependent; the `DONE` line is the
canonical result. Executable hashes are deliberately excluded from the
portable manifest because compiler and platform changes alter the bytes.

## Scientific scope

- The p-first scan is exhaustive only for inert primes `p ≤ 50,000,000`.
- The two-support scan is exhaustive only for its declared smooth family,
  `q<t≤5000` and `p<10^18`.
- Zero hits in either domain is not a proof of H4.
