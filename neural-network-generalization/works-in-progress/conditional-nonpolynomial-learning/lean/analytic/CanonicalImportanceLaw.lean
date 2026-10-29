import MeasureQuadratureCube
import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap

/-! The actual importance probability law used for canonical feature maps.
Normalization and the density-independent coefficient bounds are derived from
second-moment integrability. -/

noncomputable section
open MeasureTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

variable {Ω E : Type*} [MeasurableSpace Ω] [NormedAddCommGroup E] [NormedSpace ℝ E]

def canonicalNormalizer (μ : Measure Ω) (e : Ω → E) (k : Ω → ℝ) : ℝ :=
  1+(∫ x, ‖e x‖^2 ∂μ)+(∫ x, (k x)^2 ∂μ)

def canonicalDensity (μ : Measure Ω) (e : Ω → E) (k : Ω → ℝ) (x : Ω) : ℝ :=
  (1+‖e x‖^2+(k x)^2)/canonicalNormalizer μ e k

def canonicalImportanceLaw (μ : Measure Ω) (e : Ω → E) (k : Ω → ℝ) : Measure Ω :=
  μ.withDensity (fun x => ENNReal.ofReal (canonicalDensity μ e k x))

lemma canonicalNormalizer_pos (μ : Measure Ω) (e : Ω → E) (k : Ω → ℝ) :
    0 < canonicalNormalizer μ e k := by
  unfold canonicalNormalizer
  have h0 : (0:ℝ) ≤ ∫ x, ‖e x‖^2 ∂μ := integral_nonneg (fun x => sq_nonneg ‖e x‖)
  have h1 : (0:ℝ) ≤ ∫ x, (k x)^2 ∂μ := integral_nonneg (fun x => sq_nonneg (k x))
  linarith

lemma canonicalDensity_pos (μ : Measure Ω) (e : Ω → E) (k : Ω → ℝ) (x : Ω) :
    0 < canonicalDensity μ e k x :=
  div_pos (by nlinarith [sq_nonneg ‖e x‖, sq_nonneg (k x)])
    (canonicalNormalizer_pos μ e k)

lemma canonicalDensity_integrable (μ : Measure Ω) [IsProbabilityMeasure μ]
    (e : Ω → E) (k : Ω → ℝ)
    (he : Integrable (fun x => ‖e x‖^2) μ) (hk : Integrable (fun x => (k x)^2) μ) :
    Integrable (canonicalDensity μ e k) μ :=
  ((integrable_const (1:ℝ)).add he |>.add hk).div_const _

lemma canonicalDensity_integral (μ : Measure Ω) [IsProbabilityMeasure μ]
    (e : Ω → E) (k : Ω → ℝ)
    (he : Integrable (fun x => ‖e x‖^2) μ) (hk : Integrable (fun x => (k x)^2) μ) :
    ∫ x, canonicalDensity μ e k x ∂μ = 1 := by
  simp only [canonicalDensity]
  rw [integral_div,
    integral_add (f:=fun x => 1+‖e x‖^2) (g:=fun x => (k x)^2)
      ((integrable_const (1:ℝ)).add he) hk,
    integral_add (f:=fun _ => (1:ℝ)) (g:=fun x => ‖e x‖^2) (integrable_const (1:ℝ)) he]
  simp only [integral_const, probReal_univ, smul_eq_mul, one_mul]
  exact div_self (canonicalNormalizer_pos μ e k).ne'

/-- The importance measure is proved to be a probability law. -/
theorem canonicalImportanceLaw_probability (μ : Measure Ω) [IsProbabilityMeasure μ]
    (e : Ω → E) (k : Ω → ℝ)
    (he : Integrable (fun x => ‖e x‖^2) μ) (hk : Integrable (fun x => (k x)^2) μ) :
    IsProbabilityMeasure (canonicalImportanceLaw μ e k) := by
  constructor
  rw [canonicalImportanceLaw, withDensity_apply _ MeasurableSet.univ, Measure.restrict_univ,
    ← ofReal_integral_eq_lintegral_ofReal (canonicalDensity_integrable μ e k he hk)
      (Filter.Eventually.of_forall fun x => (canonicalDensity_pos μ e k x).le),
    canonicalDensity_integral μ e k he hk, ENNReal.ofReal_one]

lemma canonical_projection_coefficient_bound (μ : Measure Ω) (e : Ω → E)
    (k : Ω → ℝ) (x : Ω) :
    ‖(k x/canonicalDensity μ e k x) • e x‖ ≤ canonicalNormalizer μ e k/2 := by
  let Z := canonicalNormalizer μ e k
  have hZ : 0 < Z := canonicalNormalizer_pos μ e k
  have hp := canonicalDensity_pos μ e k x
  have hden : 0 < 1+‖e x‖^2+(k x)^2 := by positivity
  rw [norm_smul, Real.norm_eq_abs, abs_div, abs_of_pos hp]
  change |k x| / ((1+‖e x‖^2+(k x)^2)/Z) * ‖e x‖ ≤ Z/2
  have hid : |k x| / ((1+‖e x‖^2+(k x)^2)/Z) * ‖e x‖ =
      Z*(|k x| * ‖e x‖)/(1+‖e x‖^2+(k x)^2) := by field_simp
  rw [hid]
  apply (div_le_iff₀ hden).mpr
  have hs := sq_nonneg (|k x|-‖e x‖)
  have habs := sq_abs (k x)
  nlinarith [mul_nonneg hZ.le hs]

lemma canonical_norm_coefficient_bound (μ : Measure Ω) (e : Ω → E)
    (k : Ω → ℝ) (x : Ω) :
    0 ≤ (k x)^2/canonicalDensity μ e k x ∧
      (k x)^2/canonicalDensity μ e k x ≤ canonicalNormalizer μ e k := by
  have hp := canonicalDensity_pos μ e k x
  refine ⟨div_nonneg (sq_nonneg _) hp.le,?_⟩
  apply (div_le_iff₀ hp).mpr
  unfold canonicalDensity
  have hZ := canonicalNormalizer_pos μ e k
  rw [mul_div_cancel₀ _ hZ.ne']
  nlinarith [sq_nonneg ‖e x‖]

lemma canonicalDensity_measurable (μ : Measure Ω) (e : Ω → E) (k : Ω → ℝ)
    (he : Measurable (fun x => ‖e x‖^2)) (hk : Measurable (fun x => (k x)^2)) :
    Measurable (canonicalDensity μ e k) :=
  ((measurable_const.add he).add hk).div_const _

/-- Reweighting by the reciprocal density preserves the actual Bochner mean,
including vector-valued means. The density is strictly positive everywhere. -/
theorem integral_canonical_reweight {F : Type*} [NormedAddCommGroup F]
    [NormedSpace ℝ F] (μ : Measure Ω) (e : Ω → E) (k : Ω → ℝ)
    (he : Measurable (fun x => ‖e x‖^2)) (hk : Measurable (fun x => (k x)^2))
    (f : Ω → F) :
    (∫ x, (canonicalDensity μ e k x)⁻¹ • f x ∂canonicalImportanceLaw μ e k) =
      ∫ x, f x ∂μ := by
  rw [canonicalImportanceLaw, integral_withDensity_eq_integral_toReal_smul
    (canonicalDensity_measurable μ e k he hk).ennreal_ofReal
    (Filter.Eventually.of_forall fun _ => ENNReal.ofReal_lt_top)]
  apply integral_congr_ae
  exact Filter.Eventually.of_forall (fun x => by
    dsimp only
    rw [ENNReal.toReal_ofReal (canonicalDensity_pos μ e k x).le,
      smul_smul, mul_inv_cancel₀ (canonicalDensity_pos μ e k x).ne', one_smul])

lemma canonicalNormalizer_bound (μ : Measure Ω) (e : Ω → E) (k : Ω → ℝ)
    (M K : ℝ) (he : (∫ x, ‖e x‖^2 ∂μ) ≤ M) (hk : (∫ x, (k x)^2 ∂μ) ≤ K) :
    canonicalNormalizer μ e k ≤ 1+M+K := by
  unfold canonicalNormalizer
  linarith

#print axioms integral_canonical_reweight
#print axioms canonicalImportanceLaw_probability
#print axioms canonical_projection_coefficient_bound
#print axioms canonical_norm_coefficient_bound
end ConditionalNonpolynomial.Analytic
