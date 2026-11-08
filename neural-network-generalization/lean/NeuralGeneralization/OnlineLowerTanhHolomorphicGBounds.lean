import NeuralGeneralization.OnlineLowerTanhHolomorphicRootData

noncomputable section
open scoped BigOperators
open Complex
namespace NeuralGeneralization.OnlineLowerTanh

def weightedMajorantSum (K:ℝ) (n:ℕ) : ℝ :=
  ∑'j:ℕ,K*((j:ℝ)+1)^n*logisticMajorant j
def weightedFirstMajorantSum (K:ℝ) (n:ℕ) : ℝ :=
  ∑'j:ℕ,K*((j:ℝ)+1)^n*logisticFirstMajorant j

def stationaryCoefficientBound (K:ℝ) (n:ℕ) : ℝ :=
  8*weightedFirstMajorantSum K n+4*weightedMajorantSum K n

def stationaryRemainderBound : ℝ :=
  8*(∑'j:ℕ,complexDerivativeRemainderMajorant j)+4*(∑'j:ℕ,complexRemainderMajorant j)

lemma weightedMajorantSum_nonneg {K:ℝ} (hK:0≤K) (n:ℕ) : 0≤weightedMajorantSum K n := by
  apply tsum_nonneg
  intro j
  unfold logisticMajorant
  positivity
lemma weightedFirstMajorantSum_nonneg {K:ℝ} (hK:0≤K) (n:ℕ) : 0≤weightedFirstMajorantSum K n := by
  apply tsum_nonneg
  intro j
  unfold logisticFirstMajorant logisticMajorant
  positivity
lemma stationaryCoefficientBound_nonneg {K:ℝ} (hK:0≤K) (n:ℕ) :
    0≤stationaryCoefficientBound K n := by
  unfold stationaryCoefficientBound
  positivity [weightedMajorantSum_nonneg hK n,weightedFirstMajorantSum_nonneg hK n]
lemma stationaryRemainderBound_nonneg : 0≤stationaryRemainderBound := by
  unfold stationaryRemainderBound
  have h0 : 0≤∑'j:ℕ,complexRemainderMajorant j := tsum_nonneg (fun j=>by
    unfold complexRemainderMajorant logisticMajorant; positivity)
  have h1 : 0≤∑'j:ℕ,complexDerivativeRemainderMajorant j := tsum_nonneg (fun j=>by
    unfold complexDerivativeRemainderMajorant logisticFirstMajorant logisticMajorant; positivity)
  positivity

lemma weightedLogistic_norm_bound (w:ℕ→ℂ) (K:ℝ) (n:ℕ)
    (hw:∀j,‖w j‖≤K*((j:ℝ)+1)^n) {a:ℂ} (ha:1≤a.re) :
    ‖∑'j:ℕ,w j*complexLogistic j a‖≤weightedMajorantSum K n := by
  have hs:=weightedLogistic_summable w K n hw ha
  have hm : Summable (fun j:ℕ=>K*((j:ℝ)+1)^n*logisticMajorant j) := by
    simpa only [mul_assoc] using (logisticMajorant_poly_summable n).mul_left K
  apply (norm_tsum_le_tsum_norm hs.norm).trans
  apply hs.norm.tsum_le_tsum _ hm
  intro j
  rw [norm_mul]
  exact mul_le_mul (hw j) (complexLogistic_bound j ha) (norm_nonneg _) ((norm_nonneg _).trans (hw j))

lemma weightedLogisticFirst_norm_bound (w:ℕ→ℂ) (K:ℝ) (n:ℕ)
    (hw:∀j,‖w j‖≤K*((j:ℝ)+1)^n) {a:ℂ} (ha:1≤a.re) :
    ‖∑'j:ℕ,w j*complexLogisticFirst j a‖≤weightedFirstMajorantSum K n := by
  have hs:=weightedLogisticFirst_summable w K n hw ha
  have hm : Summable (fun j:ℕ=>K*((j:ℝ)+1)^n*logisticFirstMajorant j) := by
    simpa only [mul_assoc] using (logisticFirstMajorant_poly_summable n).mul_left K
  apply (norm_tsum_le_tsum_norm hs.norm).trans
  apply hs.norm.tsum_le_tsum _ hm
  intro j
  rw [norm_mul]
  exact mul_le_mul (hw j) (complexLogisticFirst_bound j ha) (norm_nonneg _) ((norm_nonneg _).trans (hw j))

lemma prefactoredFirst_weight_bound (j:ℕ) :
    ‖(-1:ℂ)^j*(prefactoredFirst j:ℂ)‖≤3*((j:ℝ)+1)^2 := by
  simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul,Complex.norm_real,Real.norm_eq_abs]
    using prefactoredFirst_abs_bound j
lemma prefactoredSecond_weight_bound (j:ℕ) :
    ‖(-1:ℂ)^j*(prefactoredSecond j:ℂ)‖≤7*((j:ℝ)+1)^4 := by
  simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul,Complex.norm_real,Real.norm_eq_abs,
    abs_of_nonneg (prefactoredSecond_nonneg j)] using prefactoredSecond_bound j

lemma complexStationary1_bound {a:ℂ} (ha:1≤a.re) (haN:‖a‖≤2) :
    ‖complexStationary1 a‖≤stationaryCoefficientBound 3 2 := by
  have h0:=weightedLogistic_norm_bound (fun j=>(-1:ℂ)^j*(prefactoredFirst j:ℂ)) 3 2 prefactoredFirst_weight_bound ha
  have h1:=weightedLogisticFirst_norm_bound (fun j=>(-1:ℂ)^j*(prefactoredFirst j:ℂ)) 3 2 prefactoredFirst_weight_bound ha
  unfold complexStationary1 complexF1 complexF1Derivative stationaryCoefficientBound
  apply (norm_sub_le _ _).trans
  simp only [norm_mul,norm_neg,norm_ofNat]
  nlinarith [mul_le_mul_of_nonneg_right haN (norm_nonneg (∑'j:ℕ,(-1:ℂ)^j*(prefactoredFirst j:ℂ)*complexLogisticFirst j a))]

lemma complexStationary2_bound {a:ℂ} (ha:1≤a.re) (haN:‖a‖≤2) :
    ‖complexStationary2 a‖≤stationaryCoefficientBound 7 4 := by
  have h0:=weightedLogistic_norm_bound (fun j=>(-1:ℂ)^j*(prefactoredSecond j:ℂ)) 7 4 prefactoredSecond_weight_bound ha
  have h1:=weightedLogisticFirst_norm_bound (fun j=>(-1:ℂ)^j*(prefactoredSecond j:ℂ)) 7 4 prefactoredSecond_weight_bound ha
  unfold complexStationary2 complexF2 complexF2Derivative stationaryCoefficientBound
  apply (norm_sub_le _ _).trans
  simp only [norm_mul,norm_neg,norm_ofNat]
  nlinarith [mul_le_mul_of_nonneg_right haN (norm_nonneg (∑'j:ℕ,(-1:ℂ)^j*(prefactoredSecond j:ℂ)*complexLogisticFirst j a))]

theorem complexStationary_expansion_bound {z a:ℂ} (hz:0≤z.re) (hn:z≠0)
    (ha:1≤a.re) (haN:‖a‖≤2) :
    ‖complexStationary z a-(complexStationary0 a+complexStationary1 a/z+complexStationary2 a/z^2)‖≤
      stationaryRemainderBound/‖z‖^3 := by
  have hF:=complexF_expansion_bound hz hn ha
  have hD:=complexFDerivative_expansion_bound hz hn ha
  have he : complexStationary z a-(complexStationary0 a+complexStationary1 a/z+complexStationary2 a/z^2)=
      a*(complexFDerivative z a-(complexF0Derivative a+complexF1Derivative a/z+complexF2Derivative a/z^2))-
        (complexF z a-(complexF0 a+complexF1 a/z+complexF2 a/z^2)) := by
    unfold complexStationary complexStationary0 complexStationary1 complexStationary2
    ring
  rw [he]
  apply (norm_sub_le _ _).trans
  rw [norm_mul]
  calc
    _ ≤ 2*((4*∑'j:ℕ,complexDerivativeRemainderMajorant j)/‖z‖^3)+
        ((4*∑'j:ℕ,complexRemainderMajorant j)/‖z‖^3) := by
      apply add_le_add _ hF
      exact mul_le_mul haN hD (norm_nonneg _) (by norm_num)
    _ = _ := by unfold stationaryRemainderBound; ring

theorem complexStationary_first_expansion {z a:ℂ} (hz:0≤z.re) (hn:1≤‖z‖)
    (ha:1≤a.re) (haN:‖a‖≤2) :
    ‖complexStationary z a-(complexStationary0 a+complexStationary1 a/z)‖≤
      (stationaryCoefficientBound 7 4+stationaryRemainderBound)/‖z‖^2 := by
  have hzn:z≠0 := norm_ne_zero_iff.mp (ne_of_gt (lt_of_lt_of_le (by norm_num) hn))
  have he : complexStationary z a-(complexStationary0 a+complexStationary1 a/z)=
      (complexStationary z a-(complexStationary0 a+complexStationary1 a/z+complexStationary2 a/z^2))+
        complexStationary2 a/z^2 := by ring
  rw [he]
  apply (norm_add_le _ _).trans
  rw [norm_div,norm_pow]
  calc
    _ ≤ stationaryRemainderBound/‖z‖^3+stationaryCoefficientBound 7 4/‖z‖^2 := by
      exact add_le_add (complexStationary_expansion_bound hz hzn ha haN)
        (div_le_div_of_nonneg_right (complexStationary2_bound ha haN) (sq_nonneg _))
    _ ≤ stationaryRemainderBound/‖z‖^2+stationaryCoefficientBound 7 4/‖z‖^2 := by
      apply add_le_add _ le_rfl
      apply div_le_div_of_nonneg_left stationaryRemainderBound_nonneg (by positivity)
      nlinarith [sq_nonneg (‖z‖-1)]
    _ = _ := by ring

end NeuralGeneralization.OnlineLowerTanh
