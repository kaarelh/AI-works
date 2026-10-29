import TanhResidualBall
import ScalarMomentEntropy
import ControlledL2Features
import CanonicalProjectionGeometry

/-! Actual controlled Gaussian layers in L² and their canonical finite-dimensional
realization. All feature maps below are built from the given probability law. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic

variable {I : Type*} [Fintype I]

def coordinateL2 (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) (i : I) : Lp ℝ 2 Q :=
  ((memLp_two_iff_integrable_sq (measurable_pi_apply i).aestronglyMeasurable).mpr
    (gaussian_coordinate_second_moment_integrable Q hKL i)).toLp (fun z => z i)

theorem coordinateL2_ae (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) (i : I) :
    coordinateL2 Q hKL i =ᵐ[Q] fun z => z i := MemLp.coeFn_toLp _

def linearL2Map (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) :
    EuclideanSpace ℝ I →ₗ[ℝ] Lp ℝ 2 Q where
  toFun a := ∑ i, a i • coordinateL2 Q hKL i
  map_add' a b := by simp [PiLp.add_apply, add_smul, Finset.sum_add_distrib]
  map_smul' c a := by simp [PiLp.smul_apply, smul_smul, Finset.smul_sum]

theorem linearL2Map_ae (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (a : EuclideanSpace ℝ I) : linearL2Map Q hKL a =ᵐ[Q] gaussianLinearForm a := by
  classical
  have hi (i : I) : (fun z => (a i • coordinateL2 Q hKL i) z) =ᵐ[Q] fun z => a i*z i := by
    filter_upwards [Lp.coeFn_smul (a i) (coordinateL2 Q hKL i), coordinateL2_ae Q hKL i] with z hz hzi
    simp only [hz, Pi.smul_apply, smul_eq_mul, hzi]
  have hall : ∀ᵐ z ∂Q, ∀ i, (a i • coordinateL2 Q hKL i) z = a i*z i :=
    ae_all_iff.mpr hi
  filter_upwards [Lp.coeFn_finsetSum Finset.univ (fun i => a i • coordinateL2 Q hKL i), hall]
    with z hz hallz
  change (∑ i, a i • coordinateL2 Q hKL i) z = _
  rw [hz]
  simp only [Finset.sum_apply, hallz, gaussianLinearForm, PiLp.inner_apply,
    WithLp.ofLp_toLp, Real.inner_apply]

theorem linearL2Map_norm_sq (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (a : EuclideanSpace ℝ I) :
    ‖linearL2Map Q hKL a‖^2 = ∫ z, (gaussianLinearForm a z)^2 ∂Q := by
  rw [← real_inner_self_eq_norm_sq, L2.inner_def]
  apply integral_congr_ae
  filter_upwards [linearL2Map_ae Q hKL a] with z hz
  simp [hz, Real.inner_apply, pow_two]

theorem linearL2Map_norm_le (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (a : EuclideanSpace ℝ I) :
    ‖linearL2Map Q hKL a‖ ≤
      (1+Real.sqrt (2*(klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal))*‖a‖ := by
  by_cases haz : a = 0
  · subst a
    simp
  have ha : 0 < ‖a‖ := norm_pos_iff.mpr haz
  let u : EuclideanSpace ℝ I := ‖a‖⁻¹ • a
  let Z := gaussianLinearForm u
  let G : Measure (I → ℝ) := Measure.pi fun _ : I => gaussianReal 0 1
  let P : Measure ℝ := Q.map Z
  let D := (klDiv Q G).toReal
  have hu : ‖u‖ = 1 := by
    dsimp [u]
    rw [norm_smul, Real.norm_eq_abs, abs_inv, abs_of_pos ha, inv_mul_cancel₀ ha.ne']
  have hZ : Measurable Z := gaussianLinearForm_measurable u
  have hZG : G.map Z = gaussianReal 0 1 := by
    have h := (gaussianLinearForm_hasLaw u).map_eq
    simpa only [hu, one_pow, Real.toNNReal_one] using h
  have hdata := NeuralGeneralization.RobustEntropy.klDiv_map_le Q G hZ
  rw [hZG] at hdata
  have hfinite : klDiv P (gaussianReal 0 1) ≠ ∞ :=
    ne_of_lt (lt_of_le_of_lt hdata (lt_top_iff_ne_top.mpr hKL))
  haveI : IsProbabilityMeasure P := Measure.isProbabilityMeasure_map hZ.aemeasurable
  let M := ∫ z : ℝ, z^2 ∂P
  have hM : 0 ≤ M := integral_nonneg (fun z => sq_nonneg z)
  have hp := scalar_gaussian_polar_deviation P hfinite
  have hD : 0 ≤ D := ENNReal.toReal_nonneg
  have hreal : (klDiv P (gaussianReal 0 1)).toReal ≤ D := ENNReal.toReal_mono hKL hdata
  have hsqD := Real.sq_sqrt (show 0 ≤ 2*D by positivity)
  have hsqM := Real.sq_sqrt hM
  have hdev : |Real.sqrt M-1| ≤ Real.sqrt (2*D) := by
    apply (sq_le_sq₀ (abs_nonneg _) (Real.sqrt_nonneg _)).mp
    rw [sq_abs, hsqD]
    exact hp.trans (mul_le_mul_of_nonneg_left hreal (by norm_num))
  have hroot : Real.sqrt M ≤ 1+Real.sqrt (2*D) := by
    have := (le_abs_self (Real.sqrt M-1)).trans hdev
    linarith
  have hMb : M ≤ (1+Real.sqrt (2*D))^2 := by
    have := sq_le_sq₀ (Real.sqrt_nonneg M) (show 0 ≤ 1+Real.sqrt (2*D) by positivity)
    rw [← hsqM]
    exact this.mpr hroot
  have hm : (∫ z, (Z z)^2 ∂Q) = M := by
    dsimp [M, P]
    exact (integral_map hZ.aemeasurable
      (show AEStronglyMeasurable (fun z : ℝ => z^2) (Q.map Z) from
        (measurable_id.pow_const 2).aestronglyMeasurable)).symm
  have hscale (z : I → ℝ) : gaussianLinearForm a z = ‖a‖*Z z := by
    dsimp [Z, u, gaussianLinearForm]
    rw [real_inner_smul_left]
    field_simp
  apply (sq_le_sq₀ (norm_nonneg _) (show 0 ≤ (1+Real.sqrt (2*D))*‖a‖ by positivity)).mp
  rw [linearL2Map_norm_sq]
  simp_rw [hscale, mul_pow]
  rw [integral_const_mul, hm]
  nlinarith [mul_le_mul_of_nonneg_left hMb (sq_nonneg ‖a‖)]

def actualTanhL2 (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (a : EuclideanSpace ℝ I) : Lp ℝ 2 Q :=
  boundedL2Feature Q (fun z => Real.tanh (gaussianLinearForm a z))
    (by unfold gaussianLinearForm; fun_prop) (fun z => (Real.abs_tanh_lt_one _).le)

theorem actualTanhL2_ae (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (a : EuclideanSpace ℝ I) :
    actualTanhL2 Q a =ᵐ[Q] fun z => Real.tanh (gaussianLinearForm a z) :=
  boundedL2Feature_ae Q _ _ _

def actualResidualL2 (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (a : EuclideanSpace ℝ I) : Lp ℝ 2 Q := actualTanhL2 Q a-linearL2Map Q hKL a

theorem actualResidualL2_ae (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (a : EuclideanSpace ℝ I) :
    actualResidualL2 Q hKL a =ᵐ[Q] tanhResidualFeature a := by
  filter_upwards [Lp.coeFn_sub (actualTanhL2 Q a) (linearL2Map Q hKL a),
    actualTanhL2_ae Q a, linearL2Map_ae Q hKL a] with z hs ht hl
  change (actualTanhL2 Q a-linearL2Map Q hKL a) z = _
  simp only [hs, Pi.sub_apply, ht, hl, tanhResidualFeature, tanhRemainder]

theorem actualResidualL2_distance_sq (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (a b : EuclideanSpace ℝ I) :
    ‖actualResidualL2 Q hKL a-actualResidualL2 Q hKL b‖^2 =
      ∫ z, (tanhResidualFeature a z-tanhResidualFeature b z)^2 ∂Q := by
  rw [← real_inner_self_eq_norm_sq, L2.inner_def]
  apply integral_congr_ae
  filter_upwards [Lp.coeFn_sub (actualResidualL2 Q hKL a) (actualResidualL2 Q hKL b),
    actualResidualL2_ae Q hKL a, actualResidualL2_ae Q hKL b] with z hs ha hb
  simp only [hs, Pi.sub_apply, ha, hb, Real.inner_apply, pow_two]

theorem actualResidualL2_ball_lipschitz (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (s : ℝ) (hs : 0 < s) (a b : EuclideanSpace ℝ I)
    (ha : ‖a‖ ≤ s) (hb : ‖b‖ ≤ s) :
    ‖actualResidualL2 Q hKL a-actualResidualL2 Q hKL b‖ ≤
      112*(s^2+Real.sqrt ((klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal))*‖a-b‖ := by
  have h := tanhResidualFeature_ball_rms_lipschitz Q hKL s hs a b ha hb
  rw [← actualResidualL2_distance_sq Q hKL a b, Real.sqrt_sq (norm_nonneg _)] at h
  exact h

#print axioms actualResidualL2_ball_lipschitz
end ConditionalNonpolynomial.Analytic
