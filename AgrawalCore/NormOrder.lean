/-
Nucleo Lean della campagna Agrawal — decomposizione ordine/norma.

Se un elemento `u` di un gruppo finito soddisfa `u ^ m = b`, la formula
classica per l'ordine di una potenza dà

  orderOf b = orderOf u / gcd (orderOf u) m

e quindi

  orderOf u = orderOf b * gcd (orderOf u) m.

Il fattore residuo è a sua volta l'ordine di
`u ^ orderOf b`. Nell'applicazione ciclotomica:

  u = ζ₅ - 1,
  m = 1 + q + q² + q³,
  b = Norm_{F_{q⁴}/F_q}(u) = 5.

Questa unità formalizza soltanto il nucleo gruppale B–C. L'identità di
norma `u ^ m = 5` è un ingresso algebrico separato e non viene assunta come
assioma del progetto.
-/
import Mathlib.GroupTheory.OrderOfElement
import Mathlib.Tactic

namespace AgrawalCore

variable {G : Type*} [Group G] [Finite G]

/-- L'ordine dell'immagine di una potenza è il quoziente dell'ordine
originario per il gcd con l'esponente. -/
theorem orderOf_norm_power
    (u b : G) (m : ℕ) (hNorm : u ^ m = b) :
    orderOf b = orderOf u / Nat.gcd (orderOf u) m := by
  subst b
  exact orderOf_pow u

/-- **DECOMPOSIZIONE ORDINE/NORMA.** Se `u ^ m = b`, l'ordine di `u`
si fattorizza esattamente nel prodotto dell'ordine di `b` e del fattore
che rimane nel nucleo della potenza `m`. -/
theorem orderOf_norm_decomposition
    (u b : G) (m : ℕ) (hNorm : u ^ m = b) :
    orderOf u = orderOf b * Nat.gcd (orderOf u) m := by
  rw [orderOf_norm_power u b m hNorm]
  exact (Nat.div_mul_cancel (Nat.gcd_dvd_left (orderOf u) m)).symm

/-- Il fattore residuo della decomposizione è esso stesso un ordine:
è l'ordine di `u` elevato all'ordine della sua immagine `b`. -/
theorem orderOf_norm_kernel
    (u b : G) (m : ℕ) (hNorm : u ^ m = b) :
    orderOf (u ^ orderOf b) = Nat.gcd (orderOf u) m := by
  have hu : orderOf u ≠ 0 := Nat.ne_of_gt (orderOf_pos u)
  have hg : Nat.gcd (orderOf u) m ∣ orderOf u :=
    Nat.gcd_dvd_left (orderOf u) m
  rw [orderOf_norm_power u b m hNorm]
  exact orderOf_pow_orderOf_div hu hg

/-- In particolare, l'ordine dell'immagine divide l'ordine originario. -/
theorem orderOf_norm_power_dvd
    (u b : G) (m : ℕ) (hNorm : u ^ m = b) :
    orderOf b ∣ orderOf u := by
  rw [orderOf_norm_power u b m hNorm]
  exact Nat.div_dvd_of_dvd (Nat.gcd_dvd_left (orderOf u) m)

/-- **Exact threshold in terms of the defect product.**

If `T * I = 10 * (q² - 1)` and `q ≥ 7`, then `T < q²` is equivalent
to `I ≥ 10`.  In the cyclotomic application `I` is the product of the
two odd defect indices. -/
theorem defectProduct_threshold {q T I : ℕ}
    (hq : 7 ≤ q) (hexact : T * I = 10 * (q ^ 2 - 1)) :
    T < q ^ 2 ↔ 10 ≤ I := by
  have hq2 : 10 < q ^ 2 := by nlinarith
  constructor
  · intro hT
    by_contra hI
    have hIle : I ≤ 9 := by omega
    have hsub : q ^ 2 - 1 + 1 = q ^ 2 := by omega
    nlinarith
  · intro hI
    have hsub : q ^ 2 - 1 + 1 = q ^ 2 := by omega
    have hIpos : 0 < I := by omega
    nlinarith

/-- Since the two defect indices are odd, the first exceptional value is
`11`, not `10`. -/
theorem odd_defectProduct_threshold {q T I : ℕ}
    (hq : 7 ≤ q) (hexact : T * I = 10 * (q ^ 2 - 1))
    (hodd : Odd I) :
    T < q ^ 2 ↔ 11 ≤ I := by
  rw [defectProduct_threshold hq hexact]
  rcases hodd with ⟨k, rfl⟩
  omega

/-- Complementary normal-range formulation: for an odd defect product,
`T ≥ q²` holds exactly for the finite range `I ≤ 9`. -/
theorem odd_defectProduct_normal_iff {q T I : ℕ}
    (hq : 7 ≤ q) (hexact : T * I = 10 * (q ^ 2 - 1))
    (hodd : Odd I) :
    q ^ 2 ≤ T ↔ I ≤ 9 := by
  have hthreshold := odd_defectProduct_threshold hq hexact hodd
  constructor
  · intro hT
    by_cases hI : I ≤ 9
    · exact hI
    · have h11 : 11 ≤ I := by
        rcases hodd with ⟨k, hk⟩
        omega
      have hlt : T < q ^ 2 := hthreshold.mpr h11
      omega
  · intro hI
    by_cases hT : q ^ 2 ≤ T
    · exact hT
    · have hlt : T < q ^ 2 := by omega
      have h11 : 11 ≤ I := hthreshold.mp hlt
      omega

end AgrawalCore
