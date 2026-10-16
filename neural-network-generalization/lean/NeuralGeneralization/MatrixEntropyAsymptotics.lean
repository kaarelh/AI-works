import NeuralGeneralization.GaussianApproximationTail
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

/-! # Absorbing the matrix witness entropy for every fixed gamma greater than one -/

noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped Topology NNReal

namespace NeuralGeneralization
open LowRankGrid

def matrixTruncationScale (N : ℕ) (γ : ℝ) : ℝ :=
  (Real.sqrt ((N : ℝ) ^ ((γ - 1) / 2)))⁻¹

theorem matrixTruncationScale_pos {N : ℕ} (hN : 0 < N) (γ : ℝ) :
    0 < matrixTruncationScale N γ := by
  unfold matrixTruncationScale
  exact inv_pos.mpr (Real.sqrt_pos.mpr (Real.rpow_pos_of_pos (by exact_mod_cast hN) _))

theorem matrixTruncationScale_sq {N : ℕ} (hN : 0 < N) (γ : ℝ) :
    (matrixTruncationScale N γ) ^ 2 = ((N : ℝ) ^ ((γ - 1) / 2))⁻¹ := by
  rw [matrixTruncationScale, inv_pow, Real.sq_sqrt (Real.rpow_nonneg (by positivity) _)]

theorem grid_log_bound {N : ℕ} (hN : 2 ≤ N) :
    Real.log (2 * (gridMesh N : ℝ) + 1) ≤ 7 * Real.log (N : ℝ) := by
  have hn : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hn0 : (0 : ℝ) < N := by linarith
  have h3 : (1 : ℝ) ≤ (N : ℝ) ^ 3 := one_le_pow₀ (by linarith)
  have h4 : (16 : ℝ) ≤ (N : ℝ) ^ 4 := by
    have h := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 2) hn 4
    norm_num at h ⊢
    exact h
  have hpoly : 2 * (gridMesh N : ℝ) + 1 ≤ (N : ℝ) ^ 7 := by
    dsimp [gridMesh]
    push_cast
    calc
      2 * (6 * (N : ℝ) ^ 3) + 1 ≤ 13 * (N : ℝ) ^ 3 := by linarith
      _ ≤ (N : ℝ) ^ 3 * (N : ℝ) ^ 4 := by nlinarith [mul_nonneg (sq_nonneg (N : ℝ)) hn0.le]
      _ = _ := by ring
  calc
    _ ≤ Real.log ((N : ℝ) ^ 7) := Real.log_le_log (by positivity) hpoly
    _ = _ := by rw [Real.log_pow]; norm_num

theorem matrixGridEntropy_bound {N : ℕ} (hN : 2 ≤ N)
    (γ K : ℝ) (hγ : 1 < γ) (hK : 1 ≤ K) :
    matrixGridEntropy N (matrixTruncationScale N γ) K ≤
      44 * K * ((N : ℝ) ^ ((γ - 1) / 2)) * N * Real.log (N : ℝ) := by
  have hn : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hn1 : (1 : ℝ) ≤ N := by linarith
  have hn0 : (0 : ℝ) < N := by linarith
  have hP : 1 ≤ (N : ℝ) ^ ((γ - 1) / 2) := Real.one_le_rpow hn1 (by linarith)
  have hP0 : 0 < (N : ℝ) ^ ((γ - 1) / 2) := by linarith
  have hKP : 1 ≤ K * (N : ℝ) ^ ((γ - 1) / 2) := by nlinarith
  have hKPx : 1 ≤ K * (N : ℝ) ^ ((γ - 1) / 2) * N := by nlinarith
  have hlog : 0 ≤ Real.log (N : ℝ) := Real.log_nonneg hn1
  have hfirst : Real.log ((N : ℝ) + 1) ≤ 2 * Real.log (N : ℝ) := by
    calc
      _ ≤ Real.log ((N : ℝ) ^ 2) := Real.log_le_log (by positivity) (by nlinarith)
      _ = _ := by rw [Real.log_pow]; norm_num
  have hquot : K / (matrixTruncationScale N γ) ^ 2 = K * (N : ℝ) ^ ((γ - 1) / 2) := by
    rw [matrixTruncationScale_sq (by omega) γ, div_inv_eq_mul]
  have hsecond : (K / (matrixTruncationScale N γ) ^ 2 + 1) *
      (2 * (N : ℝ) + 1) * Real.log (2 * (gridMesh N : ℝ) + 1) ≤
      (2 * K * (N : ℝ) ^ ((γ - 1) / 2)) * (3 * N) * (7 * Real.log (N : ℝ)) := by
    rw [hquot]
    apply mul_le_mul
    · apply mul_le_mul
      · linarith
      · linarith
      · positivity
      · positivity
    · exact grid_log_bound hN
    · exact Real.log_nonneg (by have := Nat.cast_nonneg (gridMesh N) (α := ℝ); linarith)
    · positivity
  dsimp [matrixGridEntropy]
  have hsmall := mul_le_mul_of_nonneg_right hKPx hlog
  nlinarith

/-- The width threshold depends on gamma, but not on the energy budget. -/
theorem eventually_matrix_entropy_small (γ : ℝ) (hγ : 1 < γ) :
    ∀ᶠ N : ℕ in atTop, ∀ K : ℝ, 1 ≤ K →
      matrixGridEntropy N (matrixTruncationScale N γ) K ≤
        K * (N : ℝ) ^ γ / 64 := by
  let δ := (γ - 1) / 2
  have hδ : 0 < δ := by dsimp [δ]; linarith
  have hlim : Tendsto (fun N : ℕ => Real.log (N : ℝ) / (N : ℝ) ^ δ)
      atTop (𝓝 0) :=
    (isLittleO_log_rpow_atTop hδ).tendsto_div_nhds_zero.comp tendsto_natCast_atTop_atTop
  have hevent : ∀ᶠ N : ℕ in atTop,
      Real.log (N : ℝ) / (N : ℝ) ^ δ ≤ 1 / (44 * 64 : ℝ) :=
    hlim.eventually (eventually_le_nhds (by norm_num))
  filter_upwards [hevent, eventually_ge_atTop 2] with N he hN K hK
  have hn0 : (0 : ℝ) < N := by exact_mod_cast (show 0 < N by omega)
  have hpow : 0 < (N : ℝ) ^ δ := Real.rpow_pos_of_pos hn0 δ
  have hlog : Real.log (N : ℝ) ≤ (N : ℝ) ^ δ / (44 * 64) := by
    have hh := (div_le_iff₀ hpow).mp he
    linarith
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
    _ ≤ 44 * K * (N : ℝ) ^ δ * N * ((N : ℝ) ^ δ / (44 * 64)) :=
      mul_le_mul_of_nonneg_left hlog (by positivity)
    _ = K * ((N : ℝ) ^ δ * N * (N : ℝ) ^ δ) / 64 := by ring
    _ = _ := by rw [hid]

/-- Every fixed above-mean-field exponent has one energy-independent width
threshold after which actual matrix approximation fails with exponentially
small probability. The additional `K≤N²` only controls the crude norm tail. -/
theorem eventually_gaussian_matrix_approximation_tail (γ : ℝ) (hγ : 1 < γ) :
    ∀ᶠ N : ℕ in atTop, ∀ K : ℝ, 1 ≤ K → K ≤ (N : ℝ) ^ 2 →
      (Measure.pi fun _ : Fin N × Fin N =>
        gaussianReal 0 ((N : ℝ) ^ (-γ)).toNNReal).real
        (matrixApproximationFailure N (matrixTruncationScale N γ) K) ≤
        2 * Real.exp (-K * (N : ℝ) ^ γ / 64) := by
  filter_upwards [eventually_matrix_entropy_small γ hγ, eventually_ge_atTop 8]
    with N hentropy hN K hK hKN
  have hn : (8 : ℝ) ≤ N := by exact_mod_cast hN
  have hn0 : (0 : ℝ) < N := by linarith
  have hn1 : (1 : ℝ) ≤ N := by linarith
  have hpow : 0 < (N : ℝ) ^ γ := Real.rpow_pos_of_pos hn0 γ
  have hpown : (N : ℝ) ≤ (N : ℝ) ^ γ := by
    simpa only [Real.rpow_one] using Real.rpow_le_rpow_of_exponent_le hn1 hγ.le
  have hv : 0 < (N : ℝ) ^ (-γ) := Real.rpow_pos_of_pos hn0 _
  have hvsmall : (N : ℝ) ^ (-γ) ≤ 1 / 8 := by
    rw [Real.rpow_neg hn0.le]
    exact (inv_le_comm₀ hpow (by norm_num)).mpr (by linarith)
  have hcoe : ((((N : ℝ) ^ (-γ)).toNNReal : ℝ≥0) : ℝ) = (N : ℝ) ^ (-γ) :=
    Real.coe_toNNReal _ hv.le
  have ht := gaussian_matrix_approximation_tail (show 0 < N by omega)
    ((N : ℝ) ^ (-γ)).toNNReal (by simpa only [hcoe] using hv)
    (by simpa only [hcoe] using hvsmall)
    (matrixTruncationScale N γ) K (matrixTruncationScale_pos (by omega) γ) hK
  have hd4 : -(N : ℝ) ^ 2 / (4 * (N : ℝ) ^ (-γ)) =
      -(N : ℝ) ^ 2 * (N : ℝ) ^ γ / 4 := by
    rw [Real.rpow_neg hn0.le]
    field_simp
  have hd32 : K / (32 * (N : ℝ) ^ (-γ)) = K * (N : ℝ) ^ γ / 32 := by
    rw [Real.rpow_neg hn0.le]
    field_simp
  simp only [hcoe, hd4, hd32] at ht
  have he1 : Real.exp (-(N : ℝ) ^ 2 * (N : ℝ) ^ γ / 4) ≤
      Real.exp (-K * (N : ℝ) ^ γ / 64) := by
    apply Real.exp_le_exp.mpr
    nlinarith [mul_le_mul_of_nonneg_right hKN hpow.le]
  have he2 : Real.exp (matrixGridEntropy N (matrixTruncationScale N γ) K -
        K * (N : ℝ) ^ γ / 32) ≤ Real.exp (-K * (N : ℝ) ^ γ / 64) := by
    apply Real.exp_le_exp.mpr
    have hh := hentropy K hK
    linarith
  linarith

end NeuralGeneralization
