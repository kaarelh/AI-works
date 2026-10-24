import NeuralGeneralization.BatchTwoShallowRelativeGrowth
import NeuralGeneralization.BatchTwoShallowExplicitBudget
import NeuralGeneralization.PowerPriorScaling

/-! The sharper-dimension boxed theorem, with the exact displayed sample budgets. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel CompressionSampling

def sharpImplicitBudget (d m n : ℕ) (ε δ : ℝ) : ℝ :=
  64/ε*((m : ℝ)*(d+1)*Real.log (2*Real.exp 1*n)+Real.log (4*((m : ℝ)+2)/δ))

def sharpBudgetParameter (d m : ℕ) (ε δ : ℝ) : ℝ :=
  64/ε*((m : ℝ)*(d+1)+Real.log (4*((m : ℝ)+2)/δ))

def sharpExplicitBudget (d m : ℕ) (ε δ : ℝ) : ℕ :=
  ⌈4*sharpBudgetParameter d m ε δ*Real.log (8*Real.exp 1*sharpBudgetParameter d m ε δ)⌉₊

theorem sharp_log_pos (m : ℕ) {δ : ℝ} (hδ : 0 < δ) (hδ1 : δ < 1) :
    0 < Real.log (4*((m : ℝ)+2)/δ) := by
  apply Real.log_pos
  apply (one_lt_div hδ).mpr
  have hm : (0 : ℝ) ≤ m := Nat.cast_nonneg m
  linarith

theorem sharp_implicit_pos {d m n : ℕ} {ε δ : ℝ} (hε : 0 < ε)
    (hδ : 0 < δ) (hδ1 : δ < 1) (hn : sharpImplicitBudget d m n ε δ ≤ (n : ℝ)) : 0 < n := by
  by_contra hn0
  have he : n=0 := Nat.eq_zero_of_not_pos hn0
  subst n
  have hl := sharp_log_pos m hδ hδ1
  have hp : 0 < 64/ε*Real.log (4*((m : ℝ)+2)/δ) := by positivity
  simp only [sharpImplicitBudget, Nat.cast_zero, mul_zero, Real.log_zero, zero_add] at hn
  linarith

theorem sharp_explicit_implies_implicit {d m n : ℕ} (hm : 0 < m)
    {ε δ : ℝ} (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (hn : sharpExplicitBudget d m ε δ ≤ n) : sharpImplicitBudget d m n ε δ ≤ (n : ℝ) := by
  let A := 64/ε*((m : ℝ)*(d+1))
  let B := 64/ε*Real.log (4*((m : ℝ)+2)/δ)
  have hA : 0 ≤ A := by dsimp [A]; positivity
  have hB : 0 ≤ B := by dsimp [B]; exact (mul_pos (by positivity) (sharp_log_pos m hδ hδ1)).le
  have hT : 1 ≤ A+B := by
    have hmR : (1 : ℝ) ≤ m := by exact_mod_cast hm
    have hdR : (1 : ℝ) ≤ (d : ℝ)+1 := by have := Nat.cast_nonneg (α := ℝ) d; linarith
    have hfactor : (1 : ℝ) ≤ (m : ℝ)*(d+1) := by nlinarith
    have h64 : (64 : ℝ) ≤ 64/ε := (le_div_iff₀ hε).mpr (by linarith)
    have ha : (64 : ℝ) ≤ A := by dsimp [A]; nlinarith
    linarith
  have he : sharpBudgetParameter d m ε δ=A+B := by dsimp [sharpBudgetParameter,A,B]; ring
  have hnR : 4*(A+B)*Real.log (8*Real.exp 1*(A+B)) ≤ (n : ℝ) := by
    rw [← he]
    exact (Nat.le_ceil _).trans (by exact_mod_cast hn)
  have h := explicit_log_budget hA hB hT hnR
  convert h using 1 <;> dsimp [sharpImplicitBudget,A,B] <;> ring

theorem shallow_risk_of_vote_event {d C N n : ℕ} (hd : 0 < d) (hC : 0 < C)
    (hCN : C ≤ N) (hn : 0 < n)
    (w : Weights d C 0) (f : BooleanFunction d) (hw : w ∈ marginEvent Real.tanh (1/2) f)
    {c ε σ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1)
    (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1)
    (robust global : Bool) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (sample : Fin n → Cube d)
    (hsample : sample ∈ BatchTwoRelativeStatistics.generalizationEvent D
      (voteLoss f (readoutBound (targetScale c robust) ε w) (voteCount (targetScale c robust) ε w)) n (ε/2)) :
    0 < (smallPrior d N 0 σ).real (conditioningEvent c robust global f sample) ∧
    RobustConfidence.gibbsMarginRisk D (posterior (N := N) σ c robust global f sample)
      (fun x => labelReal (f x)) (networkOutput Real.tanh) (1/4) ≤ ε := by
  let s := targetScale c robust
  have hs : 0 ≤ s := by dsimp [s,targetScale]; cases robust <;> simp <;> linarith
  let B := readoutBound s ε w
  let m := voteCount s ε w
  have hB : 0 < B := readoutBound_pos hs hε hε1 w
  have hm : 0 < m := voteCount_pos hs hε hε1 w
  have hmass := conditioning_mass hd hC hCN w f hw hc hσ hscale robust global sample
  have hpos : 0 < (smallPrior d N 0 σ).real (conditioningEvent c robust global f sample) :=
    (Real.exp_pos _).trans_le hmass
  refine ⟨hpos, ?_⟩
  have hE0 : (smallPrior d N 0 σ) (conditioningEvent c robust global f sample) ≠ 0 := by
    intro he
    simp only [Measure.real, he, ENNReal.toReal_zero] at hpos
    exact (lt_irrefl 0) hpos
  letI : IsProbabilityMeasure (posterior (N := N) σ c robust global f sample) := cond_isProbabilityMeasure hE0
  have htrain : ∀ᵐ u ∂posterior (N := N) σ c robust global f sample,
      ∀ i, (1 : ℝ)/2 < labelReal (f (sample i))*networkOutput Real.tanh u (sample i) := by
    filter_upwards [ae_cond_mem (μ := smallPrior d N 0 σ)
      (measurable_conditioningEvent hc robust global f sample)] with u hu
    exact hu.2
  have htail := posterior_readout_tail hd hC hCN w f hw hc hσ hscale hε hε1 robust global sample
  have hrisk := shallow_posterior_risk D (posterior σ c robust global f sample) f hB m hm
    sample hn (by positivity : 0 ≤ ε/2) hsample htail htrain
  have halpha := vote_error_budget hs hε hε1 w
  change 2*Real.exp (-(m : ℝ)/(512*B^2)) ≤ ε/12 at halpha
  linarith

/-- **Sharper implicit boxed theorem.** Literal common-event statement for all widths and scales. -/
theorem shallow_sharp_all_width_all_scale {d C n : ℕ} (hd : 0 < d) (hC : 0 < C)
    (w : Weights d C 0) (f : BooleanFunction d) (hw : w ∈ marginEvent Real.tanh (1/2) f)
    {c ε δ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (robust global : Bool) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (hn : sharpImplicitBudget d (voteCount (targetScale c robust) ε w) n ε δ ≤ (n : ℝ)) :
    ∃ A : Set (Fin n → Cube d), MeasurableSet A ∧ (1-δ ≤ (iidSamples D n).real A) ∧
      ∀ sample ∈ A, ∀ N : ℕ, C ≤ N → ∀ σ : ℝ, 0 < σ → (N : ℝ)*σ^2 ≤ 1 →
        (0 < (smallPrior d N 0 σ).real (conditioningEvent c robust global f sample)) ∧
        RobustConfidence.gibbsMarginRisk D (posterior (N := N) σ c robust global f sample)
          (fun x => labelReal (f x)) (networkOutput Real.tanh) (1/4) ≤ ε := by
  let s := targetScale c robust
  let B := readoutBound s ε w
  let m := voteCount s ε w
  have hn0 : 0 < n := sharp_implicit_pos hε hδ hδ1 hn
  let A := BatchTwoRelativeStatistics.generalizationEvent D (voteLoss f B m) n (ε/2)
  have hprob : 1-δ ≤ (iidSamples D n).real A := by
    apply vote_relative_growth_probability hn0 D f B hδ hδ1
    have hl : Real.log (4/δ) ≤ Real.log (4*((m : ℝ)+2)/δ) := by
      apply Real.log_le_log (by positivity)
      apply div_le_div_of_nonneg_right _ hδ.le
      have hm : (0 : ℝ) ≤ m := Nat.cast_nonneg m
      linarith
    have hmul := mul_le_mul_of_nonneg_right hn hε.le
    change (64/ε*((m : ℝ)*(d+1)*Real.log (2*Real.exp 1*n)+Real.log (4*((m : ℝ)+2)/δ)))*ε ≤ (n : ℝ)*ε at hmul
    have heq : (64/ε*((m : ℝ)*(d+1)*Real.log (2*Real.exp 1*n)+Real.log (4*((m : ℝ)+2)/δ)))*ε =
        64*((m : ℝ)*(d+1)*Real.log (2*Real.exp 1*n)+Real.log (4*((m : ℝ)+2)/δ)) := by field_simp
    rw [heq] at hmul
    nlinarith
  refine ⟨A,BatchTwoRelativeStatistics.measurable_generalizationEvent D (voteLoss f B m)
    (fun _ => measurable_of_finite _) n (ε/2),hprob,?_⟩
  intro sample hsample N hCN σ hσ hscale
  exact shallow_risk_of_vote_event hd hC hCN hn0 w f hw hc hε hε1 hσ hscale robust global D sample hsample

/-- **Sharper explicit boxed theorem.** The stated ceiling budget suffices. -/
theorem shallow_explicit_sharp_all_width_all_scale {d C n : ℕ} (hd : 0 < d) (hC : 0 < C)
    (w : Weights d C 0) (f : BooleanFunction d) (hw : w ∈ marginEvent Real.tanh (1/2) f)
    {c ε δ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (robust global : Bool) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (hn : sharpExplicitBudget d (voteCount (targetScale c robust) ε w) ε δ ≤ n) :
    ∃ A : Set (Fin n → Cube d), MeasurableSet A ∧ (1-δ ≤ (iidSamples D n).real A) ∧
      ∀ sample ∈ A, ∀ N : ℕ, C ≤ N → ∀ σ : ℝ, 0 < σ → (N : ℝ)*σ^2 ≤ 1 →
        (0 < (smallPrior d N 0 σ).real (conditioningEvent c robust global f sample)) ∧
        RobustConfidence.gibbsMarginRisk D (posterior (N := N) σ c robust global f sample)
          (fun x => labelReal (f x)) (networkOutput Real.tanh) (1/4) ≤ ε := by
  apply shallow_sharp_all_width_all_scale hd hC w f hw hc hε hε1 hδ hδ1 robust global D
  have hs : 0 ≤ targetScale c robust := by unfold targetScale; cases robust <;> simp <;> linarith
  exact sharp_explicit_implies_implicit (voteCount_pos hs hε hε1 w) hε hε1 hδ hδ1 hn

end NeuralGeneralization.BatchTwoShallow
