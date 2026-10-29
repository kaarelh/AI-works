import RareSeedCalibration
import UniformChannelReference

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization

theorem seedEntropyBudget_uniform {d : ℕ} (hd : 1≤d) {t : ℝ} (ht : 0<t) :
    t^2*seedEntropyBudget d (t/Real.sqrt d)=seedEntropyBudget d (1/Real.sqrt d) := by
  have hd0 : (0:ℝ)<d := by exact_mod_cast (show 0<d by omega)
  rw [seedEntropyBudget_critical d hd]
  unfold seedEntropyBudget
  rw [div_pow,Real.sq_sqrt hd0.le]
  field_simp

theorem calibrated_uniform_seed_cost {d : ℕ} (hd : 1≤d) {t H : ℝ}
    (ht : 0<t) (hH : 1≤H) :
    let θ := rareCalibration (seedEntropyBudget d (1/Real.sqrt d)) H
    t^2*(θ*seedEntropyBudget d (t/Real.sqrt d))≤1/H := by
  dsimp only
  have he := seedEntropyBudget_uniform hd ht
  have hb := (rareCalibration_bounds (seedEntropyBudget_nonneg d (1/Real.sqrt d)) hH).2.2
  calc
    _ = rareCalibration (seedEntropyBudget d (1/Real.sqrt d)) H*
        (t^2*seedEntropyBudget d (t/Real.sqrt d)) := by ring
    _ ≤ _ := by rwa [he]

/-- Fixed tagging probability, independent of t, retains a uniform normalized
entropy bound for the literal physical first-layer prior. -/
theorem calibrated_uniform_rareFourierSeed_kl {d : ℕ} (hd : 1≤d)
    (f : ClippingCube d→ℝ) (hf : ∃x,f x≠0) {t H : ℝ}
    (ht : 0<t) (ht1 : t≤1) (hH : 1≤H) :
    let σ := t/Real.sqrt d
    let θ := rareCalibration (seedEntropyBudget d (1/Real.sqrt d)) H
    let Q := rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ)
    let P := rareSeedLaw θ (seedGaussianReference σ) (seedGaussianReference σ)
    klDiv Q P≠∞ ∧ t^2*(klDiv Q P).toReal≤1/H := by
  dsimp only
  let θ := rareCalibration (seedEntropyBudget d (1/Real.sqrt d)) H
  have hb := rareCalibration_bounds (seedEntropyBudget_nonneg d (1/Real.sqrt d)) hH
  have hd0 : (0:ℝ)<d := by exact_mod_cast (show 0<d by omega)
  have hσ0 : t/Real.sqrt d≠0 := by positivity
  have hσ := originalScale_noise_variance hd t ht.le ht1
  have hkl := rareFourierSeed_kl_bound f (t/Real.sqrt d) θ hf hσ0 hσ hb.1.le hb.2.1
  have hfinite := ne_top_of_le_ne_top ENNReal.ofReal_ne_top hkl
  refine ⟨hfinite,?_⟩
  have hh := ENNReal.toReal_mono ENNReal.ofReal_ne_top hkl
  rw [ENNReal.toReal_ofReal (mul_nonneg hb.1.le (seedEntropyBudget_nonneg d _))] at hh
  exact (mul_le_mul_of_nonneg_left hh (sq_nonneg t)).trans (calibrated_uniform_seed_cost hd ht hH)

#print axioms calibrated_uniform_rareFourierSeed_kl
end ConditionalNonpolynomial.Analytic
