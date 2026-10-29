import DistanceThresholdEvaluator
import VolterraGridInitialization

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic NeuralGeneralization.ConcreteModel
variable {κ ι J : Type} [Fintype κ] [Fintype ι] [Fintype J] [DecidableEq ι] [DecidableEq J]

 def coordinateAugmentGrid (p : ι→κ) (Q N Q' U : ℕ) :
    CircuitMap (Fintype.card κ*Fintype.card (ScalarGrid Q N))
      (Fintype.card (ι⊕Unit)*Fintype.card (ScalarGrid Q' U)) :=
  sumGridCircuits
    ((projectGridCoordinates Q N p).then (recodeCoordinates Q N Q' U))
    (booleanGridInput Q' U (fun _:Unit=>BooleanInputSource.constant 1))

 theorem coordinateAugmentGrid_eval (p : ι→κ) (Q N Q' U : ℕ)
    (a : κ→ScalarCode Q N) :
    (coordinateAugmentGrid (ι:=ι) p Q N Q' U).eval (encodeCoordinateState Q N a)=
      encodeCoordinateState Q' U (Sum.elim (fun i=>scalarEncode Q' U (scalarDecode Q N (a (p i))))
        (fun _:Unit=>scalarEncode Q' U 1)) := by
  apply sumGridCircuits_eval
  · rw [CircuitMap.eval_then,projectGridCoordinates_eval,recodeCoordinates_eval]
    rfl
  · simp only [booleanGridInput_eval,BooleanInputSource.eval]

 theorem coordinateAugmentGrid_depth (p : ι→κ) (Q N Q' U : ℕ) :
    (coordinateAugmentGrid (ι:=ι) p Q N Q' U).depth≤5 := by
  apply sumGridCircuits_depth _ _ 5
  · apply (CircuitMap.depth_then _ _).trans
    have hz:(projectGridCoordinates Q N p).depth=0:=CircuitMap.rewire_depth _
    rw [hz,zero_add]
    exact recodeCoordinates_depth _ _ _ _
  · exact (booleanGridInput_depth _ _ _).trans (by norm_num)

 def coordinateDistanceClassifier (p : ι→κ) (Q N : ℕ)
    (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool) (r : ℝ) (B U : ℕ) (ε : ℝ) :
    ThresholdCircuit (Fintype.card κ*Fintype.card (ScalarGrid Q N)) :=
  let Q':=(distanceProgramBlock centers).mesh B U ε
  let c:=coordinateAugmentGrid (ι:=ι) p Q N Q' U
  substituteCircuit c.gates c.outputs (distanceThresholdEvaluator centers labels r B U ε)

 theorem coordinateDistanceClassifier_depth (p : ι→κ) (Q N : ℕ)
    (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool) (r : ℝ) (B U : ℕ) (ε : ℝ) :
    (coordinateDistanceClassifier p Q N centers labels r B U ε).depth≤16 := by
  exact (substituteCircuit_depth _ _ _).trans
    ((Nat.add_le_add (coordinateAugmentGrid_depth _ _ _ _ _) (distanceThresholdEvaluator_depth _ _ _ _ _ _)).trans_eq (by norm_num))

 theorem coordinateDistanceClassifier_correct (p : ι→κ) (Q N : ℕ)
    (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool) (r : ℝ) (B U : ℕ)
    (hB : 1≤B) (hc : ∀j i,|centers j i|≤(B:ℝ)) {ε : ℝ} (hε : 0<ε) (hε1 : ε≤1)
    (a : κ→ScalarCode Q N) (truth : Bool)
    (hx : ∀i,|scalarDecode Q N (a (p i))|≤(U:ℝ)) (hU : 1≤U)
    (htrue : truth=true→∃c,labels c=true ∧
      ‖decodeCoordinates Q N (fun i=>a (p i))-centers c‖^2+((Fintype.card J:ℝ)+1)*ε<r)
    (hfalse : truth=false→∀c,labels c=true→ r+((Fintype.card J:ℝ)+1)*ε≤
      ‖decodeCoordinates Q N (fun i=>a (p i))-centers c‖^2) :
    (coordinateDistanceClassifier p Q N centers labels r B U ε).eval (encodeCoordinateState Q N a)=truth := by
  unfold coordinateDistanceClassifier
  rw [substituteCircuit_eval]
  change (distanceThresholdEvaluator centers labels r B U ε).eval
    ((coordinateAugmentGrid p Q N ((distanceProgramBlock centers).mesh B U ε) U).eval (encodeCoordinateState Q N a))=truth
  rw [coordinateAugmentGrid_eval]
  let Q':=(distanceProgramBlock centers).mesh B U ε
  have hcode : Sum.elim (fun i=>scalarEncode Q' U (scalarDecode Q N (a (p i))))
      (fun _:Unit=>scalarEncode Q' U 1)=
      (fun z:ι⊕Unit=>scalarEncode Q' U (Sum.elim (fun i=>scalarDecode Q N (a (p i))) (fun _:Unit=>1) z)) := by
    funext z
    cases z <;> rfl
  rw [hcode]
  have hh:=distanceThresholdEvaluator_correct centers labels r B U hB hc hε hε1
    (decodeCoordinates Q N (fun i=>a (p i))) truth hx hU htrue hfalse
  exact hh

 theorem distance_gap_of_endpoint_error (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool)
    (x y : EuclideanSpace ℝ ι) (truth : Bool) {a b e r δ : ℝ}
    (he : ‖x-y‖≤e) (hb : e≤b)
    (hnear : truth=true→∃j,labels j=true ∧ ‖y-centers j‖≤a)
    (hfar : truth=false→∀j,labels j=true→b≤‖y-centers j‖)
    (hpos : (a+e)^2+δ<r) (hneg : r+δ≤(b-e)^2) :
    (truth=true→∃j,labels j=true ∧ ‖x-centers j‖^2+δ<r) ∧
    (truth=false→∀j,labels j=true→ r+δ≤‖x-centers j‖^2) := by
  constructor
  · intro ht
    obtain ⟨j,hj,hd⟩:=hnear ht
    refine ⟨j,hj,?_⟩
    have hdist:‖x-centers j‖≤a+e:=(norm_sub_le_norm_sub_add_norm_sub x y (centers j)).trans
      (by linarith)
    have ha:0≤a+e:=(norm_nonneg _).trans hdist
    have hs:=sq_le_sq₀ (norm_nonneg (x-centers j)) ha |>.mpr hdist
    linarith
  · intro ht j hj
    have ht0:=norm_sub_le_norm_sub_add_norm_sub y x (centers j)
    rw [norm_sub_rev y x] at ht0
    have hdist:b-e≤‖x-centers j‖:=by linarith [hfar ht j hj]
    exact hneg.trans ((sq_le_sq₀ (by linarith) (norm_nonneg _)).mpr hdist)

#print axioms coordinateDistanceClassifier_correct
#print axioms distance_gap_of_endpoint_error
end ConditionalNonpolynomial.AnalyticLookup
