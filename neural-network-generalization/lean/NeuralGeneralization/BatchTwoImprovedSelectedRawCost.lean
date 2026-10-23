import NeuralGeneralization.BatchTwoImprovedBankError

/-! The selected sharp cost for the coupling retaining every original row. -/
noncomputable section
set_option backward.isDefEq.respectTransparency true
set_option maxHeartbeats 300000
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

theorem actual_selected_sharp_raw_cost (hq : 0 < q) (hm : 0 < m)
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
    let κ := (currentRowJoint Q).condKernel
    let ρ := selectedHQueryKernel (q:=q) κ b hb J hJ t x
    let obs := selectedHObservation (q:=q) b J t x
    let data := selectedSharpBankData (m:=m) (q:=q) b hb J hJ h hh x
    let p := data.sharpParameters t BH
    let joint := fullSampledLayerCoupling
      (selectedIndicesKernel (Nat.pos_of_neZero N) hq b hb J hJ)
      (augmentedCurrentRows κ) obs (measurable_selectedHObservation b hb J hJ t x) ρ p
    (∫⁻ θ, ∫⁻ w,
      (if sourceBad (selectedMessageBasis (q:=q) b J θ) w.2.1 then 0 else
        ENNReal.ofReal (data.squaredError Real.tanh t BH BG
          ((θ,(obs (θ,w.1)).1),w.2.1) ((obs (θ,w.1)).2,w.2.2)))
      ∂joint θ ∂(currentRowJoint Q).fst) ≤
      4*(ENNReal.ofReal (4/BH^2)*ENNReal.ofReal (N*(8*K+2*q)) + ENNReal.ofReal (2*t^2)*D +
        (ENNReal.ofReal (2/(m:ℝ))*ENNReal.ofReal (N*(8*K+2*q))+
          ENNReal.ofReal (16*(N:ℝ)*((q:ℝ)+1)/m))+
        ENNReal.ofReal (128*(N:ℝ)*m/BG^2)) := by
  dsimp only
  let κ := (currentRowJoint Q).condKernel
  let ρ := selectedHQueryKernel (q:=q) κ b hb J hJ t x
  let obs := selectedHObservation (q:=q) b J t x
  let data := selectedSharpBankData (m:=m) (q:=q) b hb J hJ h hh x
  let p := data.sharpParameters t BH
  let Samp := selectedIndicesKernel (m:=m) (Nat.pos_of_neZero N) hq b hb J hJ
  let F := fun z : ((A × Y) × (Fin N → EuclideanSpace ℝ (Fin q))) ×
      ((Fin m → Fin N) × ((Fin N → ℝ) × (Fin N → Fin m → ℝ))) =>
    if sourceBad (selectedMessageBasis (q:=q) b J z.1.1) z.2.1 then 0 else
      ENNReal.ofReal (data.squaredError Real.tanh t BH BG (z.1,z.2.1) z.2.2)
  have hF : Measurable F := by
    have hbad := measurable_sourceBad.preimage
      (show Measurable (fun z : ((A × Y) × (Fin N → EuclideanSpace ℝ (Fin q))) ×
        ((Fin m → Fin N) × ((Fin N → ℝ) × (Fin N → Fin m → ℝ))) =>
          (selectedMessageBasis (q:=q) b J z.1.1,z.2.1)) from
        ((measurable_selectedMessageBasis b hb J hJ).comp (by fun_prop)).prodMk (by fun_prop))
    have hdecode : Measurable (fun z : ((A × Y) × (Fin N → EuclideanSpace ℝ (Fin q))) ×
        ((Fin m → Fin N) × ((Fin N → ℝ) × (Fin N → Fin m → ℝ))) => ((z.1,z.2.1),z.2.2)) := by fun_prop
    have herr := SharpBankData.measurable_squaredError data tanh_lipschitzWith.continuous t BH BG
    have herr' := ENNReal.measurable_ofReal.comp (herr.comp hdecode)
    dsimp only [F]
    exact Measurable.ite hbad measurable_const herr' 
  have he (θ : A × Y) := fullSampledLayerCoupling_cost Samp
    (augmentedCurrentRows κ) obs (measurable_selectedHObservation b hb J hJ t x) ρ p
    (selectedHQueryKernel_parameterMap κ b hb J hJ t x) θ
    (fun z => F ((θ,z.1.1),(z.2.1,(z.1.2,z.2.2))))
    (hF.comp (by fun_prop))
  calc
    _ = ∫⁻ θ, ∫⁻ H, ∫⁻ I, ∫⁻ z : LayerDraw N m, F ((θ,H),(I,(z.1.1,z.2)))
        ∂layerJointKernel (ρ.condKernel.comap Prod.fst measurable_fst) p ((θ,H),I)
        ∂Samp (θ,H) ∂ρ.fst θ ∂(currentRowJoint Q).fst := by
      apply lintegral_congr
      intro θ
      exact he θ
    _ ≤ _ := by
      have hf : Measurable (fun θ : (A × Y) × (Fin N → EuclideanSpace ℝ (Fin q)) =>
          ∫⁻ I, ∫⁻ z : LayerDraw N m, F (θ,(I,(z.1.1,z.2)))
            ∂layerJointKernel (ρ.condKernel.comap Prod.fst measurable_fst) p (θ,I)
            ∂Samp θ) := by
        apply Measurable.lintegral_kernel_prod_right
        apply Measurable.lintegral_kernel_prod_right
        exact hF.comp (by fun_prop)
      have hfubini := Measure.lintegral_compProd (μ:=(currentRowJoint Q).fst) (κ:=ρ.fst) hf
      rw [← hfubini]
      convert actual_selected_sharp_cost hq hm Q Pfuture b hb J hJ h hh hbounded hK ht ht1
        hBH hBG hentropy x D hquery using 1
      apply lintegral_congr
      intro θ
      apply lintegral_congr
      intro I
      by_cases hh : sourceBad (selectedMessageBasis (q:=q) b J θ.1) I
      · simp [F,hh]
      · simp only [F,hh,if_false]
        rfl

end NeuralGeneralization.BatchTwoImprovedSelectedBank
