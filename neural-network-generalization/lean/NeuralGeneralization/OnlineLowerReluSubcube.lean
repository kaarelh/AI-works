import NeuralGeneralization.OnlineLowerReluMonotone
import Mathlib.Algebra.BigOperators.Group.Finset.Powerset

/-! # Exact coordinate elimination and sharp bounds on selected subcubes -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

theorem sum_subsets_eq_subtype_sum {α : Type*} [DecidableEq α]
    (s : Finset α) (f : Finset α → ℝ) :
    (∑ T ∈ s.powerset, f T) = ∑ U : Finset {i // i ∈ s}, f (U.image Subtype.val) := by
  classical
  symm
  apply Finset.sum_bij (fun U _ => U.image Subtype.val)
  · intro U _
    apply Finset.mem_powerset.mpr
    intro i hi
    obtain ⟨j, _, rfl⟩ := Finset.mem_image.mp hi
    exact j.property
  · intro U _ V _ h
    exact Finset.image_injective (fun _ _ h => Subtype.ext h) h
  · intro T hT
    have hTs := Finset.mem_powerset.mp hT
    refine ⟨T.subtype (fun i => i ∈ s), Finset.mem_univ _, ?_⟩
    ext i
    simp only [Finset.mem_image, Finset.mem_subtype]
    constructor
    · rintro ⟨j, hj, rfl⟩
      exact hj
    · intro hi
      exact ⟨⟨i, hTs hi⟩, hi, rfl⟩
  · intro U _
    rfl

theorem monotone_subcube_parity_bound {α : Type*} [DecidableEq α]
    (s : Finset α) (n : ℕ) (hcard : s.card = n + 1)
    (f : Finset α → ℝ) (hmono : Monotone f)
    (hzero : ∀ S, 0 ≤ f S) (hone : ∀ S, f S ≤ 1) :
    |∑ S ∈ s.powerset, (-1 : ℝ) ^ S.card * f S| ≤ (n.choose (n / 2) : ℝ) := by
  classical
  rw [sum_subsets_eq_subtype_sum]
  simp_rw [Finset.card_image_of_injective _ Subtype.val_injective]
  apply monotone_fintype_subset_parity_bound n
  · simpa using hcard
  · intro U V h
    exact hmono (Finset.image_subset_image h)
  · intro U
    exact hzero _
  · intro U
    exact hone _

/-- Removing one coordinate from a top-parity coefficient is exactly a
finite derivative, before any inequality is applied. -/
theorem parity_sum_insert_coordinate {α : Type*} [DecidableEq α]
    (s : Finset α) (j : α) (hj : j ∉ s) (f : Finset α → ℝ) :
    (∑ S ∈ (insert j s).powerset, (-1 : ℝ) ^ S.card * f S) =
      ∑ S ∈ s.powerset, (-1 : ℝ) ^ S.card * (f S - f (insert j S)) := by
  rw [Finset.sum_powerset_insert hj]
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro S hS
  have hjS : j ∉ S := fun h => hj ((Finset.mem_powerset.mp hS) h)
  rw [Finset.card_insert_of_notMem hjS, pow_succ]
  ring

/-- A monotone remaining score and an exactly linear distinguished bit
give the sharp ReLU top-parity estimate on a literal selected subcube. -/
theorem subcube_relu_parity_bound {α : Type*} [DecidableEq α]
    (s : Finset α) (j : α) (hj : j ∉ s) (n : ℕ) (hcard : s.card = n + 1)
    (score : Finset α → ℝ) (hmono : Monotone score) (d : ℝ) (hd : 0 ≤ d)
    (hstep : ∀ S ⊆ s, score (insert j S) = score S + 2 * d) :
    |(∑ S ∈ (insert j s).powerset, (-1 : ℝ) ^ S.card * max (score S) 0) /
        (2 : ℝ) ^ (n + 2)| ≤ d * (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) := by
  classical
  have heq : (∑ S ∈ (insert j s).powerset,
      (-1 : ℝ) ^ S.card * max (score S) 0) =
      -(∑ S ∈ s.powerset, (-1 : ℝ) ^ S.card * reluDifference d (score S + d)) := by
    rw [parity_sum_insert_coordinate s j hj]
    rw [← Finset.sum_neg_distrib]
    apply Finset.sum_congr rfl
    intro S hS
    rw [hstep S (Finset.mem_powerset.mp hS)]
    unfold reluDifference
    ring_nf
  rw [heq, neg_div, abs_neg]
  rcases hd.eq_or_lt with h | h
  · subst d
    simp [reluDifference]
  let f : Finset α → ℝ := fun S => reluDifference d (score S + d) / (2 * d)
  obtain ⟨hmonod, hrange⟩ := normalized_reluDifference_properties h
  have hfmono : Monotone f := by
    intro S T hST
    apply hmonod
    have := hmono hST
    linarith
  have hbound := monotone_subcube_parity_bound s n hcard f hfmono
    (fun S => (hrange _).1) (fun S => (hrange _).2)
  have hfactor : (∑ S ∈ s.powerset, (-1 : ℝ) ^ S.card *
      reluDifference d (score S + d)) =
      2 * d * ∑ S ∈ s.powerset, (-1 : ℝ) ^ S.card * f S := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro S _
    dsimp [f]
    field_simp [h.ne']
  rw [hfactor, abs_div, abs_mul,
    abs_of_pos (by positivity : (0 : ℝ) < 2 * d),
    abs_of_pos (by positivity : (0 : ℝ) < 2 ^ (n + 2))]
  calc
    2 * d * |∑ S ∈ s.powerset, (-1 : ℝ) ^ S.card * f S| / (2 : ℝ) ^ (n + 2) ≤
      2 * d * (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 2) := by
        exact div_le_div_of_nonneg_right
          (mul_le_mul_of_nonneg_left hbound (by positivity)) (by positivity)
    _ = _ := by
      rw [show n + 2 = (n + 1) + 1 by omega, pow_succ]
      field_simp

end NeuralGeneralization.OnlineLowerRelu
