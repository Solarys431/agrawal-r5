/-
Nucleo Lean della campagna Agrawal (S45) — lotto 5: la reciprocità.
`p ≡ ±2 (mod 5)` (cioè p inerte in Q(√5)) implica che 5 non è un
quadrato mod p: le ipotesi dei teoremi diventano quelle aritmetiche
vere del paper. Campagna UNICO, 24 luglio 2026.
-/
import Mathlib.NumberTheory.LegendreSymbol.QuadraticReciprocity
import Mathlib.Tactic.NormNum.Prime

namespace AgrawalCore

instance fact_prime_five : Fact (Nat.Prime 5) := ⟨by norm_num⟩

variable {p : ℕ} [Fact p.Prime]

/-- Per `p ≠ 2` primo con `p ≡ 2` o `3 (mod 5)`, il `5` non è un
quadrato mod `p` (reciprocità quadratica, ramo `5 ≡ 1 (mod 4)`). -/
theorem not_isSquare_five (hp2 : p ≠ 2) (hp : p % 5 = 2 ∨ p % 5 = 3) :
    ¬ IsSquare (5 : ZMod p) := by
  have hp5 : p ≠ 5 := by rcases hp with h | h <;> omega
  have h50 : ((5 : ℤ) : ZMod p) ≠ 0 := by
    have h : ((5 : ℕ) : ZMod p) ≠ 0 := by
      rw [Ne, CharP.cast_eq_zero_iff (ZMod p) p]
      intro hdvd
      exact hp5 ((Nat.prime_dvd_prime_iff_eq Fact.out fact_prime_five.out).mp hdvd)
    exact_mod_cast h
  intro hsq
  have h1 : legendreSym p 5 = 1 :=
    (legendreSym.eq_one_iff p h50).mpr (by exact_mod_cast hsq)
  have hrec : legendreSym p 5 = legendreSym 5 p :=
    legendreSym.quadratic_reciprocity_one_mod_four (by norm_num) hp2
  have hmod : legendreSym 5 (p : ℤ) = legendreSym 5 ((p % 5 : ℕ) : ℤ) := by
    rw [legendreSym.mod]
    norm_cast
  rcases hp with h | h
  · rw [h] at hmod
    have hval : legendreSym 5 ((2 : ℕ) : ℤ) = -1 := by decide
    rw [hrec, hmod, hval] at h1
    exact absurd h1 (by norm_num)
  · rw [h] at hmod
    have hval : legendreSym 5 ((3 : ℕ) : ℤ) = -1 := by decide
    rw [hrec, hmod, hval] at h1
    exact absurd h1 (by norm_num)

end AgrawalCore
