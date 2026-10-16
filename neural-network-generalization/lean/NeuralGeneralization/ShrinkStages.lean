import NeuralGeneralization.GrowthPathBudget

/-! Exact finite-stage indices for paths whose diameter shrinks in unit steps. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.GrowthPath

variable (s : ℕ → ℕ) (hunbounded : ∀ i, ∃ h, i ≤ s h)

def stageStart (i : ℕ) : ℕ := Nat.find (hunbounded i)

theorem stageStart_reached (i : ℕ) : i ≤ s (stageStart s hunbounded i) :=
  Nat.find_spec (hunbounded i)

theorem stageStart_le_iff (hs : Monotone s) (i h : ℕ) :
    stageStart s hunbounded i ≤ h ↔ i ≤ s h := by
  constructor
  · intro hi
    exact (stageStart_reached s hunbounded i).trans (hs hi)
  · intro hi
    exact Nat.find_min' (hunbounded i) hi

@[simp] theorem stageStart_zero : stageStart s hunbounded 0 = 0 := by
  exact Nat.eq_zero_of_le_zero (Nat.find_min' (hunbounded 0) (Nat.zero_le (s 0)))

theorem stageStart_value (hs0 : s 0 = 0) (hstep : ∀ h, s (h+1) ≤ s h + 1)
    (i : ℕ) : s (stageStart s hunbounded i) = i := by
  have hlo := stageStart_reached s hunbounded i
  apply Nat.le_antisymm _ hlo
  generalize he : stageStart s hunbounded i = h at *
  cases h with
  | zero => simpa [hs0] using Nat.zero_le i
  | succ h =>
    have hprev : ¬ i ≤ s h := Nat.find_min (hunbounded i) (by
      change h < stageStart s hunbounded i
      rw [he]
      exact Nat.lt_succ_self _)
    have hh := hstep h
    omega

theorem stageStart_strictMono (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h + 1) : StrictMono (stageStart s hunbounded) := by
  intro i j hij
  by_contra hn
  have hle := hs (Nat.le_of_not_gt hn)
  rw [stageStart_value s hunbounded hs0 hstep j, stageStart_value s hunbounded hs0 hstep i] at hle
  omega

theorem stageStart_le_self_stage (hs : Monotone s) (h : ℕ) :
    stageStart s hunbounded (s h) ≤ h := (stageStart_le_iff s hunbounded hs _ _).mpr le_rfl

theorem self_lt_next_stage (hs : Monotone s) (h : ℕ) :
    h < stageStart s hunbounded (s h + 1) := by
  by_contra hn
  have hh := (stageStart_le_iff s hunbounded hs _ _).mp (Nat.le_of_not_gt hn)
  omega

theorem stage_value_on_interval (hs : Monotone s) (i h : ℕ)
    (hlo : stageStart s hunbounded i ≤ h)
    (hhi : h < stageStart s hunbounded (i+1)) : s h = i := by
  have h₁ := (stageStart_le_iff s hunbounded hs i h).mp hlo
  have h₂ : ¬ i+1 ≤ s h := by
    intro hh
    exact (Nat.not_le_of_gt hhi) ((stageStart_le_iff s hunbounded hs _ _).mpr hh)
  omega

def stageEnd (i : ℕ) : ℕ := stageStart s hunbounded (i+1) - 1

theorem stageEnd_succ (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h + 1) (i : ℕ) :
    stageEnd s hunbounded i + 1 = stageStart s hunbounded (i+1) := by
  have hh := stageStart_strictMono s hunbounded hs hs0 hstep (Nat.lt_succ_self i)
  simp only [Nat.succ_eq_add_one] at hh
  unfold stageEnd
  omega

theorem stageStart_le_end (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h + 1) (i : ℕ) :
    stageStart s hunbounded i ≤ stageEnd s hunbounded i := by
  have hh := stageStart_strictMono s hunbounded hs hs0 hstep (Nat.lt_succ_self i)
  simp only [Nat.succ_eq_add_one] at hh
  unfold stageEnd
  omega

theorem stageEnd_value (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h + 1) (i : ℕ) :
    s (stageEnd s hunbounded i) = i := by
  apply stage_value_on_interval s hunbounded hs i _ (stageStart_le_end s hunbounded hs hs0 hstep i)
  have hh := stageEnd_succ s hunbounded hs hs0 hstep i
  omega

/-- A stage with at least two nodes has an actual last unchanged-diameter
edge immediately before its last node. -/
theorem last_right_step (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h + 1) (i : ℕ)
    (hlong : stageStart s hunbounded i < stageEnd s hunbounded i) :
    s (stageEnd s hunbounded i - 1) = i ∧
      s (stageEnd s hunbounded i) = s (stageEnd s hunbounded i - 1) := by
  have hval : s (stageEnd s hunbounded i - 1) = i := by
    apply stage_value_on_interval s hunbounded hs i _ (by omega)
    have hh := stageEnd_succ s hunbounded hs hs0 hstep i
    omega
  exact ⟨hval, (stageEnd_value s hunbounded hs hs0 hstep i).trans hval.symm⟩

end NeuralGeneralization.GrowthPath
