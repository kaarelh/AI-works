import TanhWalshSymmetrization
import NeuralGeneralization.ElementaryTailGram
import NeuralGeneralization.TanhScalarJet

/-! The exact parity symmetrization as an actual probability law on tanh
weights: independently draw a uniform cube translation and a controlled weight
row, then apply the explicit coordinate sign transform. -/

noncomputable section
open scoped BigOperators
open MeasureTheory ProbabilityTheory NeuralGeneralization

namespace ConditionalNonpolynomial.Analytic

variable {d : ℕ}

theorem measurable_tanhCubeFeature (x : ClippingCube d) :
    Measurable (fun w : Option (Fin d) → ℝ => tanhCubeFeature w x) := by
  unfold tanhCubeFeature
  exact (show Continuous (fun w : Option (Fin d) → ℝ =>
    Real.tanh (w none + ∑ i, w (some i) * cubeCoordinateSign (x i))) by fun_prop).measurable

theorem measurable_symmetrizedTanhWeights (S : Finset (Fin d)) :
    Measurable (fun p : ClippingCube d × (Option (Fin d) → ℝ) =>
      symmetrizedTanhWeights S p.1 p.2) := by
  apply measurable_pi_lambda
  intro i
  have hc : Measurable (fun p : ClippingCube d × (Option (Fin d) → ℝ) =>
      walshCharacter S p.1) :=
    (measurable_of_countable (fun u : ClippingCube d => walshCharacter S u)).comp measurable_fst
  have hw (i : Option (Fin d)) : Measurable
      (fun p : ClippingCube d × (Option (Fin d) → ℝ) => p.2 i) :=
    (measurable_pi_apply i).comp measurable_snd
  cases i with
  | none => exact hc.mul (hw none)
  | some i =>
    have hx : Measurable (fun p : ClippingCube d × (Option (Fin d) → ℝ) =>
        cubeCoordinateSign (p.1 i)) :=
      (measurable_of_countable (fun u : ClippingCube d => cubeCoordinateSign (u i))).comp
        measurable_fst
    exact (hc.mul hx).mul (hw (some i))

def symmetrizedTanhLaw (S : Finset (Fin d))
    (μ : Measure (Option (Fin d) → ℝ)) : Measure (Option (Fin d) → ℝ) :=
  ((uniformCubeMeasure d).prod μ).map
    (fun p => symmetrizedTanhWeights S p.1 p.2)

instance symmetrizedTanhLaw_probability (S : Finset (Fin d))
    (μ : Measure (Option (Fin d) → ℝ)) [IsProbabilityMeasure μ] :
    IsProbabilityMeasure (symmetrizedTanhLaw S μ) := by
  exact Measure.isProbabilityMeasure_map (measurable_symmetrizedTanhWeights S).aemeasurable

theorem tanhCubeFeature_abs_le_one (w : Option (Fin d) → ℝ) (x : ClippingCube d) :
    |tanhCubeFeature w x| ≤ 1 := (Real.abs_tanh_lt_one _).le

theorem integrable_tanhCubeFeature (μ : Measure (Option (Fin d) → ℝ))
    [IsProbabilityMeasure μ] (x : ClippingCube d) :
    Integrable (fun w => tanhCubeFeature w x) μ :=
  Integrable.of_bound (measurable_tanhCubeFeature x).aestronglyMeasurable 1
    (ae_of_all _ (fun w => tanhCubeFeature_abs_le_one w x))

theorem symmetrizedTanhLaw_mean (S : Finset (Fin d))
    (μ : Measure (Option (Fin d) → ℝ)) [IsProbabilityMeasure μ]
    (x : ClippingCube d) :
    (∫ w, tanhCubeFeature w x ∂symmetrizedTanhLaw S μ) =
      walshCoefficients (fun y => ∫ w, tanhCubeFeature w y ∂μ) S *
        walshCharacter S x := by
  have hmeas := (measurable_tanhCubeFeature x).comp (measurable_symmetrizedTanhWeights S)
  have hint : Integrable
      (fun p : ClippingCube d × (Option (Fin d) → ℝ) =>
        tanhCubeFeature (symmetrizedTanhWeights S p.1 p.2) x)
      ((uniformCubeMeasure d).prod μ) :=
    Integrable.of_bound hmeas.aestronglyMeasurable 1
      (ae_of_all _ (fun p => tanhCubeFeature_abs_le_one _ _))
  rw [symmetrizedTanhLaw, integral_map (measurable_symmetrizedTanhWeights S).aemeasurable
    (measurable_tanhCubeFeature x).aestronglyMeasurable, integral_prod _ hint]
  simp_rw [tanhCubeFeature_symmetrizedWeights, walshSymmetrizedFeature,
    integral_const_mul]
  rw [uniformCubeMeasure_integral]
  simpa only [walshSymmetrizedFeature] using walshSymmetrizedFeature_mean S
    (fun y => ∫ w, tanhCubeFeature w y ∂μ) x

theorem symmetrizedTanhLaw_secondMoment (S : Finset (Fin d))
    (μ : Measure (Option (Fin d) → ℝ)) [IsProbabilityMeasure μ]
    (x : ClippingCube d) :
    (∫ w, tanhCubeFeature w x ^ 2 ∂symmetrizedTanhLaw S μ) =
      ∫ w, uniformCubeMean (fun y => tanhCubeFeature w y ^ 2) ∂μ := by
  have hmeas := ((measurable_tanhCubeFeature x).pow_const 2).comp
    (measurable_symmetrizedTanhWeights S)
  have hint : Integrable
      (fun p : ClippingCube d × (Option (Fin d) → ℝ) =>
        tanhCubeFeature (symmetrizedTanhWeights S p.1 p.2) x ^ 2)
      ((uniformCubeMeasure d).prod μ) := by
    apply Integrable.of_bound hmeas.aestronglyMeasurable 1
    apply ae_of_all
    intro p
    rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
    change tanhCubeFeature (symmetrizedTanhWeights S p.1 p.2) x ^ 2 ≤ 1
    have h := tanhCubeFeature_abs_le_one (symmetrizedTanhWeights S p.1 p.2) x
    have hsq := pow_le_pow_left₀ (abs_nonneg _) h 2
    simpa only [sq_abs, one_pow] using hsq
  rw [symmetrizedTanhLaw, integral_map (measurable_symmetrizedTanhWeights S).aemeasurable
    ((measurable_tanhCubeFeature x).pow_const 2).aestronglyMeasurable,
    integral_prod _ hint, integral_integral_swap hint]
  apply integral_congr_ae
  apply ae_of_all
  intro w
  change (∫ u, tanhCubeFeature (symmetrizedTanhWeights S u w) x ^ 2
    ∂uniformCubeMeasure d) = _
  rw [uniformCubeMeasure_integral, actualTanh_symmetrization_constant_diagonal]

/-- An actual symmetrized tanh row law has constant second-moment diagonal. -/
theorem symmetrizedTanhLaw_constant_diagonal (S : Finset (Fin d))
    (μ : Measure (Option (Fin d) → ℝ)) [IsProbabilityMeasure μ]
    (x y : ClippingCube d) :
    (∫ w, tanhCubeFeature w x ^ 2 ∂symmetrizedTanhLaw S μ) =
      ∫ w, tanhCubeFeature w y ^ 2 ∂symmetrizedTanhLaw S μ := by
  rw [symmetrizedTanhLaw_secondMoment, symmetrizedTanhLaw_secondMoment]

/-- A signed margin for the original actual row mean becomes an exact pure-parity
mean with at least that coefficient after the explicit law transformation. -/
theorem symmetrizedTanhLaw_parity_seed (S : Finset (Fin d))
    (μ : Measure (Option (Fin d) → ℝ)) [IsProbabilityMeasure μ]
    (c : ℝ) (hc : ∀ x, c ≤ walshCharacter S x * ∫ w, tanhCubeFeature w x ∂μ) :
    ∃ b : ℝ, c ≤ b ∧
      (∀ x, (∫ w, tanhCubeFeature w x ∂symmetrizedTanhLaw S μ) =
        b * walshCharacter S x) ∧
      (∀ x y, (∫ w, tanhCubeFeature w x ^ 2 ∂symmetrizedTanhLaw S μ) =
        ∫ w, tanhCubeFeature w y ^ 2 ∂symmetrizedTanhLaw S μ) := by
  refine ⟨walshCoefficients (fun x => ∫ w, tanhCubeFeature w x ∂μ) S,
    walshCoefficients_lower_of_signed_margin S _ c hc, ?_, ?_⟩
  · exact symmetrizedTanhLaw_mean S μ
  · exact symmetrizedTanhLaw_constant_diagonal S μ

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.symmetrizedTanhLaw_mean
#print axioms ConditionalNonpolynomial.Analytic.symmetrizedTanhLaw_constant_diagonal
#print axioms ConditionalNonpolynomial.Analytic.symmetrizedTanhLaw_parity_seed
