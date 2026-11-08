import NeuralGeneralization.OnlineLowerTanhAbsoluteMixture
import NeuralGeneralization.OnlineLowerTanhCodeKernel
import NeuralGeneralization.OnlineLowerTanhScalar

/-! # The actual balanced coefficient as a positive rational series -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

theorem balancedParity_sine_integral (r : ℕ) (a : ℝ) :
    balancedParity r a = ∫t : ℝ in Ioi 0, Real.sin (a*t)^(2*r+1)/Real.sinh (Real.pi*t/2) := by
  unfold balancedParity
  rw [parityCorrelation_sine_integral rfl]
  simp only [mul_zero,Real.cos_zero,one_mul,Finset.prod_const,Finset.card_univ,Fintype.card_fin]
  rw [← mul_assoc,← pow_add,show r+r=2*r by omega,pow_mul]
  norm_num
  congr 1
  funext t
  rw [mul_comm t a]

def signedSinePartial (p : ℕ) (a : ℝ) (N : ℕ) (t : ℝ) : ℝ :=
  ∑ n ∈ Finset.range N, sineKernelTerm t n * Real.sin (a*t)^p

theorem signedSinePartial_abs_le (p : ℕ) (a : ℝ) (N : ℕ) (t : ℝ) (ht : 0<t) :
    |signedSinePartial p a N t| ≤ absoluteSineKernel p a t := by
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  have hnon (n) : 0≤sineKernelTerm t n := by unfold sineKernelTerm; positivity
  simp_rw [abs_mul,abs_of_nonneg (hnon _),abs_pow]
  exact absoluteSinePartial_le p a N t ht

theorem signedSinePartial_tendsto (p : ℕ) (a t : ℝ) (ht : 0<t) :
    Tendsto (fun N => signedSinePartial p a N t) atTop
      (𝓝 (Real.sin (a*t)^p/Real.sinh (Real.pi*t/2))) := by
  have h := ((sineKernelTerm_hasSum t ht).mul_right (Real.sin (a*t)^p)).tendsto_sum_nat
  simpa only [signedSinePartial,one_div,mul_comm,div_eq_mul_inv,one_mul] using h

/-- The sum is over positive Laplace integrals for positive gain. -/
theorem balancedParity_laplace_hasSum (r : ℕ) (a : ℝ) (ha : 0<a) :
    HasSum (fun n => 2*laplaceSinePower (2*r+1) (sineDecay n) a) (balancedParity r a) := by
  have hd := tendsto_integral_of_dominated_convergence (absoluteSineKernel (2*r+1) a)
    (fun N => (show Continuous (signedSinePartial (2*r+1) a N) by
      unfold signedSinePartial sineKernelTerm; fun_prop).aestronglyMeasurable)
    (absoluteSineKernel_integrable (2*r+1) (by omega) a)
    (fun N => by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      simpa only [Real.norm_eq_abs] using signedSinePartial_abs_le (2*r+1) a N t ht)
    (by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      exact signedSinePartial_tendsto (2*r+1) a t ht)
  have hfin (N : ℕ) : (∫t : ℝ in Ioi 0,signedSinePartial (2*r+1) a N t) =
      ∑ n ∈ Finset.range N, 2*laplaceSinePower (2*r+1) (sineDecay n) a := by
    unfold signedSinePartial
    rw [integral_finsetSum]
    · apply Finset.sum_congr rfl
      intro n _
      unfold sineKernelTerm laplaceSinePower
      simp_rw [mul_assoc]
      rw [integral_const_mul]
    · intro n _
      simpa only [sineKernelTerm,mul_assoc] using
        (integrable_laplace_sinePower (2*r+1) (sineDecay n) a (sineDecay_pos n)).const_mul 2
  simp_rw [hfin] at hd
  rw [← balancedParity_sine_integral] at hd
  have hnon (n) : 0≤2*laplaceSinePower (2*r+1) (sineDecay n) a := by
    have h := laplace_odd_sinePower_pos r a (sineDecay n) ha (sineDecay_pos n)
    exact mul_nonneg (by norm_num) h.le
  exact (hasSum_iff_tendsto_nat_of_nonneg hnon _).mpr hd

/-- Explicit positive rational summands, with the original actual tanh
coefficient on the right-hand side. -/
theorem balancedParity_positive_series (r : ℕ) (a : ℝ) (ha : 0<a) :
    HasSum (fun l => 2*((2*r+1).factorial:ℝ)*a^(2*r+1) /
      ∏j∈Finset.range (r+1), ((sineDecay l)^2+(2*(j:ℝ)+1)^2*a^2)) (balancedParity r a) := by
  have h := balancedParity_laplace_hasSum r a ha
  convert h using 1
  funext l
  have hprod := laplace_odd_sinePower_product r a (sineDecay l) (sineDecay_pos l)
  change laplaceSinePower (2*r+1) (sineDecay l) a = _ at hprod
  rw [hprod]
  push_cast
  ring

end NeuralGeneralization.OnlineLowerTanh
