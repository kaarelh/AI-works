import NeuralGeneralization.OnlineLowerTanhPositiveSeries
import Mathlib.Analysis.Real.Pi.Bounds
import Mathlib.Topology.Algebra.InfiniteSum.Order

/-! # Strict increase of the actual balanced gain below one

The proof is termwise algebra in the positive rational series. It avoids
differentiating an infinite sum.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Set
namespace NeuralGeneralization.OnlineLowerTanh

def smallGainBase (C a : ℝ) : ℝ :=
  a^4/((C+a^2)*(C+9*a^2)*(C+25*a^2))

def smallGainTerm (r : ℕ) (C a : ℝ) : ℝ :=
  a^(2*r)/(∏j∈Finset.range (r+1), (C+(2*(j:ℝ)+1)^2*a^2))

lemma smallGain_polynomial_pos (C x y : ℝ) (hC : 12/5≤C)
    (hx : 0<x) (hy : 0<y) (hx1 : x≤1) (hy1 : y≤1) :
    0<C^3*(x+y)+35*C^2*x*y-225*x^2*y^2 := by
  have hC0 : 0<C := by linarith
  have hC2 := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤12/5) hC 2
  have hC3 := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤12/5) hC 3
  have hconst : 0<2*C^3+35*C^2-225 := by nlinarith only [hC2,hC3]
  have hxy : 0<x*y := mul_pos hx hy
  have hsum : 2*(x*y)≤x+y := by
    have h1 := mul_le_mul_of_nonneg_right hx1 hy.le
    have h2 := mul_le_mul_of_nonneg_right hy1 hx.le
    nlinarith only [h1,h2]
  have hxy1 : x*y≤1 := mul_le_one₀ hx1 hy.le hy1
  have hsq : (x*y)^2≤x*y := by nlinarith [mul_le_mul_of_nonneg_left hxy1 hxy.le]
  have hfirst := mul_le_mul_of_nonneg_left hsum (pow_nonneg hC0.le 3)
  have hlast := mul_le_mul_of_nonneg_left hsq (show (0:ℝ)≤225 by norm_num)
  have hpos := mul_pos hconst hxy
  nlinarith only [hfirst,hlast,hpos]

lemma smallGainBase_pos (C a : ℝ) (hC : 0<C) (ha : 0<a) :
    0<smallGainBase C a := by unfold smallGainBase; positivity

lemma smallGainBase_strictMono (C : ℝ) (hC : 12/5≤C) :
    StrictMonoOn (smallGainBase C) (Ioc 0 1) := by
  intro a ha b hb hab
  have ha0 := ha.1
  have hb0 := hb.1
  have hC0 : 0<C := by linarith
  have ha2 : 0<a^2 := sq_pos_of_pos ha.1
  have hb2 : 0<b^2 := sq_pos_of_pos hb.1
  have ha21 : a^2≤1 := pow_le_one₀ ha.1.le ha.2
  have hb21 : b^2≤1 := pow_le_one₀ hb.1.le hb.2
  have hbracket := smallGain_polynomial_pos C (a^2) (b^2) hC ha2 hb2 ha21 hb21
  have hdiff : 0<b^2-a^2 := by nlinarith [ha.1]
  have hpos := mul_pos hdiff hbracket
  unfold smallGainBase
  apply (div_lt_div_iff₀ (by positivity) (by positivity)).mpr
  have hid : b^4*((C+a^2)*(C+9*a^2)*(C+25*a^2))-
      a^4*((C+b^2)*(C+9*b^2)*(C+25*b^2)) =
      (b^2-a^2)*(C^3*(a^2+b^2)+35*C^2*a^2*b^2-225*(a^2)^2*(b^2)^2) := by ring
  nlinarith only [hid,hpos]

lemma smallGainFactor_mono (C k a b : ℝ) (hC : 0<C) (hk : 0≤k)
    (ha : 0<a) (hab : a≤b) :
    a^2/(C+k*a^2)≤b^2/(C+k*b^2) := by
  have hb : 0<b := ha.trans_le hab
  apply (div_le_div_iff₀ (by positivity) (by positivity)).mpr
  have hs : a^2≤b^2 := pow_le_pow_left₀ ha.le hab 2
  nlinarith [mul_le_mul_of_nonneg_left hs hC.le]

lemma smallGainTerm_factor (r : ℕ) (hr : 2≤r) (C a : ℝ) (ha : a≠0) :
    smallGainTerm r C a = smallGainBase C a *
      ∏j∈Finset.range (r-2), a^2/(C+(2*((j+3:ℕ):ℝ)+1)^2*a^2) := by
  unfold smallGainTerm smallGainBase
  rw [show r+1=3+(r-2) by omega,Finset.prod_range_add]
  simp only [Finset.prod_range_succ,Finset.prod_range_zero,one_mul]
  rw [Finset.prod_div_distrib]
  simp only [Finset.prod_const,Finset.card_range,←pow_mul]
  have hexp : 2*r=4+2*(r-2) := by omega
  rw [hexp,pow_add]
  push_cast
  norm_num
  simp only [div_eq_mul_inv,mul_inv_rev]
  ring

lemma smallGainTerm_strictMono (r : ℕ) (hr : 2≤r) (C : ℝ) (hC : 12/5≤C) :
    StrictMonoOn (smallGainTerm r C) (Ioc 0 1) := by
  intro a ha b hb hab
  have ha0 := ha.1
  have hb0 := hb.1
  have hC0 : 0<C := by linarith
  rw [smallGainTerm_factor r hr C a ha.1.ne',smallGainTerm_factor r hr C b hb.1.ne']
  have hbase := smallGainBase_strictMono C hC ha hb hab
  have hprod : (∏j∈Finset.range (r-2), a^2/(C+(2*((j+3:ℕ):ℝ)+1)^2*a^2)) ≤
      ∏j∈Finset.range (r-2), b^2/(C+(2*((j+3:ℕ):ℝ)+1)^2*b^2) := by
    apply Finset.prod_le_prod
    · intro j _; positivity
    · intro j _
      exact smallGainFactor_mono C _ a b hC0 (sq_nonneg _) ha.1 hab.le
  have hprodpos : 0<∏j∈Finset.range (r-2), a^2/(C+(2*((j+3:ℕ):ℝ)+1)^2*a^2) :=
    Finset.prod_pos (fun j _ => by positivity)
  exact (mul_lt_mul_of_pos_right hbase hprodpos).trans_le
    (mul_le_mul_of_nonneg_left hprod (smallGainBase_pos C b hC0 hb.1).le)

lemma sineDecay_square_lower (l : ℕ) : (12:ℝ)/5≤sineDecay l^2 := by
  have hl : (0:ℝ)≤l := Nat.cast_nonneg l
  have hpi := Real.pi_gt_d2
  have hc : Real.pi/2≤sineDecay l := by
    unfold sineDecay
    nlinarith [Real.pi_pos]
  nlinarith [Real.pi_pos]

/-- The positive rational series for gain divided by its incoming scale. -/
theorem balancedRatio_smallGain_hasSum (r : ℕ) (a : ℝ) (ha : 0<a) :
    HasSum (fun l => (2*((2*r+1).factorial:ℝ))*smallGainTerm r (sineDecay l^2) a)
      (balancedRatio r a) := by
  have h := (balancedParity_positive_series r a ha).div_const a
  apply h.congr_fun
  intro l
  unfold smallGainTerm
  rw [show 2*r+1=2*r+1 by rfl,pow_succ]
  field_simp
  ring

/-- For every odd degree at least five, the actual balanced gain ratio is
strictly increasing throughout the interval from zero to one. -/
theorem balancedRatio_strictMono_small (r : ℕ) (hr : 2≤r) :
    StrictMonoOn (balancedRatio r) (Ioc 0 1) := by
  intro a ha b hb hab
  have hfac : 0<2*((2*r+1).factorial:ℝ) := by positivity
  have hterm (l : ℕ) := smallGainTerm_strictMono r hr (sineDecay l^2)
    (sineDecay_square_lower l) ha hb hab
  exact hasSum_lt (fun l => (mul_lt_mul_of_pos_left (hterm l) hfac).le)
    (mul_lt_mul_of_pos_left (hterm 0) hfac)
    (balancedRatio_smallGain_hasSum r a ha.1) (balancedRatio_smallGain_hasSum r b hb.1)

end NeuralGeneralization.OnlineLowerTanh
