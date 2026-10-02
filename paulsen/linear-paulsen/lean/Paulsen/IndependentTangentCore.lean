import Paulsen.GaussianSoftCount
import Paulsen.GaussianTangentCoupling

/-!
# Small-ball estimate for an independent normalized tangent row

A scalar Gaussian numerator is controlled either by its density or by its
second moment, according to the size of its mean. The random normalization
costs only a first-moment Markov bound.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory

namespace Paulsen
noncomputable section

variable {κ : Type*} [Fintype κ]

/-- A Gaussian with mean separated from zero enters a short interval only after
a fluctuation whose size is bounded below. -/
theorem affineGaussian_small_ball_of_large_mean
    (D : StrongDual ℝ (EuclideanSpace ℝ κ)) {m q : ℝ}
    (hm : 1 / 2 ≤ |m|) (hq : q ≤ 1 / 4) :
    (stdGaussian (EuclideanSpace ℝ κ)).real {g | |m + D g| ≤ q} ≤ 16 * ‖D‖ ^ 2 := by
  have hint : Integrable (fun g : EuclideanSpace ℝ κ => (D g) ^ 2)
      (stdGaussian (EuclideanSpace ℝ κ)) :=
    (memLp_square_of_hasLaw (hasLaw_dual_stdGaussian D)).integrable (by norm_num)
  have hmarkov := mul_meas_ge_le_integral_of_nonneg
    (ae_of_all _ fun g => sq_nonneg (D g)) hint (1 / 16)
  rw [integral_sq_dual_stdGaussian] at hmarkov
  have hsub : {g : EuclideanSpace ℝ κ | |m + D g| ≤ q} ⊆
      {g | (1 : ℝ) / 16 ≤ (D g) ^ 2} := by
    intro g hg
    change |m + D g| ≤ q at hg
    have habs := abs_sub (m + D g) (D g)
    have hm' : |m| ≤ |m + D g| + |D g| := by simpa only [add_sub_cancel_right] using habs
    have hquarter : 1 / 4 ≤ |D g| := by linarith
    change 1 / 16 ≤ (D g) ^ 2
    nlinarith [sq_abs (D g), sq_nonneg (|D g| - 1 / 4)]
  have hmono := measureReal_mono (μ := stdGaussian (EuclideanSpace ℝ κ)) hsub
  linarith

/-- A random denominator of the form sqrt(1+R) exceeds two with probability
at most one third of its nonnegative mean parameter. -/
theorem normalized_small_ball_union_le
    (D : StrongDual ℝ (EuclideanSpace ℝ κ)) (m w : ℝ) (hw : 0 ≤ w)
    (R : EuclideanSpace ℝ κ → ℝ) (hR : ∀ g, 0 ≤ R g)
    (hRi : Integrable R (stdGaussian (EuclideanSpace ℝ κ))) :
    (stdGaussian (EuclideanSpace ℝ κ)).real
      {g | |(m + D g) / Real.sqrt (1 + R g)| ≤ w} ≤
      (∫ g, R g ∂stdGaussian (EuclideanSpace ℝ κ)) / 3 +
        (stdGaussian (EuclideanSpace ℝ κ)).real {g | |m + D g| ≤ 2 * w} := by
  have hsub : {g : EuclideanSpace ℝ κ | |(m + D g) / Real.sqrt (1 + R g)| ≤ w} ⊆
      {g | 3 ≤ R g} ∪ {g | |m + D g| ≤ 2 * w} := by
    intro g hg
    change |(m + D g) / Real.sqrt (1 + R g)| ≤ w at hg
    by_cases hlarge : 3 ≤ R g
    · exact Or.inl hlarge
    · apply Or.inr
      change |m + D g| ≤ 2 * w
      have hden : 0 < Real.sqrt (1 + R g) := Real.sqrt_pos.mpr (by linarith [hR g])
      have hdenle : Real.sqrt (1 + R g) ≤ 2 := by
        apply (Real.sqrt_le_iff).mpr
        constructor <;> linarith
      rw [abs_div, abs_of_pos hden] at hg
      have hnum := (div_le_iff₀ hden).mp hg
      nlinarith
  have hmarkov := mul_meas_ge_le_integral_of_nonneg (ae_of_all _ hR) hRi (3 : ℝ)
  calc
    _ ≤ (stdGaussian (EuclideanSpace ℝ κ)).real
        ({g | 3 ≤ R g} ∪ {g | |m + D g| ≤ 2 * w}) := measureReal_mono hsub
    _ ≤ (stdGaussian (EuclideanSpace ℝ κ)).real {g | 3 ≤ R g} +
        (stdGaussian (EuclideanSpace ℝ κ)).real {g | |m + D g| ≤ 2 * w} :=
      measureReal_union_le _ _
    _ ≤ _ := by linarith


/-- Uniform small-ball control for a Gaussian numerator with the tangent-row
variance, including a dependent random normalization. -/
theorem normalized_tangent_scalar_small_ball
    (D : StrongDual ℝ (EuclideanSpace ℝ κ)) (m s t h : ℝ)
    (hs : 0 < s) (hh : 0 < h) (hst : s ^ 2 ≤ t ^ 2) (hhs : h * s ≤ 1 / 8)
    (hvar : ‖D‖ ^ 2 = s ^ 2 * (1 - m ^ 2))
    (R : EuclideanSpace ℝ κ → ℝ) (hR : ∀ g, 0 ≤ R g)
    (hRi : Integrable R (stdGaussian (EuclideanSpace ℝ κ)))
    (hmean : (∫ g, R g ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ t ^ 2) :
    (stdGaussian (EuclideanSpace ℝ κ)).real
      {g | |(m + D g) / Real.sqrt (1 + R g)| ≤ h * s} ≤
      2 * Real.exp 1 * h + 17 * t ^ 2 := by
  have hunion := normalized_small_ball_union_le D m (h * s) (by positivity) R hR hRi
  by_cases hm : |m| ≤ 1 / 2
  · have hm2 : m ^ 2 ≤ 1 / 4 := by nlinarith [sq_abs m, abs_nonneg m]
    have hvarlower : s ^ 2 / 2 ≤ ‖D‖ ^ 2 := by
      rw [hvar]
      nlinarith [mul_nonneg (sq_nonneg s) (sub_nonneg.mpr hm2)]
    have hsmall := stdGaussian_affine_smallBall D m
      (show 0 < s ^ 2 / 2 by positivity) hvarlower
      (show 0 < 2 * (h * s) by positivity)
    have hsqrt : Real.sqrt (2 * (s ^ 2 / 2)) = s := by
      rw [show 2 * (s ^ 2 / 2) = s ^ 2 by ring, Real.sqrt_sq hs.le]
    rw [hsqrt] at hsmall
    have heq : Real.exp 1 * (2 * (h * s)) / s = 2 * Real.exp 1 * h := by
      field_simp
    rw [heq] at hsmall
    nlinarith [sq_nonneg t]
  · have hsmall := affineGaussian_small_ball_of_large_mean D
      (show 1 / 2 ≤ |m| by linarith) (show 2 * (h * s) ≤ 1 / 4 by linarith)
    have hvarupper : ‖D‖ ^ 2 ≤ t ^ 2 := by
      rw [hvar]
      nlinarith [mul_nonneg (sq_nonneg s) (sq_nonneg m)]
    nlinarith [mul_pos (Real.exp_pos (1 : ℝ)) hh, sq_nonneg t]

/-- The component of a Gaussian row orthogonal to its original unit direction. -/
def independentTangentProjection {d : ℕ} (e : EuclideanSpace ℝ (Fin d)) :
    EuclideanSpace ℝ (Fin d) →L[ℝ] EuclideanSpace ℝ (Fin d) :=
  (ℝ ∙ e)ᗮ.starProjection

theorem independentTangentProjection_apply {d : ℕ} (e : EuclideanSpace ℝ (Fin d))
    (he : ‖e‖ = 1) (g : EuclideanSpace ℝ (Fin d)) :
    independentTangentProjection e g = g - (inner ℝ e g) • e := by
  rw [independentTangentProjection, Submodule.starProjection_orthogonal]
  simp [Submodule.starProjection_singleton, he]

/-- Unit direction of an independently normalized tangent perturbation. -/
def independentTangentDirection {d : ℕ} (e : EuclideanSpace ℝ (Fin d)) (t : ℝ)
    (g : EuclideanSpace ℝ (Fin d)) : EuclideanSpace ℝ (Fin d) :=
  (1 / Real.sqrt (1 + (t / Real.sqrt d) ^ 2 * ‖independentTangentProjection e g‖ ^ 2)) •
    (e + (t / Real.sqrt d) • independentTangentProjection e g)

theorem independentTangentDirection_inner {d : ℕ}
    (e f : EuclideanSpace ℝ (Fin d)) (he : ‖e‖ = 1) (t : ℝ)
    (g : EuclideanSpace ℝ (Fin d)) :
    inner ℝ f (independentTangentDirection e t g) =
      (inner ℝ f e + ((t / Real.sqrt d) • innerSL ℝ (f - (inner ℝ f e) • e)) g) /
        Real.sqrt (1 + (t / Real.sqrt d) ^ 2 * ‖independentTangentProjection e g‖ ^ 2) := by
  unfold independentTangentDirection
  rw [inner_smul_right, inner_add_right, inner_smul_right]
  rw [independentTangentProjection_apply e he]
  simp only [inner_sub_right, inner_smul_right, smul_apply,
    innerSL_apply_apply, inner_sub_left, inner_smul_left, conj_trivial, smul_eq_mul]
  ring

theorem tangent_numerator_variance {d : ℕ} (e f : EuclideanSpace ℝ (Fin d))
    (he : ‖e‖ = 1) (hf : ‖f‖ = 1) (s : ℝ) :
    ‖s • innerSL ℝ (f - (inner ℝ f e) • e)‖ ^ 2 =
      s ^ 2 * (1 - (inner ℝ f e) ^ 2) := by
  rw [norm_smul, mul_pow, Real.norm_eq_abs, sq_abs, innerSL_apply_norm,
    norm_sub_sq_real, inner_smul_right, norm_smul, mul_pow, he, hf,
    one_pow, mul_one, Real.norm_eq_abs, sq_abs]
  ring


/-- The denominator parameter of a tangent perturbation has mean at most t². -/
theorem independentTangentProjection_mean_norm_sq_le {d : ℕ} (hd : 0 < d)
    (e : EuclideanSpace ℝ (Fin d)) (t : ℝ) :
    (∫ g : EuclideanSpace ℝ (Fin d),
      (t / Real.sqrt d) ^ 2 * ‖independentTangentProjection e g‖ ^ 2
        ∂stdGaussian (EuclideanSpace ℝ (Fin d))) ≤ t ^ 2 := by
  let E : Submodule ℝ (EuclideanSpace ℝ (Fin d)) := (ℝ ∙ e)ᗮ
  have hmean : (∫ g, ‖E.starProjection g‖ ^ 2
      ∂stdGaussian (EuclideanSpace ℝ (Fin d))) = (Module.finrank ℝ E : ℝ) := by
    simpa only [one_smul, one_pow, one_mul] using integral_norm_sq_scaled_projection E 1
  change (∫ g, (t / Real.sqrt d) ^ 2 * ‖E.starProjection g‖ ^ 2
    ∂stdGaussian (EuclideanSpace ℝ (Fin d))) ≤ _
  rw [integral_const_mul, hmean]
  have hrank : (Module.finrank ℝ E : ℝ) ≤ d := by
    exact_mod_cast E.finrank_le.trans_eq (by simp)
  calc
    _ ≤ (t / Real.sqrt d) ^ 2 * d := mul_le_mul_of_nonneg_left hrank (sq_nonneg _)
    _ = _ := by
      rw [div_pow, Real.sq_sqrt (Nat.cast_nonneg d)]
      exact div_mul_cancel₀ _ (by exact_mod_cast hd.ne')

theorem independentTangentProjection_integrable_norm_sq {d : ℕ}
    (e : EuclideanSpace ℝ (Fin d)) (t : ℝ) :
    Integrable (fun g : EuclideanSpace ℝ (Fin d) =>
      (t / Real.sqrt d) ^ 2 * ‖independentTangentProjection e g‖ ^ 2)
      (stdGaussian (EuclideanSpace ℝ (Fin d))) := by
  have h := (memLp_norm_sq_gaussianImage (subspaceProjectionMatrix ((ℝ ∙ e)ᗮ))).integrable
    (by norm_num)
  simp only [subspaceProjectionMatrix_toEuclideanLin, ContinuousLinearMap.coe_coe] at h
  exact h.const_mul _

/-- An independently normalized tangent row has uniformly small probability
of lying close to any fixed equatorial hyperplane. -/
theorem independentTangentDirection_small_ball {d : ℕ} (hd : 0 < d)
    (e f : EuclideanSpace ℝ (Fin d)) (he : ‖e‖ = 1) (hf : ‖f‖ = 1)
    {t h : ℝ} (ht : 0 < t) (ht1 : t ≤ 1) (hh : 0 < h) (hh8 : h ≤ 1 / 8) :
    (stdGaussian (EuclideanSpace ℝ (Fin d))).real
      {g | |inner ℝ f (independentTangentDirection e t g)| ≤ h * t / Real.sqrt d} ≤
        2 * Real.exp 1 * h + 17 * t ^ 2 := by
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hsqrt : 1 ≤ Real.sqrt d := by
    apply (Real.le_sqrt (by norm_num) (Nat.cast_nonneg d)).mpr
    simpa using hdR
  have hsqrtpos : 0 < Real.sqrt d := by positivity
  have hs : 0 < t / Real.sqrt d := by positivity
  have hst : t / Real.sqrt d ≤ t := (div_le_self ht.le hsqrt)
  have hst2 : (t / Real.sqrt d) ^ 2 ≤ t ^ 2 := by nlinarith
  have hhs : h * (t / Real.sqrt d) ≤ 1 / 8 := by
    have hs1 : t / Real.sqrt d ≤ 1 := hst.trans ht1
    nlinarith
  have hsmall := normalized_tangent_scalar_small_ball
    ((t / Real.sqrt d) • innerSL ℝ (f - (inner ℝ f e) • e))
    (inner ℝ f e) (t / Real.sqrt d) t h hs hh hst2 hhs
    (tangent_numerator_variance e f he hf _)
    (fun g => (t / Real.sqrt d) ^ 2 * ‖independentTangentProjection e g‖ ^ 2)
    (by intro g; positivity) (independentTangentProjection_integrable_norm_sq e t)
    (independentTangentProjection_mean_norm_sq_le hd e t)
  simpa only [independentTangentDirection_inner e f he, mul_div_assoc] using hsmall



/-- Normalization preserves unit row length in every realization. -/
theorem norm_independentTangentDirection {d : ℕ}
    (e : EuclideanSpace ℝ (Fin d)) (he : ‖e‖ = 1) (t : ℝ)
    (g : EuclideanSpace ℝ (Fin d)) : ‖independentTangentDirection e t g‖ = 1 := by
  have horth : inner ℝ e (independentTangentProjection e g) = 0 := by
    rw [independentTangentProjection_apply e he, inner_sub_right, inner_smul_right,
      real_inner_self_eq_norm_sq, he]
    ring
  have hnorm : ‖e + (t / Real.sqrt d) • independentTangentProjection e g‖ ^ 2 =
      1 + (t / Real.sqrt d) ^ 2 * ‖independentTangentProjection e g‖ ^ 2 := by
    rw [norm_add_sq_real, inner_smul_right, horth, he, norm_smul,
      mul_pow, Real.norm_eq_abs, sq_abs]
    ring
  have heq : ‖e + (t / Real.sqrt d) • independentTangentProjection e g‖ =
      Real.sqrt (1 + (t / Real.sqrt d) ^ 2 * ‖independentTangentProjection e g‖ ^ 2) := by
    rw [← hnorm, Real.sqrt_sq (norm_nonneg _)]
  unfold independentTangentDirection
  rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg (by positivity), heq]
  exact one_div_mul_cancel (by positivity)

theorem continuous_independentTangentDirection {d : ℕ}
    (e : EuclideanSpace ℝ (Fin d)) (t : ℝ) :
    Continuous (independentTangentDirection e t) := by
  unfold independentTangentDirection
  have hc := (independentTangentProjection e).continuous
  have hscaled : Continuous (fun g : EuclideanSpace ℝ (Fin d) =>
      (t / Real.sqrt d) • independentTangentProjection e g) := by
    exact (continuous_const : Continuous (fun _ : EuclideanSpace ℝ (Fin d) => t / Real.sqrt d)).fun_smul hc
  have hnum : Continuous (fun g : EuclideanSpace ℝ (Fin d) =>
      e + (t / Real.sqrt d) • independentTangentProjection e g) :=
    continuous_const.add hscaled
  have hden : Continuous (fun g : EuclideanSpace ℝ (Fin d) =>
      1 / Real.sqrt (1 + (t / Real.sqrt d) ^ 2 * ‖independentTangentProjection e g‖ ^ 2)) := by
    apply Continuous.div continuous_const
    · exact (continuous_const.add (continuous_const.mul (hc.norm.pow 2))).sqrt
    · intro g
      positivity
  exact hden.fun_smul hnum

/-- Concrete numerical parameters make the bad-edge probability at most 1/50. -/
theorem independentTangentDirection_small_ball_one_fiftieth {d : ℕ} (hd : 0 < d)
    (e f : EuclideanSpace ℝ (Fin d)) (he : ‖e‖ = 1) (hf : ‖f‖ = 1)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1)) :
    (stdGaussian (EuclideanSpace ℝ (Fin d))).real
      {g | |inner ℝ f (independentTangentDirection e t g)| ≤ h * t / Real.sqrt d} ≤
        1 / 50 := by
  have he1 : 1 ≤ Real.exp (1 : ℝ) := Real.one_le_exp (by norm_num)
  have hh8 : h ≤ 1 / 8 := by
    have hmul := (le_div_iff₀ (show 0 < 400 * Real.exp (1 : ℝ) by positivity)).mp hh400
    nlinarith
  have hb := independentTangentDirection_small_ball hd e f he hf ht (by linarith) hh hh8
  have hmul := (le_div_iff₀ (show 0 < 400 * Real.exp (1 : ℝ) by positivity)).mp hh400
  have ht2 : t ^ 2 ≤ 1 / 10000 := by nlinarith
  nlinarith

end
end Paulsen
