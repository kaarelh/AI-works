import NeuralGeneralization.BatchTwoShallowPosterior
import NeuralGeneralization.BatchTwoShallowStatistics

/-! The explicit simultaneous all-width/all-scale shallow tanh theorem.
This is the first boxed sample budget in the manuscript, with the actual
Gaussian prior and all three support conventions. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel CompressionSampling

def voteCount {d C : ℕ} (s ε : ℝ) (w : Weights d C 0) : ℕ :=
  ⌈512*(readoutBound s ε w)^2*Real.log (24/ε)⌉₊

def dimensionEntropy (d : ℕ) : ℝ := (d+1 : ℝ)*(1+(d : ℝ)*Real.log 2)

def sampleBudget {d C : ℕ} (s ε δ : ℝ) (w : Weights d C 0) : ℝ :=
  16/ε*((voteCount s ε w : ℝ)*dimensionEntropy d+Real.log (1/δ))

theorem voteCount_pos {d C : ℕ} {s ε : ℝ} (hs : 0 ≤ s) (hε : 0 < ε)
    (hε1 : ε < 1) (w : Weights d C 0) : 0 < voteCount s ε w := by
  apply Nat.ceil_pos.mpr
  have hB := readoutBound_pos hs hε hε1 w
  have hl : 0 < Real.log (24/ε) := Real.log_pos ((lt_div_iff₀ hε).mpr (by linarith))
  positivity

theorem vote_error_budget {d C : ℕ} {s ε : ℝ} (hs : 0 ≤ s) (hε : 0 < ε)
    (hε1 : ε < 1) (w : Weights d C 0) :
    2*Real.exp (-(voteCount s ε w : ℝ)/(512*(readoutBound s ε w)^2)) ≤ ε/12 := by
  have hB := readoutBound_pos hs hε hε1 w
  have hden : 0 < 512*(readoutBound s ε w)^2 := by positivity
  have hm := Nat.le_ceil (512*(readoutBound s ε w)^2*Real.log (24/ε))
  have hquot : Real.log (24/ε) ≤ (voteCount s ε w : ℝ)/(512*(readoutBound s ε w)^2) := by
    apply (le_div_iff₀ hden).mpr
    simpa only [voteCount, mul_comm] using hm
  have hlog : Real.exp (-Real.log (24/ε))=ε/24 := by
    rw [Real.exp_neg, Real.exp_log (by positivity)]
    field_simp
  have he := Real.exp_le_exp.mpr (neg_le_neg hquot)
  rw [← neg_div, hlog] at he
  linarith

/-- **First boxed theorem of the shallow paper.** A single measurable sample
event works simultaneously for every learner width N≥C and every Gaussian
scale Nσ²≤1. Raw, globally margin-conditioned, and original robustness-
restricted priors are all literal instances of the support switches. -/
theorem shallow_all_width_all_scale {d C n : ℕ} (hd : 0 < d) (hC : 0 < C)
    (w : Weights d C 0) (f : BooleanFunction d) (hw : w ∈ marginEvent Real.tanh (1/2) f)
    {c ε δ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (robust global : Bool) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (hn : sampleBudget (targetScale c robust) ε δ w ≤ (n : ℝ)) :
    ∃ A : Set (Fin n → Cube d), MeasurableSet A ∧ (1-δ ≤ (iidSamples D n).real A) ∧
      ∀ sample ∈ A, ∀ N : ℕ, C ≤ N → ∀ σ : ℝ, 0 < σ → (N : ℝ)*σ^2 ≤ 1 →
        (0 < (smallPrior d N 0 σ).real (conditioningEvent c robust global f sample)) ∧
        RobustConfidence.gibbsMarginRisk D (posterior (N := N) σ c robust global f sample)
          (fun x => labelReal (f x)) (networkOutput Real.tanh) (1/4) ≤ ε := by
  let s := targetScale c robust
  have hs : 0 ≤ s := by dsimp [s,targetScale]; cases robust <;> simp <;> linarith
  let B := readoutBound s ε w
  let m := voteCount s ε w
  have hB : 0 < B := readoutBound_pos hs hε hε1 w
  have hm : 0 < m := voteCount_pos hs hε hε1 w
  have hedim : 0 ≤ dimensionEntropy d := by
    unfold dimensionEntropy
    have hl := Real.log_nonneg (by norm_num : (1 : ℝ) ≤ 2)
    positivity
  have hlogδ : 0 < Real.log (1/δ) := Real.log_pos ((one_lt_div hδ).mpr hδ1)
  have hsum : 0 < (m : ℝ)*dimensionEntropy d+Real.log (1/δ) := by positivity
  have hbudget : 16/ε*((m : ℝ)*dimensionEntropy d+Real.log (1/δ)) ≤ (n : ℝ) := hn
  have hnR : 0 < (n : ℝ) := (mul_pos (div_pos (by norm_num) hε) hsum).trans_le hbudget
  have hn0 : 0 < n := Nat.cast_pos.mp hnR
  let A := BatchTwoRelativeStatistics.generalizationEvent D (voteLoss f B m) n (ε/2)
  have hprob : 1-δ ≤ (iidSamples D n).real A := by
    apply BatchTwoRelativeStatistics.finite_class_good_probability_log D (voteLoss f B m)
      (fun _ => measurable_of_finite _) (voteLoss_bounds f B m) n hn0 hδ
      (E := (m : ℝ)*dimensionEntropy d)
    · simpa only [dimensionEntropy, mul_assoc] using vote_log_card_bound d m
    · have hmul := mul_le_mul_of_nonneg_right hbudget hε.le
      have heq : (16/ε*((m : ℝ)*dimensionEntropy d+Real.log (1/δ)))*ε =
          16*((m : ℝ)*dimensionEntropy d+Real.log (1/δ)) := by field_simp
      rw [heq] at hmul
      nlinarith
  refine ⟨A, BatchTwoRelativeStatistics.measurable_generalizationEvent D (voteLoss f B m)
    (fun _ => measurable_of_finite _) n (ε/2), hprob, ?_⟩
  intro sample hsample N hCN σ hσ hscale
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
    sample hn0 (by positivity : 0 ≤ ε/2) hsample htail htrain
  have halpha := vote_error_budget hs hε hε1 w
  change 2*Real.exp (-(m : ℝ)/(512*B^2)) ≤ ε/12 at halpha
  linarith

end NeuralGeneralization.BatchTwoShallow
