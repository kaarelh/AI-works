import Mathlib.Analysis.Calculus.Deriv.Pi
import Mathlib.Analysis.Calculus.FDeriv.Comp
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Tactic.Ring

/-! # Concrete finite gradients and linear fields
These are actual continuous linear maps used by Frechet derivatives, not
formal arrays carrying assumed chain-rule conclusions.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.FiniteDifferential
variable {I J : Type*} [Fintype I] [Fintype J]

def gradientLinear (g : I → ℝ) : (I → ℝ) →L[ℝ] ℝ :=
  ∑ i, g i • ContinuousLinearMap.proj i

@[simp] theorem gradientLinear_apply (g x : I → ℝ) :
    gradientLinear g x = ∑ i, g i * x i := by
  simp [gradientLinear]

@[simp] theorem gradientLinear_add (g h : I → ℝ) :
    gradientLinear (g + h) = gradientLinear g + gradientLinear h := by
  ext x
  simp [Pi.add_apply, add_mul, Finset.sum_add_distrib]

@[simp] theorem gradientLinear_smul (a : ℝ) (g : I → ℝ) :
    gradientLinear (a • g) = a • gradientLinear g := by
  ext x
  simp [Pi.smul_apply, smul_eq_mul, Finset.mul_sum, mul_assoc]

@[simp] theorem gradientLinear_sum {K : Type*} (s : Finset K) (g : K → I → ℝ) :
    gradientLinear (∑ k ∈ s, g k) = ∑ k ∈ s, gradientLinear (g k) := by
  ext x
  simp only [gradientLinear_apply, Finset.sum_apply, sum_apply,
    Finset.sum_mul]
  exact Finset.sum_comm

@[simp] theorem gradientLinear_single [DecidableEq I] (g : I → ℝ) (i : I) (a : ℝ) :
    gradientLinear g (Pi.single i a) = g i * a := by
  simp [gradientLinear_apply, Pi.single_apply, mul_ite]

@[simp] theorem gradientLinear_single_coeff [DecidableEq I] (i : I) (a : ℝ) :
    gradientLinear (Pi.single i a) = a • ContinuousLinearMap.proj i := by
  ext x
  simp [gradientLinear_apply, Pi.single_apply, ite_mul]

def fieldLinear (C : I → J → ℝ) : (J → ℝ) →L[ℝ] (I → ℝ) :=
  ContinuousLinearMap.pi (fun i => gradientLinear (C i))

omit [Fintype I] in
@[simp] theorem fieldLinear_apply (C : I → J → ℝ) (x : J → ℝ) (i : I) :
    fieldLinear C x i = ∑ j, C i j * x j := by
  simp [fieldLinear]

omit [Fintype I] in
@[simp] theorem fieldLinear_single [DecidableEq J] (C : I → J → ℝ) (j : J) (a : ℝ) :
    fieldLinear C (Pi.single j a) = fun i => C i j * a := by
  funext i
  change gradientLinear (C i) (Pi.single j a) = C i j * a
  exact gradientLinear_single (C i) j a

/-- Derivative of an actual linear field when one raw coordinate is varied. -/
theorem hasDerivAt_field_update [DecidableEq J] (C : I → J → ℝ)
    (x : J → ℝ) (j : J) (t : ℝ) :
    HasDerivAt (fun u => fieldLinear C (Function.update x j u)) (fun i => C i j) t := by
  have h := (fieldLinear C).hasFDerivAt.comp_hasDerivAt t (hasDerivAt_update x j t)
  simpa only [fieldLinear_single, mul_one, Function.comp_def] using h

end NeuralGeneralization.FiniteDifferential
end
