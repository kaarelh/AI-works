import NeuralGeneralization.BatchTwoImprovedSelectedState
import NeuralGeneralization.RobustCompressionSelectedStepLaw

/-! Actual shared new-state kernel of the sharp layer comparison. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory Classical
namespace NeuralGeneralization.BatchTwoImprovedSelectedBank
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompression RobustCompressionCanonicalLayer BatchTwoImprovedCanonicalLayer
open BatchTwoImprovedWeightedSampling RobustCompressionLayerGaussian
variable {d N m s r M q : ℕ} [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)] [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "P" => ActivePrefix d N m s
local notation "E" => EuclideanSpace ℝ (Fin N)
local notation "Rows" => Fin N → E
local notation "HRows" => Fin N → EuclideanSpace ℝ (Fin q)
local notation "Base" => P × FutureWeights N r
local notation "S" => Fin m → Fin N
local notation "R" => Fin N → Fin m → ℝ

def sharpNextHKernel (hq : 0 < q)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH BG : ℝ) (i : Fin M) : Kernel (Base × HRows) (ActivePrefix d N m (s+1)) :=
  let p := (selectedSharpBankData b hb J hJ h hh i).sharpParameters t BH
  RobustCompression.parameterMap ((selectedIndicesKernel (Nat.pos_of_neZero N) hq b hb J hJ) ⊗ₖ
      residualRowsKernel p.sourceMatrix p.sourceMatrix_measurable)
    (fun z => sharpSelectedStateFromH b J t BH BG z.1.1 (z.1.2,z.2))
    (by
      have hm : Measurable (fun z : (Base × HRows) × (S × R) => (z.1.1,(z.1.2,z.2))) := by fun_prop
      exact (measurable_sharpSelectedStateFromH b hb J hJ t BH BG).comp hm)

instance sharpNextHKernel_markov (hq : 0 < q)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h) (t BH BG : ℝ) (i : Fin M) :
    IsMarkovKernel (sharpNextHKernel (q:=q) hq b hb J hJ h hh t BH BG i) := by
  unfold sharpNextHKernel
  infer_instance

theorem sharpNextHKernel_actual (hq : 0 < q)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH BG : ℝ) (i : Fin M) (θ : Base) (g : Rows) :
    sharpNextHKernel hq b hb J hJ h hh t BH BG i
      (θ,actualActiveH (selectedMessageBasis (q:=q) b J θ) t g) =
    sharpCanonicalLayerKernel (Nat.pos_of_neZero N) hq b hb t BH BG
      (selectedCanonicalInput (q:=q) J θ g) := by
  let H := actualActiveH (selectedMessageBasis (q:=q) b J θ) t g
  have hd : Measurable (fun z:S×R => sharpSelectedStateFromH b J t BH BG θ (H,z)) := by
    have hm : Measurable (fun z : S×R => (θ,(H,z))) := by fun_prop
    exact (measurable_sharpSelectedStateFromH b hb J hJ t BH BG).comp hm
  rw [sharpCanonicalLayerKernel_selected_factor (Nat.pos_of_neZero N) hq b hb J hJ t BH BG θ g,
    sharpNextHKernel,RobustCompression.parameterMap_apply]
  ext T hT
  rw [Measure.map_apply hd hT,Kernel.compProd_apply (hd hT),
    Measure.map_apply hd hT,Measure.compProd_apply (hd hT)]
  apply lintegral_congr
  intro I
  rw [residualRowsKernel_apply,Kernel.comap_apply,sharpSelectedResidualKernel_apply]
  rfl

/-- Exact active/coefficient marginal; its right kernel is the one decoded by
`sharpNextHKernel`, including every source-bank failure. -/
theorem actualSharpLayerKernel_active_coefficients (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH : ℝ) (i : Fin M) (θ : Base) :
    (actualSharpLayerKernel hq Q b hb J hJ h hh t BH i θ).map
      (fun z => (actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2)) =
      ((selectedHQueryKernel (q:=q) (currentRowJoint (prefixCurrentLaw Q)).condKernel
        b hb J hJ t i).fst ⊗ₖ
        ((selectedIndicesKernel (Nat.pos_of_neZero N) hq b hb J hJ) ⊗ₖ
          residualRowsKernel
            ((selectedSharpBankData b hb J hJ h hh i).sharpParameters t BH).sourceMatrix
            ((selectedSharpBankData b hb J hJ h hh i).sharpParameters t BH).sourceMatrix_measurable)) θ := by
  have hρ : RobustCompression.parameterMap (currentRowDummyKernel Q)
      (selectedHObservation (q:=q) b J t i) (measurable_selectedHObservation b hb J hJ t i) =
      selectedHQueryKernel (q:=q) (currentRowJoint (prefixCurrentLaw Q)).condKernel b hb J hJ t i := by
    ext p : 1
    rw [RobustCompression.parameterMap_apply,currentRowDummyKernel,Kernel.prod_apply,Kernel.const_apply]
    exact selectedHQueryKernel_augmented_law _ b hb J hJ t i p
  exact BatchTwoImprovedLayerComparison.fullSampledLayerCoupling_active_coefficients
    (selectedIndicesKernel (Nat.pos_of_neZero N) hq b hb J hJ)
    (currentRowDummyKernel Q) (selectedHObservation (q:=q) b J t i)
    (measurable_selectedHObservation b hb J hJ t i)
    (selectedHQueryKernel (q:=q) (currentRowJoint (prefixCurrentLaw Q)).condKernel b hb J hJ t i)
    ((selectedSharpBankData b hb J hJ h hh i).sharpParameters t BH)
    ((selectedSharpBankData b hb J hJ h hh i).sharpParameters_contractive t BH) hρ θ

end NeuralGeneralization.BatchTwoImprovedSelectedBank
