import GaussianEntropyGain
import DimensionFreeGaussianTransfer

/-! Sharp entropy gains for actual controlled Gaussian feature maps. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.ConcreteModel
variable {I : Type*} [Fintype I]

theorem linearL2Map_sharp_gain (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (a : EuclideanSpace ℝ I) :
    ‖linearL2Map Q hKL a‖≤
      Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal))*‖a‖ := by
  by_cases haz : a=0
  · subst a
    simp
  have ha : 0<‖a‖ := norm_pos_iff.mpr haz
  let u : EuclideanSpace ℝ I := ‖a‖⁻¹ • a
  let Z := gaussianLinearForm u
  let G : Measure (I → ℝ) := Measure.pi fun _ : I => gaussianReal 0 1
  let P : Measure ℝ := Q.map Z
  let D := (klDiv Q G).toReal
  have hu : ‖u‖=1 := by
    dsimp [u]
    rw [norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos ha,inv_mul_cancel₀ ha.ne']
  have hZ : Measurable Z := gaussianLinearForm_measurable u
  have hZG : G.map Z=gaussianReal 0 1 := by
    have h := (gaussianLinearForm_hasLaw u).map_eq
    simpa only [hu,one_pow,Real.toNNReal_one] using h
  have hdata := NeuralGeneralization.RobustEntropy.klDiv_map_le Q G hZ
  rw [hZG] at hdata
  have hfinite : klDiv P (gaussianReal 0 1) ≠ ∞ :=
    ne_of_lt (lt_of_le_of_lt hdata (lt_top_iff_ne_top.mpr hKL))
  haveI : IsProbabilityMeasure P := Measure.isProbabilityMeasure_map hZ.aemeasurable
  let M := ∫ z : ℝ,z^2 ∂P
  have hM : 0≤M := integral_nonneg fun z => sq_nonneg z
  have hreal : (klDiv P (gaussianReal 0 1)).toReal≤D := ENNReal.toReal_mono hKL hdata
  have hMb : M≤gaussianEntropyGain D := by
    by_cases hm1 : 1≤M
    · exact (gaussianVarianceCost_le_iff ENNReal.toReal_nonneg hm1).mp
        ((scalar_gaussian_second_moment_entropy P hfinite).trans hreal)
    · exact (le_of_not_ge hm1).trans (gaussianEntropyGain_one_le D)
  have hm : (∫ z,(Z z)^2 ∂Q)=M := by
    dsimp [M,P]
    exact (integral_map hZ.aemeasurable
      ((measurable_id.pow_const 2).aestronglyMeasurable)).symm
  have hscale (z : I → ℝ) : gaussianLinearForm a z=‖a‖*Z z := by
    dsimp [Z,u,gaussianLinearForm]
    rw [real_inner_smul_left]
    field_simp
  have hgain : 0≤gaussianEntropyGain D := (by norm_num : (0:ℝ)≤1).trans (gaussianEntropyGain_one_le D)
  apply (sq_le_sq₀ (norm_nonneg _) (by positivity : 0≤Real.sqrt (gaussianEntropyGain D)*‖a‖)).mp
  rw [linearL2Map_norm_sq]
  simp_rw [hscale,mul_pow]
  rw [integral_const_mul,hm,Real.sq_sqrt hgain]
  nlinarith [mul_le_mul_of_nonneg_left hMb (sq_nonneg ‖a‖)]

theorem actualTanhL2_sharp_gain (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)≠∞)
    (a b : EuclideanSpace ℝ I) :
    ‖actualTanhL2 Q a-actualTanhL2 Q b‖≤
      Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal))*‖a-b‖ := by
  have hpoint : ∀ᵐz ∂Q,‖(actualTanhL2 Q a-actualTanhL2 Q b) z‖≤
      ‖linearL2Map Q hKL (a-b) z‖ := by
    filter_upwards [Lp.coeFn_sub (actualTanhL2 Q a) (actualTanhL2 Q b),
      actualTanhL2_ae Q a,actualTanhL2_ae Q b,linearL2Map_ae Q hKL (a-b)] with z hs ha hb hl
    have ht := tanh_lipschitzWith.dist_le_mul (gaussianLinearForm a z) (gaussianLinearForm b z)
    simp only [Real.dist_eq,NNReal.coe_one,one_mul] at ht
    simpa only [hs,Pi.sub_apply,ha,hb,hl,Real.norm_eq_abs,gaussianLinearForm,inner_sub_left] using ht
  exact (Lp.norm_le_norm_of_ae_le hpoint).trans (linearL2Map_sharp_gain Q hKL (a-b))

/-- Multiplying preactivation coefficients by the physical scale yields the
literal t sqrt(Gain(D)) factor used in the uniform-depth argument. -/
theorem actualTanhL2_scaled_sharp_gain (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)≠∞)
    (a b : EuclideanSpace ℝ I) {t : ℝ} (ht : 0≤t) :
    ‖actualTanhL2 Q (t • a)-actualTanhL2 Q (t • b)‖≤
      (t*Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal)))*‖a-b‖ := by
  have h := actualTanhL2_sharp_gain Q hKL (t • a) (t • b)
  rw [← smul_sub,norm_smul,Real.norm_eq_abs,abs_of_nonneg ht] at h
  convert h using 1 <;> ring

#print axioms actualTanhL2_scaled_sharp_gain
end ConditionalNonpolynomial.Analytic
