import NeuralGeneralization.BatchTwoImprovedReconstruction
import NeuralGeneralization.RobustCompressionResidualClipping

/-! Uniform coefficient bounds for the actual leverage-weighted reconstruction. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
open MeasureTheory ProbabilityTheory InnerProductSpace
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry RobustCompressionClipping
open RobustCompressionGaussian BatchTwoImprovedActiveGeometry Classical
variable {N q m D : ℕ}

theorem gaussianClip_abs_le {B : ℝ} (hB : 0 ≤ B) (z : ℝ) : |gaussianClip B z| ≤ B := by
  apply abs_le.mpr
  constructor
  · exact le_max_left _ _
  · exact max_le (by linarith) (min_le_left _ _)

theorem importance_active_coefficient_bound (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (htrace : ∑ j, rowEnergy u j ≤ (N : ℝ)*q)
    {BH : ℝ} (hBH : 0 ≤ BH) (H : EuclideanSpace ℝ (Fin q)) (j : Fin N) :
    |sourceMultiplier u j * linearEvaluation (u j) (fun k => wholeClip BH H k)| ≤
      2*BH*((q : ℝ)+1) := by
  let a := sourceMultiplier u j
  let e := rowEnergy u j
  let z := linearEvaluation (u j) (fun k => wholeClip BH H k)
  have ha : 0 ≤ a := (sourceMultiplier_pos hN hq u j).le
  have ha2 : a ≤ 2 := sourceMultiplier_le_two hN hq u htrace j
  have hae : a*e ≤ 2*q := sourceMultiplier_energy_le hN hq u htrace j
  have he : 0 ≤ e := rowEnergy_nonneg u j
  have hnorm := wholeClip_norm_le BH hBH H
  have hnormsq : (∑ k, (wholeClip BH H k)^2) ≤ BH^2 := by
    rw [← EuclideanSpace.real_norm_sq_eq]
    exact pow_le_pow_left₀ (norm_nonneg _) hnorm 2
  have hz : z^2 ≤ e*BH^2 := by
    exact (Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (u j) (fun k => wholeClip BH H k)).trans
      (mul_le_mul_of_nonneg_left hnormsq he)
  have hae2 : a^2*e ≤ 4*q := by
    have hh := mul_le_mul_of_nonneg_right ha2 (mul_nonneg ha he)
    nlinarith
  have hsq : (a*z)^2 ≤ 4*(q : ℝ)*BH^2 := by
    rw [mul_pow]
    calc
      _ ≤ a^2*(e*BH^2) := mul_le_mul_of_nonneg_left hz (sq_nonneg a)
      _ = (a^2*e)*BH^2 := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_right hae2 (sq_nonneg BH)
  have hq0 : (0 : ℝ) ≤ q := Nat.cast_nonneg q
  have hqbound : 4*(q : ℝ)*BH^2 ≤ (2*BH*((q : ℝ)+1))^2 := by
    nlinarith [mul_nonneg (sq_nonneg BH) (sq_nonneg (q : ℝ))]
  apply (sq_le_sq₀ (abs_nonneg _) (by positivity : 0 ≤ 2*BH*((q : ℝ)+1))).mp
  simpa only [sq_abs] using hsq.trans hqbound

theorem sharpSourceRowsDraw_bounded (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (u : Fin N → Fin q → ℝ) (htrace : ∑ j, rowEnergy u j ≤ (N : ℝ)*q)
    (H : Fin D → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (ξ : Fin D → Fin m → ℝ) {t BH BG : ℝ}
    (ht : |t| ≤ 1) (hBH : 0 ≤ BH) (hBG : 0 ≤ BG) (i : Fin D) (j : Fin m) :
    |sharpSourceRowsDraw t BH BG ((u,H),I) ξ i j| ≤ 2*BH*((q : ℝ)+1)+2*BG := by
  have hm1 : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have hsqrtm : (1 : ℝ) ≤ Real.sqrt m := by
    apply (Real.le_sqrt (by norm_num) (Nat.cast_nonneg m)).mpr
    simpa using hm1
  have htm : |t/Real.sqrt (m : ℝ)| ≤ 1 := by
    rw [abs_div, abs_of_nonneg (Real.sqrt_nonneg _)]
    exact (div_le_one (by positivity)).mpr (ht.trans hsqrtm)
  have ha := (sourceMultiplier_pos hN hq u (I j)).le
  have ha2 := sourceMultiplier_le_two hN hq u htrace (I j)
  have hsa : Real.sqrt (sourceMultiplier u (I j)) ≤ 2 := by
    nlinarith [Real.sq_sqrt ha, Real.sqrt_nonneg (sourceMultiplier u (I j))]
  have hb := importance_active_coefficient_bound hN hq u htrace hBH (H i) (I j)
  have hactive : |sourceMultiplier u (I j)/(m : ℝ) *
      linearEvaluation (u (I j)) (fun k => wholeClip BH (H i) k)| ≤ 2*BH*((q : ℝ)+1) := by
    rw [div_mul_eq_mul_div, abs_div, abs_of_nonneg (show (0 : ℝ) ≤ (m : ℝ) from Nat.cast_nonneg m)]
    exact (div_le_div_of_nonneg_right hb (Nat.cast_nonneg m)).trans
      (div_le_self (by positivity) hm1)
  have hgaussian : |t/Real.sqrt (m : ℝ)*Real.sqrt (sourceMultiplier u (I j))*gaussianClip BG (ξ i j)| ≤ 2*BG := by
    rw [abs_mul, abs_mul, abs_of_nonneg (Real.sqrt_nonneg _)]
    have hp : |t/Real.sqrt (m : ℝ)| * Real.sqrt (sourceMultiplier u (I j)) ≤ 2 :=
      (mul_le_mul_of_nonneg_right htm (Real.sqrt_nonneg _)).trans (by simpa using hsa)
    exact mul_le_mul hp (gaussianClip_abs_le hBG _) (abs_nonneg _) (by norm_num)
  exact (abs_add_le _ _).trans (add_le_add hactive hgaussian)

theorem sharpSourceRowsDraw_sourceRows_bounded (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (b : Fin q → EuclideanSpace ℝ (Fin N))
    (H : Fin D → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (ξ : Fin D → Fin m → ℝ) {t BH BG : ℝ}
    (ht : |t| ≤ 1) (hBH : 0 ≤ BH) (hBG : 0 ≤ BG) (i : Fin D) (j : Fin m) :
    |sharpSourceRowsDraw t BH BG (((fun j k => sourceRows b j k),H),I) ξ i j| ≤
      2*BH*((q : ℝ)+1)+2*BG :=
  sharpSourceRowsDraw_bounded hN hq hm _ (sourceRows_trace b hN) H I ξ ht hBH hBG i j

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
