import Paulsen.Paper.ManyRow

/-!
# Paper blueprint, Section 4.4: proof of `thm:manyrow` with its constant recipe
(`sections/manyrow.tex`, "Proof of Theorem 4.1")

All constants of the proof are defined here with their exact paper values, in terms of the
constants `h, t₀, c₁` of `lem:mr-dense` and `C_𝓜` of `lem:rowmoments`.  The intermediate
claims of the proof are stated deterministically for a fixed sample `g` in the event
`MrEvent`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-! ## The constants -/

/-- `κ₀ = h²/200`. -/
def mrKappa0 (h : ℝ) : ℝ := h ^ 2 / 200

/-- `C' = 36²·20`. -/
def mrCPrime : ℝ := 36 ^ 2 * 20

/-- `C_mix = 125/h² + 3`. -/
def mrCmix (h : ℝ) : ℝ := 125 / h ^ 2 + 3

/-- `Θ = max{42, C_mix}`. -/
def mrTheta (h : ℝ) : ℝ := max 42 (mrCmix h)

/-- `θ = min{1/(4Θ), h/60}`. -/
def mrSmallTheta (h : ℝ) : ℝ := min (1 / (4 * mrTheta h)) (h / 60)

/-- `C_R = 300 + 100 √C_𝓜`. -/
def mrCR (CM : ℝ) : ℝ := 300 + 100 * Real.sqrt CM

/-- `t₁ = min{t₀, θ/(16 C_R)}`. -/
def mrT1 (h t₀ CM : ℝ) : ℝ := min t₀ (mrSmallTheta h / (16 * mrCR CM))

/-- The amplitude `t`, defined by `t² = 4η/θ`. -/
def mrAmplitude (h η : ℝ) : ℝ := Real.sqrt (4 * η / mrSmallTheta h)

/-- `c_* = θ t₁²/4`. -/
def mrCStar (h t₀ CM : ℝ) : ℝ := mrSmallTheta h * mrT1 h t₀ CM ^ 2 / 4

/-- `C_* = 12Θ/θ`. -/
def mrCostStar (h : ℝ) : ℝ := 12 * mrTheta h / mrSmallTheta h

/-- The requirements on `B` in the proof of `thm:manyrow`.

TeX: "Finally choose $B$ so large that
$n\ge Bd^2$ implies $d^2/n\le\theta/4$, $\sqrt{160d^2/n}\le\theta/4$,
$2aC'd/\kappa_0\le\frac14$ [...], $n\ge30$, and $ne^{-c_1(n-1)}\le0.01$." -/
def MrBChoice (h c₁ B : ℝ) : Prop :=
  ∀ n d : ℕ, 2 ≤ d → B * (d : ℝ) ^ 2 ≤ n →
    (d : ℝ) ^ 2 / n ≤ mrSmallTheta h / 4 ∧
    Real.sqrt (160 * (d : ℝ) ^ 2 / n) ≤ mrSmallTheta h / 4 ∧
    2 * ((d : ℝ) / n) * mrCPrime * d / mrKappa0 h ≤ 1 / 4 ∧
    (30 : ℝ) ≤ n ∧
    (n : ℝ) * Real.exp (-c₁ * ((n : ℝ) - 1)) ≤ 1 / 100

/-- The conclusion of `lem:rowmoments` for a given constant `C_𝓜`. -/
def RowMomentBound (CM : ℝ) : Prop :=
  ∀ (n d : ℕ) (X : Frame n d), 2 ≤ d → (d : ℝ) ^ 2 ≤ n → IsEqualNorm X → mrMoment X ≤ CM

/-- Relations between the constants (proof of `thm:manyrow`, "Constants").

TeX: "Put $\kappa_0=h^2/200$, $C'=36^2\cdot20$, and $C_{\rm mix}=125/h^2+3$, then
$\Theta=\max\{42,C_{\rm mix}\}$ and $\theta=\min\{1/(4\Theta),h/60\}$. Let
$C_R=300+100\sqrt{C_{\mathcal M}}$, choose $t_1=\min\{t_0,\theta/(16C_R)\}$, and set
$t^2=4\eta/\theta$, $c_*=\theta t_1^2/4$, so that $\eta\le c_*$ gives $t\le t_1$."
and (Section 4 preamble) "the choice of $c_*$ below gives $c_*\le\frac1{64}$". -/
theorem mr_constants {h t₀ CM : ℝ} (hh : 0 < h) (hh1 : h ≤ 1) (ht₀ : 0 < t₀) (ht₀1 : t₀ ≤ 1)
    (hCM : 0 ≤ CM) :
    42 ≤ mrTheta h ∧ mrCmix h ≤ mrTheta h ∧ 0 < mrSmallTheta h ∧
    mrSmallTheta h ≤ 1 / (4 * mrTheta h) ∧ mrSmallTheta h ≤ h / 60 ∧
    0 < mrT1 h t₀ CM ∧ mrT1 h t₀ CM ≤ t₀ ∧ mrT1 h t₀ CM ≤ mrSmallTheta h / (16 * mrCR CM) ∧
    0 < mrCStar h t₀ CM ∧ mrCStar h t₀ CM ≤ 1 / 64 ∧ 0 < mrCostStar h ∧
    ∀ η : ℝ, 0 < η → η ≤ mrCStar h t₀ CM →
      mrAmplitude h η ^ 2 = 4 * η / mrSmallTheta h ∧ 0 < mrAmplitude h η ∧
      mrAmplitude h η ≤ mrT1 h t₀ CM := by
  sorry

/-- Existence of `B` (proof of `thm:manyrow`, "choose `B` so large that ..."). -/
theorem mr_B_exists {h c₁ : ℝ} (hh : 0 < h) (hh1 : h ≤ 1) (hc₁ : 0 < c₁) :
    ∃ B : ℝ, 0 < B ∧ MrBChoice h c₁ B := by
  sorry

/-! ## The event -/

/-- The event in the proof of `thm:manyrow` (for the sample `g`, amplitude `t`).

TeX: "with positive probability all of the following hold:
\[ \fro Z^2\le20d,\quad \fro{Z-Z_0}^2\le\frac{20d^2}n,\quad
 \fro{Q-\E Q}^2\le\frac{160d^2}n,\quad
 \fro{\Gamma Z}^2\le20\mathcal M,\quad \fro{\Lambda X}^2\le20\mathcal M, \]
$\opn Z,\opn{Z_0}\le16$, and the conclusion of \cref{lem:mr-dense}" -/
structure MrEvent {n d : ℕ} (h t : ℝ) (X : Frame n d) (g : FrameVector n d) : Prop where
  frob_Z : frobSq (conditionedNoise X g) ≤ 20 * (d : ℝ)
  coupling : sqDistance (conditionedNoise X g) (rowNoise X g) ≤ 20 * (d : ℝ) ^ 2 / n
  fluctuation : frobSq (mrQ X (conditionedNoise X g) ((d : ℝ) / n) - mrQMean X) ≤
    160 * (d : ℝ) ^ 2 / n
  gamma : frobSq (mrGamma ((d : ℝ) / n) t (conditionedNoise X g) * conditionedNoise X g) ≤
    20 * mrMoment X
  lambda : frobSq (mrLambda ((d : ℝ) / n) t (conditionedNoise X g) * X) ≤ 20 * mrMoment X
  op_Z : opNorm (conditionedNoise X g) ≤ 16
  op_Z₀ : opNorm (rowNoise X g) ≤ 16
  dense : ∀ i : Fin n, 9 / 10 * ((n : ℝ) - 1) ≤
    ((Finset.univ.filter (fun j => j ≠ i ∧
      h * t * Real.sqrt (((d : ℝ) / n) / n) ≤
        |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|)).card : ℝ)

/-- The failure probabilities of the event (proof of `thm:manyrow`, "The event").

TeX: "the five Markov events fail with probability at most $\frac1{20}$ each, the two net
bounds (\cref{lem:gauss}(c) with $\sigma^2=1/n$, $u=16$) with probability at most
$2\cdot5^{n+d}e^{-8n}$ each, and \cref{lem:mr-dense} with probability at most $0.01$." -/
theorem mr_event_failures {n d : ℕ} (hn : 0 < n) (hd : 2 ≤ d) (hdn : (d : ℝ) ^ 2 ≤ n)
    (X : Frame n d) (hX : IsEqualNorm X) {t : ℝ} (ht : 0 < t) (ht1 : t ≤ 1) :
    (gaussFrame n d).real {g | 20 * (d : ℝ) < frobSq (conditionedNoise X g)} ≤ 1 / 20 ∧
    (gaussFrame n d).real
      {g | 20 * (d : ℝ) ^ 2 / n < sqDistance (conditionedNoise X g) (rowNoise X g)} ≤ 1 / 20 ∧
    (gaussFrame n d).real {g | 160 * (d : ℝ) ^ 2 / n <
      frobSq (mrQ X (conditionedNoise X g) ((d : ℝ) / n) - mrQMean X)} ≤ 1 / 20 ∧
    (gaussFrame n d).real {g | 20 * mrMoment X <
      frobSq (mrGamma ((d : ℝ) / n) t (conditionedNoise X g) * conditionedNoise X g)} ≤
        1 / 20 ∧
    (gaussFrame n d).real {g | 20 * mrMoment X <
      frobSq (mrLambda ((d : ℝ) / n) t (conditionedNoise X g) * X)} ≤ 1 / 20 ∧
    (gaussFrame n d).real {g | 16 < opNorm (conditionedNoise X g)} ≤
      2 * 5 ^ (n + d) * Real.exp (-8 * n) ∧
    (gaussFrame n d).real {g | 16 < opNorm (rowNoise X g)} ≤
      2 * 5 ^ (n + d) * Real.exp (-8 * n) := by
  sorry

/-- The failure budget of the event is less than one. -/
theorem mr_event_budget {n d : ℕ} (hn : 30 ≤ n) (hdn : d ≤ n) :
    5 * (1 / 20 : ℝ) + 2 * (2 * 5 ^ (n + d) * Real.exp (-8 * n)) + 1 / 100 < 1 := by
  sorry

/-- The standing data of the proof of `thm:manyrow`. -/
structure MrSetting (h t₀ c₁ CM B : ℝ) {n d : ℕ} (X : Frame n d) (η : ℝ) : Prop where
  h_pos : 0 < h
  h_le : h ≤ 1
  t₀_pos : 0 < t₀
  t₀_le : t₀ ≤ 1
  c₁_pos : 0 < c₁
  dense : MrDenseConclusion h t₀ c₁
  CM_nonneg : 0 ≤ CM
  moments : RowMomentBound CM
  B_pos : 0 < B
  B_choice : MrBChoice h c₁ B
  two_le_d : 2 ≤ d
  many_rows : B * (d : ℝ) ^ 2 ≤ n
  equal_norm : IsEqualNorm X
  spectral : IsNearlyParseval η X
  η_pos : 0 < η
  η_le : η ≤ mrCStar h t₀ CM

/-- The event has positive probability (proof of `thm:manyrow`, "The event"). -/
theorem mr_event_pos {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) :
    0 < (gaussFrame n d).real {g | MrEvent h (mrAmplitude h η) X g} := by
  sorry

/-! ## Spectral error -/

/-- Proof of `thm:manyrow`, "Spectral error": the remainder bound.

TeX: "Since $\opn X\le\sqrt2$, $\opn S\le\frac32$ and $t\le1$, \cref{lem:remainder} and the
event give
$\opn{R_3}+\opn{R_4}\le t^3\bigl(2\sqrt{40\mathcal M}+256+16\sqrt{20\mathcal M}
+\tfrac32+\sqrt{40\mathcal M}\bigr)\le C_Rt^3$" -/
theorem mr_remainder_bound {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) (g : FrameVector n d)
    (hg : MrEvent h (mrAmplitude h η) X g) :
    opNorm X ≤ Real.sqrt 2 ∧ opNorm (X.transpose * X) ≤ 3 / 2 ∧
    opNorm (mrR3 X (conditionedNoise X g) ((d : ℝ) / n) (mrAmplitude h η)) +
        opNorm (mrR4 X (conditionedNoise X g) ((d : ℝ) / n) (mrAmplitude h η)) ≤
      mrAmplitude h η ^ 3 * (2 * Real.sqrt (40 * mrMoment X) + 256 +
        16 * Real.sqrt (20 * mrMoment X) + 3 / 2 + Real.sqrt (40 * mrMoment X)) ∧
    mrAmplitude h η ^ 3 * (2 * Real.sqrt (40 * mrMoment X) + 256 +
        16 * Real.sqrt (20 * mrMoment X) + 3 / 2 + Real.sqrt (40 * mrMoment X)) ≤
      mrCR CM * mrAmplitude h η ^ 3 := by
  sorry

/-- Proof of `thm:manyrow`, "Spectral error".

TeX: "By~\eqref{eq:mr-identity},
$V^TV-I=(1-t^2)(S-I)+t^2(\E Q-(I-S))+t^2(Q-\E Q)+R_3+R_4$. [...] therefore
\[ \delta:=\opn{V^TV-I}\le\eta+t^2\frac{d^2}n+t^2\sqrt{\frac{160d^2}n}+C_Rt^3
 \le\frac\theta4t^2+\frac\theta4t^2+\frac\theta4t^2+\frac\theta{16}t^2<\theta t^2 . \]"

Here `V = conditionedSeed X t g = tangentSeed X Z a t`. -/
theorem mr_spectral_error {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) (g : FrameVector n d)
    (hg : MrEvent h (mrAmplitude h η) X g) :
    (conditionedSeed X (mrAmplitude h η) g).transpose * conditionedSeed X (mrAmplitude h η) g -
        1 =
      (1 - mrAmplitude h η ^ 2) • (X.transpose * X - 1) +
      mrAmplitude h η ^ 2 • (mrQMean X - (1 - X.transpose * X)) +
      mrAmplitude h η ^ 2 • (mrQ X (conditionedNoise X g) ((d : ℝ) / n) - mrQMean X) +
      mrR3 X (conditionedNoise X g) ((d : ℝ) / n) (mrAmplitude h η) +
      mrR4 X (conditionedNoise X g) ((d : ℝ) / n) (mrAmplitude h η) ∧
    opNorm ((conditionedSeed X (mrAmplitude h η) g).transpose *
        conditionedSeed X (mrAmplitude h η) g - 1) ≤
      η + mrAmplitude h η ^ 2 * ((d : ℝ) ^ 2 / n) +
        mrAmplitude h η ^ 2 * Real.sqrt (160 * (d : ℝ) ^ 2 / n) +
        mrCR CM * mrAmplitude h η ^ 3 ∧
    η + mrAmplitude h η ^ 2 * ((d : ℝ) ^ 2 / n) +
        mrAmplitude h η ^ 2 * Real.sqrt (160 * (d : ℝ) ^ 2 / n) +
        mrCR CM * mrAmplitude h η ^ 3 ≤
      mrSmallTheta h / 4 * mrAmplitude h η ^ 2 + mrSmallTheta h / 4 * mrAmplitude h η ^ 2 +
        mrSmallTheta h / 4 * mrAmplitude h η ^ 2 + mrSmallTheta h / 16 * mrAmplitude h η ^ 2 ∧
    mrSmallTheta h / 4 * mrAmplitude h η ^ 2 + mrSmallTheta h / 4 * mrAmplitude h η ^ 2 +
        mrSmallTheta h / 4 * mrAmplitude h η ^ 2 + mrSmallTheta h / 16 * mrAmplitude h η ^ 2 <
      mrSmallTheta h * mrAmplitude h η ^ 2 := by
  sorry

/-! ## Graph -/

/-- The exceptional set `𝔅₀`: rows whose contribution to `‖VVᵀ - V₀V₀ᵀ‖_F²` exceeds
`κ₀ a t²`. -/
def mrExceptional {n d : ℕ} (h t : ℝ) (X : Frame n d) (g : FrameVector n d) :
    Finset (Fin n) :=
  Finset.univ.filter fun i => mrKappa0 h * ((d : ℝ) / n) * t ^ 2 <
    rowNormSq (frameProjection (conditionedSeed X t g) -
      frameProjection (rowIndependentSeed X t g)) i

/-- Proof of `thm:manyrow`, "Graph" (first part).

TeX: "By~\eqref{eq:mr-contract}, $\opn V,\opn{V_0}\le\sqrt2+16\le18$
and $\fro{VV^T-V_0V_0^T}\le36\,t\fro{Z-Z_0}$, so
$\fro{VV^T-V_0V_0^T}^2\le C't^2d^2/n$." -/
theorem mr_graph_coupling {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) (g : FrameVector n d)
    (hg : MrEvent h (mrAmplitude h η) X g) :
    opNorm (conditionedSeed X (mrAmplitude h η) g) ≤ Real.sqrt 2 + 16 ∧
    opNorm (rowIndependentSeed X (mrAmplitude h η) g) ≤ Real.sqrt 2 + 16 ∧
    Real.sqrt 2 + 16 ≤ 18 ∧
    Real.sqrt (sqDistance (frameProjection (conditionedSeed X (mrAmplitude h η) g))
        (frameProjection (rowIndependentSeed X (mrAmplitude h η) g))) ≤
      36 * mrAmplitude h η * Real.sqrt (sqDistance (conditionedNoise X g) (rowNoise X g)) ∧
    sqDistance (frameProjection (conditionedSeed X (mrAmplitude h η) g))
        (frameProjection (rowIndependentSeed X (mrAmplitude h η) g)) ≤
      mrCPrime * mrAmplitude h η ^ 2 * (d : ℝ) ^ 2 / n := by
  sorry

/-- Proof of `thm:manyrow`, "Graph" (exceptional rows).

TeX: "Let $\mathcal B_0$ be the set of rows whose
contribution to this sum exceeds $\kappa_0at^2$; then $|\mathcal B_0|\le C'd/\kappa_0$. A row
$i\notin \mathcal B_0$ has at most $\kappa_0at^2/((h/2)^2t^2a/n)=n/50$ indices with
$|(VV^T-V_0V_0^T)_{ij}|\ge\frac h2t\sqrt{a/n}$, so by \cref{lem:mr-dense} it has at
least $0.85n$ indices $j\ne i$ with $|(VV^T)_{ij}|\ge\frac h2t\sqrt{a/n}$." -/
theorem mr_graph_exceptional {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) (g : FrameVector n d)
    (hg : MrEvent h (mrAmplitude h η) X g) :
    ((mrExceptional h (mrAmplitude h η) X g).card : ℝ) ≤ mrCPrime * d / mrKappa0 h ∧
    mrKappa0 h * ((d : ℝ) / n) * mrAmplitude h η ^ 2 /
        ((h / 2) ^ 2 * mrAmplitude h η ^ 2 * ((d : ℝ) / n) / n) = (n : ℝ) / 50 ∧
    ∀ i, i ∉ mrExceptional h (mrAmplitude h η) X g →
      ((Finset.univ.filter (fun j =>
        h / 2 * mrAmplitude h η * Real.sqrt (((d : ℝ) / n) / n) ≤
          |(frameProjection (conditionedSeed X (mrAmplitude h η) g) -
            frameProjection (rowIndependentSeed X (mrAmplitude h η) g)) i j|)).card : ℝ) ≤
        (n : ℝ) / 50 ∧
      85 / 100 * (n : ℝ) ≤ ((Finset.univ.filter (fun j => j ≠ i ∧
        h / 2 * mrAmplitude h η * Real.sqrt (((d : ℝ) / n) / n) ≤
          |frameProjection (conditionedSeed X (mrAmplitude h η) g) i j|)).card : ℝ) := by
  sorry

/-- Proof of `thm:manyrow`, "Graph" (after whitening).

TeX: "Let $U=V(V^TV)^{-1/2}$, $P=UU^T$. By \cref{lem:align} (rows of $P-VV^T$) a row loses at
most $6a\theta^2t^4/((h/4)^2t^2a/n)\le n/20$ of these indices, so each $i\notin
\mathcal B_0$ has at least $0.8n$ indices $j\ne i$ with $P_{ij}^2\ge(h^2/16)at^2/n$.
Also $a/2\le P_{ii}\le2a$ and $\sum_{i\in \mathcal B_0}P_{ii}\le\frac14$." -/
theorem mr_graph_whitened {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) (g : FrameVector n d)
    (hg : MrEvent h (mrAmplitude h η) X g) :
    (∀ i, rowNormSq (frameProjection (polarFactor (conditionedSeed X (mrAmplitude h η) g)) -
        frameProjection (conditionedSeed X (mrAmplitude h η) g)) i ≤
      6 * ((d : ℝ) / n) * mrSmallTheta h ^ 2 * mrAmplitude h η ^ 4) ∧
    6 * ((d : ℝ) / n) * mrSmallTheta h ^ 2 * mrAmplitude h η ^ 4 /
        ((h / 4) ^ 2 * mrAmplitude h η ^ 2 * ((d : ℝ) / n) / n) ≤ (n : ℝ) / 20 ∧
    (∀ i, i ∉ mrExceptional h (mrAmplitude h η) X g →
      8 / 10 * (n : ℝ) ≤ ((Finset.univ.filter (fun j => j ≠ i ∧
        h ^ 2 / 16 * ((d : ℝ) / n) * mrAmplitude h η ^ 2 / n ≤
          frameProjection (polarFactor (conditionedSeed X (mrAmplitude h η) g)) i j ^ 2)).card :
            ℝ)) ∧
    (∀ i, (d : ℝ) / n / 2 ≤
        frameProjection (polarFactor (conditionedSeed X (mrAmplitude h η) g)) i i ∧
      frameProjection (polarFactor (conditionedSeed X (mrAmplitude h η) g)) i i ≤
        2 * ((d : ℝ) / n)) ∧
    ∑ i ∈ mrExceptional h (mrAmplitude h η) X g,
        frameProjection (polarFactor (conditionedSeed X (mrAmplitude h η) g)) i i ≤ 1 / 4 := by
  sorry

/-- Proof of `thm:manyrow`, "Graph" (barrier constant).

TeX: "\Cref{lem:core} with $\mathcal B=\mathcal B_0$, part (i) with $\vartheta=0.3$ and
$\gamma=h^2at^2/16$, and part (iii) with $\alpha=a$ (so $R=\frac8{3a}$,
$F_{\mathcal B}\le\frac43$) shows that
$H(L_P)\le\frac{7/3}{0.3\gamma}+\frac8{3a}\le C_{\rm mix}/(at^2)$." -/
theorem mr_barrier {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) (g : FrameVector n d)
    (hg : MrEvent h (mrAmplitude h η) X g) :
    2 / (3 * ((d : ℝ) / n)) * (2 * ((d : ℝ) / n)) ≤ 4 / 3 ∧
    Linear.FrameBarrierBound (polarFactor (conditionedSeed X (mrAmplitude h η) g))
      ((7 / 3) / (3 / 10 * (h ^ 2 * ((d : ℝ) / n) * mrAmplitude h η ^ 2 / 16)) +
        8 / (3 * ((d : ℝ) / n))) ∧
    (7 / 3) / (3 / 10 * (h ^ 2 * ((d : ℝ) / n) * mrAmplitude h η ^ 2 / 16)) +
        8 / (3 * ((d : ℝ) / n)) ≤ mrCmix h / ((d : ℝ) / n * mrAmplitude h η ^ 2) := by
  sorry

/-! ## Seed -/

/-- Proof of `thm:manyrow`, "Seed".

TeX: "$\fro{U-X}^2\le2d\delta^2+2t^2\fro Z^2\le42t^2d$, the diagonal error
is at most $2a\delta\le2\theta at^2\le at^2/(2\Theta)$, and the barrier constant
is at most $\Theta/(at^2)$. So $U$ is a $(\Theta,t)$-seed" -/
theorem mr_seed {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) (g : FrameVector n d)
    (hg : MrEvent h (mrAmplitude h η) X g) :
    sqDistance X (polarFactor (conditionedSeed X (mrAmplitude h η) g)) ≤
      2 * d * opNorm ((conditionedSeed X (mrAmplitude h η) g).transpose *
        conditionedSeed X (mrAmplitude h η) g - 1) ^ 2 +
      2 * mrAmplitude h η ^ 2 * frobSq (conditionedNoise X g) ∧
    2 * d * opNorm ((conditionedSeed X (mrAmplitude h η) g).transpose *
        conditionedSeed X (mrAmplitude h η) g - 1) ^ 2 +
      2 * mrAmplitude h η ^ 2 * frobSq (conditionedNoise X g) ≤
      42 * mrAmplitude h η ^ 2 * d ∧
    (∀ i, |frameProjection (polarFactor (conditionedSeed X (mrAmplitude h η) g)) i i -
        (d : ℝ) / n| ≤
      2 * ((d : ℝ) / n) * opNorm ((conditionedSeed X (mrAmplitude h η) g).transpose *
        conditionedSeed X (mrAmplitude h η) g - 1)) ∧
    2 * ((d : ℝ) / n) * opNorm ((conditionedSeed X (mrAmplitude h η) g).transpose *
        conditionedSeed X (mrAmplitude h η) g - 1) ≤
      2 * mrSmallTheta h * ((d : ℝ) / n) * mrAmplitude h η ^ 2 ∧
    2 * mrSmallTheta h * ((d : ℝ) / n) * mrAmplitude h η ^ 2 ≤
      (d : ℝ) / n * mrAmplitude h η ^ 2 / (2 * mrTheta h) ∧
    mrCmix h / ((d : ℝ) / n * mrAmplitude h η ^ 2) ≤
      mrTheta h / ((d : ℝ) / n * mrAmplitude h η ^ 2) ∧
    IsSeed X (polarFactor (conditionedSeed X (mrAmplitude h η) g)) (mrTheta h)
      (mrAmplitude h η) := by
  sorry

/-- Proof of `thm:manyrow`, final cost.

TeX: "\cref{cor:seed} gives an ENP frame within $3\Theta t^2d=(12\Theta/\theta)\eta d$
of $X$; thus $C_*=12\Theta/\theta$ works." -/
theorem mr_final_cost {h η : ℝ} (hh : 0 < h) (hη : 0 ≤ η) (d : ℝ) :
    3 * mrTheta h * mrAmplitude h η ^ 2 * d = mrCostStar h * η * d := by
  sorry

/-! ## The theorem -/

/-- `thm:manyrow` with the explicit constants of its proof: `c_* = θ t₁²/4`,
`C_* = 12Θ/θ`, and any `B` as chosen in the proof. -/
theorem thm_manyrow_explicit {h t₀ c₁ CM B : ℝ} (hh : 0 < h) (hh1 : h ≤ 1) (ht₀ : 0 < t₀)
    (ht₀1 : t₀ ≤ 1) (hc₁ : 0 < c₁) (hdense : MrDenseConclusion h t₀ c₁) (hCM : 0 ≤ CM)
    (hmom : RowMomentBound CM) (hB : 0 < B) (hBc : MrBChoice h c₁ B) :
    ∀ (n d : ℕ), 2 ≤ d → B * (d : ℝ) ^ 2 ≤ n → ∀ X : Frame n d, IsEqualNorm X →
      ∀ η : ℝ, IsNearlyParseval η X → 0 < η → η ≤ mrCStar h t₀ CM →
        HasCorrection X (mrCostStar h * η * (d : ℝ)) := by
  sorry

/-- `thm:manyrow`.

TeX: "There are absolute constants $B,c_*,C_*>0$ such that the following holds. Let
$2\le d$, $n\ge Bd^2$, let $X\in\R^{n\times d}$ have $\norm{x_i}^2=a=d/n$ for all
$i$, and suppose $\eta:=\opn{X^TX-I}$ satisfies $0<\eta\le c_*$. Then there is
an ENP frame $W$ with $\fro{X-W}^2\le C_*\eta d$."

Encoding: `IsNearlyParseval η X` (`η ≥ ‖XᵀX-I‖_op`), equivalent since the bound is monotone
in `η` and `η = 0` is the ENP case. -/
theorem thm_manyrow :
    ∃ B cs Cs : ℝ, 0 < B ∧ 0 < cs ∧ 0 < Cs ∧
      ∀ (n d : ℕ), 2 ≤ d → B * (d : ℝ) ^ 2 ≤ n → ∀ X : Frame n d, IsEqualNorm X →
        ∀ η : ℝ, IsNearlyParseval η X → 0 < η → η ≤ cs →
          HasCorrection X (Cs * η * (d : ℝ)) := by
  sorry

end

end Paulsen.Paper
