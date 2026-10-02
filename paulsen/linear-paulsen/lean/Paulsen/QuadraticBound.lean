import Paulsen.FullSparkQuadratic
import Paulsen.NormalizedDensity
import Paulsen.SpectralContinuity
import Paulsen.Energy

/-!
# The unconditional quadratic Paulsen bound for equal-row frames

Full-spark approximation, stability at a slightly relaxed error, and
compactness remove every genericity assumption from the radial-scaling/transport
argument. This is the quadratic fallback, not the sharp linear-in-rank target.
-/

namespace Paulsen

open Filter
open scoped Topology

/-- An arbitrary equal-row nearly Parseval frame has an exact correction at
the elementary quadratic cost. Degenerate frames are included. -/
theorem equalRow_quadratic_correction {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (X : Frame n d) (η : ℝ)
    (hX_norm : IsEqualNorm X) (hX_parseval : IsNearlyParseval η X) :
    HasCorrection X (η * (d : ℝ) * ((d : ℝ) - 1)) := by
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  obtain ⟨F, hF, hgood⟩ := exists_equalRow_fullSpark_approximation X hX_norm hd hn
  have hrelaxed (η' : ℝ) (hη' : η < η') :
      HasCorrection X (η' * (d : ℝ) * ((d : ℝ) - 1)) := by
    have hnear := hX_parseval.eventually_of_tendsto hη' hF
    apply hasCorrection_of_tendsto F (fun _ => η' * (d : ℝ) * ((d : ℝ) - 1))
      X (η' * (d : ℝ) * ((d : ℝ) - 1)) hF tendsto_const_nhds
    filter_upwards [hgood, hnear] with t ht hp
    exact fullSpark_quadratic_correction hn hdn (F t) η' ht.2 ht.1 hp
  have hcost : Tendsto (fun η' : ℝ => η' * (d : ℝ) * ((d : ℝ) - 1))
      (𝓝[>] η) (𝓝 (η * (d : ℝ) * ((d : ℝ) - 1))) := by
    exact ((continuous_id.mul continuous_const).mul continuous_const).continuousAt.tendsto.mono_left
      nhdsWithin_le_nhds
  apply hasCorrection_of_tendsto (fun _ : ℝ => X)
    (fun η' : ℝ => η' * (d : ℝ) * ((d : ℝ) - 1)) X
    (η * (d : ℝ) * ((d : ℝ) - 1)) tendsto_const_nhds hcost
  filter_upwards [self_mem_nhdsWithin] with η' hη'
  exact hrelaxed η' hη'

/-- The quadratic interface used in the global rank-regime assembly is now
an unconditional theorem with numerical coefficient one. -/
theorem quadratic_equalRowBound (n d : ℕ) (hd : 0 < d) (hdn : d ≤ n)
    (η : ℝ) (hη : 0 ≤ η) : EqualRowBound n d η (d : ℝ) := by
  intro X hX hp
  apply (equalRow_quadratic_correction hd hdn X η hX hp).mono
  nlinarith [mul_nonneg hη (Nat.cast_nonneg d)]

theorem exists_equalNormParseval {n d : ℕ} (hn : 0 < n) (hdn : d ≤ n) :
    ∃ W : Frame n d, IsEqualNormParseval W := by
  obtain ⟨w, _, M, _, hW⟩ := exists_fullSpark_radial_scaling hn hdn
    (vandermondeFrame n d) (vandermondeFrame_fullSpark n d)
  exact ⟨Matrix.diagonal w * vandermondeFrame n d * M, hW⟩

/-- A fully proved quadratic Paulsen theorem for the original input conditions.
The sharp O(εd) theorem is proved separately in Paulsen.SharpBound. -/
theorem quadratic_paulsen {n d : ℕ} (hd : 0 < d) (hdn : d ≤ n)
    (ε : ℝ) (U : Frame n d) (hε : 0 < ε) (hεone : ε < 1)
    (hU : IsNearlyEqualNormParseval ε U) :
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance U W ≤ 12 * ε * (d : ℝ) ^ 2 := by
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hd0 : (0 : ℝ) ≤ d := Nat.cast_nonneg d
  by_cases hsmall : ε ≤ 1 / 2
  · have h := correction_of_equalRowBound hd hn U hε.le hsmall hU
      (quadratic_equalRowBound n d hd hdn (4 * ε) (by positivity))
    apply h.mono
    calc
      (2 + 8 * (d : ℝ)) * ε * d ≤ (12 * (d : ℝ)) * ε * d :=
        mul_le_mul_of_nonneg_right
          (mul_le_mul_of_nonneg_right (by linarith) hε.le) hd0
      _ = 12 * ε * (d : ℝ) ^ 2 := by ring
  · obtain ⟨W, hW⟩ := exists_equalNormParseval hn hdn
    refine ⟨W, hW, ?_⟩
    have he := hU.2.total_rowNormSq_le hn
    have hdist := sqDistance_le_twice_energy U W
    rw [hW.1.total_rowNormSq] at hdist
    have hlarge : 1 / 2 < ε := lt_of_not_ge hsmall
    calc
      sqDistance U W ≤ 6 * (d : ℝ) := by
        nlinarith [mul_nonneg (show 0 ≤ 1 - ε by linarith) hd0]
      _ ≤ 6 * (d : ℝ) ^ 2 := by nlinarith
      _ ≤ 12 * ε * (d : ℝ) ^ 2 := by
        nlinarith [mul_nonneg (show 0 ≤ 2 * ε - 1 by linarith) (sq_nonneg (d : ℝ))]

end Paulsen
