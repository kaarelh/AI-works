import NeuralGeneralization.DualCertificate
import NeuralGeneralization.CovarianceDualLift
import NeuralGeneralization.CovarianceIndexCounting

/-!
# The actual empirical covariance certificate on the Boolean cube

The reference field law is any probability law, including singular Gaussian
laws. Its 2^(2d) covariance coordinates contribute only 4d to the log count.
Outside the measured exceptional event, an actual symmetric exponential
tilt has entropy at most K and entrywise covariance error at most K/G.
-/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.CovarianceDualCertificate
open ConcreteModel BoundedDual ActualBoundedDual CompressionSampling
open CovarianceDualLift DualCertificate

variable {d : ℕ} (μ : Measure (Cube d → ℝ)) [IsProbabilityMeasure μ]

/-- The actual IID covariance bad event has a dimension-linear exponent. -/
theorem covariance_bad_event_tail (hd : 0 < d)
    (φ : ℝ → ℝ) (hφmeas : Measurable φ) (hφbound : ∀ z, |φ z| ≤ 1)
    {N s : ℕ} (hN : 0 < N) (hs : 0 < s) {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (iidSamples μ N).real (badEvent μ (features φ) N G K) ≤
      Real.exp (4 * (d : ℝ) * (s : ℝ) -
        (N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) := by
  apply (bounded_dual_tail_exp μ (features φ) (measurable_features φ hφmeas)
    (features_bound φ hφbound) hN hs hG K).trans
  apply Real.exp_le_exp.mpr
  have h := mul_le_mul_of_nonneg_left
    (CovarianceIndexCounting.covariance_log_atom_count_le_four_mul hd)
    (Nat.cast_nonneg s : (0 : ℝ) ≤ (s : ℝ))
  nlinarith

/-- The good event yields a symmetric parameter for the actual tilted law. -/
theorem covariance_lift_of_not_bad
    (φ : ℝ → ℝ) (hφmeas : Measurable φ) (hφbound : ∀ z, |φ z| ≤ 1)
    {N : ℕ} {G K : ℝ} (hG : 0 < G)
    (a : Fin N → Cube d → ℝ) (ha : a ∉ badEvent μ (features φ) N G K) :
    ∃ A : Cube d → Cube d → ℝ, (∀ i j, A i j = A j i) ∧
      SymmetricTilt.entryL1 A ≤ G ∧
      entropy μ (features φ) (parameter A) ≤ K ∧
      maxAbs (empirical (features φ) a - mean μ (features φ) (parameter A)) ≤ K / G := by
  apply exists_symmetric_covariance_lift μ φ hφmeas hφbound
    (empirical (features φ) a) hG
  intro v hv
  by_contra h
  exact ha ⟨v, hv, lt_of_not_ge h⟩

end NeuralGeneralization.CovarianceDualCertificate
end
