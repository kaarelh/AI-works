import Mathlib.Analysis.Complex.CauchyIntegral
import Mathlib.Tactic

/-! Uniform right-half-plane expansion of the actual Hamming ratio product. -/
noncomputable section
open scoped BigOperators
open Complex
namespace NeuralGeneralization.OnlineLowerTanh

def hammingRatio (j:ℕ) (z:ℂ) : ℂ :=
  ∏l∈Finset.range j,(z-(2*(l:ℂ)+1))/(z+(2*(l:ℂ)+3))
def ratioFirst (j:ℕ) : ℝ := -2*(j:ℝ)*((j:ℝ)+1)
def ratioSecond (j:ℕ) : ℝ := 2*(j:ℝ)*((j:ℝ)+1)+2*((j:ℝ)*((j:ℝ)+1))^2
def ratioApprox (j:ℕ) (z:ℂ) : ℂ := 1+(ratioFirst j:ℂ)/z+(ratioSecond j:ℂ)/z^2
def ratioRemainderConstant (j:ℕ) : ℝ :=
  2*(j:ℝ)*((j:ℝ)+1)*(2*(j:ℝ)^4+4*(j:ℝ)^3+10*(j:ℝ)^2+8*(j:ℝ)+3)/3

lemma norm_le_norm_add_nonneg (z:ℂ) (c:ℝ) (hz:0≤z.re) (hc:0≤c) :
    ‖z‖≤‖z+(c:ℂ)‖ := by
  apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  rw [←Complex.normSq_eq_norm_sq,←Complex.normSq_eq_norm_sq]
  simp only [Complex.normSq_apply,Complex.add_re,Complex.add_im,Complex.ofReal_re,
    Complex.ofReal_im,add_zero]
  nlinarith

lemma hamming_den_ne_zero (z:ℂ) (j:ℕ) (hz:0≤z.re) :
    z+(2*(j:ℂ)+3)≠0 := by
  intro h
  have hh:=congrArg Complex.re h
  simp only [Complex.add_re,Complex.mul_re,
    Complex.natCast_re,Complex.natCast_im,mul_zero,sub_zero,Complex.zero_re] at hh
  norm_num at hh
  have hj:0≤(j:ℝ) := Nat.cast_nonneg _
  linarith

lemma hamming_factor_norm_le_one (z:ℂ) (j:ℕ) (hz:0≤z.re) :
    ‖(z-(2*(j:ℂ)+1))/(z+(2*(j:ℂ)+3))‖≤1 := by
  rw [norm_div]
  apply (div_le_one (norm_pos_iff.mpr (hamming_den_ne_zero z j hz))).mpr
  apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  rw [←Complex.normSq_eq_norm_sq,←Complex.normSq_eq_norm_sq]
  simp only [Complex.normSq_apply,Complex.add_re,Complex.add_im,Complex.sub_re,Complex.sub_im,
    Complex.mul_re,Complex.mul_im,Complex.natCast_re,
    Complex.natCast_im,mul_zero,zero_mul,add_zero,sub_zero]
  norm_num
  nlinarith [Nat.cast_nonneg (α:=ℝ) j]

lemma hammingRatio_norm_le_one (j:ℕ) {z:ℂ} (hz:0≤z.re) : ‖hammingRatio j z‖≤1 := by
  unfold hammingRatio
  rw [norm_prod]
  exact Finset.prod_le_one (fun _ _=>norm_nonneg _) (fun l _=>hamming_factor_norm_le_one z l hz)

lemma ratioSecond_nonneg (j:ℕ) : 0≤ratioSecond j := by unfold ratioSecond; positivity
lemma ratioRemainderConstant_nonneg (j:ℕ) : 0≤ratioRemainderConstant j := by
  unfold ratioRemainderConstant
  positivity

lemma ratioRemainderConstant_succ (j:ℕ) :
    ratioRemainderConstant (j+1)=ratioRemainderConstant j+
      ((2*(j:ℝ)+1)*ratioSecond j+(2*(j:ℝ)+3)*ratioSecond (j+1)) := by
  unfold ratioRemainderConstant ratioSecond
  push_cast
  ring

lemma hammingRatio_succ (j:ℕ) (z:ℂ) :
    hammingRatio (j+1) z=hammingRatio j z*((z-(2*(j:ℂ)+1))/(z+(2*(j:ℂ)+3))) := by
  unfold hammingRatio
  rw [Finset.prod_range_succ]

lemma ratioApprox_defect (j:ℕ) {z:ℂ} (hz:z≠0) (hden:z+(2*(j:ℂ)+3)≠0) :
    ((z-(2*(j:ℂ)+1))/(z+(2*(j:ℂ)+3)))*ratioApprox j z-ratioApprox (j+1) z=
      -(((2*(j:ℂ)+1)*(ratioSecond j:ℂ)+(2*(j:ℂ)+3)*(ratioSecond (j+1):ℂ))/
        (z^2*(z+(2*(j:ℂ)+3)))) := by
  unfold ratioApprox ratioFirst ratioSecond
  push_cast
  field_simp
  ring

/-- A polynomial remainder bound valid simultaneously for every finite Hamming level,
without a cutoff depending on the complex interpolation parameter. -/
theorem hammingRatio_remainder_bound (j:ℕ) {z:ℂ} (hz:0≤z.re) (hn:z≠0) :
    ‖hammingRatio j z-ratioApprox j z‖≤ratioRemainderConstant j/‖z‖^3 := by
  induction j with
  | zero => simp [hammingRatio,ratioApprox,ratioFirst,ratioSecond,ratioRemainderConstant]
  | succ j ih =>
    let f : ℂ := (z-(2*(j:ℂ)+1))/(z+(2*(j:ℂ)+3))
    let K : ℝ := (2*(j:ℝ)+1)*ratioSecond j+(2*(j:ℝ)+3)*ratioSecond (j+1)
    have hK : 0≤K := by
      have h0:=ratioSecond_nonneg j
      have h1:=ratioSecond_nonneg (j+1)
      dsimp [K]
      positivity
    have hden:=hamming_den_ne_zero z j hz
    have hdenNorm : ‖z‖≤‖z+(2*(j:ℂ)+3)‖ := by
      convert norm_le_norm_add_nonneg z (2*(j:ℝ)+3) hz (by positivity) using 1 <;> push_cast <;> rfl
    have hd : ‖f*ratioApprox j z-ratioApprox (j+1) z‖≤K/‖z‖^3 := by
      rw [ratioApprox_defect j hn hden,norm_neg,norm_div,norm_mul,norm_pow]
      have hnum : ‖(2*(j:ℂ)+1)*(ratioSecond j:ℂ)+(2*(j:ℂ)+3)*(ratioSecond (j+1):ℂ)‖=K := by
        have he : (2*(j:ℂ)+1)*(ratioSecond j:ℂ)+(2*(j:ℂ)+3)*(ratioSecond (j+1):ℂ)=(K:ℂ) := by
          dsimp [K]; push_cast; rfl
        rw [he,Complex.norm_real,Real.norm_eq_abs,abs_of_nonneg hK]
      rw [hnum]
      apply div_le_div_of_nonneg_left hK (pow_pos (norm_pos_iff.mpr hn) 3)
      calc
        ‖z‖^3=‖z‖^2*‖z‖ := by ring
        _ ≤ _ := mul_le_mul_of_nonneg_left hdenNorm (sq_nonneg _)
    have he : hammingRatio (j+1) z-ratioApprox (j+1) z=
        f*(hammingRatio j z-ratioApprox j z)+(f*ratioApprox j z-ratioApprox (j+1) z) := by
      rw [hammingRatio_succ]
      dsimp [f]
      ring
    rw [he,ratioRemainderConstant_succ,add_div]
    apply (norm_add_le _ _).trans
    apply add_le_add _ hd
    rw [norm_mul]
    calc
      _ ≤ 1*(ratioRemainderConstant j/‖z‖^3) :=
        mul_le_mul (hamming_factor_norm_le_one z j hz) ih (norm_nonneg _) (by norm_num)
      _ = _ := one_mul _

lemma ratioRemainderConstant_poly (j:ℕ) : ratioRemainderConstant j≤64*((j:ℝ)+1)^6 := by
  unfold ratioRemainderConstant
  have h : 0≤64*((j:ℝ)+1)^6-
      2*(j:ℝ)*((j:ℝ)+1)*(2*(j:ℝ)^4+4*(j:ℝ)^3+10*(j:ℝ)^2+8*(j:ℝ)+3)/3 := by
    ring_nf
    positivity
  linarith

def prefactoredRatio (j:ℕ) (z:ℂ) : ℂ := z/(z+1)*hammingRatio j z
def prefactoredFirst (j:ℕ) : ℝ := ratioFirst j-1
def prefactoredSecond (j:ℕ) : ℝ := ratioSecond j-ratioFirst j+1
def prefactoredApprox (j:ℕ) (z:ℂ) : ℂ :=
  1+(prefactoredFirst j:ℂ)/z+(prefactoredSecond j:ℂ)/z^2

lemma prefactoredSecond_nonneg (j:ℕ) : 0≤prefactoredSecond j := by
  unfold prefactoredSecond ratioSecond ratioFirst
  ring_nf
  positivity

lemma prefactoredRatio_norm_le_one (j:ℕ) {z:ℂ} (hz:0≤z.re) :
    ‖prefactoredRatio j z‖≤1 := by
  have hd : z+1≠0 := by
    intro h
    have hh:=congrArg Complex.re h
    simp at hh
    linarith
  have hn:‖z/(z+1)‖≤1 := by
    rw [norm_div]
    exact (div_le_one (norm_pos_iff.mpr hd)).mpr
      (by simpa only [Complex.ofReal_one] using norm_le_norm_add_nonneg z 1 hz (by norm_num))
  unfold prefactoredRatio
  rw [norm_mul]
  exact mul_le_one₀ hn (norm_nonneg _) (hammingRatio_norm_le_one j hz)

lemma prefactoredApprox_defect (j:ℕ) {z:ℂ} (hz:z≠0) (hd:z+1≠0) :
    z/(z+1)*ratioApprox j z-prefactoredApprox j z=
      -(prefactoredSecond j:ℂ)/(z^2*(z+1)) := by
  unfold ratioApprox prefactoredApprox prefactoredFirst prefactoredSecond
  push_cast
  field_simp
  ring

theorem prefactoredRatio_remainder_bound (j:ℕ) {z:ℂ} (hz:0≤z.re) (hn:z≠0) :
    ‖prefactoredRatio j z-prefactoredApprox j z‖≤
      (ratioRemainderConstant j+prefactoredSecond j)/‖z‖^3 := by
  have hd : z+1≠0 := by
    intro h
    have hh:=congrArg Complex.re h
    simp at hh
    linarith
  have hzn:‖z‖≤‖z+1‖ := by
    simpa only [Complex.ofReal_one] using norm_le_norm_add_nonneg z 1 hz (by norm_num)
  have hp:‖z/(z+1)‖≤1 := by rw [norm_div]; exact (div_le_one (norm_pos_iff.mpr hd)).mpr hzn
  have he : prefactoredRatio j z-prefactoredApprox j z=
      z/(z+1)*(hammingRatio j z-ratioApprox j z)+
      (z/(z+1)*ratioApprox j z-prefactoredApprox j z) := by
    unfold prefactoredRatio
    ring
  rw [he,add_div]
  apply (norm_add_le _ _).trans
  apply add_le_add
  · rw [norm_mul]
    calc
      _ ≤ 1*(ratioRemainderConstant j/‖z‖^3) :=
        mul_le_mul hp (hammingRatio_remainder_bound j hz hn) (norm_nonneg _) (by norm_num)
      _ = _ := one_mul _
  · rw [prefactoredApprox_defect j hn hd,norm_div,norm_neg,norm_mul,norm_pow,
      Complex.norm_real,Real.norm_eq_abs,abs_of_nonneg (prefactoredSecond_nonneg j)]
    apply div_le_div_of_nonneg_left (prefactoredSecond_nonneg j) (pow_pos (norm_pos_iff.mpr hn) 3)
    calc
      ‖z‖^3=‖z‖^2*‖z‖ := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_left hzn (sq_nonneg _)

lemma prefactoredFirst_abs_bound (j:ℕ) : |prefactoredFirst j|≤3*((j:ℝ)+1)^2 := by
  unfold prefactoredFirst ratioFirst
  rw [abs_of_nonpos (by nlinarith [Nat.cast_nonneg (α:=ℝ) j])]
  nlinarith [Nat.cast_nonneg (α:=ℝ) j]

lemma prefactoredSecond_bound (j:ℕ) : prefactoredSecond j≤7*((j:ℝ)+1)^4 := by
  have h : 0≤7*((j:ℝ)+1)^4-prefactoredSecond j := by
    unfold prefactoredSecond ratioSecond ratioFirst
    ring_nf
    positivity
  linarith

end NeuralGeneralization.OnlineLowerTanh
