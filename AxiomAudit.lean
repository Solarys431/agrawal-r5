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
#print axioms AgrawalCore.lenstra_proposition_card
#print axioms AgrawalCore.partition_forced
#print axioms AgrawalCore.hasOrderFourTransport_iff_goldenH_support
#print axioms AgrawalCore.no_squarefree_counterexample_of_no_witnesses
#print axioms AgrawalCore.primitiveSupport_iff_fourCoefficientGcd
#print axioms AgrawalCore.one_order_dvd_eight_of_single_odd_prime
