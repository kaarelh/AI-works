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
