/-
Exact transport between the final local row and one earlier row.

This module isolates two logically different statements:

* a genuine compatibility obstruction modulo `gcd Tₚ T_q`, independent of
  the final-row multiplier;
* exact linear normal forms for the remaining multiplier-dependent lift.

No finite census or asymptotic assertion is formalized here.
-/
import Mathlib.Data.Nat.ModEq
import Mathlib.Tactic.Ring

namespace AgrawalCore

/-- **Two-row transport.**

If the final row gives `P ≡ c (mod Tq)` and an earlier row, after
multiplication by its prime, gives `Pq ≡ a (mod Tp)`, then their common
reduction forces

`cq ≡ a (mod gcd Tp Tq)`.

Unlike either input row alone, this necessary condition couples the two order
moduli and no longer contains the final-row multiplier. -/
theorem finalSmallRow_transport {P c q a Tp Tq : ℕ}
    (hfinal : P ≡ c [MOD Tq]) (hsmall : P * q ≡ a [MOD Tp]) :
    c * q ≡ a [MOD Nat.gcd Tp Tq] := by
  have hqfinal : P * q ≡ c * q [MOD Nat.gcd Tp Tq] :=
    (hfinal.of_dvd (Nat.gcd_dvd_right Tp Tq)).mul_right q
  have hqsmall : P * q ≡ a [MOD Nat.gcd Tp Tq] :=
    hsmall.of_dvd (Nat.gcd_dvd_left Tp Tq)
  exact hqfinal.symm.trans hqsmall

/-- Pure-branch transport: `P ≡ 1 (mod Tq)` forces
`q ≡ a (mod gcd Tp Tq)`. -/
theorem pureSmallRow_transport {P q a Tp Tq : ℕ}
    (hfinal : P ≡ 1 [MOD Tq]) (hsmall : P * q ≡ a [MOD Tp]) :
    q ≡ a [MOD Nat.gcd Tp Tq] := by
  simpa using finalSmallRow_transport hfinal hsmall

/-- Twisted-branch transport: `P ≡ q² (mod Tq)` forces
`q³ ≡ a (mod gcd Tp Tq)`. -/
theorem twistedSmallRow_transport {P q a Tp Tq : ℕ}
    (hfinal : P ≡ q ^ 2 [MOD Tq]) (hsmall : P * q ≡ a [MOD Tp]) :
    q ^ 3 ≡ a [MOD Nat.gcd Tp Tq] := by
  have h := finalSmallRow_transport hfinal hsmall
  convert h using 1
  ring

/-- **The third side of the CRT triangle.**

Two earlier rows involving the same product `P * q` must agree after
reduction to the common divisor of their order moduli:

`a ≡ b (mod gcd Tp Tr)`.

Together with the two transports from the final row, this is the complete
pairwise compatibility condition for the three residue classes. -/
theorem smallRows_triangle {P q a b Tp Tr : ℕ}
    (hp : P * q ≡ a [MOD Tp]) (hr : P * q ≡ b [MOD Tr]) :
    a ≡ b [MOD Nat.gcd Tp Tr] := by
  have hp' : P * q ≡ a [MOD Nat.gcd Tp Tr] :=
    hp.of_dvd (Nat.gcd_dvd_left Tp Tr)
  have hr' : P * q ≡ b [MOD Nat.gcd Tp Tr] :=
    hr.of_dvd (Nat.gcd_dvd_right Tp Tr)
  exact hp'.symm.trans hr'

/-- Exact multiplier normal form in the pure branch `P = 1 + hTq`. -/
theorem pureSmallRow_lift_iff {h q Tq a Tp : ℕ} :
    (1 + h * Tq) * q ≡ a [MOD Tp] ↔
      q + (q * Tq) * h ≡ a [MOD Tp] := by
  have heq : (1 + h * Tq) * q = q + (q * Tq) * h := by ring
  rw [heq]

/-- Exact multiplier normal form in the twisted branch
`P + hTq = q²`.  It uses addition only, so no truncated natural-number
subtraction enters the certified statement. -/
theorem twistedSmallRow_lift_iff {P h q Tq a Tp : ℕ}
    (hP : P + h * Tq = q ^ 2) :
    P * q ≡ a [MOD Tp] ↔
      a + (q * Tq) * h ≡ q ^ 3 [MOD Tp] := by
  have heq : P * q + (q * Tq) * h = q ^ 3 := by
    calc
      P * q + (q * Tq) * h = (P + h * Tq) * q := by ring
      _ = q ^ 2 * q := by rw [hP]
      _ = q ^ 3 := by ring
  constructor
  · intro hr
    have hadd := hr.add (Nat.ModEq.refl ((q * Tq) * h))
    rw [heq] at hadd
    exact hadd.symm
  · intro hr
    rw [← heq] at hr
    have hcancel := Nat.ModEq.add_right_cancel
      (Nat.ModEq.refl ((q * Tq) * h)) hr
    exact hcancel.symm

/-- **Bounded-lift exclusion.**

Two distinct representatives below the modulus cannot be congruent.  In the
fibre audit, `h ≤ H < M` is the exact multiplier interval, while `h₀` is the
canonical solution of the reduced linear congruence.  Thus `H < h₀ < M`
certifies that the row has no admissible lift. -/
theorem boundedLift_exclusion {h H h₀ M : ℕ}
    (hh : h ≤ H) (hH₀ : H < h₀) (h₀M : h₀ < M) (hHM : H < M) :
    ¬ h ≡ h₀ [MOD M] := by
  intro hmod
  have hhM : h < M := lt_of_le_of_lt hh hHM
  have heq : h = h₀ := hmod.eq_of_lt_of_lt hhM h₀M
  omega

end AgrawalCore
