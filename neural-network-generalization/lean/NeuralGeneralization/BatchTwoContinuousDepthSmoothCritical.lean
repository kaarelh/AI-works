import NeuralGeneralization.BatchTwoContinuousDepthSmoothRisk
import NeuralGeneralization.BatchTwoContinuousDepthJitterLower
import NeuralGeneralization.BatchTwoContinuousDepthCriticalMain

/-! The width-first critical-prior conclusion for the smooth law. The sharp
label bands permit reuse of the original low-rate physical network witness. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open MeasureTheory ProbabilityTheory Filter
open scoped Topology BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

theorem smooth_critical_prior_pair_tail {N r : ℕ} (hN : 0 < N) (hr : 12 ≤ r+1) (ω : SignStream × Jitter (r+1)) :
    (powerPrior 2 N r 1).real {w | (12/25 : ℝ) ≤
      |output Real.tanh w (jitteredCoding (r+1) ω)-output Real.tanh w (jitteredCoding (r+1) (jitterFlip (r+1) ω))|} ≤
      Real.exp (-((r : ℝ)+1)*(N : ℝ)/2) := by
  have hNR : (0 : ℝ)<N := by exact_mod_cast hN
  rw [powerPrior_eq_smallPrior hN,Real.rpow_neg_one]
  apply jittered_meanfield_pair_tail hN hr (Real.sqrt_pos.mpr (inv_pos.mpr hNR))
  rw [Real.sq_sqrt (inv_nonneg.mpr hNR.le),mul_inv_cancel₀ hNR.ne']

theorem smooth_critical_posterior_pair_tail {N r n : ℕ} (hN : 0 < N) (hr : 12 ≤ r+1)
    (s : Fin n → RealInput 2)
    (hden : Real.exp (-((r : ℝ)+1)*(N : ℝ)/4) ≤
      (powerPrior 2 N r 1).real (trainingEvent Real.tanh (depthTarget (r+1)) (1/8) s)) :
    IsProbabilityMeasure (criticalPosterior (r := r) s N) ∧
    ∀ ω, (criticalPosterior (r := r) s N).real {w | (12/25 : ℝ) ≤
      |output Real.tanh w (jitteredCoding (r+1) ω)-output Real.tanh w (jitteredCoding (r+1) (jitterFlip (r+1) ω))|} ≤
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
  have hnum := smooth_critical_prior_pair_tail hN hr ω
  have hratio := RobustPosterior.cond_real_le_ratio μ V
    {w | (12/25 : ℝ) ≤ |output Real.tanh w (jitteredCoding (r+1) ω)-
      output Real.tanh w (jitteredCoding (r+1) (jitterFlip (r+1) ω))|}
    (isOpen_trainingEvent tanh_continuous _ _ s).measurableSet
  apply hratio.trans
  have hh := div_le_div₀ (Real.exp_nonneg _) hnum (Real.exp_pos _) hden
  apply hh.trans_eq
  rw [←Real.exp_sub]
  congr 1
  ring

theorem smooth_critical_posterior_risk_from_mass {N r n : ℕ} (hN : 0 < N) (hr : 12 ≤ r+1)
    (s : Fin n → RealInput 2)
    (hden : Real.exp (-((r : ℝ)+1)*(N : ℝ)/4) ≤
      (powerPrior 2 N r 1).real (trainingEvent Real.tanh (depthTarget (r+1)) (1/8) s)) :
    (1-Real.exp (-((r : ℝ)+1)*(N : ℝ)/4))/2 ≤
      risk Real.tanh (smoothInputLaw (r+1)) (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) ∧
    (1/2 : ℝ) ≤ (smoothInputLaw (r+1)).real {x | correctProbability Real.tanh
      (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) x < 2/3} := by
  obtain ⟨hQ,hpair⟩ := smooth_critical_posterior_pair_tail hN hr s hden
  letI := hQ
  refine ⟨smooth_paired_gibbs_risk_lower _ (r+1) hpair,?_⟩
  apply smooth_paired_strict_output_change_barrier _ (r+1) _ hpair
  have hNr : (1 : ℝ)≤N := by exact_mod_cast hN
  have hrr : (12 : ℝ)≤(r : ℝ)+1 := by exact_mod_cast hr
  have hex : -((r : ℝ)+1)*(N : ℝ)/4≤-3 := by nlinarith only [hNr,hrr]
  have hfour : (4 : ℝ)≤Real.exp 3 := by linarith only [Real.add_one_le_exp (3 : ℝ)]
  have he : Real.exp (-3 : ℝ)≤1/4 := by
    rw [Real.exp_neg]
    simpa only [one_div] using one_div_le_one_div_of_le (by norm_num : (0 : ℝ)<4) hfour
  exact lt_of_le_of_lt ((Real.exp_le_exp.mpr hex).trans he) (by norm_num)

theorem smooth_critical_posterior_liminf_from_mass {r n : ℕ} (hr : 12 ≤ r+1)
    (s : Fin n → RealInput 2)
    (hden : ∀ᶠ N : ℕ in atTop, Real.exp (-((r : ℝ)+1)*(N : ℝ)/4) ≤
      (powerPrior 2 N r 1).real (trainingEvent Real.tanh (depthTarget (r+1)) (1/8) s)) :
    (1/2 : ℝ) ≤ liminf (fun N : ℕ =>
      risk Real.tanh (smoothInputLaw (r+1)) (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4)) atTop ∧
    (1/2 : ℝ) ≤ liminf (fun N : ℕ => (smoothInputLaw (r+1)).real {x | correctProbability Real.tanh
      (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) x < 2/3}) atTop := by
  have hN : ∀ᶠ N : ℕ in atTop, 0<N := eventually_gt_atTop 0
  have hpost := hden.and hN
  have hrisk : ∀ᶠ N : ℕ in atTop,
      (1-Real.exp (-((r : ℝ)+1)*(N : ℝ)/4))/2 ≤
        risk Real.tanh (smoothInputLaw (r+1)) (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) :=
    hpost.mono (fun N h => (smooth_critical_posterior_risk_from_mass h.2 hr s h.1).1)
  have hriskUpper : ∀ᶠ N : ℕ in atTop,
      risk Real.tanh (smoothInputLaw (r+1)) (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) ≤ 1 := by
    filter_upwards [hpost] with N h
    letI := (smooth_critical_posterior_pair_tail h.2 hr s h.1).1
    exact (measureReal_mono (Set.subset_univ _)).trans_eq probReal_univ
  have hconf : ∀ᶠ N : ℕ in atTop, (1/2 : ℝ) ≤ (smoothInputLaw (r+1)).real {x | correctProbability Real.tanh
      (criticalPosterior (r := r) s N) (depthTarget (r+1)) (1/4) x < 2/3} :=
    hpost.mono (fun N h => (smooth_critical_posterior_risk_from_mass h.2 hr s h.1).2)
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

end NeuralGeneralization.BatchTwoContinuousDepthLower

namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

theorem smooth_critical_manuscript_depth_lower_bound :
    ∃c : ℝ,0<c ∧ ∃h0 : ℕ,∀h n : ℕ,h0≤h→0<n→(n:ℝ)≤Real.exp (c*(h:ℝ))→
      (49/50:ℝ)≤(Measure.pi fun _ : Fin n=>(smoothInputLaw h)).real
        {s | (1/2:ℝ)≤liminf (fun N : ℕ=>
          risk Real.tanh (smoothInputLaw h) (criticalPosterior (r:=h-1) s N) (depthTarget h) (1/4)) atTop ∧
          (1/2:ℝ)≤liminf (fun N : ℕ=>(smoothInputLaw h).real {x | correctProbability Real.tanh
            (criticalPosterior (r:=h-1) s N) (depthTarget h) (1/4) x<2/3}) atTop} := by
  obtain ⟨c,hc,h0,hschedule⟩ := exists_critical_recovery_schedule
  refine ⟨c,hc,max h0 12,?_⟩
  intro h n hh hn hne
  obtain ⟨hs,hcost⟩ := hschedule h (by omega) n hn hne
  have hh12 : 12≤h := by omega
  have hhpos : 0<h := by omega
  have heq : h-1+1=h := by omega
  have hbounds := smooth_iid_critical_sample_bounds h n
  have hgood : ∀ᵐs ∂(Measure.pi fun _ : Fin n=>(smoothInputLaw h)),s∈separatedSample n→
      (1/2:ℝ)≤liminf (fun N : ℕ=>
        risk Real.tanh (smoothInputLaw h) (criticalPosterior (r:=h-1) s N) (depthTarget h) (1/4)) atTop ∧
      (1/2:ℝ)≤liminf (fun N : ℕ=>(smoothInputLaw h).real {x | correctProbability Real.tanh
        (criticalPosterior (r:=h-1) s N) (depthTarget h) (1/4) x<2/3}) atTop := by
    filter_upwards [hbounds] with s hb hsep
    have hx0 (i : Fin n) : |s i 0|≤1 := by
      have hz := Finset.single_le_sum (fun (j : Fin 2) (_ : j∈Finset.univ)=>sq_nonneg (s i j))
        (Finset.mem_univ (0 : Fin 2))
      exact (sq_le_one_iff_abs_le_one _).mp (hz.trans (hb.1 i))
    have hmass := critical_training_mass_eventually hn hs hcost s
      (fun i=>targetLabel (depthTarget h (s i))) hb.1 hx0 hsep hb.2
    have hmass' : ∀ᶠ N : ℕ in atTop,Real.exp (-(((h-1:ℕ):ℝ)+1)*(N:ℝ)/4)≤
        (powerPrior 2 N (h-1) 1).real
          (trainingEvent Real.tanh (depthTarget (h-1+1)) (1/8) s) := by
      have hcast : ((h-1:ℕ):ℝ)+1=(h:ℝ) := by exact_mod_cast heq
      simpa only [hcast,heq] using hmass
    have hp := smooth_critical_posterior_liminf_from_mass (r:=h-1) (by omega : 12≤h-1+1) s hmass'
    simpa only [heq] using hp
  apply (jittered_separatedSample_probability h (smoothJitterLaw h) hn).trans
  exact ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono_ae hgood)

/-- The critical statement can use a sample exponent no larger than the
unchanged 1/100 exponent of the strong-prior and finite-power statements. -/
theorem smooth_critical_common_sample_exponent :
    ∃ c : ℝ, 0<c ∧ c≤1/100 ∧ ∃ h0 : ℕ, ∀ h n : ℕ,
      h0≤h → 0<n → (n:ℝ)≤Real.exp (c*(h:ℝ)) →
      (49/50:ℝ)≤(Measure.pi fun _ : Fin n => smoothInputLaw h).real
        {s | (1/2:ℝ)≤liminf (fun N : ℕ =>
          risk Real.tanh (smoothInputLaw h) (criticalPosterior (r:=h-1) s N) (depthTarget h) (1/4)) atTop ∧
          (1/2:ℝ)≤liminf (fun N : ℕ => (smoothInputLaw h).real {x | correctProbability Real.tanh
            (criticalPosterior (r:=h-1) s N) (depthTarget h) (1/4) x<2/3}) atTop} := by
  obtain ⟨c,hc,h0,hh⟩ := smooth_critical_manuscript_depth_lower_bound
  refine ⟨min c (1/100), lt_min hc (by norm_num), min_le_right _ _, h0, ?_⟩
  intro h n hh0 hn hne
  apply hh h n hh0 hn
  exact hne.trans (Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_right (min_le_left c (1/100)) (Nat.cast_nonneg h)))

end NeuralGeneralization.BatchTwoContinuousDepthCritical
