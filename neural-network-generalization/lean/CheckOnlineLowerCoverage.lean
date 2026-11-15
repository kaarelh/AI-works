import NeuralGeneralization.OnlineLowerFullPaperCoverage
import Lean.Util.CollectAxioms

/-! Exact main-statement gates and an axiom audit of every declaration
in the added coverage modules (including generated proof declarations).
The module inventory is fixed here so an omitted module cannot silently pass.
-/
set_option maxHeartbeats 0

open NeuralGeneralization
example : OnlineLower.ReLUConcreteMainStatement := OnlineLower.relu_concrete_main
example : OnlineLower.TanhConcreteMainStatement := OnlineLower.tanh_concrete_main
example : OnlineLowerSoftplus.SoftplusConcreteMainStatement := OnlineLowerSoftplus.softplus_concrete_main
example : OnlineLower.WidthExponentLowerBound OnlineLowerSoftplus.softplus (1/2) :=
  OnlineLowerSoftplus.softplus_width_square_root_lower_bound

-- Literal numerical normalizations and the paper's coordinate-product equation.
open MeasureTheory Set
open scoped BigOperators
example : OnlineLowerRelu.fourierAbsConstant = Real.pi :=
  OnlineLowerRelu.fourierAbsConstant_eq_pi
example (z : ℝ) : |z| = (2 / Real.pi) *
    ∫ t : ℝ in Ioi 0, (1 - Real.cos (t * z)) / t ^ 2 :=
  OnlineLowerRelu.abs_eq_cosine_integral_pi z
example {d : ℕ} (S : Finset (Fin d)) (hS : 2 ≤ S.card) (heven : Even S.card)
    (b : ℝ) (u : Fin d → ℝ) :
    let kernel : ℝ → ℝ := fun t => Real.cos (b * t) *
      (∏ i ∈ S, Real.sin (u i * t)) *
      (∏ i ∈ Finset.univ \ S, Real.cos (u i * t)) / t ^ 2
    IntegrableOn kernel (Ioi 0) ∧
    walshCoefficients (fun x => max (OnlineLowerRelu.cubeAffine b u x) 0) S =
      (-1 : ℝ) ^ (S.card / 2 + 1) / Real.pi * ∫ t : ℝ in Ioi 0, kernel t :=
  OnlineLowerRelu.relu_walsh_integral_paper S hS heven b u

section TanhCostExpansionGate
open OnlineLowerTanh
example : ∃ T K : ℝ, 2 ≤ T ∧ 0 < K ∧ 0 < optimizedCostCurvature ∧
    ∀ r : ℕ, T < (2 * r + 1 : ℕ) →
      |balancedCost r - (optimizedCostSlope * (2 * r + 1 : ℕ) +
        optimizedCostIntercept + optimizedCostCurvature / (2 * r + 1 : ℕ))| ≤
          K / (2 * r + 1 : ℕ) ^ 2 := balanced_cost_expansion_paper
example : ∃ T K : ℝ, 2 ≤ T ∧ 0 < K ∧ ∀ u : ℝ, 3 * T < u →
    |iteratedDeriv 2 (optimizedRealCost actualGainBranch) u -
      2 * optimizedCostCurvature / u ^ 3| ≤ 24 * K / u ^ 4 := by
  obtain ⟨T, K, hT, hK, _, _, _, _, _, hd⟩ := optimized_cost_expansion_paper
  exact ⟨T, K, hT, hK, hd⟩
end TanhCostExpansionGate

#print axioms OnlineLowerTanh.optimized_cost_expansion_paper
#print axioms OnlineLowerTanh.balanced_cost_expansion_paper
#print axioms OnlineLowerRelu.fourierAbsConstant_eq_pi
#print axioms OnlineLowerRelu.relu_walsh_integral_paper

#print axioms OnlineLower.relu_concrete_main
#print axioms OnlineLower.tanh_concrete_main
#print axioms OnlineLowerSoftplus.softplus_concrete_main
#print axioms OnlineLowerRelu.relu_arbitrary_layer_variance_main

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let modules : Array Name := #[
    `NeuralGeneralization.OnlineLowerCostPathGap,
    `NeuralGeneralization.OnlineLowerOffsetOutputBound,
    `NeuralGeneralization.OnlineLowerReluCoverageBalancing,
    `NeuralGeneralization.OnlineLowerReluCoverageBalancingUnused,
    `NeuralGeneralization.OnlineLowerReluCoverageEquality,
    `NeuralGeneralization.OnlineLowerReluCoverageMinimum,
    `NeuralGeneralization.OnlineLowerReluCoverageMinimumCoordinate,
    `NeuralGeneralization.OnlineLowerReluCoverageRepresentation,
    `NeuralGeneralization.OnlineLowerReluCoverageStability,
    `NeuralGeneralization.OnlineLowerReluCoverageVariation,
    `NeuralGeneralization.OnlineLowerReluFourierNormalization,
    `NeuralGeneralization.OnlineLowerReluLayerVariance,
    `NeuralGeneralization.OnlineLowerReluLayerVarianceMain,
    `NeuralGeneralization.OnlineLowerSoftplusAtom,
    `NeuralGeneralization.OnlineLowerSoftplusAtomFamilyPotential,
    `NeuralGeneralization.OnlineLowerSoftplusAtomPotential,
    `NeuralGeneralization.OnlineLowerSoftplusBasic,
    `NeuralGeneralization.OnlineLowerSoftplusCompact,
    `NeuralGeneralization.OnlineLowerSoftplusConcreteStatement,
    `NeuralGeneralization.OnlineLowerSoftplusConstraints,
    `NeuralGeneralization.OnlineLowerSoftplusEmbedding,
    `NeuralGeneralization.OnlineLowerSoftplusFamilyAssembly,
    `NeuralGeneralization.OnlineLowerSoftplusFinalBridge,
    `NeuralGeneralization.OnlineLowerSoftplusMain,
    `NeuralGeneralization.OnlineLowerSoftplusMixture,
    `NeuralGeneralization.OnlineLowerSoftplusMixtureHinge,
    `NeuralGeneralization.OnlineLowerSoftplusNetwork,
    `NeuralGeneralization.OnlineLowerSoftplusParameters,
    `NeuralGeneralization.OnlineLowerSoftplusTeacher,
    `NeuralGeneralization.OnlineLowerSoftplusTeacherGrid,
    `NeuralGeneralization.OnlineLowerSoftplusTeacherPadding,
    `NeuralGeneralization.OnlineLowerTanhCodeAmbient,
    `NeuralGeneralization.OnlineLowerTanhCodeAmbientAllPairs,
    `NeuralGeneralization.OnlineLowerTanhCodeAmbientCoordinates,
    `NeuralGeneralization.OnlineLowerTanhCodeAmbientJensen,
    `NeuralGeneralization.OnlineLowerTanhCodeAmbientLocalization,
    `NeuralGeneralization.OnlineLowerTanhCodeAmbientPaper,
    `NeuralGeneralization.OnlineLowerTanhCodeCoverageEquality,
    `NeuralGeneralization.OnlineLowerTanhCodeExactSharp,
    `NeuralGeneralization.OnlineLowerTanhCodeExactSharpCore,
    `NeuralGeneralization.OnlineLowerTanhCodeLocalSharp,
    `NeuralGeneralization.OnlineLowerTanhCodeLocalSmallness,
    `NeuralGeneralization.OnlineLowerTanhCodeProjectionSharp,
    `NeuralGeneralization.OnlineLowerTanhCodeQuantitativeLocalization,
    `NeuralGeneralization.OnlineLowerTanhCodeQuantitativePaper,
    `NeuralGeneralization.OnlineLowerTanhCodeVanishingSharp,
    `NeuralGeneralization.OnlineLowerTanhCostExpansionPaper,
    `NeuralGeneralization.OnlineLowerTanhCoverageVariation,
    `NeuralGeneralization.OnlineLowerTanhDominantPairAsymptotics,
    `NeuralGeneralization.OnlineLowerTanhEqualBulkEquality,
    `NeuralGeneralization.OnlineLowerTanhEqualityAffine,
    `NeuralGeneralization.OnlineLowerTanhEqualityDefects,
    `NeuralGeneralization.OnlineLowerTanhEqualityIntrinsic,
    `NeuralGeneralization.OnlineLowerTanhEqualityPhase,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityAmbientGap,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityCodeSigns,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityCurvature,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityDirectional,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityGain,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityGradient,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityHessian,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityLocalCode,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityLocalCodePaper,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityLocalMaximum,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityLocalSign,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityMoments,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityOffSupport,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityPairSlices,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityQuadratic,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityQuadraticGap,
    `NeuralGeneralization.OnlineLowerTanhFiniteParityRails,
    `NeuralGeneralization.OnlineLowerTanhFiniteParitySlices,
    `NeuralGeneralization.OnlineLowerTanhInverseLaplaceBasics,
    `NeuralGeneralization.OnlineLowerTanhInverseLaplaceContour,
    `NeuralGeneralization.OnlineLowerTanhInverseLaplaceInversion,
    `NeuralGeneralization.OnlineLowerTanhInverseLaplaceKernel,
    `NeuralGeneralization.OnlineLowerTanhNearOptimalBulk,
    `NeuralGeneralization.OnlineLowerTanhNearOptimalConcentration,
    `NeuralGeneralization.OnlineLowerTanhNearOptimalLattice,
    `NeuralGeneralization.OnlineLowerTanhPaperLP,
    `NeuralGeneralization.OnlineLowerTanhPaperLPDistribution,
    `NeuralGeneralization.OnlineLowerTanhPaperLPDual,
    `NeuralGeneralization.OnlineLowerTanhPaperLPMinimum,
    `NeuralGeneralization.OnlineLowerTanhPaperLPNormalize,
    `NeuralGeneralization.OnlineLowerTanhPaperLPOvershootData,
    `NeuralGeneralization.OnlineLowerTanhPaperLPPaper,
    `NeuralGeneralization.OnlineLowerTanhPaperLPPoint,
    `NeuralGeneralization.OnlineLowerTanhPaperLPSubgroup,
    `NeuralGeneralization.OnlineLowerTanhParitySupremumLimit,
    `NeuralGeneralization.OnlineLowerTanhPeriodicCompactSmoothing,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactBinomial,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactGaussian,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactLargeGain,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactMaximum,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactPeriodization,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactRealDerivative,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoring,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringCoefficients,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringError,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringFourier,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringPolynomial,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringRatioError,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringTail,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactSecond,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactShape,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactSmallGain,
    `NeuralGeneralization.OnlineLowerTanhPeriodicExactSmoothingGap,
    `NeuralGeneralization.OnlineLowerTanhPeriodicRestoringExpectation,
    `NeuralGeneralization.OnlineLowerTanhPeriodicRestoringIntegral,
    `NeuralGeneralization.OnlineLowerTanhPhysicalSupportSharpConstant,
    `NeuralGeneralization.OnlineLowerTanhPositiveInverseLaplace,
    `NeuralGeneralization.OnlineLowerTanhRectangleAsymptotics,
    `NeuralGeneralization.OnlineLowerTanhResidualAllDerivatives,
    `NeuralGeneralization.OnlineLowerTanhResidualCompactUniform,
    `NeuralGeneralization.OnlineLowerTanhResidualEnvelopeCorrection,
    `NeuralGeneralization.OnlineLowerTanhResidualExternalPhase,
    `NeuralGeneralization.OnlineLowerTanhResidualGaussianJet,
    `NeuralGeneralization.OnlineLowerTanhResidualMomentCLT,
    `NeuralGeneralization.OnlineLowerTanhResidualMomentSeries,
    `NeuralGeneralization.OnlineLowerTanhResidualMomentTruncation,
    `NeuralGeneralization.OnlineLowerTanhResidualPaper,
    `NeuralGeneralization.OnlineLowerTanhResidualUniformTheorem,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificate,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateBasis,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateExpanded,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle0,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle1,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle10,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle2,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle3,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle4,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle5,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle6,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle7,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle8,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle9,
    `NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangles,
    `NeuralGeneralization.OnlineLowerTanhSupportSharpConstant,
    `NeuralGeneralization.OnlineLowerTanhThreeBitAlgebra,
    `NeuralGeneralization.OnlineLowerTanhThreeBitHolder,
    `NeuralGeneralization.OnlineLowerTanhThreeBitMaximum,
    `NeuralGeneralization.OnlineLowerTanhThreeBitSharp,
    `NeuralGeneralization.OnlineLowerTanhThreeBitStationary,
    `NeuralGeneralization.OnlineLowerTanhThreeBitVariation,
    `NeuralGeneralization.OnlineLowerTanhWalshAsymptotics
  ]
  let moduleSet : NameSet := modules.foldl (fun s n => s.insert n) {}
  let allowed : Array Name := #[`propext, `Classical.choice, `Quot.sound]
  -- A printed axiom list alone would not reject a new axiom in a main theorem.
  let mainEndpoints : Array Name := #[
    `NeuralGeneralization.OnlineLower.relu_concrete_main,
    `NeuralGeneralization.OnlineLower.relu_width_square_root_lower_bound,
    `NeuralGeneralization.OnlineLower.tanh_concrete_main,
    `NeuralGeneralization.OnlineLower.tanh_square_root_log_loss_lower_bound,
    `NeuralGeneralization.OnlineLowerSoftplus.softplus_concrete_main,
    `NeuralGeneralization.OnlineLowerSoftplus.softplus_width_square_root_lower_bound,
    `NeuralGeneralization.OnlineLowerRelu.relu_arbitrary_layer_variance_main
  ]
  for endpoint in mainEndpoints do
    unless env.contains endpoint do
      throwError "Missing main endpoint {endpoint}"
    for ax in (← Lean.collectAxioms endpoint) do
      unless allowed.contains ax do
        throwError "Unexpected axiom {ax} in main endpoint {endpoint}"
  let mut checked := 0
  let mut theorems := 0
  let mut seen : Array Name := #[]
  for (n, ci) in env.constants.toList do
    if let some idx := env.getModuleIdxFor? n then
      let mod := env.header.moduleNames[idx]!
      if moduleSet.contains mod then
        let axioms ← Lean.collectAxioms n
        for ax in axioms do
          unless allowed.contains ax do
            throwError "Unexpected axiom {ax} in {n}"
        checked := checked + 1
        if ci matches .thmInfo _ then theorems := theorems + 1
        unless seen.contains mod do seen := seen.push mod
  for mod in modules do
    unless seen.contains mod do
      throwError "No checked declaration from coverage module {mod}"
  logInfo m!"Coverage audit passed: {checked} declarations ({theorems} theorems) in {seen.size} added modules; only propext, Classical.choice, Quot.sound."
