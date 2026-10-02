import Paulsen.Paper.ModerateSample

/-!
# Paper blueprint, Sections 5.6–5.7: the drifted retraction, the graph of the seed, and the
proof of `thm:moderate` with its constant recipe (`sections/moderate.tex`)

Ambient coordinates: `W = Z + (t/2) m_*` is `driftedNoise U ρ t g` (a horizontal frame), and
`U_t = (U + tVW) G^{-1/2}` with `G = I + t² WᵀW` is `retraction U W t`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-! ## 5.6 The drifted retraction -/

/-- `U_t = (U + tW) (I + t² WᵀW)^{-1/2}` (ambient `W`). -/
def retraction {n d : ℕ} (U W : Frame n d) (t : ℝ) : Frame n d :=
  (U + t • W) * invSqrt (1 + t ^ 2 • (W.transpose * W))

/-- `W = Z + (t/2) m_*`. -/
def driftedNoise {n d : ℕ} (U : Frame n d) (ρ t : ℝ) (g : FrameVector n d) : Frame n d :=
  moderateNoise U ρ g + (t / 2) • driftMean U ρ

/-- The drifted retraction `U_t` with `ρ = D² t²`. -/
def driftedFrame {n d : ℕ} (U : Frame n d) (D t : ℝ) (g : FrameVector n d) : Frame n d :=
  retraction U (driftedNoise U (D ^ 2 * t ^ 2) t g) t

/-- `𝖤 = P_t - P - tY` (with `Y = Y_Z` for the sample `Z`). -/
def retractionError {n d : ℕ} (U : Frame n d) (D t : ℝ) (g : FrameVector n d) :
    Matrix (Fin n) (Fin n) ℝ :=
  frameProjection (driftedFrame U D t g) - frameProjection U -
    t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g)

/-- The remainder `𝗋` of `lem:retraction`(c):
`diag P_t - a𝟙 - [(1-t²)(p-a𝟙) + 2t𝒜Z - t²b₀ + t²(q(Z)-Eq(Z)) + t³q(Z,m_*) + (t⁴/4)q(m_*)]`. -/
def retractionRemainder {n d : ℕ} (U : Frame n d) (D t : ℝ) (g : FrameVector n d)
    (i : Fin n) : ℝ :=
  (frameProjection (driftedFrame U D t g) i i - (d : ℝ) / n) -
    ((1 - t ^ 2) * (rowNormSq U i - (d : ℝ) / n) +
      2 * t * diagMap U (moderateNoise U (D ^ 2 * t ^ 2) g) i -
      t ^ 2 * baseBias U i +
      t ^ 2 * (horizontalQuadraticDiagonal U (moderateNoise U (D ^ 2 * t ^ 2) g) i -
        ∫ g', horizontalQuadraticDiagonal U (moderateNoise U (D ^ 2 * t ^ 2) g') i
          ∂gaussAmb n d) +
      t ^ 3 * Linear.horizontalQuadraticCross U (moderateNoise U (D ^ 2 * t ^ 2) g)
        (driftMean U (D ^ 2 * t ^ 2)) i +
      t ^ 4 / 4 * horizontalQuadraticDiagonal U (driftMean U (D ^ 2 * t ^ 2)) i)

/-- Setup of Section 5.6.

TeX: "Since $U^TV=0$, $(U+tVW)^T(U+tVW)=G$ and $U_t$ is Parseval." -/
theorem retraction_parseval {n d : ℕ} (U W : Frame n d) (hU : IsParseval U)
    (hUW : U.transpose * W = 0) (t : ℝ) :
    (U + t • W).transpose * (U + t • W) = 1 + t ^ 2 • (W.transpose * W) ∧
    IsParseval (retraction U W t) ∧
    frameProjection (retraction U W t) =
      (U + t • W) * (1 + t ^ 2 • (W.transpose * W))⁻¹ * (U + t • W).transpose := by
  sorry

/-- The conclusion of `lem:retraction` for a given constant `C_E`.

TeX: "(a) $\fro{U_t-U}^2\le C_Et^2d$;
(b) every row of $\mathsf E=P_t-P-tY$ satisfies
$\sum_j\mathsf E_{ij}^2\le at^2(D^{-2}+C_Et^2)$;
(c) with $\norm{\mathsf r}_\infty\le C_Eat^3$,
\[ \diag P_t-a\one=(1-t^2)(p-a\one)+2t\mathcal AZ-t^2b_0+t^2\bigl(q(Z)-\E q(Z)\bigr)
 +t^3q(Z,m_*)+\tfrac{t^4}4q(m_*)+\mathsf r ; \]
(d) $\norm{\diag P_t-a\one}_\infty\le at^2\bigl(\frac{\eps}{t^2}
+6D\sqrt{\log(2n)/d}+\frac{12\eps}d+\eta'+\frac{40}D+\frac1{2D^2}+C_Et\bigr)$."

(a)–(c) use (S1); (d) also uses (S2) with parameter `η'` and `|p_i - a| ≤ εa`. -/
def IsRetractionConstant (CE : ℝ) : Prop :=
  ∀ (n d : ℕ) (U : Frame n d) (D t : ℝ) (g : FrameVector n d),
    ModerateStanding U → 12 ≤ D → 0 < t → t ≤ 1 → SampleS1 U (D ^ 2 * t ^ 2) g →
      sqDistance (driftedFrame U D t g) U ≤ CE * t ^ 2 * d ∧
      (∀ i, rowNormSq (retractionError U D t g) i ≤
        (d : ℝ) / n * t ^ 2 * (1 / D ^ 2 + CE * t ^ 2)) ∧
      (∀ i, |retractionRemainder U D t g i| ≤ CE * ((d : ℝ) / n) * t ^ 3) ∧
      ∀ ε η' : ℝ, 0 ≤ ε → ε ≤ 1 / 2 → IsNearlyEqualNorm ε U →
        SampleS2 U (D ^ 2 * t ^ 2) η' g → ∀ i,
          |frameProjection (driftedFrame U D t g) i i - (d : ℝ) / n| ≤
            (d : ℝ) / n * t ^ 2 * (ε / t ^ 2 + 6 * D * Real.sqrt (Real.log (2 * n) / d) +
              12 * ε / d + η' + 40 / D + 1 / (2 * D ^ 2) + CE * t)

/-- `lem:retraction`.

TeX: "There is an absolute $C_E$ (depending only on the bounds in \ref{S1} and on
$D\ge12$) such that: (a) [...] (b) [...] (c) [...] (d) [...]" -/
theorem lem_retraction : ∃ CE : ℝ, 0 < CE ∧ IsRetractionConstant CE := by
  sorry

/-- Proof of `lem:retraction`: the explicit auxiliary bounds.

TeX: "By \cref{lem:mean}, $\frac t2\opn{m_*}\le\frac t2\fro{m_*}\le\sqrt{a/2}/D\le\frac1{24}$,
so with \ref{S1}: $\opn W\le17$, $\fro W\le17\sqrt d$,
$\norm{W^Tv_i}\le2\sqrt a$, $\norm{Wu_i}\le17\sqrt{3a/2}$, and
$\norm{(Y_{m_*})_i}^2\le\opn{m_*}^2\le2a/\rho$. Hence $\opn{G^{-1}-I}$ and
$\opn{G^{-1/2}-I}$ are at most $289t^2$, $\opn{U+tVW}\le18$ and
$\norm{u_i+tW^Tv_i}\le4\sqrt a$." -/
theorem lem_retraction_aux {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {D t : ℝ}
    (hD : 12 ≤ D) (ht : 0 < t) (ht1 : t ≤ 1) (g : FrameVector n d)
    (hS1 : SampleS1 U (D ^ 2 * t ^ 2) g) :
    t / 2 * opNorm (driftMean U (D ^ 2 * t ^ 2)) ≤
        t / 2 * Real.sqrt (frobSq (driftMean U (D ^ 2 * t ^ 2))) ∧
    t / 2 * Real.sqrt (frobSq (driftMean U (D ^ 2 * t ^ 2))) ≤
        Real.sqrt (((d : ℝ) / n) / 2) / D ∧
    Real.sqrt (((d : ℝ) / n) / 2) / D ≤ 1 / 24 ∧
    opNorm (driftedNoise U (D ^ 2 * t ^ 2) t g) ≤ 17 ∧
    Real.sqrt (frobSq (driftedNoise U (D ^ 2 * t ^ 2) t g)) ≤ 17 * Real.sqrt d ∧
    (∀ i, Real.sqrt (rowNormSq (driftedNoise U (D ^ 2 * t ^ 2) t g) i) ≤
      2 * Real.sqrt ((d : ℝ) / n)) ∧
    (∀ i, Real.sqrt (rowNormSq (U * (driftedNoise U (D ^ 2 * t ^ 2) t g).transpose) i) ≤
      17 * Real.sqrt (3 * ((d : ℝ) / n) / 2)) ∧
    (∀ i, rowNormSq (tangentY U (driftMean U (D ^ 2 * t ^ 2))) i ≤
      opNorm (driftMean U (D ^ 2 * t ^ 2)) ^ 2) ∧
    opNorm (driftMean U (D ^ 2 * t ^ 2)) ^ 2 ≤ 2 * ((d : ℝ) / n) / (D ^ 2 * t ^ 2) ∧
    opNorm ((1 + t ^ 2 • ((driftedNoise U (D ^ 2 * t ^ 2) t g).transpose *
      driftedNoise U (D ^ 2 * t ^ 2) t g))⁻¹ - 1) ≤ 289 * t ^ 2 ∧
    opNorm (invSqrt (1 + t ^ 2 • ((driftedNoise U (D ^ 2 * t ^ 2) t g).transpose *
      driftedNoise U (D ^ 2 * t ^ 2) t g)) - 1) ≤ 289 * t ^ 2 ∧
    opNorm (U + t • driftedNoise U (D ^ 2 * t ^ 2) t g) ≤ 18 ∧
    ∀ i, Real.sqrt (rowNormSq (U + t • driftedNoise U (D ^ 2 * t ^ 2) t g) i) ≤
      4 * Real.sqrt ((d : ℝ) / n) := by
  sorry

/-- Proof of `lem:retraction`(b): the decomposition of `𝖤`.

TeX: "$\mathsf E=\frac{t^2}2Y_{m_*}+\mathsf E'$ with
$\mathsf E'=P_t-P-tY_W=(U+tVW)(G^{-1}-I)(U+tVW)^T+t^2VWW^TV^T$, [...]
The rows of $\frac{t^2}2Y_{m_*}$ have squared norm at
most $\frac{t^4}4\cdot\frac{2a}\rho=\frac{at^2}{2D^2}$." -/
theorem lem_retraction_error {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {D t : ℝ}
    (hD : 0 < D) (ht : 0 < t) (g : FrameVector n d) :
    let W := driftedNoise U (D ^ 2 * t ^ 2) t g
    retractionError U D t g = (t ^ 2 / 2) • tangentY U (driftMean U (D ^ 2 * t ^ 2)) +
      ((U + t • W) * ((1 + t ^ 2 • (W.transpose * W))⁻¹ - 1) * (U + t • W).transpose +
        t ^ 2 • (W * W.transpose)) ∧
    t ^ 4 / 4 * (2 * ((d : ℝ) / n) / (D ^ 2 * t ^ 2)) = (d : ℝ) / n * t ^ 2 / (2 * D ^ 2) := by
  sorry

/-- Proof of `lem:retraction`(c): the exact diagonal expansion.

TeX: "Let $\xi_i=u_i+tW^Tv_i$, the $i$th row of $U+tVW$. Inserting
$G^{-1}=I-t^2W^TW+t^4(W^TW)^2G^{-1}$ into $(P_t)_{ii}=\xi_i^TG^{-1}\xi_i$ and using
$u_i^TW^Tv_i=(\mathcal AW)_i$,
\[ (P_t)_{ii}=p_i+2t(\mathcal AW)_i+t^2q_i(W)-2t^3\ip{Wu_i}{WW^Tv_i}
 -t^4\norm{WW^Tv_i}^2+t^4\xi_i^T(W^TW)^2G^{-1}\xi_i , \]
[...] Now $2t\mathcal AW=2t\mathcal AZ+t^2\mathcal
Am_*$, $q(W)=q(Z)+tq(Z,m_*)+\frac{t^2}4q(m_*)$" -/
theorem lem_retraction_expansion {n d : ℕ} (U W : Frame n d) (hU : IsParseval U)
    (hUW : U.transpose * W = 0) (t : ℝ) (i : Fin n) :
    frameProjection (retraction U W t) i i =
      rowNormSq U i + 2 * t * diagMap U W i + t ^ 2 * horizontalQuadraticDiagonal U W i -
      2 * t ^ 3 * ∑ k, (U * W.transpose) i k * (W * W.transpose) i k -
      t ^ 4 * rowNormSq (W * W.transpose) i +
      t ^ 4 * ((U + t • W) * (W.transpose * W) ^ 2 * (1 + t ^ 2 • (W.transpose * W))⁻¹ *
        (U + t • W).transpose : Matrix (Fin n) (Fin n) ℝ) i i := by
  sorry

/-- Proof of `lem:retraction`(c): the effect of the drift on `𝒜` and `q`. -/
theorem lem_retraction_drift_split {n d : ℕ} (U H m : Frame n d) (t : ℝ) (i : Fin n) :
    2 * t * diagMap U (H + (t / 2) • m) i = 2 * t * diagMap U H i + t ^ 2 * diagMap U m i ∧
    horizontalQuadraticDiagonal U (H + (t / 2) • m) i =
      horizontalQuadraticDiagonal U H i + t * Linear.horizontalQuadraticCross U H m i +
        t ^ 2 / 4 * horizontalQuadraticDiagonal U m i := by
  sorry

/-- Proof of `lem:retraction`(d): the individual terms.

TeX: "In (c): $(1-t^2)\norm{p-a\one}_\infty\le\eps a$;
$2t\norm{\mathcal AZ}_\infty\le6tD t\sqrt{a\log(2n)/n}$ by \ref{S2}, which is
$6Dat^2\sqrt{\log(2n)/d}$; $t^2\norm{b_0}_\infty\le12\eps t^2/n$; the fluctuation is
at most $\eta'at^2$; by~\eqref{eq:q-cs} and \ref{S1},
$t^3|q_i(Z,m_*)|\le t^3\sqrt{800a}\sqrt{2a/\rho}=40at^2/D$ and
$\frac{t^4}4|q_i(m_*)|\le\frac{t^4}4\cdot\frac{2a}\rho=\frac{at^2}{2D^2}$." -/
theorem lem_retraction_terms {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U)
    {ε D t η' : ℝ} (hε0 : 0 ≤ ε) (hε : ε ≤ 1 / 2) (hnear : IsNearlyEqualNorm ε U)
    (hD : 12 ≤ D) (ht : 0 < t) (ht1 : t ≤ 1) (g : FrameVector n d)
    (hS1 : SampleS1 U (D ^ 2 * t ^ 2) g) (hS2 : SampleS2 U (D ^ 2 * t ^ 2) η' g) (i : Fin n) :
    (1 - t ^ 2) * |rowNormSq U i - (d : ℝ) / n| ≤ ε * ((d : ℝ) / n) ∧
    2 * t * |diagMap U (moderateNoise U (D ^ 2 * t ^ 2) g) i| ≤
      6 * t * D * t * Real.sqrt ((d : ℝ) / n * Real.log (2 * n) / n) ∧
    6 * t * D * t * Real.sqrt ((d : ℝ) / n * Real.log (2 * n) / n) =
      6 * D * ((d : ℝ) / n) * t ^ 2 * Real.sqrt (Real.log (2 * n) / d) ∧
    t ^ 2 * |baseBias U i| ≤ 12 * ε * t ^ 2 / n ∧
    t ^ 3 * |Linear.horizontalQuadraticCross U (moderateNoise U (D ^ 2 * t ^ 2) g)
        (driftMean U (D ^ 2 * t ^ 2)) i| ≤
      t ^ 3 * Real.sqrt (800 * ((d : ℝ) / n)) *
        Real.sqrt (2 * ((d : ℝ) / n) / (D ^ 2 * t ^ 2)) ∧
    t ^ 3 * Real.sqrt (800 * ((d : ℝ) / n)) *
        Real.sqrt (2 * ((d : ℝ) / n) / (D ^ 2 * t ^ 2)) = 40 * ((d : ℝ) / n) * t ^ 2 / D ∧
    t ^ 4 / 4 * |horizontalQuadraticDiagonal U (driftMean U (D ^ 2 * t ^ 2)) i| ≤
      t ^ 4 / 4 * (2 * ((d : ℝ) / n) / (D ^ 2 * t ^ 2)) ∧
    t ^ 4 / 4 * (2 * ((d : ℝ) / n) / (D ^ 2 * t ^ 2)) = (d : ℝ) / n * t ^ 2 / (2 * D ^ 2) := by
  sorry

/-! ## The graph of the seed -/

/-- `C_core = 10(1 + b_max)/h² + 32 √b_max` (with `h = 1/500`). -/
def coreConstant : ℝ := 10 * (1 + bMax) / sampleH ^ 2 + 32 * Real.sqrt bMax

/-- The conclusion of `lem:seed-graph` for constants `t_*`, `C_core`. -/
def SeedGraphConclusion (tstar Ccore : ℝ) : Prop :=
  ∀ A : ℝ → ℝ, SampleThreshold A → ∀ η' : ℝ, 0 < η' → η' ≤ 1 / 32 →
    ∀ (n d : ℕ) (U : Frame n d), ModerateStanding U → A η' * Real.log (2 * n) ≤ d →
      ∀ D : ℝ, 13 / sampleH ≤ D → ∀ t : ℝ, 0 < t → t ≤ tstar →
        ((exceptionalSet U (D ^ 2 * t ^ 2)).card : ℝ) ≤ (n : ℝ) / 10 →
        ∀ g, GoodSample U (D ^ 2 * t ^ 2) t sampleH η' g →
          Linear.FrameBarrierBound (driftedFrame U D t g) (Ccore / ((d : ℝ) / n * t ^ 2))

/-- `lem:seed-graph` (Graph of the seed).

TeX: "There are absolute $t_*\in(0,1]$ and $C_{\rm core}$ such that the following
holds. Let $\eta'\le\frac1{32}$, $d\ge A_{\eta'}\log(2n)$, $D\ge13/h$,
$b\le n/10$ and $t\le t_*$, and let $Z$ satisfy \ref{S1}--\ref{S4}. Then
$H(L_{P_t})\le C_{\rm core}/(at^2)$."

(`h = sampleH = 1/500` and `A_{η'}` are those of `lem:sample`.) -/
theorem lem_seed_graph :
    ∃ tstar Ccore : ℝ, 0 < tstar ∧ tstar ≤ 1 ∧ SeedGraphConclusion tstar Ccore := by
  sorry

/-- `lem:seed-graph` with the explicit constants of its proof: any `t_* ≤ 1` with
`t_*² ≤ h²/(160 C_E)` and `t_*² ≤ 1/(128 C_E)`, and
`C_core = 10(1+b_max)/h² + 32√b_max`. -/
theorem lem_seed_graph_explicit {CE tstar : ℝ} (hCE : 0 < CE) (hret : IsRetractionConstant CE)
    (ht0 : 0 < tstar) (ht1 : tstar ≤ 1) (htCE : tstar ^ 2 ≤ sampleH ^ 2 / (160 * CE))
    (htCE' : tstar ^ 2 ≤ 1 / (128 * CE)) :
    SeedGraphConclusion tstar coreConstant := by
  sorry

/-- Proof of `lem:seed-graph`, "Core".

TeX: "In a row $i\notin\mathfrak B$, by \cref{lem:retraction}(b), at most
$at^2(D^{-2}+C_Et^2)\big/\bigl(\frac{h^2}4\frac{at^2}n\bigr)\le0.05n$ indices have
$|\mathsf E_{ij}|\ge\frac h2t\sqrt{a/n}$, once $D\ge13/h$ and
$t^2\le h^2/(160C_E)$. With \ref{S3}, every $i\notin\mathfrak B$ has at least
$0.9n$ indices $j\ne i$ with $(P_t)_{ij}^2\ge\frac{h^2}4\frac{at^2}n$." -/
theorem seed_graph_core {CE : ℝ} (hCE : 0 < CE) (hret : IsRetractionConstant CE) {η' : ℝ}
    {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) {D t : ℝ} (hD : 13 / sampleH ≤ D)
    (ht : 0 < t) (ht1 : t ≤ 1) (htCE : t ^ 2 ≤ sampleH ^ 2 / (160 * CE)) (g : FrameVector n d)
    (hg : GoodSample U (D ^ 2 * t ^ 2) t sampleH η' g) :
    (d : ℝ) / n * t ^ 2 * (1 / D ^ 2 + CE * t ^ 2) /
        (sampleH ^ 2 / 4 * ((d : ℝ) / n * t ^ 2 / n)) ≤ 5 / 100 * n ∧
    ∀ i, i ∉ exceptionalSet U (D ^ 2 * t ^ 2) →
      ((Finset.univ.filter (fun j => sampleH / 2 * t * Real.sqrt (((d : ℝ) / n) / n) ≤
        |retractionError U D t g i j|)).card : ℝ) ≤ 5 / 100 * n ∧
      9 / 10 * (n : ℝ) ≤ ((Finset.univ.filter (fun j => j ≠ i ∧
        sampleH ^ 2 / 4 * ((d : ℝ) / n * t ^ 2 / n) ≤
          frameProjection (driftedFrame U D t g) i j ^ 2)).card : ℝ) := by
  sorry

/-- Proof of `lem:seed-graph`, "Block".

TeX: "For $x$ supported on $\mathfrak B$, \cref{lem:expected-graph},
$x^T\mathsf Kx\ge(n-b)\norm x^2$ and \ref{S4} give
\[ x^T\Lap(P+tY)x\ge\Bigl(1-\eta'-t^2\bigl(\tfrac2n+\tfrac8d\bigr)-\tfrac8{D^2}\Bigr)x^TLx
 +at^2\Bigl(\tfrac14\bigl(1-\tfrac bn\bigr)-2\eta'\Bigr)\norm x^2
 \ge\frac{at^2}8\norm x^2 , \]
since the first coefficient is positive and $\frac14\cdot\frac9{10}-\frac1{16}\ge\frac18$.
By \eqref{eq:lap-basic} and \cref{lem:retraction}(b),
$L_{P_t}=\Lap(P+tY+\mathsf E)\succeq\frac12\Lap(P+tY)-2at^2(D^{-2}+C_Et^2)I$,
which is at least $\frac{at^2}{32}$ on vectors supported on $\mathfrak B$ once
$t^2\le1/(128C_E)$." -/
theorem seed_graph_block {CE : ℝ} (hCE : 0 < CE) (hret : IsRetractionConstant CE) {η' : ℝ}
    (hη' : 0 < η') (hη'1 : η' ≤ 1 / 32) {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U)
    (hd : (10 : ℝ) ^ 6 ≤ d) {D t : ℝ} (hD : 13 / sampleH ≤ D) (ht : 0 < t) (ht1 : t ≤ 1)
    (htCE' : t ^ 2 ≤ 1 / (128 * CE))
    (hb : ((exceptionalSet U (D ^ 2 * t ^ 2)).card : ℝ) ≤ (n : ℝ) / 10)
    (g : FrameVector n d) (hg : GoodSample U (D ^ 2 * t ^ 2) t sampleH η' g) :
    0 < 1 - η' - t ^ 2 * (2 / n + 8 / d) - 8 / D ^ 2 ∧
    (1 / 8 : ℝ) ≤ 1 / 4 * (9 / 10) - 1 / 16 ∧
    ∀ x : Fin n → ℝ, (∀ j, j ∉ exceptionalSet U (D ^ 2 * t ^ 2) → x j = 0) →
      (d : ℝ) / n * ((n : ℝ) - (exceptionalSet U (D ^ 2 * t ^ 2)).card) * vectorNormSq x ≤
          (d : ℝ) / n * matrixQuadratic (completeLaplacian n) x ∧
      (1 - η' - t ^ 2 * (2 / n + 8 / d) - 8 / D ^ 2) *
          matrixQuadratic (projectionLaplacian (frameProjection U)) x +
        (d : ℝ) / n * t ^ 2 *
          (1 / 4 * (1 - ((exceptionalSet U (D ^ 2 * t ^ 2)).card : ℝ) / n) - 2 * η') *
          vectorNormSq x ≤
        matrixQuadratic (sqLaplacian (frameProjection U +
          t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g))) x ∧
      (d : ℝ) / n * t ^ 2 / 8 * vectorNormSq x ≤
        matrixQuadratic (sqLaplacian (frameProjection U +
          t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g))) x ∧
      (1 / 2) * matrixQuadratic (sqLaplacian (frameProjection U +
          t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g))) x -
          2 * ((d : ℝ) / n) * t ^ 2 * (1 / D ^ 2 + CE * t ^ 2) * vectorNormSq x ≤
        matrixQuadratic (projectionLaplacian (frameProjection (driftedFrame U D t g))) x ∧
      (d : ℝ) / n * t ^ 2 / 32 * vectorNormSq x ≤
        matrixQuadratic (projectionLaplacian (frameProjection (driftedFrame U D t g))) x := by
  sorry

/-- Proof of `lem:seed-graph`, "Barrier".

TeX: "\Cref{lem:core} with $\mathcal B=\mathfrak B$, part (i) with
$\vartheta=0.4$, $\gamma=h^2at^2/4$, and part (ii) with $\lambda=at^2/32$, gives
$H(L_{P_t})\le\frac{1+b}{0.1h^2at^2}+\frac{32\sqrt b}{at^2}$. Put
$C_{\rm core}=10(1+b_{\max})/h^2+32\sqrt{b_{\max}}$." -/
theorem seed_graph_barrier {CE : ℝ} (hCE : 0 < CE) (hret : IsRetractionConstant CE) {η' : ℝ}
    (hη' : 0 < η') (hη'1 : η' ≤ 1 / 32) {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U)
    (hd : (10 : ℝ) ^ 6 ≤ d) {D t : ℝ} (hD : 13 / sampleH ≤ D) (ht : 0 < t) (ht1 : t ≤ 1)
    (htCE : t ^ 2 ≤ sampleH ^ 2 / (160 * CE)) (htCE' : t ^ 2 ≤ 1 / (128 * CE))
    (hb : ((exceptionalSet U (D ^ 2 * t ^ 2)).card : ℝ) ≤ (n : ℝ) / 10)
    (g : FrameVector n d) (hg : GoodSample U (D ^ 2 * t ^ 2) t sampleH η' g) :
    Linear.FrameBarrierBound (driftedFrame U D t g)
      ((1 + ((exceptionalSet U (D ^ 2 * t ^ 2)).card : ℝ)) /
          (1 / 10 * sampleH ^ 2 * ((d : ℝ) / n) * t ^ 2) +
        32 * Real.sqrt ((exceptionalSet U (D ^ 2 * t ^ 2)).card : ℝ) / ((d : ℝ) / n * t ^ 2)) ∧
    (1 + ((exceptionalSet U (D ^ 2 * t ^ 2)).card : ℝ)) /
          (1 / 10 * sampleH ^ 2 * ((d : ℝ) / n) * t ^ 2) +
        32 * Real.sqrt ((exceptionalSet U (D ^ 2 * t ^ 2)).card : ℝ) / ((d : ℝ) / n * t ^ 2) ≤
      coreConstant / ((d : ℝ) / n * t ^ 2) := by
  sorry

/-! ## 5.7 Proof of `thm:moderate` -/

/-- `Θ = max{2, C_core, C_E}`. -/
def modTheta (CE : ℝ) : ℝ := max 2 (max coreConstant CE)

/-- `K₀ = 12Θ` (so `t² = K₀ ε`). -/
def modK0 (CE : ℝ) : ℝ := 12 * modTheta CE

/-- `η' = min{1/32, 1/(12Θ)}`. -/
def modEtaPrime (CE : ℝ) : ℝ := min (1 / 32) (1 / (12 * modTheta CE))

/-- `C_m = 36 Θ²`. -/
def modCm (CE : ℝ) : ℝ := 36 * modTheta CE ^ 2

/-- The choices of `D`, `A`, `ε₀` in the proof of `thm:moderate`.

TeX: "choose, in this order: $D\ge\max\{13/h,
500\Theta\}$, so that $\frac{40}D+\frac1{2D^2}\le\frac1{12\Theta}$; $K_0=12\Theta$
and $\eta'=\min\{\frac1{32},\frac1{12\Theta}\}$; $A\ge A_{\eta'}$ so large that
$d\ge A\log(2n)$ implies $6D\sqrt{\log(2n)/d}\le\frac1{12\Theta}$ and
$b_{\max}\le n/10$; and $\eps_0\le\frac12$ so that $t=\sqrt{K_0\eps}$ satisfies
$t\le t_*$, $C_Et\le\frac1{12\Theta}$ and $12\eps\le\frac1{12\Theta}$ for
$\eps\le\eps_0$." -/
structure ModerateChoice (CE tstar : ℝ) (Afun : ℝ → ℝ) (D A ε₀ : ℝ) : Prop where
  D_ge : max (13 / sampleH) (500 * modTheta CE) ≤ D
  A_ge : Afun (modEtaPrime CE) ≤ A
  A_large : ∀ n d : ℕ, 1 ≤ n → 2 * d ≤ n → A * Real.log (2 * n) ≤ d →
    6 * D * Real.sqrt (Real.log (2 * n) / d) ≤ 1 / (12 * modTheta CE) ∧ bMax ≤ (n : ℝ) / 10
  ε₀_pos : 0 < ε₀
  ε₀_le : ε₀ ≤ 1 / 2
  ε₀_small : ∀ ε : ℝ, 0 < ε → ε ≤ ε₀ →
    Real.sqrt (modK0 CE * ε) ≤ tstar ∧
    CE * Real.sqrt (modK0 CE * ε) ≤ 1 / (12 * modTheta CE) ∧
    12 * ε ≤ 1 / (12 * modTheta CE)

/-- The choices in the proof of `thm:moderate` can be made. -/
theorem moderate_choice_exists {CE tstar : ℝ} (hCE : 0 < CE) (htstar : 0 < tstar)
    (Afun : ℝ → ℝ) : ∃ D A ε₀ : ℝ, 0 < A ∧ ModerateChoice CE tstar Afun D A ε₀ := by
  sorry

/-- Proof of `thm:moderate`, the drift numerics.

TeX: "$D\ge\max\{13/h, 500\Theta\}$, so that $\frac{40}D+\frac1{2D^2}\le\frac1{12\Theta}$"
-/
theorem moderate_drift_numerics {Θ D : ℝ} (hΘ : 2 ≤ Θ) (hD : 500 * Θ ≤ D) :
    40 / D + 1 / (2 * D ^ 2) ≤ 1 / (12 * Θ) := by
  sorry

/-- Proof of `thm:moderate`, "Seed".

TeX: "With $t^2=K_0\eps$, \cref{lem:retraction}(d) bounds the diagonal
error of $P_t$ by $at^2\cdot\frac6{12\Theta}=\frac{at^2}{2\Theta}$;
\cref{lem:seed-graph} bounds the barrier constant by $\Theta/(at^2)$; and
\cref{lem:retraction}(a) bounds $\fro{U_t-U}^2$ by $\Theta t^2d$. So $U_t$ is a
$(\Theta,t)$-seed for $U$, and \cref{cor:seed} gives an ENP frame $\widehat U$
with $\fro{\widehat U-U}^2\le3\Theta t^2d=36\Theta^2\eps d$." -/
theorem moderate_seed {CE tstar D A ε₀ : ℝ} {Afun : ℝ → ℝ} (hA : SampleThreshold Afun)
    (hCE : 0 < CE) (hret : IsRetractionConstant CE) (ht0 : 0 < tstar) (ht1 : tstar ≤ 1)
    (hsg : SeedGraphConclusion tstar coreConstant)
    (hch : ModerateChoice CE tstar Afun D A ε₀) {n d : ℕ} (hd : 0 < d) (hdn : 2 * d ≤ n)
    (hrank : A * Real.log (2 * n) ≤ d) {ε : ℝ} (hε : 0 < ε) (hεle : ε ≤ ε₀) (U : Frame n d)
    (hU : IsParseval U) (hnear : IsNearlyEqualNorm ε U) :
    ε / Real.sqrt (modK0 CE * ε) ^ 2 = 1 / (12 * modTheta CE) ∧
    (d : ℝ) / n * Real.sqrt (modK0 CE * ε) ^ 2 * (6 / (12 * modTheta CE)) =
      (d : ℝ) / n * Real.sqrt (modK0 CE * ε) ^ 2 / (2 * modTheta CE) ∧
    3 * modTheta CE * Real.sqrt (modK0 CE * ε) ^ 2 * d = modCm CE * ε * d ∧
    ∃ g : FrameVector n d, IsSeed U (driftedFrame U D (Real.sqrt (modK0 CE * ε)) g)
      (modTheta CE) (Real.sqrt (modK0 CE * ε)) := by
  sorry

/-- `thm:moderate` with the explicit constants of its proof: `C_m = 36Θ²`,
`Θ = max{2, C_core, C_E}`, and `A`, `ε₀` as chosen in the proof. -/
theorem thm_moderate_explicit {CE tstar D A ε₀ : ℝ} {Afun : ℝ → ℝ}
    (hA : SampleThreshold Afun) (hCE : 0 < CE) (hret : IsRetractionConstant CE)
    (ht0 : 0 < tstar) (ht1 : tstar ≤ 1) (hsg : SeedGraphConclusion tstar coreConstant)
    (hch : ModerateChoice CE tstar Afun D A ε₀) :
    Linear.ModerateParsevalBound A ε₀ (modCm CE) := by
  sorry

/-- `thm:moderate`.

TeX: "There are absolute constants $A,C_m,\eps_0>0$ such that the following holds.
Let $U\in\R^{n\times d}$ be Parseval with $2d\le n$, $d\ge A\log(2n)$, and
$|\norm{u_i}^2-a|\le\eps a$ for all $i$, where $0<\eps\le\eps_0$. Then there is
an ENP frame $\widehat U$ with $\fro{\widehat U-U}^2\le C_m\eps d$."

`Linear.ModerateParsevalBound A ε₀ C` is exactly this statement (with `1 ≤ d`). -/
theorem thm_moderate :
    ∃ A Cm ε₀ : ℝ, 0 < A ∧ 0 < Cm ∧ 0 < ε₀ ∧ Linear.ModerateParsevalBound A ε₀ Cm := by
  sorry

end

end Paulsen.Paper
