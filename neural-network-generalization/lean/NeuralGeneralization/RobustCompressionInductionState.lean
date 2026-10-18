import NeuralGeneralization.RobustCompressionInductionOutput

/-! # The actual canonical prefix state, including absorbing abort

Stage zero stores the physical clipped first-layer rows. Stage s+1 stores
an ordinary compact prefix through s+1 hidden layers and N virtual next rows.
An explicit Boolean abort flag avoids any choice of a test input in the state.
-/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel

abbrev FirstRows (d N : ℕ) := Fin N → Fin (d+1) → ℝ

def PrefixPayload (d N m : ℕ) : ℕ → Type
  | 0 => FirstRows d N
  | s+1 => VirtualPrefix d N m s

instance prefixPayload_measurable (d N m s : ℕ) : MeasurableSpace (PrefixPayload d N m s) := by
  cases s <;> unfold PrefixPayload <;> infer_instance
instance prefixPayload_standardBorel (d N m s : ℕ) : StandardBorelSpace (PrefixPayload d N m s) := by
  cases s with
  | zero => change StandardBorelSpace (FirstRows d N); infer_instance
  | succ s => change StandardBorelSpace (VirtualPrefix d N m s); infer_instance
instance prefixPayload_nonempty (d N m s : ℕ) : Nonempty (PrefixPayload d N m s) := by
  cases s <;> unfold PrefixPayload <;> infer_instance

abbrev ActivePrefix (d N m s : ℕ) := Bool × PrefixPayload d N m s

def zeroPayload (d N m : ℕ) : (s : ℕ) → PrefixPayload d N m s
  | 0 => fun _ _ => 0
  | _+1 => ((fun _ => 0),fun _ _ => 0)

def firstRowsWeights {d N : ℕ} (a : FirstRows d N) : Weights d N 0 :=
  Sum.elim (fun ij => a ij.1 ij.2)
    (Sum.elim (fun z => Fin.elim0 z.1) (fun _ => 0))

def payloadHidden (d N m : ℕ) (φ : ℝ → ℝ) (x : Cube d) :
    (s : ℕ) → PrefixPayload d N m s → Fin N → ℝ
  | 0,a => firstHidden φ (firstRowsWeights a) x
  | _+1,p => virtualHidden φ p x

def activeHidden {d N m s : ℕ} (φ : ℝ → ℝ) (p : ActivePrefix d N m s)
    (x : Cube d) : Fin N → ℝ :=
  if p.1 then payloadHidden d N m φ x s p.2 else fun _ => 0

def stepPayload (d N m : ℕ) : (s : ℕ) → PrefixPayload d N m s →
    PrefixDraw N m → PrefixPayload d N m (s+1)
  | 0,a,draw => firstPrefix (firstRowsWeights a) draw.1 draw.2
  | _+1,p,draw => extendPrefix p draw.1 draw.2

/-- Both the previous abort flag and current success flag are checked. -/
def stepActive {d N m s : ℕ} (p : ActivePrefix d N m s)
    (draw : PrefixDraw N m) (success : Bool) : ActivePrefix d N m (s+1) :=
  if p.1 && success then (true,stepPayload d N m s p.2 draw)
    else (false,zeroPayload d N m (s+1))

@[simp] theorem stepActive_aborted {d N m s : ℕ} (a : PrefixPayload d N m s)
    (draw : PrefixDraw N m) (success : Bool) :
    stepActive (false,a) draw success = (false,zeroPayload d N m (s+1)) := by
  simp [stepActive]

@[simp] theorem stepActive_failure {d N m s : ℕ} (p : ActivePrefix d N m s)
    (draw : PrefixDraw N m) :
    stepActive p draw false = (false,zeroPayload d N m (s+1)) := by simp [stepActive]

/-- The next field is the actual reconstructed coefficient matrix acting on
the sampled previous virtual activations, at every input simultaneously. -/
theorem payloadHidden_step (d N m s : ℕ) (φ : ℝ → ℝ) (x : Cube d)
    (p : PrefixPayload d N m s) (draw : PrefixDraw N m) :
    payloadHidden d N m φ x (s+1) (stepPayload d N m s p draw) =
      fun i => φ (∑ j,draw.2 i j*payloadHidden d N m φ x s p (draw.1 j)) := by
  cases s with
  | zero => exact firstPrefix_virtual_hidden φ (firstRowsWeights p) draw.1 draw.2 x
  | succ s => exact extendPrefix_virtual_hidden φ p draw.1 draw.2 x

def finishPayload (d N m : ℕ) : (s : ℕ) → PrefixPayload d N m s →
    (Fin m → Fin N) → (Fin m → ℝ) → Weights d m s
  | 0,a,I,v => firstLayerOutput (firstRowsWeights a) I v
  | _+1,p,I,v => finishPrefix p I v

def finishActive {d N m s : ℕ} (p : ActivePrefix d N m s)
    (I : Fin m → Fin N) (v : Fin m → ℝ) : Weights d m s :=
  if p.1 then finishPayload d N m s p.2 I v else fun _ => 0

theorem finishPayload_output (d N m s : ℕ) (φ : ℝ → ℝ) (x : Cube d)
    (p : PrefixPayload d N m s) (I : Fin m → Fin N) (v : Fin m → ℝ) :
    networkOutput φ (finishPayload d N m s p I v) x =
      ∑ i,v i*payloadHidden d N m φ x s p (I i) := by
  cases s with
  | zero => exact firstLayerOutput_output φ (firstRowsWeights p) I v x
  | succ s => exact finishPrefix_output φ p I v x

theorem finishActive_output {d N m s : ℕ} (φ : ℝ → ℝ) (x : Cube d)
    (p : ActivePrefix d N m s) (I : Fin m → Fin N) (v : Fin m → ℝ) :
    networkOutput φ (finishActive p I v) x = ∑ i,v i*activeHidden φ p x (I i) := by
  unfold finishActive activeHidden
  split_ifs with h
  · exact finishPayload_output d N m s φ x p.2 I v
  · simp [networkOutput]

end NeuralGeneralization.RobustCompressionInduction
