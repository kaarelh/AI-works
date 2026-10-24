import NeuralGeneralization.BatchTwoNonGaussianApproximationTail
import NeuralGeneralization.MatrixEntropyAsymptotics
import NeuralGeneralization.PowerPriorScaling

/-! The actual non-Gaussian spectral witness entropy is absorbed at every
fixed exponent γ>1, uniformly over the energy budget. -/
noncomputable section
open Filter MeasureTheory
open scoped Topology
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel

theorem eventually_matrix_entropy_small (ν : CoordinateLaw) (γ : ℝ) (hγ : 1 < γ) :
    ∀ᶠ N : ℕ in atTop, ∀ K : ℝ, 1 ≤ K →
      matrixGridEntropy N (matrixTruncationScale N γ) K ≤
        K * (N : ℝ) ^ γ / (64*subGaussianVariance ν) := by
  let δ := (γ - 1) / 2
  have hδ : 0 < δ := by dsimp [δ]; linarith
  have hlim : Tendsto (fun N : ℕ => Real.log (N : ℝ) / (N : ℝ) ^ δ)
      atTop (𝓝 0) :=
    (isLittleO_log_rpow_atTop hδ).tendsto_div_nhds_zero.comp tendsto_natCast_atTop_atTop
  have hevent : ∀ᶠ N : ℕ in atTop,
      Real.log (N : ℝ) / (N : ℝ) ^ δ ≤ 1 / (44 * 64 * subGaussianVariance ν : ℝ) :=
    hlim.eventually (eventually_le_nhds (by have := subGaussianVariance_pos ν; positivity))
  filter_upwards [hevent, eventually_ge_atTop 2] with N he hN K hK
  have hn0 : (0 : ℝ) < N := by exact_mod_cast (show 0 < N by omega)
  have hpow : 0 < (N : ℝ) ^ δ := Real.rpow_pos_of_pos hn0 δ
  have hlog : Real.log (N : ℝ) ≤ (N : ℝ) ^ δ / (44 * 64 * subGaussianVariance ν) := by
    have hh := (div_le_iff₀ hpow).mp he
    simpa only [one_div,mul_comm,div_eq_mul_inv,one_mul] using hh
  have hid : (N : ℝ) ^ δ * N * (N : ℝ) ^ δ = (N : ℝ) ^ γ := by
    calc
      _ = (N : ℝ) ^ (δ + δ) * (N : ℝ) ^ (1 : ℝ) := by
        rw [Real.rpow_one, Real.rpow_add hn0]
        ring
      _ = (N : ℝ) ^ (δ + δ + 1) := (Real.rpow_add hn0 _ _).symm
      _ = _ := by
        congr 1
        dsimp [δ]
        ring
  calc
    _ ≤ 44 * K * (N : ℝ) ^ δ * N * Real.log (N : ℝ) :=
      matrixGridEntropy_bound hN γ K hγ hK
    _ ≤ 44 * K * (N : ℝ) ^ δ * N * ((N : ℝ) ^ δ / (44 * 64 * subGaussianVariance ν)) :=
      mul_le_mul_of_nonneg_left hlog (by positivity)
    _ = K * ((N : ℝ) ^ δ * N * (N : ℝ) ^ δ) / (64*subGaussianVariance ν) := by ring
    _ = _ := by rw [hid]

theorem eventually_matrix_approximation_tail (ν : CoordinateLaw) (γ : ℝ) (hγ : 1 < γ) :
    ∀ᶠ N : ℕ in atTop, ∀ K : ℝ, 1 ≤ K → K ≤ (N : ℝ)^2 →
      (scaledCoordinates ν (Fin N × Fin N) (powerStandardDeviation N γ)).real
        (matrixApproximationFailure N (matrixTruncationScale N γ) K) ≤
        2*Real.exp (-K*(N : ℝ)^γ/(64*subGaussianVariance ν)) := by
  have hv := subGaussianVariance_pos ν
  filter_upwards [eventually_matrix_entropy_small ν γ hγ,
    eventually_ge_atTop (⌈8*subGaussianVariance ν⌉₊+1)] with N hentropy hN K hK hKN
  have hN0 : 0 < N := by omega
  have hn0 : (0 : ℝ) < N := Nat.cast_pos.mpr hN0
  have hn1 : (1 : ℝ) ≤ N := by exact_mod_cast hN0
  have hnlarge : 8*subGaussianVariance ν ≤ (N : ℝ) :=
    (Nat.le_ceil _).trans (by exact_mod_cast (show ⌈8*subGaussianVariance ν⌉₊ ≤ N by omega))
  have hpow : 0 < (N : ℝ)^γ := Real.rpow_pos_of_pos hn0 γ
  have hpown : (N : ℝ) ≤ (N : ℝ)^γ := by
    simpa only [Real.rpow_one] using Real.rpow_le_rpow_of_exponent_le hn1 hγ.le
  have hsmall : powerStandardDeviation N γ^2*subGaussianVariance ν ≤ 1/8 := by
    rw [powerStandardDeviation_sq hN0,Real.rpow_neg hn0.le]
    have he : ((N : ℝ)^γ)⁻¹*subGaussianVariance ν =
        subGaussianVariance ν/(N : ℝ)^γ := by ring
    rw [he]
    apply (div_le_iff₀ hpow).mpr
    linarith
  have ht := actual_matrix_approximation_tail ν hN0 (powerStandardDeviation_pos hN0 γ)
    hsmall (matrixTruncationScale N γ) K (matrixTruncationScale_pos hN0 γ) hK
  have he (x c : ℝ) : x/(c*(powerStandardDeviation N γ^2*subGaussianVariance ν))=
      x*(N : ℝ)^γ/(c*subGaussianVariance ν) := by
    rw [powerStandardDeviation_sq hN0,Real.rpow_neg hn0.le]
    field_simp
  rw [he,he] at ht
  have hden : 0 < 64*subGaussianVariance ν := by positivity
  have he1 : Real.exp (-(N : ℝ)^2*(N : ℝ)^γ/(8*subGaussianVariance ν)) ≤
      Real.exp (-K*(N : ℝ)^γ/(64*subGaussianVariance ν)) := by
    apply Real.exp_le_exp.mpr
    apply (div_le_div_iff₀ (by positivity : 0 < 8*subGaussianVariance ν) hden).mpr
    have hh := mul_le_mul_of_nonneg_right hKN hpow.le
    nlinarith [mul_nonneg (sub_nonneg.mpr hh) hv.le,
      mul_nonneg (by positivity : 0 ≤ K*(N : ℝ)^γ) hv.le]
  have he2 : Real.exp (matrixGridEntropy N (matrixTruncationScale N γ) K-
      K*(N : ℝ)^γ/(32*subGaussianVariance ν)) ≤
      Real.exp (-K*(N : ℝ)^γ/(64*subGaussianVariance ν)) := by
    apply Real.exp_le_exp.mpr
    have hh := hentropy K hK
    have hid : K*(N : ℝ)^γ/(32*subGaussianVariance ν)=
        2*(K*(N : ℝ)^γ/(64*subGaussianVariance ν)) := by ring
    rw [hid]
    simp only [neg_mul,neg_div]
    linarith
  linarith

end NeuralGeneralization.BatchTwoNonGaussian
