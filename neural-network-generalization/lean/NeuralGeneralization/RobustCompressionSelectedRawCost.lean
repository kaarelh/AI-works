import NeuralGeneralization.RobustCompressionSelectedCost
import NeuralGeneralization.RobustCompressionSampledCost
import NeuralGeneralization.RobustCompressionBankError

/-! # The full original-row coupling has the actual selected-layer cost bound -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace Classical
set_option maxHeartbeats 600000
namespace NeuralGeneralization.RobustCompressionSelectedBank
open RobustEntropy RobustGaussianGeometry RobustCompressionInduction ConcreteModel
open RobustCompressionLayerComparison RobustCompressionLayerParameters
open RobustCompressionSourceBank RobustCoupling CompressionSampling
variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    [StandardBorelSpace A] [StandardBorelSpace Y] [Nonempty A] [Nonempty Y]
    {N M m q : ℕ} [NeZero N] [NeZero m]
    [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
    [MeasurableSpace (QueryMessage (Fin M) q)]
    [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "Rows" => Fin N → EuclideanSpace ℝ (Fin N)

theorem actual_selected_raw_cost
    (Q : Measure (A × (Rows × Y))) [IsProbabilityMeasure Q]
    (Pfuture : Measure Y) [IsProbabilityMeasure Pfuture]
    (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J)
    (h : A → Fin M → Fin N → ℝ) (hh : Measurable h)
    (hbounded : ∀ a x i, |h a x i| ≤ 1)
    {K a t T BH BG δ : ℝ} (hK : 0 ≤ K)
    (ha : 0 ≤ a) (ht : 0 < t) (ht1 : t^2 ≤ 1)
    (hT : 0 < T) (hBH : 0 < BH) (hBG : 0 < BG) (hδ : 0 < δ) (hδ1 : δ ≤ 1)
    (hentropy : futureEntropy Q ((rowGaussian N N).prod Pfuture) ≤
      ENNReal.ofReal (2*N*K/t^2))
    (x : Fin M)
    (hquery : (∫⁻ p, klDiv
      ((safeQueryKernel (currentRowJoint Q).condKernel (fun a => b a.1)
        (hb.comp measurable_fst) J hJ x).condKernel p)
      (standardGaussianVector N)
      ∂(currentRowJoint Q).fst ⊗ₘ
        (safeQueryKernel (currentRowJoint Q).condKernel (fun a => b a.1)
          (hb.comp measurable_fst) J hJ x).fst) ≤ ENNReal.ofReal (N*δ^3/t^2))
    (success : Set (SelectedBankState A Y N m q)) (hsuccess : MeasurableSet success)
    (hgood : ∀ θ ∈ success,
      sourceBankGood (sourceRows (selectedMessageBasis (q := q) b J θ.1.1))
        (h θ.1.1.1) a T θ.2) :
    let κ := (currentRowJoint Q).condKernel
    let ρ := selectedHQueryKernel (q := q) κ b hb J hJ t x
    let obs := selectedHObservation (q := q) b J t x
    let data := selectedBankData (m := m) (q := q) b hb J hJ h hh
    let p := data.totalizedParameters a t T BH x
    let joint := fullSampledLayerCoupling (augmentedCurrentRows κ) obs
      (measurable_selectedHObservation b hb J hJ t x) ρ p
    (∫⁻ θ, ∫⁻ w,
      (if ((θ,(obs (θ,w.1)).1),w.2.1) ∈ success then
        ENNReal.ofReal (bankSquaredError data a t T BH BG x
          ((θ,(obs (θ,w.1)).1),w.2.1) ((obs (θ,w.1)).2,w.2.2)) else 0)
      ∂joint θ ∂(currentRowJoint Q).fst) ≤
      4*(ENNReal.ofReal (4/BH^2)*ENNReal.ofReal (N*(8*K+2*q)) +
        ENNReal.ofReal (14*N*δ) +
        ENNReal.ofReal ((N : ℝ)*(BH^2*((q : ℝ)/T+2*a)^2 +
          t^2*(a+2*((q : ℝ)/T+2*a)))) + ENNReal.ofReal (64*(N : ℝ)*m/BG^2)) := by
  let κ := (currentRowJoint Q).condKernel
  let ρ := selectedHQueryKernel (q := q) κ b hb J hJ t x
  let data := selectedBankData (m := m) (q := q) b hb J hJ h hh
  let p := data.totalizedParameters a t T BH x
  have he := fullSampledLayerCoupling_restricted_cost (currentRowJoint Q).fst
    (augmentedCurrentRows κ) (selectedHObservation (q := q) b J t x)
    (measurable_selectedHObservation b hb J hJ t x) ρ p
    (selectedHQueryKernel_parameterMap κ b hb J hJ t x)
    success hsuccess (fun z => ENNReal.ofReal (bankSquaredError data a t T BH BG x z.1 z.2))
    (ENNReal.measurable_ofReal.comp (measurable_bankSquaredError data a t T BH BG x))
  dsimp only
  rw [he]
  exact actual_selected_layer_cost Q Pfuture b hb J hJ h hh hbounded hK ha ht ht1
    hT hBH hBG hδ hδ1 hentropy x hquery success hsuccess hgood

end NeuralGeneralization.RobustCompressionSelectedBank
