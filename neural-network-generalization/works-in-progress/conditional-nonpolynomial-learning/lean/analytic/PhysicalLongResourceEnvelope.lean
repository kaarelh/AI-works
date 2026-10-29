import PhysicalLongGeometricResources
import PhysicalLongEvaluationResources
import PhysicalGainPrefixGridSystem

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort

def longPrefixResourceCoefficient (C : ℝ) (a : ℕ) : ℝ :=
  3*C+longEvaluationLogCoefficient C (a*11)+1
def longPrefixResourceExponent (C : ℝ) (a : ℕ) : ℕ :=
  192*a+longRoundingResourceExponent C (a*11)+
    ⌈longPrefixResourceCoefficient C a*(1+1/Real.log 2)⌉₊+3

lemma longPrefixResourceCoefficient_nonneg {C : ℝ} (hC : 0≤C) (a : ℕ) :
    0≤longPrefixResourceCoefficient C a := by
  have hi := longEvaluationLogCoefficient_nonneg hC (a*11)
  unfold longPrefixResourceCoefficient
  positivity

namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

lemma gridSystem_totalBound (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1) :
    (M.gridSystem T hT).totalBound=3*M.nonlinearBudget := by
  unfold VolterraGridSystem.totalBound gridSystem
  simp only
  rw [←Finset.mul_sum,Fin.sum_univ_eq_sum_range (fun j=>M.nonlinearGain j),Finset.sum_range_succ]
  have hz : M.nonlinearGain J=0 := by simp [nonlinearGain]
  rw [hz,add_zero]
  rfl

/-- Actual anchor dimensions, clipping floors, Picard precision and retained
input/state grids admit a common polynomial resource scale. The only analytic
bounds assumed here are the explicit gain/readout and prefix occupation
estimates supplied by the long-prefix argument. -/
theorem long_prefix_resource_envelope (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    {R C : ℝ} (hR : 2≤R) (hC : 0≤C) (a : ℕ) (ha : 1≤a)
    (hH : (H:ℝ)+1≤R^a) (hd : (d:ℝ)+1≤R^a)
    (hr : ‖P.readout‖≤R^a) (hG : physicalGainProduct P H≤R^a)
    (hcard : (S.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P (longCompressionPrecision P))+
      ‖P.readout‖^2/((1:ℝ)/32)^2)
    (hdim : ∀j≤H,(states j).dimension≤d+1+j*(S.card+1))
    (hfloor : ∀j:Fin J,(M.radius j)⁻¹≤((H:ℝ)+1)*(physicalPartialGainBound P+1))
    (hΛ : M.nonlinearBudget≤C*(1+Real.log R)) :
    M.PrimitiveResources (R^(longPrefixResourceExponent C a))
      (longEvaluationRounding M.nonlinearBudget (longEvaluationPrecision P)) ∧
      (Fintype.card (M.gridSystem T hT).InputIndex:ℝ)≤R^(longPrefixResourceExponent C a) ∧
      (Fintype.card (M.gridSystem T hT).StateIndex:ℝ)≤R^(longPrefixResourceExponent C a) ∧
      ((J+1:ℕ):ℝ)≤R^(longPrefixResourceExponent C a) ∧
      (M.gridSystem T hT).totalBound≤R^(longPrefixResourceExponent C a) ∧
      (longEvaluationIterations M.nonlinearBudget (longEvaluationPrecision P):ℝ)≤R^(longPrefixResourceExponent C a) := by
  let c:=⌈longPrefixResourceCoefficient C a*(1+1/Real.log 2)⌉₊
  have hRa : R≤R^a := by simpa only [pow_one] using resource_pow_mono hR ha
  have hWa : 2≤R^a := hR.trans hRa
  have hg := long_prefix_geometric_resources M hWa hH hd hr hG hcard hdim hfloor
  simp only [←pow_mul] at hg
  have hξ := (long_precision_primitive_resources P hWa hH hr hG).2.2.1
  rw [←pow_mul] at hξ
  have he := longEvaluation_resources M.nonlinearBudget_nonneg (longEvaluationPrecision_pos P)
    hC hR (a*11) hΛ hξ
  have hcoeff := resource_constant (longPrefixResourceCoefficient_nonneg hC a) hR
  change longPrefixResourceCoefficient C a≤R^c at hcoeff
  have hthreeC : 3*C≤R^c :=
    (show 3*C≤longPrefixResourceCoefficient C a by
      unfold longPrefixResourceCoefficient;linarith [longEvaluationLogCoefficient_nonneg hC (a*11)]).trans hcoeff
  have hiterC : longEvaluationLogCoefficient C (a*11)≤R^c :=
    (show longEvaluationLogCoefficient C (a*11)≤longPrefixResourceCoefficient C a by
      unfold longPrefixResourceCoefficient;linarith).trans hcoeff
  have hlog : 1+Real.log R≤R := by linarith [Real.log_le_sub_one_of_pos (show 0<R by linarith)]
  have htotal : (M.gridSystem T hT).totalBound≤R^(c+1) := by
    rw [M.gridSystem_totalBound]
    have hh := mul_le_mul_of_nonneg_left hΛ (by norm_num : (0:ℝ)≤3)
    have hl := mul_le_mul_of_nonneg_left hlog (show 0≤3*C by positivity)
    apply le_trans (show 3*M.nonlinearBudget≤(3*C)*R by nlinarith [hh,hl])
    exact resource_mul hR hthreeC (b:=1) (by simpa only [pow_one] using le_refl R) (by linarith)
  have hk : (longEvaluationIterations M.nonlinearBudget (longEvaluationPrecision P):ℝ)≤R^(c+1) :=
    he.1.trans ((mul_le_mul_of_nonneg_left hlog (longEvaluationLogCoefficient_nonneg hC (a*11))).trans
      (resource_mul hR hiterC (b:=1) (by simpa only [pow_one] using le_refl R) (by linarith)))
  have hmono (n : ℕ) (hn : n≤longPrefixResourceExponent C a) : R^n≤R^(longPrefixResourceExponent C a) :=
    resource_pow_mono hR hn
  have htime : ((J+1:ℕ):ℝ)≤R^a := by
    have hj : (J:ℝ)≤H := by exact_mod_cast M.length_le
    push_cast
    linarith
  refine ⟨⟨?_,hg.2.1.trans (hmono _ ?_),hg.1.trans (hmono _ ?_),
    fun j=>(hg.2.2.2.2 j).trans (hmono _ ?_),he.2.trans (hmono _ ?_)⟩,
    hg.2.2.2.1.trans (hmono _ ?_),hg.2.2.1.trans (hmono _ ?_),htime.trans (hmono _ ?_),
    htotal.trans (hmono _ ?_),hk.trans (hmono _ ?_)⟩
  · exact hR.trans (by simpa only [pow_one] using hmono 1 (by unfold longPrefixResourceExponent;omega))
  all_goals dsimp [longPrefixResourceExponent,c] <;> omega

#print axioms long_prefix_resource_envelope
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
