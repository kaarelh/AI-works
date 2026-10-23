import NeuralGeneralization.BatchTwoActivationGaussianBulkTail
import NeuralGeneralization.BatchTwoActivationRescaling

/-!
# Bounded bulk and normalized tail features

This file constructs the source-space decomposition for a finite Gaussian
linear map. The residual energy is measured in an actual Euclidean source,
which supplies an RKHS certificate without choosing a pseudoinverse.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation

variable {I : Type*} [Fintype I] {n : ℕ}

theorem linearObservation_abs_le (a : I→Fin n→ℝ) {M : ℝ} (hM : 0≤M)
    (hvar : ∀i, (∑ j, (a i j)^2)≤M) (x : EuclideanSpace ℝ (Fin n)) (i : I) :
    |linearObservation a x i|≤Real.sqrt M*‖x‖ := by
  have hs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (a i) (fun j => x j)
  have hxnonneg : 0≤∑ j, (x j)^2 := Finset.sum_nonneg (fun j _ => sq_nonneg (x j))
  have hm := mul_le_mul_of_nonneg_right (hvar i) hxnonneg
  have hn : (∑ j, (x j)^2)=‖x‖^2 := (EuclideanSpace.real_norm_sq_eq x).symm
  rw [hn] at hm hs
  have hsq := hs.trans hm
  change (linearObservation a x i)^2≤M*‖x‖^2 at hsq
  apply (sq_le_sq₀ (abs_nonneg _) (by positivity : 0≤Real.sqrt M*‖x‖)).mp
  rw [sq_abs, mul_pow, Real.sq_sqrt hM]
  exact hsq

def gaussianBulkSource (a : I→Fin n→ℝ) (M : ℝ) (x : Fin n→ℝ) :
    EuclideanSpace ℝ (Fin n) :=
  convexProjection (linearBoxBody a (gaussianBulkThreshold I M))
    (linearBoxBody_nonempty a (Real.sqrt_nonneg _))
    (linearBoxBody_closed a (gaussianBulkThreshold I M))
    (linearBoxBody_convex a (gaussianBulkThreshold I M)) (WithLp.toLp 2 x)

def gaussianResidualSource (a : I→Fin n→ℝ) (M : ℝ) (x : Fin n→ℝ) :
    EuclideanSpace ℝ (Fin n) := WithLp.toLp 2 x-gaussianBulkSource a M x

theorem gaussianBulkSource_measurable (a : I→Fin n→ℝ) (M : ℝ) :
    Measurable (gaussianBulkSource a M) :=
  (convexProjection_lipschitz _ _ _ _).continuous.measurable.comp
    (PiLp.continuous_toLp 2 _).measurable

theorem gaussianResidualSource_measurable (a : I→Fin n→ℝ) (M : ℝ) :
    Measurable (gaussianResidualSource a M) :=
  (PiLp.continuous_toLp 2 _).measurable.sub (gaussianBulkSource_measurable a M)

theorem gaussianBulkSource_bound (a : I→Fin n→ℝ) (M : ℝ) (x : Fin n→ℝ) (i : I) :
    |linearObservation a (gaussianBulkSource a M x) i|≤gaussianBulkThreshold I M :=
by
  have h := convexProjection_mem (linearBoxBody a (gaussianBulkThreshold I M))
    (linearBoxBody_nonempty a (Real.sqrt_nonneg _))
    (linearBoxBody_closed a (gaussianBulkThreshold I M))
    (linearBoxBody_convex a (gaussianBulkThreshold I M)) (WithLp.toLp 2 x)
  exact h i

theorem gaussianBulkSource_add_residual (a : I→Fin n→ℝ) (M : ℝ) (x : Fin n→ℝ) (i : I) :
    linearObservation a (WithLp.toLp 2 x) i=
      linearObservation a (gaussianBulkSource a M x) i+
      linearObservation a (gaussianResidualSource a M x) i := by
  unfold gaussianResidualSource linearObservation
  simp only [PiLp.sub_apply, mul_sub, Finset.sum_sub_distrib]
  ring

theorem gaussianResidualSource_moment (a : I→Fin n→ℝ) {M : ℝ} (hM : 0<M)
    (hvar : ∀i, (∑ j, (a i j)^2)≤M) :
    (∫⁻ x, ENNReal.ofReal (Real.exp (‖gaussianResidualSource a M x‖^2/8))
      ∂standardGaussian n)≤3 :=
  (gaussian_linearBox_projection_moment a hM hvar).2.2

/-- Actual independent Gaussian rows admit a measurable bounded part and
residual certificates of controlled average squared norm. -/
theorem gaussianResidualSource_empirical_tail (N : ℕ) (a : I→Fin n→ℝ) {M : ℝ}
    (hM : 0<M) (hvar : ∀i, (∑ j, (a i j)^2)≤M) (K : ℝ) :
    (Measure.pi (fun _ : Fin N => standardGaussian n)).real
      {x | 8*(N : ℝ)*(K+Real.log 3)≤
        ∑ i, ‖gaussianResidualSource a M (x i)‖^2}≤Real.exp (-(N : ℝ)*K) :=
  iid_square_residual_tail N (fun x => ‖gaussianResidualSource a M x‖)
    (gaussianResidualSource_measurable a M).norm
    (gaussianResidualSource_moment a hM hvar) K

/-- A residual activation is exactly a scaled unit-source feature. The
activation may vary with the residual radius, but its Lipschitz constant does
not grow. -/
theorem residual_activation_normalization {φ : ℝ→ℝ} {ℓ δ : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hδ : 0<δ) (u : ℝ) :
    let ψ := fun t => φ (δ*t)/δ
    zeroLipschitzActivation ℓ ψ ∧ φ u=δ*ψ (u/δ) := by
  dsimp only
  constructor
  · constructor
    · simp [hφ.1]
    · intro x y
      have h := hφ.2 (δ*x) (δ*y)
      rw [show δ*x-δ*y=δ*(x-y) by ring, abs_mul, abs_of_pos hδ] at h
      rw [←sub_div, abs_div, abs_of_pos hδ]
      apply (div_le_iff₀ hδ).mpr
      nlinarith
  · field_simp

end NeuralGeneralization.BatchTwoActivation
