import PhysicalGainPrefixResidualRealMap
import VolterraGridSystem
import FiniteVolterraCoordinates
import ValidParallelPicard

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort
namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def baseCoordinates (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (j : Fin (J+1)) :
    EuclideanSpace ℝ (Fin (d+1))→L[ℝ]EuclideanSpace ℝ (CanonicalAmbientIndex states J) :=
  (canonicalAmbientCurry states J).symm.toContinuousLinearMap.comp
    ((propagation M.linear j 0).comp T)

 def propagationCoordinates (M : GainPrefixDynamics P S states J) (j i : Fin (J+1)) :
    EuclideanSpace ℝ (CanonicalAmbientIndex states J)→L[ℝ]EuclideanSpace ℝ (CanonicalAmbientIndex states J) :=
  (canonicalAmbientCurry states J).symm.toContinuousLinearMap.comp
    ((M.propagator j i).comp (canonicalAmbientCurry states J).toContinuousLinearMap)

 def allResidualCoordinates (M : GainPrefixDynamics P S states J) (j : Fin (J+1))
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states J)) : EuclideanSpace ℝ (CanonicalAmbientIndex states J) :=
  (canonicalAmbientCurry states J).symm
    (M.residual j (canonicalAmbientCurry states J x))

 theorem baseCoordinates_norm (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (j : Fin (J+1)) : ‖M.baseCoordinates T j‖≤1 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro x
  change ‖(canonicalAmbientCurry states J).symm ((propagation M.linear j 0) (T x))‖≤1*‖x‖
  rw [LinearIsometryEquiv.norm_map,one_mul]
  exact ((propagation M.linear j 0).le_opNorm _).trans
    ((mul_le_mul (propagation_contracts M.linear M.linear_contracts j 0)
      ((T.le_opNorm x).trans ((mul_le_mul_of_nonneg_right hT (norm_nonneg x)).trans_eq (one_mul _)))
      (norm_nonneg _) (by norm_num : (0:ℝ)≤1)).trans_eq (one_mul _))

 theorem propagationCoordinates_norm (M : GainPrefixDynamics P S states J) (j i : Fin (J+1)) :
    ‖M.propagationCoordinates j i‖≤1 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro x
  change ‖(canonicalAmbientCurry states J).symm (M.propagator j i (canonicalAmbientCurry states J x))‖≤1*‖x‖
  rw [LinearIsometryEquiv.norm_map,one_mul]
  exact ((M.propagator j i).le_opNorm _).trans
    ((mul_le_mul_of_nonneg_right (M.propagator_contracts j i) (norm_nonneg _)).trans_eq
      (by rw [one_mul,LinearIsometryEquiv.norm_map]))

 theorem allResidualCoordinates_range (M : GainPrefixDynamics P S states J) (j : Fin (J+1))
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states J)) :
    ‖M.allResidualCoordinates j x‖≤3*M.nonlinearGain j := by
  rw [allResidualCoordinates,LinearIsometryEquiv.norm_map]
  exact M.residual_range j _

 theorem allResidualCoordinates_eq (M : GainPrefixDynamics P S states J) (j : Fin J)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states J)) :
    M.allResidualCoordinates j.castSucc x=M.residualCoordinates j x := rfl

 theorem allResidualCoordinates_last (M : GainPrefixDynamics P S states J)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states J)) :
    M.allResidualCoordinates (Fin.last J) x=0 := by
  simp [allResidualCoordinates,residual]

 def picardCoefficientMatrix (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) :=
  volterraCoefficients (M.baseCoordinates T) M.propagationCoordinates

 theorem picardCoefficientMatrix_bound (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1) :
    ∀z v,|M.picardCoefficientMatrix T z v|≤1 :=
  volterraCoefficients_bound _ _ (by norm_num) (M.baseCoordinates_norm T hT) M.propagationCoordinates_norm

 def picardCoordinateUpdate (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) :=
  affineRealMap (M.picardCoefficientMatrix T) (fun _=>0)∘residualCarryMap M.allResidualCoordinates

 theorem picardCoordinateUpdate_eval (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J)
    (x : EuclideanSpace ℝ (Fin (d+1)))
    (u : Fin (J+1)→EuclideanSpace ℝ (CanonicalAmbientIndex states J))
    (z : Fin (J+1)×CanonicalAmbientIndex states J) :
    M.picardCoordinateUpdate T (WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun v=>u v.1 v.2))) z=
      finiteVolterraValue (M.baseCoordinates T) M.propagationCoordinates M.allResidualCoordinates x u z.1 z.2 :=
  volterraCoefficients_eval _ _ _ x u z

 theorem picardCoordinateUpdate_range (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (x : EuclideanSpace ℝ (Fin (d+1)))
    (u : Fin (J+1)→EuclideanSpace ℝ (CanonicalAmbientIndex states J)) {R : ℝ} (hx : ‖x‖≤R) :
    ‖M.picardCoordinateUpdate T (WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun v=>u v.1 v.2)))‖≤
      ((Fintype.card (Fin (J+1)×CanonicalAmbientIndex states J):ℝ)+1)*
        (R+∑j:Fin (J+1),3*M.nonlinearGain j) := by
  have hRj (j : Fin (J+1)) : 0≤3*M.nonlinearGain j := mul_nonneg (by norm_num) (M.nonlinearGain_nonneg j)
  have hR : 0≤R := (norm_nonneg x).trans hx
  apply euclidean_norm_of_coordinate_bounds _ (add_nonneg hR (Finset.sum_nonneg fun j _=>hRj j))
  intro z
  rw [M.picardCoordinateUpdate_eval]
  exact (PiLp.norm_apply_le _ z.2).trans
    ((finiteVolterraValue_norm _ _ _ (M.baseCoordinates_norm T hT) M.propagationCoordinates_norm
      (fun j=>3*M.nonlinearGain j) hRj M.allResidualCoordinates_range x u z.1).trans
        (add_le_add hx le_rfl))

def gridSystem (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1) :
    VolterraGridSystem (Fin (d+1)) (CanonicalAmbientIndex states J) J where
  base := M.baseCoordinates T
  transfer := M.propagationCoordinates
  residual := M.allResidualCoordinates
  bound := fun j=>3*M.nonlinearGain j
  base_norm := M.baseCoordinates_norm T hT
  transfer_norm := M.propagationCoordinates_norm
  bound_nonneg := fun j=>mul_nonneg (by norm_num) (M.nonlinearGain_nonneg j)
  residual_range := M.allResidualCoordinates_range

#print axioms gridSystem
#print axioms picardCoefficientMatrix_bound
#print axioms picardCoordinateUpdate_range
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
