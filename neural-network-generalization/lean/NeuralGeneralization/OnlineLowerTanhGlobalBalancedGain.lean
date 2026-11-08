import NeuralGeneralization.OnlineLowerTanhGainIdentification
import NeuralGeneralization.OnlineLowerTanhSmallGain

/-! Global positive-gain optimality of the actual balanced optimizer. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set Complex
namespace NeuralGeneralization.OnlineLowerTanh

lemma continuousOn_balancedRatio_pos (r:ℕ) {D:Set ℝ} (hD:∀x∈D,0<x) :
    ContinuousOn (balancedRatio r) D :=
  (continuous_balancedParity r).continuousOn.div continuousOn_id (fun x hx=>(hD x hx).ne')

lemma balancedRatio_strictMono_before_stationary (r:ℕ) (a:ℝ) (ha:1≤a)
    (hroot:balancedStationary r a=0) : StrictMonoOn (balancedRatio r) (Icc 1 a) := by
  apply strictMonoOn_of_deriv_pos (convex_Icc _ _)
    (continuousOn_balancedRatio_pos r (fun x hx=>by linarith [hx.1]))
  intro x hx
  rw [interior_Icc] at hx
  have hxp:0<x := by linarith [hx.1]
  rw [(hasDerivAt_balancedRatio r x hxp.ne').deriv]
  apply div_pos
  · have hh:=balancedStationary_strictAntiOn r hx.1.le ha hx.2
    rwa [hroot] at hh
  · positivity

lemma balancedRatio_strictAnti_after_stationary (r:ℕ) (a:ℝ) (ha:1≤a)
    (hroot:balancedStationary r a=0) : StrictAntiOn (balancedRatio r) (Ici a) := by
  apply strictAntiOn_of_deriv_neg (convex_Ici _)
    (continuousOn_balancedRatio_pos r (fun x hx=>by change a≤x at hx; linarith))
  intro x hx
  rw [interior_Ici] at hx
  have hxp:0<x := by change a<x at hx; linarith
  rw [(hasDerivAt_balancedRatio r x hxp.ne').deriv]
  apply div_neg_of_neg_of_pos
  · have hh:=balancedStationary_strictAntiOn r ha (le_trans ha hx.le) hx
    rwa [hroot] at hh
  · positivity

lemma balancedGain_interior_of_large (b:ActualGainBranch) (r:ℕ)
    (hr:b.threshold<(2*r+1:ℕ)) : balancedGain r∈Ioo (1:ℝ) 2 := by
  have hn:0<((2*r+1:ℕ):ℂ).re := by simp; positivity
  have hnN:b.threshold<‖((2*r+1:ℕ):ℂ)‖ := by simpa only [Complex.norm_natCast] using hr
  have hmem:=(b.root ((2*r+1:ℕ):ℂ) hn hnN).1
  rw [actualGainBranch_eq_balancedGain b r hr] at hmem
  have hnear:dist (balancedGain r:ℂ) (limitingGain:ℂ)<(1/8:ℝ) := by
    have hh:dist (balancedGain r:ℂ) (limitingGain:ℂ)≤b.radius:=hmem
    linarith [b.radius_small,b.radius_pos]
  have hh:=limitingGain_disk_bounds hnear
  simpa only [Set.mem_Ioo,Complex.ofReal_re,Complex.norm_real,Real.norm_eq_abs,
    abs_of_pos (balancedGain_pos r)] using hh

lemma balancedGain_stationary_of_large (b:ActualGainBranch) (r:ℕ)
    (hr:b.threshold<(2*r+1:ℕ)) : balancedStationary r (balancedGain r)=0 := by
  have ha:=balancedGain_interior_of_large b r hr
  have hn:0<((2*r+1:ℕ):ℂ).re := by simp; positivity
  have hnN:b.threshold<‖((2*r+1:ℕ):ℂ)‖ := by simpa only [Complex.norm_natCast] using hr
  have hroot:=(b.root ((2*r+1:ℕ):ℂ) hn hnN).2.1
  rw [actualGainBranch_eq_balancedGain b r hr,complexStationary_odd_eq_balanced r _ ha.1] at hroot
  have hh:balancedStationary r (balancedGain r)/oddParityKappa r=0 := by exact_mod_cast hroot
  exact (div_eq_zero_iff.mp hh).resolve_right (oddParityKappa_pos r).ne'

/-- Strict global optimality for every positive gain, at every sufficiently
large finite odd degree. -/
theorem balancedGain_global_strict_max (b:ActualGainBranch) (r:ℕ) (hr2:2≤r)
    (hr:b.threshold<(2*r+1:ℕ)) (a:ℝ) (ha:0<a) (hne:a≠balancedGain r) :
    balancedRatio r a<balancedRatio r (balancedGain r) := by
  have hg:=balancedGain_interior_of_large b r hr
  have hz:=balancedGain_stationary_of_large b r hr
  have hbefore:=balancedRatio_strictMono_before_stationary r (balancedGain r) hg.1.le hz
  have hafter:=balancedRatio_strictAnti_after_stationary r (balancedGain r) hg.1.le hz
  by_cases ha1:a≤1
  · have hsmall:balancedRatio r a≤balancedRatio r 1 :=
      (balancedRatio_strictMono_small r hr2).monotoneOn ⟨ha,ha1⟩ (by norm_num) ha1
    exact hsmall.trans_lt (hbefore ⟨le_rfl,hg.1.le⟩ ⟨hg.1.le,le_rfl⟩ hg.1)
  · have ha1:1<a := lt_of_not_ge ha1
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · exact hbefore ⟨ha1.le,hlt.le⟩ ⟨hg.1.le,le_rfl⟩ hlt
    · exact hafter (Set.mem_Ici.mpr le_rfl)
        (show a∈Ici (balancedGain r) from hgt.le) hgt

lemma scalarRatio_hasDerivAt (a:ℝ) (ha:6/5<a) :
    HasDerivAt (fun x:ℝ=>scalarF0 x/x) (scalarStationary a/a^2) a := by
  have h:=(hasDerivAt_scalarF0 a ha).div (hasDerivAt_id a) (by linarith : a≠0)
  convert h using 1 <;> try rfl
  simp only [scalarStationary,id_eq,mul_one]
  ring

lemma scalarRatio_strictMono_before_limitingGain :
    StrictMonoOn (fun a:ℝ=>scalarF0 a/a) (Icc (123/100) limitingGain) := by
  apply strictMonoOn_of_deriv_pos (convex_Icc _ _)
    (fun a ha=>(scalarRatio_hasDerivAt a (by linarith [ha.1])).continuousAt.continuousWithinAt)
  intro a ha
  rw [interior_Icc] at ha
  rw [(scalarRatio_hasDerivAt a (by linarith [ha.1])).deriv]
  apply div_pos
  · have hh:=scalarStationary_strictAntiOn
      (show a∈Icc (123/100) (5/4) from ⟨ha.1.le,le_trans ha.2.le limitingGain_mem.2.le⟩)
      (show limitingGain∈Icc (123/100) (5/4) from ⟨limitingGain_mem.1.le,limitingGain_mem.2.le⟩) ha.2
    rwa [limitingGain_stationary] at hh
  · exact sq_pos_of_pos (by linarith [ha.1])

lemma scalarRatio_strictAnti_after_limitingGain :
    StrictAntiOn (fun a:ℝ=>scalarF0 a/a) (Icc limitingGain (5/4)) := by
  apply strictAntiOn_of_deriv_neg (convex_Icc _ _)
    (fun a ha=>(scalarRatio_hasDerivAt a (by linarith [ha.1,limitingGain_mem.1])).continuousAt.continuousWithinAt)
  intro a ha
  rw [interior_Icc] at ha
  rw [(scalarRatio_hasDerivAt a (by linarith [ha.1,limitingGain_mem.1])).deriv]
  apply div_neg_of_neg_of_pos
  · have hh:=scalarStationary_strictAntiOn
      (show limitingGain∈Icc (123/100) (5/4) from ⟨limitingGain_mem.1.le,limitingGain_mem.2.le⟩)
      (show a∈Icc (123/100) (5/4) from ⟨le_trans limitingGain_mem.1.le ha.1.le,ha.2.le⟩) ha.1
    rwa [limitingGain_stationary] at hh
  · exact sq_pos_of_pos (by linarith [ha.1,limitingGain_mem.1])

end NeuralGeneralization.OnlineLowerTanh
