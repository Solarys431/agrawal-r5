/-
Identificazione scalare della riduzione primitiva.

Il teorema dei quattro coefficienti produce inizialmente gli ordini di
`γ^(k+1)` e `γ^(k-1)`.  Questo modulo verifica nel kernel che il primo
elemento è precisamente `5` e che il secondo è l'inverso dell'unità
aurea quadrata coordinata con la radice `γ`.
-/
import AgrawalCore.PrimitiveOrderBridge

namespace AgrawalCore

set_option maxHeartbeats 200000

variable {p r s k : ℕ} [Fact p.Prime]

/-- L'unità aurea quadrata coordinata con una radice
`γ²-5γ+5=0`: `γ/(5-γ)`. -/
def goldenSquareFromGamma (γ : ZMod p) : ZMod p :=
  γ / (5 - γ)

private theorem five_ne_zero (hp5 : p ≠ 5) : (5 : ZMod p) ≠ 0 := by
  have hnat : ((5 : ℕ) : ZMod p) ≠ 0 := by
    rw [Ne, CharP.cast_eq_zero_iff (ZMod p) p]
    intro hp
    exact hp5 ((Nat.prime_dvd_prime_iff_eq Fact.out (by norm_num)).mp hp)
  exact_mod_cast hnat

theorem gamma_mul_conj (γ : ZMod p) (hγ : γ ^ 2 = 5 * γ - 5) :
    γ * (5 - γ) = 5 := by
  linear_combination -hγ

/-- Sotto il trasporto canonico, la potenza `k+1` è lo scalare `5`. -/
theorem gamma_pow_succ_transport (γ : ZMod p)
    (hγ : γ ^ 2 = 5 * γ - 5) (htransport : γ ^ k = 5 - γ) :
    γ ^ (k + 1) = 5 := by
  rw [pow_succ, htransport]
  simpa [mul_comm] using gamma_mul_conj γ hγ

/-- La potenza `k-1` è l'inverso moltiplicativo dell'unità aurea
quadrata coordinata con `γ`. -/
theorem gamma_pow_pred_mul_goldenSquare (hp5 : p ≠ 5) (hk : 1 ≤ k)
    (γ : ZMod p) (hγ : γ ^ 2 = 5 * γ - 5)
    (htransport : γ ^ k = 5 - γ) :
    γ ^ (k - 1) * goldenSquareFromGamma γ = 1 := by
  have hprod := gamma_mul_conj γ hγ
  have hconj : (5 - γ : ZMod p) ≠ 0 := by
    intro hz
    rw [hz, mul_zero] at hprod
    exact five_ne_zero hp5 hprod.symm
  rw [goldenSquareFromGamma, div_eq_mul_inv, ← mul_assoc,
    ← pow_succ, Nat.sub_add_cancel hk, htransport]
  exact mul_inv_cancel₀ hconj

/-- Un elemento e un inverso esplicito hanno lo stesso ordine anche
nel monoide moltiplicativo con zero di `ZMod p`. -/
theorem orderOf_eq_of_mul_eq_one {a b : ZMod p} (hab : a * b = 1) :
    orderOf a = orderOf b := by
  rw [orderOf_eq_orderOf_iff]
  intro n
  have hpowers : a ^ n * b ^ n = 1 := by
    rw [← mul_pow, hab, one_pow]
  constructor
  · intro ha
    simpa [ha] using hpowers
  · intro hb
    simpa [hb] using hpowers

/-- **Ponte scalare completo nel verso del supporto primitivo.**
Un buon divisore del gcd a quattro coefficienti ha gli ordini scalari
esatti richiesti dal gcd ciclotomico originale. -/
theorem dvd_D_exact_scalar_profile
    (hp5 : p ≠ 5) (hr : 0 < r) (hs : 0 < s) (hkpos : 1 ≤ k)
    (hpm : ¬p ∣ 4 * r * s)
    (hsig : CanonicalSignature (4 * r * s) r s k)
    (γ : ZMod p) (hγ : γ ^ 2 = 5 * γ - 5)
    (hD : p ∣ primitiveFourCoefficientD (4 * r * s) k) :
    orderOf (5 : ZMod p) = 2 * r ∧
      orderOf (goldenSquareFromGamma γ) = 2 * s := by
  have hv :
      PrimitiveFourVanish p (4 * r * s) k γ :=
    (primitiveFourVanish_iff_dvd_D hp5 (4 * r * s) k hkpos γ hγ).mpr hD
  have horders :=
    primitiveFourVanish_exact_order_profile hr hs hkpos hpm hsig γ hv
  have hfive : γ ^ (k + 1) = 5 :=
    gamma_pow_succ_transport γ hγ hv.2.2.1
  have hinv :
      γ ^ (k - 1) * goldenSquareFromGamma γ = 1 :=
    gamma_pow_pred_mul_goldenSquare hp5 hkpos γ hγ hv.2.2.1
  constructor
  · rw [← hfive]
    exact horders.2.1
  · rw [← orderOf_eq_of_mul_eq_one hinv]
    exact horders.2.2

end AgrawalCore
