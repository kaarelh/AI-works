import NeuralGeneralization.OnlineLowerCostEnumerator
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-! A quantitative gap for the actual finite path enumerators. -/
noncomputable section
namespace NeuralGeneralization.OnlineLower

lemma signedSeries_gap_of_lex (r : ℝ) (hr0 : 0<r) (hr:r≤1/3)
    {xs ys:List Bool} (h:digitLexLt xs ys) :
    r^xs.length ≤ signedSeries r ys-signedSeries r xs := by
  induction xs generalizing ys with
  | nil => exact h.elim
  | cons a xs ih =>
    cases ys with
    | nil => exact h.elim
    | cons b ys =>
      rcases h with ⟨ha,hb⟩ | ⟨hab,ht⟩
      · subst a;subst b
        have hx:=abs_le.mp (signedSeries_abs_le r hr0.le hr xs)
        have hy:=abs_le.mp (signedSeries_abs_le r hr0.le hr ys)
        have hxu:=mul_le_mul_of_nonneg_left hx.2 hr0.le
        have hyl:=mul_le_mul_of_nonneg_left hy.1 hr0.le
        have hp:r^(false::xs).length≤1:=pow_le_one₀ hr0.le (by linarith)
        simp only [signedSeries,digitSign,Bool.false_eq_true,if_false,if_true]
        nlinarith
      · subst b
        have hm:=mul_le_mul_of_nonneg_left (ih ht) hr0.le
        simpa only [List.length_cons,pow_succ,signedSeries] using (show
          r^xs.length*r ≤ digitSign a+r*signedSeries r ys-(digitSign a+r*signedSeries r xs) by nlinarith)

lemma path_small_interval_bounds (x:ℝ) (hx:1/2≤x) (hx1:x≤1) :
    1/48≤pathRatio x ∧ 1/6≤pathSlope x ∧
      (1-x)/4≤pathBlockScale x ∧ 1/48≤x^2*pathSlope x/(1+x^2) := by
  have hx0:0≤x:=by linarith
  have hx2:x^2≤1:=pow_le_one₀ hx0 hx1
  have hx3:x^3≤1:=pow_le_one₀ hx0 hx1
  have hx4:x^4≤1:=pow_le_one₀ hx0 hx1
  have hx6:x^6≤x:=by simpa only [pow_one] using (pow_le_pow_of_le_one hx0 hx1 (by norm_num : 1≤6))
  have hxlo:(1/2:ℝ)^4≤x^4:=pow_le_pow_left₀ (by norm_num) hx 4
  have hratio:1/48≤pathRatio x:=by
    unfold pathRatio
    apply (le_div_iff₀ (pathDenominator_pos x)).mpr
    norm_num at hxlo
    nlinarith
  have hslope:1/6≤pathSlope x:=by
    unfold pathSlope
    apply (le_div_iff₀ (pathDenominator_pos x)).mpr
    nlinarith [mul_nonneg hx0 (sq_nonneg x)]
  have hden: (1+x^2)^2*(1+x^3)*(1+x)≤16:=by
    calc
      _ ≤ (2:ℝ)^2*2*2:=by gcongr <;> linarith
      _ = _:=by norm_num
  have hblock:(1-x)/4≤pathBlockScale x:=by
    unfold pathBlockScale
    apply (le_div_iff₀ (by positivity : 0<(1+x^2)^2*(1+x^3)*(1+x))).mpr
    have hh:=mul_le_mul_of_nonneg_left hden (show 0≤(1-x)/4 by linarith)
    nlinarith
  refine ⟨hratio,hslope,hblock,?_⟩
  apply (le_div_iff₀ (by positivity : 0<1+x^2)).mpr
  have hx2lo:(1/4:ℝ)≤x^2:=by nlinarith
  have hm:=mul_le_mul_of_nonneg_left hslope (sq_nonneg x)
  nlinarith

lemma candidatePathEnumerator_gap (x:ℝ) (hx:1/2≤x) (hx1:x<1)
    (endpoint:Bool) {xs ys:List Bool} (hlen:xs.length=ys.length)
    (hlex:digitLexLt xs ys) :
    (1/48)*(pathBlockScale x*pathRatio x)^(xs.length+1) ≤
      candidatePathEnumerator x endpoint ys-candidatePathEnumerator x endpoint xs := by
  have hx0:0<x:=by linarith
  have hb:=path_small_interval_bounds x hx hx1.le
  have hS:=signedSeries_gap_of_lex (pathRatio x) (pathRatio_pos x hx0)
    (pathRatio_le_third x hx0.le hx1.le) hlex
  have hL:=pathBlockScale_pos x hx0 hx1
  have hR:=pathRatio_pos x hx0
  have hB:=pathSlope_pos x hx0
  have he: candidatePathEnumerator x endpoint ys-candidatePathEnumerator x endpoint xs =
      (x^2*pathSlope x/(1+x^2))*pathBlockScale x^(xs.length+1)*pathRatio x*
        (signedSeries (pathRatio x) ys-signedSeries (pathRatio x) xs) := by
    rw [candidatePathEnumerator_formula x hx0.le,candidatePathEnumerator_formula x hx0.le,←hlen]
    unfold pathBoundaryScalar
    ring
  rw [he]
  calc
    _ = (1/48)*pathBlockScale x^(xs.length+1)*pathRatio x*(pathRatio x)^xs.length := by
      rw [mul_pow,pow_succ];ring
    _ ≤ (x^2*pathSlope x/(1+x^2))*pathBlockScale x^(xs.length+1)*pathRatio x*
        (signedSeries (pathRatio x) ys-signedSeries (pathRatio x) xs) := by
      have hcoef := mul_le_mul_of_nonneg_right
        (mul_le_mul_of_nonneg_right hb.2.2.2 (pow_nonneg hL.le (xs.length+1))) hR.le
      exact mul_le_mul hcoef hS (pow_nonneg hR.le _) (by positivity)

lemma exp_path_scale_lower (t:ℝ) (ht:0<t) (ht1:t≤1/4) :
    1/2≤Real.exp (-2*t) ∧ Real.exp (-2*t)<1 ∧
      t/4≤pathBlockScale (Real.exp (-2*t)) := by
  let x:=Real.exp (-2*t)
  have hx0:0<x:=Real.exp_pos _
  have hxhalf:1/2≤x:=by
    have hh:=Real.add_one_le_exp (-2*t)
    dsimp [x];linarith
  have hx1:x<1:=by dsimp [x];rw [Real.exp_lt_one_iff];linarith
  have hid:x*Real.exp (2*t)=1:=by
    dsimp [x];rw [←Real.exp_add,show -2*t+2*t=0 by ring,Real.exp_zero]
  have he:=mul_le_mul_of_nonneg_left (Real.add_one_le_exp (2*t)) hx0.le
  rw [hid] at he
  have htx:0≤t*(2*x-1):=mul_nonneg ht.le (by linarith)
  have hxt:t≤1-x:=by nlinarith
  have hb:=(path_small_interval_bounds x hxhalf hx1.le).2.2.1
  exact ⟨hxhalf,hx1,(by linarith)⟩

/-- The paper's uniform small-t scalar gap, with the explicit base 9216. -/
theorem candidatePathEnumerator_uniform_gap (t:ℝ) (ht:0<t) (ht1:t≤1/4)
    (endpoint:Bool) {xs ys:List Bool} (hlen:xs.length=ys.length) (hne:xs≠ys) :
    (t/9216)^(xs.length+1) ≤
      |candidatePathEnumerator (Real.exp (-2*t)) endpoint ys-
        candidatePathEnumerator (Real.exp (-2*t)) endpoint xs| := by
  let x:=Real.exp (-2*t)
  obtain ⟨hx,hx1,hL⟩:=exp_path_scale_lower t ht ht1
  have hR:1/48≤pathRatio x:=(path_small_interval_bounds x hx hx1.le).1
  have hgap (xs ys:List Bool) (hlen:xs.length=ys.length) (hlex:digitLexLt xs ys) :
      (t/9216)^(xs.length+1)≤candidatePathEnumerator x endpoint ys-candidatePathEnumerator x endpoint xs:=by
    have hprod:t/192≤pathBlockScale x*pathRatio x:=by
      have hh:=mul_le_mul hL hR (by norm_num : (0:ℝ)≤1/48) (pathBlockScale_pos x (by linarith) hx1).le
      nlinarith
    have hp:=pow_le_pow_left₀ (by positivity : (0:ℝ)≤t/192) hprod (xs.length+1)
    have hconst:(1/48:ℝ)^(xs.length+1)≤1/48:=by simpa only [pow_one] using (pow_le_pow_of_le_one (by norm_num : (0:ℝ)≤1/48) (by norm_num : (1/48:ℝ)≤1) (by omega : 1≤xs.length+1))
    calc
      _ = (1/48:ℝ)^(xs.length+1)*(t/192)^(xs.length+1):=by rw [←mul_pow];congr 1;ring
      _ ≤ (1/48)*(pathBlockScale x*pathRatio x)^(xs.length+1):=
        mul_le_mul hconst hp (by positivity) (by norm_num)
      _ ≤ _:=candidatePathEnumerator_gap x hx hx1 endpoint hlen hlex
  rcases digitLexLt_or_reverse hlen hne with h | h
  · exact (hgap xs ys hlen h).trans (le_abs_self _)
  · have hh:=hgap ys xs hlen.symm h
    rw [←hlen] at hh
    exact hh.trans (by rw [abs_sub_comm];exact le_abs_self _)

/-- Literal exp(-C k)t^k form of the manuscript, C=log(9216), t₀=1/4. -/
theorem candidatePathEnumerator_exponential_gap (t:ℝ) (ht:0<t) (ht1:t≤1/4)
    (endpoint:Bool) {xs ys:List Bool} (hlen:xs.length=ys.length) (hne:xs≠ys) :
    Real.exp (-Real.log 9216*(xs.length+1))*t^(xs.length+1) ≤
      |candidatePathEnumerator (Real.exp (-2*t)) endpoint ys-
        candidatePathEnumerator (Real.exp (-2*t)) endpoint xs| := by
  have hh:=candidatePathEnumerator_uniform_gap t ht ht1 endpoint hlen hne
  have he:Real.exp (-Real.log 9216*(xs.length+1))*t^(xs.length+1)=(t/9216)^(xs.length+1):=by
    rw [show -Real.log 9216*(xs.length+1)=((xs.length+1:ℕ):ℝ)*(-Real.log 9216) by push_cast;ring,
      Real.exp_nat_mul,Real.exp_neg,Real.exp_log (by norm_num : (0:ℝ)<9216),←mul_pow]
    congr 1;ring
  rwa [he]

end NeuralGeneralization.OnlineLower
