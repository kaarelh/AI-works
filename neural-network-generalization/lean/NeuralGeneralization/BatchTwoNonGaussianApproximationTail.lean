import NeuralGeneralization.BatchTwoNonGaussianScaledTail

/-! Operator approximation of the actual scaled non-Gaussian matrix. The
finite low-rank witness grid is deterministic; every probability bound below
is proved for the actual independent coordinate law. -/

noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open LowRankGrid

theorem actual_candidate_alignment_tail (ν : CoordinateLaw) {N R : ℕ}
    {σ : ℝ} (hσ : 0 < σ) (b : ℝ) (hb : 0 ≤ b)
    (Z : Fin N × Fin N → ℝ) (hZ : Z ∈ candidates N R) :
    (scaledCoordinates ν (Fin N × Fin N) σ).real {G | b / 2 ≤ alignment G Z} ≤
      Real.exp (-b ^ 2 / (32 * (σ ^ 2 * subGaussianVariance ν))) := by
  have hS : 0 < σ ^ 2 * subGaussianVariance ν := mul_pos (sq_pos_of_pos hσ) (subGaussianVariance_pos ν)
  have hvar : (σ ^ 2 * subGaussianVariance ν) * (∑ ij, Z ij ^ 2) ≤
      4 * (σ ^ 2 * subGaussianVariance ν) := by
    have h := mul_le_mul_of_nonneg_left (candidates_squaredSum_le N R Z hZ) hS.le
    simpa only [squaredSum, mul_comm] using h
  have h := scaled_linear_upper_tail ν σ Z (4 * (σ ^ 2 * subGaussianVariance ν)) (b / 2)
    (by positivity) (by positivity) hvar
  have he : -(b / 2) ^ 2 / (2 * (4 * (σ ^ 2 * subGaussianVariance ν))) =
      -b ^ 2 / (32 * (σ ^ 2 * subGaussianVariance ν)) := by ring
  simpa only [he, alignment] using h

theorem actual_lowRank_witness_tail (ν : CoordinateLaw) {N R : ℕ}
    (hN : 0 < N) (hR : R ≤ N) {σ : ℝ} (hσ : 0 < σ) (b : ℝ) (hb : 1 ≤ b) :
    (scaledCoordinates ν (Fin N × Fin N) σ).real (witnessEvent N R b) ≤
      ((2 * gridMesh N + 1) ^ (R * (2 * N + 1)) : ℕ) *
        Real.exp (-b ^ 2 / (32 * (σ ^ 2 * subGaussianVariance ν))) := by
  classical
  let μ := scaledCoordinates ν (Fin N × Fin N) σ
  calc
    _ ≤ μ.real (⋃ Z ∈ candidates N R, {G | b / 2 ≤ alignment G Z}) :=
      measureReal_mono (witnessEvent_subset_grid hN hR b hb) (measure_ne_top μ _)
    _ ≤ ∑ Z ∈ candidates N R, μ.real {G | b / 2 ≤ alignment G Z} :=
      measureReal_biUnion_finset_le _ _
    _ ≤ ∑ _Z ∈ candidates N R, Real.exp (-b ^ 2 / (32 * (σ ^ 2 * subGaussianVariance ν))) := by
      apply Finset.sum_le_sum
      intro Z hZ
      exact actual_candidate_alignment_tail ν hσ b (by linarith) Z hZ
    _ = (candidates N R).card * Real.exp (-b ^ 2 / (32 * (σ ^ 2 * subGaussianVariance ν))) := by
      rw [Finset.sum_const, nsmul_eq_mul]
    _ ≤ _ := by
      apply mul_le_mul_of_nonneg_right _ (Real.exp_pos _).le
      exact_mod_cast candidates_card N R

/-- The actual matrix approximation tail with its finite-grid entropy.
At every fixed exponent γ>1 the entropy is absorbed by N^γ, using the same
deterministic entropy analysis as the Gaussian theorem. -/
theorem actual_matrix_approximation_tail (ν : CoordinateLaw) {N : ℕ} (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (hsmall : σ ^ 2 * subGaussianVariance ν ≤ 1 / 8)
    (a K : ℝ) (ha : 0 < a) (hK : 1 ≤ K) :
    (scaledCoordinates ν (Fin N × Fin N) σ).real (matrixApproximationFailure N a K) ≤
      Real.exp (-(N : ℝ) ^ 2 / (8 * (σ ^ 2 * subGaussianVariance ν))) +
        Real.exp (matrixGridEntropy N a K - K / (32 * (σ ^ 2 * subGaussianVariance ν))) := by
  classical
  let μ := scaledCoordinates ν (Fin N × Fin N) σ
  let S := σ ^ 2 * subGaussianVariance ν
  let E : ℝ := (K / a ^ 2 + 1) * (2 * (N : ℝ) + 1) *
    Real.log (2 * (gridMesh N : ℝ) + 1)
  have hlarge : μ.real {G | (N : ℝ) ^ 2 ≤ squaredSum G} ≤
      Real.exp (-(N : ℝ) ^ 2 / (8 * S)) := by
    apply scaled_squaredNorm_upper_tail ν hσ
    simp only [Fintype.card_prod, Fintype.card_fin, Nat.cast_mul]
    nlinarith [mul_le_mul_of_nonneg_left hsmall (sq_nonneg (N : ℝ))]
  have hsmallEvent : μ.real (⋃ R ∈ approximationRanks N a K,
      witnessEvent N R (Real.sqrt K)) ≤ Real.exp (matrixGridEntropy N a K - K / (32 * S)) := by
    have hterm R (hR : R ∈ approximationRanks N a K) :
        μ.real (witnessEvent N R (Real.sqrt K)) ≤ Real.exp (E - K / (32 * S)) := by
      obtain ⟨hRN, hRK⟩ := Finset.mem_filter.mp hR
      have hb : 1 ≤ Real.sqrt K := by simpa using Real.sqrt_le_sqrt hK
      have ht := actual_lowRank_witness_tail ν hN
        (show R ≤ N by have := Finset.mem_range.mp hRN; omega) hσ (Real.sqrt K) hb
      rw [Real.sq_sqrt (by linarith : 0 ≤ K)] at ht
      calc
        _ ≤ (((2 * gridMesh N + 1) ^ (R * (2 * N + 1)) : ℕ) : ℝ) *
            Real.exp (-K / (32 * S)) := ht
        _ ≤ Real.exp E * Real.exp (-K / (32 * S)) :=
          mul_le_mul_of_nonneg_right (grid_count_le_exp a K hRK) (Real.exp_pos _).le
        _ = _ := by rw [← Real.exp_add]; congr 1; ring
    calc
      _ ≤ ∑ R ∈ approximationRanks N a K, μ.real (witnessEvent N R (Real.sqrt K)) :=
        measureReal_biUnion_finset_le _ _
      _ ≤ ∑ _R ∈ approximationRanks N a K, Real.exp (E - K / (32 * S)) :=
        Finset.sum_le_sum hterm
      _ = (approximationRanks N a K).card * Real.exp (E - K / (32 * S)) := by
        rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ ((N : ℝ) + 1) * Real.exp (E - K / (32 * S)) := by
        apply mul_le_mul_of_nonneg_right _ (Real.exp_pos _).le
        have hc := Finset.card_filter_le (Finset.range (N + 1))
          (fun R : ℕ => (R : ℝ) ≤ K / a ^ 2 + 1)
        rw [Finset.card_range] at hc
        simpa only [Finset.card_range, Nat.cast_add, Nat.cast_one] using
          (show ((approximationRanks N a K).card : ℝ) ≤ (N + 1 : ℕ) by exact_mod_cast hc)
      _ = _ := by
        rw [← Real.exp_log (show 0 < (N : ℝ) + 1 by positivity), ← Real.exp_add]
        congr 1
        dsimp [matrixGridEntropy, E]
        ring
  calc
    _ ≤ μ.real ({G | (N : ℝ) ^ 2 ≤ squaredSum G} ∪
        ⋃ R ∈ approximationRanks N a K, witnessEvent N R (Real.sqrt K)) :=
      measureReal_mono (approximationFailure_subset N a K ha (by linarith))
    _ ≤ μ.real {G | (N : ℝ) ^ 2 ≤ squaredSum G} +
        μ.real (⋃ R ∈ approximationRanks N a K, witnessEvent N R (Real.sqrt K)) :=
      measureReal_union_le _ _
    _ ≤ _ := add_le_add hlarge hsmallEvent

end NeuralGeneralization.BatchTwoNonGaussian
