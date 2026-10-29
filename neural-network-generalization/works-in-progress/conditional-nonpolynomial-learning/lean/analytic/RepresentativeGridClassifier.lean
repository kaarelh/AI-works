import RepresentativeDistanceBudgets

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic NeuralGeneralization.ConcreteModel
variable {d Q N : ℕ} {κ ι J : Type} [Fintype κ] [Fintype ι] [Fintype J]
variable [DecidableEq ι] [DecidableEq J]

 def representativeClassifierAfter
    (C : CircuitMap d (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (p : ι→κ)
    (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool) (A : ℝ) : ThresholdCircuit d :=
  substituteCircuit C.gates C.outputs (coordinateDistanceClassifier p Q N centers labels
    (representativeDistanceThreshold A) 2 3 (representativeDistanceTolerance A (Fintype.card J)))

 theorem representativeClassifierAfter_depth
    (C : CircuitMap d (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (p : ι→κ)
    (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool) (A : ℝ) :
    (representativeClassifierAfter C p centers labels A).depth≤C.depth+16 :=
  (substituteCircuit_depth _ _ _).trans (Nat.add_le_add_left (coordinateDistanceClassifier_depth _ _ _ _ _ _ _ _ _) _)

 theorem representativeClassifierAfter_size
    (C : CircuitMap d (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (p : ι→κ)
    (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool) (A : ℝ) :
    (representativeClassifierAfter C p centers labels A).size=C.size+
      (coordinateDistanceClassifier p Q N centers labels (representativeDistanceThreshold A) 2 3
        (representativeDistanceTolerance A (Fintype.card J))).size := substituteCircuit_size _ _ _

 theorem representativeClassifierAfter_correct
    (C : CircuitMap d (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (p : ι→κ)
    (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool) (A : ℝ) (hA : 1≤A)
    (target : Input d→EuclideanSpace ℝ ι) (f : Input d→Bool)
    (htarget : ∀x,‖target x‖≤2) (hcenter : ∀j,‖centers j‖≤2)
    (hC : ∀x,∃a:κ→ScalarCode Q N,C.eval x=encodeCoordinateState Q N a ∧
      ‖decodeCoordinates Q N (fun i=>a (p i))-target x‖≤1/(256*A))
    (hnear : ∀x,f x=true→∃j,labels j=true ∧ ‖target x-centers j‖≤1/(64*A))
    (hfar : ∀x,f x=false→∀j,labels j=true→3/(4*A)≤‖target x-centers j‖) :
    (representativeClassifierAfter C p centers labels A).eval=f := by
  have hAp:0<A:=by linarith
  have hε:=representativeDistanceTolerance_pos hAp (Fintype.card J)
  have hε1:=representativeDistanceTolerance_le_one hA (Fintype.card J)
  have hcoeff:∀j i,|centers j i|≤((2:ℕ):ℝ):=fun j i=>(PiLp.norm_apply_le _ i).trans (hcenter j)
  funext x
  obtain ⟨a,ha,he⟩:=hC x
  have hg:=representative_distance_gap centers labels (decodeCoordinates Q N (fun i=>a (p i)))
    (target x) (f x) hAp he (hnear x) (hfar x)
  have hsmall:1/(256*A)≤1:=by
    apply (div_le_iff₀ (by positivity : 0<256*A)).mpr
    linarith
  have hnorm:‖decodeCoordinates Q N (fun i=>a (p i))‖≤3:=by
    have hh:=norm_le_norm_sub_add (decodeCoordinates Q N (fun i=>a (p i))) (target x)
    linarith [htarget x]
  unfold representativeClassifierAfter
  rw [substituteCircuit_eval]
  change (coordinateDistanceClassifier p Q N centers labels (representativeDistanceThreshold A) 2 3
    (representativeDistanceTolerance A (Fintype.card J))).eval (C.eval x)=f x
  rw [ha]
  exact coordinateDistanceClassifier_correct p Q N centers labels (representativeDistanceThreshold A) 2 3
    (by norm_num) hcoeff hε hε1 a (f x) (fun i=>(PiLp.norm_apply_le _ i).trans hnorm)
    (by norm_num) hg.1 hg.2

#print axioms representativeClassifierAfter_correct
end ConditionalNonpolynomial.AnalyticLookup
