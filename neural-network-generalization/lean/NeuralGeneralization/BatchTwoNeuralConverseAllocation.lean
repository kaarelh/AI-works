import NeuralGeneralization.BatchTwoNeuralConverseNeumann
import Mathlib.Data.Fintype.Sigma

/-! Explicit finite feature allocations; no asymptotic clone fractions are assumed. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
variable {I : Type*} [Fintype I] [Nonempty I]

def allocationRate (I : Type*) [Fintype I] : ℝ := 8*Fintype.card I
def featureCopies (b : I → ℝ) (i : I) : ℕ := ⌈allocationRate I*|b i|⌉₊+1
abbrev AllocationIndex (b : I → ℝ) := (i : I) × Fin (featureCopies b i)
def allocationWidth (b : I → ℝ) : ℕ := Fintype.card (AllocationIndex b)
def allocationEquiv (b : I → ℝ) : AllocationIndex b ≃ Fin (allocationWidth b) := Fintype.equivFin _
def allocationLabel (b : I → ℝ) (j : Fin (allocationWidth b)) : I := ((allocationEquiv b).symm j).1

theorem allocationRate_pos : 0 < allocationRate I := by
  have hc : 0 < Fintype.card I := Fintype.card_pos
  unfold allocationRate
  positivity

theorem featureCopies_pos (b : I → ℝ) (i : I) : 0 < featureCopies b i := Nat.succ_pos _

theorem featureCopies_lower (b : I → ℝ) (i : I) : allocationRate I*|b i| ≤ featureCopies b i := by
  have h := Nat.le_ceil (allocationRate I*|b i|)
  unfold featureCopies
  push_cast
  linarith

theorem featureCopies_upper (b : I → ℝ) (i : I) :
    (featureCopies b i : ℝ) ≤ allocationRate I*|b i|+2 := by
  have h := Nat.ceil_lt_add_one (show 0 ≤ allocationRate I*|b i| by
    exact mul_nonneg allocationRate_pos.le (abs_nonneg _))
  unfold featureCopies
  push_cast
  linarith

theorem allocationWidth_sum (b : I → ℝ) : allocationWidth b = ∑ i, featureCopies b i := by
  simp [allocationWidth, AllocationIndex]

theorem allocationWidth_pos (b : I → ℝ) : 0 < allocationWidth b := by
  rw [allocationWidth_sum]
  exact Finset.sum_pos (fun i _ => featureCopies_pos b i) Finset.univ_nonempty

theorem sum_allocation (b : I → ℝ) (F : I → ℝ) :
    (∑ j : Fin (allocationWidth b), F (allocationLabel b j)) =
      ∑ i, (featureCopies b i : ℝ)*F i := by
  unfold allocationLabel
  let G : AllocationIndex b → ℝ := fun p => F p.1
  change (∑ j, G ((allocationEquiv b).symm j)) = _
  rw [(allocationEquiv b).symm.sum_comp]
  simp [G, Fintype.sum_sigma]

theorem allocationWidth_upper (b : I → ℝ) :
    (allocationWidth b : ℝ) ≤ allocationRate I*vectorL1 b+2*Fintype.card I := by
  rw [allocationWidth_sum, Nat.cast_sum]
  calc
    _ ≤ ∑ i, (allocationRate I*|b i|+2) := Finset.sum_le_sum (fun i _ => featureCopies_upper b i)
    _ = _ := by simp [vectorL1, Finset.sum_add_distrib, Finset.mul_sum, mul_comm]

theorem allocated_square_sum (b : I → ℝ) :
    (∑ i, (b i)^2/(featureCopies b i : ℝ)) ≤ vectorL1 b/allocationRate I := by
  have hrate : 0 < allocationRate I := allocationRate_pos
  rw [vectorL1, Finset.sum_div]
  apply Finset.sum_le_sum
  intro i _
  have hn : (0 : ℝ) < featureCopies b i := by exact_mod_cast featureCopies_pos b i
  apply (div_le_div_iff₀ hn hrate).mpr
  have h := mul_le_mul_of_nonneg_right (featureCopies_lower b i) (abs_nonneg (b i))
  nlinarith [sq_abs (b i)]

/-- The explicit ceil allocation has effective readout energy at most17 when
the feature expansion has variation at most4. -/
theorem allocated_energy_le_seventeen (b : I → ℝ) (hb : vectorL1 b ≤ 4) :
    (allocationWidth b : ℝ)*(∑ i, (b i)^2/(featureCopies b i : ℝ)) ≤ 17 := by
  have hV := vectorL1_nonneg b
  have hr : 0 < allocationRate I := allocationRate_pos
  have hc : (0 : ℝ) < Fintype.card I := by exact_mod_cast Fintype.card_pos (α := I)
  have hbound := mul_le_mul_of_nonneg_left (allocated_square_sum b) (Nat.cast_nonneg (allocationWidth b))
  have hwidth := mul_le_mul_of_nonneg_right (allocationWidth_upper b) (div_nonneg hV hr.le)
  have he : (allocationRate I*vectorL1 b+2*Fintype.card I)*(vectorL1 b/allocationRate I) =
      (vectorL1 b)^2+vectorL1 b/4 := by
    unfold allocationRate
    field_simp
    ring
  rw [he] at hwidth
  have hquad : (vectorL1 b)^2 ≤ 16 := by nlinarith
  linarith

theorem allocated_linear_identity (b F : I → ℝ) :
    (∑ j : Fin (allocationWidth b),
      (b (allocationLabel b j)/(featureCopies b (allocationLabel b j) : ℝ))*F (allocationLabel b j)) =
      ∑ i, b i*F i := by
  rw [sum_allocation b (fun i => b i/(featureCopies b i : ℝ)*F i)]
  apply Finset.sum_congr rfl
  intro i _
  have hn : (featureCopies b i : ℝ) ≠ 0 := by exact_mod_cast (featureCopies_pos b i).ne'
  field_simp

theorem allocated_square_identity (b : I → ℝ) :
    (∑ j : Fin (allocationWidth b),
      (b (allocationLabel b j)/(featureCopies b (allocationLabel b j) : ℝ))^2) =
      ∑ i, (b i)^2/(featureCopies b i : ℝ) := by
  rw [sum_allocation b (fun i => (b i/(featureCopies b i : ℝ))^2)]
  apply Finset.sum_congr rfl
  intro i _
  have hn : (featureCopies b i : ℝ) ≠ 0 := by exact_mod_cast (featureCopies_pos b i).ne'
  field_simp

end
end NeuralGeneralization.BatchTwoNeuralConverse
