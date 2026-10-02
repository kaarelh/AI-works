import Paulsen.Linear.Seed
import Paulsen.Linear.Core
import Paulsen.Linear.BlockBarrier
import Paulsen.MedianBarrier
import Paulsen.FrameAlignment
import Paulsen.ScalingDistance
import Paulsen.NormalTangentGraph
import Paulsen.PolarGram
import Paulsen.DiagonalScalingPotential
import Mathlib.Analysis.Matrix.HermitianFunctionalCalculus

/-!
# Paper blueprint, Section 2: the scaling toolbox (`sections/toolbox.tex`)

Statements only (proofs are `sorry`).  Every numbered item of `toolbox.tex` is stated
with exactly the constants of the paper.

## Encoding conventions (used in all `Paulsen.Paper` files)

* A frame `X ∈ ℝ^{n×d}` is `X : Frame n d` (rows are the frame vectors); `a = d/n` is
  written `(d : ℝ) / n`; `‖x_i‖² = rowNormSq X i`; `P = UUᵀ = frameProjection U`,
  `p_i = P_ii = rowNormSq U i`.
* `‖X - Y‖_F² = sqDistance X Y`; `‖M‖_F² = frobSq M`.
* The Euclidean operator norm `‖M‖_op` is `opNorm M`, the norm of the continuous linear map
  `Matrix.toEuclideanLin M`.  For a *symmetric* matrix we sometimes use the equivalent
  quadratic-form encoding `∀ x, |xᵀ M x| ≤ c ‖x‖²` (and `A ⪯ B` is `∀ x, xᵀAx ≤ xᵀBx`).
* A spectral error `‖XᵀX - I‖_op ≤ η` is `IsNearlyParseval η X` (see
  `isNearlyParseval_iff_opNorm`).  Where the paper *defines* `η := ‖XᵀX-I‖`, the blueprint
  takes any `η ≥ ‖XᵀX-I‖`; all conclusions are monotone in `η`, so this is equivalent.
* `‖v‖_∞ ≤ β` is written `∀ i, |v i| ≤ β`; `max_i`/`min_i` bounds are written pointwise.
* The weighted Laplacian of weights `w` acts by `weightedLaplacian w x i = ∑ⱼ wᵢⱼ (xᵢ - xⱼ)`;
  the barrier constant bound `H(L) ≤ H` is `Paulsen.Linear.HasBarrierBound w H`.
* `M^{-1/2}` for a positive definite matrix is `invSqrt M` (continuous functional calculus).
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators ContDiff

noncomputable section

/-! ## Generic notation -/

/-- The Euclidean operator norm `‖M‖_op` of a real matrix, encoded as the norm of the
induced continuous linear map `EuclideanSpace ℝ κ → EuclideanSpace ℝ ι`. -/
def opNorm {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq κ] (M : Matrix ι κ ℝ) : ℝ :=
  ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖

/-- The squared Frobenius norm `‖M‖_F² = ∑_{i,j} M_{ij}²`. -/
def frobSq {ι κ : Type*} [Fintype ι] [Fintype κ] (M : Matrix ι κ ℝ) : ℝ :=
  ∑ i, ∑ j, M i j ^ 2

/-- `G^{-1/2}`, defined by the continuous functional calculus with the function
`x ↦ 1/√x`; for positive definite `G` this is the unique positive definite inverse square
root. -/
def invSqrt {k : Type*} [Fintype k] [DecidableEq k] (G : Matrix k k ℝ) : Matrix k k ℝ :=
  cfc (fun x : ℝ => (Real.sqrt x)⁻¹) G

/-- The polar factor `X̃ = X (XᵀX)^{-1/2}` of `lem:align`. -/
def polarFactor {n d : ℕ} (X : Frame n d) : Frame n d :=
  X * invSqrt (X.transpose * X)

/-- The singular values `σ_1,…,σ_d` of `UᵀW`: square roots of the eigenvalues of
`(UᵀW)ᵀ(UᵀW)`. -/
def crossSingularValues {n d : ℕ} (U W : Frame n d) : Fin d → ℝ :=
  fun k => Real.sqrt
    ((Matrix.posSemidef_conjTranspose_mul_self (U.transpose * W)).isHermitian.eigenvalues k)

/-- Encoding check (not in the paper): the quadratic-form predicate `IsNearlyParseval δ X`
is exactly `‖XᵀX - I‖_op ≤ δ`. -/
theorem isNearlyParseval_iff_opNorm {n d : ℕ} (X : Frame n d) {δ : ℝ} (hδ : 0 ≤ δ) :
    IsNearlyParseval δ X ↔ opNorm (X.transpose * X - 1) ≤ δ := by
  sorry

/-- Encoding check (not in the paper): `invSqrt G` is the positive definite inverse square
root of a positive definite `G`. -/
theorem invSqrt_spec {k : Type*} [Fintype k] [DecidableEq k] (G : Matrix k k ℝ)
    (hG : G.PosDef) :
    (invSqrt G).PosDef ∧ invSqrt G * invSqrt G = G⁻¹ ∧ invSqrt G * G * invSqrt G = 1 := by
  sorry

/-! ## 2.1 Projections, distances, and the squared-Gram Laplacian -/

/-- `lem:align` (first display).

TeX: "Let $U,W\in\R^{n\times d}$ be Parseval with projections $P,Q$, and let
$\sigma_1,\dots,\sigma_d\in[0,1]$ be the singular values of $U^TW$. Then
\[ \min_{R\in O(d)}\fro{U-WR}^2=2\sum_k(1-\sigma_k)\le
 \fro{P-Q}^2=2\sum_k(1-\sigma_k^2)=2\fro{(I-P)W}^2\le2\fro{U-W}^2 . \]"

The minimum over `O(d)` is encoded with `IsLeast`. -/
theorem lem_align {n d : ℕ} (U W : Frame n d) (hU : IsParseval U) (hW : IsParseval W) :
    (∀ k, 0 ≤ crossSingularValues U W k ∧ crossSingularValues U W k ≤ 1) ∧
    IsLeast {c | ∃ R ∈ Matrix.orthogonalGroup (Fin d) ℝ, c = sqDistance U (W * R)}
      (2 * ∑ k, (1 - crossSingularValues U W k)) ∧
    2 * ∑ k, (1 - crossSingularValues U W k) ≤
      sqDistance (frameProjection U) (frameProjection W) ∧
    sqDistance (frameProjection U) (frameProjection W) =
      2 * ∑ k, (1 - crossSingularValues U W k ^ 2) ∧
    sqDistance (frameProjection U) (frameProjection W) =
      2 * frobSq ((1 - frameProjection U) * W) ∧
    sqDistance (frameProjection U) (frameProjection W) ≤ 2 * sqDistance U W := by
  sorry

/-- `lem:align` (second sentence).

TeX: "Right multiplication by $R\in O(d)$ preserves Parsevalness and every row norm." -/
theorem lem_align_orthogonal {n d : ℕ} (U : Frame n d) (R : Matrix (Fin d) (Fin d) ℝ)
    (hR : R ∈ Matrix.orthogonalGroup (Fin d) ℝ) :
    (IsParseval U → IsParseval (U * R)) ∧ ∀ i, rowNormSq (U * R) i = rowNormSq U i := by
  sorry

/-- `lem:align` (polar factor).

TeX: "If $X\in\R^{n\times d}$ has $\delta=\opn{X^TX-I}<1$, its polar factor
$\tilde X=X(X^TX)^{-1/2}$ is Parseval, $\fro{X-\tilde X}^2\le d\delta^2$, and
$\norm{x_i}^2/(1+\delta)\le\norm{\tilde x_i}^2\le\norm{x_i}^2/(1-\delta)$."

Encoding: `IsNearlyParseval δ X` means `δ ≥ ‖XᵀX - I‖_op`. -/
theorem lem_align_polar {n d : ℕ} (X : Frame n d) {δ : ℝ} (hδ0 : 0 ≤ δ) (hδ1 : δ < 1)
    (hX : IsNearlyParseval δ X) :
    IsParseval (polarFactor X) ∧
    sqDistance X (polarFactor X) ≤ (d : ℝ) * δ ^ 2 ∧
    ∀ i, rowNormSq X i / (1 + δ) ≤ rowNormSq (polarFactor X) i ∧
      rowNormSq (polarFactor X) i ≤ rowNormSq X i / (1 - δ) := by
  sorry

/-- `lem:align` (polar factor, `δ ≤ 1/2`).

TeX: "If moreover $\delta\le\frac12$, then
$|\norm{\tilde x_i}^2-\norm{x_i}^2|\le2\delta\norm{x_i}^2$ and row $i$ of
$\tilde X\tilde X^T-XX^T$ has squared norm at most $6\delta^2\norm{x_i}^2$." -/
theorem lem_align_polar_half {n d : ℕ} (X : Frame n d) {δ : ℝ} (hδ0 : 0 ≤ δ)
    (hδ : δ ≤ 1 / 2) (hX : IsNearlyParseval δ X) (i : Fin n) :
    |rowNormSq (polarFactor X) i - rowNormSq X i| ≤ 2 * δ * rowNormSq X i ∧
    rowNormSq (frameProjection (polarFactor X) - frameProjection X) i ≤
      6 * δ ^ 2 * rowNormSq X i := by
  sorry

/-- `lem:energy` (Energy identity).

TeX: "$L$ is the Laplacian of the weights $P_{ij}^2$ $(i\ne j)$, $L\succeq0$,
$L\one=0$, $L_{I-P}=L_P$, and for $x\in\R^n$, $X=\Diag(x)$,
\[ x^TLx=\tfrac12\sum_{i,j}P_{ij}^2(x_i-x_j)^2=\fro{(I-P)XU}^2
 =\tfrac12\fro{[X,P]}^2 . \]"

Here `L = L_P = projectionLaplacian P = Diag(p) - P∘P`. -/
theorem lem_energy {n d : ℕ} (U : Frame n d) (hU : IsParseval U) :
    (∀ (x : Fin n → ℝ) (i : Fin n),
      (projectionLaplacian (frameProjection U) *ᵥ x) i =
        weightedLaplacian (fun i j => if i = j then 0 else frameProjection U i j ^ 2) x i) ∧
    (projectionLaplacian (frameProjection U)).PosSemidef ∧
    projectionLaplacian (frameProjection U) *ᵥ (fun _ => (1 : ℝ)) = 0 ∧
    projectionLaplacian (1 - frameProjection U) = projectionLaplacian (frameProjection U) ∧
    ∀ x : Fin n → ℝ,
      matrixQuadratic (projectionLaplacian (frameProjection U)) x =
          (1 / 2) * ∑ i, ∑ j, frameProjection U i j ^ 2 * (x i - x j) ^ 2 ∧
      matrixQuadratic (projectionLaplacian (frameProjection U)) x =
          frobSq ((1 - frameProjection U) * Matrix.diagonal x * U) ∧
      matrixQuadratic (projectionLaplacian (frameProjection U)) x =
          (1 / 2) * frobSq (diagonalCommutator x (frameProjection U)) := by
  sorry

/-- `lem:scaled` (Scaled projections).

TeX: "For $w\in\R^n_{>0}$ put $D=\Diag(w)$, $M=(U^TD^2U)^{-1/2}$ and $W=DUM$. Then
$W$ is Parseval with column space $D\im U$, and
\[ \fro{WW^T-P}^2=2\fro{(I-P)W}^2\le\frac{2\,w^TLw}{\min_iw_i^2} . \]"

Encoding: `min_i w_i` is replaced by any `m > 0` with `m ≤ w_i` for all `i` (equivalent,
as the bound is antitone in `m`). -/
theorem lem_scaled {n d : ℕ} (U : Frame n d) (hU : IsParseval U) (w : Fin n → ℝ)
    (hw : ∀ i, 0 < w i) {m : ℝ} (hm : 0 < m) (hmw : ∀ i, m ≤ w i) :
    IsParseval (Matrix.diagonal w * U *
        invSqrt (U.transpose * Matrix.diagonal w ^ 2 * U)) ∧
    LinearMap.range (Matrix.mulVecLin (Matrix.diagonal w * U *
        invSqrt (U.transpose * Matrix.diagonal w ^ 2 * U))) =
      LinearMap.range (Matrix.mulVecLin (Matrix.diagonal w * U)) ∧
    sqDistance (frameProjection (Matrix.diagonal w * U *
        invSqrt (U.transpose * Matrix.diagonal w ^ 2 * U))) (frameProjection U) =
      2 * frobSq ((1 - frameProjection U) * (Matrix.diagonal w * U *
        invSqrt (U.transpose * Matrix.diagonal w ^ 2 * U))) ∧
    2 * frobSq ((1 - frameProjection U) * (Matrix.diagonal w * U *
        invSqrt (U.transpose * Matrix.diagonal w ^ 2 * U))) ≤
      2 * matrixQuadratic (projectionLaplacian (frameProjection U)) w / m ^ 2 := by
  sorry

/-! ## 2.2 Diagonal scaling -/

/-- `F(s) = ½ log det(Uᵀ D_s² U)` with `D_s = Diag(e^s)`. -/
def scalingPotential {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) : ℝ :=
  (1 / 2) * Real.log (U.transpose * Matrix.diagonal (fun i => Real.exp (2 * s i)) * U).det

/-- `P(s)`, the orthogonal projection onto `D_s im U` (Gram-inverse formula). -/
def scaledProjection {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  columnSpaceProjection (Matrix.diagonal (fun i => Real.exp (s i)) * U)

/-- `r(s) = diag P(s)`. -/
def scaledDiagonal {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) : Fin n → ℝ :=
  fun i => scaledProjection U s i i

/-- `lem:potential`.

TeX: "$F$ is smooth and convex, $\nabla F(s)=r(s)$, $\sum_ir_i(s)=d$, and
$F(s+c\one)=F(s)+cd$." -/
theorem lem_potential {n d : ℕ} (U : Frame n d) (hU : IsParseval U) :
    ContDiff ℝ ∞ (scalingPotential U) ∧
    ConvexOn ℝ Set.univ (scalingPotential U) ∧
    (∀ s, HasFDerivAt (scalingPotential U)
      (∑ i, scaledDiagonal U s i • (ContinuousLinearMap.proj i : (Fin n → ℝ) →L[ℝ] ℝ)) s) ∧
    (∀ s, ∑ i, scaledDiagonal U s i = (d : ℝ)) ∧
    ∀ s (c : ℝ), scalingPotential U (fun i => s i + c) = scalingPotential U s + c * d := by
  sorry

/-- The diagonal `r` of the projection onto `Diag(√z) im U` (used in `lem:scaling-ineq`). -/
def sqrtScaledDiagonal {n d : ℕ} (U : Frame n d) (z : Fin n → ℝ) : Fin n → ℝ :=
  fun i => columnSpaceProjection (Matrix.diagonal (fun j => Real.sqrt (z j)) * U) i i

/-- `lem:scaling-ineq` (One-sided scaling inequalities).

TeX: "For $z\in\R^n_{>0}$ let $r$ be the diagonal of the projection onto
$\Diag(\sqrt z)\im U$. Then, coordinatewise,
\[ Lz\le z\circ(r-p),\qquad L(z^{-1})\le-z^{-1}\circ(r-p). \]" -/
theorem lem_scaling_ineq {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (z : Fin n → ℝ) (hz : ∀ i, 0 < z i) (i : Fin n) :
    weightedLaplacian (fun i j => frameProjection U i j ^ 2) z i ≤
      z i * (sqrtScaledDiagonal U z i - rowNormSq U i) ∧
    weightedLaplacian (fun i j => frameProjection U i j ^ 2) (fun j => (z j)⁻¹) i ≤
      -(z i)⁻¹ * (sqrtScaledDiagonal U z i - rowNormSq U i) := by
  sorry

/-! ## 2.3 The barrier constant and static balancing -/

/-- `def:barrier` (Barrier constant).

TeX: "Let $L$ be a weighted Laplacian on $[n]$. For $S\subseteq[n]$, an
\emph{$S$-barrier} is a vector $\psi\ge0$ with $(L\psi)_i\ge1$ for every
$i\notin S$. The \emph{barrier constant} $H(L)\in(0,\infty]$ is the least $H$ such
that every $S$ with $|S|\ge n/2$ has an $S$-barrier with $\norm\psi_\infty\le H$
($H(L)=\infty$ if some such $S$ has no barrier)."

The predicates `S`-barrier and `H(L) ≤ H` are the library's `Paulsen.Linear.IsBarrier` and
`Paulsen.Linear.HasBarrierBound`; here is the value `H(L) ∈ [0,∞]` itself. -/
def barrierConstant {ι : Type*} [Fintype ι] [DecidableEq ι] (w : ι → ι → ℝ) : ENNReal :=
  ⨅ (H : NNReal) (_ : Linear.HasBarrierBound w (H : ℝ)), (H : ENNReal)

/-- `def:barrier` ("the least `H`"): the infimum defining `H(L)` is attained, so
`H(L) ≤ H` iff `HasBarrierBound w H`. -/
theorem barrierConstant_le_iff {ι : Type*} [Fintype ι] [DecidableEq ι] (w : ι → ι → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i) {H : ℝ} (hH : 0 ≤ H) :
    barrierConstant w ≤ ENNReal.ofReal H ↔ Linear.HasBarrierBound w H := by
  sorry

/-- Paragraph after `def:barrier` (unnumbered claim).

TeX: "If $H(L)<\infty$ then the graph is connected: for a component $J$ with
$|J|\le n/2$, summing $(L\psi)_i$ over $i\in J$ gives $0$, so $S=[n]\setminus J$ has no
barrier."

Encoding: no nonempty `J` with `2|J| ≤ n` is closed under the edges. -/
theorem barrier_connected {ι : Type*} [Fintype ι] [DecidableEq ι] (w : ι → ι → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i) {H : ℝ}
    (hH : Linear.HasBarrierBound w H) (J : Finset ι) (hJ : J.Nonempty)
    (hJn : 2 * J.card ≤ Fintype.card ι) :
    ∃ i ∈ J, ∃ j, j ∉ J ∧ 0 < w i j := by
  sorry

/-- `lem:median` (Median barrier).

TeX: "Let $L$ be a weighted Laplacian on $[n]$ with $H(L)\le H<\infty$, let $\beta\ge0$
with $\beta H<1$, let $z\in\R^n_{>0}$, and let $m$ be a median of $z$ (so that
$\{z\le m\}$ and $\{z\ge m\}$ both have at least $n/2$ elements). If
\[ (Lz)_i\le\beta z_i\ \text{ when }z_i>m,\qquad
 (Lz^{-1})_i\le\beta z_i^{-1}\ \text{ when }z_i<m , \]
then $(1-\beta H)\max_iz_i\le m\le(1-\beta H)^{-1}\min_iz_i$." -/
theorem lem_median {ι : Type*} [Fintype ι] [DecidableEq ι] (w : ι → ι → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i) {H β : ℝ}
    (hH : Linear.HasBarrierBound w H) (hβ : 0 ≤ β) (hβH : β * H < 1)
    (z : ι → ℝ) (hz : ∀ i, 0 < z i) (m : ℝ)
    (hlow : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => z i ≤ m)).card)
    (hhigh : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => m ≤ z i)).card)
    (hsub : ∀ i, m < z i → weightedLaplacian w z i ≤ β * z i)
    (hsup : ∀ i, z i < m → weightedLaplacian w (fun j => (z j)⁻¹) i ≤ β * (z i)⁻¹) :
    (∀ i, (1 - β * H) * z i ≤ m) ∧ ∀ i, m ≤ (1 - β * H)⁻¹ * z i := by
  sorry

/-- `thm:balancing` (Static balancing).

TeX: "Suppose $H(L_P)\le H<\infty$, and $q\in\R^n$ satisfies $\sum_iq_i=d$ and
$\beta H\le\frac12$, where $\beta=\norm{q-p}_\infty$. Then
there is a Parseval $W$ with $\diag(WW^T)=q$ and
\[ \fro{U-W}^2\le\fro{UU^T-WW^T}^2\le\tfrac{15}4\norm{q-p}_1 . \]
$W$ is obtained from $U$ by a row scaling with ratio of scales at most $2$,
whitening, and an orthogonal right factor."

Encoding: `β` is any number `≥ ‖q-p‖_∞` (equivalent, the hypothesis is antitone in `β`). -/
theorem thm_balancing {n d : ℕ} (U : Frame n d) (hU : IsParseval U) {H : ℝ}
    (hH : Linear.FrameBarrierBound U H) (q : Fin n → ℝ) (hq : ∑ i, q i = (d : ℝ))
    {β : ℝ} (hβ0 : 0 ≤ β) (hβ : ∀ i, |q i - rowNormSq U i| ≤ β) (hβH : β * H ≤ 1 / 2) :
    ∃ W : Frame n d, IsParseval W ∧ (∀ i, frameProjection W i i = q i) ∧
      sqDistance U W ≤ sqDistance (frameProjection U) (frameProjection W) ∧
      sqDistance (frameProjection U) (frameProjection W) ≤
        15 / 4 * ∑ i, |q i - rowNormSq U i| ∧
      ∃ w : Fin n → ℝ, (∀ i, 0 < w i) ∧ (∀ i j, w i ≤ 2 * w j) ∧
        ∃ R ∈ Matrix.orthogonalGroup (Fin d) ℝ,
          W = Matrix.diagonal w * U *
            invSqrt ((Matrix.diagonal w * U).transpose * (Matrix.diagonal w * U)) * R := by
  sorry

/-- `osc(x) = max_i x_i - min_i x_i`. -/
def osc {n : ℕ} (x : Fin n → ℝ) : ℝ := (⨆ i, x i) - ⨅ i, x i

/-- `Φ(s) = F(s) - ⟨q, s⟩`, the potential minimised over the cube in `thm:balancing`. -/
def balancingPotential {n d : ℕ} (U : Frame n d) (q s : Fin n → ℝ) : ℝ :=
  scalingPotential U s - ∑ i, q i * s i

/-- `eq:kkt` (in the proof of `thm:balancing`).

TeX: "Let $s$ minimise $\Phi(s)=F(s)-\ip qs$ over the cube $[0,1]^n$ (compactness),
and write $r=r(s)$. Since $\partial_i\Phi=r_i-q_i$ (\cref{lem:potential}),
coordinatewise optimality gives
\begin{equation} r_i\le q_i\ \text{ if }s_i>0,\qquad r_i\ge q_i\ \text{ if }s_i<1 .
\end{equation}" -/
theorem eq_kkt {n d : ℕ} (U : Frame n d) (hU : IsParseval U) (q s : Fin n → ℝ)
    (hs : s ∈ Set.Icc (0 : Fin n → ℝ) 1)
    (hmin : IsMinOn (balancingPotential U q) (Set.Icc (0 : Fin n → ℝ) 1) s) :
    (∃ s' ∈ Set.Icc (0 : Fin n → ℝ) 1, IsMinOn (balancingPotential U q)
      (Set.Icc (0 : Fin n → ℝ) 1) s') ∧
    (∀ i, 0 < s i → scaledDiagonal U s i ≤ q i) ∧
    (∀ i, s i < 1 → q i ≤ scaledDiagonal U s i) := by
  sorry

/-- Proof of `thm:balancing`, with its explicit constants (the origin of `15/4`).

TeX: "Let $z=e^{2s}$ with median $m$, so $1\le\min z\le m\le\max z\le e^{2}$. [...] By
\cref{lem:median}, $\max z/\min z\le(1-\beta H)^{-2}\le4$, i.e.\ $\osc(s)\le\log2<1$.
[...] in both cases $r=q$. For the distance let $w=e^{s}$, $f=q-p$, and let $c$ be the
midpoint of the range of $z^2$. [...]
\[ z^TLz\le\sum_iz_i^2f_i=\sum_i(z_i^2-c)f_i\le\tfrac12\osc(z^2)\norm f_1 . \]
As $(z_i-z_j)^2\ge4\min w^2\,(w_i-w_j)^2$, \cref{lem:energy,lem:scaled} give
\[ \fro{P(s)-P}^2\le\frac{2\,w^TLw}{\min w^2}\le\frac{z^TLz}{2\min z^2}
 \le\frac{\osc(z^2)}{4\min z^2}\norm f_1\le\frac{4^2-1}4\norm f_1 . \]" -/
theorem thm_balancing_steps {n d : ℕ} (hn : 0 < n) (U : Frame n d) (hU : IsParseval U) {H : ℝ}
    (hH : Linear.FrameBarrierBound U H) (q : Fin n → ℝ) (hq : ∑ i, q i = (d : ℝ))
    {β : ℝ} (hβ0 : 0 ≤ β) (hβ : ∀ i, |q i - rowNormSq U i| ≤ β) (hβH : β * H ≤ 1 / 2)
    (s : Fin n → ℝ) (hs : s ∈ Set.Icc (0 : Fin n → ℝ) 1)
    (hmin : IsMinOn (balancingPotential U q) (Set.Icc (0 : Fin n → ℝ) 1) s) :
    let z : Fin n → ℝ := fun i => Real.exp (2 * s i)
    let w : Fin n → ℝ := fun i => Real.exp (s i)
    let f : Fin n → ℝ := fun i => q i - rowNormSq U i
    let c : ℝ := ((⨆ i, z i ^ 2) + ⨅ i, z i ^ 2) / 2
    let L := projectionLaplacian (frameProjection U)
    (∀ i, 1 ≤ z i ∧ z i ≤ Real.exp 2) ∧
    (⨆ i, z i) ≤ ((1 - β * H) ^ 2)⁻¹ * (⨅ i, z i) ∧ ((1 - β * H) ^ 2)⁻¹ ≤ 4 ∧
    osc s ≤ Real.log 2 ∧ Real.log 2 < 1 ∧
    (∀ i, scaledDiagonal U s i = q i) ∧
    matrixQuadratic L z ≤ ∑ i, z i ^ 2 * f i ∧
    ∑ i, z i ^ 2 * f i = ∑ i, (z i ^ 2 - c) * f i ∧
    ∑ i, (z i ^ 2 - c) * f i ≤ 1 / 2 * osc (fun i => z i ^ 2) * ∑ i, |f i| ∧
    (∀ i j, 4 * (⨅ k, w k) ^ 2 * (w i - w j) ^ 2 ≤ (z i - z j) ^ 2) ∧
    sqDistance (scaledProjection U s) (frameProjection U) ≤
      2 * matrixQuadratic L w / (⨅ k, w k) ^ 2 ∧
    2 * matrixQuadratic L w / (⨅ k, w k) ^ 2 ≤ matrixQuadratic L z / (2 * (⨅ k, z k) ^ 2) ∧
    matrixQuadratic L z / (2 * (⨅ k, z k) ^ 2) ≤
      osc (fun i => z i ^ 2) / (4 * (⨅ k, z k) ^ 2) * ∑ i, |f i| ∧
    osc (fun i => z i ^ 2) / (4 * (⨅ k, z k) ^ 2) * ∑ i, |f i| ≤
      (4 ^ 2 - 1) / 4 * ∑ i, |f i| := by
  sorry

/-- Remark after `thm:balancing` (first claim).

TeX: "The hypothesis forces $q_i\ge p_i/2>0$: for $n\ge2$, the barrier for
$S=[n]\setminus\{i\}$ gives $1\le(L\psi)_i\le p_i(1-p_i)H$, so
$\beta\le1/(2H)\le p_i/2$." -/
theorem rem_balancing_forces_positive {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hn : 2 ≤ n) {H : ℝ} (hH : Linear.FrameBarrierBound U H) (q : Fin n → ℝ) {β : ℝ}
    (hβ0 : 0 ≤ β) (hβ : ∀ i, |q i - rowNormSq U i| ≤ β) (hβH : β * H ≤ 1 / 2) (i : Fin n) :
    1 ≤ rowNormSq U i * (1 - rowNormSq U i) * H ∧
    β ≤ 1 / (2 * H) ∧ 1 / (2 * H) ≤ rowNormSq U i / 2 ∧
    rowNormSq U i / 2 ≤ q i ∧ 0 < rowNormSq U i := by
  sorry

/-- Remark after `thm:balancing` (second claim).

TeX: "With $\beta H<1$ and a box of side $T>-\log(1-\beta H)$ the same proof gives scale
ratio $(1-\beta H)^{-1}$ and cost $\frac14((1-\beta H)^{-4}-1)\norm{q-p}_1$." -/
theorem rem_balancing_general {n d : ℕ} (U : Frame n d) (hU : IsParseval U) {H : ℝ}
    (hH : Linear.FrameBarrierBound U H) (q : Fin n → ℝ) (hq : ∑ i, q i = (d : ℝ))
    {β : ℝ} (hβ0 : 0 ≤ β) (hβ : ∀ i, |q i - rowNormSq U i| ≤ β) (hβH : β * H < 1) :
    ∃ W : Frame n d, IsParseval W ∧ (∀ i, frameProjection W i i = q i) ∧
      sqDistance U W ≤ sqDistance (frameProjection U) (frameProjection W) ∧
      sqDistance (frameProjection U) (frameProjection W) ≤
        1 / 4 * (((1 - β * H) ^ 4)⁻¹ - 1) * ∑ i, |q i - rowNormSq U i| ∧
      ∃ w : Fin n → ℝ, (∀ i, 0 < w i) ∧ (∀ i j, w i ≤ (1 - β * H)⁻¹ * w j) ∧
        ∃ R ∈ Matrix.orthogonalGroup (Fin d) ℝ,
          W = Matrix.diagonal w * U *
            invSqrt ((Matrix.diagonal w * U).transpose * (Matrix.diagonal w * U)) * R := by
  sorry

/-! ## 2.4 Barriers from a dense core -/

/-- Hypothesis (a) of `lem:core`: every good vertex sends weight `≥ κ` into every half-set
avoiding it. -/
def CoreDense {ι : Type*} [Fintype ι] (w : ι → ι → ℝ) (B : Finset ι) (κ : ℝ) : Prop :=
  ∀ i, i ∉ B → ∀ S : Finset ι, i ∉ S → Fintype.card ι ≤ 2 * S.card → κ ≤ ∑ j ∈ S, w i j

/-- Hypothesis (b) of `lem:core`, with `y ∈ ℝ^𝔅` extended by zero off `𝔅` (then
`(L_{𝔅𝔅} y)_i = (L y)_i` for `i ∈ 𝔅`). -/
def CoreExceptional {ι : Type*} [Fintype ι] (w : ι → ι → ℝ) (B : Finset ι) (R F : ℝ) :
    Prop :=
  ∃ y : ι → ℝ, (∀ j, 0 ≤ y j) ∧ (∀ j, j ∉ B → y j = 0) ∧ (∀ j, y j ≤ R) ∧
    (∀ i, i ∈ B → 1 ≤ weightedLaplacian w y i) ∧
    (∀ i, i ∉ B → ∑ j ∈ B, w i j * y j ≤ F)

/-- `lem:core` (Dense core with exceptional vertices), main statement.

TeX: "Let $L$ be the Laplacian of nonnegative symmetric weights $w_{ij}$ on $[n]$,
and let $[n]=\mathcal G\sqcup\mathcal B$. Suppose:
(a) there is $\kappa>0$ with $\sum_{j\in S}w_{ij}\ge\kappa$ for every
$i\in\mathcal G$ and every $S\subseteq[n]\setminus\{i\}$ with $|S|\ge n/2$;
(b) there are $y\in\R^{\mathcal B}$, $y\ge0$, and $R,F_{\mathcal B}\ge0$ with
$\norm y_\infty\le R$, $(L_{\mathcal B\mathcal B}y)_i\ge1$ for $i\in\mathcal B$,
and $\sum_{j\in\mathcal B}w_{ij}y_j\le F_{\mathcal B}$ for $i\in\mathcal G$.
(If $\mathcal B=\varnothing$ take $R=F_{\mathcal B}=0$.)
Then $H(L)\le(1+F_{\mathcal B})/\kappa+R$." -/
theorem lem_core {ι : Type*} [Fintype ι] [DecidableEq ι] (w : ι → ι → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i) (B : Finset ι)
    {κ R F : ℝ} (hκ : 0 < κ) (hR : 0 ≤ R) (hF : 0 ≤ F)
    (ha : CoreDense w B κ) (hb : CoreExceptional w B R F) :
    Linear.HasBarrierBound w ((1 + F) / κ + R) := by
  sorry

/-- `lem:core` (i).

TeX: "(a) holds with $\kappa=\vartheta\gamma$ if $\vartheta\in(0,\frac12]$,
$\gamma>0$, and every $i\in\mathcal G$ has at least $(\frac12+\vartheta)n$ indices
$j\ne i$ with $w_{ij}\ge\gamma/n$." -/
theorem lem_core_i {ι : Type*} [Fintype ι] [DecidableEq ι] (w : ι → ι → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i) (B : Finset ι)
    {ϑ γ : ℝ} (hϑ0 : 0 < ϑ) (hϑ : ϑ ≤ 1 / 2) (hγ : 0 < γ)
    (hcount : ∀ i, i ∉ B → (1 / 2 + ϑ) * (Fintype.card ι : ℝ) ≤
      ((Finset.univ.filter (fun j => j ≠ i ∧ γ / (Fintype.card ι : ℝ) ≤ w i j)).card : ℝ)) :
    CoreDense w B (ϑ * γ) := by
  sorry

/-- `lem:core` (ii).

TeX: "(b) holds with $R=\sqrt b/\lambda$, $F_{\mathcal B}=b$, if
$x^TLx\ge\lambda\norm x^2$ for every $x$ supported on $\mathcal B$ ($\lambda>0$)."
(Here `b = |𝔅|`; `λ` is renamed `lam`.) -/
theorem lem_core_ii {ι : Type*} [Fintype ι] [DecidableEq ι] (w : ι → ι → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i) (B : Finset ι)
    {lam : ℝ} (hlam : 0 < lam)
    (hgap : ∀ x : ι → ℝ, (∀ j, j ∉ B → x j = 0) →
      lam * ∑ i, x i ^ 2 ≤ ∑ i, x i * weightedLaplacian w x i) :
    CoreExceptional w B (Real.sqrt (B.card : ℝ) / lam) (B.card : ℝ) := by
  sorry

/-- `lem:core` (iii).

TeX: "for $w_{ij}=P_{ij}^2$, (b) holds with $R=\frac8{3\alpha}$,
$F_{\mathcal B}=\frac2{3\alpha}\max_ip_i$ if $\alpha>0$, $p_i\ge\alpha/2$ on
$\mathcal B$ and $\sum_{i\in\mathcal B}p_i\le\frac14$."

Encoding: `max_i p_i` is replaced by any upper bound `M` of all `p_i`. -/
theorem lem_core_iii {n d : ℕ} (U : Frame n d) (hU : IsParseval U) (B : Finset (Fin n))
    {α M : ℝ} (hα : 0 < α) (hp : ∀ i ∈ B, α / 2 ≤ rowNormSq U i)
    (htrace : ∑ i ∈ B, rowNormSq U i ≤ 1 / 4) (hM : ∀ i, rowNormSq U i ≤ M) :
    CoreExceptional (fun i j => frameProjection U i j ^ 2) B (8 / (3 * α))
      (2 / (3 * α) * M) := by
  sorry

/-- `rem:poisson` (Poisson constants), first inequality `H ≤ 2K`.

TeX: "The $\ell_\infty$ Poisson constant $K$ of $L$ is the least $K$ such that every
$f\perp\one$ has a solution of $Lg=f$ with $\norm g_\infty\le K\norm f_\infty$. Then
$K\le H\le2K$. Indeed, for $|S|\ge n/2$ the forcing $f=\one-\frac n{|S|}\one_S$ has
$\norm f_\infty\le1$, and $g+K\one$ is an $S$-barrier"

`BoundedPoissonSolvability w K` (library) is "Poisson constant `≤ K`". -/
theorem rem_poisson_barrier_le_twice {ι : Type*} [Fintype ι] [DecidableEq ι]
    (w : ι → ι → ℝ) (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i) {K : ℝ}
    (hK : BoundedPoissonSolvability w K) :
    Linear.HasBarrierBound w (2 * K) := by
  sorry

/-- `rem:poisson`, second inequality `K ≤ H`.

TeX: "conversely, if $H<\infty$ the graph is connected,
so $Lg=f$ is solvable for every $f\perp\one$, and if $\norm f_\infty\le1$ and $m$ is
a median of $g$, the argument of \cref{lem:median}
applied to $g-m\one-\beta'\psi$ ($\beta'>1$) gives $g\le m+H$, and symmetrically
$g\ge m-H$." -/
theorem rem_poisson_le_barrier {ι : Type*} [Fintype ι] [DecidableEq ι]
    (w : ι → ι → ℝ) (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i) {H : ℝ}
    (hH : Linear.HasBarrierBound w H) :
    BoundedPoissonSolvability w H := by
  sorry

/-! ## 2.5 From a seed to an exact frame -/

/-- `def:seed` (Seed).

TeX: "Let $\Theta\ge2$ and $t>0$. A \emph{$(\Theta,t)$-seed} for $X\in\R^{n\times d}$
is a Parseval $V\in\R^{n\times d}$ with
\[ \fro{V-X}^2\le\Theta t^2d,\qquad
 H(L_{VV^T})\le\frac{\Theta}{at^2},\qquad
 \max_i\bigl|(VV^T)_{ii}-a\bigr|\le\frac{at^2}{2\Theta}. \]"

This is the library predicate `Paulsen.Linear.IsSeed` (fields `parseval`, `dist`,
`barrier`, `diag`), which matches exactly; the side conditions `Θ ≥ 2`, `t > 0` are carried as
hypotheses where the seed is used. -/
abbrev IsSeed {n d : ℕ} (X V : Frame n d) (Θ t : ℝ) : Prop := Linear.IsSeed X V Θ t

/-- `cor:seed`.

TeX: "If $X$ has a $(\Theta,t)$-seed, there is an ENP frame $W$ with
$\fro{X-W}^2\le3\Theta t^2d$." -/
theorem cor_seed {n d : ℕ} (hd : 0 < d) (hdn : d ≤ n) {X V : Frame n d} {Θ t : ℝ}
    (hΘ : 2 ≤ Θ) (ht : 0 < t) (hs : IsSeed X V Θ t) :
    HasCorrection X (3 * Θ * t ^ 2 * (d : ℝ)) := by
  sorry

/-- Proof of `cor:seed`, with its explicit constants.

TeX: "Apply \cref{thm:balancing} to $V$ with $q=a\one$: $\beta H\le\frac12$, and
$\fro{V-W}^2\le\frac{15}4n\cdot\frac{at^2}{2\Theta}\le t^2d$. Then
$\fro{X-W}^2\le2\fro{X-V}^2+2\fro{V-W}^2\le(2\Theta+2)t^2d\le3\Theta t^2d$." -/
theorem cor_seed_proof {n d : ℕ} (hd : 0 < d) (hdn : d ≤ n) {X V : Frame n d} {Θ t : ℝ}
    (hΘ : 2 ≤ Θ) (ht : 0 < t) (hs : IsSeed X V Θ t) :
    ((d : ℝ) / n * t ^ 2 / (2 * Θ)) * (Θ / ((d : ℝ) / n * t ^ 2)) ≤ 1 / 2 ∧
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance V W ≤ 15 / 4 * (n : ℝ) * ((d : ℝ) / n * t ^ 2 / (2 * Θ)) ∧
      15 / 4 * (n : ℝ) * ((d : ℝ) / n * t ^ 2 / (2 * Θ)) ≤ t ^ 2 * (d : ℝ) ∧
      sqDistance X W ≤ (2 * Θ + 2) * t ^ 2 * (d : ℝ) ∧
      (2 * Θ + 2) * t ^ 2 * (d : ℝ) ≤ 3 * Θ * t ^ 2 * (d : ℝ) := by
  sorry

end

end Paulsen.Paper
