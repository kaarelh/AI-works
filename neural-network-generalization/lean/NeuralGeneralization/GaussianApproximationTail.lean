import NeuralGeneralization.MatrixEnergyWitness
import NeuralGeneralization.GaussianLowRankTail
import NeuralGeneralization.GaussianTail

/-!
# Low-energy approximation of actual Gaussian matrices

The deterministic orthogonal-energy witness and its explicit finite grid
give a tail for failure to approximate a Gaussian matrix in operator norm
by a matrix of bounded squared Frobenius norm.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization
open LowRankGrid

theorem gaussian_squaredNorm_upper_tail {ι : Type*} [Fintype ι]
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) (u : ℝ)
    (hu : 8 * (Fintype.card ι : ℝ) * (v : ℝ) ≤ u) :
    (Measure.pi fun _ : ι => gaussianReal 0 v).real
      {x : ι → ℝ | u ≤ ∑ i, x i ^ 2} ≤ Real.exp (-u / (4 * (v : ℝ))) := by
  have h := GaussianTail.gaussian_squaredNorm_rate_upper (ι := ι) v hv u (1 / 4)
    (by norm_num) (by norm_num)
  have hsqrt : (Real.sqrt (1 / 4 : ℝ))⁻¹ = 2 := by
    rw [show (1 / 4 : ℝ) = (1 / 2 : ℝ) ^ 2 by norm_num, Real.sqrt_sq_eq_abs]
    norm_num
  rw [hsqrt] at h
  have hpow : (2 : ℝ) ^ Fintype.card ι ≤ Real.exp (Fintype.card ι : ℝ) := by
    have he : (2 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
    simpa only [← Real.exp_nat_mul, mul_one] using
      pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 2) he (Fintype.card ι)
  calc
    _ ≤ Real.exp (-((1 - 1 / 4) * u) / (2 * (v : ℝ))) *
        (2 : ℝ) ^ Fintype.card ι := h
    _ ≤ Real.exp (-((1 - 1 / 4) * u) / (2 * (v : ℝ))) *
        Real.exp (Fintype.card ι : ℝ) :=
      mul_le_mul_of_nonneg_left hpow (Real.exp_pos _).le
    _ = Real.exp (-((1 - 1 / 4) * u) / (2 * (v : ℝ)) + Fintype.card ι) :=
      (Real.exp_add _ _).symm
    _ ≤ _ := by
      apply Real.exp_le_exp.mpr
      apply (le_div_iff₀ (by positivity : 0 < 4 * (v : ℝ))).mpr
      have he : (-((1 - 1 / 4) * u) / (2 * (v : ℝ)) + Fintype.card ι) *
          (4 * (v : ℝ)) = -(3 / 2) * u + 4 * Fintype.card ι * (v : ℝ) := by
        field_simp
        ring
      rw [he]
      linarith

def matrixApproximationFailure (N : ℕ) (a K : ℝ) :
    Set (Fin N × Fin N → ℝ) :=
  {G | ¬ ∃ H : Fin N × Fin N → ℝ, squaredSum H ≤ K ∧
    ‖matrixOperator G - matrixOperator H‖ ≤ a}

def approximationRanks (N : ℕ) (a K : ℝ) : Finset ℕ :=
  (Finset.range (N + 1)).filter fun R => (R : ℝ) ≤ K / a ^ 2 + 1

theorem approximationFailure_subset (N : ℕ) (a K : ℝ) (ha : 0 < a) (hK : 0 ≤ K) :
    matrixApproximationFailure N a K ⊆
      {G | (N : ℝ) ^ 2 ≤ squaredSum G} ∪
        ⋃ R ∈ approximationRanks N a K, witnessEvent N R (Real.sqrt K) := by
  intro G hG
  by_cases hnorm : (N : ℝ) ^ 2 ≤ squaredSum G
  · exact Or.inl hnorm
  right
  rcases matrix_approximation_or_factor_witness G a K ha hK with hgood | hbad
  · exact False.elim (hG hgood)
  obtain ⟨R, hRN, hR, p, hp, henergy, halign⟩ := hbad
  apply Set.mem_iUnion₂.mpr
  refine ⟨R, ?_, ?_⟩
  · exact Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega), hR⟩
  · refine ⟨(lt_of_not_ge hnorm).le, p, hp, henergy.le, ?_⟩
    simpa only [alignment, mul_comm] using halign.le

def matrixGridEntropy (N : ℕ) (a K : ℝ) : ℝ :=
  Real.log ((N : ℝ) + 1) +
    (K / a ^ 2 + 1) * (2 * (N : ℝ) + 1) * Real.log (2 * (gridMesh N : ℝ) + 1)

theorem grid_count_le_exp {N R : ℕ} (a K : ℝ)
    (hR : (R : ℝ) ≤ K / a ^ 2 + 1) :
    (((2 * gridMesh N + 1) ^ (R * (2 * N + 1)) : ℕ) : ℝ) ≤
      Real.exp ((K / a ^ 2 + 1) * (2 * (N : ℝ) + 1) *
        Real.log (2 * (gridMesh N : ℝ) + 1)) := by
  have hb : (0 : ℝ) < 2 * (gridMesh N : ℝ) + 1 := by positivity
  have hlog : 0 ≤ Real.log (2 * (gridMesh N : ℝ) + 1) :=
    Real.log_nonneg (by have := Nat.cast_nonneg (gridMesh N) (α := ℝ); linarith)
  have he : (((2 * gridMesh N + 1) ^ (R * (2 * N + 1)) : ℕ) : ℝ) =
      Real.exp ((R : ℝ) * (2 * (N : ℝ) + 1) *
        Real.log (2 * (gridMesh N : ℝ) + 1)) := by
    rw [show (R : ℝ) * (2 * (N : ℝ) + 1) = (R * (2 * N + 1) : ℕ) by norm_cast,
      Real.exp_nat_mul, Real.exp_log hb]
    push_cast
    rfl
  rw [he]
  exact Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hR (by positivity)) hlog)

/-- The matrix tail with the explicit finite-grid entropy. -/
theorem gaussian_matrix_approximation_tail {N : ℕ} (hN : 0 < N)
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) (hvsmall : (v : ℝ) ≤ 1 / 8)
    (a K : ℝ) (ha : 0 < a) (hK : 1 ≤ K) :
    (Measure.pi fun _ : Fin N × Fin N => gaussianReal 0 v).real
      (matrixApproximationFailure N a K) ≤
      Real.exp (-(N : ℝ) ^ 2 / (4 * (v : ℝ))) +
        Real.exp (matrixGridEntropy N a K - K / (32 * (v : ℝ))) := by
  classical
  let μ : Measure (Fin N × Fin N → ℝ) := Measure.pi fun _ => gaussianReal 0 v
  let E : ℝ := (K / a ^ 2 + 1) * (2 * (N : ℝ) + 1) *
    Real.log (2 * (gridMesh N : ℝ) + 1)
  have hlarge : μ.real {G | (N : ℝ) ^ 2 ≤ squaredSum G} ≤
      Real.exp (-(N : ℝ) ^ 2 / (4 * (v : ℝ))) := by
    apply gaussian_squaredNorm_upper_tail v hv
    simp only [Fintype.card_prod, Fintype.card_fin, Nat.cast_mul]
    nlinarith [mul_le_mul_of_nonneg_left hvsmall (sq_nonneg (N : ℝ))]
  have hsmall : μ.real (⋃ R ∈ approximationRanks N a K,
      witnessEvent N R (Real.sqrt K)) ≤
      Real.exp (matrixGridEntropy N a K - K / (32 * (v : ℝ))) := by
    have hterm R (hR : R ∈ approximationRanks N a K) :
        μ.real (witnessEvent N R (Real.sqrt K)) ≤
          Real.exp (E - K / (32 * (v : ℝ))) := by
      obtain ⟨hRN, hRK⟩ := Finset.mem_filter.mp hR
      have hb : 1 ≤ Real.sqrt K := by
        simpa using Real.sqrt_le_sqrt hK
      have ht := gaussian_lowRank_witness_tail hN
        (show R ≤ N by have := Finset.mem_range.mp hRN; omega) v hv (Real.sqrt K) hb
      rw [Real.sq_sqrt (by linarith : 0 ≤ K)] at ht
      calc
        _ ≤ (((2 * gridMesh N + 1) ^ (R * (2 * N + 1)) : ℕ) : ℝ) *
            Real.exp (-K / (32 * (v : ℝ))) := ht
        _ ≤ Real.exp E * Real.exp (-K / (32 * (v : ℝ))) :=
          mul_le_mul_of_nonneg_right (grid_count_le_exp a K hRK) (Real.exp_pos _).le
        _ = _ := by rw [← Real.exp_add]; congr 1; ring
    calc
      _ ≤ ∑ R ∈ approximationRanks N a K, μ.real (witnessEvent N R (Real.sqrt K)) :=
        measureReal_biUnion_finset_le _ _
      _ ≤ ∑ _R ∈ approximationRanks N a K, Real.exp (E - K / (32 * (v : ℝ))) :=
        Finset.sum_le_sum hterm
      _ = (approximationRanks N a K).card * Real.exp (E - K / (32 * (v : ℝ))) := by
        rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ ((N : ℝ) + 1) * Real.exp (E - K / (32 * (v : ℝ))) := by
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
    _ ≤ _ := add_le_add hlarge hsmall

end NeuralGeneralization
