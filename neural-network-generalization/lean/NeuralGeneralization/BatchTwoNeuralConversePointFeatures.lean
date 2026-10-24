import NeuralGeneralization.BatchTwoNeuralConverseShells

/-! The shell interpolation is an actual affine-tanh point indicator on the Boolean cube. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
open ConcreteModel

def hammingShell {d : ℕ} (a x : Cube d) : ℕ :=
  (Finset.univ.filter (fun i => x i ≠ a i)).card

theorem hammingShell_le {d : ℕ} (a x : Cube d) : hammingShell a x ≤ d := by
  simpa [hammingShell] using Finset.card_filter_le (s := Finset.univ) (p := fun i => x i ≠ a i)

theorem hammingShell_eq_zero {d : ℕ} (a x : Cube d) : hammingShell a x = 0 ↔ x=a := by
  simp only [hammingShell, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  constructor
  · intro h
    funext i
    exact Classical.not_not.mp (h (Finset.mem_univ i))
  · intro h i _
    simp [h]

def shellIndex {d : ℕ} (a x : Cube d) : Fin (d+1) := ⟨hammingShell a x, Nat.lt_succ_of_le (hammingShell_le a x)⟩

theorem shellIndex_eq_zero {d : ℕ} (a x : Cube d) : shellIndex a x = 0 ↔ x=a := by
  rw [Fin.ext_iff]
  exact hammingShell_eq_zero a x

theorem label_dot_shell {d : ℕ} (a x : Cube d) :
    (∑ i, labelReal (a i)*labelReal (x i)) = (d : ℝ)-2*hammingShell a x := by
  have he (i : Fin d) : labelReal (a i)*labelReal (x i) =
      1-2*(if x i ≠ a i then (1 : ℝ) else 0) := by
    cases ha : a i <;> cases hx : x i <;> norm_num [ha, hx, labelReal]
  have hs : (∑ i : Fin d, if x i ≠ a i then (1 : ℝ) else 0) = hammingShell a x := by
    rw [← Finset.sum_filter]
    simp [hammingShell]
  simp_rw [he, Finset.sum_sub_distrib, ← Finset.mul_sum, hs]
  simp

def pointFeatureWeights {d : ℕ} (a : Cube d) (j : Fin (d+1)) : Fin (d+1) → ℝ :=
  if j=0 then Fin.cases 1 (fun _ => 0)
  else Fin.cases (-singletonSlope d*((d : ℝ)-2*j.val+1))
    (fun i => singletonSlope d*labelReal (a i))

theorem pointFeature_preactivation {d : ℕ} (a x : Cube d) (j : Fin (d+1)) :
    (∑ k, pointFeatureWeights a j k*inputVector x k) =
      if j=0 then 1 else singletonSlope d*(2*j.val-2*(hammingShell a x : ℝ)-1) := by
  unfold pointFeatureWeights
  split_ifs with hj
  · rw [Fin.sum_univ_succ]
    simp [inputVector]
  · rw [Fin.sum_univ_succ]
    simp only [Fin.cases_zero, Fin.cases_succ, inputVector, mul_one]
    simp_rw [mul_assoc, ← Finset.mul_sum, label_dot_shell]
    ring

theorem pointFeature_value {d : ℕ} (a x : Cube d) (j : Fin (d+1)) :
    Real.tanh (∑ k, pointFeatureWeights a j k*inputVector x k) = shellFeature (shellIndex a x) j := by
  rw [pointFeature_preactivation]
  by_cases hj : j=0 <;> simp [shellFeature, hj, shellIndex]

def firstFeatureBudget (d : ℕ) : ℝ := 1+(singletonSlope d)^2*d*(d+1 : ℝ)

theorem pointFeature_row_bound {d : ℕ} (a : Cube d) (j : Fin (d+1)) :
    (∑ k, (pointFeatureWeights a j k)^2) ≤ firstFeatureBudget d := by
  by_cases hj : j=0
  · simp only [pointFeatureWeights, hj, ↓reduceIte]
    rw [Fin.sum_univ_succ]
    simp only [Fin.cases_zero, Fin.cases_succ, one_pow, zero_pow (by norm_num : 2 ≠ 0), Finset.sum_const_zero, add_zero]
    unfold firstFeatureBudget
    have h : 0 ≤ (singletonSlope d)^2*(d : ℝ)*(d+1 : ℝ) := by positivity
    linarith
  · have hjp : (1 : ℝ) ≤ j.val := by
      have hn : 0 < j.val := Nat.pos_of_ne_zero (by intro h; exact hj (Fin.ext h))
      exact_mod_cast hn
    have hjd : (j.val : ℝ) ≤ d := by exact_mod_cast Nat.le_of_lt_succ j.isLt
    have hlabel (i : Fin d) : (labelReal (a i))^2=1 := by cases a i <;> norm_num [labelReal]
    simp only [pointFeatureWeights, hj, ↓reduceIte]
    rw [Fin.sum_univ_succ]
    simp only [Fin.cases_zero, Fin.cases_succ, mul_pow, neg_sq, hlabel, mul_one, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    have hd : (0 : ℝ) ≤ d := Nat.cast_nonneg d
    have hs : ((d : ℝ)-2*j.val+1)^2 ≤ (d : ℝ)^2 := by nlinarith
    have hm := mul_le_mul_of_nonneg_left hs (sq_nonneg (singletonSlope d))
    unfold firstFeatureBudget
    nlinarith

theorem exists_exact_point_features {d : ℕ} (hd : 0 < d) (a : Cube d) :
    ∃ b : Fin (d+1) → ℝ, vectorL1 b ≤ 4 ∧
      (∀ x : Cube d, (∑ j, b j*Real.tanh (∑ k, pointFeatureWeights a j k*inputVector x k)) =
        if x=a then 1 else 0) ∧
      (∀ j, (∑ k, (pointFeatureWeights a j k)^2) ≤ firstFeatureBudget d) := by
  obtain ⟨b,hb,hinterp⟩ := exists_exact_shell_indicator d hd
  refine ⟨b,hb,?_,pointFeature_row_bound a⟩
  intro x
  simp_rw [pointFeature_value]
  rw [hinterp]
  simp only [shellIndex_eq_zero]

end
end NeuralGeneralization.BatchTwoNeuralConverse
