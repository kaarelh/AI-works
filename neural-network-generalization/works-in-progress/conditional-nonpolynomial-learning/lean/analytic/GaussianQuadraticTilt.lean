import GaussianEntropyProjection
import GaussianVarianceKL
import NeuralGeneralization.GaussianProductDensity

/-! Identification of the actual quadratic exponential tilt with its Gaussian
second-moment reference. This supplies a concrete, rather than named-only,
Gaussian reference in the entropy decomposition. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
variable {I : Type*} [Fintype I]

def diagonalGaussianDensity (v : I → ℝ≥0) (x : I → ℝ) : ℝ :=
  ∏ i, gaussianPDFReal 0 (v i) (x i)

@[fun_prop] theorem measurable_diagonalGaussianDensity (v : I → ℝ≥0) :
    Measurable (diagonalGaussianDensity v) := by
  unfold diagonalGaussianDensity
  apply Finset.measurable_prod
  intro i _
  exact (measurable_gaussianPDFReal 0 (v i)).comp (measurable_pi_apply i)

theorem diagonalGaussianDensity_pos (v : I → ℝ≥0) (hv : ∀ i, v i ≠ 0) (x : I → ℝ) :
    0 < diagonalGaussianDensity v x :=
  Finset.prod_pos fun i _ => gaussianPDFReal_pos 0 (v i) (x i) (hv i)

theorem diagonalGaussianDensity_integrable (v : I → ℝ≥0) :
    Integrable (diagonalGaussianDensity v) volume :=
  Integrable.fintype_prod fun i => integrable_gaussianPDFReal 0 (v i)

theorem diagonalGaussian_density (v : I → ℝ≥0) (hv : ∀ i, v i ≠ 0) :
    (Measure.pi fun i => gaussianReal 0 (v i)) =
      (volume : Measure (I → ℝ)).withDensity
        (fun x => ENNReal.ofReal (diagonalGaussianDensity v x)) := by
  apply Measure.pi_eq
  intro s hs
  rw [withDensity_apply _ (MeasurableSet.univ_pi hs)]
  rw [← ofReal_integral_eq_lintegral_ofReal (diagonalGaussianDensity_integrable v).restrict
    (ae_of_all _ fun x => (diagonalGaussianDensity_pos v hv x).le)]
  change ENNReal.ofReal (∫ x, diagonalGaussianDensity v x
    ∂(Measure.pi fun _ : I => (volume : Measure ℝ)).restrict (Set.univ.pi s)) = _
  rw [Measure.restrict_pi_pi]
  change ENNReal.ofReal (∫ x, ∏ i, gaussianPDFReal 0 (v i) (x i)
    ∂Measure.pi fun i => (volume : Measure ℝ).restrict (s i)) = _
  rw [integral_fintype_prod_eq_prod]
  simp_rw [gaussianReal_apply_eq_integral 0 (hv _)]
  exact ENNReal.ofReal_prod_of_nonneg fun i _ => integral_nonneg (gaussianPDFReal_nonneg _ _)

theorem diagonalGaussianDensity_log (v : I → ℝ≥0) (hv : ∀ i, v i ≠ 0) (x : I → ℝ) :
    Real.log (diagonalGaussianDensity v x) =
      ∑ i, (-(Real.log (2*Real.pi)+Real.log (v i:ℝ))/2-(x i)^2/(2*v i)) := by
  rw [diagonalGaussianDensity,
    Real.log_prod (fun i _ => (gaussianPDFReal_pos 0 (v i) (x i) (hv i)).ne')]
  apply Finset.sum_congr rfl
  intro i _
  exact log_gaussianPDFReal_zero (v i) (hv i) (x i)

theorem diagonalGaussianDensity_ratio (v : I → ℝ≥0) (hv : ∀ i, v i ≠ 0) (x : I → ℝ) :
    diagonalGaussianDensity v x = diagonalGaussianDensity (fun _ => 1) x *
      (Real.exp (diagonalQuadraticPotential (fun i => (v i:ℝ)) x) /
        Real.exp (diagonalQuadraticLogPartition (fun i => (v i:ℝ)))) := by
  have hlog : Real.log (diagonalGaussianDensity v x) =
      Real.log (diagonalGaussianDensity (fun _ : I => 1) x) +
      diagonalQuadraticPotential (fun i => (v i:ℝ)) x -
      diagonalQuadraticLogPartition (fun i => (v i:ℝ)) := by
    rw [diagonalGaussianDensity_log v hv,
      diagonalGaussianDensity_log (fun _ : I => 1) (fun _ => by norm_num)]
    simp only [diagonalQuadraticPotential,diagonalQuadraticLogPartition,
      ← Finset.sum_add_distrib,← Finset.sum_sub_distrib,NNReal.coe_one,Real.log_one]
    apply Finset.sum_congr rfl
    intro i _
    have hvi : (v i:ℝ) ≠ 0 := by exact_mod_cast hv i
    field_simp
    <;> ring
  rw [← Real.exp_log (diagonalGaussianDensity_pos v hv x),hlog,
    Real.exp_sub,Real.exp_add,Real.exp_log (diagonalGaussianDensity_pos
      (fun _ : I => 1) (fun _ => by norm_num) x)]
  ring

theorem diagonalQuadratic_tilt_eq_gaussian (v : I → ℝ≥0) (hv : ∀ i, v i ≠ 0) :
    (Measure.pi fun _ : I => gaussianReal 0 1).tilted
      (diagonalQuadraticPotential (fun i => (v i:ℝ))) =
        Measure.pi fun i => gaussianReal 0 (v i) := by
  have hvp (i : I) : 0 < (v i:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr (hv i))
  rw [Measure.tilted,diagonalQuadratic_exp_integral (fun i => (v i:ℝ)) hvp,
    diagonalGaussian_density (fun _ : I => 1) (fun _ => by norm_num),
    diagonalGaussian_density v hv]
  rw [← withDensity_mul _ (measurable_diagonalGaussianDensity _).ennreal_ofReal (by
    unfold diagonalQuadraticPotential
    fun_prop)]
  apply withDensity_congr_ae
  filter_upwards [] with x
  simp only [Pi.mul_apply]
  rw [← ENNReal.ofReal_mul (diagonalGaussianDensity_pos
    (fun _ : I => 1) (fun _ => by norm_num) x).le,← diagonalGaussianDensity_ratio v hv x]

theorem gaussian_matching_diagonal_entropy_decomposition
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (v : I → ℝ≥0) (hv : ∀ i, v i ≠ 0)
    (hm : ∀ i, ∫ x : I → ℝ, x i^2 ∂Q = (v i:ℝ)) :
    klDiv Q (Measure.pi fun i => gaussianReal 0 (v i)) ≠ ∞ ∧
      (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal =
        (klDiv Q (Measure.pi fun i => gaussianReal 0 (v i))).toReal +
        (∑ i, ((v i:ℝ)-1-Real.log (v i:ℝ)))/2 := by
  have hvp (i : I) : 0 < (v i:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr (hv i))
  have h := gaussian_diagonal_entropy_decomposition Q hKL (fun i => (v i:ℝ)) hvp hm
  rwa [diagonalQuadratic_tilt_eq_gaussian v hv] at h

#print axioms diagonalQuadratic_tilt_eq_gaussian
#print axioms gaussian_matching_diagonal_entropy_decomposition
end ConditionalNonpolynomial.Analytic
