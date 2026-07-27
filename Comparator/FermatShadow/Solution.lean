import Mathlib
import AgrawalCore.AgrawalBridge

/-! Submitted proof of the independent Fermat-shadow challenge. -/

open Polynomial

namespace FermatShadowChallenge

theorem agrawal_fermat_shadow {n : ℕ} (hsq : Squarefree n)
    (h5 : ¬ 5 ∣ n)
    (h : ∃ g : Polynomial (ZMod n),
      (X - 1) ^ n = X ^ n - 1 + (X ^ 5 - 1) * g) :
    n ∣ 5 ^ (n - 1) - 1 :=
  AgrawalCore.agrawal_fermat_shadow hsq h5 h

end FermatShadowChallenge
