import NeuralGeneralization.OnlineLowerReluWalshIntegral
import NeuralGeneralization.OnlineLowerTanhMoments

/-!
# Actual ReLU neuron and Fourier coefficient continuity

All distances below are explicit sums of squares. No sup norm on the
function type of incoming weights is substituted for Euclidean energy.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

theorem relu_lipschitz (x y : ℝ) : |max x 0 - max y 0| ≤ |x - y| := by
  by_cases hx : 0 ≤ x <;> by_cases hy : 0 ≤ y
  · simp [max_eq_left hx, max_eq_left hy]
  · have hy' : y ≤ 0 := le_of_not_ge hy
    rw [max_eq_left hx, max_eq_right hy', sub_zero, abs_of_nonneg hx,
      abs_of_nonneg (by linarith : 0 ≤ x - y)]
    linarith
  · have hx' : x ≤ 0 := le_of_not_ge hx
    rw [max_eq_right hx', max_eq_left hy, zero_sub, abs_neg, abs_of_nonneg hy,
      abs_of_nonpos (by linarith : x - y ≤ 0)]
    linarith
  · simp [max_eq_right (le_of_not_ge hx), max_eq_right (le_of_not_ge hy)]

theorem relu_square_difference_le (x y : ℝ) :
    (max x 0 - max y 0) ^ 2 ≤ (x - y) ^ 2 := by
  have h := mul_self_le_mul_self (abs_nonneg (max x 0 - max y 0)) (relu_lipschitz x y)
  simpa only [← pow_two, sq_abs] using h

theorem uniformCubeMean_mono {d : ℕ} (F G : ClippingCube d → ℝ)
    (h : ∀ x, F x ≤ G x) : uniformCubeMean F ≤ uniformCubeMean G :=
  div_le_div_of_nonneg_right (Finset.sum_le_sum (fun x _ => h x)) (Nat.cast_nonneg _)

theorem uniformCubeMean_eq_momentMean {d : ℕ} (F : ClippingCube d → ℝ) :
    uniformCubeMean F = OnlineLowerTanh.cubeMean F := by
  simp [uniformCubeMean, OnlineLowerTanh.cubeMean, ClippingCube,
    div_eq_mul_inv, mul_comm]

theorem cubeAffine_secondMoment {d : ℕ} (b : ℝ) (u : Fin d → ℝ) :
    uniformCubeMean (fun x => cubeAffine b u x ^ 2) = b ^ 2 + ∑ i, u i ^ 2 := by
  rw [uniformCubeMean_eq_momentMean]
  exact OnlineLowerTanh.affine_secondMoment u b

theorem cubeAffine_sub {d : ℕ} (b c : ℝ) (u v : Fin d → ℝ) (x : ClippingCube d) :
    cubeAffine b u x - cubeAffine c v x = cubeAffine (b - c) (fun i => u i - v i) x := by
  simp only [cubeAffine, sub_mul, Finset.sum_sub_distrib]
  ring

/-- Exact population L2 Lipschitz bound in incoming Euclidean coordinates. -/
theorem relu_neuron_l2_difference_le {d : ℕ} (b c : ℝ) (u v : Fin d → ℝ) :
    uniformCubeMean (fun x => (max (cubeAffine b u x) 0 - max (cubeAffine c v x) 0) ^ 2) ≤
      (b - c) ^ 2 + ∑ i, (u i - v i) ^ 2 := by
  calc
    _ ≤ uniformCubeMean (fun x => (cubeAffine b u x - cubeAffine c v x) ^ 2) :=
      uniformCubeMean_mono _ _ (fun x => relu_square_difference_le _ _)
    _ = _ := by simp_rw [cubeAffine_sub]; exact cubeAffine_secondMoment _ _

/-- A single Walsh coefficient is a norm-one linear functional in population L2. -/
theorem walsh_difference_sq_le_l2 {d : ℕ} (F G : ClippingCube d → ℝ)
    (S : Finset (Fin d)) :
    (walshCoefficients F S - walshCoefficients G S) ^ 2 ≤
      uniformCubeMean (fun x => (F x - G x) ^ 2) := by
  have h := uniformCubeMean_sq_le (fun x => (F x - G x) * walshCharacter S x)
  have hl : uniformCubeMean (fun x => (F x - G x) * walshCharacter S x) =
      walshCoefficients F S - walshCoefficients G S := by
    simp [uniformCubeMean, walshCoefficients, sub_mul, Finset.sum_sub_distrib, sub_div]
  rw [hl] at h
  simpa only [mul_pow, walshCharacter_sq, mul_one] using h

/-- The exact coefficient-continuity estimate needed when a closest
balanced support is omitted from a retained subcode. -/
theorem relu_walsh_difference_sq_le {d : ℕ} (b c : ℝ) (u v : Fin d → ℝ)
    (S : Finset (Fin d)) :
    (walshCoefficients (fun x => max (cubeAffine b u x) 0) S -
      walshCoefficients (fun x => max (cubeAffine c v x) 0) S) ^ 2 ≤
      (b - c) ^ 2 + ∑ i, (u i - v i) ^ 2 :=
  (walsh_difference_sq_le_l2 _ _ S).trans (relu_neuron_l2_difference_le b c u v)

/-- Flip invariance annihilates every Fourier character containing that coordinate. -/
theorem walsh_eq_zero_of_flip_invariant {d : ℕ} (F : ClippingCube d → ℝ)
    (S : Finset (Fin d)) (i : Fin d) (hi : i ∈ S)
    (hF : ∀ x, F (cubeFlip i x) = F x) : walshCoefficients F S = 0 := by
  have h := (cubeFlip i).sum_comp (fun x => F x * walshCharacter S x)
  simp_rw [hF, walshCharacter_flip, if_pos hi, mul_neg, Finset.sum_neg_distrib] at h
  have hs : (∑ x, F x * walshCharacter S x) = 0 := by linarith
  unfold walshCoefficients uniformCubeMean
  rw [hs, zero_div]

theorem cubeAffine_flip_of_zero {d : ℕ} (b : ℝ) (u : Fin d → ℝ)
    (i : Fin d) (hi : u i = 0) (x : ClippingCube d) :
    cubeAffine b u (cubeFlip i x) = cubeAffine b u x := by
  have h := OnlineLowerTanh.incomingLinear_flip u i x
  rw [hi, mul_zero, zero_mul, sub_zero] at h
  exact congrArg (fun z => b + z) h

/-- An actual neuron whose weights vanish outside `A` lies in the entire
Walsh downward space of `A`, including its affine and odd components. -/
theorem relu_walsh_eq_zero_outside_support {d : ℕ} (b : ℝ) (u : Fin d → ℝ)
    (A S : Finset (Fin d)) (hu : ∀ i, i ∉ A → u i = 0) (hS : ¬ S ⊆ A) :
    walshCoefficients (fun x => max (cubeAffine b u x) 0) S = 0 := by
  classical
  obtain ⟨i, hiS, hiA⟩ := Finset.not_subset.mp hS
  apply walsh_eq_zero_of_flip_invariant _ S i hiS
  intro x
  rw [cubeAffine_flip_of_zero b u i (hu i hiA)]

end NeuralGeneralization.OnlineLowerRelu
