import NeuralGeneralization.AllWidthTargetMass
import NeuralGeneralization.AllWidthCylinderCost

/-!
# Quantitative target mass at every admissible width

This is a closed lower bound for the actual Gaussian network prior, including
the mean-field endpoint. A bounded-weight realizing circuit is the only
representation hypothesis. No cylinder, geometric, or probabilistic estimate
is assumed by the theorem.
-/

noncomputable section

namespace NeuralGeneralization.ConcreteModel

/-- The complete all-width target-mass estimate for every exponent `γ ≥ 1`.
The coefficient and polynomial degree depend only on depth, and are independent
of width, dimension, target complexity, activation, and exponent. -/
theorem powerPrior_target_mass_polynomial {d C N r : ℕ}
    (hd : 0 < d) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) {γ : ℝ} (hγ : 1 ≤ γ) :
    Real.exp (-(cylinderPolynomialCoefficient r *
      (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r * (N : ℝ) ^ γ)) ≤
      functionMass φ (1/2) (powerPrior d N r γ) f := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  obtain ⟨v,b,J,hm,hK,hJ,hrows,hhidden⟩ :=
    exists_adapted_cylinder_teacher φ f hf hCN
  have hJR : (J.card : ℝ) ≤ (C : ℝ)+1 := by exact_mod_cast hJ
  have hmass := smallPrior_supported_target_mass hd hN φ hφ f v b J
    (cylinderTeacherCost d r C) ((C : ℝ)+1) (powerStandardDeviation N γ)
    (cylinderTeacherCost_nonneg d r C) (by positivity)
    (powerStandardDeviation_pos hN γ)
    (width_mul_powerStandardDeviation_sq_le_one hN hγ) hJR hm hK hrows hhidden
  rw [powerPrior_eq_smallPrior_standardDeviation hN γ]
  exact (cylinder_polynomial_exp_le hN d r C hγ).trans hmass

/-- The endpoint target bound, with no power notation in the width factor. -/
theorem meanField_target_mass_polynomial {d C N r : ℕ}
    (hd : 0 < d) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) :
    Real.exp (-(cylinderPolynomialCoefficient r *
      (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r * (N : ℝ))) ≤
      functionMass φ (1/2) (powerPrior d N r 1) f := by
  simpa only [Real.rpow_one] using
    powerPrior_target_mass_polynomial hd φ hφ f hf hCN (γ := 1) le_rfl

/-- A single target-mass budget for every admissible width below a threshold.
This is the small-width input to the finite statistical splice. -/
theorem powerPrior_target_mass_below_threshold {d C N r T : ℕ}
    (hd : 0 < d) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) (hNT : N ≤ T) {γ : ℝ} (hγ : 1 ≤ γ) :
    Real.exp (-(cylinderPolynomialCoefficient r *
      (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r * (T : ℝ) ^ γ)) ≤
      functionMass φ (1/2) (powerPrior d N r γ) f := by
  apply le_trans _ (powerPrior_target_mass_polynomial hd φ hφ f hf hCN hγ)
  apply Real.exp_le_exp.mpr
  apply neg_le_neg
  apply mul_le_mul_of_nonneg_left
  · exact Real.rpow_le_rpow (Nat.cast_nonneg N) (by exact_mod_cast hNT)
      (zero_le_one.trans hγ)
  · have := (cylinderPolynomialCoefficient_pos r).le
    positivity

end NeuralGeneralization.ConcreteModel
