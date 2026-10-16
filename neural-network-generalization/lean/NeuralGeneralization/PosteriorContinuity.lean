import NeuralGeneralization.RatePosterior
import Mathlib.Topology.Algebra.Order.Field

/-!
# Conditional finite-law limits and the strict confidence convention

Pointwise convergence of actual unnormalized sign-event masses yields the
exact consistency posterior whenever the limiting normalizer is positive.
A confidence buffer below two thirds transfers to a lower bound for the
finite-width confidence failure, including ties at the actual threshold.
-/

noncomputable section
open Filter
open scoped Topology BigOperators

namespace NeuralGeneralization

variable {H I : Type*} [Fintype H]

theorem normalizer_tendsto {l : Filter I} (w : I → H → ℝ) (w₀ : H → ℝ)
    (keep : H → Prop) [DecidablePred keep]
    (hw : ∀ h, Tendsto (fun i => w i h) l (𝓝 (w₀ h))) :
    Tendsto (fun i => normalizer (w i) keep) l (𝓝 (normalizer w₀ keep)) := by
  unfold normalizer
  apply tendsto_finsetSum
  intro h hh
  by_cases hk : keep h
  · simpa only [if_pos hk] using hw h
  · simp only [if_neg hk]
    exact tendsto_const_nhds

theorem posterior_tendsto {l : Filter I} (w : I → H → ℝ) (w₀ : H → ℝ)
    (keep : H → Prop) [DecidablePred keep]
    (hw : ∀ h, Tendsto (fun i => w i h) l (𝓝 (w₀ h)))
    (hden : normalizer w₀ keep ≠ 0) (h : H) :
    Tendsto (fun i => posterior (w i) keep h) l (𝓝 (posterior w₀ keep h)) := by
  unfold posterior
  apply Tendsto.div _ (normalizer_tendsto w w₀ keep hw) hden
  by_cases hk : keep h
  · simpa only [if_pos hk] using hw h
  · simp only [if_neg hk]
    exact tendsto_const_nhds

theorem eventually_normalizer_pos {l : Filter I} (w : I → H → ℝ) (w₀ : H → ℝ)
    (keep : H → Prop) [DecidablePred keep]
    (hw : ∀ h, Tendsto (fun i => w i h) l (𝓝 (w₀ h)))
    (hden : 0 < normalizer w₀ keep) :
    ∀ᶠ i in l, 0 < normalizer (w i) keep :=
  (normalizer_tendsto w w₀ keep hw).eventually (eventually_gt_nhds hden)

variable {X Y : Type*} [Fintype X] [DecidableEq Y]

omit [Fintype X] in
theorem correctAt_tendsto {l : Filter I} (p : I → H → ℝ) (p₀ : H → ℝ)
    (predict : H → X → Y) (truth : X → Y)
    (hp : ∀ h, Tendsto (fun i => p i h) l (𝓝 (p₀ h))) (x : X) :
    Tendsto (fun i => correctAt (p i) predict truth x) l
      (𝓝 (correctAt p₀ predict truth x)) := by
  unfold correctAt
  apply tendsto_finsetSum
  intro h hh
  by_cases hc : predict h x = truth x
  · simpa only [if_pos hc] using hp h
  · simp only [if_neg hc]
    exact tendsto_const_nhds

/-- The buffered failure mass is eventually a lower bound for failure of the
actual strict `>2/3` rule. No classification by posterior mean is used. -/
theorem eventually_buffered_confidence_lower {l : Filter I}
    (p : I → H → ℝ) (p₀ : H → ℝ) (D : X → ℝ)
    (predict : H → X → Y) (truth : X → Y)
    (hp : ∀ h, Tendsto (fun i => p i h) l (𝓝 (p₀ h)))
    (hD : ∀ x, 0 ≤ D x) (b : ℝ) (hb : b < 2 / 3) :
    ∀ᶠ i in l,
      (∑ x, if correctAt p₀ predict truth x ≤ b then D x else 0) ≤
        confidenceFailure (p i) D predict truth := by
  classical
  have heach (x : X) : ∀ᶠ i in l,
      correctAt p₀ predict truth x ≤ b → correctAt (p i) predict truth x ≤ 2 / 3 := by
    by_cases hx : correctAt p₀ predict truth x ≤ b
    · have ht := (correctAt_tendsto p p₀ predict truth hp x).eventually
        (eventually_lt_nhds (hx.trans_lt hb))
      exact ht.mono fun i hi _ => hi.le
    · exact Filter.Eventually.of_forall fun i hi => (hx hi).elim
  filter_upwards [Filter.eventually_all.mpr heach] with i hi
  unfold confidenceFailure
  apply Finset.sum_le_sum
  intro x hx
  by_cases hlow : correctAt p₀ predict truth x ≤ b
  · simp only [if_pos hlow, if_pos (hi x hlow), le_refl]
  · simp only [if_neg hlow]
    split_ifs
    · exact hD x
    · exact le_rfl

theorem buffered_confidence_liminf_lower
    (p : ℕ → H → ℝ) (p₀ : H → ℝ) (D : X → ℝ)
    (predict : H → X → Y) (truth : X → Y)
    (hp : ∀ h, Tendsto (fun i => p i h) atTop (𝓝 (p₀ h)))
    (hD : ∀ x, 0 ≤ D x) (hDs : ∑ x, D x = 1)
    (b : ℝ) (hb : b < 2 / 3) :
    (∑ x, if correctAt p₀ predict truth x ≤ b then D x else 0) ≤
      Filter.liminf (fun n => confidenceFailure (p n) D predict truth) atTop := by
  classical
  let B := ∑ x, if correctAt p₀ predict truth x ≤ b then D x else 0
  have hl : Tendsto (fun _ : ℕ => B) atTop (𝓝 B) := tendsto_const_nhds
  have hub : IsCoboundedUnder (· ≥ ·) atTop
      (fun n => confidenceFailure (p n) D predict truth) :=
    isCoboundedUnder_ge_of_le atTop fun n =>
      (confidenceFailure_mem_unit_interval (p n) D predict truth hD hDs).2
  have hh := liminf_le_liminf (eventually_buffered_confidence_lower p p₀ D predict truth hp hD b hb)
    hl.isBoundedUnder_ge hub
  rwa [hl.liminf_eq] at hh

end NeuralGeneralization
