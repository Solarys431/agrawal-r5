import Comparator.GoldenMoment.Solution
import Comparator.FermatShadow.Solution
import Comparator.PrimitiveSupport.Solution
import Comparator.FinalRowSize.Solution

/-!
`#print axioms` audit for every theorem exported through the independent
Comparator surfaces.  The expected dependencies are a subset of
`propext`, `Quot.sound`, and `Classical.choice`.
-/

#print axioms GoldenMomentChallenge.golden_moment_factorization
#print axioms FermatShadowChallenge.agrawal_fermat_shadow
#print axioms PrimitiveSupportChallenge.four_coefficient_bridge
#print axioms PrimitiveSupportChallenge.scalar_profile
#print axioms PrimitiveSupportChallenge.single_support_exclusion
#print axioms FinalRowSizeChallenge.three_factor_exclusion
#print axioms FinalRowSizeChallenge.second_product_unique
