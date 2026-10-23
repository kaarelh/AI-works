import NeuralGeneralization.BatchTwoContinuousDepthCriticalPopulation

/-! A single tolerance tracks every possible empirical seed through a fixed
number of free layers and preserves a uniform signed signal. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical

variable {J:Type*}

theorem freeMomentMap_iterate_fst (s:(J→ℝ)×(J→ℝ)) (H:ℕ) (i:J) :
    ((freeMomentMap^[H]) s).1 i=coolingOrbit (s.1 i) H := by
  induction H with
  | zero=>rfl
  | succ H ih=>
    rw [Function.iterate_succ_apply']
    change coolingSecondMoment (((freeMomentMap^[H]) s).1 i)=_
    rw [ih]
    simp only [coolingOrbit,Function.iterate_succ_apply']

theorem freeMomentMap_iterate_snd (s:(J→ℝ)×(J→ℝ)) (H:ℕ) (i:J) :
    ((freeMomentMap^[H]) s).2 i=s.2 i*freeSeedMultiplier (s.1 i) H := by
  induction H with
  | zero=>simp [freeSeedMultiplier]
  | succ H ih=>
    rw [Function.iterate_succ_apply']
    change ((freeMomentMap^[H]) s).2 i*coolingDerivative (((freeMomentMap^[H]) s).1 i)=_
    rw [ih,freeMomentMap_iterate_fst]
    simp only [freeSeedMultiplier,Finset.prod_range_succ]
    ring

theorem freeMomentMap_iterate_mem {s:(J→ℝ)×(J→ℝ)} (hs:s∈momentBox J) (H:ℕ) :
    (freeMomentMap^[H]) s∈momentBox J := by
  induction H with
  | zero=>exact hs
  | succ H ih=>rw [Function.iterate_succ_apply'];exact freeMomentMap_mem ih

theorem freeSeedMultiplier_depth_lower {q:ℝ} (hq:0≤q) (hq1:q≤1) {H h:ℕ} (hH:H≤h) :
    Real.exp (-(1+Real.log ((h:ℝ)+1))/(coolingConstant*derivativeFloor))≤freeSeedMultiplier q H := by
  apply le_trans _ (freeSeedMultiplier_lower hq hq1 H)
  apply Real.exp_le_exp.mpr
  apply div_le_div_of_nonneg_right _ (mul_nonneg coolingConstant_pos.le derivativeFloor_pos.le)
  have hl:=Real.log_le_log (by positivity : (0:ℝ)<(H:ℝ)+1)
    (show (H:ℝ)+1≤(h:ℝ)+1 by exact_mod_cast Nat.add_le_add_right hH 1)
  linarith

theorem freeMomentMap_signed_signal {n P H h:ℕ} (hn:0<n) (hP:0<P) (hH:H≤h)
    {s:(J→ℝ)×(J→ℝ)} (hs:s∈momentBox J) (labels:J→Bool)
    (hseed:∀i,seedSignal n P≤ConcreteModel.labelReal (labels i)*s.2 i) (i:J) :
    2*retainedSignal n P h≤ConcreteModel.labelReal (labels i)*((freeMomentMap^[H]) s).2 i := by
  rw [freeMomentMap_iterate_snd,←mul_assoc]
  have hmult:=freeSeedMultiplier_depth_lower (hs.1.1 i) (hs.1.2 i) hH
  have hnon:0≤freeSeedMultiplier (s.1 i) H := (Real.exp_pos _).le.trans hmult
  have hm:=mul_le_mul (hseed i) hmult (Real.exp_pos _).le
    ((seedSignal_pos hn hP).le.trans (hseed i))
  unfold retainedSignal
  nlinarith

/-- Uniformity in the initial seed is essential: no convergence of its
second moments with width is assumed. -/
theorem free_layers_retain_signal [Fintype J] {n P H h:ℕ} (hn:0<n) (hP:0<P) (hH:H≤h)
    (labels:J→Bool) :
    ∃δ:ℝ,0<δ ∧ ∀s:ℕ→((J→ℝ)×(J→ℝ)),
      (∀k,k≤H→s k∈momentBox J) →
      (∀i,seedSignal n P≤ConcreteModel.labelReal (labels i)*(s 0).2 i) →
      (∀k,k<H→dist (s (k+1)) (freeMomentMap (s k))<δ) →
      ∀i,retainedSignal n P h<ConcreteModel.labelReal (labels i)*(s H).2 i := by
  obtain ⟨δ,hδ,htrack⟩:=finite_recursion_uniform_stability (momentBox J)
    (fun _=>@freeMomentMap J) (fun _=>freeMomentMap_uniformContinuous) H
    (retainedSignal_pos hn hP h)
  refine ⟨δ,hδ,?_⟩
  intro s hs hseed hstep i
  let ideal:ℕ→((J→ℝ)×(J→ℝ)):=fun k=>(freeMomentMap^[k]) (s 0)
  have hclose:=htrack ideal s (fun k _=>freeMomentMap_iterate_mem (hs 0 (by omega)) k)
    hs (fun k _=>by simp only [ideal,Function.iterate_succ_apply'])
    (by simpa only [ideal,Function.iterate_zero,Function.id_def,dist_self] using hδ) hstep H le_rfl
  have hsignal:=freeMomentMap_signed_signal hn hP hH (hs 0 (by omega)) labels hseed i
  have hprod:dist (s H).2 (ideal H).2≤dist (s H) (ideal H):=le_max_right _ _
  have hcoord:dist ((s H).2 i) ((ideal H).2 i)≤dist (s H).2 (ideal H).2:=dist_le_pi_dist _ _ i
  have herr:|(s H).2 i-(ideal H).2 i|<retainedSignal n P h := by
    simpa only [Real.dist_eq] using (hcoord.trans hprod).trans_lt hclose
  have hlabel:|ConcreteModel.labelReal (labels i)*((s H).2 i-(ideal H).2 i)|<retainedSignal n P h := by
    simpa only [abs_mul,ConcreteModel.abs_labelReal,one_mul] using herr
  have hb:-(retainedSignal n P h)<ConcreteModel.labelReal (labels i)*((s H).2 i-(ideal H).2 i):=
    (abs_lt.mp hlabel).1
  change 2*retainedSignal n P h≤ConcreteModel.labelReal (labels i)*(ideal H).2 i at hsignal
  nlinarith

end NeuralGeneralization.BatchTwoContinuousDepthCritical
