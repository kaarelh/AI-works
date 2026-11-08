import NeuralGeneralization.OnlineLowerBernsteinDerivatives
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic

/-! Endpoint values and exponential domination for the concrete kernel. -/

noncomputable section
open MeasureTheory Set

namespace NeuralGeneralization.OnlineLowerBernstein

theorem moment_at_zero (j : ℕ) : moment j 0 = 1 / ((j : ℝ) + 1) := by
  simp [moment, integral_pow, Nat.cast_add, Nat.cast_one]

theorem kernel_zero : kernel 0 = 1 := by
  norm_num [kernel, moment_at_zero]

theorem kernelPrime_zero : kernelPrime 0 = 1 / 4 := by
  norm_num [kernelPrime, firstKernelDerivative, moment_at_zero]

theorem kernel_bound (t : ℝ) : kernel t ≤ Real.exp (|t| / 2) := by
  have hroot : Real.exp (-|t| / 2) ≤ Real.sqrt (moment 0 t) := by
    apply Real.le_sqrt_of_sq_le
    calc
      Real.exp (-|t| / 2) ^ 2 = Real.exp (-|t|) := by
        rw [pow_two, ← Real.exp_add]
        congr 1
        ring
      _ ≤ moment 0 t := moment_zero_lower_bound t
  have hrecip := one_div_le_one_div_of_le (Real.exp_pos (-|t| / 2)) hroot
  have he : 1 / Real.exp (-|t| / 2) = Real.exp (|t| / 2) := by
    rw [neg_div, Real.exp_neg, one_div, inv_inv]
  exact hrecip.trans_eq he

theorem kernelPrime_le_half_kernel (t : ℝ) : kernelPrime t ≤ kernel t / 2 :=
  firstKernelDerivative_le_half_kernel _ _ (moment_pos 0 t) (moment_le_zero 1 t)

theorem kernelSecond_abs_le_kernel (t : ℝ) : |kernelSecond t| ≤ (5 / 4) * kernel t :=
  abs_secondKernelDerivative_le _ _ _ (moment_pos 0 t) (moment_pos 1 t).le
    (moment_le_zero 1 t) (moment_pos 2 t).le (moment_le_zero 2 t)

theorem kernelPrime_abs_bound (t : ℝ) : |kernelPrime t| ≤ (1 / 2) * Real.exp (|t| / 2) := by
  rw [abs_of_pos (kernelPrime_pos t)]
  have h := kernelPrime_le_half_kernel t
  have hb := kernel_bound t
  linarith

theorem kernelSecond_abs_bound (t : ℝ) : |kernelSecond t| ≤ (5 / 4) * Real.exp (|t| / 2) := by
  exact (kernelSecond_abs_le_kernel t).trans
    (mul_le_mul_of_nonneg_left (kernel_bound t) (by norm_num))

end NeuralGeneralization.OnlineLowerBernstein
