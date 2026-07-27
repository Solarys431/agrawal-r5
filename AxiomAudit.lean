import AgrawalCore

/-!
Reproducible `#print axioms` surface for the headline declarations.

The expected output contains only Lean/Mathlib's standard logical axioms:
`propext`, `Classical.choice`, and `Quot.sound` (with
`Classical.choice` absent where it is not needed). No project-defined axiom is
introduced.
-/

#print axioms AgrawalCore.moment_covariance
#print axioms AgrawalCore.pow_succ_eq_one_of_moment_ne_zero
#print axioms AgrawalCore.golden_moment_factorization
#print axioms AgrawalCore.zmod_golden_moment_index
#print axioms AgrawalCore.agrawal_fermat_shadow
#print axioms AgrawalCore.agrawal_two_adic_jaw
#print axioms AgrawalCore.orderOf_norm_power
#print axioms AgrawalCore.orderOf_norm_decomposition
#print axioms AgrawalCore.orderOf_norm_kernel
#print axioms AgrawalCore.defectProduct_threshold
#print axioms AgrawalCore.odd_defectProduct_threshold
#print axioms AgrawalCore.odd_defectProduct_normal_iff
#print axioms AgrawalCore.lenstra_proposition_card
#print axioms AgrawalCore.partition_forced
#print axioms AgrawalCore.hasOrderFourTransport_iff_goldenH_support
#print axioms AgrawalCore.no_squarefree_counterexample_of_no_witnesses
#print axioms AgrawalCore.primitiveSupport_iff_fourCoefficientGcd
#print axioms AgrawalCore.one_order_dvd_eight_of_single_odd_prime
#print axioms AgrawalCore.gamma_pow_formula
#print axioms AgrawalCore.noncanonicalP_prime
#print axioms AgrawalCore.noncanonical_inert
#print axioms AgrawalCore.noncanonical_five_order_certificate
#print axioms AgrawalCore.noncanonical_five_order
#print axioms AgrawalCore.split_pair_zero_iff_four_coefficient_gcd
#print axioms AgrawalCore.eval₂_cyclotomic_gamma_coeffs
#print axioms AgrawalCore.primitiveFourVanish_iff_dvd_D
#print axioms AgrawalCore.canonicalSignature_unique
#print axioms AgrawalCore.primitiveFourVanish_exact_order_profile
#print axioms AgrawalCore.dvd_primitiveFourCoefficientD_exact_order_profile
#print axioms AgrawalCore.dvd_D_exact_scalar_profile
#print axioms AgrawalCore.no_split_single_odd_support
#print axioms AgrawalCore.threeFactor_finalRow_size_exclusion
#print axioms AgrawalCore.localRow_order_le_max
#print axioms AgrawalCore.pureRow_dvd_product_sub_one
#print axioms AgrawalCore.twistedRow_dvd_sq_sub_product
#print axioms AgrawalCore.twistedRow_product_le_sq_sub_order
#print axioms AgrawalCore.mitm_secondProduct_unique
