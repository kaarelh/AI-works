import NeuralGeneralization.RobustCompressionSelectedLayerCoupling

/-! # Exact alignment support of the actual old/new layer joint -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionCanonicalLayer
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

theorem selectedStatePair_future (φ : ℝ → ℝ) (b : P → Fin M → E)
    (J : Base → Finset (Fin M)) (a t T BH BG : ℝ) (z : Raw) :
    (splitFuture N r (selectedStatePair (q:=q) φ b J a t T BH BG z).1.2).2 =
      (selectedStatePair (q:=q) φ b J a t T BH BG z).2.2 := by
  change (splitFuture N r ((splitFuture N r).symm (flattenRows N z.2.1.1,z.1.2))).2 = z.1.2
  rw [MeasurableEquiv.apply_symm_apply]

theorem selectedStatePair_alive_imp (φ : ℝ → ℝ) (b : P → Fin M → E)
    (J : Base → Finset (Fin M)) (a t T BH BG : ℝ) (z : Raw) :
    (selectedStatePair (q:=q) φ b J a t T BH BG z).2.1.1 = true →
      (selectedStatePair (q:=q) φ b J a t T BH BG z).1.1.1 = true := by
  change (stepActive z.1.1 _ _).1=true → z.1.1.1=true
  cases hp : z.1.1.1 <;> simp [stepActive,hp]

theorem selectedLayerJoint_future
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH BG : ℝ) (i : Fin M) :
    ∀ᵐ z ∂selectedLayerJoint (q:=q) Q φ b hb J hJ h hh a t T BH BG i,
      (splitFuture N r z.1.2).2=z.2.2 := by
  unfold selectedLayerJoint
  apply (ae_map_iff (measurable_selectedStatePair hφ b hb J hJ a t T BH BG).aemeasurable
    (measurableSet_eq_fun (by fun_prop) (by fun_prop))).mpr
  exact Filter.Eventually.of_forall (selectedStatePair_future φ b J a t T BH BG)

theorem selectedLayerJoint_alive_imp
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH BG : ℝ) (i : Fin M) :
    ∀ᵐ z ∂selectedLayerJoint (q:=q) Q φ b hb J hJ h hh a t T BH BG i,
      z.2.1.1=true → z.1.1.1=true := by
  have hm : MeasurableSet {z : Pair | z.2.1.1=true → z.1.1.1=true} := by
    simp only [imp_iff_not_or]
    exact (measurableSet_eq_fun (by fun_prop) measurable_const).compl.union
      (measurableSet_eq_fun (by fun_prop) measurable_const)
  unfold selectedLayerJoint
  apply (ae_map_iff (measurable_selectedStatePair hφ b hb J hJ a t T BH BG).aemeasurable hm).mpr
  exact Filter.Eventually.of_forall (selectedStatePair_alive_imp φ b J a t T BH BG)

end NeuralGeneralization.RobustCompressionCanonicalLayer
