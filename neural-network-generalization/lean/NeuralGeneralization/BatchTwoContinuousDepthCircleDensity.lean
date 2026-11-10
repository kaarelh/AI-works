import NeuralGeneralization.BatchTwoContinuousDepthArcLength

/-! A globally smooth ambient density whose restriction to the circle is the
Radon--Nikodym density of the jittered law with respect to genuine arclength. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set Filter MeasureTheory
open scoped BigOperators ENNReal ContDiff
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open BatchTwoContinuous

def upperArcSelector : ContDiffBump (1 : ℝ) := ⟨1/4, 1/2, by norm_num, by norm_num⟩

def circleDensity (r : ℕ) (x : RealInput 2) : ℝ :=
  smoothedScalarDensity r (x 0) * x 1 * upperArcSelector (x 1)

theorem circleDensity_contDiff (r : ℕ) : ContDiff ℝ ∞ (circleDensity r) := by
  have hg := smoothedScalarDensity_contDiff r
  have hs : ContDiff ℝ ∞ upperArcSelector := upperArcSelector.contDiff
  unfold circleDensity
  fun_prop

theorem upperArcSelector_zero {y : ℝ} (hy : y ≤ 0) : upperArcSelector y = 0 := by
  apply upperArcSelector.zero_of_le_dist
  change (1/2 : ℝ) ≤ |y-1|
  rw [abs_of_nonpos (by linarith)]
  linarith

theorem circleDensity_nonneg (r : ℕ) (x : RealInput 2) : 0 ≤ circleDensity r x := by
  by_cases hx : 0 ≤ x 1
  · exact mul_nonneg (mul_nonneg (smoothedScalarDensity_nonneg r _) hx) upperArcSelector.nonneg
  · unfold circleDensity
    rw [upperArcSelector_zero (le_of_not_ge hx), mul_zero]

theorem circleDensity_upper (r : ℕ) (t : ℝ) :
    circleDensity r (signedCircleArc 1 t) = smoothedScalarDensity r t * Real.sqrt (1-t^2) := by
  simp only [circleDensity, signedCircleArc, Matrix.cons_val_zero, Matrix.cons_val_one, one_mul]
  by_cases hg : smoothedScalarDensity r t = 0
  · simp [hg]
  have ht : |t| ≤ (13/20 : ℝ) := by
    by_contra hh
    exact hg (smoothedScalarDensity_zero r (lt_of_not_ge hh))
  have ht2 : t^2 ≤ (169/400 : ℝ) := by nlinarith [sq_abs t, abs_nonneg t]
  have hp : 0 ≤ 1-t^2 := by linarith
  have hs := Real.sq_sqrt hp
  have hs0 := Real.sqrt_nonneg (1-t^2)
  have hlo : (3/4 : ℝ) ≤ Real.sqrt (1-t^2) := by nlinarith
  have hhi : Real.sqrt (1-t^2) ≤ 1 := by nlinarith [sq_nonneg t]
  have hsel : upperArcSelector (Real.sqrt (1-t^2)) = 1 := by
    apply upperArcSelector.one_of_mem_closedBall
    change |Real.sqrt (1-t^2)-1| ≤ (1/4 : ℝ)
    rw [abs_le]
    constructor <;> linarith
  rw [hsel, mul_one]

theorem circleDensity_lower (r : ℕ) (t : ℝ) : circleDensity r (signedCircleArc (-1) t) = 0 := by
  simp only [circleDensity, signedCircleArc, Matrix.cons_val_zero, Matrix.cons_val_one, neg_one_mul]
  rw [upperArcSelector_zero (neg_nonpos.mpr (Real.sqrt_nonneg _)), mul_zero]

theorem circleDensity_speed (r : ℕ) {t : ℝ} (ht : t ∈ Ioo (-1 : ℝ) 1) :
    ENNReal.ofReal (circleArcSpeed t) * ENNReal.ofReal (circleDensity r (signedCircleArc 1 t)) =
      ENNReal.ofReal (smoothedScalarDensity r t) := by
  rw [← ENNReal.ofReal_mul (circleArcSpeed_nonneg t), circleDensity_upper]
  congr 1
  have hp : 0 < 1-t^2 := by nlinarith [ht.1,ht.2]
  have hs := (Real.sqrt_pos.mpr hp).ne'
  unfold circleArcSpeed
  field_simp

/-- The compact scalar density has no mass outside the graph chart. -/
theorem smoothedScalarDensity_restrict (r : ℕ) :
    (volume.restrict (Ioo (-1 : ℝ) 1)).withDensity
      (fun t => ENNReal.ofReal (smoothedScalarDensity r t)) =
    volume.withDensity (fun t => ENNReal.ofReal (smoothedScalarDensity r t)) := by
  rw [← restrict_withDensity measurableSet_Ioo]
  apply Measure.restrict_eq_self_of_ae_mem
  rw [ae_withDensity_iff (smoothedScalarDensity_contDiff r).continuous.measurable.ennreal_ofReal]
  apply Eventually.of_forall
  intro t ht
  have hg : smoothedScalarDensity r t ≠ 0 := fun h => ht (by rw [h]; simp)
  have hb : |t| ≤ (13/20 : ℝ) := by
    by_contra hh
    exact hg (smoothedScalarDensity_zero r (lt_of_not_ge hh))
  have hab := abs_le.mp hb
  exact ⟨by linarith [hab.1], by linarith [hab.2]⟩

theorem angularArcLength_density_integral (r : ℕ) (ε : ℝ)
    (f : RealInput 2 → ℝ≥0∞) (hf : Measurable f) :
    ∫⁻ x, f x ∂(angularArcLength ε).withDensity (fun x => ENNReal.ofReal (circleDensity r x)) =
      ∫⁻ t in Ioo (-1 : ℝ) 1, ENNReal.ofReal (circleArcSpeed t) *
        (ENNReal.ofReal (circleDensity r (signedCircleArc ε t)) * f (signedCircleArc ε t)) := by
  have hρ := (circleDensity_contDiff r).continuous.measurable.ennreal_ofReal
  rw [lintegral_withDensity_eq_lintegral_mul _ hρ hf, angularArcLength_graph,
    lintegral_map (hρ.mul hf) (signedCircleArc_continuous ε).measurable]
  simp only [Pi.mul_apply]
  rw [lintegral_withDensity_eq_lintegral_mul _ circleArcSpeed_measurable.ennreal_ofReal
      (show Measurable (fun t => ENNReal.ofReal (circleDensity r (signedCircleArc ε t)) *
          f (signedCircleArc ε t)) from (hρ.mul hf).comp (signedCircleArc_continuous ε).measurable)]
  rfl

theorem upper_arclength_density (r : ℕ) :
    (angularArcLength 1).withDensity (fun x => ENNReal.ofReal (circleDensity r x)) = smoothInputLaw r := by
  apply Measure.ext_of_lintegral
  intro f hf
  rw [angularArcLength_density_integral r 1 f hf, smoothInputLaw_density_pushforward,
    ← smoothedScalarDensity_restrict,
    lintegral_map hf sphereArc_continuous.measurable,
    lintegral_withDensity_eq_lintegral_mul _
      (smoothedScalarDensity_contDiff r).continuous.measurable.ennreal_ofReal
      (show Measurable (fun t => f (sphereArc t)) from hf.comp sphereArc_continuous.measurable)]
  apply setLIntegral_congr_fun measurableSet_Ioo
  intro t ht
  change ENNReal.ofReal (circleArcSpeed t) *
    (ENNReal.ofReal (circleDensity r (signedCircleArc 1 t)) * f (signedCircleArc 1 t)) =
    ENNReal.ofReal (smoothedScalarDensity r t) * f (sphereArc t)
  rw [← mul_assoc, circleDensity_speed r ht]
  congr 1
  simp only [signedCircleArc, sphereArc, one_mul]

theorem lower_arclength_density (r : ℕ) :
    (angularArcLength (-1)).withDensity (fun x => ENNReal.ofReal (circleDensity r x)) = 0 := by
  apply Measure.ext_of_lintegral
  intro f hf
  rw [angularArcLength_density_integral r (-1) f hf]
  simp only [circleDensity_lower, ENNReal.ofReal_zero, zero_mul, mul_zero, lintegral_zero,
    lintegral_zero_measure]

/-- The smooth-distribution claim uses the actual circle arclength measure,
and its density extends to a C-infinity function on the ambient plane. -/
theorem smoothInputLaw_arclength_density (r : ℕ) :
    smoothInputLaw r = circleArcLength.withDensity (fun x => ENNReal.ofReal (circleDensity r x)) := by
  rw [circleArcLength, withDensity_add_measure, upper_arclength_density, lower_arclength_density, add_zero]

theorem smoothInputLaw_has_smooth_arclength_density (r : ℕ) :
    ∃ ρ : RealInput 2 → ℝ, ContDiff ℝ ∞ ρ ∧ (∀ x, 0 ≤ ρ x) ∧
      smoothInputLaw r = circleArcLength.withDensity (fun x => ENNReal.ofReal (ρ x)) :=
  ⟨circleDensity r, circleDensity_contDiff r, circleDensity_nonneg r, smoothInputLaw_arclength_density r⟩

end NeuralGeneralization.BatchTwoContinuousDepthLower
