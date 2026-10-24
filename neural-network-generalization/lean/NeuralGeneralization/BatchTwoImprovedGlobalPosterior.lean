import NeuralGeneralization.RobustPosterior

/-! # The optional globally margin-conditioned robust posterior -/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoImprovedGlobalPosterior
open ConcreteModel RobustPosterior

variable {d N r n : ℕ}

def trainingMarginEvent (φ : ℝ → ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) : Set (Weights d N r) :=
  {w | ∀ i, 1 / 2 < labelReal (f (sample i)) * networkOutput φ w (sample i)}

def robustPosteriorEvent (φ : ℝ → ℝ) (c : ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) : Set (Weights d N r) :=
  (robustEvent φ c ∩ globalMarginEvent φ (1/2)) ∩ trainingMarginEvent φ f sample

def robustPosterior (φ : ℝ → ℝ) (c σ : ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (robustPosteriorEvent φ c f sample)

def readoutCap (B : ℝ) : Set (Weights d N r) := {w | readoutEnergy w ≤ B}

def retainedPosterior (φ : ℝ → ℝ) (c σ B : ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (robustPosteriorEvent φ c f sample ∩ readoutCap B)

theorem measurable_trainingMarginEvent {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) :
    MeasurableSet (trainingMarginEvent (N := N) (r := r) φ f sample) := by
  unfold trainingMarginEvent
  simp only [Set.setOf_forall]
  exact MeasurableSet.iInter (fun i => measurableSet_lt measurable_const
    ((continuous_networkOutput hφ (sample i)).measurable.const_mul _))

theorem measurable_globalMarginEvent {φ : ℝ → ℝ} (hφ : Continuous φ) :
    MeasurableSet (globalMarginEvent (d:=d) (N:=N) (r:=r) φ (1/2)) := by
  unfold globalMarginEvent
  simp only [Set.setOf_forall]
  exact MeasurableSet.iInter (fun x => measurableSet_lt measurable_const
    (continuous_networkOutput hφ x).measurable.abs)

theorem measurable_robustPosteriorEvent {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c : ℝ} (hc : 0 < c) (f : BooleanFunction d) (sample : Fin n → Cube d) :
    MeasurableSet (robustPosteriorEvent (N := N) (r := r) φ c f sample) :=
  ((measurableSet_robustEvent hφ hc).inter (measurable_globalMarginEvent hφ)).inter
    (measurable_trainingMarginEvent hφ f sample)

theorem measurable_readoutCap (B : ℝ) : MeasurableSet (readoutCap (d := d) (N := N) (r := r) B) :=
  measurableSet_le continuous_readoutEnergy.measurable measurable_const

/-- This is exactly conditioning the robust prior on the training likelihood. -/
theorem robustPosterior_eq_two_stage {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c : ℝ} (hc : 0 < c) (σ : ℝ) (f : BooleanFunction d) (sample : Fin n → Cube d) :
    robustPosterior (N := N) (r := r) φ c σ f sample =
      cond (cond (smallPrior d N r σ) (robustEvent φ c ∩ globalMarginEvent φ (1/2))) (trainingMarginEvent φ f sample) := by
  exact (cond_cond_eq_cond_inter ((measurableSet_robustEvent hφ hc).inter (measurable_globalMarginEvent hφ))
    (measurable_trainingMarginEvent hφ f sample) _).symm

theorem retainedPosterior_eq_cond {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c : ℝ} (hc : 0 < c) (σ B : ℝ) (f : BooleanFunction d) (sample : Fin n → Cube d) :
    retainedPosterior (N := N) (r := r) φ c σ B f sample =
      cond (robustPosterior φ c σ f sample) (readoutCap B) := by
  exact (cond_cond_eq_cond_inter (measurable_robustPosteriorEvent hφ hc f sample)
    (measurable_readoutCap B) _).symm

theorem target_subset_posteriorEvent (φ : ℝ → ℝ) (c : ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) :
    robustEvent φ c ∩ marginEvent (N := N) (r := r) φ (1 / 2) f ⊆
      robustPosteriorEvent φ c f sample := by
  intro w hw
  exact ⟨⟨hw.1,marginEvent_subset_global φ (1/2) f hw.2⟩,fun i => hw.2 (sample i)⟩

theorem posterior_event_mass_lower (φ : ℝ → ℝ) (c σ : ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) {D : ℝ}
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustEvent φ c ∩ marginEvent φ (1 / 2) f)) :
    Real.exp (-D / σ ^ 2) ≤
      (smallPrior d N r σ).real (robustPosteriorEvent φ c f sample) :=
  htarget.trans (measureReal_mono (target_subset_posteriorEvent φ c f sample))

theorem posterior_event_ne_zero (φ : ℝ → ℝ) (c σ : ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) {D : ℝ}
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustEvent φ c ∩ marginEvent φ (1 / 2) f)) :
    smallPrior d N r σ (robustPosteriorEvent φ c f sample) ≠ 0 := by
  have hp := (Real.exp_pos _).trans_le (posterior_event_mass_lower φ c σ f sample htarget)
  intro he
  simp only [Measure.real, he, ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

theorem retained_training_null {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c : ℝ} (hc : 0 < c) (σ B : ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) (i : Fin n) :
    (retainedPosterior (N := N) (r := r) φ c σ B f sample).real
      {w | labelReal (f (sample i)) * networkOutput φ w (sample i) ≤ 1 / 2} = 0 := by
  apply cond_null_of_disjoint _ _ _
    ((measurable_robustPosteriorEvent hφ hc f sample).inter (measurable_readoutCap B))
  apply Set.disjoint_left.mpr
  intro w hw hbad
  exact (not_le_of_gt (hw.1.2 i)) hbad

theorem retained_supported {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c : ℝ} (hc : 0 < c) (σ B : ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) :
    ∀ᵐ w ∂retainedPosterior (N := N) (r := r) φ c σ B f sample,
      w ∈ robustEvent φ c ∧ readoutEnergy w ≤ B := by
  have h := ae_cond_mem (μ := smallPrior d N r σ)
    ((measurable_robustPosteriorEvent hφ hc f sample).inter (measurable_readoutCap B))
  exact h.mono (fun _ hw => ⟨hw.1.1.1, hw.2⟩)

theorem calibrated_radius_lower {c B : ℝ} (hc : 0 < c)
    (w : Weights d N r) (hread : readoutEnergy w ≤ B) :
    c / Real.sqrt (1 + ((r : ℝ) + 1) * B) ≤ robustRadius c w := by
  unfold robustRadius
  apply div_le_div_of_nonneg_left hc.le
  · apply Real.sqrt_pos.mpr
    have := readoutEnergy_nonneg w
    positivity
  · apply Real.sqrt_le_sqrt
    have hm := mul_le_mul_of_nonneg_left hread (show 0 ≤ (r : ℝ) + 1 by positivity)
    linarith

theorem robustPosterior_readout_tail {φ : ℝ → ℝ} (hφ : Continuous φ)
    (hd : 0 < d) (hN : 0 < N) {c σ D B β : ℝ}
    (hc : 0 < c) (hσ : 0 < σ) (hscale : (N : ℝ) * σ ^ 2 ≤ 1)
    (hβ : 0 < β) (hβ1 : β ≤ 1) (hB : 8 ≤ B)
    (hbudget : 4 * (D - Real.log β) ≤ B)
    (f : BooleanFunction d) (sample : Fin n → Cube d)
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustEvent φ c ∩ marginEvent φ (1 / 2) f)) :
    (robustPosterior (N := N) (r := r) φ c σ f sample).real (readoutCap B)ᶜ ≤ β := by
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hs1 : σ ^ 2 ≤ 1 := by nlinarith [sq_nonneg σ]
  have ht := smallPrior_readout_tail (r := r) hd hN hσ (B := B) (by nlinarith)
  have heq : (readoutCap (d := d) (N := N) (r := r) B)ᶜ = {w | B < readoutEnergy w} := by
    ext w
    simp only [readoutCap, Set.mem_compl_iff, Set.mem_setOf_eq, not_le]
  apply conditional_tail_of_exponential_bounds (smallPrior d N r σ)
    (robustPosteriorEvent φ c f sample) (readoutCap B)ᶜ
    (measurable_robustPosteriorEvent hφ hc f sample)
    (sq_pos_of_pos hσ) hs1 hβ hβ1
    (posterior_event_mass_lower φ c σ f sample htarget) _ hbudget
  simpa only [heq] using ht

theorem robustPosterior_isProbability (φ : ℝ → ℝ) (c σ : ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) {D : ℝ}
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustEvent φ c ∩ marginEvent φ (1 / 2) f)) :
    IsProbabilityMeasure (robustPosterior (N := N) (r := r) φ c σ f sample) :=
  cond_isProbabilityMeasure (posterior_event_ne_zero φ c σ f sample htarget)

theorem retainedPosterior_mass_lower {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c σ D B β : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hσ1 : σ ^ 2 ≤ 1)
    (hβ : β ≤ 1 / 2) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustEvent φ c ∩ marginEvent φ (1 / 2) f))
    (htail : (robustPosterior (N := N) (r := r) φ c σ f sample).real (readoutCap B)ᶜ ≤ β) :
    Real.exp (-(D + 1) / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustPosteriorEvent φ c f sample ∩ readoutCap B) :=
  retained_exponential_mass _ _ _ (measurable_robustPosteriorEvent hφ hc f sample)
    (measurable_readoutCap B) (sq_pos_of_pos hσ) hσ1 hβ
    (posterior_event_mass_lower φ c σ f sample htarget) htail

theorem retainedPosterior_isProbability {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c σ D B β : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hσ1 : σ ^ 2 ≤ 1)
    (hβ : β ≤ 1 / 2) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustEvent φ c ∩ marginEvent φ (1 / 2) f))
    (htail : (robustPosterior (N := N) (r := r) φ c σ f sample).real (readoutCap B)ᶜ ≤ β) :
    IsProbabilityMeasure (retainedPosterior (N := N) (r := r) φ c σ B f sample) := by
  apply cond_isProbabilityMeasure
  have hp := (Real.exp_pos _).trans_le
    (retainedPosterior_mass_lower hφ hc hσ hσ1 hβ f sample htarget htail)
  intro he
  simp only [Measure.real, he, ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

theorem retainedPosterior_klDiv_bound {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c σ D B β : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hσ1 : σ ^ 2 ≤ 1)
    (hβ : β ≤ 1 / 2) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustEvent φ c ∩ marginEvent φ (1 / 2) f))
    (htail : (robustPosterior (N := N) (r := r) φ c σ f sample).real (readoutCap B)ᶜ ≤ β) :
    klDiv (retainedPosterior (N := N) (r := r) φ c σ B f sample) (smallPrior d N r σ) ≤
      ENNReal.ofReal ((D + 1) / σ ^ 2) :=
  retained_klDiv_bound _ _ _ (measurable_robustPosteriorEvent hφ hc f sample)
    (measurable_readoutCap B) (sq_pos_of_pos hσ) hσ1 hβ
    (posterior_event_mass_lower φ c σ f sample htarget) htail

theorem robustPosterior_restore {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c σ D B β : ℝ} (hc : 0 < c) (hβ : β < 1)
    (f : BooleanFunction d) (sample : Fin n → Cube d)
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustEvent φ c ∩ marginEvent φ (1 / 2) f))
    (htail : (robustPosterior (N := N) (r := r) φ c σ f sample).real (readoutCap B)ᶜ ≤ β)
    (A : Set (Weights d N r)) :
    (robustPosterior φ c σ f sample).real A ≤
      β + (retainedPosterior φ c σ B f sample).real A := by
  letI := robustPosterior_isProbability φ c σ f sample htarget
  have hp : 0 < (robustPosterior (N := N) (r := r) φ c σ f sample).real (readoutCap B) := by
    rw [probReal_compl_eq_one_sub (measurable_readoutCap B)] at htail
    linarith
  rw [retainedPosterior_eq_cond hφ hc σ B f sample]
  exact retained_restore_of_tail _ _ A (measurable_readoutCap B) hp htail

end NeuralGeneralization.BatchTwoImprovedGlobalPosterior
