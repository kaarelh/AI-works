import Paulsen.Paper.SampleAuxS1
import Paulsen.SmoothQuadraticTail

/-!
# Helpers for `ModerateSample`: the event (S2)

* the Gaussian tail of the linear diagonal `(𝒜Z)_i`;
* the tail of the quadratic diagonal `q_i(Z) - E q_i(Z)` from `lem:gauss`(a).
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- Gaussian tail of `(𝒜Z)_i` from its variance. -/
theorem diagMap_tail {n d : ℕ} {U : Frame n d} (_hU : IsParseval U) {ρ : ℝ} (i : Fin n)
    {v u : ℝ} (hv : 0 < v) (hu : 0 ≤ u)
    (hvar : ∫ g, diagMap U (moderateNoise U ρ g) i ^ 2 ∂gaussAmb n d ≤ v) :
    (gaussAmb n d).real {g | u < |diagMap U (moderateNoise U ρ g) i|} ≤
      2 * Real.exp (-u ^ 2 / (2 * v)) := by
  let w : Fin n × Fin d → ℝ := fun p => if p.1 = i then U i p.2 else 0
  set L := linDual (noiseF U ρ) w
  have hL : ∀ g, L g = diagMap U (moderateNoise U ρ g) i := by
    intro g
    rw [linDual_apply]
    simp only [w, Fintype.sum_prod_type, ite_mul, zero_mul, Finset.sum_ite_irrel,
      Finset.sum_const_zero, Finset.sum_ite_eq', Finset.mem_univ, if_true]
    simp only [diagMap, Matrix.mul_apply, Matrix.transpose_apply,
      moderateNoise_apply]
    apply Finset.sum_congr rfl
    intro c _
    ring
  have hnorm : ‖L‖ ^ 2 ≤ v := by
    rw [← integral_sq_dual_stdGaussian]
    simp_rw [hL]
    exact hvar
  have ht := stdGaussian_dual_abs_tail L v u hv hu hnorm
  have hsub : {g : FrameVector n d | u < |diagMap U (moderateNoise U ρ g) i|} ⊆
      {g | u ≤ |L g|} := by
    intro g hg
    simp only [Set.mem_setOf_eq] at hg ⊢
    rw [hL]
    exact hg.le
  exact (measureReal_mono hsub).trans ht

/-- `exp(-3 log(2n)) = (2n)^{-3}`. -/
theorem exp_neg_three_log {n : ℕ} (hn : 0 < n) :
    Real.exp (-(3 * Real.log (2 * n))) = (2 * (n : ℝ)) ^ (-3 : ℤ) := by
  have h2n : (0 : ℝ) < 2 * n := by positivity
  rw [Real.exp_neg, show (3 : ℝ) * Real.log (2 * n) = ((3 : ℕ) : ℝ) * Real.log (2 * n) by norm_num,
    Real.exp_nat_mul, Real.exp_log h2n, _root_.zpow_neg]
  norm_cast

/-- Tail of the quadratic diagonal, from `lem:gauss`(a) with `u = η'a`. -/
theorem quadDiag_tail {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (hn : 0 < n) (hd : 0 < d)
    {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n)
    (hfrob : frobSq (Smooth.horizontalQuadraticCoefficient U i) ≤ 7 * d) {η' : ℝ}
    (hη' : 0 < η') (hη'7 : η' ≤ 7) :
    (gaussAmb n d).real {g | η' * ((d : ℝ) / n) <
      |horizontalQuadraticDiagonal U (moderateNoise U ρ g) i -
        ∫ g', horizontalQuadraticDiagonal U (moderateNoise U ρ g') i ∂gaussAmb n d|} ≤
      2 * Real.exp (-(η' ^ 2 * d / 56)) := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  set M := Smooth.horizontalQuadraticCoefficient U i
  set F := noiseF U ρ
  have hM := Smooth.horizontalQuadraticCoefficient_isHermitian U i
  have hcov : opNorm (F * F.transpose) ≤ 1 / (n : ℝ) := by
    unfold opNorm
    rw [euclidean_operator_norm_covariance F]
    exact opNorm_noiseF_sq hU hρ
  have hop : opNorm M ≤ 1 :=
    Smooth.horizontalQuadraticCoefficient_operator_norm_le U i (hU.leverage_le_one i)
  have ht := quad_tail_of_bounds M hM F (s := 1 / (n : ℝ)) (V := 7 * d) (B := 1)
    (u := η' * ((d : ℝ) / n)) (by positivity) (by positivity) hcov hfrob hop
  have hset : {g : FrameVector n d | η' * ((d : ℝ) / n) <
      |horizontalQuadraticDiagonal U (moderateNoise U ρ g) i -
        ∫ g', horizontalQuadraticDiagonal U (moderateNoise U ρ g') i ∂gaussAmb n d|} =
      {g | η' * ((d : ℝ) / n) < |euclideanQuadratic M (Matrix.toEuclideanLin F g) -
        (F.transpose * M * F).trace|} := by
    have hmean := Smooth.horizontalQuadraticDiagonal_mean_eq_trace U F i
    ext g
    simp only [Set.mem_setOf_eq]
    change η' * ((d : ℝ) / n) < |horizontalQuadraticDiagonal U
        (frameOfVector (Matrix.toEuclideanLin F g)) i -
        ∫ g', horizontalQuadraticDiagonal U (frameOfVector (Matrix.toEuclideanLin F g')) i
          ∂stdGaussian (EuclideanSpace ℝ (Fin n × Fin d))| ↔ _
    rw [hmean, Smooth.horizontalQuadraticDiagonal_linear_image]
  rw [hset]
  have hmin : min ((η' * ((d : ℝ) / n)) ^ 2 / ((1 / (n : ℝ)) ^ 2 * (7 * d)))
      (η' * ((d : ℝ) / n) / (1 / (n : ℝ) * 1)) = η' ^ 2 * d / 7 := by
    have e1 : (η' * ((d : ℝ) / n)) ^ 2 / ((1 / (n : ℝ)) ^ 2 * (7 * d)) = η' ^ 2 * d / 7 := by
      field_simp
    have e2 : η' * ((d : ℝ) / n) / (1 / (n : ℝ) * 1) = η' * d := by field_simp
    rw [e1, e2]
    apply min_eq_left
    have : η' ^ 2 ≤ 7 * η' := by nlinarith
    have := mul_le_mul_of_nonneg_right this hdR.le
    linarith
  rw [hmin] at ht
  have he : -(1 / 8 : ℝ) * (η' ^ 2 * d / 7) = -(η' ^ 2 * d / 56) := by ring
  rw [he] at ht
  exact ht

end

end Paulsen.Paper
