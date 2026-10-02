import Paulsen.ConditionedSeedBounds
import Paulsen.GaussianTangentCoupling

/-!
# Simultaneous good events for the conditioned Gaussian seed

All moment estimates are instantiated on the actual projected Gaussian.
Only the separate dense-core event is supplied to the selection theorem.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators

noncomputable section

namespace Paulsen

/-- Finite Markov selection with strict inequalities and one extra event. -/
theorem exists_mem_core_lt_budgets {Ω I : Type*} [MeasurableSpace Ω] [Fintype I]
    (P : Measure Ω) [IsProbabilityMeasure P] (f : I → Ω → ℝ) (b : I → ℝ)
    (core : Set Ω) (K : ℝ) (hK : 0 < K)
    (hf : ∀ i ω, 0 ≤ f i ω) (hi : ∀ i, Integrable (f i) P)
    (hb : ∀ i, 0 < b i) (hmean : ∀ i, (∫ ω, f i ω ∂P) ≤ b i)
    (hbudget : P.real coreᶜ + (Fintype.card I : ℝ) / K < 1) :
    ∃ ω ∈ core, ∀ i, f i ω < K * b i := by
  classical
  let bad : I → Set Ω := fun i => {ω | K * b i ≤ f i ω}
  have htail (i : I) : P.real (bad i) ≤ 1 / K := by
    have hm := mul_meas_ge_le_integral_of_nonneg
      (Filter.Eventually.of_forall (hf i)) (hi i) (K * b i)
    calc
      _ ≤ b i / (K * b i) := by
        apply (le_div_iff₀ (mul_pos hK (hb i))).mpr
        simpa only [bad, mul_comm] using hm.trans (hmean i)
      _ = _ := by field_simp [(hb i).ne', hK.ne']
  by_contra h
  push Not at h
  have hu : (Set.univ : Set Ω) ⊆ coreᶜ ∪ ⋃ i, bad i := by
    intro ω _
    by_cases hc : ω ∈ core
    · obtain ⟨i, hi⟩ := h ω hc
      exact Or.inr (Set.mem_iUnion.mpr ⟨i, hi⟩)
    · exact Or.inl hc
  have hmeasure : (1 : ℝ) ≤ P.real coreᶜ + (Fintype.card I : ℝ) / K := by
    calc
      _ = P.real Set.univ := (probReal_univ).symm
      _ ≤ P.real (coreᶜ ∪ ⋃ i, bad i) := measureReal_mono hu
      _ ≤ P.real coreᶜ + P.real (⋃ i, bad i) := measureReal_union_le _ _
      _ ≤ P.real coreᶜ + ∑ i, P.real (bad i) :=
        add_le_add le_rfl (measureReal_iUnion_fintype_le bad)
      _ ≤ P.real coreᶜ + ∑ _i : I, 1 / K :=
        add_le_add le_rfl (Finset.sum_le_sum fun i _ => htail i)
      _ = _ := by simp [div_eq_mul_inv]
  linarith

/-- Squared energy of the unconditioned noise is controlled by the conditioned
noise and the coupling cost, so it requires no fifth probabilistic event. -/
theorem rowTangentNoise_energy_le {n d : ℕ} (X : Frame n d) (g : FrameVector n d) :
    (∑ i, rowNormSq (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)) i) ≤
      2 * (∑ i, rowNormSq (conditionedNoise X g) i) +
        2 * sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
          (conditionedNoise X g) := by
  simp only [rowNormSq, sqDistance, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i _
  apply Finset.sum_le_sum
  intro j _
  nlinarith [sq_nonneg (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g) i j -
    2 * conditionedNoise X g i j)]

/-- A single actual Gaussian sample satisfies the four strict seed budgets
and any supplied core event whose failure probability is at most one half. -/
theorem exists_conditionedSeed_good_events {n d : ℕ} (X : Frame n d)
    (hn : 0 < n) (hd : 0 < d) (hX : IsEqualNorm X)
    (t : ℝ) (ht : 0 < t) (core : Set (FrameVector n d))
    (hcore : (stdGaussian (FrameVector n d)).real coreᶜ ≤ 1 / 2) :
    ∃ g ∈ core,
      (∑ i, rowNormSq (conditionedNoise X g) i) < 100 * (d : ℝ) ∧
      sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
        (conditionedNoise X g) < 100 * ((d : ℝ) ^ 2 / n) ∧
      ‖conditionedFluctuation X g‖ ^ 2 < 100 * (8 * (d : ℝ) ^ 2 / n) ∧
      tangentRemainderBudget (conditionedNoise X g) ((d : ℝ) / n) t <
        100 * ((d : ℝ) * (4 * |t| ^ 3 + 6 * t ^ 4)) ∧
      (∑ i, rowNormSq (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)) i) <
        200 * (d : ℝ) + 200 * ((d : ℝ) ^ 2 / n) := by
  let f : Fin 4 → FrameVector n d → ℝ := ![
    fun g => ∑ i, rowNormSq (conditionedNoise X g) i,
    fun g => sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
      (conditionedNoise X g),
    fun g => ‖conditionedFluctuation X g‖ ^ 2,
    fun g => tangentRemainderBudget (conditionedNoise X g) ((d : ℝ) / n) t]
  let b : Fin 4 → ℝ := ![(d : ℝ), (d : ℝ) ^ 2 / n, 8 * (d : ℝ) ^ 2 / n,
    (d : ℝ) * (4 * |t| ^ 3 + 6 * t ^ 4)]
  have hf (i : Fin 4) (g : FrameVector n d) : 0 ≤ f i g := by
    fin_cases i
    · change 0 ≤ ∑ i, rowNormSq (conditionedNoise X g) i
      exact Finset.sum_nonneg fun i _ => rowNormSq_nonneg _ i
    · exact sqDistance_nonneg _ _
    · exact sq_nonneg _
    · exact tangentRemainderBudget_nonneg _ _ _ (by positivity)
  have hi (i : Fin 4) : Integrable (f i) (stdGaussian (FrameVector n d)) := by
    fin_cases i
    · change Integrable (fun g => ∑ i, rowNormSq (conditionedNoise X g) i) _
      simp only [conditionedNoise, totalEnergy_frameOfVector]
      exact (memLp_norm_sq_gaussianImage (tangentNoiseFactor X)).integrable (by norm_num)
    · change Integrable (fun g => sqDistance _ (conditionedNoise X g)) _
      simp only [conditionedNoise, sqDistance_frameOfVector]
      exact (memLp_tangentNoise_coupling_sq X).integrable (by norm_num)
    · exact integrable_conditionedFluctuation_sq X
    · exact integrable_tangentRemainderBudget_conditioned X hn hd t
  have hb (i : Fin 4) : 0 < b i := by
    fin_cases i <;> dsimp [b] <;> positivity
  have hmean (i : Fin 4) : (∫ g, f i g ∂stdGaussian (FrameVector n d)) ≤ b i := by
    fin_cases i
    · exact integral_totalEnergy_tangentNoise_le X hn
    · exact integral_sqDistance_tangentNoise_coupling_le X
    · exact integral_conditionedFluctuation_sq_le X hn hd hX
    · exact integral_tangentRemainderBudget_conditioned_le X hn hd t
  obtain ⟨g, hgc, hg⟩ := exists_mem_core_lt_budgets
    (stdGaussian (FrameVector n d)) f b core 100 (by norm_num) hf hi hb hmean (by
      simp only [Fintype.card_fin, Nat.cast_ofNat]
      linarith)
  have h0 : (∑ i, rowNormSq (conditionedNoise X g) i) < 100 * (d : ℝ) := hg 0
  have h1 : sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
      (conditionedNoise X g) < 100 * ((d : ℝ) ^ 2 / n) := hg 1
  refine ⟨g, hgc, h0, h1, hg 2, hg 3, ?_⟩
  have hz := rowTangentNoise_energy_le X g
  linarith

end Paulsen
