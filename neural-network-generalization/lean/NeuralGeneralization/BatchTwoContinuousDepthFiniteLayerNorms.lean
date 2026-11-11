import NeuralGeneralization.BatchTwoContinuousDepthFiniteNormalized

/-! Exact layer energy and perturbation norms for the normalized model. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous
set_option maxHeartbeats 1200000
set_option backward.isDefEq.respectTransparency false

def internalFrobenius {d N r : ℕ} (u : Weights d N r) (s : Fin r) : ℝ :=
  ‖WithLp.toLp 2 (fun ij : Fin N × Fin N => u (Sum.inr (Sum.inl (s,ij))))‖

def normalizedLayerNorm {d N r : ℕ} (u : Weights d N r) : Fin (r+2) → ℝ :=
  Fin.cases ‖firstBlockProjection d N r (WithLp.toLp 2 u)‖
    (Fin.snoc (internalFrobenius u) ‖readoutEnergyVector u‖)

theorem normalizedLayerNorm_zero {d N r : ℕ} (u : Weights d N r) :
    normalizedLayerNorm u 0=‖firstBlockProjection d N r (WithLp.toLp 2 u)‖ := rfl

theorem normalizedLayerNorm_internal {d N r : ℕ} (u : Weights d N r) (s : Fin r) :
    normalizedLayerNorm u s.castSucc.succ=internalFrobenius u s := by
  simp [normalizedLayerNorm]

theorem normalizedLayerNorm_last {d N r : ℕ} (u : Weights d N r) :
    normalizedLayerNorm u (Fin.last (r+1))=‖readoutEnergyVector u‖ := by
  change normalizedLayerNorm u (Fin.last r).succ=_
  simp only [normalizedLayerNorm,Fin.cases_succ,Fin.snoc_last]

theorem normalizedLayerNorm_nonneg {d N r : ℕ} (u : Weights d N r) (s : Fin (r+2)) :
    0 ≤ normalizedLayerNorm u s := by
  refine Fin.cases ?_ (fun i => ?_) s
  · exact norm_nonneg _
  · refine Fin.lastCases ?_ (fun j => ?_) i
    · rw [show (Fin.last r).succ=Fin.last (r+1) from rfl,normalizedLayerNorm_last]
      exact norm_nonneg _
    · rw [normalizedLayerNorm_internal]
      exact norm_nonneg _

theorem normalizedLayerNorm_energy {d N r : ℕ} (u : Weights d N r) :
    ∑ s,(normalizedLayerNorm u s)^2=∑ q,u q^2 := by
  rw [Fin.sum_univ_succ,Fin.sum_univ_castSucc]
  simp only [normalizedLayerNorm,Fin.cases_zero,Fin.cases_succ,Fin.snoc_castSucc,Fin.snoc_last,
    internalFrobenius,readoutEnergyVector,firstBlockProjection,readoutBlockProjection,
    LinearMap.coe_mk,AddHom.coe_mk,EuclideanSpace.real_norm_sq_eq,PiLp.toLp_apply,
    Fintype.sum_sum_type,Fintype.sum_prod_type]

theorem firstEnergyOperator_add {d N r : ℕ} (u v : Weights d N r) :
    firstEnergyOperator (u+v)=firstEnergyOperator u+firstEnergyOperator v := by
  ext x i
  simp [firstEnergyOperator,coordinateMatrixOperator,Matrix.toLpLin_apply,Matrix.mulVec,
    dotProduct,add_mul,Finset.sum_add_distrib]

theorem internalEnergyOperator_add {d N r : ℕ} (u v : Weights d N r) (s : Fin r) :
    internalEnergyOperator (u+v) s=internalEnergyOperator u s+internalEnergyOperator v s := by
  unfold internalEnergyOperator
  rw [WithLp.toLp_add,map_add]

theorem readoutEnergyVector_add {d N r : ℕ} (u v : Weights d N r) :
    readoutEnergyVector (u+v)=readoutEnergyVector u+readoutEnergyVector v := by
  unfold readoutEnergyVector
  rw [WithLp.toLp_add,map_add]

def smallEnergyBlocks {d N r : ℕ} (u : Weights d N r) (η : ℝ) : Prop :=
  ‖firstBlockProjection d N r (WithLp.toLp 2 u)‖ ≤ η ∧
  (∀ s,‖internalEnergyOperator u s‖ ≤ η) ∧ ‖readoutEnergyVector u‖ ≤ η

theorem firstEnergyOperator_le_layer {d N r : ℕ} (u : Weights d N r) :
    ‖firstEnergyOperator u‖ ≤ normalizedLayerNorm u 0 :=
  coordinateMatrixOperator_norm_le _

theorem internalEnergyOperator_le_layer {d N r : ℕ} (u : Weights d N r) (s : Fin r) :
    ‖internalEnergyOperator u s‖ ≤ normalizedLayerNorm u s.castSucc.succ := by
  rw [normalizedLayerNorm_internal]
  exact coordinateMatrixOperator_norm_le _

theorem first_perturbed_operator {d N r : ℕ} (u v : Weights d N r) {η : ℝ}
    (hv : smallEnergyBlocks v η) :
    ‖firstEnergyOperator (u+v)‖ ≤ normalizedLayerNorm u 0+η ∧
    ‖firstEnergyOperator (u+v)-firstEnergyOperator u‖ ≤ η := by
  have hnorm : ‖firstEnergyOperator v‖ ≤ η := (firstEnergyOperator_le_layer v).trans hv.1
  rw [firstEnergyOperator_add]
  constructor
  · exact (norm_add_le _ _).trans (add_le_add (firstEnergyOperator_le_layer u) hnorm)
  · simpa only [add_sub_cancel_left] using hnorm

theorem internal_perturbed_operator {d N r : ℕ} (u v : Weights d N r) {η : ℝ}
    (hv : smallEnergyBlocks v η) (s : Fin r) :
    ‖internalEnergyOperator (u+v) s‖ ≤ normalizedLayerNorm u s.castSucc.succ+η ∧
    ‖internalEnergyOperator (u+v) s-internalEnergyOperator u s‖ ≤ η := by
  rw [internalEnergyOperator_add]
  constructor
  · exact (norm_add_le _ _).trans (add_le_add (internalEnergyOperator_le_layer u s) (hv.2.1 s))
  · simpa only [add_sub_cancel_left] using hv.2.1 s

theorem readout_perturbed_operator {d N r : ℕ} (u v : Weights d N r) {η : ℝ}
    (hv : smallEnergyBlocks v η) :
    ‖readoutEnergyVector (u+v)‖ ≤ normalizedLayerNorm u (Fin.last (r+1))+η ∧
    ‖readoutEnergyVector (u+v)-readoutEnergyVector u‖ ≤ η := by
  rw [readoutEnergyVector_add,normalizedLayerNorm_last]
  constructor
  · exact (norm_add_le _ _).trans (add_le_add le_rfl hv.2.2)
  · simpa only [add_sub_cancel_left] using hv.2.2

end NeuralGeneralization.BatchTwoContinuousDepthPaper
