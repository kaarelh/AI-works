import NeuralGeneralization.BatchTwoMergingGaussian
import NeuralGeneralization.NetworkCylinderScaling
import NeuralGeneralization.Activation
import Mathlib.Analysis.Real.Pi.Bounds

/-! Sharp logarithmic target-cylinder mass and shallow deterministic stability. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel

def coordinateCylinder {d N : ℕ} (v : Weights d N 0) (ρ σ : ℝ) : Set (Weights d N 0) :=
  {w | ∀ q, |whiten w q - whiten v q| ≤ ρ*σ}

theorem coordinateCylinder_eq {d N : ℕ} (v : Weights d N 0) (ρ σ : ℝ) :
    coordinateCylinder v ρ σ = whiten ⁻¹'
      Set.pi Set.univ (fun q => Icc (whiten v q-ρ*σ) (whiten v q+ρ*σ)) := by
  ext w
  simp only [coordinateCylinder, mem_setOf_eq, mem_preimage, mem_pi, mem_univ,
    forall_const, mem_Icc, abs_le]
  constructor <;> intro h q <;> constructor <;> linarith [(h q).1, (h q).2]

theorem measurable_coordinateCylinder {d N : ℕ} (v : Weights d N 0) (ρ σ : ℝ) :
    MeasurableSet (coordinateCylinder v ρ σ) := by
  rw [coordinateCylinder_eq]
  exact (MeasurableSet.univ_pi (fun _ => measurableSet_Icc)).preimage
    (continuous_whiten d N 0).measurable

theorem coordinateCylinder_mass {d N : ℕ} (hd : 0 < d) (hN : 0 < N)
    (v : Weights d N 0) {ρ σ K : ℝ} (hρ : 0 < ρ) (hρ1 : ρ ≤ 1/4)
    (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1)
    (hcost : weightedSquaredNorm v ≤ K) :
    Real.exp (-(K+((d : ℝ)+2)*(1-Real.log (2*ρ/Real.sqrt (2*Real.pi))))/σ^2) ≤
      (smallPrior d N 0 σ).real (coordinateCylinder v ρ σ) := by
  have hm := BatchTwoMerging.gaussian_scaled_rectangle_log_lower (whiten v) ρ σ hρ hσ
  rw [← map_smallPrior_whiten hd hN hσ] at hm
  rw [Measure.real, Measure.map_apply (continuous_whiten d N 0).measurable
    (MeasurableSet.univ_pi (fun _ => measurableSet_Icc)), ← coordinateCylinder_eq] at hm
  have he : ∑ q, (whiten v q)^2 = weightedSquaredNorm v := by
    rw [← weightedSquaredNorm_unwhiten hd hN, unwhiten_whiten hd hN]
  rw [he] at hm
  have hdim : (Fintype.card (WeightIndex d N 0) : ℝ) = (N : ℝ)*(d+2) := by
    simp only [WeightIndex, Fintype.card_sum, Fintype.card_prod, Fintype.card_fin]
    push_cast
    ring
  rw [hdim] at hm
  have hsqrt : (1 : ℝ) ≤ Real.sqrt (2*Real.pi) := by
    apply (Real.le_sqrt (by norm_num) (by positivity)).mpr
    nlinarith [Real.pi_gt_three]
  have hratio : 2*ρ/Real.sqrt (2*Real.pi) ≤ 1 := by
    apply (div_le_one (by positivity)).mpr
    linarith
  have hlog : Real.log (2*ρ/Real.sqrt (2*Real.pi)) ≤ 0 :=
    Real.log_nonpos (by positivity) hratio
  have hρsq : ρ^2 ≤ 1 := by nlinarith
  have hk : 0 ≤ 1-Real.log (2*ρ/Real.sqrt (2*Real.pi)) := by linarith
  have hdimscale : ((N : ℝ)*(d+2))*σ^2 ≤ (d : ℝ)+2 := by
    nlinarith [mul_le_mul_of_nonneg_left hscale (show (0 : ℝ) ≤ d+2 by positivity)]
  have hexp : -(K+((d : ℝ)+2)*(1-Real.log (2*ρ/Real.sqrt (2*Real.pi))))/σ^2 ≤
      -weightedSquaredNorm v/σ^2 - ((N : ℝ)*(d+2))*(ρ^2-Real.log (2*ρ/Real.sqrt (2*Real.pi))) := by
    apply (div_le_iff₀ (sq_pos_of_pos hσ)).mpr
    have hh := mul_le_mul_of_nonneg_right hdimscale hk
    have hρterm := mul_le_mul_of_nonneg_left hρsq
      (show (0 : ℝ) ≤ (N : ℝ)*(d+2)*σ^2 by positivity)
    rw [sub_mul, div_mul_cancel₀ _ (sq_pos_of_pos hσ).ne']
    nlinarith
  exact (Real.exp_le_exp.mpr hexp).trans hm

theorem input_error_sharp {d N : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ ρ : ℝ} (hσ : 0 ≤ σ) (hρ : 0 ≤ ρ) (hscale : (N : ℝ)*σ^2 ≤ 1)
    (w v : Weights d N 0) (i : Fin N) (j : Fin (d+1))
    (h : |whiten w (Sum.inl (i,j))-whiten v (Sum.inl (i,j))| ≤ ρ*σ) :
    |w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ ρ/Real.sqrt d := by
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have hsqrt : 0 < Real.sqrt (d : ℝ) := Real.sqrt_pos.mpr hdR
  have hpos := (coordinateScale_pos (r := 0) hd hN (Sum.inl (i,j))).le
  have hsq := coordinateScale_sq (r := 0) hd hN (Sum.inl (i,j))
  simp only [smallVariance, one_pow, mul_one] at hsq
  have hs : coordinateScale d N 0 (Sum.inl (i,j))*σ ≤ 1/Real.sqrt d := by
    apply (sq_le_sq₀ (mul_nonneg hpos hσ) (by positivity : (0 : ℝ) ≤ 1/Real.sqrt d)).mp
    rw [mul_pow, hsq, div_pow, one_pow, Real.sq_sqrt hdR.le]
    apply (le_div_iff₀ hdR).mpr
    have hc : ((N : ℝ)/d*σ^2)*(d : ℝ) = (N : ℝ)*σ^2 := by field_simp
    rw [hc]
    exact hscale
  have hh := coordinate_error_of_whitened hd hN w v (Sum.inl (i,j)) (ρ*σ) h
  have hm := mul_le_mul_of_nonneg_left hs hρ
  exact hh.trans (by simpa only [one_div, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, one_mul] using hm)

end NeuralGeneralization.BatchTwoShallow
