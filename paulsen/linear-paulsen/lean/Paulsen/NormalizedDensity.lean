import Paulsen.FullSparkDensity
import Paulsen.RowNormalization
import Paulsen.CompactCorrection

/-! Full-spark approximation within the equal-row constraint. -/

namespace Paulsen

open Filter
open scoped Topology

theorem continuousAt_normalizeRows {n d : ℕ} (U : Frame n d)
    (hU : ∀ i, 0 < rowNormSq U i) : ContinuousAt normalizeRows U := by
  apply continuousAt_pi.mpr
  intro i
  apply continuousAt_pi.mpr
  intro j
  have hq : ContinuousAt (fun X : Frame n d => rowNormSq X i) U :=
    (continuous_rowNormSq i).continuousAt
  have hs : ContinuousAt
      (fun X : Frame n d => Real.sqrt (((d : ℝ) / n) / rowNormSq X i)) U :=
    Real.continuous_sqrt.continuousAt.comp (continuousAt_const.div hq (ne_of_gt (hU i)))
  exact hs.mul (((continuous_apply j).comp (continuous_apply i)).continuousAt)

theorem normalizeRows_eq_self {n d : ℕ} (U : Frame n d)
    (hU : IsEqualNorm U) (hd : 0 < d) (hn : 0 < n) : normalizeRows U = U := by
  have ha : 0 < (d : ℝ) / n := by positivity
  ext i j
  change Real.sqrt (((d : ℝ) / n) / rowNormSq U i) * U i j = U i j
  rw [hU i, div_self (ne_of_gt ha), Real.sqrt_one, one_mul]

theorem IsFullSpark.normalizeRows {n d : ℕ} {U : Frame n d}
    (hU : IsFullSpark U) (hd : 0 < d) (hn : 0 < n)
    (hpos : ∀ i, 0 < rowNormSq U i) : IsFullSpark (normalizeRows U) := by
  have hform : Paulsen.normalizeRows U = Matrix.diagonal (rowNormalizationScale U) * U := by
    ext i j
    simp [Paulsen.normalizeRows, Matrix.diagonal_mul]
  rw [hform]
  apply hU.diagonal_mul
  intro i
  apply ne_of_gt
  unfold rowNormalizationScale
  exact Real.sqrt_pos.mpr (div_pos (div_pos (Nat.cast_pos.mpr hd) (Nat.cast_pos.mpr hn)) (hpos i))

/-- A concrete equal-row full-spark approximation, parameterized near zero. -/
theorem exists_equalRow_fullSpark_approximation {n d : ℕ}
    (U : Frame n d) (hU : IsEqualNorm U) (hd : 0 < d) (hn : 0 < n) :
    ∃ X : ℝ → Frame n d,
      Tendsto X (𝓝[≠] (0 : ℝ)) (𝓝 U) ∧
      ∀ᶠ t in 𝓝[≠] (0 : ℝ), IsEqualNorm (X t) ∧ IsFullSpark (X t) := by
  let V := vandermondeFrame n d
  let Y : ℝ → Frame n d := fun t => U + t • V
  let X : ℝ → Frame n d := fun t => normalizeRows (Y t)
  have hpos : ∀ i, 0 < rowNormSq U i := by
    intro i
    rw [hU i]
    positivity
  have hY : Continuous Y := by dsimp [Y]; fun_prop
  have ht : Tendsto Y (𝓝[≠] (0 : ℝ)) (𝓝 U) := by
    simpa [Y] using (hY.tendsto (0 : ℝ)).mono_left nhdsWithin_le_nhds
  have hX : Tendsto X (𝓝[≠] (0 : ℝ)) (𝓝 U) := by
    have h := (continuousAt_normalizeRows U hpos).tendsto.comp ht
    rwa [normalizeRows_eq_self U hU hd hn] at h
  have hpositive : ∀ᶠ t in 𝓝 (0 : ℝ), ∀ i, 0 < rowNormSq (Y t) i := by
    apply eventually_all.mpr
    intro i
    have hcont := (continuous_rowNormSq i).comp hY
    have hval : 0 < rowNormSq (Y 0) i := by simpa [Y] using hpos i
    exact hcont.continuousAt.eventually (eventually_gt_nhds hval)
  have hspark : ∀ᶠ t in 𝓝[≠] (0 : ℝ), IsFullSpark (Y t) :=
    (eventually_fullSpark_pencil U V (vandermondeFrame_fullSpark n d)).filter_mono
      (nhdsNE_le_cofinite 0)
  refine ⟨X, hX, ?_⟩
  filter_upwards [hpositive.filter_mono nhdsWithin_le_nhds, hspark] with t hp hs
  exact ⟨normalizeRows_equalNorm (Y t) hp, hs.normalizeRows hd hn hp⟩

end Paulsen
