import Mathlib.Data.Finset.Max
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# Finite greedy covers for the growth-functional method

The selected centers maximize a local potential on the points not yet
removed. Coarse balls are removed, while smaller balls witness the growth
of the potential. A remaining small set is dominated by every selected
local potential. These are finite constructions, not covering assumptions.
-/
noncomputable section
namespace NeuralGeneralization.GrowthCover
open Classical
attribute [local instance] Classical.propDecidable

variable {U : Type*} [DecidableEq U]

def ball (δ : U → U → ℝ) (C : Finset U) (x : U) (r : ℝ) : Finset U :=
  C.filter (fun y => δ x y ≤ r)

@[simp] theorem mem_ball (δ : U → U → ℝ) (C : Finset U) (x y : U) (r : ℝ) :
    y ∈ ball δ C x r ↔ y ∈ C ∧ δ x y ≤ r := Finset.mem_filter

theorem ball_subset (δ : U → U → ℝ) (C : Finset U) (x : U) (r : ℝ) :
    ball δ C x r ⊆ C := Finset.filter_subset _ _

theorem ball_mono (δ : U → U → ℝ) {C D : Finset U} (h : C ⊆ D)
    (x : U) {r s : ℝ} (hrs : r ≤ s) : ball δ C x r ⊆ ball δ D x s := by
  intro y hy
  exact Finset.mem_filter.mpr ⟨h (Finset.mem_filter.mp hy).1, (Finset.mem_filter.mp hy).2.trans hrs⟩

def center (δ : U → U → ℝ) (F : Finset U → ℝ) (ρ : ℝ) (x₀ : U)
    (C : Finset U) : U :=
  if h : C.Nonempty then Classical.choose (C.exists_max_image (fun x => F (ball δ C x ρ)) h)
  else x₀

theorem center_mem (δ : U → U → ℝ) (F : Finset U → ℝ) (ρ : ℝ) (x₀ : U)
    (C : Finset U) (h : C.Nonempty) : center δ F ρ x₀ C ∈ C := by
  simp only [center, dif_pos h]
  exact (Classical.choose_spec (C.exists_max_image (fun x => F (ball δ C x ρ)) h)).1

theorem center_max (δ : U → U → ℝ) (F : Finset U → ℝ) (ρ : ℝ) (x₀ : U)
    (C : Finset U) (x : U) (hx : x ∈ C) :
    F (ball δ C x ρ) ≤ F (ball δ C (center δ F ρ x₀ C) ρ) := by
  have h : C.Nonempty := ⟨x, hx⟩
  simp only [center, dif_pos h]
  exact (Classical.choose_spec (C.exists_max_image (fun x => F (ball δ C x ρ)) h)).2 x hx

def remainder (δ : U → U → ℝ) (F : Finset U → ℝ) (ρ R : ℝ) (x₀ : U)
    (C : Finset U) : ℕ → Finset U
  | 0 => C
  | n + 1 => let D := remainder δ F ρ R x₀ C n
      D \ ball δ D (center δ F ρ x₀ D) R

def chosen (δ : U → U → ℝ) (F : Finset U → ℝ) (ρ R : ℝ) (x₀ : U)
    (C : Finset U) (n : ℕ) : U := center δ F ρ x₀ (remainder δ F ρ R x₀ C n)

def piece (δ : U → U → ℝ) (F : Finset U → ℝ) (ρ R : ℝ) (x₀ : U)
    (C : Finset U) (n : ℕ) : Finset U :=
  ball δ (remainder δ F ρ R x₀ C n) (chosen δ F ρ R x₀ C n) R

def core (δ : U → U → ℝ) (F : Finset U → ℝ) (ρ R : ℝ) (x₀ : U)
    (C : Finset U) (n : ℕ) : Finset U :=
  ball δ (remainder δ F ρ R x₀ C n) (chosen δ F ρ R x₀ C n) ρ

@[simp] theorem remainder_zero (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) : remainder δ F ρ R x₀ C 0 = C := rfl

theorem remainder_succ (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) (n : ℕ) :
    remainder δ F ρ R x₀ C (n+1) = remainder δ F ρ R x₀ C n \ piece δ F ρ R x₀ C n := rfl

theorem remainder_antitone (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) : Antitone (remainder δ F ρ R x₀ C) := by
  apply antitone_nat_of_succ_le
  intro n
  exact Finset.sdiff_subset

theorem remainder_subset (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) (n : ℕ) : remainder δ F ρ R x₀ C n ⊆ C :=
  remainder_antitone δ F ρ R x₀ C (Nat.zero_le n)

theorem piece_subset (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) (n : ℕ) : piece δ F ρ R x₀ C n ⊆ C :=
  (ball_subset _ _ _ _).trans (remainder_subset δ F ρ R x₀ C n)

theorem core_subset (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) (n : ℕ) : core δ F ρ R x₀ C n ⊆ C :=
  (ball_subset _ _ _ _).trans (remainder_subset δ F ρ R x₀ C n)

theorem remainder_disjoint_piece (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) {i j : ℕ} (hij : i < j) :
    Disjoint (remainder δ F ρ R x₀ C j) (piece δ F ρ R x₀ C i) := by
  apply Finset.disjoint_left.mpr
  intro x hx hp
  have hs := remainder_antitone δ F ρ R x₀ C (Nat.succ_le_iff.mpr hij) hx
  rw [remainder_succ] at hs
  exact (Finset.mem_sdiff.mp hs).2 hp

theorem piece_pairwise_disjoint (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) : Pairwise (fun i j => Disjoint (piece δ F ρ R x₀ C i) (piece δ F ρ R x₀ C j)) := by
  intro i j hij
  rcases lt_or_gt_of_ne hij with hij | hji
  · exact (remainder_disjoint_piece δ F ρ R x₀ C hij).symm.mono_right (ball_subset _ _ _ _)
  · exact (remainder_disjoint_piece δ F ρ R x₀ C hji).mono_left (ball_subset _ _ _ _)

theorem chosen_mem (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) {n : ℕ}
    (hn : (remainder δ F ρ R x₀ C n).Nonempty) :
    chosen δ F ρ R x₀ C n ∈ remainder δ F ρ R x₀ C n := center_mem _ _ _ _ _ hn

theorem chosen_separated (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) {i j : ℕ} (hij : i < j)
    (hj : (remainder δ F ρ R x₀ C j).Nonempty) :
    R < δ (chosen δ F ρ R x₀ C i) (chosen δ F ρ R x₀ C j) := by
  have hx := chosen_mem δ F ρ R x₀ C hj
  have hn := Finset.disjoint_left.mp (remainder_disjoint_piece δ F ρ R x₀ C hij) hx
  have hi := remainder_antitone δ F ρ R x₀ C hij.le hx
  exact lt_of_not_ge (fun hh => hn (Finset.mem_filter.mpr ⟨hi, hh⟩))

theorem core_potential_antitone (δ : U → U → ℝ) (F : Finset U → ℝ)
    (hF : Monotone F) (ρ R : ℝ) (x₀ : U) (C : Finset U) {i j : ℕ}
    (hij : i ≤ j) (hj : (remainder δ F ρ R x₀ C j).Nonempty) :
    F (core δ F ρ R x₀ C j) ≤ F (core δ F ρ R x₀ C i) := by
  have hs := remainder_antitone δ F ρ R x₀ C hij
  have hx := hs (chosen_mem δ F ρ R x₀ C hj)
  exact (hF (ball_mono δ hs _ le_rfl)).trans (center_max δ F ρ x₀ _ _ hx)

/-- Every nonempty small descendant in the final remainder has potential
at most each earlier greedy core. -/
theorem descendant_potential_le (δ : U → U → ℝ) (F : Finset U → ℝ)
    (hF : Monotone F) (ρ R : ℝ) (x₀ : U) (C J : Finset U) {i n : ℕ}
    (hin : i ≤ n) (hJ : J ⊆ remainder δ F ρ R x₀ C n)
    (z : U) (hz : z ∈ J) (hsmall : ∀ y ∈ J, δ z y ≤ ρ) :
    F J ≤ F (core δ F ρ R x₀ C i) := by
  have hs := hJ.trans (remainder_antitone δ F ρ R x₀ C hin)
  have hb : J ⊆ ball δ (remainder δ F ρ R x₀ C i) z ρ :=
    fun y hy => Finset.mem_filter.mpr ⟨hs hy, hsmall y hy⟩
  exact (hF hb).trans (center_max δ F ρ x₀ _ z (hs hz))

/-- The first n pieces and the remainder cover the original finite set. -/
theorem cover (δ : U → U → ℝ) (F : Finset U → ℝ)
    (ρ R : ℝ) (x₀ : U) (C : Finset U) (n : ℕ) (x : U) (hx : x ∈ C) :
    x ∈ remainder δ F ρ R x₀ C n ∨ ∃ i < n, x ∈ piece δ F ρ R x₀ C i := by
  induction n with
  | zero => exact Or.inl hx
  | succ n ih =>
    rcases ih with hn | ⟨i, hi, hix⟩
    · by_cases hp : x ∈ piece δ F ρ R x₀ C n
      · exact Or.inr ⟨n, Nat.lt_succ_self _, hp⟩
      · exact Or.inl (Finset.mem_sdiff.mpr ⟨hn, hp⟩)
    · exact Or.inr ⟨i, hi.trans (Nat.lt_succ_self n), hix⟩

/-- If a nonempty remainder survives all `m` centers, each center lies
in its local core and the centers form a genuinely separated family. -/
theorem cores_valid (δ : U → U → ℝ) (hdiag : ∀ x, δ x x = 0)
    (hsymm : ∀ x y, δ x y = δ y x) (F : Finset U → ℝ)
    (ρ R : ℝ) (hρ : 0 ≤ ρ) (x₀ : U) (C : Finset U) (m : ℕ)
    (hm : (remainder δ F ρ R x₀ C m).Nonempty) :
    (∀ i : Fin m, chosen δ F ρ R x₀ C i ∈ core δ F ρ R x₀ C i) ∧
    (∀ i j : Fin m, i ≠ j → R < δ (chosen δ F ρ R x₀ C i) (chosen δ F ρ R x₀ C j)) := by
  have hne (i : Fin m) : (remainder δ F ρ R x₀ C i).Nonempty :=
    hm.mono (remainder_antitone δ F ρ R x₀ C i.isLt.le)
  constructor
  · intro i
    exact Finset.mem_filter.mpr ⟨chosen_mem δ F ρ R x₀ C (hne i), by rw [hdiag]; exact hρ⟩
  · intro i j hij
    rcases lt_or_gt_of_ne (Fin.val_ne_of_ne hij) with hij | hji
    · exact chosen_separated δ F ρ R x₀ C hij (hne j)
    · rw [hsymm]
      exact chosen_separated δ F ρ R x₀ C hji (hne i)

/-- A finite growth condition in a lower-bound formulation, avoiding an
arbitrary convention for the minimum of an empty family. -/
def GrowthAt (δ : U → U → ℝ) (F G : Finset U → ℝ) (m : ℕ)
    (c w : ℝ) : Prop :=
  ∀ (C : Finset U) (a : ℝ), 0 < a →
    ∀ (x : Fin m → U) (H : Fin m → Finset U),
      (∀ i, x i ∈ H i) → (∀ i, H i ⊆ C) →
      (∀ i y, y ∈ H i → δ (x i) y ≤ a / 64) →
      (∀ i j, i ≠ j → a ≤ δ (x i) (x j) ∧ δ (x i) (x j) ≤ 64 * a) →
      ∀ t : ℝ, (∀ i, t ≤ F (H i)) → c * a * w + t ≤ G C

/-- The key greedy growth drop. A small descendant in the unremoved
remainder forces a definite loss of potential in its parent. -/
theorem remainder_growth_drop (δ : U → U → ℝ)
    (hdiag : ∀ x, δ x x = 0) (hsymm : ∀ x y, δ x y = δ y x)
    (F G : Finset U → ℝ) (hF : Monotone F) (m : ℕ) (c w : ℝ)
    (hgrowth : GrowthAt δ F G m c w) (R : ℝ) (hR : 0 < R)
    (x₀ : U) (C J : Finset U)
    (hdiam : ∀ x ∈ C, ∀ y ∈ C, δ x y ≤ 64 * R)
    (hJ : J ⊆ remainder δ F (R / 64) R x₀ C m)
    (z : U) (hz : z ∈ J) (hsmall : ∀ y ∈ J, δ z y ≤ R / 64) :
    c * R * w + F J ≤ G C := by
  have hm : (remainder δ F (R / 64) R x₀ C m).Nonempty := ⟨z, hJ hz⟩
  obtain ⟨hcenters, hsep⟩ := cores_valid δ hdiag hsymm F (R / 64) R
    (by positivity) x₀ C m hm
  apply hgrowth C R hR (fun i => chosen δ F (R / 64) R x₀ C i)
    (fun i => core δ F (R / 64) R x₀ C i) hcenters
    (fun i => core_subset _ _ _ _ _ _ _) (fun i y hy => (Finset.mem_filter.mp hy).2)
  · intro i j hij
    exact ⟨(hsep i j hij).le, hdiam _ (core_subset _ _ _ _ _ _ _ (hcenters i))
      _ (core_subset _ _ _ _ _ _ _ (hcenters j))⟩
  · intro i
    exact descendant_potential_le δ F hF _ _ x₀ C J i.isLt.le hJ z hz hsmall

end NeuralGeneralization.GrowthCover
