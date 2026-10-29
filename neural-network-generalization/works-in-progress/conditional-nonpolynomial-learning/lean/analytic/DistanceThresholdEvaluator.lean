import DistanceArithmeticProgram
import GridBallClassifier

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ι J : Type} [Fintype ι] [Fintype J] [DecidableEq ι] [DecidableEq J]

 theorem distanceProgramBlock_realMap (centers : J→EuclideanSpace ℝ ι)
    (x : EuclideanSpace ℝ ι) (t : ℝ) :
    (distanceProgramBlock centers).realMap (WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun _=>t)))=
      WithLp.toLp 2 (fun j=>‖x-t • centers j‖^2) := by
  apply WithLp.ofLp_injective 2
  funext j
  change (distanceProgramBlock centers).eval
    (realCoordinates (Sum.elim (fun i=>x i) (fun _=>t))) (Fintype.equivFin J j)=_
  rw [distanceProgramBlock_eval]
  simp only [realCoordinates,Equiv.symm_apply_apply]

 def distanceThresholdEvaluator (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool)
    (r : ℝ) (B U : ℕ) (ε : ℝ) :=
  let P:=distanceProgramBlock centers
  let Q:=P.mesh B U ε
  let c:=P.compile Q B U
  substituteCircuit c.gates c.outputs (gridBallClassifier Q (P.outputRange B U) labels r)

 theorem distanceThresholdEvaluator_depth (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool)
    (r : ℝ) (B U : ℕ) (ε : ℝ) :
    (distanceThresholdEvaluator centers labels r B U ε).depth≤11 := by
  have hc:=(distanceProgramBlock centers).compile_depth ((distanceProgramBlock centers).mesh B U ε) B U
  rw [distanceProgramBlock_length] at hc
  exact (substituteCircuit_depth _ _ _).trans
    ((Nat.add_le_add hc (gridBallClassifier_depth _ _ _ _)).trans_eq (by norm_num))

 theorem distanceThresholdEvaluator_correct (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool)
    (r : ℝ) (B U : ℕ) (hB : 1≤B) (hc : ∀j i,|centers j i|≤(B:ℝ))
    {ε : ℝ} (hε : 0<ε) (hεone : ε≤1) (x : EuclideanSpace ℝ ι) (truth : Bool)
    (hx : ∀i,|x i|≤(U:ℝ)) (hU : 1≤U)
    (htrue : truth=true→∃j,labels j=true ∧ ‖x-centers j‖^2+((Fintype.card J:ℝ)+1)*ε<r)
    (hfalse : truth=false→∀j,labels j=true → r+((Fintype.card J:ℝ)+1)*ε≤‖x-centers j‖^2) :
    let Q:=(distanceProgramBlock centers).mesh B U ε
    (distanceThresholdEvaluator centers labels r B U ε).eval
      (encodeCoordinateState Q U (fun z:ι⊕Unit=>scalarEncode Q U (Sum.elim (fun i=>x i) (fun _=>1) z)))=truth := by
  intro Q
  let P:=distanceProgramBlock centers
  let v:EuclideanSpace ℝ (ι⊕Unit):=WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun _=>1))
  have hv : ∀z,|v z|≤(U:ℝ) := by
    rintro (i|⟨⟩)
    · exact hx i
    · change |(1:ℝ)|≤U
      norm_num
      exact_mod_cast hU
  obtain ⟨b,hb,he⟩:=P.finite_evaluator B U (distanceProgramBlock_bounded centers B hB hc) hε hεone v hv
  have hp : P.realMap v=WithLp.toLp 2 (fun j=>‖x-centers j‖^2) := by
    simpa only [P,v,one_smul] using distanceProgramBlock_realMap centers x 1
  rw [hp] at he
  have herr (j : J) : |‖x-centers j‖^2-scalarDecode Q (P.outputRange B U) (b j)|≤
      ((Fintype.card J:ℝ)+1)*ε :=
    (PiLp.norm_apply_le (WithLp.toLp 2 (fun j=>‖x-centers j‖^2)-decodeCoordinates Q (P.outputRange B U) b) j).trans he
  unfold distanceThresholdEvaluator
  rw [substituteCircuit_eval]
  change (gridBallClassifier Q (P.outputRange B U) labels r).eval
    ((P.compile Q B U).eval (encodeCoordinateState Q U (fun z=>scalarEncode Q U (v z))))=truth
  rw [hb]
  exact gridBallClassifier_correct _ _ labels r b (fun j=>‖x-centers j‖^2) truth herr htrue hfalse

#print axioms distanceThresholdEvaluator_correct
#print axioms distanceThresholdEvaluator_depth
end ConditionalNonpolynomial.AnalyticLookup
