import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.MeasureTheory.Integral.IntegralEqImproper
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

/-!
# One-dimensional Gaussian integration by parts

The identity is proved for the actual Gaussian density. Uniform bounds on the
function and its derivative give all required integrability; whole-line
integration by parts then has zero boundary contribution. No Stein identity
or Gaussian integration-by-parts formula is assumed as a hypothesis.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped NNReal
namespace NeuralGeneralization.GaussianStein

/-- Derivative of the actual centered Gaussian density. -/
theorem hasDerivAt_gaussianPDFReal (v : ℝ≥0) (x : ℝ) :
    HasDerivAt (gaussianPDFReal 0 v)
      (-(x / (v : ℝ)) * gaussianPDFReal 0 v x) x := by
  have h := (((hasDerivAt_id x).pow 2).neg.div_const (2 * (v : ℝ))).exp.const_mul
    ((Real.sqrt (2 * Real.pi * (v : ℝ)))⁻¹)
  convert h using 1
  all_goals first
    | rfl
    | (funext y; simp only [gaussianPDFReal, sub_zero, Pi.neg_apply, Pi.pow_apply, id_eq])
    | (simp only [gaussianPDFReal, sub_zero, Pi.neg_apply, Pi.pow_apply,
        id_eq, Nat.cast_ofNat, Nat.reduceSub, pow_one, mul_one]; ring)

/-- The first absolute Gaussian moment is finite. -/
theorem integrable_id_gaussian (v : ℝ≥0) :
    Integrable (fun x : ℝ => x) (gaussianReal 0 v) := by
  change Integrable id (gaussianReal 0 v)
  exact memLp_one_iff_integrable.mp (memLp_id_gaussianReal' 1 (by simp))

/-- Multiplication by a bounded measurable function preserves integrability
of the Gaussian coordinate. -/
theorem integrable_mul_gaussian_of_bounded (v : ℝ≥0) (f : ℝ → ℝ)
    (hf : Measurable f) (B : ℝ) (hfB : ∀ x, |f x| ≤ B) :
    Integrable (fun x => x * f x) (gaussianReal 0 v) := by
  exact (integrable_id_gaussian v).mul_bdd hf.aestronglyMeasurable
    (Filter.Eventually.of_forall fun x => by simpa only [Real.norm_eq_abs] using hfB x)

/-- Every bounded measurable function is integrable for a real Gaussian. -/
theorem integrable_gaussian_of_bounded (v : ℝ≥0) (f : ℝ → ℝ)
    (hf : Measurable f) (B : ℝ) (hfB : ∀ x, |f x| ≤ B) :
    Integrable f (gaussianReal 0 v) := by
  apply Integrable.of_bound hf.aestronglyMeasurable B
  exact Filter.Eventually.of_forall fun x => by
    simpa only [Real.norm_eq_abs] using hfB x

/-- Lebesgue integrability of the coordinate times the Gaussian density. -/
theorem integrable_mul_gaussianPDFReal (v : ℝ≥0) (hv : v ≠ 0) :
    Integrable (fun x : ℝ => x * gaussianPDFReal 0 v x) := by
  have hvpos : 0 < (v : ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  have h := (integrable_mul_exp_neg_mul_sq
    (show 0 < (2 * (v : ℝ))⁻¹ by positivity)).const_mul
      ((Real.sqrt (2 * Real.pi * (v : ℝ)))⁻¹)
  convert h using 1
  ext x
  simp only [gaussianPDFReal, sub_zero]
  rw [show -x ^ 2 / (2 * (v : ℝ)) = -(2 * (v : ℝ))⁻¹ * x ^ 2 by ring]
  ring

/-- Stein's identity for bounded differentiable real test functions with
bounded measurable derivative, including the degenerate variance-zero law. -/
theorem gaussian_integral_mul_eq_integral_deriv (v : ℝ≥0) (f f' : ℝ → ℝ)
    (hderiv : ∀ x, HasDerivAt f (f' x) x) (hf' : Measurable f')
    (B B' : ℝ) (hfB : ∀ x, |f x| ≤ B) (hf'B : ∀ x, |f' x| ≤ B') :
    (∫ x : ℝ, x * f x ∂gaussianReal 0 v) =
      (v : ℝ) * ∫ x : ℝ, f' x ∂gaussianReal 0 v := by
  by_cases hv : v = 0
  · simp [hv]
  have hvR : (v : ℝ) ≠ 0 := by exact_mod_cast hv
  have hf : Measurable f := (continuous_iff_continuousAt.mpr
    fun x => (hderiv x).continuousAt).measurable
  let ρ : ℝ → ℝ := gaussianPDFReal 0 v
  let ρ' : ℝ → ℝ := fun x => -(x / (v : ℝ)) * ρ x
  have hρ : Integrable ρ := integrable_gaussianPDFReal 0 v
  have hρ' : Integrable ρ' := by
    have h := (integrable_mul_gaussianPDFReal v hv).const_mul (-(v : ℝ)⁻¹)
    convert h using 1
    ext x
    dsimp [ρ', ρ]
    ring
  have hff : Integrable (fun x => f x * ρ x) :=
    hρ.bdd_mul hf.aestronglyMeasurable
      (Filter.Eventually.of_forall fun x => by simpa only [Real.norm_eq_abs] using hfB x)
  have hff' : Integrable (fun x => f x * ρ' x) :=
    hρ'.bdd_mul hf.aestronglyMeasurable
      (Filter.Eventually.of_forall fun x => by simpa only [Real.norm_eq_abs] using hfB x)
  have hf'f : Integrable (fun x => f' x * ρ x) :=
    hρ.bdd_mul hf'.aestronglyMeasurable
      (Filter.Eventually.of_forall fun x => by simpa only [Real.norm_eq_abs] using hf'B x)
  have hibp := integral_mul_deriv_eq_deriv_mul_of_integrable
    (u := f) (u' := f') (v := ρ) (v' := ρ')
    (fun x _ => hderiv x) (fun x _ => hasDerivAt_gaussianPDFReal v x)
    hff' hf'f hff
  have heq : (fun x => f x * ρ' x) =
      fun x => -(v : ℝ)⁻¹ * (ρ x * (x * f x)) := by
    ext x
    dsimp [ρ']
    ring
  rw [heq, integral_const_mul] at hibp
  have heq' : (fun x => f' x * ρ x) = (fun x => ρ x * f' x) := by
    ext x
    ring
  rw [heq'] at hibp
  rw [integral_gaussianReal_eq_integral_smul hv,
    integral_gaussianReal_eq_integral_smul hv]
  simp only [smul_eq_mul]
  change (∫ x, ρ x * (x * f x)) = (v : ℝ) * ∫ x, ρ x * f' x
  calc
    (∫ x, ρ x * (x * f x)) =
        -(v : ℝ) * (-(v : ℝ)⁻¹ * ∫ x, ρ x * (x * f x)) := by
      field_simp [hvR]
    _ = -(v : ℝ) * (-(∫ x, ρ x * f' x)) := congrArg (fun z : ℝ => -(v : ℝ) * z) hibp
    _ = (v : ℝ) * ∫ x, ρ x * f' x := by ring

end NeuralGeneralization.GaussianStein
