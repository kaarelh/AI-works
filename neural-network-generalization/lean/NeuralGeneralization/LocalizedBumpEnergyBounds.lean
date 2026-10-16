import NeuralGeneralization.LocalizedBumpEnergy

/-! # Quantitative diagonal energy bounds for the concrete averaged bump -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
variable {d : ℕ}

lemma sum_by_card (F : ℕ → ℝ) :
    (∑ S : Finset (Fin d), F S.card) = ∑ j ∈ Finset.range (d+1), (d.choose j:ℝ)*F j := by
  classical
  have h := Finset.sum_powerset (Finset.univ : Finset (Fin d)) (fun S => F S.card)
  have hu : (Finset.univ : Finset (Fin d)).powerset = Finset.univ := by ext S; simp
  rw [hu] at h
  simp only [Finset.card_univ, Fintype.card_fin, Finset.sum_powersetCard, nsmul_eq_mul] at h
  exact h

lemma choose_squared_coefficient_le {j : ℕ} (hj : j ≤ d) :
    (d.choose j:ℝ)^2*coefficient d j^2 ≤ 40000/(d+1:ℝ)^2 := by
  have hh := choose_mul_coefficient_le hj
  have hn := coefficient_nonneg d j
  have hd : (0:ℝ) < d+1 := by positivity
  have hs : ((d.choose j:ℝ)*coefficient d j)^2 ≤ (200/(d+1:ℝ))^2 :=
    sq_le_sq₀ (by positivity) (by positivity) |>.mpr hh
  norm_num only [mul_pow, div_pow, show (200:ℝ)^2=40000 by norm_num] at hs
  exact hs

lemma weighted_coefficient_sum_le :
    (∑ S : Finset (Fin d), (d.choose S.card:ℝ)*coefficient d S.card^2) ≤ 40000/(d+1:ℝ) := by
  rw [sum_by_card (fun j => (d.choose j:ℝ)*coefficient d j^2)]
  calc
    _ ≤ ∑ _j ∈ Finset.range (d+1), 40000/(d+1:ℝ)^2 := by
      apply Finset.sum_le_sum
      intro j hj
      simpa only [pow_two, mul_assoc] using choose_squared_coefficient_le (Nat.lt_succ_iff.mp (Finset.mem_range.mp hj))
    _ = _ := by simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul, Nat.cast_add, Nat.cast_one]; field_simp

/-- On any family of low modes, a binomial lower bound on the actual
population eigenvalue gives the needed dimension-polynomial bump energy. -/
theorem low_diagonalEnergy_le (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (L : Finset (Finset (Fin d))) (ell : ℝ) (hell : 0 < ell)
    (hlow : ∀ S ∈ L, ell ≤ (d.choose S.card:ℝ)*w S) :
    (∑ S ∈ L, coefficient d S.card^2/w S) ≤ 40000/((d+1:ℝ)*ell) := by
  have hpoint (S : Finset (Fin d)) (hS : S ∈ L) :
      coefficient d S.card^2/w S ≤ ((d.choose S.card:ℝ)*coefficient d S.card^2)/ell := by
    apply (div_le_div_iff₀ (hw S) hell).mpr
    nlinarith [mul_le_mul_of_nonneg_right (hlow S hS) (sq_nonneg (coefficient d S.card))]
  calc
    _ ≤ ∑ S ∈ L, ((d.choose S.card:ℝ)*coefficient d S.card^2)/ell := Finset.sum_le_sum hpoint
    _ ≤ ∑ S : Finset (Fin d), ((d.choose S.card:ℝ)*coefficient d S.card^2)/ell :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ L) (fun S _ _ => by positivity)
    _ = (∑ S : Finset (Fin d), (d.choose S.card:ℝ)*coefficient d S.card^2)/ell := by rw [Finset.sum_div]
    _ ≤ (40000/(d+1:ℝ))/ell := div_le_div_of_nonneg_right weighted_coefficient_sum_le hell.le
    _ = _ := by rw [div_div]

/-- The polynomial full-matrix floor controls a set of remaining modes
once their individual Fourier coefficients have been bounded. -/
theorem high_diagonalEnergy_le (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (H : Finset (Finset (Fin d))) (v B : ℝ) (hv : 0 < v) (hB : 0 ≤ B)
    (hfloor : ∀ S, v ≤ (2:ℝ)^d*w S)
    (hcoeff : ∀ S ∈ H, coefficient d S.card ≤ B) :
    (∑ S ∈ H, coefficient d S.card^2/w S) ≤ (4:ℝ)^d*B^2/v := by
  have hpoint (S : Finset (Fin d)) (hS : S ∈ H) :
      coefficient d S.card^2/w S ≤ (2:ℝ)^d*B^2/v := by
    apply (div_le_div_iff₀ (hw S) hv).mpr
    have hc := (sq_le_sq₀ (coefficient_nonneg d S.card) hB).mpr (hcoeff S hS)
    have h1 := mul_le_mul_of_nonneg_right (hfloor S) (sq_nonneg (coefficient d S.card))
    have h2 := mul_le_mul_of_nonneg_left hc
      (show 0 ≤ (2:ℝ)^d*w S from mul_nonneg (by positivity) (hw S).le)
    nlinarith
  calc
    _ ≤ ∑ _S ∈ H, (2:ℝ)^d*B^2/v := Finset.sum_le_sum hpoint
    _ ≤ ∑ _S : Finset (Fin d), (2:ℝ)^d*B^2/v :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ H) (fun S _ _ => by positivity)
    _ = _ := by
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_finset, Fintype.card_fin,
        nsmul_eq_mul, Nat.cast_pow, Nat.cast_ofNat]
      have hp : (2:ℝ)^d*(2:ℝ)^d=(4:ℝ)^d := by rw [← mul_pow]; norm_num
      linear_combination (B^2/v)*hp

/-- A full matrix eigenvalue floor gives exponentially small maximum
coordinates for the cross-energy covariance. -/
theorem coefficient_energy_max_le (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (v : ℝ) (hv : 0 < v) (hfloor : ∀ S, v ≤ (2:ℝ)^d*w S)
    (S : Finset (Fin d)) :
    coefficient d S.card^2/w S ≤ (18/25:ℝ)^d/v := by
  have hc := coefficient_le_three_fifths (d:=d)
    (show S.card ≤ d by simpa using Finset.card_le_univ S)
  have hs := (sq_le_sq₀ (coefficient_nonneg d S.card) (by positivity)).mpr hc
  apply (div_le_div_iff₀ (hw S) hv).mpr
  calc
    _ ≤ ((3/5:ℝ)^d)^2*((2:ℝ)^d*w S) :=
      mul_le_mul hs (hfloor S) hv.le (sq_nonneg _)
    _ = _ := by rw [← pow_mul, mul_comm d 2, pow_mul, ← mul_assoc, ← mul_pow]; norm_num

end NeuralGeneralization.LocalizedCubeBump
