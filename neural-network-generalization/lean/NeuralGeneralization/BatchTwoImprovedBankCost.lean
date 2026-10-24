import NeuralGeneralization.BatchTwoImprovedBankENN
import NeuralGeneralization.BatchTwoImprovedLayerBound

/-! All four local errors in the actual sharp conditional coupling. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal RealInnerProductSpace
open MeasureTheory ProbabilityTheory InnerProductSpace InformationTheory
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open RobustCompressionLayerGaussian RobustCompressionLayerCost RobustEntropy
open BatchTwoImprovedLayerComparison
variable {A : Type*} [MeasurableSpace A] {N q m : ℕ}

theorem sharp_bank_four_cost (b : SharpBankData A N N m q)
    (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (θ : A) (hbound : ∀ j, |b.feature θ j| ≤ 1)
    {t BH BG : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) (hBH : 0 < BH) (hBG : 0 < BG)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hφb : ∀ z, |φ z| ≤ 1) :
    let p := b.sharpParameters t BH
    (∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
      (φ (⟪b.active θ i,activeCoordinateVector (b.basis θ) (RobustGaussianGeometry.normalizedFeature (b.feature θ))⟫+
          Real.sqrt (p.idealVariance θ i:ℝ)*z.1.1 i)-
        φ (p.clippedFiniteObservable BG (θ,z.2) i))^2) ∂layerJointKernel P p θ) ≤
      4*(ENNReal.ofReal ((4/BH^2)*∑ i, ‖b.active θ i‖^2)+
        ENNReal.ofReal (2*t^2)*klDiv (P θ) (Measure.pi (fun _ : Fin N => gaussianReal 0 1))+
        ENNReal.ofReal (gaussianParameterError p θ)+ENNReal.ofReal (128*(N:ℝ)*m/BG^2)) := by
  dsimp only
  let p := b.sharpParameters t BH
  have hp := b.sharpParameters_contractive t BH
  have hφm := hφ.continuous.measurable
  have hclip : (∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (p.finiteObservable (θ,z.2) i)-φ (p.clippedFiniteObservable BG (θ,z.2) i))^2)
      ∂p.fullCoupling θ) ≤ ENNReal.ofReal (128*(N:ℝ)*m/BG^2) := by
    exact activation_vector_cost_lintegral_le (p.fullCoupling θ) φ hφm hφb _ _
      ((p.finiteObservable_measurable.comp measurable_prodMk_left).comp measurable_snd)
      (((p.clippedFiniteObservable_measurable BG).comp measurable_prodMk_left).comp measurable_snd)
      (fullCoupling_activation_clipping_error_two p hp θ
        (b.sharpParameters_coefficient_energy hN hq hm (by rwa [abs_of_nonneg ht]) BH θ hbound)
        hBG φ hφ hφb)
  have hc := layerJointKernel_total_cost P p hp θ φ hφ hφb (b.active θ)
    (activeCoordinateVector (b.basis θ) (RobustGaussianGeometry.normalizedFeature (b.feature θ)))
    hBH hBG (b.sharpParameters_idealMean_inner hN t BH θ) hclip
  have htCost := ideal_transport_cost_point P p θ ht
    (b.sharpParameters_idealVariance_le hN t BH θ hbound) φ hφ
  exact hc.trans (mul_le_mul' le_rfl
    (add_le_add (add_le_add (add_le_add le_rfl htCost) le_rfl) le_rfl))

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
