import CriticalMemorizerSeed

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory
open scoped NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization

theorem memorizer_seed_normalizer_uniform_polynomial {d n : ℕ} (sample : Fin n → ClippingCube d)
    (f : ClippingCube d → Bool) (σ : ℝ) (hσ : ((d:ℝ)+1)*σ^2≤2) {R : ℝ} (hR : 2 ≤ R)
    (hdR : (d : ℝ)+1 ≤ R) (hnR : (n : ℝ) ≤ R) :
    fourierSeedNormalizer (pointExceptionFunction (negativeSamplePoints sample f)) σ ≤ R^5 := by
  have hz := sampleMemorizer_fourierSeedNormalizer_le sample f σ hσ
  have hn : 1+2*(n : ℝ) ≤ 3*R := by linarith
  have hmul := mul_le_mul hdR hn (by positivity : (0 : ℝ) ≤ 1+2*(n : ℝ)) (by linarith : 0 ≤ R)
  have hpow := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 2) hR 3
  norm_num at hpow
  have hprod := mul_le_mul_of_nonneg_right hpow (sq_nonneg R)
  have he : R^3*R^2=R^5 := by ring
  rw [he] at hprod
  nlinarith [sq_nonneg R]

theorem uniform_memorizer_seed_state {d n H : ℕ}
    (sample : Fin n → ClippingCube d) (f : ClippingCube d → Bool)
    (hd : 1 ≤ d) (hH : 1 ≤ H) (t : ℝ) (ht : 0<t) (ht1 : t≤1) {R : ℝ} (hR : 2 ≤ R)
    (hdR : (d : ℝ)+1 ≤ R) (hnR : (n : ℝ) ≤ R) (hHR : (H : ℝ)+1 ≤ R) :
    let g := pointExceptionFunction (negativeSamplePoints sample f)
    let σ := t/Real.sqrt d
    let θ := rareCalibration (seedEntropyBudget d (1/Real.sqrt d)) H
    let v := rareSeedSignal g σ θ
    let r := rareSeedResidual g σ θ
    0 < θ ∧ θ ≤ 1 ∧ 0 < v ∧ 0 ≤ r ∧ v+r ≤ 1 ∧
      1/R^23 ≤ v ∧ targetLogBudget v H ≤ 26*Real.log R ∧
      ∀ z : Bool×(Option (Fin d)→ℝ), |rareSeedScore θ z| ≤ R^13 := by
  let g := pointExceptionFunction (negativeSamplePoints sample f)
  let σ := t/Real.sqrt d
  let D := seedEntropyBudget d (1/Real.sqrt d)
  let θ := rareCalibration D H
  let v := rareSeedSignal g σ θ
  let r := rareSeedResidual g σ θ
  have hHreal : (1 : ℝ) ≤ H := by exact_mod_cast hH
  have hσ : ((d : ℝ)+1)*σ^2 ≤ 2 := originalScale_noise_variance hd t ht.le ht1
  have hf : ∃ x,g x ≠ 0 := sampleMemorizer_nonzero sample f
  have hb : ∀ x,(g x)^2=1 := by
    intro x
    rcases pointExceptionFunction_boolean (negativeSamplePoints sample f) x with hh|hh <;>
      dsimp only [g] <;> rw [hh] <;> norm_num
  have hcal := rareCalibration_bounds (seedEntropyBudget_nonneg d (1/Real.sqrt d)) hHreal
  have hv : 0 < v := rareSeedSignal_pos g σ θ hf hσ hcal.1
  have hr : 0 ≤ r := rareSeedResidual_nonneg g σ θ hf hb hσ hcal.1 hcal.2.1
  have htotal : v+r ≤ 1 := rareSeedState_total_le g σ θ hf hσ hcal.1.le hcal.2.1
  have hDpoly : D+1 ≤ R^12 := critical_seed_entropy_polynomial hd hR hdR
  have hZpoly := memorizer_seed_normalizer_uniform_polynomial sample f σ hσ hR hdR hnR
  have hZpos := fourierSeedNormalizer_pos g σ hf hσ
  have hfloor : 1/R^23 ≤ v := calibrated_seed_signal_polynomial
    (seedEntropyBudget_nonneg d (1/Real.sqrt d)) hHreal hZpos hR hDpoly (by linarith : (H : ℝ) ≤ R) hZpoly
  refine ⟨hcal.1,hcal.2.1,hv,hr,htotal,hfloor,signal_lower_log_budget hv hR hfloor H hHR,?_⟩
  intro z
  exact (rareSeedScore_bound θ hcal.1 z).trans
    (calibrated_score_polynomial (seedEntropyBudget_nonneg d (1/Real.sqrt d)) hHreal hR hDpoly (by linarith))

#print axioms uniform_memorizer_seed_state
end ConditionalNonpolynomial.Analytic
