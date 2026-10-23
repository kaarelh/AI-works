import NeuralGeneralization.BatchTwoMergingModel
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic.FieldSimp

/-! # Exact finite-dimensional geometry of neuron populations -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoMerging

open ConcreteModel

def relu (z : ℝ) : ℝ := max 0 z

theorem continuous_relu : Continuous relu := continuous_const.max continuous_id

@[simp] theorem relu_zero : relu 0 = 0 := by simp [relu]

theorem relu_mul_nonneg (a z : ℝ) (ha : 0 ≤ a) : relu (a * z) = a * relu z := by
  unfold relu
  rw [mul_max_of_nonneg _ _ ha, mul_zero]

def populationSize {N : ℕ} (p : PopulationPartition N)
    (a : Fin (populationCount p)) : ℝ := (populationMembers p a).card

theorem populationSize_pos {N : ℕ} (p : PopulationPartition N)
    (a : Fin (populationCount p)) : 0 < populationSize p a := by
  unfold populationSize
  exact_mod_cast populationMembers_card_pos p a

theorem populationSize_ne_zero {N : ℕ} (p : PopulationPartition N)
    (a : Fin (populationCount p)) : populationSize p a ≠ 0 :=
  (populationSize_pos p a).ne'

def populationLift {N : ℕ} (p : PopulationPartition N)
    (h : Fin (populationCount p) → ℝ) : Fin N → ℝ :=
  fun i => h (populationLabel p i) / Real.sqrt (populationSize p (populationLabel p i))

def populationCoordinates {N : ℕ} (p : PopulationPartition N)
    (h : Fin N → ℝ) : Fin (populationCount p) → ℝ :=
  fun a => (∑ i ∈ populationMembers p a, h i) / Real.sqrt (populationSize p a)

theorem populationAverage_eq {N : ℕ} (p : PopulationPartition N)
    (h : Fin N → ℝ) (i : Fin N) :
    populationAverage p h i =
      (∑ j ∈ populationMembers p (populationLabel p i), h j) /
        populationSize p (populationLabel p i) := by
  classical
  unfold populationAverage populationProjection populationMembers populationSize
  rw [Finset.sum_filter]
  simp only [ite_mul, zero_mul]
  have heq : (∑ j : Fin N,
      if populationLabel p i = populationLabel p j then
        ((Finset.univ.filter (fun i' => populationLabel p i' = populationLabel p i)).card : ℝ)⁻¹ *
          h j else 0) =
    ((Finset.univ.filter (fun i' => populationLabel p i' = populationLabel p i)).card : ℝ)⁻¹ *
      ∑ j : Fin N, if populationLabel p j = populationLabel p i then h j else 0 := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    by_cases hj : populationLabel p j = populationLabel p i
    · simp [hj]
    · simp [hj, Ne.symm hj]
  rw [heq]
  unfold populationMembers
  ring

theorem populationCoordinates_lift {N : ℕ} (p : PopulationPartition N)
    (h : Fin (populationCount p) → ℝ) :
    populationCoordinates p (populationLift p h) = h := by
  classical
  funext a
  have hk : 0 < populationSize p a := populationSize_pos p a
  have hs : Real.sqrt (populationSize p a) ≠ 0 := (Real.sqrt_pos.mpr hk).ne'
  have hsum : (∑ i ∈ populationMembers p a, populationLift p h i) =
      populationSize p a * (h a / Real.sqrt (populationSize p a)) := by
    calc
      _ = ∑ _i ∈ populationMembers p a, h a / Real.sqrt (populationSize p a) := by
        apply Finset.sum_congr rfl
        intro i hi
        simp only [populationLift, (mem_populationMembers p a i).mp hi]
      _ = _ := by simp [populationSize]
  unfold populationCoordinates
  rw [hsum]
  have hsq := Real.sq_sqrt hk.le
  field_simp
  rw [hsq]
  ring

theorem populationLift_coordinates {N : ℕ} (p : PopulationPartition N)
    (h : Fin N → ℝ) :
    populationLift p (populationCoordinates p h) = populationAverage p h := by
  funext i
  rw [populationAverage_eq]
  unfold populationLift populationCoordinates
  rw [div_div, ← pow_two, Real.sq_sqrt (populationSize_pos p _).le]

theorem populationAverage_idempotent {N : ℕ} (p : PopulationPartition N)
    (h : Fin N → ℝ) :
    populationAverage p (populationAverage p h) = populationAverage p h := by
  rw [← populationLift_coordinates, ← populationLift_coordinates,
    populationCoordinates_lift, populationLift_coordinates]

theorem populationLift_injective {N : ℕ} (p : PopulationPartition N) :
    Function.Injective (populationLift p) := by
  intro h g heq
  have hh := congrArg (populationCoordinates p) heq
  simpa only [populationCoordinates_lift] using hh

/-- ReLU commutes exactly with the nonnegative, disjoint population lift. -/
theorem relu_populationLift {N : ℕ} (p : PopulationPartition N)
    (h : Fin (populationCount p) → ℝ) :
    (fun i => relu (populationLift p h i)) = populationLift p (fun a => relu (h a)) := by
  funext i
  unfold populationLift
  rw [div_eq_mul_inv, mul_comm, relu_mul_nonneg _ _ (by positivity)]
  ring

/-- The sum of a function constant on a fibre is its population size times
its common value. -/
theorem sum_population_constant {N : ℕ} (p : PopulationPartition N)
    (a : Fin (populationCount p)) (h : Fin (populationCount p) → ℝ) :
    (∑ i ∈ populationMembers p a, h (populationLabel p i)) = populationSize p a * h a := by
  classical
  calc
    _ = ∑ _i ∈ populationMembers p a, h a := by
      apply Finset.sum_congr rfl
      intro i hi
      rw [(mem_populationMembers p a i).mp hi]
    _ = _ := by simp [populationSize]

theorem populationProjection_row_sum {N : ℕ} (p : PopulationPartition N) (i : Fin N) :
    (∑ j, populationProjection p i j) = 1 := by
  have hh := populationAverage_eq p (fun _ => 1) i
  have hn : ((populationMembers p (populationLabel p i)).card : ℝ) ≠ 0 :=
    populationSize_ne_zero p _
  simpa [populationAverage, populationSize, hn] using hh

theorem populationAverage_same_fibre {N : ℕ} (p : PopulationPartition N)
    (h : Fin N → ℝ) {i j : Fin N} (hij : populationLabel p i = populationLabel p j) :
    populationAverage p h i = populationAverage p h j := by
  rw [populationAverage_eq, populationAverage_eq, hij]

/-- Averaging cannot increase the coordinate maximum. -/
theorem populationAverage_abs_le {N : ℕ} (p : PopulationPartition N)
    (h : Fin N → ℝ) (B : ℝ) (hh : ∀ i, |h i| ≤ B) (i : Fin N) :
    |populationAverage p h i| ≤ B := by
  calc
    _ ≤ ∑ j, |populationProjection p i j * h j| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ j, populationProjection p i j * |h j| := by
      simp_rw [abs_mul, abs_of_nonneg (populationProjection_nonneg p i _)]
    _ ≤ ∑ j, populationProjection p i j * B := by
      apply Finset.sum_le_sum
      intro j _
      exact mul_le_mul_of_nonneg_left (hh j) (populationProjection_nonneg p i j)
    _ = B := by rw [← Finset.sum_mul, populationProjection_row_sum, one_mul]

end NeuralGeneralization.BatchTwoMerging
