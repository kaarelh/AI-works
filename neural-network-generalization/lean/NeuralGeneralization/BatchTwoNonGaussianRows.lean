import NeuralGeneralization.BatchTwoNonGaussianRowTail
import NeuralGeneralization.BatchTwoNonGaussianCertificate
import NeuralGeneralization.GaussianTowerConstruction
import NeuralGeneralization.CovarianceFactor

/-! Actual bounded tilted non-Gaussian rows and a finite first-layer realization. -/

noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open CompressionSampling TiltedGaussianRows FiniteDifferential TanhDifferential
open ConcreteModel GaussianTowerConstruction TowerNetwork ActualBoundedDual CovarianceDualLift

section Rows
variable {X J : Type*} [Fintype X] [Fintype J] [DecidableEq J]

theorem exists_actual_bounded_covariance_rows (ν : CoordinateLaw)
    (V : (J → ℝ) → ℝ) (hV : Measurable V) {G : ℝ} (hVbound : ∀ w, |V w| ≤ G)
    (h : (J → ℝ) → X → ℝ) (hh : ∀ x, Measurable (fun w => h w x))
    (hbound : ∀ w x, |h w x| ≤ 1) {N : ℕ} (hN : 0 < N)
    {η B : ℝ} (hη : 0 ≤ η) (hB : 0 ≤ B)
    (hbudget : 2 * (Fintype.card X : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * ν.comparisonFactor ν.lowerCurvature * (N : ℝ) * (Fintype.card J : ℝ) *
        Real.exp (2 * G - ν.lowerCurvature * B ^ 2 / 2) < 1) :
    ∃ w : Fin N → J → ℝ, (∀ i j, |w i j| < B) ∧ ∀ x y,
      |(∑ i, h (w i) x * h (w i) y) / (N : ℝ) -
        ∫ a, h a x * h a y ∂((Measure.pi fun _ : J => ν.law).tilted V)| < η := by
  let μ := (Measure.pi fun _ : J => ν.law).tilted V
  letI : IsProbabilityMeasure μ := BoundedTilt.tilted_probability _ V hV hVbound
  let A : Set (Fin N → J → ℝ) := {w | ∃ x y,
    η ≤ |(∑ i, h (w i) x * h (w i) y) / (N : ℝ) - ∫ a, h a x * h a y ∂μ|}
  let Bset : Set (Fin N → J → ℝ) := {w | ∃ i j, B ≤ |w i j|}
  have hA := TiltedRowSampling.covariance_sampling_tail μ h hh hbound hN hη
  have hBs := actual_sampled_coordinate_tail ν V hV hVbound N hB
  by_contra hnone
  have hcover : A ∪ Bset = Set.univ := by
    ext w
    simp only [Set.mem_union, Set.mem_univ, iff_true]
    by_contra hnot
    obtain ⟨ha, hb⟩ := not_or.mp hnot
    apply hnone
    refine ⟨w, ?_, ?_⟩
    · intro i j
      exact lt_of_not_ge (fun hij => hb ⟨i, j, hij⟩)
    · intro x y
      exact lt_of_not_ge (fun hxy => ha ⟨x, y, hxy⟩)
  have hu := measureReal_union_le (μ := iidSamples μ N) A Bset
  rw [hcover] at hu
  simp only [probReal_univ] at hu
  change (iidSamples μ N).real A ≤ _ at hA
  change (iidSamples μ N).real Bset ≤ _ at hBs
  linarith

def actualTiltedMoment (ν : CoordinateLaw) (A : X → J → ℝ) (Γ : X → X → ℝ)
    (x y : X) : ℝ :=
  ∫ z, Real.tanh (fieldLinear A z x) * Real.tanh (fieldLinear A z y)
    ∂(Measure.pi fun _ : J => ν.law).tilted (rowTilt A Γ)

theorem actualTiltedMoment_eq_mean [DecidableEq X] [Nonempty X]
    (ν : CoordinateLaw) (A : X → J → ℝ) (Γ : X → X → ℝ) (x y : X) :
    actualTiltedMoment ν A Γ x y =
      mean (actualFieldLaw ν A) (features Real.tanh) (parameter Γ) (x, y) := by
  unfold actualTiltedMoment mean
  rw [integral_tilted, integral_tilted]
  simp only [smul_eq_mul]
  have hp : potential (features Real.tanh) (parameter Γ) = potentialValue Real.tanh Γ := by
    funext z
    simp only [potential, BoundedDual.pairing, features, parameter, potentialValue,
      pairValue, Fintype.sum_prod_type]
  rw [hp]
  unfold actualFieldLaw
  rw [integral_map (fieldLinear A).continuous.measurable.aemeasurable]
  · rw [integral_map (fieldLinear A).continuous.measurable.aemeasurable]
    · rfl
    · exact (Real.continuous_exp.comp (continuous_tanhPotentialValue Γ)).aestronglyMeasurable
  · exact (((Real.continuous_exp.comp (continuous_tanhPotentialValue Γ)).div_const _).mul
      (continuous_tanhPairValue x y)).aestronglyMeasurable

theorem exists_actual_bounded_tanh_rows [DecidableEq X] (ν : CoordinateLaw)
    (A : X → J → ℝ) (Γ : X → X → ℝ) {G : ℝ} (hΓ : couplingMass Γ ≤ G)
    {N : ℕ} (hN : 0 < N) {η B : ℝ} (hη : 0 ≤ η) (hB : 0 ≤ B)
    (hbudget : 2 * (Fintype.card X : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * ν.comparisonFactor ν.lowerCurvature * (N : ℝ) * (Fintype.card J : ℝ) *
        Real.exp (2 * G - ν.lowerCurvature * B ^ 2 / 2) < 1) :
    ∃ w : Fin N → J → ℝ, (∀ i j, |w i j| < B) ∧ ∀ x y,
      |(∑ i, Real.tanh (fieldLinear A (w i) x) * Real.tanh (fieldLinear A (w i) y)) /
        (N : ℝ) - actualTiltedMoment ν A Γ x y| < η :=
  exists_actual_bounded_covariance_rows ν (rowTilt A Γ) (continuous_rowTilt A Γ).measurable
    (rowTilt_bound A Γ hΓ) (fun z i => Real.tanh (fieldLinear A z i)) (fun _ => by fun_prop)
    (fun _ _ => (Real.abs_tanh_lt_one _).le) hN hη hB hbudget

theorem actualTiltedMoment_has_gram_factor [DecidableEq X]
    (ν : CoordinateLaw) (A : X → J → ℝ) (Γ : X → X → ℝ) :
    ∃ R : X → X → ℝ, ∀ x y,
      GaussianAngularPrice.gram R x y = actualTiltedMoment ν A Γ x y := by
  let μ := (Measure.pi fun _ : J => ν.law).tilted (rowTilt A Γ)
  letI : IsProbabilityMeasure μ := BoundedTilt.tilted_probability _ (rowTilt A Γ)
    (continuous_rowTilt A Γ).measurable (rowTilt_bound A Γ le_rfl)
  apply CovarianceFactor.covariance_has_gram_factor μ (fun x z => Real.tanh (fieldLinear A z x))
  intro x y
  apply Integrable.of_bound (by fun_prop) 1
  filter_upwards [] with z
  change |Real.tanh (fieldLinear A z x) * Real.tanh (fieldLinear A z y)| ≤ 1
  rw [abs_mul]
  exact (mul_le_mul (Real.abs_tanh_lt_one _).le (Real.abs_tanh_lt_one _).le
    (abs_nonneg _) zero_le_one).trans_eq (one_mul 1)

end Rows

/-- A genuinely non-Gaussian first hidden layer of an ordinary finite network,
with its complete coordinate and covariance budgets. -/
theorem exists_actual_input_covariance (ν : CoordinateLaw) {d N : ℕ}
    (hd : 0 < d) (hN : 0 < N) (Γ : Cube d → Cube d → ℝ) {G η B : ℝ}
    (hη : 0 ≤ η) (hB : 0 ≤ B) (hΓ : couplingMass Γ ≤ G)
    (hbudget : 2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * ν.comparisonFactor ν.lowerCurvature * (N : ℝ) * (d + 1 : ℝ) *
        Real.exp (2 * G - ν.lowerCurvature * B ^ 2 / 2) < 1) :
    ∃ w : Weights d N 0, (∀ i, |w i| ≤ B) ∧ ∀ x y,
      |finalCovariance Real.tanh w x y - actualTiltedMoment ν (inputMatrix d) Γ x y| ≤ η := by
  obtain ⟨a, ha, hc⟩ := exists_actual_bounded_tanh_rows ν (inputMatrix d) Γ hΓ hN hη hB
    (by simpa using hbudget)
  refine ⟨inputWeights a, inputWeights_bound hd a hB (fun i j => (ha i j).le), ?_⟩
  intro x y
  simpa only [finalCovariance, finalHidden_inputWeights] using (hc x y).le

end NeuralGeneralization.BatchTwoNonGaussian
