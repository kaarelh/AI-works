import Paulsen.Paper.Intro
import Paulsen.Paper.Bounded
import Paulsen.Paper.ManyRowProof
import Paulsen.Paper.ModerateSeed
import Paulsen.SharpProjection
import Paulsen.Paper.AssemblyAux

/-!
# Paper blueprint, Section 6: assembly (`sections/assembly.tex`), and the main theorems
`thm:main`, `thm:projection` (stated in `sections/intro.tex`)

The constant chain of the paper:
`C₀ = max{d₀, C_*, 4/c_*, 2+4C_m, 16/ε₀}`, `C_P = max{4, 2+8C₀}`, `C = max{12, 1+8C_P}`.

All proofs are complete (modulo the upstream paper lemmas they cite).  The chain is the
paper's: `thm_main` ← `thm_main_explicit` (+ `thm_main_steps`) ← `thm_projection_explicit`
(+ `thm_projection_steps`) ← `prop_equalrow` ← `prop_equalrow_explicit` (+ `prop_equalrow_d0`,
`prop_equalrow_cases`, `prop_equalrow_polar`) ← `thm_manyrow`, `thm_moderate`, `lem_HM`,
`cor_exist`; the library route `Paulsen.Linear.sharpPaulsenBound` is not used.  The proof-step
lemmas are placed before the paper items they prove.  Complements and row normalisation are in
the helper file `AssemblyAux.lean`.
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
  intro n d hd hBn η hη hηc X hX hXη
  exact thm_manyrow_explicit hh hh1 ht₀ ht₀1 hc₁ hdense hCM hmom hB hBc n d hd hBn X hX η hXη
    hη hηc

/-! ## `prop:equalrow` -/

/-- Proof of `prop:equalrow`: existence of `d₀`. -/
theorem prop_equalrow_d0 {A B : ℝ} (hA : 0 ≤ A) (hB : 0 < B) :
    ∃ d₀ : ℕ, 2 ≤ d₀ ∧ ∀ d : ℕ, d₀ ≤ d → A * Real.log (2 * B * (d : ℝ) ^ 2) ≤ d := by
  obtain ⟨D, -, hD⟩ := Linear.exists_log_threshold A B hA hB
  exact ⟨max D 2, le_max_right _ _, fun d hd => hD d ((le_max_left _ _).trans hd)⟩

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
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hηd : 0 ≤ η * d := by positivity
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro hdd
    have h1 : (d : ℝ) - 1 ≤ d₀ := by
      have : (d : ℝ) < d₀ := by exact_mod_cast hdd
      linarith
    have := mul_le_mul_of_nonneg_left h1 hηd
    linarith
  · intro hc
    have h1 : 4 ≤ 4 / cs * η := by
      rw [div_mul_eq_mul_div, le_div_iff₀ hcs]; linarith
    have := mul_le_mul_of_nonneg_right h1 (by positivity : (0 : ℝ) ≤ d)
    linarith
  · intro hnB hd0 hdd
    have h1 := hd0 d hdd
    have h2 : Real.log (2 * n) ≤ Real.log (2 * B * (d : ℝ) ^ 2) :=
      Real.log_le_log (by positivity) (by linarith)
    calc A * Real.log (2 * n) ≤ A * Real.log (2 * B * (d : ℝ) ^ 2) :=
          mul_le_mul_of_nonneg_left h2 hA
      _ ≤ d := h1
  · intro hη4 hε1
    have hη1 : η ≤ 1 := by linarith
    have h1 : η ^ 2 ≤ η := by nlinarith
    have := mul_le_mul_of_nonneg_left h1 (by positivity : (0 : ℝ) ≤ 2 * d)
    nlinarith
  · intro hη4
    have h1 : 4 ≤ 16 / ε₀ * η := by
      rw [div_mul_eq_mul_div, le_div_iff₀ hε₀]; linarith
    have := mul_le_mul_of_nonneg_right h1 (by positivity : (0 : ℝ) ≤ d)
    linarith

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
  obtain ⟨h1, h2, h3⟩ := lem_align_polar X hη0 (by linarith) hXp
  refine ⟨h1, h2, fun i => ?_, fun i => ?_⟩
  · rw [← hX i]; exact h3 i
  · have := (lem_align_polar_half X hη0 hη hXp i).1
    rwa [hX i] at this

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
  set C₀ := max (max (max (max (d₀ : ℝ) Cs) (4 / cs)) (2 + 4 * Cm)) (16 / ε₀) with hC₀
  have hC1 : (d₀ : ℝ) ≤ C₀ :=
    (le_max_left _ _).trans ((le_max_left _ _).trans ((le_max_left _ _).trans (le_max_left _ _)))
  have hC2 : Cs ≤ C₀ :=
    (le_max_right _ _).trans ((le_max_left _ _).trans ((le_max_left _ _).trans (le_max_left _ _)))
  have hC3 : 4 / cs ≤ C₀ := (le_max_right _ _).trans ((le_max_left _ _).trans (le_max_left _ _))
  have hC4 : 2 + 4 * Cm ≤ C₀ := (le_max_right _ _).trans (le_max_left _ _)
  have hC5 : 16 / ε₀ ≤ C₀ := le_max_right _ _
  intro n d hd hdn η hη X hX hXη
  have hdn' : d ≤ n := by omega
  have hn : 0 < n := by omega
  have hdR : (0 : ℝ) ≤ d := Nat.cast_nonneg d
  have hscale : ∀ c : ℝ, c ≤ C₀ → c * η * d ≤ C₀ * η * d := fun c hc =>
    mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hc hη) hdR
  -- `η = 0`: `lem:HM` gives cost `0`
  rcases hη.lt_or_eq with hηpos | hη0
  swap
  · subst hη0
    obtain ⟨W, hW, hdist⟩ := lem_HM hd hdn' X hX hXη
    exact ⟨W, hW, by simpa using hdist⟩
  obtain ⟨hc1, hc2, hc3, hc4, hc5⟩ := prop_equalrow_cases (A := A) (ε₀ := ε₀) (Cm := Cm)
    (B := B) (cs := cs) (d₀ := d₀) hηpos hA hε₀ hcs hd hn
  by_cases hdd : d < d₀
  · -- Case `d < d₀`: `lem:HM`
    obtain ⟨W, hW, hdist⟩ := lem_HM hd hdn' X hX hXη
    exact ⟨W, hW, hdist.trans ((hc1 hdd).trans (hscale _ hC1))⟩
  push Not at hdd
  have hd2 : 2 ≤ d := hd₀.trans hdd
  by_cases hBn : B * (d : ℝ) ^ 2 ≤ n
  · -- Case `n ≥ B d²`: `thm:manyrow`, or the trivial cost
    by_cases hηc : η ≤ cs
    · exact (hmany n d hd2 hBn η hηpos hηc X hX hXη).mono (hscale _ hC2)
    · push Not at hηc
      obtain ⟨W, hW, hdist, heq⟩ := cor_exist_trivial hd hdn' X hX
      rw [heq] at hdist
      exact ⟨W, hW, hdist.trans ((hc2 hηc).trans (hscale _ hC3))⟩
  · -- Case `n < B d²`: polar normalisation and `thm:moderate`
    push Not at hBn
    have hAlog := hc3 hBn hd₀A hdd
    by_cases hηe : η ≤ ε₀ / 4
    · obtain ⟨hUp, hXU, -, hrow⟩ := prop_equalrow_polar X hX hη (by linarith) hXη
      have hnear : IsNearlyEqualNorm (2 * η) (polarFactor X) := fun i => by
        have := abs_le.mp (hrow i); constructor <;> linarith
      have hmodc := hmod n d (by omega) hdn hAlog (2 * η) (by positivity) (by linarith)
        (polarFactor X) hUp hnear
      refine (hmodc.transfer hXU).mono ?_
      have h4 := hc4 hηe (by linarith)
      have e : 2 * ((d : ℝ) * η ^ 2) + 2 * (Cm * (2 * η) * d) =
          2 * d * η ^ 2 + 4 * Cm * η * d := by ring
      rw [e]
      exact h4.trans (hscale _ hC4)
    · push Not at hηe
      obtain ⟨W, hW, hdist, heq⟩ := cor_exist_trivial hd hdn' X hX
      rw [heq] at hdist
      exact ⟨W, hW, hdist.trans ((hc5 hηe).trans (hscale _ hC5))⟩

/-- `prop:equalrow`.

TeX: "There is an absolute constant $C_0$ such that every $X\in\R^{n\times d}$ with
$1\le d$, $2d\le n$ and $\norm{x_i}^2=a$ for all $i$ admits an ENP frame $W$
with \[ \fro{X-W}^2\le C_0\,d\,\opn{X^TX-I}. \]"

(`EqualRowBound n d η C₀`: every equal-norm `X` with `‖XᵀX-I‖ ≤ η` has a correction of cost
`C₀ η d`.) -/
theorem prop_equalrow : ∃ C₀ : ℝ, 0 < C₀ ∧ EqualRowBoundWith C₀ := by
  obtain ⟨A, Cm, ε₀, hA, hCm, hε₀, _hε₀half, hmod⟩ := thm_moderate
  obtain ⟨B, cs, Cs, hB, hcs, hCs, hmany⟩ := thm_manyrow
  -- the standing assumption `ε₀ ≤ 1/2` of Section 5 (shrinking `ε₀` keeps `thm:moderate`)
  have hmod' : Linear.ModerateParsevalBound A (min ε₀ (1 / 2)) Cm :=
    fun n d hd hdn hr ε hε hεle U hU hnear =>
      hmod n d hd hdn hr ε hε (hεle.trans (min_le_left _ _)) U hU hnear
  have hmany' : ManyRowWith B cs Cs := fun n d hd hBn η hη hηc X hX hXη =>
    hmany n d hd hBn X hX η hXη hη hηc
  obtain ⟨d₀, hd₀, hd₀A⟩ := prop_equalrow_d0 hA.le hB
  refine ⟨_, ?_, prop_equalrow_explicit hA.le (lt_min hε₀ (by norm_num)) (min_le_right _ _)
    hCm.le hB hcs hCs.le hmod' hmany' hd₀ hd₀A⟩
  have : (2 : ℝ) ≤ d₀ := by exact_mod_cast hd₀
  exact lt_of_lt_of_le (by linarith)
    ((le_max_left _ _).trans ((le_max_left _ _).trans ((le_max_left _ _).trans (le_max_left _ _))))

/-! ## `thm:projection` -/

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
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hdR : (0 : ℝ) < d := by exact_mod_cast (show 0 < d by omega)
  have ha : 0 < (d : ℝ) / n := div_pos hdR hnR
  refine ⟨fun P k hs hi hr => AssemblyAux.complement_facts hn P k hs hi hr, ?_, ?_⟩
  · intro hδ W hW
    obtain ⟨hσ, -, -, heq, -, -⟩ := lem_align U W hU hW
    constructor
    · rw [heq]
      have h1 : ∑ k, (1 - crossSingularValues U W k ^ 2) ≤ ∑ _k : Fin d, (1 : ℝ) :=
        Finset.sum_le_sum fun k _ => by nlinarith [sq_nonneg (crossSingularValues U W k)]
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul,
        mul_one] at h1
      linarith
    · have hβ2 : (d : ℝ) / n / 2 ≤ β := by
        rw [le_div_iff₀ ha] at hδ; linarith
      have e : (d : ℝ) = n * ((d : ℝ) / n) := by field_simp
      have := mul_le_mul_of_nonneg_left hβ2 (by positivity : (0 : ℝ) ≤ 4 * n)
      nlinarith
  · intro hδ
    obtain ⟨h1, h2, h3⟩ := AssemblyAux.rowNormalize_facts hn hd U hU hβ herr hδ
    intro δ X
    have hδ0 : 0 ≤ δ := div_nonneg hβ ha.le
    have hδd : δ * d = n * β := by
      change β / ((d : ℝ) / n) * d = n * β
      field_simp
    refine ⟨h1, h2, h3, hδd, ?_, by ring⟩
    have hδ1 : δ ≤ 1 / 2 := hδ.le
    have h4 : 2 * δ ^ 2 * d ≤ δ * d := by
      have : 2 * δ ^ 2 ≤ δ := by nlinarith
      exact mul_le_mul_of_nonneg_right this hdR.le
    have h5 : (1 + 4 * C₀) * n * β = (1 + 4 * C₀) * (δ * d) := by rw [hδd]; ring
    rw [h5]
    nlinarith

/-- `thm:projection` with the explicit constant of its proof.

TeX: "So \cref{thm:projection} holds with $C_P=\max\{4,2+8C_0\}$." -/
theorem thm_projection_explicit {C₀ : ℝ} (hC₀ : 0 ≤ C₀) (h : EqualRowBoundWith C₀) :
    ProjectionBoundWith (max 4 (2 + 8 * C₀)) := by
  set CP := max 4 (2 + 8 * C₀) with hCP
  have hCP4 : 4 ≤ CP := le_max_left _ _
  have hCP2 : 2 + 8 * C₀ ≤ CP := le_max_right _ _
  -- the case `2d ≤ n`
  have hlow : ∀ (n d : ℕ), 0 < n → 2 * d ≤ n → ∀ (P : Frame n n), P.transpose = P →
      P * P = P → P.rank = d → ∀ β : ℝ, 0 ≤ β → (∀ i, |P i i - (d : ℝ) / n| ≤ β) →
      ∃ Q : Frame n n, Q.transpose = Q ∧ Q * Q = Q ∧ Q.rank = d ∧
        (∀ i, Q i i = (d : ℝ) / n) ∧ sqDistance P Q ≤ CP * (n : ℝ) * β := by
    intro n d hn hdn P hsymm hidem hrank β hβ herr
    have hnR : (0 : ℝ) < n := by exact_mod_cast hn
    have hCnβ : 0 ≤ CP * n * β := by positivity
    obtain ⟨U, hU, hUP⟩ : ∃ U : Frame n d, IsParseval U ∧ frameProjection U = P := by
      rw [← hrank]; exact exists_parseval_of_symmetric_idempotent P hsymm hidem
    have herrU : ∀ i, |rowNormSq U i - (d : ℝ) / n| ≤ β := fun i => by
      rw [← frameProjection_diagonal, hUP]; exact herr i
    rcases Nat.eq_zero_or_pos d with hd0 | hd
    · subst hd0
      refine ⟨P, hsymm, hidem, hrank, fun i => ?_, by rw [sqDistance_self]; exact hCnβ⟩
      rw [← hUP, frameProjection_diagonal]
      simp [rowNormSq]
    · have steps := thm_projection_steps hn hd hdn U hU hβ hC₀ herrU
      have hdR : (0 : ℝ) < d := by exact_mod_cast hd
      have ha : 0 < (d : ℝ) / n := by positivity
      by_cases hδ : 1 / 2 ≤ β / ((d : ℝ) / n)
      · -- `δ ≥ 1/2`: any ENP frame (`cor:exist`)
        obtain ⟨W, hW⟩ := cor_exist (n := n) hd (by omega)
        obtain ⟨h1, h2⟩ := steps.2.1 hδ W hW.1
        refine ⟨frameProjection W, frameProjection_transpose W, hW.1.frameProjection_idempotent,
          hW.1.frameProjection_rank, hW.2.projection_diagonal, ?_⟩
        rw [← hUP]
        refine h1.trans (h2.trans ?_)
        have := mul_le_mul_of_nonneg_right hCP4 (by positivity : (0 : ℝ) ≤ n * β)
        nlinarith
      · -- `δ < 1/2`: row normalisation and `prop:equalrow`
        push Not at hδ
        obtain ⟨hXeq, hXU, hXp, -, hcost, hfin⟩ := steps.2.2 hδ
        have hδ0 : 0 ≤ β / ((d : ℝ) / n) := div_nonneg hβ ha.le
        obtain ⟨W, hW, hXW⟩ := h n d hd hdn (2 * (β / ((d : ℝ) / n))) (by positivity) _ hXeq hXp
        have hUW : sqDistance U W ≤ 2 * (β / ((d : ℝ) / n)) ^ 2 * d +
            4 * C₀ * (β / ((d : ℝ) / n)) * d := by
          have h1 := sqDistance_triangle U (Matrix.of fun i j =>
            Real.sqrt ((d : ℝ) / n) * U i j / Real.sqrt (rowNormSq U i) : Frame n d) W
          have h2 := sqDistance_symm U (Matrix.of fun i j =>
            Real.sqrt ((d : ℝ) / n) * U i j / Real.sqrt (rowNormSq U i) : Frame n d)
          linarith
        refine ⟨frameProjection W, frameProjection_transpose W, hW.1.frameProjection_idempotent,
          hW.1.frameProjection_rank, hW.2.projection_diagonal, ?_⟩
        rw [← hUP]
        have hal := (lem_align U W hU hW.1).2.2.2.2.2
        calc _ ≤ 2 * sqDistance U W := hal
          _ ≤ 2 * ((1 + 4 * C₀) * n * β) := by linarith
          _ = (2 + 8 * C₀) * n * β := hfin
          _ ≤ CP * n * β :=
            mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hCP2 hnR.le) hβ
  -- complement symmetry
  intro n d hn P hsymm hidem hrank β hβ herr
  by_cases h2d : 2 * d ≤ n
  · exact hlow n d hn h2d P hsymm hidem hrank β hβ herr
  · push Not at h2d
    have hdn : d ≤ n := hrank ▸ Matrix.rank_le_height P
    obtain ⟨hcd, hcr⟩ := AssemblyAux.complement_facts hn P d hsymm hidem hrank
    have hs' : (1 - P).transpose = 1 - P := by
      rw [Matrix.transpose_sub, Matrix.transpose_one, hsymm]
    have hidem1 : ∀ R : Frame n n, R * R = R → (1 - R) * (1 - R) = 1 - R := by
      intro R hR
      rw [Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_sub, Matrix.one_mul, Matrix.mul_one,
        Matrix.one_mul, hR]
      abel
    obtain ⟨Q', hQs, hQi, hQr, hQd, hdist⟩ := hlow n (n - d) hn (by omega) (1 - P) hs'
      (hidem1 P hidem) hcr β hβ (fun i => (le_of_eq (hcd i)).trans (herr i))
    obtain ⟨-, hcr'⟩ := AssemblyAux.complement_facts hn Q' (n - d) hQs hQi hQr
    refine ⟨1 - Q', by rw [Matrix.transpose_sub, Matrix.transpose_one, hQs], hidem1 Q' hQi,
      by rw [hcr']; omega, fun i => ?_, ?_⟩
    · have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
      rw [Matrix.sub_apply, Matrix.one_apply_eq, hQd i, Nat.cast_sub hdn]
      field_simp
      ring
    · have := sqDistance_one_sub (1 - P) Q'
      rw [sub_sub_cancel] at this
      rw [this]
      exact hdist

/-- `thm:projection` (Projection form).

TeX: "There is an absolute constant $C$ such that for every $n\ge1$ and every
rank-$d$ orthogonal projection $P$ on $\R^n$, with
$\beta=\max_i|P_{ii}-d/n|$, there is a rank-$d$ orthogonal projection $Q$ with
$Q_{ii}=d/n$ for all $i$ and $\fro{P-Q}^2\le Cn\beta$." -/
theorem thm_projection : SharpProjectionBound := by
  obtain ⟨C₀, hC₀, hER⟩ := prop_equalrow
  exact ⟨_, lt_of_lt_of_le (by norm_num) (le_max_left _ _), thm_projection_explicit hC₀.le hER⟩

/-! ## `thm:main` -/

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
  obtain ⟨hXp, hXn⟩ := hX
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  have hn : 0 < n := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have ha : 0 < (d : ℝ) / n := by positivity
  have hfrob := AssemblyAux.frobSq_le_of_nearlyParseval X hXp
  have hfrobeq : frobSq X = ∑ i, rowNormSq X i := rfl
  refine ⟨hfrob, ?_, ?_⟩
  · intro hε2 W hW
    have h1 := sqDistance_le_twice_energy X W
    rw [hW.1.total_rowNormSq, ← hfrobeq] at h1
    refine ⟨h1, by nlinarith, by nlinarith⟩
  · intro hε2
    obtain ⟨-, hpd, hprow⟩ := lem_align_polar X hε.le hε1 hXp
    have hbounds : ∀ i, (1 - ε) / (1 + ε) * ((d : ℝ) / n) ≤
        frameProjection (polarFactor X) i i ∧
        frameProjection (polarFactor X) i i ≤ (1 + ε) / (1 - ε) * ((d : ℝ) / n) := by
      intro i
      rw [frameProjection_diagonal]
      have hx := hXn i
      constructor
      · calc (1 - ε) / (1 + ε) * ((d : ℝ) / n) = (1 - ε) * ((d : ℝ) / n) / (1 + ε) := by ring
          _ ≤ rowNormSq X i / (1 + ε) := div_le_div_of_nonneg_right hx.1 (by linarith)
          _ ≤ rowNormSq (polarFactor X) i := (hprow i).1
      · calc rowNormSq (polarFactor X) i ≤ rowNormSq X i / (1 - ε) := (hprow i).2
          _ ≤ (1 + ε) * ((d : ℝ) / n) / (1 - ε) := div_le_div_of_nonneg_right hx.2 (by linarith)
          _ = (1 + ε) / (1 - ε) * ((d : ℝ) / n) := by ring
    have hup : (1 + ε) / (1 - ε) ≤ 1 + 4 * ε := by
      rw [div_le_iff₀ (by linarith)]; nlinarith
    have hlo : 1 - 4 * ε ≤ (1 - ε) / (1 + ε) := by
      rw [le_div_iff₀ (by linarith)]; nlinarith
    refine ⟨by rw [mul_comm]; exact hpd, hbounds, fun i => ?_, by field_simp, ?_⟩
    · obtain ⟨h1, h2⟩ := hbounds i
      have h3 := mul_le_mul_of_nonneg_right hup ha.le
      have h4 := mul_le_mul_of_nonneg_right hlo ha.le
      rw [abs_le]; constructor <;> nlinarith
    · have h1 : 2 * ε ^ 2 ≤ ε := by nlinarith
      have := mul_le_mul_of_nonneg_right h1 hdR.le
      nlinarith

/-- `thm:main` with the explicit constant of its proof.

TeX: "so \cref{thm:main} holds with $C=\max\{12,1+8C_P\}$." -/
theorem thm_main_explicit {CP : ℝ} (hCP : 0 ≤ CP) (h : ProjectionBoundWith CP) :
    PaulsenBoundWith (max 12 (1 + 8 * CP)) := by
  set C := max 12 (1 + 8 * CP) with hC
  intro n d hd hdn ε X hε hε1 hX
  obtain ⟨-, hbig, hsmall⟩ := thm_main_steps hd hdn hε hε1 hCP X hX
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  have hn : 0 < n := by omega
  have hεd : 0 ≤ ε * d := by positivity
  by_cases hε2 : 1 / 2 ≤ ε
  · -- `ε ≥ 1/2`: any ENP frame
    obtain ⟨W, hW⟩ := cor_exist (n := n) hd hdn
    obtain ⟨h1, h2, h3⟩ := hbig hε2 W hW
    refine ⟨W, hW, ?_⟩
    have : 12 * ε * d ≤ C * ε * d :=
      mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right (le_max_left _ _) hε.le) hdR.le
    linarith
  · -- `ε < 1/2`: polar factor, `thm:projection`, and `lem:align`
    push Not at hε2
    obtain ⟨hXU, -, hbeta, hcp, hfin⟩ := hsmall hε2
    have hU : IsParseval (polarFactor X) := (lem_align_polar X hε.le hε1 hX.1).1
    obtain ⟨Q, hQs, hQi, hQr, hQd, hPQ⟩ := h n d hn (frameProjection (polarFactor X))
      (frameProjection_transpose _) hU.frameProjection_idempotent hU.frameProjection_rank
      (4 * ε * ((d : ℝ) / n)) (by positivity) hbeta
    obtain ⟨W₀, hW₀, hW₀Q⟩ : ∃ W₀ : Frame n d, IsParseval W₀ ∧ frameProjection W₀ = Q := by
      rw [← hQr]; exact exists_parseval_of_symmetric_idempotent Q hQs hQi
    obtain ⟨-, hleast, hle, -⟩ := lem_align (polarFactor X) W₀ hU hW₀
    obtain ⟨R, hR, hRe⟩ := hleast.1
    have hW : IsEqualNormParseval (W₀ * R) := by
      obtain ⟨h1, h2⟩ := lem_align_orthogonal W₀ R hR
      refine ⟨h1 hW₀, fun i => ?_⟩
      rw [h2 i, ← frameProjection_diagonal, hW₀Q, hQd i]
    refine ⟨W₀ * R, hW, ?_⟩
    have hUW : sqDistance (polarFactor X) (W₀ * R) ≤
        sqDistance (frameProjection (polarFactor X)) Q := by
      rw [← hRe, ← hW₀Q]; exact hle
    have htri := sqDistance_triangle X (polarFactor X) (W₀ * R)
    have hCP' : (1 + 8 * CP) * ε * d ≤ C * ε * d :=
      mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right (le_max_right _ _) hε.le) hdR.le
    linarith

/-- `thm:main` (Linear Paulsen bound).

TeX: "There is an absolute constant $C$ such that for all $1\le d\le n$, all
$0<\eps<1$ and every real $\eps$-nearly ENP frame $X\in\R^{n\times d}$ there is
an ENP frame $W\in\R^{n\times d}$ with $\fro{X-W}^2\le C\eps d$." -/
theorem thm_main : SharpPaulsenBound := by
  obtain ⟨C₀, hC₀, hER⟩ := prop_equalrow
  have hP := thm_projection_explicit hC₀.le hER
  exact ⟨_, lt_of_lt_of_le (by norm_num) (le_max_left _ _),
    thm_main_explicit (le_trans (by norm_num) (le_max_left _ _)) hP⟩

/-- The full constant chain of the paper, from the seed constants to the constant of
`thm:main`. -/
theorem thm_main_constant_chain {A ε₀ Cm B cs Cs : ℝ} {d₀ : ℕ} (hA : 0 ≤ A) (hε₀ : 0 < ε₀)
    (hε₀1 : ε₀ ≤ 1 / 2) (hCm : 0 ≤ Cm) (hB : 0 < B) (hcs : 0 < cs) (hCs : 0 ≤ Cs)
    (hmod : Linear.ModerateParsevalBound A ε₀ Cm) (hmany : ManyRowWith B cs Cs)
    (hd₀ : 2 ≤ d₀) (hd₀A : ∀ d : ℕ, d₀ ≤ d → A * Real.log (2 * B * (d : ℝ) ^ 2) ≤ d) :
    let C₀ := max (max (max (max (d₀ : ℝ) Cs) (4 / cs)) (2 + 4 * Cm)) (16 / ε₀)
    let CP := max 4 (2 + 8 * C₀)
    EqualRowBoundWith C₀ ∧ ProjectionBoundWith CP ∧ PaulsenBoundWith (max 12 (1 + 8 * CP)) := by
  intro C₀ CP
  have h1 : EqualRowBoundWith C₀ :=
    prop_equalrow_explicit hA hε₀ hε₀1 hCm hB hcs hCs hmod hmany hd₀ hd₀A
  have hC₀ : 0 ≤ C₀ := le_trans (Nat.cast_nonneg d₀)
    ((le_max_left _ _).trans ((le_max_left _ _).trans ((le_max_left _ _).trans (le_max_left _ _))))
  have h2 : ProjectionBoundWith CP := thm_projection_explicit hC₀ h1
  exact ⟨h1, h2, thm_main_explicit (le_trans (by norm_num) (le_max_left _ _)) h2⟩

end

end Paulsen.Paper
