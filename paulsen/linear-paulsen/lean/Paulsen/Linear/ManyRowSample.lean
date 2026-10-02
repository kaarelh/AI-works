import Paulsen.Linear.ManyRowGraph
import Paulsen.RowSeedCore
import Paulsen.HugeSeedGeneric
import Paulsen.GaussianOperatorNet

/-!
# A good Gaussian sample for the many-row seed

One sample satisfies simultaneously: the dense reference core for the
row-independent seed, operator-norm bounds `‖Z‖, ‖Z₀‖ ≤ 128` (net bound), and
the four Markov events for `‖Z‖_F²`, `‖Z₀ - Z‖_F²`, the fluctuation of `Q`,
and the row deviation `a ∑ (rᵢ² - 1)²`.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators

namespace Paulsen.Linear

open Paulsen

noncomputable section

/-- Existence of a sample on which every many-row event holds. -/
theorem exists_manyRow_sample {n d : ℕ} (X : Frame n d)
    (hn : 200 ≤ n) (hd : 0 < d) (hdn : d ≤ n) (hX : IsEqualNorm X)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1)) :
    ∃ g : FrameVector n d,
      (∀ i, 17 * n ≤ 20 *
        (largeNeighbors (fun i j =>
          ((rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j) ^ 2)
          (4 * rowSeedThreshold n d t h) i).card) ∧
      ‖(Matrix.toEuclideanLin (conditionedNoise X g)).toContinuousLinearMap‖ ≤ 128 ∧
      ‖(Matrix.toEuclideanLin (frameOfVector
        (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))).toContinuousLinearMap‖ ≤ 128 ∧
      (∑ i, rowNormSq (conditionedNoise X g) i) < 100 * (d : ℝ) ∧
      sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
        (conditionedNoise X g) < 100 * ((d : ℝ) ^ 2 / n) ∧
      ‖conditionedFluctuation X g‖ ^ 2 < 100 * (8 * (d : ℝ) ^ 2 / n) ∧
      rowFourthDeviation ((d : ℝ) / n) (conditionedNoise X g) <
        100 * (12 * (1 + (d : ℝ) ^ 2 / n) + 120024) := by
  classical
  have hn0 : 0 < n := by omega
  set P := stdGaussian (FrameVector n d)
  let dense : Set (FrameVector n d) := {g | ∀ i, 17 * n ≤ 20 *
        (largeNeighbors (fun i j =>
          ((rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j) ^ 2)
          (4 * rowSeedThreshold n d t h) i).card}
  let opZ : Set (FrameVector n d) :=
    {g | ‖(Matrix.toEuclideanLin (conditionedNoise X g)).toContinuousLinearMap‖ ≤ 128}
  let opZ₀ : Set (FrameVector n d) :=
    {g | ‖(Matrix.toEuclideanLin (frameOfVector
        (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))).toContinuousLinearMap‖ ≤ 128}
  let core := dense ∩ opZ ∩ opZ₀
  have hdense : P.real denseᶜ ≤ 1 / 2 := by
    have h1 := rowIndependentSeed_dense_core_failure_le X (by omega) hd hX ht ht100 hh hh400
    exact h1.trans (dense_core_failure_bound_le_half hn)
  have hopZ : P.real opZᶜ ≤ 1 / 100 := by
    have h1 := gaussian_matrix_operator_failure_le hn0 hdn (tangentNoiseFactor X)
      (tangentNoiseFactor_operator_norm_sq_le X hn0)
    have hset : opZᶜ = {g : FrameVector n d | 128 < ‖(Matrix.toEuclideanLin (frameOfVector
        (Matrix.toEuclideanLin (tangentNoiseFactor X) g))).toContinuousLinearMap‖} := by
      ext g; simp [opZ, conditionedNoise]
    rw [hset]; exact h1
  have hopZ₀ : P.real opZ₀ᶜ ≤ 1 / 100 := by
    have h1 := gaussian_matrix_operator_failure_le hn0 hdn (rowTangentNoiseFactor X)
      (rowTangentNoiseFactor_operator_norm_sq_le' X hn0)
    have hset : opZ₀ᶜ = {g : FrameVector n d | 128 < ‖(Matrix.toEuclideanLin (frameOfVector
        (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))).toContinuousLinearMap‖} := by
      ext g; simp [opZ₀]
    rw [hset]; exact h1
  have hcore : P.real coreᶜ ≤ 1 / 2 + 2 / 100 := by
    have hsub : coreᶜ ⊆ denseᶜ ∪ opZᶜ ∪ opZ₀ᶜ := by
      intro g hg
      simp only [core, Set.mem_compl_iff, Set.mem_inter_iff, not_and_or] at hg
      rcases hg with (hg | hg) | hg
      · exact Or.inl (Or.inl hg)
      · exact Or.inl (Or.inr hg)
      · exact Or.inr hg
    calc P.real coreᶜ ≤ P.real (denseᶜ ∪ opZᶜ ∪ opZ₀ᶜ) := measureReal_mono hsub
      _ ≤ P.real (denseᶜ ∪ opZᶜ) + P.real opZ₀ᶜ := measureReal_union_le _ _
      _ ≤ P.real denseᶜ + P.real opZᶜ + P.real opZ₀ᶜ :=
          add_le_add (measureReal_union_le _ _) le_rfl
      _ ≤ 1 / 2 + 1 / 100 + 1 / 100 := add_le_add (add_le_add hdense hopZ) hopZ₀
      _ = _ := by norm_num
  have hM := integral_rowFourthDeviation_conditioned X hn0 hd hX
  let f : Fin 4 → FrameVector n d → ℝ := ![
    fun g => ∑ i, rowNormSq (conditionedNoise X g) i,
    fun g => sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
      (conditionedNoise X g),
    fun g => ‖conditionedFluctuation X g‖ ^ 2,
    fun g => rowFourthDeviation ((d : ℝ) / n) (conditionedNoise X g)]
  let b : Fin 4 → ℝ := ![(d : ℝ), (d : ℝ) ^ 2 / n, 8 * (d : ℝ) ^ 2 / n,
    12 * (1 + (d : ℝ) ^ 2 / n) + 120024]
  have hf (i : Fin 4) (g : FrameVector n d) : 0 ≤ f i g := by
    fin_cases i
    · change 0 ≤ ∑ i, rowNormSq (conditionedNoise X g) i
      exact Finset.sum_nonneg fun i _ => rowNormSq_nonneg _ i
    · exact sqDistance_nonneg _ _
    · exact sq_nonneg _
    · exact rowFourthDeviation_nonneg _ (by positivity) _
  have hi (i : Fin 4) : Integrable (f i) P := by
    fin_cases i
    · change Integrable (fun g => ∑ i, rowNormSq (conditionedNoise X g) i) _
      simp only [conditionedNoise, totalEnergy_frameOfVector]
      exact (memLp_norm_sq_gaussianImage (tangentNoiseFactor X)).integrable (by norm_num)
    · change Integrable (fun g => sqDistance _ (conditionedNoise X g)) _
      simp only [conditionedNoise, sqDistance_frameOfVector]
      exact (memLp_tangentNoise_coupling_sq X).integrable (by norm_num)
    · exact integrable_conditionedFluctuation_sq X
    · exact hM.1
  have hb (i : Fin 4) : 0 < b i := by
    fin_cases i <;> dsimp [b] <;> positivity
  have hmean (i : Fin 4) : (∫ g, f i g ∂P) ≤ b i := by
    fin_cases i
    · exact integral_totalEnergy_tangentNoise_le X hn0
    · exact integral_sqDistance_tangentNoise_coupling_le X
    · exact integral_conditionedFluctuation_sq_le X hn0 hd hX
    · exact hM.2
  obtain ⟨g, hgc, hg⟩ := exists_mem_core_lt_budgets P f b core 100 (by norm_num) hf hi hb hmean
    (by simp only [Fintype.card_fin, Nat.cast_ofNat]; linarith)
  obtain ⟨⟨hgd, hgz⟩, hgz₀⟩ := hgc
  exact ⟨g, hgd, hgz, hgz₀, hg 0, hg 1, hg 2, hg 3⟩

end

end Paulsen.Linear
