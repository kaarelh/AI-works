import PhysicalGainPrefixGridSystem
import PhysicalShortCoordinateTrajectory

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort

namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def coordinateTrajectory (_M : GainPrefixDynamics P S states J)
    (u : EuclideanSpace ℝ (Fin (J+1)×CanonicalAmbientIndex states J)) (j : ℕ) :
    PrefixAmbient states J :=
  if hj:j≤J then canonicalAmbientCurry states J (timeSlice u ⟨j,by omega⟩) else 0

 theorem coordinateTrajectory_fin (M : GainPrefixDynamics P S states J)
    (u : EuclideanSpace ℝ (Fin (J+1)×CanonicalAmbientIndex states J)) (j : Fin (J+1)) :
    M.coordinateTrajectory u j=canonicalAmbientCurry states J (timeSlice u j) := by
  simp only [coordinateTrajectory,dif_pos (Nat.le_of_lt_succ j.isLt)]

 theorem finiteVolterra_curry (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J)
    (x : EuclideanSpace ℝ (Fin (d+1)))
    (u : EuclideanSpace ℝ (Fin (J+1)×CanonicalAmbientIndex states J))
    (j : Fin (J+1)) :
    canonicalAmbientCurry states J
      (finiteVolterraValue (M.baseCoordinates T) M.propagationCoordinates M.allResidualCoordinates
        x (timeSlice u) j)=
    volterra (fun n=>propagation M.linear n 0 (T x)) M.propagator
      (M.residual) (M.coordinateTrajectory u) j := by
  classical
  simp only [finiteVolterraValue,map_add,map_sum,baseCoordinates,ContinuousLinearMap.comp_apply,
    LinearIsometryEquiv.coe_toContinuousLinearEquiv,LinearIsometryEquiv.coe_toLinearEquiv,
    LinearIsometryEquiv.apply_symm_apply,volterra]
  congr 1
  calc
    _ = ∑i:Fin (J+1),if i.val<j.val then
        M.propagator j i (M.residual i (M.coordinateTrajectory u i)) else 0 := by
      apply Finset.sum_congr rfl
      intro i hi
      by_cases hij:i<j
      · simp only [if_pos hij,show i.val<j.val from hij,if_true,propagationCoordinates,
          allResidualCoordinates,ContinuousLinearMap.comp_apply,M.coordinateTrajectory_fin,
          LinearIsometryEquiv.apply_symm_apply]
        change canonicalAmbientCurry states J ((canonicalAmbientCurry states J).symm
          (M.propagator j i (canonicalAmbientCurry states J ((canonicalAmbientCurry states J).symm
            (M.residual i (canonicalAmbientCurry states J (timeSlice u i)))))))=_
        simp only [LinearIsometryEquiv.apply_symm_apply]
      · simp [hij,show ¬i.val<j.val from hij]
    _ = _ := finite_prefix_sum (fun i=>M.propagator j i (M.residual i (M.coordinateTrajectory u i))) (Nat.le_of_lt j.isLt)

 theorem picardCoordinateUpdate_trajectory (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J)
    (x : EuclideanSpace ℝ (Fin (d+1)))
    (u : EuclideanSpace ℝ (Fin (J+1)×CanonicalAmbientIndex states J))
    (j : Fin (J+1)) :
    M.coordinateTrajectory (M.picardCoordinateUpdate T
      (WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun z=>u z)))) j=
    volterra (fun n=>propagation M.linear n 0 (T x)) M.propagator
      (M.residual) (M.coordinateTrajectory u) j := by
  rw [M.coordinateTrajectory_fin]
  convert M.finiteVolterra_curry T x u j using 2
  ext i
  exact M.picardCoordinateUpdate_eval T x (timeSlice u) (j,i)

 theorem coordinateTrajectory_error (M : GainPrefixDynamics P S states J)
    (u v : EuclideanSpace ℝ (Fin (J+1)×CanonicalAmbientIndex states J))
    (j : Fin (J+1)) : ‖M.coordinateTrajectory u j-M.coordinateTrajectory v j‖≤‖u-v‖ := by
  rw [M.coordinateTrajectory_fin,M.coordinateTrajectory_fin,← map_sub,LinearIsometryEquiv.norm_map,
    ← timeSlice_sub]
  exact timeSlice_norm_le _ j

 theorem picardCoordinateUpdate_true_input_error (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.state x 0)
    (x : Cube d) (z : EuclideanSpace ℝ (Fin (d+1)))
    (u : EuclideanSpace ℝ (Fin (J+1)×CanonicalAmbientIndex states J))
    (j : Fin (J+1)) :
    ‖M.coordinateTrajectory (M.picardCoordinateUpdate T
      (WithLp.toLp 2 (Sum.elim (fun i=>z i) (fun v=>u v)))) j-
      volterra (M.affineBase x) M.propagator (M.residual)
        (M.coordinateTrajectory u) j‖≤‖z-normalizedInputFeature d x‖ := by
  rw [M.picardCoordinateUpdate_trajectory]
  simp only [volterra,add_sub_add_right_eq_sub,affineBase,← hTx x,← map_sub]
  exact ((propagation M.linear j 0).le_opNorm _).trans
    ((mul_le_mul (propagation_contracts _ M.linear_contracts j 0)
      ((T.le_opNorm _).trans ((mul_le_mul_of_nonneg_right hT (norm_nonneg _)).trans_eq (one_mul _)))
      (norm_nonneg _) (by norm_num : (0:ℝ)≤1)).trans_eq (one_mul _))

#print axioms finiteVolterra_curry
#print axioms picardCoordinateUpdate_true_input_error
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
