import NeuralGeneralization.BatchTwoImprovedBankBounds
import NeuralGeneralization.BatchTwoImprovedFullLayer
import NeuralGeneralization.BatchTwoImprovedCanonicalLayer
import NeuralGeneralization.RobustCompressionSelectedOldMarginal
import NeuralGeneralization.RobustEntropySelectedHObservation

/-! The actual selected active bank and its input-independent source kernel.
The full original-row conditional law is retained exactly. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp
open scoped BigOperators RealInnerProductSpace ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedSelectedBank
open RobustEntropy RobustGaussianGeometry RobustCompressionInduction ConcreteModel
open BatchTwoImprovedWeightedSampling RobustCompressionLayerGaussian RobustCompression
variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    {N M m q : ℕ}
    [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
    [MeasurableSpace (QueryMessage (Fin M) q)] [MeasurableSingletonClass (QueryMessage (Fin M) q)]

def selectedSources (b : A → Fin M → EuclideanSpace ℝ (Fin N))
    (J : A × Y → Finset (Fin M)) (θ : A × Y) : Fin N → Fin q → ℝ :=
  fun j k => sourceRows (selectedMessageBasis (q:=q) b J θ) j k

theorem measurable_selectedSources (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) :
    Measurable (selectedSources (q:=q) b J) := by
  apply measurable_pi_lambda
  intro j
  exact (WithLp.measurable_ofLp 2 (Fin q → ℝ)).comp ((measurable_pi_apply j).comp
    (measurable_sourceRows.comp (measurable_selectedMessageBasis b hb J hJ)))

def selectedIndicesKernel (hN : 0 < N) (hq : 0 < q)
    (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) :
    Kernel ((A × Y) × (Fin N → EuclideanSpace ℝ (Fin q))) (Fin m → Fin N) :=
  (sourceIndicesKernel hN hq m).comap (fun θ => selectedSources b J θ.1)
    ((measurable_selectedSources b hb J hJ).comp measurable_fst)

instance selectedIndicesKernel_markov (hN : 0 < N) (hq : 0 < q)
    (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) :
    IsMarkovKernel (selectedIndicesKernel (m:=m) hN hq b hb J hJ) := by
  unfold selectedIndicesKernel
  infer_instance

def selectedSharpBankData (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J)
    (h : A → Fin M → Fin N → ℝ) (hh : Measurable h) (x : Fin M) :
    SharpBankData (((A × Y) × (Fin N → EuclideanSpace ℝ (Fin q))) × (Fin m → Fin N)) N N m q :=
  sampledBankData (fun θ => selectedMessageBasis (q:=q) b J θ.1)
    ((measurable_selectedMessageBasis b hb J hJ).comp measurable_fst)
    Prod.snd measurable_snd (fun θ => h θ.1.1 x)
      (((measurable_pi_apply x).comp hh).comp (by fun_prop))

section Actual
variable {d s r : ℕ} [NeZero N]
local notation "P" => ActivePrefix d N m s
local notation "E" => EuclideanSpace ℝ (Fin N)
local notation "Rows" => Fin N → E
local notation "Base" => P × FutureWeights N r
local notation "S" => Fin m → Fin N
local notation "R" => Fin N → Fin m → ℝ

def actualSharpLayerKernel (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH : ℝ) (x : Fin M) : Kernel Base ((Rows × (Fin N → ℝ)) × (S × R)) :=
  BatchTwoImprovedLayerComparison.fullSampledLayerCoupling
    (selectedIndicesKernel (Nat.pos_of_neZero N) hq b hb J hJ)
    (currentRowDummyKernel Q) (selectedHObservation (q:=q) b J t x)
    (measurable_selectedHObservation b hb J hJ t x)
    (selectedHQueryKernel (q:=q) (currentRowJoint (prefixCurrentLaw Q)).condKernel b hb J hJ t x)
    ((selectedSharpBankData b hb J hJ h hh x).sharpParameters t BH)

instance actualSharpLayerKernel_markov (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h) (t BH : ℝ) (x : Fin M) :
    IsMarkovKernel (actualSharpLayerKernel hq Q b hb J hJ h hh t BH x) := by
  unfold actualSharpLayerKernel
  infer_instance

theorem actualSharpLayerKernel_fst (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h) (t BH : ℝ) (x : Fin M) :
    (actualSharpLayerKernel hq Q b hb J hJ h hh t BH x).fst=currentRowDummyKernel Q := by
  exact BatchTwoImprovedLayerComparison.fullSampledLayerCoupling_original _ _ _ _ _ _

theorem actualSharpLayerKernel_restores_old (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h) (t BH : ℝ) (x : Fin M) :
    ((currentRowJoint (prefixCurrentLaw Q)).fst ⊗ₘ
      actualSharpLayerKernel hq Q b hb J hJ h hh t BH x).map
        (fun z => restoreCurrentRowState (z.1,z.2.1.1)) = Q :=
  layer_comparison_restores_old Q _ (actualSharpLayerKernel_fst hq Q b hb J hJ h hh t BH x)

end Actual
end NeuralGeneralization.BatchTwoImprovedSelectedBank
