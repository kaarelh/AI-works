import NeuralGeneralization.Network
import Mathlib.Analysis.Complex.Trigonometric
import NeuralGeneralization.ClippedParity
import NeuralGeneralization.OnlineLowerTanhSupport
import Mathlib.Algebra.Ring.Parity
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise

/-!
# Concrete Boolean-cube parity identities for ordinary tanh

The coefficients in this module are actual normalized finite sums of
`Real.tanh` on the Boolean cube. In particular, the bias-transfer identity
is not an abstract assumption on an unspecified correlation functional.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLowerTanh

open scoped BigOperators
open ConcreteModel

/-- The full parity sign on the concrete Boolean input cube. -/
def paritySign {n : ℕ} (x : Cube n) : ℝ := ∏ i, labelReal (x i)

/-- The bias-free incoming linear form. -/
def incomingLinear {n : ℕ} (u : Fin n → ℝ) (x : Cube n) : ℝ :=
  ∑ i, u i * labelReal (x i)

/-- Squared incoming norm excluding the bias. -/
def incomingEnergy {n : ℕ} (u : Fin n → ℝ) : ℝ := ∑ i, u i ^ 2

/-- The actual normalized full-parity Walsh coefficient of an affine tanh
neuron, retaining its incoming bias as an explicit argument. -/
def parityCorrelation {n : ℕ} (u : Fin n → ℝ) (b : ℝ) : ℝ :=
  (Fintype.card (Cube n) : ℝ)⁻¹ *
    ∑ x : Cube n, paritySign x * Real.tanh (b + incomingLinear u x)

/-- Negation of every physical input is a cube permutation. -/
def negateInputs (n : ℕ) : Cube n ≃ Cube n where
  toFun x i := !(x i)
  invFun x i := !(x i)
  left_inv x := by funext i; simp
  right_inv x := by funext i; simp

@[simp] theorem labelReal_not (b : Bool) : labelReal (!b) = -labelReal b := by
  cases b <;> norm_num [labelReal]

@[simp] theorem incomingLinear_negate {n : ℕ} (u : Fin n → ℝ) (x : Cube n) :
    incomingLinear u (negateInputs n x) = -incomingLinear u x := by
  simp [incomingLinear, negateInputs, Finset.sum_neg_distrib]

@[simp] theorem paritySign_negate {n : ℕ} (x : Cube n) :
    paritySign (negateInputs n x) = (-1 : ℝ) ^ n * paritySign x := by
  simp [paritySign, negateInputs, Finset.prod_neg]

/-- For odd selected degree the full-parity tanh coefficient is an even
function of the incoming bias. -/
theorem parityCorrelation_bias_neg {n : ℕ} (hn : Odd n)
    (u : Fin n → ℝ) (b : ℝ) :
    parityCorrelation u (-b) = parityCorrelation u b := by
  have hpoint (x : Cube n) :
      paritySign (negateInputs n x) *
          Real.tanh (-b + incomingLinear u (negateInputs n x)) =
        paritySign x * Real.tanh (b + incomingLinear u x) := by
    rw [paritySign_negate, hn.neg_one_pow, incomingLinear_negate]
    have he : -b + -incomingLinear u x = -(b + incomingLinear u x) := by ring
    rw [he, Real.tanh_neg]
    ring
  have hsum := (negateInputs n).sum_comp
    (fun x => paritySign x * Real.tanh (-b + incomingLinear u x))
  simp_rw [hpoint] at hsum
  unfold parityCorrelation
  rw [hsum]

/-- Add a scalar to one selected incoming coordinate. -/
def shiftIncoming {n : ℕ} (u : Fin n → ℝ) (i : Fin n) (b : ℝ) : Fin n → ℝ :=
  fun j => u j + if j = i then b else 0

@[simp] theorem incomingLinear_shift {n : ℕ} (u : Fin n → ℝ)
    (i : Fin n) (b : ℝ) (x : Cube n) :
    incomingLinear (shiftIncoming u i b) x =
      incomingLinear u x + b * labelReal (x i) := by
  classical
  simp [incomingLinear, shiftIncoming, add_mul, Finset.sum_add_distrib,
    ite_mul]

/-- Exact odd-degree bias transfer: an affine coefficient is the average of
two intrinsic coefficients with the bias moved into one selected weight. -/
theorem parityCorrelation_bias_transfer {n : ℕ} (hn : Odd n)
    (u : Fin n → ℝ) (i : Fin n) (b : ℝ) :
    parityCorrelation u b =
      (parityCorrelation (shiftIncoming u i b) 0 +
        parityCorrelation (shiftIncoming u i (-b)) 0) / 2 := by
  have hpoint (x : Cube n) :
      Real.tanh (incomingLinear (shiftIncoming u i b) x) +
        Real.tanh (incomingLinear (shiftIncoming u i (-b)) x) =
      Real.tanh (b + incomingLinear u x) +
        Real.tanh (-b + incomingLinear u x) := by
    simp only [incomingLinear_shift]
    cases hi : x i <;> simp [labelReal] <;> ring_nf
  have he : parityCorrelation (shiftIncoming u i b) 0 +
      parityCorrelation (shiftIncoming u i (-b)) 0 =
      parityCorrelation u b + parityCorrelation u (-b) := by
    unfold parityCorrelation
    simp only [zero_add]
    rw [← mul_add, ← Finset.sum_add_distrib, ← mul_add, ← Finset.sum_add_distrib]
    congr 1
    apply Finset.sum_congr rfl
    intro x _
    rw [← mul_add, hpoint, mul_add]
  rw [he, parityCorrelation_bias_neg hn]
  ring

/-- The exact squared norm after transferring a bias to one coordinate. -/
theorem incomingEnergy_shift {n : ℕ} (u : Fin n → ℝ) (i : Fin n) (b : ℝ) :
    incomingEnergy (shiftIncoming u i b) = incomingEnergy u + b ^ 2 + 2 * u i * b := by
  classical
  have hpoint (j : Fin n) : (shiftIncoming u i b j) ^ 2 =
      u j ^ 2 + if j = i then b ^ 2 + 2 * u i * b else 0 := by
    by_cases hji : j = i
    · subst j; simp [shiftIncoming]; ring
    · simp [shiftIncoming, hji]
  simp_rw [incomingEnergy, hpoint, Finset.sum_add_distrib]
  simp
  ring

/-- The sharp intrinsic parity bound is an explicit proposition about actual
tanh neurons. Its eventual high-degree validity is the separate analytic
single-parity theorem, not an axiom or a hidden structure field. -/
def IntrinsicParityBound (n : ℕ) (w : ℝ) : Prop :=
  ∀ u : Fin n → ℝ, w * |parityCorrelation u 0| ≤ Real.sqrt (incomingEnergy u)

/-- The proved exact bias-transfer identity converts an intrinsic bound into
the pointwise square-root mean used in support Jensen. -/
theorem intrinsic_bound_biasTransfer {n : ℕ} (hn : Odd n) (w : ℝ)
    (hw : 0 ≤ w) (hsharp : IntrinsicParityBound n w)
    (u : Fin n → ℝ) (i : Fin n) (b : ℝ) :
    w * |parityCorrelation u b| ≤
      sqrtPair (incomingEnergy u + b ^ 2) (2 * u i * b) := by
  have hp := hsharp (shiftIncoming u i b)
  have hm := hsharp (shiftIncoming u i (-b))
  have habs := mul_le_mul_of_nonneg_left
    (abs_add_le (parityCorrelation (shiftIncoming u i b) 0)
      (parityCorrelation (shiftIncoming u i (-b)) 0)) hw
  rw [parityCorrelation_bias_transfer hn u i b, abs_div]
  rw [abs_of_pos (by norm_num : (0 : ℝ) < 2)]
  have he : sqrtPair (incomingEnergy u + b ^ 2) (2 * u i * b) =
      (Real.sqrt (incomingEnergy (shiftIncoming u i b)) +
        Real.sqrt (incomingEnergy (shiftIncoming u i (-b)))) / 2 := by
    rw [incomingEnergy_shift, incomingEnergy_shift]
    unfold sqrtPair
    congr 2
    congr 1
    ring
  rw [he]
  nlinarith

@[simp] theorem abs_paritySign {n : ℕ} (x : Cube n) : |paritySign x| = 1 := by
  have hs : paritySign x = 1 ∨ paritySign x = -1 := fullParity_sign x
  rcases hs with h | h <;> rw [h] <;> norm_num

@[simp] theorem paritySign_flip {n : ℕ} (i : Fin n) (x : Cube n) :
    paritySign (cubeFlip i x) = -paritySign x := fullParity_cubeFlip i x

theorem incomingLinear_flip {n : ℕ} (u : Fin n → ℝ) (i : Fin n) (x : Cube n) :
    incomingLinear u (cubeFlip i x) = incomingLinear u x - 2 * u i * labelReal (x i) := by
  classical
  have hrest : (∑ j ∈ Finset.univ.erase i, u j * labelReal (cubeFlip i x j)) =
      ∑ j ∈ Finset.univ.erase i, u j * labelReal (x j) := by
    apply Finset.sum_congr rfl
    intro j hj
    have hji : j ≠ i := (Finset.mem_erase.mp hj).1
    simp [cubeFlip, Function.update_of_ne hji]
  have hsum (z : Cube n) : incomingLinear u z =
      u i * labelReal (z i) + ∑ j ∈ Finset.univ.erase i, u j * labelReal (z j) :=
    (Finset.add_sum_erase Finset.univ (fun j => u j * labelReal (z j))
      (Finset.mem_univ i)).symm
  rw [hsum (cubeFlip i x), hrest, hsum x]
  simp only [cubeFlip, Equiv.coe_fn_mk, Function.update_self, labelReal_not]
  ring

end NeuralGeneralization.OnlineLowerTanh
