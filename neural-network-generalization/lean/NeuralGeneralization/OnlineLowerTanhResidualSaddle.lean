import NeuralGeneralization.OnlineLowerTanhPeriodicPhase
import Mathlib.Analysis.SpecialFunctions.Log.Deriv

/-! # Quantitative Gaussian approximation of a finite cosine product

These estimates concern the actual finite product, with no local-limit
hypothesis.  They provide the saddle approximation in the signed residual
central limit theorem, including dimension-varying arrays.
-/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma log_cosine_quartic_error {z : ℝ} (hz : |z| ≤ 1/2) :
    |Real.log (Real.cos z)+z^2/2| ≤ z^4 := by
  have hz2 : z^2 ≤ 1/4 := by nlinarith [sq_abs z, abs_nonneg z]
  have hc0 := Real.one_sub_sq_div_two_le_cos (x := z)
  have hc1 := Real.cos_le_one z
  have hc : 0 < Real.cos z := by linarith
  have hx0 : 0 ≤ 1-Real.cos z := by linarith
  have hx : |1-Real.cos z| < 1 := by rw [abs_of_nonneg hx0]; linarith
  have hlog := Real.abs_log_sub_add_sum_range_le hx 1
  norm_num [Finset.sum_range_succ] at hlog
  rw [abs_of_nonneg hx0] at hlog
  have hsmall : (1-Real.cos z)^2 ≤ z^4/4 := by
    nlinarith [sq_nonneg (z^2/2-(1-Real.cos z))]
  have hfrac : (1-Real.cos z)^2/(1-(1-Real.cos z)) ≤ z^4/2 := by
    apply (div_le_iff₀ (by linarith : 0 < 1-(1-Real.cos z))).mpr
    nlinarith [mul_nonneg (show 0 ≤ z^4 from by positivity) (show 0 ≤ Real.cos z-1/2 by linarith)]
  have hcos := Real.cos_bound (show |z| ≤ 1 by linarith)
  rw [show |z|^4=z^4 by rw [pow_abs, abs_of_nonneg (by positivity)]] at hcos
  calc
    _ = |((1-Real.cos z)+Real.log (Real.cos z)) + (Real.cos z-(1-z^2/2))| := by congr 1; ring
    _ ≤ |(1-Real.cos z)+Real.log (Real.cos z)| + |Real.cos z-(1-z^2/2)| := abs_add_le _ _
    _ ≤ z^4/2+z^4*(5/96) := add_le_add (hlog.trans hfrac) hcos
    _ ≤ z^4 := by nlinarith [show 0 ≤ z^4 from by positivity]

lemma cosine_product_log_error {ι : Type*} [Fintype ι] (z : ι → ℝ)
    (hz : ∀ i, |z i| ≤ 1/2) :
    |(∑ i, Real.log (Real.cos (z i)))+(∑ i, (z i)^2)/2| ≤ ∑ i, (z i)^4 := by
  have he : (∑ i, Real.log (Real.cos (z i)))+(∑ i, (z i)^2)/2 =
      ∑ i, (Real.log (Real.cos (z i))+(z i)^2/2) := by
    rw [Finset.sum_add_distrib, Finset.sum_div]
  rw [he]
  exact (Finset.abs_sum_le_sum_abs _ _).trans
    (Finset.sum_le_sum (fun i _ => log_cosine_quartic_error (hz i)))

lemma cosine_product_gaussian_ratio {ι : Type*} [Fintype ι] (z : ι → ℝ)
    (hz : ∀ i, |z i| ≤ 1/2) :
    (∏ i, Real.cos (z i))/Real.exp (-(∑ i, (z i)^2)/2) =
      Real.exp ((∑ i, Real.log (Real.cos (z i)))+(∑ i, (z i)^2)/2) := by
  have hc (i : ι) : 0 < Real.cos (z i) := by
    have hz2 : (z i)^2 ≤ 1/4 := by nlinarith [sq_abs (z i), hz i, abs_nonneg (z i)]
    have h := Real.one_sub_sq_div_two_le_cos (x := z i)
    linarith
  rw [Real.exp_add, Real.exp_sum]
  simp_rw [Real.exp_log (hc _)]
  rw [div_eq_mul_inv, ← Real.exp_neg]
  congr 2
  ring

/-- Relative error, with its Gaussian factor preserved. This avoids a
window-length loss when integrating the approximation. -/
theorem cosine_product_gaussian_relative_error {ι : Type*} [Fintype ι] (z : ι → ℝ)
    (hz : ∀ i, |z i| ≤ 1/2) (hfour : ∑ i, (z i)^4 ≤ 1) :
    |(∏ i, Real.cos (z i))/Real.exp (-(∑ i, (z i)^2)/2)-1| ≤
      2*∑ i, (z i)^4 := by
  rw [cosine_product_gaussian_ratio z hz]
  have hlog := cosine_product_log_error z hz
  exact (Real.abs_exp_sub_one_le (hlog.trans hfour)).trans
    (mul_le_mul_of_nonneg_left hlog (by norm_num))

/-- The exact residual quadratic form after least-squares orthogonalization. -/
theorem residual_quadratic_identity {ι : Type*} [Fintype ι]
    (q d : ι → ℝ) (A x t : ℝ) (horth : ∑ i, q i*d i = 0) :
    (∑ i, (A*q i*x+d i*(t+x))^2) =
      A^2*(∑ i, (q i)^2)*x^2+(∑ i, (d i)^2)*(t+x)^2 := by
  have he (i : ι) : (A*q i*x+d i*(t+x))^2 =
      (A^2*x^2)*(q i)^2+(2*A*x*(t+x))*(q i*d i)+(t+x)^2*(d i)^2 := by ring
  simp_rw [he, Finset.sum_add_distrib, ← Finset.mul_sum, horth, mul_zero, add_zero]
  ring

lemma residual_quartic_bound {ι : Type*} [Fintype ι]
    (z : ι → ℝ) {M : ℝ} (hz : ∀ i, (z i)^2 ≤ M) :
    (∑ i, (z i)^4) ≤ M*∑ i, (z i)^2 := by
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  nlinarith [mul_le_mul_of_nonneg_right (hz i) (sq_nonneg (z i))]

/-- A version with arbitrary sequence-dependent dimensions. -/
theorem cosine_product_gaussian_ratio_tendsto (N : ℕ → ℕ)
    (z : (k : ℕ) → Fin (N k) → ℝ)
    (hsmall : ∀ᶠ k in atTop, ∀ i, |z k i| ≤ 1/2)
    (hfour : Tendsto (fun k => ∑ i, (z k i)^4) atTop (𝓝 0)) :
    Tendsto (fun k => (∏ i, Real.cos (z k i)) /
      Real.exp (-(∑ i, (z k i)^2)/2)) atTop (𝓝 1) := by
  have he : Tendsto (fun k => (∑ i, Real.log (Real.cos (z k i)))+
      (∑ i, (z k i)^2)/2) atTop (𝓝 0) := by
    apply squeeze_zero_norm' _ hfour
    filter_upwards [hsmall] with k hk
    simpa only [Real.norm_eq_abs] using cosine_product_log_error (z k) hk
  have hh := Real.continuous_exp.continuousAt.tendsto.comp he
  try simp only [Real.exp_zero] at hh
  apply hh.congr'
  filter_upwards [hsmall] with k hk
  exact (cosine_product_gaussian_ratio (z k) hk).symm

/-- A triangular-array Gaussian limit requiring only a vanishing maximum
coordinate and convergence of its squared norm. -/
theorem cosine_product_gaussian_limit (N : ℕ → ℕ)
    (z : (k : ℕ) → Fin (N k) → ℝ) (M : ℕ → ℝ) {S : ℝ}
    (hM : Tendsto M atTop (𝓝 0))
    (hmax : ∀ᶠ k in atTop, ∀ i, |z k i| ≤ M k)
    (hS : Tendsto (fun k => ∑ i, (z k i)^2) atTop (𝓝 S)) :
    Tendsto (fun k => ∏ i, Real.cos (z k i)) atTop (𝓝 (Real.exp (-S/2))) := by
  have hsmall : ∀ᶠ k in atTop, ∀ i, |z k i| ≤ 1/2 := by
    filter_upwards [hmax, hM.eventually (gt_mem_nhds (show (0:ℝ)<1/2 by norm_num))] with k hk hm i
    exact (hk i).trans hm.le
  have hfour : Tendsto (fun k => ∑ i, (z k i)^4) atTop (𝓝 0) := by
    apply squeeze_zero' (g := fun k => (M k)^2*(∑ i, (z k i)^2)) (Eventually.of_forall (fun k => Finset.sum_nonneg (fun i _ => by positivity)))
    · filter_upwards [hmax] with k hk
      apply residual_quartic_bound (M := (M k)^2)
      intro i
      have hM0 : 0 ≤ M k := (abs_nonneg (z k i)).trans (hk i)
      nlinarith [sq_abs (z k i), mul_self_le_mul_self (abs_nonneg (z k i)) (hk i)]
    · convert (hM.pow 2).mul hS using 1 <;> norm_num
  have hr := cosine_product_gaussian_ratio_tendsto N z hsmall hfour
  have he := Real.continuous_exp.continuousAt.tendsto.comp (hS.neg.div_const 2)
  have hh := hr.mul he
  simp only [one_mul] at hh
  convert hh using 1
  funext k
  exact (div_mul_cancel₀ _ (Real.exp_ne_zero _)).symm

/-- Pointwise residual saddle limit, before any integration. The dimensions,
lattice coordinates, gain and residual vector may all vary with the sequence. -/
theorem residual_cosine_product_limit (N : ℕ → ℕ)
    (q d : (k : ℕ) → Fin (N k) → ℝ) (A x t D : ℕ → ℝ)
    {Q E S t₀ : ℝ} (hQ : 0 ≤ Q)
    (hq : ∀ k i, |q k i| ≤ Q)
    (hd : ∀ k i, |d k i| ≤ D k)
    (horth : ∀ k, ∑ i, q k i*d k i = 0)
    (hAx : Tendsto (fun k => A k*x k) atTop (𝓝 0))
    (hx : Tendsto x atTop (𝓝 0)) (ht : Tendsto t atTop (𝓝 t₀))
    (hD : Tendsto D atTop (𝓝 0))
    (hE : Tendsto (fun k => ∑ i, (d k i)^2) atTop (𝓝 E))
    (hbulk : Tendsto (fun k => (A k)^2*(∑ i, (q k i)^2)*(x k)^2)
      atTop (𝓝 S)) :
    Tendsto (fun k => ∏ i, Real.cos (A k*q k i*x k+d k i*(t k+x k)))
      atTop (𝓝 (Real.exp (-(S+E*t₀^2)/2))) := by
  apply cosine_product_gaussian_limit N _
    (fun k => |A k*x k| *Q+D k* |t k+x k|)
  · convert (hAx.abs.mul_const Q).add (hD.mul ((ht.add hx).abs)) using 1 <;> simp
  · apply Eventually.of_forall
    intro k i
    calc
      _ ≤ |A k*q k i*x k| +|d k i*(t k+x k)| := abs_add_le _ _
      _ = |A k*x k| * |q k i| +|d k i| * |t k+x k| := by simp only [abs_mul]; ring
      _ ≤ _ := add_le_add (mul_le_mul_of_nonneg_left (hq k i) (abs_nonneg _))
        (mul_le_mul_of_nonneg_right (hd k i) (abs_nonneg _))
  · simp_rw [residual_quadratic_identity _ _ _ _ _ (horth _)]
    convert hbulk.add (hE.mul ((ht.add hx).pow 2)) using 1 <;> simp

end NeuralGeneralization.OnlineLowerTanh
