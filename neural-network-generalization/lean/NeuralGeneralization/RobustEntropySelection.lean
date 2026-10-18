import NeuralGeneralization.RobustEntropyChain
import Mathlib.Data.Finset.Max

/-! # Measurable finite selection of entropy-revealing inputs

Maximize the potential `E(S) - δ |S|` over the finite input subsets.
This gives the same stopping and rank properties as greedy querying, while
making parameter measurability explicit. The entropy identities used to
instantiate `E` are separate measure-theoretic statements.
-/

noncomputable section
open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.RobustEntropySelection

def bestFold {I : Type*} (s : List I) (a : I) (F : I → ℝ) : I :=
  match s with
  | [] => a
  | b :: t => if F (bestFold t a F) ≤ F b then b else bestFold t a F

theorem bestFold_ge_default {I : Type*} (s : List I) (a : I) (F : I → ℝ) :
    F a ≤ F (bestFold s a F) := by
  induction s with
  | nil => exact le_rfl
  | cons b t ih =>
    simp only [bestFold]
    split_ifs with h
    · exact ih.trans h
    · exact ih

theorem bestFold_ge_mem {I : Type*} (s : List I) (a : I) (F : I → ℝ)
    (b : I) (hb : b ∈ s) : F b ≤ F (bestFold s a F) := by
  induction s with
  | nil => simp at hb
  | cons c t ih =>
    simp only [List.mem_cons] at hb
    simp only [bestFold]
    split_ifs with h
    · rcases hb with rfl | hb
      · exact le_rfl
      · exact (ih hb).trans h
    · rcases hb with rfl | hb
      · exact (lt_of_not_ge h).le
      · exact ih hb

theorem measurable_bestFold {I Ω : Type*} [MeasurableSpace I] [MeasurableSpace Ω]
    (s : List I) (a : I) (F : I → Ω → ℝ) (hF : ∀ i, Measurable (F i)) :
    Measurable (fun ω => bestFold s a (fun i => F i ω)) ∧
      Measurable (fun ω => F (bestFold s a (fun i => F i ω)) ω) := by
  classical
  induction s with
  | nil => exact ⟨measurable_const, hF a⟩
  | cons b t ih =>
    have hset : MeasurableSet {ω | F (bestFold t a (fun i => F i ω)) ω ≤ F b ω} :=
      measurableSet_le ih.2 (hF b)
    constructor
    · exact Measurable.ite hset measurable_const ih.1
    · have hh : Measurable (fun ω => if F (bestFold t a (fun i => F i ω)) ω ≤ F b ω
          then F b ω else F (bestFold t a (fun i => F i ω)) ω) :=
        Measurable.ite hset (hF b) ih.2
      convert hh using 1
      funext ω
      simp only [bestFold]
      split_ifs <;> rfl

def selectedSet {I Ω : Type*} [Fintype I] [DecidableEq I]
    (E : Finset I → Ω → ℝ) (δ : ℝ) (ω : Ω) : Finset I :=
  bestFold (Finset.univ : Finset (Finset I)).toList ∅
    (fun S => E S ω - δ * S.card)

theorem selectedSet_potential_max {I Ω : Type*} [Fintype I] [DecidableEq I]
    (E : Finset I → Ω → ℝ) (δ : ℝ) (ω : Ω) (S : Finset I) :
    E S ω - δ * S.card ≤
      E (selectedSet E δ ω) ω - δ * (selectedSet E δ ω).card := by
  exact bestFold_ge_mem (Finset.univ : Finset (Finset I)).toList ∅
    (fun T => E T ω - δ * T.card) S (by simp)

theorem measurable_selectedSet {I Ω : Type*} [Fintype I] [DecidableEq I]
    [MeasurableSpace Ω] [MeasurableSpace (Finset I)]
    (E : Finset I → Ω → ℝ) (hE : ∀ S, Measurable (E S)) (δ : ℝ) :
    Measurable (selectedSet E δ) := by
  exact (measurable_bestFold _ ∅ (fun S ω => E S ω - δ * S.card)
    (fun S => (hE S).sub measurable_const)).1

theorem selectedSet_card_budget {I Ω : Type*} [Fintype I] [DecidableEq I]
    (E : Finset I → Ω → ℝ) (δ : ℝ) (ω : Ω) (R : ℝ)
    (h0 : 0 ≤ E ∅ ω) (hR : ∀ S, E S ω ≤ R) :
    δ * (selectedSet E δ ω).card ≤ R := by
  have h := selectedSet_potential_max E δ ω ∅
  simp only [Finset.card_empty, Nat.cast_zero, mul_zero, sub_zero] at h
  linarith [hR (selectedSet E δ ω)]

theorem selectedSet_increment_le {I Ω : Type*} [Fintype I] [DecidableEq I]
    (E : Finset I → Ω → ℝ) (δ : ℝ) (hδ : 0 ≤ δ) (ω : Ω) (i : I) :
    E (insert i (selectedSet E δ ω)) ω - E (selectedSet E δ ω) ω ≤ δ := by
  by_cases hi : i ∈ selectedSet E δ ω
  · simp only [Finset.insert_eq_of_mem hi, sub_self]
    exact hδ
  · have h := selectedSet_potential_max E δ ω (insert i (selectedSet E δ ω))
    rw [Finset.card_insert_of_notMem hi, Nat.cast_add, Nat.cast_one] at h
    nlinarith

end NeuralGeneralization.RobustEntropySelection
