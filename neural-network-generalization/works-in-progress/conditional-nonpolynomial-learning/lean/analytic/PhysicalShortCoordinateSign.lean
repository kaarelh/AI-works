import PhysicalShortCoordinateEndpoints

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 theorem coordinate_initial_error (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.normState x 0)
    (x : Cube d) (z : EuclideanSpace ℝ (Fin (d+1)))
    (u : EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H))
    {ξ η : ℝ} (hz : ‖z-normalizedInputFeature d x‖≤ξ)
    (hu : ‖u-M.initialCoordinateMap T z‖≤η) (j : ℕ) (hj : j≤H) :
    ‖M.coordinateTrajectory u j-M.affineBase x j‖≤η+ξ := by
  let jf : Fin (H+1) := ⟨j,by omega⟩
  have h1 := (M.coordinateTrajectory_error u (M.initialCoordinateMap T z) jf).trans hu
  have h2 := (M.initialCoordinateMap_true_input_error T hT hTx x z jf).trans hz
  exact (norm_sub_le_norm_sub_add_norm_sub _ (M.coordinateTrajectory (M.initialCoordinateMap T z) j) _).trans
    (add_le_add h1 h2)

 theorem coordinate_update_error (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.normState x 0)
    (x : Cube d) (z : EuclideanSpace ℝ (Fin (d+1)))
    (u v : EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H))
    {ξ η : ℝ} (hz : ‖z-normalizedInputFeature d x‖≤ξ)
    (hv : ‖v-M.picardCoordinateUpdate T
      (WithLp.toLp 2 (Sum.elim (fun i=>z i) (fun i=>u i)))‖≤η)
    (j : ℕ) (hj : j≤H) :
    ‖M.coordinateTrajectory v j-volterra (M.affineBase x) M.propagator
      (M.normResidual (canonicalSignPrecision P)) (M.coordinateTrajectory u) j‖≤η+ξ := by
  let jf : Fin (H+1) := ⟨j,by omega⟩
  let next := M.picardCoordinateUpdate T (WithLp.toLp 2 (Sum.elim (fun i=>z i) (fun i=>u i)))
  have h1 := (M.coordinateTrajectory_error v next jf).trans hv
  have h2 := (M.picardCoordinateUpdate_true_input_error T hT hTx x z u jf).trans hz
  exact (norm_sub_le_norm_sub_add_norm_sub _ (M.coordinateTrajectory next j) _).trans (add_le_add h1 h2)

 theorem coordinate_numeric_margin (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.normState x 0)
    (c : EuclideanSpace ℝ (states H).Index)
    (hcert : ∀x (v : ℕ→ℕ→CanonicalAmbient states H),
      (∀j≤H,‖v 0 j-M.affineBase x j‖≤canonicalSignRounding P)→
      (∀k j,j≤H→‖v (k+1) j-volterra (M.affineBase x) M.propagator
        (M.normResidual (canonicalSignPrecision P)) (v k) j‖≤canonicalSignRounding P)→
      (1:ℝ)/4<labelReal (f x)*M.predict c (v (canonicalSignIterations P) H))
    (x : Cube d) (z : EuclideanSpace ℝ (Fin (d+1)))
    (u : ℕ→EuclideanSpace ℝ (Fin (H+1)×CanonicalAmbientIndex states H))
    {ξ η : ℝ} (hz : ‖z-normalizedInputFeature d x‖≤ξ)
    (hbudget : η+ξ≤canonicalSignRounding P)
    (hinit : ‖u 0-M.initialCoordinateMap T z‖≤η)
    (hupdate : ∀k,‖u (k+1)-M.picardCoordinateUpdate T
      (WithLp.toLp 2 (Sum.elim (fun i=>z i) (fun i=>u k i)))‖≤η) :
    (1:ℝ)/4<labelReal (f x)*M.scalarReadout c (u (canonicalSignIterations P)) := by
  rw [M.scalarReadout_eval]
  apply hcert x (fun k=>M.coordinateTrajectory (u k))
  · intro j hj
    exact (M.coordinate_initial_error T hT hTx x z (u 0) hz hinit j hj).trans hbudget
  · intro k j hj
    exact (M.coordinate_update_error T hT hTx x z (u k) (u (k+1)) hz (hupdate k) j hj).trans hbudget

#print axioms coordinate_numeric_margin
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
