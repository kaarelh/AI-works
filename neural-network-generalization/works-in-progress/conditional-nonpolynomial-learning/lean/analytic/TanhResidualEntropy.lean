import ResidualGaussianMoment
import NeuralGeneralization.TanhScalarJet

/-! The actual nonlinear tanh remainder satisfies the scalar bounds needed for
the dimension-free entropy estimate. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open NeuralGeneralization.TanhDifferential
open scoped ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

def tanhRemainder (x : ℝ) : ℝ := Real.tanh x - x

theorem hasDerivAt_tanhRemainder (x : ℝ) :
    HasDerivAt tanhRemainder (-(Real.tanh x)^2) x := by
  have h := (hasDerivAt_tanh_first x).sub (hasDerivAt_id x)
  have hf : tanhRemainder = Real.tanh - id := by rfl
  rw [hf]
  convert h using 1 <;> first | rfl | (dsimp [tanhFirst]; ring)

theorem tanhRemainder_lipschitz : LipschitzWith 1 tanhRemainder := by
  apply lipschitzWith_of_nnnorm_deriv_le
    (fun x => (hasDerivAt_tanhRemainder x).differentiableAt)
  intro x
  apply NNReal.coe_le_coe.mp
  change |deriv tanhRemainder x| ≤ 1
  rw [(hasDerivAt_tanhRemainder x).deriv, abs_neg, abs_of_nonneg (sq_nonneg _)]
  exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one x).le

theorem tanhRemainder_sub_le_radius (a b R : ℝ) (hR : 0 ≤ R)
    (ha : |a| ≤ R) (hb : |b| ≤ R) :
    |tanhRemainder a - tanhRemainder b| ≤ R^2 * |a-b| := by
  have hbound (x : ℝ) (hx : x ∈ Set.Icc (-R) R) : |-(Real.tanh x)^2| ≤ R^2 := by
    have htx : |Real.tanh x| ≤ |x| := by
      simpa only [Real.dist_eq, Real.tanh_zero, sub_zero, NNReal.coe_one, one_mul] using
        NeuralGeneralization.ConcreteModel.tanh_lipschitzWith.dist_le_mul x 0
    have hxabs : |x| ≤ R := abs_le.mpr hx
    rw [abs_neg, abs_of_nonneg (sq_nonneg _)]
    nlinarith [abs_nonneg (Real.tanh x), sq_abs (Real.tanh x)]
  have h := Convex.norm_image_sub_le_of_norm_hasDerivWithin_le
    (f := tanhRemainder) (f' := fun x => -(Real.tanh x)^2)
    (fun x _ => (hasDerivAt_tanhRemainder x).hasDerivWithinAt)
    (fun x hx => by simpa only [Real.norm_eq_abs] using hbound x hx)
    (convex_Icc (-R) R) (abs_le.mp hb) (abs_le.mp ha)
  simpa only [Real.norm_eq_abs] using h

theorem tanhRemainder_difference_sq_le (a b : ℝ) :
    (tanhRemainder a - tanhRemainder b)^2 ≤ (a-b)^2 := by
  have h := tanhRemainder_lipschitz.dist_le_mul a b
  simp only [Real.dist_eq, NNReal.coe_one, one_mul] at h
  nlinarith [sq_abs (tanhRemainder a-tanhRemainder b), sq_abs (a-b),
    abs_nonneg (tanhRemainder a-tanhRemainder b), abs_nonneg (a-b)]

theorem tanhRemainder_difference_sq_le_fourth (a b : ℝ) :
    (tanhRemainder a - tanhRemainder b)^2 ≤ (a-b)^2 * (a^4+b^4) := by
  rcases le_total |a| |b| with hab | hba
  · have h := tanhRemainder_sub_le_radius a b |b| (abs_nonneg _) hab le_rfl
    have hsq := (sq_le_sq₀ (abs_nonneg _) (mul_nonneg (sq_nonneg _) (abs_nonneg _))).mpr h
    simp only [mul_pow, sq_abs] at hsq
    have hextra := mul_nonneg (sq_nonneg (a-b)) (pow_nonneg (sq_nonneg a) 2)
    nlinarith
  · have h := tanhRemainder_sub_le_radius a b |a| (abs_nonneg _) le_rfl hba
    have hsq := (sq_le_sq₀ (abs_nonneg _) (mul_nonneg (sq_nonneg _) (abs_nonneg _))).mpr h
    simp only [mul_pow, sq_abs] at hsq
    have hextra := mul_nonneg (sq_nonneg (a-b)) (pow_nonneg (sq_nonneg b) 2)
    nlinarith

/-- An actual tanh residual difference under finite KL. The normalized
projections may be correlated and their variances may be zero. -/
theorem tanhRemainder_entropy_difference_sq
    {Ω : Type*} [MeasurableSpace Ω] (Q G : Measure Ω)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G ≠ ∞)
    (X Y Z : Ω → ℝ) (hXm : Measurable X) (hYm : Measurable Y)
    (s δ : ℝ) (hδ : δ ≠ 0)
    (hrel : ∀ ω, s*X ω-s*Y ω = δ*Z ω)
    (vZ vX vY : ℝ≥0) (hvZ : vZ ≤ 1) (hvX : vX ≤ 1) (hvY : vY ≤ 1)
    (hZ : HasLaw Z (gaussianReal 0 vZ) G)
    (hX : HasLaw X (gaussianReal 0 vX) G)
    (hY : HasLaw Y (gaussianReal 0 vY) G) :
    Integrable (fun ω => (tanhRemainder (s*X ω)-tanhRemainder (s*Y ω))^2) Q ∧
    (∫ ω, (tanhRemainder (s*X ω)-tanhRemainder (s*Y ω))^2 ∂Q) ≤
      δ^2 * (16*(klDiv Q G).toReal+12544*s^4) := by
  let W : Ω → ℝ := fun ω =>
    (tanhRemainder (s*X ω)-tanhRemainder (s*Y ω))^2 / δ^2
  have hδsq : 0 < δ^2 := sq_pos_of_ne_zero hδ
  have hW : Measurable W := by
    dsimp [W, tanhRemainder]
    fun_prop
  have hW0 (ω : Ω) : 0 ≤ W ω := by dsimp [W]; positivity
  have hW1 (ω : Ω) : W ω ≤ (Z ω)^2 := by
    apply (div_le_iff₀ hδsq).mpr
    have h := tanhRemainder_difference_sq_le (s*X ω) (s*Y ω)
    rw [hrel ω, mul_pow] at h
    nlinarith
  have hW2 (ω : Ω) : W ω ≤ (s^2)^2*(Z ω)^2*((X ω)^4+(Y ω)^4) := by
    apply (div_le_iff₀ hδsq).mpr
    have h := tanhRemainder_difference_sq_le_fourth (s*X ω) (s*Y ω)
    rw [hrel ω] at h
    calc
      _ ≤ (δ*Z ω)^2*((s*X ω)^4+(s*Y ω)^4) := h
      _ = _ := by ring
  obtain ⟨hi, hb⟩ := residual_gaussian_entropy_moment Q G hKL Z X Y W hW (s^2)
    vZ vX vY hvZ hvX hvY hZ hX hY hW0 hW1 hW2
  have heq : (fun ω => (tanhRemainder (s*X ω)-tanhRemainder (s*Y ω))^2) =
      fun ω => δ^2 * W ω := by
    funext ω
    dsimp [W]
    field_simp
  refine ⟨?_, ?_⟩
  · rw [heq]
    exact hi.const_mul _
  · rw [heq, integral_const_mul]
    calc
      _ ≤ δ^2*(16*(klDiv Q G).toReal+12544*(s^2)^2) :=
        mul_le_mul_of_nonneg_left hb hδsq.le
      _ = _ := by ring

#print axioms tanhRemainder_difference_sq_le_fourth
#print axioms tanhRemainder_entropy_difference_sq
end ConditionalNonpolynomial.Analytic
