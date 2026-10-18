import NeuralGeneralization.RobustCompressionSampledLayer

/-! # Exact success-restricted cost transfer through the full-field coupling -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory ENNReal Classical
set_option maxHeartbeats 600000
namespace NeuralGeneralization.RobustCompressionLayerComparison
open RobustCompression RobustCompressionLayerGaussian CompressionSampling
variable {A H Ω : Type*} [MeasurableSpace A] [MeasurableSpace H] [MeasurableSpace Ω]
  [StandardBorelSpace H] {N m q : ℕ} [NeZero N]
local notation "Z" => Fin N → ℝ
local notation "S" => Fin m → Fin N
local notation "R" => Fin N → Fin m → ℝ

theorem fullSampledLayerCoupling_restricted_cost
    (μ : Measure A) [IsProbabilityMeasure μ]
    (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q)
    (hρ : parameterMap κ o ho = ρ)
    (success : Set ((A × H) × S)) (hsuccess : MeasurableSet success)
    (F : (((A × H) × S) × (Z × R)) → ℝ≥0∞) (hF : Measurable F) :
    (∫⁻ θ, ∫⁻ w,
      (if ((θ,(o (θ,w.1)).1),w.2.1) ∈ success then
        F (((θ,(o (θ,w.1)).1),w.2.1),((o (θ,w.1)).2,w.2.2)) else 0)
      ∂fullSampledLayerCoupling κ o ho ρ p θ ∂μ) =
    ∫⁻ θ, ∫⁻ z : LayerDraw N m, F (θ,(z.1.1,z.2))
      ∂layerJointKernel (ρ.condKernel.comap Prod.fst measurable_fst) p θ
      ∂((μ ⊗ₘ ρ.fst).prod (iidSamples (uniformIndexLaw N) m)).restrict success := by
  classical
  let G : (A × H) × S → ℝ≥0∞ := fun θ =>
    ∫⁻ z : LayerDraw N m, F (θ,(z.1.1,z.2))
      ∂layerJointKernel (ρ.condKernel.comap Prod.fst measurable_fst) p θ
  have hG : Measurable G := by
    apply Measurable.lintegral_kernel_prod_right
    exact hF.comp (by fun_prop)
  have hGi : Measurable (success.indicator G) := hG.indicator hsuccess
  have hμ : (∫⁻ θ, G θ
        ∂((μ ⊗ₘ ρ.fst).prod (iidSamples (uniformIndexLaw N) m)).restrict success) =
      ∫⁻ θ, ∫⁻ H, ∫⁻ I, success.indicator G ((θ,H),I)
        ∂iidSamples (uniformIndexLaw N) m ∂ρ.fst θ ∂μ := by
    rw [← lintegral_indicator hsuccess,lintegral_prod _ hGi.aemeasurable]
    rw [Measure.lintegral_compProd hGi.lintegral_prod_right']
  change _ = ∫⁻ θ, G θ ∂((μ ⊗ₘ ρ.fst).prod (iidSamples (uniformIndexLaw N) m)).restrict success
  rw [hμ]
  apply lintegral_congr
  intro θ
  let Fθ : (H × Z) × (S × R) → ℝ≥0∞ := fun w =>
    if ((θ,w.1.1),w.2.1) ∈ success then
      F (((θ,w.1.1),w.2.1),(w.1.2,w.2.2)) else 0
  have hFθ : Measurable Fθ := by
    exact (hF.comp (by fun_prop)).ite (hsuccess.preimage (by fun_prop)) measurable_const
  have heq := fullSampledLayerCoupling_cost κ o ho ρ p hρ θ Fθ hFθ
  change (∫⁻ w, Fθ (o (θ,w.1),w.2) ∂fullSampledLayerCoupling κ o ho ρ p θ) = _
  rw [heq]
  apply lintegral_congr
  intro H
  apply lintegral_congr
  intro I
  by_cases hs : ((θ,H),I) ∈ success
  · simp only [Fθ,if_pos hs,Set.indicator_of_mem hs,G]
  · simp only [Fθ,if_neg hs,Set.indicator_of_notMem hs,lintegral_zero]

end NeuralGeneralization.RobustCompressionLayerComparison
