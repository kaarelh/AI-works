import NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringTail
import NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringFourier

/-! The finite normalized Fourier coefficient approximation and its exact error. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma restoringRatioPolynomial_error_le {q : ℝ} (hq0 : 0≤q) (hq1 : q<1)
    (j : ℕ) (hj1 : 1≤j) (hj5 : j≤5) :
    |restoringExactRatio q j-restoringRatioPolynomial q j| ≤ q^15/(1-q) := by
  interval_cases j
  · convert restoringRatio_geometric_error_le_margin hq0 hq1 1 3 5 (by norm_num) (by norm_num) using 1 <;>
      norm_num [restoringExactRatio,restoringRatioPolynomial,Finset.sum_range_succ]
  · convert restoringRatio_geometric_error_le_margin hq0 hq1 2 5 3 (by norm_num) (by norm_num) using 1 <;>
      norm_num [restoringExactRatio,restoringRatioPolynomial,Finset.sum_range_succ]
  · convert restoringRatio_geometric_error_le_margin hq0 hq1 3 7 2 (by norm_num) (by norm_num) using 1 <;>
      norm_num [restoringExactRatio,restoringRatioPolynomial,Finset.sum_range_succ]
  · convert restoringRatio_geometric_error_le_margin hq0 hq1 4 9 2 (by norm_num) (by norm_num) using 1 <;>
      norm_num [restoringExactRatio,restoringRatioPolynomial,Finset.sum_range_succ]
  · convert restoringRatio_geometric_error_le_margin hq0 hq1 5 11 1 (by norm_num) (by norm_num) using 1 <;>
      norm_num [restoringExactRatio,restoringRatioPolynomial,Finset.sum_range_succ]

end NeuralGeneralization.OnlineLowerTanh
