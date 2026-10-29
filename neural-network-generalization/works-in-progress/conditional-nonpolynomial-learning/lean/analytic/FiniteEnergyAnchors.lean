import NeuralGeneralization.RobustEntropyChain
import Mathlib.Data.Finset.Max
import Mathlib.Data.Finset.Powerset
import Mathlib.Tactic.Linarith

noncomputable section
open scoped BigOperators
namespace ConditionalAnalytic

variable {X : Type*} [Fintype X] [DecidableEq X]

/-- A finite penalized maximizer supplies all small marginal increments at
once. No algorithmic assumption is needed in this nonuniform construction. -/
theorem finite_energy_anchors (energy : Finset X → ℝ) (δ A : ℝ)
    (hδ : 0 < δ) (hzero : 0 ≤ energy ∅) (hbound : ∀ S, energy S ≤ A) :
    ∃ S : Finset X, δ*S.card ≤ A ∧
      ∀ x, energy (insert x S)-energy S ≤ δ := by
  classical
  let score : Finset X → ℝ := fun S => energy S-δ*S.card
  obtain ⟨S,hS,hmax⟩ := (Finset.univ : Finset (Finset X)).exists_max_image score
    (by simp)
  have he := hmax ∅ (Finset.mem_univ _)
  simp only [score,Finset.card_empty,Nat.cast_zero,mul_zero,sub_zero] at he
  refine ⟨S,by linarith [hbound S],?_⟩
  intro x
  by_cases hx : x∈S
  · simp [Finset.insert_eq_of_mem hx,hδ.le]
  · have hh := hmax (insert x S) (Finset.mem_univ _)
    simp only [score,Finset.card_insert_of_notMem hx,Nat.cast_add,Nat.cast_one] at hh
    linarith

/-- Simultaneous anchors for finitely many monotone energy functionals. Each
functional gets its own normalized threshold; the size pays their summed
normalized budgets. -/
theorem finite_multi_energy_anchors {J : Type*} [Fintype J]
    (energy : J → Finset X → ℝ) (δ : J → ℝ) (A : J → ℝ)
    (hδ : ∀ j,0<δ j) (hzero : ∀ j,0≤energy j ∅)
    (hbound : ∀ j S,energy j S≤A j) (hmono : ∀ j,Monotone (energy j)) :
    ∃ S : Finset X, (S.card:ℝ) ≤ ∑ j,A j/δ j ∧
      ∀ j x,energy j (insert x S)-energy j S≤δ j := by
  let E := fun S => ∑ j,energy j S/δ j
  obtain ⟨S,hsize,hinc⟩ := finite_energy_anchors E 1 (∑ j,A j/δ j) (by norm_num)
    (Finset.sum_nonneg fun j _ => div_nonneg (hzero j) (hδ j).le)
    (fun S => Finset.sum_le_sum fun j _ => div_le_div_of_nonneg_right (hbound j S) (hδ j).le)
  refine ⟨S,by simpa using hsize,?_⟩
  intro j x
  have hj : (energy j (insert x S)-energy j S)/δ j ≤
      ∑ k,(energy k (insert x S)-energy k S)/δ k := by
    apply Finset.single_le_sum (s := Finset.univ)
      (f := fun k => (energy k (insert x S)-energy k S)/δ k)
    · intro k hk
      exact div_nonneg (sub_nonneg.mpr (hmono k (Finset.subset_insert x S))) (hδ k).le
    · exact Finset.mem_univ j
  have heq : (∑ k,(energy k (insert x S)-energy k S)/δ k)=E (insert x S)-E S := by
    simp only [E,sub_div,Finset.sum_sub_distrib]
  rw [heq] at hj
  have hh := hj.trans (hinc x)
  exact (div_le_one (hδ j)).mp hh

#print axioms finite_multi_energy_anchors
end ConditionalAnalytic
