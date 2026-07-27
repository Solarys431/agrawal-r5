/-
Public-facing replay surface for the rigorously closed part of the H4
reduction.  The class-specific inertia statement is intentionally absent:
it remains the open conjecture.
-/
import AgrawalCore.PrimitiveScalarBridge
import AgrawalCore.SingleSupportExclusion

namespace Challenges

open AgrawalCore

variable {p r s k : ℕ} [Fact p.Prime]

theorem four_coefficient_bridge_challenge
    (hp5 : p ≠ 5) (hr : 0 < r) (hs : 0 < s) (hkpos : 1 ≤ k)
    (hpm : ¬p ∣ 4 * r * s)
    (hsig : CanonicalSignature (4 * r * s) r s k)
    (x : ZMod p) (hxpoly : x ^ 2 = 5 * x - 5)
    (hD : p ∣ primitiveFourCoefficientD (4 * r * s) k) :
    orderOf x = 4 * r * s ∧
      orderOf (x ^ (k + 1)) = 2 * r ∧
      orderOf (x ^ (k - 1)) = 2 * s :=
  dvd_primitiveFourCoefficientD_exact_order_profile
    hp5 hr hs hkpos hpm hsig x hxpoly hD

theorem scalar_profile_challenge
    (hp5 : p ≠ 5) (hr : 0 < r) (hs : 0 < s) (hkpos : 1 ≤ k)
    (hpm : ¬p ∣ 4 * r * s)
    (hsig : CanonicalSignature (4 * r * s) r s k)
    (x : ZMod p) (hxpoly : x ^ 2 = 5 * x - 5)
    (hD : p ∣ primitiveFourCoefficientD (4 * r * s) k) :
    orderOf (5 : ZMod p) = 2 * r ∧
      orderOf (goldenSquareFromGamma x) = 2 * s :=
  dvd_D_exact_scalar_profile hp5 hr hs hkpos hpm hsig x hxpoly hD

theorem single_support_exclusion_challenge {q e : ℕ} (hq : q.Prime)
    (hp2 : p ≠ 2) (hp5 : p ≠ 5)
    (hrs : Nat.Coprime r s)
    (hpform : p - 1 = 8 * q ^ e)
    (hord5 : orderOf (5 : ZMod p) = 2 * r)
    (x : ZMod p) (hx : x ^ 2 = 3 * x - 1)
    (hordx : orderOf x = 2 * s) :
    p % 5 = 2 ∨ p % 5 = 3 :=
  no_split_single_odd_support hq hp2 hp5 hrs hpform hord5 x hx hordx

end Challenges
