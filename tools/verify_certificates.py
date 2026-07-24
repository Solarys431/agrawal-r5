#!/usr/bin/env python3
"""Independent re-verifier for the certificates shipped in this repo.

What it re-checks, certificate by certificate:
  - fiber certificates (both schemas): status field, no missing
    required level, primality of every listed prime factor
    (sympy.isprime: deterministic below 2^64, BPSW above; the original
    certificates additionally carry factor_proven primality from
    PARI), and EMPTINESS, i.e. no listed factor that is inert mod 5,
    larger than p2 and inside one of the certificate's own detector
    classes;
  - exact reconstruction of every level whose factorization embeds
    its value (schema with explicit level values);
  - the census manifest: status complete, zero split factors, count
    coherence.

Exit code 0 iff every check passes. No network, no trust required.
"""
import json, sys, glob, os

try:
    from sympy import isprime
except ImportError:
    sys.exit("please install sympy (pip install sympy)")

HERE = os.path.dirname(os.path.abspath(__file__))
CERT = os.path.join(HERE, "..", "certificates")
ok = True


def fail(msg):
    global ok
    ok = False
    print("FAIL:", msg)


def detector_classes(c):
    if "detector" in c:  # schema 1
        return [(cl["modulus"], cl["residue"]) for cl in c["detector"]["classes"]]
    return [(m, r) for (_, r, m) in c["detector_classes"]]  # schema 2


def factors_of(c):
    out = {}
    if "factorization" in c:  # schema 1: global factor map
        for q, e in c["factorization"]["factors"].items():
            out[int(q)] = max(out.get(int(q), 0), int(e))
    else:  # schema 2: per-level maps, values may be embedded
        for lv in c["level_factorizations"].values():
            for q, e in lv["factorization"].items():
                out[int(q)] = max(out.get(int(q), 0), int(e))
    return out


def check_fiber(path):
    c = json.load(open(path))
    name = os.path.basename(path)
    p1, p2 = c["pair"]
    if c.get("status") != "fibra_vuota_certificata":
        fail(f"{name}: unexpected status {c.get('status')}")
    if c.get("missing_required_levels"):
        fail(f"{name}: missing required levels {c['missing_required_levels']}")
    fac = factors_of(c)
    det = detector_classes(c)
    for q in fac:
        if q > 3 and not isprime(q):
            fail(f"{name}: listed factor {q} is not prime")
    surv = [q for q in fac if q % 5 in (2, 3) and q > p2
            and any(q % m == r for (m, r) in det)]
    if surv:
        fail(f"{name}: survivors in detector classes: {surv}")
    # reconstruction where level values are embedded
    if "level_factorizations" in c:
        for d, lv in c["level_factorizations"].items():
            if "value" in lv:
                prod = 1
                for q, e in lv["factorization"].items():
                    prod *= int(q) ** int(e)
                if prod != int(lv["value"]):
                    fail(f"{name}: level {d} reconstruction mismatch")
    print(f"ok   {name}: pair ({p1},{p2}), {len(fac)} primes, empty")


def check_census():
    path = os.path.join(CERT, "manifest_censimento_Hn_certificato.json")
    m = json.load(open(path))
    if m.get("status") != "complete":
        fail("census: status is not complete")
    if m.get("split_factor_count", -1) != 0 or m.get("split_factors"):
        fail("census: split factors present")
    if m.get("nontrivial_H") != m.get("complete_factorizations"):
        fail("census: factorization count mismatch")
    print(f"ok   census: {m['tested_indices']} indices, "
          f"{m['nontrivial_H']} nontrivial H, 0 split factors")


for f in sorted(glob.glob(os.path.join(CERT, "fibers", "certificato_fibra_*.json"))):
    check_fiber(f)
check_census()

print("ALL CHECKS PASSED" if ok else "CHECKS FAILED")
sys.exit(0 if ok else 1)
