import Paulsen.Linear.Barrier

/-!
# Static balancing controlled by the barrier constant

A single compact minimisation over the unit box gives exact balancing of any
target diagonal whose distance from the current diagonal, times the barrier
constant of the squared-Gram graph, is at most one half. The cost is linear
in the total diagonal error.
-/

namespace Paulsen.Linear

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-- The barrier constant of the squared-Gram graph of a frame. -/
def FrameBarrierBound {n d : ℕ} (U : Frame n d) (H : ℝ) : Prop :=
  HasBarrierBound (fun i j => (frameProjection U i j) ^ 2) H

/-- The barrier bound controls every box minimiser. -/
theorem box_minimizer_oscillation_barrier {n d k : ℕ}
    (hn : 0 < n) (U : Frame n d) (V : Frame n k)
    (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (q s : Fin n → ℝ) (β H : ℝ)
    (hs : s ∈ Set.Icc (0 : Fin n → ℝ) 1)
    (hmin : IsMinOn (targetScalingPotential U q) (Set.Icc 0 1) s)
    (herror : ∀ i, |q i - (U * U.transpose) i i| ≤ β)
    (hbar : HasBarrierBound (fun i j => ((U * U.transpose) i j) ^ 2) H)
    (hβ : 0 ≤ β) (hsmall : β * H < 1) :
    ∀ i j, s i - s j ≤ -Real.log (1 - β * H) := by
  letI : NeZero n := ⟨hn.ne'⟩
  obtain ⟨hkkt₁, hkkt₂⟩ := targetScalingPotential_box_optimality hU q s hs hmin
  obtain ⟨k, hlow, hhigh⟩ := finite_median_index (fun i => Real.exp (2 * s i))
  apply exponential_barrier_median (fun i j => sq_nonneg _)
    hbar hβ hsmall (Real.exp_pos (2 * s k)) ?_ ?_ hlow hhigh
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

/-- Exact balancing by one box minimisation, with oscillation control. -/
theorem exists_box_balancing_barrier {n d k : ℕ}
    (hn : 0 < n) (U : Frame n d) (V : Frame n k)
    (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (q : Fin n → ℝ) (β H : ℝ)
    (hqsum : (∑ i, q i) = (d : ℝ))
    (herror : ∀ i, |q i - (U * U.transpose) i i| ≤ β)
    (hbar : HasBarrierBound (fun i j => ((U * U.transpose) i j) ^ 2) H)
    (hβ : 0 ≤ β) (hsmall : β * H ≤ 1 / 2) :
    ∃ s : Fin n → ℝ,
      (∀ i, scaledLeverage U (fun j => Real.exp (2 * s j)) i = q i) ∧
      ∀ i j, s i - s j ≤ -Real.log (1 - β * H) := by
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
  have hosc := box_minimizer_oscillation_barrier hn U V hU hV hcomplete horth q s β H
    hs hmin herror hbar hβ (by linarith)
  have hlog : -Real.log (1 - β * H) < 1 := by
    have hh := Real.log_le_log (by norm_num : (0 : ℝ) < 1 / 2)
      (show (1 / 2 : ℝ) ≤ 1 - β * H by linarith)
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

/-- Positive row scaling and right whitening with bounded scale ratio. -/
theorem exists_box_radial_scaling_barrier {n d k : ℕ}
    (hn : 0 < n) (U : Frame n d) (V : Frame n k)
    (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (q : Fin n → ℝ) (β H : ℝ)
    (hqsum : (∑ i, q i) = (d : ℝ))
    (herror : ∀ i, |q i - (U * U.transpose) i i| ≤ β)
    (hbar : HasBarrierBound (fun i j => ((U * U.transpose) i j) ^ 2) H)
    (hβ : 0 ≤ β) (hsmall : β * H ≤ 1 / 2) :
    ∃ w : Fin n → ℝ, (∀ i, 0 < w i) ∧
      ∃ M : Matrix (Fin d) (Fin d) ℝ,
      IsParseval (rowScale U w * M) ∧
      (∀ i, rowNormSq (rowScale U w * M) i = q i) ∧
      ∀ i j, (1 - β * H) ^ 2 * w i ^ 2 ≤ w j ^ 2 := by
  letI : NeZero n := ⟨hn.ne'⟩
  obtain ⟨s, hbal, hosc⟩ := exists_box_balancing_barrier hn U V hU hV hcomplete
    horth q β H hqsum herror hbar hβ hsmall
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
  · -- the ratio bound follows from the oscillation bound
    intro i j
    have hδ : 0 < 1 - β * H := by linarith
    have h1 := hosc i j
    have hlog : Real.log (1 - β * H) ≤ s j - s i := by linarith
    have hexp : 1 - β * H ≤ Real.exp (s j - s i) := by
      rw [← Real.exp_log hδ]; exact Real.exp_le_exp.mpr hlog
    have hwi : 0 < w i := hw i
    have hratio : (1 - β * H) * w i ≤ w j := by
      have : Real.exp (s j - s i) * w i = w j := by
        dsimp [w]; rw [← Real.exp_add]; congr 1; ring
      calc (1 - β * H) * w i ≤ Real.exp (s j - s i) * w i :=
            mul_le_mul_of_nonneg_right hexp hwi.le
        _ = w j := this
    have h0 : 0 ≤ (1 - β * H) * w i := by positivity
    calc (1 - β * H) ^ 2 * w i ^ 2 = ((1 - β * H) * w i) ^ 2 := by ring
      _ ≤ w j ^ 2 := pow_le_pow_left₀ h0 hratio 2

/-- Exact balancing with projection cost at most eight times the total
diagonal error, controlled by the barrier constant. -/
theorem balancing_projection_cost_barrier {n d k : ℕ}
    (hn : 0 < n) (U : Frame n d) (V : Frame n k)
    (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (q : Fin n → ℝ) (β H : ℝ)
    (hqsum : (∑ i, q i) = (d : ℝ))
    (herror : ∀ i, |q i - rowNormSq U i| ≤ β)
    (hbar : FrameBarrierBound U H)
    (hβ : 0 ≤ β) (hsmall : β * H ≤ 1 / 2) :
    ∃ W : Frame n d, IsParseval W ∧ (∀ i, rowNormSq W i = q i) ∧
      sqDistance (frameProjection U) (frameProjection W) ≤
        8 * ∑ i, |q i - rowNormSq U i| := by
  classical
  letI : NeZero n := ⟨ne_of_gt hn⟩
  obtain ⟨w, hw, M, hWp, hWn, hratio⟩ := exists_box_radial_scaling_barrier hn U V
    hU hV hcomplete horth q β H hqsum
    (by intro i; change |q i - frameProjection U i i| ≤ β;
        rw [frameProjection_diagonal]; exact herror i) hbar hβ hsmall
  let W := rowScale U w * M
  have hbal (i : Fin n) : scaledLeverage U (fun j => w j ^ 2) i = q i := by
    rw [← rowScale_projection_diagonal,
      columnSpaceProjection_eq_of_parseval_right_mul (rowScale U w) M hWp,
      frameProjection_diagonal]
    exact hWn i
  obtain ⟨i₀, _, hmin⟩ := Finset.exists_min_image Finset.univ w Finset.univ_nonempty
  let m := w i₀
  have hm : 0 < m := hw i₀
  have hwm : ∀ i, m ≤ w i := fun i => hmin i (Finset.mem_univ i)
  have hZ : ∀ i, w i ^ 2 ≤ 4 * m ^ 2 := by
    intro i
    have hr := hratio i i₀
    have ha : (1 / 2 : ℝ) ≤ 1 - β * H := by linarith
    have hasq := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 1 / 2) ha 2
    have hp := mul_le_mul_of_nonneg_right hasq (sq_nonneg (w i))
    change (1 - β * H) ^ 2 * w i ^ 2 ≤ m ^ 2 at hr
    nlinarith
  have hcost := diagonal_scaling_projection_distance_total_error U w M hU hWp
    m (4 * m ^ 2) hm hwm hZ
  have hcoef : (4 * m ^ 2) ^ 2 / (2 * m ^ 4) = 8 := by
    field_simp
    ring
  rw [hcoef] at hcost
  simp_rw [hbal] at hcost
  exact ⟨W, hWp, hWn, hcost⟩

/-- Static balancing to the constant diagonal `d/n`, in frame distance. -/
theorem balancing_cost_barrier {n d : ℕ}
    (hn : 0 < n) (hdn : d ≤ n) (U : Frame n d)
    (hU : IsParseval U) (β H : ℝ)
    (herror : ∀ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i| ≤ β)
    (hbar : FrameBarrierBound U H)
    (hβ : 0 ≤ β) (hsmall : β * H ≤ 1 / 2) :
    HasCorrection U (8 * ∑ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i|) := by
  obtain ⟨V, hV, hcomplete, horth⟩ := hU.exists_complement U hdn
  have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hsum : (∑ _i : Fin n, (d : ℝ) / n) = (d : ℝ) := by
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  obtain ⟨W, hWp, hWn, hcost⟩ := balancing_projection_cost_barrier hn U V
    hU hV hcomplete horth (fun _ => (d : ℝ) / n) β H hsum herror hbar hβ hsmall
  obtain ⟨R, hRR, hRtR, hdist⟩ := exists_parseval_frame_alignment U W hU hWp
  exact ⟨W * R, ⟨hWp.mul_orthogonal R hRtR, fun i => by
      rw [rowNormSq_mul_orthogonal W R hRR, hWn]⟩, hdist.trans hcost⟩

end
end Paulsen.Linear
