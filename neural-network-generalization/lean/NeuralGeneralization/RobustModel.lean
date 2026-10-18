import NeuralGeneralization.Network
import NeuralGeneralization.Activation
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Positivity

/-!
# Actual finite-noise robustness for the Gaussian network architecture

The disturbance is added after each of the `r + 1` hidden activations and
at the scalar output. Hidden disturbances may leave the activation range.
The support condition concerns the clipped score, not the raw logit.
-/
noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.ConcreteModel

variable {d N r : ℕ}

abbrev NetworkDisturbance (N r : ℕ) := (Fin (r + 1) → Fin N → ℝ) × ℝ

/-- Joint squared RMS budget, including scalar readout noise. -/
def noiseBudgetSq (η : NetworkDisturbance N r) : ℝ :=
  (∑ s, ∑ i, (η.1 s i) ^ 2) / (N : ℝ) + η.2 ^ 2

/-- The readout part of the Gaussian quadratic energy. -/
def readoutEnergy (w : Weights d N r) : ℝ :=
  (N : ℝ) * ∑ i, w (Sum.inr (Sum.inr i)) ^ 2

/-- Clipping at the training margin. -/
def clippedScore (z : ℝ) : ℝ := max (-(1 / 2 : ℝ)) (min (1 / 2 : ℝ) z)

/-- A disturbance is added after the first hidden activation. -/
def noisyFirstHidden (φ : ℝ → ℝ) (w : Weights d N r)
    (x : Cube d) (η : NetworkDisturbance N r) : Fin N → ℝ :=
  fun i => firstHidden φ w x i + η.1 0 i

/-- Internal layer `s` receives postactivation disturbance `s + 1`. -/
def noisyHiddenStep (φ : ℝ → ℝ) (w : Weights d N r)
    (η : NetworkDisturbance N r) (h : Fin N → ℝ) (s : Fin r) : Fin N → ℝ :=
  fun i => hiddenStep φ w h s i + η.1 s.succ i

def noisyFinalHidden (φ : ℝ → ℝ) (w : Weights d N r)
    (x : Cube d) (η : NetworkDisturbance N r) : Fin N → ℝ :=
  (List.finRange r).foldl (noisyHiddenStep φ w η) (noisyFirstHidden φ w x η)

/-- The concrete noisy network, including the scalar output disturbance. -/
def noisyNetworkOutput (φ : ℝ → ℝ) (w : Weights d N r)
    (x : Cube d) (η : NetworkDisturbance N r) : ℝ :=
  (∑ i, w (Sum.inr (Sum.inr i)) * noisyFinalHidden φ w x η i) + η.2

/-- The calibration depends on the actual readout energy. -/
def robustRadius (c : ℝ) (w : Weights d N r) : ℝ :=
  c / Real.sqrt (1 + ((r : ℝ) + 1) * readoutEnergy w)

/-- Exact all-input, simultaneous finite-disturbance support restriction. -/
def robustEvent (φ : ℝ → ℝ) (c : ℝ) : Set (Weights d N r) :=
  {w | ∀ (x : Cube d) (η : NetworkDisturbance N r),
    noiseBudgetSq η ≤ (robustRadius c w) ^ 2 →
    |clippedScore (noisyNetworkOutput φ w x η) -
      clippedScore (networkOutput φ w x)| ≤ (1 / 16 : ℝ)}

@[simp] theorem noiseBudgetSq_zero : noiseBudgetSq (0 : NetworkDisturbance N r) = 0 := by
  simp [noiseBudgetSq]

theorem noiseBudgetSq_nonneg (η : NetworkDisturbance N r) : 0 ≤ noiseBudgetSq η := by
  unfold noiseBudgetSq
  positivity

theorem readoutEnergy_nonneg (w : Weights d N r) : 0 ≤ readoutEnergy w := by
  unfold readoutEnergy
  positivity

theorem readoutEnergy_le_weightedSquaredNorm (w : Weights d N r) :
    readoutEnergy w ≤ weightedSquaredNorm w := by
  have hfirst : 0 ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i, j)) ^ 2) := by
    positivity
  have hinternal : 0 ≤ ∑ s, ∑ i, ∑ j,
      w (Sum.inr (Sum.inl (s, i, j))) ^ 2 := by positivity
  unfold readoutEnergy weightedSquaredNorm
  linarith

theorem robustRadius_pos {c : ℝ} (hc : 0 < c) (w : Weights d N r) :
    0 < robustRadius c w := by
  unfold robustRadius
  apply div_pos hc
  apply Real.sqrt_pos.mpr
  have := readoutEnergy_nonneg w
  positivity

@[simp] theorem noisyFirstHidden_zero (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d) :
    noisyFirstHidden φ w x 0 = firstHidden φ w x := by
  funext i
  simp [noisyFirstHidden]

@[simp] theorem noisyHiddenStep_zero (φ : ℝ → ℝ) (w : Weights d N r) :
    noisyHiddenStep φ w 0 = hiddenStep φ w := by
  funext h s i
  simp [noisyHiddenStep]

@[simp] theorem noisyFinalHidden_zero (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d) :
    noisyFinalHidden φ w x 0 = finalHidden φ w x := by
  simp [noisyFinalHidden, finalHidden]

@[simp] theorem noisyNetworkOutput_zero (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d) :
    noisyNetworkOutput φ w x 0 = networkOutput φ w x := by
  simp [noisyNetworkOutput, networkOutput]

/-- A uniformly preserved signed margin gives exact clipped-score invariance. -/
theorem clippedScore_eq_label_of_margin (b : Bool) (z : ℝ)
    (hz : (1 / 2 : ℝ) ≤ labelReal b * z) :
    clippedScore z = labelReal b / 2 := by
  cases b
  · simp only [labelReal_false, neg_one_mul] at hz ⊢
    simp only [clippedScore]
    rw [min_eq_right (by linarith), max_eq_left (by linarith)]
    ring
  · simp only [labelReal_true, one_mul] at hz ⊢
    unfold clippedScore
    rw [min_eq_left hz, max_eq_right (by norm_num)]

/-- This sufficient condition is applied to the robust target cylinder. -/
theorem mem_robustEvent_of_uniform_noisy_margin
    (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (f : BooleanFunction d)
    (hmargin : ∀ (x : Cube d) (η : NetworkDisturbance N r),
      noiseBudgetSq η ≤ (robustRadius c w) ^ 2 →
      (1 / 2 : ℝ) ≤ labelReal (f x) * noisyNetworkOutput φ w x η) :
    w ∈ robustEvent φ c := by
  intro x η hη
  have hn := clippedScore_eq_label_of_margin (f x) _ (hmargin x η hη)
  have hz := hmargin x 0 (by simp only [noiseBudgetSq_zero]; positivity)
  rw [noisyNetworkOutput_zero] at hz
  rw [hn, clippedScore_eq_label_of_margin (f x) _ hz, sub_self, abs_zero]
  norm_num

end NeuralGeneralization.ConcreteModel
