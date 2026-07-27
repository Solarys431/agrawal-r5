import Mathlib

/-!
Trusted, solution-independent statements for the rigorously closed part of
the primitive H4 reduction.

Only Mathlib is imported.  The definitions needed to state the results are
included here so that no theorem or definition from the submitted solution
is trusted by the challenge.
-/
open Polynomial

namespace PrimitiveSupportChallenge

def CanonicalSignature (m r s k : ℕ) : Prop :=
  Nat.gcd m (k - 1) = 2 * r ∧ Nat.gcd m (k + 1) = 2 * s

def gammaU : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | n + 2 => 5 * gammaU (n + 1) - 5 * gammaU n

noncomputable def gammaMinPoly : Polynomial ℤ :=
  X ^ 2 - C 5 * X + C 5

noncomputable def gammaCoeff0 (P : Polynomial ℤ) : ℤ :=
  (P %ₘ gammaMinPoly).coeff 0

noncomputable def gammaCoeff1 (P : Polynomial ℤ) : ℤ :=
  (P %ₘ gammaMinPoly).coeff 1

noncomputable def cyclotomicGammaCoeffs (m : ℕ) : ℤ × ℤ :=
  (gammaCoeff0 (Polynomial.cyclotomic m ℤ),
    gammaCoeff1 (Polynomial.cyclotomic m ℤ))

def fourCoefficientGcd (c d a w : ℕ) : ℕ :=
  Nat.gcd (Nat.gcd c d) (Nat.gcd a w)

noncomputable def primitiveFourCoefficientD (m k : ℕ) : ℕ :=
  let cd := cyclotomicGammaCoeffs m
  fourCoefficientGcd cd.1.natAbs cd.2.natAbs
    (gammaU k + 1).natAbs (gammaU (k - 1) + 1).natAbs

def goldenSquareFromGamma {p : ℕ} [Fact p.Prime]
    (γ : ZMod p) : ZMod p :=
  γ / (5 - γ)

variable {p r s k : ℕ} [Fact p.Prime]

theorem four_coefficient_bridge
    (hp5 : p ≠ 5) (hr : 0 < r) (hs : 0 < s) (hkpos : 1 ≤ k)
    (hpm : ¬p ∣ 4 * r * s)
    (hsig : CanonicalSignature (4 * r * s) r s k)
    (x : ZMod p) (hxpoly : x ^ 2 = 5 * x - 5)
    (hD : p ∣ primitiveFourCoefficientD (4 * r * s) k) :
    orderOf x = 4 * r * s ∧
      orderOf (x ^ (k + 1)) = 2 * r ∧
      orderOf (x ^ (k - 1)) = 2 * s := by
  sorry

theorem scalar_profile
    (hp5 : p ≠ 5) (hr : 0 < r) (hs : 0 < s) (hkpos : 1 ≤ k)
    (hpm : ¬p ∣ 4 * r * s)
    (hsig : CanonicalSignature (4 * r * s) r s k)
    (x : ZMod p) (hxpoly : x ^ 2 = 5 * x - 5)
    (hD : p ∣ primitiveFourCoefficientD (4 * r * s) k) :
    orderOf (5 : ZMod p) = 2 * r ∧
      orderOf (goldenSquareFromGamma x) = 2 * s := by
  sorry

theorem single_support_exclusion {q e : ℕ} (hq : q.Prime)
    (hp2 : p ≠ 2) (hp5 : p ≠ 5)
    (hrs : Nat.Coprime r s)
    (hpform : p - 1 = 8 * q ^ e)
    (hord5 : orderOf (5 : ZMod p) = 2 * r)
    (x : ZMod p) (hx : x ^ 2 = 3 * x - 1)
    (hordx : orderOf x = 2 * s) :
    p % 5 = 2 ∨ p % 5 = 3 := by
  sorry

end PrimitiveSupportChallenge
