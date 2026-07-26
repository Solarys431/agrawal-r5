#!/usr/bin/env python3
"""Independent re-verifier for the certificates shipped in this repo.

Default mode re-checks, certificate by certificate:

  fiber certificates (both schemas):
    - file bytes against the SHA-256 recorded in fibers/MANIFEST.json;
    - status field and absence of missing required levels (checked both
      at top level and inside level_summary, where schema 1 stores it);
    - primality of every listed prime factor (sympy.isprime, deterministic
      below 2^64, followed by PARI isprime for every larger factor);
    - EMPTINESS: no listed factor that is inert mod 5, larger than p2
      and inside one of the certificate's own detector classes;
    - independent recomputation of every universal level value
      N(Phi_d(U)) as the resultant of Phi_d with
      X^2 + 625 X + 3125, the minimal polynomial of U;
    - schema 2: exact equality of every recomputed level value with its
      listed factorization and embedded value_sha256;
    - schema 1: equality of every recomputed piece hash and digit count,
      followed by exact equality of the recomputed scope product with the
      global factor map, scope hash and digit count; the certificate's self-hash
      (payload_sha256, canonical compact JSON), and full verification
      of the embedded multiplicative-order certificates: in
      F_p[X]/(X^4+X^3+X^2+X+1) it recomputes (X-1)^T = 1 and, for
      every prime l | T, (X-1)^(T/l) against the recorded witness
      (which must differ from 1), plus T | p^4 - 1 for inert p and
      the factorback of T's own factorization.

  census manifest:
    - status complete, zero split factors, and full coherence of the
      counters with the 9,725 embedded rows (recount, factorback of
      every row, class-mod-5 scan of every listed factor).

--full additionally REPLAYS the census from scratch: for every
n = 4 mod 5 up to n_max it recomputes A_n (Lucas for even n via
2*F_(n+1)-F_n, Fibonacci for odd n), H_n = gcd(A_n, 5^(n-1)+1) with
the factors 2 and 5 stripped, and demands that the recomputed value
match the manifest row exactly, with every factor proven prime.

Not covered (documented limit): the schema 2 self-hash field
(payload_sha256_without_hash_field), whose serialization convention is
not shipped. It carries no mathematical content beyond the independently
recomputed values and checks above.

The separate 10^9 corpus listed in SHA256SUMS_S28_1E9.txt is
HASH-ONLY provenance: the artifacts are not distributed in this
repository and are NOT verified by this tool.

Exit code 0 iff every check passes. No network access required.
"""
import argparse
import hashlib
import json
import math
import os
import shutil
import subprocess
import sys
import glob
from functools import lru_cache

try:
    from sympy import cyclotomic_poly, isprime, resultant, symbols
except ImportError:
    sys.exit("please install sympy (pip install sympy)")

if hasattr(sys, "set_int_max_str_digits"):
    sys.set_int_max_str_digits(100_000)

HERE = os.path.dirname(os.path.abspath(__file__))
CERT = os.path.join(HERE, "..", "certificates")
ok = True
large_prime_contexts = {}
LEVEL_X = symbols("x")
LEVEL_MINPOLY = LEVEL_X ** 2 + 625 * LEVEL_X + 3125


def fail(msg):
    global ok
    ok = False
    print("FAIL:", msg)


def check_prime(n, context):
    """Screen a factor and queue large ones for a PARI proof."""
    n = int(n)
    if not isprime(n):
        fail(f"{context}: {n} is not prime")
        return False
    if n >= 2 ** 64:
        large_prime_contexts.setdefault(n, []).append(context)
    return True


def prove_large_primes_with_pari():
    """Prove every queued factor above 2^64 with PARI's isprime."""
    if not large_prime_contexts:
        print("ok   primality: all factors below 2^64")
        return
    gp = shutil.which("gp")
    if gp is None:
        fail("large-factor primality requires PARI/GP (install pari-gp)")
        return
    nums = sorted(large_prime_contexts)
    program = "".join(f'print({n}, " ", isprime({n}));\n' for n in nums)
    try:
        run = subprocess.run(
            [gp, "-q", "-f"],
            input=program,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=600,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        fail(f"PARI primality batch failed: {exc}")
        return
    if run.returncode != 0:
        fail(f"PARI primality batch exited {run.returncode}: "
             f"{run.stderr.strip()}")
        return
    proven = {}
    for line in run.stdout.splitlines():
        fields = line.strip().split()
        if len(fields) == 2 and fields[0].isdigit() and fields[1] in ("0", "1"):
            proven[int(fields[0])] = fields[1] == "1"
    for n in nums:
        if not proven.get(n, False):
            where = "; ".join(large_prime_contexts[n][:3])
            fail(f"PARI did not prove {n} prime ({where})")
    if all(proven.get(n, False) for n in nums):
        print(f"ok   primality: PARI proved {len(nums)} factors above 2^64")


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def sha256_str(s):
    return hashlib.sha256(s.encode()).hexdigest()


@lru_cache(maxsize=None)
def universal_level_value(d):
    """N(Phi_d(U)) for Tr(U)=-625 and N(U)=3125."""
    phi = cyclotomic_poly(int(d), LEVEL_X)
    return abs(int(resultant(LEVEL_MINPOLY, phi, LEVEL_X)))


# --- arithmetic in F_p[X] / (X^4 + X^3 + X^2 + X + 1) -----------------

ONE = (1, 0, 0, 0)


def phi5_mul(a, b, p):
    """Multiply two elements given as coefficient 4-tuples."""
    raw = [0] * 7
    for i in range(4):
        if a[i]:
            for j in range(4):
                raw[i + j] = (raw[i + j] + a[i] * b[j]) % p
    for k in (6, 5, 4):  # X^k = -(X^(k-1)+X^(k-2)+X^(k-3)+X^(k-4))
        c = raw[k]
        if c:
            raw[k] = 0
            for t in range(k - 4, k):
                raw[t] = (raw[t] - c) % p
    return tuple(raw[:4])


def phi5_pow(a, e, p):
    r = ONE
    while e:
        if e & 1:
            r = phi5_mul(r, a, p)
        a = phi5_mul(a, a, p)
        e >>= 1
    return r


def check_order_certificate(name, oc):
    p = oc["p"]
    T = oc["T"]
    if p % 5 not in (2, 3):
        fail(f"{name}: order certificate p={p} is not inert mod 5")
        return
    if oc.get("group_order") != p ** 4 - 1:
        fail(f"{name}: group_order for p={p} is not p^4-1")
    if (p ** 4 - 1) % T != 0:
        fail(f"{name}: T={T} does not divide p^4-1 for p={p}")
    back = 1
    for q, e in oc["T_factorization"].items():
        check_prime(int(q), f"{name}: T factor")
        back *= int(q) ** int(e)
    if back != T:
        fail(f"{name}: factorback of T_factorization != T for p={p}")
    x_minus_1 = ((p - 1) % p, 1, 0, 0)
    if phi5_pow(x_minus_1, T, p) != ONE:
        fail(f"{name}: (X-1)^T != 1 for p={p}")
    if not oc.get("power_T_is_one"):
        fail(f"{name}: power_T_is_one flag is false for p={p}")
    for q, wit in oc["power_T_over_prime_witnesses"].items():
        got = phi5_pow(x_minus_1, T // int(q), p)
        want = tuple(int(c) % p for c in wit)
        if got != want:
            fail(f"{name}: witness (X-1)^(T/{q}) mismatch for p={p}")
        if want == ONE:
            fail(f"{name}: witness (X-1)^(T/{q}) equals 1 for p={p}: "
                 f"T is not the exact order")


# --- fiber certificates ----------------------------------------------

def detector_classes(c):
    if "detector" in c:  # schema 1
        return [(cl["modulus"], cl["residue"]) for cl in c["detector"]["classes"]]
    return [(m, r) for (_, r, m) in c["detector_classes"]]  # schema 2


def factors_of(c):
    out = {}
    if "factorization" in c:  # schema 1: global factor map
        for q, e in c["factorization"]["factors"].items():
            out[int(q)] = max(out.get(int(q), 0), int(e))
    else:  # schema 2: per-level maps
        for lv in c["level_factorizations"].values():
            for q, e in lv["factorization"].items():
                out[int(q)] = max(out.get(int(q), 0), int(e))
    return out


def missing_levels(c):
    if c.get("missing_required_levels"):
        return c["missing_required_levels"]
    ls = c.get("level_summary", {})
    return ls.get("missing_required_levels") or []


def check_fiber(path, manifest_hashes):
    c = json.load(open(path))
    name = os.path.basename(path)
    if name in manifest_hashes:
        got = sha256_file(path)
        if got != manifest_hashes[name]:
            fail(f"{name}: file hash differs from fibers/MANIFEST.json")
    else:
        fail(f"{name}: not listed in fibers/MANIFEST.json")
    p1, p2 = c["pair"]
    if c.get("status") != "fibra_vuota_certificata":
        fail(f"{name}: unexpected status {c.get('status')}")
    miss = missing_levels(c)
    if miss:
        fail(f"{name}: missing required levels {miss}")
    fac = factors_of(c)
    det = detector_classes(c)
    for q in fac:
        check_prime(q, f"{name}: listed factor")
    surv = [q for q in fac if q % 5 in (2, 3) and q > p2
            and any(q % m == r for (m, r) in det)]
    if surv:
        fail(f"{name}: survivors in detector classes: {surv}")
    n_orders = 0
    if "level_factorizations" in c:  # schema 2
        for d, lv in c["level_factorizations"].items():
            expected = universal_level_value(int(d))
            prod = 1
            for q, e in lv["factorization"].items():
                prod *= int(q) ** int(e)
            if prod != expected:
                fail(f"{name}: level {d} factorization differs from "
                     "independently recomputed N(Phi_d(U))")
            if "value" in lv:
                if expected != int(lv["value"]):
                    fail(f"{name}: level {d} reconstruction mismatch")
            elif "value_sha256" in lv:
                if sha256_str(str(expected)) != lv["value_sha256"]:
                    fail(f"{name}: level {d} value hash mismatch")
            else:
                fail(f"{name}: level {d} carries no value and no hash")
            if not lv.get("exact_reconstruction", True):
                fail(f"{name}: level {d} exact_reconstruction flag false")
            if not lv.get("all_prime_factors_certified", True):
                fail(f"{name}: level {d} primality flag false")
        req = set(map(int, c.get("required_universal_levels", [])))
        have = set(map(int, c["level_factorizations"].keys()))
        if not req <= have:
            fail(f"{name}: required levels absent: {sorted(req - have)}")
    else:  # schema 1
        fz = c["factorization"]
        prod = 1
        for q, e in fz["factors"].items():
            prod *= int(q) ** int(e)
        level_values = {}
        for lv in c["levels"]:
            d = int(lv["d"])
            value = universal_level_value(d)
            level_values[d] = value
            if len(str(value)) != lv.get("piece_digits"):
                fail(f"{name}: level {d} piece digit count mismatch")
            if sha256_str(str(value)) != lv.get("piece_sha256"):
                fail(f"{name}: level {d} piece hash mismatch")
        scope = 1
        for d in c["level_summary"]["factorized_levels"]:
            if int(d) not in level_values:
                fail(f"{name}: factorized level {d} has no level record")
                continue
            scope *= level_values[int(d)]
        if prod != scope:
            fail(f"{name}: global factor map differs from independently "
                 "recomputed level product")
        if len(str(scope)) != fz.get("scope_product_digits"):
            fail(f"{name}: scope product digit count mismatch")
        if sha256_str(str(scope)) != fz.get("scope_product_sha256"):
            fail(f"{name}: scope product hash mismatch")
        if "payload_sha256" in c:
            d = {k: v for k, v in c.items() if k != "payload_sha256"}
            enc = json.dumps(d, sort_keys=True, separators=(",", ":"),
                             ensure_ascii=False)
            if sha256_str(enc) != c["payload_sha256"]:
                fail(f"{name}: payload self-hash mismatch")
        for oc in c.get("detector", {}).get("order_certificates", []):
            check_order_certificate(name, oc)
            n_orders += 1
    extra = f", {n_orders} order certs" if n_orders else ""
    print(f"ok   {name}: pair ({p1},{p2}), {len(fac)} primes, empty{extra}")


# --- census -----------------------------------------------------------

def fib_pair(n):
    """(F_n, F_(n+1)) by fast doubling."""
    if n == 0:
        return (0, 1)
    a, b = fib_pair(n >> 1)
    c = a * (2 * b - a)
    d = a * a + b * b
    return (d, c + d) if n & 1 else (c, d)


def strip_2_5(m):
    while m % 2 == 0:
        m //= 2
    while m % 5 == 0:
        m //= 5
    return m


def census_H(n):
    f_n, f_np1 = fib_pair(n)
    a_n = 2 * f_np1 - f_n if n % 2 == 0 else f_n
    residue = (pow(5, n - 1, a_n) + 1) % a_n
    return strip_2_5(math.gcd(a_n, residue))


def check_census(full):
    path = os.path.join(CERT, "manifest_censimento_Hn_certificato.json")
    m = json.load(open(path))
    if m.get("status") != "complete":
        fail("census: status is not complete")
    if m.get("split_factor_count", -1) != 0 or m.get("split_factors"):
        fail("census: split factors present")
    rows = m["factorizations"]
    if len(rows) != m.get("complete_factorizations"):
        fail("census: row count != complete_factorizations")
    if m.get("nontrivial_H") != m.get("complete_factorizations"):
        fail("census: factorization count mismatch")
    distinct = {}
    for row in rows:
        h = int(row["H"])
        back = 1
        for f in row["factors"]:
            p, e = int(f["p"]), int(f["exponent"])
            back *= p ** e
            distinct[p] = distinct.get(p, 0) + e
            if p % 5 in (1, 4):
                fail(f"census: split factor {p} at n={row['n']}")
            if p in (2, 5):
                fail(f"census: stripped prime {p} survives at n={row['n']}")
        if back != h:
            fail(f"census: factorback mismatch at n={row['n']}")
    if len(distinct) != m.get("distinct_factor_count"):
        fail("census: distinct factor count mismatch")
    if distinct and max(distinct) != m.get("max_distinct_factor"):
        fail("census: max distinct factor mismatch")
    listed = set(map(int, m["distinct_factors"].keys()))
    if listed != set(distinct):
        fail("census: distinct_factors keys differ from the rows")
    for p in distinct:
        check_prime(p, "census factor")
    mode = "smoke + row coherence"
    if full:
        by_n = {int(r["n"]): int(r["H"]) for r in rows}
        n_max = m["n_max"]
        tested = nontriv = 0
        for n in range(4, n_max + 1, 5):
            tested += 1
            h = census_H(n)
            if h > 1:
                nontriv += 1
                if by_n.get(n) != h:
                    fail(f"census replay: H_{n} = {h} != manifest "
                         f"{by_n.get(n)}")
            elif n in by_n:
                fail(f"census replay: manifest lists trivial n={n}")
            if tested % 4000 == 0:
                print(f"     ... census replay {tested}/{(n_max - 4)//5 + 1}",
                      flush=True)
        if tested != m.get("tested_indices"):
            fail("census replay: tested index count mismatch")
        if nontriv != m.get("nontrivial_H"):
            fail("census replay: nontrivial count mismatch")
        mode = "FULL REPLAY"
    print(f"ok   census ({mode}): {m['tested_indices']} indices, "
          f"{m['nontrivial_H']} nontrivial H, "
          f"{m['distinct_factor_count']} distinct primes, 0 split")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--full", action="store_true",
                    help="additionally replay the whole census from scratch "
                         "(recompute every H_n; a couple of minutes)")
    args = ap.parse_args()

    mpath = os.path.join(CERT, "fibers", "MANIFEST.json")
    fm = json.load(open(mpath))
    manifest_hashes = {os.path.basename(k): v
                       for k, v in fm.get("files", {}).items()}
    if fm.get("certified_empty_fibers") != len(manifest_hashes):
        fail("fibers/MANIFEST.json: fiber count mismatch")

    for f in sorted(glob.glob(os.path.join(CERT, "fibers",
                                           "certificato_fibra_*.json"))):
        check_fiber(f, manifest_hashes)
    check_census(args.full)
    prove_large_primes_with_pari()

    print("ALL CHECKS PASSED" if ok else "CHECKS FAILED")
    sys.exit(0 if ok else 1)


main()
