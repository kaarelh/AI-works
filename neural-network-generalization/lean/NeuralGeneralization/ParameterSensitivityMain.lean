import NeuralGeneralization.ParameterSensitivity

/-! Exact Lambda_L(R,d) from the manuscript. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.ParameterSensitivity
open ConcreteModel

theorem coefficient_eq (R S : ℝ) (n : ℕ) :
    coefficient R S n=S*R^(2*n)+∑ j∈Finset.range n,R^(2*j) := by
  induction n with
  | zero => simp [coefficient]
  | succ n ih =>
    rw [coefficient,ih,Finset.sum_range_succ']
    simp only [Nat.mul_add,Nat.mul_one,pow_add,pow_zero,Finset.mul_sum]
    have he : (∑ j∈Finset.range n,R^(2*j)*R^2)=R^2*(∑ j∈Finset.range n,R^(2*j)) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      ring
    rw [he]
    ring

def lambdaSquared (d r : ℕ) (R : ℝ) : ℝ :=
  (((d:ℝ)+1)/d)*R^(2*(r+1))+∑ j∈Finset.range (r+1),R^(2*j)

theorem lambdaSquared_pos (d r : ℕ) (R : ℝ) : 0<lambdaSquared d r R := by
  rw [lambdaSquared,← coefficient_eq,coefficient]
  have h := coefficient_nonneg R (show 0≤((d:ℝ)+1)/d by positivity) r
  positivity

/-- Squared form of Lemma (Parameter sensitivity), with its literal constant.
Only one endpoint's energy needs to be bounded. -/
theorem parameter_sensitivity_sq {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w v : Weights d N r) {R : ℝ}
    (hw : weightedSquaredNorm w≤R^2) (x : Cube d) :
    (networkOutput φ w x-networkOutput φ v x)^2≤
      lambdaSquared d r R*weightedSquaredNorm (w-v) := by
  simpa only [coefficient_eq,lambdaSquared] using output_difference_bound hd hN φ hφ w v hw x

theorem parameter_sensitivity {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w v : Weights d N r) {R : ℝ}
    (hw : weightedSquaredNorm w≤R^2) (x : Cube d) :
    |networkOutput φ w x-networkOutput φ v x|≤
      Real.sqrt (lambdaSquared d r R)*Real.sqrt (weightedSquaredNorm (w-v)) := by
  apply (sq_le_sq₀ (abs_nonneg _) (by positivity)).mp
  rw [sq_abs,mul_pow,Real.sq_sqrt (lambdaSquared_pos d r R).le,
    Real.sq_sqrt (weightedSquaredNorm_nonneg (w-v))]
  exact parameter_sensitivity_sq hd hN φ hφ w v hw x

#print axioms parameter_sensitivity
end NeuralGeneralization.ParameterSensitivity
