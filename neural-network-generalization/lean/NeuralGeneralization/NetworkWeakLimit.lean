import NeuralGeneralization.NetworkOutputLaw
import NeuralGeneralization.NetworkGramConcentration
import NeuralGeneralization.WalshGaussianLaw
import NeuralGeneralization.VaryingProbabilityLimit
import Mathlib.MeasureTheory.Measure.LevyConvergence

/-! The normalized output of the actual neural network converges weakly to
the explicit iterated-arcsine Gaussian field at every exponent gamma < 1. -/
noncomputable section
open MeasureTheory ProbabilityTheory Filter
open scoped Topology

namespace NeuralGeneralization.NetworkWeakLimit
open ConcreteModel NetworkOutputLaw NetworkGramConcentration

theorem covarianceChar_probability_tendsto_zero {d : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 1) (t : EuclideanSpace ℝ (Cube d))
    {ε : ℝ} (hε : 0 < ε) :
    Tendsto (fun N : ℕ => (powerPrior d N r γ).real
      {w | ε ≤ ‖covarianceChar (finalCovariance Real.tanh w) t -
        covarianceChar (arcsineCovariance d (r + 1)) t‖}) atTop (𝓝 (0 : ℝ)) := by
  obtain ⟨δ, hδ, hnear⟩ := Metric.continuousAt_iff.mp
    (continuous_covarianceChar t).continuousAt ε hε
  have hsub (N : ℕ) :
      {w : Weights d N r | ε ≤ ‖covarianceChar (finalCovariance Real.tanh w) t -
        covarianceChar (arcsineCovariance d (r + 1)) t‖} ⊆
      gramBad (arcsineCovariance d (r + 1)) δ := by
    intro w hw
    by_contra hn
    have hg := (not_mem_gramBad _ _ w).mp hn
    have hdist : dist (finalCovariance Real.tanh w) (arcsineCovariance d (r + 1)) < δ := by
      apply (dist_pi_lt_iff hδ).mpr
      intro x
      apply (dist_pi_lt_iff hδ).mpr
      intro y
      simpa only [Real.dist_eq] using hg x y
    have hh := hnear hdist
    rw [dist_eq_norm] at hh
    exact (not_lt_of_ge hw) hh
  exact squeeze_zero (fun _ => measureReal_nonneg)
    (fun N => measureReal_mono (hsub N))
    (actual_gram_bad_probability_tendsto_zero hd r hγ hδ)

theorem charFun_tendsto {d : ℕ} (hd : 0 < d) (r : ℕ) {γ : ℝ} (hγ : γ < 1)
    (t : EuclideanSpace ℝ (Cube d)) :
    Tendsto (fun N => charFun (NetworkOutputLaw.law d N r Real.tanh γ) t)
      atTop (𝓝 (charFun (WalshGaussianLaw.arcsineLaw d r) t)) := by
  rw [WalshGaussianLaw.charFun_arcsineLaw]
  have hm (N : ℕ) : StronglyMeasurable (fun w : Weights d N r =>
      covarianceChar (finalCovariance Real.tanh w) t) :=
    ((continuous_covarianceChar t).comp
      (NetworkOutputLaw.continuous_finalCovariance tanh_lipschitzWith.continuous)).stronglyMeasurable
  have hh := tendsto_integral_of_varying_probability (fun N => powerPrior d N r γ)
    (fun N w => covarianceChar (finalCovariance Real.tanh w) t)
    (covarianceChar (arcsineCovariance d (r + 1)) t) 1 (by norm_num) hm
    (fun N w => covarianceChar_final_norm_le_one Real.tanh w t)
    (fun ε hε => covarianceChar_probability_tendsto_zero hd r hγ t hε)
  apply hh.congr'
  filter_upwards [eventually_gt_atTop (0 : ℕ)] with N hN
  exact (charFun_law hN tanh_lipschitzWith.continuous γ t).symm

def outputProbability (d N r : ℕ) (γ : ℝ) : ProbabilityMeasure (EuclideanSpace ℝ (Cube d)) :=
  ⟨NetworkOutputLaw.law d N r Real.tanh γ,
    law_probability tanh_lipschitzWith.continuous d N r γ⟩

def arcsineProbability (d r : ℕ) : ProbabilityMeasure (EuclideanSpace ℝ (Cube d)) :=
  ⟨WalshGaussianLaw.arcsineLaw d r, inferInstance⟩

/-- Weak convergence is a theorem about the actual product-prior network,
not a Gaussian approximation supplied as an assumption. -/
theorem actual_network_weak_limit {d : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 1) :
    Tendsto (fun N => outputProbability d N r γ) atTop (𝓝 (arcsineProbability d r)) := by
  apply ProbabilityMeasure.tendsto_of_tendsto_charFun
  exact charFun_tendsto hd r hγ

end NeuralGeneralization.NetworkWeakLimit
