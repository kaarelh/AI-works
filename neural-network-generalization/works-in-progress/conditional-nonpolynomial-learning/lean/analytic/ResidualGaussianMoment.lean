import GaussianCovarianceEntropy
import Mathlib.Probability.HasLaw

/-! A dimension-free residual exponential moment. Only the three one-dimensional
Gaussian marginals are used; no independence between projections is needed. -/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

theorem exp_sub_one_le_mul_exp (a : ℝ) :
    Real.exp a - 1 ≤ a * Real.exp a := by
  have h := mul_le_mul_of_nonneg_right (Real.add_one_le_exp (-a)) (Real.exp_pos a).le
  rw [← Real.exp_add] at h
  simp only [neg_add_cancel, Real.exp_zero] at h
  nlinarith

theorem fourth_power_exp_bound (z : ℝ) : z^4 ≤ 128 * Real.exp (z^2/8) := by
  have h := Real.pow_div_factorial_le_exp (z^2/8) (show 0 ≤ z^2/8 by positivity) 2
  norm_num only [Nat.factorial, Nat.cast_ofNat, Nat.cast_one] at h
  nlinarith

theorem eighth_power_exp_bound (z : ℝ) : z^8 ≤ 6144 * Real.exp (z^2/4) := by
  have h := Real.pow_div_factorial_le_exp (z^2/4) (show 0 ≤ z^2/4 by positivity) 4
  norm_num only [Nat.factorial, Nat.cast_ofNat, Nat.cast_one] at h
  nlinarith

theorem residual_exponential_excess_pointwise
    (q z x y w : ℝ) (hw0 : 0 ≤ w) (hw1 : w ≤ z^2)
    (hw2 : w ≤ q^2 * z^2 * (x^4 + y^4)) :
    Real.exp (w/16) - 1 ≤ q^2 *
      (8 * Real.exp (z^2/4) + 192 * Real.exp (x^2/4) + 192 * Real.exp (y^2/4)) := by
  let e := Real.exp (z^2/16)
  have he : 0 < e := Real.exp_pos _
  have he2 : e^2 = Real.exp (z^2/8) := by
    dsimp [e]
    rw [pow_two, ← Real.exp_add]
    congr 1
    ring
  have hsmall : Real.exp (w/16) - 1 ≤ w/16 * e := by
    exact (exp_sub_one_le_mul_exp (w/16)).trans
      (mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr (by linarith)) (by positivity))
  have hreplace : w/16 * e ≤ q^2/16 * (z^2*(x^4+y^4)*e) := by
    nlinarith [mul_le_mul_of_nonneg_right hw2 he.le]
  have hxy : z^2*(x^4+y^4)*e ≤ z^4*Real.exp (z^2/8)+(x^8+y^8)/2 := by
    have h1 := sq_nonneg (z^2*e-x^4)
    have h2 := sq_nonneg (z^2*e-y^4)
    have heq : z^4*e^2 = z^4*Real.exp (z^2/8) := by rw [he2]
    nlinarith
  have hz : z^4*Real.exp (z^2/8) ≤ 128*Real.exp (z^2/4) := by
    have h := mul_le_mul_of_nonneg_right (fourth_power_exp_bound z) (Real.exp_pos (z^2/8)).le
    have heq : Real.exp (z^2/8)*Real.exp (z^2/8) = Real.exp (z^2/4) := by
      rw [← Real.exp_add]
      congr 1
      ring
    nlinarith
  have hb : z^2*(x^4+y^4)*e ≤
      128*Real.exp (z^2/4)+3072*Real.exp (x^2/4)+3072*Real.exp (y^2/4) := by
    linarith [eighth_power_exp_bound x, eighth_power_exp_bound y]
  have hm := mul_le_mul_of_nonneg_left hb (show 0 ≤ q^2/16 by positivity)
  nlinarith

theorem gaussian_bounded_variance_exp_square
    (v : ℝ≥0) (hv : v ≤ 1) :
    Integrable (fun z : ℝ => Real.exp (z^2/4)) (gaussianReal 0 v) ∧
      (∫ z : ℝ, Real.exp (z^2/4) ∂gaussianReal 0 v) ≤ 2 := by
  have hvR : (v:ℝ) ≤ 1 := by exact_mod_cast hv
  have hd : 0 < 1-2*(1/4:ℝ)*v := by nlinarith
  have h := NeuralGeneralization.GaussianTail.integral_exp_mul_sq_gaussianReal v (1/4) hd
  have heq : (fun z : ℝ => Real.exp (z^2/4)) = fun z : ℝ => Real.exp ((1/4)*z^2) := by
    funext z; congr 1; ring
  rw [← heq] at h
  have hp : 0 < Real.sqrt (1-2*(1/4:ℝ)*v) := Real.sqrt_pos.mpr hd
  have hl : (1/2:ℝ) ≤ Real.sqrt (1-2*(1/4:ℝ)*v) := by
    apply (Real.le_sqrt (by norm_num) hd.le).mpr
    nlinarith
  refine ⟨Integrable.of_integral_ne_zero (by rw [h]; positivity), ?_⟩
  rw [h, ← one_div]
  apply (div_le_iff₀ hp).mpr
  linarith

theorem gaussian_law_exp_square
    {Ω : Type*} [MeasurableSpace Ω] (G : Measure Ω) (X : Ω → ℝ)
    (v : ℝ≥0) (hv : v ≤ 1) (hX : HasLaw X (gaussianReal 0 v) G) :
    Integrable (fun ω => Real.exp ((X ω)^2/4)) G ∧
      (∫ ω, Real.exp ((X ω)^2/4) ∂G) ≤ 2 := by
  obtain ⟨hi, hb⟩ := gaussian_bounded_variance_exp_square v hv
  have him : Integrable (fun z : ℝ => Real.exp (z^2/4)) (G.map X) := by
    rwa [hX.map_eq]
  refine ⟨(integrable_map_measure (by fun_prop) hX.aemeasurable).mp him, ?_⟩
  have heq := hX.integral_comp (f := fun z : ℝ => Real.exp (z^2/4)) (by fun_prop)
  exact heq.trans_le hb

/-- Correlation between the three Gaussian projections is unrestricted. -/
theorem residual_gaussian_exponential_moment
    {Ω : Type*} [MeasurableSpace Ω] (G : Measure Ω) [IsProbabilityMeasure G]
    (Z X Y W : Ω → ℝ) (hW : Measurable W) (q : ℝ)
    (vZ vX vY : ℝ≥0) (hvZ : vZ ≤ 1) (hvX : vX ≤ 1) (hvY : vY ≤ 1)
    (hZ : HasLaw Z (gaussianReal 0 vZ) G)
    (hX : HasLaw X (gaussianReal 0 vX) G)
    (hY : HasLaw Y (gaussianReal 0 vY) G)
    (hW0 : ∀ ω, 0 ≤ W ω) (hW1 : ∀ ω, W ω ≤ (Z ω)^2)
    (hW2 : ∀ ω, W ω ≤ q^2 * (Z ω)^2 * ((X ω)^4+(Y ω)^4)) :
    Integrable (fun ω => Real.exp (W ω/16)) G ∧
      (∫ ω, Real.exp (W ω/16) ∂G) ≤ 1 + 784*q^2 := by
  obtain ⟨hiZ, hbZ⟩ := gaussian_law_exp_square G Z vZ hvZ hZ
  obtain ⟨hiX, hbX⟩ := gaussian_law_exp_square G X vX hvX hX
  obtain ⟨hiY, hbY⟩ := gaussian_law_exp_square G Y vY hvY hY
  let F : Ω → ℝ := fun ω => q^2 *
    (8*Real.exp ((Z ω)^2/4)+192*Real.exp ((X ω)^2/4)+192*Real.exp ((Y ω)^2/4))
  have hiF : Integrable F G :=
    (((hiZ.const_mul 8).add (hiX.const_mul 192)).add (hiY.const_mul 192)).const_mul _
  have hp (ω : Ω) : Real.exp (W ω/16) ≤ F ω + 1 := by
    have h := residual_exponential_excess_pointwise q (Z ω) (X ω) (Y ω) (W ω)
      (hW0 ω) (hW1 ω) (hW2 ω)
    change Real.exp (W ω/16)-1 ≤ F ω at h
    linarith
  have hie : Integrable (fun ω => Real.exp (W ω/16)) G := by
    apply (hiF.add (integrable_const 1)).mono' ((hW.div_const 16).exp.aestronglyMeasurable)
    filter_upwards [] with ω
    simpa only [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _), Pi.add_apply] using hp ω
  refine ⟨hie, ?_⟩
  have hmono := integral_mono hie (hiF.add (integrable_const 1)) hp
  have hiZX : Integrable (fun ω => 8*Real.exp ((Z ω)^2/4)+192*Real.exp ((X ω)^2/4)) G :=
    (hiZ.const_mul 8).add (hiX.const_mul 192)
  have hIF : (∫ ω, F ω ∂G) ≤ 784*q^2 := by
    dsimp only [F]
    rw [integral_const_mul, integral_add hiZX
      (hiY.const_mul 192), integral_add (hiZ.const_mul 8) (hiX.const_mul 192),
      integral_const_mul, integral_const_mul, integral_const_mul]
    have h := mul_le_mul_of_nonneg_left (show
      8*(∫ ω, Real.exp ((Z ω)^2/4) ∂G)+192*(∫ ω, Real.exp ((X ω)^2/4) ∂G)+
        192*(∫ ω, Real.exp ((Y ω)^2/4) ∂G) ≤ 784 by linarith) (sq_nonneg q)
    nlinarith
  simp only [Pi.add_apply] at hmono
  rw [integral_add hiF (integrable_const 1)] at hmono
  simp only [integral_const, probReal_univ, one_smul] at hmono
  linarith

/-- The actual controlled law inherits the required small residual second
moment from finite KL, with no L² bound on its density. -/
theorem residual_gaussian_entropy_moment
    {Ω : Type*} [MeasurableSpace Ω] (Q G : Measure Ω)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G ≠ ∞)
    (Z X Y W : Ω → ℝ) (hW : Measurable W) (q : ℝ)
    (vZ vX vY : ℝ≥0) (hvZ : vZ ≤ 1) (hvX : vX ≤ 1) (hvY : vY ≤ 1)
    (hZ : HasLaw Z (gaussianReal 0 vZ) G)
    (hX : HasLaw X (gaussianReal 0 vX) G)
    (hY : HasLaw Y (gaussianReal 0 vY) G)
    (hW0 : ∀ ω, 0 ≤ W ω) (hW1 : ∀ ω, W ω ≤ (Z ω)^2)
    (hW2 : ∀ ω, W ω ≤ q^2 * (Z ω)^2 * ((X ω)^4+(Y ω)^4)) :
    Integrable W Q ∧ (∫ ω, W ω ∂Q) ≤ 16*(klDiv Q G).toReal + 12544*q^2 := by
  obtain ⟨hie, he⟩ := residual_gaussian_exponential_moment G Z X Y W hW q
    vZ vX vY hvZ hvX hvY hZ hX hY hW0 hW1 hW2
  have hm : (∫ ω, Real.exp (W ω/16) ∂G) ≤ Real.exp (784*q^2) :=
    he.trans (by simpa [add_comm] using Real.add_one_le_exp (784*q^2))
  have hi := NeuralGeneralization.RobustEntropyMoments.integrable_of_exp_integrable_finite_kl
    Q G hKL (fun ω => W ω/16) (hW.div_const 16) (fun ω => div_nonneg (hW0 ω) (by norm_num)) hie
  have h := NeuralGeneralization.RobustEntropyMoments.integral_le_kl_add_exponential_bound
    Q G hKL (fun ω => W ω/16) (hW.div_const 16) (fun ω => div_nonneg (hW0 ω) (by norm_num)) hie (784*q^2) hm
  refine ⟨?_, ?_⟩
  · convert hi.const_mul 16 using 1
    funext ω
    ring
  · rw [integral_div] at h
    linarith

#print axioms residual_exponential_excess_pointwise
#print axioms residual_gaussian_entropy_moment
end ConditionalNonpolynomial.Analytic
