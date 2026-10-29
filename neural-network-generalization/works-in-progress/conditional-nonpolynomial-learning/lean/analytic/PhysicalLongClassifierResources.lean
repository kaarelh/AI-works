import PhysicalLongPrefixCircuitResources
import PhysicalPrefixClassifier

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort

def longClassifierCommonExponent (C : ℝ) (a b : ℕ) : ℕ :=
  105*longPrefixResourceExponent C a+b+3*a+2

def longClassifierSizeExponent (C : ℝ) (a b : ℕ) : ℕ :=
  longClassifierCommonExponent C a b*
    (longCompiledPrefixResourceExponent+14*distanceClassifierResourceExponent+1)

def longClassifierDepthCoefficient (C : ℝ) (a : ℕ) : ℝ :=
  90*longEvaluationLogCoefficient C (a*11)+27

namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

/-- The literal representative classifier has polynomial size and logarithmic
threshold depth. The coefficient and exponent depend only on the stated
uniform analytic resource constants. -/
theorem representativeClassifier_resources (M : GainPrefixDynamics P S states J)
    (hinit : ∀x,‖(states 0).feature x‖≤2)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    {R C : ℝ} (hR : 2≤R) (hC : 0≤C) (a b : ℕ) (ha : 1≤a)
    (hH : (H:ℝ)+1≤R^a) (hd : (d:ℝ)+1≤R^a)
    (hr : ‖P.readout‖≤R^a) (hG : physicalGainProduct P H≤R^a)
    (hcard : (S.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P (longCompressionPrecision P))+
      ‖P.readout‖^2/((1:ℝ)/32)^2)
    (hdim : ∀j≤H,(states j).dimension≤d+1+j*(S.card+1))
    (hfloor : ∀j:Fin J,(M.radius j)⁻¹≤((H:ℝ)+1)*(physicalPartialGainBound P+1))
    (hΛ : M.nonlinearBudget≤C*(1+Real.log R))
    (Y : Finset (Cube d)) (hY : (Y.card:ℝ)≤R^b) :
    ((M.representativeClassifier T hT Y).size:ℝ)≤R^(longClassifierSizeExponent C a b) ∧
      ((M.representativeClassifier T hT Y).depth:ℝ)≤longClassifierDepthCoefficient C a*(1+Real.log R) := by
  classical
  let l:=longClassifierCommonExponent C a b
  let p:=longPrefixResourceExponent C a
  have hpre:=M.precisePrefix_resources T hT hR hC a ha hH hd hr hG hcard hdim hfloor hΛ
  have hmono (n : ℕ) (hn : n≤l) : R^n≤R^l:=resource_pow_mono hR hn
  have hl2 : 2≤l := by dsimp [l,longClassifierCommonExponent];omega
  have hscale:3≤R^l:= (show (3:ℝ)≤R^2 by nlinarith).trans (hmono 2 hl2)
  have hA : 1≤1+‖P.readout‖*physicalGainProduct P H := by
    have hh:=mul_nonneg (norm_nonneg P.readout) (physicalGainProduct_pos P H).le
    linarith
  have hAR:1+‖P.readout‖*physicalGainProduct P H≤R^l:=by
    have hp:=resource_mul hR hr hG (physicalGainProduct_pos P H).le
    have hs:=resource_add_one hR hp
    have he:a+a+1≤l:=by dsimp [l,longClassifierCommonExponent];omega
    exact (by linarith : 1+‖P.readout‖*physicalGainProduct P H≤R^(a+a+1)).trans (hmono _ he)
  have hD:(Fintype.card (states J).Index:ℝ)≤R^l:=by
    have hi : Fintype.card (states J).Index≤canonicalAmbientDimension states J :=
      Fintype.card_le_of_injective (fun i=>(⟨Fin.last J,i⟩ : CanonicalAmbientIndex states J))
        (by intro x y h;cases h;rfl)
    exact (show (Fintype.card (states J).Index:ℝ)≤canonicalAmbientDimension states J by exact_mod_cast hi).trans
      (hpre.2.2.2.2.trans (hmono p (by dsimp [p,l,longClassifierCommonExponent];omega)))
  have hQ:=hpre.2.2.1.trans (hmono (p*105) (by dsimp [p,l,longClassifierCommonExponent];omega))
  have hN:=hpre.2.2.2.1.trans (hmono (p*6) (by dsimp [p,l,longClassifierCommonExponent];omega))
  have hCsize : ((M.precisePrefix T hT (longEvaluationPrecision P) (longEvaluationPrecision_pos P)).size:ℝ)≤
      (R^l)^longCompiledPrefixResourceExponent := by
    rw [←pow_mul]
    apply hpre.1.trans
    apply resource_pow_mono hR
    unfold longPrefixSizeExponent
    exact Nat.mul_le_mul_right _ (by dsimp [l,longClassifierCommonExponent];omega)
  have hs:=representativeClassifierAfter_polynomial_size
    (M.precisePrefix T hT (longEvaluationPrecision P) (longEvaluationPrecision_pos P))
    M.endpointProjection (fun y:Y=>M.normalizedEndpoint y) (fun y:Y=>f y)
    hA hscale (fun y=>M.normalizedEndpoint_norm hinit y) hAR hD
    (by simpa only [Fintype.card_coe] using hY.trans (hmono b (by dsimp [l,longClassifierCommonExponent];omega)))
    hQ hN longCompiledPrefixResourceExponent hCsize
  have hd0:((M.representativeClassifier T hT Y).depth:ℝ)≤
      ((M.precisePrefix T hT (longEvaluationPrecision P) (longEvaluationPrecision_pos P)).depth:ℝ)+16:=by
    exact_mod_cast representativeClassifierAfter_depth
      (M.precisePrefix T hT (longEvaluationPrecision P) (longEvaluationPrecision_pos P))
      M.endpointProjection (fun y:Y=>M.normalizedEndpoint y) (fun y:Y=>f y)
      (1+‖P.readout‖*physicalGainProduct P H)
  refine ⟨?_,?_⟩
  · exact hs.trans_eq (pow_mul R l (longCompiledPrefixResourceExponent+14*distanceClassifierResourceExponent+1)).symm
  · have hl:0≤Real.log R:=Real.log_nonneg (by linarith)
    have hh:=hpre.2.1
    unfold longPrefixDepthCoefficient at hh
    unfold longClassifierDepthCoefficient
    nlinarith

#print axioms representativeClassifier_resources
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
