import PhysicalShortCoordinateTrajectory

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

 def timeSliceLinear {J I : Type*} [Fintype J] [Fintype I] (j : J) :
    EuclideanSpace ℝ (J×I)→L[ℝ]EuclideanSpace ℝ I :=
  ({toFun:=fun x=>timeSlice x j,map_add':=by intros;rfl,map_smul':=by intros;rfl} :
    EuclideanSpace ℝ (J×I)→ₗ[ℝ]EuclideanSpace ℝ I).mkContinuous 1
      (fun x=>by change ‖timeSlice x j‖≤1*‖x‖; simpa only [one_mul] using timeSlice_norm_le x j)

 theorem timeSliceLinear_norm {J I : Type*} [Fintype J] [Fintype I] (j : J) :
    ‖timeSliceLinear (I:=I) j‖≤1 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro x
  exact (timeSlice_norm_le x j).trans_eq (one_mul _).symm

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def initialCoefficientMatrix (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (z : Fin (H+1)×CanonicalAmbientIndex states H) (i : Fin (d+1)) : ℝ :=
  linearCoefficients (M.baseCoordinates T z.1) z.2 i

 def initialCoordinateMap (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) :=
  affineRealMap (M.initialCoefficientMatrix T) (fun _=>0)

 theorem initialCoefficientMatrix_bound (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1) :
    ∀z i,|M.initialCoefficientMatrix T z i|≤1 :=
  fun z i=>(linearCoefficients_bound _ _ _).trans (M.baseCoordinates_norm T hT z.1)

 theorem initialCoordinateMap_eval (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (x : EuclideanSpace ℝ (Fin (d+1))) (z : Fin (H+1)×CanonicalAmbientIndex states H) :
    M.initialCoordinateMap T x z=M.baseCoordinates T z.1 x z.2 := by
  change 0+∑i,linearCoefficients (M.baseCoordinates T z.1) z.2 i*x i=_
  rw [zero_add,linearCoefficients_eval]

 theorem initialCoordinateMap_trajectory (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (x : EuclideanSpace ℝ (Fin (d+1))) (j : Fin (H+1)) :
    M.coordinateTrajectory (M.initialCoordinateMap T x) j=propagation M.normLinear j 0 (T x) := by
  rw [M.coordinateTrajectory_fin]
  have hh : timeSlice (M.initialCoordinateMap T x) j=M.baseCoordinates T j x := by
    ext i
    exact M.initialCoordinateMap_eval T x (j,i)
  rw [hh]
  change canonicalAmbientCurry states H ((canonicalAmbientCurry states H).symm _) = _
  exact LinearIsometryEquiv.apply_symm_apply _ _

 theorem initialCoordinateMap_range (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (x : EuclideanSpace ℝ (Fin (d+1))) {R : ℝ} (hx : ‖x‖≤R) :
    ‖M.initialCoordinateMap T x‖≤((Fintype.card (Fin (H+1)×CanonicalAmbientIndex states H):ℝ)+1)*R := by
  apply euclidean_norm_of_coordinate_bounds _ ((norm_nonneg x).trans hx)
  intro z
  rw [M.initialCoordinateMap_eval]
  exact (PiLp.norm_apply_le _ z.2).trans (((M.baseCoordinates T z.1).le_opNorm _).trans
    ((mul_le_mul_of_nonneg_right (M.baseCoordinates_norm T hT z.1) (norm_nonneg _)).trans
      ((one_mul _).le.trans hx)))

 theorem initialCoordinateMap_true_input_error (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.normState x 0)
    (x : Cube d) (z : EuclideanSpace ℝ (Fin (d+1))) (j : Fin (H+1)) :
    ‖M.coordinateTrajectory (M.initialCoordinateMap T z) j-M.affineBase x j‖≤
      ‖z-normalizedInputFeature d x‖ := by
  rw [M.initialCoordinateMap_trajectory]
  simp only [affineBase,← hTx x,← map_sub]
  exact ((propagation M.normLinear j 0).le_opNorm _).trans
    ((mul_le_mul (propagation_contracts _ M.normLinear_norm_le j 0)
      ((T.le_opNorm _).trans ((mul_le_mul_of_nonneg_right hT (norm_nonneg _)).trans_eq (one_mul _)))
      (norm_nonneg _) (by norm_num : (0:ℝ)≤1)).trans_eq (one_mul _))

 def scalarReadout (M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index) :
    EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H)→L[ℝ]ℝ :=
  normalizingScale M.linearGain H •
    ((innerSL ℝ (M.paddedReadout c)).comp
      ((canonicalAmbientCurry states H).toContinuousLinearMap.comp (timeSliceLinear (Fin.last H))))

 theorem scalarReadout_eval (M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index)
    (u : EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H)) :
    M.scalarReadout c u=M.predict c (M.coordinateTrajectory u H) := by
  have hh := M.coordinateTrajectory_fin u (Fin.last H)
  change M.coordinateTrajectory u H=canonicalAmbientCurry states H (timeSlice u (Fin.last H)) at hh
  rw [hh]
  rfl

 theorem scalarReadout_norm (M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index) :
    ‖M.scalarReadout c‖≤normalizingScale M.linearGain H*‖c‖ := by
  have hS : 0≤normalizingScale M.linearGain H := le_trans (by norm_num) (normalizingScale_one_le _ M.linearGain_one_le H)
  apply ContinuousLinearMap.opNorm_le_bound _ (mul_nonneg hS (norm_nonneg _))
  intro u
  change ‖normalizingScale M.linearGain H * inner ℝ (M.paddedReadout c)
    (canonicalAmbientCurry states H (timeSlice u (Fin.last H)))‖≤_
  rw [Real.norm_eq_abs,abs_mul,abs_of_nonneg hS]
  calc
    _ ≤ normalizingScale M.linearGain H*(‖M.paddedReadout c‖*‖canonicalAmbientCurry states H (timeSlice u (Fin.last H))‖) :=
      mul_le_mul_of_nonneg_left (abs_real_inner_le_norm _ _) hS
    _ ≤ normalizingScale M.linearGain H*(‖c‖*‖u‖) := by
      rw [M.paddedReadout_norm,LinearIsometryEquiv.norm_map]
      exact mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left (timeSlice_norm_le _ _) (norm_nonneg _)) hS
    _ = _ := by ring

 def readoutCoefficient (M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index)
    (i : Fin (H+1)×CanonicalAmbientIndex states H) : ℝ :=
  M.scalarReadout c (EuclideanSpace.basisFun _ ℝ i)

 theorem readoutCoefficient_bound (M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index) (i : Fin (H+1)×CanonicalAmbientIndex states H) :
    |M.readoutCoefficient c i|≤normalizingScale M.linearGain H*‖c‖ := by
  have hh := (M.scalarReadout c).le_opNorm (EuclideanSpace.basisFun _ ℝ i)
  rw [(EuclideanSpace.basisFun _ ℝ).norm_eq_one,mul_one] at hh
  exact hh.trans (M.scalarReadout_norm c)

 theorem readoutCoefficient_eval (M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index)
    (u : EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H)) :
    (∑i,M.readoutCoefficient c i*u i)=M.predict c (M.coordinateTrajectory u H) := by
  rw [← M.scalarReadout_eval c u]
  have hu : (∑i,u i • EuclideanSpace.basisFun _ ℝ i)=u := by
    simpa only [EuclideanSpace.basisFun_repr] using (EuclideanSpace.basisFun _ ℝ).sum_repr u
  have hh := congrArg (M.scalarReadout c) hu
  simpa only [map_sum,map_smul,smul_eq_mul,readoutCoefficient,mul_comm] using hh

#print axioms initialCoordinateMap_true_input_error
#print axioms readoutCoefficient_eval
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
