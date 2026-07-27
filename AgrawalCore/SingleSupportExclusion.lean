/-
Esclusione della prima famiglia strutturale H4: `p-1 = 8*q^e`.

Il lemma combinatorio sugli ordini è in `PrimitiveSupport`. Qui vengono
formalizzati i due certificati algebrico-aritmetici che eliminano il caso
in cui uno degli ordini completi divide `8`.
-/
import AgrawalCore.PrimitiveSupport

namespace AgrawalCore

theorem five_pow_eight_sub_one_factorization :
    5 ^ 8 - 1 = 2 ^ 5 * 3 * 13 * 313 := by
  norm_num

theorem golden_square_norm_eight_factorization :
    2205 = 3 ^ 2 * 5 * 7 ^ 2 := by
  norm_num

theorem prime_dvd_five_pow_eight_sub_one_cases {p : ℕ} (hp : p.Prime)
    (h : p ∣ 5 ^ 8 - 1) :
    p = 2 ∨ p = 3 ∨ p = 13 ∨ p = 313 := by
  have h' : p ∣ 2 ^ 5 * 3 * 13 * 313 := by
    rwa [five_pow_eight_sub_one_factorization] at h
  rcases hp.dvd_mul.mp h' with hleft | h313
  · rcases hp.dvd_mul.mp hleft with hleft | h13
    · rcases hp.dvd_mul.mp hleft with h2pow | h3
      · left
        exact (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp
          (hp.dvd_of_dvd_pow h2pow)
      · right; left
        exact (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp h3
    · right; right; left
      exact (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp h13
  · right; right; right
    exact (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp h313

theorem prime_dvd_2205_cases {p : ℕ} (hp : p.Prime) (h : p ∣ 2205) :
    p = 3 ∨ p = 5 ∨ p = 7 := by
  have h' : p ∣ 3 ^ 2 * 5 * 7 ^ 2 := by
    rwa [golden_square_norm_eight_factorization] at h
  rcases hp.dvd_mul.mp h' with hleft | h7pow
  · rcases hp.dvd_mul.mp hleft with h3pow | h5
    · left
      exact (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp
        (hp.dvd_of_dvd_pow h3pow)
    · right; left
      exact (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp h5
  · right; right
    exact (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp
      (hp.dvd_of_dvd_pow h7pow)

variable {p : ℕ} [Fact p.Prime]

/-- Se `5^8=1` modulo un buon primo, quel primo è inerte. -/
theorem inert_of_five_pow_eight_eq_one (hp2 : p ≠ 2) (hp5 : p ≠ 5)
    (hpow : (5 : ZMod p) ^ 8 = 1) :
    p % 5 = 2 ∨ p % 5 = 3 := by
  have hzero : (390624 : ZMod p) = 0 := by
    norm_num at hpow ⊢
    linear_combination hpow
  have hdvd : p ∣ 5 ^ 8 - 1 := by
    norm_num
    exact (CharP.cast_eq_zero_iff (ZMod p) p 390624).mp hzero
  rcases prime_dvd_five_pow_eight_sub_one_cases Fact.out hdvd with
      rfl | rfl | rfl | rfl
  · exact absurd rfl hp2
  · right; norm_num
  · right; norm_num
  · right; norm_num

/-- Riduzione di `x^8` per una radice di `X²-3X+1`. -/
theorem golden_square_pow_eight {R : Type*} [CommRing R] (x : R)
    (hx : x ^ 2 = 3 * x - 1) :
    x ^ 8 = 987 * x - 377 := by
  have hx4 : x ^ 4 = 21 * x - 8 := by
    calc
      x ^ 4 = (x ^ 2) ^ 2 := by ring
      _ = (3 * x - 1) ^ 2 := by rw [hx]
      _ = 9 * x ^ 2 - 6 * x + 1 := by ring
      _ = 9 * (3 * x - 1) - 6 * x + 1 := by rw [hx]
      _ = 21 * x - 8 := by ring
  calc
    x ^ 8 = (x ^ 4) ^ 2 := by ring
    _ = (21 * x - 8) ^ 2 := by rw [hx4]
    _ = 441 * x ^ 2 - 336 * x + 64 := by ring
    _ = 441 * (3 * x - 1) - 336 * x + 64 := by rw [hx]
    _ = 987 * x - 377 := by ring

/-- Se una radice aurea quadrata ha ottava potenza uno, la caratteristica
divide il risultante `2205`. -/
theorem dvd_2205_of_golden_square_pow_eight (x : ZMod p)
    (hx : x ^ 2 = 3 * x - 1) (hpow : x ^ 8 = 1) :
    p ∣ 2205 := by
  have h8 := golden_square_pow_eight x hx
  have hlin : 987 * x - 378 = 0 := by
    linear_combination hpow - h8
  have hzero : (2205 : ZMod p) = 0 := by
    linear_combination -974169 * hx + (987 * x - 2583) * hlin
  exact (CharP.cast_eq_zero_iff (ZMod p) p 2205).mp hzero

/-- Anche il ramo aureo `x^8=1` forza un buon primo a essere inerte. -/
theorem inert_of_golden_square_pow_eight (hp2 : p ≠ 2) (hp5 : p ≠ 5)
    (x : ZMod p) (hx : x ^ 2 = 3 * x - 1) (hpow : x ^ 8 = 1) :
    p % 5 = 2 ∨ p % 5 = 3 := by
  rcases prime_dvd_2205_cases Fact.out
      (dvd_2205_of_golden_square_pow_eight x hx hpow) with rfl | rfl | rfl
  · right; norm_num
  · exact absurd rfl hp5
  · left; norm_num

/-- **Esclusione universale del singolo supporto dispari.**

Se `p-1=8*q^e`, i due semiordini sono coprimi e sono davvero gli ordini
di `5` e di una radice di `X²-3X+1`, allora `p` non può essere split
modulo `5`. -/
theorem no_split_single_odd_support {q e r s : ℕ} (hq : q.Prime)
    (hp2 : p ≠ 2) (hp5 : p ≠ 5)
    (hrs : Nat.Coprime r s)
    (hpform : p - 1 = 8 * q ^ e)
    (hord5 : orderOf (5 : ZMod p) = 2 * r)
    (x : ZMod p) (hx : x ^ 2 = 3 * x - 1)
    (hordx : orderOf x = 2 * s) :
    p % 5 = 2 ∨ p % 5 = 3 := by
  have hR : 2 * r ∣ 8 * q ^ e := by
    rw [← hpform, ← hord5]
    exact ZMod.orderOf_dvd_card_sub_one (by
      intro h50
      have hpdiv : p ∣ 5 :=
        (CharP.cast_eq_zero_iff (ZMod p) p 5).mp h50
      exact hp5 ((Nat.prime_dvd_prime_iff_eq Fact.out (by norm_num)).mp hpdiv))
  have hE : 2 * s ∣ 8 * q ^ e := by
    rw [← hpform, ← hordx]
    exact ZMod.orderOf_dvd_card_sub_one (by
      intro hx0
      rw [hx0, zero_pow (by norm_num : (2 : ℕ) ≠ 0)] at hx
      norm_num at hx)
  rcases one_order_dvd_eight_of_single_odd_prime hq hrs hR hE with h8 | h8
  · apply inert_of_five_pow_eight_eq_one hp2 hp5
    apply orderOf_dvd_iff_pow_eq_one.mp
    rwa [hord5]
  · apply inert_of_golden_square_pow_eight hp2 hp5 x hx
    apply orderOf_dvd_iff_pow_eq_one.mp
    rwa [hordx]

end AgrawalCore
