import NeuralGeneralization.BatchTwoImprovedAveragedCost
import NeuralGeneralization.BatchTwoImprovedSelectedBank
import NeuralGeneralization.RobustEntropySelectedEnergy

/-! Sharp selected-layer error with both analytic budgets derived from the
actual current-state law and the actual selected-query entropy. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace Classical
namespace NeuralGeneralization.BatchTwoImprovedSelectedBank
open RobustEntropy RobustGaussianGeometry RobustCompressionInduction ConcreteModel
open BatchTwoImprovedWeightedSampling BatchTwoImprovedLayerComparison
open RobustCompressionLayerGaussian RobustCoupling
variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    [StandardBorelSpace A] [StandardBorelSpace Y] [Nonempty A] [Nonempty Y]
    {N M m q : ℕ} [NeZero N]
    [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
    [MeasurableSpace (QueryMessage (Fin M) q)]
    [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "Rows" => Fin N → EuclideanSpace ℝ (Fin N)

theorem actual_selected_sharp_cost (hq : 0 < q) (hm : 0 < m)
    (Q : Measure (A × (Rows × Y))) [IsProbabilityMeasure Q]
    (Pfuture : Measure Y) [IsProbabilityMeasure Pfuture]
    (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J)
    (h : A → Fin M → Fin N → ℝ) (hh : Measurable h)
    (hbounded : ∀ a x j, |h a x j| ≤ 1)
    {K t BH BG : ℝ} (hK : 0 ≤ K) (ht : 0 < t) (ht1 : t ≤ 1)
    (hBH : 0 < BH) (hBG : 0 < BG)
    (hentropy : futureEntropy Q ((rowGaussian N N).prod Pfuture) ≤
      ENNReal.ofReal (2*N*K/t^2))
    (x : Fin M) (D : ℝ≥0∞)
    (hquery : (∫⁻ p, klDiv
      ((safeQueryKernel (currentRowJoint Q).condKernel (fun a => b a.1)
        (hb.comp measurable_fst) J hJ x).condKernel p)
      (standardGaussianVector N)
      ∂(currentRowJoint Q).fst ⊗ₘ
        (safeQueryKernel (currentRowJoint Q).condKernel (fun a => b a.1)
          (hb.comp measurable_fst) J hJ x).fst) ≤ D) :
    let ρ := selectedHQueryKernel (q:=q) (currentRowJoint Q).condKernel b hb J hJ t x
    let μ := (currentRowJoint Q).fst ⊗ₘ ρ.fst
    let data := selectedSharpBankData (m:=m) b hb J hJ h hh x
    let p := data.sharpParameters t BH
    (∫⁻ θ, ∫⁻ I, if sourceBad (selectedMessageBasis (q:=q) b J θ.1) I then 0 else
      (∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
        (Real.tanh (⟪θ.2 i,activeCoordinateVector (selectedMessageBasis (q:=q) b J θ.1)
          (normalizedFeature (h θ.1.1 x))⟫+Real.sqrt (p.idealVariance (θ,I) i:ℝ)*z.1.1 i)-
          Real.tanh (p.clippedFiniteObservable BG ((θ,I),z.2) i))^2)
        ∂layerJointKernel (ρ.condKernel.comap Prod.fst measurable_fst) p (θ,I))
      ∂selectedIndicesKernel (Nat.pos_of_neZero N) hq b hb J hJ θ ∂μ) ≤
      4*(ENNReal.ofReal (4/BH^2)*ENNReal.ofReal (N*(8*K+2*q)) + ENNReal.ofReal (2*t^2)*D +
        (ENNReal.ofReal (2/(m:ℝ))*ENNReal.ofReal (N*(8*K+2*q))+
          ENNReal.ofReal (16*(N:ℝ)*((q:ℝ)+1)/m))+
        ENNReal.ofReal (128*(N:ℝ)*m/BG^2)) := by
  let κ := (currentRowJoint Q).condKernel
  let ρ := selectedHQueryKernel (q:=q) κ b hb J hJ t x
  let μ := (currentRowJoint Q).fst ⊗ₘ ρ.fst
  have henergy : (∫⁻ θ, ENNReal.ofReal (∑ i : Fin N, ‖θ.2 i‖^2) ∂μ) ≤
      ENNReal.ofReal (N*(8*K+2*q)) := by
    dsimp only [μ]
    rw [Measure.lintegral_compProd (by fun_prop)]
    dsimp only [ρ]
    rw [selectedHQueryKernel_fst]
    exact actual_selected_active_energy Q Pfuture b hb J hJ hK ht (by nlinarith) hentropy
  have hbudget : (∫⁻ θ, klDiv (ρ.condKernel θ) (standardGaussianVector N) ∂μ) ≤ D :=
    selectedHQueryKernel_averaged_cost (currentRowJoint Q).fst κ b hb J hJ t x D hquery
  exact averaged_bank_four_cost (Nat.pos_of_neZero N) hq hm μ
    (fun θ => selectedMessageBasis (q:=q) b J θ.1)
    ((measurable_selectedMessageBasis b hb J hJ).comp measurable_fst)
    Prod.snd measurable_snd (fun θ => h θ.1.1 x)
    (((measurable_pi_apply x).comp hh).comp (by fun_prop)) ρ.condKernel
    (fun θ => hbounded θ.1.1 x) ht.le ht1 hBH hBG Real.tanh
    tanh_lipschitzWith (fun z => (Real.abs_tanh_lt_one z).le) henergy hbudget

end NeuralGeneralization.BatchTwoImprovedSelectedBank
