import NeuralGeneralization.ClippedParity
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

/-!
# Walsh characters and the degree bound for the cube Laplacian

This module supplies finite Fourier identities used by the clipping argument.
It does not assume or prove the neural kernel spectrum or sampling theorem.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators

def walshCharacter {d : ℕ} (S : Finset (Fin d)) (x : ClippingCube d) : ℝ :=
  ∏ i ∈ S, cubeCoordinateSign (x i)

theorem cubeCoordinateSign_sq (b : Bool) : cubeCoordinateSign b ^ 2 = 1 := by
  cases b <;> norm_num [cubeCoordinateSign]

theorem walshCharacter_sq {d : ℕ} (S : Finset (Fin d)) (x : ClippingCube d) :
    walshCharacter S x ^ 2 = 1 := by
  simp only [walshCharacter, ← Finset.prod_pow, cubeCoordinateSign_sq,
    Finset.prod_const_one]

theorem walshCharacter_flip {d : ℕ} (S : Finset (Fin d)) (i : Fin d)
    (x : ClippingCube d) :
    walshCharacter S (cubeFlip i x) =
      if i ∈ S then -walshCharacter S x else walshCharacter S x := by
  classical
  by_cases hi : i ∈ S
  · rw [if_pos hi]
    have hprod (z : ClippingCube d) : walshCharacter S z =
        cubeCoordinateSign (z i) * ∏ j ∈ S.erase i, cubeCoordinateSign (z j) :=
      (Finset.mul_prod_erase S (fun j => cubeCoordinateSign (z j)) hi).symm
    have hrest : (∏ j ∈ S.erase i, cubeCoordinateSign (cubeFlip i x j)) =
        ∏ j ∈ S.erase i, cubeCoordinateSign (x j) := by
      apply Finset.prod_congr rfl
      intro j hj
      have hji : j ≠ i := (Finset.mem_erase.mp hj).1
      simp [cubeFlip, Function.update_of_ne hji]
    rw [hprod (cubeFlip i x), hrest, hprod x]
    simp only [cubeFlip, Equiv.coe_fn_mk, Function.update_self]
    rw [cubeCoordinateSign_not]
    ring
  · rw [if_neg hi]
    unfold walshCharacter
    apply Finset.prod_congr rfl
    intro j hj
    have hji : j ≠ i := by intro h; subst j; exact hi hj
    simp [cubeFlip, Function.update_of_ne hji]

theorem walshCharacter_orthogonal {d : ℕ} (S T : Finset (Fin d)) :
    (∑ x : ClippingCube d, walshCharacter S x * walshCharacter T x) =
      if S = T then (Fintype.card (ClippingCube d) : ℝ) else 0 := by
  classical
  by_cases hST : S = T
  · subst T
    simp only [ite_true, ← pow_two, walshCharacter_sq, Finset.sum_const,
      Finset.card_univ, nsmul_eq_mul, mul_one]
  · rw [if_neg hST]
    have hex : ∃ i, ¬(i ∈ S ↔ i ∈ T) := by
      by_contra h
      apply hST
      ext i
      exact not_not.mp (not_exists.mp h i)
    obtain ⟨i, hi⟩ := hex
    have hflip (x : ClippingCube d) :
        walshCharacter S (cubeFlip i x) * walshCharacter T (cubeFlip i x) =
          -(walshCharacter S x * walshCharacter T x) := by
      rw [walshCharacter_flip, walshCharacter_flip]
      by_cases hs : i ∈ S <;> by_cases ht : i ∈ T <;> simp_all
    have hsum := (cubeFlip i).sum_comp
      (fun x => walshCharacter S x * walshCharacter T x)
    simp_rw [hflip] at hsum
    rw [Finset.sum_neg_distrib] at hsum
    linarith

theorem cubeLaplacian_walshCharacter {d : ℕ} (S : Finset (Fin d))
    (x : ClippingCube d) :
    cubeLaplacian (walshCharacter S) x = (S.card : ℝ) * walshCharacter S x := by
  classical
  unfold cubeLaplacian
  have hterm (i : Fin d) :
      walshCharacter S x - walshCharacter S (cubeFlip i x) =
        if i ∈ S then 2 * walshCharacter S x else 0 := by
    rw [walshCharacter_flip]
    by_cases hi : i ∈ S
    · simp [hi]
      ring
    · simp [hi]
  simp_rw [hterm]
  rw [Fintype.sum_ite_mem]
  simp only [Finset.sum_const, nsmul_eq_mul]
  ring

/-- A finite Walsh expansion. Degree at most `u` means its coefficients
vanish for all subsets of cardinality greater than `u`. -/
def walshExpansion {d : ℕ} (a : Finset (Fin d) → ℝ) (x : ClippingCube d) : ℝ :=
  ∑ S, a S * walshCharacter S x

theorem walshExpansion_inner {d : ℕ} (a b : Finset (Fin d) → ℝ) :
    (∑ x : ClippingCube d, walshExpansion a x * walshExpansion b x) =
      (Fintype.card (ClippingCube d) : ℝ) * ∑ S, a S * b S := by
  classical
  unfold walshExpansion
  simp_rw [Finset.sum_mul, Finset.mul_sum]
  calc
    (∑ x : ClippingCube d, ∑ S, ∑ T,
        (a S * walshCharacter S x) * (b T * walshCharacter T x)) =
        ∑ S, ∑ x : ClippingCube d, ∑ T,
          (a S * walshCharacter S x) * (b T * walshCharacter T x) := by
      rw [Finset.sum_comm]
    _ = ∑ S, ∑ T, ∑ x : ClippingCube d,
          (a S * walshCharacter S x) * (b T * walshCharacter T x) := by
      apply Finset.sum_congr rfl
      intro S hS
      rw [Finset.sum_comm]
    _ = ∑ S, ∑ T, a S * b T *
          (∑ x : ClippingCube d, walshCharacter S x * walshCharacter T x) := by
      apply Finset.sum_congr rfl
      intro S hS
      apply Finset.sum_congr rfl
      intro T hT
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro x hx
      ring
    _ = ∑ S, a S * b S * (Fintype.card (ClippingCube d) : ℝ) := by
      simp_rw [walshCharacter_orthogonal, mul_ite, mul_zero]
      simp
    _ = _ := by
      apply Finset.sum_congr rfl
      intro S hS
      ring

theorem walshExpansion_parseval {d : ℕ} (a : Finset (Fin d) → ℝ) :
    (∑ x : ClippingCube d, walshExpansion a x ^ 2) =
      (Fintype.card (ClippingCube d) : ℝ) * ∑ S, a S ^ 2 := by
  simpa only [pow_two] using walshExpansion_inner a a

theorem cubeLaplacian_walshExpansion {d : ℕ} (a : Finset (Fin d) → ℝ)
    (x : ClippingCube d) :
    cubeLaplacian (walshExpansion a) x =
      walshExpansion (fun S => (S.card : ℝ) * a S) x := by
  classical
  unfold cubeLaplacian walshExpansion
  simp_rw [← Finset.sum_sub_distrib]
  rw [Finset.sum_comm, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro S hS
  calc
    (∑ i, (a S * walshCharacter S x - a S * walshCharacter S (cubeFlip i x))) / 2 =
        a S * cubeLaplacian (walshCharacter S) x := by
      unfold cubeLaplacian
      simp_rw [← mul_sub]
      rw [← Finset.mul_sum]
      ring
    _ = (S.card : ℝ) * a S * walshCharacter S x := by
      rw [cubeLaplacian_walshCharacter]
      ring

/-- The squared `L²` degree bound, proved directly from finite Walsh
orthogonality. No kernel-spectrum or sampling hypothesis is used. -/
theorem cubeLaplacian_degree_bound {d u : ℕ} (a : Finset (Fin d) → ℝ)
    (hdegree : ∀ S, a S ≠ 0 → S.card ≤ u) :
    (∑ x : ClippingCube d, cubeLaplacian (walshExpansion a) x ^ 2) ≤
      (u : ℝ) ^ 2 * ∑ x : ClippingCube d, walshExpansion a x ^ 2 := by
  classical
  simp_rw [cubeLaplacian_walshExpansion]
  rw [walshExpansion_parseval, walshExpansion_parseval]
  have hterm (S : Finset (Fin d)) :
      ((S.card : ℝ) * a S) ^ 2 ≤ (u : ℝ) ^ 2 * a S ^ 2 := by
    by_cases ha : a S = 0
    · simp [ha]
    · have hcard : (S.card : ℝ) ≤ u := Nat.cast_le.mpr (hdegree S ha)
      have hsq : (S.card : ℝ) ^ 2 ≤ (u : ℝ) ^ 2 := by
        nlinarith [show (0 : ℝ) ≤ S.card from Nat.cast_nonneg _,
          show (0 : ℝ) ≤ u from Nat.cast_nonneg _]
      have h := mul_le_mul_of_nonneg_right hsq (sq_nonneg (a S))
      nlinarith [h]
  have hsum := Finset.sum_le_sum (fun S (_ : S ∈ Finset.univ) => hterm S)
  have hscaled := mul_le_mul_of_nonneg_left hsum
    (Nat.cast_nonneg (Fintype.card (ClippingCube d)) :
      (0 : ℝ) ≤ Fintype.card (ClippingCube d))
  rw [← Finset.mul_sum] at hscaled
  nlinarith [hscaled]

theorem uniformCubeMean_sq_le {d : ℕ} (P : ClippingCube d → ℝ) :
    uniformCubeMean P ^ 2 ≤ uniformCubeMean (fun x => P x ^ 2) := by
  have hM : (0 : ℝ) < Fintype.card (ClippingCube d) :=
    Nat.cast_pos.mpr Fintype.card_pos
  have hCS : (∑ x, P x) ^ 2 ≤
      (Fintype.card (ClippingCube d) : ℝ) * ∑ x, P x ^ 2 := by
    simpa only [one_mul, one_pow, Finset.sum_const, Finset.card_univ,
      nsmul_eq_mul, mul_one] using
      Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (fun _ : ClippingCube d => (1 : ℝ)) P
  unfold uniformCubeMean
  rw [div_pow]
  apply (div_le_iff₀ (sq_pos_of_pos hM)).2
  calc
    (∑ x, P x) ^ 2 ≤ (Fintype.card (ClippingCube d) : ℝ) * ∑ x, P x ^ 2 := hCS
    _ = ((∑ x, P x ^ 2) / Fintype.card (ClippingCube d)) *
        (Fintype.card (ClippingCube d) : ℝ) ^ 2 := by
      field_simp [ne_of_gt hM]

theorem uniformCubeMean_nonneg {d : ℕ} (P : ClippingCube d → ℝ)
    (hP : ∀ x, 0 ≤ P x) : 0 ≤ uniformCubeMean P := by
  exact div_nonneg (Finset.sum_nonneg (fun x hx => hP x)) (Nat.cast_nonneg _)

/-- The clipped-correlation degree bound, in a square-root-free form
equivalent to `|E[f clip(P/b)]| <= u * ||P||₂ / (b*d)`.
All Fourier and averaging facts in this statement are proved here. -/
theorem cube_clipped_parity_degree_bound_squared {d u : ℕ} (hd : 0 < d)
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ u)
    (b : ℝ) (hb : 0 < b) :
    (b * (d : ℝ)) ^ 2 *
      uniformCubeMean (fun x => fullParity x * symmetricClip b (walshExpansion a x)) ^ 2 ≤
        (u : ℝ) ^ 2 * uniformCubeMean (fun x => walshExpansion a x ^ 2) := by
  have hB : 0 < b * (d : ℝ) := mul_pos hb (Nat.cast_pos.mpr hd)
  have hclip := cube_clipped_parity_mean_bound hd (walshExpansion a) b hb
  have hscaled := (le_div_iff₀ hB).mp hclip
  have hnonneg := uniformCubeMean_nonneg
    (fun x => |cubeLaplacian (walshExpansion a) x|) (fun x => abs_nonneg _)
  have hsq := mul_le_mul hscaled hscaled
    (mul_nonneg (abs_nonneg _) hB.le) hnonneg
  simp only [← pow_two] at hsq
  have hCS := uniformCubeMean_sq_le (fun x => |cubeLaplacian (walshExpansion a) x|)
  simp only [sq_abs] at hCS
  have hdegreeMean : uniformCubeMean (fun x => cubeLaplacian (walshExpansion a) x ^ 2) ≤
      (u : ℝ) ^ 2 * uniformCubeMean (fun x => walshExpansion a x ^ 2) := by
    have h := div_le_div_of_nonneg_right (cubeLaplacian_degree_bound a hdegree)
      (Nat.cast_nonneg (Fintype.card (ClippingCube d)) :
        (0 : ℝ) ≤ Fintype.card (ClippingCube d))
    simpa only [uniformCubeMean, mul_div_assoc] using h
  have hfinal := hsq.trans (hCS.trans hdegreeMean)
  simpa only [← pow_two, mul_pow, sq_abs, mul_comm] using hfinal

end NeuralGeneralization
