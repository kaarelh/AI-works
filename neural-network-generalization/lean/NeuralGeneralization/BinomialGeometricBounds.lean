import NeuralGeneralization.BinomialModeBound

/-! Elementary geometric growth bounds for binomial coefficients below one third
of the ambient dimension.  These bounds retain the extra inverse-level factor
needed in the spectral second moment. -/
noncomputable section
namespace NeuralGeneralization.BinomialGeometry
open scoped BigOperators

theorem choose_double {D j : ℕ} (h : 3*j+2 ≤ D) :
    2*D.choose j ≤ D.choose (j+1) := by
  have hj : j ≤ D := by omega
  have hr : 2*(j+1) ≤ D-j := by omega
  have hh := Nat.mul_le_mul_left (D.choose j) hr
  rw [← Nat.choose_succ_right_eq D j] at hh
  apply Nat.le_of_mul_le_mul_right (c := j+1) _ (by omega)
  nlinarith only [hh]

theorem choose_growth {D k j B : ℕ} (hkj : k ≤ j) (hjB : j ≤ B)
    (hB : 3*B ≤ D) :
    2^(j-k)*D.choose k ≤ D.choose j := by
  induction j, hkj using Nat.le_induction with
  | base => simp
  | succ j hkj ih =>
    have ih' := ih (by omega)
    have hd := choose_double (D:=D) (j:=j) (by omega)
    have he : j+1-k=(j-k)+1 := by omega
    rw [he, pow_succ]
    nlinarith only [ih', hd]

theorem choose_sum_range_le {D r : ℕ} (hr : 3*r ≤ D) :
    (∑ j ∈ Finset.range (r+1), D.choose j) ≤ 2*D.choose r := by
  induction r with
  | zero => simp
  | succ r ih =>
    rw [Finset.sum_range_succ]
    have ih' := ih (by omega)
    have hd := choose_double (D:=D) (j:=r) (by omega)
    omega

theorem choose_growth_multiple {D k B : ℕ} (hkB : 2*k ≤ B) (hB : 3*B ≤ D) :
    k*D.choose k ≤ D.choose B := by
  have hkg : k ≤ B-k := by omega
  have hkpow : k ≤ 2^(B-k) := by
    exact (Nat.lt_two_pow_self (n:=k)).le.trans
      (Nat.pow_le_pow_right (by omega : 0<2) hkg)
  exact (Nat.mul_le_mul_right _ hkpow).trans (choose_growth (by omega) le_rfl hB)

theorem reciprocal_choose_sum {D k n : ℕ} (h : 3*(k+n) ≤ D) :
    (∑ j ∈ Finset.range n, 1/(D.choose (k+j):ℝ)) ≤ 2/(D.choose k:ℝ) := by
  induction n generalizing k with
  | zero => simp; positivity
  | succ n ih =>
    rw [Finset.sum_range_succ']
    have he : (∑ j ∈ Finset.range n, 1/(D.choose (k+(j+1)):ℝ)) =
        ∑ j ∈ Finset.range n, 1/(D.choose (k+1+j):ℝ) := by
      apply Finset.sum_congr rfl
      intro j _
      rw [show k+(j+1)=k+1+j by omega]
    rw [he]
    have hsum := ih (k:=k+1) (by omega)
    have hp : (0:ℝ)<D.choose k := by exact_mod_cast Nat.choose_pos (by omega : k≤D)
    have hp' : (0:ℝ)<D.choose (k+1) := by
      exact_mod_cast Nat.choose_pos (by omega : k+1≤D)
    have hd : 2*(D.choose k:ℝ) ≤ D.choose (k+1) := by
      exact_mod_cast choose_double (D:=D) (j:=k) (by omega)
    have hinv : 2/(D.choose (k+1):ℝ) ≤ 1/(D.choose k:ℝ) := by
      apply (div_le_div_iff₀ hp' hp).mpr
      simpa using hd
    simp only [Nat.add_zero]
    calc
      _ ≤ 1/(D.choose k:ℝ)+1/(D.choose k:ℝ) :=
        by linarith only [hsum.trans hinv]
      _ = _ := by ring

theorem reciprocal_choose_Ico {D k B : ℕ} (hkB : k ≤ B) (hB : 3*(B+1) ≤ D) :
    (∑ j ∈ Finset.Ico k (B+1), 1/(D.choose j:ℝ)) ≤ 2/(D.choose k:ℝ) := by
  rw [Finset.sum_Ico_eq_sum_range]
  exact reciprocal_choose_sum (by omega)

end NeuralGeneralization.BinomialGeometry
