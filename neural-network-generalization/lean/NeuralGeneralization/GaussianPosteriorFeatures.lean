import NeuralGeneralization.GaussianSignRegression

/-! Actual Gaussian sign posterior in weighted finite feature coordinates. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianPosteriorFeatures
open GaussianConeRadial GaussianSignCone GaussianSignRegression
variable {I J X : Type*} [Fintype I] [Fintype J]

def gaussianField (φ : I → X → ℝ) (w : I → ℝ) (z : I → ℝ) (x : X) : ℝ :=
  ∑ i, Real.sqrt (w i) * z i * φ i x

def trainingMatrix (φ : I → X → ℝ) (w : I → ℝ) (s : J → X) (y : J → ℝ) : J → I → ℝ :=
  fun j i => y j * Real.sqrt (w i) * φ i (s j)

def posteriorCoefficients (A : J → I → ℝ) (w : I → ℝ) (i : I) : ℝ :=
  Real.sqrt (w i) * ∫ z : I → ℝ, z i ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)

theorem signCone_trainingMatrix_eq (φ : I → X → ℝ) (w : I → ℝ) (s : J → X) (y : J → ℝ) :
    signCone (trainingMatrix φ w s y) = {z | ∀ j, 0 < y j * gaussianField φ w z (s j)} := by
  ext z
  simp only [signCone, Set.mem_setOf_eq, trainingMatrix, gaussianField, Finset.mul_sum]
  apply forall_congr'
  intro j
  have hh : (∑ i, y j * Real.sqrt (w i) * φ i (s j) * z i) =
      ∑ i, y j * (Real.sqrt (w i) * z i * φ i (s j)) := by
    apply Finset.sum_congr rfl
    intro i hi
    ring
  rw [hh]

/-- The deterministic posterior feature coefficients are exactly the
coefficients of the actual conditional Gaussian mean function. -/
theorem mean_eq_featureField (φ : I → X → ℝ) (w : I → ℝ) (A : J → I → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A) ≠ 0) (x : X) :
    (∫ z, gaussianField φ w z x ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)) =
      featureField φ (posteriorCoefficients A w) x := by
  have hi (i : I) : Integrable (fun z : I → ℝ => Real.sqrt (w i) * z i * φ i x)
      (cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)) :=
    ((((memLp_eval i).integrable (by norm_num)).restrict.smul_measure
      (ENNReal.inv_ne_top.mpr hprob)).const_mul _).mul_const _
  unfold gaussianField featureField posteriorCoefficients
  rw [integral_finsetSum _ (fun i _ => hi i)]
  simp only [integral_mul_const, integral_const_mul]

/-- The actual Gaussian sign-posterior mean has feature/RKHS energy at most
the number of observed signs, including degenerate weights and repeated inputs. -/
theorem posterior_feature_energy_le_sample_count (w : I → ℝ) (hw : ∀ i, 0 ≤ w i)
    (A : J → I → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A) ≠ 0) :
    featureEnergy w (posteriorCoefficients A w) ≤ Fintype.card J := by
  apply le_trans _ (conditional_mean_sq_le_sample_count A hprob)
  unfold featureEnergy posteriorCoefficients
  apply Finset.sum_le_sum
  intro i hi
  by_cases hz : w i = 0
  · simp only [hz, Real.sqrt_zero, zero_mul, ne_eq, OfNat.ofNat_ne_zero,
      not_false_eq_true, zero_pow, div_zero]
    exact sq_nonneg _
  · rw [mul_pow, Real.sq_sqrt (hw i)]
    rw [mul_div_cancel_left₀ _ hz]

/-- The actual posterior mean satisfies every observed strict sign. -/
theorem signed_training_mean_pos (φ : I → X → ℝ) (w : I → ℝ) (s : J → X) (y : J → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone (trainingMatrix φ w s y)) ≠ 0)
    (j : J) :
    0 < y j * featureField φ (posteriorCoefficients (trainingMatrix φ w s y) w) (s j) := by
  have h := signed_conditional_mean_pos (trainingMatrix φ w s y) hprob j
  convert h using 1
  unfold featureField posteriorCoefficients trainingMatrix
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  ring

end NeuralGeneralization.GaussianPosteriorFeatures
