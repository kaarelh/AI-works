import NeuralGeneralization.BatchTwoImprovedSelectedRun
import NeuralGeneralization.BatchTwoImprovedCoefficientBounds
import NeuralGeneralization.RobustCompressionInductionSelectedBounds

/-! Actual bounded-coefficient support throughout the sharp selected run. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedCanonicalLayer
open ConcreteModel RobustCompressionInduction RobustCompressionCanonicalLayer
open RobustGaussianGeometry BatchTwoImprovedWeightedSampling
variable {d N m s q : ℕ} {I : Type*} [Fintype I]
  [MeasurableSpace (QueryMessage I q)] [MeasurableSingletonClass (QueryMessage I q)]

theorem sharpCanonicalDrawKernel_bounded (hN : 0 < N) (hq : 0 < q)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    {t BH BG B : ℝ} (hm : 0 < m) (ht : |t|≤1) (hBH : 0≤BH) (hBG : 0≤BG)
    (hB : 2*BH*((q:ℝ)+1)+2*BG≤B) (z : CanonicalLayerInput d N m s q I) :
    ∀ᵐ draw ∂sharpCanonicalDrawKernel hN hq b hb t BH BG z, ∀ i j, |draw.2 i j|≤B := by
  have hset : MeasurableSet {draw : (Fin m → Fin N) × (Fin N → Fin m → ℝ) |
      ∀ i j, |draw.2 i j|≤B} := by
    simp only [Set.setOf_forall]
    exact MeasurableSet.iInter fun i => MeasurableSet.iInter fun j =>
      measurableSet_le (by fun_prop) measurable_const
  rw [sharpCanonicalDrawKernel,Kernel.comap_apply,sharpReconstructionKernel_factor]
  apply (Measure.ae_compProd_iff hset).mpr
  apply Filter.Eventually.of_forall
  intro S
  rw [Kernel.comap_apply,sharpSourceRowKernel_apply]
  have hdraw : Measurable (sharpSourceRowsDraw t BH BG (sharpCanonicalInput b t z,S)) := by
    have hd : Measurable (fun ξ : Fin N → Fin m → ℝ => ((sharpCanonicalInput b t z,S),ξ)) :=
      measurable_const.prodMk measurable_id
    have he := (measurable_sharpSourceRowsDraw (N:=N) (D:=N) (m:=m) (q:=q) t BH BG).comp hd
    simpa only [Function.comp_def] using he
  have hrows : MeasurableSet {ξ : Fin N → Fin m → ℝ | ∀ i j, |ξ i j|≤B} := by
    simp only [Set.setOf_forall]
    exact MeasurableSet.iInter fun i => MeasurableSet.iInter fun j =>
      measurableSet_le (by fun_prop) measurable_const
  apply (ae_map_iff hdraw.aemeasurable hrows).mpr
  exact Filter.Eventually.of_forall fun ξ i j =>
    (sharpSourceRowsDraw_sourceRows_bounded hN hq hm (canonicalBasis b z)
      (sharpCanonicalInput b t z).2 S ξ ht hBH hBG i j).trans hB

theorem sharpCanonicalLayerKernel_bounded (hN : 0 < N) (hq : 0 < q)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    {t BH BG B : ℝ} (hm : 0<m) (ht : |t|≤1) (hBH : 0≤BH) (hBG : 0≤BG) (hB : 0≤B)
    (hbound : 2*BH*((q:ℝ)+1)+2*BG≤B) (z : CanonicalLayerInput d N m s q I)
    (hz : activePrefixBounded B z.1.1) :
    ∀ᵐ p ∂sharpCanonicalLayerKernel hN hq b hb t BH BG z, activePrefixBounded B p := by
  rw [sharpCanonicalLayerKernel,RobustCompression.parameterMap_apply]
  have hm' : Measurable (fun z : CanonicalLayerInput d N m s q I ×
      ((Fin m → Fin N) × (Fin N → Fin m → ℝ)) =>
      stepActive z.1.1.1 z.2 (sharpCanonicalSuccess b z.1 z.2)) :=
    measurable_stepActive _ _ _ (by fun_prop) (by fun_prop) (measurable_sharpCanonicalSuccess b hb)
  apply (ae_map_iff (hm'.comp measurable_prodMk_left).aemeasurable
    (measurableSet_activePrefixBounded B)).mpr
  filter_upwards [sharpCanonicalDrawKernel_bounded hN hq b hb hm ht hBH hBG hbound z] with draw hdraw
  exact stepActive_bounded hB z.1.1 draw _ hz hdraw
end NeuralGeneralization.BatchTwoImprovedCanonicalLayer

namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustCompressionInduction BatchTwoImprovedCanonicalLayer
variable {d N m q : ℕ}
local notation "QI" => Fin (Fintype.card (Cube d))
local notation "Msg" => QueryMessage QI q

theorem sharpSelectedNext_bounded [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {s r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ) (hq : 0 < q)
    {t BH BG δ η B : ℝ} (hm : 0<m) (ht : |t|≤1)
    (hBH : 0≤BH) (hBG : 0≤BG) (hB : 0≤B) (hbound : 2*BH*((q:ℝ)+1)+2*BG≤B)
    (Q : CanonicalStateLaw d N m s (r+1)) (S : ActualPrefixSelection Q φ hφ q t δ η)
    (hQ : ∀ᵐ z ∂Q.law, activePrefixBounded B z.1) :
    ∀ᵐ z ∂(sharpSelectedNext hφ hq t BH BG δ η Q S).law, activePrefixBounded B z.1 := by
  apply canonicalStepLaw_bounded Q.law _ _ B hQ
  intro z hz
  exact sharpCanonicalLayerKernel_bounded (Nat.pos_of_neZero N) hq
    (indexedPrefixQueries φ) (measurable_indexedPrefixQueries hφ) hm ht hBH hBG hB hbound z hz

theorem SharpSelectedRun.terminal_bounded [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {φ : ℝ → ℝ} {hφ : Continuous φ} {hq : 0<q} {t BH BG δ η B : ℝ}
    {s r : ℕ} {Q : CanonicalStateLaw d N m s r}
    (P : SharpSelectedRun (d:=d) (N:=N) (m:=m) (q:=q) hφ hq t BH BG δ η s r Q)
    (hm : 0<m) (ht : |t|≤1) (hBH : 0≤BH) (hBG : 0≤BG) (hB : 0≤B)
    (hbound : 2*BH*((q:ℝ)+1)+2*BG≤B)
    (hQ : ∀ᵐ z ∂Q.law, activePrefixBounded B z.1) :
    ∀ᵐ z ∂P.terminal.2.law, activePrefixBounded B z.1 := by
  induction P with
  | nil s Q => exact hQ
  | @cons s r Q S tail ih =>
    exact ih (sharpSelectedNext_bounded hφ hq hm ht hBH hBG hB hbound Q S hQ)
end NeuralGeneralization.BatchTwoImprovedInduction
