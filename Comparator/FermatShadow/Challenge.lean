import Mathlib

/-!
Trusted, solution-independent statement of the squarefree Fermat shadow.

This file intentionally imports only Mathlib.  It states the complete
polynomial-congruence-to-divisibility bridge, not an intermediate lemma.
-/
open Polynomial

namespace FermatShadowChallenge

theorem agrawal_fermat_shadow {n : ℕ} (hsq : Squarefree n)
    (h5 : ¬ 5 ∣ n)
    (h : ∃ g : Polynomial (ZMod n),
      (X - 1) ^ n = X ^ n - 1 + (X ^ 5 - 1) * g) :
    n ∣ 5 ^ (n - 1) - 1 := by
  sorry

end FermatShadowChallenge
