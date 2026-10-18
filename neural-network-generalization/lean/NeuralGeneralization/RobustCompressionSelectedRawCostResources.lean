import NeuralGeneralization.RobustCompressionSelectedRawCost
import NeuralGeneralization.RobustCompressionSuccessfulLayerResources

/-! # Explicit resources for the complete original-row comparison -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace Classical
namespace NeuralGeneralization.RobustCompressionSelectedBank
open RobustEntropy RobustGaussianGeometry RobustCompressionInduction ConcreteModel
open RobustCompressionLayerComparison RobustCompressionLayerParameters
open RobustCompressionSourceBank RobustCoupling CompressionSampling
variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    [StandardBorelSpace A] [StandardBorelSpace Y] [Nonempty A] [Nonempty Y]
    {N M : ℕ} [NeZero N]
    [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]

/-- With the declared polynomial resources, the complete actual successful
hidden-layer error is at most 10 N / inverseLayerError. The only analytic
premises are actual current-law entropy and the selected query's proved KL
budget, not an approximation or transport certificate. -/
theorem actual_selected_raw_cost_resources
    (res : RobustCompressionInput)
    [MeasurableSpace (QueryMessage (Fin M) res.activeRank)]
    [MeasurableSingletonClass (QueryMessage (Fin M) res.activeRank)]
    (Q : Measure (A × ((Fin N → EuclideanSpace ℝ (Fin N)) × Y))) [IsProbabilityMeasure Q]
    (Pfuture : Measure Y) [IsProbabilityMeasure Pfuture]
    (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J)
    (h : A → Fin M → Fin N → ℝ) (hh : Measurable h)
    (hbounded : ∀ a x i, |h a x i| ≤ 1)
    {t : ℝ} (hE : 0 < res.inverseLayerError) (ht : 0 < t) (ht1 : t^2 ≤ 1)
    (hentropy : futureEntropy Q ((rowGaussian N N).prod Pfuture) ≤
      ENNReal.ofReal (2*N*res.energy/t^2))
    (x : Fin M)
    (hquery : (∫⁻ p, klDiv
      ((safeQueryKernel (currentRowJoint Q).condKernel (fun a => b a.1)
        (hb.comp measurable_fst) J hJ x).condKernel p)
      (standardGaussianVector N)
      ∂(currentRowJoint Q).fst ⊗ₘ
        (safeQueryKernel (currentRowJoint Q).condKernel (fun a => b a.1)
          (hb.comp measurable_fst) J hJ x).fst) ≤
      ENNReal.ofReal (N*((res.inverseSelectionError : ℝ)⁻¹)^3/t^2))
    (success : Set (SelectedBankState A Y N res.bankSize res.activeRank))
    (hsuccess : MeasurableSet success)
    (hgood : ∀ θ ∈ success,
      sourceBankGood (sourceRows (selectedMessageBasis (q := res.activeRank) b J θ.1.1))
        (h θ.1.1.1) (res.inverseKernelPrecision : ℝ)⁻¹ res.sourceClip θ.2) :
    let κ := (currentRowJoint Q).condKernel
    let ρ := selectedHQueryKernel (q := res.activeRank) κ b hb J hJ t x
    let obs := selectedHObservation (q := res.activeRank) b J t x
    let data := selectedBankData (m := res.bankSize) (q := res.activeRank) b hb J hJ h hh
    let p := data.totalizedParameters (res.inverseKernelPrecision : ℝ)⁻¹ t res.sourceClip
      (Real.sqrt (res.activeSquaredBound : ℝ)) x
    let joint := fullSampledLayerCoupling (augmentedCurrentRows κ) obs
      (measurable_selectedHObservation b hb J hJ t x) ρ p
    (∫⁻ θ, ∫⁻ w,
      (if ((θ,(obs (θ,w.1)).1),w.2.1) ∈ success then
        ENNReal.ofReal (bankSquaredError data (res.inverseKernelPrecision : ℝ)⁻¹ t res.sourceClip
          (Real.sqrt (res.activeSquaredBound : ℝ)) (Real.sqrt (res.gaussianSquaredBound : ℝ)) x
          ((θ,(obs (θ,w.1)).1),w.2.1) ((obs (θ,w.1)).2,w.2.2)) else 0)
      ∂joint θ ∂(currentRowJoint Q).fst) ≤
      ENNReal.ofReal (10*(N : ℝ)/res.inverseLayerError) := by
  letI : NeZero res.bankSize := ⟨res.bankSize_pos.ne'⟩
  have hsel : 0 < res.inverseSelectionError := by
    unfold RobustCompressionInput.inverseSelectionError
    positivity
  have hselR : (0 : ℝ) < res.inverseSelectionError := by exact_mod_cast hsel
  have hsel1 : (1 : ℝ) ≤ res.inverseSelectionError := by exact_mod_cast hsel
  have hδ : 0 < (res.inverseSelectionError : ℝ)⁻¹ := inv_pos.mpr hselR
  have hδ1 : (res.inverseSelectionError : ℝ)⁻¹ ≤ 1 := (inv_le_one₀ hselR).mpr hsel1
  have hq : 0 < res.activeRank := by unfold RobustCompressionInput.activeRank; omega
  have hBH : 0 < res.activeSquaredBound := by
    unfold RobustCompressionInput.activeSquaredBound
    positivity
  have hBG : 0 < res.gaussianSquaredBound := by
    unfold RobustCompressionInput.gaussianSquaredBound
    exact Nat.mul_pos (Nat.mul_pos (by norm_num) res.bankSize_pos) hE
  have hBH' : 0 < Real.sqrt (res.activeSquaredBound : ℝ) :=
    Real.sqrt_pos.mpr (by exact_mod_cast hBH)
  have hBG' : 0 < Real.sqrt (res.gaussianSquaredBound : ℝ) :=
    Real.sqrt_pos.mpr (by exact_mod_cast hBG)
  have hT : (0 : ℝ) < res.sourceClip := by exact_mod_cast res.sourceClip_pos hE
  have hbound := actual_selected_raw_cost (m := res.bankSize) (q := res.activeRank)
    Q Pfuture b hb J hJ h hh hbounded (K := (res.energy : ℝ)) (Nat.cast_nonneg _)
    (a := (res.inverseKernelPrecision : ℝ)⁻¹) (by positivity)
    ht ht1 hT hBH' hBG' hδ hδ1 hentropy x hquery success hsuccess hgood
  exact hbound.trans (res.successful_layer_resources N hE ht1)

end NeuralGeneralization.RobustCompressionSelectedBank
