import GridCircuitComposition

/-! Actual zero-cost coordinate wiring and parallel shared-input circuit banks.
These are the Boolean graph operations needed for a simultaneous Picard step. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

variable {ι κ J : Type*} [Fintype ι] [Fintype κ] [Fintype J]

 def gridWire (Q N : ℕ) (i : ι) (a : ScalarCode Q N) :
    Fin (Fintype.card ι*Fintype.card (ScalarGrid Q N)) :=
  finProdFinEquiv (Fintype.equivFin ι i,a)

 def gridWireCoordinate (Q N : ℕ)
    (j : Fin (Fintype.card ι*Fintype.card (ScalarGrid Q N))) : ι :=
  (Fintype.equivFin ι).symm (finProdFinEquiv.symm j).1

 def gridWireValue (Q N : ℕ)
    (j : Fin (Fintype.card ι*Fintype.card (ScalarGrid Q N))) : ScalarCode Q N :=
  (finProdFinEquiv.symm j).2

@[simp] lemma gridWireCoordinate_wire (Q N : ℕ) (i : ι) (a : ScalarCode Q N) :
    gridWireCoordinate Q N (gridWire Q N i a)=i := by simp [gridWireCoordinate,gridWire]

@[simp] lemma gridWireValue_wire (Q N : ℕ) (i : ι) (a : ScalarCode Q N) :
    gridWireValue (ι:=ι) Q N (gridWire Q N i a)=a := by simp [gridWireValue,gridWire]

@[simp] lemma encodeCoordinateState_bit (Q N : ℕ) (a : ι→ScalarCode Q N)
    (j : Fin (Fintype.card ι*Fintype.card (ScalarGrid Q N))) :
    encodeCoordinateState Q N a j=decide (a (gridWireCoordinate Q N j)=gridWireValue (ι:=ι) Q N j) := rfl

 def CircuitMap.rewire {d k : ℕ} (p : Fin k→Fin d) : CircuitMap d k where
  gateCount:=0
  gates:=()
  outputs:=fun i=>⟨p i,by have hh:=(p i).isLt;omega⟩

@[simp] theorem CircuitMap.rewire_eval {d k : ℕ} (p : Fin k→Fin d) (x : Input d) :
    (CircuitMap.rewire p).eval x=fun i=>x (p i) := by
  funext i
  simp [CircuitMap.rewire,CircuitMap.eval,ThresholdGates.eval,
    NeuralGeneralization.BatchTwoCircuitConverse.initialWire,(p i).isLt]

@[simp] theorem CircuitMap.rewire_size {d k : ℕ} (p : Fin k→Fin d) :
    (CircuitMap.rewire p).size=0 := rfl
@[simp] theorem CircuitMap.rewire_depth {d k : ℕ} (p : Fin k→Fin d) :
    (CircuitMap.rewire p).depth=0 := rfl

 def projectGridCoordinates (Q N : ℕ) (p : κ→ι) :=
  CircuitMap.rewire fun j:Fin (Fintype.card κ*Fintype.card (ScalarGrid Q N))=>
    gridWire Q N (p (gridWireCoordinate Q N j)) (gridWireValue (ι:=κ) Q N j)

@[simp] theorem projectGridCoordinates_eval (Q N : ℕ) (p : κ→ι) (a : ι→ScalarCode Q N) :
    (projectGridCoordinates Q N p).eval (encodeCoordinateState Q N a)=
      encodeCoordinateState Q N (a∘p) := by
  funext j
  simp only [projectGridCoordinates,CircuitMap.rewire_eval,encodeCoordinateState_bit,
    gridWireCoordinate_wire,gridWireValue_wire,Function.comp_apply]
  rfl

 def parallelGridCircuits {input : ℕ} (Q N : ℕ)
    (cs : J→CircuitMap input (Fintype.card κ*Fintype.card (ScalarGrid Q N))) :
    CircuitMap input (Fintype.card (J×κ)*Fintype.card (ScalarGrid Q N)) :=
  CircuitMap.ofCircuits fun bit=>
    (cs (gridWireCoordinate Q N bit).1).select
      (gridWire Q N (gridWireCoordinate Q N bit).2 (gridWireValue (ι:=J×κ) Q N bit))

 theorem parallelGridCircuits_eval {input : ℕ} (Q N : ℕ)
    (cs : J→CircuitMap input (Fintype.card κ*Fintype.card (ScalarGrid Q N)))
    (x : Input input) (a : J→κ→ScalarCode Q N)
    (hc : ∀j,(cs j).eval x=encodeCoordinateState Q N (a j)) :
    (parallelGridCircuits Q N cs).eval x=
      encodeCoordinateState Q N (fun z:J×κ=>a z.1 z.2) := by
  funext bit
  simp only [parallelGridCircuits,CircuitMap.eval_ofCircuits,CircuitMap.eval_select,hc,
    encodeCoordinateState_bit,gridWireCoordinate_wire,gridWireValue_wire]

 theorem parallelGridCircuits_size {input : ℕ} (Q N : ℕ)
    (cs : J→CircuitMap input (Fintype.card κ*Fintype.card (ScalarGrid Q N)))
    (S : ℕ) (hS : ∀j,(cs j).size≤S) :
    (parallelGridCircuits Q N cs).size≤
      (Fintype.card (J×κ)*Fintype.card (ScalarGrid Q N))*S := by
  apply CircuitMap.size_ofCircuits_le
  intro bit
  exact hS _

 theorem parallelGridCircuits_depth {input : ℕ} (Q N : ℕ)
    (cs : J→CircuitMap input (Fintype.card κ*Fintype.card (ScalarGrid Q N)))
    (D : ℕ) (hD : ∀j,(cs j).depth≤D) : (parallelGridCircuits Q N cs).depth≤D := by
  apply CircuitMap.depth_ofCircuits_le
  intro bit
  exact hD _

 def blockVector (x : EuclideanSpace ℝ (J×ι)) (j : J) : EuclideanSpace ℝ ι :=
  WithLp.toLp 2 (fun i=>x (j,i))

 def parallelRealMap (F : J→EuclideanSpace ℝ ι→EuclideanSpace ℝ κ)
    (x : EuclideanSpace ℝ (J×ι)) : EuclideanSpace ℝ (J×κ) :=
  WithLp.toLp 2 (fun z=>F z.1 (blockVector x z.1) z.2)

 def parallelBlockCircuits (Q Ni Qo No : ℕ)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q Ni))
      (Fintype.card κ*Fintype.card (ScalarGrid Qo No))) :=
  parallelGridCircuits Qo No (fun j=>
    (projectGridCoordinates Q Ni (fun i:ι=>(j,i))).then (cs j))

 theorem parallelBlockCircuits_approximates (Q Ni Qo No : ℕ)
    (F : J→EuclideanSpace ℝ ι→EuclideanSpace ℝ κ)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q Ni))
      (Fintype.card κ*Fintype.card (ScalarGrid Qo No)))
    {ε : ℝ} (hε : 0≤ε) (hc : ∀j,GridApproximates Q Ni Qo No (F j) (cs j) ε) :
    GridApproximates Q Ni Qo No (parallelRealMap F) (parallelBlockCircuits Q Ni Qo No cs)
      (((Fintype.card (J×κ):ℝ)+1)*ε) := by
  intro a
  have hchoose : ∀j:J,∃b:κ→ScalarCode Qo No,
      (cs j).eval (encodeCoordinateState Q Ni (fun i=>a (j,i)))=encodeCoordinateState Qo No b ∧
        ‖F j (decodeCoordinates Q Ni (fun i=>a (j,i)))-decodeCoordinates Qo No b‖≤ε :=
    fun j=>hc j (fun i=>a (j,i))
  choose b hbeval hberror using hchoose
  refine ⟨(fun z=>b z.1 z.2),?_,?_⟩
  · apply parallelGridCircuits_eval
    intro j
    rw [CircuitMap.eval_then,projectGridCoordinates_eval]
    exact hbeval j
  · apply euclidean_norm_of_coordinate_bounds _ hε
    intro z
    have hh := PiLp.norm_apply_le
      (F z.1 (decodeCoordinates Q Ni (fun i=>a (z.1,i)))-decodeCoordinates Qo No (b z.1)) z.2
    exact hh.trans (hberror z.1)

#print axioms parallelBlockCircuits_approximates
#print axioms parallelGridCircuits_depth
end ConditionalNonpolynomial.AnalyticLookup
