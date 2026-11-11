import NeuralGeneralization.BatchTwoContinuousDepthInterpolation
import Mathlib.Order.Fin.Basic

/-! The bounded step interpolator in the continuous-depth paper. Its tanh
basis is a partition of unity, including the single-sample case. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuousDepthLower BatchTwoNeuralConverse

def extendedProfile {m : ℕ} (θ : Fin m → ℝ) : Fin (m+2) → ℝ :=
  Fin.cases 1 (Fin.snoc θ (-1))

@[simp] theorem extendedProfile_zero {m : ℕ} (θ : Fin m → ℝ) :
    extendedProfile θ 0=1 := rfl

@[simp] theorem extendedProfile_last {m : ℕ} (θ : Fin m → ℝ) :
    extendedProfile θ (Fin.last (m+1)) = -1 := by
  rw [show Fin.last (m+1) = (Fin.last m).succ from rfl]
  simp only [extendedProfile,Fin.cases_succ,Fin.snoc_last]

@[simp] theorem extendedProfile_internal {m : ℕ} (θ : Fin m → ℝ) (i : Fin m) :
    extendedProfile θ i.castSucc.succ = θ i := by simp [extendedProfile]

theorem extendedProfile_bounds {m : ℕ} (θ : Fin m → ℝ) (hθ : ∀ i, |θ i| ≤ 1)
    (i : Fin (m+2)) : -1 ≤ extendedProfile θ i ∧ extendedProfile θ i ≤ 1 := by
  induction i using Fin.cases with
  | zero => simp
  | succ i =>
    induction i using Fin.lastCases with
    | last => simp only [Fin.succ_last,extendedProfile_last]; norm_num
    | cast i => simpa using (abs_le.mp (hθ i))

theorem extendedProfile_antitone {m : ℕ} (θ : Fin m → ℝ)
    (hθ : ∀ i, |θ i| ≤ 1) (hmono : Antitone θ) : Antitone (extendedProfile θ) := by
  intro i j hij
  induction i using Fin.cases with
  | zero => simpa using (extendedProfile_bounds θ hθ j).2
  | succ i =>
    induction j using Fin.cases with
    | zero => exact False.elim (by have := Fin.le_iff_val_le_val.mp hij; simp at this)
    | succ j =>
      have hij' : i ≤ j := Fin.succ_le_succ_iff.mp hij
      induction j using Fin.lastCases with
      | last =>
        simpa using (extendedProfile_bounds θ hθ i.succ).1
      | cast j =>
        induction i using Fin.lastCases with
        | last => exact False.elim (by have := Fin.le_iff_val_le_val.mp hij'; simp at this; omega)
        | cast i => simpa using hmono (Fin.castSucc_le_castSucc_iff.mp hij')

def stepBasis {m : ℕ} (θ : Fin m → ℝ) (i : Fin (m+1)) : ℝ :=
  (extendedProfile θ i.castSucc-extendedProfile θ i.succ)/2

theorem stepBasis_nonneg {m : ℕ} (θ : Fin m → ℝ)
    (hθ : ∀ i, |θ i| ≤ 1) (hmono : Antitone θ) (i : Fin (m+1)) :
    0 ≤ stepBasis θ i := by
  unfold stepBasis
  apply div_nonneg _ (by norm_num)
  exact sub_nonneg.mpr (extendedProfile_antitone θ hθ hmono (Fin.castSucc_le_succ i))

theorem stepBasis_sum {m : ℕ} (θ : Fin m → ℝ) : ∑ i, stepBasis θ i=1 := by
  unfold stepBasis
  rw [← Finset.sum_div,Finset.sum_sub_distrib]
  have hleft := Fin.sum_univ_castSucc (extendedProfile θ)
  have hright := Fin.sum_univ_succ (extendedProfile θ)
  simp only [extendedProfile_last,extendedProfile_zero] at hleft hright
  linarith

def stepCombination {m : ℕ} (θ : Fin m → ℝ) (t : Fin (m+1) → ℝ) : ℝ :=
  (t 0+t (Fin.last m))/2 + ∑ i : Fin m, (t i.succ-t i.castSucc)/2*θ i

theorem stepCombination_partition {m : ℕ} (θ : Fin m → ℝ) (t : Fin (m+1) → ℝ) :
    stepCombination θ t = ∑ i, stepBasis θ i*t i := by
  have hleft : (∑ i : Fin (m+1),extendedProfile θ i.castSucc*t i) =
      t 0+∑ i : Fin m, θ i*t i.succ := by
    rw [Fin.sum_univ_succ]
    simp only [Fin.castSucc_zero,extendedProfile_zero,one_mul,Fin.castSucc_succ,
      extendedProfile_internal]
  have hright : (∑ i : Fin (m+1),extendedProfile θ i.succ*t i) =
      (∑ i : Fin m, θ i*t i.castSucc)-t (Fin.last m) := by
    rw [Fin.sum_univ_castSucc]
    simp only [extendedProfile_internal,Fin.succ_last,extendedProfile_last,neg_one_mul]
    ring
  simp only [stepBasis,div_mul_eq_mul_div,sub_mul]
  rw [← Finset.sum_div,Finset.sum_sub_distrib,hleft,hright]
  unfold stepCombination
  simp_rw [div_mul_eq_mul_div,sub_mul]
  rw [← Finset.sum_div,Finset.sum_sub_distrib]
  simp_rw [mul_comm (t _)]
  ring

theorem stepCombination_bound {m : ℕ} (θ : Fin m → ℝ) (t : Fin (m+1) → ℝ)
    (hθ : ∀ i, |θ i| ≤ 1) (hmono : Antitone θ) {B : ℝ} (ht : ∀ i, |t i| ≤ B) :
    |stepCombination θ t| ≤ B := by
  rw [stepCombination_partition]
  calc
    _ ≤ ∑ i, |stepBasis θ i*t i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, stepBasis θ i*B := by
      apply Finset.sum_le_sum
      intro i _
      rw [abs_mul,abs_of_nonneg (stepBasis_nonneg θ hθ hmono i)]
      exact mul_le_mul_of_nonneg_left (ht i) (stepBasis_nonneg θ hθ hmono i)
    _ = B := by rw [← Finset.sum_mul,stepBasis_sum,one_mul]

def thresholdProfile {m : ℕ} (a : ℝ) (c : Fin m → ℝ) (x : ℝ) (j : Fin m) : ℝ :=
  Real.tanh (a*(x-c j))

theorem thresholdProfile_antitone {m : ℕ} {a : ℝ} (ha : 0 ≤ a)
    (c : Fin m → ℝ) (hc : Monotone c) (x : ℝ) : Antitone (thresholdProfile a c x) := by
  intro i j hij
  apply BatchTwoNeuralConverse.tanh_monotone
  exact mul_le_mul_of_nonneg_left (sub_le_sub_left (hc hij) x) ha

/-- Global boundedness uses monotone thresholds, with no bound on the query. -/
theorem tanh_stepCombination_bound {m : ℕ} {a : ℝ} (ha : 0 ≤ a)
    (c : Fin m → ℝ) (hc : Monotone c) (t : Fin (m+1) → ℝ)
    {B : ℝ} (ht : ∀ i, |t i| ≤ B) (x : ℝ) :
    |stepCombination (thresholdProfile a c x) t| ≤ B :=
  stepCombination_bound _ t (fun i => (Real.abs_tanh_lt_one _).le)
    (thresholdProfile_antitone ha c hc x) ht

end NeuralGeneralization.BatchTwoContinuousDepthPaper
