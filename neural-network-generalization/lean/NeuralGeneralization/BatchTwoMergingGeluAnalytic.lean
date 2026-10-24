import NeuralGeneralization.BatchTwoMergingPolynomialMain
import Mathlib.Probability.CDF
import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Analysis.Complex.ExponentialBounds

/-! Exact GELU, defined using the standard normal distribution function. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators NNReal
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoMerging

def normalCDF (x : ℝ) : ℝ := cdf (gaussianReal 0 1) x
def normalPDF (x : ℝ) : ℝ := gaussianPDFReal 0 1 x
def gelu (x : ℝ) : ℝ := x*normalCDF x

theorem normalCDF_bounds (x : ℝ) : 0≤normalCDF x ∧ normalCDF x≤1 :=
  ⟨cdf_nonneg _ _,cdf_le_one _ _⟩

theorem normalCDF_eq_integral (x : ℝ) : normalCDF x=∫ t in Iic x,normalPDF t := by
  rw [normalCDF,cdf_eq_real,Measure.real,gaussianReal_apply_eq_integral 0 (by norm_num)]
  exact ENNReal.toReal_ofReal (integral_nonneg (fun t=>gaussianPDFReal_nonneg _ _ _))

theorem continuous_normalPDF : Continuous normalPDF := by
  unfold normalPDF gaussianPDFReal
  fun_prop

theorem integrable_normalPDF : Integrable normalPDF := integrable_gaussianPDFReal 0 1

theorem normalCDF_interval (a x : ℝ) :
    normalCDF x=normalCDF a+∫ t in a..x,normalPDF t := by
  rw [normalCDF_eq_integral,normalCDF_eq_integral,
    ←intervalIntegral.integral_Iic_sub_Iic integrable_normalPDF.integrableOn integrable_normalPDF.integrableOn]
  ring

theorem hasDerivAt_normalCDF (x : ℝ) : HasDerivAt normalCDF (normalPDF x) x := by
  have h := intervalIntegral.integral_hasDerivAt_right
    (continuous_normalPDF.intervalIntegrable 0 x)
    continuous_normalPDF.aestronglyMeasurable.stronglyMeasurableAtFilter
    continuous_normalPDF.continuousAt
  have hh := h.const_add (normalCDF 0)
  have he : normalCDF=(fun u=>normalCDF 0+∫t in 0..u,normalPDF t) :=
    funext (normalCDF_interval 0)
  rw [he]
  exact hh

theorem normalCDF_neg (x : ℝ) : normalCDF (-x)=1-normalCDF x := by
  let μ := gaussianReal 0 1
  letI : NullSingletonClass μ := nullSingletonClass_gaussianReal (by norm_num)
  have hmap : μ.map (fun t:ℝ=>-t)=μ := by simp [μ,gaussianReal_map_neg]
  have he : μ (Iic (-x))=μ (Ici x) := by
    calc
      _=(μ.map (fun t:ℝ=>-t)) (Iic (-x)) := congrArg (fun ν:Measure ℝ=>ν (Iic (-x))) hmap.symm
      _=μ (Ici x) := by
        rw [Measure.map_apply measurable_neg measurableSet_Iic]
        congr 1
        ext t
        simp
  have hc : (Iio x)ᶜ=Ici x := compl_Iio
  have heq : μ.real (Iio x)=μ.real (Iic x) := by
    exact congrArg ENNReal.toReal (measure_congr Iio_ae_eq_Iic)
  unfold normalCDF
  rw [cdf_eq_real,cdf_eq_real]
  change μ.real (Iic (-x))=1-μ.real (Iic x)
  unfold Measure.real
  rw [he]
  change μ.real (Ici x)=1-μ.real (Iic x)
  rw [←hc,probReal_compl_eq_one_sub measurableSet_Iio,heq]

@[simp] theorem normalCDF_zero : normalCDF 0=1/2 := by
  have h := normalCDF_neg 0
  simp only [neg_zero] at h
  linarith

@[simp] theorem gelu_zero : gelu 0=0 := by simp [gelu]

theorem gelu_abs_le (x : ℝ) : |gelu x|≤|x| := by
  rw [gelu,abs_mul,abs_of_nonneg (normalCDF_bounds x).1]
  simpa using mul_le_mul_of_nonneg_left (normalCDF_bounds x).2 (abs_nonneg x)

theorem hasDerivAt_gelu (x : ℝ) :
    HasDerivAt gelu (normalCDF x+x*normalPDF x) x := by
  convert (hasDerivAt_id' x).mul (hasDerivAt_normalCDF x) using 1 <;>
    first | rfl | simp [gelu,Pi.mul_apply]

theorem normalPDF_formula (x : ℝ) :
    normalPDF x=(Real.sqrt (2*Real.pi))⁻¹*Real.exp (-x^2/2) := by
  simp [normalPDF,gaussianPDFReal]

theorem normalPDF_monomial_bound (x : ℝ) :
    |x| *normalPDF x≤1 ∧ x^2*normalPDF x≤1 := by
  have hs : 1≤Real.sqrt (2*Real.pi) := by
    have hsq := Real.sq_sqrt (show 0≤2*Real.pi by positivity)
    nlinarith [Real.two_le_pi,Real.sqrt_nonneg (2*Real.pi)]
  have hsinv : (Real.sqrt (2*Real.pi))⁻¹≤1 := inv_le_one_of_one_le₀ hs
  have hsmall : |x|≤Real.exp (x^2/2) := by
    have he := Real.add_one_le_exp (x^2/2)
    nlinarith [sq_nonneg (|x|-1),sq_abs x]
  have hlarge : x^2≤Real.exp (x^2/2) := by
    have he := Real.two_mul_le_exp (x:=x^2/2)
    nlinarith
  have hmul (a : ℝ) (ha : 0≤a) (hb : a≤Real.exp (x^2/2)) :
      a*normalPDF x≤1 := by
    rw [normalPDF_formula]
    have hprod : a*Real.exp (-x^2/2)≤1 := by
      have he := mul_le_mul_of_nonneg_right hb (Real.exp_pos (-x^2/2)).le
      have heq : Real.exp (x^2/2)*Real.exp (-x^2/2)=1 := by
        rw [←Real.exp_add]
        convert Real.exp_zero using 1 <;> ring
      rw [heq] at he
      exact he
    have hh := mul_le_mul hsinv hprod (by positivity : 0≤a*Real.exp (-x^2/2)) (by norm_num : (0:ℝ)≤1)
    nlinarith
  exact ⟨hmul |x| (abs_nonneg x) hsmall,hmul (x^2) (sq_nonneg x) hlarge⟩

theorem gelu_deriv_abs_le (x : ℝ) : |normalCDF x+x*normalPDF x|≤2 := by
  have h := abs_add_le (normalCDF x) (x*normalPDF x)
  rw [abs_of_nonneg (normalCDF_bounds x).1,abs_mul,
    abs_of_nonneg (show 0≤normalPDF x from gaussianPDFReal_nonneg 0 1 x)] at h
  linarith [(normalCDF_bounds x).2,(normalPDF_monomial_bound x).1]

theorem gelu_lipschitz : LipschitzWith 2 gelu := by
  apply lipschitzWith_of_nnnorm_deriv_le (fun x=>(hasDerivAt_gelu x).differentiableAt)
  intro x
  rw [←NNReal.coe_le_coe]
  change |deriv gelu x|≤(2:ℝ)
  rw [(hasDerivAt_gelu x).deriv]
  exact gelu_deriv_abs_le x

end NeuralGeneralization.BatchTwoMerging
