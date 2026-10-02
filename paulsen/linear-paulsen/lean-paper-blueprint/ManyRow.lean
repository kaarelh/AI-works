import Paulsen.Paper.Gaussian
import Paulsen.Linear.ManyRow

/-!
# Paper blueprint, Section 4.1–4.3: the many-row seed, noise and identities
(`sections/manyrow.tex`)

Representation (library objects):
* `E = rowTangentSpace X`, `F = globalTangentSpace X` (subspaces of `FrameVector n d`);
* `Z = n^{-1/2} Π_F g = conditionedNoise X g`, `Z₀ = n^{-1/2} Π_E g = rowNoise X g`, with the
  *same* standard Gaussian `g ∼ stdGaussian (FrameVector n d)`;
* `V = tangentSeed X Z a t` (rows `(x_i + t z_i)/√(1+t² r_i)`), `V₀ = tangentSeed X Z₀ a t`;
* expectations are Bochner integrals against `stdGaussian (FrameVector n d)`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- The standard Gaussian on `ℝ^{n×d}`. -/
abbrev gaussFrame (n d : ℕ) : Measure (FrameVector n d) := stdGaussian (FrameVector n d)

/-- `Z₀ = n^{-1/2} Π_{𝓔} g`, the row-independent tangent noise. -/
def rowNoise {n d : ℕ} (X : Frame n d) (g : FrameVector n d) : Frame n d :=
  frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)

/-- `m = dim 𝓔 - dim 𝓕`. -/
def mrCodim {n d : ℕ} (X : Frame n d) : ℝ :=
  (Module.finrank ℝ (rowTangentSpace X) : ℝ) - (Module.finrank ℝ (globalTangentSpace X) : ℝ)

/-! ## 4.1 The noise -/

/-- Definition of `m` (manyrow, "The noise").

TeX: "let $m=\dim\mathcal E-\dim\mathcal F\le\dim\mathrm{Sym}_d\le d^2\le n$."
(The last inequality uses the standing assumption `n ≥ B d²`, here `d² ≤ n`.) -/
theorem mr_codim_le {n d : ℕ} (X : Frame n d) (hX : IsEqualNorm X) (hd : 1 ≤ d) :
    0 ≤ mrCodim X ∧ mrCodim X ≤ (d : ℝ) * ((d : ℝ) + 1) / 2 ∧
    (d : ℝ) * ((d : ℝ) + 1) / 2 ≤ (d : ℝ) ^ 2 := by
  sorry

/-- Covariance claims of "The noise" (unnumbered).

TeX: "each row $z_i$ of $Z$ is Gaussian with covariance $\Sigma_i\preceq n^{-1}(I-e_ie_i^T)$,
and $\Cov(\mathrm{vec}\,Z)\preceq I/n$." (with $e_i=x_i/\sqrt a$; the same holds for
$Z_0$.) -/
theorem mr_noise_covariance {n d : ℕ} (hn : 0 < n) (X : Frame n d) (hX : IsEqualNorm X) :
    opNorm (tangentNoiseFactor X) ^ 2 ≤ 1 / (n : ℝ) ∧
    opNorm (rowTangentNoiseFactor X) ^ 2 ≤ 1 / (n : ℝ) ∧
    ∀ (i : Fin n) (v : Fin d → ℝ),
      ∫ g, (∑ j, conditionedNoise X g i j * v j) ^ 2 ∂gaussFrame n d ≤
        (1 / (n : ℝ)) * (vectorNormSq v -
          (∑ j, X i j / Real.sqrt ((d : ℝ) / n) * v j) ^ 2) := by
  sorry

/-- `eq:mr-noise`.

TeX: "\E\fro Z^2=\frac{n(d-1)-m}{n}\le d,\qquad
 \E\fro{Z-Z_0}^2=\frac mn\le\frac{d^2}n ." -/
theorem eq_mr_noise {n d : ℕ} (hn : 0 < n) (hd : 1 ≤ d) (X : Frame n d)
    (hX : IsEqualNorm X) :
    ∫ g, frobSq (conditionedNoise X g) ∂gaussFrame n d =
        ((n : ℝ) * ((d : ℝ) - 1) - mrCodim X) / n ∧
    ((n : ℝ) * ((d : ℝ) - 1) - mrCodim X) / n ≤ (d : ℝ) ∧
    ∫ g, sqDistance (conditionedNoise X g) (rowNoise X g) ∂gaussFrame n d =
        mrCodim X / n ∧
    mrCodim X / n ≤ (d : ℝ) ^ 2 / n := by
  sorry

/-- `r_i = ‖z_i‖²/a` for the constrained noise `Z`. -/
def mrRatio {n d : ℕ} (X : Frame n d) (g : FrameVector n d) (i : Fin n) : ℝ :=
  rowNormSq (conditionedNoise X g) i / ((d : ℝ) / n)

/-- `μ_i = E r_i`. -/
def mrRatioMean {n d : ℕ} (X : Frame n d) (i : Fin n) : ℝ :=
  ∫ g, mrRatio X g i ∂gaussFrame n d

/-- `δ_i = 1 - μ_i`. -/
def mrDeficit {n d : ℕ} (X : Frame n d) (i : Fin n) : ℝ := 1 - mrRatioMean X i

/-- `𝓜 = a ∑_i E[(r_i-1)²(1+r_i)²]`. -/
def mrMoment {n d : ℕ} (X : Frame n d) : ℝ :=
  ((d : ℝ) / n) * ∑ i, ∫ g, (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2 ∂gaussFrame n d

/-- `Σ̃_i = Σ_i / a`, the normalised covariance of the row `z_i`. -/
def mrRowCovariance {n d : ℕ} (X : Frame n d) (i : Fin n) : Matrix (Fin d) (Fin d) ℝ :=
  Matrix.of fun j k =>
    (∫ g, conditionedNoise X g i j * conditionedNoise X g i k ∂gaussFrame n d) / ((d : ℝ) / n)

/-- `lem:rowmoments`, first claims.

TeX: "Let $r_i=\norm{z_i}^2/a$, $\mu_i=\E r_i$ and $\delta_i=1-\mu_i$. Then
$1/d\le\delta_i\le1$, $\sum_ia\delta_i=1+m/n\le2$"

(The bound `≤ 2` uses the standing assumption `m ≤ d² ≤ n`.) -/
theorem lem_rowmoments_deficit {n d : ℕ} (hd : 2 ≤ d) (hdn : (d : ℝ) ^ 2 ≤ n)
    (X : Frame n d) (hX : IsEqualNorm X) :
    (∀ i, 1 / (d : ℝ) ≤ mrDeficit X i ∧ mrDeficit X i ≤ 1) ∧
    ∑ i, ((d : ℝ) / n) * mrDeficit X i = 1 + mrCodim X / n ∧
    1 + mrCodim X / n ≤ 2 := by
  sorry

/-- `lem:rowmoments`, main claim.

TeX: "\[ \mathcal M:=a\sum_i\E\bigl[(r_i-1)^2(1+r_i)^2\bigr]\le C_{\mathcal M}, \]
with $C_{\mathcal M}$ absolute." -/
theorem lem_rowmoments :
    ∃ CM : ℝ, 0 ≤ CM ∧ ∀ (n d : ℕ) (X : Frame n d), 2 ≤ d → (d : ℝ) ^ 2 ≤ n →
      IsEqualNorm X → mrMoment X ≤ CM := by
  sorry

/-- Proof of `lem:rowmoments`: Gaussian moment formulas, with explicit constants.

TeX: "$\tilde\Sigma_i=\Sigma_i/a\preceq d^{-1}I$ has trace $\mu_i\le(d-1)/d$, so
$\tr\tilde\Sigma_i^2\le1/d$ and $\tr\tilde\Sigma_i^4\le d^{-3}$. For
$\xi_i=r_i-\mu_i$ the Gaussian moment formulas give $\E\xi_i^2=2\tr\tilde\Sigma_i^2\le
2/d$ and $\E\xi_i^4=12(\tr\tilde\Sigma_i^2)^2+48\tr\tilde\Sigma_i^4\le60/d^2$." -/
theorem lem_rowmoments_gaussian {n d : ℕ} (hd : 2 ≤ d) (hdn : (d : ℝ) ^ 2 ≤ n)
    (X : Frame n d) (hX : IsEqualNorm X) (i : Fin n) :
    (∀ v : Fin d → ℝ, matrixQuadratic (mrRowCovariance X i) v ≤ (1 / (d : ℝ)) * vectorNormSq v) ∧
    (mrRowCovariance X i).trace = mrRatioMean X i ∧
    mrRatioMean X i ≤ ((d : ℝ) - 1) / d ∧
    (mrRowCovariance X i ^ 2).trace ≤ 1 / (d : ℝ) ∧
    (mrRowCovariance X i ^ 4).trace ≤ ((d : ℝ) ^ 3)⁻¹ ∧
    ∫ g, (mrRatio X g i - mrRatioMean X i) ^ 2 ∂gaussFrame n d =
      2 * (mrRowCovariance X i ^ 2).trace ∧
    2 * (mrRowCovariance X i ^ 2).trace ≤ 2 / (d : ℝ) ∧
    ∫ g, (mrRatio X g i - mrRatioMean X i) ^ 4 ∂gaussFrame n d =
      12 * ((mrRowCovariance X i ^ 2).trace) ^ 2 + 48 * (mrRowCovariance X i ^ 4).trace ∧
    12 * ((mrRowCovariance X i ^ 2).trace) ^ 2 + 48 * (mrRowCovariance X i ^ 4).trace ≤
      60 / (d : ℝ) ^ 2 := by
  sorry

/-- Proof of `lem:rowmoments`: the pointwise inequality.

TeX: "Finally $(r_i-1)^2\le2\xi_i^2+2\delta_i^2$ and $(1+r_i)^2\le8+2\xi_i^2$, so
\[ \E(r_i-1)^2(1+r_i)^2\le16\E\xi_i^2+4\E\xi_i^4+16\delta_i^2+4\delta_i^2\E\xi_i^2 \]"
(scalar form, with `r = 1 - δ + ξ`, `0 ≤ δ ≤ 1`). -/
theorem lem_rowmoments_scalar (δ ξ : ℝ) (hδ0 : 0 ≤ δ) (hδ1 : δ ≤ 1) :
    ((1 - δ + ξ) - 1) ^ 2 ≤ 2 * ξ ^ 2 + 2 * δ ^ 2 ∧
    (1 + (1 - δ + ξ)) ^ 2 ≤ 8 + 2 * ξ ^ 2 ∧
    ((1 - δ + ξ) - 1) ^ 2 * (1 + (1 - δ + ξ)) ^ 2 ≤
      16 * ξ ^ 2 + 4 * ξ ^ 4 + 16 * δ ^ 2 + 4 * δ ^ 2 * ξ ^ 2 := by
  sorry

/-! ## 4.2 Row normalisation and the exact second-order identity -/

/-- `eq:mr-contract` (with the exact row norms and the 1-Lipschitz normalisation).

TeX: "Since $z_i\perp x_i$, $\norm{v_i}^2=\norm{v_{0,i}}^2=a$ exactly. [...] Thus
\[ \fro{V-X}\le t\fro Z,\quad \fro{V-V_0}\le t\fro{Z-Z_0},\quad
 \opn V\le\opn{X+tZ},\quad\opn{V_0}\le\opn{X+tZ_0}, \]" -/
theorem eq_mr_contract {n d : ℕ} (X Z Z₀ : Frame n d) {a t : ℝ} (ha : 0 < a) (ht : 0 < t)
    (ht1 : t ≤ 1) (hX : ∀ i, rowNormSq X i = a) (hZ : ∀ i, rowDot X Z i = 0)
    (hZ₀ : ∀ i, rowDot X Z₀ i = 0) :
    (∀ i, rowNormSq (tangentSeed X Z a t) i = a) ∧
    (∀ i, rowNormSq (tangentSeed X Z₀ a t) i = a) ∧
    Real.sqrt (sqDistance (tangentSeed X Z a t) X) ≤ t * Real.sqrt (frobSq Z) ∧
    Real.sqrt (sqDistance (tangentSeed X Z a t) (tangentSeed X Z₀ a t)) ≤
      t * Real.sqrt (sqDistance Z Z₀) ∧
    opNorm (tangentSeed X Z a t) ≤ opNorm (X + t • Z) ∧
    opNorm (tangentSeed X Z₀ a t) ≤ opNorm (X + t • Z₀) := by
  sorry

/-- The metric-projection fact used for `eq:mr-contract` (unnumbered).

TeX: "The map $y\mapsto\sqrt a\,y/\norm y$ is the metric projection onto the closed ball of
radius $\sqrt a$ on $\{\norm y\ge\sqrt a\}$, hence $1$-Lipschitz there." -/
theorem mr_normalisation_lipschitz {d : ℕ} {a : ℝ} (ha : 0 < a)
    (y y' : EuclideanSpace ℝ (Fin d)) (hy : Real.sqrt a ≤ ‖y‖) (hy' : Real.sqrt a ≤ ‖y'‖) :
    ‖(Real.sqrt a / ‖y‖) • y - (Real.sqrt a / ‖y'‖) • y'‖ ≤ ‖y - y'‖ := by
  sorry

/-- `c_i = r_i/(1+t² r_i)`, with `r_i = ‖z_i‖²/a`. -/
def mrWeight {n d : ℕ} (a t : ℝ) (Z : Frame n d) (i : Fin n) : ℝ :=
  tangentRatio a Z i / (1 + t ^ 2 * tangentRatio a Z i)

/-- `Q(Z) = ZᵀZ - ∑_i r_i x_i x_iᵀ`. -/
def mrQ {n d : ℕ} (X Z : Frame n d) (a : ℝ) : Matrix (Fin d) (Fin d) ℝ :=
  Z.transpose * Z - X.transpose * Matrix.diagonal (tangentRatio a Z) * X

/-- `R₃ = -t³ ∑_i c_i (x_i z_iᵀ + z_i x_iᵀ)`. -/
def mrR3 {n d : ℕ} (X Z : Frame n d) (a t : ℝ) : Matrix (Fin d) (Fin d) ℝ :=
  (-t ^ 3) • (X.transpose * Matrix.diagonal (mrWeight a t Z) * Z +
    Z.transpose * Matrix.diagonal (mrWeight a t Z) * X)

/-- `R₄ = -t⁴ ∑_i c_i (z_i z_iᵀ - r_i x_i x_iᵀ)`. -/
def mrR4 {n d : ℕ} (X Z : Frame n d) (a t : ℝ) : Matrix (Fin d) (Fin d) ℝ :=
  (-t ^ 4) • (Z.transpose * Matrix.diagonal (mrWeight a t Z) * Z -
    X.transpose * Matrix.diagonal (fun i => mrWeight a t Z i * tangentRatio a Z i) * X)

/-- `eq:mr-identity`.

TeX: "Expanding $1/(1+t^2r_i)=1-t^2c_i$ with $c_i=\frac{r_i}{1+t^2r_i}$,
and using $X^TZ+Z^TX=0$, one finds the exact identity
\[ V^TV=S+t^2Q(Z)+R_3+R_4,\qquad Q(Z)=Z^TZ-\sum_ir_ix_ix_i^T, \]
\[ R_3=-t^3\sum_ic_i(x_iz_i^T+z_ix_i^T),\qquad
 R_4=-t^4\sum_ic_i(z_iz_i^T-r_ix_ix_i^T). \]" -/
theorem eq_mr_identity {n d : ℕ} (X Z : Frame n d) {a : ℝ} (ha : 0 < a) (t : ℝ)
    (hglobal : X.transpose * Z + Z.transpose * X = 0) :
    (∀ i, 1 / (1 + t ^ 2 * tangentRatio a Z i) = 1 - t ^ 2 * mrWeight a t Z i) ∧
    (tangentSeed X Z a t).transpose * tangentSeed X Z a t =
      X.transpose * X + t ^ 2 • mrQ X Z a + mrR3 X Z a t + mrR4 X Z a t := by
  sorry

/-- Bridge to the library (not in the paper): `Q` and `R₃ + R₄` are the library's
`tangentQuadratic` and `tangentRemainder`. -/
theorem mrQ_mrR_eq_library {n d : ℕ} (X Z : Frame n d) (a t : ℝ) :
    mrQ X Z a = tangentQuadratic X Z a ∧
    mrR3 X Z a t + mrR4 X Z a t = tangentRemainder X Z a t := by
  sorry

/-- `E Q(Z)`, entrywise. -/
def mrQMean {n d : ℕ} (X : Frame n d) : Matrix (Fin d) (Fin d) ℝ :=
  Matrix.of fun j k => ∫ g, mrQ X (conditionedNoise X g) ((d : ℝ) / n) j k ∂gaussFrame n d

/-- `lem:Q` (Mean and fluctuation of `Q`).

TeX: "$\opn{\E Q(Z)-(I-S)}\le m/n$ and $\E\fro{Q(Z)-\E Q(Z)}^2\le8d^2/n$." -/
theorem lem_Q {n d : ℕ} (hn : 0 < n) (hd : 1 ≤ d) (X : Frame n d) (hX : IsEqualNorm X) :
    opNorm (mrQMean X - (1 - X.transpose * X)) ≤ mrCodim X / n ∧
    ∫ g, frobSq (mrQ X (conditionedNoise X g) ((d : ℝ) / n) - mrQMean X) ∂gaussFrame n d ≤
      8 * (d : ℝ) ^ 2 / n := by
  sorry

/-- Proof of `lem:Q`: the unconstrained mean.

TeX: "For $Z_0$: $\E Z_0^TZ_0=n^{-1}\sum_i(I-e_ie_i^T)=I-S/d$ and $\E r_{0,i}=(d-1)/d$,
so $\E Q(Z_0)=I-S/d-(1-1/d)S=I-S$." -/
theorem lem_Q_row_mean {n d : ℕ} (hn : 0 < n) (hd : 1 ≤ d) (X : Frame n d)
    (hX : IsEqualNorm X) :
    (Matrix.of fun j k => ∫ g, ((rowNoise X g).transpose * rowNoise X g) j k ∂gaussFrame n d) =
      1 - (1 / (d : ℝ)) • (X.transpose * X) ∧
    (∀ i, ∫ g, tangentRatio ((d : ℝ) / n) (rowNoise X g) i ∂gaussFrame n d =
      ((d : ℝ) - 1) / d) ∧
    (Matrix.of fun j k => ∫ g, mrQ X (rowNoise X g) ((d : ℝ) / n) j k ∂gaussFrame n d) =
      1 - X.transpose * X := by
  sorry

/-- Proof of `lem:Q`: the coefficient matrices of the entries of `Q`.

TeX: "Entry $(\alpha,\beta)$ of $Q$ is the quadratic form $\sum_iz_i^T\mathsf B_{\alpha\beta,i}z_i$
with $\mathsf B_{\alpha\beta,i}=\frac12(E_{\alpha\beta}+E_{\beta\alpha})-(e_i)_\alpha(e_i)_\beta I$
[...] Since $\sum_{\alpha,\beta}\fro{\mathsf B_{\alpha\beta,i}}^2\le2d^2+2d\le4d^2$ for
each $i$" (here `e` is any unit vector). -/
theorem lem_Q_coefficients {d : ℕ} (hd : 1 ≤ d) (e : Fin d → ℝ) (he : vectorNormSq e = 1) :
    ∑ α, ∑ β, frobSq ((1 / 2 : ℝ) • (Matrix.single α β (1 : ℝ) + Matrix.single β α 1) -
        (e α * e β) • (1 : Matrix (Fin d) (Fin d) ℝ)) ≤ 2 * (d : ℝ) ^ 2 + 2 * d ∧
    2 * (d : ℝ) ^ 2 + 2 * d ≤ 4 * (d : ℝ) ^ 2 := by
  sorry

/-- `c̄ = 1/(1+t²)`. -/
def mrCbar (t : ℝ) : ℝ := 1 / (1 + t ^ 2)

/-- `Γ = Diag(c_i - c̄)`. -/
def mrGamma {n d : ℕ} (a t : ℝ) (Z : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal fun i => mrWeight a t Z i - mrCbar t

/-- `Λ = Diag(c_i r_i - c̄)`. -/
def mrLambda {n d : ℕ} (a t : ℝ) (Z : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal fun i => mrWeight a t Z i * tangentRatio a Z i - mrCbar t

/-- `lem:remainder` (Remainder), deterministic bounds.

TeX: "Let $\bar c=1/(1+t^2)$, $\Gamma=\Diag(c_i-\bar c)$ and
$\Lambda=\Diag(c_ir_i-\bar c)$. Then
\[ \opn{R_3}\le2t^3\opn X\fro{\Gamma Z},\qquad
 \opn{R_4}\le t^4\bigl(\opn Z^2+\opn Z\fro{\Gamma Z}+\opn S+\opn X\fro{\Lambda X}\bigr), \]" -/
theorem lem_remainder {n d : ℕ} (X Z : Frame n d) {a t : ℝ} (ha : 0 < a) (ht : 0 < t)
    (ht1 : t ≤ 1) (hglobal : X.transpose * Z + Z.transpose * X = 0) :
    opNorm (mrR3 X Z a t) ≤ 2 * t ^ 3 * opNorm X * Real.sqrt (frobSq (mrGamma a t Z * Z)) ∧
    opNorm (mrR4 X Z a t) ≤ t ^ 4 * (opNorm Z ^ 2 +
      opNorm Z * Real.sqrt (frobSq (mrGamma a t Z * Z)) + opNorm (X.transpose * X) +
      opNorm X * Real.sqrt (frobSq (mrLambda a t Z * X))) := by
  sorry

/-- `lem:remainder`, moment bounds.

TeX: "and $\E\fro{\Gamma Z}^2\le\mathcal M$, $\E\fro{\Lambda X}^2\le\mathcal M$." -/
theorem lem_remainder_moments {n d : ℕ} (hn : 0 < n) (hd : 2 ≤ d) (X : Frame n d)
    (hX : IsEqualNorm X) {t : ℝ} (ht : 0 < t) (ht1 : t ≤ 1) :
    ∫ g, frobSq (mrGamma ((d : ℝ) / n) t (conditionedNoise X g) * conditionedNoise X g)
        ∂gaussFrame n d ≤ mrMoment X ∧
    ∫ g, frobSq (mrLambda ((d : ℝ) / n) t (conditionedNoise X g) * X) ∂gaussFrame n d ≤
      mrMoment X := by
  sorry

/-- Proof of `lem:remainder`: the scalar weight identities.

TeX: "c_i-\bar c=\frac{r_i-1}{(1+t^2r_i)(1+t^2)},\qquad
 c_ir_i-\bar c=\frac{(r_i-1)(1+r_i+t^2r_i)}{(1+t^2r_i)(1+t^2)},
so $|c_i-\bar c|\le|r_i-1|$ and, as $1+r+t^2r\le(1+r)(1+t^2r)$,
$|c_ir_i-\bar c|\le|r_i-1|(1+r_i)$." -/
theorem lem_remainder_scalar (r t : ℝ) (hr : 0 ≤ r) :
    r / (1 + t ^ 2 * r) - 1 / (1 + t ^ 2) = (r - 1) / ((1 + t ^ 2 * r) * (1 + t ^ 2)) ∧
    r / (1 + t ^ 2 * r) * r - 1 / (1 + t ^ 2) =
      (r - 1) * (1 + r + t ^ 2 * r) / ((1 + t ^ 2 * r) * (1 + t ^ 2)) ∧
    |r / (1 + t ^ 2 * r) - 1 / (1 + t ^ 2)| ≤ |r - 1| ∧
    1 + r + t ^ 2 * r ≤ (1 + r) * (1 + t ^ 2 * r) ∧
    |r / (1 + t ^ 2 * r) * r - 1 / (1 + t ^ 2)| ≤ |r - 1| * (1 + r) := by
  sorry

/-- Remark after `lem:remainder` (the termwise bound).

TeX: "The termwise bound $\opn{R_3}\le2t^3\sum_ic_i\norm{x_i}\norm{z_i}\approx2t^3d$
would only allow $\eta\lesssim d^{-2}$." (the rigorous part: the termwise inequality.) -/
theorem rem_remainder_termwise {n d : ℕ} (X Z : Frame n d) {a t : ℝ} (ha : 0 < a)
    (ht : 0 < t) :
    opNorm (mrR3 X Z a t) ≤
      2 * t ^ 3 * ∑ i, mrWeight a t Z i * Real.sqrt (rowNormSq X i) *
        Real.sqrt (rowNormSq Z i) := by
  sorry

/-! ## 4.3 A dense reference graph -/

/-- The conclusion of `lem:mr-dense` for given constants `h, t₀, c₁`. -/
def MrDenseConclusion (h t₀ c₁ : ℝ) : Prop :=
  ∀ (n d : ℕ) (X : Frame n d), 2 ≤ d → IsEqualNorm X → ∀ t : ℝ, 0 < t → t ≤ t₀ →
    1 - (n : ℝ) * Real.exp (-c₁ * ((n : ℝ) - 1)) ≤
      (gaussFrame n d).real {g | ∀ i : Fin n, 9 / 10 * ((n : ℝ) - 1) ≤
        ((Finset.univ.filter (fun j => j ≠ i ∧
          h * t * Real.sqrt (((d : ℝ) / n) / n) ≤
            |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|)).card : ℝ)}

/-- `lem:mr-dense`.

TeX: "There are absolute $h,t_0\in(0,1]$ and $c_1>0$ such that for $d\ge2$ and
$t\le t_0$, with probability at least $1-ne^{-c_1(n-1)}$, every $i$ has at least $0.9(n-1)$
indices $j\ne i$ with \[ |\ip{v_{0,i}}{v_{0,j}}|\ge h\,t\sqrt{a/n}. \]"

(`V₀ = rowIndependentSeed X t g = tangentSeed X Z₀ a t`; `⟨v_{0,i}, v_{0,j}⟩ = (V₀V₀ᵀ)_{ij}`.) -/
theorem lem_mr_dense :
    ∃ h t₀ c₁ : ℝ, 0 < h ∧ h ≤ 1 ∧ 0 < t₀ ∧ t₀ ≤ 1 ∧ 0 < c₁ ∧ MrDenseConclusion h t₀ c₁ := by
  sorry

/-- Proof of `lem:mr-dense`, with its explicit constant recipe.

TeX: "Choose $h$ and $t_0$ so that $3h+t_0^2/3+8t_0^2\le\frac1{50}$ [...] more than
$0.1(n-1)$ failures have probability at most
$\exp(-(n-1)[0.1-\frac{e-1}{50}])\le e^{-c_1(n-1)}$." -/
theorem lem_mr_dense_explicit {h t₀ : ℝ} (hh : 0 < h) (hh1 : h ≤ 1) (ht₀ : 0 < t₀)
    (ht₀1 : t₀ ≤ 1) (hsum : 3 * h + t₀ ^ 2 / 3 + 8 * t₀ ^ 2 ≤ 1 / 50) :
    0 < 1 / 10 - (Real.exp 1 - 1) / 50 ∧
    MrDenseConclusion h t₀ (1 / 10 - (Real.exp 1 - 1) / 50) := by
  sorry

/-- Proof of `lem:mr-dense`: the per-pair failure estimates (explicit constants).

TeX: "By Markov, $\Prob(N_j>2)\le t^2/3$. [...] If $|u_j|\le\frac12$
the variance is at least $3t^2/(4d)$ and the Gaussian density bound gives
probability at most $4h/\sqrt{3\pi/2}\le3h$. If $|u_j|>\frac12$ and $2ht\le\frac14$,
failure requires $\frac t{\sqrt d}|\ip f{g'_j}|>\frac14$, of probability at most
$16t^2/d$. [...] (this also gives $2ht\le\frac14$, and $16t^2/d\le8t^2$ as $d\ge2$)."

Stated for a scalar Gaussian `ν ∼ N(u, s²)` and the elementary inequalities. -/
theorem lem_mr_dense_pair {h t : ℝ} {d : ℕ} (hd : 2 ≤ d) (hh : 0 < h) (ht : 0 < t)
    (ht1 : t ≤ 1) (u : ℝ) (s : NNReal) (hs : 3 * t ^ 2 / (4 * d) ≤ (s : ℝ)) :
    (gaussianReal u s).real {x | |x| < 2 * h * t / Real.sqrt d} ≤
      4 * h / Real.sqrt (3 * Real.pi / 2) ∧
    4 * h / Real.sqrt (3 * Real.pi / 2) ≤ 3 * h ∧
    16 * t ^ 2 / d ≤ 8 * t ^ 2 ∧
    (3 * h + t ^ 2 / 3 + 8 * t ^ 2 ≤ 1 / 50 → 2 * h * t ≤ 1 / 4) := by
  sorry

end

end Paulsen.Paper
