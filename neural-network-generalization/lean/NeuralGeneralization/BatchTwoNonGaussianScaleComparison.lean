import NeuralGeneralization.BatchTwoNonGaussianComparison
import NeuralGeneralization.ModelFacts

/-! The density comparison transported to the actual anisotropic network priors.
The comparison factors depend on the finite parameter count but not on σ. -/

noncomputable section
open MeasureTheory ProbabilityTheory
open NeuralGeneralization.ConcreteModel
namespace NeuralGeneralization.BatchTwoNonGaussian

theorem productPrior_eq_map (ν : CoordinateLaw) (d N r : ℕ) (scale : WeightIndex d N r → ℝ) :
    productPrior ν d N r scale =
      (Measure.pi fun _ : WeightIndex d N r => ν.law).map (fun u i => scale i * u i) := by
  rw [Measure.pi_map_pi (f := fun i x => scale i * x) (fun i => by fun_prop)]
  rfl

theorem map_gaussian_scaled (d N r : ℕ) (scale : WeightIndex d N r → ℝ) (c : ℝ) (hc : 0 < c) :
    (Measure.pi fun _ : WeightIndex d N r => gaussianReal 0 (1 / c).toNNReal).map
        (fun u i => scale i * u i) =
      productGaussian d N r (fun i => scale i ^ 2 / c) := by
  rw [Measure.pi_map_pi (f := fun i x => scale i * x) (fun i => by fun_prop)]
  unfold productGaussian
  congr 1
  funext i
  rw [gaussianReal_map_const_mul, mul_zero]
  congr 1
  apply NNReal.eq
  simp only [NNReal.coe_mul, NNReal.coe_mk,
    Real.coe_toNNReal _ (div_nonneg zero_le_one hc.le),
    Real.coe_toNNReal _ (div_nonneg (sq_nonneg _) hc.le)]
  ring

theorem smallScale_sq {d N r : ℕ} (hd : 0 < d) (hN : 0 < N) (σ : ℝ)
    (i : WeightIndex d N r) : smallScale d N r σ i ^ 2 = smallVariance d N r σ i := by
  have hd0 : (0 : ℝ) < d := by exact_mod_cast hd
  have hN0 : (0 : ℝ) < N := by exact_mod_cast hN
  rcases i with ij | (sij | j)
  · simp only [smallScale, smallVariance, mul_pow, Real.sq_sqrt (div_nonneg hN0.le hd0.le)]
    ring
  · rfl
  · simp only [smallScale, smallVariance, div_pow, Real.sq_sqrt hN0.le]

theorem smallVariance_div_sqrt (d N r : ℕ) (σ c : ℝ) (hc : 0 < c) (i : WeightIndex d N r) :
    smallVariance d N r (σ / Real.sqrt c) i = smallVariance d N r σ i / c := by
  rcases i with ij | (sij | j) <;>
    simp only [smallVariance, div_pow, Real.sq_sqrt hc.le] <;> ring

theorem map_gaussian_smallScale {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (σ c : ℝ) (hc : 0 < c) :
    (Measure.pi fun _ : WeightIndex d N r => gaussianReal 0 (1 / c).toNNReal).map
        (fun u i => smallScale d N r σ i * u i) =
      ConcreteModel.smallPrior d N r (σ / Real.sqrt c) := by
  rw [map_gaussian_scaled _ _ _ _ _ hc]
  congr 1
  funext i
  rw [smallScale_sq hd hN, ← smallVariance_div_sqrt _ _ _ _ _ hc]

/-- Actual network prior lower comparison; the prefactor is independent of σ. -/
theorem smallPrior_gaussian_lower (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (σ : ℝ) :
    ENNReal.ofReal (ν.comparisonFactor ν.upperCurvature ^ Fintype.card (WeightIndex d N r)) •
        ConcreteModel.smallPrior d N r (σ / Real.sqrt ν.upperCurvature) ≤ smallPrior ν d N r σ := by
  have h := Measure.map_mono (ν.product_measure_gaussian_lower (I := WeightIndex d N r))
    (show Measurable (fun u i => smallScale d N r σ i * u i) by fun_prop)
  rw [Measure.map_smul, map_gaussian_smallScale hd hN σ _ ν.upperCurvature_pos] at h
  rw [smallPrior, productPrior_eq_map]
  exact h

/-- Actual network prior upper comparison, simultaneously for every event. -/
theorem smallPrior_gaussian_upper (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (σ : ℝ) :
    smallPrior ν d N r σ ≤
      ENNReal.ofReal (ν.comparisonFactor ν.lowerCurvature ^ Fintype.card (WeightIndex d N r)) •
        ConcreteModel.smallPrior d N r (σ / Real.sqrt ν.lowerCurvature) := by
  have h := Measure.map_mono (ν.product_measure_gaussian_upper (I := WeightIndex d N r))
    (show Measurable (fun u i => smallScale d N r σ i * u i) by fun_prop)
  rw [Measure.map_smul, map_gaussian_smallScale hd hN σ _ ν.lowerCurvature_pos] at h
  rw [smallPrior, productPrior_eq_map]
  exact h

end NeuralGeneralization.BatchTwoNonGaussian
