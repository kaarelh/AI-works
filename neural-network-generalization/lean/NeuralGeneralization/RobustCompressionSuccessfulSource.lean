import NeuralGeneralization.RobustCompressionSuccessfulLayer
import NeuralGeneralization.RobustCompressionSampledLayer

/-! # Source-bank restriction preserves the actual active-energy and KL budgets -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionLayerComparison
open RobustCompressionLayerParameters RobustCompressionLayerGaussian RobustCompressionSourceBank
open RobustCompressionClipping RobustCoupling CompressionSampling

variable {A B X : Type*} [MeasurableSpace A] [MeasurableSpace B]

theorem product_restrict_lintegral_fst_le
    (μ : Measure A) (ν : Measure B) [IsProbabilityMeasure ν]
    (s : Set (A × B)) (F : A → ℝ≥0∞) (hF : Measurable F) :
    (∫⁻ z, F z.1 ∂(μ.prod ν).restrict s) ≤ ∫⁻ a, F a ∂μ := by
  calc
    _ ≤ ∫⁻ z, F z.1 ∂μ.prod ν := lintegral_mono' Measure.restrict_le_self le_rfl
    _ = _ := by rw [lintegral_prod _ (show AEMeasurable (fun z : A × B => F z.1) (μ.prod ν) from (hF.comp measurable_fst).aemeasurable)]; simp

variable [Fintype X] {N m q : ℕ}
local notation "S" => Fin m → Fin N

/-- The source bank is genuinely independent sampling. Restricting to a
measurable success event incurs no renormalization or entropy penalty. -/
theorem successful_source_cost [NeZero N] [NeZero m]
    (μ : Measure A) [IsProbabilityMeasure μ]
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (b : BankLayerData (A × S) X N m q)
    (H : A → Fin N → EuclideanSpace ℝ (Fin q)) (hH : Measurable H)
    (hactive : ∀ θ I, b.active (θ,I) = H θ)
    {a t T BH BG δ : ℝ} (ha : 0 ≤ a) (ht : 0 < t) (ht1 : t ≤ 1)
    (hT : 0 < T) (hBH : 0 < BH) (hBG : 0 < BG) (hδ : 0 < δ) (hδ1 : δ ≤ 1)
    (hbounded : ∀ θ x i, |b.feature θ x i| ≤ 1)
    (hquad : ∀ θ v, (∑ i, ⟪b.source θ i,v⟫^2)/(N : ℝ) ≤ ‖v‖^2)
    (htrace : ∀ θ, (∑ i, ‖b.source θ i‖^2)/(N : ℝ) ≤ q)
    (success : Set (A × S)) (hsuccess : MeasurableSet success)
    (hgood : ∀ θ ∈ success, sourceBankGood (b.source θ) (b.feature θ) a T (b.indices θ))
    {EH : ℝ≥0∞}
    (henergy : (∫⁻ θ, ENNReal.ofReal (∑ i, ‖H θ i‖^2) ∂μ) ≤ EH)
    (hbudget : (∫⁻ θ, klDiv (P θ) (standardGaussianVector N) ∂μ) ≤
      ENNReal.ofReal (N*δ^3/t^2)) (x : X) :
    let p := b.totalizedParameters a t T BH x
    (∫⁻ θ, ∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
      (Real.tanh (⟪b.active θ i,b.idealFeature x θ⟫+
          Real.sqrt (p.idealVariance θ i : ℝ)*z.1.1 i) -
        Real.tanh (p.clippedFiniteObservable BG (θ,z.2) i))^2)
      ∂layerJointKernel (P.comap Prod.fst measurable_fst) p θ
      ∂(μ.prod (iidSamples (uniformIndexLaw N) m)).restrict success) ≤
      4*(ENNReal.ofReal (4/BH^2)*EH + ENNReal.ofReal (14*N*δ) +
        ENNReal.ofReal ((N : ℝ)*(BH^2*((q : ℝ)/T+2*a)^2 +
          t^2*(a+2*((q : ℝ)/T+2*a)))) + ENNReal.ofReal (64*(N : ℝ)*m/BG^2)) := by
  let ν := (μ.prod (iidSamples (uniformIndexLaw N) m)).restrict success
  let P' : Kernel (A × S) (Fin N → ℝ) := P.comap Prod.fst measurable_fst
  have hmass : ν Set.univ ≤ 1 := by
    exact (Measure.restrict_le_self Set.univ).trans (by simp)
  have heg : (∫⁻ θ, ENNReal.ofReal (∑ i, ‖b.active θ i‖^2) ∂ν) ≤ EH := by
    have heq : (fun θ : A × S => ENNReal.ofReal (∑ i, ‖b.active θ i‖^2)) =
        fun θ => ENNReal.ofReal (∑ i, ‖H θ.1 i‖^2) := by
      funext θ
      rw [hactive θ.1 θ.2]
    rw [heq]
    exact (product_restrict_lintegral_fst_le μ _ success _ (by fun_prop)).trans henergy
  have hkl : (∫⁻ θ, klDiv (P' θ)
      (standardGaussianVector N) ∂ν) ≤ ENNReal.ofReal (N*δ^3/t^2) := by
    change (∫⁻ θ, klDiv (P θ.1) (standardGaussianVector N) ∂ν) ≤ _
    exact (product_restrict_lintegral_fst_le μ _ success _
      (RobustEntropy.measurable_kernel_klDiv P (Kernel.const A (standardGaussianVector N)))).trans hbudget
  apply successful_layer_cost ν hmass (P.comap Prod.fst measurable_fst) b
    ha ht ht1 hT hBH hBG hδ hδ1 hbounded hquad htrace _ heg hkl x
  filter_upwards [ae_restrict_mem hsuccess] with θ hθ
  exact hgood θ hθ

end NeuralGeneralization.RobustCompressionLayerComparison
