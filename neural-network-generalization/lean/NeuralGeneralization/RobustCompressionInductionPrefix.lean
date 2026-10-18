import NeuralGeneralization.RobustModelContinuity
import NeuralGeneralization.RobustCompressionInjections

/-! # Concrete virtual prefixes for depthwise compression

After the first source bank has been selected, a prefix consists of an
ordinary width-m network and N literal coefficient rows for its next virtual
layer. Selecting m of those rows appends one ordinary hidden layer. All old
coefficients are retained exactly. Thus iterated reconstruction produces a
finite neural network, without abstract feature functions in its output type.
-/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel

abbrev VirtualRows (N m : ℕ) := Fin N → Fin m → ℝ
abbrev VirtualPrefix (d N m s : ℕ) := Weights d m s × VirtualRows N m

def virtualHidden {d N m s : ℕ} (φ : ℝ → ℝ) (p : VirtualPrefix d N m s)
    (x : Cube d) : Fin N → ℝ :=
  fun i => φ (∑ j, p.2 i j * finalHidden φ p.1 x j)

/-- Append a single ordinary hidden matrix. The readout is carried unchanged;
it is immaterial until the final scalar reconstruction. -/
def appendWeights {d m s : ℕ} (w : Weights d m s) (a : Fin m → Fin m → ℝ) :
    Weights d m (s+1) :=
  Sum.elim (fun ij => w (Sum.inl ij))
    (Sum.elim (fun sij => Fin.lastCases (a sij.2.1 sij.2.2)
      (fun k => w (Sum.inr (Sum.inl (k,sij.2.1,sij.2.2)))) sij.1)
      (fun i => w (Sum.inr (Sum.inr i))))

@[simp] theorem appendWeights_first {d m s : ℕ} (w : Weights d m s)
    (a : Fin m → Fin m → ℝ) (i : Fin m) (j : Fin (d+1)) :
    appendWeights w a (Sum.inl (i,j)) = w (Sum.inl (i,j)) := rfl

@[simp] theorem appendWeights_old {d m s : ℕ} (w : Weights d m s)
    (a : Fin m → Fin m → ℝ) (k : Fin s) (i j : Fin m) :
    appendWeights w a (Sum.inr (Sum.inl (k.castSucc,i,j))) =
      w (Sum.inr (Sum.inl (k,i,j))) := by simp [appendWeights]

@[simp] theorem appendWeights_last {d m s : ℕ} (w : Weights d m s)
    (a : Fin m → Fin m → ℝ) (i j : Fin m) :
    appendWeights w a (Sum.inr (Sum.inl (Fin.last s,i,j))) = a i j := by
  simp [appendWeights]

@[simp] theorem appendWeights_readout {d m s : ℕ} (w : Weights d m s)
    (a : Fin m → Fin m → ℝ) (i : Fin m) :
    appendWeights w a (Sum.inr (Sum.inr i)) = w (Sum.inr (Sum.inr i)) := rfl

@[simp] theorem firstHidden_appendWeights {d m s : ℕ} (φ : ℝ → ℝ)
    (w : Weights d m s) (a : Fin m → Fin m → ℝ) (x : Cube d) :
    firstHidden φ (appendWeights w a) x = firstHidden φ w x := rfl

@[simp] theorem hiddenStep_appendWeights_old {d m s : ℕ} (φ : ℝ → ℝ)
    (w : Weights d m s) (a : Fin m → Fin m → ℝ)
    (h : Fin m → ℝ) (k : Fin s) :
    hiddenStep φ (appendWeights w a) h k.castSucc = hiddenStep φ w h k := by
  funext i
  simp [hiddenStep]

/-- Exact prefix evaluation: appending does not perturb an earlier layer. -/
theorem finalHidden_appendWeights {d m s : ℕ} (φ : ℝ → ℝ)
    (w : Weights d m s) (a : Fin m → Fin m → ℝ) (x : Cube d) :
    finalHidden φ (appendWeights w a) x =
      fun i => φ (∑ j, a i j * finalHidden φ w x j) := by
  unfold finalHidden
  rw [List.finRange_succ_last, List.foldl_append, List.foldl_cons,
    List.foldl_nil, List.foldl_map, firstHidden_appendWeights]
  simp only [hiddenStep_appendWeights_old]
  funext i
  simp [hiddenStep]

/-- The actual next prefix produced from a sampled source bank and literal
reconstructed coefficient rows. -/
def extendPrefix {d N m s : ℕ} (p : VirtualPrefix d N m s)
    (I : Fin m → Fin N) (rows : VirtualRows N m) : VirtualPrefix d N m (s+1) :=
  (appendWeights p.1 (fun i j => p.2 (I i) j), rows)

/-- Selected previous virtual neurons are the next compact hidden state. -/
theorem extendPrefix_compact_hidden {d N m s : ℕ} (φ : ℝ → ℝ)
    (p : VirtualPrefix d N m s) (I : Fin m → Fin N)
    (rows : VirtualRows N m) (x : Cube d) :
    finalHidden φ (extendPrefix p I rows).1 x = fun i => virtualHidden φ p x (I i) := by
  exact finalHidden_appendWeights φ p.1 (fun i j => p.2 (I i) j) x

/-- Reconstruction at a layer is evaluated against precisely the selected
old virtual activations. It is not an approximation to a different prefix. -/
theorem extendPrefix_virtual_hidden {d N m s : ℕ} (φ : ℝ → ℝ)
    (p : VirtualPrefix d N m s) (I : Fin m → Fin N)
    (rows : VirtualRows N m) (x : Cube d) :
    virtualHidden φ (extendPrefix p I rows) x =
      fun i => φ (∑ j, rows i j * virtualHidden φ p x (I j)) := by
  unfold virtualHidden
  rw [extendPrefix_compact_hidden]
  rfl

/-- The first compact hidden layer consists of sampled actual input rows. -/
def firstPrefix {d N m r : ℕ} (w : Weights d N r)
    (I : Fin m → Fin N) (rows : VirtualRows N m) : VirtualPrefix d N m 0 :=
  (Sum.elim (fun ij => w (Sum.inl (I ij.1,ij.2)))
    (Sum.elim (fun z => Fin.elim0 z.1) (fun _ => 0)),rows)

theorem firstPrefix_hidden {d N m r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (I : Fin m → Fin N) (rows : VirtualRows N m) (x : Cube d) :
    finalHidden φ (firstPrefix w I rows).1 x = fun i => firstHidden φ w x (I i) := by
  funext i
  simp [finalHidden,firstPrefix,firstHidden]

theorem firstPrefix_virtual_hidden {d N m r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (I : Fin m → Fin N) (rows : VirtualRows N m) (x : Cube d) :
    virtualHidden φ (firstPrefix w I rows) x =
      fun i => φ (∑ j, rows i j * firstHidden φ w x (I j)) := by
  unfold virtualHidden
  rw [firstPrefix_hidden]
  rfl

/-- Appending preserves the same coefficient bound; the depth never appears
in this estimate. -/
theorem appendWeights_bounded {d m s : ℕ} (w : Weights d m s)
    (a : Fin m → Fin m → ℝ) {B : ℝ} (hw : boundedWeights B w)
    (ha : ∀ i j, |a i j| ≤ B) : boundedWeights B (appendWeights w a) := by
  intro z
  rcases z with z | z
  · exact hw _
  · rcases z with ⟨k,i,j⟩ | i
    · induction k using Fin.lastCases with
      | last => simpa using ha i j
      | cast k => simpa using hw (Sum.inr (Sum.inl (k,i,j)))
    · exact hw _

theorem extendPrefix_bounded {d N m s : ℕ} (p : VirtualPrefix d N m s)
    (I : Fin m → Fin N) (rows : VirtualRows N m) {B : ℝ}
    (hp : boundedWeights B p.1) (hold : ∀ i j, |p.2 i j| ≤ B)
    (hnew : ∀ i j, |rows i j| ≤ B) :
    boundedWeights B (extendPrefix p I rows).1 ∧
      ∀ i j, |(extendPrefix p I rows).2 i j| ≤ B :=
  ⟨appendWeights_bounded p.1 _ hp (fun i j => hold (I i) j),hnew⟩

end NeuralGeneralization.RobustCompressionInduction
