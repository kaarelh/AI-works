import NeuralGeneralization.BatchTwoNonGaussianSpectralLaw
import NeuralGeneralization.BatchTwoNonGaussianEntropyAsymptotics
import NeuralGeneralization.BatchTwoNonGaussianMeanFieldBudget

/-! Whole-network spectral tails for the original non-Gaussian prior. -/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel

theorem powerPrior_badSpectralWeights_tail (ν : CoordinateLaw) {d N r K : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ a B : ℝ)
    (hfirst : 8 * ((N * (d+1) : ℕ) : ℝ) * ((N : ℝ) ^ (-γ)*subGaussianVariance ν) ≤ (K : ℝ))
    (hread : 8 * (N : ℝ) * ((N : ℝ) ^ (-γ)*subGaussianVariance ν) ≤ (K : ℝ))
    (hmat : (scaledCoordinates ν (Fin N × Fin N) (powerStandardDeviation N γ)).real
        (matrixApproximationFailure N a K) ≤ B) :
    (powerPrior ν d N r γ).real (goodSpectralWeightsAtRadius d N r K a)ᶜ ≤
      2 * Real.exp (-(K : ℝ) / (8 * ((N : ℝ) ^ (-γ)*subGaussianVariance ν))) + (r : ℝ) * B := by
  classical
  let μ := powerPrior ν d N r γ
  let F : Set (Weights d N r) :=
    {w | (K : ℝ) ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2)}
  let R : Set (Weights d N r) :=
    {w | (K : ℝ) ≤ (N : ℝ) * (∑ i, w (Sum.inr (Sum.inr i)) ^ 2)}
  let M (s : Fin r) : Set (Weights d N r) :=
    {w | (fun ij => w (Sum.inr (Sum.inl (s,ij.1,ij.2)))) ∈ matrixApproximationFailure N a K}
  have hF : μ.real F ≤ Real.exp (-(K : ℝ) / (8 * ((N : ℝ) ^ (-γ)*subGaussianVariance ν))) :=
    powerPrior_first_energy_tail ν hd hN γ K hfirst
  have hR : μ.real R ≤ Real.exp (-(K : ℝ) / (8 * ((N : ℝ) ^ (-γ)*subGaussianVariance ν))) :=
    powerPrior_readout_energy_tail ν hd hN γ K hread
  have hM : μ.real (⋃ s, M s) ≤ (r : ℝ) * B := by
    calc
      _ ≤ ∑ s, μ.real (M s) := measureReal_iUnion_fintype_le M
      _ ≤ ∑ _s : Fin r, B := Finset.sum_le_sum fun s _ =>
        powerPrior_internal_approximation_tail ν hd hN γ a K B s hmat
      _ = _ := by simp
  calc
    _ ≤ μ.real ((F ∪ R) ∪ ⋃ s, M s) :=
      measureReal_mono (badSpectralWeights_subset a) (measure_ne_top μ _)
    _ ≤ μ.real (F ∪ R) + μ.real (⋃ s, M s) := measureReal_union_le _ _
    _ ≤ μ.real F + μ.real R + μ.real (⋃ s, M s) :=
      add_le_add (measureReal_union_le F R) le_rfl
    _ ≤ _ := by linarith

/-- In `γ≥1`, an energy budget `K≥8(d+1)` controls both endpoint layers at
all widths. This leaves only the genuinely internal matrix estimate. -/
theorem powerPrior_badSpectralWeights_tail_of_gamma_ge_one (ν : CoordinateLaw) {d N r K : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ a B : ℝ) (hγ : 1 ≤ γ)
    (hK : 8 * ((d : ℝ)+1)*subGaussianVariance ν ≤ (K : ℝ))
    (hmat : (scaledCoordinates ν (Fin N × Fin N) (powerStandardDeviation N γ)).real
        (matrixApproximationFailure N a K) ≤ B) :
    (powerPrior ν d N r γ).real (goodSpectralWeightsAtRadius d N r K a)ᶜ ≤
      2 * Real.exp (-(K : ℝ) / (8 * ((N : ℝ) ^ (-γ)*subGaussianVariance ν))) + (r : ℝ) * B := by
  have hscale : (N : ℝ) * (N : ℝ) ^ (-γ) ≤ 1 := by
    simpa only [powerStandardDeviation_sq hN] using
      width_mul_powerStandardDeviation_sq_le_one hN hγ
  have hv := subGaussianVariance_pos ν
  apply powerPrior_badSpectralWeights_tail ν hd hN γ a B _ _ hmat
  · push_cast
    have hh := mul_le_mul_of_nonneg_left hscale
      (by positivity : 0 ≤ 8*((d : ℝ)+1)*subGaussianVariance ν)
    nlinarith
  · have hh := mul_le_mul_of_nonneg_left hscale
      (by positivity : 0 ≤ 8*subGaussianVariance ν)
    have hd0 : (0 : ℝ) ≤ d := Nat.cast_nonneg d
    nlinarith [mul_nonneg hd0 hv.le]

/-- Actual aggregate function-prior tail outside the finite compressed class. -/
theorem spectralFunctions_complement_mass_tail (ν : CoordinateLaw) {d N r K : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK0 : 0 < K)
    (hK : 8 * ((d : ℝ)+1)*subGaussianVariance ν ≤ (K : ℝ))
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (γ a B : ℝ) (hγ : 1 ≤ γ) (ha : a ≤ spectralTruncationRadius r K)
    (hmat : (scaledCoordinates ν (Fin N × Fin N) (powerStandardDeviation N γ)).real
        (matrixApproximationFailure N a K) ≤ B) :
    (∑ f ∈ Finset.univ \ spectralFunctions d r K φ,
      functionMass φ (1 / 2) (powerPrior ν d N r γ) f) ≤
      2 * Real.exp (-(K : ℝ) / (8 * ((N : ℝ) ^ (-γ)*subGaussianVariance ν))) + (r : ℝ) * B := by
  exact (spectralFunctions_complement_mass_le_radius hd hN (by omega)
    φ hφ (powerPrior ν d N r γ) a ha).trans
    (powerPrior_badSpectralWeights_tail_of_gamma_ge_one ν (by omega) hN γ a B hγ hK hmat)



theorem eventually_spectralFunctions_complement_mass_tail (ν : CoordinateLaw)
    (γ : ℝ) (hγ : 1 < γ) :
    ∀ᶠ N : ℕ in Filter.atTop, ∀ d r K : ℕ,
      1 ≤ d → 8*NonGaussianMeanField.tailScale ν*(d+1) ≤ K → (K : ℝ) ≤ (N : ℝ)^2 →
      matrixTruncationScale N γ ≤ spectralTruncationRadius r K →
      (∑ f ∈ Finset.univ \ spectralFunctions d r K Real.tanh,
        functionMass Real.tanh (1/2) (powerPrior ν d N r γ) f) ≤
        2*((r : ℝ)+1)*Real.exp (-(K : ℝ)*(N : ℝ)^γ/(64*(NonGaussianMeanField.tailScale ν : ℝ))) := by
  filter_upwards [eventually_matrix_approximation_tail ν γ hγ,
    Filter.eventually_ge_atTop 1] with N hmatrix hN d r K hd hK hKN ha
  have hN0 : 0 < N := by omega
  have hq := NonGaussianMeanField.tailScale_ge_one ν
  have hvq := NonGaussianMeanField.tailScale_ge_variance ν
  have hv := subGaussianVariance_pos ν
  have hK0 : 0 < K := by
    have hqnat : 1 ≤ NonGaussianMeanField.tailScale ν := by exact_mod_cast hq
    exact (Nat.mul_pos (Nat.mul_pos (by omega) (by omega)) (by omega)).trans_le hK
  have hKR : (1 : ℝ) ≤ K := by exact_mod_cast hK0
  have hKv : 8*((d : ℝ)+1)*subGaussianVariance ν ≤ (K : ℝ) := by
    have hcast : 8*(NonGaussianMeanField.tailScale ν : ℝ)*((d : ℝ)+1) ≤ (K : ℝ) := by exact_mod_cast hK
    nlinarith [mul_le_mul_of_nonneg_left hvq (by positivity : 0 ≤ 8*((d : ℝ)+1))]
  have ht := spectralFunctions_complement_mass_tail ν hd hN0 hK0 hKv Real.tanh tanh_admissible γ
    (matrixTruncationScale N γ)
    (2*Real.exp (-(K : ℝ)*(N : ℝ)^γ/(64*subGaussianVariance ν))) hγ.le ha (hmatrix K hKR hKN)
  have hconvert : -(K : ℝ)/(8*((N : ℝ)^(-γ)*subGaussianVariance ν))=
      -(K : ℝ)*(N : ℝ)^γ/(8*subGaussianVariance ν) := by
    rw [Real.rpow_neg (Nat.cast_nonneg N)]
    field_simp
  have hprod : 0 ≤ (K : ℝ)*(N : ℝ)^γ := by positivity
  have he1 : Real.exp (-(K : ℝ)/(8*((N : ℝ)^(-γ)*subGaussianVariance ν))) ≤
      Real.exp (-(K : ℝ)*(N : ℝ)^γ/(64*(NonGaussianMeanField.tailScale ν : ℝ))) := by
    rw [hconvert]
    apply Real.exp_le_exp.mpr
    simp only [neg_mul,neg_div,neg_le_neg_iff]
    exact div_le_div_of_nonneg_left hprod (by positivity) (by linarith)
  have he2 : Real.exp (-(K : ℝ)*(N : ℝ)^γ/(64*subGaussianVariance ν)) ≤
      Real.exp (-(K : ℝ)*(N : ℝ)^γ/(64*(NonGaussianMeanField.tailScale ν : ℝ))) := by
    apply Real.exp_le_exp.mpr
    simp only [neg_mul,neg_div,neg_le_neg_iff]
    exact div_le_div_of_nonneg_left hprod (by positivity) (by linarith)
  have hr := mul_le_mul_of_nonneg_left he2 (show 0 ≤ 2*(r : ℝ) by positivity)
  nlinarith

end NeuralGeneralization.BatchTwoNonGaussian
