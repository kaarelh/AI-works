import NeuralGeneralization.BatchTwoImprovedNextKernel
import NeuralGeneralization.RobustCompressionSelectedLayerRightReduction

/-! Actual old/new joint law of one sharp selected compression layer. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory Classical
namespace NeuralGeneralization.BatchTwoImprovedSelectedBank
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompression RobustCompressionCanonicalLayer BatchTwoImprovedCanonicalLayer
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

def sharpSelectedStatePair (b : P → Fin M → E)
    (J : Base → Finset (Fin M)) (t BH BG : ℝ) (z : Raw) :
    (P × FutureWeights N (r+1)) × (ActivePrefix d N m (s+1) × FutureWeights N r) :=
  (restoreCurrentRowState (z.1,z.2.1.1),
    (sharpSelectedStateFromH b J t BH BG z.1
      (actualActiveH (selectedMessageBasis (q := q) b J z.1) t z.2.1.1,z.2.2),z.1.2))

theorem measurable_sharpSelectedStatePair (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J) (t BH BG : ℝ) :
    Measurable (sharpSelectedStatePair (q := q) b J t BH BG) := by
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
  exact ho.prodMk (((measurable_sharpSelectedStateFromH b hb J hJ t BH BG).comp hd).prodMk
    (by fun_prop))

def sharpLayerJoint (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH BG : ℝ) (i : Fin M) :
    Measure ((P × FutureWeights N (r+1)) ×
      (ActivePrefix d N m (s+1) × FutureWeights N r)) :=
  ((currentRowJoint (prefixCurrentLaw Q)).fst ⊗ₘ
    actualSharpLayerKernel (q := q) hq Q b hb J hJ h hh t BH i).map
      (sharpSelectedStatePair (q := q) b J t BH BG)

theorem sharpLayerJoint_probability (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH BG : ℝ) (i : Fin M) :
    IsProbabilityMeasure (sharpLayerJoint (q := q) hq Q b hb J hJ h hh t BH BG i) := by
  unfold sharpLayerJoint
  exact Measure.isProbabilityMeasure_map
    (measurable_sharpSelectedStatePair b hb J hJ t BH BG).aemeasurable

/-- The complete old canonical state is retained exactly. -/
theorem sharpLayerJoint_left (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH BG : ℝ) (i : Fin M) :
    (sharpLayerJoint (q := q) hq Q b hb J hJ h hh t BH BG i).map Prod.fst = Q := by
  rw [sharpLayerJoint,Measure.map_map measurable_fst
    (measurable_sharpSelectedStatePair b hb J hJ t BH BG)]
  exact actualSharpLayerKernel_restores_old hq Q b hb J hJ h hh t BH i

end NeuralGeneralization.BatchTwoImprovedSelectedBank
