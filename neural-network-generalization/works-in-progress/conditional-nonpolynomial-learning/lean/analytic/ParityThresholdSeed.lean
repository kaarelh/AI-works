import TanhWalshSymmetrization
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise

/-! A concrete threshold decomposition of every Walsh character, expressed in
the number of false input bits. These are the detector means used to construct
the low-cost first-layer parity law. -/

noncomputable section
open scoped BigOperators
open NeuralGeneralization

namespace ConditionalNonpolynomial.Analytic

variable {d : ℕ}

def falseCount (S : Finset (Fin d)) (x : ClippingCube d) : ℕ :=
  (S.filter (fun i => x i = false)).card

theorem falseCount_le (S : Finset (Fin d)) (x : ClippingCube d) :
    falseCount S x ≤ S.card := Finset.card_filter_le _ _

theorem walshCharacter_eq_falseCount (S : Finset (Fin d)) (x : ClippingCube d) :
    walshCharacter S x = (-1 : ℝ) ^ falseCount S x := by
  have hsign (i : Fin d) : cubeCoordinateSign (x i) =
      if x i = false then (-1 : ℝ) else 1 := by
    cases hx : x i <;> simp [cubeCoordinateSign]
  simp only [walshCharacter, hsign, Finset.prod_ite, Finset.prod_const,
    one_pow, mul_one, falseCount]

theorem sum_coordinateSign_eq_falseCount (S : Finset (Fin d)) (x : ClippingCube d) :
    (∑ i ∈ S, cubeCoordinateSign (x i)) = (S.card : ℝ) - 2 * falseCount S x := by
  have hsign (i : Fin d) : cubeCoordinateSign (x i) =
      1 - 2 * (if x i = false then (1 : ℝ) else 0) := by
    cases hx : x i <;> norm_num [cubeCoordinateSign, hx]
  simp_rw [hsign, Finset.sum_sub_distrib, ← Finset.mul_sum]
  simp [falseCount]

def parityStep (j r : ℕ) : ℝ := if j < r then 1 else -1

def parityConstant (k : ℕ) : ℝ := (1 + (-1 : ℝ) ^ k) / 2

theorem parityConstant_zero_or_one (k : ℕ) :
    parityConstant k = 0 ∨ parityConstant k = 1 := by
  have hs : ((-1 : ℝ) ^ k) ^ 2 = 1 := by
    rw [← pow_mul, Nat.mul_comm, pow_mul]
    norm_num
  rcases sq_eq_one_iff.mp hs with h | h <;> simp [parityConstant, h]

theorem alternating_partial_sum (r : ℕ) :
    2 * (∑ j ∈ Finset.range r, (-1 : ℝ) ^ (j+1)) = (-1 : ℝ)^r - 1 := by
  induction r with
  | zero => norm_num
  | succ r ih =>
    rw [Finset.sum_range_succ]
    rw [show (-1 : ℝ)^(r+1) = (-1 : ℝ)^r * -1 from pow_succ _ _]
    nlinarith only [ih]

theorem parity_threshold_decomposition (k r : ℕ) (hr : r ≤ k) :
    (-1 : ℝ)^r = parityConstant k +
      ∑ j ∈ Finset.range k, (-1 : ℝ)^(j+1) * parityStep j r := by
  have hfilt : (Finset.range k).filter (fun j => j < r) = Finset.range r := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_range]
    omega
  have hstep (j : ℕ) : (-1 : ℝ)^(j+1) * parityStep j r =
      2 * (if j < r then (-1 : ℝ)^(j+1) else 0) - (-1 : ℝ)^(j+1) := by
    by_cases hj : j < r <;> simp [parityStep, hj] <;> ring
  simp_rw [hstep, Finset.sum_sub_distrib, ← Finset.mul_sum]
  rw [← Finset.sum_filter, hfilt]
  have hr' := alternating_partial_sum r
  have hk' := alternating_partial_sum k
  unfold parityConstant
  linarith

theorem walsh_threshold_decomposition (S : Finset (Fin d)) (x : ClippingCube d) :
    walshCharacter S x = parityConstant S.card +
      ∑ j ∈ Finset.range S.card, (-1 : ℝ)^(j+1) * parityStep j (falseCount S x) := by
  rw [walshCharacter_eq_falseCount]
  exact parity_threshold_decomposition _ _ (falseCount_le S x)

/-- This is an affine form in the original Boolean input coordinates. -/
def parityDetectorArgument (S : Finset (Fin d)) (j : ℕ) (M : ℝ)
    (x : ClippingCube d) : ℝ :=
  M * ((S.card : ℝ) - 2 * j - 1 - ∑ i ∈ S, cubeCoordinateSign (x i))

theorem parityDetectorArgument_eq_count (S : Finset (Fin d)) (j : ℕ) (M : ℝ)
    (x : ClippingCube d) :
    parityDetectorArgument S j M x = M * (2 * falseCount S x - 2 * j - 1) := by
  rw [parityDetectorArgument, sum_coordinateSign_eq_falseCount]
  ring

/-- Every detector has uniform signed margin M at every Boolean input. -/
theorem parityDetectorArgument_margin (S : Finset (Fin d)) (j : ℕ) (M : ℝ)
    (hM : 0 ≤ M) (x : ClippingCube d) :
    M ≤ parityStep j (falseCount S x) * parityDetectorArgument S j M x := by
  rw [parityDetectorArgument_eq_count]
  by_cases hj : j < falseCount S x
  · have hcast : (j : ℝ) + 1 ≤ falseCount S x := by exact_mod_cast hj
    simp only [parityStep, if_pos hj, one_mul]
    nlinarith
  · have hcast : (falseCount S x : ℝ) ≤ j := by exact_mod_cast (Nat.le_of_not_gt hj)
    simp only [parityStep, if_neg hj, neg_one_mul]
    nlinarith

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.walsh_threshold_decomposition
#print axioms ConditionalNonpolynomial.Analytic.parityDetectorArgument_margin
