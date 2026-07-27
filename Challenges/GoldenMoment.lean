/-
Public-facing replay surface for the golden-moment theorem.

This file deliberately imports only the module that proves the result.
-/
import AgrawalCore.GoldenMoment

namespace Challenges

open AgrawalCore

variable {R : Type*} [CommRing R]

theorem golden_moment_challenge {ζ : R}
    (hζ : ζ ^ 4 + ζ ^ 3 + ζ ^ 2 + ζ + 1 = 0) :
    quadraticMomentUnit ζ =
      cyclotomicSqrtFive ζ ^ 5 * cyclotomicGoldenUnit ζ ^ 3 :=
  golden_moment_factorization hζ

end Challenges
