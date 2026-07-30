/-
Agrawal r = 5 — THE LITERAL ROW-TO-RESULTANT INTERFACE.

For an inert prime `q`, the cyclotomic quotient `Phi5Ring q` is a field.
A pure or twisted literal row at exponent `A + 1` then supplies a common
root modulo `q` of `Φ₅` and the corresponding integer fiber polynomial:

  pure:    (X - 1)^A - 1,
  twisted: X (X - 1)^A + 1.

The Sylvester resultant therefore vanishes modulo `q`.  Irreducibility of
`Φ₅ mod q` gives more: `Φ₅` divides the fiber polynomial modulo `q`, so the
integral remainder has every coefficient divisible by `q`.  Homogeneity of
the resultant in its second input then supplies the full factor `q^4`.
Independently, reduction modulo `5` identifies `Φ₅` with `(X - 1)^4`;
evaluation at `1` shows that both resultants are `1 mod 5`, hence nonzero.
Together these facts yield the fixed-exponent size trap
`q^4 ≤ natAbs resultant`.
-/
import AgrawalCore.QuarticRigidity
import Mathlib.FieldTheory.Minpoly.Field
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

/-- If the reduction of a monic integral polynomial is irreducible and has
the same root as a second polynomial in a field extension of `ZMod q`, then
the full `q ^ deg f` divides their integral resultant.

The proof is coefficient-level.  Irreducibility identifies the reduction of
`f` with the minimal polynomial of the common root.  Thus it divides the
reduction of `g`; equivalently, the integral remainder of `g` modulo `f` is
coefficientwise divisible by `q`.  Resultant invariance under adding a
multiple of `f`, followed by homogeneity in the second input, produces one
factor of `q` for each degree of `f`. -/
theorem prime_pow_natDegree_dvd_resultant_of_common_root
    {q : ℕ} [Fact q.Prime] {K : Type*} [Field K]
    [Algebra (ZMod q) K]
    {f g : ℤ[X]} (hf : f.Monic)
    (hfirr : Irreducible (f.map (Int.castRingHom (ZMod q))))
    {x : K}
    (hfx : (f.map ((algebraMap (ZMod q) K).comp
      (Int.castRingHom (ZMod q)))).eval x = 0)
    (hgx : (g.map ((algebraMap (ZMod q) K).comp
      (Int.castRingHom (ZMod q)))).eval x = 0) :
    (q : ℤ) ^ f.natDegree ∣ f.resultant g := by
  let φ : ℤ →+* ZMod q := Int.castRingHom (ZMod q)
  let fbar : (ZMod q)[X] := f.map φ
  let gbar : (ZMod q)[X] := g.map φ
  have hfx' : Polynomial.aeval x fbar = 0 := by
    simpa [Polynomial.aeval_def, fbar, φ, eval_map, eval₂_map] using hfx
  have hgx' : Polynomial.aeval x gbar = 0 := by
    simpa [Polynomial.aeval_def, gbar, φ, eval_map, eval₂_map] using hgx
  have hmin : fbar = minpoly (ZMod q) x :=
    minpoly.eq_of_irreducible_of_monic
      (by simpa [fbar, φ] using hfirr) hfx' (hf.map φ)
  have hfdvd : fbar ∣ gbar := by
    rw [hmin]
    exact minpoly.dvd (ZMod q) x hgx'
  let rem : ℤ[X] := g %ₘ f
  let quo : ℤ[X] := g /ₘ f
  have hmaprem : rem.map φ = 0 := by
    rw [show rem.map φ = gbar %ₘ fbar by
      simpa [rem, fbar, gbar] using
        (Polynomial.map_modByMonic φ hf)]
    exact (Polynomial.modByMonic_eq_zero_iff_dvd (hf.map φ)).2 hfdvd
  have hC : C (q : ℤ) ∣ rem := by
    rw [Polynomial.C_dvd_iff_dvd_coeff]
    intro i
    have hz : ((rem.coeff i : ℤ) : ZMod q) = 0 := by
      have hc := congrArg (fun P : (ZMod q)[X] => P.coeff i) hmaprem
      simpa [φ] using hc
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp hz
  obtain ⟨scaledRem, hscaledRem⟩ := hC
  let m := f.natDegree
  let n := g.natDegree + f.natDegree
  have hquoDegree : quo.natDegree + m ≤ n := by
    rw [show quo.natDegree = g.natDegree - f.natDegree by
      simpa [quo] using Polynomial.natDegree_divByMonic g hf]
    simp [m, n]
  have hdefault : f.resultant g m n = f.resultant g := by
    simpa [m, n, Polynomial.coeff_natDegree, hf.leadingCoeff] using
      (Polynomial.resultant_add_right_deg
        f g m g.natDegree m (le_refl g.natDegree))
  refine ⟨f.resultant scaledRem m n, ?_⟩
  calc
    f.resultant g = f.resultant g m n := hdefault.symm
    _ = f.resultant (rem + f * quo) m n := by
      rw [Polynomial.modByMonic_add_div]
    _ = f.resultant rem m n :=
      Polynomial.resultant_add_mul_right
        f rem quo m n hquoDegree (le_refl f.natDegree)
    _ = f.resultant (C (q : ℤ) * scaledRem) m n := by rw [hscaledRem]
    _ = (q : ℤ) ^ m * f.resultant scaledRem m n :=
      Polynomial.resultant_C_mul_right f scaledRem m n (q : ℤ)
    _ = (q : ℤ) ^ f.natDegree * f.resultant scaledRem m n := rfl

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

lemma intPhi5_map_zmod_five :
    (cyclotomic 5 ℤ).map (Int.castRingHom (ZMod 5)) =
      (X - 1) ^ 4 := by
  rw [map_cyclotomic_int, cyclotomic_prime]
  norm_num [Finset.sum_range_succ]
  have hfour : (4 : ZMod 5) = -1 := by decide
  have hsix : (6 : ZMod 5) = 1 := by decide
  ring_nf
  ext n
  by_cases hn : n ≤ 3
  · interval_cases n <;>
      simp [coeff_add, coeff_sub, coeff_X_pow, coeff_X,
        coeff_one, hfour, hsix]
  · have hn0 : n ≠ 0 := by omega
    have hn1 : n ≠ 1 := by omega
    have hn2 : n ≠ 2 := by omega
    have hn3 : n ≠ 3 := by omega
    simp [coeff_add, coeff_sub, coeff_X_pow, coeff_X,
      coeff_one, hfour, hsix, hn0, hn2, hn3, Ne.symm hn1]

theorem intPhi5_map_irreducible_of_inert {q : ℕ} [Fact q.Prime]
    (hq : InertModFive q) :
    Irreducible
      ((cyclotomic 5 ℤ).map (Int.castRingHom (ZMod q))) := by
  rw [map_cyclotomic_int, ← phi5_eq_cyclotomic]
  exact phi5_irreducible_of_inert hq

theorem pure_resultant_mod_five_eq_one {A : ℕ} (hA : 0 < A) :
    ((cyclotomic 5 ℤ).resultant (pureFiberPolynomial A) : ZMod 5) =
      1 := by
  let φ : ℤ →+* ZMod 5 := Int.castRingHom (ZMod 5)
  let gbar : (ZMod 5)[X] := (pureFiberPolynomial A).map φ
  have hres :=
    resultant_X_sub_C_pow_left (1 : ZMod 5) gbar 4 gbar.natDegree le_rfl
  have hdegPhi : (cyclotomic 5 ℤ).natDegree = 4 := by
    rw [natDegree_cyclotomic]
    decide
  have hdegG :
      gbar.natDegree = (pureFiberPolynomial A).natDegree := by
    simpa [gbar] using
      (pureFiberPolynomial_monic hA).natDegree_map φ
  rw [hdegG] at hres
  have heval : eval 1 gbar = (-1 : ZMod 5) := by
    simp [gbar, pureFiberPolynomial, hA.ne']
  have hpure : ((-1 : ZMod 5) ^ 4) = 1 := by decide
  rw [heval, hpure] at hres
  change φ ((cyclotomic 5 ℤ).resultant (pureFiberPolynomial A)) = 1
  rw [← resultant_map_map]
  rw [intPhi5_map_zmod_five]
  simpa [gbar, pureFiberPolynomial, hdegPhi, hA.ne', C_1] using hres

theorem twisted_resultant_mod_five_eq_one (A : ℕ) :
    ((cyclotomic 5 ℤ).resultant (twistedFiberPolynomial A) : ZMod 5) =
      1 := by
  let φ : ℤ →+* ZMod 5 := Int.castRingHom (ZMod 5)
  let gbar : (ZMod 5)[X] := (twistedFiberPolynomial A).map φ
  have hres :=
    resultant_X_sub_C_pow_left (1 : ZMod 5) gbar 4 gbar.natDegree le_rfl
  have hdegPhi : (cyclotomic 5 ℤ).natDegree = 4 := by
    rw [natDegree_cyclotomic]
    decide
  have hdegG :
      gbar.natDegree = (twistedFiberPolynomial A).natDegree := by
    simpa [gbar] using
      (twistedFiberPolynomial_monic A).natDegree_map φ
  rw [hdegG] at hres
  have heval : eval 1 gbar = (0 : ZMod 5) ^ A + 1 := by
    simp [gbar, twistedFiberPolynomial]
  have htwisted : (((0 : ZMod 5) ^ A + 1) ^ 4) = 1 := by
    cases A with
    | zero => decide
    | succ A => simp
  rw [heval, htwisted] at hres
  change φ ((cyclotomic 5 ℤ).resultant (twistedFiberPolynomial A)) = 1
  rw [← resultant_map_map]
  rw [intPhi5_map_zmod_five]
  simpa [gbar, twistedFiberPolynomial, hdegPhi, C_1] using hres

/-- The pure resultant is a nonzero integer for every positive fiber
exponent.  In fact, its reduction modulo `5` is `1`. -/
theorem pure_resultant_ne_zero {A : ℕ} (hA : 0 < A) :
    (cyclotomic 5 ℤ).resultant (pureFiberPolynomial A) ≠ 0 := by
  intro hzero
  have hmod := pure_resultant_mod_five_eq_one hA
  rw [hzero] at hmod
  exact zero_ne_one hmod

/-- The twisted resultant is a nonzero integer for every fiber exponent. -/
theorem twisted_resultant_ne_zero (A : ℕ) :
    (cyclotomic 5 ℤ).resultant (twistedFiberPolynomial A) ≠ 0 := by
  intro hzero
  have hmod := twisted_resultant_mod_five_eq_one A
  rw [hzero] at hmod
  exact zero_ne_one hmod

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

/-- The full inert-degree contribution for the pure final row:
the quartic cyclotomic factor forces `q^4`, not merely `q`, to divide the
explicit integer resultant. -/
theorem pure_row_pow_four_dvd_resultant {q A : ℕ} [Fact q.Prime]
    (hq : InertModFive q)
    (hres : (A + 1) % 5 = 1) (hrow : LocalS5 q (A + 1)) :
    (q : ℤ) ^ 4 ∣
      (cyclotomic 5 ℤ).resultant (pureFiberPolynomial A) := by
  letI : Fact (Irreducible (phi5 q)) :=
    ⟨phi5_irreducible_of_inert hq⟩
  have hpow :=
    prime_pow_natDegree_dvd_resultant_of_common_root
      intPhi5_monic (intPhi5_map_irreducible_of_inert hq)
      (x := (zeta5 : Phi5Ring q))
      (intPhi5_eval_zeta_of_inert hq)
      (by rw [pureFiberPolynomial_eval_zeta,
          pure_row_power hq hres hrow, sub_self])
  have htot : Nat.totient 5 = 4 := by decide
  simpa [natDegree_cyclotomic, htot] using hpow

/-- The full inert-degree contribution for the twisted final row. -/
theorem twisted_row_pow_four_dvd_resultant {q A : ℕ} [Fact q.Prime]
    (hq : InertModFive q)
    (hres : (A + 1) % 5 = 4) (hrow : LocalS5 q (A + 1)) :
    (q : ℤ) ^ 4 ∣
      (cyclotomic 5 ℤ).resultant (twistedFiberPolynomial A) := by
  letI : Fact (Irreducible (phi5 q)) :=
    ⟨phi5_irreducible_of_inert hq⟩
  have hpow :=
    prime_pow_natDegree_dvd_resultant_of_common_root
      intPhi5_monic (intPhi5_map_irreducible_of_inert hq)
      (x := (zeta5 : Phi5Ring q))
      (intPhi5_eval_zeta_of_inert hq)
      (by rw [twistedFiberPolynomial_eval_zeta,
          twisted_row_vanishing hq hres hrow])
  have htot : Nat.totient 5 = 4 := by decide
  simpa [natDegree_cyclotomic, htot] using hpow

/-- A pure final row at positive exponent gives a finite size trap:
`q^4` is bounded by the absolute value of the fixed nonzero resultant. -/
theorem pure_row_pow_four_le_resultant_natAbs {q A : ℕ} [Fact q.Prime]
    (hq : InertModFive q) (hA : 0 < A)
    (hres : (A + 1) % 5 = 1) (hrow : LocalS5 q (A + 1)) :
    q ^ 4 ≤
      Int.natAbs
        ((cyclotomic 5 ℤ).resultant (pureFiberPolynomial A)) := by
  have hle :=
    Int.natAbs_le_of_dvd_ne_zero
      (pure_row_pow_four_dvd_resultant hq hres hrow)
      (pure_resultant_ne_zero hA)
  simpa [Int.natAbs_pow] using hle

/-- The corresponding finite size trap in the twisted branch. -/
theorem twisted_row_pow_four_le_resultant_natAbs {q A : ℕ} [Fact q.Prime]
    (hq : InertModFive q)
    (hres : (A + 1) % 5 = 4) (hrow : LocalS5 q (A + 1)) :
    q ^ 4 ≤
      Int.natAbs
        ((cyclotomic 5 ℤ).resultant (twistedFiberPolynomial A)) := by
  have hle :=
    Int.natAbs_le_of_dvd_ne_zero
      (twisted_row_pow_four_dvd_resultant hq hres hrow)
      (twisted_resultant_ne_zero A)
  simpa [Int.natAbs_pow] using hle

end AgrawalCore
