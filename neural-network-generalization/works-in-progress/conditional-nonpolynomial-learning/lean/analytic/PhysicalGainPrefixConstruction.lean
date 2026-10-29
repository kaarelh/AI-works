import PhysicalGainPrefixPicard
import PhysicalFlooredRadiusBudget

noncomputable section
set_option maxHeartbeats 1800000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

def flooredGainPrefix (M : PhysicalShort.FiniteCanonicalDynamics P S states)
    (hd : 1≤d) (hJ : J≤H)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y))
    (hstep : ∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1))) :
    GainPrefixDynamics P S states J where
  model:=M
  length_le:=hJ
  radius:=physicalFlooredRadius P states
  radius_pos:=fun j _=>physicalFlooredRadius_pos P states j
  radius_le:=fun j hj=>(physicalFlooredRadius_le_two P hd S states hzero hstep j
    (le_trans hj.le hJ)).trans (by norm_num)
  contains:=fun j _ x=>physicalFlooredRadius_contains P states j x

lemma flooredGainPrefix_inverse (M : PhysicalShort.FiniteCanonicalDynamics P S states)
    (hd : 1≤d) (hJ : J≤H)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y))
    (hstep : ∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1))) (j : ℕ) :
    ((flooredGainPrefix M hd hJ hzero hstep).radius j)⁻¹≤
      ((H:ℝ)+1)*(physicalPartialGainBound P+1) := physicalFlooredRadius_inverse P states j

/-- All normalized Picard Lipschitz charges are bounded by original physical
prefix quantities; the clipping floor costs at most one before the factor224. -/
theorem flooredGainPrefix_nonlinearBudget (M : PhysicalShort.FiniteCanonicalDynamics P S states)
    (hd : 1≤d) (hJ : J≤H)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y))
    (hstep : ∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1)))
    {ε : ℝ} (hε : 0≤ε)
    (hquery : ∀j<J,∀x,QueryFeatureClose (P.feature j) (states j).feature S x ε) :
    (flooredGainPrefix M hd hJ hzero hstep).nonlinearBudget≤
      224*(2*(∑j∈Finset.range J,physicalMaxVariance P j)+2*(J:ℝ)*ε^2+1+
        Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,physicalLayerCost P j))) := by
  have he : (flooredGainPrefix M hd hJ hzero hstep).nonlinearBudget=
      224*(∑j∈Finset.range J,((t*physicalGainProduct P j*physicalFlooredRadius P states j)^2+
        Real.sqrt (physicalLayerCost P j))) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    simp only [GainPrefixDynamics.nonlinearGain,if_pos (Finset.mem_range.mp hj),
      GainPrefixDynamics.inputScale,flooredGainPrefix]
  rw [he]
  exact mul_le_mul_of_nonneg_left (physical_floored_prefix_budget P S states hJ hε hquery) (by norm_num)

#print axioms flooredGainPrefix_nonlinearBudget
end ConditionalNonpolynomial.Analytic.PhysicalLong
