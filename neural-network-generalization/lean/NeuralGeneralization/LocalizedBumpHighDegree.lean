import NeuralGeneralization.LocalizedBumpEnergyBounds

/-! # Exponential decay above forty-nine percent of the cube dimension -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump

lemma coefficient_le_relative_powers {d j : ℕ} (hj : j ≤ d) :
    coefficient d j ≤ (3/5:ℝ)^d*(27/40:ℝ)^j := by
  apply (coefficient_le_endpoint_powers d j).trans_eq
  rw [show (81/200:ℝ)=(3/5)*(27/40) by norm_num, mul_pow]
  rw [mul_right_comm, ← pow_add, Nat.add_sub_of_le hj]

/-- The numerical constants are deliberately rational. Raising to the
fiftieth power proves exponential decay without asymptotic notation. -/
theorem high_coefficient_exponential {d j : ℕ} (hj : j ≤ d) (hhigh : 49*d ≤ 100*j) :
    (4:ℝ)^d*coefficient d j^2 ≤ (99/100:ℝ)^d := by
  have hc := (sq_le_sq₀ (coefficient_nonneg d j) (by positivity)).mpr (coefficient_le_relative_powers hj)
  have hbase : (4:ℝ)^d*coefficient d j^2 ≤ (36/25:ℝ)^d*(27/40:ℝ)^(2*j) := by
    calc
      _ ≤ (4:ℝ)^d*((3/5:ℝ)^d*(27/40:ℝ)^j)^2 := mul_le_mul_of_nonneg_left hc (by positivity)
      _ = _ := by rw [mul_pow, ← pow_mul, mul_comm d 2, pow_mul, ← mul_assoc, ← mul_pow, ← pow_mul, mul_comm j 2]; norm_num
  have hpow : ((36/25:ℝ)^d*(27/40:ℝ)^(2*j))^50 ≤ ((99/100:ℝ)^d)^50 := by
    calc
      _ = (36/25:ℝ)^(50*d)*(27/40:ℝ)^(100*j) := by rw [mul_pow, ← pow_mul, ← pow_mul]; congr 2 <;> omega
      _ ≤ (36/25:ℝ)^(50*d)*(27/40:ℝ)^(49*d) :=
        mul_le_mul_of_nonneg_left (pow_le_pow_of_le_one (by norm_num) (by norm_num) hhigh) (by positivity)
      _ = ((36/25:ℝ)^50*(27/40:ℝ)^49)^d := by rw [mul_pow, ← pow_mul, ← pow_mul]
      _ ≤ (((99/100:ℝ)^50))^d := pow_le_pow_left₀ (by positivity) (by norm_num) _
      _ = _ := by rw [← pow_mul, ← pow_mul]; congr 1; omega
  have hn : (36/25:ℝ)^d*(27/40:ℝ)^(2*j) ≤ (99/100:ℝ)^d := by
    by_contra hh
    have hl := pow_lt_pow_left₀ (lt_of_not_ge hh) (by positivity : (0:ℝ) ≤ (99/100:ℝ)^d) (by norm_num : 50 ≠ 0)
    exact (not_lt_of_ge hpow) hl
  exact hbase.trans hn

/-- The entire high-degree contribution decays exponentially, using only
the polynomial lower bound on the full covariance matrix. -/
theorem high_diagonalEnergy_exponential {d : ℕ} (w : Finset (Fin d) → ℝ)
    (hw : ∀ S, 0 < w S) (v : ℝ) (hv : 0 < v)
    (hfloor : ∀ S, v ≤ (2:ℝ)^d*w S) :
    (∑ S ∈ Finset.univ.filter (fun S : Finset (Fin d) => 49*d ≤ 100*S.card),
      coefficient d S.card^2/w S) ≤ (99/100:ℝ)^d/v := by
  classical
  have hpoint (S : Finset (Fin d)) (hS : S ∈ Finset.univ.filter (fun S : Finset (Fin d) => 49*d ≤ 100*S.card)) :
      coefficient d S.card^2/w S ≤ (99/100:ℝ)^d/((2:ℝ)^d*v) := by
    have hc := high_coefficient_exponential
      (show S.card ≤ d by simpa using Finset.card_le_univ S) (Finset.mem_filter.mp hS).2
    apply (div_le_div_iff₀ (hw S) (mul_pos (by positivity) hv)).mpr
    have hm := mul_le_mul_of_nonneg_left (hfloor S) (show 0 ≤ (2:ℝ)^d*coefficient d S.card^2 by positivity)
    have hc' := mul_le_mul_of_nonneg_right hc (hw S).le
    have hp : (2:ℝ)^d*(2:ℝ)^d=(4:ℝ)^d := by rw [← mul_pow]; norm_num
    rw [← hp] at hc'
    nlinarith
  calc
    _ ≤ ∑ _S ∈ Finset.univ.filter (fun S : Finset (Fin d) => 49*d ≤ 100*S.card),
      (99/100:ℝ)^d/((2:ℝ)^d*v) := Finset.sum_le_sum hpoint
    _ ≤ ∑ _S : Finset (Fin d), (99/100:ℝ)^d/((2:ℝ)^d*v) :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) (fun S _ _ => by positivity)
    _ = _ := by simp [Fintype.card_finset]; field_simp

/-- Combining actual low-mode spectral control with the unconditional
high-mode estimate gives the full single-bump energy. -/
theorem diagonalEnergy_le_low_plus_exponential {d : ℕ} (w : Finset (Fin d) → ℝ)
    (hw : ∀ S, 0 < w S) (v ell : ℝ) (hv : 0 < v) (hell : 0 < ell)
    (hfloor : ∀ S, v ≤ (2:ℝ)^d*w S)
    (hlow : ∀ S, 100*S.card < 49*d → ell ≤ (d.choose S.card:ℝ)*w S) :
    diagonalEnergy w ≤ 40000/((d+1:ℝ)*ell)+(99/100:ℝ)^d/v := by
  classical
  let L := Finset.univ.filter (fun S : Finset (Fin d) => 100*S.card < 49*d)
  have hlo := low_diagonalEnergy_le w hw L ell hell
    (fun S hS => hlow S (Finset.mem_filter.mp hS).2)
  have hhi := high_diagonalEnergy_exponential w hw v hv hfloor
  have heq : diagonalEnergy w =
      (∑ S ∈ L, coefficient d S.card^2/w S)+
        ∑ S ∈ Finset.univ.filter (fun S : Finset (Fin d) => 49*d ≤ 100*S.card),
          coefficient d S.card^2/w S := by
    unfold diagonalEnergy L
    rw [Finset.sum_filter, Finset.sum_filter, ← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro S hS
    by_cases hS : 100*S.card < 49*d
    · simp [hS, Nat.not_le_of_gt hS]
    · simp [hS, Nat.le_of_not_gt hS]
  rw [heq]
  exact add_le_add hlo hhi

end NeuralGeneralization.LocalizedCubeBump
