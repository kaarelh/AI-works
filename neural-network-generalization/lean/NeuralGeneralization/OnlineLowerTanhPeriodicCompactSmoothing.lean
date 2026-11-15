import NeuralGeneralization.OnlineLowerTanhPeriodicExactSmoothingGap
import NeuralGeneralization.OnlineLowerTanhConditionedEfficiency
import Mathlib.Analysis.Normed.Group.FunctionSeries

/-! # A strict Gaussian smoothing loss uniform on every positive compact gain range -/
noncomputable section
open scoped Topology BigOperators Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def smoothingParameterBox (lo hi e₀ K:ℝ):Set (ℝ×ℝ×ℝ):=
  Icc lo hi ×ˢ (Icc e₀ K ×ˢ Icc 0 (2*hi))

lemma smoothedResponse_continuousOn_box {lo hi e₀ K:ℝ}
    (hlo:0<lo) (hhi:lo ≤ hi) (he₀:0 ≤ e₀) :
    ContinuousOn (fun p:ℝ×ℝ×ℝ=>smoothedResponse p.1 p.2.1 p.2.2)
      (smoothingParameterBox lo hi e₀ K) := by
  have hhip:0<hi:=hlo.trans_le hhi
  let M:ℕ→ℝ:=fun j=>((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicRatio hi^j
  have hq:=periodicRatio_mem hhip
  have hsum:Summable M:=((hasSum_geometric_of_lt_one hq.1.le hq.2).summable).mul_left _
  refine continuousOn_tsum (u:=M) ?_ hsum ?_
  · intro j p hp
    have ha:0<p.1:=hlo.trans_le hp.1.1
    have hcoef:ContinuousAt (fun p:ℝ×ℝ×ℝ=>periodicCoefficient p.1 j) p:=
      (periodicCoefficient_continuousAt ha j).comp continuousAt_fst
    have hfreq:ContinuousAt (fun p:ℝ×ℝ×ℝ=>periodicFrequency p.1) p:=by
      unfold periodicFrequency
      exact continuousAt_const.div (continuousAt_const.mul continuousAt_fst)
        (mul_ne_zero (by norm_num) ha.ne')
    have hc:ContinuousAt (fun p:ℝ×ℝ×ℝ=>smoothedCoefficient p.1 p.2.1 j) p:=by
      unfold smoothedCoefficient
      have he:ContinuousAt (fun p:ℝ×ℝ×ℝ=>p.2.1) p:=by fun_prop
      exact hcoef.mul (Real.continuous_exp.continuousAt.comp
        ((he.neg.mul ((hfreq.const_mul (2*(j:ℝ)+1)).pow 2)).div_const 2))
    have hb:ContinuousAt (fun p:ℝ×ℝ×ℝ=>p.2.2) p:=by fun_prop
    exact (hc.mul (Real.continuous_sin.continuousAt.comp
      ((hfreq.const_mul (2*(j:ℝ)+1)).mul hb))).continuousWithinAt
  · intro j p hp
    have ha:0<p.1:=hlo.trans_le hp.1.1
    have hE:0 ≤ p.2.1:=he₀.trans hp.2.1.1
    rw [Real.norm_eq_abs,abs_mul,abs_of_pos (smoothedCoefficient_pos ha _ j)]
    calc
      _ ≤ smoothedCoefficient p.1 p.2.1 j :=
        mul_le_of_le_one_right (smoothedCoefficient_pos ha _ j).le (Real.abs_sin_le_one _)
      _ ≤ M j:=smoothedCoefficient_compact_bound hlo hp.1.1 hp.1.2 hE j

lemma scalarF0_continuousOn_box {lo hi e₀ K:ℝ} (hlo:0<lo) :
    ContinuousOn (fun p:ℝ×ℝ×ℝ=>scalarF0 p.1) (smoothingParameterBox lo hi e₀ K) := by
  intro p hp
  have ha:0<p.1:=hlo.trans_le hp.1.1
  have h:ContinuousAt scalarF0 p.1:=scalarF0_tendsto_of_positive ha continuousAt_id
  exact (h.comp continuousAt_fst).continuousWithinAt

lemma smoothedResponse_reduce_phase {a:ℝ} (ha:0<a) (E b:ℝ) :
    ∃b':ℝ,b'∈Icc 0 (2*a) ∧ |smoothedResponse a E b|=|smoothedResponse a E b'| := by
  let r:ℤ:=phaseInteger true (b/a)
  let z:ℝ:=a*phaseError true (b/a)
  have hr:Odd r:=phaseInteger_odd _
  have hz:|z| ≤ a := by
    dsimp [z]
    rw [abs_mul,abs_of_pos ha]
    exact (mul_le_mul_of_nonneg_left (phaseError_abs_le_one true (b/a)) ha.le).trans_eq (mul_one a)
  have hb:(r:ℝ)*a+z=b := by
    dsimp [r,z,phaseError]
    field_simp
    ring
  have hanti:Function.Antiperiodic (smoothedResponse a E) (2*a):=smoothedResponse_antiperiod ha
  obtain ⟨s,hs,hphase⟩:=odd_base_phase (smoothedResponse a E) a hanti hr
  have hh:=hphase z
  rw [hb] at hh
  refine ⟨a+z,?_,?_⟩
  · have hh:=abs_le.mp hz
    constructor <;> linarith
  · rw [hh,abs_mul,hs,one_mul]

/-- Positive Gaussian residual energy lowers the periodic maximum by a
single strict amount, uniformly over all external phases and over any
specified compact positive gain/energy box. -/
theorem smoothedResponse_uniform_strict_loss
    {lo hi e₀ K:ℝ} (hlo:0<lo) (hhi:lo ≤ hi) (he₀:0<e₀) (hK:e₀ ≤ K) :
    ∃η:ℝ,0<η ∧ ∀a∈Icc lo hi,∀E∈Icc e₀ K,∀b:ℝ,
      |smoothedResponse a E b| ≤ scalarF0 a-η := by
  let Q:=smoothingParameterBox lo hi e₀ K
  let gap:ℝ×ℝ×ℝ→ℝ:=fun p=>scalarF0 p.1-|smoothedResponse p.1 p.2.1 p.2.2|
  have hQ:IsCompact Q:=isCompact_Icc.prod (isCompact_Icc.prod isCompact_Icc)
  have hQne:Q.Nonempty:=⟨(lo,e₀,0),⟨⟨le_rfl,hhi⟩,⟨le_rfl,hK⟩,⟨le_rfl,by linarith⟩⟩⟩
  have hcont:ContinuousOn gap Q:=
    (scalarF0_continuousOn_box hlo).sub (smoothedResponse_continuousOn_box hlo hhi he₀.le).abs
  obtain ⟨p,hp,hmin⟩:=hQ.exists_isMinOn hQne hcont
  have hpos:0<gap p := by
    have ha:=hlo.trans_le hp.1.1
    have hE:=he₀.trans_le hp.2.1.1
    have hh:=smoothedResponse_abs_lt_all_gain ha hE p.2.2
    rw [periodicFourierMaximum_eq_scalarF0 p.1 ha] at hh
    exact sub_pos.mpr hh
  refine ⟨gap p,hpos,?_⟩
  intro a ha E hE b
  obtain ⟨b',hb',heq⟩:=smoothedResponse_reduce_phase (hlo.trans_le ha.1) E b
  have hbhi:b' ≤ 2*hi := hb'.2.trans (by linarith [ha.2])
  have hh:=hmin (show (a,E,b')∈Q from ⟨ha,hE,hb'.1,hbhi⟩)
  change gap p ≤ scalarF0 a-|smoothedResponse a E b'| at hh
  rw [heq]
  linarith

end NeuralGeneralization.OnlineLowerTanh
