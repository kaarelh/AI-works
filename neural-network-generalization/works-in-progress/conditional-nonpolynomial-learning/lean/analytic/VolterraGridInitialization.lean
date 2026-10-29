import VolterraProgramGrid

noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic NeuralGeneralization.ConcreteModel
namespace VolterraGridSystem
variable {d H : ℕ} {ι : Type} [Fintype ι]

 theorem input_card (M : VolterraGridSystem (Fin (d+1)) ι H) :
    Fintype.card (Fin (d+1))≤Fintype.card M.InputIndex := by
  simp only [InputIndex,Fintype.card_sum]
  omega

 theorem initial_error (M : VolterraGridSystem (Fin (d+1)) ι H) {η : ℝ} (hη : 0<η) :
    baseGridError (Fin (d+1)) (ι) (Fin (H+1))
      (M.mesh η) M.stateRange≤η/4 := by
  have hb:=picard_weight_base (Fintype.card M.InputIndex) (Fintype.card M.StateIndex)
    (Fintype.card ι) M.stateRange (Fintype.card (Fin (d+1))) M.input_card
  have hbr : (((Fintype.card M.StateIndex+1)*(Fintype.card (Fin (d+1))*(M.stateRange+1)+2):ℕ):ℝ)≤(picardRoundingWeight (Fintype.card M.InputIndex) (Fintype.card M.StateIndex) (Fintype.card ι) M.stateRange:ℝ) := by exact_mod_cast hb
  have hh:=picard_weight_rounding hη hbr
  convert hh using 1
  unfold baseGridError mesh
  push_cast
  ring

 theorem input_error (M : VolterraGridSystem (Fin (d+1)) ι H) {η : ℝ} (hη : 0<η) :
    ((d:ℝ)+2)/(2*(M.mesh η:ℝ))≤η/4 := by
  have hcard:=M.input_card
  have hb:=picard_weight_base (Fintype.card M.InputIndex) (Fintype.card M.StateIndex)
    (Fintype.card ι) M.stateRange (d+1) (by simpa using hcard)
  have hnum : d+2≤(Fintype.card M.StateIndex+1)*((d+1)*(M.stateRange+1)+2) := by
    have h1 : d+1≤(d+1)*(M.stateRange+1):=Nat.le_mul_of_pos_right _ (by omega)
    have h2 : (d+1)*(M.stateRange+1)+2≤(Fintype.card M.StateIndex+1)*((d+1)*(M.stateRange+1)+2) :=
      Nat.le_mul_of_pos_left _ (by omega)
    omega
  exact picard_weight_rounding hη (by exact_mod_cast hnum.trans hb)

 theorem initial_range (M : VolterraGridSystem (Fin (d+1)) ι H) {η : ℝ} (hη : 0<η) (hη1 : η≤1) :
    ((Fintype.card M.StateIndex:ℝ)+1)*3+
      ((Fintype.card M.StateIndex:ℝ)+1)*(((Fintype.card (Fin (d+1)):ℝ)*((M.stateRange:ℝ)+1)+1)/(2*(M.mesh η:ℝ)))≤M.stateRange := by
  have he:=M.initial_error hη
  have hlow:=M.stateRange_lower
  have hr:=M.totalBound_nonneg
  have hk:0≤(Fintype.card M.StateIndex:ℝ):=Nat.cast_nonneg _
  have hn:0≤((Fintype.card M.StateIndex:ℝ)+1)/(2*(M.mesh η:ℝ)):=by positivity
  unfold baseGridError at he
  nlinarith [mul_nonneg hk hr]

 theorem initial_affine_range (M : VolterraGridSystem (Fin (d+1)) ι H) :
    1+Fintype.card (Fin (d+1))*2*(M.stateRange+1)≤M.affineRange := by
  exact Nat.add_le_add_left (Nat.mul_le_mul_right _ (Nat.mul_le_mul_right 2 M.input_card)) 1

 def initialGrid (M : VolterraGridSystem (Fin (d+1)) ι H) (η : ℝ) :=
  booleanAffineInitializer M.base (M.mesh η) M.stateRange M.affineRange

 theorem initialGrid_eval (M : VolterraGridSystem (Fin (d+1)) ι H) (hd : 1≤d)
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) (x : Input d) :
    ∃u:M.StateIndex→ScalarCode (M.mesh η) M.stateRange,
      (M.initialGrid η).eval x=encodeCoordinateState (M.mesh η) M.stateRange
        (Sum.elim (normalizedCodes d (M.mesh η) M.stateRange x) u) ∧
      ‖baseVectorMap M.base (decodeCoordinates (M.mesh η) M.stateRange
        (normalizedCodes d (M.mesh η) M.stateRange x))-decodeCoordinates (M.mesh η) M.stateRange u‖≤η/4 := by
  have hp:((d:ℝ)+2)/(2*(M.mesh η:ℝ))≤1:=(M.input_error hη).trans (by linarith)
  obtain ⟨u,hu,he⟩:=booleanAffineInitializer_eval M.base M.base_norm
    (M.mesh η) M.stateRange M.affineRange hd (M.mesh_pos η) M.stateRange_two hp
    M.initial_affine_range (M.initial_range hη hη1) x
  exact ⟨u,hu,he.trans (M.initial_error hη)⟩

 def programEvaluator (M : VolterraGridSystem (Fin (d+1)) ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (η : ℝ) (k : ℕ) :=
  (M.initialGrid η).then (pipeline (List.replicate k (carryInputCircuit (M.programStep P B η))))

 theorem programEvaluator_depth (M : VolterraGridSystem (Fin (d+1)) ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (η : ℝ) (k : ℕ) (hP : ∀j,(P j).length≤14) :
    (M.programEvaluator P B η k).depth≤90*k+11 := by
  have hi:=booleanAffineInitializer_depth M.base (M.mesh η) M.stateRange M.affineRange
  have hs:=M.programStep_depth P B η hP
  have hp:=(gridIteration_bounds (M.programStep P B η) k).2
  have hh:=CircuitMap.depth_then (M.initialGrid η) (pipeline (List.replicate k (carryInputCircuit (M.programStep P B η))))
  change (M.initialGrid η).depth≤11 at hi
  change (M.programEvaluator P B η k).depth≤_ at hh
  nlinarith

 theorem programEvaluator_eval (M : VolterraGridSystem (Fin (d+1)) ι H) (hd : 1≤d)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (hB : ∀j,(P j).bounded (B j)) {η : ℝ} (hη : 0<η) (hη1 : η≤1)
    (happrox : ∀j x,‖M.residual j x-(P j).realMap x‖≤M.tolerance η) (x : Input d) :
    let Q:=M.mesh η
    let N:=M.stateRange
    let a:=normalizedCodes d Q N x
    ∃u:ℕ→M.StateIndex→ScalarCode Q N,
      ‖decodeCoordinates Q N a-normalizedInputFeature d x‖≤η/4 ∧
      ‖decodeCoordinates Q N (u 0)-baseVectorMap M.base (decodeCoordinates Q N a)‖≤η/4 ∧
      (∀k,‖decodeCoordinates Q N (u (k+1))-M.update (decodeCoordinates Q N (Sum.elim a (u k)))‖≤η/2) ∧
      ∀k,(M.programEvaluator P B η k).eval x=encodeCoordinateState Q N (Sum.elim a (u k)) := by
  intro Q N a
  have hvalid:‖decodeCoordinates Q N a‖≤3:=normalizedCodes_valid d Q N hd (M.mesh_pos η)
    M.stateRange_two ((M.input_error hη).trans (by linarith)) x
  obtain ⟨u0,hu0,he0⟩:=M.initialGrid_eval hd η hη hη1 x
  have hstep:=M.programStep_approximates P B hB hη hη1 happrox
  let u:=validGridIteration (valid:=fun a=>‖decodeCoordinates Q N a‖≤3) hstep a hvalid u0
  refine ⟨u,?_,?_,?_,?_⟩
  · rw [norm_sub_rev]
    exact (normalizedCodes_error d Q N hd (M.mesh_pos η) M.stateRange_two x).trans (M.input_error hη)
  · change ‖decodeCoordinates Q N u0-baseVectorMap M.base (decodeCoordinates Q N a)‖≤_
    rw [norm_sub_rev]
    exact he0
  · intro k
    exact validGridIteration_step_error (valid:=fun a=>‖decodeCoordinates Q N a‖≤3) hstep a hvalid u0 k
  · intro k
    unfold programEvaluator
    rw [CircuitMap.eval_then,hu0,validGridIteration_eval (valid:=fun a=>‖decodeCoordinates Q N a‖≤3) hstep a hvalid]

#print axioms programEvaluator_eval
#print axioms programEvaluator_depth
end VolterraGridSystem
end ConditionalNonpolynomial.AnalyticLookup
