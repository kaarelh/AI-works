import NeuralGeneralization.OnlineLowerTanhResidualTail
import Mathlib.Analysis.SpecificLimits.Normed

/-! # The integrable endpoint at frequency zero -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma paritySineProduct_uniform_bound {n : ℕ} (u : Fin n → ℝ) {M t : ℝ}
    (hu : ∀ i, |u i| ≤ M) (ht : 0 ≤ t) :
    paritySineProduct u t ≤ (M*t)^n := by
  calc
    _ ≤ ∏ i : Fin n, M*t := by
      apply Finset.prod_le_prod (fun i _ => abs_nonneg _)
      intro i _
      have h := Real.abs_sin_le_abs (x := t*u i)
      rw [abs_mul,abs_of_nonneg ht] at h
      exact h.trans (by nlinarith [mul_le_mul_of_nonneg_left (hu i) ht])
    _ = _ := by simp

lemma parity_kernel_near_zero_bound {n : ℕ} (hn : 0 < n) (u : Fin n → ℝ)
    {M b ρ t : ℝ} (hM : 0 ≤ M) (hb : 0 < b) (hρ : 0 ≤ ρ)
    (hu : ∀ i, |u i| ≤ M) (ht : 0 < t) (htρ : t ≤ ρ) :
    paritySineProduct u t/Real.sinh (b*t) ≤ (M/b)*(M*ρ)^(n-1) := by
  have hP := paritySineProduct_uniform_bound u hu ht.le
  have hpow := pow_le_pow_left₀ (mul_nonneg hM ht.le)
    (mul_le_mul_of_nonneg_left htρ hM) (n-1)
  have hn' : n = (n-1)+1 := by omega
  have hp : paritySineProduct u t ≤ M*t*(M*ρ)^(n-1) := by
    calc
      _ ≤ (M*t)^n := hP
      _ = M*t*(M*t)^(n-1) := by conv_lhs => rw [hn']; rw [pow_succ'];
      _ ≤ _ := mul_le_mul_of_nonneg_left hpow (mul_nonneg hM ht.le)
  have hs := Real.self_le_sinh_iff.mpr (mul_pos hb ht).le
  have hc : 0 ≤ (M/b)*(M*ρ)^(n-1) := by positivity
  have hm := mul_le_mul_of_nonneg_left hs hc
  have he : ((M/b)*(M*ρ)^(n-1))*(b*t) = M*t*(M*ρ)^(n-1) := by field_simp
  rw [he] at hm
  exact (div_le_iff₀ (Real.sinh_pos_iff.mpr (mul_pos hb ht))).mpr (hp.trans hm)

/-- The singular hyperbolic kernel costs only one of the vanishing sine
factors. The remaining n−1 factors give exponential decay. -/
theorem parity_kernel_near_zero_integral {n : ℕ} (hn : 0 < n) (u : Fin n → ℝ)
    {M b ρ : ℝ} (hM : 0 ≤ M) (hb : 0 < b) (hρ : 0 ≤ ρ)
    (hu : ∀ i, |u i| ≤ M) :
    IntegrableOn (fun t : ℝ => paritySineProduct u t/Real.sinh (b*t)) (Ioc 0 ρ) ∧
      (∫ t : ℝ in Ioc 0 ρ, paritySineProduct u t/Real.sinh (b*t)) ≤
        ρ*((M/b)*(M*ρ)^(n-1)) := by
  have hc : IntegrableOn (fun _ : ℝ => (M/b)*(M*ρ)^(n-1)) (Ioc 0 ρ) :=
    integrableOn_const (by simp)
  have hi : IntegrableOn (fun t : ℝ => paritySineProduct u t/Real.sinh (b*t)) (Ioc 0 ρ) := by
    apply hc.mono'
    · exact ((continuous_paritySineProduct u).measurable.div (by fun_prop)).aestronglyMeasurable
    · filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
      rw [Real.norm_eq_abs,abs_of_nonneg (div_nonneg (paritySineProduct_nonneg u t)
        (Real.sinh_pos_iff.mpr (mul_pos hb ht.1)).le)]
      exact parity_kernel_near_zero_bound hn u hM hb hρ hu ht.1 ht.2
  refine ⟨hi,?_⟩
  have hh := integral_mono_ae hi hc (by
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
    exact parity_kernel_near_zero_bound hn u hM hb hρ hu ht.1 ht.2)
  simpa only [setIntegral_const, smul_eq_mul, Real.volume_real_Ioc_of_le hρ, sub_zero] using hh

lemma sqrt_mul_geometric_pred_tendsto {r : ℝ} (hr : 0 < r) (hr1 : r < 1) :
    Tendsto (fun n : ℕ => Real.sqrt (n:ℝ)*r^(n-1)) atTop (𝓝 0) := by
  have hmain := (tendsto_self_mul_const_pow_of_lt_one hr.le hr1).div_const r
  simp only [zero_div] at hmain
  apply squeeze_zero' (Eventually.of_forall (fun n => by positivity)) _ hmain
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hnreal : (1:ℝ) ≤ n := by exact_mod_cast hn
  have hs : Real.sqrt (n:ℝ) ≤ n := by
    have hsq := Real.sq_sqrt (show (0:ℝ)≤n by positivity)
    nlinarith [Real.sqrt_nonneg (n:ℝ)]
  have he : (n:ℝ)*r^n/r = (n:ℝ)*r^(n-1) := by
    have hn' : n = (n-1)+1 := by omega
    rw [show r^n=r^(n-1)*r by rw [← pow_succ, ← hn']]
    field_simp
  rw [he]
  exact mul_le_mul_of_nonneg_right hs (pow_nonneg hr.le _)

/-- Absolute integrability holds in every positive dimension, including
even dimensions, for each fixed external-phase derivative. -/
theorem integrable_parity_kernel_moment {n : ℕ} (hn : 0 < n) (u : Fin n → ℝ)
    (j : ℕ) {b : ℝ} (hb : 0 < b) :
    IntegrableOn (fun t : ℝ => t^j*paritySineProduct u t/Real.sinh (b*t)) (Ioi 0) := by
  let M : ℝ := ∑ i, |u i|
  have hM : 0 ≤ M := Finset.sum_nonneg (fun i _ => abs_nonneg _)
  have hu (i : Fin n) : |u i| ≤ M :=
    Finset.single_le_sum (fun k _ => abs_nonneg (u k)) (Finset.mem_univ i)
  have hnear := (parity_kernel_near_zero_integral hn u hM hb (by norm_num : (0:ℝ)≤1) hu).1
  have hjnear : IntegrableOn (fun t : ℝ => t^j*paritySineProduct u t/Real.sinh (b*t)) (Ioc 0 1) := by
    apply hnear.mono'
    · exact ((by fun_prop : Measurable (fun t : ℝ => t^j)).mul
        (continuous_paritySineProduct u).measurable).div (by fun_prop) |>.aestronglyMeasurable
    · filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
      have hs : 0 < Real.sinh (b*t) := Real.sinh_pos_iff.mpr (mul_pos hb ht.1)
      rw [Real.norm_eq_abs,abs_of_nonneg (div_nonneg (mul_nonneg (pow_nonneg ht.1.le j)
        (paritySineProduct_nonneg u t)) hs.le)]
      apply div_le_div_of_nonneg_right _ hs.le
      exact mul_le_of_le_one_left (paritySineProduct_nonneg u t) (pow_le_one₀ ht.1.le ht.2)
  have htail := (parity_kernel_moment_tail hn u j hb (le_refl (1:ℝ))).1
  have hU : Ioc (0:ℝ) 1 ∪ Ioi 1 = Ioi 0 := by
    ext t
    simp only [mem_union,mem_Ioc,mem_Ioi]
    constructor
    · rintro (h|h)
      · exact h.1
      · linarith
    · intro h
      by_cases ht : t ≤ 1
      · exact Or.inl ⟨h,ht⟩
      · exact Or.inr (lt_of_not_ge ht)
  rw [← hU]
  exact integrableOn_union.mpr ⟨hjnear,htail⟩

end NeuralGeneralization.OnlineLowerTanh
