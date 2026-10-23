import NeuralGeneralization.BatchTwoContinuousFiniteTargetPolynomial

/-! Exact finite-scale target-tube mass, including the mean-field endpoint. -/
noncomputable section
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteTarget
open ConcreteModel BatchTwoNonGaussian

theorem powerPrior_uniformTube_mass (ν : CoordinateLaw) {d C N r : ℕ}
    (hd : 0<d) (hC : 0<C) (hCN : C≤N) {B ρ γ : ℝ} (hB : 0≤B) (hρ : 0<ρ)
    (hγ : 1≤γ) (teacher : Weights d C r) (hteacher : boundedWeights B teacher)
    (X : Set (RealInput d)) (hX : IsCompact X) (hball : ∀ x ∈ X, ∑ j, x j^2≤1) :
    Real.exp (-(targetCost ν d C r B ρ*(N : ℝ)^γ)) ≤
      (powerPrior ν d N r γ).real (uniformTube Real.tanh (output Real.tanh teacher) X ρ) := by
  have hN : 0<N := hC.trans_le hCN
  rw [powerPrior_eq_smallPrior_standardDeviation ν hd hN γ]
  have h := smallPrior_uniformTube_mass ν hd hC hCN hB hρ
    (powerStandardDeviation_pos hN γ) teacher hteacher X hX hball
    (width_mul_powerStandardDeviation_sq_le_one hN hγ)
  have he : -targetCost ν d C r B ρ/powerStandardDeviation N γ^2=
      -(targetCost ν d C r B ρ*(N : ℝ)^γ) := by
    rw [←powerStandardDeviation_inv_sq hN γ]
    ring
  rwa [he] at h

#print axioms powerPrior_uniformTube_mass
#print axioms targetCost_polynomial_envelope
end NeuralGeneralization.BatchTwoContinuous.FiniteTarget
