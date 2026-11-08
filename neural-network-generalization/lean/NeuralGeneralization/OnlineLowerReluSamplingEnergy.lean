import NeuralGeneralization.OnlineLowerReluBlockPotential
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise

/-! # The exact independent rail-sampling law and its energy identity -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

variable {κ : Type*} [Fintype κ] [DecidableEq κ] {β : κ → Type*}
variable [∀ j, Fintype (β j)] [∀ j, Nonempty (β j)]

/-- Literal product weights for independent, possibly differently sized blocks. -/
def dependentProductWeight (p : (j : κ) → β j → ℝ) (pick : (j : κ) → β j) : ℝ :=
  ∏ j, p j (pick j)

omit [∀ j, Nonempty (β j)] in
theorem dependentProductWeight_sum (p : (j : κ) → β j → ℝ)
    (hp : ∀ j, ∑ k, p j k = 1) :
    (∑ pick : (j : κ) → β j, dependentProductWeight p pick) = 1 := by
  unfold dependentProductWeight
  rw [← Fintype.prod_sum]
  simp_rw [hp]
  simp

omit [∀ j, Nonempty (β j)] in
/-- The coordinate marginal of the exact dependent finite product law. -/
theorem dependentProductWeight_coordinate (p : (j : κ) → β j → ℝ)
    (hp : ∀ j, ∑ k, p j k = 1) (j : κ) (F : β j → ℝ) :
    (∑ pick : (j : κ) → β j, dependentProductWeight p pick * F (pick j)) =
      ∑ k, p j k * F k := by
  classical
  let g : (i : κ) → β i → ℝ := Function.update (fun i (_ : β i) => (1 : ℝ)) j F
  have hg (pick : (j : κ) → β j) : (∏ i, g i (pick i)) = F (pick j) := by
    rw [Finset.prod_eq_single j]
    · simp [g]
    · intro i _ hij
      simp [g, hij]
    · simp
  have hterm (pick : (j : κ) → β j) :
      dependentProductWeight p pick * F (pick j) = ∏ i, p i (pick i) * g i (pick i) := by
    rw [Finset.prod_mul_distrib, hg]
    rfl
  simp_rw [hterm]
  rw [← Fintype.prod_sum (fun i k => p i k * g i k), Finset.prod_eq_single j]
  · simp [g]
  · intro i _ hij
    simp [g, hij, hp]
  · simp

omit [∀ j, Nonempty (β j)] in
/-- Independence of two distinct coordinates in the literal dependent law. -/
theorem dependentProductWeight_two_coordinates (p : (j : κ) → β j → ℝ)
    (hp : ∀ j, ∑ k, p j k = 1) (j k : κ) (hjk : j ≠ k)
    (F : β j → ℝ) (G : β k → ℝ) :
    (∑ pick : (j : κ) → β j,
      dependentProductWeight p pick * (F (pick j) * G (pick k))) =
      (∑ x, p j x * F x) * (∑ y, p k y * G y) := by
  classical
  let a : (i : κ) → β i → ℝ := Function.update (fun i (_ : β i) => (1 : ℝ)) j F
  let b : (i : κ) → β i → ℝ := Function.update (fun i (_ : β i) => (1 : ℝ)) k G
  have ha (pick : (j : κ) → β j) : (∏ i, a i (pick i)) = F (pick j) := by
    rw [Finset.prod_eq_single j]
    · simp [a]
    · intro i _ hij; simp [a, hij]
    · simp
  have hb (pick : (j : κ) → β j) : (∏ i, b i (pick i)) = G (pick k) := by
    rw [Finset.prod_eq_single k]
    · simp [b]
    · intro i _ hik; simp [b, hik]
    · simp
  have ht (pick : (j : κ) → β j) :
      dependentProductWeight p pick * (F (pick j) * G (pick k)) =
        ∏ i, p i (pick i) * (a i (pick i) * b i (pick i)) := by
    rw [Finset.prod_mul_distrib, Finset.prod_mul_distrib, ha, hb]
    rfl
  simp_rw [ht]
  rw [← Fintype.prod_sum (fun i z => p i z * (a i z * b i z))]
  rw [← Finset.mul_prod_erase _ _ (Finset.mem_univ j)]
  have hjvalue : (∑ z, p j z * (a j z * b j z)) = ∑ z, p j z * F z := by
    simp [a, b, hjk]
  rw [hjvalue]
  congr 1
  rw [Finset.prod_eq_single k]
  · simp [a, b, Ne.symm hjk]
  · intro i hi hik
    have hij : i ≠ j := (Finset.mem_erase.mp hi).1
    simp [a, b, hij, hik, hp]
  · intro hk
    exact False.elim (hk (Finset.mem_erase.mpr ⟨Ne.symm hjk, Finset.mem_univ k⟩))

/-- Uniform independent rail sampling with the exact product normalizer. -/
def uniformBlockAverage (F : ((j : κ) → β j) → ℝ) : ℝ :=
  (∏ j, (Fintype.card (β j) : ℝ)⁻¹) * ∑ pick, F pick

theorem uniformBlockAverage_coordinate (j : κ) (F : β j → ℝ) :
    uniformBlockAverage (fun pick => F (pick j)) =
      (Fintype.card (β j) : ℝ)⁻¹ * ∑ k, F k := by
  have hc (i : κ) : (Fintype.card (β i) : ℝ) ≠ 0 := by
    exact_mod_cast Fintype.card_ne_zero
  have hp (i : κ) : (∑ _ : β i, (Fintype.card (β i) : ℝ)⁻¹) = 1 := by simp [hc i]
  have h := dependentProductWeight_coordinate (fun i _ => (Fintype.card (β i) : ℝ)⁻¹)
    hp j F
  simpa only [dependentProductWeight, uniformBlockAverage, ← Finset.mul_sum] using h

theorem uniformBlockAverage_mul_coordinates (j k : κ) (hjk : j ≠ k)
    (F : β j → ℝ) (G : β k → ℝ) :
    uniformBlockAverage (fun pick => F (pick j) * G (pick k)) =
      uniformBlockAverage (fun pick => F (pick j)) *
        uniformBlockAverage (fun pick => G (pick k)) := by
  have hc (i : κ) : (Fintype.card (β i) : ℝ) ≠ 0 := by
    exact_mod_cast Fintype.card_ne_zero
  have hp (i : κ) : (∑ _ : β i, (Fintype.card (β i) : ℝ)⁻¹) = 1 := by simp [hc i]
  rw [uniformBlockAverage_coordinate j F, uniformBlockAverage_coordinate k G]
  have h := dependentProductWeight_two_coordinates
    (fun i _ => (Fintype.card (β i) : ℝ)⁻¹) hp j k hjk F G
  simpa only [dependentProductWeight, uniformBlockAverage, ← Finset.mul_sum] using h

omit [∀ j, Nonempty (β j)] in
theorem uniformBlockAverage_sum {ι : Type*} [Fintype ι]
    (F : ι → ((j : κ) → β j) → ℝ) :
    uniformBlockAverage (fun pick => ∑ i, F i pick) = ∑ i, uniformBlockAverage (F i) := by
  unfold uniformBlockAverage
  rw [Finset.sum_comm, Finset.mul_sum]

omit [∀ j, Nonempty (β j)] in
theorem uniformBlockAverage_const_mul (c : ℝ) (F : ((j : κ) → β j) → ℝ) :
    uniformBlockAverage (fun pick => c * F pick) = c * uniformBlockAverage F := by
  unfold uniformBlockAverage
  rw [← Finset.mul_sum]
  ring

/-- The actual squared incoming norm in block coordinates. -/
def blockEnergy (u : (j : κ) → β j → ℝ) : ℝ := ∑ j, ∑ k, u j k ^ 2

omit [DecidableEq κ] [∀ j, Nonempty (β j)] in
theorem blockEnergy_sampled (u : (j : κ) → β j → ℝ) (pick : (j : κ) → β j) :
    blockEnergy (sampledBlockWeights u pick) =
      ∑ j, (Fintype.card (β j) : ℝ) * u j (pick j) ^ 2 := by
  simp [blockEnergy, sampledBlockWeights]

/-- Balancing preserves incoming energy exactly in expectation. -/
theorem blockEnergy_sample_average (u : (j : κ) → β j → ℝ) :
    uniformBlockAverage (fun pick => blockEnergy (sampledBlockWeights u pick)) = blockEnergy u := by
  simp_rw [blockEnergy_sampled]
  rw [uniformBlockAverage_sum]
  unfold blockEnergy
  apply Finset.sum_congr rfl
  intro j _
  rw [uniformBlockAverage_const_mul, uniformBlockAverage_coordinate j (fun k => u j k ^ 2)]
  have hc : (Fintype.card (β j) : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  rw [← mul_assoc, mul_inv_cancel₀ hc, one_mul]

omit [DecidableEq κ] [∀ j, Nonempty (β j)] in
/-- The block energy is the norm in the actual physical coordinate model. -/
theorem blockWeights_energy {d : ℕ} (e : ((j : κ) × β j) ≃ Fin d)
    (u : (j : κ) → β j → ℝ) :
    (∑ i : Fin d, blockWeights e u i ^ 2) = blockEnergy u := by
  have h := e.sum_comp (fun i => blockWeights e u i ^ 2)
  rw [Fintype.sum_sigma] at h
  simpa only [blockWeights_apply, blockEnergy] using h.symm

end NeuralGeneralization.OnlineLowerRelu
