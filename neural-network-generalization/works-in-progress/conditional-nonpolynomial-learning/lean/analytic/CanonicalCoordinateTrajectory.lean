import CanonicalPicardCoordinates
import CanonicalSignApproximation

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

lemma finite_prefix_sum {E : Type*} [AddCommMonoid E] (g : ℕ→E) {j n : ℕ} (hj : j≤n) :
    (∑i:Fin n,if i.val<j then g i.val else 0)=∑i∈Finset.range j,g i := by
  classical
  rw [Fin.sum_univ_eq_sum_range (fun i=>if i<j then g i else 0) n]
  rw [← Finset.sum_filter]
  congr 1
  ext i
  simp only [Finset.mem_filter,Finset.mem_range]
  omega

def timeSlice {J I : Type*} [Fintype J] [Fintype I]
    (v : EuclideanSpace ℝ (J×I)) (j : J) : EuclideanSpace ℝ I :=
  WithLp.toLp 2 (fun i=>v (j,i))

lemma timeSlice_norm_le {J I : Type*} [Fintype J] [Fintype I]
    (v : EuclideanSpace ℝ (J×I)) (j : J) : ‖timeSlice v j‖≤‖v‖ := by
  have hh : ‖timeSlice v j‖^2≤‖v‖^2 := by
    rw [EuclideanSpace.real_norm_sq_eq,EuclideanSpace.real_norm_sq_eq,Fintype.sum_prod_type]
    change (∑i:I,(v (j,i))^2)≤∑k:J,∑i:I,(v (k,i))^2
    exact Finset.single_le_sum (fun k _=>Finset.sum_nonneg (fun i _=>sq_nonneg (v (k,i)))) (Finset.mem_univ j)
  nlinarith [norm_nonneg (timeSlice v j),norm_nonneg v]

lemma timeSlice_sub {J I : Type*} [Fintype J] [Fintype I]
    (v w : EuclideanSpace ℝ (J×I)) (j : J) : timeSlice (v-w) j=timeSlice v j-timeSlice w j := by
  rfl

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def coordinateTrajectory (_M : FiniteCanonicalDynamics P S states)
    (u : EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H)) (j : ℕ) :
    CanonicalAmbient states H :=
  if hj:j≤H then canonicalAmbientCurry states H (timeSlice u ⟨j,by omega⟩) else 0

 theorem coordinateTrajectory_fin (M : FiniteCanonicalDynamics P S states)
    (u : EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H)) (j : Fin (H+1)) :
    M.coordinateTrajectory u j=canonicalAmbientCurry states H (timeSlice u j) := by
  simp only [coordinateTrajectory,dif_pos (Nat.le_of_lt_succ j.isLt)]

 theorem finiteVolterra_curry (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (x : EuclideanSpace ℝ (Fin (d+1)))
    (u : EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H))
    (j : Fin (H+1)) :
    canonicalAmbientCurry states H
      (finiteVolterraValue (M.baseCoordinates T) M.propagationCoordinates M.allResidualCoordinates
        x (timeSlice u) j)=
    volterra (fun n=>propagation M.normLinear n 0 (T x)) M.propagator
      (M.normResidual (canonicalSignPrecision P)) (M.coordinateTrajectory u) j := by
  classical
  simp only [finiteVolterraValue,map_add,map_sum,baseCoordinates,ContinuousLinearMap.comp_apply,
    LinearIsometryEquiv.coe_toContinuousLinearEquiv,LinearIsometryEquiv.coe_toLinearEquiv,
    LinearIsometryEquiv.apply_symm_apply,volterra]
  congr 1
  calc
    _ = ∑i:Fin (H+1),if i.val<j.val then
        M.propagator j i (M.normResidual (canonicalSignPrecision P) i (M.coordinateTrajectory u i)) else 0 := by
      apply Finset.sum_congr rfl
      intro i hi
      by_cases hij:i<j
      · simp only [if_pos hij,show i.val<j.val from hij,if_true,propagationCoordinates,
          allResidualCoordinates,ContinuousLinearMap.comp_apply,M.coordinateTrajectory_fin,
          LinearIsometryEquiv.apply_symm_apply]
        change canonicalAmbientCurry states H ((canonicalAmbientCurry states H).symm
          (M.propagator j i (canonicalAmbientCurry states H ((canonicalAmbientCurry states H).symm
            (M.normResidual (canonicalSignPrecision P) i (canonicalAmbientCurry states H (timeSlice u i)))))))=_
        simp only [LinearIsometryEquiv.apply_symm_apply]
      · simp [hij,show ¬i.val<j.val from hij]
    _ = _ := finite_prefix_sum (fun i=>M.propagator j i (M.normResidual (canonicalSignPrecision P) i (M.coordinateTrajectory u i))) (Nat.le_of_lt j.isLt)

 theorem picardCoordinateUpdate_trajectory (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (x : EuclideanSpace ℝ (Fin (d+1)))
    (u : EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H))
    (j : Fin (H+1)) :
    M.coordinateTrajectory (M.picardCoordinateUpdate T
      (WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun z=>u z)))) j=
    volterra (fun n=>propagation M.normLinear n 0 (T x)) M.propagator
      (M.normResidual (canonicalSignPrecision P)) (M.coordinateTrajectory u) j := by
  rw [M.coordinateTrajectory_fin]
  convert M.finiteVolterra_curry T x u j using 2
  ext i
  exact M.picardCoordinateUpdate_eval T x (timeSlice u) (j,i)

 theorem coordinateTrajectory_error (M : FiniteCanonicalDynamics P S states)
    (u v : EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H))
    (j : Fin (H+1)) : ‖M.coordinateTrajectory u j-M.coordinateTrajectory v j‖≤‖u-v‖ := by
  rw [M.coordinateTrajectory_fin,M.coordinateTrajectory_fin,← map_sub,LinearIsometryEquiv.norm_map,
    ← timeSlice_sub]
  exact timeSlice_norm_le _ j

 theorem picardCoordinateUpdate_true_input_error (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.normState x 0)
    (x : Cube d) (z : EuclideanSpace ℝ (Fin (d+1)))
    (u : EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H))
    (j : Fin (H+1)) :
    ‖M.coordinateTrajectory (M.picardCoordinateUpdate T
      (WithLp.toLp 2 (Sum.elim (fun i=>z i) (fun v=>u v)))) j-
      volterra (M.affineBase x) M.propagator (M.normResidual (canonicalSignPrecision P))
        (M.coordinateTrajectory u) j‖≤‖z-normalizedInputFeature d x‖ := by
  rw [M.picardCoordinateUpdate_trajectory]
  simp only [volterra,add_sub_add_right_eq_sub,affineBase,← hTx x,← map_sub]
  exact ((propagation M.normLinear j 0).le_opNorm _).trans
    ((mul_le_mul (propagation_contracts _ M.normLinear_norm_le j 0)
      ((T.le_opNorm _).trans ((mul_le_mul_of_nonneg_right hT (norm_nonneg _)).trans_eq (one_mul _)))
      (norm_nonneg _) (by norm_num : (0:ℝ)≤1)).trans_eq (one_mul _))

#print axioms finiteVolterra_curry
#print axioms picardCoordinateUpdate_true_input_error
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic
