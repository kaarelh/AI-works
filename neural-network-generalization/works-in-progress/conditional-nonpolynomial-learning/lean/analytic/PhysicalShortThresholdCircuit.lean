import PhysicalShortClassifierResources
import PhysicalShortGridResourceEnvelope
import PhysicalShortRoundingBounds

/-! An actual polynomial-size, logarithmic-depth threshold DAG is constructed
from every near-baseline physical controlled margin path. All Gaussian
compression, quadrature, arithmetic lookup, finite precision, retained-input
wiring and final sign decisions occur in the imported proved construction. -/
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

 def criticalCapacitySizeExponent (B : ℝ) : ℕ :=
  criticalGridExponent B*canonicalClassifierResourceExponent
 def criticalCapacityDepthCoefficient (B : ℝ) : ℝ :=
  90*criticalIterationCoefficient B+17
 def criticalCapacityExponent (B : ℝ) : ℕ :=
  criticalCapacitySizeExponent B+⌈criticalCapacityDepthCoefficient B⌉₊+1

 theorem critical_path_threshold_circuit {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H)
    {ε B R : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R)
    (hdR : (d:ℝ)≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε) :
    ∃C : ThresholdCircuit d,C.eval=f ∧
      (C.size:ℝ)≤R^(criticalCapacitySizeExponent B) ∧
      (C.depth:ℝ)≤criticalCapacityDepthCoefficient B*(1+Real.log R) := by
  obtain ⟨S,states,c,M,hzero,hcard,hdim,hquery,hc,hcert⟩ :=
    critical_finite_parallel_sign_program P hd (by omega)
  obtain ⟨T,hT,hTx⟩ := M.initial_linear_map hzero
  obtain ⟨hprim,hI,hK,hHp,hΛ,hread,hk⟩ := M.critical_grid_resource_envelope hd hH hε hB hR
    hdR hHR hgap hnear hdim hcard
  have hη := canonicalSignRounding_positive P
  have hη1 := canonicalSignRounding_le_one P
  have hηsmall : canonicalSignRounding P≤(1:ℝ)/4 := (canonicalSignRounding_small P).trans (by norm_num)
  let C := M.selectedClassifier hd T c (canonicalSignRounding P) hη hη1
  have hcorrect : C.eval=f := M.selectedClassifier_correct hd T hT hTx c hcert
    (canonicalSignRounding P) hη hη1 hηsmall le_rfl
  have hS : 0≤normalizingScale M.linearGain H := by
    linarith [normalizingScale_one_le M.linearGain M.linearGain_one_le H]
  have hreadc : normalizingScale M.linearGain H*‖c‖≤R^(criticalGridExponent B) :=
    (mul_le_mul_of_nonneg_left hc hS).trans hread
  have hsize := M.selectedClassifier_polynomial_size hd T hT c hprim hη hη1 hI hK hHp hΛ hreadc hk
  have hdepth : (C.depth:ℝ)≤90*(canonicalSignIterations P:ℝ)+17 := by
    exact_mod_cast M.selectedClassifier_depth hd T c (canonicalSignRounding P) hη hη1
  refine ⟨C,hcorrect,?_,?_⟩
  · simpa only [C,←pow_mul,criticalCapacitySizeExponent] using hsize
  · have hklog := critical_iteration_log_bound P hd hH hε hB hR hHR hgap hnear
    have hlog : 0≤Real.log R := Real.log_nonneg (by linarith)
    unfold criticalCapacityDepthCoefficient
    nlinarith

/-- Uniform quantifier order: the exponent depends only on the fixed action
slack coefficient B, never on the target, depth, width or controlled law. -/
theorem critical_path_capacity {B : ℝ} (hB : 0≤B) :
    ∃K : ℕ,∀{d H : ℕ} {t : ℝ} {f : BooleanFunction d} (P : ControlledMarginPath d H t f),
      1≤d→1≤H→∀{ε R : ℝ},0≤ε→2≤R→(d:ℝ)≤R→(H:ℝ)≤R→
      (H:ℝ)*ε≤B*(1+Real.log R)^2→P.action≤scalarBaseline.toReal+ε→
      ∃C : ThresholdCircuit d,C.eval=f ∧ (C.size:ℝ)≤R^K ∧ (C.depth:ℝ)≤(K:ℝ)*(1+Real.log R) := by
  refine ⟨criticalCapacityExponent B,?_⟩
  intro d H t f P hd hH ε R hε hR hdR hHR hgap hnear
  obtain ⟨C,hf,hs,hD⟩ := critical_path_threshold_circuit P hd hH hε hB hR hdR hHR hgap hnear
  refine ⟨C,hf,hs.trans (resource_pow_mono hR ?_),hD.trans ?_⟩
  · unfold criticalCapacityExponent
    omega
  · have hcoef : criticalCapacityDepthCoefficient B≤(criticalCapacityExponent B:ℝ) := by
      have hh := Nat.le_ceil (criticalCapacityDepthCoefficient B)
      unfold criticalCapacityExponent
      push_cast
      linarith [show (0:ℝ)≤(criticalCapacitySizeExponent B:ℝ) from Nat.cast_nonneg _]
    exact mul_le_mul_of_nonneg_right hcoef (by linarith [Real.log_nonneg (show 1≤R by linarith)])

#print axioms critical_path_threshold_circuit
#print axioms critical_path_capacity
end ConditionalNonpolynomial.Analytic.PhysicalShort
