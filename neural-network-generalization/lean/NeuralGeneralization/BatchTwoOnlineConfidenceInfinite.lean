import NeuralGeneralization.BatchTwoOnlineMain

/-! Strict-confidence failure counts for the entire infinite IID stream. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal
open Classical MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoOnline

variable {H : Type*} [Fintype H] [DecidableEq H] {m : ℕ}

def confidenceError (w : H → ℝ) (good : H → Fin m → Prop)
    (θ : ℝ) (s : ℕ → Fin m) (i : ℕ) : ℝ :=
  if 1-onlineError w good s i ≤ θ then 1 else 0

def totalConfidence (w : H → ℝ) (good : H → Fin m → Prop)
    (θ : ℝ) (s : ℕ → Fin m) : ℝ≥0∞ :=
  ∑' i, ENNReal.ofReal (confidenceError w good θ s i)

theorem totalConfidence_le_totalError
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (θ : ℝ) (hθ : θ < 1) (s : ℕ → Fin m) :
    totalConfidence w good θ s ≤ ENNReal.ofReal (1/(1-θ))*totalError w good s := by
  unfold totalConfidence totalError
  rw [← ENNReal.tsum_mul_left]
  apply ENNReal.tsum_le_tsum
  intro i
  rw [← ENNReal.ofReal_mul (by positivity : 0 ≤ 1/(1-θ))]
  apply ENNReal.ofReal_le_ofReal
  unfold confidenceError
  split_ifs with hi
  · have h := (le_div_iff₀ (by linarith : 0 < 1-θ)).mpr (show 1*(1-θ) ≤ onlineError w good s i by linarith)
    simpa [div_eq_mul_inv, mul_comm] using h
  · exact mul_nonneg (by positivity) (onlineError_nonneg w good s hw target htarget hwt i)

variable [MeasurableSpace H] [MeasurableSingletonClass H] [NeZero m]

/-- The confidence count uses the literal weak-failure convention from the
paper; at theta=2/3 its bounds are exactly three times the posterior-error bounds. -/
theorem iid_confidence_bounds (w : H → ℝ) (hw : ∀ g, 0 ≤ w g)
    (good : H → Fin m → Prop) (target : H) (htarget : ∀ x, good target x)
    (hwt : 0 < w target) (h β : ℝ)
    (hb : InfiniteIIDBounds w good hw target htarget hwt h β)
    (θ : ℝ) (hθ : θ < 1) :
    (∫⁻ s, totalConfidence w good θ s ∂iidQueryLaw (Fin m)) ≤
      ENNReal.ofReal (expectationBudget m h β/(1-θ)) ∧
    ∀ δ : ℝ, 0 < δ → δ < 1 →
      iidQueryLaw (Fin m) {s | ENNReal.ofReal (highProbabilityBudget m h β δ/(1-θ)) <
        totalConfidence w good θ s} ≤ ENNReal.ofReal δ := by
  let c : ℝ := 1/(1-θ)
  have hc : 0 < c := by dsimp [c]; positivity
  have hs := totalConfidence_le_totalError w hw good target htarget hwt θ hθ
  constructor
  · calc
      _ ≤ ∫⁻ s, ENNReal.ofReal c*totalError w good s ∂iidQueryLaw (Fin m) := lintegral_mono hs
      _ = ENNReal.ofReal c*(∫⁻ s, totalError w good s ∂iidQueryLaw (Fin m)) :=
        lintegral_const_mul' _ _ ENNReal.ofReal_ne_top
      _ ≤ ENNReal.ofReal c*ENNReal.ofReal (expectationBudget m h β) := mul_le_mul_left' hb.1 _
      _ = _ := by rw [← ENNReal.ofReal_mul hc.le]; congr 1; dsimp [c]; ring
  · intro δ hδ hδ1
    apply (measure_mono (show {s | ENNReal.ofReal (highProbabilityBudget m h β δ/(1-θ)) <
        totalConfidence w good θ s} ⊆
      {s | ENNReal.ofReal (highProbabilityBudget m h β δ) < totalError w good s} from ?_)).trans
      (hb.2.2 δ hδ hδ1).1
    intro s hsbad
    by_contra he
    have hupper := (hs s).trans (mul_le_mul_left' (le_of_not_gt he) (ENNReal.ofReal c))
    have heq : ENNReal.ofReal c*ENNReal.ofReal (highProbabilityBudget m h β δ) =
        ENNReal.ofReal (highProbabilityBudget m h β δ/(1-θ)) := by
      rw [← ENNReal.ofReal_mul hc.le]
      congr 1
      dsimp [c]
      ring
    rw [heq] at hupper
    exact not_lt_of_ge hupper hsbad

end NeuralGeneralization.BatchTwoOnline
