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
| **The bridge: Agrawal's congruence ⟹ base-5 pseudoprime** | `agrawal_fermat_shadow` | `AgrawalBridge.lean` |
| Product identity (ζ−1)(ζ²−1)(ζ³−1)(ζ⁴−1) = 5 | `prod_pow_sub_one` | `AgrawalBridge.lean` |
| Mod-5 corollaries | `inertia_J_fib_mod5`, `inertia_J_lucas_mod5` | `Corollaries.lean` |

## Paper

`paper/agrawal-certified-core.pdf`: the kernel-certified core of the
study. Everything called a theorem in it is checked by Lean, every
computational claim carries a certificate, and the two central open
problems are posed without any claim of proof.

## Certificates

`certificates/`: seven certified-empty fibers of the three-factor
case (each certificate embeds its own detector criterion and level
factorizations, all prime factors proven), the self-certifying census
manifest (n ≤ 100000, proven factorizations, zero split factors), the
reproducibility manifest, and the SHA-256 sums of the 10^9 prime-first
corpus. Everything is replayable; nothing depends on trusting us. Run
`python3 tools/verify_certificates.py` to re-check every fiber
certificate (primality cross-check, detector-class emptiness,
internal consistency) and the census manifest.

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
rilevazione e le fattorizzazioni di livello, con tutti i fattori
primi provati), il manifest autocertificante del censimento
(n ≤ 100000, fattorizzazioni provate, zero fattori split), il
manifest di riproducibilità e le somme SHA-256 del corpus prime-first
a 10^9. Tutto è rieseguibile; nulla richiede fiducia in noi. Con
`python3 tools/verify_certificates.py` si ricontrollano tutti i
certificati di fibra (primalità, vuotezza nelle classi del
rilevatore, coerenza interna) e il manifest del censimento.

</details>
