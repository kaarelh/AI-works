import NeuralGeneralization.BatchTwoImprovedCoefficientBounds
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

theorem importance_active_coefficient_bound_manuscript (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (htrace : ∑ j, rowEnergy u j ≤ (N : ℝ)*q)
    {BH : ℝ} (hBH : 0 ≤ BH) (H : EuclideanSpace ℝ (Fin q)) (j : Fin N) :
    |sourceMultiplier u j * linearEvaluation (u j) (fun k => wholeClip BH H k)| ≤
      2*BH*Real.sqrt ((q : ℝ)+1) := by
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
  have hqbound : 4*(q : ℝ)*BH^2 ≤ (2*BH*Real.sqrt ((q : ℝ)+1))^2 := by
    rw [mul_pow,mul_pow,Real.sq_sqrt (by positivity : 0≤(q:ℝ)+1)]
    nlinarith [sq_nonneg BH]
  apply (sq_le_sq₀ (abs_nonneg _) (by positivity : 0 ≤ 2*BH*Real.sqrt ((q : ℝ)+1))).mp
  simpa only [sq_abs] using hsq.trans hqbound

theorem sharpSourceRowsDraw_bounded_manuscript (hN : 0<N) (hq : 0<q) (hm : 0<m)
    (u : Fin N→Fin q→ℝ) (htrace : ∑j,rowEnergy u j≤(N:ℝ)*q)
    (H : Fin D→EuclideanSpace ℝ (Fin q)) (I : Fin m→Fin N)
    (ξ : Fin D→Fin m→ℝ) {t BH BG : ℝ}
    (ht : |t|≤1) (hBH : 0≤BH) (hBG : 0≤BG) (i : Fin D) (j : Fin m) :
    |sharpSourceRowsDraw t BH BG ((u,H),I) ξ i j|≤
      2*BH*Real.sqrt ((q:ℝ)+1)/(m:ℝ)+Real.sqrt 2*BG/Real.sqrt (m:ℝ) := by
  have hm0 : (0:ℝ)<m := Nat.cast_pos.mpr hm
  have htm : |t/Real.sqrt (m:ℝ)|≤1/Real.sqrt (m:ℝ) := by
    rw [abs_div,abs_of_nonneg (Real.sqrt_nonneg _)]
    exact div_le_div_of_nonneg_right ht (Real.sqrt_nonneg _)
  have hsa : Real.sqrt (sourceMultiplier u (I j))≤Real.sqrt 2 :=
    Real.sqrt_le_sqrt (sourceMultiplier_le_two hN hq u htrace (I j))
  have hb := importance_active_coefficient_bound_manuscript hN hq u htrace hBH (H i) (I j)
  have hactive : |sourceMultiplier u (I j)/(m:ℝ)*
      linearEvaluation (u (I j)) (fun k=>wholeClip BH (H i) k)|≤
        2*BH*Real.sqrt ((q:ℝ)+1)/(m:ℝ) := by
    rw [div_mul_eq_mul_div,abs_div,abs_of_nonneg hm0.le]
    exact div_le_div_of_nonneg_right hb hm0.le
  have hgaussian : |t/Real.sqrt (m:ℝ)*Real.sqrt (sourceMultiplier u (I j))*gaussianClip BG (ξ i j)|≤
      Real.sqrt 2*BG/Real.sqrt (m:ℝ) := by
    rw [abs_mul,abs_mul,abs_of_nonneg (Real.sqrt_nonneg _)]
    have hp := mul_le_mul htm hsa (Real.sqrt_nonneg _) (by positivity : 0≤1/Real.sqrt (m:ℝ))
    have hh := mul_le_mul hp (gaussianClip_abs_le hBG (ξ i j)) (abs_nonneg _) (by positivity)
    exact hh.trans_eq (by ring)
  exact (abs_add_le _ _).trans (add_le_add hactive hgaussian)

theorem sharpSourceRowsDraw_sourceRows_bounded_manuscript (hN : 0<N) (hq : 0<q) (hm : 0<m)
    (b : Fin q→EuclideanSpace ℝ (Fin N))
    (H : Fin D→EuclideanSpace ℝ (Fin q)) (I : Fin m→Fin N)
    (ξ : Fin D→Fin m→ℝ) {t BH BG : ℝ}
    (ht : |t|≤1) (hBH : 0≤BH) (hBG : 0≤BG) (i : Fin D) (j : Fin m) :
    |sharpSourceRowsDraw t BH BG (((fun j k=>sourceRows b j k),H),I) ξ i j|≤
      2*BH*Real.sqrt ((q:ℝ)+1)/(m:ℝ)+Real.sqrt 2*BG/Real.sqrt (m:ℝ) :=
  sharpSourceRowsDraw_bounded_manuscript hN hq hm _ (sourceRows_trace b hN) H I ξ ht hBH hBG i j

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
