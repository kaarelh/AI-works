import NeuralGeneralization.RobustCompressionSuccessfulSource
import NeuralGeneralization.RobustCompressionSelectedBank
import NeuralGeneralization.RobustEntropySelectedEnergy

/-! # The actual selected-current law satisfies the full hidden-layer error bound

Both analytic budgets are derived from the current canonical law and the
actual selected-query entropy inequality. No approximating-law or transport
certificate is assumed.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace Classical
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

theorem actual_selected_layer_cost
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
    let μ := (currentRowJoint Q).fst ⊗ₘ ρ.fst
    let data := selectedBankData (m := m) (q := q) b hb J hJ h hh
    let p := data.totalizedParameters a t T BH x
    (∫⁻ θ, ∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
      (Real.tanh (⟪data.active θ i,data.idealFeature x θ⟫+
          Real.sqrt (p.idealVariance θ i : ℝ)*z.1.1 i) -
        Real.tanh (p.clippedFiniteObservable BG (θ,z.2) i))^2)
      ∂layerJointKernel (ρ.condKernel.comap Prod.fst measurable_fst) p θ
      ∂(μ.prod (iidSamples (uniformIndexLaw N) m)).restrict success) ≤
      4*(ENNReal.ofReal (4/BH^2)*ENNReal.ofReal (N*(8*K+2*q)) +
        ENNReal.ofReal (14*N*δ) +
        ENNReal.ofReal ((N : ℝ)*(BH^2*((q : ℝ)/T+2*a)^2 +
          t^2*(a+2*((q : ℝ)/T+2*a)))) + ENNReal.ofReal (64*(N : ℝ)*m/BG^2)) := by
  let κ := (currentRowJoint Q).condKernel
  let ρ := selectedHQueryKernel (q := q) κ b hb J hJ t x
  let μ := (currentRowJoint Q).fst ⊗ₘ ρ.fst
  let data := selectedBankData (m := m) (q := q) b hb J hJ h hh
  have henergy : (∫⁻ θ, ENNReal.ofReal (∑ i : Fin N, ‖θ.2 i‖^2) ∂μ) ≤
      ENNReal.ofReal (N*(8*K+2*q)) := by
    dsimp only [μ]
    rw [Measure.lintegral_compProd (by fun_prop)]
    dsimp only [ρ]
    rw [selectedHQueryKernel_fst]
    exact actual_selected_active_energy Q Pfuture b hb J hJ hK ht ht1 hentropy
  have hbudget : (∫⁻ θ, klDiv (ρ.condKernel θ) (standardGaussianVector N) ∂μ) ≤
      ENNReal.ofReal (N*δ^3/t^2) :=
    selectedHQueryKernel_averaged_cost (currentRowJoint Q).fst κ b hb J hJ t x _ hquery
  exact successful_source_cost μ ρ.condKernel data (fun θ => θ.2) measurable_snd
    (fun _ _ => rfl) ha ht (by nlinarith) hT hBH hBG hδ hδ1
    (fun θ => hbounded θ.1.1.1)
    (SelectedBank.population_contractive b hb J hJ h hh (NeZero.pos N))
    (SelectedBank.population_trace b hb J hJ h hh (NeZero.pos N))
    success hsuccess hgood henergy hbudget x

end NeuralGeneralization.RobustCompressionSelectedBank
