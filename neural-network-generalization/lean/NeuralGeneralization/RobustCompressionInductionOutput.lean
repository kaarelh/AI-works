import NeuralGeneralization.RobustCompressionInductionMeasurable

/-! # Finishing the canonical virtual prefix as an ordinary network

The last source bank is retained as the actual last hidden layer, and the
sampled readout is attached to it. This closes the deterministic output side
of the compression induction, including the one-hidden-layer case.
-/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel

def setReadout {d m s : ℕ} (w : Weights d m s) (v : Fin m → ℝ) : Weights d m s :=
  Sum.elim (fun ij => w (Sum.inl ij))
    (Sum.elim (fun z => w (Sum.inr (Sum.inl z))) v)

@[simp] theorem firstHidden_setReadout {d m s : ℕ} (φ : ℝ → ℝ)
    (w : Weights d m s) (v : Fin m → ℝ) (x : Cube d) :
    firstHidden φ (setReadout w v) x = firstHidden φ w x := rfl

@[simp] theorem hiddenStep_setReadout {d m s : ℕ} (φ : ℝ → ℝ)
    (w : Weights d m s) (v h : Fin m → ℝ) (k : Fin s) :
    hiddenStep φ (setReadout w v) h k = hiddenStep φ w h k := rfl

@[simp] theorem finalHidden_setReadout {d m s : ℕ} (φ : ℝ → ℝ)
    (w : Weights d m s) (v : Fin m → ℝ) (x : Cube d) :
    finalHidden φ (setReadout w v) x = finalHidden φ w x := rfl

theorem networkOutput_setReadout {d m s : ℕ} (φ : ℝ → ℝ)
    (w : Weights d m s) (v : Fin m → ℝ) (x : Cube d) :
    networkOutput φ (setReadout w v) x = ∑ i,v i*finalHidden φ w x i := rfl

def finishPrefix {d N m s : ℕ} (p : VirtualPrefix d N m s)
    (I : Fin m → Fin N) (v : Fin m → ℝ) : Weights d m (s+1) :=
  setReadout (appendWeights p.1 (fun i j => p.2 (I i) j)) v

theorem finishPrefix_output {d N m s : ℕ} (φ : ℝ → ℝ)
    (p : VirtualPrefix d N m s) (I : Fin m → Fin N) (v : Fin m → ℝ)
    (x : Cube d) : networkOutput φ (finishPrefix p I v) x =
      ∑ i,v i*virtualHidden φ p x (I i) := by
  rw [finishPrefix,networkOutput_setReadout,finalHidden_appendWeights]
  rfl

def firstLayerOutput {d N m r : ℕ} (w : Weights d N r)
    (I : Fin m → Fin N) (v : Fin m → ℝ) : Weights d m 0 :=
  setReadout (firstPrefix w I (fun _ _ => 0)).1 v

theorem firstLayerOutput_output {d N m r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (I : Fin m → Fin N) (v : Fin m → ℝ)
    (x : Cube d) : networkOutput φ (firstLayerOutput w I v) x =
      ∑ i,v i*firstHidden φ w x (I i) := by
  rw [firstLayerOutput,networkOutput_setReadout,firstPrefix_hidden]

theorem setReadout_bounded {d m s : ℕ} (w : Weights d m s)
    (v : Fin m → ℝ) {B : ℝ} (hw : boundedWeights B w)
    (hv : ∀ i,|v i|≤B) : boundedWeights B (setReadout w v) := by
  intro i
  rcases i with ij | z
  · exact hw _
  · rcases z with z | i
    · exact hw _
    · exact hv i

theorem finishPrefix_bounded {d N m s : ℕ} (p : VirtualPrefix d N m s)
    (I : Fin m → Fin N) (v : Fin m → ℝ) {B : ℝ}
    (hp : boundedWeights B p.1) (hrows : ∀ i j,|p.2 i j|≤B)
    (hv : ∀ i,|v i|≤B) : boundedWeights B (finishPrefix p I v) :=
  setReadout_bounded _ v (appendWeights_bounded _ _ hp (fun i j => hrows (I i) j)) hv

variable {A : Type*} [MeasurableSpace A]

theorem measurable_setReadout {d m s : ℕ} (w : A → Weights d m s)
    (v : A → Fin m → ℝ) (hw : Measurable w) (hv : Measurable v) :
    Measurable (fun a => setReadout (w a) (v a)) := by
  apply measurable_pi_lambda
  intro i
  rcases i with ij | z
  · exact hw.eval
  · rcases z with z | i
    · exact hw.eval
    · exact hv.eval

theorem measurable_finishPrefix {d N m s : ℕ} (p : A → VirtualPrefix d N m s)
    (I : A → Fin m → Fin N) (v : A → Fin m → ℝ)
    (hp : Measurable p) (hI : Measurable I) (hv : Measurable v) :
    Measurable (fun a => finishPrefix (p a) (I a) (v a)) := by
  apply measurable_setReadout _ _ _ hv
  exact (measurable_extendPrefix p I (fun _ _ _ => 0) hp hI measurable_const).fst

end NeuralGeneralization.RobustCompressionInduction
