import NeuralGeneralization.OnlineLowerTanhGlobalBalancedGain
import NeuralGeneralization.OnlineLowerTanhAllGainLimit

/-! # Global strict maximum of the actual limiting balanced gain -/
noncomputable section
open scoped Topology BigOperators
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma oddDegree_real_tendsto : Tendsto (fun r : ℕ => (2*r+1:ℕ):ℕ→ℝ) atTop atTop := by
  exact tendsto_natCast_atTop_atTop.comp
    (StrictMono.tendsto_atTop (fun a b hab => by omega))

lemma oddDegree_complex_tendsto :
    Tendsto (fun r : ℕ => ((2*r+1:ℕ):ℂ)) atTop rightDegreeInfinity := by
  apply tendsto_inf.mpr
  constructor
  · apply tendsto_norm_atTop_iff_cobounded.mp
    simpa only [Complex.norm_natCast] using oddDegree_real_tendsto
  · apply tendsto_principal.mpr
    exact Eventually.of_forall (fun r => by simp; positivity)

lemma balancedGain_tendsto : Tendsto balancedGain atTop (𝓝 limitingGain) := by
  have h := (actualGainBranch_tendsto actualGainBranch).comp oddDegree_complex_tendsto
  apply tendsto_ofReal_iff.mp
  apply h.congr'
  filter_upwards [oddDegree_real_tendsto.eventually (eventually_gt_atTop actualGainBranch.threshold)] with r hr
  exact actualGainBranch_eq_balancedGain actualGainBranch r hr

lemma balancedRatio_normalized_tendsto (a : ℝ) (ha : 0 < a) :
    Tendsto (fun r => balancedRatio r a/oddParityKappa r) atTop (𝓝 (scalarF0 a/a)) := by
  have h := (balancedParity_normalized_tendsto a ha).div_const a
  convert h using 1
  funext r
  unfold balancedRatio
  ring

lemma balancedRatio_mono_before_gain (r : ℕ) (hr : 2 ≤ r)
    (hstationary : balancedStationary r (balancedGain r)=0)
    (a b : ℝ) (ha : 0 < a) (hab : a ≤ b) (hb : b ≤ balancedGain r) :
    balancedRatio r a ≤ balancedRatio r b := by
  have hgain := (balancedGain_mem r).1
  by_cases hb1 : b ≤ 1
  · exact (balancedRatio_strictMono_small r hr).monotoneOn ⟨ha,hab.trans hb1⟩
      ⟨ha.trans_le hab,hb1⟩ hab
  · have h1b : 1 ≤ b := (lt_of_not_ge hb1).le
    have hm := (balancedRatio_strictMono_before_stationary r (balancedGain r) hgain hstationary).monotoneOn
    by_cases ha1 : a ≤ 1
    · exact ((balancedRatio_strictMono_small r hr).monotoneOn ⟨ha,ha1⟩ (by norm_num) ha1).trans
        (hm ⟨le_rfl,hgain⟩ ⟨h1b,hb⟩ h1b)
    · exact hm ⟨(lt_of_not_ge ha1).le,hab.trans hb⟩ ⟨h1b,hb⟩ hab

/-- Pointwise finite-degree convergence preserves monotonicity on either
side of the limiting gain; local strictness will rule out distant plateaus. -/
theorem scalarRatio_monotone_before_limitingGain :
    MonotoneOn (fun a : ℝ => scalarF0 a/a) (Ioo 0 limitingGain) := by
  intro a ha b hb hab
  apply le_of_tendsto_of_tendsto (balancedRatio_normalized_tendsto a ha.1)
    (balancedRatio_normalized_tendsto b hb.1)
  filter_upwards [eventually_ge_atTop 2,
    oddDegree_real_tendsto.eventually (eventually_gt_atTop actualGainBranch.threshold),
    balancedGain_tendsto.eventually (lt_mem_nhds hb.2)] with r hr hrT hbg
  exact div_le_div_of_nonneg_right
    (balancedRatio_mono_before_gain r hr
      (balancedGain_stationary_of_large actualGainBranch r hrT) a b ha.1 hab hbg.le)
    (oddParityKappa_pos r).le

theorem scalarRatio_antitone_after_limitingGain :
    AntitoneOn (fun a : ℝ => scalarF0 a/a) (Ioi limitingGain) := by
  intro a ha b hb hab
  have hap : 0 < a := limitingGain_pos.trans ha
  have hbp : 0 < b := limitingGain_pos.trans hb
  apply le_of_tendsto_of_tendsto (balancedRatio_normalized_tendsto b hbp)
    (balancedRatio_normalized_tendsto a hap)
  filter_upwards [oddDegree_real_tendsto.eventually (eventually_gt_atTop actualGainBranch.threshold),
    balancedGain_tendsto.eventually (gt_mem_nhds ha)] with r hrT hga
  have hm := (balancedRatio_strictAnti_after_stationary r (balancedGain r)
    (balancedGain_mem r).1 (balancedGain_stationary_of_large actualGainBranch r hrT)).antitoneOn
  exact div_le_div_of_nonneg_right (hm hga.le (hga.le.trans hab) hab) (oddParityKappa_pos r).le

/-- The limiting gain has a unique global maximum among every positive
scale, rather than only on the compact interval used to construct it. -/
theorem scalarRatio_global_strict_max (a : ℝ) (ha : 0 < a) (hne : a ≠ limitingGain) :
    scalarF0 a/a < scalarF0 limitingGain/limitingGain := by
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · let b := (max a (123/100)+limitingGain)/2
    have hm : max a (123/100) < limitingGain := max_lt hlt limitingGain_mem.1
    have hab : a < b := by have hh := le_max_left a (123/100); dsimp [b]; linarith
    have hb0 : 123/100 < b := by have hh := le_max_right a (123/100); dsimp [b]; linarith
    have hbg : b < limitingGain := by dsimp [b]; linarith
    exact (scalarRatio_monotone_before_limitingGain ⟨ha,hlt⟩ ⟨by linarith,hbg⟩ hab.le).trans_lt
      (scalarRatio_strictMono_before_limitingGain ⟨hb0.le,hbg.le⟩ ⟨limitingGain_mem.1.le,le_rfl⟩ hbg)
  · let b := (limitingGain+min a (5/4))/2
    have hm : limitingGain < min a (5/4) := lt_min hgt limitingGain_mem.2
    have hgb : limitingGain < b := by dsimp [b]; linarith
    have hba : b < a := by have hh := min_le_left a (5/4); dsimp [b]; linarith
    have hb1 : b < 5/4 := by have hh := min_le_right a (5/4); dsimp [b]; linarith
    exact (scalarRatio_antitone_after_limitingGain hgb hgt hba.le).trans_lt
      (scalarRatio_strictAnti_after_limitingGain ⟨le_rfl,limitingGain_mem.2.le⟩ ⟨hgb.le,hb1.le⟩ hgb)

theorem scalarRatio_global_max (a : ℝ) (ha : 0 < a) :
    scalarF0 a/a ≤ scalarF0 limitingGain/limitingGain := by
  by_cases he : a=limitingGain
  · simp [he]
  · exact (scalarRatio_global_strict_max a ha he).le

end NeuralGeneralization.OnlineLowerTanh
