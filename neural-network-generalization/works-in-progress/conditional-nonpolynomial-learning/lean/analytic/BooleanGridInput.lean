import ParallelGridCircuits
import NetworkKernelAdapter

/-! Actual constant-depth encoding of Boolean inputs, including the constant
coordinate and the normalization used by the controlled Gaussian path. -/
noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic NeuralGeneralization.ConcreteModel

 def constantCircuit (d : ℕ) (b : Bool) : ThresholdCircuit d :=
  ⟨0,(),⟨d+(if b then 1 else 0),by split <;> omega⟩⟩

@[simp] theorem constantCircuit_eval (d : ℕ) (b : Bool) (x : Input d) :
    (constantCircuit d b).eval x=b := by
  cases b <;> simp [constantCircuit,ThresholdCircuit.eval,ThresholdGates.eval,
    NeuralGeneralization.BatchTwoCircuitConverse.initialWire]
@[simp] theorem constantCircuit_size (d : ℕ) (b : Bool) : (constantCircuit d b).size=0 := rfl
@[simp] theorem constantCircuit_depth (d : ℕ) (b : Bool) : (constantCircuit d b).depth=0 := rfl

 def bitTableCircuit {d : ℕ} (i : Fin d) (t : Bool→Bool) : ThresholdCircuit d :=
  if t false=t true then constantCircuit d (t false) else literal i (t true)

@[simp] theorem bitTableCircuit_eval {d : ℕ} (i : Fin d) (t : Bool→Bool) (x : Input d) :
    (bitTableCircuit i t).eval x=t (x i) := by
  cases hf:t false <;> cases ht:t true <;> cases hx:x i <;>
    simp [bitTableCircuit,hf,ht,hx]
 theorem bitTableCircuit_size {d : ℕ} (i : Fin d) (t : Bool→Bool) : (bitTableCircuit i t).size≤3 := by
  unfold bitTableCircuit
  split
  · simp only [constantCircuit_size];omega
  · exact literal_size _ _
 theorem bitTableCircuit_depth {d : ℕ} (i : Fin d) (t : Bool→Bool) : (bitTableCircuit i t).depth≤1 := by
  unfold bitTableCircuit
  split
  · simp only [constantCircuit_depth];omega
  · exact literal_depth _ _

 inductive BooleanInputSource (d : ℕ) where
  | constant (v : ℝ)
  | bit (i : Fin d) (values : Bool→ℝ)

 def BooleanInputSource.eval {d : ℕ} : BooleanInputSource d→Input d→ℝ
  | .constant v,_=>v
  | .bit i v,x=>v (x i)

 def sourceBitCircuit {d : ℕ} (Q N : ℕ) (s : BooleanInputSource d) (a : ScalarCode Q N) : ThresholdCircuit d :=
  match s with
  | .constant v=>constantCircuit d (decide (scalarEncode Q N v=a))
  | .bit i values=>bitTableCircuit i (fun b=>decide (scalarEncode Q N (values b)=a))

@[simp] theorem sourceBitCircuit_eval {d : ℕ} (Q N : ℕ) (s : BooleanInputSource d)
    (a : ScalarCode Q N) (x : Input d) :
    (sourceBitCircuit Q N s a).eval x=decide (scalarEncode Q N (s.eval x)=a) := by
  cases s <;> simp [sourceBitCircuit,BooleanInputSource.eval]

 def booleanGridInput {d : ℕ} {ι : Type*} [Fintype ι] (Q N : ℕ) (s : ι→BooleanInputSource d) :
    CircuitMap d (Fintype.card ι*Fintype.card (ScalarGrid Q N)) :=
  CircuitMap.ofCircuits fun bit=>sourceBitCircuit Q N (s (gridWireCoordinate Q N bit))
    (gridWireValue (ι:=ι) Q N bit)

@[simp] theorem booleanGridInput_eval {d : ℕ} {ι : Type*} [Fintype ι]
    (Q N : ℕ) (s : ι→BooleanInputSource d) (x : Input d) :
    (booleanGridInput Q N s).eval x=encodeCoordinateState Q N (fun i=>scalarEncode Q N ((s i).eval x)) := by
  funext bit
  simp only [booleanGridInput,CircuitMap.eval_ofCircuits,sourceBitCircuit_eval,encodeCoordinateState_bit]

 theorem booleanGridInput_depth {d : ℕ} {ι : Type*} [Fintype ι]
    (Q N : ℕ) (s : ι→BooleanInputSource d) : (booleanGridInput Q N s).depth≤1 := by
  apply CircuitMap.depth_ofCircuits_le
  intro bit
  cases s (gridWireCoordinate Q N bit) <;> simp only [sourceBitCircuit,constantCircuit_depth]
  · omega
  · exact bitTableCircuit_depth _ _

 theorem booleanGridInput_size {d : ℕ} {ι : Type*} [Fintype ι]
    (Q N : ℕ) (s : ι→BooleanInputSource d) :
    (booleanGridInput Q N s).size≤3*(Fintype.card ι*Fintype.card (ScalarGrid Q N)) := by
  have hh:=CircuitMap.size_ofCircuits_le (fun bit=>sourceBitCircuit Q N
    (s (gridWireCoordinate Q N bit)) (gridWireValue (ι:=ι) Q N bit)) 3 (by
      intro bit
      cases s (gridWireCoordinate Q N bit) <;> simp only [sourceBitCircuit,constantCircuit_size]
      · omega
      · exact bitTableCircuit_size _ _)
  simpa only [booleanGridInput,Nat.mul_comm] using hh

 def normalizedInputSources (d : ℕ) : Fin (d+1)→BooleanInputSource d :=
  Fin.cases (.constant (1/Real.sqrt d)) (fun i=>.bit i (fun b=>labelReal b/Real.sqrt d))

@[simp] theorem normalizedInputSources_eval (d : ℕ) (x : Input d) (i : Fin (d+1)) :
    (normalizedInputSources d i).eval x=normalizedInputFeature d x i := by
  refine Fin.cases ?_ (fun i=>?_) i <;> rfl

 theorem normalizedInputEncoding_error (d Q N : ℕ) (hQ : 0<Q)
    (hN : ∀x:Input d,∀i,|normalizedInputFeature d x i|≤(N:ℝ)) (x : Input d) :
    ‖normalizedInputFeature d x-decodeCoordinates Q N
      (fun i=>scalarEncode Q N ((normalizedInputSources d i).eval x))‖≤
        ((d:ℝ)+2)/(2*(Q:ℝ)) := by
  have hh:=euclidean_norm_of_coordinate_bounds
    (normalizedInputFeature d x-decodeCoordinates Q N
      (fun i=>scalarEncode Q N ((normalizedInputSources d i).eval x)))
    (show 0≤1/(2*(Q:ℝ)) by positivity) (by
      intro i
      simpa only [PiLp.sub_apply,decodeCoordinates,WithLp.ofLp_toLp,normalizedInputSources_eval] using scalarEncode_error Q N hQ (normalizedInputFeature d x i) (hN x i))
  convert hh using 1 <;> simp only [Fintype.card_fin,Nat.cast_add,Nat.cast_one] <;> ring

#print axioms booleanGridInput_eval
#print axioms normalizedInputEncoding_error
end ConditionalNonpolynomial.AnalyticLookup
