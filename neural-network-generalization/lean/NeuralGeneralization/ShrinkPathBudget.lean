import NeuralGeneralization.ShrinkStages
import Mathlib.Algebra.Order.BigOperators.Group.Finset

/-! From literal shrink-count paths to a uniform chaining budget. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.GrowthPath

variable (s : ℕ → ℕ) (hu : ∀ i, ∃ h, i ≤ s h)

def nodeWeight (D : ℝ) (h : ℕ) : ℝ := (2 : ℝ)^h * (D * (1 / 8 : ℝ)^(s h))
def stageWeight (D : ℝ) (i : ℕ) : ℝ :=
  (2 : ℝ)^(stageEnd s hu i) * (D * (1 / 8 : ℝ)^i)
def stageCharge (D : ℝ) (i : ℕ) : ℝ :=
  if stageStart s hu i < stageEnd s hu i then stageWeight s hu D i / 2 else 0

theorem nodeWeight_nonneg {D : ℝ} (hD : 0 ≤ D) (h : ℕ) : 0 ≤ nodeWeight s D h := by
  unfold nodeWeight
  positivity

theorem stageWeight_nonneg {D : ℝ} (hD : 0 ≤ D) (i : ℕ) : 0 ≤ stageWeight s hu D i := by
  unfold stageWeight
  positivity

theorem first_stage_budget (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h+1) {D : ℝ} (hD : 0 ≤ D) :
    stageWeight s hu D 0 ≤ D + 2 * stageCharge s hu D 0 := by
  unfold stageCharge
  split_ifs with hh
  · linarith
  · have he := stageStart_le_end s hu hs hs0 hstep 0
    have hz : stageEnd s hu 0 = 0 := by simp only [stageStart_zero] at he hh; omega
    simp [stageWeight, hz]

theorem stage_weight_step (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h+1) {D : ℝ} (hD : 0 ≤ D) (i : ℕ) :
    stageWeight s hu D (i+1) ≤ stageWeight s hu D i / 4 + 2 * stageCharge s hu D (i+1) := by
  unfold stageCharge
  split_ifs with hh
  · have hp := stageWeight_nonneg s hu hD i
    linarith
  · have hstart := stageStart_le_end s hu hs hs0 hstep (i+1)
    have he : stageEnd s hu (i+1) = stageEnd s hu i + 1 := by
      have hsuc := stageEnd_succ s hu hs hs0 hstep i
      omega
    unfold stageWeight
    rw [he, pow_succ, pow_succ]
    ring_nf
    exact le_refl _

theorem stage_interval_cost (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h+1) {D : ℝ} (hD : 0 ≤ D) (i : ℕ) :
    (∑ h ∈ Finset.Ico (stageStart s hu i) (stageStart s hu (i+1)), nodeWeight s D h) ≤
      2 * stageWeight s hu D i := by
  let A := D * (1 / 8 : ℝ)^i
  have hA : 0 ≤ A := by positivity
  have heq : (∑ h ∈ Finset.Ico (stageStart s hu i) (stageStart s hu (i+1)), nodeWeight s D h) =
      (∑ h ∈ Finset.Ico (stageStart s hu i) (stageStart s hu (i+1)), (2 : ℝ)^h) * A := by
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro h hh
    rw [nodeWeight, stage_value_on_interval s hu hs i h (Finset.mem_Ico.mp hh).1 (Finset.mem_Ico.mp hh).2]
  rw [heq]
  have hsum : (∑ h ∈ Finset.Ico (stageStart s hu i) (stageStart s hu (i+1)), (2 : ℝ)^h) ≤
      (2 : ℝ)^(stageStart s hu (i+1)) := by
    calc
      _ ≤ ∑ h ∈ Finset.range (stageStart s hu (i+1)), (2 : ℝ)^h := by
        apply Finset.sum_le_sum_of_subset_of_nonneg
        · intro h hh
          exact Finset.mem_range.mpr (Finset.mem_Ico.mp hh).2
        · intro h hh hnot
          positivity
      _ ≤ _ := by
        have hg := geom_sum_mul (2 : ℝ) (stageStart s hu (i+1))
        linarith
  have hm := mul_le_mul_of_nonneg_right hsum hA
  have hpow : (2 : ℝ)^(stageStart s hu (i+1)) = 2 * 2^(stageEnd s hu i) := by
    rw [← stageEnd_succ s hu hs hs0 hstep i, pow_succ]
    ring
  rw [hpow] at hm
  simpa only [stageWeight, A, mul_assoc, mul_comm, mul_left_comm] using hm

theorem cost_through_stage (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h+1) {D : ℝ} (hD : 0 ≤ D) (L : ℕ) :
    (∑ h ∈ Finset.range (stageStart s hu L), nodeWeight s D h) ≤
      2 * ∑ i ∈ Finset.range L, stageWeight s hu D i := by
  induction L with
  | zero => simp
  | succ L ih =>
    have hlo := (stageStart_strictMono s hu hs hs0 hstep (Nat.lt_succ_self L)).le
    have he := Finset.sum_range_add_sum_Ico (nodeWeight s D) hlo
    rw [← he, Finset.sum_range_succ]
    have hh := stage_interval_cost s hu hs hs0 hstep hD L
    linarith

theorem prefix_cost_le_stages (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h+1) {D : ℝ} (hD : 0 ≤ D) (L : ℕ) :
    (∑ h ∈ Finset.range L, nodeWeight s D h) ≤
      2 * ∑ i ∈ Finset.range L, stageWeight s hu D i := by
  apply le_trans _ (cost_through_stage s hu hs hs0 hstep hD L)
  apply Finset.sum_le_sum_of_subset_of_nonneg
  · exact Finset.range_mono ((stageStart_strictMono s hu hs hs0 hstep).id_le L)
  · intro h hh hnot
    exact nodeWeight_nonneg s hD h

/-- The charge of a nontrivial run is exactly the weight of its last
unchanged-diameter edge. -/
theorem stageCharge_eq_last_right (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h+1) (D : ℝ) (i : ℕ)
    (hlong : stageStart s hu i < stageEnd s hu i) :
    stageCharge s hu D i = nodeWeight s D (stageEnd s hu i - 1) := by
  have he : stageEnd s hu i - 1 + 1 = stageEnd s hu i := by omega
  have hv := (last_right_step s hu hs hs0 hstep i hlong).1
  have hp : (2 : ℝ)^(stageEnd s hu i) = 2 * 2^(stageEnd s hu i - 1) := by
    conv_lhs => rw [← he]
    rw [pow_succ]
    ring
  rw [stageCharge, if_pos hlong, nodeWeight, hv, stageWeight, hp]
  ring

/-- The actual four-shrink drop yields a telescoping charge between run
starts; no previously established chaining bound is assumed. -/
theorem stageCharge_drop (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h+1) (D c : ℝ)
    (A : ℕ → ℝ) (hA : Antitone A)
    (hdrop : ∀ h k, h+1 ≤ k → s (h+1) = s h → s h+4 ≤ s k →
      (c/64) * nodeWeight s D h ≤ A h - A k) (i : ℕ) :
    (c/64) * stageCharge s hu D i ≤
      A (stageStart s hu i) - A (stageStart s hu (i+4)) := by
  by_cases hlong : stageStart s hu i < stageEnd s hu i
  · rw [stageCharge_eq_last_right s hu hs hs0 hstep D i hlong]
    have he : stageEnd s hu i - 1 + 1 = stageEnd s hu i := by omega
    obtain ⟨hv, hr⟩ := last_right_step s hu hs hs0 hstep i hlong
    have hnext : stageEnd s hu i < stageStart s hu (i+4) := by
      have h₁ := stageEnd_succ s hu hs hs0 hstep i
      have h₂ := stageStart_strictMono s hu hs hs0 hstep (show i+1 < i+4 by omega)
      omega
    have hd := hdrop (stageEnd s hu i - 1) (stageStart s hu (i+4))
      (by omega) (by rwa [he]) (by rw [hv, stageStart_value s hu hs0 hstep])
    have ha := hA (show stageStart s hu i ≤ stageEnd s hu i - 1 by omega)
    linarith
  · rw [stageCharge, if_neg hlong, mul_zero]
    have ha := hA ((stageStart_strictMono s hu hs hs0 hstep).monotone (show i ≤ i+4 by omega))
    linarith

include hu in
/-- Uniform cost of the actual unit-shrink path. The hypotheses describe
only local potential drops and the path itself. -/
theorem shrink_path_budget (hs : Monotone s) (hs0 : s 0 = 0)
    (hstep : ∀ h, s (h+1) ≤ s h+1) {D c B : ℝ} (hD : 0 ≤ D) (hc : 0 < c)
    (A : ℕ → ℝ) (hA : Antitone A) (hAnonneg : ∀ h, 0 ≤ A h) (hA0 : A 0 ≤ B)
    (hdrop : ∀ h k, h+1 ≤ k → s (h+1) = s h → s h+4 ≤ s k →
      (c/64) * nodeWeight s D h ≤ A h - A k) (L : ℕ) :
    (∑ h ∈ Finset.range L, nodeWeight s D h) ≤ 4 * D + 2048 * B / c := by
  apply four_stage_path_budget (fun i => A (stageStart s hu i))
    (stageWeight s hu D) (stageCharge s hu D) D c B _ L
  · intro i; exact hAnonneg _
  · exact hA.comp_monotone (stageStart_strictMono s hu hs hs0 hstep).monotone
  · simpa only [stageStart_zero] using hA0
  · exact stageWeight_nonneg s hu hD
  · exact hD
  · exact hc
  · exact first_stage_budget s hu hs hs0 hstep hD
  · exact stage_weight_step s hu hs hs0 hstep hD
  · intro i hi
    exact stageCharge_drop s hu hs hs0 hstep D c A hA hdrop i
  · exact prefix_cost_le_stages s hu hs hs0 hstep hD L

end NeuralGeneralization.GrowthPath
