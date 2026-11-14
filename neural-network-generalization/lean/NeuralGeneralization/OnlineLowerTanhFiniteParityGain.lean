import NeuralGeneralization.OnlineLowerTanhGlobalBalancedGain
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Analysis.Calculus.LocalExtr.Basic

/-! Finite-degree balanced gain: the optimum is in (1,2) at every odd degree at least five. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators Topology
open Set
namespace NeuralGeneralization.OnlineLowerTanh
open TanhDifferential

lemma smallGainTerm_rescale (r : ℕ) (C a s : ℝ) (hs : s ≠ 0) :
    smallGainTerm r C (s*a) = (s⁻¹)^2 * smallGainTerm r (C/s^2) a := by
  unfold smallGainTerm
  have hp : (∏j∈Finset.range (r+1), (C+(2*(j:ℝ)+1)^2*(s*a)^2)) =
      (s^2)^(r+1) * ∏j∈Finset.range (r+1), (C/s^2+(2*(j:ℝ)+1)^2*a^2) := by
    calc
      _ = ∏j∈Finset.range (r+1), s^2*(C/s^2+(2*(j:ℝ)+1)^2*a^2) := by
        apply Finset.prod_congr rfl
        intro j hj
        field_simp
        <;> ring
      _ = _ := by rw [Finset.prod_mul_distrib]; simp
  rw [hp,mul_pow,pow_succ,pow_mul]
  generalize (∏j∈Finset.range (r+1), (C/s^2+(2*(j:ℝ)+1)^2*a^2)) = P
  by_cases hP : P=0
  · simp [hP]
  · field_simp
    <;> ring

lemma sineDecay_rescaled_square_lower (l : ℕ) :
    (12:ℝ)/5 ≤ sineDecay l^2/(101/100)^2 := by
  have hl : (0:ℝ)≤l := Nat.cast_nonneg l
  have hpi := Real.pi_gt_d2
  have hc : Real.pi/2≤sineDecay l := by
    unfold sineDecay
    nlinarith [Real.pi_pos]
  have hp := Real.pi_pos
  norm_num
  nlinarith

lemma balancedRatio_strictMono_beyond_one (r : ℕ) (hr : 2≤r) :
    StrictMonoOn (balancedRatio r) (Ioc 0 (101/100)) := by
  intro a ha b hb hab
  have hfac : 0<2*((2*r+1).factorial:ℝ) := by positivity
  have hterm (l : ℕ) : smallGainTerm r (sineDecay l^2) a <
      smallGainTerm r (sineDecay l^2) b := by
    have h := smallGainTerm_strictMono r hr (sineDecay l^2/(101/100)^2)
      (sineDecay_rescaled_square_lower l)
      (show a/(101/100)∈Ioc (0:ℝ) 1 from ⟨div_pos ha.1 (by norm_num),by linarith [ha.2]⟩)
      (show b/(101/100)∈Ioc (0:ℝ) 1 from ⟨div_pos hb.1 (by norm_num),by linarith [hb.2]⟩)
      (by linarith : a/(101/100)<b/(101/100))
    have h1 := smallGainTerm_rescale r (sineDecay l^2) (a/(101/100)) (101/100) (by norm_num)
    have h2 := smallGainTerm_rescale r (sineDecay l^2) (b/(101/100)) (101/100) (by norm_num)
    have hsa : (101/100:ℝ)*(a/(101/100))=a := by ring
    have hsb : (101/100:ℝ)*(b/(101/100))=b := by ring
    rw [hsa] at h1
    rw [hsb] at h2
    rw [h1,h2]
    exact mul_lt_mul_of_pos_left h (by norm_num)
  exact hasSum_lt (fun l => (mul_lt_mul_of_pos_left (hterm l) hfac).le)
    (mul_lt_mul_of_pos_left (hterm 0) hfac)
    (balancedRatio_smallGain_hasSum r a ha.1) (balancedRatio_smallGain_hasSum r b hb.1)

lemma balancedStationary_one_pos (r : ℕ) (hr : 2≤r) : 0<balancedStationary r 1 := by
  by_contra h
  have hnon : balancedStationary r 1≤0 := le_of_not_gt h
  have hm : StrictAntiOn (balancedRatio r) (Ici 1) := by
    apply strictAntiOn_of_deriv_neg (convex_Ici _)
      (continuousOn_balancedRatio_pos r (fun x hx=>by change 1≤x at hx; linarith))
    intro x hx
    rw [interior_Ici] at hx
    change 1<x at hx
    rw [(hasDerivAt_balancedRatio r x (by linarith : x≠0)).deriv]
    apply div_neg_of_neg_of_pos
    · exact (balancedStationary_strictAntiOn r (by simp) hx.le hx).trans_le hnon
    · positivity
  have hp := balancedRatio_strictMono_beyond_one r hr
    (show (1:ℝ)∈Ioc 0 (101/100) by norm_num)
    (show (101/100:ℝ)∈Ioc 0 (101/100) by norm_num) (by norm_num)
  have hn := hm (show (1:ℝ)∈Ici 1 by simp)
    (show (101/100:ℝ)∈Ici 1 by norm_num) (by norm_num)
  linarith

def finiteGainTail (t : ℝ) : ℝ := t*tanhFirst t+1-Real.tanh t

lemma finiteGainTail_hasDerivAt (t : ℝ) :
    HasDerivAt finiteGainTail (t*tanhSecond t) t := by
  have h := (((hasDerivAt_id t).mul (hasDerivAt_tanhFirst t)).add_const 1).sub
    (hasDerivAt_tanh_first t)
  convert h using 1 <;> try rfl
  simp only [id_eq,one_mul]
  ring

lemma finiteGainTail_nonneg {t : ℝ} (ht : 0≤t) : 0≤finiteGainTail t := by
  unfold finiteGainTail
  have hh:=mul_nonneg ht (tanhFirst_nonneg t)
  linarith [Real.tanh_lt_one t]

lemma finiteGainTail_antitone : AntitoneOn finiteGainTail (Ici 0) := by
  apply antitoneOn_of_deriv_nonpos (convex_Ici _) (fun x _ =>
    (finiteGainTail_hasDerivAt x).continuousAt.continuousWithinAt)
    (fun x _ => (finiteGainTail_hasDerivAt x).differentiableAt.differentiableWithinAt)
  intro x hx
  rw [interior_Ici] at hx
  change 0<x at hx
  rw [(finiteGainTail_hasDerivAt x).deriv]
  have ht:0≤Real.tanh x := by
    simpa only [Real.tanh_zero] using scalar_tanh_monotone hx.le
  unfold tanhSecond
  have hh:=mul_nonneg ht (tanhFirst_nonneg x)
  nlinarith

lemma finiteGainTail_exp (t : ℝ) :
    finiteGainTail t = 4*t*Real.exp (2*t)/(1+Real.exp (2*t))^2 + 2/(1+Real.exp (2*t)) := by
  unfold finiteGainTail tanhFirst
  rw [TanhSaturation.tanh_exp_formula]
  have he:=Real.exp_pos (2*t)
  field_simp
  <;> ring

lemma finiteGainTail_two_lt_half : finiteGainTail 2 < (1/2:ℝ) := by
  rw [finiteGainTail_exp]
  have he2:7<Real.exp 2 := by
    have h:=Real.exp_one_gt_d9
    rw [show (2:ℝ)=1+1 by norm_num,Real.exp_add]
    nlinarith [Real.exp_pos 1]
  have he4:49<Real.exp 4 := by
    rw [show (4:ℝ)=2+2 by norm_num,Real.exp_add]
    nlinarith [Real.exp_pos 2]
  norm_num
  have he:=Real.exp_pos 4
  apply (lt_div_iff₀ (by norm_num : (0:ℝ)<2)).mpr
  field_simp
  nlinarith

lemma balancedParityFirst_centered (r : ℕ) (a : ℝ) :
    balancedParityFirst r a = (1:ℝ)/4^r *
      ∑j∈Finset.range (r+1), (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*
        (tanhFirst (a*(2*j+1))*(2*j+1)) := by
  have h := (HasDerivAt.sum (u:=Finset.range (r+1)) (fun j hj =>
    ((hasDerivAt_tanh_first (a*(2*j+1))).comp a
      ((hasDerivAt_id a).mul_const (2*j+1))).const_mul
        ((-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)))).const_mul ((1:ℝ)/4^r)
  have he : (fun a:ℝ => (1:ℝ)/4^r * ∑j∈Finset.range (r+1),
      (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*Real.tanh (a*(2*j+1))) = balancedParity r :=
    funext (fun a => (balancedParity_centered r a).symm)
  simp only [Finset.sum_apply,Function.comp_apply,id_eq,one_mul] at h
  rw [he] at h
  simpa only [one_mul] using (hasDerivAt_balancedParity r a).unique h

lemma balancedStationary_tail_formula (r : ℕ) (a : ℝ) :
    balancedStationary r a = -oddParityKappa r + (1:ℝ)/4^r *
      ∑j∈Finset.range (r+1), (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*
        finiteGainTail (a*(2*j+1)) := by
  have hg : (∑j∈Finset.range (r+1), (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*
        finiteGainTail (a*(2*j+1))) =
      a*(∑j∈Finset.range (r+1), (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*
        (tanhFirst (a*(2*j+1))*(2*j+1))) +
      (∑j∈Finset.range (r+1), (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)) -
      (∑j∈Finset.range (r+1), (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*
        Real.tanh (a*(2*j+1))) := by
    rw [Finset.mul_sum,← Finset.sum_add_distrib,← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro j hj
    unfold finiteGainTail
    ring
  rw [hg,centered_choose_alternating]
  unfold balancedStationary
  rw [balancedParityFirst_centered,balancedParity_centered]
  unfold oddParityKappa
  ring

lemma balancedStationary_two_neg (r : ℕ) : balancedStationary r 2<0 := by
  let f:ℕ→ℝ := fun j => ((2*r+1).choose (r-j):ℝ)*finiteGainTail (2*(2*j+1))
  have hf (j:ℕ):0≤f j := mul_nonneg (Nat.cast_nonneg _)
    (finiteGainTail_nonneg (by positivity))
  have hm (j:ℕ):f (j+1)≤f j := by
    apply mul_le_mul
    · exact_mod_cast centered_choose_antitone r j
    · apply finiteGainTail_antitone (show 0≤2*(2*(j:ℝ)+1) by positivity)
        (show 0≤2*(2*((j+1:ℕ):ℝ)+1) by positivity)
      push_cast
      linarith
    · exact finiteGainTail_nonneg (by positivity)
    · exact Nat.cast_nonneg _
  have hsum := (alternating_nonnegative_antitone (r+1) f hf hm).2
  have hscale:0<(1:ℝ)/4^r := by positivity
  have hh:=mul_le_mul_of_nonneg_left hsum hscale.le
  have hchoose:=mul_le_mul_of_nonneg_right (centered_choose_le_twice r)
    (finiteGainTail_nonneg (by norm_num : (0:ℝ)≤2))
  have hc:=mul_le_mul_of_nonneg_left hchoose hscale.le
  have hk:=oddParityKappa_pos r
  have htail:=finiteGainTail_two_lt_half
  have hp:=mul_lt_mul_of_pos_left htail (show 0<2*oddParityKappa r by positivity)
  rw [balancedStationary_tail_formula]
  simp only [f,Nat.sub_zero,Nat.cast_zero,mul_zero,zero_add,mul_one] at hh
  unfold oddParityKappa at *
  simp only [div_eq_mul_inv] at hp hc hh ⊢
  simp_rw [mul_assoc] at hh ⊢
  nlinarith only [hh,hc,hp]

/-- Every finite odd degree at least five has its unique stationary balanced
optimizer strictly between one and two; no eventual-degree premise occurs. -/
theorem balancedGain_interior_and_stationary (r : ℕ) (hr : 2≤r) :
    balancedGain r ∈ Ioo (1:ℝ) 2 ∧ balancedStationary r (balancedGain r)=0 := by
  have h1:=balancedStationary_one_pos r hr
  have h2:=balancedStationary_two_neg r
  have hc:ContinuousOn (balancedStationary r) (Icc (1:ℝ) 2) :=
    fun a _ => (hasDerivAt_balancedStationary r a).continuousAt.continuousWithinAt
  obtain ⟨a,ha,hroot⟩ := intermediate_value_Icc' (by norm_num : (1:ℝ)≤2) hc
    (show (0:ℝ)∈Icc (balancedStationary r 2) (balancedStationary r 1) from ⟨h2.le,h1.le⟩)
  have ha' : a∈Ioo (1:ℝ) 2 := by
    constructor
    · rcases ha.1.eq_or_lt with h | h
      · subst a; linarith
      · exact h
    · rcases ha.2.eq_or_lt with h | h
      · subst a; linarith
      · exact h
  have he:=balancedGain_eq_of_stationary r a ha' hroot
  rw [he]
  exact ⟨ha',hroot⟩

/-- Strict global balanced-gain optimality at every odd degree at least five. -/
theorem balancedGain_finite_global_strict_max (r:ℕ) (hr:2≤r)
    (a:ℝ) (ha:0<a) (hne:a≠balancedGain r) :
    balancedRatio r a<balancedRatio r (balancedGain r) := by
  obtain ⟨hg,hz⟩:=balancedGain_interior_and_stationary r hr
  have hbefore:=balancedRatio_strictMono_before_stationary r (balancedGain r) hg.1.le hz
  have hafter:=balancedRatio_strictAnti_after_stationary r (balancedGain r) hg.1.le hz
  by_cases ha1:a≤1
  · have hsmall:balancedRatio r a≤balancedRatio r 1 :=
      (balancedRatio_strictMono_small r hr).monotoneOn ⟨ha,ha1⟩ (by norm_num) ha1
    exact hsmall.trans_lt (hbefore ⟨le_rfl,hg.1.le⟩ ⟨hg.1.le,le_rfl⟩ hg.1)
  · have ha1:1<a := lt_of_not_ge ha1
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · exact hbefore ⟨ha1.le,hlt.le⟩ ⟨hg.1.le,le_rfl⟩ hlt
    · exact hafter (Set.mem_Ici.mpr le_rfl)
        (show a∈Ici (balancedGain r) from hgt.le) hgt

/-- The balanced ratio has exactly one global positive-gain maximizer. -/
theorem balancedGain_finite_unique_max (r : ℕ) (hr : 2≤r) :
    balancedGain r ∈ Ioo (1:ℝ) 2 ∧
      ∀a:ℝ,0<a → balancedRatio r a≤balancedRatio r (balancedGain r) ∧
        (balancedRatio r a=balancedRatio r (balancedGain r) ↔ a=balancedGain r) := by
  refine ⟨(balancedGain_interior_and_stationary r hr).1,?_⟩
  intro a ha
  by_cases he:a=balancedGain r
  · simp [he]
  · have hh:=balancedGain_finite_global_strict_max r hr a ha he
    exact ⟨hh.le,⟨fun h => False.elim (hh.ne h),fun h => False.elim (he h)⟩⟩

end NeuralGeneralization.OnlineLowerTanh
