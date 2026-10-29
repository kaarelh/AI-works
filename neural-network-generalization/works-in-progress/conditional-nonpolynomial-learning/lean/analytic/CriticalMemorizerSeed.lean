import RareSeedState
import TargetProgramLogarithms

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory
open scoped NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization

theorem calibrated_score_polynomial {D H R : ℝ} (hD : 0 ≤ D) (hH : 1 ≤ H)
    (hR : 2 ≤ R) (hDR : D+1 ≤ R^12) (hHR : H ≤ R) :
    1/Real.sqrt (rareCalibration D H) ≤ R^13 := by
  have hb := rareCalibration_bounds hD hH
  have hs : rareCalibration D H ≤ Real.sqrt (rareCalibration D H) := by
    apply (sq_le_sq₀ hb.1.le (Real.sqrt_nonneg _)).mp
    rw [Real.sq_sqrt hb.1.le]
    nlinarith
  have hi := one_div_le_one_div_of_le hb.1 hs
  have he : 1/rareCalibration D H=(D+1)*H := by rw [rareCalibration,one_div_one_div]
  rw [he] at hi
  have hm := mul_le_mul hDR hHR (by linarith : 0 ≤ H) (by positivity : 0 ≤ R^12)
  have hp : R^12*R=R^13 := by ring
  rw [hp] at hm
  exact hi.trans hm

theorem signal_lower_log_budget {v R : ℝ} (hv : 0 < v) (hR : 2 ≤ R)
    (hfloor : 1/R^23 ≤ v) (H : ℕ) (hHR : (H : ℝ)+1 ≤ R) :
    targetLogBudget v H ≤ 26*Real.log R := by
  have hR0 : 0 < R := by linarith
  have hp : 0 < R^23 := pow_pos hR0 _
  have hm := (div_le_iff₀ hp).mp hfloor
  have hi : 1/v ≤ R^23 := (div_le_iff₀ hv).mpr (by nlinarith)
  have hl := Real.log_le_log (one_div_pos.mpr hv) hi
  rw [Real.log_pow] at hl
  norm_num at hl
  have hHlog := Real.log_le_log (by positivity : 0 < (H : ℝ)+1) hHR
  have htwo := Real.le_log_one_add_of_nonneg (show (0 : ℝ) ≤ 1 by norm_num)
  norm_num at htwo
  have hlogR := Real.log_le_log (by norm_num : (0 : ℝ) < 2) hR
  unfold targetLogBudget
  simp only [one_div,Real.log_inv]
  linarith

theorem critical_memorizer_seed_state {d n H : ℕ}
    (sample : Fin n → ClippingCube d) (f : ClippingCube d → Bool)
    (hd : 1 ≤ d) (hH : 1 ≤ H) {R : ℝ} (hR : 2 ≤ R)
    (hdR : (d : ℝ)+1 ≤ R) (hnR : (n : ℝ) ≤ R) (hHR : (H : ℝ)+1 ≤ R) :
    let g := pointExceptionFunction (negativeSamplePoints sample f)
    let σ := 1/Real.sqrt d
    let θ := rareCalibration (seedEntropyBudget d σ) H
    let v := rareSeedSignal g σ θ
    let r := rareSeedResidual g σ θ
    0 < θ ∧ θ ≤ 1 ∧ 0 < v ∧ 0 ≤ r ∧ v+r ≤ 1 ∧
      1/R^23 ≤ v ∧ targetLogBudget v H ≤ 26*Real.log R ∧
      ∀ z : Bool×(Option (Fin d)→ℝ), |rareSeedScore θ z| ≤ R^13 := by
  let g := pointExceptionFunction (negativeSamplePoints sample f)
  let σ := 1/Real.sqrt d
  let D := seedEntropyBudget d σ
  let θ := rareCalibration D H
  let v := rareSeedSignal g σ θ
  let r := rareSeedResidual g σ θ
  have hHreal : (1 : ℝ) ≤ H := by exact_mod_cast hH
  have hσ : ((d : ℝ)+1)*σ^2 ≤ 2 := originalScale_noise_variance hd 1 (by norm_num) (by norm_num)
  have hf : ∃ x,g x ≠ 0 := sampleMemorizer_nonzero sample f
  have hb : ∀ x,(g x)^2=1 := by
    intro x
    rcases pointExceptionFunction_boolean (negativeSamplePoints sample f) x with hh|hh <;>
      dsimp only [g] <;> rw [hh] <;> norm_num
  have hcal := rareCalibration_bounds (seedEntropyBudget_nonneg d σ) hHreal
  have hv : 0 < v := rareSeedSignal_pos g σ θ hf hσ hcal.1
  have hr : 0 ≤ r := rareSeedResidual_nonneg g σ θ hf hb hσ hcal.1 hcal.2.1
  have htotal : v+r ≤ 1 := rareSeedState_total_le g σ θ hf hσ hcal.1.le hcal.2.1
  have hDpoly : D+1 ≤ R^12 := critical_seed_entropy_polynomial hd hR hdR
  have hZpoly := memorizer_seed_normalizer_polynomial sample f hd hR hdR hnR
  have hZpos := fourierSeedNormalizer_pos g σ hf hσ
  have hfloor : 1/R^23 ≤ v := calibrated_seed_signal_polynomial
    (seedEntropyBudget_nonneg d σ) hHreal hZpos hR hDpoly (by linarith : (H : ℝ) ≤ R) hZpoly
  refine ⟨hcal.1,hcal.2.1,hv,hr,htotal,hfloor,signal_lower_log_budget hv hR hfloor H hHR,?_⟩
  intro z
  exact (rareSeedScore_bound θ hcal.1 z).trans
    (calibrated_score_polynomial (seedEntropyBudget_nonneg d σ) hHreal hR hDpoly (by linarith))

#print axioms critical_memorizer_seed_state
end ConditionalNonpolynomial.Analytic
