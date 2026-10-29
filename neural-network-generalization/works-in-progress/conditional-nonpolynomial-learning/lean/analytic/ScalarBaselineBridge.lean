import ScalarGaussianGrowth
import GaussianVarianceKL

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

lemma sum_cost_le_increment (m : ℕ) (q e : ℕ → ℝ)
    (he : ∀ j<m, e j≤128*(q (j+1)-q j)) :
    (∑ j ∈ Finset.range m, e j) ≤128*(q m-q 0) := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hh := ih (fun j hj => he j (Nat.lt_succ_of_lt hj))
    have hl := he m (Nat.lt_succ_self m)
    rw [Finset.sum_range_succ]
    linarith

/-- The literal scalar Bellman value has a linear bridge to every sufficiently
small positive state. Gaussian inflation steps may overshoot that state; value
monotonicity handles the overshoot without an exact-hitting assertion. -/
theorem scalarValue_small_bridge {a p : ℝ} (ha : 0<a) (hap : a≤p)
    (hp : p≤1/2048) : scalarValue a≤scalarValue p+144*p := by
  let q := stoppedGrowth p a
  have hex : ∃n, p≤q n := stoppedGrowth_reaches ha hap hp
  let m := Nat.find hex
  have hm : p≤q m := Nat.find_spec hex
  have hbelow (j:ℕ) (hj:j<m) : q j<p := by
    exact lt_of_not_ge (Nat.find_min hex hj)
  have hpos (j:ℕ) : 0<q j := ha.trans_le (stoppedGrowth_bounds ha hap hp j).1
  have htrans (j:ℕ) (hj:j<m) : scalarTransition (q j) (inflationLaw (q j))=q (j+1) := by
    rw [inflationLaw_transition (hpos j).le]
    exact (show q (j+1)=growthState (q j) by
      change (if q j<p then growthState (q j) else q j)=growthState (q j)
      rw [if_pos (hbelow j hj)]).symm
  have hb := scalarValue_prefix m q (fun j => inflationLaw (q j))
    (fun j _ => hpos j) (fun j _ => inflationLaw_probability (q j))
    (fun j _ => gaussian_inflation_kl_ne_top (q j) (hpos j).le) htrans
  have he (j:ℕ) (hj:j<m) :
      (klDiv (inflationLaw (q j)) (gaussianReal 0 1)).toReal≤128*(q (j+1)-q j) := by
    have hc := gaussian_inflation_kl_quadratic (q j) (hpos j).le
    change (klDiv (inflationLaw (q j)) (gaussianReal 0 1)).toReal≤_ at hc
    have hg := (growthState_bounds (hpos j).le ((hbelow j hj).le.trans hp)).1
    have ht : q (j+1)=growthState (q j) := by
      change (if q j<p then growthState (q j) else q j)=growthState (q j)
      rw [if_pos (hbelow j hj)]
    rw [← ht] at hg
    linarith
  have hs := sum_cost_le_increment m q
    (fun j => (klDiv (inflationLaw (q j)) (gaussianReal 0 1)).toReal) he
  have hv := scalarValue_antitone (ha.trans_le hap) hm
  have hqm := (stoppedGrowth_bounds ha hap hp m).2
  have hp0 : 0<p := ha.trans_le hap
  have hbound : q m≤(9/8:ℝ)*p := by nlinarith
  have hq0 : q 0=a := rfl
  rw [hq0] at hb hs
  linarith

/-- Uniform in the starting state a; larger initial states need no bridge. -/
theorem scalarValue_uniform_bridge {p : ℝ} (hp0 : 0<p) (hp : p≤1/2048)
    {a : ℝ} (ha : 0<a) : scalarValue a≤scalarValue p+144*p := by
  rcases le_total a p with hap | hpa
  · exact scalarValue_small_bridge ha hap hp
  · have hv := scalarValue_antitone hp0 hpa
    linarith

/-- The scalar baseline is finite, proved by a concrete finite-KL control path
from each positive initial state. -/
theorem scalarBaseline_ne_top : scalarBaseline≠∞ := by
  have hbound : scalarBaseline≤ENNReal.ofReal (scalarValue (1/2048)+144*(1/2048)) := by
    unfold scalarBaseline
    refine iSup_le (fun q => iSup_le (fun hq => ?_))
    exact ENNReal.ofReal_le_ofReal (scalarValue_uniform_bridge (by norm_num) (by norm_num) hq)
  exact ne_top_of_le_ne_top ENNReal.ofReal_ne_top hbound

lemma scalarValue_le_baseline {q : ℝ} (hq : 0<q) : scalarValue q≤scalarBaseline.toReal := by
  have hh : ENNReal.ofReal (scalarValue q)≤scalarBaseline :=
    le_iSup_of_le q (le_iSup_of_le hq le_rfl)
  have ht := ENNReal.toReal_mono scalarBaseline_ne_top hh
  rwa [ENNReal.toReal_ofReal (scalarValue_nonneg q)] at ht

/-- A genuine O(q) bridge between the critical baseline and the actual finite
scalar path value, with no assumed Bellman estimate. -/
theorem scalarBaseline_linear_bridge {p : ℝ} (hp0 : 0<p) (hp : p≤1/2048) :
    0≤scalarBaseline.toReal-scalarValue p ∧
      scalarBaseline.toReal-scalarValue p≤144*p := by
  have hbound : scalarBaseline≤ENNReal.ofReal (scalarValue p+144*p) := by
    unfold scalarBaseline
    refine iSup_le (fun q => iSup_le (fun hq => ?_))
    exact ENNReal.ofReal_le_ofReal (scalarValue_uniform_bridge hp0 hp hq)
  have hn : 0≤scalarValue p+144*p := by
    have hh := scalarValue_nonneg p
    positivity
  have ht := ENNReal.toReal_mono ENNReal.ofReal_ne_top hbound
  rw [ENNReal.toReal_ofReal hn] at ht
  constructor
  · linarith [scalarValue_le_baseline hp0]
  · linarith

lemma scalarTransition_nonneg (q : ℝ) (Q : Measure ℝ) :
    0≤scalarTransition q Q := integral_nonneg (varianceTest_nonneg q)

lemma scalarTransition_le_one (q : ℝ) (Q : Measure ℝ) [IsProbabilityMeasure Q] :
    scalarTransition q Q≤1 := by
  have hh := integral_mono (varianceTest_integrable Q q) (integrable_const (1:ℝ))
    (varianceTest_le_one q)
  simpa only [integral_const,probReal_univ,one_smul,scalarTransition] using hh

/-- A positive lower potential for every literal finite scalar control path. -/
theorem ScalarPath.cost_lower {q : ℝ} (p : ScalarPath q) (hq1 : q≤1) :
    driftRate*((1/8:ℝ)-q)≤p.cost := by
  induction p with
  | @stop q hq =>
    change driftRate*((1/8:ℝ)-_)≤1/(8*_)
    have hread : (1/8:ℝ)≤1/(8*q) :=
      one_div_le_one_div_of_le (by positivity) (by linarith)
    have hd := driftRate_le_one
    have hd0 := driftRate_pos
    nlinarith
  | @step q hq Q hprob hfinite tail ih =>
    letI := hprob
    have hn := scalarTransition_le_one q Q
    have ht := ih hn
    have hd := scalar_entropy_drift Q hfinite hq.le hq1
    change scalarTransition q Q-q≤_ at hd
    have he : driftRate*(scalarTransition q Q-q)≤
        (klDiv Q (gaussianReal 0 1)).toReal := by
      have hh : scalarTransition q Q-q≤
          (klDiv Q (gaussianReal 0 1)).toReal/driftRate := by
        nlinarith [driftDissipation_pos, sq_nonneg q]
      simpa only [mul_comm] using (le_div_iff₀ driftRate_pos).mp hh
    change _≤(klDiv Q (gaussianReal 0 1)).toReal+tail.cost
    linarith

theorem scalarValue_lower {q : ℝ} (hq : 0<q) (hq1 : q≤1) :
    driftRate*((1/8:ℝ)-q)≤scalarValue q := by
  apply le_csInf (scalarCosts_nonempty hq)
  rintro r ⟨p,rfl⟩
  exact p.cost_lower hq1

theorem scalarBaseline_pos : 0<scalarBaseline.toReal := by
  have hl := scalarValue_lower (q:=(1/16:ℝ)) (by norm_num) (by norm_num)
  have hu := scalarValue_le_baseline (q:=(1/16:ℝ)) (by norm_num)
  have hp := driftRate_pos
  linarith

/-- Coarse explicit baseline ceiling, sufficient for polynomial-resource use. -/
theorem scalarBaseline_le : scalarBaseline.toReal≤257 := by
  have hb := (scalarBaseline_linear_bridge (p:=(1/2048:ℝ)) (by norm_num) (by norm_num)).2
  have hr := scalarValue_le_readout (q:=(1/2048:ℝ)) (by norm_num)
  norm_num at hr hb
  linarith

/-- A global linear bridge. Its coarse constant avoids any near-critical or
exact endpoint assumptions and is adequate for qualitative polynomial bounds. -/
theorem scalarBaseline_global_bridge {q : ℝ} (hq : 0<q) :
    0≤scalarBaseline.toReal-scalarValue q ∧
      scalarBaseline.toReal-scalarValue q≤526336*q := by
  constructor
  · linarith [scalarValue_le_baseline hq]
  · rcases le_total q (1/2048) with hs | hs
    · have hh := (scalarBaseline_linear_bridge hq hs).2
      nlinarith
    · have hh := scalarBaseline_le
      have hn := scalarValue_nonneg q
      linarith

/-- Any genuine scalar suffix costs at least baseline minus a linear variance
allowance. This is the form used in near-baseline prefix accounting. -/
theorem ScalarPath.cost_ge_baseline {q : ℝ} (p : ScalarPath q) :
    scalarBaseline.toReal-526336*q≤p.cost := by
  have hb := (scalarBaseline_global_bridge p.start_pos).2
  have hv := scalarValue_le_path p
  linarith

/-- Decomposing an actual near-baseline action at a scalar suffix bounds the
entropy already spent by a linear function of the remaining variance. -/
theorem prefix_cost_near_baseline {q spent excess : ℝ} (suffix : ScalarPath q)
    (hnear : spent+suffix.cost≤scalarBaseline.toReal+excess) :
    spent≤excess+526336*q := by
  have hh := suffix.cost_ge_baseline
  linarith

#print axioms scalarBaseline_ne_top
#print axioms scalarBaseline_linear_bridge
#print axioms scalarBaseline_pos
#print axioms ScalarPath.cost_ge_baseline
end ConditionalNonpolynomial.Analytic
