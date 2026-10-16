import Mathlib.MeasureTheory.Measure.Tilted
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Function.SpecialFunctions.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Actual bounded exponential tilts and their entropy

The measure here is the real exponentially tilted measure `μ.tilted V`
from Mathlib, not an abstract entropy certificate. Bounded measurable V
makes its density integrable and normalized, its log-density integrable,
and its relative log-density expectation nonnegative. No Gaussian
assumption is needed, so singular Gaussian reference laws are included.
-/

noncomputable section

open MeasureTheory Real
open scoped ENNReal

namespace NeuralGeneralization.BoundedTilt

variable {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]

/-- The actual partition integral. -/
def partition (V : Ω → ℝ) : ℝ := ∫ x, Real.exp (V x) ∂μ

/-- Density of the exponential tilt relative to its reference law. -/
def density (V : Ω → ℝ) (x : Ω) : ℝ := Real.exp (V x) / partition μ V

lemma integrable_exp_of_bounded (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    Integrable (fun x => Real.exp (V x)) μ := by
  apply (integrable_const (Real.exp G)).mono' hV.exp.aestronglyMeasurable
  apply ae_of_all
  intro x
  rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
  exact Real.exp_le_exp.mpr ((le_abs_self _).trans (hbound x))

lemma partition_pos (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) : 0 < partition μ V :=
  integral_exp_pos (integrable_exp_of_bounded μ V hV hbound)

lemma partition_le_exp (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) : partition μ V ≤ Real.exp G := by
  have h := integral_mono_ae (integrable_exp_of_bounded μ V hV hbound)
    (integrable_const (Real.exp G))
    (ae_of_all μ (fun x => Real.exp_le_exp.mpr ((le_abs_self _).trans (hbound x))))
  simpa only [integral_const, probReal_univ, smul_eq_mul, one_mul, partition] using h

lemma exp_neg_le_partition (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) : Real.exp (-G) ≤ partition μ V := by
  have h := integral_mono_ae (integrable_const (Real.exp (-G)))
    (integrable_exp_of_bounded μ V hV hbound)
    (ae_of_all μ (fun x => Real.exp_le_exp.mpr (abs_le.mp (hbound x)).1))
  simpa only [integral_const, probReal_univ, smul_eq_mul, one_mul, partition] using h

lemma abs_log_partition_le (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) : |Real.log (partition μ V)| ≤ G := by
  have hlo := Real.log_le_log (Real.exp_pos (-G)) (exp_neg_le_partition μ V hV hbound)
  have hhi := Real.log_le_log (partition_pos μ V hV hbound) (partition_le_exp μ V hV hbound)
  rw [Real.log_exp] at hlo hhi
  exact abs_le.mpr ⟨hlo, hhi⟩

/-- Integral Jensen inequality for log, derived from log r ≤ r−1 with
explicit integrability and positive normalizing integral. -/
theorem integral_log_le_log_integral (f : Ω → ℝ)
    (hfpos : ∀ x, 0 < f x) (hf : Integrable f μ)
    (hlog : Integrable (fun x => Real.log (f x)) μ)
    (hmean : 0 < ∫ x, f x ∂μ) :
    (∫ x, Real.log (f x) ∂μ) ≤ Real.log (∫ x, f x ∂μ) := by
  let C : ℝ := ∫ x, f x ∂μ
  have hpoint (x : Ω) : Real.log (f x) - Real.log C ≤ f x / C - 1 := by
    have h := Real.log_le_sub_one_of_pos (div_pos (hfpos x) hmean)
    rwa [Real.log_div (hfpos x).ne' hmean.ne'] at h
  have h := integral_mono_ae
    (hlog.sub (integrable_const (Real.log C)))
    ((hf.div_const C).sub (integrable_const (1 : ℝ)))
    (ae_of_all μ hpoint)
  change (∫ x, Real.log (f x) - Real.log C ∂μ) ≤
    ∫ x, f x / C - 1 ∂μ at h
  rw [integral_sub hlog (integrable_const (Real.log C)),
    integral_sub (hf.div_const C) (integrable_const (1 : ℝ)), integral_div] at h
  simp only [integral_const, probReal_univ, smul_eq_mul, one_mul] at h
  have hC : (∫ x, f x ∂μ) / C = 1 := div_self hmean.ne'
  rw [hC, sub_self] at h
  exact sub_nonpos.mp h

lemma density_pos (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) (x : Ω) : 0 < density μ V x :=
  div_pos (Real.exp_pos _) (partition_pos μ V hV hbound)

lemma integrable_density (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) : Integrable (density μ V) μ :=
  (integrable_exp_of_bounded μ V hV hbound).div_const _

lemma integral_density (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) : ∫ x, density μ V x ∂μ = 1 := by
  simp only [density, integral_div]
  exact div_self (partition_pos μ V hV hbound).ne'

lemma log_density (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) (x : Ω) :
    Real.log (density μ V x) = V x - Real.log (partition μ V) := by
  rw [density, Real.log_div (Real.exp_pos _).ne' (partition_pos μ V hV hbound).ne',
    Real.log_exp]

/-- Nonnegativity of entropy for an actual normalized positive density. -/
theorem entropy_nonneg_of_density (rho : Ω → ℝ)
    (hpositive : ∀ᵐ x ∂μ, 0 < rho x) (hρ : Integrable rho μ)
    (hnormalized : ∫ x, rho x ∂μ = 1)
    (hentropy : Integrable (fun x => rho x * Real.log (rho x)) μ) :
    0 ≤ ∫ x, rho x * Real.log (rho x) ∂μ := by
  have hscalar : ∀ᵐ x ∂μ, rho x - 1 ≤ rho x * Real.log (rho x) := by
    filter_upwards [hpositive] with x hx
    have h := mul_le_mul_of_nonneg_left (Real.one_sub_inv_le_log_of_pos hx) hx.le
    simpa only [mul_sub, mul_one, mul_inv_cancel₀ hx.ne'] using h
  calc
    0 = ∫ x, rho x - 1 ∂μ := by
      rw [integral_sub hρ (integrable_const (1 : ℝ)), hnormalized]
      simp
    _ ≤ ∫ x, rho x * Real.log (rho x) ∂μ :=
      integral_mono_ae (hρ.sub (integrable_const (1 : ℝ))) hentropy hscalar

lemma integrable_density_mul_potential (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    Integrable (fun x => density μ V x * V x) μ := by
  apply (integrable_density μ V hV hbound).mul_bdd hV.aestronglyMeasurable
  exact ae_of_all μ (fun x => by simpa only [Real.norm_eq_abs] using hbound x)

lemma integrable_density_mul_log_density (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    Integrable (fun x => density μ V x * Real.log (density μ V x)) μ := by
  have heq : (fun x => density μ V x * Real.log (density μ V x)) =
      fun x => density μ V x * V x - density μ V x * Real.log (partition μ V) := by
    funext x
    rw [log_density μ V hV hbound, mul_sub]
  rw [heq]
  exact (integrable_density_mul_potential μ V hV hbound).sub
    ((integrable_density μ V hV hbound).mul_const _)

/-- Exact entropy formula for the bounded density, with all integrability
proved from boundedness and measurability. -/
theorem density_entropy_identity (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    (∫ x, density μ V x * Real.log (density μ V x) ∂μ) =
      (∫ x, density μ V x * V x ∂μ) - Real.log (partition μ V) := by
  have heq : (fun x => density μ V x * Real.log (density μ V x)) =
      fun x => density μ V x * V x - density μ V x * Real.log (partition μ V) := by
    funext x
    rw [log_density μ V hV hbound, mul_sub]
  rw [heq, integral_sub (integrable_density_mul_potential μ V hV hbound)
    ((integrable_density μ V hV hbound).mul_const _), integral_mul_const,
    integral_density μ V hV hbound, one_mul]

theorem density_entropy_nonneg (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    0 ≤ ∫ x, density μ V x * Real.log (density μ V x) ∂μ :=
  entropy_nonneg_of_density μ (density μ V)
    (ae_of_all μ (density_pos μ V hV hbound))
    (integrable_density μ V hV hbound) (integral_density μ V hV hbound)
    (integrable_density_mul_log_density μ V hV hbound)

/-- The exponential tilt is a genuine probability measure. -/
theorem tilted_probability (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) : IsProbabilityMeasure (μ.tilted V) :=
  isProbabilityMeasure_tilted (integrable_exp_of_bounded μ V hV hbound)

/-- The relative log-density is integrable under the actual tilted law,
so the entropy assertions do not rely on totalized nonintegrable integrals. -/
theorem integrable_log_density_tilted (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    Integrable (fun x => Real.log (density μ V x)) (μ.tilted V) := by
  letI : IsProbabilityMeasure (μ.tilted V) := tilted_probability μ V hV hbound
  have hintV : Integrable V (μ.tilted V) := by
    apply (integrable_const G).mono' hV.aestronglyMeasurable
    exact ae_of_all _ (fun x => by simpa only [Real.norm_eq_abs] using hbound x)
  have heq : (fun x => Real.log (density μ V x)) =
      fun x => V x - Real.log (partition μ V) := by
    funext x
    exact log_density μ V hV hbound x
  rw [heq]
  exact hintV.sub (integrable_const _)

/-- The logarithmic density is the logarithm of the actual Radon--Nikodym
derivative, almost everywhere under the tilted law itself. -/
theorem log_density_ae_log_rnDeriv (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    (fun x => Real.log (density μ V x)) =ᵐ[μ.tilted V]
      (fun x => Real.log (((μ.tilted V).rnDeriv μ x).toReal)) := by
  have h := (tilted_absolutelyContinuous μ V).ae_eq
    (log_rnDeriv_tilted_left_self (integrable_exp_of_bounded μ V hV hbound))
  filter_upwards [h] with x hx
  rw [log_density μ V hV hbound]
  exact hx.symm

theorem integrable_log_rnDeriv_tilted (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    Integrable (fun x => Real.log (((μ.tilted V).rnDeriv μ x).toReal)) (μ.tilted V) :=
  (integrable_log_density_tilted μ V hV hbound).congr
    (log_density_ae_log_rnDeriv μ V hV hbound)

/-- Hence the entropy integral is literally the relative log-likelihood
integral, not an unrelated functional called entropy. -/
theorem entropy_eq_integral_log_rnDeriv (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    (∫ x, Real.log (density μ V x) ∂(μ.tilted V)) =
      ∫ x, Real.log (((μ.tilted V).rnDeriv μ x).toReal) ∂(μ.tilted V) :=
  integral_congr_ae (log_density_ae_log_rnDeriv μ V hV hbound)

omit [IsProbabilityMeasure μ] in
/-- The density formulas above refer to the actual tilted-measure expectation. -/
theorem integral_tilted_eq_density (V F : Ω → ℝ) :
    (∫ x, F x ∂(μ.tilted V)) = ∫ x, density μ V x * F x ∂μ := by
  simpa only [density, partition, smul_eq_mul] using integral_tilted V F

/-- Nonnegative relative log-density expectation under the actual tilt. -/
theorem tilted_entropy_nonneg (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    0 ≤ ∫ x, Real.log (density μ V x) ∂(μ.tilted V) := by
  rw [integral_tilted_eq_density]
  exact density_entropy_nonneg μ V hV hbound

/-- Exact entropy identity under the actual tilted probability measure. -/
theorem tilted_entropy_identity (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    (∫ x, Real.log (density μ V x) ∂(μ.tilted V)) =
      (∫ x, V x ∂(μ.tilted V)) - Real.log (partition μ V) := by
  rw [integral_tilted_eq_density, integral_tilted_eq_density]
  exact density_entropy_identity μ V hV hbound

end NeuralGeneralization.BoundedTilt

end
