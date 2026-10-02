import Paulsen.Linear.DriftAlgebra
import Paulsen.HorizontalTaylor
import Paulsen.SmoothDiagonal

/-!
# The drifted retraction

We retract along `H_W = H + (t/2) m`, where `H` is the sampled horizontal noise
and `m` a small deterministic horizontal drift. The projection moves by
`t Y_H` up to a small row error, and the diagonal changes by
`2t 𝒜H + t² 𝒜m + t² q(H)` up to a remainder of order `a t³ + a t² · 10⁻³⁵`.
With `m = m_*` the term `t² 𝒜 m_* = t² b_*` cancels the filter bias exactly.
-/

namespace Paulsen.Linear

open Matrix Paulsen MeasureTheory ProbabilityTheory
open scoped BigOperators

noncomputable section

theorem toEuclideanLin_add_smul_norm_le {n d : ℕ} (H m : Frame n d) (c : ℝ) :
    ‖(Matrix.toEuclideanLin (H + c • m)).toContinuousLinearMap‖ ≤
      ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ +
        |c| * ‖(Matrix.toEuclideanLin m).toContinuousLinearMap‖ := by
  have he : (Matrix.toEuclideanLin (H + c • m)).toContinuousLinearMap =
      (Matrix.toEuclideanLin H).toContinuousLinearMap +
        c • (Matrix.toEuclideanLin m).toContinuousLinearMap := by
    rw [map_add, map_smul, map_add, map_smul]
  rw [he]
  refine (norm_add_le _ _).trans ?_
  rw [norm_smul, Real.norm_eq_abs]

set_option maxHeartbeats 2000000 in
/-- The drifted retraction with all estimates needed for the seed. -/
theorem exists_drifted_retraction {n d : ℕ}
    (U H m : Frame n d) (hU : IsParseval U)
    (hUH : U.transpose * H = 0) (hUm : U.transpose * m = 0)
    (hH : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ≤ 128)
    {a : ℝ} (ha : 0 < a) (ha1 : a ≤ 1 / 2) (hna : (n : ℝ) * a = d)
    (hUrow : ∀ i, rowNormSq U i ≤ 2 * a)
    (hHrow : ∀ i, rowNormSq H i ≤ 600 * a)
    (hYrow : ∀ i, rowNormSq (H * U.transpose + U * H.transpose) i ≤ 2000 * a)
    {t : ℝ} (ht : 0 < t) (htsmall : t ^ 2 ≤ 1 / (10 ^ 24 : ℝ))
    (hm : t ^ 2 * ‖normalFrobVector m‖ ^ 2 ≤ a / 10 ^ 78) :
    ∃ (W : Frame n d) (r : Fin n → ℝ), IsParseval W ∧
      sqDistance U W ≤ 20000 * t ^ 2 * (d : ℝ) ∧
      (∀ i, rowNormSq (frameProjection W - frameProjection U -
        t • (H * U.transpose + U * H.transpose)) i ≤ a * t ^ 2 / 320000000) ∧
      (∀ i, rowNormSq W i = rowNormSq U i + 2 * t * (H * U.transpose) i i +
        t ^ 2 * (m * U.transpose) i i + t ^ 2 * horizontalQuadraticDiagonal U H i + r i) ∧
      (∀ i, |r i| ≤ 10 ^ 12 * a * t ^ 3 + a * t ^ 2 / 10 ^ 35) := by
  set M := ‖normalFrobVector m‖ with hMdef
  have hM0 : 0 ≤ M := norm_nonneg _
  set HW := H + (t / 2) • m with hHWdef
  have hUHW : U.transpose * HW = 0 := by
    rw [hHWdef, Matrix.mul_add, Matrix.mul_smul, hUH, hUm, smul_zero, add_zero]
  have ht2 : 0 < t ^ 2 := by positivity
  have htM : t * M ≤ 1 / 10 ^ 39 := by
    have h1 : (t * M) ^ 2 ≤ (1 / 10 ^ 39) ^ 2 := by
      rw [mul_pow]; nlinarith
    exact (sq_le_sq₀ (by positivity) (by positivity)).mp h1
  have hop : ‖(Matrix.toEuclideanLin HW).toContinuousLinearMap‖ ≤ 128 + 1 := by
    refine (toEuclideanLin_add_smul_norm_le H m (t / 2)).trans ?_
    have h1 := opNorm_le_frob m
    rw [abs_of_nonneg (by positivity)]
    have h2 : t / 2 * ‖(Matrix.toEuclideanLin m).toContinuousLinearMap‖ ≤ t / 2 * M :=
      mul_le_mul_of_nonneg_left h1 (by positivity)
    nlinarith
  have hK : ‖(Matrix.toEuclideanLin HW).toContinuousLinearMap‖ ^ 2 ≤ (16641 : ℝ) := by
    have := norm_nonneg (Matrix.toEuclideanLin HW).toContinuousLinearMap
    nlinarith
  have hp1 : ∀ i, rowNormSq U i ≤ 1 := fun i => (hUrow i).trans (by linarith)
  have hmrow : ∀ i, rowNormSq m i ≤ M ^ 2 := fun i => rowNormSq_le_frob_sq m i
  have hUmrow : ∀ i, rowNormSq (U * m.transpose) i ≤ M ^ 2 := by
    intro i
    refine (rowNormSq_mul_transpose_le U m i).trans ?_
    have := mul_le_mul_of_nonneg_right (hp1 i) (sq_nonneg M)
    linarith
  have hHWrow : ∀ i, rowNormSq HW i ≤ 1201 * a := by
    intro i
    refine (rowNormSq_add_le _ _ i).trans ?_
    rw [rowNormSq_smul]
    have h1 := hHrow i
    have h2 := mul_le_mul_of_nonneg_left (hmrow i) (sq_nonneg (t / 2))
    have h3 : (t / 2) ^ 2 * M ^ 2 ≤ a / 10 ^ 78 := by nlinarith
    nlinarith
  have hnum1 : t ^ 2 * (16641 : ℝ) ≤ 1 / 2 := by nlinarith
  have hnum2 : t ^ 2 ≤ 1 := by nlinarith
  obtain ⟨W, r', hW, hcost, hgram, htaylor, hrem, _hcanon, _hspark⟩ :=
    exists_horizontal_polar_retraction_taylor_uniform U HW t 16641 (1201 * a) hU hUHW hK
      hnum1 hnum2 (fun i => (hUrow i).trans (by linarith)) hHWrow
  let r : Fin n → ℝ := fun i => t ^ 3 * horizontalQuadraticCross U H m i +
    t ^ 4 / 4 * horizontalQuadraticDiagonal U m i + r' i
  refine ⟨W, r, hW, ?_, ?_, ?_, ?_⟩
  · -- distance
    have hsum : (∑ i, rowNormSq HW i) ≤ 1201 * (d : ℝ) := by
      calc (∑ i, rowNormSq HW i) ≤ ∑ _i : Fin n, 1201 * a :=
            Finset.sum_le_sum fun i _ => hHWrow i
        _ = 1201 * (d : ℝ) := by
            rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, ← hna]
            ring
    have hd0 : (0 : ℝ) ≤ d := Nat.cast_nonneg d
    have h1 := mul_le_mul_of_nonneg_left hsum (show (0 : ℝ) ≤ 2 * t ^ 2 by positivity)
    have h2 : 2 * t ^ 4 * (16641 : ℝ) ^ 2 * (d : ℝ) ≤ t ^ 2 * d := by
      have : t ^ 4 = t ^ 2 * t ^ 2 := by ring
      rw [this]
      have h3 : 2 * t ^ 2 * (16641 : ℝ) ^ 2 ≤ 1 := by nlinarith
      have h4 := mul_le_mul_of_nonneg_right h3 (mul_nonneg ht2.le hd0)
      nlinarith
    nlinarith
  · -- rows
    intro i
    have hE : frameProjection W - frameProjection U - t • (H * U.transpose + U * H.transpose) =
        (frameProjection W - frameProjection U - t • (HW * U.transpose + U * HW.transpose)) +
          (t ^ 2 / 2) • (m * U.transpose + U * m.transpose) := by
      rw [hHWdef]
      simp only [Matrix.add_mul, Matrix.transpose_add, Matrix.transpose_smul, Matrix.mul_add,
        Matrix.smul_mul, Matrix.mul_smul]
      module
    rw [hE]
    refine (rowNormSq_add_le _ _ i).trans ?_
    rw [rowNormSq_smul, rowNormSq_tangent_horizontal hU hUm]
    have h1 := hgram i
    have h2 := add_le_add (hmrow i) (hUmrow i)
    have h3 : (t ^ 2 / 2) ^ 2 * (rowNormSq m i + rowNormSq (U * m.transpose) i) ≤
        (t ^ 2 / 2) ^ 2 * (2 * M ^ 2) :=
      mul_le_mul_of_nonneg_left (by linarith) (sq_nonneg _)
    have h4 : (t ^ 2 / 2) ^ 2 * (2 * M ^ 2) ≤ t ^ 2 * (a / 10 ^ 78) / 2 := by
      have : (t ^ 2 / 2) ^ 2 * (2 * M ^ 2) = t ^ 2 * (t ^ 2 * M ^ 2) / 2 := by ring
      rw [this]
      have := mul_le_mul_of_nonneg_left hm ht2.le
      linarith
    have h5 : (48 * (16641 : ℝ) ^ 2 + 2 * 16641) * (1201 * a) * t ^ 4 ≤
        a * t ^ 2 / 1000000000 := by
      have : t ^ 4 = t ^ 2 * t ^ 2 := by ring
      rw [this]
      have h6 := mul_le_mul_of_nonneg_left htsmall (mul_nonneg ha.le ht2.le)
      nlinarith
    have hat : 0 ≤ a * t ^ 2 := by positivity
    calc 2 * rowNormSq (frameProjection W - frameProjection U -
          t • (HW * U.transpose + U * HW.transpose)) i +
          2 * ((t ^ 2 / 2) ^ 2 * (rowNormSq m i + rowNormSq (U * m.transpose) i)) ≤
          2 * (a * t ^ 2 / 1000000000) + 2 * (t ^ 2 * (a / 10 ^ 78) / 2) :=
          add_le_add (mul_le_mul_of_nonneg_left (h1.trans h5) (by norm_num))
            (mul_le_mul_of_nonneg_left (h3.trans h4) (by norm_num))
      _ ≤ _ := by
          have e : t ^ 2 * (a / 10 ^ 78) = (a * t ^ 2) / 10 ^ 78 := by ring
          rw [e]; linarith
  · -- diagonal identity
    intro i
    rw [htaylor i]
    have hA : (HW * U.transpose) i i = (H * U.transpose) i i + (t / 2) * (m * U.transpose) i i := by
      rw [hHWdef, Matrix.add_mul, Matrix.smul_mul, Matrix.add_apply, Matrix.smul_apply,
        smul_eq_mul]
    have hq : horizontalQuadraticDiagonal U HW i = horizontalQuadraticDiagonal U H i +
        t * horizontalQuadraticCross U H m i + t ^ 2 / 4 * horizontalQuadraticDiagonal U m i := by
      rw [hHWdef, horizontalQuadraticDiagonal_add, horizontalQuadraticCross_smul,
        horizontalQuadraticDiagonal_smul]
      ring
    rw [hA, hq]
    simp only [r]
    ring
  · -- remainder
    intro i
    simp only [r]
    have hr' : |r' i| ≤ 10 ^ 12 * a * t ^ 3 := by
      refine (hrem i).trans ?_
      rw [abs_of_nonneg ht.le]
      have ht1 : t ≤ 1 / 10 ^ 12 := by
        have : t ^ 2 ≤ (1 / 10 ^ 12) ^ 2 := by nlinarith
        exact (sq_le_sq₀ ht.le (by positivity)).mp this
      have h1 : t ^ 4 = t ^ 3 * t := by ring
      rw [h1]
      have h2 := mul_le_mul_of_nonneg_left ht1 (show 0 ≤ a * t ^ 3 by positivity)
      have h3 : 0 ≤ a * t ^ 3 := by positivity
      nlinarith
    set s : ℝ := 1 / (10 ^ 39 * t) with hs
    have hs0 : 0 < s := by positivity
    have hc := horizontalQuadraticCross_abs_le U H m i hs0
    rw [← rowNormSq_tangent_horizontal hU hUH, ← rowNormSq_tangent_horizontal hU hUm] at hc
    have hYm : rowNormSq (m * U.transpose + U * m.transpose) i ≤ 2 * M ^ 2 := by
      rw [rowNormSq_tangent_horizontal hU hUm]; linarith [hmrow i, hUmrow i]
    have hcross : |t ^ 3 * horizontalQuadraticCross U H m i| ≤
        a * t ^ 2 / 10 ^ 36 + a * t ^ 2 / 10 ^ 39 := by
      rw [abs_mul, abs_of_nonneg (by positivity)]
      refine (mul_le_mul_of_nonneg_left hc (by positivity)).trans ?_
      have hYH := hYrow i
      have e1 : t ^ 3 * ((s * rowNormSq (H * U.transpose + U * H.transpose) i +
          rowNormSq (m * U.transpose + U * m.transpose) i / s) / 2) =
          t ^ 2 * rowNormSq (H * U.transpose + U * H.transpose) i / (2 * 10 ^ 39) +
            10 ^ 39 * t ^ 4 * rowNormSq (m * U.transpose + U * m.transpose) i / 2 := by
        rw [hs]; field_simp
      rw [e1]
      have h1 := mul_le_mul_of_nonneg_left hYH ht2.le
      have h2 := mul_le_mul_of_nonneg_left hYm (show 0 ≤ t ^ 4 by positivity)
      have h3 : t ^ 4 * (2 * M ^ 2) ≤ 2 * t ^ 2 * (a / 10 ^ 78) := by
        have : t ^ 4 * (2 * M ^ 2) = 2 * t ^ 2 * (t ^ 2 * M ^ 2) := by ring
        rw [this]
        exact mul_le_mul_of_nonneg_left hm (by positivity)
      nlinarith
    have hquad : |t ^ 4 / 4 * horizontalQuadraticDiagonal U m i| ≤ a * t ^ 2 / 10 ^ 78 := by
      rw [abs_mul, abs_of_nonneg (by positivity)]
      have h1 := horizontalQuadraticDiagonal_abs_le U m i
      have h2 : |horizontalQuadraticDiagonal U m i| ≤ 2 * M ^ 2 := by
        linarith [hmrow i, hUmrow i]
      have h3 := mul_le_mul_of_nonneg_left h2 (show 0 ≤ t ^ 4 / 4 by positivity)
      have h4 : t ^ 4 / 4 * (2 * M ^ 2) ≤ t ^ 2 * (a / 10 ^ 78) / 2 := by
        have : t ^ 4 / 4 * (2 * M ^ 2) = t ^ 2 * (t ^ 2 * M ^ 2) / 2 := by ring
        rw [this]
        have := mul_le_mul_of_nonneg_left hm ht2.le
        linarith
      have hat : 0 ≤ a * t ^ 2 := by positivity
      nlinarith
    have hat : 0 ≤ a * t ^ 2 := by positivity
    calc _ ≤ |t ^ 3 * horizontalQuadraticCross U H m i +
          t ^ 4 / 4 * horizontalQuadraticDiagonal U m i| + |r' i| := abs_add_le _ _
      _ ≤ (|t ^ 3 * horizontalQuadraticCross U H m i| +
          |t ^ 4 / 4 * horizontalQuadraticDiagonal U m i|) + |r' i| := by
          gcongr; exact abs_add_le _ _
      _ ≤ _ := by nlinarith

end

end Paulsen.Linear
