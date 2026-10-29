import PhysicalGainPrefixCoordinateTrajectory
import PhysicalGainPrefixResidualFamily
import VolterraGridInitialization

noncomputable section
set_option maxHeartbeats 400000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort
namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

lemma base_trajectory (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J)
    (z : EuclideanSpace ℝ (Fin (d+1))) (j : Fin (J+1)) :
    M.coordinateTrajectory (baseVectorMap (M.baseCoordinates T) z) j =
      propagation M.linear j 0 (T z) := by
  rw [M.coordinateTrajectory_fin]
  have hh : timeSlice (baseVectorMap (M.baseCoordinates T) z) j=M.baseCoordinates T j z := by
    ext i
    rfl
  rw [hh]
  change canonicalAmbientCurry states J ((canonicalAmbientCurry states J).symm _) = _
  exact LinearIsometryEquiv.apply_symm_apply _ _

lemma base_true_input_error (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.state x 0)
    (x : Cube d) (z : EuclideanSpace ℝ (Fin (d+1))) (j : Fin (J+1)) :
    ‖M.coordinateTrajectory (baseVectorMap (M.baseCoordinates T) z) j-M.affineBase x j‖≤
      ‖z-normalizedInputFeature d x‖ := by
  rw [M.base_trajectory]
  simp only [affineBase,←hTx x,←map_sub]
  exact ((propagation M.linear j 0).le_opNorm _).trans
    ((mul_le_mul (propagation_contracts _ M.linear_contracts j 0)
      ((T.le_opNorm _).trans ((mul_le_mul_of_nonneg_right hT (norm_nonneg _)).trans_eq (one_mul _)))
      (norm_nonneg _) (by norm_num : (0:ℝ)≤1)).trans_eq (one_mul _))

 theorem coordinate_initial_error (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.state x 0)
    (x : Cube d) (z : EuclideanSpace ℝ (Fin (d+1)))
    (u : EuclideanSpace ℝ (Fin (J+1)×CanonicalAmbientIndex states J))
    {ξ η : ℝ} (hz : ‖z-normalizedInputFeature d x‖≤ξ)
    (hu : ‖u-baseVectorMap (M.baseCoordinates T) z‖≤η) (j : ℕ) (hj : j≤J) :
    ‖M.coordinateTrajectory u j-M.affineBase x j‖≤η+ξ := by
  let jf : Fin (J+1) := ⟨j,by omega⟩
  have h1 := (M.coordinateTrajectory_error u (baseVectorMap (M.baseCoordinates T) z) jf).trans hu
  have h2 := (M.base_true_input_error T hT hTx x z jf).trans hz
  exact (norm_sub_le_norm_sub_add_norm_sub _ (M.coordinateTrajectory (baseVectorMap (M.baseCoordinates T) z) j) _).trans
    (add_le_add h1 h2)

 theorem coordinate_update_error (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.state x 0)
    (x : Cube d) (z : EuclideanSpace ℝ (Fin (d+1)))
    (u v : EuclideanSpace ℝ (Fin (J+1)×CanonicalAmbientIndex states J))
    {ξ η : ℝ} (hz : ‖z-normalizedInputFeature d x‖≤ξ)
    (hv : ‖v-M.picardCoordinateUpdate T
      (WithLp.toLp 2 (Sum.elim (fun i=>z i) (fun i=>u i)))‖≤η)
    (j : ℕ) (hj : j≤J) :
    ‖M.coordinateTrajectory v j-volterra (M.affineBase x) M.propagator
      M.residual (M.coordinateTrajectory u) j‖≤η+ξ := by
  let jf : Fin (J+1) := ⟨j,by omega⟩
  let next := M.picardCoordinateUpdate T (WithLp.toLp 2 (Sum.elim (fun i=>z i) (fun i=>u i)))
  have h1 := (M.coordinateTrajectory_error v next jf).trans hv
  have h2 := (M.picardCoordinateUpdate_true_input_error T hT hTx x z u jf).trans hz
  exact (norm_sub_le_norm_sub_add_norm_sub _ (M.coordinateTrajectory next j) _).trans (add_le_add h1 h2)


def selectedResidualProgram (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) :=
  M.chosenResidualProgram ((M.gridSystem T hT).tolerance η)
    ((M.gridSystem T hT).tolerance_pos hη) ((M.gridSystem T hT).tolerance_one hη hη1)

def compiledPrefix (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) (k : ℕ) :=
  (M.gridSystem T hT).programEvaluator (M.selectedResidualProgram T hT η hη hη1)
    M.allResidualCoefficientBudget η k

lemma compiledPrefix_depth (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) (k : ℕ) :
    (M.compiledPrefix T hT η hη hη1 k).depth≤90*k+11 := by
  apply (M.gridSystem T hT).programEvaluator_depth
  intro j
  exact (M.chosenResidualProgram_spec _ _ _ j).1

/-- The actual threshold graph evaluates the normalized original canonical
prefix to factorial Picard accuracy, with all arithmetic and grid errors
included. -/
theorem compiledPrefix_eval (M : GainPrefixDynamics P S states J) (hd : 1≤d)
    (hinit : ∀x,‖(states 0).feature x‖≤2)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.state x 0)
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) (x : Cube d) :
    let G:=M.gridSystem T hT
    let Q:=G.mesh η
    let N:=G.stateRange
    let a:=normalizedCodes d Q N x
    ∃u:ℕ→G.StateIndex→ScalarCode Q N,
      (∀k,(M.compiledPrefix T hT η hη hη1 k).eval x=
        encodeCoordinateState Q N (Sum.elim a (u k))) ∧
      ∀k,‖M.coordinateTrajectory (decodeCoordinates Q N (u k)) J-M.state x J‖≤
        4*M.nonlinearBudget^k/(k.factorial:ℝ)+η*Real.exp M.nonlinearBudget := by
  intro G Q N a
  have hb (j) : (M.selectedResidualProgram T hT η hη hη1 j).bounded
      (M.allResidualCoefficientBudget j) := (M.chosenResidualProgram_spec _ _ _ j).2.1
  have ha (j) (z) : ‖G.residual j z-(M.selectedResidualProgram T hT η hη hη1 j).realMap z‖≤G.tolerance η := by
    rw [norm_sub_rev]
    exact (M.chosenResidualProgram_spec _ _ _ j).2.2.2 z
  obtain ⟨u,hinput,hzero,hupdate,heval⟩ := G.programEvaluator_eval hd
    (M.selectedResidualProgram T hT η hη hη1) M.allResidualCoefficientBudget hb hη hη1 ha x
  refine ⟨u,heval,?_⟩
  intro k
  apply M.rounded_iterate_error hinit x (fun k=>M.coordinateTrajectory (decodeCoordinates Q N (u k))) hη.le
  · intro j hj
    exact (M.coordinate_initial_error T hT hTx x (decodeCoordinates Q N a)
      (decodeCoordinates Q N (u 0)) hinput hzero j hj).trans (by linarith)
  · intro k j hj
    have hu : ‖decodeCoordinates Q N (u (k+1))-M.picardCoordinateUpdate T
        (WithLp.toLp 2 (Sum.elim (fun i=>decodeCoordinates Q N a i)
          (fun i=>decodeCoordinates Q N (u k) i)))‖≤η/2 := hupdate k
    exact (M.coordinate_update_error T hT hTx x (decodeCoordinates Q N a)
      (decodeCoordinates Q N (u k)) (decodeCoordinates Q N (u (k+1))) hinput hu j hj).trans (by linarith)

#print axioms compiledPrefix_eval
#print axioms compiledPrefix_depth
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
