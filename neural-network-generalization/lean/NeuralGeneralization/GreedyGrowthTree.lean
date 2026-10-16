import NeuralGeneralization.GreedyGrowthCover
import Mathlib.Data.Finset.Union
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Lean.Elab.Tactic.Omega

/-!
# The actual greedy growth tree

At each node, finitely many greedy balls are the shrinking children and
the unremoved remainder is one additional child. A point follows the
unique child containing it. All cells along its path are nested; a
remainder step strictly decreases cardinality. Consequently every path
eventually reaches a cell of zero pseudometric diameter.
-/

noncomputable section
namespace NeuralGeneralization.GrowthTree
open Classical GrowthCover
open scoped BigOperators
attribute [local instance] Classical.propDecidable

variable {U : Type*} [DecidableEq U]

abbrev State (U : Type*) := Finset U × ℕ

def scale (D : ℝ) (s : State U) : ℝ := D * (1 / 8 : ℝ) ^ s.2

def child (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (h : ℕ) (s : State U) (j : Fin (m h + 1)) : State U :=
  if j.val = 0 then
    (remainder δ (F (h+1)) (scale D s / 4096) (scale D s / 64) x₀ s.1 (m h), s.2)
  else
    (piece δ (F (h+1)) (scale D s / 4096) (scale D s / 64) x₀ s.1 (j.val-1), s.2+1)

theorem child_subset (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (h : ℕ) (s : State U) (j : Fin (m h+1)) :
    (child δ F m D x₀ h s j).1 ⊆ s.1 := by
  unfold child
  split_ifs
  · exact remainder_subset _ _ _ _ _ _ _
  · exact piece_subset _ _ _ _ _ _ _

theorem child_count (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (h : ℕ) (s : State U) (j : Fin (m h+1)) :
    (child δ F m D x₀ h s j).2 = s.2 + if j.val=0 then 0 else 1 := by
  unfold child
  split_ifs <;> simp

theorem child_cover (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (h : ℕ) (s : State U) (x : U) (hx : x ∈ s.1) :
    ∃ j : Fin (m h+1), x ∈ (child δ F m D x₀ h s j).1 := by
  rcases cover δ (F (h+1)) (scale D s/4096) (scale D s/64) x₀ s.1 (m h) x hx with hr | ⟨i, hi, hp⟩
  · exact ⟨⟨0, by omega⟩, by simpa [child] using hr⟩
  · refine ⟨⟨i+1, by omega⟩, ?_⟩
    simpa only [child, Nat.add_eq_zero_iff, Nat.one_ne_zero, and_false, if_false,
      Nat.add_sub_cancel] using hp

def selected (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (h : ℕ) (s : State U) (x : U) : Fin (m h+1) :=
  if hx : x ∈ s.1 then (child_cover δ F m D x₀ h s x hx).choose else ⟨0, by omega⟩

theorem mem_selected (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (h : ℕ) (s : State U) (x : U) (hx : x ∈ s.1) :
    x ∈ (child δ F m D x₀ h s (selected δ F m D x₀ h s x)).1 := by
  simp only [selected, dif_pos hx]
  exact (child_cover δ F m D x₀ h s x hx).choose_spec

def path (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (x : U) : ℕ → State U
  | 0 => (C, 0)
  | h+1 => child δ F m D x₀ h (path δ F m D x₀ C x h)
      (selected δ F m D x₀ h (path δ F m D x₀ C x h) x)

def branch (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (x : U) (h : ℕ) : Fin (m h+1) :=
  selected δ F m D x₀ h (path δ F m D x₀ C x h) x

@[simp] theorem path_zero (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (x : U) : path δ F m D x₀ C x 0 = (C,0) := rfl

theorem path_succ (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (x : U) (h : ℕ) :
    path δ F m D x₀ C x (h+1) =
      child δ F m D x₀ h (path δ F m D x₀ C x h) (branch δ F m D x₀ C x h) := rfl

theorem mem_path (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (x : U) (hx : x ∈ C) (h : ℕ) :
    x ∈ (path δ F m D x₀ C x h).1 := by
  induction h with
  | zero => exact hx
  | succ h ih => exact mem_selected δ F m D x₀ h _ x ih

theorem path_antitone (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (x : U) :
    Antitone (fun h => (path δ F m D x₀ C x h).1) := by
  apply antitone_nat_of_succ_le
  intro h
  exact child_subset _ _ _ _ _ _ _ _

theorem path_count_succ (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (x : U) (h : ℕ) :
    (path δ F m D x₀ C x (h+1)).2 = (path δ F m D x₀ C x h).2 +
      if (branch δ F m D x₀ C x h).val=0 then 0 else 1 := child_count _ _ _ _ _ _ _ _

theorem path_count_monotone (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (x : U) :
    Monotone (fun h => (path δ F m D x₀ C x h).2) := by
  apply monotone_nat_of_le_succ
  intro h
  rw [path_count_succ]
  exact Nat.le_add_right _ _

theorem path_potential_antitone (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ)
    (hmono : ∀ h, Monotone (F h)) (hanti : ∀ C, Antitone (fun h => F h C))
    (m : ℕ → ℕ) (D : ℝ) (x₀ : U) (C : Finset U) (x : U) :
    Antitone (fun h => F h (path δ F m D x₀ C x h).1) := by
  intro h k hk
  exact (hanti (path δ F m D x₀ C x k).1 hk).trans
    (hmono h (path_antitone δ F m D x₀ C x hk))

theorem piece_diameter (δ : U → U → ℝ) (hsymm : ∀ x y, δ x y = δ y x)
    (htri : ∀ x y z, δ x z ≤ 4*(δ x y + δ y z))
    (F : Finset U → ℝ) (ρ R : ℝ) (x₀ : U) (C : Finset U) (n : ℕ)
    {x y : U} (hx : x ∈ piece δ F ρ R x₀ C n) (hy : y ∈ piece δ F ρ R x₀ C n) :
    δ x y ≤ 8*R := by
  have hx' := (Finset.mem_filter.mp hx).2
  have hy' := (Finset.mem_filter.mp hy).2
  have ht := htri x (chosen δ F ρ R x₀ C n) y
  rw [hsymm (chosen δ F ρ R x₀ C n) x] at hx'
  linarith

theorem child_diameter (δ : U → U → ℝ) (hsymm : ∀ x y, δ x y = δ y x)
    (htri : ∀ x y z, δ x z ≤ 4*(δ x y + δ y z))
    (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ) (D : ℝ) (x₀ : U)
    (h : ℕ) (s : State U) (j : Fin (m h+1))
    (hdiam : ∀ x ∈ s.1, ∀ y ∈ s.1, δ x y ≤ scale D s) :
    ∀ x ∈ (child δ F m D x₀ h s j).1,
      ∀ y ∈ (child δ F m D x₀ h s j).1, δ x y ≤ scale D (child δ F m D x₀ h s j) := by
  intro x hx y hy
  unfold child at hx hy ⊢
  split_ifs at hx hy ⊢ with hj
  · exact hdiam x (remainder_subset _ _ _ _ _ _ _ hx) y (remainder_subset _ _ _ _ _ _ _ hy)
  · have hh := piece_diameter δ hsymm htri (F (h+1)) _ _ x₀ s.1 (j.val-1) hx hy
    dsimp only [scale, Prod.snd] at hh ⊢
    rw [pow_succ]
    linarith

theorem path_diameter (δ : U → U → ℝ) (hsymm : ∀ x y, δ x y = δ y x)
    (htri : ∀ x y z, δ x z ≤ 4*(δ x y + δ y z))
    (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ) (D : ℝ) (x₀ : U) (C : Finset U)
    (hdiam : ∀ x ∈ C, ∀ y ∈ C, δ x y ≤ D) (x : U) (h : ℕ) :
    ∀ y ∈ (path δ F m D x₀ C x h).1,
      ∀ z ∈ (path δ F m D x₀ C x h).1, δ y z ≤ scale D (path δ F m D x₀ C x h) := by
  induction h with
  | zero => simpa only [path_zero, scale, pow_zero, mul_one] using hdiam
  | succ h ih => exact child_diameter δ hsymm htri F m D x₀ h _ _ ih

theorem remainder_card_lt (δ : U → U → ℝ) (hdiag : ∀ x, δ x x=0)
    (F : Finset U → ℝ) (ρ R : ℝ) (hR : 0 ≤ R) (x₀ : U) (C : Finset U)
    (hC : C.Nonempty) (m : ℕ) (hm : 0 < m) :
    (remainder δ F ρ R x₀ C m).card < C.card := by
  have hc : chosen δ F ρ R x₀ C 0 ∈ C := chosen_mem _ _ _ _ _ _ hC
  have hp : (piece δ F ρ R x₀ C 0).Nonempty :=
    ⟨chosen δ F ρ R x₀ C 0, Finset.mem_filter.mpr ⟨hc, by rw [hdiag]; exact hR⟩⟩
  have he := Finset.card_sdiff_add_card_eq_card (ball_subset δ C
    (chosen δ F ρ R x₀ C 0) R)
  have hp' := Finset.card_pos.mpr hp
  have hsub : (remainder δ F ρ R x₀ C m).card ≤ (remainder δ F ρ R x₀ C 1).card :=
    Finset.card_le_card (remainder_antitone δ F ρ R x₀ C hm)
  change (remainder δ F ρ R x₀ C 1).card + (piece δ F ρ R x₀ C 0).card = C.card at he
  omega

/-- There can be at most `C.card` nonshrinking edges along a path,
because every such edge removes at least one actual point. -/
theorem path_card_progress (δ : U → U → ℝ) (hdiag : ∀ x, δ x x=0)
    (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ) (hm : ∀ h, 0 < m h)
    (D : ℝ) (hD : 0 ≤ D) (x₀ : U) (C : Finset U) (x : U) (hx : x ∈ C) (h : ℕ) :
    h + (path δ F m D x₀ C x h).1.card ≤ (path δ F m D x₀ C x h).2 + C.card := by
  induction h with
  | zero => simp only [path_zero, zero_add, Prod.fst, Prod.snd, le_refl]
  | succ h ih =>
    have hsub : (path δ F m D x₀ C x (h+1)).1.card ≤ (path δ F m D x₀ C x h).1.card :=
      Finset.card_le_card (path_antitone δ F m D x₀ C x (Nat.le_succ h))
    have hcount := path_count_succ δ F m D x₀ C x h
    by_cases hj : (branch δ F m D x₀ C x h).val=0
    · have hc := remainder_card_lt δ hdiag (F (h+1)) (scale D (path δ F m D x₀ C x h)/4096)
        (scale D (path δ F m D x₀ C x h)/64) (by unfold scale; positivity) x₀
        (path δ F m D x₀ C x h).1 ⟨x, mem_path δ F m D x₀ C x hx h⟩ (m h) (hm h)
      have hnext : (path δ F m D x₀ C x (h+1)).1 =
          remainder δ (F (h+1)) (scale D (path δ F m D x₀ C x h)/4096)
            (scale D (path δ F m D x₀ C x h)/64) x₀ (path δ F m D x₀ C x h).1 (m h) := by
        rw [path_succ, child, if_pos hj]
      rw [← hnext] at hc
      rw [if_pos hj] at hcount
      omega
    · rw [if_neg hj] at hcount
      omega

def levelStates (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) : ℕ → Finset (State U)
  | 0 => {(C,0)}
  | h+1 => (levelStates δ F m D x₀ C h).biUnion
      (fun s => Finset.univ.image (child δ F m D x₀ h s))

theorem path_mem_levelStates (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (x : U) (h : ℕ) :
    path δ F m D x₀ C x h ∈ levelStates δ F m D x₀ C h := by
  induction h with
  | zero => simp [path, levelStates]
  | succ h ih =>
    exact Finset.mem_biUnion.mpr ⟨_, ih, Finset.mem_image.mpr
      ⟨branch δ F m D x₀ C x h, Finset.mem_univ _, rfl⟩⟩

theorem levelStates_card_succ (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (h : ℕ) :
    (levelStates δ F m D x₀ C (h+1)).card ≤ (levelStates δ F m D x₀ C h).card * (m h+1) := by
  apply Finset.card_biUnion_le.trans
  calc
    _ ≤ ∑ _ ∈ levelStates δ F m D x₀ C h, (m h+1) :=
      Finset.sum_le_sum (fun s _ => (Finset.card_image_le).trans_eq (by simp))
    _ = _ := by simp

def branching (h : ℕ) : ℕ := 2 ^ (4 ^ (h+1))

theorem branching_pos (h : ℕ) : 0 < branching h := by unfold branching; positivity

theorem branching_succ_le (h : ℕ) : branching h+1 ≤ 2^(4^(h+1)+1) := by
  have hp : 1 ≤ 2^(4^(h+1)) := Nat.one_le_pow _ _ (by decide)
  unfold branching
  rw [pow_succ 2 (4^(h+1))]
  omega

theorem levelStates_card (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ)
    (D : ℝ) (x₀ : U) (C : Finset U) (h : ℕ) :
    (levelStates δ F branching D x₀ C h).card ≤ 2^(2*4^h) := by
  induction h with
  | zero => norm_num [levelStates]
  | succ h ih =>
    apply (levelStates_card_succ δ F branching D x₀ C h).trans
    calc
      _ ≤ 2^(2*4^h) * 2^(4^(h+1)+1) := Nat.mul_le_mul ih (branching_succ_le h)
      _ = 2^(2*4^h+(4^(h+1)+1)) := (pow_add _ _ _).symm
      _ ≤ 2^(2*4^(h+1)) := by
        apply Nat.pow_le_pow_right (by decide)
        have hp : 1 ≤ 4^h := Nat.one_le_pow _ _ (by decide)
        rw [pow_succ]
        omega

theorem scale_le_of_count_le (D : ℝ) (hD : 0 ≤ D) (s t : State U) (hst : s.2 ≤ t.2) :
    scale D t ≤ scale D s :=
  mul_le_mul_of_nonneg_left (pow_le_pow_of_le_one (by norm_num : (0:ℝ) ≤ 1/8)
    (by norm_num : (1/8:ℝ) ≤ 1) hst) hD

theorem scale_le_four_shrinks (D : ℝ) (hD : 0 ≤ D) (s t : State U) (hst : s.2+4 ≤ t.2) :
    scale D t ≤ scale D s/4096 := by
  have hh := scale_le_of_count_le D hD (s.1,s.2+4) t hst
  dsimp only [scale, Prod.snd] at hh ⊢
  rw [pow_add] at hh
  norm_num at hh
  linarith

theorem path_count_tendsto (δ : U → U → ℝ) (hdiag : ∀ x, δ x x=0)
    (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ) (hm : ∀ h, 0 < m h)
    (D : ℝ) (hD : 0 ≤ D) (x₀ : U) (C : Finset U) (x : U) (hx : x ∈ C) :
    Filter.Tendsto (fun h => (path δ F m D x₀ C x h).2) Filter.atTop Filter.atTop := by
  apply Filter.tendsto_atTop.mpr
  intro b
  apply Filter.eventually_atTop.mpr
  refine ⟨b+C.card, ?_⟩
  intro h hh
  have hp := path_card_progress δ hdiag F m hm D hD x₀ C x hx h
  omega

theorem path_scale_tendsto (δ : U → U → ℝ) (hdiag : ∀ x, δ x x=0)
    (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ) (hm : ∀ h, 0 < m h)
    (D : ℝ) (hD : 0 ≤ D) (x₀ : U) (C : Finset U) (x : U) (hx : x ∈ C) :
    Filter.Tendsto (fun h => scale D (path δ F m D x₀ C x h)) Filter.atTop (nhds 0) := by
  have hh := (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num : (0:ℝ) ≤ 1/8)
    (by norm_num : (1/8:ℝ)<1)).comp (path_count_tendsto δ hdiag F m hm D hD x₀ C x hx)
  simpa only [scale, Function.comp_def, mul_zero] using hh.const_mul D

def representative (x₀ : U) (h : ℕ) (s : State U) : U :=
  if h=0 then x₀ else if hs : s.1.Nonempty then hs.choose else x₀

theorem representative_mem (x₀ : U) (h : ℕ) (s : State U) (hs : s.1.Nonempty)
    (hzero : h=0 → x₀ ∈ s.1) : representative x₀ h s ∈ s.1 := by
  unfold representative
  split_ifs with hh
  · exact hzero hh
  · exact hs.choose_spec

def approximation (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (h : ℕ) (x : U) : U :=
  representative x₀ h (path δ F m D x₀ C x h)

@[simp] theorem approximation_zero (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (x : U) : approximation δ F m D x₀ C 0 x = x₀ := by
  simp [approximation, representative]

theorem approximation_mem_path (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (hroot : x₀ ∈ C) (h : ℕ) (x : U) (hx : x ∈ C) :
    approximation δ F m D x₀ C h x ∈ (path δ F m D x₀ C x h).1 := by
  apply representative_mem x₀ h _ ⟨x, mem_path δ F m D x₀ C x hx h⟩
  rintro rfl
  exact hroot

theorem approximation_increment (δ : U → U → ℝ) (hsymm : ∀ x y, δ x y = δ y x)
    (htri : ∀ x y z, δ x z ≤ 4*(δ x y + δ y z))
    (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ) (D : ℝ) (x₀ : U) (C : Finset U)
    (hdiam : ∀ x ∈ C, ∀ y ∈ C, δ x y ≤ D) (hroot : x₀ ∈ C)
    (h : ℕ) (x : U) (hx : x ∈ C) :
    δ (approximation δ F m D x₀ C (h+1) x) (approximation δ F m D x₀ C h x) ≤
      scale D (path δ F m D x₀ C x h) := by
  apply path_diameter δ hsymm htri F m D x₀ C hdiam x h
  · exact path_antitone δ F m D x₀ C x (Nat.le_succ h)
      (approximation_mem_path δ F m D x₀ C hroot (h+1) x hx)
  · exact approximation_mem_path δ F m D x₀ C hroot h x hx

/-- On a finite set the approximation is eventually exactly equal in
the pseudometric, without requiring that zero distance identify points. -/
theorem approximation_eventually_zero (δ : U → U → ℝ) (hnonneg : ∀ x y, 0 ≤ δ x y)
    (hdiag : ∀ x, δ x x=0) (hsymm : ∀ x y, δ x y = δ y x)
    (htri : ∀ x y z, δ x z ≤ 4*(δ x y + δ y z))
    (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ) (hm : ∀ h, 0 < m h)
    (D : ℝ) (hD : 0 ≤ D) (x₀ : U) (C : Finset U)
    (hdiam : ∀ x ∈ C, ∀ y ∈ C, δ x y ≤ D) (hroot : x₀ ∈ C) :
    ∀ᶠ h in Filter.atTop, ∀ x ∈ C, δ (approximation δ F m D x₀ C h x) x = 0 := by
  apply (Filter.eventually_all_finset C).mpr
  intro x hx
  have hh : ∀ᶠ h in Filter.atTop, ∀ y ∈ C,
      0 < δ y x → scale D (path δ F m D x₀ C x h) < δ y x := by
    apply (Filter.eventually_all_finset C).mpr
    intro y hy
    by_cases hp : 0 < δ y x
    · exact ((path_scale_tendsto δ hdiag F m hm D hD x₀ C x hx).eventually
        (gt_mem_nhds hp)).mono (fun h hh _ => hh)
    · exact Filter.Eventually.of_forall (fun _ hh => False.elim (hp hh))
  filter_upwards [hh] with h hh
  have ha := approximation_mem_path δ F m D x₀ C hroot h x hx
  have hac : approximation δ F m D x₀ C h x ∈ C :=
    path_antitone δ F m D x₀ C x (Nat.zero_le h) ha
  have hd := path_diameter δ hsymm htri F m D x₀ C hdiam x h _ ha _ (mem_path δ F m D x₀ C x hx h)
  by_contra hne
  have hp := lt_of_le_of_ne (hnonneg _ _) (Ne.symm hne)
  exact (not_lt_of_ge hd) (hh _ hac hp)

/-- The geometric charging statement for an actual remainder edge and
any descendant at least four shrinking steps later. -/
theorem path_remainder_growth_drop (δ : U → U → ℝ) (hdiag : ∀ x, δ x x=0)
    (hsymm : ∀ x y, δ x y = δ y x) (htri : ∀ x y z, δ x z ≤ 4*(δ x y+δ y z))
    (F : ℕ → Finset U → ℝ) (hmono : ∀ h, Monotone (F h))
    (hanti : ∀ C, Antitone (fun h => F h C)) (m : ℕ → ℕ) (c : ℝ) (w : ℕ → ℝ)
    (hgrowth : ∀ h, GrowthAt δ (F (h+1)) (F h) (m h) c (w h))
    (D : ℝ) (hD : 0 < D) (x₀ : U) (C : Finset U)
    (hdiam : ∀ x ∈ C, ∀ y ∈ C, δ x y ≤ D) (x : U) (hx : x ∈ C)
    (h k : ℕ) (hk : h+1 ≤ k) (hright : (branch δ F m D x₀ C x h).val=0)
    (hfour : (path δ F m D x₀ C x h).2+4 ≤ (path δ F m D x₀ C x k).2) :
    (c/64)*(w h*scale D (path δ F m D x₀ C x h)) ≤
      F h (path δ F m D x₀ C x h).1 - F k (path δ F m D x₀ C x k).1 := by
  have hnext : (path δ F m D x₀ C x (h+1)).1 =
      remainder δ (F (h+1)) (scale D (path δ F m D x₀ C x h)/4096)
        (scale D (path δ F m D x₀ C x h)/64) x₀ (path δ F m D x₀ C x h).1 (m h) := by
    rw [path_succ, child, if_pos hright]
  have hsub : (path δ F m D x₀ C x k).1 ⊆ (path δ F m D x₀ C x (h+1)).1 :=
    path_antitone δ F m D x₀ C x hk
  rw [hnext] at hsub
  have hR : 0 < scale D (path δ F m D x₀ C x h)/64 := by unfold scale; positivity
  have hrad : scale D (path δ F m D x₀ C x h)/64/64 =
      scale D (path δ F m D x₀ C x h)/4096 := by ring
  have hg := remainder_growth_drop δ hdiag hsymm (F (h+1)) (F h) (hmono (h+1))
    (m h) c (w h) (hgrowth h) (scale D (path δ F m D x₀ C x h)/64) hR x₀
    (path δ F m D x₀ C x h).1 (path δ F m D x₀ C x k).1
    (by simpa only [mul_div_cancel₀ _ (by norm_num : (64:ℝ)≠0)] using
      path_diameter δ hsymm htri F m D x₀ C hdiam x h)
    (by simpa only [hrad] using hsub) x (mem_path δ F m D x₀ C x hx k)
    (fun y hy => (path_diameter δ hsymm htri F m D x₀ C hdiam x k x
      (mem_path δ F m D x₀ C x hx k) y hy).trans (by
        rw [hrad]
        exact scale_le_four_shrinks D hD.le _ _ hfour))
  have ha := hanti (path δ F m D x₀ C x k).1 hk
  nlinarith only [hg, ha]

def possibleEdges (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (h : ℕ) : Finset (U × U) :=
  (levelStates δ F m D x₀ C h).biUnion (fun s => Finset.univ.image
    (fun j => (representative x₀ (h+1) (child δ F m D x₀ h s j), representative x₀ h s)))

def edgeSet (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (h : ℕ) : Finset (U × U) :=
  C.image (fun x => (approximation δ F m D x₀ C (h+1) x, approximation δ F m D x₀ C h x))

theorem edgeSet_subset (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (h : ℕ) :
    edgeSet δ F m D x₀ C h ⊆ possibleEdges δ F m D x₀ C h := by
  intro e he
  obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp he
  exact Finset.mem_biUnion.mpr ⟨_, path_mem_levelStates δ F m D x₀ C x h,
    Finset.mem_image.mpr ⟨branch δ F m D x₀ C x h, Finset.mem_univ _, rfl⟩⟩

theorem possibleEdges_card (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ) (m : ℕ → ℕ)
    (D : ℝ) (x₀ : U) (C : Finset U) (h : ℕ) :
    (possibleEdges δ F m D x₀ C h).card ≤ (levelStates δ F m D x₀ C h).card*(m h+1) := by
  apply Finset.card_biUnion_le.trans
  calc
    _ ≤ ∑ _ ∈ levelStates δ F m D x₀ C h, (m h+1) :=
      Finset.sum_le_sum (fun s _ => (Finset.card_image_le).trans_eq (by simp))
    _ = _ := by simp

/-- The actual approximation edges have the admissible double-exponential
cardinality, with one absolute numerical constant. -/
theorem edgeSet_card (δ : U → U → ℝ) (F : ℕ → Finset U → ℝ)
    (D : ℝ) (x₀ : U) (C : Finset U) (h : ℕ) :
    (edgeSet δ F branching D x₀ C h).card ≤ 2^(8*4^h) := by
  apply (Finset.card_le_card (edgeSet_subset δ F branching D x₀ C h)).trans
  apply (possibleEdges_card δ F branching D x₀ C h).trans
  calc
    _ ≤ 2^(2*4^h)*2^(4^(h+1)+1) :=
      Nat.mul_le_mul (levelStates_card δ F D x₀ C h) (branching_succ_le h)
    _ = 2^(2*4^h+(4^(h+1)+1)) := (pow_add _ _ _).symm
    _ ≤ 2^(8*4^h) := by
      apply Nat.pow_le_pow_right (by decide)
      have hp : 1 ≤ 4^h := Nat.one_le_pow _ _ (by decide)
      rw [pow_succ]
      omega

end NeuralGeneralization.GrowthTree
