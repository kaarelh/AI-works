import NeuralGeneralization.Network
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Analysis.Calculus.MeanValue

/-!
# The actual tanh activation meets the manuscript assumptions

This proves the unit bound and unit Lipschitz constant for `Real.tanh`, rather
than leaving those facts as assumptions when specializing to the mean-field
and subcritical models.
-/

noncomputable section
open scoped NNReal

namespace NeuralGeneralization.ConcreteModel

theorem hasDerivAt_tanh (x : ℝ) :
    HasDerivAt Real.tanh (1 / (Real.cosh x) ^ 2) x := by
  have h := (Real.hasDerivAt_sinh x).div (Real.hasDerivAt_cosh x)
    (Real.cosh_pos x).ne'
  have hf : Real.tanh = Real.sinh / Real.cosh := by
    funext y
    exact Real.tanh_eq_sinh_div_cosh y
  rw [hf]
  simpa only [← pow_two, Real.cosh_sq_sub_sinh_sq] using h

theorem tanh_lipschitzWith : LipschitzWith 1 Real.tanh := by
  apply lipschitzWith_of_nnnorm_deriv_le
    (fun x => (hasDerivAt_tanh x).differentiableAt)
  intro x
  apply NNReal.coe_le_coe.mp
  change |deriv Real.tanh x| ≤ 1
  rw [(hasDerivAt_tanh x).deriv,
    abs_of_pos (one_div_pos.mpr (sq_pos_of_pos (Real.cosh_pos x)))]
  apply (div_le_one (sq_pos_of_pos (Real.cosh_pos x))).mpr
  nlinarith [Real.cosh_sq_sub_sinh_sq x, sq_nonneg (Real.sinh x)]

theorem tanh_admissible : admissibleActivation Real.tanh := by
  constructor
  · intro x
    exact (Real.abs_tanh_lt_one x).le
  · intro x y
    simpa only [Real.dist_eq, NNReal.coe_one, one_mul] using
      tanh_lipschitzWith.dist_le_mul x y

end NeuralGeneralization.ConcreteModel
