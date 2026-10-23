import NeuralGeneralization.BatchTwoContinuousDepthPairRisk
import NeuralGeneralization.BatchTwoContinuousPairTailDecay
import NeuralGeneralization.GaussianModelRate
import Mathlib.Topology.Order.LiminfLimsup

/-! The width-first mean-field posterior conclusion from a low-cost training
event. The input-pair numerator is proved directly for the actual network.
The remaining denominator premise is isolated for the controlled-network
construction, not asserted as an axiom or hidden inside the final statement. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter
open scoped Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

def criticalPosterior {r n : ℕ} (s : Fin n → RealInput 2) (N : ℕ) : Measure (Weights 2 N r) :=
  BatchTwoContinuous.posterior Real.tanh (powerPrior 2 N r 1) (depthTarget (r+1)) (1/8) s

theorem critical_prior_pair_tail {N r : ℕ} (hN : 0 < N) (hr : 12 ≤ r+1) (ω : SignStream) :
    (powerPrior 2 N r 1).real {w | (1/2 : ℝ) ≤
      |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate (r+1) ω))|} ≤
      Real.exp (-((r : ℝ)+1)*(N : ℝ)/2) := by
  have hNR : (0 : ℝ)<N := by exact_mod_cast hN
  rw [powerPrior_eq_smallPrior hN,Real.rpow_neg_one]
  apply meanfield_paired_input_tail hN hr (Real.sqrt_pos.mpr (inv_pos.mpr hNR))
  rw [Real.sq_sqrt (inv_nonneg.mpr hNR.le),mul_inv_cancel₀ hNR.ne']

theorem critical_posterior_pair_tail {N r n : ℕ} (hN : 0 < N) (hr : 12 ≤ r+1)
    (s : Fin n → RealInput 2)
    (hden : Real.exp (-((r : ℝ)+1)*(N : ℝ)/4) ≤
      (powerPrior 2 N r 1).real (trainingEvent Real.tanh (depthTarget (r+1)) (1/8) s)) :
    IsProbabilityMeasure (criticalPosterior (r := r) s N) ∧
    ∀ ω, (criticalPosterior (r := r) s N).real {w | (1/2 : ℝ) ≤
      |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate (r+1) ω))|} ≤
      Real.exp (-((r : ℝ)+1)*(N : ℝ)/4) := by
  let μ := powerPrior 2 N r 1
  let V := trainingEvent (N := N) (r := r) Real.tanh (depthTarget (r+1)) (1/8) s
  have hpos : 0<μ.real V := (Real.exp_pos _).trans_le hden
  have hne : μ V≠0 := by
    intro hz
    simp only [Measure.real,hz,ENNReal.toReal_zero] at hpos
    exact hpos.false
  refine ⟨cond_isProbabilityMeasure hne,?_⟩
  intro ω
  have hnum := critical_prior_pair_tail hN hr ω
  have hratio := RobustPosterior.cond_real_le_ratio μ V
    {w | (1/2 : ℝ) ≤ |output Real.tanh w (sphereCoding ω)-
      output Real.tanh w (sphereCoding (flipCoordinate (r+1) ω))|}
    (isOpen_trainingEvent tanh_continuous _ _ s).measurableSet
  apply hratio.trans
  have hh := div_le_div₀ (Real.exp_nonneg _) hnum (Real.exp_pos _) hden
  apply hh.trans_eq
  rw [←Real.exp_sub]
  congr 1
  ring

theorem critical_posterior_risk_from_mass {N r n : ℕ} (hN : 0 < N) (hr : 12 ≤ r+1)
    (s : Fin n → RealInput 2)
    (hden : Real.exp (-((r : ℝ)+1)*(N : ℝ)/4) ≤
      (powerPrior 2 N r 1).real (trainingEvent Real.tanh (depthTarget (r+1)) (1/8) s)) :
    (1-Real.exp (-((r : ℝ)+1)*(N : ℝ)/4))/2 ≤
      risk Real.tanh inputLaw (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) ∧
    (1/2 : ℝ) ≤ inputLaw.real {x | correctProbability Real.tanh
      (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) x < 2/3} := by
  obtain ⟨hQ,hpair⟩ := critical_posterior_pair_tail hN hr s hden
  letI := hQ
  refine ⟨paired_gibbs_risk_lower _ (r+1) hpair,?_⟩
  apply paired_strict_output_change_barrier _ (r+1) _ hpair
  have hNr : (1 : ℝ)≤N := by exact_mod_cast hN
  have hrr : (12 : ℝ)≤(r : ℝ)+1 := by exact_mod_cast hr
  have hex : -((r : ℝ)+1)*(N : ℝ)/4≤-3 := by nlinarith only [hNr,hrr]
  have hfour : (4 : ℝ)≤Real.exp 3 := by linarith only [Real.add_one_le_exp (3 : ℝ)]
  have he : Real.exp (-3 : ℝ)≤1/4 := by
    rw [Real.exp_neg]
    simpa only [one_div] using one_div_le_one_div_of_le (by norm_num : (0 : ℝ)<4) hfour
  exact lt_of_le_of_lt ((Real.exp_le_exp.mpr hex).trans he) (by norm_num)

theorem critical_posterior_liminf_from_mass {r n : ℕ} (hr : 12 ≤ r+1)
    (s : Fin n → RealInput 2)
    (hden : ∀ᶠ N : ℕ in atTop, Real.exp (-((r : ℝ)+1)*(N : ℝ)/4) ≤
      (powerPrior 2 N r 1).real (trainingEvent Real.tanh (depthTarget (r+1)) (1/8) s)) :
    (1/2 : ℝ) ≤ liminf (fun N : ℕ =>
      risk Real.tanh inputLaw (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4)) atTop ∧
    (1/2 : ℝ) ≤ liminf (fun N : ℕ => inputLaw.real {x | correctProbability Real.tanh
      (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) x < 2/3}) atTop := by
  have hN : ∀ᶠ N : ℕ in atTop, 0<N := eventually_gt_atTop 0
  have hpost := hden.and hN
  have hrisk : ∀ᶠ N : ℕ in atTop,
      (1-Real.exp (-((r : ℝ)+1)*(N : ℝ)/4))/2 ≤
        risk Real.tanh inputLaw (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) :=
    hpost.mono (fun N h => (critical_posterior_risk_from_mass h.2 hr s h.1).1)
  have hriskUpper : ∀ᶠ N : ℕ in atTop,
      risk Real.tanh inputLaw (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) ≤ 1 := by
    filter_upwards [hpost] with N h
    letI := (critical_posterior_pair_tail h.2 hr s h.1).1
    exact (measureReal_mono (Set.subset_univ _)).trans_eq probReal_univ
  have hconf : ∀ᶠ N : ℕ in atTop, (1/2 : ℝ) ≤ inputLaw.real {x | correctProbability Real.tanh
      (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) x < 2/3} :=
    hpost.mono (fun N h => (critical_posterior_risk_from_mass h.2 hr s h.1).2)
  have hlimit : Tendsto (fun N : ℕ => (1-Real.exp (-((r : ℝ)+1)*(N : ℝ)/4))/2) atTop (𝓝 (1/2 : ℝ)) := by
    have hexp := Real.tendsto_exp_neg_atTop_nhds_zero.comp
      ((tendsto_natCast_atTop_atTop : Tendsto (fun N : ℕ => (N : ℝ)) atTop atTop).const_mul_atTop
        (show 0<((r : ℝ)+1)/4 by positivity))
    have he : Tendsto (fun N : ℕ => Real.exp (-((r : ℝ)+1)*(N : ℝ)/4)) atTop (𝓝 (0 : ℝ)) := by
      convert hexp using 1 <;> ext N <;> congr 1 <;> ring
    simpa using ((tendsto_const_nhds : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1)).sub he).div_const 2
  refine ⟨?_,le_liminf_of_le
    (isCoboundedUnder_ge_of_le atTop (fun _ =>
      (measureReal_mono (Set.subset_univ _)).trans_eq probReal_univ)) hconf⟩
  rw [←hlimit.liminf_eq]
  exact liminf_le_liminf hrisk hlimit.isBoundedUnder_ge (isCoboundedUnder_ge_of_eventually_le atTop hriskUpper)

#print axioms critical_posterior_liminf_from_mass
end NeuralGeneralization.BatchTwoContinuousDepthLower
