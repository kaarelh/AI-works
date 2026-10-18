import NeuralGeneralization.RobustCouplingRawPath
import NeuralGeneralization.RobustCouplingSmallWidthResources

/-!
# Common finite-grid reduction for the two width branches

Small-width compression is proved outright from the actual Gaussian KL budget.
The large-width premise below is explicitly the actual raw-path construction;
it is not a score-coupling premise or a learning conclusion. The analytic
large-width construction must be supplied before this reduction yields the
unconditional all-width compression theorem.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.ConcreteModel
namespace RobustCompressionInput

theorem finite_grid_compression_of_large_width_raw (p : RobustCompressionInput)
    {N : ℕ} (hd : 0 < p.dimension) (hN : 0 < N)
    (hA : 0 < p.inverseFailure) (hR : 6 ≤ p.inverseRadius)
    {σ t c : ℝ} (ht : 0 < t) (ht1 : t ^ 2 ≤ 1) (hscale : t ^ 2 = N * σ ^ 2)
    (Q : Measure (Weights p.dimension N (p.depth - 2))) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior p.dimension N (p.depth - 2) σ) ≤
      ENNReal.ofReal (N * (p.energy : ℝ) / t ^ 2))
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (hrob : ∀ᵐ w ∂Q, w ∈ robustEvent φ c)
    (hrad : ∀ᵐ w ∂Q, 1 / (p.inverseRadius : ℝ) ≤ robustRadius c w)
    (hlarge : p.widthBound < N →
      ∃ Γ : Measure (Weights p.dimension p.bankSize (p.depth - 2)),
        IsProbabilityMeasure Γ ∧ RawPathCompression φ Q Γ p.weightBound
          (1 / (p.inverseRadius : ℝ)) (1 / (p.inverseFailure : ℝ))) :
    ∃ Γ : Measure (RobustOutputCode p.dimension p.widthBound (p.depth - 2)
        p.weightBound p.inverseOutputError), IsProbabilityMeasure Γ ∧
      ∃ π : ∀ x : Cube p.dimension, RobustStatistics.ProbabilityCoupling Q Γ,
        ∀ x, (π x).joint.real
          (RobustStatistics.scoreFailure (fun w => networkOutput φ w x)
            (fun q => robustGridOutput p.dimension p.widthBound (p.depth - 2)
              p.weightBound p.inverseOutputError φ q x)) ≤ 1 / (p.inverseFailure : ℝ) := by
  by_cases hNM : N ≤ p.widthBound
  · let Γ := Q.map (padAndRoundCode (d := p.dimension) (r := p.depth - 2)
      hNM p.weightBound p.inverseOutputError)
    haveI : IsProbabilityMeasure Γ := Measure.isProbabilityMeasure_map
      (measurable_padAndRoundCode hNM p.weightBound p.inverseOutputError).aemeasurable
    refine ⟨Γ, inferInstance,
      fun _ => smallWidthGridCoupling Q hNM p.weightBound p.inverseOutputError, ?_⟩
    intro x
    exact small_width_grid_score_coupling p hd hN hNM hA (by omega) ht ht1 hscale
      (by simp only [one_div]; exact le_rfl) Q hKL φ hφ x
  · obtain ⟨Γ, hΓ, hraw⟩ := hlarge (Nat.lt_of_not_ge hNM)
    letI : IsProbabilityMeasure Γ := hΓ
    have hmM : p.bankSize ≤ p.widthBound := by dsimp [widthBound]; omega
    let Γgrid := Γ.map (padAndRoundCode (d := p.dimension) (r := p.depth - 2)
      hmM p.weightBound p.inverseOutputError)
    haveI : IsProbabilityMeasure Γgrid := Measure.isProbabilityMeasure_map
      (measurable_padAndRoundCode hmM p.weightBound p.inverseOutputError).aemeasurable
    refine ⟨Γgrid, inferInstance, ?_⟩
    have hRp : (0 : ℝ) < p.inverseRadius := by exact_mod_cast (show 0 < p.inverseRadius by omega)
    apply hraw.finite_grid hmM φ hφ (by positivity : 0 ≤ 1 / (p.inverseRadius : ℝ))
      (one_div_le_one_div_of_le (by norm_num : (0 : ℝ) < 6) (by exact_mod_cast hR))
      p.weightBound_pos (by dsimp [inverseOutputError]; omega)
      (show 1 / (p.inverseOutputError : ℝ) ≤ (1 / (p.inverseRadius : ℝ)) / 8 from ?_)
      hrob hrad
    simp only [inverseOutputError, Nat.cast_mul, Nat.cast_ofNat]
    field_simp
    norm_num

end RobustCompressionInput
end NeuralGeneralization.ConcreteModel
