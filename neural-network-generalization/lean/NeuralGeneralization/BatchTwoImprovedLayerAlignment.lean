import NeuralGeneralization.BatchTwoImprovedLayerFiber

/-! # Exact alignment support of the actual old/new layer joint -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedSelectedBank
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction

variable {d N m s r M q : ℕ} [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)]
  [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "P" => ActivePrefix d N m s
local notation "E" => EuclideanSpace ℝ (Fin N)
local notation "Rows" => Fin N → E
local notation "Base" => P × FutureWeights N r
local notation "S" => Fin m → Fin N
local notation "R" => Fin N → Fin m → ℝ
local notation "Raw" => Base × ((Rows × (Fin N → ℝ)) × (S × R))
local notation "Pair" => (P × FutureWeights N (r+1)) ×
  (ActivePrefix d N m (s+1) × FutureWeights N r)

theorem sharpSelectedStatePair_future (b : P → Fin M → E)
    (J : Base → Finset (Fin M)) (t BH BG : ℝ) (z : Raw) :
    (splitFuture N r (sharpSelectedStatePair (q:=q) b J t BH BG z).1.2).2 =
      (sharpSelectedStatePair (q:=q) b J t BH BG z).2.2 := by
  change (splitFuture N r ((splitFuture N r).symm (flattenRows N z.2.1.1,z.1.2))).2 = z.1.2
  rw [MeasurableEquiv.apply_symm_apply]

theorem sharpSelectedStatePair_alive_imp (b : P → Fin M → E)
    (J : Base → Finset (Fin M)) (t BH BG : ℝ) (z : Raw) :
    (sharpSelectedStatePair (q:=q) b J t BH BG z).2.1.1 = true →
      (sharpSelectedStatePair (q:=q) b J t BH BG z).1.1.1 = true := by
  change (stepActive z.1.1 _ _).1=true → z.1.1.1=true
  cases hp : z.1.1.1 <;> simp [stepActive,hp]

theorem sharpLayerJoint_future (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH BG : ℝ) (i : Fin M) :
    ∀ᵐ z ∂sharpLayerJoint (q:=q) hq Q b hb J hJ h hh t BH BG i,
      (splitFuture N r z.1.2).2=z.2.2 := by
  unfold sharpLayerJoint
  apply (ae_map_iff (measurable_sharpSelectedStatePair b hb J hJ t BH BG).aemeasurable
    (measurableSet_eq_fun (by fun_prop) (by fun_prop))).mpr
  exact Filter.Eventually.of_forall (sharpSelectedStatePair_future b J t BH BG)

theorem sharpLayerJoint_alive_imp (hq : 0 < q)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (t BH BG : ℝ) (i : Fin M) :
    ∀ᵐ z ∂sharpLayerJoint (q:=q) hq Q b hb J hJ h hh t BH BG i,
      z.2.1.1=true → z.1.1.1=true := by
  have hm : MeasurableSet {z : Pair | z.2.1.1=true → z.1.1.1=true} := by
    simp only [imp_iff_not_or]
    exact (measurableSet_eq_fun (by fun_prop) measurable_const).compl.union
      (measurableSet_eq_fun (by fun_prop) measurable_const)
  unfold sharpLayerJoint
  apply (ae_map_iff (measurable_sharpSelectedStatePair b hb J hJ t BH BG).aemeasurable hm).mpr
  exact Filter.Eventually.of_forall (sharpSelectedStatePair_alive_imp b J t BH BG)

end NeuralGeneralization.BatchTwoImprovedSelectedBank
