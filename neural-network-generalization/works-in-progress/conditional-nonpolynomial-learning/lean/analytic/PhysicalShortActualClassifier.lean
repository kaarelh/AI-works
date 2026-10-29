import PhysicalShortGridReadout
import PhysicalShortCoordinateSign
import ValidFiniteGridClassifier

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def selectedInitializerGrid (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (η : ℝ) :=
  booleanAffineInitializer (M.baseCoordinates T) (M.gridMesh η) M.gridStateRange M.gridAffineRange

 theorem selectedInitializerGrid_eval (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) (x : Input d) :
    ∃u:M.PicardStateIndex→ScalarCode (M.gridMesh η) M.gridStateRange,
      (M.selectedInitializerGrid T η).eval x=encodeCoordinateState (M.gridMesh η) M.gridStateRange
        (Sum.elim (normalizedCodes d (M.gridMesh η) M.gridStateRange x) u) ∧
      ‖M.initialCoordinateMap T (decodeCoordinates (M.gridMesh η) M.gridStateRange
        (normalizedCodes d (M.gridMesh η) M.gridStateRange x))-
        decodeCoordinates (M.gridMesh η) M.gridStateRange u‖≤η/4 := by
  have hp:((d:ℝ)+2)/(2*(M.gridMesh η:ℝ))≤1:=(M.grid_input_error hη).trans (by linarith)
  obtain ⟨u,hu,he⟩:=booleanAffineInitializer_eval (M.baseCoordinates T) (M.baseCoordinates_norm T hT)
    (M.gridMesh η) M.gridStateRange M.gridAffineRange hd (M.gridMesh_pos η) M.gridStateRange_two hp
    M.grid_initial_affine_range (M.grid_initial_range hη hη1) x
  refine ⟨u,hu,?_⟩
  rw [M.initialCoordinateMap_eq_base]
  exact he.trans (M.grid_initial_error hη)

 def selectedClassifier (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (c : EuclideanSpace ℝ (states H).Index) (η : ℝ) (hη : 0<η) (hη1 : η≤1) : ThresholdCircuit d :=
  assembledGridClassifier (M.selectedInitializerGrid T η) (M.selectedPicardGrid hd T η hη hη1)
    (canonicalSignIterations P) (M.selectedReadoutGrid c η)

 theorem selectedClassifier_correct (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.normState x 0)
    (c : EuclideanSpace ℝ (states H).Index)
    (hcert : ∀x (v : ℕ→ℕ→CanonicalAmbient states H),
      (∀j≤H,‖v 0 j-M.affineBase x j‖≤canonicalSignRounding P)→
      (∀k j,j≤H→‖v (k+1) j-volterra (M.affineBase x) M.propagator
        (M.normResidual (canonicalSignPrecision P)) (v k) j‖≤canonicalSignRounding P)→
      (1:ℝ)/4<labelReal (f x)*M.predict c (v (canonicalSignIterations P) H))
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) (hηsmall : η≤1/4) (hηbudget : η≤canonicalSignRounding P) :
    (M.selectedClassifier hd T c η hη hη1).eval=f := by
  let Q:=M.gridMesh η
  let N:=M.gridStateRange
  let a:Input d→Fin (d+1)→ScalarCode Q N:=normalizedCodes d Q N
  let valid:(Fin (d+1)→ScalarCode Q N)→Prop:=fun a=>‖decodeCoordinates Q N a‖≤3
  have hva:∀x,valid (a x):=by
    intro x
    exact normalizedCodes_valid d Q N hd (M.gridMesh_pos η) M.gridStateRange_two
      ((M.grid_input_error hη).trans (by linarith)) x
  have hinit:=M.selectedInitializerGrid_eval hd T hT η hη hη1
  let u:Input d→M.PicardStateIndex→ScalarCode Q N:=fun x=>Classical.choose (hinit x)
  have hu:∀x,(M.selectedInitializerGrid T η).eval x=encodeCoordinateState Q N (Sum.elim (a x) (u x)) ∧
      ‖M.initialCoordinateMap T (decodeCoordinates Q N (a x))-decodeCoordinates Q N (u x)‖≤η/4 :=
    fun x=>Classical.choose_spec (hinit x)
  have hstep:=M.selectedPicardGrid_approximates hd T hT η hη hη1
  let seq (x : Input d) := validGridIteration hstep (a x) (hva x) (u x)
  let z (x : Input d):ℝ:=M.scalarReadout c (decodeCoordinates Q N (seq x (canonicalSignIterations P)))
  have hmargin:∀x,(1:ℝ)/4<labelReal (f x)*z x:=by
    intro x
    apply M.coordinate_numeric_margin T hT hTx c hcert x (decodeCoordinates Q N (a x))
      (fun k=>decodeCoordinates Q N (seq x k)) (ξ:=η/4) (η:=η/2)
    · rw [norm_sub_rev]
      exact (normalizedCodes_error d Q N hd (M.gridMesh_pos η) M.gridStateRange_two x).trans (M.grid_input_error hη)
    · linarith
    · change ‖decodeCoordinates Q N (u x)-M.initialCoordinateMap T (decodeCoordinates Q N (a x))‖≤η/2
      rw [norm_sub_rev]
      exact (hu x).2.trans (by linarith)
    · intro k
      exact validGridIteration_step_error hstep (a x) (hva x) (u x) k
  apply assembledGridClassifier_correctOn (M.selectedInitializerGrid T η)
    (M.selectedPicardGrid hd T η hη hη1) (canonicalSignIterations P) (M.selectedReadoutGrid c η)
    (M.picardCoordinateUpdate T) valid hstep a u hva (fun x=>(hu x).1) z f (show 0≤η/2 by positivity)
  · intro x
    exact lt_of_le_of_lt (by linarith : η/2≤(1:ℝ)/4) (hmargin x)
  · intro x
    exact M.selectedReadoutGrid_eval c η hη (a x) (seq x (canonicalSignIterations P))

 theorem selectedClassifier_depth (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (c : EuclideanSpace ℝ (states H).Index) (η : ℝ) (hη : 0<η) (hη1 : η≤1) :
    (M.selectedClassifier hd T c η hη hη1).depth≤90*canonicalSignIterations P+17 := by
  have hi:=booleanAffineInitializer_depth (M.baseCoordinates T) (M.gridMesh η) M.gridStateRange M.gridAffineRange
  have hs:=M.selectedPicardGrid_depth hd T η hη hη1
  have hr:=M.selectedReadoutGrid_depth c η
  have hh:=assembledGridClassifier_depth (M.selectedInitializerGrid T η)
    (M.selectedPicardGrid hd T η hη hη1) (canonicalSignIterations P) (M.selectedReadoutGrid c η)
  change (M.selectedInitializerGrid T η).depth≤11 at hi
  change (M.selectedClassifier hd T c η hη hη1).depth≤_ at hh
  nlinarith

#print axioms selectedClassifier_correct
#print axioms selectedClassifier_depth
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
