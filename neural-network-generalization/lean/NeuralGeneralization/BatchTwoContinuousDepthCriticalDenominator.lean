import NeuralGeneralization.BatchTwoContinuousDepthCriticalTrainingMass
import NeuralGeneralization.BatchTwoContinuousDepthCriticalSchedule
import NeuralGeneralization.GaussianModelRate

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel BatchTwoContinuousDepthLower

theorem eventually_width_budget {a : ℝ} (ha : 0<a) (b : ℝ) :
    ∀ᶠ N : ℕ in atTop,b≤(N:ℝ)*a := by
  have ht := ((tendsto_natCast_atTop_atTop : Tendsto (fun N:ℕ=>(N:ℝ)) atTop atTop).const_mul_atTop ha).eventually_ge_atTop b
  simpa only [mul_comm] using ht

/-- All finite-width constraints disappear in the specified width-first
limit; the actual Gaussian training event has the needed strict rate gap. -/
theorem critical_training_mass_eventually {n h : ℕ} (hn : 0<n)
    (hsched : recoveryCount n h+2≤h)
    (hcost : 2+2*(recoveryCount n h:ℝ)*robustAmplificationGain^2+
      2*saturationGain^2+2*(3/5:ℝ)^2<(h:ℝ)/8)
    (s : Fin n→BatchTwoContinuous.RealInput 2) (labels : Fin n→Bool)
    (hx : ∀i,∑j,s i j^2≤1) (hx0 : ∀i,|s i 0|≤1)
    (hsep : ∀i j,i≠j→sampleSeparation n≤|s i 0-s j 0|)
    (htarget : ∀i,|depthTarget h (s i)-(3/5)*labelReal (labels i)|≤1/10) :
    ∀ᶠ N : ℕ in atTop,Real.exp (-(h:ℝ)*(N:ℝ)/4)≤
      (powerPrior 2 N (h-1) 1).real
        (BatchTwoContinuous.trainingEvent Real.tanh (depthTarget h) (1/8) s) := by
  let P := seedDilution n (sampleSeparation n)
  let m := recoveryCount n h
  let H := h-m-2
  have hP : 0<P := seedDilution_pos n _
  have hH : H≤h := by dsimp [H];omega
  have heq : H+m+1=h-1 := by dsimp [H,m];omega
  have hh : 0<h := by omega
  have hhR : (0:ℝ)<h := by exact_mod_cast hh
  obtain ⟨ε,hε,hε4,hmass⟩ := critical_training_mass_of_schedule hn hP hH s labels htarget
  have hbase : 0<seedSignal n P := seedSignal_pos hn hP
  have hNmin : ∀ᶠ N:ℕ in atTop,2*(Fintype.card (Fin n×Bool)*P)≤N := eventually_ge_atTop _
  have hNpos : ∀ᶠ N:ℕ in atTop,0<N := eventually_gt_atTop 0
  have hseed := eventually_width_budget (sq_pos_of_pos hbase) (4*(n:ℝ))
  have hfree := eventually_width_budget (sq_pos_of_pos (show 0<ε/8 by positivity)) (4*(64+2*(n:ℝ)))
  have hcontrol := eventually_width_budget (sq_pos_of_pos hε) (4*(n:ℝ))
  have hover := eventually_width_budget (show 0<(h:ℝ)/8 by positivity)
    (5*((H+amplificationCount (retainedSignal n P h)+1:ℕ):ℝ)+10)
  have he : Tendsto (fun N:ℕ=>2*(n:ℝ)*Real.exp (-(N:ℝ)*(1/200:ℝ)^2/2)) atTop (𝓝 0) := by
    have ht := Real.tendsto_exp_neg_atTop_nhds_zero.comp
      ((tendsto_natCast_atTop_atTop : Tendsto (fun N:ℕ=>(N:ℝ)) atTop atTop).const_mul_atTop
        (by norm_num : (0:ℝ)<(1/200:ℝ)^2/2))
    have ht' : Tendsto (fun N:ℕ=>Real.exp (-(N:ℝ)*(1/200:ℝ)^2/2)) atTop (𝓝 (0:ℝ)) := by
      convert ht using 1 <;> ext N <;> congr 1 <;> ring
    simpa only [mul_zero] using ht'.const_mul (2*(n:ℝ))
  have hread := he.eventually (gt_mem_nhds (by norm_num : (0:ℝ)<1/4))
  filter_upwards [hNmin,hNpos,hseed,hfree,hcontrol,hover,hread] with N hN hNp hs hf hc ho hr
  have hb := hmass N hN rfl hx hx0 hsep hs hf hc hr.le
  have hNr : (0:ℝ)<N := by exact_mod_cast hNp
  have hrate : -(h:ℝ)*(N:ℝ)/4≤
      -(N:ℝ)*(2+2*(amplificationCount (retainedSignal n P h):ℝ)*robustAmplificationGain^2+
        2*saturationGain^2+2*(3/5:ℝ)^2)-5*((H+amplificationCount (retainedSignal n P h)+1:ℕ):ℝ)-10 := by
    change 2+2*(amplificationCount (retainedSignal n P h):ℝ)*robustAmplificationGain^2+
      2*saturationGain^2+2*(3/5:ℝ)^2<(h:ℝ)/8 at hcost
    have hm := mul_le_mul_of_nonneg_left hcost.le hNr.le
    nlinarith only [hm,ho]
  have hb' := (Real.exp_le_exp.mpr hrate).trans hb
  have heq' : H+amplificationCount (retainedSignal n P h)+1=h-1 := by
    simpa only [m,recoveryCount,P] using heq
  rw [heq'] at hb'
  rw [powerPrior_eq_smallPrior hNp,Real.rpow_neg_one,Real.sqrt_inv]
  simpa only [one_div] using hb'

#print axioms critical_training_mass_eventually
end NeuralGeneralization.BatchTwoContinuousDepthCritical
