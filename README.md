# Agrawal's conjecture at r = 5: certified core

<details open>
<summary><strong>English</strong></summary>

A structural study of Agrawal's conjecture (2002) at r = 5, produced by
an autonomous multi-model pipeline with external review. This
repository is the verification surface: the Lean core, the paper, and
the computational certificates. We do **not** prove the conjecture;
the two open problems (the local hypothesis H4 and the global
emptiness of the fibers) are stated precisely in the paper.

## Lean core

Eight modules over plain Mathlib (pinned), no `sorry`, no extra
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
| Mod-5 corollaries | `inertia_J_fib_mod5`, `inertia_J_lucas_mod5` | `Corollaries.lean` |

## Paper

`paper/agrawal-local-structure-v17.pdf`: the full study, with every
statement carrying its exact status (theorem / theorem under GRH /
open) and its pointer to a certificate or a Lean declaration.

## Certificates

`certificates/`: seven certified-empty fibers of the three-factor
case (each certificate embeds its own detector criterion and level
factorizations, all prime factors proven), the self-certifying census
manifest (n ≤ 100000, proven factorizations, zero split factors), the
reproducibility manifest, and the SHA-256 sums of the 10^9 prime-first
corpus. Everything is replayable; nothing depends on trusting us.

</details>

<details>
<summary><strong>Italiano</strong></summary>

Uno studio strutturale della congettura di Agrawal (2002) per r = 5,
prodotto da una pipeline autonoma multi-modello con revisione esterna.
Questo repository è la superficie di verifica: il nucleo Lean, il
paper e i certificati computazionali. La congettura **non** è
dimostrata; i due problemi aperti (l'ipotesi locale H4 e la vacuità
globale delle fibre) sono enunciati con precisione nel paper.

## Nucleo Lean

Otto moduli su Mathlib puro (versione pinnata), senza `sorry`, senza
assiomi aggiuntivi. Compilazione:

```
lake exe cache get
lake build
```

La tabella dei risultati è nella sezione inglese: ogni riga mappa un
teorema del paper sulla sua dichiarazione Lean.

## Paper

`paper/agrawal-local-structure-v17.pdf`: lo studio completo, con lo
status esatto di ogni enunciato (teorema / teorema sotto GRH / aperto)
e il puntatore al certificato o alla dichiarazione Lean.

## Certificati

`certificates/`: le sette fibre certificate vuote del caso a tre
fattori (ogni certificato incorpora il proprio criterio di
rilevazione e le fattorizzazioni di livello, con tutti i fattori
primi provati), il manifest autocertificante del censimento
(n ≤ 100000, fattorizzazioni provate, zero fattori split), il
manifest di riproducibilità e le somme SHA-256 del corpus prime-first
a 10^9. Tutto è rieseguibile; nulla richiede fiducia in noi.

</details>
