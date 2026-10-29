import GaussianFourierSeedKL

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization

def rareCalibration (D H : ℝ) : ℝ := 1/((D+1)*H)

theorem rareCalibration_bounds {D H : ℝ} (hD : 0 ≤ D) (hH : 1 ≤ H) :
    0 < rareCalibration D H ∧ rareCalibration D H ≤ 1 ∧ rareCalibration D H*D ≤ 1/H := by
  have hp : 0 < (D+1)*H := by positivity
  have hH0 : 0 < H := by linarith
  refine ⟨one_div_pos.mpr hp,?_,?_⟩
  · apply (div_le_one hp).mpr
    nlinarith
  · unfold rareCalibration
    have he : 1/((D+1)*H)*D=(D/(D+1))/H := by field_simp
    rw [he]
    apply div_le_div_of_nonneg_right _ hH0.le
    exact (div_le_one (by positivity : 0 < D+1)).mpr (by linarith)

theorem calibrated_rareFourierSeed_kl (f : ClippingCube d → ℝ) (σ H : ℝ)
    (hf : ∃ x,f x ≠ 0) (hσ0 : σ ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) (hH : 1 ≤ H) :
    let θ := rareCalibration (seedEntropyBudget d σ) H
    klDiv (rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ))
      (rareSeedLaw θ (seedGaussianReference σ) (seedGaussianReference σ)) ≠ ∞ ∧
    (klDiv (rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ))
      (rareSeedLaw θ (seedGaussianReference σ) (seedGaussianReference σ))).toReal ≤ 1/H := by
  dsimp only
  let θ := rareCalibration (seedEntropyBudget d σ) H
  have hb := rareCalibration_bounds (seedEntropyBudget_nonneg d σ) hH
  have hkl := rareFourierSeed_kl_bound f σ θ hf hσ0 hσ hb.1.le hb.2.1
  have hupper := hkl.trans (ENNReal.ofReal_le_ofReal hb.2.2)
  have hfinite := ne_top_of_le_ne_top ENNReal.ofReal_ne_top hupper
  refine ⟨hfinite,?_⟩
  have hh := ENNReal.toReal_mono ENNReal.ofReal_ne_top hupper
  rwa [ENNReal.toReal_ofReal (by positivity : 0 ≤ 1/H)] at hh

theorem seedEntropyBudget_critical (d : ℕ) (hd : 1 ≤ d) :
    seedEntropyBudget d (1/Real.sqrt d)=64*(d : ℝ)*((d : ℝ)+1)^4 := by
  have hd0 : (0 : ℝ) < d := by exact_mod_cast (show 0 < d by omega)
  unfold seedEntropyBudget
  rw [div_pow,Real.sq_sqrt hd0.le,one_pow]
  field_simp

theorem critical_seed_entropy_polynomial {d : ℕ} (hd : 1 ≤ d) {R : ℝ}
    (hR : 2 ≤ R) (hdR : (d : ℝ)+1 ≤ R) :
    seedEntropyBudget d (1/Real.sqrt d)+1 ≤ R^12 := by
  rw [seedEntropyBudget_critical d hd]
  have hd0 : (0 : ℝ) ≤ d := Nat.cast_nonneg _
  have hR0 : 0 ≤ R := by linarith
  have hdR' : (d : ℝ) ≤ R := by linarith
  have hpow := pow_le_pow_left₀ (show (0 : ℝ) ≤ (d : ℝ)+1 by positivity) hdR 4
  have hmul := mul_le_mul hdR' hpow (by positivity : 0 ≤ ((d : ℝ)+1)^4) hR0
  have htwo := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 2) hR 6
  norm_num at htwo
  have hprod := mul_le_mul_of_nonneg_right htwo (pow_nonneg hR0 5)
  have he11 : R^6*R^5=R^11 := by ring
  rw [he11] at hprod
  have hbase : 64*(d : ℝ)*((d : ℝ)+1)^4 ≤ R^11 := by nlinarith
  have hone : (1 : ℝ) ≤ R^11 := one_le_pow₀ (by linarith)
  have hstep := mul_le_mul_of_nonneg_right hR (pow_nonneg hR0 11)
  have he12 : R*R^11=R^12 := by ring
  rw [he12] at hstep
  nlinarith

theorem memorizer_seed_normalizer_polynomial {d n : ℕ} (sample : Fin n → ClippingCube d)
    (f : ClippingCube d → Bool) (hd : 1 ≤ d) {R : ℝ} (hR : 2 ≤ R)
    (hdR : (d : ℝ)+1 ≤ R) (hnR : (n : ℝ) ≤ R) :
    fourierSeedNormalizer (pointExceptionFunction (negativeSamplePoints sample f)) (1/Real.sqrt d) ≤ R^5 := by
  have hs := originalScale_noise_variance hd 1 (by norm_num) (by norm_num)
  have hz := sampleMemorizer_fourierSeedNormalizer_le sample f (1/Real.sqrt d) hs
  have hn : 1+2*(n : ℝ) ≤ 3*R := by linarith
  have hmul := mul_le_mul hdR hn (by positivity : (0 : ℝ) ≤ 1+2*(n : ℝ)) (by linarith : 0 ≤ R)
  have hpow := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 2) hR 3
  norm_num at hpow
  have hprod := mul_le_mul_of_nonneg_right hpow (sq_nonneg R)
  have he : R^3*R^2=R^5 := by ring
  rw [he] at hprod
  nlinarith [sq_nonneg R]

theorem calibrated_seed_signal_polynomial {D H Z R : ℝ}
    (hD : 0 ≤ D) (hH : 1 ≤ H) (hZ : 0 < Z) (hR : 2 ≤ R)
    (hDR : D+1 ≤ R^12) (hHR : H ≤ R) (hZR : Z ≤ R^5) :
    1/R^23 ≤ rareCalibration D H/Z^2 := by
  have hD1 : 0 < D+1 := by positivity
  have hH0 : 0 < H := by linarith
  have hR0 : 0 < R := by linarith
  have hpair := mul_le_mul hDR hHR hH0.le (pow_nonneg hR0.le 12)
  have hZsq := pow_le_pow_left₀ hZ.le hZR 2
  have hproduct := mul_le_mul hpair hZsq (sq_nonneg Z)
    (mul_nonneg (pow_nonneg hR0.le 12) hR0.le)
  have hden : (D+1)*H*Z^2 ≤ R^23 := by nlinarith only [hproduct]
  have hh := one_div_le_one_div_of_le (by positivity : 0 < (D+1)*H*Z^2) hden
  have he : rareCalibration D H/Z^2=1/((D+1)*H*Z^2) := by
    rw [rareCalibration,div_div]
  rwa [he]

#print axioms calibrated_rareFourierSeed_kl
#print axioms calibrated_seed_signal_polynomial
end ConditionalNonpolynomial.Analytic
