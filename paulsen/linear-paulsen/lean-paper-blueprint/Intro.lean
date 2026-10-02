import Paulsen.Paper.Toolbox

/-!
# Paper blueprint, Section 1: statement and optimality (`sections/intro.tex`)

`thm:main` and `thm:projection` are stated in `Paulsen.Paper.Assembly` (where the paper
proves them), as `Paulsen.SharpPaulsenBound` and `Paulsen.SharpProjectionBound`.
This file contains the definitions of the statement section and `rem:optimal`.
-/

namespace Paulsen.Paper

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-- Definitions of the statement section.

TeX: "$X$ is \emph{Parseval} if $X^TX=I_d$ and \emph{equal-norm} if
$\norm{x_i}^2=a$ for all $i$; an equal-norm Parseval frame is an \emph{ENP frame}."

These are the library's `IsParseval`, `IsEqualNorm`, `IsEqualNormParseval`. -/
theorem def_enp {n d : ℕ} (X : Frame n d) :
    IsEqualNormParseval X ↔
      X.transpose * X = 1 ∧ ∀ i, rowNormSq X i = (d : ℝ) / n :=
  Iff.rfl

/-- `eq:nearly` (definition of an `ε`-nearly ENP frame), faithfulness of the encoding.

TeX: "$X$ is an \emph{$\eps$-nearly ENP frame} if
\[ (1-\eps)I_d\preceq X^TX\preceq(1+\eps)I_d,
 \qquad (1-\eps)a\le\norm{x_i}^2\le(1+\eps)a\quad(1\le i\le n). \]"

The library predicate `IsNearlyEqualNormParseval ε X` (quadratic-form encoding of `⪯`) is
equivalent to the Loewner-order formulation. -/
theorem eq_nearly_iff {n d : ℕ} (ε : ℝ) (X : Frame n d) :
    IsNearlyEqualNormParseval ε X ↔
      ((X.transpose * X - (1 - ε) • (1 : Matrix (Fin d) (Fin d) ℝ)).PosSemidef ∧
        ((1 + ε) • (1 : Matrix (Fin d) (Fin d) ℝ) - X.transpose * X).PosSemidef) ∧
      ∀ i, (1 - ε) * ((d : ℝ) / n) ≤ rowNormSq X i ∧
        rowNormSq X i ≤ (1 + ε) * ((d : ℝ) / n) := by
  sorry

/-- The block-diagonal frame `X = X₁ ⊕ X₂` of `rem:optimal`, with `X₁` of `n₁ - k` rows and
`X₂` of `n₁ + k` rows, both in `ℝ^{d₁}`; it has `(n₁-k)+(n₁+k) = 2n₁` rows and `2d₁`
columns. -/
def optimalExample {n₁ k d₁ : ℕ} (X₁ : Frame (n₁ - k) d₁) (X₂ : Frame (n₁ + k) d₁) :
    Frame ((n₁ - k) + (n₁ + k)) (d₁ + d₁) :=
  Matrix.reindex finSumFinEquiv finSumFinEquiv (Matrix.fromBlocks X₁ 0 0 X₂)

/-- `rem:optimal` (Optimality).

TeX: "Let $d=2d_1$, $n=2n_1$, and $1\le k\le n_1/4$ with $n_1-k\ge d_1$; put
$\eps=4k/n$. Let $X=X_1\oplus X_2$, where $X_1$ is an ENP frame of $n_1-k$
vectors in $\R^{d_1}$ and $X_2$ one of $n_1+k$ vectors in $\R^{d_1}$
(\cref{cor:exist}). Then $X$ is Parseval, and its squared row norms
$a(1\mp2k/n)^{-1}$ make it an $\eps$-nearly ENP frame. Let $W$ be ENP, [...]
so $\Delta=E-A$ has $\tr\Delta=ka=\eps d/4$. [...]
i.e.\ $\fro{XX^T-WW^T}^2\ge\tr\Delta$, and by \cref{lem:align}
$\fro{X-W}^2\ge\frac12\tr\Delta=\eps d/8$."

Here `n = (n₁-k)+(n₁+k)` and `d = d₁+d₁`. -/
theorem rem_optimal (n₁ k d₁ : ℕ) (hk : 1 ≤ k) (hkn : 4 * k ≤ n₁) (hkd : d₁ ≤ n₁ - k)
    (X₁ : Frame (n₁ - k) d₁) (X₂ : Frame (n₁ + k) d₁)
    (hX₁ : IsEqualNormParseval X₁) (hX₂ : IsEqualNormParseval X₂) :
    let N : ℝ := (((n₁ - k) + (n₁ + k) : ℕ) : ℝ)
    let D : ℝ := ((d₁ + d₁ : ℕ) : ℝ)
    let ε : ℝ := 4 * (k : ℝ) / N
    N = 2 * (n₁ : ℝ) ∧
    IsParseval (optimalExample X₁ X₂) ∧
    (∀ i : Fin (n₁ - k), rowNormSq (optimalExample X₁ X₂) (finSumFinEquiv (Sum.inl i)) =
      D / N * (1 - 2 * (k : ℝ) / N)⁻¹) ∧
    (∀ i : Fin (n₁ + k), rowNormSq (optimalExample X₁ X₂) (finSumFinEquiv (Sum.inr i)) =
      D / N * (1 + 2 * (k : ℝ) / N)⁻¹) ∧
    IsNearlyEqualNormParseval ε (optimalExample X₁ X₂) ∧
    ∀ W : Frame ((n₁ - k) + (n₁ + k)) (d₁ + d₁), IsEqualNormParseval W →
      (k : ℝ) * (D / N) = ε * D / 4 ∧
      (k : ℝ) * (D / N) ≤
          sqDistance (frameProjection (optimalExample X₁ X₂)) (frameProjection W) ∧
      ε * D / 8 ≤ sqDistance (optimalExample X₁ X₂) W := by
  sorry

end

end Paulsen.Paper
