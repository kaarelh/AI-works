import Paulsen.Paper.Toolbox

/-!
# Paper blueprint, Section 3: bounded rank, Hamilton–Moitra (`sections/bounded.tex`)
-/

namespace Paulsen.Paper

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-- `lem:HM`.

TeX: "Let $1\le d\le n$, let $X\in\R^{n\times d}$ have $\norm{x_i}^2=a$ for all $i$,
and let $\eta=\opn{X^TX-I}$. There is an ENP frame $W$ with
$\fro{X-W}^2\le\eta d(d-1)$."

Encoding: `IsNearlyParseval η X` means `η ≥ ‖XᵀX - I‖_op` (equivalent). -/
theorem lem_HM {n d : ℕ} (hd : 1 ≤ d) (hdn : d ≤ n) (X : Frame n d) (hX : IsEqualNorm X)
    {η : ℝ} (hη : IsNearlyParseval η X) :
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance X W ≤ η * (d : ℝ) * ((d : ℝ) - 1) := by
  sorry

/-- `cor:exist` (first sentence).

TeX: "For all $1\le d\le n$ an ENP frame exists." -/
theorem cor_exist {n d : ℕ} (hd : 1 ≤ d) (hdn : d ≤ n) :
    ∃ W : Frame n d, IsEqualNormParseval W := by
  sorry

/-- `cor:exist` (second sentence).

TeX: "Consequently every equal-norm $X\in\R^{n\times d}$ is within
$\fro{X-W}^2\le2\fro X^2+2\fro W^2=4d$ of an ENP frame $W$." -/
theorem cor_exist_trivial {n d : ℕ} (hd : 1 ≤ d) (hdn : d ≤ n) (X : Frame n d)
    (hX : IsEqualNorm X) :
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance X W ≤ 2 * frobSq X + 2 * frobSq W ∧
      2 * frobSq X + 2 * frobSq W = 4 * (d : ℝ) := by
  sorry

end

end Paulsen.Paper
