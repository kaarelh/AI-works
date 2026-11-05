import NeuralGeneralization.GaussianMatrixGeometry
import Mathlib.Analysis.Normed.Operator.Mul
import Mathlib.Algebra.Ring.GeomSum
import Mathlib.Tactic

/-! The finite lower-triangular inverse on the full Euclidean hidden stack. -/
noncomputable section
open scoped BigOperators
open WithLp
namespace NeuralGeneralization.JacobianCertificate

abbrev Stack (N r : ℕ) := EuclideanSpace ℝ (Fin (r+1) × Fin N)

variable {N r : ℕ}

/-- Strict block lower bidiagonal operator, with exactly the Euclidean stack
norm used in the paper. -/
def shift (C : Fin r → Fin N → Fin N → ℝ) : Stack N r →L[ℝ] Stack N r :=
  LinearMap.toContinuousLinearMap {
    toFun := fun X => toLp 2 (fun p => Fin.cases 0
      (fun s => ∑ j, C s p.2 j * X (s.castSucc,j)) p.1)
    map_add' := by
      intro X Y
      ext ⟨s,i⟩
      induction s using Fin.cases with
      | zero => simp
      | succ s => simp [mul_add, Finset.sum_add_distrib]
    map_smul' := by
      intro a X
      ext ⟨s,i⟩
      induction s using Fin.cases with
      | zero => simp
      | succ s => simp [Finset.mul_sum, mul_left_comm]
  }

@[simp] theorem shift_zero (C : Fin r → Fin N → Fin N → ℝ) (X : Stack N r) (i : Fin N) :
    shift C X (0,i) = 0 := rfl

@[simp] theorem shift_succ (C : Fin r → Fin N → Fin N → ℝ) (X : Stack N r)
    (s : Fin r) (i : Fin N) :
    shift C X (s.succ,i) = ∑ j, C s i j * X (s.castSucc,j) := rfl

theorem shift_pow_zero_below (C : Fin r → Fin N → Fin N → ℝ) (n : ℕ)
    (X : Stack N r) (s : Fin (r+1)) (i : Fin N) (hs : s.val < n) :
    (shift C ^ n) X (s,i) = 0 := by
  induction n generalizing s i with
  | zero => omega
  | succ n ih =>
    rw [pow_succ', ContinuousLinearMap.mul_apply]
    induction s using Fin.cases with
    | zero => exact shift_zero _ _ _
    | succ s =>
      rw [shift_succ]
      apply Finset.sum_eq_zero
      intro j _
      rw [ih s.castSucc j (by simpa using Nat.lt_of_succ_lt_succ hs),mul_zero]

/-- Nilpotence is proved from the actual feedforward indexing. -/
theorem shift_nilpotent (C : Fin r → Fin N → Fin N → ℝ) : shift C ^ (r+1) = 0 := by
  ext X ⟨s,i⟩
  exact shift_pow_zero_below C (r+1) X s i s.isLt

/-- The inverse is the finite geometric series, not an assumed resolvent. -/
def transport (C : Fin r → Fin N → Fin N → ℝ) : Stack N r →L[ℝ] Stack N r :=
  ∑ n ∈ Finset.range (r+1), shift C ^ n

theorem transport_mul (C : Fin r → Fin N → Fin N → ℝ) :
    transport C * (1-shift C) = 1 := by
  rw [transport, geom_sum_mul_neg, shift_nilpotent, sub_zero]

theorem mul_transport (C : Fin r → Fin N → Fin N → ℝ) :
    (1-shift C) * transport C = 1 := by
  rw [transport, mul_neg_geom_sum, shift_nilpotent, sub_zero]

/-- The exact fixed-point identity solved by the signed clean transport. -/
theorem transport_identity (C : Fin r → Fin N → Fin N → ℝ) (X η e : Stack N r)
    (h : X = shift C X + η + e) : X = transport C (η+e) := by
  have he : (1-shift C) X = η+e := by
    simp only [ContinuousLinearMap.sub_apply, ContinuousLinearMap.one_apply]
    apply sub_eq_iff_eq_add.mpr
    calc
      X = shift C X + η + e := h
      _ = η + e + shift C X := by abel
  have hh := congrArg (fun F : Stack N r →L[ℝ] Stack N r => F X) (transport_mul C)
  simp only [ContinuousLinearMap.mul_apply, ContinuousLinearMap.one_apply,he] at hh
  exact hh.symm

end NeuralGeneralization.JacobianCertificate
