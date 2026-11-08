import NeuralGeneralization.OnlineLowerTanhParity
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Data.Fin.Tuple.Basic

/-!
# Exact finite Rademacher moments

The second and fourth moments below are proved for the actual affine incoming
linear form on `ConcreteModel.Cube n`. They supply the moment hypotheses of
the support-stability theorem without probabilistic axioms.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLowerTanh

open scoped BigOperators
open ConcreteModel

/-- Uniform expectation on the concrete Boolean cube. -/
def cubeMean {n : ℕ} (f : Cube n → ℝ) : ℝ :=
  ((2 : ℝ) ^ n)⁻¹ * ∑ x, f x

/-- The sum of fourth powers of incoming coordinates. -/
def incomingFourth {n : ℕ} (u : Fin n → ℝ) : ℝ := ∑ i, u i ^ 4

/-- Split off the first physical Boolean coordinate. -/
def splitInputs (n : ℕ) : Cube (n + 1) ≃ Bool × Cube n where
  toFun x := (x 0, fun i => x i.succ)
  invFun y := Fin.cons y.1 y.2
  left_inv x := by
    funext i
    refine Fin.cases ?_ (fun j => ?_) i <;> rfl
  right_inv y := by cases y; rfl

theorem cubeMean_add {n : ℕ} (f g : Cube n → ℝ) :
    cubeMean (fun x => f x + g x) = cubeMean f + cubeMean g := by
  simp [cubeMean, Finset.sum_add_distrib, mul_add]

theorem cubeMean_const_mul {n : ℕ} (a : ℝ) (f : Cube n → ℝ) :
    cubeMean (fun x => a * f x) = a * cubeMean f := by
  simp [cubeMean, ← Finset.mul_sum, mul_left_comm]

@[simp] theorem cubeMean_const {n : ℕ} (a : ℝ) :
    cubeMean (fun _ : Cube n => a) = a := by
  simp [cubeMean, Cube]

theorem cubeMean_congr {n : ℕ} {f g : Cube n → ℝ} (h : ∀ x, f x = g x) :
    cubeMean f = cubeMean g := by
  unfold cubeMean
  congr 1
  exact Finset.sum_congr rfl (fun x _ => h x)

/-- Exact decomposition of uniform cube expectation into its two first-bit
slices. -/
theorem cubeMean_succ {n : ℕ} (f : Cube (n + 1) → ℝ) :
    cubeMean f =
      (cubeMean (fun x => f (Fin.cons true x)) +
        cubeMean (fun x => f (Fin.cons false x))) / 2 := by
  have hs := (splitInputs n).symm.sum_comp f
  simp only [Fintype.sum_prod_type, Fintype.sum_bool, splitInputs,
    Equiv.coe_fn_symm_mk] at hs
  unfold cubeMean
  rw [← hs, pow_succ]
  field_simp

@[simp] theorem incomingLinear_cons {n : ℕ} (u : Fin (n + 1) → ℝ)
    (b : Bool) (x : Cube n) :
    incomingLinear u (Fin.cons b x) =
      u 0 * labelReal b + incomingLinear (fun i => u i.succ) x := by
  simp [incomingLinear, Fin.sum_univ_succ]

@[simp] theorem incomingEnergy_succ {n : ℕ} (u : Fin (n + 1) → ℝ) :
    incomingEnergy u = u 0 ^ 2 + incomingEnergy (fun i => u i.succ) := by
  simp [incomingEnergy, Fin.sum_univ_succ]

@[simp] theorem incomingFourth_succ {n : ℕ} (u : Fin (n + 1) → ℝ) :
    incomingFourth u = u 0 ^ 4 + incomingFourth (fun i => u i.succ) := by
  simp [incomingFourth, Fin.sum_univ_succ]

/-- Exact second moment of an affine Rademacher sum. -/
theorem affine_secondMoment {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    cubeMean (fun x => (b + incomingLinear u x) ^ 2) = b ^ 2 + incomingEnergy u := by
  induction n generalizing b with
  | zero => simp [incomingLinear, incomingEnergy]
  | succ n ih =>
    rw [cubeMean_succ]
    have hp : cubeMean (fun x : Cube n => (b + incomingLinear u (Fin.cons true x)) ^ 2) =
        (b + u 0) ^ 2 + incomingEnergy (fun i => u i.succ) := by
      simpa [incomingLinear_cons, add_assoc] using ih (fun i => u i.succ) (b + u 0)
    have hm : cubeMean (fun x : Cube n => (b + incomingLinear u (Fin.cons false x)) ^ 2) =
        (b - u 0) ^ 2 + incomingEnergy (fun i => u i.succ) := by
      simpa [incomingLinear_cons, sub_eq_add_neg, add_assoc] using
        ih (fun i => u i.succ) (b - u 0)
    rw [hp, hm, incomingEnergy_succ]
    ring

/-- Exact fourth moment, retaining the diagonal correction that makes the
sharp factor-three bound hold. -/
theorem affine_fourthMoment {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    cubeMean (fun x => (b + incomingLinear u x) ^ 4) =
      b ^ 4 + 6 * b ^ 2 * incomingEnergy u + 3 * incomingEnergy u ^ 2 -
        2 * incomingFourth u := by
  induction n generalizing b with
  | zero => simp [incomingLinear, incomingEnergy, incomingFourth]
  | succ n ih =>
    rw [cubeMean_succ]
    have hp : cubeMean (fun x : Cube n => (b + incomingLinear u (Fin.cons true x)) ^ 4) =
        (b + u 0) ^ 4 + 6 * (b + u 0) ^ 2 * incomingEnergy (fun i => u i.succ) +
          3 * incomingEnergy (fun i => u i.succ) ^ 2 -
            2 * incomingFourth (fun i => u i.succ) := by
      simpa [incomingLinear_cons, add_assoc] using ih (fun i => u i.succ) (b + u 0)
    have hm : cubeMean (fun x : Cube n => (b + incomingLinear u (Fin.cons false x)) ^ 4) =
        (b - u 0) ^ 4 + 6 * (b - u 0) ^ 2 * incomingEnergy (fun i => u i.succ) +
          3 * incomingEnergy (fun i => u i.succ) ^ 2 -
            2 * incomingFourth (fun i => u i.succ) := by
      simpa [incomingLinear_cons, sub_eq_add_neg, add_assoc] using
        ih (fun i => u i.succ) (b - u 0)
    rw [hp, hm, incomingEnergy_succ, incomingFourth_succ]
    ring

/-- The fourth moment is at most three times the square of the second
moment, including an arbitrary deterministic bias. -/
theorem affine_fourthMoment_le {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    cubeMean (fun x => (b + incomingLinear u x) ^ 4) ≤
      3 * (b ^ 2 + incomingEnergy u) ^ 2 := by
  rw [affine_fourthMoment]
  have ht : 0 ≤ incomingFourth u := Finset.sum_nonneg (fun _ _ => by positivity)
  nlinarith [show 0 ≤ b ^ 4 by positivity]

end NeuralGeneralization.OnlineLowerTanh
