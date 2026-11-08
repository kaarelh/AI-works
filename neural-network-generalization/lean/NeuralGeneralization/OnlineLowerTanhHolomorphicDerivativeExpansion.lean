import NeuralGeneralization.OnlineLowerTanhHolomorphicStationary

noncomputable section
open scoped BigOperators
open Complex Set
namespace NeuralGeneralization.OnlineLowerTanh

def complexF0Derivative (a:ℂ) : ℂ := -4*∑'j:ℕ,(-1:ℂ)^j*complexLogisticFirst j a
def complexF1Derivative (a:ℂ) : ℂ := -4*∑'j:ℕ,(-1:ℂ)^j*(prefactoredFirst j:ℂ)*complexLogisticFirst j a
def complexF2Derivative (a:ℂ) : ℂ := -4*∑'j:ℕ,(-1:ℂ)^j*(prefactoredSecond j:ℂ)*complexLogisticFirst j a

lemma logisticFirstMajorant_poly_summable (n:ℕ) :
    Summable (fun j:ℕ=>((j:ℝ)+1)^n*logisticFirstMajorant j) := by
  have hh:=(logisticMajorant_poly_summable (n+1)).mul_left 16
  apply hh.congr
  intro j
  unfold logisticFirstMajorant
  rw [pow_succ]
  ring

lemma weightedLogisticFirst_summable (w:ℕ→ℂ) (K:ℝ) (n:ℕ)
    (hw:∀j,‖w j‖≤K*((j:ℝ)+1)^n) {a:ℂ} (ha:1≤a.re) :
    Summable (fun j=>w j*complexLogisticFirst j a) := by
  apply ((logisticFirstMajorant_poly_summable n).mul_left K).of_norm_bounded
  intro j
  rw [norm_mul]
  calc
    _ ≤ (K*((j:ℝ)+1)^n)*logisticFirstMajorant j :=
      mul_le_mul (hw j) (complexLogisticFirst_bound j ha) (norm_nonneg _) ((norm_nonneg _).trans (hw j))
    _ = _ := by ring

lemma complexF0Derivative_summable {a:ℂ} (ha:1≤a.re) :
    Summable (fun j:ℕ=>(-1:ℂ)^j*complexLogisticFirst j a) := by
  apply weightedLogisticFirst_summable (fun j=>(-1:ℂ)^j) 1 0 _ ha
  intro j
  simp

lemma complexF1Derivative_summable {a:ℂ} (ha:1≤a.re) :
    Summable (fun j:ℕ=>(-1:ℂ)^j*(prefactoredFirst j:ℂ)*complexLogisticFirst j a) := by
  apply weightedLogisticFirst_summable (fun j=>(-1:ℂ)^j*(prefactoredFirst j:ℂ)) 3 2 _ ha
  intro j
  simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul,
    Complex.norm_real,Real.norm_eq_abs] using prefactoredFirst_abs_bound j

lemma complexF2Derivative_summable {a:ℂ} (ha:1≤a.re) :
    Summable (fun j:ℕ=>(-1:ℂ)^j*(prefactoredSecond j:ℂ)*complexLogisticFirst j a) := by
  apply weightedLogisticFirst_summable (fun j=>(-1:ℂ)^j*(prefactoredSecond j:ℂ)) 7 4 _ ha
  intro j
  simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul,
    Complex.norm_real,Real.norm_eq_abs,abs_of_nonneg (prefactoredSecond_nonneg j)] using prefactoredSecond_bound j

def complexDerivativeRemainderMajorant (j:ℕ) : ℝ :=
  (64*((j:ℝ)+1)^6+7*((j:ℝ)+1)^4)*logisticFirstMajorant j

lemma complexDerivativeRemainderMajorant_summable : Summable complexDerivativeRemainderMajorant := by
  have hh:=((logisticFirstMajorant_poly_summable 6).mul_left 64).add
    ((logisticFirstMajorant_poly_summable 4).mul_left 7)
  apply hh.congr
  intro j
  unfold complexDerivativeRemainderMajorant
  ring

lemma complexFDerivative_remainder_term {z a:ℂ} (hz:0≤z.re) (hn:z≠0) (ha:1≤a.re) (j:ℕ) :
    ‖(-1:ℂ)^j*(prefactoredRatio j z-prefactoredApprox j z)*complexLogisticFirst j a‖≤
      complexDerivativeRemainderMajorant j/‖z‖^3 := by
  rw [norm_mul,norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul]
  have hK:0≤ratioRemainderConstant j+prefactoredSecond j :=
    add_nonneg (ratioRemainderConstant_nonneg j) (prefactoredSecond_nonneg j)
  calc
    _ ≤ ((ratioRemainderConstant j+prefactoredSecond j)/‖z‖^3)*logisticFirstMajorant j :=
      mul_le_mul (prefactoredRatio_remainder_bound j hz hn) (complexLogisticFirst_bound j ha)
        (norm_nonneg _) (div_nonneg hK (pow_nonneg (norm_nonneg _) _))
    _ ≤ ((64*((j:ℝ)+1)^6+7*((j:ℝ)+1)^4)/‖z‖^3)*logisticFirstMajorant j := by
      gcongr
      · unfold logisticFirstMajorant logisticMajorant; positivity
      · exact ratioRemainderConstant_poly j
      · exact prefactoredSecond_bound j
    _ = _ := by unfold complexDerivativeRemainderMajorant; ring

/-- Uniform cubic remainder for the actual Hamming-series interpolation. -/
theorem complexFDerivative_expansion_bound {z a:ℂ} (hz:0≤z.re) (hn:z≠0) (ha:1≤a.re) :
    ‖complexFDerivative z a-(complexF0Derivative a+complexF1Derivative a/z+complexF2Derivative a/z^2)‖≤
      (4*∑'j:ℕ,complexDerivativeRemainderMajorant j)/‖z‖^3 := by
  let e : ℕ→ℂ := fun j=>(-1:ℂ)^j*(prefactoredRatio j z-prefactoredApprox j z)*complexLogisticFirst j a
  have hs : Summable e := by
    apply (complexDerivativeRemainderMajorant_summable.div_const (‖z‖^3)).of_norm_bounded
    exact complexFDerivative_remainder_term hz hn ha
  have ht := (((complexFDerivative_summable hz ha).hasSum.sub (complexF0Derivative_summable ha).hasSum).sub
    ((complexF1Derivative_summable ha).hasSum.div_const z)).sub ((complexF2Derivative_summable ha).hasSum.div_const (z^2))
  have ht' := ht.congr_fun (g:=e) (fun j=>by dsimp [e,prefactoredApprox]; ring)
  have he : complexFDerivative z a-(complexF0Derivative a+complexF1Derivative a/z+complexF2Derivative a/z^2)=
      -4*∑'j:ℕ,e j := by
    rw [ht'.tsum_eq]
    unfold complexFDerivative complexF0Derivative complexF1Derivative complexF2Derivative
    ring
  have hm := hs.norm.tsum_le_tsum (fun j=>complexFDerivative_remainder_term hz hn ha j)
    (complexDerivativeRemainderMajorant_summable.div_const (‖z‖^3))
  rw [tsum_div_const] at hm
  have hb := (norm_tsum_le_tsum_norm hs.norm).trans hm
  rw [he,norm_mul]
  norm_num only [norm_neg,norm_ofNat]
  calc
    _ ≤ 4*((∑'j:ℕ,complexDerivativeRemainderMajorant j)/‖z‖^3) :=
      mul_le_mul_of_nonneg_left hb (by norm_num)
    _ = _ := by ring

end NeuralGeneralization.OnlineLowerTanh
