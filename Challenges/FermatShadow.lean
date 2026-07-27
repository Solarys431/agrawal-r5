/-
Public-facing replay surface for the Fermat-shadow theorem.

No computational decision procedure or project-defined axiom is used.
-/
import AgrawalCore.AgrawalBridge

open Polynomial

namespace Challenges

open AgrawalCore

theorem fermat_shadow_challenge {n : ℕ} (hsq : Squarefree n)
    (h5 : ¬ (5 ∣ n))
    (h : ∃ g : Polynomial (ZMod n),
      (X - 1) ^ n = X ^ n - 1 + (X ^ 5 - 1) * g) :
    n ∣ 5 ^ (n - 1) - 1 :=
  agrawal_fermat_shadow hsq h5 h

end Challenges
