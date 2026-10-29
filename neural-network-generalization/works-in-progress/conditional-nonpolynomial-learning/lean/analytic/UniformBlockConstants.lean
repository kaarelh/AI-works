import PhysicalScaleRegimes
import DisjointBlockAccounting

/-! A fixed order of choices for the long nearcritical block argument.
All constants are independent of dimension, width, depth and prior scale. -/
noncomputable section
set_option maxHeartbeats 1200000
open scoped BigOperators NNReal
namespace ConditionalNonpolynomial.Analytic

theorem subcriticalCostBaseline_quarter {v : ℝ≥0} (hv : v≠0) (hv1 : (v:ℝ)≤1) :
    subcriticalCostBaseline v≤((v:ℝ)⁻¹-1)^2/4 := by
  have hv0 : (0:ℝ)<v := NNReal.coe_pos.mpr (pos_iff_ne_zero.mpr hv)
  let a := (v:ℝ)⁻¹-1
  have ha : 0≤a := by
    dsimp [a]
    have hh := (one_le_inv₀ hv0).mpr hv1
    linarith
  have hl := Real.le_log_one_add_of_nonneg ha
  have hlow : a-a^2/2≤2*a/(a+2) := by
    apply (le_div_iff₀ (by positivity : 0<a+2)).mpr
    nlinarith [pow_nonneg ha 3]
  rw [subcriticalCostBaseline_eq_a hv]
  change (a-Real.log (1+a))/2≤a^2/4
  linarith

def longBlockContraction : ℝ := 64
def longBlockSpan : ℝ := longBlockContraction+1/4
def longBlockGaussianThreshold : ℝ := 16*longBlockSpan
def longBlockMinimumGain : ℝ := Real.exp (-longBlockSpan/4-1)

theorem longBlockMinimumGain_pos : 0<longBlockMinimumGain := Real.exp_pos _

theorem longBlock_free_contraction :
    Real.exp (-(2/5:ℝ)*longBlockContraction)≤longBlockMinimumGain/32 := by
  have hlog : Real.log (32:ℝ)≤5 := by
    have hh := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    rw [show (32:ℝ)=2^5 by norm_num,Real.log_pow]
    norm_num
    linarith
  have hexp : -(2/5:ℝ)*longBlockContraction+Real.log 32≤ -longBlockSpan/4-1 := by
    dsimp [longBlockContraction,longBlockSpan]
    linarith
  have hh := Real.exp_le_exp.mpr hexp
  rw [Real.exp_add,Real.exp_log (by norm_num : (0:ℝ)<32)] at hh
  exact (le_div_iff₀ (by norm_num : (0:ℝ)<32)).mpr hh

theorem longBlock_actual_free {t a : ℝ} (ht : 0<t) (ha : 0<a) (ha1 : a≤1/4)
    (heq : a=(t^2)⁻¹-1) :
    t^⌈longBlockContraction/a⌉₊≤longBlockMinimumGain/32 := by
  have hlogid : Real.log (1+a)= -2*Real.log t := by
    rw [heq,show 1+((t^2)⁻¹-1)=(t^2)⁻¹ by ring,Real.log_inv,Real.log_pow]
    ring
  have hl := Real.le_log_one_add_of_nonneg ha.le
  have hratio : (4/5:ℝ)*a≤2*a/(a+2) := by
    apply (le_div_iff₀ (by positivity : 0<a+2)).mpr
    nlinarith [mul_nonneg ha.le (show 0≤1/4-a by linarith)]
  have hlog : Real.log t≤ -(2/5:ℝ)*a := by linarith
  obtain ⟨hb,hbc,_⟩ := ceiling_block_length ha
    (show 0<longBlockContraction by norm_num [longBlockContraction])
  have hp := mul_le_mul_of_nonneg_left hlog
    (show (0:ℝ)≤⌈longBlockContraction/a⌉₊ by positivity)
  have hfinal : (⌈longBlockContraction/a⌉₊:ℝ)*Real.log t≤ -(2/5:ℝ)*longBlockContraction := by
    nlinarith only [hp,hbc]
  calc
    _ = Real.exp ((⌈longBlockContraction/a⌉₊:ℝ)*Real.log t) := by
      rw [←Real.log_pow,Real.exp_log (pow_pos ht _)]
    _ ≤ Real.exp (-(2/5:ℝ)*longBlockContraction) := Real.exp_le_exp.mpr hfinal
    _ ≤ _ := longBlock_free_contraction

theorem longBlock_actual_minimum_gain {a c D : ℝ} (ha : 0<a) (ha1 : a≤1/4)
    (hc : c≤a^2/4) (hD : 0≤D) :
    longBlockMinimumGain≤Real.exp ((D-(⌈longBlockContraction/a⌉₊:ℝ)*c)/a-1) := by
  obtain ⟨_,_,hb⟩ := ceiling_block_length ha
    (show 0<longBlockContraction by norm_num [longBlockContraction])
  have hba : a*(⌈longBlockContraction/a⌉₊:ℝ)≤longBlockSpan := by
    unfold longBlockSpan
    linarith
  have hcost := mul_le_mul_of_nonneg_left hc
    (show (0:ℝ)≤⌈longBlockContraction/a⌉₊ by positivity)
  have hmul := mul_le_mul_of_nonneg_right hba ha.le
  unfold longBlockMinimumGain
  apply Real.exp_le_exp.mpr
  have hlower : -longBlockSpan/4≤(D-(⌈longBlockContraction/a⌉₊:ℝ)*c)/a := by
    apply (le_div_iff₀ ha).mpr
    nlinarith only [hcost,hmul,hD]
  linarith

/-- The Gaussian block constant is chosen before the nonlinear threshold,
and the prefix length is chosen last. Thus the choices are not circular. -/
theorem exists_longBlock_prefix_constant {A C η G : ℝ}
    (hA : 0≤A) (hC : 0≤C) (hη : 0<η) (hG : 0≤G) :
    ∃K : ℝ,1≤K ∧ 2*longBlockSpan≤K ∧ C+1≤K ∧
      16*longBlockSpan*A≤η*Real.sqrt K ∧ 8*longBlockSpan*G≤K := by
  let s := 1+16*longBlockSpan*A/η+2*longBlockSpan+C+8*longBlockSpan*G
  have hc : 0<longBlockSpan := by norm_num [longBlockSpan,longBlockContraction]
  have hterm : 0≤16*longBlockSpan*A/η := by positivity
  have hlast : 0≤8*longBlockSpan*G := by positivity
  have hs : 1≤s := by dsimp [s]; linarith
  have hs0 : 0≤s := by linarith
  have hss : s≤s^2 := by nlinarith
  refine ⟨s^2,by nlinarith,?_,?_,?_,?_⟩
  · apply le_trans ?_ hss
    dsimp [s]
    linarith
  · apply le_trans ?_ hss
    dsimp [s]
    have hh : 0≤16*longBlockSpan*A/η := by positivity
    have hg : 0≤8*longBlockSpan*G := by positivity
    linarith
  · rw [Real.sqrt_sq hs0,mul_comm η s]
    apply (div_le_iff₀ hη).mp
    dsimp [s]
    have hg : 0≤8*longBlockSpan*G := by positivity
    linarith
  · apply le_trans ?_ hss
    dsimp [s]
    have hh : 0≤16*longBlockSpan*A/η := by positivity
    linarith

/-- Complete blocks occupy at least half their idealized continuous count. -/
theorem longBlock_count_lower {a K T : ℝ} {J : ℕ}
    (ha : 0<a) (ha1 : a≤1/4) (hK : 2*longBlockSpan≤K) (hT : 1≤T)
    (hJ : K*T/a≤(J:ℝ)) :
    K*T/(2*longBlockSpan)≤((J/⌈longBlockContraction/a⌉₊:ℕ):ℝ) := by
  let b := ⌈longBlockContraction/a⌉₊
  have hc : 0<longBlockContraction := by norm_num [longBlockContraction]
  have hspan : 0<longBlockSpan := by norm_num [longBlockSpan,longBlockContraction]
  obtain ⟨hb,_,hbup⟩ := ceiling_block_length ha hc
  have hbu : a*(b:ℝ)≤longBlockSpan := by
    dsimp only [b]
    unfold longBlockSpan
    linarith
  have hjb : J<(J/b+1)*b := by
    have hh := Nat.mod_lt J hb
    have hid := Nat.div_add_mod J b
    nlinarith
  have hjbr : (J:ℝ)<((J/b:ℕ)+1)*(b:ℝ) := by exact_mod_cast hjb
  have hJmul : K*T≤(J:ℝ)*a := (div_le_iff₀ ha).mp hJ
  have hupper := mul_lt_mul_of_pos_right hjbr ha
  have hblock := mul_le_mul_of_nonneg_left hbu (show (0:ℝ)≤(J/b:ℕ)+1 by positivity)
  have hKT : 2*longBlockSpan≤K*T := by
    have hk0 : 0≤K := by linarith
    nlinarith [mul_le_mul_of_nonneg_left hT hk0]
  apply (div_le_iff₀ (by positivity : 0<2*longBlockSpan)).mpr
  change K*T≤(J/b:ℕ)*(2*longBlockSpan)
  nlinarith only [hJmul,hupper,hblock,hKT]

/-- The actual Gaussian and nonlinear block charges each exhaust at most a
quarter of the blocks, once the universal prefix constant has been chosen. -/
theorem longBlock_half_good {ι : Type*} [DecidableEq ι]
    (S : Finset ι) (Cg Nl : ι→ℝ) {a K T C A η : ℝ}
    (ha : 0<a) (hT : 1≤T) (hK : 1≤K) (hC : 0≤C) (hA : 0≤A) (hη : 0<η)
    (hKC : C+1≤K) (hKsqrt : 16*longBlockSpan*A≤η*Real.sqrt K)
    (hcount : K*T/(2*longBlockSpan)≤(S.card:ℝ))
    (hCg0 : ∀i∈S,0≤Cg i) (hNl0 : ∀i∈S,0≤Nl i)
    (hCg : ∑i∈S,Cg i≤(K/2+C+1)*a*T)
    (hNl : ∑i∈S,Nl i≤A*(1+Real.sqrt K)*T) :
    K*T/(4*longBlockSpan)≤
      ((S.filter fun i=>Cg i≤longBlockGaussianThreshold*a ∧ Nl i≤η).card:ℝ) := by
  have hc : 0<longBlockSpan := by norm_num [longBlockSpan,longBlockContraction]
  have hK0 : 0≤K := by linarith
  have hT0 : 0≤T := by linarith
  have hcount' : K*T≤(S.card:ℝ)*(2*longBlockSpan) := (div_le_iff₀ (by positivity)).mp hcount
  have hgaussian : ∑i∈S,Cg i≤(longBlockGaussianThreshold*a)*(S.card:ℝ)/4 := by
    have hcoeff : K/2+C+1≤2*K := by linarith
    have h1 := mul_le_mul_of_nonneg_right hcoeff (mul_nonneg ha.le hT0)
    have h2 := mul_le_mul_of_nonneg_left hcount' (show 0≤2*a by positivity)
    unfold longBlockGaussianThreshold
    nlinarith only [hCg,h1,h2]
  have hs : 1≤Real.sqrt K := (Real.le_sqrt (by norm_num) hK0).mpr (by simpa using hK)
  have hsq := Real.sq_sqrt hK0
  have hnlcoef : 8*longBlockSpan*(A*(1+Real.sqrt K))≤η*K := by
    have h1 := mul_le_mul_of_nonneg_right hKsqrt (Real.sqrt_nonneg K)
    rw [show η*Real.sqrt K*Real.sqrt K=η*K by rw [mul_assoc,←pow_two,hsq]] at h1
    have h2 := mul_nonneg (show 0≤8*longBlockSpan*A by positivity) (show 0≤Real.sqrt K-1 by linarith)
    nlinarith only [h1,h2,hsq]
  have hnonlinear : ∑i∈S,Nl i≤η*(S.card:ℝ)/4 := by
    have h1 := mul_le_mul_of_nonneg_right hnlcoef hT0
    have h2 := mul_le_mul_of_nonneg_left hcount' hη.le
    have h3 := mul_le_mul_of_nonneg_left hNl (show 0≤8*longBlockSpan by positivity)
    nlinarith only [h1,h2,h3,hc]
  have hhalf := at_least_half_good_blocks S Cg Nl (longBlockGaussianThreshold*a) η
    (by unfold longBlockGaussianThreshold; positivity) hη hCg0 hNl0 hgaussian hnonlinear
  have hlo : K*T/(4*longBlockSpan)≤(S.card:ℝ)/2 := by
    apply (div_le_iff₀ (by positivity : 0<4*longBlockSpan)).mpr
    nlinarith only [hcount']
  exact hlo.trans hhalf

#print axioms subcriticalCostBaseline_quarter
#print axioms exists_longBlock_prefix_constant
#print axioms longBlock_count_lower
#print axioms longBlock_half_good
end ConditionalNonpolynomial.Analytic
