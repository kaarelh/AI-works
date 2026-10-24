import NeuralGeneralization.BatchTwoContinuousFiniteSpectralCover
import NeuralGeneralization.BatchTwoNonGaussianNetworkSpectralTail

/-! Actual product-prior tail outside the uniform real-output cover. The
operator-approximation event need not be given any extra measurability axiom. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteSpectral
open ConcreteModel BatchTwoNonGaussian

theorem powerPrior_cover_complement_tail (ν : CoordinateLaw) {d N r K R : ℕ}
    (hd : 1≤d) (hN : 0<N) (hK0 : 1≤K) (hR : 1≤R)
    (hK : 8*((d : ℝ)+1)*subGaussianVariance ν≤(K : ℝ))
    (X : Set (RealInput d)) (hX : X.Nonempty) (hball : ∀ x∈X, ∑ j,x j^2≤1)
    (γ a B : ℝ) (hγ : 1≤γ) (ha : a≤radius r K R)
    (hmat : (scaledCoordinates ν (Fin N×Fin N) (powerStandardDeviation N γ)).real
      (matrixApproximationFailure N a K)≤B) :
    (powerPrior ν d N r γ).real (coverEvent d N r K R Real.tanh X)ᶜ≤
      2*Real.exp (-(K : ℝ)/(8*((N : ℝ)^(-γ)*subGaussianVariance ν)))+(r : ℝ)*B := by
  apply (measureReal_mono (Set.compl_subset_compl.mpr
    (goodSpectralWeights_subset_coverEvent hd hN hK0 hR Real.tanh tanh_admissible X hX hball ha))
    (measure_ne_top _ _)).trans
  exact powerPrior_badSpectralWeights_tail_of_gamma_ge_one ν (by omega) hN γ a B hγ hK hmat

theorem eventually_cover_complement_tail (ν : CoordinateLaw) (γ : ℝ) (hγ : 1<γ) :
    ∀ᶠ N : ℕ in Filter.atTop, ∀ d r K R : ℕ,
      1≤d → 1≤R → 8*NonGaussianMeanField.tailScale ν*(d+1)≤K → (K : ℝ)≤(N : ℝ)^2 →
      matrixTruncationScale N γ≤radius r K R →
      ∀ X : Set (RealInput d), X.Nonempty → (∀ x∈X, ∑ j,x j^2≤1) →
      (powerPrior ν d N r γ).real (coverEvent d N r K R Real.tanh X)ᶜ≤
        2*((r : ℝ)+1)*Real.exp (-(K : ℝ)*(N : ℝ)^γ/(64*(NonGaussianMeanField.tailScale ν : ℝ))) := by
  filter_upwards [eventually_matrix_approximation_tail ν γ hγ,
    Filter.eventually_ge_atTop 1] with N hmatrix hN d r K R hd hR hK hKN ha X hX hball
  have hN0 : 0<N := by omega
  have hq := NonGaussianMeanField.tailScale_ge_one ν
  have hvq := NonGaussianMeanField.tailScale_ge_variance ν
  have hv := subGaussianVariance_pos ν
  have hK0 : 0<K := by
    have hqn : 1≤NonGaussianMeanField.tailScale ν := by exact_mod_cast hq
    exact (Nat.mul_pos (Nat.mul_pos (by omega) (by omega)) (by omega)).trans_le hK
  have hKR : (1 : ℝ)≤K := by exact_mod_cast hK0
  have hKv : 8*((d : ℝ)+1)*subGaussianVariance ν≤(K : ℝ) := by
    have hc : 8*(NonGaussianMeanField.tailScale ν : ℝ)*((d : ℝ)+1)≤(K : ℝ) := by exact_mod_cast hK
    nlinarith [mul_le_mul_of_nonneg_left hvq (by positivity : 0≤8*((d : ℝ)+1))]
  have ht := powerPrior_cover_complement_tail ν hd hN0 hK0 hR hKv X hX hball γ
    (matrixTruncationScale N γ) (2*Real.exp (-(K : ℝ)*(N : ℝ)^γ/(64*subGaussianVariance ν)))
    hγ.le ha (hmatrix K hKR hKN)
  have hconvert : -(K : ℝ)/(8*((N : ℝ)^(-γ)*subGaussianVariance ν))=
      -(K : ℝ)*(N : ℝ)^γ/(8*subGaussianVariance ν) := by
    rw [Real.rpow_neg (Nat.cast_nonneg N)]
    field_simp
  have hprod : 0≤(K : ℝ)*(N : ℝ)^γ := by positivity
  have he1 : Real.exp (-(K : ℝ)/(8*((N : ℝ)^(-γ)*subGaussianVariance ν)))≤
      Real.exp (-(K : ℝ)*(N : ℝ)^γ/(64*(NonGaussianMeanField.tailScale ν : ℝ))) := by
    rw [hconvert]
    apply Real.exp_le_exp.mpr
    simp only [neg_mul,neg_div,neg_le_neg_iff]
    exact div_le_div_of_nonneg_left hprod (by positivity) (by linarith)
  have he2 : Real.exp (-(K : ℝ)*(N : ℝ)^γ/(64*subGaussianVariance ν))≤
      Real.exp (-(K : ℝ)*(N : ℝ)^γ/(64*(NonGaussianMeanField.tailScale ν : ℝ))) := by
    apply Real.exp_le_exp.mpr
    simp only [neg_mul,neg_div,neg_le_neg_iff]
    exact div_le_div_of_nonneg_left hprod (by positivity) (by linarith)
  have hr := mul_le_mul_of_nonneg_left he2 (show 0≤2*(r : ℝ) by positivity)
  nlinarith

end NeuralGeneralization.BatchTwoContinuous.FiniteSpectral
