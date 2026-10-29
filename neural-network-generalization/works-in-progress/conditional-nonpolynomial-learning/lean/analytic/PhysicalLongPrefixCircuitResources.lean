import PhysicalLongCompiledResources
import PhysicalGainPrefixEndpoint
import RepresentativeGridResources

noncomputable section
set_option maxHeartbeats 1500000
set_option maxRecDepth 4000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort

def longPrefixSizeExponent (C : ℝ) (a : ℕ) : ℕ :=
  longPrefixResourceExponent C a*longCompiledPrefixResourceExponent

def longPrefixDepthCoefficient (C : ℝ) (a : ℕ) : ℝ :=
  90*longEvaluationLogCoefficient C (a*11)+11

namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

/-- The chosen prefix graph has polynomial size and logarithmic depth, and
its actual mesh and numerical range are also polynomial. -/
theorem precisePrefix_resources (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    {R C : ℝ} (hR : 2≤R) (hC : 0≤C) (a : ℕ) (ha : 1≤a)
    (hH : (H:ℝ)+1≤R^a) (hd : (d:ℝ)+1≤R^a)
    (hr : ‖P.readout‖≤R^a) (hG : physicalGainProduct P H≤R^a)
    (hcard : (S.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P (longCompressionPrecision P))+
      ‖P.readout‖^2/((1:ℝ)/32)^2)
    (hdim : ∀j≤H,(states j).dimension≤d+1+j*(S.card+1))
    (hfloor : ∀j:Fin J,(M.radius j)⁻¹≤((H:ℝ)+1)*(physicalPartialGainBound P+1))
    (hΛ : M.nonlinearBudget≤C*(1+Real.log R)) :
    let ξ:=longEvaluationPrecision P
    let η:=longEvaluationRounding M.nonlinearBudget ξ
    let G:=M.gridSystem T hT
    ((M.precisePrefix T hT ξ (longEvaluationPrecision_pos P)).size:ℝ)≤R^(longPrefixSizeExponent C a) ∧
      ((M.precisePrefix T hT ξ (longEvaluationPrecision_pos P)).depth:ℝ)≤longPrefixDepthCoefficient C a*(1+Real.log R) ∧
      (G.mesh η:ℝ)≤R^(longPrefixResourceExponent C a*105) ∧
      (G.stateRange:ℝ)≤R^(longPrefixResourceExponent C a*6) ∧
      (canonicalAmbientDimension states J:ℝ)≤R^(longPrefixResourceExponent C a) := by
  intro ξ η G
  have henv:=M.long_prefix_resource_envelope T hT hR hC a ha hH hd hr hG hcard hdim hfloor hΛ
  have hη : 0<η :=longEvaluationRounding_pos (longEvaluationPrecision_pos P)
  have hη1:η≤1:=(longEvaluationRounding_small M.nonlinearBudget_nonneg (longEvaluationPrecision_pos P)).trans (by norm_num)
  have hs:=M.compiledPrefix_polynomial_size T hT henv.1 hη hη1 henv.2.1 henv.2.2.1
    henv.2.2.2.1 henv.2.2.2.2.1 _ henv.2.2.2.2.2
  have hn:=G.numeric_resources henv.1.scale hη henv.2.1 henv.2.2.1
    henv.1.dimension henv.1.tolerance henv.2.2.2.2.1
  have hWa:2≤R^a:=hR.trans (by simpa only [pow_one] using resource_pow_mono hR ha)
  have hξ:ξ⁻¹≤R^(a*11):=by
    have hh:=(long_precision_primitive_resources P hWa hH hr hG).2.2.1
    simpa only [←pow_mul] using hh
  have hk:= (longEvaluation_resources M.nonlinearBudget_nonneg
    (longEvaluationPrecision_pos P) hC hR (a*11) hΛ hξ).1
  have hdepth:((M.precisePrefix T hT ξ (longEvaluationPrecision_pos P)).depth:ℝ)≤
      90*(longEvaluationIterations M.nonlinearBudget ξ:ℝ)+11:=by
    exact_mod_cast M.precisePrefix_depth T hT ξ (longEvaluationPrecision_pos P)
  refine ⟨?_,?_,?_,?_,henv.1.dimension⟩
  · exact hs.trans_eq (pow_mul R (longPrefixResourceExponent C a) longCompiledPrefixResourceExponent).symm
  · unfold longPrefixDepthCoefficient
    have hl:0≤Real.log R:=Real.log_nonneg (by linarith)
    nlinarith
  · simpa only [←pow_mul] using hn.2.2.2.1
  · simpa only [←pow_mul] using hn.1

#print axioms precisePrefix_resources
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
