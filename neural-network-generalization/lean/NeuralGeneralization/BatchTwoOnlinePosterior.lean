import NeuralGeneralization.FiniteLearning
import NeuralGeneralization.FunctionPriorFacts
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Tactic.FieldSimp
import Mathlib.Topology.Algebra.InfiniteSum.ENNReal

/-!
# Actual sequential consistency posteriors

The weights in this file are the prior weights themselves; all predictions
are formed by the normalized consistency posterior.  In particular, the
telescoping bound is proved from the posterior formula, not assumed as an
online-learning interface.  Queries may be deterministic or adaptive.
-/

noncomputable section
open scoped BigOperators ENNReal
open Classical

namespace NeuralGeneralization.BatchTwoOnline

variable {H X : Type*} [Fintype H]

def history (good : H → X → Prop) (query : ℕ → X) (n : ℕ) (h : H) : Prop :=
  ∀ i < n, good h (query i)

noncomputable instance historyDecidable (good : H → X → Prop) (query : ℕ → X)
    (n : ℕ) : DecidablePred (history good query n) := Classical.decPred _

def onlinePosterior (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (n : ℕ) : H → ℝ := posterior w (history good query n)

def onlineError (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (n : ℕ) : ℝ :=
  ∑ h, if good h (query n) then 0 else onlinePosterior w good query n h

def cumulativeError (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (n : ℕ) : ℝ := ∑ i ∈ Finset.range n, onlineError w good query i

lemma history_zero (good : H → X → Prop) (query : ℕ → X) (h : H) :
    history good query 0 h := by simp [history]

lemma history_succ (good : H → X → Prop) (query : ℕ → X) (n : ℕ) (h : H) :
    history good query (n+1) h ↔ history good query n h ∧ good h (query n) := by
  simp only [history, Nat.lt_succ_iff_lt_or_eq]
  constructor
  · intro hs
    exact ⟨fun i hi => hs i (Or.inl hi), hs n (Or.inr rfl)⟩
  · rintro ⟨hs, hn⟩ i (hi | rfl)
    · exact hs i hi
    · exact hn

lemma target_history (good : H → X → Prop) (query : ℕ → X) (target : H)
    (ht : ∀ x, good target x) (n : ℕ) : history good query n target :=
  fun i _ => ht (query i)

variable (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (hw : ∀ h, 0 ≤ w h) (target : H) (ht : ∀ x, good target x)
    (hwt : 0 < w target)

include hw ht hwt in
lemma onlinePosterior_nonneg (n : ℕ) (h : H) :
    0 ≤ onlinePosterior w good query n h :=
  posterior_nonneg w _ hw target (target_history good query target ht n) hwt h

include hw ht hwt in
lemma onlinePosterior_sum (n : ℕ) : ∑ h, onlinePosterior w good query n h = 1 :=
  posterior_sum w _ hw target (target_history good query target ht n) hwt

include hw ht hwt in
lemma onlineError_nonneg (n : ℕ) : 0 ≤ onlineError w good query n := by
  apply Finset.sum_nonneg
  intro h _
  split_ifs
  · exact le_rfl
  · exact onlinePosterior_nonneg w good query hw target ht hwt n h

include hw ht hwt in
lemma onlineError_le_one (n : ℕ) : onlineError w good query n ≤ 1 := by
  rw [← onlinePosterior_sum w good query hw target ht hwt n]
  apply Finset.sum_le_sum
  intro h _
  split_ifs
  · exact onlinePosterior_nonneg w good query hw target ht hwt n h
  · exact le_rfl

lemma onlineError_eq_zero_of_repeated {i n : ℕ} (hi : i < n)
    (heq : query i = query n) : onlineError w good query n = 0 := by
  apply Finset.sum_eq_zero
  intro h _
  by_cases hh : good h (query n)
  · simp [hh]
  · have hn : ¬ history good query n h := by
      intro hs
      exact hh (heq ▸ hs i hi)
    simp [onlinePosterior, posterior, hh, hn]

include hw ht hwt in
lemma normalizer_step (n : ℕ) :
    normalizer w (history good query (n+1)) =
      normalizer w (history good query n) * (1 - onlineError w good query n) := by
  have hsplit : normalizer w (history good query n) =
      normalizer w (history good query (n+1)) +
        ∑ h, if good h (query n) then 0 else
          (if history good query n h then w h else 0) := by
    unfold normalizer
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro h _
    simp only [history_succ]
    by_cases hk : history good query n h <;>
      by_cases hg : good h (query n) <;> simp [hk, hg]
  have herr : onlineError w good query n =
      (∑ h, if good h (query n) then 0 else
        (if history good query n h then w h else 0)) /
        normalizer w (history good query n) := by
    unfold onlineError onlinePosterior posterior
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro h _
    split_ifs <;> simp_all
  have hz : normalizer w (history good query n) ≠ 0 := ne_of_gt
    (normalizer_pos w _ hw target (target_history good query target ht n) hwt)
  rw [herr]
  field_simp
  linarith [hsplit]

include hw ht hwt in
lemma onlineError_lt_one (n : ℕ) : onlineError w good query n < 1 := by
  have h0 := normalizer_pos w _ hw target (target_history good query target ht n) hwt
  have h1 := normalizer_pos w _ hw target (target_history good query target ht (n+1)) hwt
  rw [normalizer_step w good query hw target ht hwt n] at h1
  have : 0 < 1 - onlineError w good query n := (mul_pos_iff_of_pos_left h0).mp h1
  linarith

include hw ht hwt in
lemma onlineError_le_log_drop (n : ℕ) :
    onlineError w good query n ≤
      Real.log (normalizer w (history good query n)) -
        Real.log (normalizer w (history good query (n+1))) := by
  have h0 := normalizer_pos w _ hw target (target_history good query target ht n) hwt
  have hq : 0 < 1 - onlineError w good query n :=
    sub_pos.mpr (onlineError_lt_one w good query hw target ht hwt n)
  have hl := Real.log_le_sub_one_of_pos hq
  rw [normalizer_step w good query hw target ht hwt n,
    Real.log_mul (ne_of_gt h0) (ne_of_gt hq)]
  linarith

include hw ht hwt in
/-- Exact Bayesian telescoping for arbitrary query sequences.  The prior may
be unnormalized; the ratio is its normalized target probability. -/
theorem cumulativeError_le_log_ratio (n : ℕ) :
    cumulativeError w good query n ≤ Real.log (∑ h, w h) - Real.log (w target) := by
  have htel : (∑ i ∈ Finset.range n,
      (Real.log (normalizer w (history good query i)) -
        Real.log (normalizer w (history good query (i+1))))) =
      Real.log (∑ h, w h) - Real.log (normalizer w (history good query n)) := by
    rw [Finset.sum_range_sub']
    simp [normalizer, history_zero]
  have hlog : Real.log (w target) ≤ Real.log (normalizer w (history good query n)) :=
    Real.log_le_log hwt (weight_le_normalizer w _ hw target
      (target_history good query target ht n))
  calc
    cumulativeError w good query n ≤ ∑ i ∈ Finset.range n,
        (Real.log (normalizer w (history good query i)) -
          Real.log (normalizer w (history good query (i+1)))) :=
      Finset.sum_le_sum fun i _ => onlineError_le_log_drop w good query hw target ht hwt i
    _ ≤ Real.log (∑ h, w h) - Real.log (w target) := by rw [htel]; linarith

include hw ht hwt in
theorem cumulativeError_le_neg_log (hwsum : ∑ h, w h ≤ 1) (n : ℕ) :
    cumulativeError w good query n ≤ -Real.log (w target) := by
  have hsumpos : 0 < ∑ h, w h :=
    hwt.trans_le (Finset.single_le_sum (fun h _ => hw h) (Finset.mem_univ target))
  have hl : Real.log (∑ h, w h) ≤ 0 := by
    simpa using Real.log_le_log hsumpos hwsum
  have hb := cumulativeError_le_log_ratio w good query hw target ht hwt n
  linarith

/-- The actual infinite-stream cumulative posterior error, in the nonnegative
extended reals. This avoids defining a divergent real series as zero. -/
def totalError (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X) : ℝ≥0∞ :=
  ∑' n, ENNReal.ofReal (onlineError w good query n)

include hw ht hwt in
theorem totalError_le_neg_log (hwsum : ∑ h, w h ≤ 1) :
    totalError w good query ≤ ENNReal.ofReal (-Real.log (w target)) := by
  apply ENNReal.tsum_le_of_sum_range_le
  intro n
  rw [← ENNReal.ofReal_sum_of_nonneg
    (fun i _ => onlineError_nonneg w good query hw target ht hwt i)]
  exact ENNReal.ofReal_le_ofReal (cumulativeError_le_neg_log w good query hw target ht hwt hwsum n)

def confidenceCount (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (θ : ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, if 1 - onlineError w good query i ≤ θ then 1 else 0

include hw ht hwt in
theorem confidenceCount_le_cumulative (θ : ℝ) (hθ : θ < 1) (n : ℕ) :
    confidenceCount w good query θ n ≤ cumulativeError w good query n / (1-θ) := by
  apply (le_div_iff₀ (sub_pos.mpr hθ)).mpr
  rw [confidenceCount, Finset.sum_mul]
  apply Finset.sum_le_sum
  intro i _
  split_ifs with hi
  · simp only [one_mul]
    linarith
  · simp only [zero_mul]
    exact onlineError_nonneg w good query hw target ht hwt i

include hw ht hwt in
theorem confidenceCount_le_prior_cost (hwsum : ∑ h, w h ≤ 1)
    (θ : ℝ) (hθ : θ < 1) (n : ℕ) :
    confidenceCount w good query θ n ≤ (-Real.log (w target)) / (1-θ) :=
  (confidenceCount_le_cumulative w good query hw target ht hwt θ hθ n).trans
    (div_le_div_of_nonneg_right
      (cumulativeError_le_neg_log w good query hw target ht hwt hwsum n)
      (sub_pos.mpr hθ).le)

section Network
open ConcreteModel MeasureTheory

/-- The sequential object above is exactly the network function posterior
already used throughout the existing formalization. -/
theorem onlinePosterior_eq_networkPosterior {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d) (query : ℕ → Cube d) (n : ℕ) :
    onlinePosterior (functionMass φ a μ) (fun g x => g x = f x) query n =
      networkPosterior φ a μ f (fun i : Fin n => query i) := by
  unfold onlinePosterior networkPosterior
  congr 1
  funext g
  apply propext
  constructor
  · intro hs i
    exact hs i i.isLt
  · intro hs i hi
    exact hs ⟨i, hi⟩

/-- Actual globally margin-conditioned network posteriors satisfy the
infinite-stream direct prior-mass bound under every input order. -/
theorem network_totalError_le_prior_cost {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (a : ℝ) (ha : 0 < a)
    (μ : Measure (Weights d N r)) [IsProbabilityMeasure μ]
    (f : BooleanFunction d) (hf : 0 < functionMass φ a μ f) (query : ℕ → Cube d) :
    totalError (functionMass φ a μ) (fun g x => g x = f x) query ≤
      ENNReal.ofReal (-Real.log (functionMass φ a μ f)) := by
  apply totalError_le_neg_log _ _ _ (functionMass_nonneg φ a μ) f (fun _ => rfl) hf
  exact functionMass_sum_le_one hφ ha.le μ

end Network

end NeuralGeneralization.BatchTwoOnline
