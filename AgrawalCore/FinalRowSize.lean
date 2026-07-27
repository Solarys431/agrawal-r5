/-
The size obstruction in the final local row.

This module isolates the deterministic arithmetic core of the reverse-fibre
argument.  It intentionally does not formalize an asymptotic claim or a finite
computer census.
-/
import Mathlib.Data.Nat.ModEq
import Mathlib.Tactic.Order

namespace AgrawalCore

/-- A natural number strictly between `1` and the modulus cannot be congruent
to `1` modulo that modulus.  This is the `j = 0` branch of the final-row size
obstruction. -/
theorem not_modEq_one_of_one_lt_of_lt {P T : ℕ}
    (hP : 1 < P) (hPT : P < T) : ¬ P ≡ 1 [MOD T] := by
  intro h
  have h1T : 1 < T := lt_trans hP hPT
  have : P = 1 := h.eq_of_lt_of_lt hPT h1T
  omega

/-- If `0 < P < q² ≤ T`, then `P` cannot be congruent to `q²` modulo
`T`.  The proof treats separately `q² < T` and the boundary `q² = T`. -/
theorem not_modEq_sq_of_pos_of_lt_of_le {P q T : ℕ}
    (hP0 : 0 < P) (hPq : P < q ^ 2) (hqT : q ^ 2 ≤ T) :
    ¬ P ≡ q ^ 2 [MOD T] := by
  intro h
  have hPT : P < T := lt_of_lt_of_le hPq hqT
  rcases hqT.lt_or_eq with hqTlt | rfl
  · have : P = q ^ 2 := h.eq_of_lt_of_lt hPT hqTlt
    omega
  · change P % (q ^ 2) = q ^ 2 % q ^ 2 at h
    rw [Nat.mod_eq_of_lt hPq, Nat.mod_self] at h
    omega

/-- **Final-row size exclusion for three factors.**

If the final local row has either residue `1` or `q²`, a product
`1 < P < q²` cannot satisfy it modulo an order `T ≥ q²`.  In the Agrawal
application, `P = p₁p₂`, `q` is the largest prime, and the two alternatives
are exactly the exponents `j_q ∈ {0,2}`. -/
theorem threeFactor_finalRow_size_exclusion {P q T : ℕ}
    (hP : 1 < P) (hPq : P < q ^ 2) (hqT : q ^ 2 ≤ T)
    (hrow : P ≡ 1 [MOD T] ∨ P ≡ q ^ 2 [MOD T]) : False := by
  rcases hrow with hrow | hrow
  · exact not_modEq_one_of_one_lt_of_lt hP (lt_of_lt_of_le hPq hqT) hrow
  · exact not_modEq_sq_of_pos_of_lt_of_le (by omega) hPq hqT hrow

/-- **Universal size bound for a local row.**

Suppose a nontrivial natural number `P`, distinct from `p²`, satisfies one
of the two local-row congruences

`P ≡ 1 (mod T)` or `P ≡ p² (mod T)`.

Then the modulus cannot exceed both representatives:

`T ≤ max p² P`.

In the Agrawal application `P = n / p`.  Squarefreeness with another
prime factor supplies `1 < P` and `P ≠ p²`; the local theory supplies the
two alternatives.  The theorem itself deliberately isolates the purely
arithmetic kernel and does not build those application hypotheses into
its statement. -/
theorem localRow_order_le_max {P p T : ℕ}
    (hP : 1 < P) (hne : P ≠ p ^ 2)
    (hrow : P ≡ 1 [MOD T] ∨ P ≡ p ^ 2 [MOD T]) :
    T ≤ max (p ^ 2) P := by
  by_contra h
  have hmax : max (p ^ 2) P < T := Nat.lt_of_not_ge h
  have hpT : p ^ 2 < T := lt_of_le_of_lt (Nat.le_max_left _ _) hmax
  have hPT : P < T := lt_of_le_of_lt (Nat.le_max_right _ _) hmax
  rcases hrow with hrow | hrow
  · exact not_modEq_one_of_one_lt_of_lt hP hPT hrow
  · exact hne (hrow.eq_of_lt_of_lt hPT hpT)

/-- Cancellation of a common multiplier in a natural congruence when that
multiplier is coprime to the modulus. -/
theorem modEq_cancel_left_of_coprime {A B₁ B₂ T : ℕ}
    (hT : 0 < T) (hAT : Nat.Coprime A T)
    (h : A * B₁ ≡ A * B₂ [MOD T]) :
    B₁ ≡ B₂ [MOD T] := by
  have reduced := h.cancel_left_div_gcd hT
  have hgcd : Nat.gcd T A = 1 := hAT.symm.gcd_eq_one
  simpa [hgcd] using reduced

/-- **Meet-in-the-middle uniqueness below the order.**

If `T ≥ q²`, two candidate second products below `q²` that give the same
final-row residue after multiplication by a unit `A` are equal.  This is the
kernel-pure uniqueness statement behind the `k = 5` decision algorithm; it
does not assert a complexity bound or the absence of a candidate. -/
theorem mitm_secondProduct_unique {A B₁ B₂ c q T : ℕ}
    (hq : 0 < q) (hqT : q ^ 2 ≤ T) (hAT : Nat.Coprime A T)
    (hB₁ : B₁ < q ^ 2) (hB₂ : B₂ < q ^ 2)
    (h₁ : A * B₁ ≡ c [MOD T]) (h₂ : A * B₂ ≡ c [MOD T]) :
    B₁ = B₂ := by
  have hT : 0 < T := by
    have : 0 < q ^ 2 := Nat.pow_pos hq
    omega
  have hmul : A * B₁ ≡ A * B₂ [MOD T] := h₁.trans h₂.symm
  have hmod : B₁ ≡ B₂ [MOD T] :=
    modEq_cancel_left_of_coprime hT hAT hmul
  exact hmod.eq_of_lt_of_lt (lt_of_lt_of_le hB₁ hqT)
    (lt_of_lt_of_le hB₂ hqT)

end AgrawalCore
