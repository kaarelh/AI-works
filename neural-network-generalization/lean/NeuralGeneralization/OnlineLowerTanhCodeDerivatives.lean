import NeuralGeneralization.TanhScalarJet
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Tactic.Positivity

/-!
# Global factorial derivative bound for ordinary tanh

The proof uses the literal real tanh function and its differential equation
`tanh' = 1 - tanh²`. Leibniz's formula gives the convenient bound `n!` on the
nth derivative, so no complex-analytic Cauchy estimate is needed in the local
transversal absorption argument.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerTanh

@[fun_prop] theorem contDiff_tanh_all {n : WithTop ℕ∞} : ContDiff ℝ n Real.tanh := by
  have he : Real.tanh = fun x : ℝ => Real.sinh x / Real.cosh x := by
    funext x
    exact Real.tanh_eq_sinh_div_cosh x
  rw [he]
  exact Real.contDiff_sinh.div Real.contDiff_cosh (fun x => (Real.cosh_pos x).ne')

/-- The actual derivative function, in the form used by iterated Leibniz. -/
theorem deriv_tanh_eq : deriv Real.tanh = fun x => 1 - Real.tanh x * Real.tanh x := by
  funext x
  rw [(TanhDifferential.hasDerivAt_tanh_first x).deriv]
  simp [TanhDifferential.tanhFirst, pow_two]

/-- A global bound for every derivative order. In particular this is stronger
than the Cauchy bound with factor `(4/π)^n` used in the manuscript. -/
theorem abs_iteratedDeriv_tanh_le_factorial (n : ℕ) (x : ℝ) :
    |iteratedDeriv n Real.tanh x| ≤ (n.factorial : ℝ) := by
  induction n using Nat.strong_induction_on with
  | h n ih =>
    cases n with
    | zero => simpa using (Real.abs_tanh_lt_one x).le
    | succ n =>
      by_cases hn : n = 0
      · subst n
        simpa [iteratedDeriv_one,
          (TanhDifferential.hasDerivAt_tanh_first x).deriv] using
          TanhDifferential.abs_tanhFirst_le_one x
      · have hnpos : 0 < n := Nat.pos_of_ne_zero hn
        rw [iteratedDeriv_succ', deriv_tanh_eq, iteratedDeriv_const_sub hnpos,
          iteratedDeriv_neg, abs_neg]
        rw [iteratedDeriv_fun_mul
          (contDiff_tanh_all (n := (n : WithTop ℕ∞))).contDiffAt
          (contDiff_tanh_all (n := (n : WithTop ℕ∞))).contDiffAt]
        calc
          |∑ i ∈ Finset.range (n + 1), (n.choose i : ℝ) *
              iteratedDeriv i Real.tanh x * iteratedDeriv (n - i) Real.tanh x|
              ≤ ∑ i ∈ Finset.range (n + 1),
                |(n.choose i : ℝ) * iteratedDeriv i Real.tanh x *
                  iteratedDeriv (n - i) Real.tanh x| := Finset.abs_sum_le_sum_abs _ _
          _ ≤ ∑ i ∈ Finset.range (n + 1),
                (n.choose i : ℝ) * (i.factorial : ℝ) * ((n-i).factorial : ℝ) := by
            apply Finset.sum_le_sum
            intro i hi
            have hi' : i ≤ n := Nat.le_of_lt_succ (Finset.mem_range.mp hi)
            rw [abs_mul, abs_mul, abs_of_nonneg (Nat.cast_nonneg _)]
            exact mul_le_mul
              (mul_le_mul_of_nonneg_left (ih i (Nat.lt_succ_of_le hi')) (Nat.cast_nonneg _))
              (ih (n-i) (Nat.lt_succ_of_le (Nat.sub_le n i)))
              (abs_nonneg _) (by positivity)
          _ = (n.succ.factorial : ℝ) := by
            have he (i : ℕ) (hi : i ∈ Finset.range (n+1)) :
                (n.choose i : ℝ) * (i.factorial : ℝ) * ((n-i).factorial : ℝ) =
                  (n.factorial : ℝ) := by
              exact_mod_cast Nat.choose_mul_factorial_mul_factorial
                (Nat.le_of_lt_succ (Finset.mem_range.mp hi))
            rw [Finset.sum_congr rfl he]
            simp [Nat.factorial_succ, Nat.cast_mul]

end NeuralGeneralization.OnlineLowerTanh
