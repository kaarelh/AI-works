import NeuralGeneralization.BatchTwoContinuousDepthSmoothDensity
import Mathlib.MeasureTheory.Function.JacobianOneDim
import Mathlib.Analysis.SpecialFunctions.Trigonometric.InverseDeriv

/-! Circle arclength is constructed by its two unit-speed angular charts.
A proved change-of-variables identity gives the Cartesian graph-chart formula. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set MeasureTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open BatchTwoContinuous

def signedCircleAngle (ε θ : ℝ) : RealInput 2 := ![Real.sin θ, ε*Real.cos θ]
def signedCircleArc (ε t : ℝ) : RealInput 2 := ![t, ε*Real.sqrt (1-t^2)]
def circleArcSpeed (t : ℝ) : ℝ := 1/Real.sqrt (1-t^2)

theorem signedCircleAngle_continuous (ε : ℝ) : Continuous (signedCircleAngle ε) := by
  apply continuous_pi
  intro i
  fin_cases i <;> simp only [signedCircleAngle, Matrix.cons_val_zero, Matrix.cons_val_one] <;> fun_prop

theorem signedCircleArc_continuous (ε : ℝ) : Continuous (signedCircleArc ε) := by
  apply continuous_pi
  intro i
  fin_cases i <;> simp only [signedCircleArc, Matrix.cons_val_zero, Matrix.cons_val_one] <;> fun_prop

theorem signedCircleAngle_derivative (ε θ : ℝ) :
    HasDerivAt (signedCircleAngle ε) ![Real.cos θ, -ε*Real.sin θ] θ := by
  apply hasDerivAt_pi.mpr
  intro i
  fin_cases i
  · convert! Real.hasDerivAt_sin θ using 1 <;> simp [signedCircleAngle]
  · convert! (Real.hasDerivAt_cos θ).const_mul ε using 1 <;> simp [signedCircleAngle]

/-- Both angular charts have Euclidean speed exactly one. -/
theorem signedCircleAngle_unit_speed {ε : ℝ} (hε : ε^2=1) (θ : ℝ) :
    Real.sqrt (∑ i : Fin 2, (![Real.cos θ, -ε*Real.sin θ] i)^2) = 1 := by
  simp only [Fin.sum_univ_succ, Matrix.cons_val_zero, Matrix.cons_val_succ,
    Fin.sum_univ_zero, add_zero, mul_pow, neg_pow_two, hε, one_mul]
  rw [Real.cos_sq_add_sin_sq, Real.sqrt_one]

theorem signedCircleAngle_on_sphere {ε : ℝ} (hε : ε^2=1) (θ : ℝ) :
    ∑ i : Fin 2, signedCircleAngle ε θ i^2 = 1 := by
  simp only [signedCircleAngle, Fin.sum_univ_succ, Matrix.cons_val_zero, Matrix.cons_val_succ,
    Fin.sum_univ_zero, add_zero, mul_pow, hε, one_mul]
  exact Real.sin_sq_add_cos_sq θ

def angularArcLength (ε : ℝ) : Measure (RealInput 2) :=
  (volume.restrict (Ioo (-(Real.pi/2)) (Real.pi/2))).map (signedCircleAngle ε)

/-- The two disjoint open semicircles, parametrized at unit speed. Their two
omitted endpoints have zero arclength. This is unnormalized circle arclength. -/
def circleArcLength : Measure (RealInput 2) := angularArcLength 1 + angularArcLength (-1)

instance angularArcLength_finite (ε : ℝ) : IsFiniteMeasure (angularArcLength ε) := by
  unfold angularArcLength
  infer_instance
instance circleArcLength_finite : IsFiniteMeasure circleArcLength := by
  unfold circleArcLength
  infer_instance

theorem angularArcLength_total (ε : ℝ) : angularArcLength ε univ = ENNReal.ofReal Real.pi := by
  rw [angularArcLength, Measure.map_apply (signedCircleAngle_continuous ε).measurable MeasurableSet.univ]
  simp [Real.volume_Ioo, show Real.pi/2- -(Real.pi/2)=Real.pi by ring]

theorem circleArcLength_total : circleArcLength univ = ENNReal.ofReal (2*Real.pi) := by
  rw [circleArcLength, Measure.add_apply, angularArcLength_total, angularArcLength_total,
    ← ENNReal.ofReal_add Real.pi_pos.le Real.pi_pos.le]
  congr 1
  ring

theorem arcsin_image_open_interval :
    Real.arcsin '' Ioo (-1 : ℝ) 1 = Ioo (-(Real.pi/2)) (Real.pi/2) := by
  simpa using Real.sinPartialHomeomorph.symm.image_source_eq_target

theorem signedCircleAngle_arcsin (ε : ℝ) {t : ℝ} (ht : t ∈ Ioo (-1 : ℝ) 1) :
    signedCircleAngle ε (Real.arcsin t) = signedCircleArc ε t := by
  simp only [signedCircleAngle, signedCircleArc, Real.sin_arcsin ht.1.le ht.2.le, Real.cos_arcsin]

theorem circleArcSpeed_nonneg (t : ℝ) : 0 ≤ circleArcSpeed t := by unfold circleArcSpeed; positivity

theorem circleArcSpeed_measurable : Measurable circleArcSpeed := by unfold circleArcSpeed; fun_prop

/-- The graph-chart arclength factor is derived from the unit-speed angular law. -/
theorem angularArcLength_graph (ε : ℝ) : angularArcLength ε =
    ((volume.restrict (Ioo (-1 : ℝ) 1)).withDensity
      (fun t => ENNReal.ofReal (circleArcSpeed t))).map (signedCircleArc ε) := by
  apply Measure.ext_of_lintegral
  intro f hf
  rw [angularArcLength, lintegral_map hf (signedCircleAngle_continuous ε).measurable,
    lintegral_map hf (signedCircleArc_continuous ε).measurable,
    lintegral_withDensity_eq_lintegral_mul _ circleArcSpeed_measurable.ennreal_ofReal
      (show Measurable (fun t => f (signedCircleArc ε t)) from
        hf.comp (signedCircleArc_continuous ε).measurable)]
  rw [← arcsin_image_open_interval]
  have he := lintegral_image_eq_lintegral_abs_deriv_mul (s := Ioo (-1 : ℝ) 1)
    measurableSet_Ioo
    (fun t ht => (Real.hasDerivAt_arcsin ht.1.ne' ht.2.ne).hasDerivWithinAt)
    (Real.injOn_arcsin.mono Ioo_subset_Icc_self) (fun θ => f (signedCircleAngle ε θ))
  rw [he]
  apply setLIntegral_congr_fun measurableSet_Ioo
  intro t ht
  change ENNReal.ofReal |circleArcSpeed t| * f (signedCircleAngle ε (Real.arcsin t)) =
    ENNReal.ofReal (circleArcSpeed t) * f (signedCircleArc ε t)
  rw [signedCircleAngle_arcsin ε ht, abs_of_nonneg (circleArcSpeed_nonneg t)]


/-- Each angular parametrization traverses its open semicircle exactly once. -/
theorem signedCircleAngle_injective (ε : ℝ) :
    InjOn (signedCircleAngle ε) (Ioo (-(Real.pi/2)) (Real.pi/2)) := by
  intro θ hθ η hη he
  apply Real.injOn_sin ⟨hθ.1.le,hθ.2.le⟩ ⟨hη.1.le,hη.2.le⟩
  exact congrFun he 0

theorem signedCircleAngle_second_sign {ε θ : ℝ} (hε : ε^2=1)
    (hθ : θ ∈ Ioo (-(Real.pi/2)) (Real.pi/2)) :
    0 < ε * signedCircleAngle ε θ 1 := by
  have hc : 0 < Real.cos θ := Real.cos_pos_of_mem_Ioo hθ
  change 0 < ε*(ε*Real.cos θ)
  rw [← mul_assoc, ← pow_two, hε, one_mul]
  exact hc

/-- The charts cover the whole unit circle except its two horizontal endpoints. -/
theorem circleAngle_covers (x : RealInput 2) (hx : ∑ i, x i^2=1) (hn : x 1≠0) :
    ∃ ε : ℝ, (ε=1 ∨ ε= -1) ∧ ∃ θ ∈ Ioo (-(Real.pi/2)) (Real.pi/2),
      signedCircleAngle ε θ = x := by
  have he : x 0^2+x 1^2=1 := by simpa [Fin.sum_univ_two] using hx
  have ht : x 0 ∈ Ioo (-1 : ℝ) 1 := by
    constructor <;> nlinarith [sq_pos_of_ne_zero hn]
  have hθ : Real.arcsin (x 0) ∈ Ioo (-(Real.pi/2)) (Real.pi/2) :=
    ⟨Real.neg_pi_div_two_lt_arcsin.mpr ht.1, Real.arcsin_lt_pi_div_two.mpr ht.2⟩
  have hs : Real.sqrt (1-x 0^2)=|x 1| := by
    rw [show 1-x 0^2=x 1^2 by linarith, Real.sqrt_sq_eq_abs]
  by_cases hp : 0 ≤ x 1
  · refine ⟨1,Or.inl rfl,Real.arcsin (x 0),hθ,?_⟩
    rw [signedCircleAngle_arcsin 1 ht]
    ext i
    fin_cases i <;> simp [signedCircleArc, hs, abs_of_nonneg hp]
  · refine ⟨-1,Or.inr rfl,Real.arcsin (x 0),hθ,?_⟩
    rw [signedCircleAngle_arcsin (-1) ht]
    ext i
    fin_cases i <;> simp [signedCircleArc, hs, abs_of_nonpos (le_of_not_ge hp)]

theorem circleAngle_images_disjoint :
    Disjoint (signedCircleAngle 1 '' Ioo (-(Real.pi/2)) (Real.pi/2))
      (signedCircleAngle (-1) '' Ioo (-(Real.pi/2)) (Real.pi/2)) := by
  apply disjoint_left.mpr
  rintro x ⟨θ,hθ,rfl⟩ ⟨η,hη,he⟩
  have hp := signedCircleAngle_second_sign (by norm_num : (1 : ℝ)^2=1) hθ
  have hn := signedCircleAngle_second_sign (by norm_num : (-1 : ℝ)^2=1) hη
  rw [he] at hn
  norm_num only [one_mul,neg_one_mul] at hp hn
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthLower
