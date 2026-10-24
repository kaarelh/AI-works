import NeuralGeneralization.BatchTwoMergingModel
import NeuralGeneralization.RobustStatisticsCoupling

/-! # Actual-posterior truncation and the calibrated population count -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoMerging

open ConcreteModel

theorem signed_margin_sq {b : Bool} {z : ℝ} (h : (1 / 2 : ℝ) < labelReal b * z) :
    (1 / 4 : ℝ) < z ^ 2 := by
  cases b <;> simp only [labelReal_true, labelReal_false, one_mul, neg_one_mul] at h <;>
    nlinarith [sq_nonneg (z - 1 / 2), sq_nonneg (z + 1 / 2)]

/-- A genuine training margin turns the scale-invariant count condition into
an absolute count bound after readout-energy truncation. -/
theorem populationCount_le_of_margin {d N r : ℕ} (hN : 0 < N)
    (φ : ℝ → ℝ) (p : LayerPartitions N r) (w : Weights d N r)
    (hw : w ∈ partitionSupport φ p) (x : Cube d) (b : Bool)
    (hmargin : (1 / 2 : ℝ) < labelReal b * networkOutput φ w x)
    (s : Fin (r + 1)) :
    (populationCount (p s) : ℝ) ≤ 1 + 16 * readoutEnergy w := by
  have hq : (1 : ℝ) ≤ populationCount (p s) := by
    exact_mod_cast populationCount_pos hN (p s)
  have hz := signed_margin_sq hmargin
  have hbudget := hw.1 s x
  nlinarith [mul_nonneg (sub_nonneg.mpr hq)
    (sub_nonneg.mpr hz.le)]

theorem exists_partition_with_bounded_count {d N r n : ℕ} (hN : 0 < N) (hn : 0 < n)
    (φ : ℝ → ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (sample : Fin n → Cube d) (w : Weights d N r)
    (hw : w ∈ posteriorEvent φ globalMargin f sample) {B : ℝ}
    (hB : readoutEnergy w ≤ B) :
    ∃ p : LayerPartitions N r, w ∈ partitionSupport φ p ∧
      ∀ s, populationCount (p s) ≤ ⌈1 + 16 * B⌉₊ := by
  obtain ⟨p, hp⟩ := Set.mem_iUnion.mp hw.1.1
  refine ⟨p, hp, ?_⟩
  intro s
  have hq := populationCount_le_of_margin hN φ p w hp
    (sample ⟨0, hn⟩) (f (sample ⟨0, hn⟩)) (hw.2 ⟨0, hn⟩) s
  have hle : (populationCount (p s) : ℝ) ≤ (⌈1 + 16 * B⌉₊ : ℝ) :=
    (hq.trans (by linarith)).trans (Nat.le_ceil _)
  exact_mod_cast hle

theorem posterior_event_mass_lower {d N r n : ℕ} (φ : ℝ → ℝ)
    (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d) (sample : Fin n → Cube d)
    {D : ℝ} (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (mergingSupport φ ∩ marginEvent φ (1 / 2) f)) :
    Real.exp (-D / σ ^ 2) ≤
      (smallPrior d N r σ).real (posteriorEvent φ globalMargin f sample) :=
  htarget.trans (measureReal_mono (target_subset_posteriorEvent φ globalMargin f sample))

theorem posterior_event_pos {d N r n : ℕ} (φ : ℝ → ℝ)
    (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d) (sample : Fin n → Cube d)
    {D : ℝ} (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (mergingSupport φ ∩ marginEvent φ (1 / 2) f)) :
    0 < (smallPrior d N r σ).real (posteriorEvent φ globalMargin f sample) :=
  (Real.exp_pos _).trans_le (posterior_event_mass_lower φ globalMargin σ f sample htarget)

/-- This is a tail bound for the actual Gaussian posterior. The target-mass
premise is supplied later by the explicit Boolean implementation cylinder. -/
theorem posterior_readout_tail {d N r n : ℕ} (hd : 0 < d) (hN : 0 < N)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (globalMargin : Bool)
    {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ) * σ ^ 2 ≤ 1)
    (f : BooleanFunction d) (sample : Fin n → Cube d) {D B β : ℝ}
    (hβ : 0 < β) (hβ1 : β ≤ 1) (hB : 8 ≤ B)
    (hbudget : 4 * (D - Real.log β) ≤ B)
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (mergingSupport φ ∩ marginEvent φ (1 / 2) f)) :
    (posterior (N := N) (r := r) φ globalMargin σ f sample).real
      {w | B < readoutEnergy w} ≤ β := by
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hs1 : σ ^ 2 ≤ 1 :=
    (le_mul_of_one_le_left (sq_nonneg σ) hN1).trans hscale
  have htail := RobustPosterior.smallPrior_readout_tail (r := r) hd hN hσ
    (B := B) (by nlinarith [hscale])
  exact RobustPosterior.conditional_tail_of_exponential_bounds
    (smallPrior d N r σ) (posteriorEvent φ globalMargin f sample)
    {w | B < readoutEnergy w} (measurable_posteriorEvent hφ globalMargin f sample)
    (sq_pos_of_pos hσ) hs1 hβ hβ1
    (posterior_event_mass_lower φ globalMargin σ f sample htarget) htail hbudget

/-- Clipping and a `3/32` approximation transfer the training/test gap to a
single finite comparison class. -/
theorem clipped_training_transfer (b : Bool) (z g : ℝ)
    (hz : (1 / 2 : ℝ) < labelReal b * z)
    (hclose : |clippedScore z - clippedScore g| ≤ (3 / 32 : ℝ)) :
    (13 / 32 : ℝ) ≤ labelReal b * clippedScore g := by
  rw [clippedScore_eq_label_of_margin b z hz.le] at hclose
  cases b <;> simp only [labelReal_true, labelReal_false, one_mul, neg_one_mul] at * <;>
    linarith [(abs_le.mp hclose).1, (abs_le.mp hclose).2]

theorem clipped_test_transfer (b : Bool) (z g : ℝ)
    (hz : labelReal b * z ≤ (1 / 4 : ℝ))
    (hclose : |clippedScore z - clippedScore g| ≤ (3 / 32 : ℝ)) :
    labelReal b * clippedScore g ≤ (11 / 32 : ℝ) := by
  have hclip : labelReal b * clippedScore z ≤ (1 / 4 : ℝ) := by
    cases b
    · simp only [labelReal_false, neg_one_mul] at hz ⊢
      unfold clippedScore
      have hmin : -(1 / 4 : ℝ) ≤ min (1 / 2 : ℝ) z := le_min (by norm_num) (by linarith)
      have hh : -(1 / 4 : ℝ) ≤ max (-(1 / 2 : ℝ)) (min (1 / 2 : ℝ) z) :=
        hmin.trans (le_max_right _ _)
      linarith
    · simp only [labelReal_true, one_mul] at hz ⊢
      exact max_le (by norm_num) ((min_le_right _ _).trans hz)
  cases b <;> simp only [labelReal_true, labelReal_false, one_mul, neg_one_mul] at * <;>
    linarith [(abs_le.mp hclose).1, (abs_le.mp hclose).2]

end NeuralGeneralization.BatchTwoMerging
