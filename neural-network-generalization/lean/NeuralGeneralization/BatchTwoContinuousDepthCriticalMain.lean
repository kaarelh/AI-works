import NeuralGeneralization.BatchTwoContinuousDepthCriticalDenominator
import NeuralGeneralization.BatchTwoContinuousDepthCriticalPosterior

/-! The literal mean-field, width-first main theorem for the fixed nonatomic
unit-circle law and the bounded width-three teacher family. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open MeasureTheory ProbabilityTheory Filter Set
open scoped BigOperators Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

theorem critical_manuscript_depth_lower_bound :
    ∃c : ℝ,0<c ∧ ∃h0 : ℕ,∀h n : ℕ,h0≤h→0<n→(n:ℝ)≤Real.exp (c*(h:ℝ))→
      (49/50:ℝ)≤(Measure.pi fun _ : Fin n=>inputLaw).real
        {s | (1/2:ℝ)≤liminf (fun N : ℕ=>
          risk Real.tanh inputLaw (criticalPosterior (r:=h-1) s N) (depthTarget h) (1/4)) atTop ∧
          (1/2:ℝ)≤liminf (fun N : ℕ=>inputLaw.real {x | correctProbability Real.tanh
            (criticalPosterior (r:=h-1) s N) (depthTarget h) (1/4) x<2/3}) atTop} := by
  obtain ⟨c,hc,h0,hschedule⟩ := exists_critical_recovery_schedule
  refine ⟨c,hc,max h0 12,?_⟩
  intro h n hh hn hne
  obtain ⟨hs,hcost⟩ := hschedule h (by omega) n hn hne
  have hh12 : 12≤h := by omega
  have hhpos : 0<h := by omega
  have heq : h-1+1=h := by omega
  have hbounds := iid_critical_sample_bounds h n
  have hgood : ∀ᵐs ∂(Measure.pi fun _ : Fin n=>inputLaw),s∈separatedSample n→
      (1/2:ℝ)≤liminf (fun N : ℕ=>
        risk Real.tanh inputLaw (criticalPosterior (r:=h-1) s N) (depthTarget h) (1/4)) atTop ∧
      (1/2:ℝ)≤liminf (fun N : ℕ=>inputLaw.real {x | correctProbability Real.tanh
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
    have hp := critical_posterior_liminf_from_mass (r:=h-1) (by omega : 12≤h-1+1) s hmass'
    simpa only [heq] using hp
  apply (separatedSample_probability hn).trans
  exact ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono_ae hgood)

#print axioms critical_manuscript_depth_lower_bound
end NeuralGeneralization.BatchTwoContinuousDepthCritical
