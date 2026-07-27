import Mathlib

/-!
Trusted, solution-independent statement of the golden-moment factorization.

This file intentionally imports only Mathlib.  The proof hole is the object
checked against `Solution.lean` by leanprover/comparator.
-/
namespace GoldenMomentChallenge

variable {R : Type*} [CommRing R]

def cyclotomicSqrtFive (ζ : R) : R :=
  1 + 2 * (ζ + ζ ^ 4)

def cyclotomicGoldenUnit (ζ : R) : R :=
  1 + ζ + ζ ^ 4

def quadraticMomentUnit (ζ : R) : R :=
  (ζ - 1) * (ζ ^ 2 - 1) ^ 4 * (ζ ^ 3 - 1) ^ 4 * (ζ ^ 4 - 1)

theorem golden_moment_factorization {ζ : R}
    (hζ : ζ ^ 4 + ζ ^ 3 + ζ ^ 2 + ζ + 1 = 0) :
    quadraticMomentUnit ζ =
      cyclotomicSqrtFive ζ ^ 5 * cyclotomicGoldenUnit ζ ^ 3 := by
  sorry

end GoldenMomentChallenge
