import NeuralGeneralization.RobustCompressionSelectedStateDraw
import NeuralGeneralization.RobustCompressionSelectedBank
import NeuralGeneralization.RobustCompressionSelectedOldMarginal
import NeuralGeneralization.RobustCompressionSelectedStepLaw

/-! # The literal old/new selected-layer joint law

The old marginal retains all original current rows and remaining future.
The new decoder observes only active H, the bounded message, and the common
source/coefficient draw. The residual comparison may depend on a test input.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory Classical
namespace NeuralGeneralization.RobustCompressionCanonicalLayer
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompression RobustCompressionLayerComparison RobustCompressionSelectedBank
variable {d N m s r M q : ℕ} [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)]
  [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "P" => ActivePrefix d N m s
local notation "E" => EuclideanSpace ℝ (Fin N)
local notation "Rows" => Fin N → E
local notation "HRows" => Fin N → EuclideanSpace ℝ (Fin q)
local notation "Base" => P × FutureWeights N r
local notation "S" => Fin m → Fin N
local notation "R" => Fin N → Fin m → ℝ
local notation "Raw" => Base × ((Rows × (Fin N → ℝ)) × (S × R))

def actualSelectedLayerKernel
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH : ℝ) (i : Fin M) :
    Kernel Base ((Rows × (Fin N → ℝ)) × (S × R)) :=
  fullSampledLayerCoupling (currentRowDummyKernel Q)
    (selectedHObservation (q := q) b J t i)
    (measurable_selectedHObservation b hb J hJ t i)
    (selectedHQueryKernel (q := q) (currentRowJoint (prefixCurrentLaw Q)).condKernel
      b hb J hJ t i)
    ((selectedBankData b hb J hJ h hh).totalizedParameters a t T BH i)

instance actualSelectedLayerKernel_markov
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH : ℝ) (i : Fin M) :
    IsMarkovKernel (actualSelectedLayerKernel (q := q) Q b hb J hJ h hh a t T BH i) := by
  unfold actualSelectedLayerKernel
  infer_instance

def selectedStatePair (φ : ℝ → ℝ) (b : P → Fin M → E)
    (J : Base → Finset (Fin M)) (a t T BH BG : ℝ) (z : Raw) :
    (P × FutureWeights N (r+1)) × (ActivePrefix d N m (s+1) × FutureWeights N r) :=
  (restoreCurrentRowState (z.1,z.2.1.1),
    (selectedStateFromH φ b J a t T BH BG z.1
      (actualActiveH (selectedMessageBasis (q := q) b J z.1) t z.2.1.1,z.2.2),z.1.2))

theorem measurable_selectedStatePair {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J) (a t T BH BG : ℝ) :
    Measurable (selectedStatePair (q := q) φ b J a t T BH BG) := by
  have ho : Measurable (fun z : Raw => restoreCurrentRowState (z.1,z.2.1.1)) :=
    measurable_restoreCurrentRowState.comp (by fun_prop)
  have hx : Measurable (fun z : Raw => (z.1,z.2.1.1)) := by fun_prop
  have hH0 : Measurable (fun p : Base × Rows =>
      actualActiveH (selectedMessageBasis (q := q) b J p.1) t p.2) :=
    measurable_actualActiveH_parameter _ (measurable_selectedMessageBasis b hb J hJ) t
  have hH := hH0.comp hx
  have hd : Measurable (fun z : Raw =>
      (z.1,(actualActiveH (selectedMessageBasis (q := q) b J z.1) t z.2.1.1,z.2.2))) :=
    measurable_fst.prodMk (hH.prodMk (by fun_prop))
  exact ho.prodMk (((measurable_selectedStateFromH hφ b hb J hJ a t T BH BG).comp hd).prodMk
    (by fun_prop))

def selectedLayerJoint
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (φ : ℝ → ℝ) (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH BG : ℝ) (i : Fin M) :
    Measure ((P × FutureWeights N (r+1)) ×
      (ActivePrefix d N m (s+1) × FutureWeights N r)) :=
  ((currentRowJoint (prefixCurrentLaw Q)).fst ⊗ₘ
    actualSelectedLayerKernel (q := q) Q b hb J hJ h hh a t T BH i).map
      (selectedStatePair (q := q) φ b J a t T BH BG)

theorem selectedLayerJoint_probability
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH BG : ℝ) (i : Fin M) :
    IsProbabilityMeasure (selectedLayerJoint (q := q) Q φ b hb J hJ h hh a t T BH BG i) := by
  unfold selectedLayerJoint
  exact Measure.isProbabilityMeasure_map
    (measurable_selectedStatePair hφ b hb J hJ a t T BH BG).aemeasurable

/-- The complete old canonical state is retained exactly. -/
theorem selectedLayerJoint_left
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH BG : ℝ) (i : Fin M) :
    (selectedLayerJoint (q := q) Q φ b hb J hJ h hh a t T BH BG i).map Prod.fst = Q := by
  rw [selectedLayerJoint,Measure.map_map measurable_fst
    (measurable_selectedStatePair hφ b hb J hJ a t T BH BG)]
  exact fullSampledLayerCoupling_restores_old Q _ _ _ _

end NeuralGeneralization.RobustCompressionCanonicalLayer
