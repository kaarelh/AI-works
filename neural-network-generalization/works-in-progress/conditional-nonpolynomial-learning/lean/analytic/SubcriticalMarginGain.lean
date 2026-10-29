import SubcriticalMarginAccounting
import TruncatedLastExitInitial

/-! The complete physical path has only logarithmic cumulative gain in the
long nearcritical regime. This uses the literal Boolean initial variance,
not an auxiliary initial state or an assumed gain certificate. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.GaussianFieldTilt
open NeuralGeneralization.NetworkGramBasics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

theorem normalizedInputFeature_norm_sq_ge_one {d : ℕ} (hd : 1≤d) (x : Cube d) :
    1≤‖normalizedInputFeature d x‖^2 := by
  have hdpos : 0<(d:ℝ) := by exact_mod_cast (Nat.zero_lt_of_lt hd)
  rw [EuclideanSpace.norm_sq_eq]
  simp only [normalizedInputFeature,WithLp.ofLp_toLp,Real.norm_eq_abs,sq_abs,div_pow,
    Real.sq_sqrt (Nat.cast_nonneg d),← Finset.sum_div,inputVector_square_sum]
  apply (le_div_iff₀ hdpos).mpr
  simp

theorem controlledMarginPath_initial_ge_one (P : ControlledMarginPath d H t f) (hd : 1≤d) :
    1≤physicalMaxVariance P 0 := by
  unfold physicalMaxVariance maxFeatureVariance
  rw [← real_inner_self_eq_norm_sq,P.initial,real_inner_self_eq_norm_sq]
  exact normalizedInputFeature_norm_sq_ge_one hd _

def physicalActionExcess (P : ControlledMarginPath d H t f) : ℝ :=
  max 0 (P.action-H*subcriticalCostBaseline (physicalVariance P)+
    ((physicalVariance P:ℝ)⁻¹-1)-scalarBaseline.toReal)

theorem physicalActionExcess_nonneg (P : ControlledMarginPath d H t f) :
    0≤physicalActionExcess P := le_max_left _ _

theorem physical_adjusted_action_excess (P : ControlledMarginPath d H t f) (hd : 1≤d) :
    (∑j∈Finset.range H,physicalAdjustedCost P j)+‖P.readout‖^2/2≤
      scalarBaseline.toReal+physicalActionExcess P := by
  have hb := physical_adjusted_action_bound P hd
  have he : P.action-H*subcriticalCostBaseline (physicalVariance P)+
      ((physicalVariance P:ℝ)⁻¹-1)-scalarBaseline.toReal≤physicalActionExcess P := le_max_right _ _
  linarith

/-- Full physical gain bound for every a=t⁻²−1>0. For 0<a≤1 the
dyadic estimate is needed; for a≥1 the tangent estimate alone is stronger.
The first input layer incurs no additional loss. -/
theorem physicalPathLogGain_bound (P : ControlledMarginPath d H t f)
    (hd : 1≤d) (hH : 1≤H) (J : ℕ) {ε : ℝ} (hε : 0≤ε)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1)
    (hreach : 1≤(2:ℝ)^J*((physicalVariance P:ℝ)⁻¹-1))
    (hnear : (∑j∈Finset.range H,physicalAdjustedCost P j)+‖P.readout‖^2/2≤
      scalarBaseline.toReal+ε) :
    (∑j∈Finset.range H,physicalPathLogGain P j)≤
      ε/((physicalVariance P:ℝ)⁻¹-1)+526336+
      2*lastExitLinearConstant*(1052673*(J:ℝ)+2*ε/((physicalVariance P:ℝ)⁻¹-1)) := by
  let a : ℝ := (physicalVariance P:ℝ)⁻¹-1
  let q := physicalMaxVariance P
  let e := physicalAdjustedCost P
  let g := physicalPathLogGain P
  have hq := controlledMarginPath_variance_positive P
  have hq1 := controlledMarginPath_variance_le_one P
  have he : ∀j<H,0≤e j := fun j hj => (controlledMarginPath_adjusted_step P j hj).1
  have hgain : ∀j<H,g j≤2*Real.sqrt (e j) :=
    fun j hj => (controlledMarginPath_adjusted_step P j hj).2.2.1
  have htangent : ∀j<H,g j≤(Real.log (q (j+1))-Real.log (q j))/2+e j/a := by
    intro j hj
    have hh := (controlledMarginPath_adjusted_step P j hj).2.2.2 ha
    rw [Real.log_div (hq (j+1) (by omega)).ne' (hq j (by omega)).ne'] at hh
    exact hh
  have hprefix := physical_adjusted_prefix_bound P hnear
  have hq0 : 0≤Real.log (q 0) := Real.log_nonneg (controlledMarginPath_initial_ge_one P hd)
  by_cases ha1 : a≤1
  · have hdri : ∀j<H,1≤j → q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate := by
      intro j hj hpos
      have hh := controlledMarginPath_adjusted_drift P j hj hpos
      have hh' : q (j+1)-q j+driftDissipation*(q j)^2≤e j/driftRate :=
        (le_div_iff₀ driftRate_pos).mpr (by simpa only [mul_comm] using hh)
      linarith only [hh']
    have hb := truncated_lastExit_gain_after_first H J q e g hH hε (by norm_num : (0:ℝ)≤526336)
      ha hreach hq hq1 he hdri hprefix hgain htangent
    have hlog : Real.log a≤0 := Real.log_nonpos ha.le ha1
    have hm : max 0 ((Real.log a-Real.log (q 0))/2)=0 := max_eq_left (by linarith)
    rw [hm] at hb
    norm_num only [zero_add] at hb
    norm_num only [show (1:ℝ)+2*526336=1052673 by norm_num] at hb
    exact hb
  · have ht := tangent_gain_prefix H q e g a htangent
    have hp := hprefix H le_rfl
    have hterm : q H≤1 := hq1 H le_rfl hH
    have hlog : Real.log (q H)≤0 := Real.log_nonpos (hq H le_rfl).le hterm
    have hcost : (∑j∈Finset.range H,e j)/a≤ε/a+526336 := by
      apply (div_le_iff₀ ha).mpr
      have hai : 1≤a := le_of_not_ge ha1
      have heq : (ε/a+526336)*a=ε+526336*a := by field_simp [ha.ne']
      rw [heq]
      linarith
    have hb : (∑j∈Finset.range H,g j)≤ε/a+526336 := by linarith
    have hnon : 0≤2*lastExitLinearConstant*(1052673*(J:ℝ)+2*ε/a) := by
      exact mul_nonneg (mul_nonneg (by norm_num) lastExitLinearConstant_nonneg) (by positivity)
    change (∑j∈Finset.range H,g j)≤ε/a+526336+_
    linarith

#print axioms physicalPathLogGain_bound
end ConditionalNonpolynomial.Analytic
