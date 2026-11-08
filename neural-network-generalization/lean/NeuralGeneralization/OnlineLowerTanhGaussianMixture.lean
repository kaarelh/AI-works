import NeuralGeneralization.OnlineLowerTanhMixtureBounds

/-! # Removing a Gaussian envelope after finite external-phase averaging -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- A proved finite-averaging lemma. The concrete residual theorems supply
the approximation premise when this is instantiated below. -/
theorem uniform_average_of_gaussian_approx
    (P : ℕ → ℕ) (p β : (k : ℕ) → Fin (P k) → ℝ)
    (s : ℕ → ℝ) (f g : ℕ → ℝ → ℝ) {C M : ℝ} (hC : 0 ≤ C) (hM : 0 ≤ M)
    (hp : ∀ k i, 0 ≤ p k i) (hsum : ∀ k, ∑ i,p k i=1)
    (hg : ∀ k B, |g k B| ≤ M) (hs : Tendsto s atTop (𝓝 0))
    (hmoment : Tendsto (fun k => (s k)^2*(∑ i,p k i*(β k i)^2)) atTop (𝓝 0))
    (happrox : ∀ ε > 0, ∀ᶠ k in atTop, ∀ B : ℝ,
      |f k B-C*Real.exp (-(B*s k)^2/2)*g k B| < ε)
    (D : ℝ) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ b : ℝ, |b| ≤ D →
      |(∑ i,p k i*f k (β k i+b))-C*(∑ i,p k i*g k (β k i+b))| < ε := by
  intro ε hε
  have henv : Tendsto (fun k => C*M*((s k)^2*((∑ i,p k i*(β k i)^2)+D^2))) atTop (𝓝 0) := by
    have ht := (hmoment.add ((hs.pow 2).mul_const (D^2))).const_mul (C*M)
    simp only [zero_pow (by decide : 2≠0),zero_mul,add_zero,mul_zero] at ht
    convert ht using 1
    funext k
    ring
  filter_upwards [happrox (ε/3) (by linarith),henv.eventually (gt_mem_nhds (by linarith : (0:ℝ)<ε/3))]
    with k hk he b hb
  have h1 := weighted_uniform_error (p k) (fun i => f k (β k i+b))
    (fun i => C*Real.exp (-((β k i+b)*s k)^2/2)*g k (β k i+b))
    (hp k) (hsum k) (fun i => (hk (β k i+b)).le)
  have h2 := weighted_gaussian_removal (p k) (β k) (fun i => g k (β k i+b))
    (hp k) (hsum k) hM (fun i => hg k _) (s k) b D hb
  have hsum' : (∑ i,p k i*(C*Real.exp (-((β k i+b)*s k)^2/2)*g k (β k i+b))) =
      C*(∑ i,p k i*Real.exp (-((β k i+b)*s k)^2/2)*g k (β k i+b)) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [hsum'] at h1
  have h2' := mul_le_mul_of_nonneg_left h2 hC
  have htri := abs_sub_le (∑ i,p k i*f k (β k i+b))
    (C*(∑ i,p k i*Real.exp (-((β k i+b)*s k)^2/2)*g k (β k i+b)))
    (C*(∑ i,p k i*g k (β k i+b)))
  rw [← mul_sub,abs_mul,abs_of_nonneg hC] at htri
  nlinarith

theorem uniform_signed_average_of_gaussian_approx
    (P : ℕ → ℕ) (p β ν : (k : ℕ) → Fin (P k) → ℝ)
    (hν : ∀ k i, |ν k i| ≤ 1)
    (s : ℕ → ℝ) (f g : ℕ → ℝ → ℝ) {C M : ℝ} (hC : 0 ≤ C) (hM : 0 ≤ M)
    (hp : ∀ k i, 0 ≤ p k i) (hsum : ∀ k, ∑ i,p k i=1)
    (hg : ∀ k B, |g k B| ≤ M) (hs : Tendsto s atTop (𝓝 0))
    (hmoment : Tendsto (fun k => (s k)^2*(∑ i,p k i*(β k i)^2)) atTop (𝓝 0))
    (happrox : ∀ ε > 0, ∀ᶠ k in atTop, ∀ B : ℝ,
      |f k B-C*Real.exp (-(B*s k)^2/2)*g k B| < ε)
    (D : ℝ) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ b : ℝ, |b| ≤ D →
      |(∑ i,p k i*(ν k i*f k (β k i+b)))-C*(∑ i,p k i*(ν k i*g k (β k i+b)))| < ε := by
  intro ε hε
  have henv : Tendsto (fun k => C*M*((s k)^2*((∑ i,p k i*(β k i)^2)+D^2))) atTop (𝓝 0) := by
    have ht := (hmoment.add ((hs.pow 2).mul_const (D^2))).const_mul (C*M)
    simp only [zero_pow (by decide : 2≠0),zero_mul,add_zero,mul_zero] at ht
    convert ht using 1
    funext k
    ring
  filter_upwards [happrox (ε/3) (by linarith),henv.eventually (gt_mem_nhds (by linarith : (0:ℝ)<ε/3))]
    with k hk he b hb
  have h1 := weighted_uniform_error (p k) (fun i => ν k i*f k (β k i+b))
    (fun i => C*Real.exp (-((β k i+b)*s k)^2/2)*(ν k i*g k (β k i+b)))
    (hp k) (hsum k) (fun i => by
      have hmul := mul_le_of_le_one_left
        (abs_nonneg (f k (β k i+b)-C*Real.exp (-((β k i+b)*s k)^2/2)*g k (β k i+b))) (hν k i)
      have heq : ν k i*f k (β k i+b)-C*Real.exp (-((β k i+b)*s k)^2/2)*(ν k i*g k (β k i+b)) =
        ν k i*(f k (β k i+b)-C*Real.exp (-((β k i+b)*s k)^2/2)*g k (β k i+b)) := by ring
      rw [heq,abs_mul]
      exact hmul.trans (hk (β k i+b)).le)
  have h2 := weighted_gaussian_removal (p k) (β k) (fun i => ν k i*g k (β k i+b))
    (hp k) (hsum k) hM (fun i => by
      rw [abs_mul]
      exact (mul_le_of_le_one_left (abs_nonneg (g k (β k i+b))) (hν k i)).trans (hg k _)) (s k) b D hb
  have hsum' : (∑ i,p k i*(C*Real.exp (-((β k i+b)*s k)^2/2)*(ν k i*g k (β k i+b)))) =
      C*(∑ i,p k i*Real.exp (-((β k i+b)*s k)^2/2)*(ν k i*g k (β k i+b))) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [hsum'] at h1
  have h2' := mul_le_mul_of_nonneg_left h2 hC
  have htri := abs_sub_le (∑ i,p k i*(ν k i*f k (β k i+b)))
    (C*(∑ i,p k i*Real.exp (-((β k i+b)*s k)^2/2)*(ν k i*g k (β k i+b))))
    (C*(∑ i,p k i*(ν k i*g k (β k i+b))))
  rw [← mul_sub,abs_mul,abs_of_nonneg hC] at htri
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
