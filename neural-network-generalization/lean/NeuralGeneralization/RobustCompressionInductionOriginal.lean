import NeuralGeneralization.RobustCompressionInductionPath

/-! # Original-network prefixes retained in the depth comparison -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel

def originalPrefix {d N r s : ℕ} (hs : s ≤ r) (w : Weights d N r) : Weights d N s :=
  Sum.elim (fun ij => w (Sum.inl ij))
    (Sum.elim (fun sij => w (Sum.inr (Sum.inl (Fin.castLE hs sij.1,sij.2))))
      (fun i => w (Sum.inr (Sum.inr i))))

@[simp] theorem originalPrefix_first {d N r s : ℕ} (hs : s ≤ r) (w : Weights d N r)
    (i : Fin N) (j : Fin (d+1)) :
    originalPrefix hs w (Sum.inl (i,j))=w (Sum.inl (i,j)) := rfl

@[simp] theorem originalPrefix_layer {d N r s : ℕ} (hs : s ≤ r) (w : Weights d N r)
    (l : Fin s) (i j : Fin N) :
    originalPrefix hs w (Sum.inr (Sum.inl (l,i,j)))=
      w (Sum.inr (Sum.inl (Fin.castLE hs l,i,j))) := rfl

@[simp] theorem originalPrefix_readout {d N r s : ℕ} (hs : s ≤ r) (w : Weights d N r)
    (i : Fin N) : originalPrefix hs w (Sum.inr (Sum.inr i))=w (Sum.inr (Sum.inr i)) := rfl

@[simp] theorem originalPrefix_full {d N r : ℕ} (w : Weights d N r) :
    originalPrefix le_rfl w=w := by
  funext i
  rcases i with ⟨i,j⟩ | (⟨l,i,j⟩ | i) <;> rfl

theorem measurable_originalPrefix {d N r s : ℕ} (hs : s ≤ r) :
    Measurable (originalPrefix (d:=d) (N:=N) hs) := by
  apply measurable_pi_lambda
  intro i
  rcases i with ⟨i,j⟩ | (⟨l,i,j⟩ | i) <;> exact measurable_pi_apply _

/-- Appending the next actual original matrix gives its actual longer prefix. -/
theorem originalPrefix_succ {d N r s : ℕ} (hs : s+1 ≤ r) (w : Weights d N r) :
    originalPrefix hs w = appendWeights (originalPrefix (by omega : s ≤ r) w)
      (fun i j => w (Sum.inr (Sum.inl (⟨s,hs⟩,i,j)))) := by
  funext z
  rcases z with ⟨i,j⟩ | (⟨l,i,j⟩ | i)
  · rfl
  · induction l using Fin.lastCases with
    | last => simp only [originalPrefix_layer,appendWeights_last]; rfl
    | cast l => simp only [originalPrefix_layer,appendWeights_old]; rfl
  · rfl

/-- The hidden-path cost is the true accumulated local disturbance against
all original matrices consumed so far. -/
def originalPathCost {d N r s : ℕ} (hs : s ≤ r) (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d) (h : HiddenPath N s) : ℝ :=
  hiddenPathCost φ (originalPrefix hs w) x h

theorem originalPathCost_succ {d N r s : ℕ} (hs : s+1 ≤ r) (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d) (h : HiddenPath N s) (v : Fin N → ℝ) :
    originalPathCost hs φ w x (appendPath h v) =
      originalPathCost (by omega : s ≤ r) φ w x h +
        localPathCost φ (fun i j => w (Sum.inr (Sum.inl (⟨s,hs⟩,i,j))))
          (h (Fin.last s)) v := by
  unfold originalPathCost
  rw [originalPrefix_succ,hiddenPathCost_append]

@[simp] theorem originalPathCost_full {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d) (h : HiddenPath N r) :
    originalPathCost le_rfl φ w x h=hiddenPathCost φ w x h := by
  simp [originalPathCost]

end NeuralGeneralization.RobustCompressionInduction
