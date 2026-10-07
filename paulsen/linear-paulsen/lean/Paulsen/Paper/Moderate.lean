import Paulsen.Paper.Gaussian
import Paulsen.Linear.DriftAlgebra
import Paulsen.ResolventRationalCovariance
import Paulsen.ResolventDrift
import Paulsen.Paper.ResolventTangent
import Paulsen.Paper.ModerateAuxMisc

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
* `r_μ = Resolvent.residualWeight ρ μ`, `R_ρ = Resolvent.modeSum U (Resolvent.residualWeight ρ)`;
* the filtered noise `Z ∼ N(0, C_ρ/n)` is `moderateNoise U ρ g = Resolvent.moderateNoiseFrame U ρ g`
  with `g ∼ stdGaussian (FrameVector n d)`.

All statements are proved. Generic helper lemmas live in namespace `Paulsen.Paper.ModerateAux`
(here and in `Paulsen.Paper.ModerateAux*`: `Lap` edge Laplacians, `Lin` row bounds and
`Ω ⪯ I`, `Filter` rational calculus of the filter, `Drift` the basis-free formula for `m_*`,
`Gauss` Gaussian second moments and the expected graph, `Misc` polarisation and
Cauchy–Schwarz). `lem_mean` and `lem_expected_graph` are placed after their proof-step lemmas,
from which they are derived.
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

namespace ModerateAux

variable {n d : ℕ} {U : Frame n d}

theorem standing_n_pos (hs : ModerateStanding U) : 0 < n := by
  have := hs.pos; have := hs.density; omega

theorem standing_nR_pos (hs : ModerateStanding U) : (0 : ℝ) < n :=
  Nat.cast_pos.mpr (standing_n_pos hs)

theorem standing_dR_pos (hs : ModerateStanding U) : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos

theorem standing_a_pos (hs : ModerateStanding U) : 0 < (d : ℝ) / n :=
  div_pos (standing_dR_pos hs) (standing_nR_pos hs)

theorem standing_a_le_half (hs : ModerateStanding U) : (d : ℝ) / n ≤ 1 / 2 := by
  have hn := standing_nR_pos hs
  rw [div_le_iff₀ hn]
  have : (2 * d : ℝ) ≤ n := by exact_mod_cast hs.density
  linarith

theorem standing_p_pos (hs : ModerateStanding U) (i : Fin n) : 0 < rowNormSq U i :=
  lt_of_lt_of_le (by have := standing_a_pos hs; positivity) (hs.rows i).1

end ModerateAux

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

namespace ModerateAux

theorem mq_sqLaplacian {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    matrixQuadratic (sqLaplacian M) x =
      ∑ i, ∑ j, if i < j then M i j ^ 2 * (x i - x j) ^ 2 else 0 :=
  mq_edgeLap (fun i j => M i j ^ 2) x

theorem mq_sqLaplacian_half {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ)
    (hM : ∀ i j, M i j ^ 2 = M j i ^ 2) (x : Fin n → ℝ) :
    matrixQuadratic (sqLaplacian M) x = (1 / 2) * ∑ i, ∑ j, M i j ^ 2 * (x i - x j) ^ 2 := by
  rw [mq_sqLaplacian, sum_lt_eq_half (fun i j => M i j ^ 2 * (x i - x j) ^ 2)
    (fun i j => by rw [hM i j]; ring) (fun i => by simp)]

theorem mq_sqLaplacian_eq_graphEnergy {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ)
    (hM : ∀ i j, M i j ^ 2 = M j i ^ 2) (x : Fin n → ℝ) :
    matrixQuadratic (sqLaplacian M) x = graphEnergy (Matrix.of fun i j => M i j ^ 2) x := by
  rw [mq_sqLaplacian_half M hM]; simp [graphEnergy]

theorem mq_sqLaplacian_nonneg {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    0 ≤ matrixQuadratic (sqLaplacian M) x := by
  rw [mq_sqLaplacian]
  apply Finset.sum_nonneg; intro i _; apply Finset.sum_nonneg; intro j _
  split_ifs <;> positivity

theorem sqLaplacian_transpose {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) :
    (sqLaplacian M).transpose = sqLaplacian M := by
  simp only [sqLaplacian, Matrix.transpose_sum]
  apply Finset.sum_congr rfl; intro i _; apply Finset.sum_congr rfl; intro j _
  split_ifs
  · rw [Matrix.transpose_smul, Matrix.transpose_vecMulVec]
  · simp

theorem graphEnergy_one_eq {n : ℕ} (x : Fin n → ℝ) :
    graphEnergy (Matrix.of fun _ _ => (1 : ℝ)) x = matrixQuadratic (completeLaplacian n) x := by
  have h : completeLaplacian n = graphLaplacian (Matrix.of fun _ _ : Fin n => (1 : ℝ)) := by
    ext i j
    simp [completeLaplacian, graphLaplacian, Matrix.diagonal_apply, Matrix.one_apply]
  rw [h, graphLaplacian_quadratic _ (fun i j => rfl)]

theorem mq_sqLaplacian_smul {n : ℕ} (c : ℝ) (M : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    matrixQuadratic (sqLaplacian (c • M)) x = c ^ 2 * matrixQuadratic (sqLaplacian M) x := by
  rw [mq_sqLaplacian, mq_sqLaplacian, Finset.mul_sum]
  apply Finset.sum_congr rfl; intro i _
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl; intro j _
  split_ifs
  · simp only [Matrix.smul_apply, smul_eq_mul]; ring
  · simp

end ModerateAux

/-- Facts stated with the definition of `𝓛` (unnumbered).

TeX: "thus $L=\Lap(P)$, $x^T\Lap(M)x=\frac12\fro{[\Diag x,M]}^2$" (for symmetric `M`), and
(Section 5.5) "$\Lap(P+tY)=L+t\mathcal C(Y)+t^2\Lap(Y)$". -/
theorem lap_facts {n d : ℕ} (U : Frame n d) (hU : IsParseval U) :
    sqLaplacian (frameProjection U) = projectionLaplacian (frameProjection U) ∧
    (∀ (M : Matrix (Fin n) (Fin n) ℝ), M.transpose = M → ∀ x,
      matrixQuadratic (sqLaplacian M) x = (1 / 2) * frobSq (diagonalCommutator x M)) ∧
    ∀ (P Y : Matrix (Fin n) (Fin n) ℝ) (t : ℝ),
      sqLaplacian (P + t • Y) = sqLaplacian P + t • crossLaplacian P Y + t ^ 2 • sqLaplacian Y := by
  refine ⟨?_, ?_, ?_⟩
  · apply ModerateAux.eq_of_quadratic_eq _ _ (ModerateAux.sqLaplacian_transpose _)
    · ext a b
      simp only [projectionLaplacian, Matrix.transpose_apply, Matrix.sub_apply,
        Matrix.diagonal_apply, Matrix.of_apply, frameProjection_symm U a b]
      by_cases hab : a = b
      · subst hab; rfl
      · simp [hab, Ne.symm hab]
    · intro x
      rw [ModerateAux.mq_sqLaplacian_half _ (fun i j => by rw [frameProjection_symm U i j]),
        hU.laplacian_energy]
  · intro M hM x
    rw [ModerateAux.mq_sqLaplacian_half M (fun i j => by
      rw [show M i j = M.transpose j i from rfl, hM])]
    simp only [frobSq, diagonalCommutator, Matrix.sub_apply, Matrix.diagonal_mul,
      Matrix.mul_diagonal]
    congr 1
    apply Finset.sum_congr rfl; intro i _; apply Finset.sum_congr rfl; intro j _; ring
  · intro P Y t
    simp only [sqLaplacian, crossLaplacian, Finset.smul_sum, ← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl; intro i _; apply Finset.sum_congr rfl; intro j _
    split_ifs
    · simp only [Matrix.add_apply, Matrix.smul_apply, smul_eq_mul, smul_smul, ← add_smul]
      congr 1; ring
    · simp

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
  have hsym : ∀ i j, M i j = M j i := fun i j => by
    rw [show M i j = M.transpose j i from rfl, hM]
  constructor
  · intro c hc x
    rw [ModerateAux.mq_sqLaplacian_half M (fun i j => by rw [hsym i j])]
    have hterm : ∀ i j, M i j ^ 2 * (x i - x j) ^ 2 ≤
        2 * (M i j ^ 2 * x i ^ 2) + 2 * (M j i ^ 2 * x j ^ 2) := by
      intro i j
      rw [← hsym i j]
      nlinarith [mul_nonneg (sq_nonneg (M i j)) (sq_nonneg (x i + x j))]
    have hrow : ∑ i, ∑ j, M i j ^ 2 * x i ^ 2 = ∑ i, x i ^ 2 * rowNormSq M i := by
      apply Finset.sum_congr rfl; intro i _
      rw [rowNormSq, Finset.mul_sum]
      apply Finset.sum_congr rfl; intro j _; ring
    have hsum := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
      Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hterm i j))
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum] at hsum
    rw [Finset.sum_comm (f := fun i j => M j i ^ 2 * x j ^ 2), hrow] at hsum
    have hc' : ∑ i, x i ^ 2 * rowNormSq M i ≤ c * vectorNormSq x := by
      rw [vectorNormSq, Finset.mul_sum]
      apply Finset.sum_le_sum; intro i _
      nlinarith [hc i, sq_nonneg (x i)]
    linarith
  · intro x
    rw [ModerateAux.mq_sqLaplacian, ModerateAux.mq_sqLaplacian, ModerateAux.mq_sqLaplacian,
      Finset.mul_sum, ← Finset.sum_sub_distrib]
    apply Finset.sum_le_sum; intro i _
    rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
    apply Finset.sum_le_sum; intro j _
    split_ifs
    · simp only [Matrix.add_apply]
      nlinarith [mul_nonneg (sq_nonneg (M i j + 2 * M' i j)) (sq_nonneg (x i - x j))]
    · simp

/-! ## 5.1 The horizontal tangent space and the filtered covariance -/

/-- `Y_Z = VZUᵀ + UZᵀVᵀ`, in ambient coordinates `Y_H = H Uᵀ + U Hᵀ`. -/
def tangentY {n d : ℕ} (U H : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  H * U.transpose + U * H.transpose

/-- `(𝒜Z)_i = v_iᵀ Z u_i = (VZUᵀ)_{ii}`, in ambient coordinates `(H Uᵀ)_{ii}`. -/
def diagMap {n d : ℕ} (U H : Frame n d) : Fin n → ℝ := fun i => (H * U.transpose) i i

namespace ModerateAux

theorem tangentY_apply_symm {n d : ℕ} (U H : Frame n d) (i j : Fin n) :
    tangentY U H i j = tangentY U H j i := by
  simp only [tangentY, Matrix.add_apply, Matrix.mul_apply, Matrix.transpose_apply]
  rw [add_comm]
  congr 1 <;> apply Finset.sum_congr rfl <;> intro k _ <;> ring

theorem tangentY_sq_symm {n d : ℕ} (U H : Frame n d) (i j : Fin n) :
    tangentY U H i j ^ 2 = tangentY U H j i ^ 2 := by rw [tangentY_apply_symm]

theorem mq_sqLaplacian_tangentY {n d : ℕ} (U H : Frame n d) (x : Fin n → ℝ) :
    matrixQuadratic (sqLaplacian (tangentY U H)) x =
      graphEnergy (Matrix.of fun i j => ((H * U.transpose + U * H.transpose) i j) ^ 2) x :=
  mq_sqLaplacian_eq_graphEnergy _ (tangentY_sq_symm U H) x

theorem tangentY_smul {n d : ℕ} (U H : Frame n d) (c : ℝ) :
    tangentY U (c • H) = c • tangentY U H := by
  simp only [tangentY, Matrix.smul_mul, Matrix.transpose_smul, Matrix.mul_smul, smul_add]

end ModerateAux

/-- Facts on `Y_Z` (Section 5.1, displayed, unnumbered).

TeX: "Y_Z=VZU^T+UZ^TV^T,\qquad \norm{(Y_Z)_i}^2=\norm{Z^Tv_i}^2+\norm{Zu_i}^2\le\opn Z^2,
 \qquad \fro{Y_Z}^2=2\fro Z^2 ." -/
theorem tangentY_facts {n d : ℕ} (U H : Frame n d) (hU : IsParseval U)
    (hUH : U.transpose * H = 0) :
    (∀ i, rowNormSq (tangentY U H) i = rowNormSq H i + rowNormSq (U * H.transpose) i) ∧
    (∀ i, rowNormSq (tangentY U H) i ≤ opNorm H ^ 2) ∧
    frobSq (tangentY U H) = 2 * frobSq H := by
  have hrow : ∀ i, rowNormSq (tangentY U H) i = rowNormSq H i + rowNormSq (U * H.transpose) i :=
    fun i => Linear.rowNormSq_tangent_horizontal hU hUH i
  refine ⟨hrow, ?_, ?_⟩
  · intro i
    rw [hrow i]
    have h1 := ModerateAux.rowNormSq_horizontal_le hU hUH i
    have h2 := ModerateAux.rowNormSq_mul_transpose_le_opNorm U H i
    unfold opNorm
    nlinarith
  · rw [ModerateAux.frobSq_eq_nfv, ModerateAux.frobSq_eq_nfv]
    exact horizontal_tangent_frobenius_sq hU hUH

/-- Facts on `𝒜` (Section 5.1, unnumbered).

TeX: "$\mathcal A^*x=N_x:=V^T\Diag(x)U$. Then $\mathcal A\mathcal A^*=L$, i.e.\
$\fro{N_x}^2=x^TLx$" (adjointness: `⟨𝒜H, x⟩ = ⟨H, N_x⟩_F` for horizontal `H`). -/
theorem diagMap_adjoint {n d : ℕ} (U H : Frame n d) (hU : IsParseval U)
    (hUH : U.transpose * H = 0) (x : Fin n → ℝ) :
    ∑ i, x i * diagMap U H i = ∑ i, ∑ k, H i k * ambientNormal U x i k ∧
    frobSq (ambientNormal U x) = matrixQuadratic (projectionLaplacian (frameProjection U)) x ∧
    U.transpose * ambientNormal U x = 0 := by
  refine ⟨ModerateAux.diag_pairing_eq hUH x, ?_, ?_⟩
  · rw [ModerateAux.frobSq_eq_nfv]; exact ambientNormal_norm_sq hU x
  · rw [← ambientNormal_horizontal hU x, ← Matrix.mul_assoc,
      hU.transpose_mul_frameComplementProjection, Matrix.zero_mul]

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
  have htr : (1 - normalizedFisher U).trace = ∑ i, frameProjection U i i ^ 2 / rowNormSq U i := by
    rw [ModerateAux.one_sub_normalizedFisher hU hp, Matrix.trace]
    apply Finset.sum_congr rfl; intro i _
    simp only [normalizedOverlap, leverageNormalizer, Matrix.diag_apply, Matrix.mul_diagonal,
      Matrix.diagonal_mul, Matrix.of_apply]
    have hs := Real.sq_sqrt (hp i).le
    have hn := (Real.sqrt_pos.mpr (hp i)).ne'
    field_simp
    rw [hs]
    field_simp [(hp i).ne']
  refine ⟨?_, fun x => ⟨ModerateAux.mq_nonneg_of_posSemidef _ (normalizedFisher_posSemidef U) x,
    ModerateAux.normalizedFisher_quadratic_le hU hp x⟩,
    fun v => ⟨ModerateAux.mq_nonneg_of_posSemidef _
      (ModerateAux.normalizedNormalCovariance_posSemidef' U) v,
      ModerateAux.normalizedNormalCovariance_quadratic_le hU hp v⟩, htr, ?_⟩
  · have h := ModerateAux.one_sub_normalizedFisher hU hp
    unfold normalizedOverlap at h
    rw [← h]
    abel
  · rw [← htr, ModerateAux.one_sub_normalizedFisher hU hp, normalizedOverlap_trace hU hp]

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
  refine ⟨?_, ?_, fun j _ => normalizedNormalFrame_eq U j, ?_⟩
  · intro j _
    have hc : normalizedNormalCovariance U * normalizedNormalMapMatrix U =
        normalizedNormalMapMatrix U * normalizedFisher U := by
      simp [normalizedNormalCovariance, normalizedFisher, Matrix.mul_assoc]
    apply WithLp.ofLp_injective
    simp only [normalizedNormalDirection, map_smul, WithLp.ofLp_smul, Matrix.toLpLin_apply,
      Matrix.mulVec_mulVec, hc]
    rw [← Matrix.mulVec_mulVec]
    change (Real.sqrt (normalizedFisherEigenvalue U j))⁻¹ • (normalizedNormalMapMatrix U *ᵥ
      (normalizedFisher U *ᵥ (normalizedFisherEigenvector U j).ofLp)) = _
    rw [ModerateAux.fisher_mulVec_eigvec, Matrix.mulVec_smul, smul_comm]
  · intro j hj j' hj'
    exact normalizedNormalDirection_inner U j j' (Finset.mem_filter.mp hj).2
      (Finset.mem_filter.mp hj').2
  · intro v _ horth
    rw [normalizedNormalCovariance_decomposition, Matrix.sum_mulVec]
    apply Finset.sum_eq_zero
    intro i _
    rw [Matrix.smul_mulVec, normalDirectionOuter, Matrix.vecMulVec_mulVec]
    by_cases hi : 0 < normalizedFisherEigenvalue U i
    · have h0 := horth i (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hi⟩)
      rw [EuclideanSpace.inner_eq_star_dotProduct] at h0
      simp only [star_trivial] at h0
      rw [h0]
      simp
    · have hz : normalizedFisherEigenvalue U i = 0 :=
        le_antisymm (not_lt.mp hi) (normalizedFisherEigenvalue_nonneg U i)
      rw [hz, zero_smul]

/-- `eq:finfty`.

TeX: "Since $p_i\ge a/2$, \[ \norm{f_y}_\infty\le\sqrt{2/a}. \]" -/
theorem eq_finfty {n d : ℕ} (U : Frame n d) (hd : 0 < d) (hn : 0 < n)
    (hp : ∀ i, (d : ℝ) / n / 2 ≤ rowNormSq U i) (j i : Fin n) :
    |normalizedNormalPotential U j i| ≤ Real.sqrt (2 / ((d : ℝ) / n)) := by
  have ha : 0 < (d : ℝ) / n / 2 := by
    have : (0 : ℝ) < d := Nat.cast_pos.mpr hd
    have : (0 : ℝ) < n := Nat.cast_pos.mpr hn
    positivity
  have h := normalizedNormalPotential_abs_le U j i ha (hp i)
  rwa [← Real.sqrt_inv, inv_div] at h

/-- Definition (Filtered covariance).

TeX: "For $\rho>0$ let $C_\rho=\rho(\rho I+\Omega)^{-1}$ on $\mathcal Z$, let
$Z\sim N(0,C_\rho/n)$, and $Y=Y_Z$."

In ambient coordinates the identity of `𝒵` is the horizontal projection. -/
def filteredCovariance {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  ρ • (horizontalProjectionMatrix U *
    (ρ • 1 + normalizedNormalCovariance U)⁻¹)

/-- The filtered Gaussian noise `Z ∼ N(0, C_ρ/n)`, as the ambient horizontal frame `H = VZ`. -/
abbrev moderateNoise {n d : ℕ} (U : Frame n d) (ρ : ℝ) (g : FrameVector n d) : Frame n d :=
  Resolvent.moderateNoiseFrame U ρ g

/-- Faithfulness of the filtered noise (bridge to the library): the library noise
`Resolvent.moderateNoiseFrame U ρ g = frameOfVector (F g)` has factor `F` with
`F Fᵀ = C_ρ / n`, and is horizontal. -/
theorem moderateNoise_spec {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    Resolvent.normalizedTangentNoiseFactor U ρ * (Resolvent.normalizedTangentNoiseFactor U ρ).transpose =
      (1 / (n : ℝ)) • filteredCovariance U ρ ∧
    filteredCovariance U ρ = Resolvent.covariance U ρ ∧
    ∀ g, U.transpose * moderateNoise U ρ g = 0 := by
  have hC : filteredCovariance U ρ = Resolvent.covariance U ρ :=
    (Resolvent.covariance_rational_formula hU hp hρ).symm
  refine ⟨?_, hC, fun g => ModerateAux.moderateNoiseFrame_horizontal' hU ρ g⟩
  rw [Resolvent.normalizedTangentNoiseFactor_covariance hU hρ.le, hC]

/-- `lem:filter` (a).

TeX: "$0\preceq C_\rho\preceq I$, and $C_\rho=I$ on $\ker \Omega$." -/
theorem lem_filter_a {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    (∀ v : Fin n × Fin d → ℝ, 0 ≤ matrixQuadratic (filteredCovariance U ρ) v ∧
      matrixQuadratic (filteredCovariance U ρ) v ≤
        matrixQuadratic (horizontalProjectionMatrix U) v) ∧
    ∀ v : Fin n × Fin d → ℝ, horizontalProjectionMatrix U *ᵥ v = v →
      normalizedNormalCovariance U *ᵥ v = 0 → filteredCovariance U ρ *ᵥ v = v := by
  have hC : filteredCovariance U ρ = Resolvent.covariance U ρ :=
    (Resolvent.covariance_rational_formula hU hp hρ).symm
  constructor
  · intro v
    rw [hC]
    refine ⟨ModerateAux.mq_nonneg_of_posSemidef _ (Resolvent.covariance_posSemidef hU hρ.le) v, ?_⟩
    have h := ModerateAux.mq_nonneg_of_posSemidef _ (Resolvent.covariance_le_horizontal U hρ.le) v
    rw [matrixQuadratic_sub] at h
    linarith
  · intro v hv hΩ
    have hA : (ρ • (1 : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) +
        normalizedNormalCovariance U)⁻¹ * (ρ • 1 + normalizedNormalCovariance U) = 1 :=
      Matrix.nonsing_inv_mul _ (ModerateAux.resolventZ_isUnit U hρ)
    have hAv : (ρ • (1 : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) +
        normalizedNormalCovariance U) *ᵥ v = ρ • v := by
      simp only [Matrix.add_mulVec, Matrix.smul_mulVec, Matrix.one_mulVec, hΩ, add_zero]
    have hAinv : (ρ • (1 : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) +
        normalizedNormalCovariance U)⁻¹ *ᵥ v = ρ⁻¹ • v := by
      have h1 := congrArg (fun w => (ρ • (1 : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) +
        normalizedNormalCovariance U)⁻¹ *ᵥ w) hAv
      simp only [Matrix.mulVec_mulVec, hA, Matrix.one_mulVec, Matrix.mulVec_smul] at h1
      calc _ = ρ⁻¹ • (ρ • (ρ • (1 : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) +
            normalizedNormalCovariance U)⁻¹ *ᵥ v) := by
            rw [smul_smul, inv_mul_cancel₀ hρ.ne', one_smul]
        _ = ρ⁻¹ • v := by rw [← h1]
    unfold filteredCovariance
    rw [Matrix.smul_mulVec, ← Matrix.mulVec_mulVec, hAinv, Matrix.mulVec_smul,
      hv, smul_smul, mul_inv_cancel₀ hρ.ne', one_smul]

/-- `lem:filter` (b).

TeX: "$\Cov(\mathcal AZ)=n^{-1}D_p^{1/2}\,\rho S(\rho I+S)^{-1}D_p^{1/2}\preceq
(\rho/n)D_p$."  (Quadratic-form encoding of the covariance.) -/
theorem lem_filter_b {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) (x : Fin n → ℝ) :
    ∫ g, (∑ i, x i * diagMap U (moderateNoise U ρ g) i) ^ 2 ∂gaussAmb n d =
      (1 / (n : ℝ)) * matrixQuadratic
        (Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i)) *
          (ρ • (normalizedFisher U *
            (ρ • 1 + normalizedFisher U)⁻¹)) *
          Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i))) x ∧
    (1 / (n : ℝ)) * matrixQuadratic
        (Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i)) *
          (ρ • (normalizedFisher U *
            (ρ • 1 + normalizedFisher U)⁻¹)) *
          Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i))) x ≤
      (ρ / n) * ∑ i, rowNormSq U i * x i ^ 2 := by
  refine ⟨ModerateAux.integral_diag_pairing_sq hU hp hρ x, ?_⟩
  set Dh := Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i))
  set M := ρ • (normalizedFisher U * (ρ • 1 + normalizedFisher U)⁻¹)
  have hq : matrixQuadratic (Dh * M * Dh) x = matrixQuadratic M (Dh *ᵥ x) := by
    rw [ModerateAux.mq_eq_dot, ModerateAux.mq_eq_dot, ModerateAux.dot_mulVec_transpose,
      Matrix.diagonal_transpose]
    simp only [Matrix.mulVec_mulVec, Matrix.mul_assoc, Dh]
  have hb := ModerateAux.rational_quadratic_le U hρ (Dh *ᵥ x)
  have hsum : ∑ i, (Dh *ᵥ x) i ^ 2 = ∑ i, rowNormSq U i * x i ^ 2 := by
    apply Finset.sum_congr rfl; intro i _
    simp only [Dh, Matrix.mulVec_diagonal, mul_pow, Real.sq_sqrt (hp i).le]
  rw [hq, ← hsum]
  calc 1 / (n : ℝ) * matrixQuadratic M (Dh *ᵥ x) ≤ 1 / (n : ℝ) * (ρ * ∑ i, (Dh *ᵥ x) i ^ 2) :=
        mul_le_mul_of_nonneg_left hb (by positivity)
    _ = _ := by ring

/-- `lem:filter` (c).

TeX: "$I-C_\rho=\alpha\Omega+R_\rho$, $\alpha=(1+\rho)^{-1}$ with $R_\rho=\sum_{\mu>0}r_\mu\,Z_y\otimes Z_y$,
$r_\mu=\alpha\mu(1-\mu)/(\rho+\mu)\ge0$, and
\[ \sum_{\mu>0}r_\mu\le d,\qquad \sum_{\mu>0}\frac{r_\mu}{\sqrt\mu}\le\frac d{2\sqrt\rho}. \]" -/
theorem lem_filter_c {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    horizontalProjectionMatrix U - filteredCovariance U ρ =
      Resolvent.baseWeight ρ • normalizedNormalCovariance U + Resolvent.modeSum U (Resolvent.residualWeight ρ) ∧
    (∀ j ∈ highNormalizedModes U 0, Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) =
      Resolvent.baseWeight ρ * (normalizedFisherEigenvalue U j * (1 - normalizedFisherEigenvalue U j) /
        (ρ + normalizedFisherEigenvalue U j)) ∧
      0 ≤ Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j)) ∧
    ∑ j ∈ highNormalizedModes U 0, Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) ≤
      (d : ℝ) ∧
    ∑ j ∈ highNormalizedModes U 0, Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) /
        Real.sqrt (normalizedFisherEigenvalue U j) ≤ (d : ℝ) / (2 * Real.sqrt ρ) := by
  have hC : filteredCovariance U ρ = Resolvent.covariance U ρ :=
    (Resolvent.covariance_rational_formula hU hp hρ).symm
  have hdef : ∑ j ∈ highNormalizedModes U 0, (1 - normalizedFisherEigenvalue U j) ≤ (d : ℝ) :=
    normalizedPositiveResidualMass_le hU hp 0
  refine ⟨by rw [hC]; exact Resolvent.residual_decomposition hU hp hρ.le, ?_, ?_,
    Resolvent.residual_inverse_sqrt_sum_le hU hp hρ⟩
  · intro j _
    exact ⟨rfl, Resolvent.residualWeight_nonneg hρ.le (normalizedFisherEigenvalue_nonneg U j)
      (normalizedFisherEigenvalue_le_one hU hp j)⟩
  · calc _ ≤ ∑ j ∈ highNormalizedModes U 0, (1 - normalizedFisherEigenvalue U j) :=
          Finset.sum_le_sum (fun j _ => Resolvent.residualWeight_le_deficit hρ.le
            (normalizedFisherEigenvalue_nonneg U j) (normalizedFisherEigenvalue_le_one hU hp j))
      _ ≤ _ := hdef

/-- Elementary properties of the ordinary resolvent weight `φ(μ)=ρ/(ρ+μ)`.
The residual trace bounds, rather than a hard cutoff, control the drift. -/
theorem rem_filter_rational {ρ μ : ℝ} (hρ : 0 < ρ) (hμ0 : 0 ≤ μ) (_hμ1 : μ ≤ 1) :
    ρ / (ρ + 0) = 1 ∧ 0 ≤ ρ / (ρ + μ) ∧
    ρ / (ρ + μ) ≤ 1 ∧ μ * (ρ / (ρ + μ)) ≤ ρ := by
  refine ⟨by simp [hρ.ne'], Resolvent.retainedWeight_nonneg hρ.le hμ0,
    Resolvent.retainedWeight_le_one hρ.le hμ0, ?_⟩
  simpa only [mul_comm, Resolvent.retainedWeight] using Resolvent.retainedWeight_mul_le hρ.le hμ0

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
  have e1 : rowNormSq (tangentY U H) i = rowNormSq H i + rowNormSq (U * H.transpose) i :=
    Linear.rowNormSq_tangent_horizontal hU hUH i
  have e2 : rowNormSq (tangentY U K) i = rowNormSq K i + rowNormSq (U * K.transpose) i :=
    Linear.rowNormSq_tangent_horizontal hU hUK i
  rw [e1, e2]
  refine ⟨Linear.horizontalQuadraticDiagonal_add U H K i, ?_,
    Linear.horizontalQuadraticDiagonal_abs_le U K i⟩
  exact ModerateAux.abs_sub_sum_mul_le (fun k => H i k) (fun k => K i k)
    (fun k => (U * H.transpose) i k) (fun k => (U * K.transpose) i k)

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
  refine ⟨?_, projectionReflection_transpose U, rfl,
    fun i => Linear.horizontalQuadraticDiagonal_ambientNormal hU f i, ?_⟩
  · have h := projectionReflection_parseval hU
    unfold IsParseval at h
    rwa [projectionReflection_transpose] at h
  · rw [ModerateAux.sqrt_frobSq_eq, ModerateAux.sqrt_frobSq_eq]
    exact Linear.driftGamma_norm_le hU f hM hf

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
  refine ⟨ambientNormalTangent_eq U f, fun x => ambientNormalTangent_commutator U x f, ?_, ?_⟩
  · intro x
    rw [ModerateAux.mq_sqLaplacian_tangentY]
    exact ambientNormalTangent_graphEnergy_le hU x f hM hf
  · intro k x
    rw [ModerateAux.mq_sqLaplacian_tangentY]
    have h := diagonalCommutator_frob_sq x (ambientNormalTangent U (Pi.single k 1))
    have h2 := ModerateAux.tangent_single_commutator_sq_le hU k x
    change graphEnergy (Matrix.of fun i j => (ambientNormalTangent U (Pi.single k 1) i j) ^ 2) x ≤ _
    linarith

/-! ## 5.3 The second-order mean and the drift -/

/-- `b₀ = (α/n) L(p^{-1})`, with `α=(1+ρ)⁻¹`. -/
def baseBias {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) : ℝ :=
  (Resolvent.baseWeight ρ / (n : ℝ)) * (projectionLaplacian (frameProjection U) *ᵥ fun j => (rowNormSq U j)⁻¹) i

/-- `m_* = (1/n) ∑_{μ>0} (r_μ/μ) Γ_{f_y}` (ambient), the resolvent's `Resolvent.driftMean`. -/
abbrev driftMean {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Frame n d := Resolvent.driftMean U ρ

/-- `b_* := 𝒜 m_*`. -/
def residualBias {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Fin n → ℝ := diagMap U (driftMean U ρ)

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
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr (Fin.pos i)
  have hIZ : ∀ (r : Fin n) (j : Fin d) (q : Fin n) (b : Fin d),
      horizontalProjectionMatrix U (r, j) (q, b) =
        frameComplementProjection U r q * (if j = b then 1 else 0) := by
    intro r j q b
    simp [horizontalProjectionMatrix, Matrix.kronecker, Matrix.kroneckerMap_apply,
      Matrix.one_apply]
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [integral_rowNormSq_gaussianImage_eq_columns]
    calc ∑ j : Fin d, ∑ k : Fin n × Fin d, horizontalProjectionMatrix U (i, j) k ^ 2
        = ∑ _j : Fin d, (1 - rowNormSq U i) := by
          apply Finset.sum_congr rfl; intro j _
          rw [Fintype.sum_prod_type, ← frameComplementProjection_row_squares hU i]
          apply Finset.sum_congr rfl; intro q _
          simp only [hIZ, mul_ite, mul_one, mul_zero, ite_pow]
          simp
      _ = _ := by simp; ring
  · simp_rw [← horizontalRightFactor_apply]
    rw [integral_rowNormSq_gaussianImage_eq_columns]
    have hent : ∀ (j : Fin n) (q : Fin n) (b : Fin d),
        horizontalRightFactor U (horizontalProjectionMatrix U) (i, j) (q, b) =
          U i b * frameComplementProjection U j q := by
      intro j q b
      simp only [horizontalRightFactor, Matrix.of_apply, hIZ, mul_ite, mul_one, mul_zero]
      rw [Finset.sum_ite_eq']; simp only [Finset.mem_univ, if_true]
    calc ∑ j : Fin n, ∑ k : Fin n × Fin d,
          horizontalRightFactor U (horizontalProjectionMatrix U) (i, j) k ^ 2
        = ∑ j : Fin n, rowNormSq U i * (1 - rowNormSq U j) := by
          apply Finset.sum_congr rfl; intro j _
          rw [Fintype.sum_prod_type, ← frameComplementProjection_row_squares hU j, rowNormSq,
            Finset.sum_mul_sum]
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl; intro q _
          apply Finset.sum_congr rfl; intro b _
          rw [hent]; ring
      _ = _ := by
          rw [← Finset.mul_sum, Finset.sum_sub_distrib, ModerateAux.sum_rowNormSq_eq hU]
          simp; ring
  · rw [integral_horizontalQuadraticDiagonal_eq_covariance, horizontalProjectionMatrix_transpose,
      horizontalProjectionMatrix_idempotent hU, normalQuadraticCovariance_horizontalProjection hU]
    field_simp
  · rw [horizontalQuadraticDiagonal_base_sum_eq_laplacian hU hp i]

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
  set a := (d : ℝ) / n with ha_def
  have ha : 0 < a := ModerateAux.standing_a_pos hs
  have h1ε : 0 < 1 - ε := by linarith
  have hlow : ∀ k, (1 - ε) * a ≤ rowNormSq U k := fun k => (hnear k).1
  have hupp : ∀ k, rowNormSq U k ≤ (1 + ε) * a := fun k => (hnear k).2
  have hpos : ∀ k, 0 < rowNormSq U k := fun k => lt_of_lt_of_le (by positivity) (hlow k)
  have hdiff : ∀ k l, |(rowNormSq U k)⁻¹ - (rowNormSq U l)⁻¹| ≤
      2 * ε * a / ((1 - ε) * a) ^ 2 := by
    intro k l
    rw [_root_.inv_sub_inv (hpos k).ne' (hpos l).ne', abs_div,
      abs_of_pos (mul_pos (hpos k) (hpos l))]
    apply div_le_div₀ (by positivity)
    · rw [abs_le]; constructor <;> nlinarith [hlow k, hlow l, hupp k, hupp l]
    · positivity
    · rw [sq]; exact mul_le_mul (hlow k) (hlow l) (by positivity) (hpos k).le
  have hstep : 2 * ε * a / ((1 - ε) * a) ^ 2 ≤ 8 * ε / a := by
    rw [div_le_div_iff₀ (by positivity) ha]
    have : (1 : ℝ) / 4 ≤ (1 - ε) ^ 2 := by nlinarith
    have hεa : 0 ≤ ε * a ^ 2 := by positivity
    nlinarith [mul_le_mul_of_nonneg_left this hεa]
  refine ⟨hdiff i j, hstep, ?_⟩
  have hL := ((lem_energy U hs.parseval).1 (fun j => (rowNormSq U j)⁻¹) i)
  rw [hL, weightedLaplacian]
  have hw : ∀ k, |(if i = k then 0 else frameProjection U i k ^ 2) *
      ((rowNormSq U i)⁻¹ - (rowNormSq U k)⁻¹)| ≤ frameProjection U i k ^ 2 * (8 * ε / a) := by
    intro k
    rw [abs_mul]
    have h0 : |(if i = k then (0 : ℝ) else frameProjection U i k ^ 2)| ≤
        frameProjection U i k ^ 2 := by
      split_ifs <;> simp [sq_nonneg]
    exact mul_le_mul h0 ((hdiff i k).trans hstep) (abs_nonneg _) (sq_nonneg _)
  calc |∑ k, (if i = k then 0 else frameProjection U i k ^ 2) *
        ((rowNormSq U i)⁻¹ - (rowNormSq U k)⁻¹)|
      ≤ ∑ k, frameProjection U i k ^ 2 * (8 * ε / a) :=
        (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun k _ => hw k)
    _ = rowNormSq U i * (8 * ε / a) := by
        rw [← Finset.sum_mul, hs.parseval.projection_row_squares i]
    _ ≤ (3 * a / 2) * (8 * ε / a) :=
        mul_le_mul_of_nonneg_right (hs.rows i).2 (by positivity)
    _ = 12 * ε := by field_simp; ring

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
        Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) *
          horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i = residualBias U ρ i) ∧
    (∀ j ∈ highNormalizedModes U 0, Real.sqrt (frobSq (ambientNormal U
      (normalizedNormalPotential U j))) = Real.sqrt (normalizedFisherEigenvalue U j)) ∧
    Real.sqrt (frobSq (driftMean U ρ)) ≤ 2 / n * Real.sqrt (2 / ((d : ℝ) / n)) *
      ∑ j ∈ highNormalizedModes U 0, Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) /
        Real.sqrt (normalizedFisherEigenvalue U j) ∧
    2 / n * Real.sqrt (2 / ((d : ℝ) / n)) * ((d : ℝ) / (2 * Real.sqrt ρ)) =
      Real.sqrt (2 * ((d : ℝ) / n) / ρ) := by
  have hU := hs.parseval
  have ha := ModerateAux.standing_a_pos hs
  have hnR := ModerateAux.standing_nR_pos hs
  have hdR := ModerateAux.standing_dR_pos hs
  have hM : ∀ j i, |normalizedNormalPotential U j i| ≤ Real.sqrt (2 / ((d : ℝ) / n)) :=
    fun j i => eq_finfty U hs.pos (ModerateAux.standing_n_pos hs) (fun i => (hs.rows i).1) j i
  have hNf : ∀ j ∈ highNormalizedModes U 0, Real.sqrt (frobSq (ambientNormal U
      (normalizedNormalPotential U j))) = Real.sqrt (normalizedFisherEigenvalue U j) := by
    intro j _
    rw [ModerateAux.sqrt_frobSq_eq, normalizedNormalPotential_image_norm]
  refine ⟨fun i => (Resolvent.driftMean_diagonal hU ρ i).symm, hNf, ?_, ?_⟩
  · have hterm : ∀ j ∈ highNormalizedModes U 0,
        ‖normalFrobVector ((Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) /
          normalizedFisherEigenvalue U j) • Linear.driftGamma U (normalizedNormalPotential U j))‖ ≤
        2 * Real.sqrt (2 / ((d : ℝ) / n)) *
          (Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) /
            Real.sqrt (normalizedFisherEigenvalue U j)) := by
      intro j hj
      have hμ : 0 < normalizedFisherEigenvalue U j := (Finset.mem_filter.mp hj).2
      have hsμ : 0 < Real.sqrt (normalizedFisherEigenvalue U j) := Real.sqrt_pos.mpr hμ
      have hw := Resolvent.residualWeight_nonneg hρ.le (normalizedFisherEigenvalue_nonneg U j)
        (normalizedFisherEigenvalue_le_one hU (ModerateAux.standing_p_pos hs) j)
      rw [Linear.normalFrobVector_smul', norm_smul, Real.norm_eq_abs,
        abs_of_nonneg (div_nonneg hw hμ.le)]
      have hg := (lem_commutator_a U hU (normalizedNormalPotential U j) (Real.sqrt_nonneg _)
        (hM j)).2.2.2.2
      rw [ModerateAux.sqrt_frobSq_eq, hNf j hj] at hg
      have key : Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) /
          normalizedFisherEigenvalue U j * Real.sqrt (normalizedFisherEigenvalue U j) =
          Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) /
            Real.sqrt (normalizedFisherEigenvalue U j) := by
        rw [div_mul_eq_mul_div, div_eq_div_iff hμ.ne' hsμ.ne', mul_assoc,
          Real.mul_self_sqrt hμ.le]
      calc _ ≤ Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) /
            normalizedFisherEigenvalue U j *
            (2 * Real.sqrt (2 / ((d : ℝ) / n)) * Real.sqrt (normalizedFisherEigenvalue U j)) :=
            mul_le_mul_of_nonneg_left hg (div_nonneg hw hμ.le)
        _ = _ := by rw [← key]; ring
    rw [ModerateAux.sqrt_frobSq_eq]
    unfold driftMean Resolvent.driftMean
    rw [Linear.normalFrobVector_smul', norm_smul, Linear.normalFrobVector_sum', Real.norm_eq_abs,
      abs_of_nonneg (by positivity)]
    calc 1 / (n : ℝ) * ‖∑ j ∈ highNormalizedModes U 0, normalFrobVector
          ((Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) /
            normalizedFisherEigenvalue U j) • Linear.driftGamma U (normalizedNormalPotential U j))‖
        ≤ 1 / (n : ℝ) * ∑ j ∈ highNormalizedModes U 0, 2 * Real.sqrt (2 / ((d : ℝ) / n)) *
          (Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) /
            Real.sqrt (normalizedFisherEigenvalue U j)) :=
          mul_le_mul_of_nonneg_left ((norm_sum_le _ _).trans (Finset.sum_le_sum hterm))
            (by positivity)
      _ = _ := by rw [← Finset.mul_sum]; ring
  · have hsρ : 0 < Real.sqrt ρ := Real.sqrt_pos.mpr hρ
    have e1 : Real.sqrt (2 / ((d : ℝ) / n)) * Real.sqrt (2 / ((d : ℝ) / n)) = 2 / ((d : ℝ) / n) :=
      Real.mul_self_sqrt (by positivity)
    have e2 : Real.sqrt ρ * Real.sqrt ρ = ρ := Real.mul_self_sqrt hρ.le
    rw [eq_comm, Real.sqrt_eq_iff_mul_self_eq (by positivity) (by positivity)]
    have e3 : 2 / (n : ℝ) * Real.sqrt (2 / ((d : ℝ) / n)) * ((d : ℝ) / (2 * Real.sqrt ρ)) =
        ((d : ℝ) / n) * Real.sqrt (2 / ((d : ℝ) / n)) / Real.sqrt ρ := by
      field_simp
    rw [e3, show ((d : ℝ) / n) * Real.sqrt (2 / ((d : ℝ) / n)) / Real.sqrt ρ *
        (((d : ℝ) / n) * Real.sqrt (2 / ((d : ℝ) / n)) / Real.sqrt ρ) =
        ((d : ℝ) / n) ^ 2 * (Real.sqrt (2 / ((d : ℝ) / n)) * Real.sqrt (2 / ((d : ℝ) / n))) /
          (Real.sqrt ρ * Real.sqrt ρ) by ring, e1, e2]
    field_simp

namespace ModerateAux

/-- `‖m_*‖_F ≤ √(2a/ρ)`, from the proof of `lem:mean` (`lem_mean_residual` and
`lem:filter`(c)). -/
theorem sqrt_frobSq_driftMean_le {n d : ℕ} {U : Frame n d} (hs : ModerateStanding U) {ρ : ℝ}
    (hρ : 0 < ρ) :
    Real.sqrt (frobSq (driftMean U ρ)) ≤ Real.sqrt (2 * ((d : ℝ) / n) / ρ) := by
  have h := lem_mean_residual U hs hρ
  have hc := (lem_filter_c U hs.parseval (standing_p_pos hs) hρ).2.2.2
  rw [← h.2.2.2]
  exact h.2.2.1.trans (mul_le_mul_of_nonneg_left hc (by positivity))

theorem frobSq_driftMean_le {n d : ℕ} {U : Frame n d} (hs : ModerateStanding U) {ρ : ℝ}
    (hρ : 0 < ρ) : frobSq (driftMean U ρ) ≤ 2 * ((d : ℝ) / n) / ρ := by
  have h := sqrt_frobSq_driftMean_le hs hρ
  have ha := standing_a_pos hs
  rwa [Real.sqrt_le_sqrt_iff (by positivity)] at h

end ModerateAux

/-- `lem:mean` (Mean).

TeX: "$\E q(Z)=a\one-p-b_0-b_*$ with $b_*:=\mathcal Am_*$, where
\[ b_0=\frac\alpha nL(p^{-1}),\quad \norm{b_0}_\infty\le\frac{12\eps}n,\qquad
 m_*=\frac1n\sum_{\mu>0}\frac{r_\mu}\mu\,\Gamma_{f_y},\quad
 \fro{m_*}^2\le\frac{2a}\rho . \]" -/
theorem lem_mean {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ε : ℝ} (hε0 : 0 < ε)
    (hε : ε ≤ 1 / 2) (hnear : IsNearlyEqualNorm ε U) {ρ : ℝ} (hρ : 0 < ρ) :
    (∀ i, ∫ g, horizontalQuadraticDiagonal U (moderateNoise U ρ g) i ∂gaussAmb n d =
      (d : ℝ) / n - rowNormSq U i - baseBias U ρ i - residualBias U ρ i) ∧
    (∀ i, |baseBias U ρ i| ≤ 12 * ε / n) ∧
    driftMean U ρ = (1 / (n : ℝ)) • ∑ j ∈ highNormalizedModes U 0,
      (Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) /
        normalizedFisherEigenvalue U j) • Linear.driftGamma U (normalizedNormalPotential U j) ∧
    U.transpose * driftMean U ρ = 0 ∧
    frobSq (driftMean U ρ) ≤ 2 * ((d : ℝ) / n) / ρ := by
  have hU := hs.parseval
  have hn := ModerateAux.standing_n_pos hs
  have hp := ModerateAux.standing_p_pos hs
  refine ⟨?_, ?_, rfl, Resolvent.driftMean_horizontal hU ρ, ?_⟩
  · intro i
    -- `E q(Z) = n⁻¹ Q(C_ρ)` with `Q` linear in the covariance and `C_ρ = I - αΩ - R_ρ`
    obtain ⟨-, -, hunf, hbase⟩ := lem_mean_unfiltered_base U hU hp i
    have hres := (lem_mean_residual U hs hρ).1 i
    have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
    have hQI : (1 / (n : ℝ)) * normalQuadraticCovariance U i (horizontalProjectionMatrix U) =
        (d : ℝ) / n - rowNormSq U i := by
      rw [← hunf, integral_horizontalQuadraticDiagonal_eq_covariance,
        horizontalProjectionMatrix_transpose, horizontalProjectionMatrix_idempotent hU]
    have hQB : normalQuadraticCovariance U i (normalizedNormalCovariance U) =
        ∑ j, horizontalQuadraticDiagonal U (baseNormalDirection U j) i := by
      rw [normalizedNormalCovariance_base_decomposition, map_sum]
      simp only [normalQuadraticCovariance_outer]
    have hQR : normalQuadraticCovariance U i (Resolvent.modeSum U (Resolvent.residualWeight ρ)) =
        ∑ j ∈ highNormalizedModes U 0, Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) *
          horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i := by
      simp only [Resolvent.modeSum, map_sum, map_smul, smul_eq_mul,
        normalQuadraticCovariance_normalDirectionOuter]
    have hcov : Resolvent.covariance U ρ = horizontalProjectionMatrix U -
        Resolvent.baseWeight ρ • normalizedNormalCovariance U - Resolvent.modeSum U (Resolvent.residualWeight ρ) := by
      have hh := Resolvent.residual_decomposition hU hp hρ.le
      rw [sub_sub, ← hh]; abel
    change ∫ g, horizontalQuadraticDiagonal U (frameOfVector
      (Matrix.toEuclideanLin (Resolvent.normalizedTangentNoiseFactor U ρ) g)) i
        ∂stdGaussian (FrameVector n d) = _
    rw [integral_horizontalQuadraticDiagonal_eq_covariance,
      Resolvent.normalizedTangentNoiseFactor_covariance hU hρ.le, map_smul, hcov, map_sub, map_sub, map_smul,
      smul_eq_mul, mul_sub, mul_sub, hQI, hQB, hQR, ← hres, baseBias]
    simp only [smul_eq_mul]
    linear_combination -(Resolvent.baseWeight ρ) * hbase
  · intro i
    have h := (lem_mean_base_bound U hs hε0 hε hnear i i).2.2
    rw [baseBias, abs_mul, abs_of_nonneg (div_nonneg (Resolvent.baseWeight_nonneg hρ.le) (Nat.cast_nonneg n))]
    calc Resolvent.baseWeight ρ / (n : ℝ) * |(projectionLaplacian (frameProjection U) *ᵥ
          fun j => (rowNormSq U j)⁻¹) i| ≤ Resolvent.baseWeight ρ / (n : ℝ) * (12 * ε) :=
          mul_le_mul_of_nonneg_left h (by exact div_nonneg (Resolvent.baseWeight_nonneg hρ.le) (Nat.cast_nonneg n))
      _ ≤ 1 / (n : ℝ) * (12 * ε) := by
          gcongr
          exact Resolvent.baseWeight_le_one hρ.le
      _ = 12 * ε / n := by ring
  · exact ModerateAux.frobSq_driftMean_le hs hρ

/-- `rem:drift` (Why a drift): basis-free formula for `m_*`.

TeX: "(Since $m_*$ does not depend on the choice of eigenbasis, it can also be written
$m_*=\frac\alpha nV^T\bigl[(D_p^{-1/2}(I-S)(\rho I+S)^{-1}D_p^{-1/2})\circ(I-2P)\bigr]U$.)"
(ambient: `V m_* = (1/n)(I-P)[…]U`; `D_p^{-1/2} = leverageNormalizer U`.) -/
theorem rem_drift_formula {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    driftMean U ρ = (Resolvent.baseWeight ρ / (n : ℝ)) • (frameComplementProjection U *
      Matrix.hadamard (leverageNormalizer U * (1 - normalizedFisher U) *
          (ρ • 1 + normalizedFisher U)⁻¹ * leverageNormalizer U)
        (projectionReflection U) * U) :=
  by
    rw [driftMean, Resolvent.driftMean_eq_baseWeight_smul, ModerateAux.driftMean_formula U hρ, smul_smul]
    congr 1
    ring

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
  constructor
  · intro i
    simp only [residualBias, diagMap, Matrix.smul_mul, Matrix.smul_apply, smul_eq_mul]
    ring
  · have ha := ModerateAux.standing_a_pos hs
    have h := ModerateAux.sqrt_frobSq_driftMean_le hs (show 0 < D ^ 2 * t ^ 2 by positivity)
    have e : 2 * ((d : ℝ) / n) / (D ^ 2 * t ^ 2) = (((d : ℝ) / n) / 2) * (2 / (D * t)) ^ 2 := by
      field_simp
    rw [e, Real.sqrt_mul (by positivity), Real.sqrt_sq (by positivity)] at h
    calc t / 2 * Real.sqrt (frobSq (driftMean U (D ^ 2 * t ^ 2)))
        ≤ t / 2 * (Real.sqrt (((d : ℝ) / n) / 2) * (2 / (D * t))) :=
          mul_le_mul_of_nonneg_left h (by positivity)
      _ = _ := by field_simp

/-! ## 5.4 The expected graph -/

/-- The unfiltered ambient noise `Z₀ ∼ N(0, I/n)` on the horizontal space. -/
def unfilteredNoise {n d : ℕ} (U : Frame n d) (g : FrameVector n d) : Frame n d :=
  frameOfVector (Matrix.toEuclideanLin ((Real.sqrt (n : ℝ))⁻¹ • horizontalProjectionMatrix U) g)

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
  have hU := hs.parseval
  have ha := ModerateAux.standing_a_pos hs
  have ha2 := ModerateAux.standing_a_le_half hs
  have hnR := ModerateAux.standing_nR_pos hs
  have hp34 : ∀ i, rowNormSq U i ≤ 3 / 4 := fun i => by nlinarith [(hs.rows i).2]
  have hscal : ∀ i j, (1 / 4) * (rowNormSq U i + rowNormSq U j) ≤
        rowNormSq U i + rowNormSq U j - 2 * rowNormSq U i * rowNormSq U j ∧
      (d : ℝ) / n / 4 ≤ (1 / 4) * (rowNormSq U i + rowNormSq U j) := by
    intro i j
    have hi := (hs.rows i).1
    have hj := (hs.rows j).1
    have h0i := rowNormSq_nonneg U i
    have h0j := rowNormSq_nonneg U j
    constructor
    · nlinarith [mul_nonneg h0i (sub_nonneg.mpr (hp34 j)), mul_nonneg h0j (sub_nonneg.mpr (hp34 i))]
    · linarith
  have hunf : ∀ g, unfilteredNoise U g = ModerateAux.unfilteredFrame U g := fun g => rfl
  refine ⟨?_, hscal, ?_⟩
  · intro i j hij
    have h := ModerateAux.integral_unfiltered_entry_sq U hU i j hij
    calc _ = _ := h
      _ = _ := by ring
  · intro x
    simp only [ModerateAux.mq_sqLaplacian_tangentY, hunf]
    rw [ModerateAux.integral_unfiltered_graph U hU x, unconditionedTangent_graphEnergy_formula]
    have hentry : ∀ i j, (((d : ℝ) / n / (4 * n)) • (Matrix.of fun _ _ : Fin n => (1 : ℝ)) -
        (2 / (n : ℝ)) • (Matrix.of fun i j => frameProjection U i j ^ 2)) i j ≤
        (Matrix.of fun i j => (rowNormSq U i + rowNormSq U j - 2 * rowNormSq U i * rowNormSq U j -
          2 * (frameProjection U i j) ^ 2) / (n : ℝ)) i j := by
      intro i j
      have h := (hscal i j).1.trans' (hscal i j).2
      simp only [Matrix.sub_apply, Matrix.smul_apply, Matrix.of_apply, smul_eq_mul, mul_one]
      have : (d : ℝ) / n / (4 * n) - 2 / n * frameProjection U i j ^ 2 =
          ((d : ℝ) / n / 4 - 2 * frameProjection U i j ^ 2) / n := by
        field_simp
      rw [this]
      exact div_le_div_of_nonneg_right (by linarith) hnR.le
    have hg := graphEnergy_pointwise_le _ _ hentry x
    rw [graphEnergy_sub_eq, graphEnergy_smul_eq, graphEnergy_smul_eq,
      ModerateAux.graphEnergy_one_eq] at hg
    have hL : graphEnergy (Matrix.of fun i j => frameProjection U i j ^ 2) x =
        matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
      rw [hU.laplacian_energy]; simp [graphEnergy]
    rw [hL] at hg
    exact hg

/-- Base covariance graph bound used by the expected-graph proof.
The resolvent comparison `I-Cρ ⪯ Ω/ρ` turns this one base bound into the full loss bound. -/
theorem lem_expected_graph_losses {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U)
    {ρ : ℝ} (hρ : 0 < ρ) (x : Fin n → ℝ) :
    (∀ k, tangentY U (baseNormalDirection U k) =
      (Real.sqrt (rowNormSq U k))⁻¹ • tangentY U (ambientNormal U (Pi.single k 1))) ∧
    ∑ k, matrixQuadratic (sqLaplacian (tangentY U (baseNormalDirection U k))) x ≤
      2 / ((d : ℝ) / n) * (2 * ∑ k, ∑ j, frameProjection U k j ^ 2 * (x k - x j) ^ 2) ∧
    2 / ((d : ℝ) / n) * (2 * ∑ k, ∑ j, frameProjection U k j ^ 2 * (x k - x j) ^ 2) =
      8 / ((d : ℝ) / n) * matrixQuadratic (projectionLaplacian (frameProjection U)) x ∧
    (1 / (n : ℝ)) * (8 / ((d : ℝ) / n)) = 8 / d := by
  have hU := hs.parseval
  have ha := ModerateAux.standing_a_pos hs
  have hnR := ModerateAux.standing_nR_pos hs
  have hdR := ModerateAux.standing_dR_pos hs
  have hp := ModerateAux.standing_p_pos hs
  have hzeta : ∀ k, baseNormalDirection U k =
      (Real.sqrt (rowNormSq U k))⁻¹ • ambientNormal U (Pi.single k 1) := by
    intro k
    ext i l
    rw [ambientNormal, Matrix.mul_assoc, Matrix.smul_apply, Matrix.mul_apply]
    simp only [Matrix.diagonal_mul, Pi.single_apply, ite_mul, one_mul, zero_mul, mul_ite,
      mul_zero, Finset.sum_ite_eq', Finset.mem_univ, if_true,
      baseNormalDirection, Matrix.of_apply, smul_eq_mul]
    ring
  have hi : ∀ k, tangentY U (baseNormalDirection U k) =
      (Real.sqrt (rowNormSq U k))⁻¹ • tangentY U (ambientNormal U (Pi.single k 1)) :=
    fun k => by rw [hzeta k, ModerateAux.tangentY_smul]
  have hsingle : ∀ k i, |(Pi.single k (1 : ℝ) : Fin n → ℝ) i| ≤ 1 := by
    intro k i; rw [Pi.single_apply]; split_ifs <;> simp
  have hbase : ∀ k, matrixQuadratic (sqLaplacian (tangentY U (baseNormalDirection U k))) x ≤
      2 / ((d : ℝ) / n) * (2 * ∑ j, frameProjection U k j ^ 2 * (x k - x j) ^ 2) := by
    intro k
    rw [hi k, ModerateAux.mq_sqLaplacian_smul, inv_pow, Real.sq_sqrt (hp k).le]
    have hb := (lem_commutator_b U hU (Pi.single k 1) zero_le_one (hsingle k)).2.2.2 k x
    have hm := ModerateAux.mq_sqLaplacian_nonneg (tangentY U (ambientNormal U (Pi.single k 1))) x
    have hpk : (rowNormSq U k)⁻¹ ≤ 2 / ((d : ℝ) / n) := by
      rw [inv_le_comm₀ (hp k) (by positivity), inv_div]
      linarith [(hs.rows k).1]
    calc (rowNormSq U k)⁻¹ * matrixQuadratic (sqLaplacian
          (tangentY U (ambientNormal U (Pi.single k 1)))) x
        ≤ 2 / ((d : ℝ) / n) * matrixQuadratic (sqLaplacian
          (tangentY U (ambientNormal U (Pi.single k 1)))) x :=
          mul_le_mul_of_nonneg_right hpk hm
      _ ≤ _ := mul_le_mul_of_nonneg_left hb (by positivity)
  refine ⟨hi, ?_, ?_, ?_⟩
  · calc _ ≤ ∑ k, 2 / ((d : ℝ) / n) * (2 * ∑ j, frameProjection U k j ^ 2 * (x k - x j) ^ 2) :=
          Finset.sum_le_sum (fun k _ => hbase k)
      _ = _ := by rw [← Finset.mul_sum, ← Finset.mul_sum]
  · rw [hU.laplacian_energy]; ring
  · field_simp
/-- `lem:expected-graph`.

TeX: "$\displaystyle\E\Lap(Y)\succeq\frac a{4n}\mathsf K-\Bigl(\frac2n+\frac8{d\rho}\Bigr)L$."
-/
theorem lem_expected_graph {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ : ℝ}
    (hρ : 0 < ρ) (x : Fin n → ℝ) :
    (d : ℝ) / n / (4 * n) * matrixQuadratic (completeLaplacian n) x -
        (2 / n + 8 / (d * ρ)) * matrixQuadratic (projectionLaplacian (frameProjection U)) x ≤
      ∫ g, matrixQuadratic (sqLaplacian (tangentY U (moderateNoise U ρ g))) x ∂gaussAmb n d := by
  have hU := hs.parseval
  have hnR := ModerateAux.standing_nR_pos hs
  have hdR := ModerateAux.standing_dR_pos hs
  have hf : ∫ g, matrixQuadratic (sqLaplacian (tangentY U (moderateNoise U ρ g))) x
      ∂gaussAmb n d = (1 / (n : ℝ)) * tangentCovarianceGraph U x (Resolvent.covariance U ρ) := by
    simp only [ModerateAux.mq_sqLaplacian_tangentY]
    have hY : ∀ g, (moderateNoise U ρ g * U.transpose +
        U * (moderateNoise U ρ g).transpose) =
        gaussianMatrixImage (Resolvent.retainedTangentFactor U ρ) g :=
      fun g => (Resolvent.moderateNoiseFrame_tangent U ρ g).symm
    simp_rw [hY]
    exact Resolvent.integral_retainedTangent_graphEnergy_eq hU hρ.le x
  have hu : ∫ g, matrixQuadratic (sqLaplacian (tangentY U (unfilteredNoise U g))) x
      ∂gaussAmb n d = (1 / (n : ℝ)) * tangentCovarianceGraph U x (horizontalProjectionMatrix U) := by
    simp only [ModerateAux.mq_sqLaplacian_tangentY]
    exact ModerateAux.integral_unfiltered_graph U hU x
  have hb : tangentCovarianceGraph U x (normalizedNormalCovariance U) =
      ∑ k, matrixQuadratic (sqLaplacian (tangentY U (baseNormalDirection U k))) x := by
    rw [normalizedNormalCovariance_base_decomposition, map_sum]
    simp only [ModerateAux.tcg_outer, ModerateAux.mq_sqLaplacian_tangentY]
  have hcmp := tangentCovarianceGraph_nonneg U x _ (Resolvent.covariance_loss_le_normal U hρ)
  simp only [map_sub, map_smul, smul_eq_mul] at hcmp
  have hscaled := mul_nonneg (show (0 : ℝ) ≤ 1 / n by positivity) hcmp
  have hbase := lem_expected_graph_losses U hs hρ x
  have hbase' : (1 / (n : ℝ)) * tangentCovarianceGraph U x (normalizedNormalCovariance U) ≤
      8 / d * matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
    rw [hb]
    calc _ ≤ (1 / (n : ℝ)) * (8 / ((d : ℝ) / n) *
          matrixQuadratic (projectionLaplacian (frameProjection U)) x) :=
          mul_le_mul_of_nonneg_left (hbase.2.1.trans_eq hbase.2.2.1) (by positivity)
      _ = _ := by rw [← mul_assoc, hbase.2.2.2]
  have hbound := mul_le_mul_of_nonneg_left hbase' (show 0 ≤ 1 / ρ by positivity)
  have hcoef : (1 / ρ) * (8 / (d : ℝ)) = 8 / (d * ρ) := by ring
  simp only [← mul_assoc] at hbound
  rw [hcoef] at hbound
  have hexpand := (lem_expected_graph_unfiltered U hs).2.2 x
  rw [hu] at hexpand
  rw [hf]
  nlinarith only [hscaled, hbound, hexpand]

/-- Remark after `thm:moderate` (quantitative claim).

TeX: "since $\ip x{b_*}^2\le\frac{2a}\rho x^TLx$ this is possible" -/
theorem rem_after_moderate {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {ρ : ℝ}
    (hρ : 0 < ρ) (x : Fin n → ℝ) :
    (∑ i, x i * residualBias U ρ i) ^ 2 ≤
      2 * ((d : ℝ) / n) / ρ * matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  have hU := hs.parseval
  have hm := Resolvent.driftMean_horizontal hU ρ
  obtain ⟨h1, h2, -⟩ := diagMap_adjoint U (driftMean U ρ) hU hm x
  have hfro := ModerateAux.frobSq_driftMean_le hs hρ
  have hL0 : 0 ≤ matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
    rw [hU.laplacian_energy]; positivity
  rw [show (∑ i, x i * residualBias U ρ i) = ∑ i, x i * diagMap U (driftMean U ρ) i from rfl, h1]
  have hcs : (∑ i, ∑ k, driftMean U ρ i k * ambientNormal U x i k) ^ 2 ≤
      frobSq (driftMean U ρ) * frobSq (ambientNormal U x) := by
    rw [← Fintype.sum_prod_type']
    have := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
      (fun p : Fin n × Fin d => driftMean U ρ p.1 p.2) (fun p => ambientNormal U x p.1 p.2)
    simpa only [frobSq, Fintype.sum_prod_type] using this
  calc _ ≤ frobSq (driftMean U ρ) * frobSq (ambientNormal U x) := hcs
    _ ≤ _ := by rw [h2]; exact mul_le_mul_of_nonneg_right hfro hL0

end

end Paulsen.Paper
