import NeuralGeneralization.OnlineLowerTanhBiasPeakMoment
import NeuralGeneralization.OnlineLowerTanhDegreeRatio

/-! Quantitative first-order penalties at all fixed periodic bias peaks,
for literal finite tanh coefficients and uniformly over gains at least one. -/
noncomputable section
open scoped BigOperators
open Polynomial
namespace NeuralGeneralization.OnlineLowerTanh

def biasPeakErrorConstant (P:Polynomial ℝ) : ℝ :=
  ∑j∈P.support,|P.coeff j| * balancedDegreeRatioError j

lemma balancedParity_pos_of_one_le (r:ℕ) (a:ℝ) (ha:1≤a) : 0<balancedParity r a := by
  have h:=balancedNormalized_lower r a ha
  have hp:0<balancedParity r a/oddParityKappa r := by
    change (1/2:ℝ)<balancedParity r a/oddParityKappa r at h
    linarith
  exact (div_pos_iff.mp hp).resolve_right (fun hh=>(oddParityKappa_pos r).not_gt hh.2) |>.1

lemma balancedPolynomialMoment_ratio_error (r:ℕ) (a:ℝ) (ha:1≤a) (P:Polynomial ℝ) :
    |balancedPolynomialMoment r a P/balancedParity r a-
      (P.eval 1-P.derivative.eval 1/(2*(r:ℝ)+1))|≤
      biasPeakErrorConstant P/(2*(r:ℝ)+1)^2 := by
  have h:=polynomial_moment_ratio_error P (fun j=>balancedParity (r+j) a)
    (2*(r:ℝ)+1) (balancedParity r a) (balancedParity_pos_of_one_le r a ha).ne'
    (fun j=>balancedDegreeRatioError j/(2*(r:ℝ)+1)^2)
    (fun j _=>balancedParity_shift_ratio_error r j a ha)
  simpa only [balancedPolynomialMoment,biasPeakErrorConstant,Finset.sum_div,mul_div_assoc] using h

lemma signed_odd_bulk_peak_exact (r l:ℕ) (a:ℝ) :
    (-1:ℝ)^(r+l)*parityCorrelation (fun _:Fin (2*r+1)=>a) (2*(l:ℝ)*a)=
      balancedPolynomialMoment r a (oddBiasPeakPolynomial l) := by
  rw [odd_bulk_peak_exact,←mul_assoc,sign_nat_square,one_mul]

lemma signed_even_bulk_peak_exact (r l:ℕ) (a:ℝ) :
    (-1:ℝ)^(r+l)*parityCorrelation (fun _:Fin (2*r)=>a) ((2*(l:ℝ)+1)*a)=
      balancedPolynomialMoment r a (evenBiasPeakPolynomial l) := by
  rw [even_bulk_peak_exact,←mul_assoc,sign_nat_square,one_mul]

/-- Noncentral odd-bulk peaks lose exactly `2l²/n` to first order. -/
theorem odd_bulk_peak_ratio_error (r l:ℕ) (a:ℝ) (ha:1≤a) :
    |((-1:ℝ)^(r+l)*parityCorrelation (fun _:Fin (2*r+1)=>a) (2*(l:ℝ)*a))/
      balancedParity r a-(1-2*(l:ℝ)^2/(2*(r:ℝ)+1))|≤
      biasPeakErrorConstant (oddBiasPeakPolynomial l)/(2*(r:ℝ)+1)^2 := by
  rw [signed_odd_bulk_peak_exact]
  simpa using balancedPolynomialMoment_ratio_error r a ha (oddBiasPeakPolynomial l)

/-- Noncentral even-bulk peaks lose exactly `2l(l+1)/n` to first order,
where `n` is the next odd degree. -/
theorem even_bulk_peak_ratio_error (r l:ℕ) (a:ℝ) (ha:1≤a) :
    |((-1:ℝ)^(r+l)*parityCorrelation (fun _:Fin (2*r)=>a) ((2*(l:ℝ)+1)*a))/
      balancedParity r a-(1-2*(l:ℝ)*((l:ℝ)+1)/(2*(r:ℝ)+1))|≤
      biasPeakErrorConstant (evenBiasPeakPolynomial l)/(2*(r:ℝ)+1)^2 := by
  rw [signed_even_bulk_peak_exact]
  simpa using balancedPolynomialMoment_ratio_error r a ha (evenBiasPeakPolynomial l)

end NeuralGeneralization.OnlineLowerTanh
