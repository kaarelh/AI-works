import Paulsen.GaussianRows
import Paulsen.IndependentTangentCounts
import Paulsen.ConditionedSeedEvents
import Paulsen.DensePerturbation

/-!
# A dense Gram core for the actual independent tangent seed

The product-row estimate is transported to the same Gaussian sample used for
conditioning. Thus dense rows and all four error budgets hold simultaneously.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory

namespace Paulsen
noncomputable section

def rowIndependentSeed {n d : ℕ} (X : Frame n d) (t : ℝ)
    (g : FrameVector n d) : Frame n d :=
  tangentSeed X (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
    ((d : ℝ) / n) t

theorem rowIndependentSeed_gram {n d : ℕ} (X : Frame n d)
    (hn : 0 < n) (hd : 0 < d) (hX : IsEqualNorm X)
    (t : ℝ) (g : FrameVector n d) (i j : Fin n) :
    (rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j =
      ((d : ℝ) / n) * inner ℝ
        (independentTangentDirection (frameRowDirection X ((d : ℝ) / n) i) t (gaussianRows g i))
        (independentTangentDirection (frameRowDirection X ((d : ℝ) / n) j) t (gaussianRows g j)) := by
  simp only [Matrix.mul_apply, Matrix.transpose_apply, rowIndependentSeed,
    tangentSeed_rowTangent_eq X hn hd hX, PiLp.inner_apply, Real.inner_apply, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro k _
  calc
    _ = Real.sqrt ((d : ℝ) / n) ^ 2 *
        ((independentTangentDirection (frameRowDirection X ((d : ℝ) / n) i) t
          (gaussianRows g i)) k *
         (independentTangentDirection (frameRowDirection X ((d : ℝ) / n) j) t
          (gaussianRows g j)) k) := by ring
    _ = _ := by rw [Real.sq_sqrt (show 0 ≤ (d : ℝ) / n by positivity)]

/-- The natural graph threshold, after restoring row lengths and squaring. -/
def rowSeedThreshold (n d : ℕ) (t h : ℝ) : ℝ :=
  h ^ 2 * t ^ 2 * ((d : ℝ) / n) / 4

theorem rowSeedThreshold_square {n d : ℕ} (hn : 0 < n) (hd : 0 < d) (t h : ℝ) :
    (((d : ℝ) / n) * (h * t / Real.sqrt d)) ^ 2 =
      4 * rowSeedThreshold n d t h / n := by
  simp only [mul_pow, div_pow, Real.sq_sqrt (Nat.cast_nonneg d)]
  unfold rowSeedThreshold
  field_simp [Nat.cast_ne_zero.mpr hn.ne', Nat.cast_ne_zero.mpr hd.ne']

/-- Strict scalar-product witnesses imply the finite dense-row criterion used
by deterministic correction. -/
theorem dense_gram_of_strict_neighbors {n d : ℕ} (hn : 0 < n) (hd : 0 < d)
    (A : Matrix (Fin n) (Fin n) ℝ) (N : Fin n → Finset (Fin n))
    {t h : ℝ} (ht : 0 < t) (hh : 0 < h)
    (hcard : ∀ i, 17 * n ≤ 20 * (N i).card)
    (hstrict : ∀ i, ∀ j ∈ N i, ((d : ℝ) / n) * (h * t / Real.sqrt d) < |A i j|) :
    ∀ i, 17 * n ≤ 20 *
      (largeNeighbors (fun i j => (A i j) ^ 2) (4 * rowSeedThreshold n d t h) i).card := by
  classical
  intro i
  apply (hcard i).trans
  apply Nat.mul_le_mul_left
  apply Finset.card_le_card
  intro j hj
  refine Finset.mem_filter.mpr ⟨Finset.mem_univ j, ?_⟩
  have hs := (sq_le_sq₀ (by positivity : 0 ≤ ((d : ℝ) / n) * (h * t / Real.sqrt d))
    (abs_nonneg (A i j))).2 (hstrict i j hj).le
  simpa only [Fintype.card_fin, sq_abs, rowSeedThreshold_square hn hd] using hs

theorem independentTangentGoodNeighbors_subset_largeNeighbors {n d : ℕ}
    (X : Frame n d) (hn : 0 < n) (hd : 0 < d) (hX : IsEqualNorm X)
    {t h : ℝ} (ht : 0 < t) (hh : 0 < h) (g : FrameVector n d) (i : Fin n) :
    independentTangentGoodNeighbors (frameRowDirection X ((d : ℝ) / n)) t
      (h * t / Real.sqrt d) (gaussianRows g) i ⊆
        largeNeighbors (fun i j =>
          ((rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j) ^ 2)
          (4 * rowSeedThreshold n d t h) i := by
  classical
  intro j hj
  have hj' := (Finset.mem_filter.mp hj).2.2
  apply Finset.mem_filter.mpr ⟨Finset.mem_univ j, ?_⟩
  dsimp only
  erw [rowIndependentSeed_gram X hn hd hX]
  have hsq := sq_le_sq₀ (by positivity : 0 ≤ h * t / Real.sqrt d)
    (abs_nonneg _) |>.2 hj'.le
  rw [sq_abs] at hsq
  have hmul := mul_le_mul_of_nonneg_left hsq (sq_nonneg ((d : ℝ) / n))
  have hcalc : ((d : ℝ) / n) ^ 2 * (h * t / Real.sqrt d) ^ 2 =
      (4 * rowSeedThreshold n d t h) / n := by
    simp only [div_pow, Real.sq_sqrt (Nat.cast_nonneg d)]
    unfold rowSeedThreshold
    field_simp [Nat.cast_ne_zero.mpr hn.ne', Nat.cast_ne_zero.mpr hd.ne']
  simpa only [Fintype.card_fin, mul_pow, hcalc] using hmul

/-- The actual vectorized sample has the required dense Gram rows except with
the explicit exponentially small failure probability. -/
theorem rowIndependentSeed_dense_core_failure_le {n d : ℕ} (X : Frame n d)
    (hn : 20 ≤ n) (hd : 0 < d) (hX : IsEqualNorm X)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1)) :
    (stdGaussian (FrameVector n d)).real
      {g | ¬ ∀ i, 17 * n ≤ 20 *
        (largeNeighbors (fun i j =>
          ((rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j) ^ 2)
          (4 * rowSeedThreshold n d t h) i).card} ≤
      n * Real.exp (-3 * n / 50) := by
  let e := frameRowDirection X ((d : ℝ) / n)
  let S : Set (Fin n → TangentRowSpace d) := {g | ∀ i, 17 * (n : ℝ) / 20 ≤
    ((independentTangentGoodNeighbors e t (h * t / Real.sqrt d) g i).card : ℝ)}
  have hn0 : 0 < n := by omega
  have hsub : {g : FrameVector n d | ¬ ∀ i, 17 * n ≤ 20 *
      (largeNeighbors (fun i j =>
        ((rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j) ^ 2)
        (4 * rowSeedThreshold n d t h) i).card} ⊆ gaussianRows ⁻¹' Sᶜ := by
    intro g hg hgS
    apply hg
    intro i
    have hc := Finset.card_le_card
      (independentTangentGoodNeighbors_subset_largeNeighbors X hn0 hd hX ht hh g i)
    have hi := hgS i
    have hcR : ((independentTangentGoodNeighbors e t (h * t / Real.sqrt d)
      (gaussianRows g) i).card : ℝ) ≤ _ := Nat.cast_le.mpr hc
    have hout : (17 : ℝ) * n ≤ 20 *
        (largeNeighbors (fun i j =>
          ((rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j) ^ 2)
          (4 * rowSeedThreshold n d t h) i).card := by linarith
    exact_mod_cast hout
  have hmap : (stdGaussian (FrameVector n d)).real (gaussianRows ⁻¹' Sᶜ) =
      (independentTangentMeasure n d).real Sᶜ := by
    apply congrArg ENNReal.toReal
    exact gaussianRows_measurePreserving.measure_preimage
      (measurableSet_independentTangentDenseCore e t (h * t / Real.sqrt d)).compl.nullMeasurableSet
  apply (measureReal_mono (μ := stdGaussian (FrameVector n d)) hsub).trans
  rw [hmap]
  exact independentTangent_dense_core_failure_le hn hd e
    (norm_frameRowDirection X (div_pos (Nat.cast_pos.mpr hd) (Nat.cast_pos.mpr hn0)) hX)
    ht ht100 hh hh400

/-- Dense independent Gram rows and every conditioned-seed moment budget hold
for one common sample, with no independence assumption between these events. -/
theorem exists_conditionedSeed_with_dense_core {n d : ℕ} (X : Frame n d)
    (hn : 20 ≤ n) (hd : 0 < d) (hX : IsEqualNorm X)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1))
    (hprob : (n : ℝ) * Real.exp (-3 * n / 50) ≤ 1 / 2) :
    ∃ g : FrameVector n d,
      (∀ i, 17 * n ≤ 20 *
        (largeNeighbors (fun i j =>
          ((rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j) ^ 2)
          (4 * rowSeedThreshold n d t h) i).card) ∧
      (∑ i, rowNormSq (conditionedNoise X g) i) < 100 * (d : ℝ) ∧
      sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
        (conditionedNoise X g) < 100 * ((d : ℝ) ^ 2 / n) ∧
      ‖conditionedFluctuation X g‖ ^ 2 < 100 * (8 * (d : ℝ) ^ 2 / n) ∧
      tangentRemainderBudget (conditionedNoise X g) ((d : ℝ) / n) t <
        100 * ((d : ℝ) * (4 * |t| ^ 3 + 6 * t ^ 4)) ∧
      (∑ i, rowNormSq (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)) i) <
        200 * (d : ℝ) + 200 * ((d : ℝ) ^ 2 / n) := by
  exact exists_conditionedSeed_good_events X (by omega) hd hX t ht _
    ((rowIndependentSeed_dense_core_failure_le X hn hd hX ht ht100 hh hh400).trans hprob)

/-- Retain strict inequalities on named neighbor sets. This version permits a
subsequent perturbation of the amplitude to make the conditioned seed full spark. -/
theorem exists_conditionedSeed_with_strict_core {n d : ℕ} (X : Frame n d)
    (hn : 20 ≤ n) (hd : 0 < d) (hX : IsEqualNorm X)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1))
    (hprob : (n : ℝ) * Real.exp (-3 * n / 50) ≤ 1 / 2) :
    ∃ (g : FrameVector n d) (N : Fin n → Finset (Fin n)),
      (∀ i, 17 * n ≤ 20 * (N i).card) ∧
      (∀ i, ∀ j ∈ N i, ((d : ℝ) / n) * (h * t / Real.sqrt d) <
        |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|) ∧
      (∑ i, rowNormSq (conditionedNoise X g) i) < 100 * (d : ℝ) ∧
      sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
        (conditionedNoise X g) < 100 * ((d : ℝ) ^ 2 / n) ∧
      ‖conditionedFluctuation X g‖ ^ 2 < 100 * (8 * (d : ℝ) ^ 2 / n) ∧
      tangentRemainderBudget (conditionedNoise X g) ((d : ℝ) / n) t <
        100 * ((d : ℝ) * (4 * |t| ^ 3 + 6 * t ^ 4)) ∧
      (∑ i, rowNormSq (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)) i) <
        200 * (d : ℝ) + 200 * ((d : ℝ) ^ 2 / n) := by
  classical
  have hn0 : 0 < n := by omega
  have ha : 0 < (d : ℝ) / n := div_pos (Nat.cast_pos.mpr hd) (Nat.cast_pos.mpr hn0)
  let e := frameRowDirection X ((d : ℝ) / n)
  let S : Set (Fin n → TangentRowSpace d) := {g | ∀ i, 17 * (n : ℝ) / 20 ≤
    ((independentTangentGoodNeighbors e t (h * t / Real.sqrt d) g i).card : ℝ)}
  have hcore : (stdGaussian (FrameVector n d)).real (gaussianRows ⁻¹' S)ᶜ ≤ 1 / 2 := by
    have hmap : (stdGaussian (FrameVector n d)).real (gaussianRows ⁻¹' S)ᶜ =
        (independentTangentMeasure n d).real Sᶜ := by
      apply congrArg ENNReal.toReal
      exact gaussianRows_measurePreserving.measure_preimage
        (measurableSet_independentTangentDenseCore e t (h * t / Real.sqrt d)).compl.nullMeasurableSet
    rw [hmap]
    exact (independentTangent_dense_core_failure_le hn hd e
      (norm_frameRowDirection X ha hX) ht ht100 hh hh400).trans hprob
  obtain ⟨g, hg, hb⟩ := exists_conditionedSeed_good_events X hn0 hd hX t ht
    (gaussianRows ⁻¹' S) hcore
  let N := independentTangentGoodNeighbors e t (h * t / Real.sqrt d) (gaussianRows g)
  refine ⟨g, N, ?_, ?_, hb⟩
  · intro i
    have hi := hg i
    have hR : (17 : ℝ) * n ≤ 20 * (N i).card := by dsimp [N]; linarith
    exact_mod_cast hR
  · intro i j hj
    have hij := (Finset.mem_filter.mp hj).2.2
    rw [rowIndependentSeed_gram X hn0 hd hX, abs_mul, abs_of_pos ha]
    exact mul_lt_mul_of_pos_left hij ha

end
end Paulsen
