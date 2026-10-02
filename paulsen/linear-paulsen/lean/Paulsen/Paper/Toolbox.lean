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
import Paulsen.Paper.ToolboxAuxAlign
import Paulsen.Paper.ToolboxAuxBalancing
import Paulsen.Paper.ToolboxAuxCore
import Paulsen.Paper.ToolboxAuxBarrier
import Paulsen.Paper.ToolboxAuxConvex
import Paulsen.LeverageCore

/-!
# Paper blueprint, Section 2: the scaling toolbox (`sections/toolbox.tex`)

Every numbered item of `toolbox.tex` is stated and proved (technical parts are in the
helper files `Paulsen.Paper.ToolboxAux*`), with exactly the constants of the paper.

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
  exact ToolboxAux.isNearlyParseval_iff_opNorm' X hδ

/-- Encoding check (not in the paper): `invSqrt G` is the positive definite inverse square
root of a positive definite `G`. -/
theorem invSqrt_spec {k : Type*} [Fintype k] [DecidableEq k] (G : Matrix k k ℝ)
    (hG : G.PosDef) :
    (invSqrt G).PosDef ∧ invSqrt G * invSqrt G = G⁻¹ ∧ invSqrt G * G * invSqrt G = 1 := by
  exact ToolboxAux.invSqrt_spec' G hG

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
  exact ToolboxAux.lem_align_display U W hU hW

/-- `lem:align` (second sentence).

TeX: "Right multiplication by $R\in O(d)$ preserves Parsevalness and every row norm." -/
theorem lem_align_orthogonal {n d : ℕ} (U : Frame n d) (R : Matrix (Fin d) (Fin d) ℝ)
    (hR : R ∈ Matrix.orthogonalGroup (Fin d) ℝ) :
    (IsParseval U → IsParseval (U * R)) ∧ ∀ i, rowNormSq (U * R) i = rowNormSq U i := by
  have hR1 : R * R.transpose = 1 := (Matrix.mem_orthogonalGroup_iff (Fin d) ℝ).mp hR
  have hR2 : R.transpose * R = 1 := (Matrix.mem_orthogonalGroup_iff' (Fin d) ℝ).mp hR
  exact ⟨fun h => h.mul_orthogonal R hR2, fun i => rowNormSq_mul_orthogonal U R hR1 i⟩

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
  obtain ⟨h1, h2, h3, -⟩ := ToolboxAux.polar_facts X hδ0 hδ1 hX
  exact ⟨h1, h2, h3⟩

/-- `lem:align` (polar factor, `δ ≤ 1/2`).

TeX: "If moreover $\delta\le\frac12$, then
$|\norm{\tilde x_i}^2-\norm{x_i}^2|\le2\delta\norm{x_i}^2$ and row $i$ of
$\tilde X\tilde X^T-XX^T$ has squared norm at most $6\delta^2\norm{x_i}^2$." -/
theorem lem_align_polar_half {n d : ℕ} (X : Frame n d) {δ : ℝ} (hδ0 : 0 ≤ δ)
    (hδ : δ ≤ 1 / 2) (hX : IsNearlyParseval δ X) (i : Fin n) :
    |rowNormSq (polarFactor X) i - rowNormSq X i| ≤ 2 * δ * rowNormSq X i ∧
    rowNormSq (frameProjection (polarFactor X) - frameProjection X) i ≤
      6 * δ ^ 2 * rowNormSq X i := by
  obtain ⟨-, -, -, h4⟩ := ToolboxAux.polar_facts X hδ0 (by linarith) hX
  exact h4 hδ i

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
  exact ToolboxAux.lem_energy' U hU

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
  exact ToolboxAux.lem_scaled' U hU w hw hm hmw

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
  obtain ⟨hC, hD, hS, hT⟩ := ToolboxAux.lem_potential_basic U hU
  exact ⟨hC ∞, ToolboxAux.potential_convex U hU, hD, hS, hT⟩

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
  exact ToolboxAux.lem_scaling_ineq' U hU z hz i

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
  constructor
  · intro h
    apply ToolboxAux.hasBarrierBound_of_forall_gt
    intro ε hε
    have hlt : barrierConstant w < ENNReal.ofReal (H + ε) :=
      lt_of_le_of_lt h ((ENNReal.ofReal_lt_ofReal_iff (by linarith)).mpr (by linarith))
    unfold barrierConstant at hlt
    obtain ⟨H', hlt'⟩ := iInf_lt_iff.mp hlt
    obtain ⟨hH', hlt''⟩ := iInf_lt_iff.mp hlt'
    have hH'lt : (H' : ℝ) < H + ε := by
      rw [← ENNReal.ofReal_coe_nnreal] at hlt''
      exact (ENNReal.ofReal_lt_ofReal_iff (by linarith)).mp hlt''
    exact hH'.mono hH'lt.le
  · intro h
    unfold barrierConstant
    have : ENNReal.ofReal H = ((H.toNNReal : NNReal) : ENNReal) := rfl
    rw [this]
    exact iInf₂_le H.toNNReal (by rw [Real.coe_toNNReal _ hH]; exact h)

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
  exact ToolboxAux.barrier_connected' hw hsymm hH J hJ hJn

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
  rcases isEmpty_or_nonempty ι with hι | hι
  · exact ⟨fun i => isEmptyElim i, fun i => isEmptyElim i⟩
  · have k : ι := Classical.choice hι
    have hm : 0 < m := by
      have hcard : 0 < Fintype.card ι := Fintype.card_pos_iff.mpr ⟨k⟩
      have : (Finset.univ.filter (fun i => z i ≤ m)).Nonempty := by
        rw [← Finset.card_pos]; omega
      obtain ⟨j, hj⟩ := this
      exact lt_of_lt_of_le (hz j) (Finset.mem_filter.mp hj).2
    obtain ⟨h1, h2⟩ := Linear.barrier_median_sandwich hw hH hβ hβH hz hm hsub hsup hlow hhigh
    refine ⟨h1, fun i => ?_⟩
    have hpos : 0 < 1 - β * H := by linarith
    rw [inv_mul_eq_div, le_div_iff₀ hpos]
    linarith [h2 i]


/-- `osc(x) = max_i x_i - min_i x_i`. -/
def osc {n : ℕ} (x : Fin n → ℝ) : ℝ := (⨆ i, x i) - ⨅ i, x i

/-- `Φ(s) = F(s) - ⟨q, s⟩`, the potential minimised over the cube in `thm:balancing`. -/
def balancingPotential {n d : ℕ} (U : Frame n d) (q s : Fin n → ℝ) : ℝ :=
  scalingPotential U s - ∑ i, q i * s i

/-- Proof-internal (for `eq:kkt`): `∂ᵢΦ = rᵢ - qᵢ`, from `lem:potential`. -/
theorem balancingPotential_hasFDerivAt {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (q s : Fin n → ℝ) :
    HasFDerivAt (balancingPotential U q)
      (∑ i, (scaledDiagonal U s i - q i) •
        (ContinuousLinearMap.proj i : (Fin n → ℝ) →L[ℝ] ℝ)) s := by
  obtain ⟨-, -, hD, -, -⟩ := lem_potential U hU
  have h2 : HasFDerivAt (fun t : Fin n → ℝ => ∑ i, q i * t i)
      (∑ i, q i • (ContinuousLinearMap.proj i : (Fin n → ℝ) →L[ℝ] ℝ)) s := by
    have := (∑ i, q i • (ContinuousLinearMap.proj i : (Fin n → ℝ) →L[ℝ] ℝ)).hasFDerivAt (x := s)
    convert this using 1
    funext t; simp
  have := (hD s).sub h2
  have heq : (∑ i, (scaledDiagonal U s i - q i) •
      (ContinuousLinearMap.proj i : (Fin n → ℝ) →L[ℝ] ℝ)) =
      (∑ i, scaledDiagonal U s i • (ContinuousLinearMap.proj i : (Fin n → ℝ) →L[ℝ] ℝ)) -
        ∑ i, q i • (ContinuousLinearMap.proj i : (Fin n → ℝ) →L[ℝ] ℝ) := by
    ext x
    simp [sub_mul, Finset.sum_sub_distrib]
  rw [heq]
  exact this

/-- Proof-internal (for `eq:kkt`): a minimiser of `Φ` over a box exists (compactness). -/
theorem exists_balancing_minimizer {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (q : Fin n → ℝ) {T : ℝ} (hT : 0 ≤ T) :
    ∃ s ∈ Set.Icc (0 : Fin n → ℝ) (fun _ => T),
      IsMinOn (balancingPotential U q) (Set.Icc (0 : Fin n → ℝ) (fun _ => T)) s := by
  have hne : (Set.Icc (0 : Fin n → ℝ) (fun _ => T)).Nonempty := ⟨0, le_rfl, fun _ => hT⟩
  have hcont : Continuous (balancingPotential U q) :=
    continuous_iff_continuousAt.mpr fun s =>
      (balancingPotential_hasFDerivAt U hU q s).continuousAt
  exact isCompact_Icc.exists_isMinOn hne hcont.continuousOn

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
  refine ⟨exists_balancing_minimizer U hU q zero_le_one, ?_⟩
  have h := ToolboxAux.box_kkt (T := 1) (balancingPotential U q)
    (fun i => scaledDiagonal U s i - q i) s (balancingPotential_hasFDerivAt U hU q s) hs hmin
  exact ⟨fun i hi => sub_nonpos.mp (h.1 i hi), fun i hi => sub_nonneg.mp (h.2 i hi)⟩

/-- Proof-internal: the argument of `thm:balancing` on a box `[0,T]^n`, for any `β H < 1`
and `T > -log(1-βH)`, given the first-order conditions `eq:kkt` at `s`.  With `T = 1` this
is the proof of `thm:balancing`; general `T` is the remark after `thm:balancing`. -/
theorem balancing_core {n d : ℕ} (hn : 0 < n) (U : Frame n d) (hU : IsParseval U) {H : ℝ}
    (hH : Linear.FrameBarrierBound U H) (q : Fin n → ℝ) (hq : ∑ i, q i = (d : ℝ))
    {β : ℝ} (hβ0 : 0 ≤ β) (hβ : ∀ i, |q i - rowNormSq U i| ≤ β) (hβH : β * H < 1)
    {T : ℝ} (hT : -Real.log (1 - β * H) < T)
    (s : Fin n → ℝ) (hs0 : ∀ i, 0 ≤ s i) (hsT : ∀ i, s i ≤ T)
    (hkkt1 : ∀ i, 0 < s i → scaledDiagonal U s i ≤ q i)
    (hkkt2 : ∀ i, s i < T → q i ≤ scaledDiagonal U s i) :
    let z : Fin n → ℝ := fun i => Real.exp (2 * s i)
    let w : Fin n → ℝ := fun i => Real.exp (s i)
    let f : Fin n → ℝ := fun i => q i - rowNormSq U i
    let c : ℝ := ((⨆ i, z i ^ 2) + ⨅ i, z i ^ 2) / 2
    let L := projectionLaplacian (frameProjection U)
    (∀ i j, s i - s j ≤ -Real.log (1 - β * H)) ∧
    (⨆ i, z i) ≤ ((1 - β * H) ^ 2)⁻¹ * (⨅ i, z i) ∧
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
      ((((1 - β * H) ^ 2)⁻¹) ^ 2 - 1) / 4 * ∑ i, |f i| := by
  intro z w f c L
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  have hH0 : 0 ≤ H := by
    obtain ⟨ψ, ⟨hψ0, -⟩, hψH⟩ := hH Finset.univ (by simp; omega)
    exact (hψ0 ⟨0, hn⟩).trans (hψH ⟨0, hn⟩)
  have hδ : 0 < 1 - β * H := by linarith
  have hz : ∀ i, 0 < z i := fun i => Real.exp_pos _
  have hw : ∀ i, 0 < w i := fun i => Real.exp_pos _
  have hzw : ∀ i, z i = w i ^ 2 := fun i => by
    show Real.exp (2 * s i) = Real.exp (s i) ^ 2
    rw [pow_two, ← Real.exp_add]; congr 1; ring
  have hsqrt : ∀ i, sqrtScaledDiagonal U z i = scaledDiagonal U s i := by
    intro i
    have : (fun j => Real.sqrt (z j)) = (fun j => Real.exp (s j)) := by
      funext j; rw [hzw j, Real.sqrt_sq (hw j).le]
    show columnSpaceProjection (Matrix.diagonal (fun j => Real.sqrt (z j)) * U) i i =
      columnSpaceProjection (Matrix.diagonal (fun j => Real.exp (s j)) * U) i i
    rw [this]
  have hfsum : ∑ i, f i = 0 := by
    show ∑ i, (q i - rowNormSq U i) = 0
    rw [Finset.sum_sub_distrib, hq, hU.total_rowNormSq, sub_self]
  have hineq := fun i => lem_scaling_ineq U hU z hz i
  -- the median barrier
  obtain ⟨k, hlow, hhigh⟩ := finite_median_index z
  obtain ⟨hmu, hml⟩ := lem_median (fun i j => frameProjection U i j ^ 2)
    (fun i j => sq_nonneg _) (fun i j => by rw [frameProjection_symm]) hH hβ0 hβH z hz (z k)
    hlow hhigh
    (by
      intro i hi
      have hi' : Real.exp (2 * s k) < Real.exp (2 * s i) := hi
      have hsi : 0 < s i := by
        have := Real.exp_lt_exp.mp hi'
        linarith [hs0 k]
      have h1 := (hineq i).1
      rw [hsqrt] at h1
      have h2 := hkkt1 i hsi
      have h3 := (abs_le.mp (hβ i)).2
      calc _ ≤ z i * (scaledDiagonal U s i - rowNormSq U i) := h1
        _ ≤ z i * β := mul_le_mul_of_nonneg_left (by linarith) (hz i).le
        _ = β * z i := mul_comm _ _)
    (by
      intro i hi
      have hi' : Real.exp (2 * s i) < Real.exp (2 * s k) := hi
      have hsi : s i < T := by
        have := Real.exp_lt_exp.mp hi'
        linarith [hsT k]
      have h1 := (hineq i).2
      rw [hsqrt] at h1
      have h2 := hkkt2 i hsi
      have h3 := (abs_le.mp (hβ i)).1
      have hzi := inv_pos.mpr (hz i)
      calc _ ≤ -(z i)⁻¹ * (scaledDiagonal U s i - rowNormSq U i) := h1
        _ ≤ β * (z i)⁻¹ := by nlinarith)
  have hml' : ∀ i, (1 - β * H) * z k ≤ z i := fun i => by
    have := hml i
    rw [inv_mul_eq_div, le_div_iff₀ hδ] at this
    linarith
  have hG1 : ∀ i j, s i - s j ≤ -Real.log (1 - β * H) :=
    pairwise_exp_median_barrier hβH hmu hml'
  have hpair : ∀ i j, z i ≤ ((1 - β * H) ^ 2)⁻¹ * z j := by
    intro i j
    have h1' : z i ≤ (1 - β * H)⁻¹ * z k := by
      rw [inv_mul_eq_div, le_div_iff₀ hδ]; linarith [hmu i]
    calc z i ≤ (1 - β * H)⁻¹ * z k := h1'
      _ ≤ (1 - β * H)⁻¹ * ((1 - β * H)⁻¹ * z j) :=
          mul_le_mul_of_nonneg_left (hml j) (inv_nonneg.mpr hδ.le)
      _ = _ := by rw [← mul_assoc, ← mul_inv, ← pow_two]
  obtain ⟨i₀, hi₀⟩ := ToolboxAux.sup_attained hn z
  obtain ⟨j₀, hj₀⟩ := ToolboxAux.inf_attained hn z
  have hG2 : (⨆ i, z i) ≤ ((1 - β * H) ^ 2)⁻¹ * (⨅ i, z i) := by
    rw [← hi₀, ← hj₀]; exact hpair i₀ j₀
  -- `r = q`
  have hrsum : ∑ i, scaledDiagonal U s i = (d : ℝ) := (lem_potential U hU).2.2.2.1 s
  have hG3 : ∀ i, scaledDiagonal U s i = q i := by
    by_cases hpos : ∀ i, 0 < s i
    · intro i
      exact (Finset.sum_eq_sum_iff_of_le (fun j _ => hkkt1 j (hpos j))).mp
        (hrsum.trans hq.symm) i (Finset.mem_univ i)
    · push Not at hpos
      obtain ⟨j, hj⟩ := hpos
      have hupper : ∀ i, s i < T := fun i => by linarith [hG1 i j, hs0 j]
      intro i
      exact ((Finset.sum_eq_sum_iff_of_le (fun j _ => hkkt2 j (hupper j))).mp
        (hq.trans hrsum.symm) i (Finset.mem_univ i)).symm
  -- the energy estimate
  have hLz : ∀ x : Fin n → ℝ, ∀ i, (L *ᵥ x) i =
      weightedLaplacian (fun i j => frameProjection U i j ^ 2) x i := by
    intro x i
    rw [(lem_energy U hU).1 x i, ToolboxAux.weightedLaplacian_offdiag]
  have hquad : ∀ x : Fin n → ℝ, matrixQuadratic L x = ∑ i, x i * (L *ᵥ x) i := by
    intro x
    unfold matrixQuadratic
    simp only [Matrix.mulVec, dotProduct, Finset.mul_sum, mul_assoc]
  have hG4 : matrixQuadratic L z ≤ ∑ i, z i ^ 2 * f i := by
    rw [hquad]
    apply Finset.sum_le_sum; intro i _
    rw [hLz]
    have h1 := (hineq i).1
    rw [hsqrt, hG3] at h1
    calc z i * weightedLaplacian (fun i j => frameProjection U i j ^ 2) z i
        ≤ z i * (z i * (q i - rowNormSq U i)) := mul_le_mul_of_nonneg_left h1 (hz i).le
      _ = z i ^ 2 * f i := by ring
  have hG5 : ∑ i, z i ^ 2 * f i = ∑ i, (z i ^ 2 - c) * f i :=
    ToolboxAux.sum_centre (fun i => z i ^ 2) f hfsum c
  have hG6 : ∑ i, (z i ^ 2 - c) * f i ≤ 1 / 2 * osc (fun i => z i ^ 2) * ∑ i, |f i| :=
    ToolboxAux.centred_sum_le (fun i => z i ^ 2) f
  have hmw : 0 < ⨅ k, w k := ToolboxAux.inf_pos_fin hn w hw
  have hG7 : ∀ i j, 4 * (⨅ k, w k) ^ 2 * (w i - w j) ^ 2 ≤ (z i - z j) ^ 2 := by
    intro i j
    rw [hzw i, hzw j]
    exact ToolboxAux.sq_diff_sq_ge (w i) (w j) _ hmw.le (ToolboxAux.inf_le_fin w i)
      (ToolboxAux.inf_le_fin w j)
  -- the distance
  obtain ⟨hWp, -, hWd, hWle⟩ := lem_scaled U hU w hw hmw (fun i => ToolboxAux.inf_le_fin w i)
  have hPs : scaledProjection U s = frameProjection (Matrix.diagonal w * U *
      invSqrt (U.transpose * Matrix.diagonal w ^ 2 * U)) :=
    columnSpaceProjection_eq_of_parseval_right_mul _ _ hWp
  have hG8 : sqDistance (scaledProjection U s) (frameProjection U) ≤
      2 * matrixQuadratic L w / (⨅ k, w k) ^ 2 := by
    rw [hPs, hWd]; exact hWle
  have hmz : (⨅ k, z k) = (⨅ k, w k) ^ 2 := by
    apply le_antisymm
    · obtain ⟨k₀, hk₀⟩ := ToolboxAux.inf_attained hn w
      rw [← hk₀, ← hzw k₀]; exact ToolboxAux.inf_le_fin z k₀
    · apply le_ciInf; intro i; rw [hzw i]
      exact pow_le_pow_left₀ hmw.le (ToolboxAux.inf_le_fin w i) 2
  have hen := (lem_energy U hU).2.2.2.2
  have hzL : 4 * (⨅ k, w k) ^ 2 * matrixQuadratic L w ≤ matrixQuadratic L z := by
    rw [(hen w).1, (hen z).1]
    have : 4 * (⨅ k, w k) ^ 2 *
        ((1 / 2) * ∑ i, ∑ j, frameProjection U i j ^ 2 * (w i - w j) ^ 2) =
        (1 / 2) * ∑ i, ∑ j, frameProjection U i j ^ 2 *
          (4 * (⨅ k, w k) ^ 2 * (w i - w j) ^ 2) := by
      simp only [Finset.mul_sum]
      apply Finset.sum_congr rfl; intro i _
      apply Finset.sum_congr rfl; intro j _
      ring
    rw [this]
    apply mul_le_mul_of_nonneg_left _ (by norm_num)
    apply Finset.sum_le_sum; intro i _; apply Finset.sum_le_sum; intro j _
    exact mul_le_mul_of_nonneg_left (hG7 i j) (sq_nonneg _)
  have hG9 : 2 * matrixQuadratic L w / (⨅ k, w k) ^ 2 ≤
      matrixQuadratic L z / (2 * (⨅ k, z k) ^ 2) := by
    have hm2 : 0 < (⨅ k, w k) ^ 2 := by positivity
    have : 2 * matrixQuadratic L w / (⨅ k, w k) ^ 2 =
        (4 * (⨅ k, w k) ^ 2 * matrixQuadratic L w) / (2 * (⨅ k, z k) ^ 2) := by
      rw [hmz]; field_simp; ring
    rw [this]
    exact div_le_div_of_nonneg_right hzL (by positivity)
  have hmz0 : 0 < ⨅ k, z k := ToolboxAux.inf_pos_fin hn z hz
  have hG10 : matrixQuadratic L z / (2 * (⨅ k, z k) ^ 2) ≤
      osc (fun i => z i ^ 2) / (4 * (⨅ k, z k) ^ 2) * ∑ i, |f i| := by
    have h := (hG4.trans_eq hG5).trans hG6
    have : osc (fun i => z i ^ 2) / (4 * (⨅ k, z k) ^ 2) * ∑ i, |f i| =
        (1 / 2 * osc (fun i => z i ^ 2) * ∑ i, |f i|) / (2 * (⨅ k, z k) ^ 2) := by
      field_simp; ring
    rw [this]
    exact div_le_div_of_nonneg_right h (by positivity)
  have hG11 : osc (fun i => z i ^ 2) / (4 * (⨅ k, z k) ^ 2) * ∑ i, |f i| ≤
      ((((1 - β * H) ^ 2)⁻¹) ^ 2 - 1) / 4 * ∑ i, |f i| := by
    apply mul_le_mul_of_nonneg_right _ (Finset.sum_nonneg fun i _ => abs_nonneg _)
    have hosc : osc (fun i => z i ^ 2) ≤
        ((((1 - β * H) ^ 2)⁻¹) ^ 2 - 1) * (⨅ k, z k) ^ 2 := by
      unfold osc
      have hsup : (⨆ i, z i ^ 2) ≤ (((1 - β * H) ^ 2)⁻¹) ^ 2 * (⨅ k, z k) ^ 2 := by
        apply ciSup_le; intro i
        have := hpair i j₀
        rw [hj₀] at this
        calc z i ^ 2 ≤ (((1 - β * H) ^ 2)⁻¹ * (⨅ k, z k)) ^ 2 :=
              pow_le_pow_left₀ (hz i).le this 2
          _ = _ := by ring
      have hinf : (⨅ k, z k) ^ 2 ≤ ⨅ i, z i ^ 2 := by
        apply le_ciInf; intro i
        exact pow_le_pow_left₀ hmz0.le (ToolboxAux.inf_le_fin z i) 2
      linarith
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith [hosc]
  exact ⟨hG1, hG2, hG3, hG4, hG5, hG6, hG7, hG8, hG9, hG10, hG11⟩

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
  intro z w f c L
  obtain ⟨-, hk1, hk2⟩ := eq_kkt U hU q s hs hmin
  have hs0 : ∀ i, 0 ≤ s i := fun i => hs.1 i
  have hs1 : ∀ i, s i ≤ 1 := fun i => hs.2 i
  have hH0 : 0 ≤ H := by
    obtain ⟨ψ, ⟨hψ0, -⟩, hψH⟩ := hH Finset.univ (by simp; omega)
    exact (hψ0 ⟨0, hn⟩).trans (hψH ⟨0, hn⟩)
  have hβH0 : 0 ≤ β * H := mul_nonneg hβ0 hH0
  have hhalf : 1 / 2 ≤ 1 - β * H := by linarith
  have hlog : -Real.log (1 - β * H) ≤ Real.log 2 := by
    rw [neg_le, ← Real.log_inv]
    exact Real.log_le_log (by norm_num) (by linarith)
  have hlog2 : Real.log 2 < 1 := by
    have := Real.log_lt_sub_one_of_pos (by norm_num : (0 : ℝ) < 2) (by norm_num : (2 : ℝ) ≠ 1)
    linarith
  have hT : -Real.log (1 - β * H) < 1 := lt_of_le_of_lt hlog hlog2
  obtain ⟨g1, g2, g3, g4, g5, g6, g7, g8, g9, g10, g11⟩ := balancing_core hn U hU hH q hq hβ0 hβ
    (by linarith) hT s hs0 hs1 hk1 hk2
  have hκ : ((1 - β * H) ^ 2)⁻¹ ≤ 4 := by
    rw [inv_le_comm₀ (by positivity) (by norm_num)]; nlinarith
  refine ⟨?_, g2, hκ, ?_, hlog2, g3, g4, g5, g6, g7, g8, g9, g10, ?_⟩
  · intro i
    constructor
    · show 1 ≤ Real.exp (2 * s i)
      exact Real.one_le_exp (by linarith [hs0 i])
    · show Real.exp (2 * s i) ≤ Real.exp 2
      exact Real.exp_le_exp.mpr (by linarith [hs1 i])
  · unfold osc
    obtain ⟨i₀, hi₀⟩ := ToolboxAux.sup_attained hn s
    obtain ⟨j₀, hj₀⟩ := ToolboxAux.inf_attained hn s
    rw [← hi₀, ← hj₀]; exact (g1 i₀ j₀).trans hlog
  · refine g11.trans (mul_le_mul_of_nonneg_right ?_ (Finset.sum_nonneg fun i _ => abs_nonneg _))
    have h0 : 0 ≤ ((1 - β * H) ^ 2)⁻¹ := by positivity
    have : (((1 - β * H) ^ 2)⁻¹) ^ 2 ≤ 4 ^ 2 := pow_le_pow_left₀ h0 hκ 2
    linarith

/-- The two Gram matrices of a row scaling agree: `(DU)ᵀ(DU) = Uᵀ D² U`. -/
theorem rowScale_gram_eq {n d : ℕ} (U : Frame n d) (w : Fin n → ℝ) :
    (Matrix.diagonal w * U).transpose * (Matrix.diagonal w * U) =
      U.transpose * Matrix.diagonal w ^ 2 * U := by
  rw [ToolboxAux.diagonal_sq, Matrix.transpose_mul, Matrix.diagonal_transpose]
  simp only [Matrix.mul_assoc]
  rw [← Matrix.mul_assoc (Matrix.diagonal w) (Matrix.diagonal w), Matrix.diagonal_mul_diagonal]
  simp only [pow_two]

/-- Proof-internal: assemble the frame of `thm:balancing` from a balanced scaling `s`:
whiten the row scaling `DU`, `D = Diag(e^s)` (`lem:scaled`), and align by an orthogonal
right factor (`lem:align`). -/
theorem balancing_assemble {n d : ℕ} (hn : 0 < n) (U : Frame n d) (hU : IsParseval U)
    (q s : Fin n → ℝ) {ρ K : ℝ}
    (hrq : ∀ i, scaledDiagonal U s i = q i) (hosc : ∀ i j, s i - s j ≤ ρ)
    (hcost : sqDistance (scaledProjection U s) (frameProjection U) ≤
      K * ∑ i, |q i - rowNormSq U i|) :
    ∃ W : Frame n d, IsParseval W ∧ (∀ i, frameProjection W i i = q i) ∧
      sqDistance U W ≤ sqDistance (frameProjection U) (frameProjection W) ∧
      sqDistance (frameProjection U) (frameProjection W) ≤ K * ∑ i, |q i - rowNormSq U i| ∧
      ∃ w : Fin n → ℝ, (∀ i, 0 < w i) ∧ (∀ i j, w i ≤ Real.exp ρ * w j) ∧
        ∃ R ∈ Matrix.orthogonalGroup (Fin d) ℝ,
          W = Matrix.diagonal w * U *
            invSqrt ((Matrix.diagonal w * U).transpose * (Matrix.diagonal w * U)) * R := by
  have hw : ∀ i, 0 < (fun i => Real.exp (s i)) i := fun i => Real.exp_pos _
  have hmw : 0 < ⨅ k, (fun i => Real.exp (s i)) k := ToolboxAux.inf_pos_fin hn _ hw
  obtain ⟨hWp, -, -, -⟩ := lem_scaled U hU (fun i => Real.exp (s i)) hw hmw
    (fun i => ToolboxAux.inf_le_fin _ i)
  have hPs : scaledProjection U s = frameProjection (Matrix.diagonal (fun i => Real.exp (s i)) *
      U * invSqrt (U.transpose * Matrix.diagonal (fun i => Real.exp (s i)) ^ 2 * U)) :=
    columnSpaceProjection_eq_of_parseval_right_mul _ _ hWp
  obtain ⟨-, ⟨⟨R, hR, hReq⟩, -⟩, hle, -⟩ := lem_align U _ hU hWp
  have hR1 : R * R.transpose = 1 := (Matrix.mem_orthogonalGroup_iff (Fin d) ℝ).mp hR
  have hPW := frameProjection_mul_orthogonal (Matrix.diagonal (fun i => Real.exp (s i)) *
      U * invSqrt (U.transpose * Matrix.diagonal (fun i => Real.exp (s i)) ^ 2 * U)) R hR1
  refine ⟨_, (lem_align_orthogonal _ R hR).1 hWp, ?_, ?_, ?_, fun i => Real.exp (s i), hw, ?_,
    R, hR, ?_⟩
  · intro i; rw [hPW, ← hPs]; exact hrq i
  · rw [hPW, ← hReq]; exact hle
  · rw [hPW, ← hPs, sqDistance_symm]; exact hcost
  · intro i j
    calc Real.exp (s i) = Real.exp (s i - s j) * Real.exp (s j) := by
          rw [← Real.exp_add]; congr 1; ring
      _ ≤ Real.exp ρ * Real.exp (s j) :=
          mul_le_mul_of_nonneg_right (Real.exp_le_exp.mpr (hosc i j)) (Real.exp_pos _).le
  · rw [rowScale_gram_eq]

/-- Proof-internal: the degenerate case `n = 0` (then `d = 0`) of the balancing statements. -/
theorem balancing_empty {d : ℕ} (U : Frame 0 d) (hU : IsParseval U) (q : Fin 0 → ℝ)
    (K κ : ℝ) :
    ∃ W : Frame 0 d, IsParseval W ∧ (∀ i, frameProjection W i i = q i) ∧
      sqDistance U W ≤ sqDistance (frameProjection U) (frameProjection W) ∧
      sqDistance (frameProjection U) (frameProjection W) ≤ K * ∑ i, |q i - rowNormSq U i| ∧
      ∃ w : Fin 0 → ℝ, (∀ i, 0 < w i) ∧ (∀ i j, w i ≤ κ * w j) ∧
        ∃ R ∈ Matrix.orthogonalGroup (Fin d) ℝ,
          W = Matrix.diagonal w * U *
            invSqrt ((Matrix.diagonal w * U).transpose * (Matrix.diagonal w * U)) * R := by
  have hd0 : d = 0 := by have := ToolboxAux.parseval_dim_le hU; omega
  subst hd0
  refine ⟨Matrix.diagonal (fun _ => 1) * U * invSqrt ((Matrix.diagonal (fun _ => (1 : ℝ)) *
    U).transpose * (Matrix.diagonal (fun _ => 1) * U)) * 1, ?_, fun i => i.elim0, ?_, ?_,
    fun _ => 1, fun i => i.elim0, fun i => i.elim0, 1, one_mem _, rfl⟩
  · unfold IsParseval; ext i j; exact i.elim0
  · simp [sqDistance]
  · simp [sqDistance]

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
  rcases Nat.eq_zero_or_pos n with hn0 | hn
  · subst hn0; exact balancing_empty U hU q _ _
  obtain ⟨s, hs, hmin⟩ := exists_balancing_minimizer U hU q (T := 1) zero_le_one
  obtain ⟨-, -, -, hosc, -, hrq, -, -, -, -, h8, h9, h10, h11⟩ :=
    thm_balancing_steps hn U hU hH q hq hβ0 hβ hβH s hs hmin
  have hcost : sqDistance (scaledProjection U s) (frameProjection U) ≤
      15 / 4 * ∑ i, |q i - rowNormSq U i| := by
    have h := ((h8.trans h9).trans h10).trans h11
    have h15 : ((4 : ℝ) ^ 2 - 1) / 4 = 15 / 4 := by norm_num
    rw [h15] at h
    exact h
  have hosc' : ∀ i j, s i - s j ≤ Real.log 2 := by
    intro i j
    have := ToolboxAux.le_sup_fin s i
    have := ToolboxAux.inf_le_fin s j
    unfold osc at hosc
    linarith
  obtain ⟨W, hW1, hW2, hW3, hW4, w, hw, hratio, R, hR, hWeq⟩ :=
    balancing_assemble hn U hU q s hrq hosc' hcost
  refine ⟨W, hW1, hW2, hW3, hW4, w, hw, fun i j => ?_, R, hR, hWeq⟩
  have := hratio i j
  rwa [Real.exp_log (by norm_num)] at this

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
  have hn0 : 0 < n := by omega
  obtain ⟨ψ, ⟨hψ0, hψ1⟩, hψH⟩ := hH (Finset.univ.erase i) (by
    rw [Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, Fintype.card_fin]
    omega)
  have h1 := hψ1 i (Finset.notMem_erase i _)
  have hrow := hU.projection_row_squares i
  have hPii : frameProjection U i i = rowNormSq U i := frameProjection_diagonal U i
  have hs : ∑ j, (if j = i then 0 else frameProjection U i j ^ 2) =
      rowNormSq U i - rowNormSq U i ^ 2 := by
    have : ∀ j, (if j = i then 0 else frameProjection U i j ^ 2) =
        frameProjection U i j ^ 2 - (if j = i then frameProjection U i j ^ 2 else 0) := by
      intro j; split_ifs <;> ring
    simp only [this, Finset.sum_sub_distrib, Finset.sum_ite_eq', Finset.mem_univ, if_true,
      hrow, hPii]
  have hLle : weightedLaplacian (fun i j => frameProjection U i j ^ 2) ψ i ≤
      H * (rowNormSq U i - rowNormSq U i ^ 2) := by
    unfold weightedLaplacian
    have hterm : ∀ j, frameProjection U i j ^ 2 * (ψ i - ψ j) ≤
        H * (if j = i then 0 else frameProjection U i j ^ 2) := by
      intro j
      by_cases hj : j = i
      · subst hj; simp
      · simp only [hj, if_false]
        nlinarith [hψ0 j, hψH i, sq_nonneg (frameProjection U i j)]
    calc ∑ j, frameProjection U i j ^ 2 * (ψ i - ψ j)
        ≤ ∑ j, H * (if j = i then 0 else frameProjection U i j ^ 2) :=
          Finset.sum_le_sum (fun j _ => hterm j)
      _ = H * (rowNormSq U i - rowNormSq U i ^ 2) := by rw [← Finset.mul_sum, hs]
  have hp0 := rowNormSq_nonneg U i
  have hp1 := hU.leverage_le_one i
  have hc1 : 1 ≤ rowNormSq U i * (1 - rowNormSq U i) * H := by nlinarith
  have hHpos : 0 < H := by
    by_contra hneg
    push Not at hneg
    have : rowNormSq U i * (1 - rowNormSq U i) * H ≤ 0 :=
      mul_nonpos_of_nonneg_of_nonpos (mul_nonneg hp0 (by linarith)) hneg
    linarith
  have hppos : 0 < rowNormSq U i := by
    by_contra hneg
    push Not at hneg
    have : rowNormSq U i = 0 := le_antisymm hneg hp0
    rw [this] at hc1; linarith
  have hc2 : β ≤ 1 / (2 * H) := by
    rw [le_div_iff₀ (by positivity)]; linarith
  have hc3 : 1 / (2 * H) ≤ rowNormSq U i / 2 := by
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith
  have hc4 : rowNormSq U i / 2 ≤ q i := by
    have := (abs_le.mp (hβ i)).1
    linarith
  exact ⟨hc1, hc2, hc3, hc4, hppos⟩

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
  rcases Nat.eq_zero_or_pos n with hn0 | hn
  · subst hn0; exact balancing_empty U hU q _ _
  have hH0 : 0 ≤ H := by
    obtain ⟨ψ, ⟨hψ0, -⟩, hψH⟩ := hH Finset.univ (by simp; omega)
    exact (hψ0 ⟨0, hn⟩).trans (hψH ⟨0, hn⟩)
  have hδ : 0 < 1 - β * H := by linarith
  have hlog0 : 0 ≤ -Real.log (1 - β * H) := by
    have : Real.log (1 - β * H) ≤ 0 :=
      Real.log_nonpos hδ.le (by nlinarith [mul_nonneg hβ0 hH0])
    linarith
  obtain ⟨s, hs, hmin⟩ := exists_balancing_minimizer U hU q
    (T := -Real.log (1 - β * H) + 1) (by linarith)
  have hk := ToolboxAux.box_kkt (balancingPotential U q) (fun i => scaledDiagonal U s i - q i) s
    (balancingPotential_hasFDerivAt U hU q s) hs hmin
  obtain ⟨g1, -, g3, -, -, -, -, g8, g9, g10, g11⟩ := balancing_core hn U hU hH q hq hβ0 hβ hβH
    (T := -Real.log (1 - β * H) + 1) (by linarith) s (fun i => hs.1 i) (fun i => hs.2 i)
    (fun i hi => sub_nonpos.mp (hk.1 i hi)) (fun i hi => sub_nonneg.mp (hk.2 i hi))
  have hcost : sqDistance (scaledProjection U s) (frameProjection U) ≤
      1 / 4 * (((1 - β * H) ^ 4)⁻¹ - 1) * ∑ i, |q i - rowNormSq U i| := by
    have h := ((g8.trans g9).trans g10).trans g11
    have hc : ((((1 - β * H) ^ 2)⁻¹) ^ 2 - 1) / 4 = 1 / 4 * (((1 - β * H) ^ 4)⁻¹ - 1) := by
      rw [inv_pow, ← pow_mul]; ring
    rw [hc] at h
    exact h
  obtain ⟨W, hW1, hW2, hW3, hW4, w, hw, hratio, R, hR, hWeq⟩ :=
    balancing_assemble hn U hU q s g3 g1 hcost
  refine ⟨W, hW1, hW2, hW3, hW4, w, hw, fun i j => ?_, R, hR, hWeq⟩
  have := hratio i j
  rwa [Real.exp_neg, Real.exp_log hδ] at this

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
  obtain ⟨y, hy0, hyB, hyR, hyLap, hyF⟩ := hb
  apply Linear.core_barrier hw B hκ hF ha y hy0 hyB hyR hyLap
  intro i hi
  have : ∑ j, w i j * y j = ∑ j ∈ B, w i j * y j :=
    (Finset.sum_subset (Finset.subset_univ B) (fun j _ hj => by rw [hyB j hj, mul_zero])).symm
  rw [this]; exact hyF i hi

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
  exact fun i hi => Linear.core_of_counts hw hγ.le i (hcount i hi)

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
  rcases isEmpty_or_nonempty ι with hι | hι
  · exact ⟨fun _ => 0, fun _ => le_rfl, fun _ _ => rfl, fun j => isEmptyElim j,
      fun i => isEmptyElim i, fun i => isEmptyElim i⟩
  · obtain ⟨y, hy0, hyB, hyR, hyLap, hyF⟩ := ToolboxAux.block_barrier_sqrt hw hsymm B hlam hgap
    refine ⟨y, hy0, hyB, hyR, hyLap, fun i hi => ?_⟩
    have : ∑ j, w i j * y j = ∑ j ∈ B, w i j * y j :=
      (Finset.sum_subset (Finset.subset_univ B) (fun j _ hj => by rw [hyB j hj, mul_zero])).symm
    rw [← this]; exact hyF i hi

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
  have hle : ∀ i j, frameProjection U i j ^ 2 ≤ rowNormSq U i * rowNormSq U j := by
    intro i j
    have := projection_entry_sq_le_diagonal_mul (frameProjection U) (frameProjection_symm U)
      hU.frameProjection_idempotent i j
    rwa [frameProjection_diagonal, frameProjection_diagonal] at this
  have hinB : ∀ i, ∑ j ∈ B, frameProjection U i j ^ 2 ≤ rowNormSq U i / 4 := by
    intro i
    calc ∑ j ∈ B, frameProjection U i j ^ 2 ≤ ∑ j ∈ B, rowNormSq U i * rowNormSq U j :=
          Finset.sum_le_sum (fun j _ => hle i j)
      _ = rowNormSq U i * ∑ j ∈ B, rowNormSq U j := by rw [Finset.mul_sum]
      _ ≤ rowNormSq U i * (1 / 4) := mul_le_mul_of_nonneg_left htrace (rowNormSq_nonneg U i)
      _ = _ := by ring
  have hl : 0 < 3 * α / 8 := by positivity
  have hout : ∀ i, i ∈ B → 3 * α / 8 ≤
      ∑ j ∈ Finset.univ.filter (fun j => j ∉ B), frameProjection U i j ^ 2 := by
    intro i hi
    have hrow := hU.projection_row_squares i
    have hsplit := Finset.sum_filter_add_sum_filter_not Finset.univ (fun j => j ∈ B)
      (fun j => frameProjection U i j ^ 2)
    rw [Finset.filter_mem_eq_inter, Finset.univ_inter, hrow] at hsplit
    have h1 := hinB i
    have h2 := hp i hi
    linarith
  have hin : ∀ i, i ∉ B → ∑ j ∈ B, frameProjection U i j ^ 2 ≤ M / 4 :=
    fun i _ => (hinB i).trans (by linarith [hM i])
  obtain ⟨hy0, hyB, hyR, hyLap, hyF⟩ := Linear.indicator_exceptional_barrier
    (fun i j => sq_nonneg (frameProjection U i j)) B hl hout hin
  refine ⟨fun j => if j ∈ B then 1 / (3 * α / 8) else 0, hy0, hyB,
    fun j => (hyR j).trans_eq (by field_simp), hyLap, fun i hi => ?_⟩
  have hsub : ∑ j, frameProjection U i j ^ 2 * (if j ∈ B then 1 / (3 * α / 8) else 0) =
      ∑ j ∈ B, frameProjection U i j ^ 2 * (if j ∈ B then 1 / (3 * α / 8) else 0) :=
    (Finset.sum_subset (Finset.subset_univ B) (fun j _ hj => by simp [hj])).symm
  have := hyF i hi
  rw [hsub] at this
  refine this.trans (le_of_eq ?_)
  field_simp
  ring

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
  exact ToolboxAux.barrier_of_poisson hK

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
  exact ToolboxAux.poisson_of_barrier hw hsymm hH (barrier_connected w hw hsymm hH)

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
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  have ha : 0 < (d : ℝ) / n := by positivity
  have hΘ0 : 0 < Θ := by linarith
  have ht2 : 0 < t ^ 2 := by positivity
  have h1 : ((d : ℝ) / n * t ^ 2 / (2 * Θ)) * (Θ / ((d : ℝ) / n * t ^ 2)) = 1 / 2 := by
    field_simp
  have hsum : ∑ _i : Fin n, (d : ℝ) / n = (d : ℝ) := by
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  obtain ⟨W, hWp, hWd, hVW, hcost, -⟩ := thm_balancing V hs.parseval hs.barrier
    (fun _ => (d : ℝ) / n) hsum (by positivity) hs.diag h1.le
  have hENP : IsEqualNormParseval W :=
    ⟨hWp, fun i => by rw [← frameProjection_diagonal]; exact hWd i⟩
  have hsum2 : ∑ i, |(d : ℝ) / n - rowNormSq V i| ≤
      (n : ℝ) * ((d : ℝ) / n * t ^ 2 / (2 * Θ)) := by
    calc ∑ i, |(d : ℝ) / n - rowNormSq V i| ≤ ∑ _i : Fin n, ((d : ℝ) / n * t ^ 2 / (2 * Θ)) :=
          Finset.sum_le_sum (fun i _ => hs.diag i)
      _ = _ := by simp
  have hVW' : sqDistance V W ≤ 15 / 4 * (n : ℝ) * ((d : ℝ) / n * t ^ 2 / (2 * Θ)) := by
    have := hVW.trans hcost
    nlinarith
  have h3 : 15 / 4 * (n : ℝ) * ((d : ℝ) / n * t ^ 2 / (2 * Θ)) ≤ t ^ 2 * (d : ℝ) := by
    have : 15 / 4 * (n : ℝ) * ((d : ℝ) / n * t ^ 2 / (2 * Θ)) = 15 / (8 * Θ) * (t ^ 2 * d) := by
      field_simp; ring
    rw [this]
    have hc : 15 / (8 * Θ) ≤ 1 := by rw [div_le_one (by positivity)]; linarith
    nlinarith [mul_pos ht2 hdR]
  have h4 : sqDistance X W ≤ (2 * Θ + 2) * t ^ 2 * (d : ℝ) := by
    have htri := sqDistance_triangle X V W
    have := hs.dist
    nlinarith
  have h5 : (2 * Θ + 2) * t ^ 2 * (d : ℝ) ≤ 3 * Θ * t ^ 2 * (d : ℝ) := by
    nlinarith [mul_pos ht2 hdR]
  exact ⟨h1.le, W, hENP, hVW', h3, h4, h5⟩

/-- `cor:seed`.

TeX: "If $X$ has a $(\Theta,t)$-seed, there is an ENP frame $W$ with
$\fro{X-W}^2\le3\Theta t^2d$." -/
theorem cor_seed {n d : ℕ} (hd : 0 < d) (hdn : d ≤ n) {X V : Frame n d} {Θ t : ℝ}
    (hΘ : 2 ≤ Θ) (ht : 0 < t) (hs : IsSeed X V Θ t) :
    HasCorrection X (3 * Θ * t ^ 2 * (d : ℝ)) := by
  obtain ⟨-, W, hW, -, -, h4, h5⟩ := cor_seed_proof hd hdn hΘ ht hs
  exact ⟨W, hW, h4.trans h5⟩

end

end Paulsen.Paper
