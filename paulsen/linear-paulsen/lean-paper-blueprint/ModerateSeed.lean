import Paulsen.Paper.ModerateSample
import Paulsen.Paper.SeedAuxRetr

/-!
# Paper blueprint, Sections 5.6–5.7: the drifted retraction, the graph of the seed, and the
proof of `thm:moderate` with its constant recipe (`sections/moderate.tex`)

Ambient coordinates: `W = Z + (t/2) m_*` is `driftedNoise U ρ t g` (a horizontal frame), and
`U_t = (U + tVW) G^{-1/2}` with `G = I + t² WᵀW` is `retraction U W t`.

All proofs are complete (modulo the upstream paper lemmas of `Moderate.lean` and
`Toolbox.lean` that they cite).  The generic operator-norm calculus and the deterministic
bookkeeping of the retraction are in the helper files `SeedAuxOp.lean` and `SeedAuxRetr.lean`.
The proof-step lemmas are placed before the paper items they prove (`lem_retraction_aux` …
`lem_retraction_terms` before `lem_retraction`; `seed_graph_core`, `seed_graph_block`,
`seed_graph_barrier` before `lem_seed_graph_explicit` and `lem_seed_graph`).  The absolute
constant of `lem:retraction` is `C_E = 2·10⁹`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen Paulsen.Paper.SeedAux
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

/-! ### Standing facts used throughout (proof helpers) -/

/-- Numerical consequences of the standing assumptions. -/
theorem standing_basics {n d : ℕ} {U : Frame n d} (hs : ModerateStanding U) :
    (0 : ℝ) < d ∧ (0 : ℝ) < n ∧ 0 < (d : ℝ) / n ∧ (d : ℝ) / n ≤ 1 / 2 ∧ (1 : ℝ) ≤ d ∧
      (∀ i, 0 < rowNormSq U i) ∧ IsNearlyEqualNorm (1 / 2) U := by
  have hd : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos
  have hd1 : (1 : ℝ) ≤ d := by exact_mod_cast hs.pos
  have hdn : (2 : ℝ) * d ≤ n := by exact_mod_cast hs.density
  have hn : (0 : ℝ) < n := by linarith
  have ha : 0 < (d : ℝ) / n := div_pos hd hn
  refine ⟨hd, hn, ha, ?_, hd1, fun i => lt_of_lt_of_le (by positivity) (hs.rows i).1, ?_⟩
  · rw [div_le_iff₀ hn]; linarith
  · intro i
    have h := hs.rows i
    constructor <;> linarith

/-- The facts on `m_*` (from `lem:mean` with `ε = 1/2`, and `Y_m` rows from Section 5.1). -/
theorem drift_basics {n d : ℕ} {U : Frame n d} (hs : ModerateStanding U) {ρ : ℝ}
    (hρ : 0 < ρ) :
    U.transpose * driftMean U ρ = 0 ∧
    frobSq (driftMean U ρ) ≤ 2 * ((d : ℝ) / n) / ρ ∧
    opNorm (driftMean U ρ) ^ 2 ≤ 2 * ((d : ℝ) / n) / ρ ∧
    (∀ i, rowNormSq (tangentY U (driftMean U ρ)) i ≤ 2 * ((d : ℝ) / n) / ρ) ∧
    (∀ i, ∫ g, horizontalQuadraticDiagonal U (moderateNoise U ρ g) i ∂gaussAmb n d =
      (d : ℝ) / n - rowNormSq U i - baseBias U i - residualBias U ρ i) := by
  obtain ⟨-, -, -, -, -, -, hhalf⟩ := standing_basics hs
  obtain ⟨hEq, -, -, hUm, hfrob⟩ := lem_mean U hs (by norm_num) le_rfl hhalf hρ
  have hop : opNorm (driftMean U ρ) ^ 2 ≤ 2 * ((d : ℝ) / n) / ρ :=
    (opNorm_sq_le_frobSq _).trans hfrob
  refine ⟨hUm, hfrob, hop, fun i => ?_, hEq⟩
  exact ((tangentY_facts U _ hs.parseval hUm).2.1 i).trans hop

/-- `|b₀| ≤ 12ε/n` for every `ε ∈ [0, 1/2]` (for `ε = 0` by letting `ε' ↓ 0` in `lem:mean`). -/
theorem baseBias_bound {n d : ℕ} {U : Frame n d} (hs : ModerateStanding U) {ε : ℝ}
    (hε0 : 0 ≤ ε) (hε : ε ≤ 1 / 2) (hnear : IsNearlyEqualNorm ε U) (i : Fin n) :
    |baseBias U i| ≤ 12 * ε / n := by
  obtain ⟨-, hn, ha, -, -, -, -⟩ := standing_basics hs
  have hmono : ∀ ε', ε ≤ ε' → IsNearlyEqualNorm ε' U := by
    intro ε' hε' j
    have := hnear j
    constructor <;> nlinarith [this.1, this.2]
  have hall : ∀ ε', 0 < ε' → ε ≤ ε' → ε' ≤ 1 / 2 → |baseBias U i| ≤ 12 * ε' / n := by
    intro ε' h1 h2 h3
    exact (lem_mean U hs h1 h3 (hmono ε' h2) (by norm_num : (0 : ℝ) < 1)).2.1 i
  rcases hε0.lt_or_eq with hpos | hzero
  · exact hall ε hpos le_rfl hε
  · subst hzero
    by_contra hcon
    push Not at hcon
    set b := |baseBias U i| with hb
    have hb0 : 0 < b := by simpa using hcon
    set ε' := min (1 / 2) (b * n / 24) with hε'
    have hε'pos : 0 < ε' := lt_min (by norm_num) (by positivity)
    have h := hall ε' hε'pos hε'pos.le (min_le_left _ _)
    have h2 : 12 * ε' / n ≤ b / 2 := by
      rw [div_le_iff₀ hn]
      have := min_le_right (1 / 2 : ℝ) (b * n / 24)
      nlinarith
    linarith

/-- Setup of Section 5.6.

TeX: "Since $U^TV=0$, $(U+tVW)^T(U+tVW)=G$ and $U_t$ is Parseval." -/
theorem retraction_parseval {n d : ℕ} (U W : Frame n d) (hU : IsParseval U)
    (hUW : U.transpose * W = 0) (t : ℝ) :
    (U + t • W).transpose * (U + t • W) = 1 + t ^ 2 • (W.transpose * W) ∧
    IsParseval (retraction U W t) ∧
    frameProjection (retraction U W t) =
      (U + t • W) * (1 + t ^ 2 • (W.transpose * W))⁻¹ * (U + t • W).transpose :=
  retr_basic U W hU hUW t

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
  obtain ⟨hd, hn, ha, ha2, hd1, hp, -⟩ := standing_basics hs
  have hU := hs.parseval
  have hD0 : 0 < D := by linarith
  have hρ : 0 < D ^ 2 * t ^ 2 := by positivity
  obtain ⟨hUm, -, hmop, -, -⟩ := drift_basics hs hρ
  obtain ⟨hZop, hZrow, -⟩ := hS1
  have hUZ : U.transpose * moderateNoise U (D ^ 2 * t ^ 2) g = 0 :=
    (moderateNoise_spec U hU hp hρ).2.2 g
  set a := (d : ℝ) / n with ha_def
  set m := driftMean U (D ^ 2 * t ^ 2) with hm_def
  set Z := moderateNoise U (D ^ 2 * t ^ 2) g with hZ_def
  have hWdef : driftedNoise U (D ^ 2 * t ^ 2) t g = Z + (t / 2) • m := rfl
  have ht2 : 0 < t / 2 := by positivity
  have hsqa : 0 ≤ Real.sqrt a := Real.sqrt_nonneg a
  -- the drift
  have c1 : t / 2 * opNorm m ≤ t / 2 * Real.sqrt (frobSq m) :=
    mul_le_mul_of_nonneg_left (opNorm_le_sqrt_frobSq m) ht2.le
  have c2 : t / 2 * Real.sqrt (frobSq m) ≤ Real.sqrt (a / 2) / D :=
    (rem_drift_size U hs hD0 ht).2
  have hsa2 : Real.sqrt (a / 2) ≤ 1 / 2 := by
    rw [Real.sqrt_le_left (by norm_num)]; linarith
  have c3 : Real.sqrt (a / 2) / D ≤ 1 / 24 := by
    rw [div_le_iff₀ hD0]; nlinarith
  have hsm : t / 2 * Real.sqrt (frobSq m) ≤ 1 / 24 := c2.trans c3
  have hom : t / 2 * opNorm m ≤ 1 / 24 := c1.trans hsm
  -- `√(a/2)/D ≤ √a/12`
  have hsa12 : Real.sqrt (a / 2) / D ≤ Real.sqrt a / 12 := by
    have h1 : Real.sqrt (a / 2) ≤ Real.sqrt a := Real.sqrt_le_sqrt (by linarith)
    rw [div_le_div_iff₀ hD0 (by norm_num)]
    nlinarith [Real.sqrt_nonneg (a / 2)]
  -- `W`
  have c4 : opNorm (driftedNoise U (D ^ 2 * t ^ 2) t g) ≤ 17 := by
    rw [hWdef]
    refine (opNorm_add_le _ _).trans ?_
    rw [opNorm_smul, abs_of_pos ht2]
    linarith
  have c5 : Real.sqrt (frobSq (driftedNoise U (D ^ 2 * t ^ 2) t g)) ≤ 17 * Real.sqrt d := by
    rw [hWdef]
    refine (sqrt_frobSq_add_le _ _).trans ?_
    rw [sqrt_frobSq_smul, abs_of_pos ht2]
    have hZF : Real.sqrt (frobSq Z) ≤ Real.sqrt d * 16 := by
      calc Real.sqrt (frobSq Z) ≤ Real.sqrt (d * opNorm Z ^ 2) :=
            Real.sqrt_le_sqrt (frobSq_le_opNorm_sq Z)
        _ = Real.sqrt d * opNorm Z := by
            rw [Real.sqrt_mul (Nat.cast_nonneg d), Real.sqrt_sq (opNorm_nonneg _)]
        _ ≤ Real.sqrt d * 16 := mul_le_mul_of_nonneg_left hZop (Real.sqrt_nonneg _)
    have hsd : 1 ≤ Real.sqrt d := by
      rw [show (1 : ℝ) = Real.sqrt 1 by simp]; exact Real.sqrt_le_sqrt hd1
    linarith
  have c6 : ∀ i, Real.sqrt (rowNormSq (driftedNoise U (D ^ 2 * t ^ 2) t g) i) ≤
      2 * Real.sqrt a := by
    intro i
    rw [hWdef]
    refine (sqrt_rowNormSq_add_le _ _ i).trans ?_
    rw [sqrt_rowNormSq_smul, abs_of_pos ht2]
    have hZi : Real.sqrt (rowNormSq Z i) ≤ 7 / 4 * Real.sqrt a := by
      calc Real.sqrt (rowNormSq Z i) ≤ Real.sqrt (3 * a) := Real.sqrt_le_sqrt (hZrow i)
        _ = Real.sqrt 3 * Real.sqrt a := Real.sqrt_mul (by norm_num) a
        _ ≤ 7 / 4 * Real.sqrt a := by
            apply mul_le_mul_of_nonneg_right _ hsqa
            rw [Real.sqrt_le_left (by norm_num)]; norm_num
    have hmi : t / 2 * Real.sqrt (rowNormSq m i) ≤ t / 2 * Real.sqrt (frobSq m) :=
      mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt (rowNormSq_le_frobSq m i)) ht2.le
    linarith
  have c7 : ∀ i, Real.sqrt (rowNormSq (U * (driftedNoise U (D ^ 2 * t ^ 2) t g).transpose) i) ≤
      17 * Real.sqrt (3 * a / 2) := by
    intro i
    rw [hWdef, Matrix.transpose_add, Matrix.transpose_smul, Matrix.mul_add, Matrix.mul_smul]
    refine (sqrt_rowNormSq_add_le _ _ i).trans ?_
    rw [sqrt_rowNormSq_smul, abs_of_pos ht2]
    have hpi : Real.sqrt (rowNormSq U i) ≤ Real.sqrt (3 * a / 2) :=
      Real.sqrt_le_sqrt (hs.rows i).2
    have hgen : ∀ K : Frame n d, Real.sqrt (rowNormSq (U * K.transpose) i) ≤
        opNorm K * Real.sqrt (3 * a / 2) := by
      intro K
      calc Real.sqrt (rowNormSq (U * K.transpose) i)
          ≤ Real.sqrt (opNorm K ^ 2 * rowNormSq U i) :=
            Real.sqrt_le_sqrt (rowNormSq_mul_transpose_le_opNorm U K i)
        _ = opNorm K * Real.sqrt (rowNormSq U i) := by
            rw [Real.sqrt_mul (sq_nonneg _), Real.sqrt_sq (opNorm_nonneg _)]
        _ ≤ opNorm K * Real.sqrt (3 * a / 2) :=
            mul_le_mul_of_nonneg_left hpi (opNorm_nonneg _)
    have h1 := hgen Z
    have h2 := mul_le_mul_of_nonneg_left (hgen m) ht2.le
    have h3 : opNorm Z * Real.sqrt (3 * a / 2) ≤ 16 * Real.sqrt (3 * a / 2) :=
      mul_le_mul_of_nonneg_right hZop (Real.sqrt_nonneg _)
    have h4 : t / 2 * (opNorm m * Real.sqrt (3 * a / 2)) ≤ 1 / 24 * Real.sqrt (3 * a / 2) := by
      rw [← mul_assoc]; exact mul_le_mul_of_nonneg_right hom (Real.sqrt_nonneg _)
    have h5 := Real.sqrt_nonneg (3 * a / 2)
    linarith
  have c8 : ∀ i, rowNormSq (tangentY U m) i ≤ opNorm m ^ 2 :=
    (tangentY_facts U m hU hUm).2.1
  have hK : opNorm (driftedNoise U (D ^ 2 * t ^ 2) t g) ^ 2 ≤ 289 := by
    have := pow_le_pow_left₀ (opNorm_nonneg _) c4 2; norm_num at this; linarith
  obtain ⟨-, -, -, -, -, c10, c11, -⟩ := gram_facts (driftedNoise U (D ^ 2 * t ^ 2) t g)
    (sq_nonneg t) hK
  have c12 : opNorm (U + t • driftedNoise U (D ^ 2 * t ^ 2) t g) ≤ 18 := by
    refine (opNorm_add_le _ _).trans ?_
    rw [opNorm_smul, abs_of_pos ht]
    have := opNorm_parseval_le_one hU
    nlinarith [opNorm_nonneg (driftedNoise U (D ^ 2 * t ^ 2) t g)]
  have c13 : ∀ i, Real.sqrt (rowNormSq (U + t • driftedNoise U (D ^ 2 * t ^ 2) t g) i) ≤
      4 * Real.sqrt a := by
    intro i
    refine (sqrt_rowNormSq_add_le _ _ i).trans ?_
    rw [sqrt_rowNormSq_smul, abs_of_pos ht]
    have hpi : Real.sqrt (rowNormSq U i) ≤ 2 * Real.sqrt a := by
      calc Real.sqrt (rowNormSq U i) ≤ Real.sqrt (3 / 2 * a) :=
            Real.sqrt_le_sqrt (by linarith [(hs.rows i).2])
        _ = Real.sqrt (3 / 2) * Real.sqrt a := Real.sqrt_mul (by norm_num) a
        _ ≤ 2 * Real.sqrt a := by
            apply mul_le_mul_of_nonneg_right _ hsqa
            rw [Real.sqrt_le_left (by norm_num)]; norm_num
    have h2 := c6 i
    nlinarith
  exact ⟨c1, c2, c3, c4, c5, c6, c7, c8, hmop, by linarith, by linarith, c12, c13⟩

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
  intro W
  obtain ⟨-, -, -, -, -, hp, -⟩ := standing_basics hs
  have hU := hs.parseval
  have hρ : 0 < D ^ 2 * t ^ 2 := by positivity
  obtain ⟨hUm, -, -, -, -⟩ := drift_basics hs hρ
  have hUZ : U.transpose * moderateNoise U (D ^ 2 * t ^ 2) g = 0 :=
    (moderateNoise_spec U hU hp hρ).2.2 g
  have hUW : U.transpose * W = 0 := by
    change U.transpose * (moderateNoise U (D ^ 2 * t ^ 2) g +
      (t / 2) • driftMean U (D ^ 2 * t ^ 2)) = 0
    rw [Matrix.mul_add, Matrix.mul_smul, hUZ, hUm, smul_zero, add_zero]
  refine ⟨?_, by field_simp; ring⟩
  have hsplit := retr_error_split U W hU hUW t
  have hYW : tangentY U W = tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g) +
      (t / 2) • tangentY U (driftMean U (D ^ 2 * t ^ 2)) := by
    change tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g +
      (t / 2) • driftMean U (D ^ 2 * t ^ 2)) = _
    unfold tangentY
    simp only [Matrix.add_mul, Matrix.transpose_add, Matrix.transpose_smul, Matrix.mul_add,
      Matrix.smul_mul, Matrix.mul_smul, smul_add]
    abel
  unfold retractionError
  change frameProjection (retraction U W t) - frameProjection U -
    t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g) = _
  have h2 : frameProjection (retraction U W t) - frameProjection U -
      t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g) =
      (frameProjection (retraction U W t) - frameProjection U - t • tangentY U W) +
        (t ^ 2 / 2) • tangentY U (driftMean U (D ^ 2 * t ^ 2)) := by
    rw [hYW, smul_add, smul_smul, show t * (t / 2) = t ^ 2 / 2 by ring]
    abel
  rw [h2]
  unfold retraction
  rw [hsplit]
  abel

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
        (U + t • W).transpose : Matrix (Fin n) (Fin n) ℝ) i i :=
  retr_expansion U W hU hUW t i

/-- Proof of `lem:retraction`(c): the effect of the drift on `𝒜` and `q`. -/
theorem lem_retraction_drift_split {n d : ℕ} (U H m : Frame n d) (t : ℝ) (i : Fin n) :
    2 * t * diagMap U (H + (t / 2) • m) i = 2 * t * diagMap U H i + t ^ 2 * diagMap U m i ∧
    horizontalQuadraticDiagonal U (H + (t / 2) • m) i =
      horizontalQuadraticDiagonal U H i + t * Linear.horizontalQuadraticCross U H m i +
        t ^ 2 / 4 * horizontalQuadraticDiagonal U m i := by
  constructor
  · simp only [diagMap, Matrix.add_mul, Matrix.smul_mul, Matrix.add_apply, Matrix.smul_apply,
      smul_eq_mul]
    ring
  · rw [Linear.horizontalQuadraticDiagonal_add, Linear.horizontalQuadraticCross_smul]
    have hq : horizontalQuadraticDiagonal U ((t / 2) • m) i =
        (t / 2) ^ 2 * horizontalQuadraticDiagonal U m i := by
      simp only [horizontalQuadraticDiagonal, Matrix.transpose_smul, Matrix.mul_smul,
        Linear.rowNormSq_smul]
      ring
    rw [hq]
    ring

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
  obtain ⟨hd, hn, ha, ha2, hd1, hp, -⟩ := standing_basics hs
  have hU := hs.parseval
  have hD0 : 0 < D := by linarith
  have hρ : 0 < D ^ 2 * t ^ 2 := by positivity
  obtain ⟨hUm, -, -, hYm, -⟩ := drift_basics hs hρ
  have hUZ : U.transpose * moderateNoise U (D ^ 2 * t ^ 2) g = 0 :=
    (moderateNoise_spec U hU hp hρ).2.2 g
  set a := (d : ℝ) / n with ha_def
  set m := driftMean U (D ^ 2 * t ^ 2) with hm_def
  set Z := moderateNoise U (D ^ 2 * t ^ 2) g with hZ_def
  have ht2 : t ^ 2 ≤ 1 := by nlinarith
  have hDt : 0 < D * t := by positivity
  -- (1)
  have t1 : (1 - t ^ 2) * |rowNormSq U i - a| ≤ ε * a := by
    have h := hnear i
    have habs : |rowNormSq U i - a| ≤ ε * a := by
      rw [abs_le]; constructor <;> nlinarith [h.1, h.2]
    have h1 : 0 ≤ 1 - t ^ 2 := by linarith
    have h2 : 1 - t ^ 2 ≤ 1 := by nlinarith [sq_nonneg t]
    calc (1 - t ^ 2) * |rowNormSq U i - a| ≤ 1 * |rowNormSq U i - a| :=
          mul_le_mul_of_nonneg_right h2 (abs_nonneg _)
      _ ≤ ε * a := by rw [one_mul]; exact habs
  -- (2)
  have hsq2 : Real.sqrt (D ^ 2 * t ^ 2 * a * Real.log (2 * n) / n) =
      D * t * Real.sqrt (a * Real.log (2 * n) / n) := by
    rw [show D ^ 2 * t ^ 2 * a * Real.log (2 * n) / n =
        (D * t) ^ 2 * (a * Real.log (2 * n) / n) by ring,
      Real.sqrt_mul (sq_nonneg _), Real.sqrt_sq hDt.le]
  have t2 : 2 * t * |diagMap U Z i| ≤ 6 * t * D * t * Real.sqrt (a * Real.log (2 * n) / n) := by
    have h := hS2.1 i
    rw [hsq2] at h
    have := mul_le_mul_of_nonneg_left h (by positivity : (0 : ℝ) ≤ 2 * t)
    linarith
  -- (3)
  have t3 : 6 * t * D * t * Real.sqrt (a * Real.log (2 * n) / n) =
      6 * D * a * t ^ 2 * Real.sqrt (Real.log (2 * n) / d) := by
    rw [show a * Real.log (2 * n) / n = a ^ 2 * (Real.log (2 * n) / d) by
        rw [ha_def]; field_simp,
      Real.sqrt_mul (sq_nonneg _), Real.sqrt_sq ha.le]
    ring
  -- (4)
  have t4 : t ^ 2 * |baseBias U i| ≤ 12 * ε * t ^ 2 / n := by
    have h := baseBias_bound hs hε0 hε hnear i
    have := mul_le_mul_of_nonneg_left h (sq_nonneg t)
    calc t ^ 2 * |baseBias U i| ≤ t ^ 2 * (12 * ε / n) := this
      _ = 12 * ε * t ^ 2 / n := by ring
  -- (5)
  have hYZ : Real.sqrt (rowNormSq (tangentY U Z) i) ≤ Real.sqrt (800 * a) :=
    Real.sqrt_le_sqrt (hS1.2.2 i)
  have hYmi : Real.sqrt (rowNormSq (tangentY U m) i) ≤
      Real.sqrt (2 * a / (D ^ 2 * t ^ 2)) := Real.sqrt_le_sqrt (hYm i)
  have hcs := eq_q_cs U Z m hU hUZ hUm i
  have t5 : t ^ 3 * |Linear.horizontalQuadraticCross U Z m i| ≤
      t ^ 3 * Real.sqrt (800 * a) * Real.sqrt (2 * a / (D ^ 2 * t ^ 2)) := by
    rw [mul_assoc]
    apply mul_le_mul_of_nonneg_left _ (by positivity)
    exact hcs.2.1.trans (mul_le_mul hYZ hYmi (Real.sqrt_nonneg _) (Real.sqrt_nonneg _))
  -- (6)
  have t6 : t ^ 3 * Real.sqrt (800 * a) * Real.sqrt (2 * a / (D ^ 2 * t ^ 2)) =
      40 * a * t ^ 2 / D := by
    rw [mul_assoc, ← Real.sqrt_mul (by positivity),
      show 800 * a * (2 * a / (D ^ 2 * t ^ 2)) = (40 * a / (D * t)) ^ 2 by
        field_simp; ring,
      Real.sqrt_sq (by positivity)]
    field_simp
  -- (7)
  have t7 : t ^ 4 / 4 * |horizontalQuadraticDiagonal U m i| ≤
      t ^ 4 / 4 * (2 * a / (D ^ 2 * t ^ 2)) :=
    mul_le_mul_of_nonneg_left (hcs.2.2.trans (hYm i)) (by positivity)
  -- (8)
  have t8 : t ^ 4 / 4 * (2 * a / (D ^ 2 * t ^ 2)) = a * t ^ 2 / (2 * D ^ 2) := by
    field_simp; ring
  exact ⟨t1, t2, t3, t4, t5, t6, t7, t8⟩

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

/-- `lem:retraction` with the explicit constant `C_E = 2·10⁹` produced by its proof
(`(18·289·4 + 2·17)²`-type bookkeeping of `lem_retraction_aux`, see `SeedAux.retr_bounds`). -/
theorem lem_retraction_explicit : IsRetractionConstant (2 * 10 ^ 9) := by
  intro n d U D t g hs hD ht ht1 hS1
  obtain ⟨hd, hn, ha, ha2, hd1, hp, -⟩ := standing_basics hs
  have hU := hs.parseval
  have hD0 : 0 < D := by linarith
  have hρ : 0 < D ^ 2 * t ^ 2 := by positivity
  obtain ⟨hUm, -, hmop, hYm, hEq⟩ := drift_basics hs hρ
  have hUZ : U.transpose * moderateNoise U (D ^ 2 * t ^ 2) g = 0 :=
    (moderateNoise_spec U hU hp hρ).2.2 g
  have hUW : U.transpose * driftedNoise U (D ^ 2 * t ^ 2) t g = 0 := by
    change U.transpose * (moderateNoise U (D ^ 2 * t ^ 2) g +
      (t / 2) • driftMean U (D ^ 2 * t ^ 2)) = 0
    rw [Matrix.mul_add, Matrix.mul_smul, hUZ, hUm, smul_zero, add_zero]
  obtain ⟨-, -, -, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13⟩ :=
    lem_retraction_aux U hs hD ht ht1 g hS1
  obtain ⟨ba, bb, bc⟩ := retr_bounds U (driftedNoise U (D ^ 2 * t ^ 2) t g) hU ha ht ht1
    c4 c5 c6 c7 c10 c11 c12 c13
  obtain ⟨hEsplit, hEm⟩ := lem_retraction_error U hs hD0 ht g
  set a := (d : ℝ) / n with ha_def
  set W := driftedNoise U (D ^ 2 * t ^ 2) t g with hW
  set Z := moderateNoise U (D ^ 2 * t ^ 2) g with hZ
  set m := driftMean U (D ^ 2 * t ^ 2) with hm
  have ht3 : 0 < t ^ 3 := by positivity
  -- (c): the remainder is the cubic part of the exact expansion
  have hrem : ∀ i, retractionRemainder U D t g i =
      -(2 * t ^ 3 * ∑ k, (U * W.transpose) i k * (W * W.transpose) i k) -
        t ^ 4 * rowNormSq (W * W.transpose) i +
        t ^ 4 * ((U + t • W) * (W.transpose * W) ^ 2 * (1 + t ^ 2 • (W.transpose * W))⁻¹ *
          (U + t • W).transpose : Matrix (Fin n) (Fin n) ℝ) i i := by
    intro i
    have hexp : frameProjection (driftedFrame U D t g) i i =
        rowNormSq U i + 2 * t * diagMap U W i + t ^ 2 * horizontalQuadraticDiagonal U W i -
        2 * t ^ 3 * ∑ k, (U * W.transpose) i k * (W * W.transpose) i k -
        t ^ 4 * rowNormSq (W * W.transpose) i +
        t ^ 4 * ((U + t • W) * (W.transpose * W) ^ 2 * (1 + t ^ 2 • (W.transpose * W))⁻¹ *
          (U + t • W).transpose : Matrix (Fin n) (Fin n) ℝ) i i :=
      lem_retraction_expansion U W hU hUW t i
    have hs1 : 2 * t * diagMap U W i = 2 * t * diagMap U Z i + t ^ 2 * diagMap U m i :=
      (lem_retraction_drift_split U Z m t i).1
    have hs2 : horizontalQuadraticDiagonal U W i =
        horizontalQuadraticDiagonal U Z i + t * Linear.horizontalQuadraticCross U Z m i +
          t ^ 2 / 4 * horizontalQuadraticDiagonal U m i :=
      (lem_retraction_drift_split U Z m t i).2
    have hE := hEq i
    unfold residualBias at hE
    unfold retractionRemainder
    linear_combination hexp + hs1 + t ^ 2 * hs2 + t ^ 2 * hE
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (a)
    calc sqDistance (driftedFrame U D t g) U ≤ 5219 ^ 2 * t ^ 2 * d := ba
      _ ≤ 2 * 10 ^ 9 * t ^ 2 * d := by
          apply mul_le_mul_of_nonneg_right _ (Nat.cast_nonneg d)
          apply mul_le_mul_of_nonneg_right _ (sq_nonneg t)
          norm_num
  · -- (b)
    intro i
    rw [hEsplit]
    refine (Linear.rowNormSq_add_le _ _ i).trans ?_
    have h1 : rowNormSq ((t ^ 2 / 2) • tangentY U m) i ≤ a * t ^ 2 / (2 * D ^ 2) := by
      rw [Linear.rowNormSq_smul, ← hEm]
      have := (hYm i)
      calc (t ^ 2 / 2) ^ 2 * rowNormSq (tangentY U m) i
          ≤ (t ^ 2 / 2) ^ 2 * (2 * a / (D ^ 2 * t ^ 2)) :=
            mul_le_mul_of_nonneg_left this (sq_nonneg _)
        _ = t ^ 4 / 4 * (2 * a / (D ^ 2 * t ^ 2)) := by ring
    have h2 := bb i
    have h3 : a * t ^ 2 / (2 * D ^ 2) * 2 = a * t ^ 2 * (1 / D ^ 2) := by
      field_simp
    have h4 : 865948040 * t ^ 4 * a ≤ a * t ^ 2 * (10 ^ 9 * t ^ 2) := by
      have : 0 ≤ t ^ 4 * a := by positivity
      nlinarith
    nlinarith
  · -- (c)
    intro i
    rw [hrem i]
    refine (bc i).trans ?_
    have : 0 ≤ a * t ^ 3 := by positivity
    nlinarith
  · -- (d)
    intro ε η' hε0 hε hnear hS2 i
    obtain ⟨t1, t2, t3, t4, t5, t6, t7, t8⟩ :=
      lem_retraction_terms U hs hε0 hε hnear hD ht ht1 g hS1 hS2 i
    have hfl := hS2.2 i
    have hr : |retractionRemainder U D t g i| ≤ 2 * 10 ^ 9 * a * t ^ 3 := by
      rw [hrem i]
      refine (bc i).trans ?_
      have : 0 ≤ a * t ^ 3 := by positivity
      nlinarith
    have hdecomp : frameProjection (driftedFrame U D t g) i i - a =
        (1 - t ^ 2) * (rowNormSq U i - a) + 2 * t * diagMap U Z i - t ^ 2 * baseBias U i +
        t ^ 2 * (horizontalQuadraticDiagonal U Z i -
          ∫ g', horizontalQuadraticDiagonal U (moderateNoise U (D ^ 2 * t ^ 2) g') i
            ∂gaussAmb n d) +
        t ^ 3 * Linear.horizontalQuadraticCross U Z m i +
        t ^ 4 / 4 * horizontalQuadraticDiagonal U m i + retractionRemainder U D t g i := by
      unfold retractionRemainder; ring
    rw [hdecomp]
    have ht1' : 0 ≤ 1 - t ^ 2 := sub_nonneg.mpr (pow_le_one₀ ht.le ht1)
    have ht2p : 0 < t ^ 2 := by positivity
    have ht4p : 0 < t ^ 4 / 4 := by positivity
    have e1 : |(1 - t ^ 2) * (rowNormSq U i - a)| ≤ ε * a := by
      rw [abs_mul, abs_of_nonneg ht1']; exact t1
    have e2 : |2 * t * diagMap U Z i| ≤ 6 * D * a * t ^ 2 * Real.sqrt (Real.log (2 * n) / d) := by
      rw [abs_mul, abs_of_pos (by positivity : (0 : ℝ) < 2 * t), ← t3]; exact t2
    have e3 : |t ^ 2 * baseBias U i| ≤ 12 * ε * t ^ 2 / n := by
      rw [abs_mul, abs_of_pos ht2p]; exact t4
    have e4 : |t ^ 2 * (horizontalQuadraticDiagonal U Z i -
          ∫ g', horizontalQuadraticDiagonal U (moderateNoise U (D ^ 2 * t ^ 2) g') i
            ∂gaussAmb n d)| ≤ t ^ 2 * (η' * a) := by
      rw [abs_mul, abs_of_pos ht2p]; exact mul_le_mul_of_nonneg_left hfl ht2p.le
    have e5 : |t ^ 3 * Linear.horizontalQuadraticCross U Z m i| ≤ 40 * a * t ^ 2 / D := by
      rw [abs_mul, abs_of_pos ht3, ← t6]; exact t5
    have e6 : |t ^ 4 / 4 * horizontalQuadraticDiagonal U m i| ≤ a * t ^ 2 / (2 * D ^ 2) := by
      rw [abs_mul, abs_of_pos ht4p, ← t8]; exact t7
    have htarget : a * t ^ 2 * (ε / t ^ 2 + 6 * D * Real.sqrt (Real.log (2 * n) / d) +
        12 * ε / d + η' + 40 / D + 1 / (2 * D ^ 2) + 2 * 10 ^ 9 * t) =
        ε * a + 6 * D * a * t ^ 2 * Real.sqrt (Real.log (2 * n) / d) + 12 * ε * t ^ 2 / n +
          t ^ 2 * (η' * a) + 40 * a * t ^ 2 / D + a * t ^ 2 / (2 * D ^ 2) +
          2 * 10 ^ 9 * a * t ^ 3 := by
      rw [ha_def]; field_simp
    rw [htarget]
    refine (abs_add_le _ _).trans ?_
    refine add_le_add ?_ hr
    refine (abs_add_le _ _).trans ?_
    refine add_le_add ?_ e6
    refine (abs_add_le _ _).trans ?_
    refine add_le_add ?_ e5
    refine (abs_add_le _ _).trans ?_
    refine add_le_add ?_ e4
    refine (abs_sub _ _).trans ?_
    refine add_le_add ?_ e3
    refine (abs_add_le _ _).trans ?_
    exact add_le_add e1 e2

/-- `lem:retraction`.

TeX: "There is an absolute $C_E$ (depending only on the bounds in \ref{S1} and on
$D\ge12$) such that: (a) [...] (b) [...] (c) [...] (d) [...]" -/
theorem lem_retraction : ∃ CE : ℝ, 0 < CE ∧ IsRetractionConstant CE :=
  ⟨2 * 10 ^ 9, by norm_num, lem_retraction_explicit⟩

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
  obtain ⟨hd, hn, ha, ha2, hd1, hp, -⟩ := standing_basics hs
  have hh : sampleH = 1 / 500 := rfl
  have hh0 : 0 < sampleH := by rw [hh]; norm_num
  have hD12 : 12 ≤ D := by
    have : (12 : ℝ) ≤ 13 / sampleH := by rw [hh]; norm_num
    linarith
  have hD0 : 0 < D := by linarith
  obtain ⟨-, hrow, -, -⟩ := hret n d U D t g hs hD12 ht ht1 hg.1
  set a := (d : ℝ) / n with ha_def
  set h := sampleH with hh_def
  have hat : 0 < a * t ^ 2 := by positivity
  -- `1/D² + C_E t² ≤ h²/80`
  have hD2 : 1 / D ^ 2 ≤ h ^ 2 / 169 := by
    have h1 : 13 ≤ D * h := by rw [div_le_iff₀ hh0] at hD; linarith
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith
  have hCt : CE * t ^ 2 ≤ h ^ 2 / 160 := by
    rw [le_div_iff₀ (by positivity : (0 : ℝ) < 160 * CE)] at htCE
    nlinarith
  have hX : 1 / D ^ 2 + CE * t ^ 2 ≤ h ^ 2 / 80 := by
    have : h ^ 2 / 169 + h ^ 2 / 160 ≤ h ^ 2 / 80 := by nlinarith [sq_nonneg h]
    linarith
  have hratio : a * t ^ 2 * (1 / D ^ 2 + CE * t ^ 2) / (h ^ 2 / 4 * (a * t ^ 2 / n)) ≤
      5 / 100 * n := by
    have heq : a * t ^ 2 * (1 / D ^ 2 + CE * t ^ 2) / (h ^ 2 / 4 * (a * t ^ 2 / n)) =
        4 * n * (1 / D ^ 2 + CE * t ^ 2) / h ^ 2 := by
      field_simp
    rw [heq, div_le_iff₀ (by positivity)]
    nlinarith
  have hthr : (h / 2 * t * Real.sqrt (a / n)) ^ 2 = h ^ 2 / 4 * (a * t ^ 2 / n) := by
    rw [mul_pow, mul_pow, Real.sq_sqrt (by positivity)]; ring
  have hthr0 : 0 ≤ h / 2 * t * Real.sqrt (a / n) := by positivity
  refine ⟨hratio, fun i hi => ?_⟩
  set F := Finset.univ.filter (fun j => h / 2 * t * Real.sqrt (a / n) ≤
    |retractionError U D t g i j|) with hF
  have hFcard : (F.card : ℝ) ≤ 5 / 100 * n := by
    have hsum : (F.card : ℝ) * (h ^ 2 / 4 * (a * t ^ 2 / n)) ≤
        a * t ^ 2 * (1 / D ^ 2 + CE * t ^ 2) := by
      calc (F.card : ℝ) * (h ^ 2 / 4 * (a * t ^ 2 / n))
          = ∑ _j ∈ F, (h / 2 * t * Real.sqrt (a / n)) ^ 2 := by rw [hthr]; simp
        _ ≤ ∑ j ∈ F, retractionError U D t g i j ^ 2 := by
            apply Finset.sum_le_sum; intro j hj
            have hj' := (Finset.mem_filter.mp hj).2
            have := pow_le_pow_left₀ hthr0 hj' 2
            rwa [sq_abs] at this
        _ ≤ ∑ j, retractionError U D t g i j ^ 2 :=
            Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
              (fun j _ _ => sq_nonneg _)
        _ ≤ _ := hrow i
    have hpos : 0 < h ^ 2 / 4 * (a * t ^ 2 / n) := by positivity
    calc (F.card : ℝ) ≤ a * t ^ 2 * (1 / D ^ 2 + CE * t ^ 2) / (h ^ 2 / 4 * (a * t ^ 2 / n)) :=
          (le_div_iff₀ hpos).mpr hsum
      _ ≤ _ := hratio
  refine ⟨hFcard, ?_⟩
  set A := Finset.univ.filter (fun j => j ≠ i ∧ h * t * Real.sqrt (a / n) ≤
    |frameProjection U i j + t * tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g) i j|) with hA
  have hAcard : 95 / 100 * (n : ℝ) ≤ (A.card : ℝ) := hg.2.2.1 i hi
  have hsub : A \ F ⊆ Finset.univ.filter (fun j => j ≠ i ∧
      h ^ 2 / 4 * (a * t ^ 2 / n) ≤ frameProjection (driftedFrame U D t g) i j ^ 2) := by
    intro j hj
    rw [Finset.mem_sdiff] at hj
    obtain ⟨hjA, hjF⟩ := hj
    obtain ⟨hji, hbig⟩ := (Finset.mem_filter.mp hjA).2
    have hsmall : |retractionError U D t g i j| < h / 2 * t * Real.sqrt (a / n) := by
      by_contra hc
      exact hjF (Finset.mem_filter.mpr ⟨Finset.mem_univ _, not_lt.mp hc⟩)
    have hPt : frameProjection (driftedFrame U D t g) i j =
        (frameProjection U i j + t * tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g) i j) +
          retractionError U D t g i j := by
      simp only [retractionError, Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul]
      ring
    refine Finset.mem_filter.mpr ⟨Finset.mem_univ _, hji, ?_⟩
    rw [← hthr, hPt]
    have h1 : h / 2 * t * Real.sqrt (a / n) ≤
        |frameProjection U i j + t * tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g) i j +
          retractionError U D t g i j| := by
      have := abs_add_le (frameProjection U i j + t * tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g) i j +
          retractionError U D t g i j) (-retractionError U D t g i j)
      rw [add_neg_cancel_right, abs_neg] at this
      linarith
    have := pow_le_pow_left₀ hthr0 h1 2
    rwa [sq_abs] at this
  have hc1 := Finset.card_le_card hsub
  have hc2 := Finset.card_le_card_sdiff_add_card (s := A) (t := F)
  have hc1' : ((A \ F).card : ℝ) ≤ ((Finset.univ.filter (fun j => j ≠ i ∧
      h ^ 2 / 4 * (a * t ^ 2 / n) ≤ frameProjection (driftedFrame U D t g) i j ^ 2)).card : ℝ) := by
    exact_mod_cast hc1
  have hc2' : (A.card : ℝ) ≤ ((A \ F).card : ℝ) + F.card := by exact_mod_cast hc2
  linarith

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
  obtain ⟨hd0, hn, ha, ha2, hd1, hp, -⟩ := standing_basics hs
  have hU := hs.parseval
  have hh : sampleH = 1 / 500 := rfl
  have hD6500 : 6500 ≤ D := by
    have : (13 : ℝ) / sampleH = 6500 := by rw [hh]; norm_num
    linarith
  have hD0 : 0 < D := by linarith
  have hD12 : 12 ≤ D := by linarith
  have hρ : 0 < D ^ 2 * t ^ 2 := by positivity
  have hn2 : 2 * (10 : ℝ) ^ 6 ≤ n := by
    have : (2 : ℝ) * d ≤ n := by exact_mod_cast hs.density
    linarith
  obtain ⟨-, hrow, -, -⟩ := hret n d U D t g hs hD12 ht ht1 hg.1
  obtain ⟨hUm, -, -, -, -⟩ := drift_basics hs hρ
  have hUZ : U.transpose * moderateNoise U (D ^ 2 * t ^ 2) g = 0 :=
    (moderateNoise_spec U hU hp hρ).2.2 g
  have hUW : U.transpose * driftedNoise U (D ^ 2 * t ^ 2) t g = 0 := by
    change U.transpose * (moderateNoise U (D ^ 2 * t ^ 2) g +
      (t / 2) • driftMean U (D ^ 2 * t ^ 2)) = 0
    rw [Matrix.mul_add, Matrix.mul_smul, hUZ, hUm, smul_zero, add_zero]
  have hUt : IsParseval (driftedFrame U D t g) :=
    (retraction_parseval U _ hU hUW t).2.1
  set a := (d : ℝ) / n with ha_def
  set b := ((exceptionalSet U (D ^ 2 * t ^ 2)).card : ℝ) with hb_def
  have ht2 : t ^ 2 ≤ 1 := pow_le_one₀ ht.le ht1
  have hD2 : 1 / D ^ 2 ≤ 1 / 6500 ^ 2 :=
    one_div_le_one_div_of_le (by norm_num) (pow_le_pow_left₀ (by norm_num) hD6500 2)
  have hc1 : 0 < 1 - η' - t ^ 2 * (2 / n + 8 / d) - 8 / D ^ 2 := by
    have h1 : 2 / (n : ℝ) ≤ 1 / 10 ^ 6 := by
      rw [div_le_div_iff₀ hn (by norm_num)]; linarith
    have h2 : 8 / (d : ℝ) ≤ 8 / 10 ^ 6 :=
      div_le_div_of_nonneg_left (by norm_num) (by norm_num) hd
    have h3 : 8 / D ^ 2 ≤ 8 / 6500 ^ 2 := by
      have := mul_le_mul_of_nonneg_left hD2 (by norm_num : (0 : ℝ) ≤ 8)
      simpa [div_eq_mul_inv] using this
    have h4 : t ^ 2 * (2 / n + 8 / d) ≤ 2 / n + 8 / d := by
      have : 0 ≤ 2 / (n : ℝ) + 8 / d := by positivity
      nlinarith
    norm_num at h1 h2 h3 ⊢
    linarith
  refine ⟨hc1, by norm_num, fun x hx => ?_⟩
  -- (1) `xᵀ𝖪x ≥ (n - b)‖x‖²`
  have hK := completeLaplacian_supported (exceptionalSet U (D ^ 2 * t ^ 2)) x hx
  have e1 : a * ((n : ℝ) - b) * vectorNormSq x ≤ a * matrixQuadratic (completeLaplacian n) x := by
    rw [mul_assoc]; exact mul_le_mul_of_nonneg_left hK ha.le
  -- (2) the expansion `𝓛(P+tY) = L + t𝒞(Y) + t²𝓛(Y)` with `lem:expected-graph` and (S4)
  have hlap := lap_facts U hU
  have hsplit : matrixQuadratic (sqLaplacian (frameProjection U +
        t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g))) x =
      matrixQuadratic (projectionLaplacian (frameProjection U)) x +
        t * matrixQuadratic (crossLaplacian (frameProjection U)
          (tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g))) x +
        t ^ 2 * matrixQuadratic (sqLaplacian (tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g))) x := by
    rw [hlap.2.2, mq_add, mq_add, mq_smul, mq_smul, hlap.1]
  obtain ⟨hS4a, hS4b⟩ := hg.2.2.2 x hx
  have hEG := lem_expected_graph U hs hρ x
  have hQ : 0 ≤ matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
    rw [(lem_energy U hU).2.2.2.2 x |>.1]
    apply mul_nonneg (by norm_num)
    exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ =>
      mul_nonneg (sq_nonneg _) (sq_nonneg _)
  have hN : 0 ≤ vectorNormSq x := vectorNormSq_nonneg x
  have hcr := (abs_le.mp hS4a).1
  have hly := (abs_le.mp hS4b).1
  have hρt : t ^ 2 * (8 / (D ^ 2 * t ^ 2)) = 8 / D ^ 2 := by field_simp
  have hKt : t ^ 2 * (a / (4 * n) * matrixQuadratic (completeLaplacian n) x) ≥
      a * t ^ 2 * (1 / 4 * (1 - b / n)) * vectorNormSq x := by
    have h1 : a * ((n : ℝ) - b) * vectorNormSq x / (4 * n) ≤
        a * matrixQuadratic (completeLaplacian n) x / (4 * n) :=
      div_le_div_of_nonneg_right e1 (by positivity)
    have h2 : a * ((n : ℝ) - b) * vectorNormSq x / (4 * n) =
        a * (1 / 4 * (1 - b / n)) * vectorNormSq x := by field_simp
    have h3 : a * matrixQuadratic (completeLaplacian n) x / (4 * n) =
        a / (4 * n) * matrixQuadratic (completeLaplacian n) x := by ring
    rw [h2, h3] at h1
    have := mul_le_mul_of_nonneg_left h1 (sq_nonneg t)
    linarith
  have e2 : (1 - η' - t ^ 2 * (2 / n + 8 / d) - 8 / D ^ 2) *
        matrixQuadratic (projectionLaplacian (frameProjection U)) x +
      a * t ^ 2 * (1 / 4 * (1 - b / n) - 2 * η') * vectorNormSq x ≤
      matrixQuadratic (sqLaplacian (frameProjection U +
        t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g))) x := by
    rw [hsplit]
    have h1 := mul_le_mul_of_nonneg_left (show
      (∫ g', matrixQuadratic (sqLaplacian (tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g'))) x
        ∂gaussAmb n d) - η' * a * vectorNormSq x ≤
      matrixQuadratic (sqLaplacian (tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g))) x by
        linarith) (sq_nonneg t)
    have h2 := mul_le_mul_of_nonneg_left hEG (sq_nonneg t)
    have h3 : t ^ 2 * (8 / (D ^ 2 * t ^ 2)) *
        matrixQuadratic (projectionLaplacian (frameProjection U)) x =
        8 / D ^ 2 * matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
      rw [hρt]
    linarith
  -- (3)
  have hbn : b / n ≤ 1 / 10 := by rw [div_le_iff₀ hn]; linarith
  have e3 : a * t ^ 2 / 8 * vectorNormSq x ≤
      matrixQuadratic (sqLaplacian (frameProjection U +
        t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g))) x := by
    have hcoef : 1 / 8 ≤ 1 / 4 * (1 - b / n) - 2 * η' := by linarith
    have h1 := mul_nonneg hc1.le hQ
    have h2 := mul_le_mul_of_nonneg_left hcoef (by positivity : (0 : ℝ) ≤ a * t ^ 2)
    have h3 := mul_le_mul_of_nonneg_right h2 hN
    linarith
  -- (4) `eq:lap-basic` and `lem:retraction`(b)
  have hYsym : (tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g)).transpose =
      tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g) := by
    unfold tangentY
    rw [Matrix.transpose_add, Matrix.transpose_mul, Matrix.transpose_mul,
      Matrix.transpose_transpose, Matrix.transpose_transpose, add_comm]
  have hMsym : (frameProjection U + t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g)).transpose =
      frameProjection U + t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g) := by
    rw [Matrix.transpose_add, Matrix.transpose_smul, hYsym, frameProjection_transpose]
  have hEsym : (retractionError U D t g).transpose = retractionError U D t g := by
    unfold retractionError
    rw [Matrix.transpose_sub, Matrix.transpose_sub, Matrix.transpose_smul, hYsym,
      frameProjection_transpose, frameProjection_transpose]
  have hlb := eq_lap_basic _ _ hMsym hEsym
  have hsum : frameProjection U + t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g) +
      retractionError U D t g = frameProjection (driftedFrame U D t g) := by
    unfold retractionError; abel
  have hE2 := (eq_lap_basic _ _ hEsym hEsym).1 _ hrow x
  have hE1 := hlb.2 x
  rw [hsum, (lap_facts _ hUt).1] at hE1
  have e4 : (1 / 2) * matrixQuadratic (sqLaplacian (frameProjection U +
        t • tangentY U (moderateNoise U (D ^ 2 * t ^ 2) g))) x -
        2 * a * t ^ 2 * (1 / D ^ 2 + CE * t ^ 2) * vectorNormSq x ≤
      matrixQuadratic (projectionLaplacian (frameProjection (driftedFrame U D t g))) x := by
    have : 2 * (a * t ^ 2 * (1 / D ^ 2 + CE * t ^ 2)) * vectorNormSq x =
        2 * a * t ^ 2 * (1 / D ^ 2 + CE * t ^ 2) * vectorNormSq x := by ring
    linarith
  -- (5)
  have hCt : CE * t ^ 2 ≤ 1 / 128 := by
    calc CE * t ^ 2 ≤ CE * (1 / (128 * CE)) := mul_le_mul_of_nonneg_left htCE' hCE.le
      _ = 1 / 128 := by field_simp
  have e5 : a * t ^ 2 / 32 * vectorNormSq x ≤
      matrixQuadratic (projectionLaplacian (frameProjection (driftedFrame U D t g))) x := by
    have hsmall : 2 * (1 / D ^ 2 + CE * t ^ 2) ≤ 1 / 32 := by norm_num at hD2 ⊢; linarith
    have hat : 0 ≤ a * t ^ 2 * vectorNormSq x := by positivity
    have h1 := mul_le_mul_of_nonneg_left hsmall hat
    linarith
  exact ⟨e1, e2, e3, e4, e5⟩

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
  obtain ⟨hd0, hn, ha, ha2, hd1, hp, -⟩ := standing_basics hs
  have hU := hs.parseval
  have hh : sampleH = 1 / 500 := rfl
  have hD0 : 0 < D := by
    have : (13 : ℝ) / sampleH = 6500 := by rw [hh]; norm_num
    linarith
  have hρ : 0 < D ^ 2 * t ^ 2 := by positivity
  obtain ⟨hUm, -, -, -, -⟩ := drift_basics hs hρ
  have hUZ : U.transpose * moderateNoise U (D ^ 2 * t ^ 2) g = 0 :=
    (moderateNoise_spec U hU hp hρ).2.2 g
  have hUW : U.transpose * driftedNoise U (D ^ 2 * t ^ 2) t g = 0 := by
    change U.transpose * (moderateNoise U (D ^ 2 * t ^ 2) g +
      (t / 2) • driftMean U (D ^ 2 * t ^ 2)) = 0
    rw [Matrix.mul_add, Matrix.mul_smul, hUZ, hUm, smul_zero, add_zero]
  have hUt : IsParseval (driftedFrame U D t g) :=
    (retraction_parseval U _ hU hUW t).2.1
  have hbmax := (exceptionalSet_card U hs hρ).2.2.2.1
  obtain ⟨-, hcore⟩ := seed_graph_core hCE hret U hs hD ht ht1 htCE g hg
  obtain ⟨-, -, hblock⟩ := seed_graph_block hCE hret hη' hη'1 U hs hd hD ht ht1 htCE' hb g hg
  set a := (d : ℝ) / n with ha_def
  set B := exceptionalSet U (D ^ 2 * t ^ 2) with hB_def
  set b := (B.card : ℝ) with hb_def
  set w : Fin n → Fin n → ℝ := fun i j => frameProjection (driftedFrame U D t g) i j ^ 2
    with hw_def
  have hw : ∀ i j, 0 ≤ w i j := fun i j => sq_nonneg _
  have hsymm : ∀ i j, w i j = w j i := fun i j => by
    simp only [hw_def]; rw [frameProjection_symm]
  have hh0 : 0 < sampleH := by rw [hh]; norm_num
  have hat : 0 < a * t ^ 2 := by positivity
  -- `lem:core`(i) with `ϑ = 0.4`, `γ = h² a t²/4`
  have hγ : 0 < sampleH ^ 2 * (a * t ^ 2) / 4 := by positivity
  have hA : CoreDense w B ((4 / 10 : ℝ) * (sampleH ^ 2 * (a * t ^ 2) / 4)) := by
    apply lem_core_i w hw hsymm B (by norm_num) (by norm_num) hγ
    intro i hi
    have h := (hcore i hi).2
    rw [Fintype.card_fin]
    have e : sampleH ^ 2 * (a * t ^ 2) / 4 / (n : ℝ) = sampleH ^ 2 / 4 * (a * t ^ 2 / n) := by
      ring
    rw [e]
    have e2 : (1 / 2 + 4 / 10 : ℝ) * n = 9 / 10 * n := by ring
    rw [e2]
    exact h
  -- `lem:core`(ii) with `λ = a t²/32`
  have hlam : 0 < a * t ^ 2 / 32 := by positivity
  have hBex : CoreExceptional w B (Real.sqrt b / (a * t ^ 2 / 32)) b := by
    apply lem_core_ii w hw hsymm B hlam
    intro x hx
    have h5 := (hblock x hx).2.2.2.2
    rw [mq_projectionLaplacian_eq_weighted _ hUt] at h5
    exact h5
  have hbar := lem_core w hw hsymm B (by positivity) (by positivity) (by positivity) hA hBex
  have heq : (1 + b) / ((4 / 10 : ℝ) * (sampleH ^ 2 * (a * t ^ 2) / 4)) +
      Real.sqrt b / (a * t ^ 2 / 32) =
      (1 + b) / (1 / 10 * sampleH ^ 2 * a * t ^ 2) + 32 * Real.sqrt b / (a * t ^ 2) := by
    field_simp
  refine ⟨?_, ?_⟩
  · rw [← heq]; exact hbar
  · have e : (1 + b) / (1 / 10 * sampleH ^ 2 * a * t ^ 2) + 32 * Real.sqrt b / (a * t ^ 2) =
        (10 * (1 + b) / sampleH ^ 2 + 32 * Real.sqrt b) / (a * t ^ 2) := by
      field_simp
    rw [e]
    apply div_le_div_of_nonneg_right _ hat.le
    unfold coreConstant
    have h1 : 10 * (1 + b) / sampleH ^ 2 ≤ 10 * (1 + bMax) / sampleH ^ 2 := by
      apply div_le_div_of_nonneg_right _ (sq_nonneg _)
      linarith
    have h2 : Real.sqrt b ≤ Real.sqrt bMax := Real.sqrt_le_sqrt hbmax
    linarith

/-- `lem:seed-graph` with the explicit constants of its proof: any `t_* ≤ 1` with
`t_*² ≤ h²/(160 C_E)` and `t_*² ≤ 1/(128 C_E)`, and
`C_core = 10(1+b_max)/h² + 32√b_max`. -/
theorem lem_seed_graph_explicit {CE tstar : ℝ} (hCE : 0 < CE) (hret : IsRetractionConstant CE)
    (ht0 : 0 < tstar) (ht1 : tstar ≤ 1) (htCE : tstar ^ 2 ≤ sampleH ^ 2 / (160 * CE))
    (htCE' : tstar ^ 2 ≤ 1 / (128 * CE)) :
    SeedGraphConclusion tstar coreConstant := by
  intro A hA η' hη' hη'1 n d U hs hAd D hD t ht htt hb g hg
  have hn1 : 1 ≤ n := by have := hs.pos; have := hs.density; omega
  have hd6 := (hA η' hη' hη'1).1 n d hn1 hAd
  have ht1 : t ≤ 1 := htt.trans ht1
  have ht2 : t ^ 2 ≤ tstar ^ 2 := pow_le_pow_left₀ ht.le htt 2
  obtain ⟨hbar, hle⟩ := seed_graph_barrier hCE hret hη' hη'1 U hs hd6 hD ht ht1
    (ht2.trans htCE) (ht2.trans htCE') hb g hg
  exact hbar.mono hle

/-- A choice of `t_*` in the proof of `lem:seed-graph`: `t_* ≤ 1`, `t_*² ≤ h²/(160 C_E)` and
`t_*² ≤ 1/(128 C_E)`. -/
theorem seed_graph_tstar_exists {CE : ℝ} (hCE : 0 < CE) :
    ∃ tstar : ℝ, 0 < tstar ∧ tstar ≤ 1 ∧ tstar ^ 2 ≤ sampleH ^ 2 / (160 * CE) ∧
      tstar ^ 2 ≤ 1 / (128 * CE) := by
  set m := min (sampleH ^ 2 / (160 * CE)) (1 / (128 * CE)) with hm
  have hh : sampleH = 1 / 500 := rfl
  have hm0 : 0 < m := lt_min (by rw [hh]; positivity) (by positivity)
  refine ⟨min 1 (Real.sqrt m), lt_min one_pos (Real.sqrt_pos.mpr hm0), min_le_left _ _, ?_⟩
  have ht2 : (min 1 (Real.sqrt m)) ^ 2 ≤ m := by
    have h := pow_le_pow_left₀ (le_min zero_le_one (Real.sqrt_nonneg m))
      (min_le_right 1 (Real.sqrt m)) 2
    rwa [Real.sq_sqrt hm0.le] at h
  exact ⟨ht2.trans (min_le_left _ _), ht2.trans (min_le_right _ _)⟩

/-- `lem:seed-graph` (Graph of the seed).

TeX: "There are absolute $t_*\in(0,1]$ and $C_{\rm core}$ such that the following
holds. Let $\eta'\le\frac1{32}$, $d\ge A_{\eta'}\log(2n)$, $D\ge13/h$,
$b\le n/10$ and $t\le t_*$, and let $Z$ satisfy \ref{S1}--\ref{S4}. Then
$H(L_{P_t})\le C_{\rm core}/(at^2)$."

(`h = sampleH = 1/500` and `A_{η'}` are those of `lem:sample`.) -/
theorem lem_seed_graph :
    ∃ tstar Ccore : ℝ, 0 < tstar ∧ tstar ≤ 1 ∧ SeedGraphConclusion tstar Ccore := by
  obtain ⟨CE, hCE, hret⟩ := lem_retraction
  obtain ⟨tstar, ht0, ht1, h1, h2⟩ := seed_graph_tstar_exists hCE
  exact ⟨tstar, coreConstant, ht0, ht1, lem_seed_graph_explicit hCE hret ht0 ht1 h1 h2⟩

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
  set Θ := modTheta CE with hΘ
  have hΘ2 : 2 ≤ Θ := le_max_left _ _
  have hΘ0 : 0 < Θ := by linarith
  have hh : sampleH = 1 / 500 := rfl
  set D := max (13 / sampleH) (500 * Θ) with hD
  have hD0 : 0 < D := lt_of_lt_of_le (by positivity) (le_max_right _ _)
  set A := max (max (Afun (modEtaPrime CE)) ((72 * D * Θ) ^ 2)) (10 ^ 5) with hA
  have hA5 : (10 : ℝ) ^ 5 ≤ A := le_max_right _ _
  have hA0 : 0 < A := lt_of_lt_of_le (by norm_num) hA5
  have hAD : (72 * D * Θ) ^ 2 ≤ A := (le_max_right _ _).trans (le_max_left _ _)
  set K₀ := modK0 CE with hK₀
  have hK₀0 : 0 < K₀ := by rw [hK₀]; unfold modK0; positivity
  set ε₀ := min (1 / 2) (min (tstar ^ 2 / K₀) (min ((1 / (12 * Θ * CE)) ^ 2 / K₀)
    (1 / (144 * Θ)))) with hε₀
  have hε₀0 : 0 < ε₀ := by
    refine lt_min (by norm_num) (lt_min (by positivity) (lt_min (by positivity) (by positivity)))
  refine ⟨D, A, ε₀, hA0, ⟨le_rfl, (le_max_left _ _).trans (le_max_left _ _), ?_, hε₀0,
    min_le_left _ _, ?_⟩⟩
  · intro n d hn hdn hAd
    have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
    have hL : Real.log 2 ≤ Real.log (2 * n) :=
      Real.log_le_log (by norm_num) (by linarith)
    have hlog2 := Real.log_two_gt_d9
    have hL0 : 0 < Real.log (2 * n) := by linarith
    have hd0 : (0 : ℝ) < d := lt_of_lt_of_le (by positivity) hAd
    constructor
    · have hq : Real.log (2 * n) / d ≤ (1 / (72 * D * Θ)) ^ 2 := by
        rw [div_le_iff₀ hd0]
        have h1 : (1 / (72 * D * Θ)) ^ 2 * A ≥ 1 := by
          rw [ge_iff_le, div_pow, one_pow, div_mul_eq_mul_div, one_mul, le_div_iff₀ (by positivity)]
          linarith
        nlinarith
      have hs : Real.sqrt (Real.log (2 * n) / d) ≤ 1 / (72 * D * Θ) :=
        (Real.sqrt_le_left (by positivity)).mpr hq
      calc 6 * D * Real.sqrt (Real.log (2 * n) / d) ≤ 6 * D * (1 / (72 * D * Θ)) :=
            mul_le_mul_of_nonneg_left hs (by positivity)
        _ = 1 / (12 * Θ) := by field_simp; ring
    · have hbm : bMax = 12800 := by unfold bMax delta0; norm_num
      rw [hbm]
      have hdn' : (2 : ℝ) * d ≤ n := by exact_mod_cast hdn
      have : (10 : ℝ) ^ 5 * Real.log 2 ≤ A * Real.log (2 * n) :=
        mul_le_mul hA5 hL (by positivity) hA0.le
      nlinarith
  · intro ε hε hεle
    have hK : 0 < K₀ * ε := by positivity
    have h1 : ε ≤ tstar ^ 2 / K₀ := hεle.trans ((min_le_right _ _).trans (min_le_left _ _))
    have h2 : ε ≤ (1 / (12 * Θ * CE)) ^ 2 / K₀ :=
      hεle.trans ((min_le_right _ _).trans ((min_le_right _ _).trans (min_le_left _ _)))
    have h3 : ε ≤ 1 / (144 * Θ) :=
      hεle.trans ((min_le_right _ _).trans ((min_le_right _ _).trans (min_le_right _ _)))
    refine ⟨?_, ?_, ?_⟩
    · rw [Real.sqrt_le_left htstar.le]
      rw [le_div_iff₀ hK₀0] at h1
      linarith
    · have hs : Real.sqrt (K₀ * ε) ≤ 1 / (12 * Θ * CE) := by
        rw [Real.sqrt_le_left (by positivity)]
        rw [le_div_iff₀ hK₀0] at h2
        linarith
      calc CE * Real.sqrt (K₀ * ε) ≤ CE * (1 / (12 * Θ * CE)) :=
            mul_le_mul_of_nonneg_left hs hCE.le
        _ = 1 / (12 * Θ) := by field_simp
    · calc 12 * ε ≤ 12 * (1 / (144 * Θ)) := by linarith
        _ = 1 / (12 * Θ) := by field_simp; ring

/-- Proof of `thm:moderate`, the drift numerics.

TeX: "$D\ge\max\{13/h, 500\Theta\}$, so that $\frac{40}D+\frac1{2D^2}\le\frac1{12\Theta}$"
-/
theorem moderate_drift_numerics {Θ D : ℝ} (hΘ : 2 ≤ Θ) (hD : 500 * Θ ≤ D) :
    40 / D + 1 / (2 * D ^ 2) ≤ 1 / (12 * Θ) := by
  have hΘ0 : 0 < Θ := by linarith
  have hD0 : 0 < D := by linarith
  have h1 : 40 / D ≤ 40 / (500 * Θ) := div_le_div_of_nonneg_left (by norm_num) (by positivity) hD
  have h2 : 1 / (2 * D ^ 2) ≤ 1 / (10 ^ 6 * Θ) := by
    apply one_div_le_one_div_of_le (by positivity)
    have : (500 * Θ) ^ 2 ≤ D ^ 2 := pow_le_pow_left₀ (by positivity) hD 2
    nlinarith
  have h3 : 40 / (500 * Θ) + 1 / (10 ^ 6 * Θ) ≤ 1 / (12 * Θ) := by
    rw [div_add_div _ _ (by positivity) (by positivity), div_le_div_iff₀ (by positivity)
      (by positivity)]
    nlinarith
  linarith

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
  set Θ := modTheta CE with hΘ
  have hΘ2 : 2 ≤ Θ := le_max_left _ _
  have hΘ0 : 0 < Θ := by linarith
  have hΘcore : coreConstant ≤ Θ := (le_max_left _ _).trans (le_max_right _ _)
  have hΘCE : CE ≤ Θ := (le_max_right _ _).trans (le_max_right _ _)
  have hK₀ : modK0 CE = 12 * Θ := rfl
  set t := Real.sqrt (modK0 CE * ε) with ht_def
  have hKε : 0 < modK0 CE * ε := by rw [hK₀]; positivity
  have ht : 0 < t := Real.sqrt_pos.mpr hKε
  have ht2 : t ^ 2 = 12 * Θ * ε := by rw [ht_def, Real.sq_sqrt hKε.le, hK₀]
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have hd1 : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hdn' : (2 : ℝ) * d ≤ n := by exact_mod_cast hdn
  have hn : (0 : ℝ) < n := by linarith
  have hn1 : 1 ≤ n := by omega
  have hc1 : ε / t ^ 2 = 1 / (12 * Θ) := by rw [ht2]; field_simp
  refine ⟨hc1, by ring, by rw [ht2]; unfold modCm; ring, ?_⟩
  -- the setting
  obtain ⟨hDge, hAge, hAlarge, hε₀0, hε₀le, hsmall⟩ := hch
  have hε12 : ε ≤ 1 / 2 := hεle.trans hε₀le
  obtain ⟨httstar, hCEt, h12ε⟩ := hsmall ε hε hεle
  have ht1' : t ≤ 1 := httstar.trans ht1
  have hs : ModerateStanding U := ⟨hU, hd, hdn, fun i => by
    have := hnear i; constructor <;> nlinarith [this.1, this.2]⟩
  have hh : sampleH = 1 / 500 := rfl
  have hD13 : 13 / sampleH ≤ D := (le_max_left _ _).trans hDge
  have hD500 : 500 * Θ ≤ D := (le_max_right _ _).trans hDge
  have hD12 : 12 ≤ D := by
    have : (13 : ℝ) / sampleH = 6500 := by rw [hh]; norm_num
    linarith
  have hρ : 0 < D ^ 2 * t ^ 2 := by positivity
  set η' := modEtaPrime CE with hη'
  have hη'0 : 0 < η' := lt_min (by norm_num) (by positivity)
  have hη'1 : η' ≤ 1 / 32 := min_le_left _ _
  have hη'Θ : η' ≤ 1 / (12 * Θ) := min_le_right _ _
  have hlog : 0 ≤ Real.log (2 * n) := Real.log_nonneg (by
    have : (1 : ℝ) ≤ n := by exact_mod_cast hn1
    linarith)
  have hAfun : Afun η' * Real.log (2 * n) ≤ d :=
    (mul_le_mul_of_nonneg_right hAge hlog).trans hrank
  -- a good sample
  have hpos := (hA η' hη'0 hη'1).2 n d U hs (D ^ 2 * t ^ 2) hρ t ht ht1' hAfun
  obtain ⟨g, hg⟩ : {g | GoodSample U (D ^ 2 * t ^ 2) t sampleH η' g}.Nonempty := by
    rcases Set.eq_empty_or_nonempty {g | GoodSample U (D ^ 2 * t ^ 2) t sampleH η' g} with h | h
    · rw [h] at hpos; simp at hpos
    · exact h
  refine ⟨g, ?_⟩
  obtain ⟨ra, -, -, rd⟩ := hret n d U D t g hs hD12 ht ht1' hg.1
  obtain ⟨hlarge, hbn⟩ := hAlarge n d hn1 hdn hrank
  have hb : ((exceptionalSet U (D ^ 2 * t ^ 2)).card : ℝ) ≤ (n : ℝ) / 10 :=
    ((exceptionalSet_card U hs hρ).2.2.2.1).trans hbn
  have hp : ∀ i, 0 < rowNormSq U i := (standing_basics hs).2.2.2.2.2.1
  obtain ⟨hUm, -, -, -, -⟩ := drift_basics hs hρ
  have hUZ : U.transpose * moderateNoise U (D ^ 2 * t ^ 2) g = 0 :=
    (moderateNoise_spec U hU hp hρ).2.2 g
  have hUW : U.transpose * driftedNoise U (D ^ 2 * t ^ 2) t g = 0 := by
    change U.transpose * (moderateNoise U (D ^ 2 * t ^ 2) g +
      (t / 2) • driftMean U (D ^ 2 * t ^ 2)) = 0
    rw [Matrix.mul_add, Matrix.mul_smul, hUZ, hUm, smul_zero, add_zero]
  have ha : 0 < (d : ℝ) / n := div_pos hdR hn
  refine ⟨(retraction_parseval U _ hU hUW t).2.1, ?_, ?_, ?_⟩
  · -- distance, `lem:retraction`(a)
    rw [sqDistance_symm]
    refine ra.trans ?_
    have : 0 ≤ t ^ 2 * d := by positivity
    nlinarith
  · -- barrier, `lem:seed-graph`
    have hbar := hsg Afun hA η' hη'0 hη'1 n d U hs hAfun D hD13 t ht httstar hb g hg
    exact hbar.mono (div_le_div_of_nonneg_right hΘcore (by positivity))
  · -- diagonal, `lem:retraction`(d)
    intro i
    have hdiag := rd ε η' hε.le hε12 hnear hg.2.1 i
    rw [frameProjection_diagonal] at hdiag
    rw [abs_sub_comm]
    refine hdiag.trans ?_
    have hdrift := moderate_drift_numerics hΘ2 hD500
    have h12d : 12 * ε / d ≤ 1 / (12 * Θ) :=
      (div_le_self (by positivity) hd1).trans h12ε
    have hsum : ε / t ^ 2 + 6 * D * Real.sqrt (Real.log (2 * n) / d) + 12 * ε / d + η' +
        40 / D + 1 / (2 * D ^ 2) + CE * t ≤ 6 * (1 / (12 * Θ)) := by
      rw [hc1]; linarith
    have h6 : 6 * (1 / (12 * Θ)) = 1 / (2 * Θ) := by field_simp; ring
    rw [h6] at hsum
    calc (d : ℝ) / n * t ^ 2 * (ε / t ^ 2 + 6 * D * Real.sqrt (Real.log (2 * n) / d) +
          12 * ε / d + η' + 40 / D + 1 / (2 * D ^ 2) + CE * t)
        ≤ (d : ℝ) / n * t ^ 2 * (1 / (2 * Θ)) :=
          mul_le_mul_of_nonneg_left hsum (by positivity)
      _ = (d : ℝ) / n * t ^ 2 / (2 * Θ) := by ring

/-- `thm:moderate` with the explicit constants of its proof: `C_m = 36Θ²`,
`Θ = max{2, C_core, C_E}`, and `A`, `ε₀` as chosen in the proof. -/
theorem thm_moderate_explicit {CE tstar D A ε₀ : ℝ} {Afun : ℝ → ℝ}
    (hA : SampleThreshold Afun) (hCE : 0 < CE) (hret : IsRetractionConstant CE)
    (ht0 : 0 < tstar) (ht1 : tstar ≤ 1) (hsg : SeedGraphConclusion tstar coreConstant)
    (hch : ModerateChoice CE tstar Afun D A ε₀) :
    Linear.ModerateParsevalBound A ε₀ (modCm CE) := by
  intro n d hd hdn hrank ε hε hεle U hU hnear
  obtain ⟨-, -, h3, g, hseed⟩ :=
    moderate_seed hA hCE hret ht0 ht1 hsg hch hd hdn hrank hε hεle U hU hnear
  have hΘ2 : 2 ≤ modTheta CE := le_max_left _ _
  have hKε : 0 < modK0 CE * ε := by unfold modK0; have := hΘ2; positivity
  have hc := cor_seed hd (by omega) hΘ2 (Real.sqrt_pos.mpr hKε) hseed
  rwa [h3] at hc

/-- `thm:moderate`.

TeX: "There are absolute constants $A,C_m>0$ and $\eps_0\in(0,\frac12]$ such that the
following holds. Let $U\in\R^{n\times d}$ be Parseval with $2d\le n$, $d\ge A\log(2n)$, and
$|\norm{u_i}^2-a|\le\eps a$ for all $i$, where $0<\eps\le\eps_0$. Then there is
an ENP frame $\widehat U$ with $\fro{\widehat U-U}^2\le C_m\eps d$."

`Linear.ModerateParsevalBound A ε₀ C` is exactly this statement (with `1 ≤ d`). -/
theorem thm_moderate :
    ∃ A Cm ε₀ : ℝ, 0 < A ∧ 0 < Cm ∧ 0 < ε₀ ∧ ε₀ ≤ 1 / 2 ∧
      Linear.ModerateParsevalBound A ε₀ Cm := by
  obtain ⟨CE, hCE, hret⟩ := lem_retraction
  obtain ⟨tstar, ht0, ht1, h1, h2⟩ := seed_graph_tstar_exists hCE
  have hsg := lem_seed_graph_explicit hCE hret ht0 ht1 h1 h2
  obtain ⟨Afun, hAfun⟩ := lem_sample_explicit
  obtain ⟨D, A, ε₀, hA, hch⟩ := moderate_choice_exists hCE ht0 Afun
  have hΘ2 : 2 ≤ modTheta CE := le_max_left _ _
  refine ⟨A, modCm CE, ε₀, hA, by unfold modCm; positivity, hch.ε₀_pos, hch.ε₀_le,
    thm_moderate_explicit hAfun hCE hret ht0 ht1 hsg hch⟩

end

end Paulsen.Paper
