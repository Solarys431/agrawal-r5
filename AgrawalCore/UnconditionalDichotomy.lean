/-
Nucleo Lean della campagna Agrawal — DICOTOMIA LOGICA DEI DUE TESTIMONI.

Questo modulo separa i due muri rimasti nel montaggio squarefree a r = 5.
Un candidato globale che non possiede un testimone locale split di ordine
quattro ricade, per il teorema di riduzione aritmetico ancora da collegare
al kernel, nel ramo delle fibre globali.

Il teorema qui formalizzato è il passaggio logico corretto:

  candidato -> testimone locale H4 oppure testimone globale di fibra.

La riduzione dal candidato senza testimone locale alla fibra è una premessa
esplicita `ReductionToFiber`; non viene trasformata in un assioma e il modulo
non afferma né H4 né la vacuità universale delle fibre.

Campagna UNICO, 27 luglio 2026.
-/
import AgrawalCore.ScalarCompleteness
import AgrawalCore.SquarefreeIngress

open Polynomial

namespace AgrawalCore

/-- Un candidato squarefree non banale alla conclusione `n² ≡ 1 (mod 5)`.
Questa definizione non afferma che un simile candidato esista. -/
def SquarefreeCounterexampleCandidate (n : ℕ) : Prop :=
  Squarefree n
    ∧ (¬ n.Prime)
    ∧ (¬ ((5 : ℕ) ∣ n))
    ∧ AgrawalCongruenceFive n
    ∧ (n ^ 2 % 5 ≠ 1)

/-- H4 richiesta soltanto sui fattori primi di un intero fissato `n`.
La forma locale evita di assumere la congettura universale quando nel
montaggio servono soltanto i fattori del candidato corrente. -/
def LocalH4For (n : ℕ) : Prop :=
  ∀ p (hp : p.Prime), p ∣ n → IsSquare (5 : ZMod p) →
    ¬ @HasOrderFourTransport p ⟨hp⟩

/-- Certificato locale esplicito del fallimento di H4 lungo un fattore
primo split del candidato `n`. -/
def SplitOrderFourWitness (n : ℕ) : Prop :=
  ∃ p, ∃ hp : p.Prime,
    p ∣ n
      ∧ IsSquare (5 : ZMod p)
      ∧ @HasOrderFourTransport p ⟨hp⟩

/-- L'assenza della H4 locale è esattamente l'esistenza di un testimone
split d'ordine quattro. -/
theorem not_localH4For_iff_splitOrderFourWitness (n : ℕ) :
    ¬ LocalH4For n ↔ SplitOrderFourWitness n := by
  classical
  simp only [LocalH4For, SplitOrderFourWitness, not_forall, not_not]
  constructor
  · rintro ⟨p, hp⟩
    rcases hp with ⟨hpp, hp⟩
    rcases hp with ⟨hpdvd, hp⟩
    rcases hp with ⟨hsplit, htransport⟩
    exact ⟨p, hpp, hpdvd, hsplit, htransport⟩
  · rintro ⟨p, hpp, hpdvd, hsplit, htransport⟩
    exact ⟨p, hpp, hpdvd, hsplit, htransport⟩

/-- Una riduzione aritmetica verso un predicato di fibra: ogni candidato
senza testimoni locali H4 produce il certificato globale indicato da
`FiberWitness`. Questa è un'interfaccia, non un assioma del progetto. -/
def ReductionToFiber (FiberWitness : ℕ → Prop) : Prop :=
  ∀ n, SquarefreeCounterexampleCandidate n → LocalH4For n → FiberWitness n

/-- **DICOTOMIA LOGICA, forma kernel-pura.** Dalla premessa esplicita che
la riduzione aritmetica sia valida nel ramo localmente H4 segue che ogni
candidato globale esibisce o un fattore split con trasporto di ordine quattro,
oppure un testimone nella fibra globale. La premessa non è dimostrata in
questo modulo. -/
theorem squarefree_counterexample_witness_dichotomy
    {FiberWitness : ℕ → Prop}
    (hreduce : ReductionToFiber FiberWitness)
    {n : ℕ} (hn : SquarefreeCounterexampleCandidate n) :
    SplitOrderFourWitness n ∨ FiberWitness n := by
  classical
  by_cases hlocal : LocalH4For n
  · exact Or.inr (hreduce n hn hlocal)
  · exact Or.inl
      ((not_localH4For_iff_splitOrderFourWitness n).mp hlocal)

/-- Se entrambi i tipi di certificato vengono esclusi, non resta alcun
candidato globale. È la forma di chiusura richiesta al futuro montaggio. -/
theorem no_squarefree_counterexample_of_no_witnesses
    {FiberWitness : ℕ → Prop}
    (hreduce : ReductionToFiber FiberWitness)
    (hlocal : ∀ n, ¬ SplitOrderFourWitness n)
    (hfiber : ∀ n, ¬ FiberWitness n) :
    ∀ n, ¬ SquarefreeCounterexampleCandidate n := by
  intro n hn
  rcases squarefree_counterexample_witness_dichotomy hreduce hn with
    hsplit | hglobal
  · exact hlocal n hsplit
  · exact hfiber n hglobal

end AgrawalCore
