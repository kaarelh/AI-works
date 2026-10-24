import NeuralGeneralization.BatchTwoContinuousDepthLaw
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-! The fixed nonatomic input distribution on the unit circle, and its
literal paired-input obstruction for arbitrary posterior mixtures. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set Filter MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal ENNReal Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open BatchTwoContinuous

def sphereArc (t : ℝ) : RealInput 2 := ![t, Real.sqrt (1-t^2)]

theorem sphereArc_continuous : Continuous sphereArc := by
  apply continuous_pi
  intro i
  fin_cases i <;> simp only [sphereArc,Matrix.cons_val_zero,Matrix.cons_val_one]
  · fun_prop
  · fun_prop

theorem sphereArc_on_sphere {t : ℝ} (ht : |t|≤1) : ∑ i, sphereArc t i^2 = 1 := by
  have hp : 0≤1-t^2 := by nlinarith [sq_abs t,abs_nonneg t]
  simp only [Fin.sum_univ_succ,sphereArc,Matrix.cons_val_zero,Matrix.cons_val_succ,
    Fin.sum_univ_zero,add_zero,Real.sq_sqrt hp]
  ring

def inputDistance (x y : RealInput 2) : ℝ := Real.sqrt (∑ i, (x i-y i)^2)

theorem sphereArc_distance {s t : ℝ} (hs : |s|≤3/4) (ht : |t|≤3/4) :
    inputDistance (sphereArc s) (sphereArc t) ≤ 2*|s-t| := by
  have hs2 : s^2≤9/16 := by nlinarith [sq_abs s,abs_nonneg s]
  have ht2 : t^2≤9/16 := by nlinarith [sq_abs t,abs_nonneg t]
  have hsp : 0≤1-s^2 := by linarith
  have htp : 0≤1-t^2 := by linarith
  have hsq1 := Real.sq_sqrt hsp
  have hsq2 := Real.sq_sqrt htp
  have hsqrt1 := Real.sqrt_nonneg (1-s^2)
  have hsqrt2 := Real.sqrt_nonneg (1-t^2)
  have hhalf1 : 1/2≤Real.sqrt (1-s^2) := by nlinarith
  have hhalf2 : 1/2≤Real.sqrt (1-t^2) := by nlinarith
  have he : (Real.sqrt (1-s^2)-Real.sqrt (1-t^2))*
      (Real.sqrt (1-s^2)+Real.sqrt (1-t^2)) = (t-s)*(t+s) := by nlinarith
  have heabs := congrArg abs he
  rw [abs_mul,abs_mul,abs_of_nonneg (add_nonneg hsqrt1 hsqrt2),abs_sub_comm t s] at heabs
  have hsum : |t+s|≤3/2 := (abs_add_le t s).trans (by linarith)
  have hb : |Real.sqrt (1-s^2)-Real.sqrt (1-t^2)| ≤ (3/2)*|s-t| := by
    nlinarith [abs_nonneg (Real.sqrt (1-s^2)-Real.sqrt (1-t^2)),abs_nonneg (s-t),
      mul_le_mul_of_nonneg_left hsum (abs_nonneg (s-t))]
  have hbsq := (sq_le_sq₀ (abs_nonneg _) (by positivity)).mpr hb
  rw [sq_abs] at hbsq
  unfold inputDistance
  apply Real.sqrt_le_iff.mpr
  constructor
  · positivity
  · simp only [Fin.sum_univ_succ,sphereArc,Matrix.cons_val_zero,Matrix.cons_val_succ,
      Fin.sum_univ_zero,add_zero]
    nlinarith [sq_abs (s-t),sq_nonneg (s-t)]

def sphereCoding (ω : SignStream) : RealInput 2 := sphereArc (scalarCoding ω)

theorem sphereCoding_measurable : Measurable sphereCoding :=
  sphereArc_continuous.measurable.comp scalarCoding_measurable

def inputLaw : Measure (RealInput 2) := signLaw.map sphereCoding
instance inputLaw_probability : IsProbabilityMeasure inputLaw :=
  Measure.isProbabilityMeasure_map sphereCoding_measurable.aemeasurable

theorem sphereCoding_injective : Function.Injective sphereCoding := by
  intro ω η he
  apply scalarCoding_injective
  exact congrFun he 0

instance inputLaw_nullSingleton : NullSingletonClass inputLaw := by
  constructor
  intro x
  rw [inputLaw,Measure.map_apply sphereCoding_measurable (measurableSet_singleton _)]
  exact (subsingleton_singleton.preimage sphereCoding_injective).measure_zero signLaw

theorem inputLaw_sphere : inputLaw {x | ∑ i, x i^2 = 1}=1 := by
  rw [inputLaw,Measure.map_apply sphereCoding_measurable (measurableSet_eq_fun (by fun_prop) measurable_const)]
  have he : sphereCoding ⁻¹' {x | ∑ i, x i^2 = 1}=univ := by
    ext ω
    simp only [mem_preimage,mem_setOf_eq,mem_univ,iff_true]
    exact sphereArc_on_sphere ((coding_range ω).2.trans (by norm_num))
  rw [he,measure_univ]

def depthTarget (r : ℕ) (x : RealInput 2) : ℝ := expandingMap^[r] (x 0)

theorem depthTarget_coded_bound (r : ℕ) (ω : SignStream) :
    |depthTarget r (sphereCoding ω)| ≤ 13/20 := by
  change |expandingMap^[r] (coding ω)|≤13/20
  rw [expandingMap_iterate_coding]
  exact (coding_range _).2

theorem depthTarget_ae_bound (r : ℕ) : ∀ᵐ x ∂inputLaw, |depthTarget r x|≤13/20 := by
  unfold depthTarget
  rw [inputLaw,ae_map_iff sphereCoding_measurable.aemeasurable
    (measurableSet_le (continuous_target r).measurable.abs measurable_const)]
  exact Filter.Eventually.of_forall (depthTarget_coded_bound r)

theorem sphereCoding_flip_law (r : ℕ) : signLaw.map (sphereCoding ∘ flipCoordinate r)=inputLaw := by
  rw [← Measure.map_map sphereCoding_measurable (flipCoordinate_measurable r),signLaw_flip]
  rfl

theorem inputLaw_balanced_pair (r : ℕ) :
    balancedPairLaw signLaw sphereCoding (sphereCoding ∘ flipCoordinate r)=inputLaw := by
  rw [balancedPairLaw,sphereCoding_flip_law]
  change (1/2 : ℝ≥0) • inputLaw+(1/2 : ℝ≥0) • inputLaw = inputLaw
  rw [← add_smul]
  norm_num

theorem sphereCoding_pair_distance (r : ℕ) (ω : SignStream) :
    inputDistance (sphereCoding ω) (sphereCoding (flipCoordinate r ω)) ≤ (13/5 : ℝ)*(1/3)^r := by
  have h := sphereArc_distance ((coding_range ω).2.trans (by norm_num))
    ((coding_range (flipCoordinate r ω)).2.trans (by norm_num))
  have hp := scalarCoding_pair_distance r ω
  dsimp [scalarCoding] at hp
  exact h.trans (by nlinarith)

theorem sphereCoding_pair_target_gap (r : ℕ) (ω : SignStream) :
    1 ≤ |depthTarget r (sphereCoding ω)-depthTarget r (sphereCoding (flipCoordinate r ω))| :=
  scalarCoding_pair_target_gap r ω

/-- The complete geometric part of the manuscript's mixture barrier. The
remaining posterior work is to prove the stated good-predictor mass and
smoothness premises from the neural prior and sample. -/
theorem inputLaw_mixture_barrier {W : Type*} [MeasurableSpace W]
    (Q : Measure W) [IsProbabilityMeasure Q] (z : W → RealInput 2 → ℝ)
    (hz : ∀ x, Measurable (fun w => z w x)) (r : ℕ) (G : Set W)
    (hbad : Q.real Gᶜ ≤ (1/3 : ℝ))
    (hgood : ∀ w ∈ G, ∃ g : RealInput 2 → ℝ,
      (∀ x, (∑ i, x i^2=1) → |z w x-g x|≤(1/32 : ℝ)) ∧
      (∀ x y, |g x-g y|≤((3:ℝ)^r/10)*inputDistance x y))
    (hq : Measurable (fun x => Q.real {w | |z w x-depthTarget r x|≤(1/4 : ℝ)})) :
    (1/2 : ℝ) ≤ inputLaw.real {x | Q.real {w | |z w x-depthTarget r x|≤(1/4 : ℝ)}≤2/3} := by
  rw [← inputLaw_balanced_pair r]
  apply paired_confidence_failure signLaw sphereCoding (sphereCoding ∘ flipCoordinate r)
    sphereCoding_measurable (sphereCoding_measurable.comp (flipCoordinate_measurable r))
    _ hq (2/3)
  intro ω
  have h := posterior_pair_sum_le Q z hz (depthTarget r) G hbad
    (sphereCoding ω) (sphereCoding (flipCoordinate r ω)) (by
      intro w hw
      obtain ⟨g,hclose,hlip⟩ := hgood w hw
      apply approximate_pair_incompatible (sphereCoding_pair_target_gap r ω)
      · have hscale : ((3:ℝ)^r/10)*((13/5 : ℝ)*(1/3)^r) = 13/50 := by
          have hp : (3:ℝ)^r≠0 := by positivity
          rw [one_div,inv_pow]
          field_simp
          <;> ring
        exact (hlip _ _).trans ((mul_le_mul_of_nonneg_left (sphereCoding_pair_distance r ω)
          (by positivity)).trans_eq hscale)
      · exact hclose _ (sphereArc_on_sphere ((coding_range ω).2.trans (by norm_num)))
      · exact hclose _ (sphereArc_on_sphere ((coding_range (flipCoordinate r ω)).2.trans (by norm_num)))
      · exact le_rfl)
  change _+_≤2*(2/3 : ℝ)
  norm_num only at *
  exact h

end NeuralGeneralization.BatchTwoContinuousDepthLower
