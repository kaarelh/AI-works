import NeuralGeneralization.OnlineLowerTanhCodeScale
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral

/-! # An integrable square-root frequency envelope -/
noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

theorem sqrt_sinh_point_bound (b t : ℝ) (hb : 0<b) (ht : 0<t) :
    Real.sqrt t/Real.sinh (b*t) ≤ (2/b)*(t^(-(1:ℝ)/2)*Real.exp (-(b/2)*t)) := by
  have hs : 0<Real.sinh (b*t) := Real.sinh_pos_iff.mpr (mul_pos hb ht)
  have hroot : 0<Real.sqrt t := Real.sqrt_pos.mpr ht
  have hpow : t^(-(1:ℝ)/2)=(Real.sqrt t)⁻¹ := by
    rw [show -(1:ℝ)/2=-(1/2:ℝ) by ring,Real.rpow_neg ht.le,←Real.sqrt_eq_rpow]
  have hl := sinh_exp_lower (b*t) (mul_pos hb ht).le
  have he : Real.exp (b*t/2)*Real.exp (-(b/2)*t)=1 := by
    rw [←Real.exp_add]
    rw [show b*t/2+ (-(b/2)*t)=0 by ring,Real.exp_zero]
  have hid : (b*t/2*Real.exp (b*t/2))*((2/b)*(t^(-(1:ℝ)/2)*Real.exp (-(b/2)*t)))=Real.sqrt t := by
    rw [hpow]
    calc
      _ = (t*(Real.sqrt t)⁻¹)*(Real.exp (b*t/2)*Real.exp (-(b/2)*t)) := by field_simp
      _ = t/Real.sqrt t := by rw [he];simp [div_eq_mul_inv]
      _ = Real.sqrt t := by apply (div_eq_iff hroot.ne').mpr;simpa only [←pow_two] using (Real.sq_sqrt ht.le).symm
  have hm := mul_le_mul_of_nonneg_right hl
    (show 0≤(2/b)*(t^(-(1:ℝ)/2)*Real.exp (-(b/2)*t)) by positivity)
  rw [hid] at hm
  exact (div_le_iff₀ hs).mpr (by simpa only [mul_comm] using hm)

theorem sqrt_sinh_integrable (b : ℝ) (hb : 0<b) :
    IntegrableOn (fun t:ℝ=>Real.sqrt t/Real.sinh (b*t)) (Ioi 0) := by
  have hi := integrableOn_rpow_mul_exp_neg_mul_rpow
    (p:=(1:ℝ)) (s:=-(1:ℝ)/2) (b:=b/2) (by norm_num) (by norm_num) (by positivity : 0<b/2)
  simp only [Real.rpow_one] at hi
  apply (hi.const_mul (2/b)).mono'
  · exact (by fun_prop : Measurable (fun t:ℝ=>Real.sqrt t/Real.sinh (b*t))).aestronglyMeasurable
  · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    have htpos : 0<t := ht
    rw [Real.norm_eq_abs,abs_of_nonneg (div_nonneg (Real.sqrt_nonneg _) (Real.sinh_pos_iff.mpr (by positivity)).le)]
    exact sqrt_sinh_point_bound b t hb htpos

def sqrtFrequencyKernelConstant : ℝ := ∫t:ℝ in Ioi 0,Real.sqrt t/Real.sinh (Real.pi*t/2)

theorem sqrtFrequencyKernel_integrable :
    IntegrableOn (fun t:ℝ=>Real.sqrt t/Real.sinh (Real.pi*t/2)) (Ioi 0) := by
  simpa only [div_mul_eq_mul_div] using sqrt_sinh_integrable (Real.pi/2) (by positivity)

theorem sqrtFrequencyKernelConstant_nonneg : 0≤sqrtFrequencyKernelConstant := by
  apply integral_nonneg_of_ae
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
  have htpos : 0<t := ht
  exact div_nonneg (Real.sqrt_nonneg _) (Real.sinh_pos_iff.mpr (by positivity)).le

/-- Combining a small-frequency linear bound and a uniform height bound
avoids any logarithmic integration of 1/t. -/
theorem min_linear_height_sqrt (G M E t : ℝ) (hG : 0≤G) (hM:0≤M) (hE:0≤E) (ht:0≤t)
    (hlin:G≤2*M*t) (hheight:G≤E) : G≤Real.sqrt (2*M*E)*Real.sqrt t := by
  have hh := mul_le_mul hlin hheight hG (show 0≤2*M*t by positivity)
  have hs := Real.sqrt_le_sqrt hh
  rw [←pow_two,Real.sqrt_sq hG] at hs
  have he : (2*M*t)*E=(2*M*E)*t := by ring
  rw [he,Real.sqrt_mul (by positivity : 0≤2*M*E)] at hs
  exact hs

/-- An actual off-orientation envelope with height E contributes at most
O(sqrt E) on any bounded positive-frequency interval. -/
theorem kernel_low_frequency_height_bound (G : ℝ→ℝ) (M E T : ℝ)
    (hM:0≤M) (hE:0≤E) (hT:0≤T) (hG:∀t>0,0≤G t)
    (hInt:IntegrableOn (fun t=>G t/Real.sinh (Real.pi*t/2)) (Ioi 0))
    (hlin:∀t>0,G t≤2*M*t) (hheight:∀t∈Ioc 0 T,G t≤E) :
    (∫t:ℝ in Ioc 0 T,G t/Real.sinh (Real.pi*t/2)) ≤
      Real.sqrt (2*M*E)*sqrtFrequencyKernelConstant := by
  have hsub : Ioc 0 T⊆Ioi (0:ℝ) := fun t ht=>ht.1
  have hpoint (t:ℝ) (ht:t∈Ioc 0 T) :
      G t/Real.sinh (Real.pi*t/2) ≤
        Real.sqrt (2*M*E)*(Real.sqrt t/Real.sinh (Real.pi*t/2)) := by
    have hh := min_linear_height_sqrt (G t) M E t (hG t ht.1) hM hE ht.1.le (hlin t ht.1) (hheight t ht)
    have htpos : 0<t := ht.1
    have hd := div_le_div_of_nonneg_right hh (Real.sinh_pos_iff.mpr (by positivity : 0<Real.pi*t/2)).le
    simpa only [mul_div_assoc] using hd
  have hh := integral_mono_ae (hInt.mono_set hsub)
    ((sqrtFrequencyKernel_integrable.mono_set hsub).const_mul (Real.sqrt (2*M*E))) (by
      filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
      exact hpoint t ht)
  rw [integral_const_mul] at hh
  have hwhole := setIntegral_mono_set sqrtFrequencyKernel_integrable
    (by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      have htpos:0<t:=ht
      exact div_nonneg (Real.sqrt_nonneg _) (Real.sinh_pos_iff.mpr (by positivity)).le)
    (Filter.Eventually.of_forall fun t=>show t∈Ioc 0 T→t∈Ioi (0:ℝ) from fun ht=>ht.1)
  exact hh.trans (mul_le_mul_of_nonneg_left hwhole (Real.sqrt_nonneg _))

end NeuralGeneralization.OnlineLowerTanh
