import Paulsen.Linear.DriftDiagonal
import Paulsen.Linear.ModerateBarrier
import Paulsen.Linear.Seed
import Paulsen.Linear.Assembly
import Paulsen.ModerateParameters
import Paulsen.ModerateRetraction
import Paulsen.SmoothSampleGraph

/-!
# The moderate-row seed theorem with a deterministic drift

The noise `Z` is the filtered Gaussian sample of the smooth moderate
construction. Adding the deterministic horizontal drift `(t/2) m_*` cancels the
filter bias `t² b_*` in the diagonal, so the drifted retraction `U_t` is
directly a seed: its diagonal is within `a t² 10⁻¹⁸` of `a`, its projection is
`P + tY + E` with small rows `E`, so its graph has a dense core off a bounded
deterministic exceptional set and a mean-zero spectral gap `a t²/32`; the
barrier constant is at most `10¹⁵/(a t²)`, and static balancing finishes.
There is no second scaling and no full-mean correction.
-/

namespace Paulsen.Linear

open Matrix Paulsen MeasureTheory ProbabilityTheory
open scoped BigOperators

noncomputable section

/-- Rank threshold constant `A`. -/
def moderateA : ℝ := 10 ^ 130
/-- Diagonal error cap `ε₀`. -/
def moderateEps : ℝ := 1 / 10 ^ 130
/-- Cost constant `C`. -/
def moderateCost : ℝ := 10 ^ 46
/-- Seed constant `Θ`. -/
def moderateTheta : ℝ := 10 ^ 15

theorem moderateA_pos : 0 < moderateA := by norm_num [moderateA]
theorem moderateEps_pos : 0 < moderateEps := by norm_num [moderateEps]
theorem moderateCost_pos : 0 < moderateCost := by norm_num [moderateCost]

/-- The barrier numerics: `(1+|B|)/(γ/5) + |B|/(9λ/10) ≤ Θ/(a t²)`. -/
theorem moderate_barrier_numerics {b s : ℝ} (hb0 : 0 ≤ b) (hb : b ≤ 2000000) (hs : 0 < s) :
    (1 + b) / (s / 16000000 / 5) + b / (9 * (s / 32) / 10) ≤ moderateTheta / s := by
  have e : (1 + b) / (s / 16000000 / 5) + b / (9 * (s / 32) / 10) =
      ((1 + b) * 80000000 + b * (320 / 9)) / s := by
    field_simp
    ring
  rw [e, moderateTheta]
  apply div_le_div_of_nonneg_right _ hs.le
  nlinarith

set_option maxHeartbeats 4000000 in
/-- **Moderate-row seed theorem** (drifted retraction, barrier endpoint). -/
theorem moderateParsevalBound : ModerateParsevalBound moderateA moderateEps moderateCost := by
  intro n d hd hdensity hrank ε hε hεcap U hU hnear
  have hdn : d ≤ n := by omega
  have hn : 0 < n := by omega
  letI : NeZero n := ⟨hn.ne'⟩
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have ha : (0 : ℝ) < (d : ℝ) / (n : ℝ) := div_pos hdR hnR
  have haf : (d : ℝ) / (n : ℝ) ≤ 1 / 2 := by
    apply (div_le_iff₀ hnR).mpr
    have hh : 2 * (d : ℝ) ≤ n := by exact_mod_cast hdensity
    linarith
  have hna : (n : ℝ) * ((d : ℝ) / (n : ℝ)) = d := by field_simp
  have hrank' : moderateSeedA * Real.log (2 * (n : ℝ)) ≤ (d : ℝ) := by
    simpa [moderateA, moderateSeedA] using hrank
  have hεcap' : ε ≤ moderateSeedEpsilon := by
    simpa [moderateEps, moderateSeedEpsilon] using hεcap
  obtain ⟨hnlarge, hdlarge, hfluct, hgraph, hdense, _hcrossdim⟩ :=
    moderate_dimension_budgets hn hdn hrank'
  let t := Real.sqrt (moderateSeedK * ε)
  obtain ⟨ht, ht2, htsmall, hρhalf, hεhalf, hδsmall⟩ := moderate_amplitude_budgets hε hεcap'
  change 0 < t at ht
  change t ^ 2 = moderateSeedK * ε at ht2
  change t ^ 2 ≤ _ at htsmall
  change ε + (4 * ε + 3 * moderateSeedZeta + moderateSeedZeta + 10 ^ 12 * t) * t ^ 2 ≤
    (1 / 10 ^ 18) * t ^ 2 at hδsmall
  let ρ := moderateSeedD ^ 2 * t ^ 2
  have hρ : 0 < ρ := by dsimp [ρ]; norm_num [moderateSeedD]; positivity
  have hrows (i : Fin n) : ((d : ℝ) / (n : ℝ)) / 2 ≤ rowNormSq U i ∧
      rowNormSq U i ≤ 3 * ((d : ℝ) / (n : ℝ)) / 2 := by
    have hh := mul_le_mul_of_nonneg_right hεhalf ha.le
    have hi := hnear i
    constructor <;> nlinarith only [hh, hi.1, hi.2]
  obtain ⟨g, hsample, hcross⟩ := Smooth.exists_moderateGaussianSample_with_cross
    hU hdlarge hdn haf hrows (show 0 < moderateSeedD by norm_num [moderateSeedD]) ht
    (show 0 < moderateSeedZeta by norm_num [moderateSeedZeta])
    (show moderateSeedZeta ≤ 1 by norm_num [moderateSeedZeta]) hfluct hgraph hdense
    (frameProjection U)
  let H := Smooth.moderateNoiseFrame U ρ g
  let Y := gaussianMatrixImage (Smooth.retainedTangentFactor U ρ) g
  have hY : Y = H * U.transpose + U * H.transpose := Smooth.moderateNoiseFrame_tangent U ρ g
  have hYsym : ∀ i j, Y i j = Y j i := Smooth.retainedTangent_realization_symmetric U ρ g
  have hYrow (i : Fin n) : rowNormSq Y i ≤ 2000 * ((d : ℝ) / (n : ℝ)) :=
    (hsample.tangentRows i).le
  -- the drift
  let m := driftMean U ρ
  have hUm : U.transpose * m = 0 := driftMean_horizontal hU ρ
  have hmnorm : ‖normalFrobVector m‖ ^ 2 ≤ 2 * ((d : ℝ) / n) / ρ :=
    driftMean_norm_sq_le hU hn hd (fun i => (hrows i).1) hρ
  have hm : t ^ 2 * ‖normalFrobVector m‖ ^ 2 ≤ ((d : ℝ) / (n : ℝ)) / 10 ^ 78 := by
    have h1 := mul_le_mul_of_nonneg_left hmnorm (sq_nonneg t)
    have h2 : t ^ 2 * (2 * ((d : ℝ) / n) / ρ) = 2 * ((d : ℝ) / n) / 10 ^ 80 := by
      dsimp only [ρ, moderateSeedD]
      field_simp
    rw [h2] at h1
    have e : 2 * ((d : ℝ) / n) / 10 ^ 80 = ((d : ℝ) / (n : ℝ)) / 10 ^ 78 * (1 / 50) := by ring
    have hpos : 0 < ((d : ℝ) / (n : ℝ)) / 10 ^ 78 := by positivity
    rw [e] at h1
    linarith
  -- the drifted retraction
  obtain ⟨W, r, hW, hUW, hrow, htaylor, hrem⟩ := exists_drifted_retraction U H m hU
    hsample.horizontal hUm hsample.operator.le ha haf hna
    (fun i => (hrows i).2.trans (by nlinarith only [ha.le]))
    (fun i => (hsample.noiseRows i).le) (fun i => hY ▸ hYrow i) ht htsmall hm
  have htaylor' (i : Fin n) : rowNormSq W i = rowNormSq U i +
      2 * t * (Smooth.moderateNoiseFrame U ρ g * U.transpose) i i +
      t ^ 2 * Smooth.normalResidualDiagonal U ρ i +
      t ^ 2 * horizontalQuadraticDiagonal U (Smooth.moderateNoiseFrame U ρ g) i + r i := by
    rw [htaylor i, driftMean_diagonal hU ρ i]
  have hrowY (i : Fin n) : rowNormSq (frameProjection W - frameProjection U - t • Y) i ≤
      ((d : ℝ) / (n : ℝ)) * t ^ 2 / 320000000 := by rw [hY]; exact hrow i
  -- the diagonal
  have hdiag := drift_diagonal_bound (θ := 1 / 10 ^ 35) hd hU hε.le hεhalf hnear hρ.le ht.le
    (by linarith only [htsmall] : t ^ 2 ≤ 1) hsample r htaylor'
    (fun i => (hrem i).trans (le_of_eq (by ring)))
  -- the graph
  have hpenalty : t ^ 2 * (2 / (n : ℝ) + 80 / (d : ℝ) + 8 / ρ) ≤ 1 / 4 :=
    moderate_graph_penalty hn hd ht htsmall
  have hcross' (x : Fin n → ℝ) :
      |2 * t * graphEnergy (fun i j => frameProjection U i j * Y i j) x| ≤
        (1 / 32) * (matrixQuadratic (projectionLaplacian (frameProjection U)) x +
          ((d : ℝ) / (n : ℝ)) * t ^ 2 * vectorNormSq x) := by
    have hh := hcross x
    rw [Smooth.matrixQuadratic_graphLinearCross_eq _ _ (frameProjection_symm U) hYsym] at hh
    exact hh
  have hlower (x : Fin n → ℝ) (hx : ∑ i, x i = 0) :
      (1 / 32) * (matrixQuadratic (projectionLaplacian (frameProjection U)) x +
        ((d : ℝ) / (n : ℝ)) * t ^ 2 * vectorNormSq x) ≤
        matrixQuadratic (projectionLaplacian (frameProjection W)) x := by
    have hlo := Smooth.moderate_affine_seed_graph_lower hU hn hd haf hrows hρ Y hpenalty x hx
      (hcross' x) (hsample.centered_energy x)
    exact (moderate_retracted_graph_comparison hU hW Y hYsym t hrowY x hlo
      (Smooth.moderate_affine_seed_graph_upper hU Y hYsym hYrow t x)).1
  have hgap (x : Fin n → ℝ) (hx : ∑ i, x i = 0) :
      (((d : ℝ) / (n : ℝ)) * t ^ 2 / 32) * vectorNormSq x ≤
        matrixQuadratic (projectionLaplacian (frameProjection W)) x := by
    have h1 := hlower x hx
    have hL : 0 ≤ matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
      rw [← ambientNormal_norm_sq hU]; positivity
    nlinarith
  let B := Smooth.moderateVarianceExceptional U ρ
  have hB : B.card ≤ 2000000 := Smooth.moderateVarianceExceptional_card_le hU
    (fun i => (by linarith [ha] : 0 < ((d : ℝ) / (n : ℝ)) / 2).trans_le (hrows i).1) hn hd hρ.le
  have hBsize : 10 * B.card ≤ n := by omega
  have hseedDense : ∀ i ∉ B, 19 * n ≤ 20 * (largeNeighbors
      (fun i j => (frameProjection U i j + t * Y i j) ^ 2)
      (t ^ 2 * ((d : ℝ) / (n : ℝ)) / 1000000) i).card := by
    intro i hi
    exact Smooth.retainedTangent_dense_neighbors U ρ t ht.le (frameProjection U) g i
      (hsample.dense i hi)
  have hmove : sqDistance (frameProjection W) (frameProjection W) ≤
      ((d : ℝ) / (n : ℝ)) * t ^ 2 / 320000000 := by
    rw [sqDistance_self]; positivity
  have hfinalDense := moderate_dense_core_after_correction hd U W W Y ht B hseedDense hrowY hmove
  have hbar := frameBarrier_of_core_and_gap hW (by omega) B hBsize
    (γ := ((d : ℝ) / (n : ℝ)) * t ^ 2 / 16000000) (l := ((d : ℝ) / (n : ℝ)) * t ^ 2 / 32)
    (by positivity) (by positivity) hfinalDense hgap
  -- the seed
  have hseed : IsSeed U W moderateTheta t := by
    refine ⟨hW, ?_, ?_, ?_⟩
    · refine hUW.trans ?_
      have : (0 : ℝ) ≤ t ^ 2 * d := by positivity
      rw [moderateTheta]; nlinarith
    · have hBR : (B.card : ℝ) ≤ 2000000 := by exact_mod_cast hB
      unfold FrameBarrierBound at hbar ⊢
      exact hbar.mono (moderate_barrier_numerics (Nat.cast_nonneg _) hBR (by positivity))
    · intro i
      rw [abs_sub_comm]
      refine (hdiag i).trans ?_
      have hz : (1 / 10 ^ 35 : ℝ) ≤ moderateSeedZeta := by norm_num [moderateSeedZeta]
      have h1 : ε + (4 * ε + 3 * moderateSeedZeta + 1 / 10 ^ 35 + 10 ^ 12 * t) * t ^ 2 ≤
          (1 / 10 ^ 18) * t ^ 2 := by nlinarith
      have h2 := mul_le_mul_of_nonneg_right h1 ha.le
      have h3 : (1 / 10 ^ 18) * t ^ 2 * ((d : ℝ) / (n : ℝ)) ≤
          (d : ℝ) / n * t ^ 2 / (2 * moderateTheta) := by
        rw [moderateTheta]
        have : 0 ≤ (d : ℝ) / n * t ^ 2 := by positivity
        rw [le_div_iff₀ (by norm_num)]
        nlinarith
      linarith
  have hcorr := hseed.hasCorrection hd hdn (by norm_num [moderateTheta]) ht
  apply hcorr.mono
  rw [ht2, moderateTheta, moderateCost, moderateSeedK]
  have : 0 ≤ ε * (d : ℝ) := by positivity
  nlinarith

end

end Paulsen.Linear
