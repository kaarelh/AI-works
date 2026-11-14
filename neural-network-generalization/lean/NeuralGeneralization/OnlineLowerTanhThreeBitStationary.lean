import NeuralGeneralization.OnlineLowerTanhThreeBitMaximum
import Mathlib.Analysis.Calculus.LocalExtr.Rolle

/-! Uniqueness of the three-bit balanced scalar optimum, using Rolle's theorem. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open scoped BigOperators
open Set
open NeuralGeneralization.TanhDifferential
namespace NeuralGeneralization.OnlineLowerTanh

def threeBitStationary (a:ℝ) : ℝ :=
  3*a*(1-Real.tanh a^4)-Real.tanh a*(1+3*Real.tanh a^2)

def threeBitStationarySlope (a:ℝ) : ℝ :=
  2-6*Real.tanh a^2-12*a*Real.tanh a^3

lemma hasDerivAt_threeBitStationary (a:ℝ) :
    HasDerivAt threeBitStationary (tanhFirst a*threeBitStationarySlope a) a := by
  have ht:=hasDerivAt_tanh_first a
  have h:=(((hasDerivAt_id a).const_mul 3).mul ((ht.pow 4).const_sub 1)).sub
    (ht.mul ((ht.pow 2).const_mul 3 |>.const_add 1))
  convert h using 1 <;> (try rfl) <;> simp only [threeBitStationary,threeBitStationarySlope,tanhFirst,Pi.sub_apply,Pi.mul_apply,Pi.pow_apply,id_eq,Nat.cast_ofNat,Nat.reduceSub,pow_one] <;> ring

lemma hasDerivAt_threeBitStationarySlope (a:ℝ) :
    HasDerivAt threeBitStationarySlope
      (-12*Real.tanh a*tanhFirst a-12*Real.tanh a^3-
        36*a*Real.tanh a^2*tanhFirst a) a := by
  have ht:=hasDerivAt_tanh_first a
  have h:=((ht.pow 2).const_mul 6 |>.const_sub 2).sub
    (((hasDerivAt_id a).const_mul 12).mul (ht.pow 3))
  convert h using 1 <;> (try rfl) <;> simp only [threeBitStationarySlope,Pi.sub_apply,Pi.mul_apply,Pi.pow_apply,id_eq,Nat.cast_ofNat,Nat.reduceSub,pow_one] <;> ring

lemma threeBitStationarySlope_strictAnti :
    StrictAntiOn threeBitStationarySlope (Ioi (0:ℝ)) := by
  apply strictAntiOn_of_deriv_neg (convex_Ioi 0)
    (fun a _=>(hasDerivAt_threeBitStationarySlope a).continuousAt.continuousWithinAt)
  intro a ha
  have ha':0<a:=by simpa only [interior_Ioi,mem_Ioi] using ha
  rw [(hasDerivAt_threeBitStationarySlope a).deriv]
  have ht:0<Real.tanh a:=three_tanh_pos ha'
  have ht':0<tanhFirst a:=sub_pos.mpr (Real.tanh_sq_lt_one a)
  have h1:0<12*Real.tanh a*tanhFirst a:=by positivity
  have h2:0<12*Real.tanh a^3:=by positivity
  have h3:0<36*a*Real.tanh a^2*tanhFirst a:=by positivity
  linarith

lemma threeBitStationary_positive_root_unique {a b:ℝ} (ha:0<a) (hb:0<b)
    (hfa:threeBitStationary a=0) (hfb:threeBitStationary b=0) : a=b := by
  have hcont:Continuous threeBitStationary:=continuous_iff_continuousAt.mpr
    (fun a=>(hasDerivAt_threeBitStationary a).continuousAt)
  have hz:threeBitStationary 0=0:=by simp [threeBitStationary]
  suffices hlt:∀a b:ℝ,0<a → a<b → threeBitStationary a=0 →
      threeBitStationary b=0 → False by
    rcases lt_trichotomy a b with h | h | h
    · exact False.elim (hlt a b ha h hfa hfb)
    · exact h
    · exact False.elim (hlt b a hb h hfb hfa)
  intro a b ha hab hfa hfb
  obtain ⟨c,hc,hcz⟩:=exists_hasDerivAt_eq_zero ha hcont.continuousOn (hz.trans hfa.symm)
    (fun x _=>hasDerivAt_threeBitStationary x)
  obtain ⟨d,hd,hdz⟩:=exists_hasDerivAt_eq_zero hab hcont.continuousOn (hfa.trans hfb.symm)
    (fun x _=>hasDerivAt_threeBitStationary x)
  have hc':threeBitStationarySlope c=0:=(mul_eq_zero.mp hcz).resolve_left
    (ne_of_gt (sub_pos.mpr (Real.tanh_sq_lt_one c)))
  have hd':threeBitStationarySlope d=0:=(mul_eq_zero.mp hdz).resolve_left
    (ne_of_gt (sub_pos.mpr (Real.tanh_sq_lt_one d)))
  have hm:=threeBitStationarySlope_strictAnti hc.1 (ha.trans hd.1) (hc.2.trans hd.1)
  rw [hc',hd'] at hm
  exact (lt_irrefl 0) hm

lemma hasDerivAt_threeBitRatio (a:ℝ) (ha:a≠0) :
    HasDerivAt (fun x=>threeBitQ x/x)
      (2*Real.tanh a^2*threeBitStationary a/((1+3*Real.tanh a^2)^2*a^2)) a := by
  have ht:=hasDerivAt_tanh_first a
  have hd:1+3*Real.tanh a^2≠0:=by positivity
  have h:=(((ht.pow 3).const_mul 2).div ((ht.pow 2).const_mul 3 |>.const_add 1) hd).div
    (hasDerivAt_id a) ha
  convert h using 1 <;> (try rfl) <;> simp only [threeBitQ,threeBitStationary,tanhFirst,Pi.div_apply,Pi.mul_apply,Pi.pow_apply,id_eq,Nat.cast_ofNat,Nat.reduceSub,pow_one] <;> field_simp <;> ring

lemma threeBit_balanced_global_stationary (a:ℝ) (ha:0<a)
    (hm:IsIntrinsicMaximizer (fun _:Fin 3=>a)) : threeBitStationary a=0 := by
  have hratio:∀b:ℝ,0<b → threeBitQ b/b≤threeBitQ a/a := by
    intro b hb
    have h:=threeBit_scalar_cap_of_global (fun _:Fin 3=>a) hm b hb.le
    have he:(fun _:Fin 3=>a)=![a,a,a]:=by funext i;fin_cases i <;> rfl
    have hs:Real.sqrt (incomingEnergy ![a,a,a])=Real.sqrt 3*a:=by
      rw [incomingEnergy_three,show a^2+a^2+a^2=3*a^2 by ring,
        Real.sqrt_mul (by norm_num : (0:ℝ)≤3),Real.sqrt_sq_eq_abs,abs_of_pos ha]
    rw [he,intrinsicGain,parityCorrelation_three_balanced,abs_neg,
      abs_of_pos (threeBitQ_pos ha),hs] at h
    apply (div_le_div_iff₀ hb ha).mpr
    have h3:Real.sqrt 3≠0:=by positivity
    field_simp at h
    nlinarith only [h]
  have hlocal:IsLocalMax (fun x=>threeBitQ x/x) a:=by
    filter_upwards [isOpen_Ioi.mem_nhds ha] with b hb
    exact hratio b hb
  have hz:=hlocal.hasDerivAt_eq_zero (hasDerivAt_threeBitRatio a ha.ne')
  have ht:Real.tanh a≠0:=(three_tanh_pos ha).ne'
  have hd:((1+3*Real.tanh a^2)^2*a^2)≠0:=by positivity
  have hnum:2*Real.tanh a^2*threeBitStationary a=0:=(div_eq_zero_iff.mp hz).resolve_right hd
  exact (mul_eq_zero.mp hnum).resolve_left (by positivity)

end NeuralGeneralization.OnlineLowerTanh
