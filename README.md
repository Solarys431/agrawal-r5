# Agrawal's conjecture at r = 5: certified core

<details open>
<summary><strong>English</strong></summary>

A structural study of Agrawal's conjecture at r = 5, produced by
an autonomous multi-model pipeline with external review. This
repository is the verification surface: the Lean core, the paper, and
the computational certificates. We do **not** prove the conjecture;
the two open problems (the local hypothesis H4 and the global
emptiness of the fibers) are stated precisely in the paper.

## Lean core

Twenty-two modules over plain Mathlib (pinned), no `sorry`, no extra
axioms. Build:

```
lake exe cache get
lake build
```

| Result | Declaration | File |
|---|---|---|
| Index lemma | `mul_dvd_gcd_mul` | `IndexLemma.lean` |
| Golden Frobenius: ε^p = 1 − ε (inert case) | `golden_frobenius` | `InertiaCore.lean` |
| Golden half-period: ε^(p+1) = −1 | `golden_pow_p_succ` | `InertiaCore.lean` |
| Inertia theorem for J_n (golden form) | `inertia_J` | `InertiaCore.lean` |
| Fibonacci bridge: ε^(n+1) = F_(n+1)ε + F_n | `golden_pow_fib` | `InertiaCore.lean` |
| Golden–cyclotomic entanglement: ζ³ε²(ζ−1)⁴ = 5 | `entanglement` | `Entanglement.lean` |
| Inertia, divisibility forms (F_n / L_n) | `inertia_J_fib`, `inertia_J_lucas` | `FibBridge.lean` |
| Quadratic reciprocity bridge for 5 | `not_isSquare_five` | `Reciprocity.lean` |
| Canonical support witness: p ≡ 2 (mod 5) ⟹ p ∣ H_((p+1)/2) | `support_witness` | `SupportBridge.lean` |
| Fermat shadow (arithmetic glue) | `fermat_shadow` | `FermatShadow.lean` |
| **The bridge: for squarefree n with 5 ∤ n, Agrawal's congruence at r = 5 ⟹ n ∣ 5^(n−1) − 1** | `agrawal_fermat_shadow` | `AgrawalBridge.lean` |
| **The two-adic jaw: v₂(q−1) ≤ v₂(n−1) for every inert prime factor q of a counterexample** | `agrawal_two_adic_jaw` | `TwoAdicJaw.lean` |
| Mod-4 corollary: n ≡ 3 (mod 4) ⟹ every inert factor is ≡ 3 (mod 4) | `agrawal_inert_mod_four` | `TwoAdicJaw.lean` |
| 2-adic saturation of a divisor | `pow_two_dvd_of_not_dvd_half` | `TwoAdicJaw.lean` |
| Product identity (ζ−1)(ζ²−1)(ζ³−1)(ζ⁴−1) = 5 | `prod_pow_sub_one` | `AgrawalBridge.lean` |
| Mod-5 corollaries | `inertia_J_fib_mod5`, `inertia_J_lucas_mod5` | `Corollaries.lean` |
| Bounded order: ord(ζ−1) divides 10(p²−1), both inert classes | `order_bounded` | `OrderBound.lean` |
| Box identity and its arithmetic corollary | `prod_pairs_sub_prod_squares`, `lt_two_mul_of_sq_le` | `BoxLemma.lean` |
| Carmichael and Lucas–Carmichael numbers (Korselt) | `IsCarmichael`, `IsLucasCarmichael` | `Korselt.lean` |
| Korselt's criterion: Carmichael ⟹ Fermat pseudoprime in every coprime base | `IsCarmichael.fermatPsp` | `Korselt.lean` |
| Class arithmetic: k ≡ 1 (mod 4) factors ≡ 3 (mod 80) ⟹ product ≡ 3 (mod 80) | `prod_class_mod_eighty` | `ClassMod80.lean` |
| The escape stays closed: n ≡ 3 (mod 80) ⟹ n² ≢ 1 (mod 5) | `sq_not_one_mod_five` | `ClassMod80.lean` |
| lcm(p−1, p+1, 80) = 10(p²−1) for p ≡ 3 (mod 80) | `lcm_three_eq` | `LcmIdentity.lean` |
| Korselt's conditions give n ≡ p (mod 10(p²−1)) | `sub_dvd_of_korselt` | `LcmIdentity.lean` |
| Cyclotomic component of Agrawal's congruence | `lenstra_local` | `LenstraLocal.lean` |
| Recomposition: (X−1) ∣ f and Φ₅ ∣ f ⟹ (X⁵−1) ∣ f | `dvd_of_dvd_both` | `Recompose.lean` |
| The congruence modulo p | `agrawal_mod_p` | `LocalGlue.lean` |
| Local to global for squarefree n | `congruence_of_local` | `GlobalGlue.lean` |
| Bridge: k ≡ 1 (mod 4) factors ≡ 3 (mod 80) ⟹ n ≡ 3 (mod 80) | `mod_eighty_of_card` | `CardBridge.lean` |
| **The Lenstra–Pomerance proposition, original hypotheses** | `lenstra_proposition_card` | `CardBridge.lean` |
| The same with n ≡ 3 (mod 80) assumed directly | `lenstra_proposition` | `Lenstra.lean` |

### On the Lenstra–Pomerance proposition

`lenstra_proposition` is the statement of Lenstra and Pomerance
([AIM notes, 2003](https://aimath.org/WWN/primesinp/articles/html/50a/),
pp. 30–32), which to our knowledge had not been machine-checked before. Three
things must be said plainly.

**The mathematics is theirs, not ours.** The AIM proof already contains the
identity (ζ₅−1)^(p²) = −ζ₅^(−1)(ζ₅−1), the bound on the order of ζ₅−1, and the
reduction to n ≡ p (mod 10(p²−1)). Our route is the same one, repackaged
through the identity lcm(p−1, p+1, 80) = 10(p²−1). We claim only the mechanical
verification.

**The statement covers the original hypotheses.** `lenstra_proposition_card`
assumes exactly what the source assumes: k ≡ 1 (mod 4) prime factors, all
≡ 3 (mod 80), and the two Korselt conditions. That n ≡ 3 (mod 80) follows is
proved in `mod_eighty_of_card`, not assumed. (An earlier version of this
repository assumed it; the gap was found by adversarial review on 2026-07-26
and closed the same day.)

**Primes satisfy the hypotheses.** n = 83 is a witness, and is obviously not a
counterexample. Only a **composite** witness would be one, and none is known:
it would be simultaneously a Carmichael and a Lucas–Carmichael number, a
question open since Pomerance raised it in 1984. The proposition is a
*sufficient* condition for building a counterexample, not a necessary condition
on all of them.

## Paper

`paper/agrawal-r5.pdf`: the kernel-certified part of the study. Everything called a theorem in it is checked by Lean, every
computational claim carries a certificate, and the two central open
problems are posed without any claim of proof.

## Certificates

`certificates/`: seven certified-empty fibers of the three-factor
case (each certificate embeds its own detector criterion, level
factorizations and, in schema 1, multiplicative-order certificates;
all prime factors proven) and the self-certifying census manifest
(n ≤ 100000, all 9,725 factorizations embedded and proven, zero
split factors). Re-check everything shipped here with

```
python3 tools/verify_certificates.py          # certificate replay
python3 tools/verify_certificates.py --full   # + full census replay
```

The default mode re-verifies file hashes against the fiber manifest,
primality of every listed factor, detector-class emptiness, level
reconstructions against the embedded value hashes, the embedded
multiplicative-order certificates (recomputed in F_p[X]/Φ₅) and the
row-by-row coherence of the census manifest. `--full` additionally
recomputes every H_n from scratch and compares it with the manifest;
the census can also be regenerated wholesale with
`certificates/censimento_Hn_certificato_v2.py` (requires PARI/GP).

Two files are provenance only and are NOT replayable from this
clone: `certificates/INDICE_PROVENIENZA_ESTERNA_AGRAWAL.json` (a
SHA-256 index of the working artifacts of the wider study) and
`certificates/SHA256SUMS_S28_1E9.txt` (hash-only commitments for the
10^9 prime-first corpus). They ship hashes, not artifacts.

</details>

<details>
<summary><strong>Italiano</strong></summary>

Uno studio strutturale della congettura di Agrawal per r = 5,
prodotto da una pipeline autonoma multi-modello con revisione esterna.
Questo repository è la superficie di verifica: il nucleo Lean, il
paper e i certificati computazionali. La congettura **non** è
dimostrata; i due problemi aperti (l'ipotesi locale H4 e la vacuità
globale delle fibre) sono enunciati con precisione nel paper.

## Nucleo Lean

Dieci moduli su Mathlib puro (versione pinnata), senza `sorry`, senza
assiomi aggiuntivi. Compilazione:

```
lake exe cache get
lake build
```

La tabella dei risultati è nella sezione inglese: ogni riga mappa un
teorema del paper sulla sua dichiarazione Lean.

## Paper

`paper/agrawal-r5.pdf`: la parte dello studio certificata dal kernel. Tutto ciò che vi è chiamato teorema è verificato da
Lean, ogni claim computazionale ha il suo certificato, e i due
problemi aperti centrali sono posti senza alcuna pretesa di prova.

## Certificati

`certificates/`: le sette fibre certificate vuote del caso a tre
fattori (ogni certificato incorpora il proprio criterio di
rilevazione, le fattorizzazioni di livello e, nello schema 1, i
certificati di ordine moltiplicativo, con tutti i fattori primi
provati) e il manifest autocertificante del censimento (n ≤ 100000,
tutte le 9.725 fattorizzazioni incorporate e provate, zero fattori
split). Tutto ciò che è distribuito qui si ricontrolla con

```
python3 tools/verify_certificates.py          # replay dei certificati
python3 tools/verify_certificates.py --full   # + replay integrale del censimento
```

La modalità base riverifica gli hash dei file contro il manifest
delle fibre, la primalità di ogni fattore elencato, la vuotezza
nelle classi del rilevatore, le ricostruzioni dei livelli contro gli
hash incorporati, i certificati di ordine moltiplicativo (ricalcolati
in F_p[X]/Φ₅) e la coerenza riga per riga del manifest del
censimento. `--full` ricalcola in aggiunta ogni H_n da zero e lo
confronta col manifest; il censimento si può anche rigenerare per
intero con `certificates/censimento_Hn_certificato_v2.py` (richiede
PARI/GP).

Due file sono di sola provenienza e NON sono rieseguibili da questo
clone: `certificates/INDICE_PROVENIENZA_ESTERNA_AGRAWAL.json` (un
indice SHA-256 degli artefatti di lavoro dello studio più ampio) e
`certificates/SHA256SUMS_S28_1E9.txt` (impegni hash-only per il
corpus prime-first a 10^9). Contengono hash, non artefatti.

</details>

---

Direction and operation of the pipeline: **Daniele Cappello**.
Formalization: Claude (Anthropic), orchestrated multi-model pipeline; every
declaration checked by the Lean 4 kernel.
