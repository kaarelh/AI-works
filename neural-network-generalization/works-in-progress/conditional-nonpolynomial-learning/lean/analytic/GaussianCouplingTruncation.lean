import CouplingTruncatedMoments

/-! A polynomial-modulus, variance-scaled replacement for the sharp Gaussian
transport inequality. Its inputs are actual marginal laws and a measurable
common-part mismatch probability. -/
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
variable {Ω : Type*} [MeasurableSpace Ω]

theorem gaussian_coupling_tanh_cutoff (M : Measure Ω) [IsProbabilityMeasure M]
    (Y Z b : Ω → ℝ) (hY : Measurable Y) (hZ : Measurable Z) (hb : Measurable b)
    (hKL : klDiv (M.map Y) (gaussianReal 0 1)≠∞)
    (hG : M.map Z=gaussianReal 0 1) {D m R : ℝ}
    (hD : (klDiv (M.map Y) (gaussianReal 0 1)).toReal≤D)
    (hm : M.real {w | Y w≠Z w}≤m) (hR : 0≤R) (σ : ℝ) :
    (∫w,(Real.tanh (b w+σ*Y w)-Real.tanh (b w+σ*Z w))^2 ∂M)≤
      σ^2*(4*R^2*m+16*D+64*Real.exp (-(R^2)/8)) := by
  haveI : IsProbabilityMeasure (M.map Y) := Measure.isProbabilityMeasure_map hY.aemeasurable
  haveI : IsProbabilityMeasure (M.map Z) := Measure.isProbabilityMeasure_map hZ.aemeasurable
  have hKLZ : klDiv (M.map Z) (gaussianReal 0 1)≠∞ := by rw [hG]; simp
  have hiY : Integrable (fun w => Y w^2) M :=
    (integrable_map_measure (by fun_prop) hY.aemeasurable).mp
      (scalar_gaussian_second_moment_integrable (M.map Y) hKL)
  have hiZ : Integrable (fun w => Z w^2) M :=
    (integrable_map_measure (by fun_prop) hZ.aemeasurable).mp
      (scalar_gaussian_second_moment_integrable (M.map Z) hKLZ)
  have hy := gaussian_tail_second_moment_le (M.map Y) hKL hR
  rw [integral_map hY.aemeasurable (gaussian_tail_square_measurable R).aestronglyMeasurable] at hy
  have hz := gaussian_tail_second_moment_le (M.map Z) hKLZ hR
  rw [integral_map hZ.aemeasurable (gaussian_tail_square_measurable R).aestronglyMeasurable,hG,
    klDiv_self,ENNReal.toReal_zero,mul_zero,zero_add] at hz
  have ht := coupling_integral_square_truncation M Y Z hY hZ hiY hiZ hR
  have hmass := mul_le_mul_of_nonneg_left hm (by positivity : (0:ℝ)≤4*R^2)
  have hall : (∫w,(Y w-Z w)^2 ∂M)≤4*R^2*m+16*D+64*Real.exp (-(R^2)/8) := by
    linarith
  exact (tanh_coupling_integral_scaled M Y Z b hY hZ hb hiY hiZ σ).trans
    (mul_le_mul_of_nonneg_left hall (sq_nonneg σ))

lemma exp_neg_square_le_inverse_square {R : ℝ} (hR : 0<R) :
    Real.exp (-(R^2)/8)≤8/R^2 := by
  have hx : 0<R^2/8 := by positivity
  have he := Real.add_one_le_exp (R^2/8)
  have he' : R^2/8≤Real.exp (R^2/8) := by linarith
  rw [show -(R^2)/8=-(R^2/8) by ring,Real.exp_neg]
  have hi := (inv_le_inv₀ (Real.exp_pos _) hx).mpr he'
  simpa only [inv_div] using hi

/-- Taking R=δ^(-1/8) gives an explicit polynomial modulus. Constants are
loose; the important point is the factor σ² and no inverse ambient scale. -/
theorem gaussian_coupling_tanh_polynomial (M : Measure Ω) [IsProbabilityMeasure M]
    (Y Z b : Ω → ℝ) (hY : Measurable Y) (hZ : Measurable Z) (hb : Measurable b)
    (hKL : klDiv (M.map Y) (gaussianReal 0 1)≠∞)
    (hG : M.map Z=gaussianReal 0 1) {δ : ℝ} (hδ : 0<δ)
    (hD : (klDiv (M.map Y) (gaussianReal 0 1)).toReal≤δ)
    (hm : M.real {w | Y w≠Z w}≤2*Real.sqrt δ) (σ : ℝ) :
    (∫w,(Real.tanh (b w+σ*Y w)-Real.tanh (b w+σ*Z w))^2 ∂M)≤
      σ^2*(520*Real.sqrt (Real.sqrt δ)+16*δ) := by
  let a := Real.sqrt (Real.sqrt δ)
  let R := (Real.sqrt a)⁻¹
  have ha : 0<a := Real.sqrt_pos.mpr (Real.sqrt_pos.mpr hδ)
  have hR : 0<R := inv_pos.mpr (Real.sqrt_pos.mpr ha)
  have hR2 : R^2=a⁻¹ := by dsimp [R]; rw [inv_pow,Real.sq_sqrt ha.le]
  have ha2 : a^2=Real.sqrt δ := Real.sq_sqrt (Real.sqrt_nonneg δ)
  have hmain := gaussian_coupling_tanh_cutoff M Y Z b hY hZ hb hKL hG hD hm hR.le σ
  have he := exp_neg_square_le_inverse_square hR
  have hl : 4*R^2*(2*Real.sqrt δ)=8*a := by
    rw [hR2,←ha2]
    field_simp
    <;> norm_num
  have hu : 8/R^2=8*a := by rw [hR2,div_inv_eq_mul]
  rw [hl] at hmain
  rw [hu] at he
  have hnon := mul_le_mul_of_nonneg_left he (sq_nonneg σ)
  change _≤σ^2*(520*a+16*δ)
  nlinarith only [hmain,hnon]

#print axioms gaussian_coupling_tanh_polynomial
end ConditionalNonpolynomial.Analytic
