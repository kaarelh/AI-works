import CanonicalResidualRealMap
import FiniteVolterraCoordinates
import ValidParallelPicard

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def baseCoordinates (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (j : Fin (H+1)) :
    EuclideanSpace ℝ (Fin (d+1))→L[ℝ]EuclideanSpace ℝ (CanonicalAmbientIndex states H) :=
  (canonicalAmbientCurry states H).symm.toContinuousLinearMap.comp
    ((propagation M.normLinear j 0).comp T)

 def propagationCoordinates (M : FiniteCanonicalDynamics P S states) (j i : Fin (H+1)) :
    EuclideanSpace ℝ (CanonicalAmbientIndex states H)→L[ℝ]EuclideanSpace ℝ (CanonicalAmbientIndex states H) :=
  (canonicalAmbientCurry states H).symm.toContinuousLinearMap.comp
    ((M.propagator j i).comp (canonicalAmbientCurry states H).toContinuousLinearMap)

 def allResidualCoordinates (M : FiniteCanonicalDynamics P S states) (j : Fin (H+1))
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states H)) : EuclideanSpace ℝ (CanonicalAmbientIndex states H) :=
  (canonicalAmbientCurry states H).symm
    (M.normResidual (canonicalSignPrecision P) j (canonicalAmbientCurry states H x))

 theorem baseCoordinates_norm (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (j : Fin (H+1)) : ‖M.baseCoordinates T j‖≤1 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro x
  change ‖(canonicalAmbientCurry states H).symm ((propagation M.normLinear j 0) (T x))‖≤1*‖x‖
  rw [LinearIsometryEquiv.norm_map,one_mul]
  exact ((propagation M.normLinear j 0).le_opNorm _).trans
    ((mul_le_mul (propagation_contracts M.normLinear M.normLinear_norm_le j 0)
      ((T.le_opNorm x).trans ((mul_le_mul_of_nonneg_right hT (norm_nonneg x)).trans_eq (one_mul _)))
      (norm_nonneg _) (by norm_num : (0:ℝ)≤1)).trans_eq (one_mul _))

 theorem propagationCoordinates_norm (M : FiniteCanonicalDynamics P S states) (j i : Fin (H+1)) :
    ‖M.propagationCoordinates j i‖≤1 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro x
  change ‖(canonicalAmbientCurry states H).symm (M.propagator j i (canonicalAmbientCurry states H x))‖≤1*‖x‖
  rw [LinearIsometryEquiv.norm_map,one_mul]
  exact ((M.propagator j i).le_opNorm _).trans
    ((mul_le_mul_of_nonneg_right (M.propagator_norm_le j i) (norm_nonneg _)).trans_eq
      (by rw [one_mul,LinearIsometryEquiv.norm_map]))

 theorem allResidualCoordinates_range (M : FiniteCanonicalDynamics P S states) (j : Fin (H+1))
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states H)) :
    ‖M.allResidualCoordinates j x‖≤M.residualRange (canonicalSignPrecision P) j := by
  rw [allResidualCoordinates,LinearIsometryEquiv.norm_map]
  exact M.normResidual_range (canonicalSignPrecision_pos P) j _

 theorem allResidualCoordinates_eq (M : FiniteCanonicalDynamics P S states) (j : Fin H)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states H)) :
    M.allResidualCoordinates j.castSucc x=M.residualCoordinates j x := rfl

 theorem allResidualCoordinates_last (M : FiniteCanonicalDynamics P S states)
    (x : EuclideanSpace ℝ (CanonicalAmbientIndex states H)) :
    M.allResidualCoordinates (Fin.last H) x=0 := by
  simp [allResidualCoordinates,normResidual,normalizedResidual,residual]

 def picardCoefficientMatrix (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) :=
  volterraCoefficients (M.baseCoordinates T) M.propagationCoordinates

 theorem picardCoefficientMatrix_bound (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1) :
    ∀z v,|M.picardCoefficientMatrix T z v|≤1 :=
  volterraCoefficients_bound _ _ (by norm_num) (M.baseCoordinates_norm T hT) M.propagationCoordinates_norm

 def picardCoordinateUpdate (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) :=
  affineRealMap (M.picardCoefficientMatrix T) (fun _=>0)∘residualCarryMap M.allResidualCoordinates

 theorem picardCoordinateUpdate_eval (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (x : EuclideanSpace ℝ (Fin (d+1)))
    (u : Fin (H+1)→EuclideanSpace ℝ (CanonicalAmbientIndex states H))
    (z : Fin (H+1)×CanonicalAmbientIndex states H) :
    M.picardCoordinateUpdate T (WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun v=>u v.1 v.2))) z=
      finiteVolterraValue (M.baseCoordinates T) M.propagationCoordinates M.allResidualCoordinates x u z.1 z.2 :=
  volterraCoefficients_eval _ _ _ x u z

 theorem picardCoordinateUpdate_range (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (x : EuclideanSpace ℝ (Fin (d+1)))
    (u : Fin (H+1)→EuclideanSpace ℝ (CanonicalAmbientIndex states H)) {R : ℝ} (hx : ‖x‖≤R) :
    ‖M.picardCoordinateUpdate T (WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun v=>u v.1 v.2)))‖≤
      ((Fintype.card (Fin (H+1)×CanonicalAmbientIndex states H):ℝ)+1)*
        (R+∑j:Fin (H+1),M.residualRange (canonicalSignPrecision P) j) := by
  have hRj (j : Fin (H+1)) : 0≤M.residualRange (canonicalSignPrecision P) j := by
    unfold residualRange
    split_ifs
    · exact mul_nonneg (by positivity) (canonicalRadius_pos P (canonicalSignPrecision_pos P) j).le
    · exact le_refl _
  have hR : 0≤R := (norm_nonneg x).trans hx
  apply euclidean_norm_of_coordinate_bounds _ (add_nonneg hR (Finset.sum_nonneg fun j _=>hRj j))
  intro z
  rw [M.picardCoordinateUpdate_eval]
  exact (PiLp.norm_apply_le _ z.2).trans
    ((finiteVolterraValue_norm _ _ _ (M.baseCoordinates_norm T hT) M.propagationCoordinates_norm
      (fun j=>M.residualRange (canonicalSignPrecision P) j) hRj M.allResidualCoordinates_range x u z.1).trans
        (add_le_add hx le_rfl))

#print axioms picardCoefficientMatrix_bound
#print axioms picardCoordinateUpdate_range
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic
