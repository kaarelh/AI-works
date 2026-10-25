import FiniteConcentration
import TwoBallGeometry

open scoped BigOperators RealInnerProductSpace

namespace BooleanDepthResearch
namespace SignFreezing

noncomputable section

/-- Boolean signs used for freezing input coordinates. -/
def sign : Bool → ℝ
  | false => -1
  | true => 1

@[simp] lemma sign_false : sign false = -1 := rfl
@[simp] lemma sign_true : sign true = 1 := rfl
@[simp] lemma abs_sign (s : Bool) : |sign s| = 1 := by cases s <;> norm_num [sign]

def fairCoinWeight : Bool → ℝ := fun _ ↦ 1 / 2

lemma fairCoinWeight_sum : ∑ i, fairCoinWeight i = 1 := by norm_num [fairCoinWeight]

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

lemma avg_bool_norm_sq (b v : E) :
    FiniteProbability.avg fairCoinWeight (fun s ↦ ‖b + sign s • v‖ ^ 2) =
      ‖b‖ ^ 2 + ‖v‖ ^ 2 := by
  simp [FiniteProbability.avg, fairCoinWeight, sign, norm_add_sq_real]
  ring

/-- Exact finite uniform-sign second-moment identity, including the empty tuple. -/
theorem uniform_sign_second_moment (n : ℕ) (b : E) (v : Fin n → E) :
    FiniteProbability.sampleAvg fairCoinWeight n (fun s ↦ ‖b + ∑ i, sign (s i) • v i‖ ^ 2) =
      ‖b‖ ^ 2 + ∑ i, ‖v i‖ ^ 2 := by
  induction n with
  | zero => simp [FiniteProbability.sampleAvg]
  | succ n ih =>
    simp_rw [FiniteProbability.sampleAvg, Fin.sum_univ_succ, Fin.cons_zero, Fin.cons_succ]
    have hpoint (s : Fin n → Bool) :
        FiniteProbability.avg fairCoinWeight (fun t ↦
          ‖b + (sign t • v 0 + ∑ i, sign (s i) • v i.succ)‖ ^ 2) =
        ‖b + ∑ i, sign (s i) • v i.succ‖ ^ 2 + ‖v 0‖ ^ 2 := by
      have heq (t : Bool) : b + (sign t • v 0 + ∑ i, sign (s i) • v i.succ) =
          (b + ∑ i, sign (s i) • v i.succ) + sign t • v 0 := by abel
      simp_rw [heq]
      exact avg_bool_norm_sq _ _
    simp_rw [hpoint]
    rw [FiniteProbability.sampleAvg_add, FiniteProbability.sampleAvg_const _ fairCoinWeight_sum, ih]
    ring

/-- An actual tuple attains at most the finite uniform average. -/
lemma exists_le_uniform_average (n : ℕ) (f : (Fin n → Bool) → ℝ) :
    ∃ s, f s ≤ FiniteProbability.sampleAvg fairCoinWeight n f := by
  induction n with
  | zero => exact ⟨Fin.elim0, le_rfl⟩
  | succ n ih =>
    obtain ⟨s, hs⟩ := ih (fun s ↦ FiniteProbability.avg fairCoinWeight (fun t ↦ f (Fin.cons t s)))
    by_cases h : f (Fin.cons false s) ≤ f (Fin.cons true s)
    · refine ⟨Fin.cons false s, le_trans ?_ hs⟩
      simp [FiniteProbability.avg, fairCoinWeight]
      linarith
    · refine ⟨Fin.cons true s, le_trans ?_ hs⟩
      simp [FiniteProbability.avg, fairCoinWeight]
      linarith

theorem exists_signs_norm_sq_le_fin (n : ℕ) (b : E) (v : Fin n → E) :
    ∃ s : Fin n → Bool, ‖b + ∑ i, sign (s i) • v i‖ ^ 2 ≤
      ‖b‖ ^ 2 + ∑ i, ‖v i‖ ^ 2 := by
  obtain ⟨s, hs⟩ := exists_le_uniform_average n (fun s ↦ ‖b + ∑ i, sign (s i) • v i‖ ^ 2)
  rw [uniform_sign_second_moment] at hs
  exact ⟨s, hs⟩

/-- The finite uniform average on signs indexed by any finite type. -/
def uniformSignAverage {I : Type*} [Fintype I] (f : (I → Bool) → ℝ) : ℝ :=
  FiniteProbability.sampleAvg fairCoinWeight (Fintype.card I)
    (fun s ↦ f (fun i ↦ s (Fintype.equivFin I i)))

theorem uniformSignAverage_norm_sq {I : Type*} [Fintype I] (b : E) (v : I → E) :
    uniformSignAverage (fun s ↦ ‖b + ∑ i, sign (s i) • v i‖ ^ 2) =
      ‖b‖ ^ 2 + ∑ i, ‖v i‖ ^ 2 := by
  let e := Fintype.equivFin I
  have hsum (s : Fin (Fintype.card I) → Bool) :
      (∑ i, sign (s (e i)) • v i) = ∑ j, sign (s j) • v (e.symm j) := by
    apply Fintype.sum_equiv e
    intro i
    simp
  have hn : (∑ i, ‖v i‖ ^ 2) = ∑ j, ‖v (e.symm j)‖ ^ 2 := by
    apply Fintype.sum_equiv e
    intro i
    simp
  change FiniteProbability.sampleAvg fairCoinWeight (Fintype.card I)
    (fun s ↦ ‖b + ∑ i, sign (s (e i)) • v i‖ ^ 2) = _
  simp_rw [hsum]
  rw [uniform_sign_second_moment, hn]

/-- Some Boolean-sign freezing does not increase the total squared norm budget.
This includes an empty coordinate type and is derived from the exact finite average. -/
theorem exists_signs_norm_sq_le {I : Type*} [Fintype I] (b : E) (v : I → E) :
    ∃ s : I → Bool, ‖b + ∑ i, sign (s i) • v i‖ ^ 2 ≤
      ‖b‖ ^ 2 + ∑ i, ‖v i‖ ^ 2 := by
  let e := Fintype.equivFin I
  obtain ⟨s, hs⟩ := exists_signs_norm_sq_le_fin (Fintype.card I) b (fun j ↦ v (e.symm j))
  refine ⟨fun i ↦ s (e i), ?_⟩
  have hsum : (∑ i, sign (s (e i)) • v i) = ∑ j, sign (s j) • v (e.symm j) := by
    apply Fintype.sum_equiv e
    intro i
    simp
  have hn : (∑ i, ‖v i‖ ^ 2) = ∑ j, ‖v (e.symm j)‖ ^ 2 := by
    apply Fintype.sum_equiv e
    intro i
    simp
  rw [hsum, hn]
  exact hs

/-- The same freezing result using the explicit scalar-sign encoding. -/
theorem exists_bool_freezing_norm_sq_le {I : Type*} [Fintype I] (b : E) (v : I → E) :
    ∃ s : I → Bool, ‖b + ∑ i, (if s i then (1 : ℝ) else -1) • v i‖ ^ 2 ≤
      ‖b‖ ^ 2 + ∑ i, ‖v i‖ ^ 2 := by
  obtain ⟨s, hs⟩ := exists_signs_norm_sq_le b v
  refine ⟨s, ?_⟩
  have he (i : I) : (if s i then (1 : ℝ) else -1) = sign (s i) := by cases s i <;> rfl
  simpa only [he] using hs

#print axioms exists_bool_freezing_norm_sq_le

end
end SignFreezing
end BooleanDepthResearch
