import NeuralGeneralization.GaussianModelRate
import NeuralGeneralization.GaussianOrthogonal
import NeuralGeneralization.GaussianCylinder

/-!
# Exact cylinder probabilities under the actual network priors

The weighted orthogonal coordinates below first whiten the manuscript's
layer variances, then apply an ordinary Euclidean orthogonal change of basis.
Their law is exactly a product of scalar Gaussians. This supplies the measure
identity needed for a network cylinder argument; geometric containment in a
target margin event remains a separate obligation.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.ConcreteModel

/-- Whitening sends the actual small-prior law to independent equal-variance
Gaussians, with no change of asymptotic regime. -/
theorem map_smallPrior_whiten {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) :
    (smallPrior d N r σ).map whiten =
      Measure.pi (fun _ : WeightIndex d N r => gaussianReal 0 (σ ^ 2).toNNReal) := by
  rw [← map_isotropic_eq_smallPrior hd hN hσ,
    Measure.map_map (continuous_whiten d N r).measurable
      (continuous_unwhiten d N r).measurable]
  have heq : (whiten : Weights d N r → Weights d N r) ∘ unwhiten = id := by
    funext u
    exact whiten_unwhiten hd hN u
  rw [heq, Measure.map_id]

/-- Arbitrary orthogonal coordinates after the exact layer-wise whitening. -/
def orthogonalWhiten {d N r : ℕ}
    (f : EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r)) : Weights d N r → Weights d N r :=
  GaussianOrthogonal.coordinateMap f ∘ whiten

theorem orthogonalWhiten_measurable {d N r : ℕ}
    (f : EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r)) : Measurable (orthogonalWhiten f) :=
  (GaussianOrthogonal.coordinateMap_measurable f).comp
    (continuous_whiten d N r).measurable

theorem map_smallPrior_orthogonalWhiten {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ)
    (f : EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r)) :
    (smallPrior d N r σ).map (orthogonalWhiten f) =
      Measure.pi (fun _ : WeightIndex d N r => gaussianReal 0 (σ ^ 2).toNNReal) := by
  unfold orthogonalWhiten
  rw [← Measure.map_map (GaussianOrthogonal.coordinateMap_measurable f)
    (continuous_whiten d N r).measurable,
    map_smallPrior_whiten hd hN hσ,
    GaussianOrthogonal.productGaussian_map_coordinateMap]

/-- Exact Gaussian product probability for every measurable cylinder of
weighted orthogonal coordinates of the actual finite network. -/
theorem smallPrior_orthogonal_cylinder_measure {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ)
    (f : EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r))
    (A : WeightIndex d N r → Set ℝ) (hA : ∀ i, MeasurableSet (A i)) :
    (smallPrior d N r σ) (orthogonalWhiten f ⁻¹' Set.pi Set.univ A) =
      ∏ i, gaussianReal 0 (σ ^ 2).toNNReal (A i) := by
  rw [← Measure.map_apply (orthogonalWhiten_measurable f) (MeasurableSet.univ_pi hA),
    map_smallPrior_orthogonalWhiten hd hN hσ f, Measure.pi_pi]

/-- The same exact finite-width cylinder identity for every real exponent γ.
The common variance in whitened coordinates is `N^(−γ)`. -/
theorem powerPrior_orthogonal_cylinder_measure {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ : ℝ)
    (f : EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r))
    (A : WeightIndex d N r → Set ℝ) (hA : ∀ i, MeasurableSet (A i)) :
    (powerPrior d N r γ) (orthogonalWhiten f ⁻¹' Set.pi Set.univ A) =
      ∏ i, gaussianReal 0 ((N : ℝ) ^ (-γ)).toNNReal (A i) := by
  have hv : 0 < (N : ℝ) ^ (-γ) := Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _
  rw [powerPrior_eq_smallPrior hN γ,
    smallPrior_orthogonal_cylinder_measure hd hN (Real.sqrt_pos.mpr hv) f A hA,
    Real.sq_sqrt hv.le]

/-- Weighted orthogonal coordinates form a measurable equivalence, so the
law identity also applies to arbitrary events without a measurability premise. -/
def orthogonalWhiteningEquiv {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (f : EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r)) : Weights d N r ≃ᵐ Weights d N r :=
  ((unwhiteningHomeomorph hd hN).symm.toMeasurableEquiv.trans
    (MeasurableEquiv.toLp 2 (Weights d N r))).trans
      (f.toHomeomorph.toMeasurableEquiv.trans
        (MeasurableEquiv.toLp 2 (Weights d N r)).symm)

@[simp] theorem orthogonalWhiteningEquiv_apply {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N)
    (f : EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r)) (w : Weights d N r) :
    orthogonalWhiteningEquiv hd hN f w = orthogonalWhiten f w := rfl

theorem smallPrior_orthogonal_event_measure {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ)
    (f : EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r)) (A : Set (Weights d N r)) :
    (smallPrior d N r σ) (orthogonalWhiten f ⁻¹' A) =
      (Measure.pi fun _ : WeightIndex d N r => gaussianReal 0 (σ ^ 2).toNNReal) A := by
  change (smallPrior d N r σ) ((orthogonalWhiteningEquiv hd hN f) ⁻¹' A) = _
  rw [← MeasurableEquiv.map_apply]
  exact congrArg (fun μ : Measure (Weights d N r) => μ A)
    (map_smallPrior_orthogonalWhiten hd hN hσ f)

/-- Actual prior mass of a cylinder with selected scalar intervals and an
arbitrary independent event in the remaining coordinates. -/
theorem smallPrior_selected_cylinder_exp_lower {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {σ ρ : ℝ} (hσ : 0 < σ) (hρ : 0 < ρ)
    (f : EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r))
    (p : WeightIndex d N r → Prop) [DecidablePred p]
    (a : {i // p i} → ℝ) (B : Set ({i // ¬p i} → ℝ))
    (hB : (1 : ℝ) / 2 ≤
      (Measure.pi fun _ : {i // ¬p i} => gaussianReal 0 (σ ^ 2).toNNReal).real B) :
    (1 / 2) * Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 -
        (Fintype.card {i // p i} : ℝ) *
          (ρ ^ 2 + Real.sqrt (2 * Real.pi) / (2 * ρ))) ≤
      (smallPrior d N r σ).real
        (orthogonalWhiten f ⁻¹'
          ((MeasurableEquiv.piEquivPiSubtypeProd (fun _ : WeightIndex d N r => ℝ) p) ⁻¹'
            ((Set.pi Set.univ fun i => Set.Icc (a i - ρ * σ) (a i + ρ * σ)) ×ˢ B))) := by
  unfold Measure.real
  rw [smallPrior_orthogonal_event_measure hd hN hσ,
    GaussianTail.gaussian_split_cylinder_measure, ENNReal.toReal_mul]
  have hbox := GaussianTail.gaussian_scaled_rectangle_exp_lower a ρ σ hρ hσ
  exact (mul_le_mul hB hbox (Real.exp_nonneg _) (measureReal_nonneg)).trans_eq (mul_comm _ _)

end NeuralGeneralization.ConcreteModel
