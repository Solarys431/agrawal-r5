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

Nine modules over plain Mathlib (pinned), no `sorry`, no extra
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
| Product identity (ζ−1)(ζ²−1)(ζ³−1)(ζ⁴−1) = 5 | `prod_pow_sub_one` | `AgrawalBridge.lean` |
| Mod-5 corollaries | `inertia_J_fib_mod5`, `inertia_J_lucas_mod5` | `Corollaries.lean` |

## Paper

`paper/agrawal-certified-core.pdf`: the kernel-certified core of the
study. Everything called a theorem in it is checked by Lean, every
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

Nove moduli su Mathlib puro (versione pinnata), senza `sorry`, senza
assiomi aggiuntivi. Compilazione:

```
lake exe cache get
lake build
```

La tabella dei risultati è nella sezione inglese: ogni riga mappa un
teorema del paper sulla sua dichiarazione Lean.

## Paper

`paper/agrawal-certified-core.pdf`: il nucleo certificato dal kernel
dello studio. Tutto ciò che vi è chiamato teorema è verificato da
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
