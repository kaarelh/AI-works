import NeuralGeneralization.OnlineLowerTanhProductLaplace
import NeuralGeneralization.OnlineLowerTanhSineIntegrable

/-! # Dimension-sharp tails of every fixed derivative kernel -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma reciprocal_sinh_tail {b t : ℝ} (hb : 0 < b) (ht : 1 ≤ t) :
    1/Real.sinh (b*t) ≤ (2/b)*Real.exp (-(b/2)*t) := by
  have ht0 : 0 < t := by linarith
  have hs := sinh_exp_lower (b*t) (by positivity)
  have hspos := Real.sinh_pos_iff.mpr (mul_pos hb ht0)
  apply (div_le_iff₀ hspos).mpr
  have hm := mul_le_mul_of_nonneg_left hs
    (show 0 ≤ (2/b)*Real.exp (-(b/2)*t) by positivity)
  have he : ((2/b)*Real.exp (-(b/2)*t))*(b*t/2*Real.exp (b*t/2)) = t := by
    rw [show ((2/b)*Real.exp (-(b/2)*t))*(b*t/2*Real.exp (b*t/2)) =
      t*(Real.exp (-(b/2)*t)*Real.exp (b*t/2)) by field_simp]
    rw [← Real.exp_add, show -(b/2)*t+b*t/2=0 by ring, Real.exp_zero,mul_one]
  rw [he] at hm
  exact ht.trans hm

lemma polynomial_exponential_bound (j : ℕ) {c t : ℝ} (hc : 0 < c) (ht : 0 ≤ t) :
    t^j*Real.exp (-c*t) ≤ (j.factorial:ℝ)/c^j := by
  have h := Real.pow_div_factorial_le_exp (c*t) (mul_nonneg hc.le ht) j
  have hf : (0:ℝ) < j.factorial := by positivity
  have hcp : 0 < c^j := pow_pos hc _
  have h1 := (div_le_iff₀ hf).mp h
  rw [mul_pow] at h1
  have h2 := mul_le_mul_of_nonneg_right h1 (Real.exp_pos (-c*t)).le
  have he : Real.exp (c*t)*Real.exp (-c*t) = 1 := by
    rw [← Real.exp_add]; simp
  apply (le_div_iff₀ hcp).mpr
  have hr : Real.exp (c*t)*(j.factorial:ℝ)*Real.exp (-c*t) = j.factorial := by
    calc
      _ = (j.factorial:ℝ)*(Real.exp (c*t)*Real.exp (-c*t)) := by ring
      _ = _ := by rw [he,mul_one]
  rw [hr] at h2
  nlinarith

lemma polynomial_sinh_tail (j : ℕ) {b t : ℝ} (hb : 0 < b) (ht : 1 ≤ t) :
    t^j/Real.sinh (b*t) ≤ ((2/b)*((j.factorial:ℝ)/(b/4)^j))*Real.exp (-(b/4)*t) := by
  have hk := mul_le_mul_of_nonneg_left (reciprocal_sinh_tail hb ht)
    (pow_nonneg (show 0 ≤ t by linarith) j)
  have hp := polynomial_exponential_bound j (show 0 < b/4 by positivity) (show 0 ≤ t by linarith)
  have hm := mul_le_mul_of_nonneg_left hp
    (show 0 ≤ (2/b)*Real.exp (-(b/4)*t) by positivity)
  have hexp : Real.exp (-(b/2)*t) = Real.exp (-(b/4)*t)*Real.exp (-(b/4)*t) := by
    rw [← Real.exp_add]
    congr 1
    ring
  rw [hexp] at hk
  simp only [div_eq_mul_inv] at hk hm ⊢
  nlinarith

/-- Tail control is uniform over all incoming amplitudes, not merely over
bounded alphabets. The factor sqrt(n) is retained. -/
theorem parity_kernel_moment_tail {n : ℕ} (hn : 0 < n) (u : Fin n → ℝ)
    (j : ℕ) {b T : ℝ} (hb : 0 < b) (hT : 1 ≤ T) :
    IntegrableOn (fun t : ℝ => t^j*paritySineProduct u t/Real.sinh (b*t)) (Ioi T) ∧
      Real.sqrt (n:ℝ)*(∫ t : ℝ in Ioi T, t^j*paritySineProduct u t/Real.sinh (b*t)) ≤
        ((2/b)*((j.factorial:ℝ)/(b/4)^j))*(Real.pi/(b/8))*Real.exp (-(b/8)*T) := by
  let C : ℝ := (2/b)*((j.factorial:ℝ)/(b/4)^j)
  have hC : 0 ≤ C := by dsimp [C]; positivity
  have hc : 0 < b/8 := by positivity
  obtain ⟨hi,hbound⟩ := paritySineProduct_laplace hn u (b/8) hc
  have hsub : Ioi T ⊆ Ioi (0:ℝ) := by intro t ht; simp only [mem_Ioi] at *; linarith
  have hpoint (t : ℝ) (ht : t ∈ Ioi T) :
      t^j*paritySineProduct u t/Real.sinh (b*t) ≤
        (C*Real.exp (-(b/8)*T))*(Real.exp (-(b/8)*t)*paritySineProduct u t) := by
    change T < t at ht
    have htt : 1 ≤ t := hT.trans ht.le
    have hk := mul_le_mul_of_nonneg_right (polynomial_sinh_tail j hb htt)
      (paritySineProduct_nonneg u t)
    have he : Real.exp (-(b/4)*t) = Real.exp (-(b/8)*t)*Real.exp (-(b/8)*t) := by
      rw [← Real.exp_add]; congr 1; ring
    rw [he] at hk
    have hmono : Real.exp (-(b/8)*t) ≤ Real.exp (-(b/8)*T) := by
      apply Real.exp_le_exp.mpr
      nlinarith [ht.le]
    have hm := mul_le_mul_of_nonneg_left hmono
      (show 0 ≤ C*Real.exp (-(b/8)*t)*paritySineProduct u t by positivity [paritySineProduct_nonneg u t])
    dsimp [C] at *
    simp only [div_eq_mul_inv] at hk hm ⊢
    nlinarith
  have hnon (t : ℝ) (ht : t ∈ Ioi T) : 0 ≤ t^j*paritySineProduct u t/Real.sinh (b*t) := by
    have ht0 : 0 < t := lt_of_lt_of_le (by norm_num : (0:ℝ)<1) (hT.trans ht.le)
    exact div_nonneg (mul_nonneg (pow_nonneg ht0.le _) (paritySineProduct_nonneg u t))
      (Real.sinh_pos_iff.mpr (mul_pos hb ht0)).le
  have hdom := (hi.mono_set hsub).const_mul (C*Real.exp (-(b/8)*T))
  have hmeas : AEStronglyMeasurable (fun t : ℝ => t^j*paritySineProduct u t/Real.sinh (b*t))
      (volume.restrict (Ioi T)) := by
    apply Measurable.aestronglyMeasurable
    exact ((by fun_prop : Measurable (fun t : ℝ => t^j)).mul
      (continuous_paritySineProduct u).measurable).div (by fun_prop)
  have hit : IntegrableOn (fun t : ℝ => t^j*paritySineProduct u t/Real.sinh (b*t)) (Ioi T) := by
    apply hdom.mono' hmeas
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    rw [Real.norm_eq_abs,abs_of_nonneg (hnon t ht)]
    exact hpoint t ht
  refine ⟨hit,?_⟩
  have hle := integral_mono_ae hit hdom (by
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    exact hpoint t ht)
  rw [integral_const_mul] at hle
  have hset := setIntegral_mono_set hi
    (Eventually.of_forall (fun t => mul_nonneg (Real.exp_pos _).le (paritySineProduct_nonneg u t)))
    (Eventually.of_forall (fun t ht => hsub ht))
  have hmul := mul_le_mul_of_nonneg_left hset
    (show 0 ≤ C*Real.exp (-(b/8)*T) by positivity)
  have hh := mul_le_mul_of_nonneg_left (hle.trans hmul) (Real.sqrt_nonneg (n:ℝ))
  have hbnd := mul_le_mul_of_nonneg_left hbound
    (show 0 ≤ C*Real.exp (-(b/8)*T) by positivity)
  dsimp [C] at *
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
