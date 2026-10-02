import Paulsen.Paper.Gaussian
import Paulsen.Linear.ModerateDrift
import Paulsen.SmoothRationalCovariance
import Paulsen.SmoothExpectedExpansion

/-!
# Paper blueprint, Section 5.0–5.4: the moderate-row seed, setup (`sections/moderate.tex`)

Representation (ambient horizontal coordinates, as in the library):
* `Z ∈ 𝒵 = ℝ^{(n-d)×d}` is represented by `H = VZ : Frame n d` with `Uᵀ H = 0`; then
  `‖Z‖ = ‖H‖` (Frobenius and operator), `Zᵀv_i` is row `i` of `H`, `‖Z u_i‖` is the norm of
  row `i` of `U Hᵀ`;
* `Y_Z = VZUᵀ + UZᵀVᵀ` is `tangentY U H = H Uᵀ + U Hᵀ`; `(𝒜Z)_i = (HUᵀ)_ii = diagMap U H i`;
* `N_x = 𝒜^* x` is `ambientNormal U x = (I-P) Diag(x) U`; `Γ_f` is `Linear.driftGamma U f`;
* `S = normalizedFisher U`, `Ω = normalizedNormalCovariance U` (acting on `FrameVector n d`),
  the identity of `𝒵` is `horizontalProjectionMatrix U`; eigenvalues `μ` are
  `normalizedFisherEigenvalue U j`, the modes `μ > 0` are `highNormalizedModes U 0`,
  `f_y = normalizedNormalPotential U j`, `Z_y = normalizedNormalFrame U j`;
* `r_μ = Smooth.residualWeight ρ μ`, `R_ρ = Smooth.modeSum U (Smooth.residualWeight ρ)`;
* the filtered noise `Z ∼ N(0, C_ρ/n)` is `moderateNoise U ρ g = Smooth.moderateNoiseFrame U ρ g`
  with `g ∼ stdGaussian (FrameVector n d)`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- The standing assumptions of Section 5.

TeX: "Throughout this section $P=UU^T$, $p=\diag P$, $D_p=\Diag(p)$, $L=L_P$, and
$\eps_0\le\frac12$, so $\frac a2\le p_i\le\frac{3a}2\le\frac34$."
(together with `U` Parseval, `2d ≤ n`, `d ≥ 1` from `thm:moderate`). -/
structure ModerateStanding {n d : ℕ} (U : Frame n d) : Prop where
  parseval : IsParseval U
  pos : 0 < d
  density : 2 * d ≤ n
  rows : ∀ i, (d : ℝ) / n / 2 ≤ rowNormSq U i ∧ rowNormSq U i ≤ 3 * ((d : ℝ) / n) / 2

/-- The standard Gaussian on the ambient space `ℝ^{n×d}` (only its horizontal part is used). -/
abbrev gaussAmb (n d : ℕ) : Measure (FrameVector n d) := stdGaussian (FrameVector n d)

/-! ## Preamble: the Laplacians `𝓛(M)`, `𝒞(Y)`, `𝖪` -/

/-- `e_i - e_j`. -/
def edgeVec {n : ℕ} (i j : Fin n) : Fin n → ℝ := Pi.single i 1 - Pi.single j 1

/-- `𝓛(M) = ∑_{i<j} M_{ij}² (e_i - e_j)(e_i - e_j)ᵀ`. -/
def sqLaplacian {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  ∑ i, ∑ j, if i < j then (M i j ^ 2) • Matrix.vecMulVec (edgeVec i j) (edgeVec i j) else 0

/-- `𝒞(Y) = ∑_{i<j} 2 P_{ij} Y_{ij} (e_i - e_j)(e_i - e_j)ᵀ`. -/
def crossLaplacian {n : ℕ} (P Y : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  ∑ i, ∑ j, if i < j then (2 * P i j * Y i j) • Matrix.vecMulVec (edgeVec i j) (edgeVec i j)
    else 0

/-- `𝖪 = nI - 𝟙𝟙ᵀ`, the Laplacian of the complete graph. -/
def completeLaplacian (n : ℕ) : Matrix (Fin n) (Fin n) ℝ :=
  (n : ℝ) • (1 : Matrix (Fin n) (Fin n) ℝ) - Matrix.of fun _ _ => (1 : ℝ)

/-- Facts stated with the definition of `𝓛` (unnumbered).

TeX: "thus $L=\Lap(P)$, $x^T\Lap(M)x=\frac12\fro{[\Diag x,M]}^2$" (for symmetric `M`), and
(Section 5.5) "$\Lap(P+tY)=L+t\mathcal C(Y)+t^2\Lap(Y)$". -/
theorem lap_facts {n d : ℕ} (U : Frame n d) (hU : IsParseval U) :
    sqLaplacian (frameProjection U) = projectionLaplacian (frameProjection U) ∧
    (∀ (M : Matrix (Fin n) (Fin n) ℝ), M.transpose = M → ∀ x,
      matrixQuadratic (sqLaplacian M) x = (1 / 2) * frobSq (diagonalCommutator x M)) ∧
    ∀ (P Y : Matrix (Fin n) (Fin n) ℝ) (t : ℝ),
      sqLaplacian (P + t • Y) = sqLaplacian P + t • crossLaplacian P Y + t ^ 2 • sqLaplacian Y :=
  by sorry

/-- `eq:lap-basic`.

TeX: "\Lap(M)\preceq2\max_i\norm{M_i}^2\,I,\qquad
 \Lap(M+M')\succeq\tfrac12\Lap(M)-\Lap(M'),"
(`M_i` is the `i`-th row; `max_i ‖M_i‖²` is replaced by any upper bound `c`.) -/
theorem eq_lap_basic {n : ℕ} (M M' : Matrix (Fin n) (Fin n) ℝ) (hM : M.transpose = M)
    (hM' : M'.transpose = M') :
    (∀ c : ℝ, (∀ i, rowNormSq M i ≤ c) → ∀ x : Fin n → ℝ,
      matrixQuadratic (sqLaplacian M) x ≤ 2 * c * vectorNormSq x) ∧
    ∀ x : Fin n → ℝ, (1 / 2) * matrixQuadratic (sqLaplacian M) x -
      matrixQuadratic (sqLaplacian M') x ≤ matrixQuadratic (sqLaplacian (M + M')) x := by
  sorry

/-! ## 5.1 The horizontal tangent space and the filtered covariance -/

/-- `Y_Z = VZUᵀ + UZᵀVᵀ`, in ambient coordinates `Y_H = H Uᵀ + U Hᵀ`. -/
def tangentY {n d : ℕ} (U H : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  H * U.transpose + U * H.transpose

/-- `(𝒜Z)_i = v_iᵀ Z u_i = (VZUᵀ)_{ii}`, in ambient coordinates `(H Uᵀ)_{ii}`. -/
def diagMap {n d : ℕ} (U H : Frame n d) : Fin n → ℝ := fun i => (H * U.transpose) i i

/-- Facts on `Y_Z` (Section 5.1, displayed, unnumbered).

TeX: "Y_Z=VZU^T+UZ^TV^T,\qquad \norm{(Y_Z)_i}^2=\norm{Z^Tv_i}^2+\norm{Zu_i}^2\le\opn Z^2,
 \qquad \fro{Y_Z}^2=2\fro Z^2 ." -/
theorem tangentY_facts {n d : ℕ} (U H : Frame n d) (hU : IsParseval U)
    (hUH : U.transpose * H = 0) :
    (∀ i, rowNormSq (tangentY U H) i = rowNormSq H i + rowNormSq (U * H.transpose) i) ∧
    (∀ i, rowNormSq (tangentY U H) i ≤ opNorm H ^ 2) ∧
    frobSq (tangentY U H) = 2 * frobSq H := by
  sorry

/-- Facts on `𝒜` (Section 5.1, unnumbered).

TeX: "$\mathcal A^*x=N_x:=V^T\Diag(x)U$. Then $\mathcal A\mathcal A^*=L$, i.e.\
$\fro{N_x}^2=x^TLx$" (adjointness: `⟨𝒜H, x⟩ = ⟨H, N_x⟩_F` for horizontal `H`). -/
theorem diagMap_adjoint {n d : ℕ} (U H : Frame n d) (hU : IsParseval U)
    (hUH : U.transpose * H = 0) (x : Fin n → ℝ) :
    ∑ i, x i * diagMap U H i = ∑ i, ∑ k, H i k * ambientNormal U x i k ∧
    frobSq (ambientNormal U x) = matrixQuadratic (projectionLaplacian (frameProjection U)) x ∧
    U.transpose * ambientNormal U x = 0 := by
  sorry

/-- `eq:S`.

TeX: "Since $L\succeq0$ and $S=I-D_p^{-1/2}(P\circ P)D_p^{-1/2}$ with $P\circ P\succeq0$
(Schur product theorem),
\[ 0\preceq S\preceq I,\qquad 0\preceq \Omega\preceq I,\qquad
 \tr(I-S)=\sum_i\frac{P_{ii}^2}{p_i}=d . \]" -/
theorem eq_S {n d : ℕ} (U : Frame n d) (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) :
    normalizedFisher U = 1 - leverageNormalizer U *
      Matrix.of (fun i j => frameProjection U i j ^ 2) * leverageNormalizer U ∧
    (∀ x : Fin n → ℝ, 0 ≤ matrixQuadratic (normalizedFisher U) x ∧
      matrixQuadratic (normalizedFisher U) x ≤ vectorNormSq x) ∧
    (∀ v : Fin n × Fin d → ℝ, 0 ≤ matrixQuadratic (normalizedNormalCovariance U) v ∧
      matrixQuadratic (normalizedNormalCovariance U) v ≤ ∑ q, v q ^ 2) ∧
    (1 - normalizedFisher U).trace = ∑ i, frameProjection U i i ^ 2 / rowNormSq U i ∧
    ∑ i, frameProjection U i i ^ 2 / rowNormSq U i = (d : ℝ) := by
  sorry

/-- The eigenbasis `(Z_y)` (Section 5.1, unnumbered).

TeX: "Since $\Omega Z_y=\mu Z_y$ and
$\ip{Z_y}{Z_{y'}}=\ip y{Sy'}/\sqrt{\mu\mu'}$, the $Z_y$ form an orthonormal
eigenbasis of $\Omega$ on $(\ker \Omega)^\perp$."
(`normalizedNormalDirection U j = vec Z_y`, `Z_y = μ^{-1/2} N_{f_y}`.) -/
theorem eigenbasis_facts {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) :
    (∀ j ∈ highNormalizedModes U 0,
      Matrix.toEuclideanLin (normalizedNormalCovariance U) (normalizedNormalDirection U j) =
        normalizedFisherEigenvalue U j • normalizedNormalDirection U j) ∧
    (∀ j ∈ highNormalizedModes U 0, ∀ j' ∈ highNormalizedModes U 0,
      inner ℝ (normalizedNormalDirection U j) (normalizedNormalDirection U j') =
        if j = j' then 1 else 0) ∧
    (∀ j ∈ highNormalizedModes U 0, normalizedNormalFrame U j =
      (Real.sqrt (normalizedFisherEigenvalue U j))⁻¹ •
        ambientNormal U (normalizedNormalPotential U j)) ∧
    ∀ v : FrameVector n d, horizontalProjectionMatrix U *ᵥ (v : Fin n × Fin d → ℝ) = v →
      (∀ j ∈ highNormalizedModes U 0, inner ℝ v (normalizedNormalDirection U j) = 0) →
        normalizedNormalCovariance U *ᵥ (v : Fin n × Fin d → ℝ) = 0 := by
  sorry

/-- `eq:finfty`.

TeX: "Since $p_i\ge a/2$, \[ \norm{f_y}_\infty\le\sqrt{2/a}. \]" -/
theorem eq_finfty {n d : ℕ} (U : Frame n d) (hd : 0 < d) (hn : 0 < n)
    (hp : ∀ i, (d : ℝ) / n / 2 ≤ rowNormSq U i) (j i : Fin n) :
    |normalizedNormalPotential U j i| ≤ Real.sqrt (2 / ((d : ℝ) / n)) := by
  sorry

/-- Definition (Filtered covariance).

TeX: "For $\rho>0$ let $C_\rho=\rho(I-\Omega)(\rho I+\Omega)^{-1}$ on $\mathcal Z$, let
$Z\sim N(0,C_\rho/n)$, and $Y=Y_Z$."

In ambient coordinates the identity of `𝒵` is the horizontal projection. -/
def filteredCovariance {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  ρ • ((horizontalProjectionMatrix U - normalizedNormalCovariance U) *
    (ρ • 1 + normalizedNormalCovariance U)⁻¹)

/-- The filtered Gaussian noise `Z ∼ N(0, C_ρ/n)`, as the ambient horizontal frame `H = VZ`. -/
abbrev moderateNoise {n d : ℕ} (U : Frame n d) (ρ : ℝ) (g : FrameVector n d) : Frame n d :=
  Smooth.moderateNoiseFrame U ρ g

/-- Faithfulness of the filtered noise (bridge to the library): the library noise
`Smooth.moderateNoiseFrame U ρ g = frameOfVector (F g)` has factor `F` with
`F Fᵀ = C_ρ / n`, and is horizontal. -/
theorem moderateNoise_spec {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    Smooth.normalizedTangentNoiseFactor U ρ * (Smooth.normalizedTangentNoiseFactor U ρ).transpose =
      (1 / (n : ℝ)) • filteredCovariance U ρ ∧
    filteredCovariance U ρ = Smooth.covariance U ρ ∧
    ∀ g, U.transpose * moderateNoise U ρ g = 0 := by
  sorry

/-- `lem:filter` (a).

TeX: "$0\preceq C_\rho\preceq I$, and $C_\rho=I$ on $\ker \Omega$." -/
theorem lem_filter_a {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    (∀ v : Fin n × Fin d → ℝ, 0 ≤ matrixQuadratic (filteredCovariance U ρ) v ∧
      matrixQuadratic (filteredCovariance U ρ) v ≤
        matrixQuadratic (horizontalProjectionMatrix U) v) ∧
    ∀ v : Fin n × Fin d → ℝ, horizontalProjectionMatrix U *ᵥ v = v →
      normalizedNormalCovariance U *ᵥ v = 0 → filteredCovariance U ρ *ᵥ v = v := by
  sorry

/-- `lem:filter` (b).

TeX: "$\Cov(\mathcal AZ)=n^{-1}D_p^{1/2}\,\rho S(I-S)(\rho I+S)^{-1}D_p^{1/2}\preceq
(\rho/n)D_p$."  (Quadratic-form encoding of the covariance.) -/
theorem lem_filter_b {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) (x : Fin n → ℝ) :
    ∫ g, (∑ i, x i * diagMap U (moderateNoise U ρ g) i) ^ 2 ∂gaussAmb n d =
      (1 / (n : ℝ)) * matrixQuadratic
        (Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i)) *
          (ρ • (normalizedFisher U * (1 - normalizedFisher U) *
            (ρ • 1 + normalizedFisher U)⁻¹)) *
          Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i))) x ∧
    (1 / (n : ℝ)) * matrixQuadratic
        (Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i)) *
          (ρ • (normalizedFisher U * (1 - normalizedFisher U) *
            (ρ • 1 + normalizedFisher U)⁻¹)) *
          Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i))) x ≤
      (ρ / n) * ∑ i, rowNormSq U i * x i ^ 2 := by
  sorry

/-- `lem:filter` (c).

TeX: "$I-C_\rho=\Omega+R_\rho$ with $R_\rho=\sum_{\mu>0}r_\mu\,Z_y\otimes Z_y$,
$r_\mu=\mu(1-\mu)/(\rho+\mu)\ge0$, and
\[ \sum_{\mu>0}r_\mu\le d,\qquad \sum_{\mu>0}\frac{r_\mu}{\sqrt\mu}\le\frac d{2\sqrt\rho},
 \qquad\sum_{\mu>0}\frac{r_\mu}\mu\le\frac d\rho . \]" -/
theorem lem_filter_c {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    horizontalProjectionMatrix U - filteredCovariance U ρ =
      normalizedNormalCovariance U + Smooth.modeSum U (Smooth.residualWeight ρ) ∧
    (∀ j ∈ highNormalizedModes U 0, Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) =
      normalizedFisherEigenvalue U j * (1 - normalizedFisherEigenvalue U j) /
        (ρ + normalizedFisherEigenvalue U j) ∧
      0 ≤ Smooth.residualWeight ρ (normalizedFisherEigenvalue U j)) ∧
    ∑ j ∈ highNormalizedModes U 0, Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) ≤
      (d : ℝ) ∧
    ∑ j ∈ highNormalizedModes U 0, Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
        Real.sqrt (normalizedFisherEigenvalue U j) ≤ (d : ℝ) / (2 * Real.sqrt ρ) ∧
    ∑ j ∈ highNormalizedModes U 0, Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
        normalizedFisherEigenvalue U j ≤ (d : ℝ) / ρ := by
  sorry

/-- Remark after `lem:filter` (properties of the rational filter).

TeX: "Only these properties of the filter $\phi(\mu)=\rho(1-\mu)/(\rho+\mu)$ are used:
$\phi(0)=1$ (so $C_\rho=I$ on $\ker \Omega$), $0\le\phi(\mu)\le1-\mu$,
$\mu\phi(\mu)\le\rho$, and the sums in (c)." -/
theorem rem_filter_rational {ρ μ : ℝ} (hρ : 0 < ρ) (hμ0 : 0 ≤ μ) (hμ1 : μ ≤ 1) :
    ρ * (1 - 0) / (ρ + 0) = 1 ∧ 0 ≤ ρ * (1 - μ) / (ρ + μ) ∧
    ρ * (1 - μ) / (ρ + μ) ≤ 1 - μ ∧ μ * (ρ * (1 - μ) / (ρ + μ)) ≤ ρ := by
  sorry

/-- Remark after `lem:filter` (the hard cutoff).

TeX: "The hard cutoff $(1-\mu)\one[\mu<\rho]$
satisfies them with $\sum r_\mu/\sqrt\mu\le d/\sqrt\rho$, which doubles some
constants below" (for the hard cutoff, `r_μ = 1 - μ - φ(μ) = (1-μ) 𝟙[μ ≥ ρ]`). -/
theorem rem_filter_hard {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    (∀ μ : ℝ, 0 ≤ μ → μ ≤ 1 →
      (if (0 : ℝ) < ρ then 1 - (0 : ℝ) else 0) = 1 ∧
      0 ≤ (if μ < ρ then 1 - μ else 0) ∧ (if μ < ρ then 1 - μ else 0) ≤ 1 - μ ∧
      μ * (if μ < ρ then 1 - μ else 0) ≤ ρ) ∧
    ∑ j ∈ highNormalizedModes U 0,
        (if normalizedFisherEigenvalue U j < ρ then 0 else 1 - normalizedFisherEigenvalue U j) /
          Real.sqrt (normalizedFisherEigenvalue U j) ≤ (d : ℝ) / Real.sqrt ρ := by
  sorry

/-! ## 5.2 Commutator identities -/

/-- `eq:q-cs` (with the polarisation identity stated just before it).

TeX: "q_i(Z)=\norm{Z^Tv_i}^2-\norm{Zu_i}^2,\qquad
 q_i(Z,M)=\ip{Z^Tv_i}{M^Tv_i}-\ip{Zu_i}{Mu_i},
so that $q(Z+M)=q(Z)+2q(Z,M)+q(M)$ and, by Cauchy--Schwarz,
\[ |q_i(Z,M)|\le\norm{(Y_Z)_i}\,\norm{(Y_M)_i},\qquad |q_i(M)|\le\norm{(Y_M)_i}^2 . \]"

(`q_i = horizontalQuadraticDiagonal`, `q_i(·,·) = Linear.horizontalQuadraticCross`.) -/
theorem eq_q_cs {n d : ℕ} (U H K : Frame n d) (hU : IsParseval U)
    (hUH : U.transpose * H = 0) (hUK : U.transpose * K = 0) (i : Fin n) :
    horizontalQuadraticDiagonal U (H + K) i = horizontalQuadraticDiagonal U H i +
      2 * Linear.horizontalQuadraticCross U H K i + horizontalQuadraticDiagonal U K i ∧
    |Linear.horizontalQuadraticCross U H K i| ≤
      Real.sqrt (rowNormSq (tangentY U H) i) * Real.sqrt (rowNormSq (tangentY U K) i) ∧
    |horizontalQuadraticDiagonal U K i| ≤ rowNormSq (tangentY U K) i := by
  sorry

/-- `lem:commutator` (a).

TeX: "Let $f\in\R^n$, $F=\Diag(f)$, and $R=I-2P$ (an orthogonal matrix). Then:
(a) $q(N_f)=\mathcal A\Gamma_f$ with $\Gamma_f=V^TFRFU$, and
$\fro{\Gamma_f}\le2\norm f_\infty\fro{N_f}$;"

(Ambient `V Γ_f = Linear.driftGamma U f = (I-P) F R F U`; `‖f‖_∞` is any bound `M`.) -/
theorem lem_commutator_a {n d : ℕ} (U : Frame n d) (hU : IsParseval U) (f : Fin n → ℝ)
    {M : ℝ} (hM : 0 ≤ M) (hf : ∀ i, |f i| ≤ M) :
    projectionReflection U * projectionReflection U = 1 ∧
    (projectionReflection U).transpose = projectionReflection U ∧
    Linear.driftGamma U f = frameComplementProjection U * Matrix.diagonal f *
      projectionReflection U * Matrix.diagonal f * U ∧
    (∀ i, horizontalQuadraticDiagonal U (ambientNormal U f) i =
      diagMap U (Linear.driftGamma U f) i) ∧
    Real.sqrt (frobSq (Linear.driftGamma U f)) ≤
      2 * M * Real.sqrt (frobSq (ambientNormal U f)) := by
  sorry

/-- `lem:commutator` (b).

TeX: "$T_f:=Y_{N_f}=FP+PF-2PFP$ satisfies
$[X,T_f]=RF[X,P]+[X,P]FR$ for diagonal $X$; hence
$\Lap(T_f)\preceq4\norm f_\infty^2L$, and
$x^T\Lap(T_{e_k})x\le2\sum_jP_{kj}^2(x_k-x_j)^2$." -/
theorem lem_commutator_b {n d : ℕ} (U : Frame n d) (hU : IsParseval U) (f : Fin n → ℝ)
    {M : ℝ} (hM : 0 ≤ M) (hf : ∀ i, |f i| ≤ M) :
    tangentY U (ambientNormal U f) = Matrix.diagonal f * frameProjection U +
      frameProjection U * Matrix.diagonal f -
        (2 : ℝ) • (frameProjection U * Matrix.diagonal f * frameProjection U) ∧
    (∀ x : Fin n → ℝ, diagonalCommutator x (tangentY U (ambientNormal U f)) =
      projectionReflection U * Matrix.diagonal f * diagonalCommutator x (frameProjection U) +
        diagonalCommutator x (frameProjection U) * Matrix.diagonal f * projectionReflection U) ∧
    (∀ x : Fin n → ℝ, matrixQuadratic (sqLaplacian (tangentY U (ambientNormal U f))) x ≤
      4 * M ^ 2 * matrixQuadratic (projectionLaplacian (frameProjection U)) x) ∧
    ∀ (k : Fin n) (x : Fin n → ℝ),
      matrixQuadratic (sqLaplacian (tangentY U (ambientNormal U (Pi.single k 1)))) x ≤
        2 * ∑ j, frameProjection U k j ^ 2 * (x k - x j) ^ 2 := by
  sorry

/-! ## 5.3 The second-order mean and the drift -/

/-- `b₀ = (1/n) L(p^{-1})`. -/
def baseBias {n d : ℕ} (U : Frame n d) (i : Fin n) : ℝ :=
  (1 / (n : ℝ)) * (projectionLaplacian (frameProjection U) *ᵥ fun j => (rowNormSq U j)⁻¹) i

/-- `m_* = (1/n) ∑_{μ>0} (r_μ/μ) Γ_{f_y}` (ambient), the library's `Linear.driftMean`. -/
abbrev driftMean {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Frame n d := Linear.driftMean U ρ

/-- `b_* := 𝒜 m_*`. -/
def residualBias {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Fin n → ℝ := diagMap U (driftMean U ρ)

/-- `lem:mean` (Mean).

TeX: "$\E q(Z)=a\one-p-b_0-b_*$ with $b_*:=\mathcal Am_*$, where
\[ b_0=\frac1nL(p^{-1}),\quad \norm{b_0}_\infty\le\frac{12\eps}n,\qquad
 m_*=\frac1n\sum_{\mu>0}\frac{r_\mu}\mu\,\Gamma_{f_y},\quad
 \fro{m_*}^2\le\frac{2a}\rho . \]" -/
theorem lem_mean {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ε : ℝ} (hε0 : 0 < ε)
    (hε : ε ≤ 1 / 2) (hnear : IsNearlyEqualNorm ε U) {ρ : ℝ} (hρ : 0 < ρ) :
    (∀ i, ∫ g, horizontalQuadraticDiagonal U (moderateNoise U ρ g) i ∂gaussAmb n d =
      (d : ℝ) / n - rowNormSq U i - baseBias U i - residualBias U ρ i) ∧
    (∀ i, |baseBias U i| ≤ 12 * ε / n) ∧
    driftMean U ρ = (1 / (n : ℝ)) • ∑ j ∈ highNormalizedModes U 0,
      (Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
        normalizedFisherEigenvalue U j) • Linear.driftGamma U (normalizedNormalPotential U j) ∧
    U.transpose * driftMean U ρ = 0 ∧
    frobSq (driftMean U ρ) ≤ 2 * ((d : ℝ) / n) / ρ := by
  sorry

/-- Proof of `lem:mean`: the unfiltered and base contributions.

TeX: "For $G\sim N(0,I)$ on $\mathcal Z$, $\E\norm{G^Tv_i}^2=d(1-p_i)$ and
$\E\norm{Gu_i}^2=(n-d)p_i$, so the unfiltered covariance $I/n$ contributes
$a\one-p$. The covariance $\Omega=\sum_j\zeta_j\otimes\zeta_j$, $\zeta_j=\bar{\mathcal
A}^*e_j=v_ju_j^T/\sqrt{p_j}$, contributes
\[ \frac1n\sum_jq_i(\zeta_j)=[\dots]=\frac1n(Lp^{-1})_i ,\]"

(Ambient unfiltered noise: factor `horizontalProjectionMatrix U`; `ζ_j` is the library's
`baseNormalDirection U j`.) -/
theorem lem_mean_unfiltered_base {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) (i : Fin n) :
    ∫ g, rowNormSq (frameOfVector (Matrix.toEuclideanLin (horizontalProjectionMatrix U) g)) i
        ∂gaussAmb n d = (d : ℝ) * (1 - rowNormSq U i) ∧
    ∫ g, rowNormSq (U * (frameOfVector
        (Matrix.toEuclideanLin (horizontalProjectionMatrix U) g)).transpose) i ∂gaussAmb n d =
      ((n : ℝ) - d) * rowNormSq U i ∧
    (1 / (n : ℝ)) * ∫ g, horizontalQuadraticDiagonal U (frameOfVector
        (Matrix.toEuclideanLin (horizontalProjectionMatrix U) g)) i ∂gaussAmb n d =
      (d : ℝ) / n - rowNormSq U i ∧
    (1 / (n : ℝ)) * ∑ j, horizontalQuadraticDiagonal U (baseNormalDirection U j) i =
      (1 / (n : ℝ)) * (projectionLaplacian (frameProjection U) *ᵥ
        fun j => (rowNormSq U j)⁻¹) i := by
  sorry

/-- Proof of `lem:mean`: the bound on `b₀`.

TeX: "Here $(Lp^{-1})_i=\sum_jP_{ij}^2(p_i^{-1}-p_j^{-1})$ and
$|p_i^{-1}-p_j^{-1}|\le2\eps a/((1-\eps)a)^2\le8\eps/a$, so
$|(Lp^{-1})_i|\le12\eps$." -/
theorem lem_mean_base_bound {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ε : ℝ}
    (hε0 : 0 < ε) (hε : ε ≤ 1 / 2) (hnear : IsNearlyEqualNorm ε U) (i j : Fin n) :
    |(rowNormSq U i)⁻¹ - (rowNormSq U j)⁻¹| ≤
      2 * ε * ((d : ℝ) / n) / ((1 - ε) * ((d : ℝ) / n)) ^ 2 ∧
    2 * ε * ((d : ℝ) / n) / ((1 - ε) * ((d : ℝ) / n)) ^ 2 ≤ 8 * ε / ((d : ℝ) / n) ∧
    |(projectionLaplacian (frameProjection U) *ᵥ fun j => (rowNormSq U j)⁻¹) i| ≤ 12 * ε := by
  sorry

/-- Proof of `lem:mean`: the residual contribution and the size of `m_*`.

TeX: "Finally $R_\rho/n$ contributes
$\frac1n\sum_\mu r_\mu q(Z_y)=\frac1n\sum_\mu\frac{r_\mu}\mu q(N_{f_y})=\mathcal
Am_*$ by \cref{lem:commutator}(a), and with $\fro{N_{f_y}}=\sqrt\mu$,
\eqref{eq:finfty} and \cref{lem:filter}(c),
\[ \fro{m_*}\le\frac2n\sqrt{\frac2a}\sum_{\mu>0}\frac{r_\mu}{\sqrt\mu}
 \le\frac2n\sqrt{\frac2a}\cdot\frac d{2\sqrt\rho}=\sqrt{\frac{2a}\rho}. \]" -/
theorem lem_mean_residual {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ : ℝ}
    (hρ : 0 < ρ) :
    (∀ i, (1 / (n : ℝ)) * ∑ j ∈ highNormalizedModes U 0,
        Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) *
          horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i = residualBias U ρ i) ∧
    (∀ j ∈ highNormalizedModes U 0, Real.sqrt (frobSq (ambientNormal U
      (normalizedNormalPotential U j))) = Real.sqrt (normalizedFisherEigenvalue U j)) ∧
    Real.sqrt (frobSq (driftMean U ρ)) ≤ 2 / n * Real.sqrt (2 / ((d : ℝ) / n)) *
      ∑ j ∈ highNormalizedModes U 0, Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
        Real.sqrt (normalizedFisherEigenvalue U j) ∧
    2 / n * Real.sqrt (2 / ((d : ℝ) / n)) * ((d : ℝ) / (2 * Real.sqrt ρ)) =
      Real.sqrt (2 * ((d : ℝ) / n) / ρ) := by
  sorry

/-- `rem:drift` (Why a drift): basis-free formula for `m_*`.

TeX: "(Since $m_*$ does not depend on the choice of eigenbasis, it can also be written
$m_*=\frac1nV^T\bigl[(D_p^{-1/2}(I-S)(\rho I+S)^{-1}D_p^{-1/2})\circ(I-2P)\bigr]U$.)"
(ambient: `V m_* = (1/n)(I-P)[…]U`; `D_p^{-1/2} = leverageNormalizer U`.) -/
theorem rem_drift_formula {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    driftMean U ρ = (1 / (n : ℝ)) • (frameComplementProjection U *
      Matrix.hadamard (leverageNormalizer U * (1 - normalizedFisher U) *
          (ρ • 1 + normalizedFisher U)⁻¹ * leverageNormalizer U)
        (projectionReflection U) * U) := by
  sorry

/-- `rem:drift`: the size of the drift.

TeX: "$t^2b_*$ is exactly the \emph{first-order} diagonal change produced
by the deterministic horizontal direction $\frac t2m_*$, whose norm is
$\frac t2\fro{m_*}\le\sqrt{a/2}/D$." (with `ρ = D²t²`) -/
theorem rem_drift_size {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {D t : ℝ}
    (hD : 0 < D) (ht : 0 < t) :
    (∀ i, t ^ 2 * residualBias U (D ^ 2 * t ^ 2) i =
      2 * t * diagMap U ((t / 2) • driftMean U (D ^ 2 * t ^ 2)) i) ∧
    t / 2 * Real.sqrt (frobSq (driftMean U (D ^ 2 * t ^ 2))) ≤
      Real.sqrt (((d : ℝ) / n) / 2) / D := by
  sorry

/-! ## 5.4 The expected graph -/

/-- The unfiltered ambient noise `Z₀ ∼ N(0, I/n)` on the horizontal space. -/
def unfilteredNoise {n d : ℕ} (U : Frame n d) (g : FrameVector n d) : Frame n d :=
  frameOfVector (Matrix.toEuclideanLin ((Real.sqrt (n : ℝ))⁻¹ • horizontalProjectionMatrix U) g)

/-- `lem:expected-graph`.

TeX: "$\displaystyle\E\Lap(Y)\succeq\frac a{4n}\mathsf K-\Bigl(\frac2n+\frac8d+\frac8\rho\Bigr)L$."
-/
theorem lem_expected_graph {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ : ℝ}
    (hρ : 0 < ρ) (x : Fin n → ℝ) :
    (d : ℝ) / n / (4 * n) * matrixQuadratic (completeLaplacian n) x -
        (2 / n + 8 / d + 8 / ρ) * matrixQuadratic (projectionLaplacian (frameProjection U)) x ≤
      ∫ g, matrixQuadratic (sqLaplacian (tangentY U (moderateNoise U ρ g))) x ∂gaussAmb n d := by
  sorry

/-- Proof of `lem:expected-graph`, unfiltered noise.

TeX: "For $Z_0\sim N(0,I/n)$ and $i\ne j$,
$(Y_{Z_0})_{ij}=v_i^TZ_0u_j+v_j^TZ_0u_i$ has variance
$n^{-1}\fro{v_iu_j^T+v_ju_i^T}^2=n^{-1}(p_i+p_j-2p_ip_j-2P_{ij}^2)$. As
$p\le\frac34$, $p_i+p_j-2p_ip_j\ge\frac14(p_i+p_j)\ge\frac a4$, so
$\E\Lap(Y_{Z_0})\succeq\frac a{4n}\mathsf K-\frac2nL$." -/
theorem lem_expected_graph_unfiltered {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) :
    (∀ i j, i ≠ j → ∫ g, tangentY U (unfilteredNoise U g) i j ^ 2 ∂gaussAmb n d =
      (1 / (n : ℝ)) * (rowNormSq U i + rowNormSq U j - 2 * rowNormSq U i * rowNormSq U j -
        2 * frameProjection U i j ^ 2)) ∧
    (∀ i j, (1 / 4) * (rowNormSq U i + rowNormSq U j) ≤
        rowNormSq U i + rowNormSq U j - 2 * rowNormSq U i * rowNormSq U j ∧
      (d : ℝ) / n / 4 ≤ (1 / 4) * (rowNormSq U i + rowNormSq U j)) ∧
    ∀ x : Fin n → ℝ,
      (d : ℝ) / n / (4 * n) * matrixQuadratic (completeLaplacian n) x -
          (2 / n) * matrixQuadratic (projectionLaplacian (frameProjection U)) x ≤
        ∫ g, matrixQuadratic (sqLaplacian (tangentY U (unfilteredNoise U g))) x ∂gaussAmb n d := by
  sorry

/-- Proof of `lem:expected-graph`, base and residual losses.

TeX: "\emph{Base loss.} $Y_{\zeta_k}=T_{e_k}/\sqrt{p_k}$, so by
\cref{lem:commutator}(b) and $p_k\ge a/2$,
$\sum_kx^T\Lap(Y_{\zeta_k})x\le\frac2a\cdot2\sum_{k,j}P_{kj}^2(x_k-x_j)^2
=\frac8a\,x^TLx$; the base part $\Omega/n$ therefore removes at most $\frac8dL$.
\emph{Residual loss.} $\Lap(Y_{Z_y})=\mu^{-1}\Lap(T_{f_y})\preceq\frac8{a\mu}L$ by
\cref{lem:commutator}(b) and \eqref{eq:finfty}, so $R_\rho/n$ removes at most
$\frac8{an}\sum_\mu\frac{r_\mu}\mu L\le\frac8\rho L$." -/
theorem lem_expected_graph_losses {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U)
    {ρ : ℝ} (hρ : 0 < ρ) (x : Fin n → ℝ) :
    (∀ k, tangentY U (baseNormalDirection U k) =
      (Real.sqrt (rowNormSq U k))⁻¹ • tangentY U (ambientNormal U (Pi.single k 1))) ∧
    ∑ k, matrixQuadratic (sqLaplacian (tangentY U (baseNormalDirection U k))) x ≤
      2 / ((d : ℝ) / n) * (2 * ∑ k, ∑ j, frameProjection U k j ^ 2 * (x k - x j) ^ 2) ∧
    2 / ((d : ℝ) / n) * (2 * ∑ k, ∑ j, frameProjection U k j ^ 2 * (x k - x j) ^ 2) =
      8 / ((d : ℝ) / n) * matrixQuadratic (projectionLaplacian (frameProjection U)) x ∧
    (1 / (n : ℝ)) * (8 / ((d : ℝ) / n)) = 8 / d ∧
    (∀ j ∈ highNormalizedModes U 0,
      matrixQuadratic (sqLaplacian (tangentY U (normalizedNormalFrame U j))) x ≤
        8 / ((d : ℝ) / n * normalizedFisherEigenvalue U j) *
          matrixQuadratic (projectionLaplacian (frameProjection U)) x) ∧
    8 / ((d : ℝ) / n * n) * ∑ j ∈ highNormalizedModes U 0,
        Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) / normalizedFisherEigenvalue U j ≤
      8 / ρ := by
  sorry

/-- Remark after `thm:moderate` (quantitative claim).

TeX: "since $\ip x{b_*}^2\le\frac{2a}\rho x^TLx$ this is possible" -/
theorem rem_after_moderate {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ : ℝ}
    (hρ : 0 < ρ) (x : Fin n → ℝ) :
    (∑ i, x i * residualBias U ρ i) ^ 2 ≤
      2 * ((d : ℝ) / n) / ρ * matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  sorry

end

end Paulsen.Paper
