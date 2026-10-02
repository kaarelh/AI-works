import Paulsen.Paper.Intro
import Paulsen.Paper.Bounded
import Paulsen.Paper.ManyRowProof
import Paulsen.Paper.ModerateSeed
import Paulsen.SharpProjection

/-!
# Paper blueprint, Section 6: assembly (`sections/assembly.tex`), and the main theorems
`thm:main`, `thm:projection` (stated in `sections/intro.tex`)

The constant chain of the paper:
`C₀ = max{d₀, C_*, 4/c_*, 2+4C_m, 16/ε₀}`, `C_P = max{4, 2+8C₀}`, `C = max{12, 1+8C_P}`.
-/

namespace Paulsen.Paper

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-! ## Explicit-constant interfaces -/

/-- The conclusion of `thm:manyrow` for given constants `B, c_*, C_*` (note `d ≥ 2`). -/
def ManyRowWith (B cs Cs : ℝ) : Prop :=
  ∀ (n d : ℕ), 2 ≤ d → B * (d : ℝ) ^ 2 ≤ n → ∀ η : ℝ, 0 < η → η ≤ cs → EqualRowBound n d η Cs

/-- The conclusion of `prop:equalrow` for a given constant `C₀`. -/
def EqualRowBoundWith (C₀ : ℝ) : Prop :=
  ∀ (n d : ℕ), 1 ≤ d → 2 * d ≤ n → ∀ η : ℝ, 0 ≤ η → EqualRowBound n d η C₀

/-- The conclusion of `thm:projection` for a given constant `C`. -/
def ProjectionBoundWith (C : ℝ) : Prop :=
  ∀ (n d : ℕ), 0 < n →
    ∀ (P : Frame n n), P.transpose = P → P * P = P → P.rank = d →
    ∀ β : ℝ, 0 ≤ β → (∀ i, |P i i - (d : ℝ) / n| ≤ β) →
    ∃ Q : Frame n n, Q.transpose = Q ∧ Q * Q = Q ∧ Q.rank = d ∧
      (∀ i, Q i i = (d : ℝ) / n) ∧ sqDistance P Q ≤ C * (n : ℝ) * β

/-- The conclusion of `thm:main` for a given constant `C`. -/
def PaulsenBoundWith (C : ℝ) : Prop :=
  ∀ (n d : ℕ), 0 < d → d ≤ n →
    ∀ (ε : ℝ) (U : Frame n d), 0 < ε → ε < 1 →
      IsNearlyEqualNormParseval ε U →
      ∃ W : Frame n d, IsEqualNormParseval W ∧ sqDistance U W ≤ C * ε * (d : ℝ)

/-- `SharpProjectionBound` is `∃ C > 0, ProjectionBoundWith C`. -/
theorem sharpProjectionBound_iff : SharpProjectionBound ↔ ∃ C : ℝ, 0 < C ∧ ProjectionBoundWith C :=
  Iff.rfl

/-- `SharpPaulsenBound` is `∃ C > 0, PaulsenBoundWith C`. -/
theorem sharpPaulsenBound_iff : SharpPaulsenBound ↔ ∃ C : ℝ, 0 < C ∧ PaulsenBoundWith C :=
  Iff.rfl

/-- The explicit form of `thm:manyrow` gives `ManyRowWith`. -/
theorem manyRowWith_of_explicit {h t₀ c₁ CM B : ℝ} (hh : 0 < h) (hh1 : h ≤ 1) (ht₀ : 0 < t₀)
    (ht₀1 : t₀ ≤ 1) (hc₁ : 0 < c₁) (hdense : MrDenseConclusion h t₀ c₁) (hCM : 0 ≤ CM)
    (hmom : RowMomentBound CM) (hB : 0 < B) (hBc : MrBChoice h c₁ B) :
    ManyRowWith B (mrCStar h t₀ CM) (mrCostStar h) := by
  sorry

/-! ## `prop:equalrow` -/

/-- `prop:equalrow`.

TeX: "There is an absolute constant $C_0$ such that every $X\in\R^{n\times d}$ with
$1\le d$, $2d\le n$ and $\norm{x_i}^2=a$ for all $i$ admits an ENP frame $W$
with \[ \fro{X-W}^2\le C_0\,d\,\opn{X^TX-I}. \]"

(`EqualRowBound n d η C₀`: every equal-norm `X` with `‖XᵀX-I‖ ≤ η` has a correction of cost
`C₀ η d`.) -/
theorem prop_equalrow : ∃ C₀ : ℝ, 0 < C₀ ∧ EqualRowBoundWith C₀ := by
  sorry

/-- `prop:equalrow` with the explicit constant of its proof.

TeX: "Let $A,\eps_0,C_m$ be the
constants of \cref{thm:moderate} and $B,c_*,C_*$ those of \cref{thm:manyrow},
and fix an integer $d_0\ge2$ with $A\log(2Bd^2)\le d$ for all $d\ge d_0$. [...]
Altogether $C_0=\max\{d_0,C_*,4/c_*,2+4C_m,16/\eps_0\}$ works."

The hypothesis `ε₀ ≤ 1/2` is the standing assumption of Section 5 ("$\eps_0\le\frac12$");
the proof needs it (for `η ≤ ε₀/4` to give `η ≤ 1/2` in the polar step and `η ≤ 1`). -/
theorem prop_equalrow_explicit {A ε₀ Cm B cs Cs : ℝ} {d₀ : ℕ} (hA : 0 ≤ A) (hε₀ : 0 < ε₀)
    (hε₀1 : ε₀ ≤ 1 / 2) (hCm : 0 ≤ Cm) (hB : 0 < B) (hcs : 0 < cs) (hCs : 0 ≤ Cs)
    (hmod : Linear.ModerateParsevalBound A ε₀ Cm) (hmany : ManyRowWith B cs Cs)
    (hd₀ : 2 ≤ d₀) (hd₀A : ∀ d : ℕ, d₀ ≤ d → A * Real.log (2 * B * (d : ℝ) ^ 2) ≤ d) :
    EqualRowBoundWith (max (max (max (max (d₀ : ℝ) Cs) (4 / cs)) (2 + 4 * Cm)) (16 / ε₀)) := by
  sorry

/-- Proof of `prop:equalrow`: existence of `d₀`. -/
theorem prop_equalrow_d0 {A B : ℝ} (hA : 0 ≤ A) (hB : 0 < B) :
    ∃ d₀ : ℕ, 2 ≤ d₀ ∧ ∀ d : ℕ, d₀ ≤ d → A * Real.log (2 * B * (d : ℝ) ^ 2) ≤ d := by
  sorry

/-- Proof of `prop:equalrow`, the case costs.

TeX: "\emph{Case $d<d_0$.} \Cref{lem:HM} gives $\fro{X-W}^2\le\eta d(d-1)\le d_0\eta d$.
\emph{Case $d\ge d_0$, $n\ge Bd^2$.} If $\eta\le c_*$ use \cref{thm:manyrow};
otherwise \cref{cor:exist} gives cost $4d\le(4/c_*)\eta d$.
\emph{Case $d\ge d_0$, $n<Bd^2$.} Then $A\log(2n)\le d$. [...]
$\fro{X-W}^2\le2d\eta^2+4C_m\eta d$. If $\eta>\eps_0/4$ use the trivial cost
$4d\le(16/\eps_0)\eta d$." -/
theorem prop_equalrow_cases {A ε₀ Cm B cs : ℝ} {d₀ n d : ℕ} {η : ℝ} (hη : 0 < η)
    (hA : 0 ≤ A) (hε₀ : 0 < ε₀) (hcs : 0 < cs) (hd : 1 ≤ d) (hn : 0 < n) :
    (d < d₀ → η * d * ((d : ℝ) - 1) ≤ d₀ * η * d) ∧
    (cs < η → 4 * (d : ℝ) ≤ (4 / cs) * η * d) ∧
    ((n : ℝ) < B * (d : ℝ) ^ 2 → (∀ d' : ℕ, d₀ ≤ d' → A * Real.log (2 * B * (d' : ℝ) ^ 2) ≤ d')
      → d₀ ≤ d → A * Real.log (2 * n) ≤ d) ∧
    (η ≤ ε₀ / 4 → ε₀ ≤ 1 → 2 * d * η ^ 2 + 4 * Cm * η * d ≤ (2 + 4 * Cm) * η * d) ∧
    (ε₀ / 4 < η → 4 * (d : ℝ) ≤ (16 / ε₀) * η * d) := by
  sorry

/-- Proof of `prop:equalrow`, the polar step.

TeX: "If $\eta\le\eps_0/4$, let
$U=X(X^TX)^{-1/2}$. The singular values of $X$ lie in
$[\sqrt{1-\eta},\sqrt{1+\eta}]$, so $\fro{X-U}^2\le d\eta^2$, and
$\norm{u_i}^2=x_i^T(X^TX)^{-1}x_i\in[a/(1+\eta),a/(1-\eta)]$, so
$|\norm{u_i}^2-a|\le2\eta a$. \Cref{thm:moderate} with $\eps=2\eta$ gives an ENP
$W$ with $\fro{U-W}^2\le2C_m\eta d$" -/
theorem prop_equalrow_polar {n d : ℕ} (X : Frame n d) (hX : IsEqualNorm X) {η : ℝ}
    (hη0 : 0 ≤ η) (hη : η ≤ 1 / 2) (hXp : IsNearlyParseval η X) :
    IsParseval (polarFactor X) ∧
    sqDistance X (polarFactor X) ≤ d * η ^ 2 ∧
    (∀ i, (d : ℝ) / n / (1 + η) ≤ rowNormSq (polarFactor X) i ∧
      rowNormSq (polarFactor X) i ≤ (d : ℝ) / n / (1 - η)) ∧
    ∀ i, |rowNormSq (polarFactor X) i - (d : ℝ) / n| ≤ 2 * η * ((d : ℝ) / n) := by
  sorry

/-! ## `thm:projection` -/

/-- `thm:projection` (Projection form).

TeX: "There is an absolute constant $C$ such that for every $n\ge1$ and every
rank-$d$ orthogonal projection $P$ on $\R^n$, with
$\beta=\max_i|P_{ii}-d/n|$, there is a rank-$d$ orthogonal projection $Q$ with
$Q_{ii}=d/n$ for all $i$ and $\fro{P-Q}^2\le Cn\beta$." -/
theorem thm_projection : SharpProjectionBound := by
  sorry

/-- `thm:projection` with the explicit constant of its proof.

TeX: "So \cref{thm:projection} holds with $C_P=\max\{4,2+8C_0\}$." -/
theorem thm_projection_explicit {C₀ : ℝ} (hC₀ : 0 ≤ C₀) (h : EqualRowBoundWith C₀) :
    ProjectionBoundWith (max 4 (2 + 8 * C₀)) := by
  sorry

/-- Proof of `thm:projection`, the steps with explicit constants.

TeX: "Replacing $(P,Q)$ by $(I-P,I-Q)$ preserves $\beta$, ranks of complements and
distances, so we may assume $d\le n/2$ [...] If
$\delta\ge\frac12$, any ENP $W$ (\cref{cor:exist}) gives
$\fro{P-WW^T}^2\le2d\le4n\beta$. Otherwise let $x_i=\sqrt a\,u_i/\norm{u_i}$. Then
$\fro{X-U}^2=\sum_i(\sqrt{p_i}-\sqrt a)^2\le\sum_i(p_i-a)^2/a\le\delta^2d$ and
$X^TX=U^T\Diag(a/p)U$, so $\opn{X^TX-I}\le\max_i|a/p_i-1|\le\delta/(1-\delta)\le
2\delta$. \Cref{prop:equalrow} gives an ENP $W$ with
$\fro{U-W}^2\le2\delta^2d+4C_0\delta d\le(1+4C_0)n\beta$, using $\delta d=n\beta$.
Take $Q=WW^T$; by \cref{lem:align}, $\fro{P-Q}^2\le2(1+4C_0)n\beta$." -/
theorem thm_projection_steps {n d : ℕ} (hn : 0 < n) (hd : 1 ≤ d) (hdn : 2 * d ≤ n)
    (U : Frame n d) (hU : IsParseval U) {β C₀ : ℝ} (hβ : 0 ≤ β) (hC₀ : 0 ≤ C₀)
    (herr : ∀ i, |rowNormSq U i - (d : ℝ) / n| ≤ β) :
    (∀ (P : Frame n n) (k : ℕ), P.transpose = P → P * P = P → P.rank = k →
      (∀ i, |(1 - P) i i - ((n - k : ℕ) : ℝ) / n| = |P i i - (k : ℝ) / n|) ∧
      (1 - P).rank = n - k) ∧
    (1 / 2 ≤ β / ((d : ℝ) / n) → ∀ W : Frame n d, IsParseval W →
      sqDistance (frameProjection U) (frameProjection W) ≤ 2 * d ∧ 2 * (d : ℝ) ≤ 4 * n * β) ∧
    (β / ((d : ℝ) / n) < 1 / 2 →
      let δ := β / ((d : ℝ) / n)
      let X : Frame n d := Matrix.of fun i j =>
        Real.sqrt ((d : ℝ) / n) * U i j / Real.sqrt (rowNormSq U i)
      IsEqualNorm X ∧
      sqDistance X U ≤ δ ^ 2 * d ∧
      IsNearlyParseval (2 * δ) X ∧
      δ * d = n * β ∧
      2 * δ ^ 2 * d + 4 * C₀ * δ * d ≤ (1 + 4 * C₀) * n * β ∧
      2 * ((1 + 4 * C₀) * n * β) = (2 + 8 * C₀) * n * β) := by
  sorry

/-! ## `thm:main` -/

/-- `thm:main` (Linear Paulsen bound).

TeX: "There is an absolute constant $C$ such that for all $1\le d\le n$, all
$0<\eps<1$ and every real $\eps$-nearly ENP frame $X\in\R^{n\times d}$ there is
an ENP frame $W\in\R^{n\times d}$ with $\fro{X-W}^2\le C\eps d$." -/
theorem thm_main : SharpPaulsenBound := by
  sorry

/-- `thm:main` with the explicit constant of its proof.

TeX: "so \cref{thm:main} holds with $C=\max\{12,1+8C_P\}$." -/
theorem thm_main_explicit {CP : ℝ} (hCP : 0 ≤ CP) (h : ProjectionBoundWith CP) :
    PaulsenBoundWith (max 12 (1 + 8 * CP)) := by
  sorry

/-- Proof of `thm:main`, the steps with explicit constants.

TeX: "If $\eps\ge\frac12$, an ENP $W$ gives $\fro{X-W}^2\le2\fro X^2+2d\le6d\le12\eps
d$, since $\fro X^2=\tr X^TX\le(1+\eps)d$. Let $\eps<\frac12$ and
$U=X(X^TX)^{-1/2}$, $P=UU^T$. As above $\fro{X-U}^2\le\eps^2d$ and
$P_{ii}=x_i^T(X^TX)^{-1}x_i\in[\frac{1-\eps}{1+\eps}a,\frac{1+\eps}{1-\eps}a]$, so
$\beta=\max_i|P_{ii}-a|\le4\eps a$. \Cref{thm:projection} gives $Q$ with
$\fro{P-Q}^2\le4C_P\eps d$, and by \cref{lem:align} there is an isometry $W$
spanning $Q$---hence ENP---with $\fro{U-W}^2\le\fro{P-Q}^2$. Then
$\fro{X-W}^2\le2\eps^2d+8C_P\eps d$" -/
theorem thm_main_steps {n d : ℕ} (hd : 0 < d) (hdn : d ≤ n) {ε CP : ℝ} (hε : 0 < ε)
    (hε1 : ε < 1) (hCP : 0 ≤ CP) (X : Frame n d) (hX : IsNearlyEqualNormParseval ε X) :
    frobSq X ≤ (1 + ε) * d ∧
    (1 / 2 ≤ ε → ∀ W : Frame n d, IsEqualNormParseval W →
      sqDistance X W ≤ 2 * frobSq X + 2 * d ∧ 2 * frobSq X + 2 * d ≤ 6 * d ∧
        6 * (d : ℝ) ≤ 12 * ε * d) ∧
    (ε < 1 / 2 →
      sqDistance X (polarFactor X) ≤ ε ^ 2 * d ∧
      (∀ i, (1 - ε) / (1 + ε) * ((d : ℝ) / n) ≤ frameProjection (polarFactor X) i i ∧
        frameProjection (polarFactor X) i i ≤ (1 + ε) / (1 - ε) * ((d : ℝ) / n)) ∧
      (∀ i, |frameProjection (polarFactor X) i i - (d : ℝ) / n| ≤ 4 * ε * ((d : ℝ) / n)) ∧
      CP * n * (4 * ε * ((d : ℝ) / n)) = 4 * CP * ε * d ∧
      2 * (ε ^ 2 * d) + 2 * (4 * CP * ε * d) ≤ (1 + 8 * CP) * ε * d) := by
  sorry

/-- The full constant chain of the paper, from the seed constants to the constant of
`thm:main`. -/
theorem thm_main_constant_chain {A ε₀ Cm B cs Cs : ℝ} {d₀ : ℕ} (hA : 0 ≤ A) (hε₀ : 0 < ε₀)
    (hε₀1 : ε₀ ≤ 1 / 2) (hCm : 0 ≤ Cm) (hB : 0 < B) (hcs : 0 < cs) (hCs : 0 ≤ Cs)
    (hmod : Linear.ModerateParsevalBound A ε₀ Cm) (hmany : ManyRowWith B cs Cs)
    (hd₀ : 2 ≤ d₀) (hd₀A : ∀ d : ℕ, d₀ ≤ d → A * Real.log (2 * B * (d : ℝ) ^ 2) ≤ d) :
    let C₀ := max (max (max (max (d₀ : ℝ) Cs) (4 / cs)) (2 + 4 * Cm)) (16 / ε₀)
    let CP := max 4 (2 + 8 * C₀)
    EqualRowBoundWith C₀ ∧ ProjectionBoundWith CP ∧ PaulsenBoundWith (max 12 (1 + 8 * CP)) := by
  sorry

end

end Paulsen.Paper
