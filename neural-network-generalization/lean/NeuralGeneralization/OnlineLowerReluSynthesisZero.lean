import NeuralGeneralization.OnlineLowerReluSynthesis

/-! # Finite ReLU Fourier synthesis with zero coefficients retained

The full Walsh index set may contain zero coefficients. They are removed
by an explicit finite subtype before applying exact per-neuron balancing.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu

private theorem sum_nonzero_coefficients {ι : Type*} [Fintype ι]
    (v : ι → ℝ) (F : ι → ℝ) (hzero : ∀ i, v i = 0 → F i = 0) :
    (∑ i : {i : ι // v i ≠ 0}, F i.val) = ∑ i, F i := by
  have hh := Fintype.sum_subtype_add_sum_subtype (fun i => v i ≠ 0) F
  have hz : (∑ i : {i : ι // ¬ v i ≠ 0}, F i.val) = 0 := by
    apply Finset.sum_eq_zero
    intro i _
    exact hzero i.val (not_not.mp i.property)
  rw [hz, add_zero] at hh
  exact hh

/-- Arbitrary finite Fourier indices and arbitrary real coefficients,
including zero coefficients, have the exact stated ReLU cost. -/
theorem relu_fourier_score_exact_at_width {d N : ℕ} {ι : Type*} [Fintype ι]
    (hd : 0 < d) (S : ι → Finset (Fin d)) (r : ι → ℕ) (v : ι → ℝ)
    (hcard : ∀ i, (S i).card = 2 * r i + 2)
    (hN : 0 < N) (hwidth : Fintype.card ι * Fintype.card (Cube d) ≤ N) :
    ∃ w : Weights d N 0,
      (∀ x, networkOutput (fun t => max 0 t) w x = ∑ i, v i * walshCharacter (S i) x) ∧
      weightedSquaredNorm w = 2 * Real.sqrt (d : ℝ) * ∑ i, |v i| * evenReluCost (r i) := by
  let I := {i : ι // v i ≠ 0}
  let e := Fintype.equivFin I
  let s : Fin (Fintype.card I) → ι := fun j => (e.symm j).val
  have hs (j) : v (s j) ≠ 0 := (e.symm j).property
  have hn : Fintype.card I ≤ Fintype.card ι :=
    Fintype.card_le_of_injective (fun i : I => i.val) Subtype.val_injective
  have hsum (F : ι → ℝ) (hzero : ∀ i, v i = 0 → F i = 0) :
      (∑ j : Fin (Fintype.card I), F (s j)) = ∑ i, F i := by
    rw [show (∑ j : Fin (Fintype.card I), F (s j)) = ∑ i : I, F i.val from
      e.symm.sum_comp (fun i : I => F i.val)]
    exact sum_nonzero_coefficients v F hzero
  obtain ⟨w, hw, hcost⟩ := relu_even_fourier_score_exact_at_width hd
    (fun j => S (s j)) (fun j => r (s j)) (fun j => v (s j))
    (fun j => hcard (s j)) hs hN ((Nat.mul_le_mul_right _ hn).trans hwidth)
  refine ⟨w, ?_, ?_⟩
  · intro x
    rw [hw]
    exact hsum (fun i => v i * walshCharacter (S i) x) (by intro i hi; rw [hi, zero_mul])
  · rw [hcost]
    congr 1
    exact hsum (fun i => |v i| * evenReluCost (r i))
      (by intro i hi; rw [hi, abs_zero, zero_mul])

/-- The corresponding strict-margin witness uses the same explicit width
threshold even when most of the displayed Fourier coefficients vanish. -/
theorem relu_fourier_strict_witness_at_width {d N : ℕ} {ι : Type*} [Fintype ι]
    (hd : 0 < d) (S : ι → Finset (Fin d)) (r : ι → ℕ) (v : ι → ℝ)
    (hcard : ∀ i, (S i).card = 2 * r i + 2)
    (g : BooleanFunction d)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g x) * ∑ i, v i * walshCharacter (S i) x)
    (B : ℝ) (hbudget : 2 * Real.sqrt (d : ℝ) * ∑ i, |v i| * evenReluCost (r i) < B)
    (hN : 0 < N) (hwidth : Fintype.card ι * Fintype.card (Cube d) ≤ N) :
    ∃ w : Weights d N 0,
      w ∈ marginEvent (fun t => max 0 t) (1 / 2) g ∧ weightedSquaredNorm w < B := by
  let I := {i : ι // v i ≠ 0}
  let e := Fintype.equivFin I
  let s : Fin (Fintype.card I) → ι := fun j => (e.symm j).val
  have hs (j) : v (s j) ≠ 0 := (e.symm j).property
  have hn : Fintype.card I ≤ Fintype.card ι :=
    Fintype.card_le_of_injective (fun i : I => i.val) Subtype.val_injective
  have hsum (F : ι → ℝ) (hzero : ∀ i, v i = 0 → F i = 0) :
      (∑ j : Fin (Fintype.card I), F (s j)) = ∑ i, F i := by
    rw [show (∑ j : Fin (Fintype.card I), F (s j)) = ∑ i : I, F i.val from
      e.symm.sum_comp (fun i : I => F i.val)]
    exact sum_nonzero_coefficients v F hzero
  apply relu_even_fourier_strict_witness_at_width hd
    (fun j => S (s j)) (fun j => r (s j)) (fun j => v (s j))
    (fun j => hcard (s j)) hs g
  · intro x
    rw [hsum (fun i => v i * walshCharacter (S i) x) (by intro i hi; rw [hi, zero_mul])]
    exact hmargin x
  · rw [hsum (fun i => |v i| * evenReluCost (r i))
      (by intro i hi; rw [hi, abs_zero, zero_mul])]
    exact hbudget
  · exact hN
  · exact (Nat.mul_le_mul_right _ hn).trans hwidth

end NeuralGeneralization.OnlineLower
