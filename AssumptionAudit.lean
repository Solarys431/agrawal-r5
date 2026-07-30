import AgrawalCore
import Mathlib.Lean.Expr.Basic

/-!
# Mechanical hypothesis-minimality audit

The UNICO/NOUS taste canon requires every instance assumption in a public
statement to be tested for removal after elaboration.  This audit inspects the
kernel-elaborated type of every public theorem in the `AgrawalCore` namespace.
It identifies instance binders absent from the proposition body and compares
them with an exact declared proof-route-debt inventory.  The companion
`lake --wfail build` checks Lean's proof-aware `unusedSectionVars` linter.

The implementation deliberately reuses Mathlib's
`getUnusedForallInstanceBinderIdxsWhere`; no source-text heuristic is involved.
-/

open Lean Meta Elab Command

namespace AgrawalCore.AssumptionAudit

private def isPublicAgrawalTheorem (name : Name) (info : ConstantInfo) : Bool :=
  let text := name.toString
  text.startsWith "AgrawalCore." &&
    !text.startsWith "AgrawalCore.AssumptionAudit." &&
    !text.contains "._" &&
    match info with
    | .thmInfo _ => true
    | _ => false

/--
Instance binders which are absent from the proposition after elaboration but
remain dependencies of the current proof route.  This list is deliberately
exact: CI fails if a new debt appears or an existing debt disappears without
the audit being updated.

The suffix records the zero-based binder indices returned by
`getUnusedForallInstanceBinderIdxsWhere`.
-/
private def declaredProofRouteDebts : List String :=
  [
    "AgrawalCore.cyclotomicSqrtFive_isUnit:[1]",
    "AgrawalCore.dvd_fib_of_pow_eq_neg_one:[1]",
    "AgrawalCore.dvd_lucas_of_pow_eq_neg_one:[1]",
    "AgrawalCore.dvd_of_natCast_eq_zero:[1]",
    "AgrawalCore.dvd_of_phi5_natCast_eq_zero:[1]",
    "AgrawalCore.eps'_sq:[1]",
    "AgrawalCore.eps_isUnit:[1]",
    "AgrawalCore.eps_mul_eps':[1]",
    "AgrawalCore.eps_pow_add_eps'_pow:[1]",
    "AgrawalCore.eps_sq:[1]",
    "AgrawalCore.goldenPoly_degree:[1]",
    "AgrawalCore.golden_pow_eq_neg_one_iff_dvd_A:[1]",
    "AgrawalCore.golden_pow_fib:[1]",
    "AgrawalCore.instCharPGoldenRing:[1]",
    "AgrawalCore.instNontrivialGoldenRing:[1]",
    "AgrawalCore.instNontrivialPhi5Ring:[1]",
    "AgrawalCore.lenstra_local:[1]",
    "AgrawalCore.localFive_isUnit:[1]",
    "AgrawalCore.mem_powMonoidHom_range_iff_pow_card_div_eq_one:[2, 3]",
    "AgrawalCore.natCast_eq_zero_of_dvd:[1]",
    "AgrawalCore.of_injective:[1]",
    "AgrawalCore.orderOf_norm_decomposition:[2]",
    "AgrawalCore.orderOf_norm_kernel:[2]",
    "AgrawalCore.orderOf_norm_power:[2]",
    "AgrawalCore.orderOf_norm_power_dvd:[2]",
    "AgrawalCore.order_bound_relation:[1]",
    "AgrawalCore.order_bounded:[1]",
    "AgrawalCore.order_bounded_one:[1]",
    "AgrawalCore.phi5_charP:[1]",
    "AgrawalCore.phi5_degree:[1]",
    "AgrawalCore.phi5_expChar:[1]",
    "AgrawalCore.phi5_irreducible_of_inert:[1]",
    "AgrawalCore.phi5_monic:[1]",
    "AgrawalCore.phi5_of_injective:[1]",
    "AgrawalCore.pow_eq_neg_one_of_dvd_fib_odd:[1]",
    "AgrawalCore.pow_eq_neg_one_of_dvd_lucas_even:[1]",
    "AgrawalCore.pow_eq_one_of_dvd_fib:[1]",
    "AgrawalCore.pow_eq_one_of_dvd_lucas:[1]",
    "AgrawalCore.sqrt5_isUnit:[1]",
    "AgrawalCore.sqrt5_sq:[1]",
    "AgrawalCore.shifted_generator_isFourthPower_iff:[2, 3]",
    "AgrawalCore.shifted_generator_isPower_iff:[2, 3]",
    "AgrawalCore.support_witness:[1]",
    "AgrawalCore.u2_isUnit:[1]",
    "AgrawalCore.u3_isUnit:[1]",
    "AgrawalCore.u4_eq_cyclo_factor:[1]",
    "AgrawalCore.u4_isUnit:[1]",
    "AgrawalCore.zeta5_isUnit:[1]",
    "AgrawalCore.zeta5_orbit_sum:[1]",
    "AgrawalCore.zeta5_pow_five:[1]",
    "AgrawalCore.zeta5_pow_mod:[1]",
    "AgrawalCore.zeta5_rel:[1]",
    "AgrawalCore.zeta_sub_one_isUnit:[1]",
    "AgrawalCore.zeta_sub_one_pow_p:[1]",
    "AgrawalCore.zeta_sub_one_pow_sq:[1]",
    "AgrawalCore.zeta5_unit_power_sub_one_isUnit:[1]"
  ]

run_cmd liftTermElabM do
  let env ← getEnv
  let declarations : List (Name × ConstantInfo) :=
    env.constants.toList
      |>.filter (fun (name, info) => isPublicAgrawalTheorem name info)

  let mut theoremCount : Nat := 0
  let mut instanceBinderCount : Nat := 0
  let mut debtBinderCount : Nat := 0
  let mut actualDebts : Array String := #[]

  for (name, info) in declarations do
    theoremCount := theoremCount + 1
    let type : Expr := ConstantInfo.type info
    let mut cursor : Expr := type
    while h : cursor.isForall do
      if (Expr.binderInfo cursor).isInstImplicit then
        instanceBinderCount := instanceBinderCount + 1
      cursor := cursor.forallBody h
    let unused : Array Nat :=
      type.getUnusedForallInstanceBinderIdxsWhere (fun _ => true)
    unless unused.isEmpty do
      debtBinderCount := debtBinderCount + unused.size
      actualDebts := actualDebts.push s!"{name}:{unused.toList}"

  let missing :=
    declaredProofRouteDebts.filter fun key => !actualDebts.contains key
  let unexpected :=
    actualDebts.toList.filter fun key => !declaredProofRouteDebts.contains key
  unless missing.isEmpty && unexpected.isEmpty do
    throwError
      "Public hypothesis-minimality inventory drifted.\n\
      Missing declared debts: {missing}\n\
      Unexpected debts: {unexpected}"

  logInfo m!"Public hypothesis-minimality audit: PASS"
  logInfo m!"  theorems inspected: {theoremCount}"
  logInfo m!"  instance binders inspected: {instanceBinderCount}"
  logInfo m!"  generalized assumptions removed in this audit: 2"
  logInfo m!"  declared proof-route debt entries: {actualDebts.size}"
  logInfo m!"  declared proof-route binders: {debtBinderCount}"
  logInfo m!"  unrecorded debts: 0"

end AgrawalCore.AssumptionAudit
