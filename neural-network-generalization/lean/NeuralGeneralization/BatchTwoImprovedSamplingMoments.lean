import NeuralGeneralization.BatchTwoImprovedSquareRootSampling
import NeuralGeneralization.BatchTwoImprovedRankSafeLeverage

/-! # Importance-weighted active and residual reconstruction moments -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling Classical
variable {N q m : ℕ}

def sampleAverage (s : Fin m → Fin N) (f : Fin N → ℝ) : ℝ := (∑ i, f (s i))/(m:ℝ)

theorem importance_mean (p a : Fin N → ℝ) (hpa : ∀ j, p j*a j=1/(N:ℝ))
    (f : Fin N → ℝ) : mean p (fun j => a j*f j) = (∑ j, f j)/(N:ℝ) := by
  unfold mean
  simp_rw [← mul_assoc,hpa]
  rw [← Finset.mul_sum]
  ring

/-- Exact active estimator with row-dependent importance weights. -/
theorem active_sample_mean_square (hN : 0 < N) (hm : 0 < m)
    (p a : Fin N → ℝ) (hp : ∀ j, 0 ≤ p j) (hpm : ∑ j, p j=1)
    (ha : ∀ j, 0 ≤ a j) (ha2 : ∀ j, a j ≤ 2)
    (hpa : ∀ j, p j*a j=1/(N:ℝ))
    (u : Fin N → Fin q → ℝ)
    (hcov : ∀ v, (∑ j, (linearEvaluation (u j) v)^2)/(N:ℝ) ≤ ∑ k, (v k)^2)
    (h : Fin N → ℝ) (hh : ∀ j, (h j)^2 ≤ 1) (v : Fin q → ℝ) :
    mean (iidWeight p m) (fun s =>
      (sampleAverage s (fun j => a j*linearEvaluation (u j) v*h j)-
        (∑ j, linearEvaluation (u j) v*h j)/(N:ℝ))^2) ≤
      2*(∑ k, (v k)^2)/(m:ℝ) := by
  have he : mean p (fun j => a j*linearEvaluation (u j) v*h j) =
      (∑ j, linearEvaluation (u j) v*h j)/(N:ℝ) := by
    simpa only [mul_assoc] using importance_mean p a hpa (fun j => linearEvaluation (u j) v*h j)
  have hb : mean p (fun j => (a j*linearEvaluation (u j) v*h j)^2) ≤
      2*(∑ k, (v k)^2) := by
    have h1 : mean p (fun j => (a j*linearEvaluation (u j) v*h j)^2) ≤
        mean p (fun j => 2*(a j*(linearEvaluation (u j) v)^2)) := by
      apply mean_mono p hp
      intro j
      have hA : (a j)^2 ≤ 2*a j := by nlinarith [ha j,ha2 j]
      have hH := mul_le_mul_of_nonneg_left (hh j)
        (mul_nonneg (sq_nonneg (a j)) (sq_nonneg (linearEvaluation (u j) v)))
      have hL := mul_le_mul_of_nonneg_right hA (sq_nonneg (linearEvaluation (u j) v))
      nlinarith only [hH,hL]
    rw [mean_mul,importance_mean p a hpa] at h1
    exact h1.trans (mul_le_mul_of_nonneg_left (hcov v) (by norm_num))
  have hz := mean_iid_average_variance_le p hpm m hm (fun j => a j*linearEvaluation (u j) v*h j)
  rw [he] at hz
  exact hz.trans (div_le_div_of_nonneg_right hb (Nat.cast_nonneg m))

/-- Residual regression correlations have zero population mean. -/
theorem residual_sample_cross_square (hm : 0 < m)
    (p a : Fin N → ℝ) (hp : ∀ j, 0 ≤ p j) (hpm : ∑ j, p j=1)
    (ha : ∀ j, 0 ≤ a j) (hpa : ∀ j, p j*a j=1/(N:ℝ))
    (u : Fin N → Fin q → ℝ) (R : Fin N → ℝ)
    (horth : ∀ k, (∑ j, u j k*R j)=0)
    (henergy : ∀ j, a j*(∑ k, (u j k)^2) ≤ 2*q) :
    mean (iidWeight p m) (fun s =>
      ∑ k, (sampleAverage s (fun j => a j*u j k*R j))^2) ≤
      2*q*((∑ j, (R j)^2)/(N:ℝ))/(m:ℝ) := by
  have hz (k : Fin q) : mean p (fun j => a j*u j k*R j) = 0 := by
    have h := importance_mean p a hpa (fun j => u j k*R j)
    simpa only [horth k,zero_div,mul_assoc] using h
  have h1 (k : Fin q) : mean (iidWeight p m)
      (fun s => (sampleAverage s (fun j => a j*u j k*R j))^2) ≤
      mean p (fun j => (a j*u j k*R j)^2)/(m:ℝ) := by
    simpa only [hz k,sub_zero,sampleAverage] using
      mean_iid_average_variance_le p hpm m hm (fun j => a j*u j k*R j)
  rw [mean_sum]
  calc
    _ ≤ ∑ k, mean p (fun j => (a j*u j k*R j)^2)/(m:ℝ) :=
      Finset.sum_le_sum (fun k _ => h1 k)
    _ = mean p (fun j => ∑ k, (a j*u j k*R j)^2)/(m:ℝ) := by
      rw [← Finset.sum_div,mean_sum]
    _ ≤ mean p (fun j => 2*q*(a j*(R j)^2))/(m:ℝ) := by
      apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg m)
      apply mean_mono p hp
      intro j
      have he : (∑ k, (a j*u j k*R j)^2) =
          (a j*(∑ k, (u j k)^2))*(a j*(R j)^2) := by
        simp only [mul_pow,Finset.mul_sum,Finset.sum_mul]
        apply Finset.sum_congr rfl
        intro k _
        ring
      rw [he]
      exact mul_le_mul_of_nonneg_right (henergy j) (mul_nonneg (ha j) (sq_nonneg _))
    _ = _ := by rw [mean_mul,importance_mean p a hpa]

/-- Variance-sensitive residual energy: no dimension-dependent absolute
covariance error is introduced before taking square roots. -/
theorem residual_sample_sqrt_error (hm : 0 < m)
    (p a : Fin N → ℝ) (hp : ∀ j, 0 ≤ p j) (hpm : ∑ j, p j=1)
    (ha : ∀ j, 0 ≤ a j) (hpa : ∀ j, p j*a j=1/(N:ℝ))
    (R : Fin N → ℝ) (hbound : ∀ j, a j*(R j)^2 ≤ 4*((q:ℝ)+1)) :
    mean (iidWeight p m) (fun s =>
      (Real.sqrt (sampleAverage s (fun j => a j*(R j)^2))-
        Real.sqrt ((∑ j, (R j)^2)/(N:ℝ)))^2) ≤ 4*((q:ℝ)+1)/(m:ℝ) := by
  have hh := mean_squareRoot_average_error p hp hpm m hm
    (fun j => a j*(R j)^2) (fun j => mul_nonneg (ha j) (sq_nonneg _))
    (by positivity : 0 ≤ 4*((q:ℝ)+1)) hbound
  rw [importance_mean p a hpa] at hh
  exact hh

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
