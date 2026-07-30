/-
Agrawal r = 5 — THE LITERAL ROW-TO-RESULTANT INTERFACE.

For an inert prime `q`, the cyclotomic quotient `Phi5Ring q` is a field.
A pure or twisted literal row at exponent `A + 1` then supplies a common
root modulo `q` of `Φ₅` and the corresponding integer fiber polynomial:

  pure:    (X - 1)^A - 1,
  twisted: X (X - 1)^A + 1.

The Sylvester resultant therefore vanishes modulo `q`.  This module proves
the resulting integer divisibility by `q` in the Lean kernel.

It does *not* assert the stronger paper-level divisibility by `q^4`; that
step uses inert prime-ideal norms in the quartic number field.
-/
import AgrawalCore.QuarticRigidity
import Mathlib.RingTheory.Polynomial.Resultant.Basic
import Mathlib.RingTheory.Polynomial.Cyclotomic.Factorization

open Polynomial

namespace AgrawalCore

theorem phi5_eq_cyclotomic {p : ℕ} [Fact p.Prime] :
    phi5 p = cyclotomic 5 (ZMod p) := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  rw [cyclotomic_prime]
  simp [phi5, Finset.sum_range_succ, add_assoc, add_comm]

theorem inertModFive_orderOf_unitOfCoprime {p : ℕ} [Fact p.Prime]
    (hp : InertModFive p) :
    orderOf (ZMod.unitOfCoprime p (by
      apply (show p.Prime from Fact.out).coprime_iff_not_dvd.mpr
      intro h
      have hp5 : p = 5 :=
        (Nat.prime_dvd_prime_iff_eq (show p.Prime from Fact.out) (by norm_num)).mp h
      subst p
      norm_num [InertModFive] at hp)) = 4 := by
  let hcop : p.Coprime 5 := by
    apply (show p.Prime from Fact.out).coprime_iff_not_dvd.mpr
    intro h
    have hp5 : p = 5 :=
      (Nat.prime_dvd_prime_iff_eq (show p.Prime from Fact.out) (by norm_num)).mp h
    subst p
    norm_num [InertModFive] at hp
  change orderOf (ZMod.unitOfCoprime p hcop) = 4
  apply (orderOf_eq_iff (x := ZMod.unitOfCoprime p hcop) (by norm_num)).2
  constructor
  · apply Units.ext
    change (p : ZMod 5) ^ 4 = 1
    rw [← ZMod.natCast_mod p 5]
    rcases hp with hp2 | hp3
    · rw [hp2]
      decide
    · rw [hp3]
      decide
  · intro m hm hpos heq
    have hv := congrArg Units.val heq
    change (p : ZMod 5) ^ m = 1 at hv
    rw [← ZMod.natCast_mod p 5] at hv
    rcases hp with hp2 | hp3
    · rw [hp2] at hv
      interval_cases m <;> norm_num at hpos hm
      all_goals revert hv; decide
    · rw [hp3] at hv
      interval_cases m <;> norm_num at hpos hm
      all_goals revert hv; decide

theorem phi5_irreducible_of_inert {p : ℕ} [Fact p.Prime]
    (hp : InertModFive p) :
    Irreducible (phi5 p) := by
  have hp5 : ¬ p ∣ 5 := by
    intro h
    have heq : p = 5 :=
      (Nat.prime_dvd_prime_iff_eq (show p.Prime from Fact.out) (by norm_num)).mp h
    subst p
    norm_num [InertModFive] at hp
  rw [phi5_eq_cyclotomic]
  apply ZMod.irreducible_of_dvd_cyclotomic_of_natDegree hp5
  · exact dvd_refl _
  · rw [natDegree_cyclotomic]
    exact (inertModFive_orderOf_unitOfCoprime hp).symm

theorem map_resultant_eq_zero_of_common_root
    {R K : Type*} [CommRing R] [Field K]
    (φ : R →+* K) {f g : R[X]} (hf : f.Monic) (hg : g.Monic)
    {x : K} (hfx : (f.map φ).eval x = 0)
    (hgx : (g.map φ).eval x = 0) :
    φ (f.resultant g) = 0 := by
  have hnotcoprime : ¬ IsCoprime (f.map φ) (g.map φ) := by
    intro hcop
    have hne := aeval_ne_zero_of_isCoprime hcop x
    simp only [aeval_def] at hne
    exact hne.elim (fun h => h hfx) (fun h => h hgx)
  have hres : (f.map φ).resultant (g.map φ) = 0 := by
    rw [resultant_eq_zero_iff]
    exact ⟨Or.inl (hf.map φ).ne_zero, hnotcoprime⟩
  rw [← hres]
  simpa only [hf.natDegree_map, hg.natDegree_map] using
    (Polynomial.resultant_map_map (f := f) (g := g)
      (m := f.natDegree) (n := g.natDegree) φ).symm

theorem prime_dvd_resultant_of_common_root
    {q : ℕ} [Fact q.Prime] {K : Type*} [Field K]
    [Algebra (ZMod q) K]
    {f g : ℤ[X]} (hf : f.Monic) (hg : g.Monic) {x : K}
    (hfx : (f.map ((algebraMap (ZMod q) K).comp
      (Int.castRingHom (ZMod q)))).eval x = 0)
    (hgx : (g.map ((algebraMap (ZMod q) K).comp
      (Int.castRingHom (ZMod q)))).eval x = 0) :
    (q : ℤ) ∣ f.resultant g := by
  have hmap :
      ((algebraMap (ZMod q) K).comp
        (Int.castRingHom (ZMod q))) (f.resultant g) = 0 :=
    map_resultant_eq_zero_of_common_root
      ((algebraMap (ZMod q) K).comp
        (Int.castRingHom (ZMod q))) hf hg hfx hgx
  have hz : ((f.resultant g : ℤ) : ZMod q) = 0 := by
    apply (algebraMap (ZMod q) K).injective
    simpa using hmap
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp hz

noncomputable def pureFiberPolynomial (A : ℕ) : ℤ[X] :=
  (X - 1) ^ A - 1

noncomputable def twistedFiberPolynomial (A : ℕ) : ℤ[X] :=
  X * (X - 1) ^ A + 1

lemma pureFiberPolynomial_monic {A : ℕ} (hA : 0 < A) :
    (pureFiberPolynomial A).Monic := by
  unfold pureFiberPolynomial
  let hm : ((X - (1 : ℤ[X])) ^ A).Monic :=
    (monic_X_sub_C (1 : ℤ)).pow A
  have hdeg : ((X - (1 : ℤ[X])) ^ A).natDegree = A := by
    simpa [sub_eq_add_neg] using
      (natDegree_pow_X_add_C (R := ℤ) A (-1))
  apply hm.sub_of_left
  rw [degree_one, degree_eq_natDegree hm.ne_zero, hdeg]
  exact_mod_cast hA

lemma twistedFiberPolynomial_monic (A : ℕ) :
    (twistedFiberPolynomial A).Monic := by
  unfold twistedFiberPolynomial
  let hm : (X * (X - (1 : ℤ[X])) ^ A).Monic :=
    monic_X.mul ((monic_X_sub_C (1 : ℤ)).pow A)
  have hdeg : (X * (X - (1 : ℤ[X])) ^ A).natDegree = A + 1 := by
    have hq : ((X - (1 : ℤ[X])) ^ A).Monic :=
      (monic_X_sub_C (1 : ℤ)).pow A
    have hpdeg : ((X - (1 : ℤ[X])) ^ A).natDegree = A := by
      simpa [sub_eq_add_neg] using
        (natDegree_pow_X_add_C (R := ℤ) A (-1))
    rw [monic_X.natDegree_mul hq, natDegree_X, hpdeg]
    omega
  apply hm.add_of_left
  rw [degree_one, degree_eq_natDegree hm.ne_zero, hdeg]
  exact_mod_cast (Nat.zero_lt_succ A)

lemma intPhi5_monic : (cyclotomic 5 ℤ).Monic :=
  cyclotomic.monic 5 ℤ

theorem intPhi5_eval_zeta_of_inert {q : ℕ} [Fact q.Prime]
    (hq : InertModFive q) :
    letI : Fact (Irreducible (phi5 q)) :=
      ⟨phi5_irreducible_of_inert hq⟩
    ((cyclotomic 5 ℤ).map
      ((algebraMap (ZMod q) (Phi5Ring q)).comp
        (Int.castRingHom (ZMod q)))).eval zeta5 = 0 := by
  dsimp
  rw [eval_map, ← eval₂_map]
  change Polynomial.aeval (zeta5 : Phi5Ring q)
    ((cyclotomic 5 ℤ).map (Int.castRingHom (ZMod q))) = 0
  rw [map_cyclotomic_int, ← phi5_eq_cyclotomic]
  unfold zeta5
  rw [AdjoinRoot.aeval_eq]
  exact AdjoinRoot.mk_self (f := phi5 q)

theorem pureFiberPolynomial_eval_zeta {q A : ℕ} [Fact q.Prime] :
    ((pureFiberPolynomial A).map
      ((algebraMap (ZMod q) (Phi5Ring q)).comp
        (Int.castRingHom (ZMod q)))).eval zeta5
      = ((zeta5 : Phi5Ring q) - 1) ^ A - 1 := by
  simp [pureFiberPolynomial]

theorem twistedFiberPolynomial_eval_zeta {q A : ℕ} [Fact q.Prime] :
    ((twistedFiberPolynomial A).map
      ((algebraMap (ZMod q) (Phi5Ring q)).comp
        (Int.castRingHom (ZMod q)))).eval zeta5
      = (zeta5 : Phi5Ring q) * ((zeta5 : Phi5Ring q) - 1) ^ A + 1 := by
  simp [twistedFiberPolynomial]

lemma ne_five_of_inertModFive {q : ℕ} (hq : InertModFive q) : q ≠ 5 := by
  intro h
  subst q
  norm_num [InertModFive] at hq

theorem pure_row_power {q A : ℕ} [Fact q.Prime]
    (hq : InertModFive q) (hres : (A + 1) % 5 = 1)
    (hrow : LocalS5 q (A + 1)) :
    ((zeta5 : Phi5Ring q) - 1) ^ A = 1 := by
  have hq5 : q ≠ 5 := ne_five_of_inertModFive hq
  let u : (Phi5Ring q)ˣ :=
    localCyclotomicUnit hq5 (1 : (ZMod 5)ˣ)
  have hunitEq : u ^ (A + 1) = u := by
    apply Units.ext
    simp only [Units.val_pow_eq_pow_val, u, localCyclotomicUnit_val,
      zmodFiveUnitOne_val, pow_one]
    calc
      ((zeta5 : Phi5Ring q) - 1) ^ (A + 1)
          = zeta5 ^ (A + 1) - 1 := hrow
      _ = zeta5 ^ ((A + 1) % 5) - 1 :=
        congrArg (fun x : Phi5Ring q => x - 1)
          (zeta5_pow_mod (p := q) (A + 1))
      _ = zeta5 - 1 := by rw [hres]; simp
  have huA : u ^ A = 1 := by
    apply mul_right_cancel (b := u)
    simpa [pow_succ] using hunitEq
  have hval := congrArg Units.val huA
  simp only [Units.val_pow_eq_pow_val, Units.val_one, u,
    localCyclotomicUnit_val] at hval
  have hone : (1 : ZMod 5).val = 1 := by decide
  rw [hone] at hval
  simpa using hval

theorem twisted_row_vanishing {q A : ℕ} [Fact q.Prime]
    (hq : InertModFive q) (hres : (A + 1) % 5 = 4)
    (hrow : LocalS5 q (A + 1)) :
    (zeta5 : Phi5Ring q) * ((zeta5 : Phi5Ring q) - 1) ^ A + 1 = 0 := by
  let z : Phi5Ring q := zeta5
  change z * (z - 1) ^ A + 1 = 0
  have hq5 : q ≠ 5 := ne_five_of_inertModFive hq
  let u : (Phi5Ring q)ˣ :=
    localCyclotomicUnit hq5 (1 : (ZMod 5)ˣ)
  have huval :
      (u : Phi5Ring q) = z - 1 := by
    simp only [u, localCyclotomicUnit_val]
    have hone : (((1 : (ZMod 5)ˣ) : ZMod 5)).val = 1 := by decide
    rw [hone, pow_one]
  have hrow' :
      (z - 1) ^ (A + 1) = z ^ 4 - 1 := by
    calc
      (z - 1) ^ (A + 1) = z ^ (A + 1) - 1 := by
        simpa [LocalS5, z] using hrow
      _ = z ^ ((A + 1) % 5) - 1 :=
        congrArg (fun x : Phi5Ring q => x - 1)
          (by simpa [z] using (zeta5_pow_mod (p := q) (A + 1)))
      _ = z ^ 4 - 1 := by rw [hres]
  have hmul :
      (z - 1) * (z * (z - 1) ^ A + 1) = 0 := by
    calc
      (z - 1) * (z * (z - 1) ^ A + 1)
          = z * (z - 1) ^ (A + 1) + (z - 1) := by
              rw [pow_succ]
              ring
      _ = z * (z ^ 4 - 1) + (z - 1) := by rw [hrow']
      _ = 0 := by
        have hz5 : z ^ 5 = 1 := by simpa [z] using (zeta5_pow_five (p := q))
        rw [mul_sub, ← pow_succ', hz5]
        ring
  calc
    z * (z - 1) ^ A + 1
        = (↑u⁻¹ : Phi5Ring q)
            * ((z - 1) * (z * (z - 1) ^ A + 1)) := by
              rw [← huval]
              simp
    _ = 0 := by rw [hmul, mul_zero]

theorem pure_row_dvd_resultant {q A : ℕ} [Fact q.Prime]
    (hq : InertModFive q) (hA : 0 < A)
    (hres : (A + 1) % 5 = 1) (hrow : LocalS5 q (A + 1)) :
    (q : ℤ) ∣ (cyclotomic 5 ℤ).resultant (pureFiberPolynomial A) := by
  letI : Fact (Irreducible (phi5 q)) :=
    ⟨phi5_irreducible_of_inert hq⟩
  apply prime_dvd_resultant_of_common_root
    intPhi5_monic (pureFiberPolynomial_monic hA)
      (x := (zeta5 : Phi5Ring q))
  · exact intPhi5_eval_zeta_of_inert hq
  · rw [pureFiberPolynomial_eval_zeta,
      pure_row_power hq hres hrow, sub_self]

theorem twisted_row_dvd_resultant {q A : ℕ} [Fact q.Prime]
    (hq : InertModFive q)
    (hres : (A + 1) % 5 = 4) (hrow : LocalS5 q (A + 1)) :
    (q : ℤ) ∣ (cyclotomic 5 ℤ).resultant (twistedFiberPolynomial A) := by
  letI : Fact (Irreducible (phi5 q)) :=
    ⟨phi5_irreducible_of_inert hq⟩
  apply prime_dvd_resultant_of_common_root
    intPhi5_monic (twistedFiberPolynomial_monic A)
      (x := (zeta5 : Phi5Ring q))
  · exact intPhi5_eval_zeta_of_inert hq
  · rw [twistedFiberPolynomial_eval_zeta,
      twisted_row_vanishing hq hres hrow]

end AgrawalCore
