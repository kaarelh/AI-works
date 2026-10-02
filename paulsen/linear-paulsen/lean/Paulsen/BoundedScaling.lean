import Paulsen.BoxScaling
import Paulsen.ScalingDistance
import Paulsen.ScalingEnergy
import Paulsen.FrameAlignment
import Paulsen.FrameComplement

/-!
# Static balancing with linear total-error cost

Compact box minimization supplies a scaling and bounds its coordinate ratios,
and one weighted sum of the first scaling inequality controls the distance.
There is no nonlinear path, Hessian comparison, or energy integration.
-/

namespace Paulsen

open scoped BigOperators

theorem diagonal_scaling_projection_distance_total_error {n d : ℕ}
    (U : Frame n d) (w : Fin n → ℝ) (M : Matrix (Fin d) (Fin d) ℝ)
    (hU : IsParseval U) (hV : IsParseval (rowScale U w * M))
    (m Z : ℝ) (hm : 0 < m) (hw : ∀ i, m ≤ w i) (hZ : ∀ i, w i ^ 2 ≤ Z) :
    sqDistance (frameProjection U) (frameProjection (rowScale U w * M)) ≤
      (Z ^ 2 / (2 * m ^ 4)) *
        ∑ i, |scaledLeverage U (fun j => w j ^ 2) i - rowNormSq U i| := by
  have hd := diagonal_scaling_projection_distance_le U w M hU hV m hm hw
  have he := diagonal_scaling_energy_le_total_error U w m Z hU hm hw hZ
  apply hd.trans
  calc
    _ ≤ (2 / m ^ 2) * ((Z ^ 2 / (4 * m ^ 2)) *
        ∑ i, |scaledLeverage U (fun j => w j ^ 2) i - rowNormSq U i|) :=
      mul_le_mul_of_nonneg_left he (by positivity)
    _ = _ := by ring

/-- Exact balancing of arbitrary Parseval frames with projection cost at most
eight times the total diagonal error. The only analytic input is the initial
bounded Poisson solver. A complementary frame is supplied explicitly here. -/
theorem balancing_projection_cost_target {n d k : ℕ}
    (hn : 0 < n) (_hdn : d ≤ n) (U : Frame n d) (V : Frame n k)
    (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (q : Fin n → ℝ) (β K : ℝ)
    (hqsum : (∑ i, q i) = (d : ℝ))
    (herror : ∀ i, |q i - rowNormSq U i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => (frameProjection U i j) ^ 2) K)
    (hβ : 0 ≤ β) (hsmall : 2 * β * K ≤ 1 / 2) :
    ∃ W : Frame n d, IsParseval W ∧ (∀ i, rowNormSq W i = q i) ∧
      sqDistance (frameProjection U) (frameProjection W) ≤
        8 * ∑ i, |q i - rowNormSq U i| := by
  classical
  letI : NeZero n := ⟨ne_of_gt hn⟩
  obtain ⟨w, hw, M, hWp, hWn, hratio⟩ := exists_box_radial_scaling hn U V
    hU hV hcomplete horth q β K hqsum
    (by intro i; change |q i - frameProjection U i i| ≤ β;
        rw [frameProjection_diagonal]; exact herror i) hsolve hβ hsmall
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
    have ha : (1 / 2 : ℝ) ≤ 1 - 2 * β * K := by linarith
    have hasq := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 1 / 2) ha 2
    have hp := mul_le_mul_of_nonneg_right hasq (sq_nonneg (w i))
    change (1 - 2 * β * K) ^ 2 * w i ^ 2 ≤ m ^ 2 at hr
    nlinarith
  have hcost := diagonal_scaling_projection_distance_total_error U w M hU hWp
    m (4 * m ^ 2) hm hwm hZ
  have hcoef : (4 * m ^ 2) ^ 2 / (2 * m ^ 4) = 8 := by
    field_simp
    ring
  rw [hcoef] at hcost
  simp_rw [hbal] at hcost
  exact ⟨W, hWp, hWn, hcost⟩

theorem balancing_projection_cost {n d k : ℕ}
    (hn : 0 < n) (hdn : d ≤ n) (U : Frame n d) (V : Frame n k)
    (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (β K : ℝ)
    (herror : ∀ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => (frameProjection U i j) ^ 2) K)
    (hβ : 0 ≤ β) (hsmall : 2 * β * K ≤ 1 / 2) :
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance (frameProjection U) (frameProjection W) ≤
        8 * ∑ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i| := by
  have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hsum : (∑ _i : Fin n, (d : ℝ) / n) = (d : ℝ) := by
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  obtain ⟨W, hWp, hWn, hcost⟩ := balancing_projection_cost_target hn hdn U V
    hU hV hcomplete horth (fun _ => (d : ℝ) / n) β K hsum herror hsolve hβ hsmall
  exact ⟨W, ⟨hWp, hWn⟩, hcost⟩

/-- Static balancing with an arbitrary target diagonal, including orthogonal
alignment and the paper's linear total-error distance bound. -/
theorem balancing_cost_target {n d : ℕ}
    (hn : 0 < n) (hdn : d ≤ n) (U : Frame n d)
    (hU : IsParseval U) (q : Fin n → ℝ) (β K : ℝ)
    (hqsum : (∑ i, q i) = (d : ℝ))
    (herror : ∀ i, |q i - rowNormSq U i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => (frameProjection U i j) ^ 2) K)
    (hβ : 0 ≤ β) (hsmall : 2 * β * K ≤ 1 / 2) :
    ∃ W : Frame n d, IsParseval W ∧ (∀ i, rowNormSq W i = q i) ∧
      sqDistance U W ≤ 8 * ∑ i, |q i - rowNormSq U i| := by
  obtain ⟨V, hV, hcomplete, horth⟩ := hU.exists_complement U hdn
  obtain ⟨W, hWp, hWn, hcost⟩ := balancing_projection_cost_target hn hdn U V
    hU hV hcomplete horth q β K hqsum herror hsolve hβ hsmall
  obtain ⟨R, hRR, hRtR, hdist⟩ := exists_parseval_frame_alignment U W hU hWp
  refine ⟨W * R, hWp.mul_orthogonal R hRtR, ?_, hdist.trans hcost⟩
  intro i
  rw [rowNormSq_mul_orthogonal W R hRR, hWn]

/-- The complete static balancing theorem for frame distance. Complementary
frames and the final orthogonal alignment are constructed internally. -/
theorem balancing_cost {n d : ℕ}
    (hn : 0 < n) (hdn : d ≤ n) (U : Frame n d)
    (hU : IsParseval U) (β K : ℝ)
    (herror : ∀ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => (frameProjection U i j) ^ 2) K)
    (hβ : 0 ≤ β) (hsmall : 2 * β * K ≤ 1 / 2) :
    HasCorrection U (8 * ∑ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i|) := by
  obtain ⟨V, hV, hcomplete, horth⟩ := hU.exists_complement U hdn
  obtain ⟨W, hW, hcost⟩ := balancing_projection_cost hn hdn U V
    hU hV hcomplete horth β K herror hsolve hβ hsmall
  obtain ⟨R, hRR, hRtR, hdist⟩ := exists_parseval_frame_alignment U W hU hW.1
  exact ⟨W * R, ⟨hW.1.mul_orthogonal R hRtR, hW.2.mul_orthogonal R hRR⟩,
    hdist.trans hcost⟩

/-- A sharp correction follows from the quantified initial Poisson hypothesis.
The seed constructions must still arrange that hypothesis at small cost. -/
theorem sharp_correction_of_poisson {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε K : ℝ)
    (hU : IsParseval U)
    (hequal : IsNearlyEqualNorm ε U) (hε : 0 ≤ ε)
    (hsolve : BoundedPoissonSolvability (fun i j => (frameProjection U i j) ^ 2) K)
    (hsmall : 2 * (ε * ((d : ℝ) / n)) * K ≤ 1 / 2) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt hn)
  have herror (i : Fin n) : |(d : ℝ) / n - rowNormSq U i| ≤ ε * ((d : ℝ) / n) := by
    rw [abs_sub_comm]
    exact hequal.abs_error i
  apply (balancing_cost hn hdn U hU (ε * ((d : ℝ) / n)) K
    herror hsolve (by positivity) hsmall).mono
  have hs := Finset.sum_le_sum (fun i (_ : i ∈ (Finset.univ : Finset (Fin n))) => herror i)
  have hsum : (∑ _i : Fin n, ε * ((d : ℝ) / n)) = ε * (d : ℝ) := by
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  rw [hsum] at hs
  nlinarith

/-- Compatibility form; full spark is not needed by the proof. -/
theorem fullSpark_balancing_projection_cost {n d k : ℕ}
    (hn : 0 < n) (hdn : d ≤ n) (U : Frame n d) (V : Frame n k)
    (_hU_spark : IsFullSpark U) (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (β K : ℝ)
    (herror : ∀ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => (frameProjection U i j) ^ 2) K)
    (hβ : 0 ≤ β) (hsmall : 2 * β * K ≤ 1 / 2) :
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance (frameProjection U) (frameProjection W) ≤
        8 * ∑ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i| := by
  exact balancing_projection_cost hn hdn U V hU hV hcomplete horth β K herror hsolve hβ hsmall

/-- Compatibility form; full spark is not needed by the proof. -/
theorem fullSpark_balancing_cost {n d : ℕ}
    (hn : 0 < n) (hdn : d ≤ n) (U : Frame n d)
    (_hU_spark : IsFullSpark U) (hU : IsParseval U) (β K : ℝ)
    (herror : ∀ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => (frameProjection U i j) ^ 2) K)
    (hβ : 0 ≤ β) (hsmall : 2 * β * K ≤ 1 / 2) :
    HasCorrection U (8 * ∑ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i|) := by
  exact balancing_cost hn hdn U hU β K herror hsolve hβ hsmall

/-- Compatibility form; full spark is not needed by the proof. -/
theorem fullSpark_sharp_correction_of_poisson {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε K : ℝ)
    (_hU_spark : IsFullSpark U) (hU : IsParseval U)
    (hequal : IsNearlyEqualNorm ε U) (hε : 0 ≤ ε)
    (hsolve : BoundedPoissonSolvability (fun i j => (frameProjection U i j) ^ 2) K)
    (hsmall : 2 * (ε * ((d : ℝ) / n)) * K ≤ 1 / 2) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  exact sharp_correction_of_poisson hd hdn U ε K hU hequal hε hsolve hsmall

end Paulsen
