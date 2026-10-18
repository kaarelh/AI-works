import NeuralGeneralization.RobustCompressionInductionPrefix

/-! # Additive disturbances of an actual virtual hidden path

The stored virtual path is compared with the original network one matrix at
a time. The identity below is the exact quantity integrated by canonical
history gluing; there are no downstream operator norms.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel

abbrev HiddenPath (N s : ℕ) := Fin (s+1) → Fin N → ℝ

def appendPath {N s : ℕ} (h : HiddenPath N s) (v : Fin N → ℝ) :
    HiddenPath N (s+1) := Fin.lastCases v h

@[simp] theorem appendPath_old {N s : ℕ} (h : HiddenPath N s)
    (v : Fin N → ℝ) (i : Fin (s+1)) : appendPath h v i.castSucc = h i := by
  simp [appendPath]

@[simp] theorem appendPath_last {N s : ℕ} (h : HiddenPath N s)
    (v : Fin N → ℝ) : appendPath h v (Fin.last (s+1)) = v := by
  simp [appendPath]

def hiddenPathCost {d N s : ℕ} (φ : ℝ → ℝ) (w : Weights d N s)
    (x : Cube d) (h : HiddenPath N s) : ℝ :=
  ((∑ i, (h 0 i-firstHidden φ w x i)^2)+
   ∑ j : Fin s, ∑ i, (h j.succ i-hiddenStep φ w (h j.castSucc) j i)^2)/(N:ℝ)

def localPathCost {N : ℕ} (φ : ℝ → ℝ) (a : Fin N → Fin N → ℝ)
    (h v : Fin N → ℝ) : ℝ :=
  (∑ i, (v i-φ (∑ j,a i j*h j))^2)/(N:ℝ)

theorem hiddenPathCost_nonneg {d N s : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N s) (x : Cube d) (h : HiddenPath N s) :
    0 ≤ hiddenPathCost φ w x h := by unfold hiddenPathCost; positivity

theorem localPathCost_nonneg {N : ℕ} (φ : ℝ → ℝ)
    (a : Fin N → Fin N → ℝ) (h v : Fin N → ℝ) :
    0 ≤ localPathCost φ a h v := by unfold localPathCost; positivity

/-- Appending one virtual layer adds precisely its normalized local squared
error against the original next matrix. -/
theorem hiddenPathCost_append {d N s : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N s) (a : Fin N → Fin N → ℝ) (x : Cube d)
    (h : HiddenPath N s) (v : Fin N → ℝ) :
    hiddenPathCost φ (appendWeights w a) x (appendPath h v) =
      hiddenPathCost φ w x h + localPathCost φ a (h (Fin.last s)) v := by
  have hz : (0 : Fin (s+2)) = (0 : Fin (s+1)).castSucc := rfl
  have hcast (j : Fin s) : j.castSucc.succ = j.succ.castSucc := rfl
  unfold hiddenPathCost localPathCost
  rw [hz,appendPath_old,firstHidden_appendWeights,Fin.sum_univ_castSucc]
  simp only [hcast,appendPath_old,hiddenStep_appendWeights_old,
    Fin.succ_last,appendPath_last]
  have hlastStep : hiddenStep φ (appendWeights w a) (h (Fin.last s)) (Fin.last s) =
      fun i => φ (∑ j,a i j*h (Fin.last s) j) := by
    funext i
    simp [hiddenStep]
  rw [hlastStep]
  ring

/-- At the final layer the path cost is the actual postactivation
perturbation budget, plus the scalar readout discrepancy. -/
theorem pathDisturbance_budget_eq_hiddenPathCost {d N s : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N s) (x : Cube d) (h : HiddenPath N s) (z : ℝ) :
    noiseBudgetSq (pathDisturbance φ w x h z) = hiddenPathCost φ w x h +
      (z-∑ i,w (Sum.inr (Sum.inr i))*h (Fin.last s) i)^2 := by
  exact pathDisturbance_budget φ w x h z

end NeuralGeneralization.RobustCompressionInduction
