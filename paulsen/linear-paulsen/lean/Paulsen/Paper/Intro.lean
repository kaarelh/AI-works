import Paulsen.Paper.Toolbox
import Paulsen.Paper.IntroAuxOptimal

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
  have hquad : ∀ (M : Matrix (Fin d) (Fin d) ℝ) (x : Fin d → ℝ),
      star x ⬝ᵥ (M *ᵥ x) = matrixQuadratic M x := by
    intro M x
    simp only [star_trivial, dotProduct, Matrix.mulVec, matrixQuadratic, Finset.mul_sum, mul_assoc]
  have hsmul : ∀ (c : ℝ) (x : Fin d → ℝ),
      matrixQuadratic (c • (1 : Matrix (Fin d) (Fin d) ℝ)) x = c * vectorNormSq x := by
    intro c x
    simp only [matrixQuadratic, vectorNormSq, Matrix.smul_apply, Matrix.one_apply, smul_eq_mul,
      mul_ite, mul_one, mul_zero, ite_mul, zero_mul, Finset.sum_ite_eq, Finset.mem_univ, if_true,
      Finset.mul_sum]
    apply Finset.sum_congr rfl; intro i _; ring
  have hG : ∀ x, frameEnergy X x = matrixQuadratic (X.transpose * X) x :=
    ToolboxAux.frameEnergy_eq_quad X
  have hH : (X.transpose * X).IsHermitian := ToolboxAux.transpose_mul_self_isHermitian X
  have hH1 : (X.transpose * X - (1 - ε) • (1 : Matrix (Fin d) (Fin d) ℝ)).IsHermitian :=
    hH.sub (Matrix.isHermitian_one.smul (IsSelfAdjoint.all _))
  have hH2 : ((1 + ε) • (1 : Matrix (Fin d) (Fin d) ℝ) - X.transpose * X).IsHermitian :=
    (Matrix.isHermitian_one.smul (IsSelfAdjoint.all _)).sub hH
  unfold IsNearlyEqualNormParseval IsNearlyEqualNorm
  constructor
  · rintro ⟨hP, hN⟩
    refine ⟨⟨Matrix.PosSemidef.of_dotProduct_mulVec_nonneg hH1 fun x => ?_,
      Matrix.PosSemidef.of_dotProduct_mulVec_nonneg hH2 fun x => ?_⟩, hN⟩
    · rw [hquad, matrixQuadratic_sub, hsmul, ← hG]; linarith [(hP x).1]
    · rw [hquad, matrixQuadratic_sub, hsmul, ← hG]; linarith [(hP x).2]
  · rintro ⟨⟨h1, h2⟩, hN⟩
    refine ⟨fun x => ⟨?_, ?_⟩, hN⟩
    · have := h1.dotProduct_mulVec_nonneg x
      rw [hquad, matrixQuadratic_sub, hsmul, ← hG] at this; linarith
    · have := h2.dotProduct_mulVec_nonneg x
      rw [hquad, matrixQuadratic_sub, hsmul, ← hG] at this; linarith

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
let $E$ be the first summand projection and $J$ its coordinate block projection.
Since $E\preceq XX^T$ and $E\preceq J$,
$\tr(XX^T(I-WW^T))\ge\tr(E(I-WW^T))\ge d_1-\tr(JWW^T)=ka$.
Thus $\fro{XX^T-WW^T}^2\ge2ka$ and $\fro{X-W}^2\ge ka=\eps d/4$."

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
      2 * ((k : ℝ) * (D / N)) ≤
          sqDistance (frameProjection (optimalExample X₁ X₂)) (frameProjection W) ∧
      ε * D / 4 ≤ sqDistance (optimalExample X₁ X₂) W := by
  intro N D ε
  have hkn1 : k ≤ n₁ := by omega
  have hmR : ((n₁ - k : ℕ) : ℝ) = (n₁ : ℝ) - k := by rw [Nat.cast_sub hkn1]
  have hN : N = 2 * (n₁ : ℝ) := by
    show (((n₁ - k) + (n₁ + k) : ℕ) : ℝ) = 2 * (n₁ : ℝ)
    push_cast [hkn1]; ring
  have hD : D = 2 * (d₁ : ℝ) := by
    show ((d₁ + d₁ : ℕ) : ℝ) = 2 * (d₁ : ℝ)
    push_cast; ring
  have hkR : (1 : ℝ) ≤ k := by exact_mod_cast hk
  have hk4 : 4 * (k : ℝ) ≤ n₁ := by exact_mod_cast hkn
  have hn1 : (0 : ℝ) < n₁ := by linarith
  have hd1 : (0 : ℝ) ≤ d₁ := Nat.cast_nonneg _
  have hmpos : (0 : ℝ) < (n₁ : ℝ) - k := by linarith
  have hε : ε = 2 * (k : ℝ) / n₁ := by
    show 4 * (k : ℝ) / N = _
    rw [hN]; field_simp; ring
  have hDN : D / N = (d₁ : ℝ) / n₁ := by
    rw [hD, hN]; field_simp
  -- the block structure
  let σ : Fin (n₁ - k) ⊕ Fin (n₁ + k) ≃ Fin ((n₁ - k) + (n₁ + k)) := finSumFinEquiv
  let τ : Fin d₁ ⊕ Fin d₁ ≃ Fin (d₁ + d₁) := finSumFinEquiv
  let F : Matrix (Fin (n₁ - k) ⊕ Fin (n₁ + k)) (Fin d₁ ⊕ Fin d₁) ℝ :=
    Matrix.fromBlocks X₁ 0 0 X₂
  have hX : optimalExample X₁ X₂ = F.submatrix σ.symm τ.symm := rfl
  have hpars : IsParseval (optimalExample X₁ X₂) := by
    unfold IsParseval
    rw [hX, Matrix.transpose_submatrix, Matrix.submatrix_mul_equiv]
    have : F.transpose * F = 1 := by
      simp only [F, Matrix.fromBlocks_transpose, Matrix.fromBlocks_multiply, Matrix.transpose_zero,
        Matrix.zero_mul, Matrix.mul_zero, add_zero, zero_add]
      rw [show X₁.transpose * X₁ = 1 from hX₁.1, show X₂.transpose * X₂ = 1 from hX₂.1,
        Matrix.fromBlocks_one]
    rw [this, Matrix.submatrix_one_equiv]
  have hP : frameProjection (optimalExample X₁ X₂) =
      (Matrix.fromBlocks (X₁ * X₁.transpose) 0 0 (X₂ * X₂.transpose)).submatrix σ.symm σ.symm := by
    unfold frameProjection
    rw [hX, Matrix.transpose_submatrix, Matrix.submatrix_mul_equiv]
    congr 1
    simp only [F, Matrix.fromBlocks_transpose, Matrix.fromBlocks_multiply, Matrix.transpose_zero,
      Matrix.zero_mul, Matrix.mul_zero, add_zero, zero_add]
  have hPσ : ∀ a b, frameProjection (optimalExample X₁ X₂) (σ a) (σ b) =
      Matrix.fromBlocks (X₁ * X₁.transpose) 0 0 (X₂ * X₂.transpose) a b := by
    intro a b
    rw [hP, Matrix.submatrix_apply, Equiv.symm_apply_apply, Equiv.symm_apply_apply]
  have hrow1 : ∀ i, rowNormSq (optimalExample X₁ X₂) (σ (Sum.inl i)) = (d₁ : ℝ) / ((n₁ : ℝ) - k) := by
    intro i
    rw [← frameProjection_diagonal, hPσ, Matrix.fromBlocks_apply₁₁]
    change frameProjection X₁ i i = _
    rw [frameProjection_diagonal, hX₁.2 i, hmR]
  have hrow2 : ∀ i, rowNormSq (optimalExample X₁ X₂) (σ (Sum.inr i)) = (d₁ : ℝ) / ((n₁ : ℝ) + k) := by
    intro i
    rw [← frameProjection_diagonal, hPσ, Matrix.fromBlocks_apply₂₂]
    change frameProjection X₂ i i = _
    rw [frameProjection_diagonal, hX₂.2 i]
    push_cast; ring
  have hv1 : D / N * (1 - 2 * (k : ℝ) / N)⁻¹ = (d₁ : ℝ) / ((n₁ : ℝ) - k) := by
    rw [hD, hN]; field_simp
  have hv2 : D / N * (1 + 2 * (k : ℝ) / N)⁻¹ = (d₁ : ℝ) / ((n₁ : ℝ) + k) := by
    rw [hD, hN]; field_simp
  -- bounds on the two row norms
  have hb1 : (1 - ε) * (D / N) ≤ (d₁ : ℝ) / ((n₁ : ℝ) - k) ∧
      (d₁ : ℝ) / ((n₁ : ℝ) - k) ≤ (1 + ε) * (D / N) := by
    rw [hε, hDN]
    constructor
    · have : (1 - 2 * (k : ℝ) / n₁) * ((d₁ : ℝ) / n₁) = d₁ * (n₁ - 2 * k) / (n₁ * n₁) := by
        field_simp
      rw [this, div_le_div_iff₀ (by positivity) hmpos]
      nlinarith [mul_nonneg hd1 (sq_nonneg (k : ℝ))]
    · have : (1 + 2 * (k : ℝ) / n₁) * ((d₁ : ℝ) / n₁) = d₁ * (n₁ + 2 * k) / (n₁ * n₁) := by
        field_simp
      rw [this, div_le_div_iff₀ hmpos (by positivity)]
      have : (n₁ : ℝ) * n₁ ≤ (n₁ + 2 * k) * (n₁ - k) := by nlinarith
      nlinarith [mul_le_mul_of_nonneg_left this hd1]
  have hb2 : (1 - ε) * (D / N) ≤ (d₁ : ℝ) / ((n₁ : ℝ) + k) ∧
      (d₁ : ℝ) / ((n₁ : ℝ) + k) ≤ (1 + ε) * (D / N) := by
    rw [hε, hDN]
    have hp : (0 : ℝ) < n₁ + k := by linarith
    constructor
    · have : (1 - 2 * (k : ℝ) / n₁) * ((d₁ : ℝ) / n₁) = d₁ * (n₁ - 2 * k) / (n₁ * n₁) := by
        field_simp
      rw [this, div_le_div_iff₀ (by positivity) hp]
      have : ((n₁ : ℝ) - 2 * k) * (n₁ + k) ≤ n₁ * n₁ := by nlinarith
      nlinarith [mul_le_mul_of_nonneg_left this hd1]
    · have : (1 + 2 * (k : ℝ) / n₁) * ((d₁ : ℝ) / n₁) = d₁ * (n₁ + 2 * k) / (n₁ * n₁) := by
        field_simp
      rw [this, div_le_div_iff₀ hp (by positivity)]
      have : (n₁ : ℝ) * n₁ ≤ (n₁ + 2 * k) * (n₁ + k) := by nlinarith
      nlinarith [mul_le_mul_of_nonneg_left this hd1]
  have hεpos : 0 ≤ ε := by rw [hε]; positivity
  refine ⟨hN, hpars, fun i => by rw [hrow1, hv1], fun i => by rw [hrow2, hv2],
    ⟨hpars.isNearlyParseval hεpos, fun i => ?_⟩, fun W hW => ?_⟩
  · -- the nearly-ENP row bounds
    obtain ⟨a, rfl⟩ := σ.surjective i
    rcases a with i | i
    · rw [hrow1]; exact hb1
    · rw [hrow2]; exact hb2
  -- Embed the first summand projection E and its coordinate support J.
  let E₀ := X₁ * X₁.transpose
  let E := (Matrix.fromBlocks E₀ (0 : Matrix (Fin (n₁-k)) (Fin (n₁+k)) ℝ) 0
    (0 : Matrix (Fin (n₁+k)) (Fin (n₁+k)) ℝ)).submatrix σ.symm σ.symm
  let J := (Matrix.fromBlocks (1 : Matrix (Fin (n₁-k)) (Fin (n₁-k)) ℝ)
    (0 : Matrix (Fin (n₁-k)) (Fin (n₁+k)) ℝ) 0
    (0 : Matrix (Fin (n₁+k)) (Fin (n₁+k)) ℝ)).submatrix σ.symm σ.symm
  have hE₀s : E₀.transpose=E₀ := by
    dsimp [E₀]; rw [Matrix.transpose_mul, Matrix.transpose_transpose]
  have hE₀ : E₀*E₀=E₀ := hX₁.1.frameProjection_idempotent
  have hEs : E.transpose=E := by
    simp only [E, Matrix.transpose_submatrix, Matrix.fromBlocks_transpose,
      hE₀s, Matrix.transpose_zero]
  have hJs : J.transpose=J := by
    simp only [J, Matrix.transpose_submatrix, Matrix.fromBlocks_transpose,
      Matrix.transpose_one, Matrix.transpose_zero]
  have hE : E*E=E := by
    simp only [E, Matrix.submatrix_mul_equiv, Matrix.fromBlocks_multiply,
      Matrix.mul_zero, Matrix.zero_mul, add_zero, zero_add, hE₀]
  have hJ : J*J=J := by
    simp only [J, Matrix.submatrix_mul_equiv, Matrix.fromBlocks_multiply,
      Matrix.mul_zero, Matrix.zero_mul, add_zero, zero_add, Matrix.one_mul]
  have hPE : frameProjection (optimalExample X₁ X₂) * E=E := by
    rw [hP]
    simp only [E, Matrix.submatrix_mul_equiv, Matrix.fromBlocks_multiply,
      Matrix.mul_zero, Matrix.zero_mul, add_zero, zero_add]
    change (Matrix.fromBlocks (E₀*E₀) (0 : Matrix (Fin (n₁-k)) (Fin (n₁+k)) ℝ) 0
      (0 : Matrix (Fin (n₁+k)) (Fin (n₁+k)) ℝ)).submatrix σ.symm σ.symm = _
    rw [hE₀]
  have hJE : J*E=E := by
    simp only [J, E, Matrix.submatrix_mul_equiv, Matrix.fromBlocks_multiply,
      Matrix.mul_zero, Matrix.zero_mul, add_zero, zero_add, Matrix.one_mul]
  have htrace (A : Matrix (Fin (n₁-k) ⊕ Fin (n₁+k)) (Fin (n₁-k) ⊕ Fin (n₁+k)) ℝ) :
      (A.submatrix σ.symm σ.symm).trace=A.trace := by
    change (∑ i, A (σ.symm i) (σ.symm i)) = ∑ i, A i i
    exact Equiv.sum_comp σ.symm (fun i => A i i)
  have htrE : E.trace = (d₁ : ℝ) := by
    rw [htrace]
    simp only [Matrix.trace, Matrix.diag_apply, Fintype.sum_sum_type,
      Matrix.fromBlocks_apply₁₁, Matrix.fromBlocks_apply₂₂, Matrix.zero_apply,
      Finset.sum_const_zero, add_zero]
    change (frameProjection X₁).trace = _
    exact hX₁.1.frameProjection_trace
  let Qb := (frameProjection W).submatrix σ σ
  have hQb : frameProjection W = Qb.submatrix σ.symm σ.symm := by
    ext i j
    simp only [Qb, Matrix.submatrix_apply, Equiv.apply_symm_apply]
  have htrJQ : (J * frameProjection W).trace = ((n₁ : ℝ)-k)*(D/N) := by
    rw [hQb]
    change ((Matrix.fromBlocks (1 : Matrix (Fin (n₁-k)) (Fin (n₁-k)) ℝ)
      (0 : Matrix (Fin (n₁-k)) (Fin (n₁+k)) ℝ) 0
      (0 : Matrix (Fin (n₁+k)) (Fin (n₁+k)) ℝ)).submatrix σ.symm σ.symm *
      Qb.submatrix σ.symm σ.symm).trace = _
    rw [Matrix.submatrix_mul_equiv, htrace]
    simp only [Matrix.trace, Matrix.diag_apply, Matrix.mul_apply, Fintype.sum_sum_type,
      Matrix.fromBlocks_apply₁₁, Matrix.fromBlocks_apply₁₂, Matrix.fromBlocks_apply₂₁,
      Matrix.fromBlocks_apply₂₂, Matrix.zero_apply, zero_mul, Finset.sum_const_zero,
      add_zero, zero_add, Matrix.one_apply, ite_mul, one_mul]
    simp only [Finset.sum_ite_eq, Finset.mem_univ, if_true]
    change (∑ i : Fin (n₁-k), frameProjection W (σ (Sum.inl i)) (σ (Sum.inl i))) = _
    have hr : ∀ i, rowNormSq W i = D/N := hW.2
    simp only [frameProjection_diagonal, hr, Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul, hmR]
  have hcore := IntroAux.optimal_core (frameProjection (optimalExample X₁ X₂))
    (frameProjection W) E J (frameProjection_transpose _) (frameProjection_transpose _)
    hEs hJs hpars.frameProjection_idempotent hW.1.frameProjection_idempotent hE hJ
    (by rw [hpars.frameProjection_trace, hW.1.frameProjection_trace]) hPE hJE
  have hkey : 2 * ((k : ℝ) * (D / N)) ≤
      sqDistance (frameProjection (optimalExample X₁ X₂)) (frameProjection W) := by
    have heq : E.trace-(J*frameProjection W).trace = (k : ℝ)*(D/N) := by
      rw [htrE, htrJQ, hDN]; field_simp; ring
    rwa [heq] at hcore
  have halign := (lem_align (optimalExample X₁ X₂) W hpars hW.1).2.2.2.2.2
  refine ⟨by rw [hε, hDN, hD]; field_simp; ring, hkey, ?_⟩
  have : ε * D / 4 = (k : ℝ) * (D / N) := by
    rw [hε, hDN, hD]; field_simp; ring
  rw [this]
  linarith

end

end Paulsen.Paper
