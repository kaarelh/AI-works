import Paulsen.Paper.ManyRow
import Paulsen.Paper.ManyRowAux3

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

theorem mr_aux_theta_pos {h : ℝ} (hh : 0 < h) :
    42 ≤ mrTheta h ∧ 0 < mrSmallTheta h ∧ mrSmallTheta h ≤ 1 / 168 := by
  have hΘ42 : 42 ≤ mrTheta h := le_max_left _ _
  have hΘpos : 0 < mrTheta h := by linarith
  refine ⟨hΘ42, lt_min (by positivity) (by positivity), ?_⟩
  calc mrSmallTheta h ≤ 1 / (4 * mrTheta h) := min_le_left _ _
    _ ≤ 1 / 168 := by
      rw [div_le_div_iff₀ (by positivity) (by norm_num)]; linarith

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
  obtain ⟨hΘ42, hθpos, hθ168⟩ := mr_aux_theta_pos hh
  have hΘmix : mrCmix h ≤ mrTheta h := le_max_right _ _
  have hθ1 : mrSmallTheta h ≤ 1 / (4 * mrTheta h) := min_le_left _ _
  have hθ2 : mrSmallTheta h ≤ h / 60 := min_le_right _ _
  have hCR : 0 < mrCR CM := by unfold mrCR; positivity
  have ht1pos : 0 < mrT1 h t₀ CM := lt_min ht₀ (by positivity)
  have ht1t0 : mrT1 h t₀ CM ≤ t₀ := min_le_left _ _
  have ht1b : mrT1 h t₀ CM ≤ mrSmallTheta h / (16 * mrCR CM) := min_le_right _ _
  have hcs : 0 < mrCStar h t₀ CM := by unfold mrCStar; positivity
  have ht1sq : mrT1 h t₀ CM ^ 2 ≤ 1 := by
    have := pow_le_pow_left₀ ht1pos.le (ht1t0.trans ht₀1) 2
    simpa using this
  have hcs64 : mrCStar h t₀ CM ≤ 1 / 64 := by
    unfold mrCStar
    have := mul_le_mul hθ168 ht1sq (sq_nonneg _) (by norm_num)
    linarith
  refine ⟨hΘ42, hΘmix, hθpos, hθ1, hθ2, ht1pos, ht1t0, ht1b, hcs, hcs64,
    by unfold mrCostStar; positivity, fun η hη hηc => ?_⟩
  have h4 : 0 ≤ 4 * η / mrSmallTheta h := by positivity
  have ht2 : mrAmplitude h η ^ 2 = 4 * η / mrSmallTheta h := Real.sq_sqrt h4
  refine ⟨ht2, Real.sqrt_pos.mpr (by positivity), ?_⟩
  have hle : 4 * η / mrSmallTheta h ≤ mrT1 h t₀ CM ^ 2 := by
    rw [div_le_iff₀ hθpos]
    unfold mrCStar at hηc
    nlinarith
  calc mrAmplitude h η = Real.sqrt (4 * η / mrSmallTheta h) := rfl
    _ ≤ Real.sqrt (mrT1 h t₀ CM ^ 2) := Real.sqrt_le_sqrt hle
    _ = mrT1 h t₀ CM := Real.sqrt_sq ht1pos.le

/-- Existence of `B` (proof of `thm:manyrow`, "choose `B` so large that ..."). -/
theorem mr_B_exists {h c₁ : ℝ} (hh : 0 < h) (hh1 : h ≤ 1) (hc₁ : 0 < c₁) :
    ∃ B : ℝ, 0 < B ∧ MrBChoice h c₁ B := by
  obtain ⟨-, hθ, -⟩ := mr_aux_theta_pos hh
  set θ := mrSmallTheta h
  have hκ : 0 < mrKappa0 h := by unfold mrKappa0; positivity
  have hC' : 0 < mrCPrime := by unfold mrCPrime; norm_num
  set B : ℝ := 4 / θ + 2560 / θ ^ 2 + 8 * mrCPrime / mrKappa0 h + 8 + 800 / c₁ ^ 2 with hB
  have p1 : (0:ℝ) ≤ 4 / θ := by positivity
  have p2 : (0:ℝ) ≤ 2560 / θ ^ 2 := by positivity
  have p3 : (0:ℝ) ≤ 8 * mrCPrime / mrKappa0 h := by positivity
  have p5 : (0:ℝ) ≤ 800 / c₁ ^ 2 := by positivity
  have h1 : 4 / θ ≤ B := by rw [hB]; linarith
  have h2 : 2560 / θ ^ 2 ≤ B := by rw [hB]; linarith
  have h3 : 8 * mrCPrime / mrKappa0 h ≤ B := by rw [hB]; linarith
  have h4 : 8 ≤ B := by rw [hB]; linarith
  have h5 : 800 / c₁ ^ 2 ≤ B := by rw [hB]; linarith
  refine ⟨B, by linarith, fun n d hd hn => ?_⟩
  have hdR : (2 : ℝ) ≤ d := by exact_mod_cast hd
  have hD : (4 : ℝ) ≤ (d : ℝ) ^ 2 := by nlinarith
  have hnB : B * 4 ≤ n := le_trans (by nlinarith) hn
  have hnpos : (0 : ℝ) < n := by linarith
  -- `B d² ≤ n` with `B ≥ c` gives `c d² ≤ n`
  have hc (c : ℝ) (hc : c ≤ B) : c * (d : ℝ) ^ 2 ≤ n :=
    le_trans (mul_le_mul_of_nonneg_right hc (by positivity)) hn
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · rw [div_le_iff₀ hnpos]
    have := hc _ h1
    rw [div_mul_eq_mul_div, div_le_iff₀ hθ] at this
    linarith
  · have hsq : 160 * (d : ℝ) ^ 2 / n ≤ (θ / 4) ^ 2 := by
      rw [div_le_iff₀ hnpos]
      have := hc _ h2
      rw [div_mul_eq_mul_div, div_le_iff₀ (by positivity)] at this
      nlinarith
    rw [Real.sqrt_le_left (by positivity)]
    exact hsq
  · have := hc _ h3
    rw [div_mul_eq_mul_div, div_le_iff₀ hκ] at this
    have e : 2 * ((d : ℝ) / n) * mrCPrime * d / mrKappa0 h =
        2 * mrCPrime * (d : ℝ) ^ 2 / (n * mrKappa0 h) := by ring
    rw [e, div_le_iff₀ (by positivity)]
    nlinarith
  · linarith
  · have hn800 : 800 / c₁ ^ 2 ≤ n := le_trans h5 (le_trans (by nlinarith) hn)
    have hn2 : (2 : ℝ) ≤ n := by linarith
    refine (mrx_exp_tail hc₁ hn2).trans ?_
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    rw [div_le_iff₀ (by positivity)] at hn800
    nlinarith

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

/-- `E Q(Z)` is the library trace formula (not a paper item). -/
theorem mr_aux_qmean_eq {n d : ℕ} (X : Frame n d) :
    mrQMean X = tangentQuadraticMean X ((d : ℝ) / n) (tangentNoiseFactor X) := by
  have hQb (Z : Frame n d) (b : ℝ) : mrQ X Z b = tangentQuadratic X Z b :=
    (mrQ_mrR_eq_library X Z b 0).1
  ext j k
  simp only [mrQMean, Matrix.of_apply]
  simp_rw [hQb]
  unfold conditionedNoise
  exact integral_tangentQuadratic X _ _ j k

/-- Integrability of the five Markov functions (not a paper item). -/
theorem mr_aux_markov_integrable {n d : ℕ} (X : Frame n d) :
    Integrable (fun g => frobSq (conditionedNoise X g)) (gaussFrame n d) ∧
    Integrable (fun g => sqDistance (conditionedNoise X g) (rowNoise X g)) (gaussFrame n d) ∧
    Integrable (fun g => frobSq (mrQ X (conditionedNoise X g) ((d : ℝ) / n) - mrQMean X))
      (gaussFrame n d) := by
  refine ⟨?_, ?_, ?_⟩
  · have h := (memLp_norm_sq_gaussianImage (tangentNoiseFactor X)).integrable (by norm_num)
    refine h.congr (Filter.Eventually.of_forall fun g => ?_)
    exact (totalEnergy_frameOfVector _).symm
  · have h := (memLp_tangentNoise_coupling_sq X).integrable (by norm_num)
    refine h.congr (Filter.Eventually.of_forall fun g => ?_)
    simp only
    unfold conditionedNoise rowNoise
    rw [sqDistance_frameOfVector, norm_sub_rev]
  · have hQb (Z : Frame n d) (b : ℝ) : mrQ X Z b = tangentQuadratic X Z b :=
      (mrQ_mrR_eq_library X Z b 0).1
    have hint (j k : Fin d) := (tangentQuadratic_centered_memLp X ((d : ℝ) / n)
      (tangentNoiseFactor X) j k).integrable_sq
    refine (integrable_finsetSum Finset.univ fun j _ =>
      integrable_finsetSum Finset.univ fun k _ => hint j k).congr
      (Filter.Eventually.of_forall fun g => ?_)
    simp only [frobSq, Matrix.sub_apply, hQb, mr_aux_qmean_eq]
    rfl

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
  have hd0 : 0 < d := by omega
  have hd1 : 1 ≤ d := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  obtain ⟨i1, i2, i3⟩ := mr_aux_markov_integrable X
  obtain ⟨i4, i5⟩ := mr_aux_gamma_lambda_integrable hn hd0 X hX t
  obtain ⟨hE1, hE1', hE2, hE2'⟩ := eq_mr_noise hn hd1 X hX
  obtain ⟨-, hE3⟩ := lem_Q hn hd1 X hX
  obtain ⟨hE4, hE5⟩ := lem_remainder_moments hn hd X hX ht ht1
  have hnet (C : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) (hC : opNorm C ^ 2 ≤ 1 / (n : ℝ)) :
      (gaussFrame n d).real {g | 16 < opNorm (frameOfVector (Matrix.toEuclideanLin C g))} ≤
        2 * 5 ^ (n + d) * Real.exp (-8 * n) := by
    have hσ : opNorm C ^ 2 ≤ (1 / Real.sqrt n) ^ 2 := by
      rw [div_pow, one_pow, Real.sq_sqrt hnR.le]; exact hC
    have h := lem_gauss_c C (by norm_num : (0 : ℝ) ≤ 16) hσ
    have e : -(16 : ℝ) ^ 2 / (32 * (1 / Real.sqrt n) ^ 2) = -8 * n := by
      rw [div_pow, one_pow, Real.sq_sqrt hnR.le]; field_simp; ring
    rwa [e] at h
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact mrx_markov20 _ (fun g => Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ =>
      sq_nonneg _) i1 (hE1.le.trans hE1')
  · have e : (20 : ℝ) * d ^ 2 / n = 20 * (d ^ 2 / n) := by ring
    rw [e]
    exact mrx_markov20 _ (fun g => sqDistance_nonneg _ _) i2 (hE2.le.trans hE2')
  · have e : (160 : ℝ) * d ^ 2 / n = 20 * (8 * d ^ 2 / n) := by ring
    rw [e]
    exact mrx_markov20 _ (fun g => Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ =>
      sq_nonneg _) i3 hE3
  · exact mrx_markov20 _ (fun g => Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ =>
      sq_nonneg _) i4 hE4
  · exact mrx_markov20 _ (fun g => Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ =>
      sq_nonneg _) i5 hE5
  · exact hnet _ (tangentNoiseFactor_operator_norm_sq_le X hn)
  · exact hnet _ (Linear.rowTangentNoiseFactor_operator_norm_sq_le' X hn)

/-- The failure budget of the event is less than one. -/
theorem mr_event_budget {n d : ℕ} (hn : 30 ≤ n) (hdn : d ≤ n) :
    5 * (1 / 20 : ℝ) + 2 * (2 * 5 ^ (n + d) * Real.exp (-8 * n)) + 1 / 100 < 1 := by
  have he2 : (2 : ℝ) ≤ Real.exp 1 := by
    have := Real.add_one_le_exp (1 : ℝ); linarith
  have he8 : (256 : ℝ) ≤ Real.exp 8 := by
    have h := pow_le_pow_left₀ (by norm_num) he2 8
    rw [← Real.exp_nat_mul] at h
    norm_num at h
    linarith
  have hkey : (5 : ℝ) ^ (n + d) * Real.exp (-8 * n) ≤ (1 / 10) ^ n := by
    have h1 : (5 : ℝ) ^ (n + d) ≤ 25 ^ n := by
      calc (5 : ℝ) ^ (n + d) ≤ 5 ^ (n + n) := pow_le_pow_right₀ (by norm_num) (by omega)
        _ = 25 ^ n := by rw [← two_mul, pow_mul]; norm_num
    have h2 : Real.exp (-8 * n) = (Real.exp (-8)) ^ n := by
      rw [← Real.exp_nat_mul]; ring_nf
    have h3 : 25 * Real.exp (-8) ≤ 1 / 10 := by
      rw [Real.exp_neg]
      rw [← div_eq_mul_inv, div_le_iff₀ (Real.exp_pos _)]
      linarith
    calc (5 : ℝ) ^ (n + d) * Real.exp (-8 * n) ≤ 25 ^ n * Real.exp (-8) ^ n := by
          rw [h2]; exact mul_le_mul_of_nonneg_right h1 (by positivity)
      _ = (25 * Real.exp (-8)) ^ n := by rw [mul_pow]
      _ ≤ (1 / 10) ^ n := pow_le_pow_left₀ (by positivity) h3 n
  have hp : ((1 : ℝ) / 10) ^ n ≤ 1 / 10 := by
    have := pow_le_pow_of_le_one (by norm_num : (0 : ℝ) ≤ 1 / 10) (by norm_num) (show 1 ≤ n by omega)
    simpa using this
  linarith

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

/-- Consequences of the standing data used throughout the proof (not a paper item). -/
theorem mr_setting_facts {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) :
    0 < n ∧ (30 : ℝ) ≤ n ∧ 2 ≤ d ∧ (d : ℝ) ^ 2 ≤ n ∧ d ≤ n ∧ 0 < (d : ℝ) / n ∧
    42 ≤ mrTheta h ∧ mrCmix h ≤ mrTheta h ∧ 0 < mrSmallTheta h ∧
    mrSmallTheta h ≤ 1 / (4 * mrTheta h) ∧ mrSmallTheta h ≤ h / 60 ∧ mrSmallTheta h ≤ 1 / 168 ∧
    mrAmplitude h η ^ 2 = 4 * η / mrSmallTheta h ∧ 0 < mrAmplitude h η ∧
    mrAmplitude h η ≤ t₀ ∧ mrAmplitude h η ≤ 1 ∧
    mrAmplitude h η ≤ mrSmallTheta h / (16 * mrCR CM) ∧
    η = mrSmallTheta h / 4 * mrAmplitude h η ^ 2 ∧ η ≤ 1 / 64 ∧
    (d : ℝ) ^ 2 / n ≤ mrSmallTheta h / 4 ∧
    Real.sqrt (160 * (d : ℝ) ^ 2 / n) ≤ mrSmallTheta h / 4 ∧
    2 * ((d : ℝ) / n) * mrCPrime * d / mrKappa0 h ≤ 1 / 4 ∧
    (n : ℝ) * Real.exp (-c₁ * ((n : ℝ) - 1)) ≤ 1 / 100 ∧
    mrMoment X ≤ CM := by
  obtain ⟨hB1, hB2, hB3, hB4, hB5⟩ := hs.B_choice n d hs.two_le_d hs.many_rows
  obtain ⟨hΘ42, hΘmix, hθpos, hθ1, hθ2, -, ht1t0, ht1b, -, hcs64, -, hη⟩ :=
    mr_constants hs.h_pos hs.h_le hs.t₀_pos hs.t₀_le hs.CM_nonneg
  obtain ⟨ht2, htpos, htt1⟩ := hη η hs.η_pos hs.η_le
  have hθ168 := (mr_aux_theta_pos hs.h_pos).2.2
  have hnR : (0 : ℝ) < n := by linarith
  have hn : 0 < n := by exact_mod_cast hnR
  have hdn2 : (d : ℝ) ^ 2 ≤ n := by
    have := hB1
    rw [div_le_iff₀ hnR] at this
    nlinarith
  have hd2 := hs.two_le_d
  have hdn : d ≤ n := by
    have hdR : (2 : ℝ) ≤ d := by exact_mod_cast hd2
    have : (d : ℝ) ≤ n := by nlinarith
    exact_mod_cast this
  have hd0 : 0 < d := by omega
  refine ⟨hn, hB4, hd2, hdn2, hdn, by positivity, hΘ42, hΘmix, hθpos, hθ1, hθ2, hθ168, ht2, htpos,
    htt1.trans ht1t0, (htt1.trans ht1t0).trans hs.t₀_le, htt1.trans ht1b, ?_,
    hs.η_le.trans hcs64, hB1, hB2, hB3, hB5, hs.moments n d X hd2 hdn2 hs.equal_norm⟩
  rw [ht2]
  field_simp

/-- The event has positive probability (proof of `thm:manyrow`, "The event"). -/
theorem mr_event_pos {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) :
    0 < (gaussFrame n d).real {g | MrEvent h (mrAmplitude h η) X g} := by
  obtain ⟨hn, hn30, hd2, hdn2, hdn, -, -, -, -, -, -, -, -, htpos, htt0, ht1, -, -, -, -, -, -,
    hB5, -⟩ := mr_setting_facts hs
  set t := mrAmplitude h η
  obtain ⟨f1, f2, f3, f4, f5, f6, f7⟩ :=
    mr_event_failures hn hd2 hdn2 X hs.equal_norm htpos ht1
  have hdense := hs.dense n d X hd2 hs.equal_norm t htpos htt0
  have hbudget := mr_event_budget (by exact_mod_cast hn30) hdn
  set μ := gaussFrame n d
  set D := {g : FrameVector n d | ∀ i : Fin n, 9 / 10 * ((n : ℝ) - 1) ≤
    ((Finset.univ.filter (fun j => j ≠ i ∧
      h * t * Real.sqrt (((d : ℝ) / n) / n) ≤
        |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|)).card : ℝ)}
  set E := {g | MrEvent h t X g}
  set A1 := {g : FrameVector n d | 20 * (d : ℝ) < frobSq (conditionedNoise X g)}
  set A2 := {g : FrameVector n d |
    20 * (d : ℝ) ^ 2 / n < sqDistance (conditionedNoise X g) (rowNoise X g)}
  set A3 := {g : FrameVector n d | 160 * (d : ℝ) ^ 2 / n <
      frobSq (mrQ X (conditionedNoise X g) ((d : ℝ) / n) - mrQMean X)}
  set A4 := {g : FrameVector n d | 20 * mrMoment X <
      frobSq (mrGamma ((d : ℝ) / n) t (conditionedNoise X g) * conditionedNoise X g)}
  set A5 := {g : FrameVector n d | 20 * mrMoment X <
      frobSq (mrLambda ((d : ℝ) / n) t (conditionedNoise X g) * X)}
  set A6 := {g : FrameVector n d | 16 < opNorm (conditionedNoise X g)}
  set A7 := {g : FrameVector n d | 16 < opNorm (rowNoise X g)}
  have hsub : D ⊆ E ∪ A1 ∪ A2 ∪ A3 ∪ A4 ∪ A5 ∪ A6 ∪ A7 := by
    intro g hg
    by_contra hc
    simp only [Set.mem_union, not_or] at hc
    obtain ⟨⟨⟨⟨⟨⟨⟨hE, h1⟩, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩ := hc
    apply hE
    simp only [A1, A2, A3, A4, A5, A6, A7, Set.mem_setOf_eq, not_lt] at h1 h2 h3 h4 h5 h6 h7
    exact ⟨h1, h2, h3, h4, h5, h6, h7, hg⟩
  have hu := measureReal_mono (μ := μ) hsub
  have hU : μ.real (E ∪ A1 ∪ A2 ∪ A3 ∪ A4 ∪ A5 ∪ A6 ∪ A7) ≤
      μ.real E + μ.real A1 + μ.real A2 + μ.real A3 + μ.real A4 + μ.real A5 +
        μ.real A6 + μ.real A7 := by
    have := measureReal_union_le (μ := μ) (E ∪ A1 ∪ A2 ∪ A3 ∪ A4 ∪ A5 ∪ A6) A7
    have := measureReal_union_le (μ := μ) (E ∪ A1 ∪ A2 ∪ A3 ∪ A4 ∪ A5) A6
    have := measureReal_union_le (μ := μ) (E ∪ A1 ∪ A2 ∪ A3 ∪ A4) A5
    have := measureReal_union_le (μ := μ) (E ∪ A1 ∪ A2 ∪ A3) A4
    have := measureReal_union_le (μ := μ) (E ∪ A1 ∪ A2) A3
    have := measureReal_union_le (μ := μ) (E ∪ A1) A2
    have := measureReal_union_le (μ := μ) E A1
    linarith
  have hD : 1 - 1 / 100 ≤ μ.real D := by linarith
  linarith

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
  obtain ⟨hn, -, hd2, -, -, ha, -, -, -, -, -, -, -, htpos, -, ht1, -, -, hη64, -, -, -, -,
    hMCM⟩ := mr_setting_facts hs
  set t := mrAmplitude h η
  set M := mrMoment X
  have hη0 : 0 ≤ η := hs.η_pos.le
  have hXsq : opNorm X ^ 2 ≤ 1 + η := hs.spectral.euclidean_operator_norm_sq_le hη0
  have hX : opNorm X ≤ Real.sqrt 2 :=
    Real.le_sqrt_of_sq_le (by linarith)
  have hS : opNorm (X.transpose * X) ≤ 3 / 2 := by
    have h := mrx_opNorm_mul_le X.transpose X
    rw [mrx_opNorm_transpose] at h
    nlinarith
  refine ⟨hX, hS, ?_, ?_⟩
  · have hglob : X.transpose * conditionedNoise X g + (conditionedNoise X g).transpose * X = 0 :=
      (tangentNoiseFactor_constraints X g).2
    obtain ⟨hR3, hR4⟩ := lem_remainder X (conditionedNoise X g) ha htpos ht1 hglob
    have hG : Real.sqrt (frobSq (mrGamma ((d : ℝ) / n) t (conditionedNoise X g) *
        conditionedNoise X g)) ≤ Real.sqrt (20 * M) := Real.sqrt_le_sqrt hg.gamma
    have hL : Real.sqrt (frobSq (mrLambda ((d : ℝ) / n) t (conditionedNoise X g) * X)) ≤
        Real.sqrt (20 * M) := Real.sqrt_le_sqrt hg.lambda
    have h40 : Real.sqrt 2 * Real.sqrt (20 * M) = Real.sqrt (40 * M) := by
      rw [← Real.sqrt_mul (by norm_num)]; ring_nf
    have hZ := hg.op_Z
    have hZ0 := mrx_opNorm_nonneg (conditionedNoise X g)
    have hX0 := mrx_opNorm_nonneg X
    have hsG := Real.sqrt_nonneg (frobSq (mrGamma ((d : ℝ) / n) t (conditionedNoise X g) *
        conditionedNoise X g))
    have hsL := Real.sqrt_nonneg (frobSq (mrLambda ((d : ℝ) / n) t (conditionedNoise X g) * X))
    have hs20 := Real.sqrt_nonneg (20 * M)
    have hs2 := Real.sqrt_nonneg (2 : ℝ)
    have e3 : opNorm X * Real.sqrt (frobSq (mrGamma ((d : ℝ) / n) t (conditionedNoise X g) *
        conditionedNoise X g)) ≤ Real.sqrt (40 * M) := by
      rw [← h40]; exact mul_le_mul hX hG hsG hs2
    have e4 : opNorm X * Real.sqrt (frobSq (mrLambda ((d : ℝ) / n) t (conditionedNoise X g) * X)) ≤
        Real.sqrt (40 * M) := by
      rw [← h40]; exact mul_le_mul hX hL hsL hs2
    have e5 : opNorm (conditionedNoise X g) ^ 2 ≤ 256 := by nlinarith
    have e6 : opNorm (conditionedNoise X g) * Real.sqrt (frobSq (mrGamma ((d : ℝ) / n) t
        (conditionedNoise X g) * conditionedNoise X g)) ≤ 16 * Real.sqrt (20 * M) :=
      mul_le_mul hZ hG hsG (by norm_num)
    have ht3 : 0 < t ^ 3 := by positivity
    have ht43 : t ^ 4 ≤ t ^ 3 := by
      have := pow_le_pow_of_le_one htpos.le ht1 (show 3 ≤ 4 by norm_num); exact this
    have hbr : 0 ≤ 256 + 16 * Real.sqrt (20 * M) + 3 / 2 + Real.sqrt (40 * M) := by positivity
    have hR4' : opNorm (mrR4 X (conditionedNoise X g) ((d : ℝ) / n) t) ≤
        t ^ 3 * (256 + 16 * Real.sqrt (20 * M) + 3 / 2 + Real.sqrt (40 * M)) := by
      refine hR4.trans ?_
      calc t ^ 4 * (opNorm (conditionedNoise X g) ^ 2 + _ + opNorm (X.transpose * X) + _)
          ≤ t ^ 4 * (256 + 16 * Real.sqrt (20 * M) + 3 / 2 + Real.sqrt (40 * M)) := by
            apply mul_le_mul_of_nonneg_left _ (by positivity); linarith
        _ ≤ _ := mul_le_mul_of_nonneg_right ht43 hbr
    have hR3' : opNorm (mrR3 X (conditionedNoise X g) ((d : ℝ) / n) t) ≤
        t ^ 3 * (2 * Real.sqrt (40 * M)) := by
      refine hR3.trans ?_
      have := mul_le_mul_of_nonneg_left e3 (show (0 : ℝ) ≤ 2 * t ^ 3 by positivity)
      linarith
    nlinarith
  · have hCM0 : 0 ≤ CM := hs.CM_nonneg
    have h40 : Real.sqrt (40 * M) ≤ 32 / 5 * Real.sqrt CM := by
      calc Real.sqrt (40 * M) ≤ Real.sqrt (40 * CM) := Real.sqrt_le_sqrt (by linarith)
        _ = Real.sqrt 40 * Real.sqrt CM := Real.sqrt_mul (by norm_num) _
        _ ≤ 32 / 5 * Real.sqrt CM := by
          apply mul_le_mul_of_nonneg_right _ (Real.sqrt_nonneg _)
          rw [Real.sqrt_le_left (by norm_num)]; norm_num
    have h20 : Real.sqrt (20 * M) ≤ 9 / 2 * Real.sqrt CM := by
      calc Real.sqrt (20 * M) ≤ Real.sqrt (20 * CM) := Real.sqrt_le_sqrt (by linarith)
        _ = Real.sqrt 20 * Real.sqrt CM := Real.sqrt_mul (by norm_num) _
        _ ≤ 9 / 2 * Real.sqrt CM := by
          apply mul_le_mul_of_nonneg_right _ (Real.sqrt_nonneg _)
          rw [Real.sqrt_le_left (by norm_num)]; norm_num
    have hsC := Real.sqrt_nonneg CM
    unfold mrCR
    rw [mul_comm (300 + 100 * Real.sqrt CM)]
    apply mul_le_mul_of_nonneg_left _ (by positivity)
    nlinarith

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
  obtain ⟨hn, -, hd2, hdn2, -, ha, -, -, hθpos, -, -, -, -, htpos, -, ht1, htCR, hηeq, -, hB1,
    hB2, -, -, -⟩ := mr_setting_facts hs
  set t := mrAmplitude h η
  set θ := mrSmallTheta h
  set Z := conditionedNoise X g
  have hglob : X.transpose * Z + Z.transpose * X = 0 := (tangentNoiseFactor_constraints X g).2
  have hid := (eq_mr_identity X Z ha t hglob).2
  have hV : conditionedSeed X t g = tangentSeed X Z ((d : ℝ) / n) t := rfl
  have hdecomp : (conditionedSeed X t g).transpose * conditionedSeed X t g - 1 =
      (1 - t ^ 2) • (X.transpose * X - 1) +
      t ^ 2 • (mrQMean X - (1 - X.transpose * X)) +
      t ^ 2 • (mrQ X Z ((d : ℝ) / n) - mrQMean X) +
      mrR3 X Z ((d : ℝ) / n) t + mrR4 X Z ((d : ℝ) / n) t := by
    rw [hV, hid]
    module
  have hd1 : 1 ≤ d := by omega
  obtain ⟨-, -, hrem, hCR⟩ := mr_remainder_bound hs g hg
  have hSI : opNorm (X.transpose * X - 1) ≤ η :=
    (isNearlyParseval_iff_opNorm X hs.η_pos.le).mp hs.spectral
  have hQm : opNorm (mrQMean X - (1 - X.transpose * X)) ≤ (d : ℝ) ^ 2 / n := by
    have h1 := (lem_Q hn hd1 X hs.equal_norm).1
    obtain ⟨-, hm1, hm2⟩ := mr_codim_le X hs.equal_norm hd1
    exact h1.trans (div_le_div_of_nonneg_right (hm1.trans hm2) (by positivity))
  have hQf : opNorm (mrQ X Z ((d : ℝ) / n) - mrQMean X) ≤ Real.sqrt (160 * (d : ℝ) ^ 2 / n) :=
    (mrx_opNorm_le_sqrt_frobSq _).trans (Real.sqrt_le_sqrt hg.fluctuation)
  have ht2 : 0 < t ^ 2 := by positivity
  have h1t : |1 - t ^ 2| ≤ 1 := by
    rw [abs_le]; constructor <;> nlinarith
  have hbound : opNorm ((conditionedSeed X t g).transpose * conditionedSeed X t g - 1) ≤
      η + t ^ 2 * ((d : ℝ) ^ 2 / n) + t ^ 2 * Real.sqrt (160 * (d : ℝ) ^ 2 / n) +
        mrCR CM * t ^ 3 := by
    rw [hdecomp]
    have a1 := mrx_opNorm_add_le ((1 - t ^ 2) • (X.transpose * X - 1) +
      t ^ 2 • (mrQMean X - (1 - X.transpose * X)) + t ^ 2 • (mrQ X Z ((d : ℝ) / n) - mrQMean X) +
      mrR3 X Z ((d : ℝ) / n) t) (mrR4 X Z ((d : ℝ) / n) t)
    have a2 := mrx_opNorm_add_le ((1 - t ^ 2) • (X.transpose * X - 1) +
      t ^ 2 • (mrQMean X - (1 - X.transpose * X)) + t ^ 2 • (mrQ X Z ((d : ℝ) / n) - mrQMean X))
      (mrR3 X Z ((d : ℝ) / n) t)
    have a3 := mrx_opNorm_add_le ((1 - t ^ 2) • (X.transpose * X - 1) +
      t ^ 2 • (mrQMean X - (1 - X.transpose * X))) (t ^ 2 • (mrQ X Z ((d : ℝ) / n) - mrQMean X))
    have a4 := mrx_opNorm_add_le ((1 - t ^ 2) • (X.transpose * X - 1))
      (t ^ 2 • (mrQMean X - (1 - X.transpose * X)))
    rw [mrx_opNorm_smul] at a4 a3
    rw [mrx_opNorm_smul] at a4
    rw [abs_of_pos ht2] at a4 a3
    have b1 : |1 - t ^ 2| * opNorm (X.transpose * X - 1) ≤ η := by
      calc _ ≤ 1 * η := mul_le_mul h1t hSI (mrx_opNorm_nonneg _) (by norm_num)
        _ = η := one_mul η
    have b2 := mul_le_mul_of_nonneg_left hQm ht2.le
    have b3 := mul_le_mul_of_nonneg_left hQf ht2.le
    have hR' : opNorm (mrR3 X Z ((d : ℝ) / n) t) + opNorm (mrR4 X Z ((d : ℝ) / n) t) ≤
        mrCR CM * t ^ 3 := hrem.trans hCR
    linarith
  refine ⟨hdecomp, hbound, ?_, ?_⟩
  · have c1 : η ≤ θ / 4 * t ^ 2 := by rw [hηeq]
    have c2 : t ^ 2 * ((d : ℝ) ^ 2 / n) ≤ θ / 4 * t ^ 2 := by nlinarith
    have c3 : t ^ 2 * Real.sqrt (160 * (d : ℝ) ^ 2 / n) ≤ θ / 4 * t ^ 2 := by nlinarith
    have hCRpos : 0 < mrCR CM := by unfold mrCR; positivity
    have c4 : mrCR CM * t ^ 3 ≤ θ / 16 * t ^ 2 := by
      have : mrCR CM * t ≤ θ / 16 := by
        rw [le_div_iff₀ (by positivity)] at htCR
        nlinarith
      have e : mrCR CM * t ^ 3 = (mrCR CM * t) * t ^ 2 := by ring
      rw [e]; exact mul_le_mul_of_nonneg_right this ht2.le
    linarith
  · have : 0 < θ * t ^ 2 := by positivity
    linarith

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
  obtain ⟨hn, -, hd2, -, -, ha, -, -, -, -, -, -, -, htpos, -, ht1, -, -, -, -, -, -, -, -⟩ :=
    mr_setting_facts hs
  set t := mrAmplitude h η
  set Z := conditionedNoise X g
  set Z₀ := rowNoise X g
  have hZ : ∀ i, rowDot X Z i = 0 := (tangentNoiseFactor_constraints X g).1
  have hZ₀ : ∀ i, rowDot X Z₀ i = 0 := rowTangentNoiseFactor_constraints X g
  obtain ⟨-, -, -, hVV₀, hV, hV₀⟩ :=
    eq_mr_contract X Z Z₀ ha htpos ht1 hs.equal_norm hZ hZ₀
  have hXsq : opNorm X ^ 2 ≤ 1 + η := hs.spectral.euclidean_operator_norm_sq_le hs.η_pos.le
  have hη64 : η ≤ 1 / 64 := (mr_setting_facts hs).2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1
  have hX : opNorm X ≤ Real.sqrt 2 := Real.le_sqrt_of_sq_le (by linarith)
  have hpert (W : Frame n d) (hW : opNorm W ≤ 16) : opNorm (X + t • W) ≤ Real.sqrt 2 + 16 := by
    calc opNorm (X + t • W) ≤ opNorm X + opNorm (t • W) := mrx_opNorm_add_le _ _
      _ = opNorm X + t * opNorm W := by rw [mrx_opNorm_smul, abs_of_pos htpos]
      _ ≤ Real.sqrt 2 + 1 * 16 := by
        have := mul_le_mul ht1 hW (mrx_opNorm_nonneg _) (by norm_num)
        linarith
      _ = _ := by ring
  have h1 : opNorm (conditionedSeed X t g) ≤ Real.sqrt 2 + 16 := hV.trans (hpert Z hg.op_Z)
  have h2 : opNorm (rowIndependentSeed X t g) ≤ Real.sqrt 2 + 16 := hV₀.trans (hpert Z₀ hg.op_Z₀)
  have h3 : Real.sqrt 2 + 16 ≤ 18 := by
    have : Real.sqrt 2 ≤ 2 := by rw [Real.sqrt_le_left (by norm_num)]; norm_num
    linarith
  have hgram := sqDistance_gram_le (conditionedSeed X t g) (rowIndependentSeed X t g)
  have hn1 : opNorm (conditionedSeed X t g) ^ 2 ≤ 18 ^ 2 :=
    pow_le_pow_left₀ (mrx_opNorm_nonneg _) (h1.trans h3) 2
  have hn2 : opNorm (rowIndependentSeed X t g) ^ 2 ≤ 18 ^ 2 :=
    pow_le_pow_left₀ (mrx_opNorm_nonneg _) (h2.trans h3) 2
  have hsqP : sqDistance (frameProjection (conditionedSeed X t g))
      (frameProjection (rowIndependentSeed X t g)) ≤
      36 ^ 2 * sqDistance (conditionedSeed X t g) (rowIndependentSeed X t g) := by
    refine hgram.trans ?_
    apply mul_le_mul_of_nonneg_right _ (sqDistance_nonneg _ _)
    change 2 * (opNorm (conditionedSeed X t g) ^ 2 + opNorm (rowIndependentSeed X t g) ^ 2) ≤ _
    linarith
  have hVsq : sqDistance (conditionedSeed X t g) (rowIndependentSeed X t g) ≤
      t ^ 2 * sqDistance Z Z₀ := by
    have h := pow_le_pow_left₀ (Real.sqrt_nonneg _) hVV₀ 2
    rwa [Real.sq_sqrt (sqDistance_nonneg _ _), mul_pow, Real.sq_sqrt (sqDistance_nonneg _ _)] at h
  have h4 : Real.sqrt (sqDistance (frameProjection (conditionedSeed X t g))
      (frameProjection (rowIndependentSeed X t g))) ≤ 36 * t * Real.sqrt (sqDistance Z Z₀) := by
    have : 36 * t * Real.sqrt (sqDistance Z Z₀) = Real.sqrt (36 ^ 2 * (t ^ 2 * sqDistance Z Z₀)) := by
      rw [Real.sqrt_mul (by norm_num), Real.sqrt_mul (sq_nonneg _), Real.sqrt_sq (by norm_num),
        Real.sqrt_sq htpos.le]; ring
    rw [this]
    exact Real.sqrt_le_sqrt (hsqP.trans (mul_le_mul_of_nonneg_left hVsq (by norm_num)))
  refine ⟨h1, h2, h3, h4, ?_⟩
  calc _ ≤ 36 ^ 2 * (t ^ 2 * sqDistance Z Z₀) :=
        hsqP.trans (mul_le_mul_of_nonneg_left hVsq (by norm_num))
    _ ≤ 36 ^ 2 * (t ^ 2 * (20 * (d : ℝ) ^ 2 / n)) := by
        gcongr; exact hg.coupling
    _ = _ := by unfold mrCPrime; ring

theorem mr_aux_sqDistance_eq_sum_rows {n m : ℕ} (A B : Matrix (Fin n) (Fin m) ℝ) :
    sqDistance A B = ∑ i, rowNormSq (A - B) i := by
  simp [sqDistance, rowNormSq, Matrix.sub_apply]

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
  obtain ⟨hn, hn30, hd2, -, -, ha, -, -, -, -, -, -, -, htpos, htt0, ht1, -, -, -, -, -, -, -, -⟩ :=
    mr_setting_facts hs
  set t := mrAmplitude h η
  set a := (d : ℝ) / n with ha_def
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hh := hs.h_pos
  have hκ : 0 < mrKappa0 h := by unfold mrKappa0; positivity
  set P := frameProjection (conditionedSeed X t g)
  set P₀ := frameProjection (rowIndependentSeed X t g)
  have hcoup := (mr_graph_coupling hs g hg).2.2.2.2
  have hratio : mrKappa0 h * a * t ^ 2 / ((h / 2) ^ 2 * t ^ 2 * a / n) = (n : ℝ) / 50 := by
    unfold mrKappa0; field_simp; ring
  have hτ : 0 < h / 2 * t * Real.sqrt (a / n) := by
    have : 0 < Real.sqrt (a / n) := Real.sqrt_pos.mpr (by positivity)
    positivity
  have hτsq : (h / 2 * t * Real.sqrt (a / n)) ^ 2 = (h / 2) ^ 2 * t ^ 2 * a / n := by
    rw [mul_pow, mul_pow, Real.sq_sqrt (by positivity)]; ring
  have hsmall (i : Fin n) (hi : i ∉ mrExceptional h t X g) :
      ((Finset.univ.filter (fun j => h / 2 * t * Real.sqrt (a / n) ≤ |(P - P₀) i j|)).card : ℝ) ≤
        (n : ℝ) / 50 := by
    have hrow : rowNormSq (P - P₀) i ≤ mrKappa0 h * a * t ^ 2 := by
      simpa [mrExceptional] using hi
    have := mrx_count_le (fun j => (P - P₀) i j) hτ hrow
    rwa [hτsq, hratio] at this
  refine ⟨?_, hratio, fun i hi => ⟨hsmall i hi, ?_⟩⟩
  · have h1 := mrx_count_exceptional (fun i => rowNormSq (P - P₀) i)
      (fun i => rowNormSq_nonneg _ i) (show 0 < mrKappa0 h * a * t ^ 2 by positivity)
      ((mr_aux_sqDistance_eq_sum_rows P P₀).symm.le.trans hcoup)
    have e : mrCPrime * t ^ 2 * (d : ℝ) ^ 2 / n / (mrKappa0 h * a * t ^ 2) =
        mrCPrime * d / mrKappa0 h := by
      rw [ha_def]; field_simp
    rw [e] at h1
    exact h1
  · -- perturbation of the dense reference graph
    have hd := hg.dense i
    have hp := mrx_count_perturb (fun j => P₀ i j) (fun j => P i j) (fun j => j ≠ i)
      (h * t * Real.sqrt (a / n)) (h / 2 * t * Real.sqrt (a / n))
    have hsm := hsmall i hi
    have e1 : (Finset.univ.filter (fun j => h / 2 * t * Real.sqrt (a / n) ≤ |P₀ i j - P i j|)) =
        Finset.univ.filter (fun j => h / 2 * t * Real.sqrt (a / n) ≤ |(P - P₀) i j|) := by
      apply Finset.filter_congr; intro j _
      rw [Matrix.sub_apply, abs_sub_comm]
    have e2 : h * t * Real.sqrt (a / n) - h / 2 * t * Real.sqrt (a / n) =
        h / 2 * t * Real.sqrt (a / n) := by ring
    rw [e1, e2] at hp
    have hd' : 9 / 10 * ((n : ℝ) - 1) ≤ ((Finset.univ.filter (fun j => j ≠ i ∧
        h * t * Real.sqrt (a / n) ≤ |P₀ i j|)).card : ℝ) := hd
    linarith

/-- The polar-factor data of the seed (not a paper item). -/
theorem mr_aux_polar {h t₀ c₁ CM B : ℝ} {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hs : MrSetting h t₀ c₁ CM B X η) (g : FrameVector n d)
    (hg : MrEvent h (mrAmplitude h η) X g) :
    0 ≤ opNorm ((conditionedSeed X (mrAmplitude h η) g).transpose *
        conditionedSeed X (mrAmplitude h η) g - 1) ∧
    opNorm ((conditionedSeed X (mrAmplitude h η) g).transpose *
        conditionedSeed X (mrAmplitude h η) g - 1) < mrSmallTheta h * mrAmplitude h η ^ 2 ∧
    opNorm ((conditionedSeed X (mrAmplitude h η) g).transpose *
        conditionedSeed X (mrAmplitude h η) g - 1) ≤ 1 / 168 ∧
    IsNearlyParseval (opNorm ((conditionedSeed X (mrAmplitude h η) g).transpose *
        conditionedSeed X (mrAmplitude h η) g - 1)) (conditionedSeed X (mrAmplitude h η) g) ∧
    (∀ i, rowNormSq (conditionedSeed X (mrAmplitude h η) g) i = (d : ℝ) / n) ∧
    IsParseval (polarFactor (conditionedSeed X (mrAmplitude h η) g)) := by
  obtain ⟨-, -, -, -, -, ha, -, -, hθpos, -, -, hθ168, -, htpos, -, ht1, -, -, -, -, -, -, -, -⟩ :=
    mr_setting_facts hs
  set t := mrAmplitude h η
  set δ := opNorm ((conditionedSeed X t g).transpose * conditionedSeed X t g - 1)
  have hδ0 : 0 ≤ δ := mrx_opNorm_nonneg _
  obtain ⟨-, h1, h2, h3⟩ := mr_spectral_error hs g hg
  have hδ : δ < mrSmallTheta h * t ^ 2 := lt_of_le_of_lt (h1.trans h2) h3
  have ht2 : t ^ 2 ≤ 1 := by nlinarith
  have hδ168 : δ ≤ 1 / 168 := by
    have : mrSmallTheta h * t ^ 2 ≤ 1 / 168 := by nlinarith
    linarith
  have hVp : IsNearlyParseval δ (conditionedSeed X t g) :=
    (isNearlyParseval_iff_opNorm _ hδ0).mpr le_rfl
  have hZ : ∀ i, rowDot X (conditionedNoise X g) i = 0 := (tangentNoiseFactor_constraints X g).1
  have hrows : ∀ i, rowNormSq (conditionedSeed X t g) i = (d : ℝ) / n := fun i =>
    tangentSeed_rowNormSq X _ _ t ha i (hs.equal_norm i) (hZ i)
  exact ⟨hδ0, hδ, hδ168, hVp, hrows,
    (lem_align_polar _ hδ0 (by linarith) hVp).1⟩

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
  obtain ⟨hn, hn30, hd2, -, -, ha, -, -, hθpos, -, hθh, hθ168, -, htpos, htt0, ht1, -, -, -, -, -,
    hB3, -, -⟩ := mr_setting_facts hs
  obtain ⟨hδ0, hδ, hδ168, hVp, hrows, hU⟩ := mr_aux_polar hs g hg
  set t := mrAmplitude h η
  set a := (d : ℝ) / n with ha_def
  set θ := mrSmallTheta h
  set V := conditionedSeed X t g
  set U := polarFactor V
  set δ := opNorm (V.transpose * V - 1)
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hh := hs.h_pos
  have hδh : δ ≤ 1 / 2 := by linarith
  have hδsq : δ ^ 2 ≤ θ ^ 2 * t ^ 4 := by
    have := pow_le_pow_left₀ hδ0 hδ.le 2; nlinarith
  have hrowU (i : Fin n) : rowNormSq (frameProjection U - frameProjection V) i ≤
      6 * a * θ ^ 2 * t ^ 4 := by
    have := (lem_align_polar_half V hδ0 hδh hVp i).2
    rw [hrows i] at this
    nlinarith
  have hratio : 6 * a * θ ^ 2 * t ^ 4 / ((h / 4) ^ 2 * t ^ 2 * a / n) ≤ (n : ℝ) / 20 := by
    have e : 6 * a * θ ^ 2 * t ^ 4 / ((h / 4) ^ 2 * t ^ 2 * a / n) = 96 * θ ^ 2 * t ^ 2 * n / h ^ 2 := by
      field_simp; ring
    rw [e, div_le_div_iff₀ (by positivity) (by norm_num)]
    have hθsq : θ ^ 2 ≤ (h / 60) ^ 2 := pow_le_pow_left₀ hθpos.le hθh 2
    have ht2 : t ^ 2 ≤ 1 := by nlinarith
    have : θ ^ 2 * t ^ 2 ≤ (h / 60) ^ 2 := by nlinarith
    nlinarith
  have hdiag (i : Fin n) : a / 2 ≤ frameProjection U i i ∧ frameProjection U i i ≤ 2 * a := by
    rw [frameProjection_diagonal]
    have := (lem_align_polar_half V hδ0 hδh hVp i).1
    rw [hrows i, abs_le] at this
    constructor <;> nlinarith
  refine ⟨hrowU, hratio, fun i hi => ?_, hdiag, ?_⟩
  · obtain ⟨-, -, h85⟩ := mr_graph_exceptional hs g hg
    have h85i := (h85 i hi).2
    have hτ : 0 < h / 4 * t * Real.sqrt (a / n) := by
      have : 0 < Real.sqrt (a / n) := Real.sqrt_pos.mpr (by positivity)
      positivity
    have hτsq : (h / 4 * t * Real.sqrt (a / n)) ^ 2 = (h / 4) ^ 2 * t ^ 2 * a / n := by
      rw [mul_pow, mul_pow, Real.sq_sqrt (by positivity)]; ring
    have hsm := mrx_count_le (fun j => (frameProjection U - frameProjection V) i j) hτ (hrowU i)
    rw [hτsq] at hsm
    have hp := mrx_count_perturb (fun j => frameProjection V i j) (fun j => frameProjection U i j)
      (fun j => j ≠ i) (h / 2 * t * Real.sqrt (a / n)) (h / 4 * t * Real.sqrt (a / n))
    have e1 : (Finset.univ.filter (fun j => h / 4 * t * Real.sqrt (a / n) ≤
        |frameProjection V i j - frameProjection U i j|)) =
        Finset.univ.filter (fun j => h / 4 * t * Real.sqrt (a / n) ≤
          |(frameProjection U - frameProjection V) i j|) := by
      apply Finset.filter_congr; intro j _
      rw [Matrix.sub_apply, abs_sub_comm]
    have e2 : h / 2 * t * Real.sqrt (a / n) - h / 4 * t * Real.sqrt (a / n) =
        h / 4 * t * Real.sqrt (a / n) := by ring
    rw [e1, e2] at hp
    have hsub : Finset.univ.filter (fun j => j ≠ i ∧ h / 4 * t * Real.sqrt (a / n) ≤
        |frameProjection U i j|) ⊆ Finset.univ.filter (fun j => j ≠ i ∧
          h ^ 2 / 16 * a * t ^ 2 / n ≤ frameProjection U i j ^ 2) := by
      intro j hj
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hj ⊢
      refine ⟨hj.1, ?_⟩
      have := pow_le_pow_left₀ hτ.le hj.2 2
      rw [sq_abs, hτsq] at this
      have e : (h / 4) ^ 2 * t ^ 2 * a / n = h ^ 2 / 16 * a * t ^ 2 / n := by ring
      linarith
    have hc := Finset.card_le_card hsub
    have hcR : ((Finset.univ.filter (fun j => j ≠ i ∧ h / 4 * t * Real.sqrt (a / n) ≤
        |frameProjection U i j|)).card : ℝ) ≤ ((Finset.univ.filter (fun j => j ≠ i ∧
          h ^ 2 / 16 * a * t ^ 2 / n ≤ frameProjection U i j ^ 2)).card : ℝ) := by
      exact_mod_cast hc
    linarith
  · have hcard := (mr_graph_exceptional hs g hg).1
    calc ∑ i ∈ mrExceptional h t X g, frameProjection U i i
        ≤ ∑ _i ∈ mrExceptional h t X g, 2 * a := Finset.sum_le_sum fun i _ => (hdiag i).2
      _ = ((mrExceptional h t X g).card : ℝ) * (2 * a) := by rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ mrCPrime * d / mrKappa0 h * (2 * a) := mul_le_mul_of_nonneg_right hcard (by positivity)
      _ = 2 * a * mrCPrime * d / mrKappa0 h := by ring
      _ ≤ 1 / 4 := hB3

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
  obtain ⟨hn, -, -, -, -, ha, -, -, -, -, -, -, -, htpos, -, ht1, -, -, -, -, -, -, -, -⟩ :=
    mr_setting_facts hs
  obtain ⟨-, -, -, -, -, hU⟩ := mr_aux_polar hs g hg
  obtain ⟨-, -, hcount, hdiag, htrace⟩ := mr_graph_whitened hs g hg
  set t := mrAmplitude h η
  set a := (d : ℝ) / n with ha_def
  set U := polarFactor (conditionedSeed X t g)
  set B₀ := mrExceptional h t X g
  set γ := h ^ 2 * a * t ^ 2 / 16 with hγ
  have hh := hs.h_pos
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hγpos : 0 < γ := by positivity
  set w : Fin n → Fin n → ℝ := fun i j => frameProjection U i j ^ 2
  have hw : ∀ i j, 0 ≤ w i j := fun i j => sq_nonneg _
  have hsymm : ∀ i j, w i j = w j i := fun i j => by simp only [w, frameProjection_symm U i j]
  have hF : 2 / (3 * a) * (2 * a) = 4 / 3 := by field_simp; ring
  have hcore : CoreDense w B₀ (3 / 10 * γ) := by
    apply lem_core_i w hw hsymm B₀ (by norm_num) (by norm_num) hγpos
    intro i hi
    simp only [Fintype.card_fin]
    have hci := hcount i hi
    have e : Finset.univ.filter (fun j => j ≠ i ∧ γ / (n : ℝ) ≤ w i j) =
        Finset.univ.filter (fun j => j ≠ i ∧ h ^ 2 / 16 * a * t ^ 2 / n ≤
          frameProjection U i j ^ 2) := by
      apply Finset.filter_congr; intro j _
      have : γ / (n : ℝ) = h ^ 2 / 16 * a * t ^ 2 / n := by rw [hγ]; ring
      rw [this]
    rw [e]
    linarith
  have hexc : CoreExceptional w B₀ (8 / (3 * a)) (2 / (3 * a) * (2 * a)) := by
    apply lem_core_iii U hU B₀ ha
    · intro i _
      rw [← frameProjection_diagonal]; exact (hdiag i).1
    · calc ∑ i ∈ B₀, rowNormSq U i = ∑ i ∈ B₀, frameProjection U i i :=
            Finset.sum_congr rfl fun i _ => (frameProjection_diagonal U i).symm
        _ ≤ 1 / 4 := htrace
    · intro i; rw [← frameProjection_diagonal]; exact (hdiag i).2
  have hbar := lem_core w hw hsymm B₀ (by positivity : (0 : ℝ) < 3 / 10 * γ)
    (by positivity : (0 : ℝ) ≤ 8 / (3 * a)) (by positivity) hcore hexc
  rw [hF] at hbar
  refine ⟨hF.le, ?_, ?_⟩
  · have e : (1 + 4 / 3 : ℝ) = 7 / 3 := by norm_num
    rw [e] at hbar
    exact hbar
  · unfold mrCmix
    have ht2 : t ^ 2 ≤ 1 := by nlinarith
    have hpos : 0 < a * t ^ 2 := by positivity
    have e1 : (7 / 3) / (3 / 10 * γ) = (1120 / 9) / h ^ 2 / (a * t ^ 2) := by
      rw [hγ]; field_simp; ring
    have e2 : (125 / h ^ 2 + 3) / (a * t ^ 2) = 125 / h ^ 2 / (a * t ^ 2) + 3 / (a * t ^ 2) := by
      ring
    rw [e1, e2]
    have i1 : (1120 / 9) / h ^ 2 / (a * t ^ 2) ≤ 125 / h ^ 2 / (a * t ^ 2) := by
      apply div_le_div_of_nonneg_right _ hpos.le
      apply div_le_div_of_nonneg_right _ (by positivity)
      norm_num
    have i2 : 8 / (3 * a) ≤ 3 / (a * t ^ 2) := by
      rw [div_le_div_iff₀ (by positivity) hpos]
      nlinarith
    linarith

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
  obtain ⟨hn, -, hd2, -, -, ha, hΘ42, hΘmix, hθpos, hθΘ, -, hθ168, -, htpos, -, ht1, -, -, -, -,
    -, -, -, -⟩ := mr_setting_facts hs
  obtain ⟨hδ0, hδ, hδ168, hVp, hrows, hU⟩ := mr_aux_polar hs g hg
  set t := mrAmplitude h η
  set a := (d : ℝ) / n with ha_def
  set θ := mrSmallTheta h
  set Θ := mrTheta h
  set V := conditionedSeed X t g
  set U := polarFactor V
  set δ := opNorm (V.transpose * V - 1)
  set Z := conditionedNoise X g
  have hd2R : (2 : ℝ) ≤ d := by exact_mod_cast hd2
  have hdR : (0 : ℝ) < d := by linarith
  have hδh : δ ≤ 1 / 2 := by linarith
  have hZ : ∀ i, rowDot X Z i = 0 := (tangentNoiseFactor_constraints X g).1
  have hdist1 : sqDistance V X ≤ t ^ 2 * frobSq Z := by
    have h := (eq_mr_contract X Z (rowNoise X g) ha htpos ht1 hs.equal_norm hZ
      (rowTangentNoiseFactor_constraints X g)).2.2.1
    have h2 := pow_le_pow_left₀ (Real.sqrt_nonneg _) h 2
    have hF0 : 0 ≤ frobSq Z := Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _
    rwa [Real.sq_sqrt (sqDistance_nonneg _ _), mul_pow, Real.sq_sqrt hF0] at h2
  have hdist2 : sqDistance V U ≤ d * δ ^ 2 := (lem_align_polar V hδ0 (by linarith) hVp).2.1
  have hc1 : sqDistance X U ≤ 2 * d * δ ^ 2 + 2 * t ^ 2 * frobSq Z := by
    have htri := sqDistance_triangle X V U
    rw [sqDistance_symm X V] at htri
    nlinarith
  have ht2 : t ^ 2 ≤ 1 := by nlinarith
  have hc2 : 2 * d * δ ^ 2 + 2 * t ^ 2 * frobSq Z ≤ 42 * t ^ 2 * d := by
    have hδ2 : δ ^ 2 ≤ t ^ 2 := by
      have h1 : δ ≤ θ * t ^ 2 := hδ.le
      have h2 : θ * t ^ 2 ≤ t ^ 2 := by nlinarith
      have h3 : δ ≤ 1 := by linarith
      nlinarith
    have hfr := hg.frob_Z
    nlinarith
  have hc3 (i : Fin n) : |frameProjection U i i - a| ≤ 2 * a * δ := by
    rw [frameProjection_diagonal]
    have := (lem_align_polar_half V hδ0 hδh hVp i).1
    rw [hrows i] at this
    linarith
  have hc4 : 2 * a * δ ≤ 2 * θ * a * t ^ 2 := by nlinarith
  have hΘpos : 0 < Θ := by linarith
  have hc5 : 2 * θ * a * t ^ 2 ≤ a * t ^ 2 / (2 * Θ) := by
    have h1 : θ * (4 * Θ) ≤ 1 := by
      have := mul_le_mul_of_nonneg_right hθΘ (show (0:ℝ) ≤ 4 * Θ by positivity)
      rwa [div_mul_cancel₀ _ (by positivity)] at this
    rw [le_div_iff₀ (by positivity)]
    have : 0 ≤ a * t ^ 2 := by positivity
    nlinarith
  have hc6 : mrCmix h / (a * t ^ 2) ≤ Θ / (a * t ^ 2) :=
    div_le_div_of_nonneg_right hΘmix (by positivity)
  refine ⟨hc1, hc2, hc3, hc4, hc5, hc6, ?_⟩
  obtain ⟨-, hbar, hbarle⟩ := mr_barrier hs g hg
  refine ⟨hU, ?_, ?_, ?_⟩
  · calc sqDistance X U ≤ 42 * t ^ 2 * d := hc1.trans hc2
      _ ≤ Θ * t ^ 2 * d := by
        apply mul_le_mul_of_nonneg_right _ hdR.le
        exact mul_le_mul_of_nonneg_right hΘ42 (sq_nonneg _)
  · exact hbar.mono (hbarle.trans hc6)
  · intro i
    rw [abs_sub_comm, ← frameProjection_diagonal]
    linarith [hc3 i]

/-- Proof of `thm:manyrow`, final cost.

TeX: "\cref{cor:seed} gives an ENP frame within $3\Theta t^2d=(12\Theta/\theta)\eta d$
of $X$; thus $C_*=12\Theta/\theta$ works." -/
theorem mr_final_cost {h η : ℝ} (hh : 0 < h) (hη : 0 ≤ η) (d : ℝ) :
    3 * mrTheta h * mrAmplitude h η ^ 2 * d = mrCostStar h * η * d := by
  obtain ⟨-, hθ, -⟩ := mr_aux_theta_pos hh
  have ht2 : mrAmplitude h η ^ 2 = 4 * η / mrSmallTheta h := Real.sq_sqrt (by positivity)
  rw [ht2]
  unfold mrCostStar
  field_simp
  ring

/-! ## The theorem -/

/-- `thm:manyrow` with the explicit constants of its proof: `c_* = θ t₁²/4`,
`C_* = 12Θ/θ`, and any `B` as chosen in the proof. -/
theorem thm_manyrow_explicit {h t₀ c₁ CM B : ℝ} (hh : 0 < h) (hh1 : h ≤ 1) (ht₀ : 0 < t₀)
    (ht₀1 : t₀ ≤ 1) (hc₁ : 0 < c₁) (hdense : MrDenseConclusion h t₀ c₁) (hCM : 0 ≤ CM)
    (hmom : RowMomentBound CM) (hB : 0 < B) (hBc : MrBChoice h c₁ B) :
    ∀ (n d : ℕ), 2 ≤ d → B * (d : ℝ) ^ 2 ≤ n → ∀ X : Frame n d, IsEqualNorm X →
      ∀ η : ℝ, IsNearlyParseval η X → 0 < η → η ≤ mrCStar h t₀ CM →
        HasCorrection X (mrCostStar h * η * (d : ℝ)) := by
  intro n d hd2 hBn X hX η hXp hη hηc
  have hs : MrSetting h t₀ c₁ CM B X η :=
    { h_pos := hh, h_le := hh1, t₀_pos := ht₀, t₀_le := ht₀1, c₁_pos := hc₁, dense := hdense,
      CM_nonneg := hCM, moments := hmom, B_pos := hB, B_choice := hBc, two_le_d := hd2,
      many_rows := hBn, equal_norm := hX, spectral := hXp, η_pos := hη, η_le := hηc }
  obtain ⟨hn, -, -, -, hdn, -, hΘ42, -, -, -, -, -, -, htpos, -, -, -, -, -, -, -, -, -, -⟩ :=
    mr_setting_facts hs
  have hpos := mr_event_pos hs
  have hne : {g | MrEvent h (mrAmplitude h η) X g}.Nonempty := by
    by_contra hc
    rw [Set.not_nonempty_iff_eq_empty] at hc
    rw [hc] at hpos
    simp at hpos
  obtain ⟨g, hg⟩ := hne
  have hseed := (mr_seed hs g hg).2.2.2.2.2.2
  have hcor := cor_seed (by omega) hdn (by linarith) htpos hseed
  rwa [mr_final_cost hh hη.le] at hcor

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
  obtain ⟨h, t₀, c₁, hh, hh1, ht₀, ht₀1, hc₁, hdense⟩ := lem_mr_dense
  obtain ⟨CM, hCM, hmom⟩ := lem_rowmoments
  obtain ⟨B, hB, hBc⟩ := mr_B_exists hh hh1 hc₁
  obtain ⟨-, -, -, -, -, -, -, -, hcs, -, hCs, -⟩ := mr_constants hh hh1 ht₀ ht₀1 hCM
  exact ⟨B, mrCStar h t₀ CM, mrCostStar h, hB, hcs, hCs,
    thm_manyrow_explicit hh hh1 ht₀ ht₀1 hc₁ hdense hCM hmom hB hBc⟩

end

end Paulsen.Paper
