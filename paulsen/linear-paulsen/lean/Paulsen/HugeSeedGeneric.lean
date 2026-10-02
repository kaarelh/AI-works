import Paulsen.TangentGeneric
import Paulsen.ConditionedSeedBounds
import Paulsen.GaussianTangentCoupling
import Paulsen.IndependentTangentCounts

/-!
# Generic huge-row seeds without losing strict good events

For a fixed Gaussian sample the amplitude is the only varying parameter.
Finite strict Gram inequalities and the strict remainder budget are open;
cofinitely many amplitudes give full spark for both tangent seeds.
-/

namespace Paulsen

open Filter MeasureTheory ProbabilityTheory
open scoped Topology BigOperators

noncomputable section

/-- Two fixed tangent perturbations can simultaneously be made full spark,
inside any open amplitude constraint and arbitrarily close to its given point. -/
theorem exists_fullSpark_tangentSeeds_near {n d : ℕ}
    (X Z W : Frame n d) (a : ℝ) (ha : 0 < a) (hX : IsFullSpark X)
    (S : Set ℝ) (hS : IsOpen S) (t : ℝ) (ht : t ∈ S) (δ : ℝ) (hδ : 0 < δ) :
    ∃ t' ∈ S, dist t' t < δ ∧ IsFullSpark (tangentSeed X Z a t') ∧
      IsFullSpark (tangentSeed X W a t') := by
  have hnear : ∀ᶠ t' in 𝓝[≠] t, t' ∈ S ∧ dist t' t < δ := by
    have hSnear : ∀ᶠ t' in 𝓝 t, t' ∈ S := hS.mem_nhds ht
    have hball : ∀ᶠ t' in 𝓝 t, dist t' t < δ := Metric.ball_mem_nhds t hδ
    exact (hSnear.and hball).filter_mono nhdsWithin_le_nhds
  have hZ := (eventually_fullSpark_tangentSeed X Z a ha hX).filter_mono (nhdsNE_le_cofinite t)
  have hW := (eventually_fullSpark_tangentSeed X W a ha hX).filter_mono (nhdsNE_le_cofinite t)
  obtain ⟨t', ht', hZ', hW'⟩ := (hnear.and (hZ.and hW)).exists
  exact ⟨t', ht'.1, ht'.2, hZ', hW'⟩

theorem continuous_tangentRemainderBudget_parameter {n d : ℕ}
    (Z : Frame n d) (a : ℝ) : Continuous (tangentRemainderBudget Z a) := by
  unfold tangentRemainderBudget
  fun_prop

theorem isOpen_tangentRemainderBudget_lt {n d : ℕ}
    (Z : Frame n d) (a : ℝ) (ρ : ℝ → ℝ) (hρ : Continuous ρ) :
    IsOpen {t | tangentRemainderBudget Z a t < ρ t} :=
  isOpen_lt (continuous_tangentRemainderBudget_parameter Z a) hρ

/-- A fixed finite list of strict row-Gram inequalities remains valid under
small amplitude changes, even when the threshold also varies continuously. -/
theorem isOpen_strict_tangentSeed_gram {n d : ℕ}
    (X Z : Frame n d) (a : ℝ) (ha : 0 < a) (N : Fin n → Finset (Fin n))
    (b : ℝ → ℝ) (hb : Continuous b) :
    IsOpen {t | ∀ i, ∀ j ∈ N i,
      b t < |(tangentSeed X Z a t * (tangentSeed X Z a t).transpose) i j|} := by
  have hc := continuous_tangentSeed_parameter X Z a ha
  have hgram := hc.matrix_mul hc.matrix_transpose
  have hentry (i j : Fin n) : IsOpen {t | j ∈ N i →
      b t < |(tangentSeed X Z a t * (tangentSeed X Z a t).transpose) i j|} := by
    by_cases hj : j ∈ N i
    · simpa only [hj, true_implies] using isOpen_lt hb (hgram.matrix_elem i j).abs
    · simp only [hj, false_implies, Set.setOf_true]
      exact isOpen_univ
  rw [show {t | ∀ i, ∀ j ∈ N i,
      b t < |(tangentSeed X Z a t * (tangentSeed X Z a t).transpose) i j|} =
      ⋂ i, ⋂ j, {t | j ∈ N i →
        b t < |(tangentSeed X Z a t * (tangentSeed X Z a t).transpose) i j|} by ext; simp]
  exact isOpen_iInter_of_finite fun i => isOpen_iInter_of_finite fun j => hentry i j

/-- Retain the strict remainder budget and every selected strict independent
Gram inequality while making the actual conditioned seed full spark. -/
theorem exists_fullSpark_conditionedSeed_preserving_strict {n d : ℕ}
    (X : Frame n d) (hn : 0 < n) (hd : 0 < d) (hX : IsFullSpark X)
    (g : FrameVector n d) (S : Set ℝ) (hS : IsOpen S) (t : ℝ) (ht : t ∈ S)
    (N : Fin n → Finset (Fin n)) (b ρ : ℝ → ℝ) (hb : Continuous b) (hρ : Continuous ρ)
    (hbudget : tangentRemainderBudget (conditionedNoise X g) ((d : ℝ) / n) t < ρ t)
    (hgram : ∀ i, ∀ j ∈ N i, b t <
      |(tangentSeed X (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
          ((d : ℝ) / n) t *
        (tangentSeed X (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
          ((d : ℝ) / n) t).transpose) i j|)
    (δ : ℝ) (hδ : 0 < δ) :
    ∃ t' ∈ S, dist t' t < δ ∧ IsFullSpark (conditionedSeed X t' g) ∧
      tangentRemainderBudget (conditionedNoise X g) ((d : ℝ) / n) t' < ρ t' ∧
      ∀ i, ∀ j ∈ N i, b t' <
        |(tangentSeed X (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
            ((d : ℝ) / n) t' *
          (tangentSeed X (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
            ((d : ℝ) / n) t').transpose) i j| := by
  let Z₀ := frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)
  let T : Set ℝ := S ∩ {s | tangentRemainderBudget (conditionedNoise X g) ((d : ℝ) / n) s < ρ s} ∩
    {s | ∀ i, ∀ j ∈ N i, b s < |(tangentSeed X Z₀ ((d : ℝ) / n) s *
      (tangentSeed X Z₀ ((d : ℝ) / n) s).transpose) i j|}
  have ha : 0 < (d : ℝ) / n := by positivity
  have hT : IsOpen T :=
    (hS.inter (isOpen_tangentRemainderBudget_lt _ _ ρ hρ)).inter
      (isOpen_strict_tangentSeed_gram X Z₀ _ ha N b hb)
  obtain ⟨t', ht', hd', hfull, _⟩ := exists_fullSpark_tangentSeeds_near X
    (conditionedNoise X g) Z₀ _ ha hX T hT t ⟨⟨ht, hbudget⟩, hgram⟩ δ hδ
  exact ⟨t', ht'.1.1, hd', hfull, ht'.1.2, ht'.2⟩

/-- A simple explicit threshold for the dense-core failure estimate. -/
theorem dense_core_failure_bound_le_half {n : ℕ} (hn : 200 ≤ n) :
    (n : ℝ) * Real.exp (-3 * n / 50) ≤ 1 / 2 := by
  have hnR : (200 : ℝ) ≤ n := by exact_mod_cast hn
  have hp := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 200) hnR 3
  have hmul := mul_le_mul_of_nonneg_left hp (Nat.cast_nonneg n : (0 : ℝ) ≤ n)
  have hexp := Real.pow_div_factorial_le_exp (3 * (n : ℝ) / 50) (by positivity) 4
  norm_num at hexp hp
  have hlower : 2 * (n : ℝ) ≤ Real.exp (3 * n / 50) := by nlinarith
  rw [show -3 * (n : ℝ) / 50 = -(3 * n / 50) by ring, Real.exp_neg, ← div_eq_mul_inv]
  exact (div_le_iff₀ (Real.exp_pos _)).mpr (by linarith)

/-- The huge-row condition implies the numerical threshold uniformly in d. -/
theorem two_hundred_le_of_huge_rows {n d : ℕ} (hd : 0 < d) (B : ℝ)
    (hB : 200 ≤ B) (hn : B * (d : ℝ) ^ 2 ≤ n) : 200 ≤ n := by
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hd2 : (1 : ℝ) ≤ (d : ℝ) ^ 2 := by nlinarith
  have hb := mul_le_mul_of_nonneg_left hd2 (show 0 ≤ B by linarith)
  have hnR : (200 : ℝ) ≤ n := by nlinarith
  exact_mod_cast hnR

theorem dense_core_failure_bound_le_half_of_huge_rows {n d : ℕ} (hd : 0 < d)
    (B : ℝ) (hB : 200 ≤ B) (hn : B * (d : ℝ) ^ 2 ≤ n) :
    (n : ℝ) * Real.exp (-3 * n / 50) ≤ 1 / 2 :=
  dense_core_failure_bound_le_half (two_hundred_le_of_huge_rows hd B hB hn)

end
end Paulsen
