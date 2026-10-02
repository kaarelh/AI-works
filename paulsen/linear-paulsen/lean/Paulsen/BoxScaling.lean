import Paulsen.BoxMedian
import Paulsen.DiagonalScalingPotential
import Mathlib.Analysis.Calculus.LocalExtr.Basic
import Mathlib.Analysis.Convex.Segment

/-! Exact diagonal balancing by compact box minimization, with no genericity hypothesis. -/
namespace Paulsen
open Matrix
open scoped BigOperators
noncomputable section

/-- The target linear functional in logarithmic scaling coordinates. -/
def scalingTargetFunctional {n : ℕ} (q : Fin n → ℝ) : (Fin n → ℝ) →L[ℝ] ℝ :=
  ∑ i, q i • ContinuousLinearMap.proj i

@[simp] theorem scalingTargetFunctional_apply {n : ℕ} (q s : Fin n → ℝ) :
    scalingTargetFunctional q s = ∑ i, q i * s i := by
  simp [scalingTargetFunctional]

def targetScalingPotential {n d : ℕ} (U : Frame n d) (q s : Fin n → ℝ) : ℝ :=
  diagonalScalingPotential U s - scalingTargetFunctional q s

theorem hasFDerivAt_targetScalingPotential {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (q s : Fin n → ℝ) :
    HasFDerivAt (targetScalingPotential U q)
      (diagonalScalingDerivative U s - scalingTargetFunctional q) s :=
  (hasFDerivAt_diagonalScalingPotential hU s).sub ((scalingTargetFunctional q).hasFDerivAt)

theorem targetScalingDerivative_apply {n d : ℕ} (U : Frame n d) (q s h : Fin n → ℝ) :
    (diagonalScalingDerivative U s - scalingTargetFunctional q) h =
      ∑ i, (scaledLeverage U (fun j => Real.exp (2 * s j)) i - q i) * h i := by
  simp only [_root_.sub_apply, diagonalScalingDerivative_apply,
    scalingTargetFunctional_apply, sub_mul, Finset.sum_sub_distrib]

/-- Coordinatewise first-order conditions on the closed unit cube. -/
theorem targetScalingPotential_box_optimality {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (q s : Fin n → ℝ)
    (hs : s ∈ Set.Icc (0 : Fin n → ℝ) 1)
    (hmin : IsMinOn (targetScalingPotential U q) (Set.Icc 0 1) s) :
    (∀ i, 0 < s i → scaledLeverage U (fun j => Real.exp (2 * s j)) i ≤ q i) ∧
    (∀ i, s i < 1 → q i ≤ scaledLeverage U (fun j => Real.exp (2 * s j)) i) := by
  have hdir (i : Fin n) (a : ℝ) (ha : a ∈ Set.Icc (0 : ℝ) 1) :
      0 ≤ (scaledLeverage U (fun j => Real.exp (2 * s j)) i - q i) * (a - s i) := by
    have hy : Function.update s i a ∈ Set.Icc (0 : Fin n → ℝ) 1 := by
      constructor <;> intro j <;> by_cases hj : j = i
      · subst j; simpa using ha.1
      · simpa [Function.update_of_ne hj] using hs.1 j
      · subst j; simpa using ha.2
      · simpa [Function.update_of_ne hj] using hs.2 j
    have hh := hmin.localize.hasFDerivWithinAt_nonneg
      (hasFDerivAt_targetScalingPotential hU q s).hasFDerivWithinAt
      (sub_mem_posTangentConeAt_of_segment_subset ((convex_Icc (0 : Fin n → ℝ) 1).segment_subset hs hy))
    rw [targetScalingDerivative_apply] at hh
    have he : (∑ j, (scaledLeverage U (fun k => Real.exp (2 * s k)) j - q j) *
        (Function.update s i a - s) j) =
        (scaledLeverage U (fun k => Real.exp (2 * s k)) i - q i) * (a - s i) := by
      rw [Finset.sum_eq_single i]
      · simp
      · intro j _ hji
        simp [Function.update_of_ne hji]
      · simp
    rwa [he] at hh
  constructor
  · intro i hi
    have hh := hdir i 0 (by norm_num)
    nlinarith
  · intro i hi
    have hh := hdir i 1 (by norm_num)
    nlinarith

/-- All scaled leverage scores sum to the column rank. -/
theorem sum_exp_scaledLeverage {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (s : Fin n → ℝ) :
    (∑ i, scaledLeverage U (fun j => Real.exp (2 * s j)) i) = (d : ℝ) := by
  calc
    _ = ∑ i, ∑ f, embeddingIncidence f i *
        (diagonalScalingWeight U s f / diagonalScalingPartition U s) := by
      simp_rw [diagonalScalingWeight_marginal hU]
    _ = ∑ f, (∑ i, embeddingIncidence f i) *
        (diagonalScalingWeight U s f / diagonalScalingPartition U s) := by
      rw [Finset.sum_comm]
      simp only [Finset.sum_mul]
    _ = (d : ℝ) * ((∑ f, diagonalScalingWeight U s f) / diagonalScalingPartition U s) := by
      simp only [sum_embeddingIncidence, ← Finset.mul_sum, ← Finset.sum_div]
    _ = d := by rw [← diagonalScalingPartition, div_self (diagonalScalingPartition_pos hU s).ne', mul_one]

/-- The restricted median barrier bounds every box minimizer before exact
balancing has been established. -/
theorem box_minimizer_oscillation {n d k : ℕ}
    (hn : 0 < n) (U : Frame n d) (V : Frame n k)
    (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (q s : Fin n → ℝ) (β K : ℝ)
    (hs : s ∈ Set.Icc (0 : Fin n → ℝ) 1)
    (hmin : IsMinOn (targetScalingPotential U q) (Set.Icc 0 1) s)
    (herror : ∀ i, |q i - (U * U.transpose) i i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => ((U * U.transpose) i j) ^ 2) K)
    (hβ : 0 ≤ β) (hsmall : 2 * β * K < 1) :
    ∀ i j, s i - s j ≤ -Real.log (1 - 2 * β * K) := by
  letI : NeZero n := ⟨hn.ne'⟩
  obtain ⟨hkkt₁, hkkt₂⟩ := targetScalingPotential_box_optimality hU q s hs hmin
  obtain ⟨k, hlow, hhigh⟩ := finite_median_index (fun i => Real.exp (2 * s i))
  apply exponential_poisson_median_barrier_restricted (fun i j => sq_nonneg _)
    hsolve hβ hsmall (Real.exp_pos (2 * s k)) ?_ ?_ hlow hhigh
  · intro i hi
    have hsi : 0 < s i := by
      have hsk := hs.1 k
      have hh := Real.exp_lt_exp.mp hi
      change 0 ≤ s k at hsk
      linarith
    have hupper := hkkt₁ i hsi
    have herr := (abs_le.mp (herror i)).2
    rw [← parseval_laplacian_apply_eq_weighted U hU]
    refine (parseval_diagonal_scaling_first_inequality U
      (fun j => Real.exp (2 * s j)) hU (fun j => Real.exp_pos _) i).trans ?_
    calc
      _ ≤ Real.exp (2 * s i) * β :=
        mul_le_mul_of_nonneg_left (by linarith) (Real.exp_nonneg _)
      _ = _ := by ring
  · intro i hi
    have hsi : s i < 1 := by
      have hsk := hs.2 k
      have hh := Real.exp_lt_exp.mp hi
      change s k ≤ 1 at hsk
      linarith
    have hlower := hkkt₂ i hsi
    have herr := (abs_le.mp (herror i)).1
    rw [← parseval_laplacian_apply_eq_weighted U hU]
    refine (diagonal_scaling_reciprocal_inequality U V
      (fun j => Real.exp (2 * s j)) hU hV hcomplete horth (fun j => Real.exp_pos _) i).trans ?_
    have hh := mul_le_mul_of_nonneg_left
      (show -(scaledLeverage U (fun j => Real.exp (2 * s j)) i -
        (U * U.transpose) i i) ≤ β by linarith)
      (le_of_lt (inv_pos.mpr (Real.exp_pos (2 * s i))))
    nlinarith

/-- A single compact minimization gives exact balancing of any target close
to the initial diagonal. Full spark, entropy minimization and continuation
are unnecessary. -/
theorem exists_box_balancing_oscillation {n d k : ℕ}
    (hn : 0 < n) (U : Frame n d) (V : Frame n k)
    (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (q : Fin n → ℝ) (β K : ℝ)
    (hqsum : (∑ i, q i) = (d : ℝ))
    (herror : ∀ i, |q i - (U * U.transpose) i i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => ((U * U.transpose) i j) ^ 2) K)
    (hβ : 0 ≤ β) (hsmall : 2 * β * K ≤ 1 / 2) :
    ∃ s : Fin n → ℝ,
      (∀ i, scaledLeverage U (fun j => Real.exp (2 * s j)) i = q i) ∧
      ∀ i j, s i - s j ≤ -Real.log (1 - 2 * β * K) := by
  letI : NeZero n := ⟨hn.ne'⟩
  have hne : (Set.Icc (0 : Fin n → ℝ) 1).Nonempty := by
    refine ⟨0, le_rfl, ?_⟩
    intro i
    norm_num
  obtain ⟨s, hs, hmin⟩ := isCompact_Icc.exists_isMinOn hne
    (show ContinuousOn (targetScalingPotential U q) (Set.Icc 0 1) from
      (show Continuous (targetScalingPotential U q) from
        (show Differentiable ℝ (targetScalingPotential U q) from
          fun s => (hasFDerivAt_targetScalingPotential hU q s).differentiableAt).continuous).continuousOn)
  have hosc := box_minimizer_oscillation hn U V hU hV hcomplete horth q s β K
    hs hmin herror hsolve hβ (by linarith)
  have hlog : -Real.log (1 - 2 * β * K) < 1 := by
    have hh := Real.log_le_log (by norm_num : (0 : ℝ) < 1 / 2)
      (show (1 / 2 : ℝ) ≤ 1 - 2 * β * K by linarith)
    rw [show (1 / 2 : ℝ) = (2 : ℝ)⁻¹ by norm_num, Real.log_inv] at hh
    have htwo := Real.log_lt_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)
      (by norm_num : (2 : ℝ) ≠ 1)
    linarith
  have hosc' : ∀ i j, s i - s j < 1 := fun i j => (hosc i j).trans_lt hlog
  obtain ⟨hkkt₁, hkkt₂⟩ := targetScalingPotential_box_optimality hU q s hs hmin
  refine ⟨s, ?_, hosc⟩
  by_cases hpos : ∀ i, 0 < s i
  · exact fun i => (Finset.sum_eq_sum_iff_of_le
      (fun j (_ : j ∈ (Finset.univ : Finset (Fin n))) => hkkt₁ j (hpos j))).mp
        ((sum_exp_scaledLeverage hU s).trans hqsum.symm) i (Finset.mem_univ i)
  · push Not at hpos
    obtain ⟨j, hj⟩ := hpos
    have hupper : ∀ i, s i < 1 := fun i => by linarith [hosc' i j]
    exact fun i => ((Finset.sum_eq_sum_iff_of_le
      (fun j (_ : j ∈ (Finset.univ : Finset (Fin n))) => hkkt₂ j (hupper j))).mp
        (hqsum.trans (sum_exp_scaledLeverage hU s).symm) i (Finset.mem_univ i)).symm

/-- Positive row scaling and right whitening, now supplied by the box argument. -/
theorem exists_box_radial_scaling {n d k : ℕ}
    (hn : 0 < n) (U : Frame n d) (V : Frame n k)
    (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (q : Fin n → ℝ) (β K : ℝ)
    (hqsum : (∑ i, q i) = (d : ℝ))
    (herror : ∀ i, |q i - (U * U.transpose) i i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => ((U * U.transpose) i j) ^ 2) K)
    (hβ : 0 ≤ β) (hsmall : 2 * β * K ≤ 1 / 2) :
    ∃ w : Fin n → ℝ, (∀ i, 0 < w i) ∧
      ∃ M : Matrix (Fin d) (Fin d) ℝ,
      IsParseval (rowScale U w * M) ∧
      (∀ i, rowNormSq (rowScale U w * M) i = q i) ∧
      ∀ i j, (1 - 2 * β * K) ^ 2 * w i ^ 2 ≤ w j ^ 2 := by
  letI : NeZero n := ⟨hn.ne'⟩
  obtain ⟨s, hbal, _hosc⟩ := exists_box_balancing_oscillation hn U V hU hV hcomplete
    horth q β K hqsum herror hsolve hβ hsmall
  let w : Fin n → ℝ := fun i => Real.exp (s i)
  have hw : ∀ i, 0 < w i := fun i => Real.exp_pos _
  have he : (fun i => w i ^ 2) = (fun i => Real.exp (2 * s i)) := by
    funext i
    dsimp [w]
    rw [pow_two, ← Real.exp_add]
    congr 1
    ring
  obtain ⟨M, _hM, hW⟩ := exists_posDef_right_whitening (rowScale U w)
    (rowScale_gram_posDef U w hU (fun i => (hw i).ne'))
  refine ⟨w, hw, M, hW, ?_, ?_⟩
  · intro i
    rw [← frameProjection_diagonal,
      ← columnSpaceProjection_eq_of_parseval_right_mul (rowScale U w) M hW,
      rowScale_projection_diagonal, he, hbal]
  · apply diagonal_scaling_ratio_bound U V (fun i => w i ^ 2) β K hU hV hcomplete horth
      (fun i => sq_pos_of_pos (hw i)) ?_ hsolve hβ (by linarith)
    intro i
    rw [he, hbal]
    exact herror i

end
end Paulsen
