import NeuralGeneralization
import Lean.Util.CollectAxioms
import Lean.Elab.Command

open Lean Elab Command in
run_cmd do
  let targets : Array Name := #[
    `NeuralGeneralization.ConcreteModel.productGaussian_map_negateReadout,
    `NeuralGeneralization.ConcreteModel.negateReadout_preimage_margin,
    `NeuralGeneralization.ConcreteModel.gaussian_functionMass_not,
    `NeuralGeneralization.ConcreteModel.correctConfidence_eq_half_of_sign_symmetry,
    `NeuralGeneralization.ConcreteModel.gaussian_empty_correctConfidence,
    `NeuralGeneralization.ConcreteModel.gaussian_empty_confidenceFailure,
    `NeuralGeneralization.QuadraticTail.quadratic_remainder_bound,
    `NeuralGeneralization.QuadraticTail.Coordinate.exists_envelope,
    `NeuralGeneralization.HasExponentialRate.log_tendsto,
    `NeuralGeneralization.QuadraticTail.functionMass_hasExponentialRate,
    `NeuralGeneralization.QuadraticTail.functionMass_log_limit,
    `NeuralGeneralization.QuadraticTail.functionMass_ratio_tendsto_zero,
    `NeuralGeneralization.ConcreteModel.complexity_of_mass_below_width,
    `NeuralGeneralization.ConcreteModel.massComplexityBudget_polynomialGrowth,
    `NeuralGeneralization.ConcreteModel.complexity_of_powerPrior_mass,
    `NeuralGeneralization.ConcreteModel.powerMassComplexity_nonneg,
    `NeuralGeneralization.ConcreteModel.complexity_le_polynomial_powerMassComplexity,
    `NeuralGeneralization.ConcreteModel.powerMassComplexity_le_polynomial_complexity,

    `NeuralGeneralization.BatchTwoContinuous.bounded_teacher_exact_minimizers,
    `NeuralGeneralization.BatchTwoContinuousDepthLower.exact_minimizer_all_width_event,
    `NeuralGeneralization.QuadraticEnvelope.gaussianFactor_pos,
    `NeuralGeneralization.QuadraticEnvelope.gaussianFactor_pdf,
    `NeuralGeneralization.QuadraticEnvelope.productDensity_nonneg,
    `NeuralGeneralization.QuadraticEnvelope.measurable_productDensity,
    `NeuralGeneralization.QuadraticEnvelope.integrable_productDensity,
    `NeuralGeneralization.QuadraticEnvelope.measure_eq_integral,
    `NeuralGeneralization.QuadraticEnvelope.product_eq_withDensity,
    `NeuralGeneralization.QuadraticEnvelope.lowerProduct_pos,
    `NeuralGeneralization.QuadraticEnvelope.upperProduct_pos,
    `NeuralGeneralization.QuadraticEnvelope.product_gaussian_lower,
    `NeuralGeneralization.QuadraticEnvelope.product_gaussian_upper,
    `NeuralGeneralization.QuadraticEnvelope.smallPrior_gaussian_lower,
    `NeuralGeneralization.QuadraticEnvelope.smallPrior_gaussian_upper,
    `NeuralGeneralization.QuadraticEnvelope.smallMass_gaussian_lower,
    `NeuralGeneralization.QuadraticEnvelope.smallMass_gaussian_upper,
    `NeuralGeneralization.QuadraticEnvelope.smallMass_pos,
    `NeuralGeneralization.QuadraticEnvelope.smallMass_ratio_tendsto_zero,
    `NeuralGeneralization.QuadraticEnvelope.energyClass_tail_ratio,
    `NeuralGeneralization.BatchTwoActivation.gelu_realizesAtComplexity,
    `NeuralGeneralization.BatchTwoActivation.powerPrior_eq_activationBandPrior,
    `NeuralGeneralization.BatchTwoActivation.powerBandScale_bounds,
    `NeuralGeneralization.BatchTwoActivation.strong_prior_manuscript_confidence,
    `NeuralGeneralization.BatchTwoActivation.uniform_manuscript_confidence,
    `NeuralGeneralization.BatchTwoOnline.network_confidence_of_online,
    `NeuralGeneralization.BatchTwoOnline.infinite_majority_count_le_twice_total,
    `NeuralGeneralization.BatchTwoOnlineSharp.strongPrior_online_confidence,
    `NeuralGeneralization.BatchTwoOnlineSharp.aboveMeanField_online_confidence,
    `NeuralGeneralization.BatchTwoOnlineSharp.meanField_online_confidence,
    `NeuralGeneralization.QuadraticEnvelope.strong_prior_quadratic_envelopes,
    `NeuralGeneralization.BatchTwoShallow.readoutL1_le_sqrt_energy,
    `NeuralGeneralization.BatchTwoShallow.targetCost_le_normTargetCost,
    `NeuralGeneralization.BatchTwoShallow.voteCount_le_resource,
    `NeuralGeneralization.BatchTwoShallow.sharpExplicitBudget_mono,
    `NeuralGeneralization.BatchTwoShallow.sharpBudget_le_resource,
    `NeuralGeneralization.BatchTwoShallow.sharp_norm_sample_bound,
    `NeuralGeneralization.BatchTwoShallow.sharp_quadratic_width_sample_bound,
    `NeuralGeneralization.BatchTwoShallow.shallow_norm_all_width_all_scale,
    `NeuralGeneralization.compressionWidth_polynomialGrowth,
    `NeuralGeneralization.realizesAtComplexity_of_energy_bound,
    `NeuralGeneralization.complexity_le_of_energy_bound,
    `NeuralGeneralization.energy_le_of_complexity,
    `NeuralGeneralization.normSublevelFunctions_card_le,
    `NeuralGeneralization.BatchTwoContinuous.continuous_weightedEnergy,
    `NeuralGeneralization.BatchTwoContinuous.isClosed_exactInterpolants,
    `NeuralGeneralization.BatchTwoContinuous.isCompact_weightedEnergy_sublevel,
    `NeuralGeneralization.BatchTwoContinuous.energyMinimizers_nonempty,
    `NeuralGeneralization.BatchTwoContinuous.energyMinimizers_energy_le,
    `NeuralGeneralization.BatchTwoContinuous.energyMinimizers_isClosed,
    `NeuralGeneralization.BatchTwoContinuous.exact_minimizers_generalize,
    `NeuralGeneralization.BatchTwoContinuousDepthLower.low_energy_mixture_pair_change,
    `NeuralGeneralization.BatchTwoContinuousDepthLower.low_energy_mixture_failure,
    `NeuralGeneralization.BatchTwoContinuousDepthLower.separated_sample_exact_minimizers]
  let env ← getEnv
  for name in targets do
    unless (env.find? name).isSome do
      throwError "Missing theorem {name}"
    let axioms ← collectAxioms name
    for ax in axioms do
      unless #[`propext, `Classical.choice, `Quot.sound].contains ax do
        throwError "Unexpected axiom {ax} in {name}"
    logInfo m!"{name}: standard axioms only"
  logInfo m!"Checked {targets.size} coverage-extension theorems."
