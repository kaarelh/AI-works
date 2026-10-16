import NeuralGeneralization.WalshLaplacian

/-!
# One-sided squared amplitudes of low-degree parity polynomials

A finite Markov argument gives the population coercivity required by the
one-sided squared sampling step. The argument uses the already proved
Laplacian degree bound; no sampling or concentration assumption is made.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators

private theorem positivePart_sub_le (a b : ℝ) :
    max 0 a ≤ max 0 b + |a - b| := by
  apply max_le
  · positivity
  · have hb : b ≤ max 0 b := le_max_right _ _
    have hab : a - b ≤ |a - b| := le_abs_self _
    linarith

/-- A convenient numerical form of Young's inequality for positive parts. -/
theorem positivePart_square_young (a b : ℝ) :
    2 * (max 0 a) ^ 2 ≤ 3 * (max 0 b) ^ 2 + 6 * (a - b) ^ 2 := by
  have h := positivePart_sub_le a b
  have hs : (max 0 a) ^ 2 ≤ (max 0 b + |a - b|) ^ 2 :=
    pow_le_pow_left₀ (le_max_left _ _) h 2
  nlinarith [sq_nonneg (max 0 b - 2 * |a - b|), sq_abs (a - b)]

/-- The positive-part squared norm contracts under a finite doubly stochastic
Markov transition. -/
theorem sum_positivePart_markov_square_le {α : Type*} [Fintype α]
    (T : α → α → ℝ) (hT : DoublyStochastic T) (q : α → ℝ) :
    (∑ x, (max 0 (markovAverage T q x)) ^ 2) ≤
      ∑ x, (max 0 (q x)) ^ 2 := by
  have hpoint (x : α) : (max 0 (markovAverage T q x)) ^ 2 ≤
      ∑ y, T x y * (max 0 (q y)) ^ 2 := by
    have hpos : max 0 (markovAverage T q x) ≤
        ∑ y, T x y * max 0 (q y) := by
      apply max_le
      · exact Finset.sum_nonneg (fun y _ => mul_nonneg (hT.nonneg x y) (le_max_left _ _))
      · exact Finset.sum_le_sum (fun y _ =>
          mul_le_mul_of_nonneg_left (le_max_right _ _) (hT.nonneg x y))
    have hCS : (∑ y, T x y * max 0 (q y)) ^ 2 ≤
        (∑ y, T x y) * ∑ y, T x y * (max 0 (q y)) ^ 2 := by
      apply Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul
      · intro y _; exact hT.nonneg x y
      · intro y _; exact mul_nonneg (hT.nonneg x y) (sq_nonneg _)
      · intro y _; nlinarith
    rw [hT.row_sum, one_mul] at hCS
    exact (pow_le_pow_left₀ (le_max_left _ _) hpos 2).trans hCS
  calc
    _ ≤ ∑ x, ∑ y, T x y * (max 0 (q y)) ^ 2 :=
      Finset.sum_le_sum (fun x _ => hpoint x)
    _ = _ := by
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro y _
      rw [← Finset.sum_mul, hT.col_sum, one_mul]

/-- If a Markov step almost reverses `q`, neither one-sided square can carry
almost all of its energy. This is a purely finite identity and inequality. -/
theorem sum_negativePart_square_markov_coercivity {α : Type*} [Fintype α]
    (T : α → α → ℝ) (hT : DoublyStochastic T) (q : α → ℝ) :
    2 * (∑ x, q x ^ 2) ≤ 5 * (∑ x, (max 0 (-q x)) ^ 2) +
      6 * ∑ x, (markovAverage T q x + q x) ^ 2 := by
  have hneg (x : α) : markovAverage T (fun y => -q y) x =
      -markovAverage T q x := by
    simp [markovAverage, mul_neg, Finset.sum_neg_distrib]
  have hcontract := sum_positivePart_markov_square_le T hT (fun y => -q y)
  simp_rw [hneg] at hcontract
  have hyoung := Finset.sum_le_sum (fun x (_ : x ∈ Finset.univ) =>
    positivePart_square_young (q x) (-markovAverage T q x))
  have hid (x : α) : q x - -markovAverage T q x = markovAverage T q x + q x := by ring
  simp_rw [hid] at hyoung
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum] at hyoung
  have hsplit (x : α) : q x ^ 2 = (max 0 (q x)) ^ 2 + (max 0 (-q x)) ^ 2 := by
    by_cases hq : 0 ≤ q x
    · simp [max_eq_right hq, max_eq_left (neg_nonpos.mpr hq)]
    · have hq' : q x ≤ 0 := le_of_not_ge hq
      simp [max_eq_left hq', max_eq_right (neg_nonneg.mpr hq')]
  have hsum : (∑ x, q x ^ 2) = (∑ x, (max 0 (q x)) ^ 2) +
      ∑ x, (max 0 (-q x)) ^ 2 := by simp_rw [hsplit, Finset.sum_add_distrib]
  linarith

/-- An explicit square-root-free population bound for a Walsh polynomial.
It is sufficient for the paper's `3/8` coercivity at degree at most `d/64`. -/
theorem parity_negativePart_square_degree_bound {d u : ℕ} (hd : 0 < d)
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ u) :
    (2 * (d : ℝ) ^ 2 - 24 * (u : ℝ) ^ 2) *
        (∑ x, walshExpansion a x ^ 2) ≤
      5 * (d : ℝ) ^ 2 *
        ∑ x, (max 0 (-(fullParity x * walshExpansion a x))) ^ 2 := by
  let P := walshExpansion a
  let T := permutationKernel (@cubeFlip d)
  have hdreal : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have hT : DoublyStochastic T := permutationKernel_doublyStochastic cubeFlip (by
    simpa using ne_of_gt hdreal)
  have hflip := permutationKernel_bipartite (@cubeFlip d) fullParity fullParity_cubeFlip
  have hsign (x : ClippingCube d) : fullParity x ^ 2 = 1 := by
    rcases fullParity_sign x with h | h <;> simp [h]
  have hdefect (x : ClippingCube d) :
      (d : ℝ) ^ 2 * (markovAverage T (fun y => fullParity y * P y) x +
        fullParity x * P x) ^ 2 = 4 * cubeLaplacian P x ^ 2 := by
    rw [markovAverage_sign_mul T fullParity P hflip]
    have hLap := markovLaplacian_cube_eq hd P x
    change (d : ℝ) / 2 * (P x - markovAverage T P x) = cubeLaplacian P x at hLap
    have hidentity : (d : ℝ) * (-fullParity x * markovAverage T P x +
        fullParity x * P x) = 2 * fullParity x * cubeLaplacian P x := by
      rw [← hLap]
      ring
    have hsquare := congrArg (fun t : ℝ => t ^ 2) hidentity
    nlinarith [hsquare, hsign x]
  have h := sum_negativePart_square_markov_coercivity T hT (fun x => fullParity x * P x)
  simp_rw [mul_pow, hsign, one_mul] at h
  have hscaled := mul_le_mul_of_nonneg_left h (sq_nonneg (d : ℝ))
  have hdefsum : (d : ℝ) ^ 2 * (∑ x,
      (markovAverage T (fun y => fullParity y * P y) x + fullParity x * P x) ^ 2) =
      4 * ∑ x, cubeLaplacian P x ^ 2 := by
    simp_rw [Finset.mul_sum, hdefect]
  have hdegree' := cubeLaplacian_degree_bound a hdegree
  change (∑ x, cubeLaplacian P x ^ 2) ≤ (u : ℝ) ^ 2 * ∑ x, P x ^ 2 at hdegree'
  nlinarith [hscaled, hdefsum, hdegree']

/-- The population squared wrong-label loss is at least `3/8` of the
squared norm for every Walsh polynomial of degree at most `d/64`. -/
theorem parity_negativePart_square_coercivity {d u : ℕ} (hd : 0 < d)
    (hu : 64 * u ≤ d) (a : Finset (Fin d) → ℝ)
    (hdegree : ∀ S, a S ≠ 0 → S.card ≤ u) :
    (3 / 8 : ℝ) * uniformCubeMean (fun x => walshExpansion a x ^ 2) ≤
      uniformCubeMean (fun x => (max 0 (-(fullParity x * walshExpansion a x))) ^ 2) := by
  have h := parity_negativePart_square_degree_bound hd a hdegree
  have hdreal : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have hureal : 64 * (u : ℝ) ≤ d := by exact_mod_cast hu
  have hcoeff : (15 / 8 : ℝ) * (d : ℝ) ^ 2 ≤ 2 * (d : ℝ) ^ 2 - 24 * (u : ℝ) ^ 2 := by
    have hsq := mul_le_mul hureal hureal (by positivity) hdreal.le
    nlinarith [hsq, sq_nonneg (u : ℝ)]
  have hsum : 0 ≤ ∑ x, walshExpansion a x ^ 2 := Finset.sum_nonneg (fun x _ => sq_nonneg _)
  have hlow := (mul_le_mul_of_nonneg_right hcoeff hsum).trans h
  have hraw : (3 / 8 : ℝ) * (∑ x, walshExpansion a x ^ 2) ≤
      ∑ x, (max 0 (-(fullParity x * walshExpansion a x))) ^ 2 := by
    nlinarith [sq_pos_of_pos hdreal]
  have hdiv := div_le_div_of_nonneg_right hraw
    (Nat.cast_nonneg (Fintype.card (ClippingCube d)) : (0 : ℝ) ≤ Fintype.card (ClippingCube d))
  simpa only [uniformCubeMean, mul_div_assoc] using hdiv

end NeuralGeneralization
