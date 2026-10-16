import NeuralGeneralization.GaussianOrthogonal
import NeuralGeneralization.Model
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.Tactic.Ring

/-!
# Exact Gaussian readout laws

For a fixed hidden feature array, the readout's characteristic function is
computed directly under its finite product Gaussian law. The covariance is
the actual empirical feature Gram matrix. No Gaussian approximation or
independence assumption about the hidden features is made here.
-/

noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators RealInnerProductSpace NNReal

namespace NeuralGeneralization.GaussianReadout

variable {I J : Type*} [Fintype I] [Fintype J]

def readout (H : I → J → ℝ) (a : I → ℝ) : EuclideanSpace ℝ J :=
  toLp 2 (fun x => ∑ i, a i * H i x)

def coefficient (H : I → J → ℝ) (t : EuclideanSpace ℝ J) : EuclideanSpace ℝ I :=
  toLp 2 (fun i => ∑ x, t x * H i x)

omit [Fintype J] in
@[fun_prop] theorem continuous_readout (H : I → J → ℝ) : Continuous (readout H) := by
  unfold readout
  fun_prop

theorem readout_inner (H : I → J → ℝ) (a : I → ℝ) (t : EuclideanSpace ℝ J) :
    ⟪readout H a, t⟫ = ⟪toLp 2 a, coefficient H t⟫ := by
  simp only [readout, coefficient, PiLp.inner_apply, RCLike.inner_apply,
    conj_trivial]
  simp_rw [Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i hi
  apply Finset.sum_congr rfl
  intro x hx
  ring

/-- The full, exact finite-dimensional law is identified by this characteristic
function; the covariance may be singular, and variance zero is allowed. -/
theorem charFun_readout (H : I → J → ℝ) (v : ℝ≥0) (t : EuclideanSpace ℝ J) :
    charFun ((Measure.pi fun _ : I => gaussianReal 0 v).map (readout H)) t =
      Complex.exp (((-(v : ℝ) * ‖coefficient H t‖ ^ 2 / 2 : ℝ) : ℂ)) := by
  rw [← GaussianOrthogonal.charFun_euclideanGaussian]
  simp only [charFun_apply, GaussianOrthogonal.euclideanGaussian]
  rw [integral_map (continuous_readout H).measurable.aemeasurable (by fun_prop),
    integral_map (WithLp.measurable_toLp 2 (I → ℝ)).aemeasurable (by fun_prop)]
  apply integral_congr_ae
  filter_upwards [] with a
  rw [readout_inner]

def gram (H : I → J → ℝ) (x y : J) : ℝ := ∑ i, H i x * H i y

theorem coefficient_norm_sq (H : I → J → ℝ) (t : EuclideanSpace ℝ J) :
    ‖coefficient H t‖ ^ 2 = ∑ x, ∑ y, t x * gram H x y * t y := by
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [coefficient, pow_two, gram]
  simp_rw [Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro x hx
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro y hy
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i hi
  ring

theorem charFun_readout_gram (H : I → J → ℝ) (v : ℝ≥0)
    (t : EuclideanSpace ℝ J) :
    charFun ((Measure.pi fun _ : I => gaussianReal 0 v).map (readout H)) t =
      Complex.exp (((-(v : ℝ) * (∑ x, ∑ y, t x * gram H x y * t y) / 2 : ℝ) : ℂ)) := by
  rw [charFun_readout, coefficient_norm_sq]

/-- Identical feature Gram matrices give identical readout laws, including
singular Gram matrices. This conclusion concerns measures, not just moments. -/
theorem law_eq_of_gram_eq {I' : Type*} [Fintype I']
    (H : I → J → ℝ) (H' : I' → J → ℝ) (v v' : ℝ≥0)
    (h : ∀ x y, (v : ℝ) * gram H x y = (v' : ℝ) * gram H' x y) :
    (Measure.pi fun _ : I => gaussianReal 0 v).map (readout H) =
      (Measure.pi fun _ : I' => gaussianReal 0 v').map (readout H') := by
  apply Measure.ext_of_charFun
  funext t
  rw [charFun_readout_gram, charFun_readout_gram]
  congr 2
  apply congrArg (fun z : ℝ => z / 2)
  simp_rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x hx
  apply Finset.sum_congr rfl
  intro y hy
  calc
    _ = -(t x * ((v : ℝ) * gram H x y) * t y) := by ring
    _ = -(t x * ((v' : ℝ) * gram H' x y) * t y) := by rw [h]
    _ = _ := by ring

/-- Exact scalar marginal law of any linear functional of the readout. -/
theorem scalar_linear_law (c : I → ℝ) (v : ℝ≥0) :
    (Measure.pi fun _ : I => gaussianReal 0 v).map (fun a => ∑ i, c i * a i) =
      gaussianReal 0 (((v : ℝ) * ∑ i, c i ^ 2).toNNReal) := by
  apply Measure.ext_of_charFun
  funext t
  have hchar : charFun ((Measure.pi fun _ : I => gaussianReal 0 v).map
      (fun a => ∑ i, c i * a i)) t =
      charFun (GaussianOrthogonal.euclideanGaussian v)
        (toLp 2 (fun i => t * c i)) := by
    rw [charFun_apply_real, charFun_apply, GaussianOrthogonal.euclideanGaussian,
      integral_map (show AEMeasurable (fun a : I → ℝ => ∑ i, c i * a i)
        (Measure.pi fun _ => gaussianReal 0 v) from
          (continuous_finsetSum _ (fun i _ => continuous_const.mul (continuous_apply i))).measurable.aemeasurable)
        (by fun_prop),
      integral_map (WithLp.measurable_toLp 2 (I → ℝ)).aemeasurable (by fun_prop)]
    apply integral_congr_ae
    filter_upwards [] with a
    congr 2
    simp only [PiLp.inner_apply, RCLike.inner_apply, conj_trivial]
    rw [← Complex.ofReal_mul]
    congr 1
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    ring
  rw [hchar, GaussianOrthogonal.charFun_euclideanGaussian, charFun_gaussianReal]
  simp only [Complex.ofReal_zero, mul_zero, zero_mul, zero_sub]
  have hvar : 0 ≤ (v : ℝ) * ∑ i, c i ^ 2 := by positivity
  rw [Real.toNNReal_of_nonneg hvar]
  simp only [NNReal.coe_mk, EuclideanSpace.real_norm_sq_eq, mul_pow,
    ← Finset.mul_sum]
  congr 1
  push_cast
  ring

/-- A nontrivial Gaussian linear form assigns zero mass to each single value.
This supplies the null boundary required by tanh saturation and conditional
sign-event convergence. -/
theorem scalar_linear_boundary_null (c : I → ℝ) (v : ℝ≥0)
    (hc : 0 < (v : ℝ) * ∑ i, c i ^ 2) (b : ℝ) :
    (Measure.pi fun _ : I => gaussianReal 0 v) {a | (∑ i, c i * a i) = b} = 0 := by
  have hne : ((v : ℝ) * ∑ i, c i ^ 2).toNNReal ≠ 0 :=
    ne_of_gt (Real.toNNReal_pos.mpr hc)
  letI := nullSingletonClass_gaussianReal (μ := 0) hne
  have h := congrArg (fun μ : Measure ℝ => μ {b}) (scalar_linear_law c v)
  rw [Measure.map_apply (by fun_prop) (measurableSet_singleton b), measure_singleton] at h
  exact h

end NeuralGeneralization.GaussianReadout
