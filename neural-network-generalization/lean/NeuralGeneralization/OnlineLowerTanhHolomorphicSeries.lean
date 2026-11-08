import NeuralGeneralization.OnlineLowerTanhHolomorphicRatio
import Mathlib.Analysis.Complex.LocallyUniformLimit
import Mathlib.Analysis.SpecificLimits.Normed

noncomputable section
open scoped BigOperators
open Complex Set
namespace NeuralGeneralization.OnlineLowerTanh

def complexLogistic (j:ℕ) (a:ℂ) : ℂ :=
  Complex.exp (-2*a*(2*(j:ℂ)+1))/(1+Complex.exp (-2*a*(2*(j:ℂ)+1)))
def complexF (z a:ℂ) : ℂ :=
  1-4*∑'j:ℕ,(-1:ℂ)^j*prefactoredRatio j z*complexLogistic j a

def complexF0 (a:ℂ) : ℂ := 1-4*∑'j:ℕ,(-1:ℂ)^j*complexLogistic j a
def complexF1 (a:ℂ) : ℂ := -4*∑'j:ℕ,(-1:ℂ)^j*(prefactoredFirst j:ℂ)*complexLogistic j a
def complexF2 (a:ℂ) : ℂ := -4*∑'j:ℕ,(-1:ℂ)^j*(prefactoredSecond j:ℂ)*complexLogistic j a

def logisticMajorant (j:ℕ) : ℝ := 2*Real.exp (-4)^j

lemma complexLogistic_exp_bound (j:ℕ) {a:ℂ} (ha:1≤a.re) :
    ‖Complex.exp (-2*a*(2*(j:ℂ)+1))‖≤Real.exp (-2)*Real.exp (-4)^j := by
  rw [Complex.norm_exp,←Real.exp_nat_mul,←Real.exp_add]
  apply Real.exp_le_exp.mpr
  simp only [Complex.mul_re,Complex.mul_im,Complex.neg_re,Complex.neg_im,
    Complex.natCast_re,Complex.natCast_im,Complex.add_re,Complex.add_im,
    Complex.one_re,Complex.one_im,mul_zero,zero_mul,sub_zero,add_zero]
  norm_num
  nlinarith [Nat.cast_nonneg (α:=ℝ) j]

lemma exp_neg_two_le_half : Real.exp (-2)≤(1/2:ℝ) := by
  rw [Real.exp_neg]
  apply (inv_le_comm₀ (Real.exp_pos _) (by norm_num : 0<(1/2:ℝ))).mpr
  have hh:=Real.add_one_le_exp 2
  norm_num at hh ⊢
  linarith

lemma complexLogistic_exp_half (j:ℕ) {a:ℂ} (ha:1≤a.re) :
    ‖Complex.exp (-2*a*(2*(j:ℂ)+1))‖≤1/2 := by
  have hpow : Real.exp (-4)^j≤1 := pow_le_one₀ (Real.exp_pos _).le
    (Real.exp_le_one_iff.mpr (by norm_num))
  calc
    _ ≤ Real.exp (-2)*Real.exp (-4)^j := complexLogistic_exp_bound j ha
    _ ≤ Real.exp (-2)*1 := mul_le_mul_of_nonneg_left hpow (Real.exp_pos _).le
    _ ≤ _ := by simpa using exp_neg_two_le_half

lemma complexLogistic_den_lower (j:ℕ) {a:ℂ} (ha:1≤a.re) :
    (1/2:ℝ)≤‖1+Complex.exp (-2*a*(2*(j:ℂ)+1))‖ := by
  have hh:=norm_sub_norm_le (1:ℂ) (-Complex.exp (-2*a*(2*(j:ℂ)+1)))
  rw [norm_one,norm_neg,sub_neg_eq_add] at hh
  linarith [complexLogistic_exp_half j ha]

lemma complexLogistic_den_ne (j:ℕ) {a:ℂ} (ha:1≤a.re) :
    1+Complex.exp (-2*a*(2*(j:ℂ)+1))≠0 :=
  norm_pos_iff.mp (lt_of_lt_of_le (by norm_num) (complexLogistic_den_lower j ha))

lemma complexLogistic_bound (j:ℕ) {a:ℂ} (ha:1≤a.re) :
    ‖complexLogistic j a‖≤logisticMajorant j := by
  unfold complexLogistic
  rw [norm_div]
  have hh:=complexLogistic_exp_bound j ha
  have hden:=complexLogistic_den_lower j ha
  calc
    _ ≤ (Real.exp (-2)*Real.exp (-4)^j)/(1/2) :=
      div_le_div₀ (by positivity) hh (by norm_num) hden
    _ ≤ logisticMajorant j := by
      unfold logisticMajorant
      have he : Real.exp (-2)≤1 := Real.exp_le_one_iff.mpr (by norm_num)
      nlinarith [pow_nonneg (Real.exp_pos (-4)).le j]

lemma logisticMajorant_summable : Summable logisticMajorant :=
  (summable_geometric_of_abs_lt_one (by
    rw [abs_of_pos (Real.exp_pos _)]
    exact Real.exp_lt_one_iff.mpr (by norm_num))).mul_left 2

lemma logisticMajorant_poly_summable (n:ℕ) :
    Summable (fun j:ℕ=>((j:ℝ)+1)^n*logisticMajorant j) := by
  have hq : ‖Real.exp (-4)‖<1 := by
    rw [Real.norm_eq_abs,abs_of_pos (Real.exp_pos _)]
    exact Real.exp_lt_one_iff.mpr (by norm_num)
  have hp:=summable_pow_mul_geometric_of_norm_lt_one n (r:=Real.exp (-4)) hq
  have hs:=hp.comp_injective (fun j k h=>Nat.succ.inj h)
  have he : (fun j:ℕ=>((j:ℝ)+1)^n*logisticMajorant j)=
      (fun j:ℕ=>(2/Real.exp (-4))*((j+1:ℕ):ℝ)^n*Real.exp (-4)^(j+1)) := by
    funext j
    unfold logisticMajorant
    push_cast
    rw [pow_succ]
    field_simp
  rw [he]
  simpa only [mul_assoc,Function.comp_def,Nat.succ_eq_add_one] using hs.mul_left (2/Real.exp (-4))

lemma complexF_summable {z a:ℂ} (hz:0≤z.re) (ha:1≤a.re) :
    Summable (fun j:ℕ=>(-1:ℂ)^j*prefactoredRatio j z*complexLogistic j a) := by
  apply logisticMajorant_summable.of_norm_bounded
  intro j
  rw [norm_mul,norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul]
  calc
    _ ≤ 1*logisticMajorant j :=
      mul_le_mul (prefactoredRatio_norm_le_one j hz) (complexLogistic_bound j ha)
        (norm_nonneg _) (by norm_num)
    _ = _ := one_mul _

lemma weightedLogistic_summable (w:ℕ→ℂ) (K:ℝ) (n:ℕ)
    (hw:∀j,‖w j‖≤K*((j:ℝ)+1)^n) {a:ℂ} (ha:1≤a.re) :
    Summable (fun j=>w j*complexLogistic j a) := by
  apply ((logisticMajorant_poly_summable n).mul_left K).of_norm_bounded
  intro j
  rw [norm_mul]
  calc
    _ ≤ (K*((j:ℝ)+1)^n)*logisticMajorant j :=
      mul_le_mul (hw j) (complexLogistic_bound j ha) (norm_nonneg _) ((norm_nonneg _).trans (hw j))
    _ = _ := by ring

lemma complexF0_summable {a:ℂ} (ha:1≤a.re) :
    Summable (fun j:ℕ=>(-1:ℂ)^j*complexLogistic j a) := by
  apply weightedLogistic_summable (fun j=>(-1:ℂ)^j) 1 0 _ ha
  intro j
  simp

lemma complexF1_summable {a:ℂ} (ha:1≤a.re) :
    Summable (fun j:ℕ=>(-1:ℂ)^j*(prefactoredFirst j:ℂ)*complexLogistic j a) := by
  apply weightedLogistic_summable (fun j=>(-1:ℂ)^j*(prefactoredFirst j:ℂ)) 3 2 _ ha
  intro j
  simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul,
    Complex.norm_real,Real.norm_eq_abs] using prefactoredFirst_abs_bound j

lemma complexF2_summable {a:ℂ} (ha:1≤a.re) :
    Summable (fun j:ℕ=>(-1:ℂ)^j*(prefactoredSecond j:ℂ)*complexLogistic j a) := by
  apply weightedLogistic_summable (fun j=>(-1:ℂ)^j*(prefactoredSecond j:ℂ)) 7 4 _ ha
  intro j
  simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul,
    Complex.norm_real,Real.norm_eq_abs,abs_of_nonneg (prefactoredSecond_nonneg j)] using prefactoredSecond_bound j

def complexRemainderMajorant (j:ℕ) : ℝ :=
  (64*((j:ℝ)+1)^6+7*((j:ℝ)+1)^4)*logisticMajorant j

lemma complexRemainderMajorant_summable : Summable complexRemainderMajorant := by
  have hh:=((logisticMajorant_poly_summable 6).mul_left 64).add
    ((logisticMajorant_poly_summable 4).mul_left 7)
  apply hh.congr
  intro j
  unfold complexRemainderMajorant
  ring

lemma complexF_remainder_term {z a:ℂ} (hz:0≤z.re) (hn:z≠0) (ha:1≤a.re) (j:ℕ) :
    ‖(-1:ℂ)^j*(prefactoredRatio j z-prefactoredApprox j z)*complexLogistic j a‖≤
      complexRemainderMajorant j/‖z‖^3 := by
  rw [norm_mul,norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul]
  have hK:0≤ratioRemainderConstant j+prefactoredSecond j :=
    add_nonneg (ratioRemainderConstant_nonneg j) (prefactoredSecond_nonneg j)
  calc
    _ ≤ ((ratioRemainderConstant j+prefactoredSecond j)/‖z‖^3)*logisticMajorant j :=
      mul_le_mul (prefactoredRatio_remainder_bound j hz hn) (complexLogistic_bound j ha)
        (norm_nonneg _) (div_nonneg hK (pow_nonneg (norm_nonneg _) _))
    _ ≤ ((64*((j:ℝ)+1)^6+7*((j:ℝ)+1)^4)/‖z‖^3)*logisticMajorant j := by
      gcongr
      · unfold logisticMajorant; positivity
      · exact ratioRemainderConstant_poly j
      · exact prefactoredSecond_bound j
    _ = _ := by unfold complexRemainderMajorant; ring

/-- Uniform cubic remainder for the actual Hamming-series interpolation. -/
theorem complexF_expansion_bound {z a:ℂ} (hz:0≤z.re) (hn:z≠0) (ha:1≤a.re) :
    ‖complexF z a-(complexF0 a+complexF1 a/z+complexF2 a/z^2)‖≤
      (4*∑'j:ℕ,complexRemainderMajorant j)/‖z‖^3 := by
  let e : ℕ→ℂ := fun j=>(-1:ℂ)^j*(prefactoredRatio j z-prefactoredApprox j z)*complexLogistic j a
  have hs : Summable e := by
    apply (complexRemainderMajorant_summable.div_const (‖z‖^3)).of_norm_bounded
    exact complexF_remainder_term hz hn ha
  have ht := (((complexF_summable hz ha).hasSum.sub (complexF0_summable ha).hasSum).sub
    ((complexF1_summable ha).hasSum.div_const z)).sub ((complexF2_summable ha).hasSum.div_const (z^2))
  have ht' := ht.congr_fun (g:=e) (fun j=>by dsimp [e,prefactoredApprox]; ring)
  have he : complexF z a-(complexF0 a+complexF1 a/z+complexF2 a/z^2)=
      -4*∑'j:ℕ,e j := by
    rw [ht'.tsum_eq]
    unfold complexF complexF0 complexF1 complexF2
    ring
  have hm := hs.norm.tsum_le_tsum (fun j=>complexF_remainder_term hz hn ha j)
    (complexRemainderMajorant_summable.div_const (‖z‖^3))
  rw [tsum_div_const] at hm
  have hb := (norm_tsum_le_tsum_norm hs.norm).trans hm
  rw [he,norm_mul]
  norm_num only [norm_neg,norm_ofNat]
  calc
    _ ≤ 4*((∑'j:ℕ,complexRemainderMajorant j)/‖z‖^3) :=
      mul_le_mul_of_nonneg_left hb (by norm_num)
    _ = _ := by ring

end NeuralGeneralization.OnlineLowerTanh
