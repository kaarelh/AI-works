import NeuralGeneralization.OnlineLowerTanhResidualConcreteCell
import NeuralGeneralization.OnlineLowerTanhResidualZero
import NeuralGeneralization.OnlineLowerTanhResidualSeries
import NeuralGeneralization.OnlineLowerAffineIntegral

/-! # Exact transport of the physical signed kernel to its Gaussian cells -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def residualRawKernel {n : ℕ} (u : Fin n → ℝ) (B θ : ℝ) (K : ℝ → ℝ) (t : ℝ) : ℝ :=
  Real.sin (B*t+θ)*(∏ i, Real.sin (u i*t))*K t

lemma residualRawKernel_integrable {n : ℕ} (hn : 0 < n) (u : Fin n → ℝ)
    (B θ : ℝ) (j : ℕ) :
    IntegrableOn (residualRawKernel u B θ (residualDerivativeKernel j)) (Ioi 0) := by
  have hi := integrable_parity_kernel_moment hn u j (by positivity : 0 < Real.pi/2)
  have he : (fun t : ℝ => t^j*paritySineProduct u t/Real.sinh ((Real.pi/2)*t)) =
      (fun t => t^j*paritySineProduct u t/Real.sinh (Real.pi*t/2)) := by funext t; congr 2 <;> ring
  rw [he] at hi
  apply hi.mono'
  · unfold residualRawKernel
    have hm : Measurable (fun t : ℝ => Real.sin (B*t+θ)*(∏ i, Real.sin (u i*t))) := by fun_prop
    exact (hm.mul (residualDerivativeKernel_measurable j)).aestronglyMeasurable
  · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    have ht0 : 0 < t := ht
    have hsin : 0 < Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
    simp only [residualRawKernel,residualDerivativeKernel,Real.norm_eq_abs,abs_mul,abs_div,
      Finset.abs_prod,abs_of_pos hsin,abs_of_nonneg (pow_nonneg ht0.le j)]
    have hp : (∏ i, |Real.sin (u i*t)|) = paritySineProduct u t := by
      unfold paritySineProduct
      apply Finset.prod_congr rfl
      intro i _
      rw [mul_comm]
    rw [hp]
    have hh := mul_le_of_le_one_left (paritySineProduct_nonneg u t) (Real.abs_sin_le_one (B*t+θ))
    have hm := mul_le_mul_of_nonneg_right hh
      (div_nonneg (pow_nonneg ht0.le j) hsin.le)
    convert hm using 1 <;> first | ring | rfl

lemma residualRawKernel_parity {n : ℕ} (u : Fin n → ℝ) (B : ℝ) :
    parityCorrelation u B = ∫ t : ℝ in Ioi 0,
      residualRawKernel u B ((n:ℝ)*Real.pi/2) (residualDerivativeKernel 0) t := by
  rw [parityCorrelation_sine_integral_all]
  apply integral_congr_ae
  exact Eventually.of_forall (fun t => by
    simp only [residualRawKernel,residualDerivativeKernel,pow_zero]
    have hp : (∏ i, Real.sin (t*u i)) = ∏ i, Real.sin (u i*t) := by
      apply Finset.prod_congr rfl
      intro i _
      rw [mul_comm]
    rw [hp]
    ring)

lemma residual_cell_endpoints {A : ℝ} (hA : A ≠ 0) (l : ℕ) :
    residualPeak A l-Real.pi/(2*A)=(l:ℝ)*(Real.pi/A) ∧
      residualPeak A l+Real.pi/(2*A)=((l:ℝ)+1)*(Real.pi/A) := by
  unfold residualPeak periodicFrequency
  constructor <;> field_simp <;> ring

/-- Exact full-cell substitution; the only discarded endpoints are singleton
sets of Lebesgue measure zero, handled by the affine integration theorem. -/
theorem residual_cell_integral {n : ℕ} {A s : ℝ} (hA : 0 < A) (hs : 0 < s)
    (q : Fin n → ℕ) (hq : ∀ i, Odd (q i)) (d : Fin n → ℝ)
    (l : ℕ) (ρ B θ : ℝ) (K : ℝ → ℝ) :
    (∫ t : ℝ in Ioc ((l:ℝ)*(Real.pi/A)) (((l:ℝ)+1)*(Real.pi/A)) ∩ Ici ρ,
      residualRawKernel (fun i => A*(q i:ℝ)+d i) B θ K t) =
      s*(-1:ℝ)^((∑ i, (q i-1)/2)+n*l)*
        ∫ y : ℝ, Real.sin (B*(residualPeak A l+y*s)+θ)*
          residualCellWindow (fun i => (q i:ℝ)) d A s l ρ K y := by
  have hend := residual_cell_endpoints hA.ne' l
  rw [← hend.1,← hend.2,setIntegral_truncated_cell_closed _ _ _ _ _ hs]
  rw [mul_assoc]
  congr 1
  rw [← integral_const_mul]
  apply integral_congr_ae
  apply Eventually.of_forall
  intro y
  have he : residualPeak A l+s*y = residualPeak A l+y*s := by ring
  simp only [he,Set.indicator,Set.mem_setOf_eq,residualCellWindow]
  split_ifs with h
  · unfold residualRawKernel
    rw [residual_peak_product_odd hA.ne' q hq]
    ring
  · ring

end NeuralGeneralization.OnlineLowerTanh
