import Paulsen.Paper.Toolbox
import Paulsen.GaussianQuadraticForm
import Paulsen.GaussianLinearImage
import Paulsen.GaussianRotationConcentration
import Paulsen.GaussianOperatorNet

/-!
# Paper blueprint, Appendix A: Gaussian tools (`sections/gaussian.tex`)

Gaussian vectors are `g ∼ stdGaussian (EuclideanSpace ℝ κ)`; a correlated Gaussian vector
is `C g` (`Matrix.toEuclideanLin C g`) with covariance `C Cᵀ`; `Cov ⪯ σ² I` is
`‖C‖_op² ≤ σ²`.  Probabilities are `(stdGaussian _).real {g | …}`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- `lem:gauss` (a), quadratic forms.

TeX: "\emph{(Quadratic forms.)} For $g$ standard Gaussian and $\mathsf A$
symmetric, $\Var(g^T\mathsf Ag)=2\fro{\mathsf A}^2$ and
\[ \Prob\{|g^T\mathsf Ag-\tr\mathsf A|>u\}\le2\exp\Bigl[-\tfrac18\min\Bigl\{\frac{u^2}{\fro{\mathsf A}^2},\frac u{\opn{\mathsf A}}\Bigr\}\Bigr]. \]" -/
theorem lem_gauss_a {κ : Type*} [Fintype κ] [DecidableEq κ] (A : Matrix κ κ ℝ)
    (hA : A.IsHermitian) (u : ℝ) :
    variance (fun g => euclideanQuadratic A g) (stdGaussian (EuclideanSpace ℝ κ)) =
      2 * frobSq A ∧
    (stdGaussian (EuclideanSpace ℝ κ)).real {g | u < |euclideanQuadratic A g - A.trace|} ≤
      2 * Real.exp (-(1 / 8) * min (u ^ 2 / frobSq A) (u / opNorm A)) := by
  sorry

/-- `lem:gauss` (a), correlated version.

TeX: "For a Gaussian vector $\zeta=\Sigma^{1/2}g$, apply this to
$\Sigma^{1/2}\mathsf A\Sigma^{1/2}$, whose norms are at most $\opn\Sigma$ times those of
$\mathsf A$."

Encoding: `ζ = C g` with `Σ = C Cᵀ`; then `ζᵀAζ = gᵀ(CᵀAC)g`, and `CᵀAC` plays the role of
`Σ^{1/2}AΣ^{1/2}`. -/
theorem lem_gauss_a_correlated {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ]
    [DecidableEq κ] (A : Matrix ι ι ℝ) (hA : A.IsHermitian) (C : Matrix ι κ ℝ) (u : ℝ) :
    (∀ g : EuclideanSpace ℝ κ,
      euclideanQuadratic A (Matrix.toEuclideanLin C g) =
        euclideanQuadratic (C.transpose * A * C) g) ∧
    frobSq (C.transpose * A * C) ≤ opNorm (C * C.transpose) ^ 2 * frobSq A ∧
    opNorm (C.transpose * A * C) ≤ opNorm (C * C.transpose) * opNorm A ∧
    (stdGaussian (EuclideanSpace ℝ κ)).real
        {g | u < |euclideanQuadratic A (Matrix.toEuclideanLin C g) -
          (C.transpose * A * C).trace|} ≤
      2 * Real.exp (-(1 / 8) * min (u ^ 2 / frobSq (C.transpose * A * C))
        (u / opNorm (C.transpose * A * C))) := by
  sorry

/-- `lem:gauss` (b), Lipschitz functions.

TeX: "\emph{(Lipschitz functions.)} If $F$ is $C^1$ with $\norm{\nabla F}\le\ell$
and $g$ is standard Gaussian, then
$\Prob\{|F(g)-\E F(g)|>u\}\le2\exp(-2u^2/(\pi^2\ell^2))$."

(`u ≥ 0` is implicit in the paper; the inequality is false for very negative `u`.) -/
theorem lem_gauss_b {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E]
    (F : E → ℝ) (hF : ContDiff ℝ 1 F) {ℓ : ℝ} (hℓ : ∀ x, ‖fderiv ℝ F x‖ ≤ ℓ)
    {u : ℝ} (hu : 0 ≤ u) :
    (stdGaussian E).real {x | u < |F x - ∫ y, F y ∂stdGaussian E|} ≤
      2 * Real.exp (-2 * u ^ 2 / (Real.pi ^ 2 * ℓ ^ 2)) := by
  sorry

/-- `lem:gauss` (c), nets.

TeX: "\emph{(Nets.)} If $Z$ is an $r\times s$ centred Gaussian matrix with
$\Cov(\mathrm{vec}\,Z)\preceq\sigma^2I$, then
$\Prob\{\opn Z>u\}\le2\cdot5^{r+s}\exp(-u^2/(32\sigma^2))$."

Encoding: `Z = frameOfVector (C g)`, `Cov(vec Z) = C Cᵀ ⪯ σ² I ⟺ ‖C‖_op² ≤ σ²`.
(`u ≥ 0` is implicit in the paper.) -/
theorem lem_gauss_c {r s : ℕ} {κ : Type*} [Fintype κ] [DecidableEq κ]
    (C : Matrix (Fin r × Fin s) κ ℝ) {σ u : ℝ} (hu : 0 ≤ u) (hC : opNorm C ^ 2 ≤ σ ^ 2) :
    (stdGaussian (EuclideanSpace ℝ κ)).real
        {g | u < opNorm (frameOfVector (Matrix.toEuclideanLin C g))} ≤
      2 * 5 ^ (r + s) * Real.exp (-u ^ 2 / (32 * σ ^ 2)) := by
  sorry

/-- Paragraph "Covariance domination" (unnumbered claim used in `lem:sample` (S4)).

TeX: "If a Gaussian vector $\xi$ has covariance
$\Gamma\preceq\gamma I$ and $(M_\alpha)$ are matrices, then
$\E\fro{\sum_\alpha\xi_\alpha M_\alpha}^2=\tr(\Gamma\mathsf G)\le\gamma\sum_\alpha
\fro{M_\alpha}^2$, where $\mathsf G\succeq0$ is the Gram matrix of the $M_\alpha$."

Encoding: `ξ = C g`, `Γ = C Cᵀ`, `Γ ⪯ γ I ⟺ ‖C‖_op² ≤ γ`. -/
theorem covariance_domination {α κ : Type*} [Fintype α] [DecidableEq α] [Fintype κ]
    [DecidableEq κ] {p q : ℕ} (C : Matrix α κ ℝ) {γ : ℝ} (hC : opNorm C ^ 2 ≤ γ)
    (M : α → Matrix (Fin p) (Fin q) ℝ) :
    ∫ g, frobSq (∑ a, (Matrix.toEuclideanLin C g) a • M a)
        ∂stdGaussian (EuclideanSpace ℝ κ) =
      (C * C.transpose * Matrix.of (fun a b => ∑ i, ∑ j, M a i j * M b i j)).trace ∧
    (C * C.transpose * Matrix.of (fun a b => ∑ i, ∑ j, M a i j * M b i j)).trace ≤
      γ * ∑ a, frobSq (M a) := by
  sorry

end

end Paulsen.Paper
