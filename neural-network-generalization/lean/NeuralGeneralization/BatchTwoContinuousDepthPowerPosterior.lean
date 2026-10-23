import NeuralGeneralization.BatchTwoContinuousDepthPowerSampleMass

/-! Direct paired-input posterior barrier. The argument controls arbitrary
posterior mixtures rather than selecting a minimum-energy predictor. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1400000
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoContinuous BatchTwoNonGaussian BatchTwoContinuousDepthLower

theorem paired_output_change_barrier {N q : ℕ}
    (Q : Measure (Weights 2 N q)) [IsProbabilityMeasure Q] (r : ℕ)
    (hpair : ∀ ω, Q.real {w | (1/2 : ℝ)≤
      |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate r ω))|}≤1/3) :
    (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh inputLaw Q (depthTarget r) (1/4) := by
  unfold BatchTwoContinuous.confidenceFailure
  rw [←inputLaw_balanced_pair r]
  apply paired_confidence_failure signLaw sphereCoding (sphereCoding ∘ flipCoordinate r)
    sphereCoding_measurable (sphereCoding_measurable.comp (flipCoordinate_measurable r))
    _ (measurable_correctProbability tanh_lipschitzWith.continuous Q (continuous_target r).measurable (1/4)) (2/3)
  intro ω
  let G : Set (Weights 2 N q) := {w |
    |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate r ω))|<1/2}
  have hb : Q.real Gᶜ≤(1/3 : ℝ) := by simpa only [G,compl_setOf,not_lt] using hpair ω
  have hh := posterior_pair_sum_le Q (output Real.tanh)
    (fun x => (continuous_output_weights tanh_lipschitzWith.continuous x).measurable)
    (depthTarget r) G hb (sphereCoding ω) (sphereCoding (flipCoordinate r ω)) (by
      intro w hw
      apply incompatible_correct_outputs (sphereCoding_pair_target_gap r ω) (le_refl _)
      change _<1
      dsimp only [G,mem_setOf_eq] at hw
      linarith)
  change _≤2*(2/3 : ℝ)
  norm_num only at *
  exact hh

/-- Exact conditioning preserves the paired lower bound once the sharp prior
numerator beats the memorizer denominator by the displayed polynomial cost. -/
theorem confidence_failure_from_pair_rate {N r n : ℕ} {σ P : ℝ}
    (hσ : 0<σ) (hσsmall : σ^2≤1/16) (hr : 60≤(r : ℝ)+1)
    (hcost : (N : ℝ)*σ^2*P≤((r : ℝ)+1)/100)
    (s : Fin n→RealInput 2)
    (hden : Real.exp (-slowEnergyCeiling r/(2*σ^2)-(N : ℝ)*P)≤
      (ConcreteModel.smallPrior 2 N (r+1) σ).real (trainingEvent Real.tanh (depthTarget (r+2)) (1/8) s))
    (hnum : ∀ ω, (ConcreteModel.smallPrior 2 N (r+1) σ).real {w | (1/2 : ℝ)≤
      |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate (r+2) ω))|}≤
        Real.exp (-(11/10)*((r : ℝ)+1)/σ^2)) :
    (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
      (BatchTwoContinuous.posterior Real.tanh (ConcreteModel.smallPrior 2 N (r+1) σ)
        (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4) := by
  let μ := ConcreteModel.smallPrior 2 N (r+1) σ
  let V := trainingEvent (N := N) (r := r+1) Real.tanh (depthTarget (r+2)) (1/8) s
  have hpos : 0<μ.real V := (Real.exp_pos _).trans_le hden
  have hne : μ V≠0 := by intro hh; simp only [Measure.real,hh,ENNReal.toReal_zero] at hpos; exact hpos.false
  letI : IsProbabilityMeasure (BatchTwoContinuous.posterior Real.tanh μ (depthTarget (r+2)) (1/8) s) :=
    cond_isProbabilityMeasure hne
  apply paired_output_change_barrier _ (r+2)
  intro ω
  let U : Set (Weights 2 N (r+1)) := {w | (1/2 : ℝ)≤
    |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate (r+2) ω))|}
  have hratio := RobustPosterior.cond_real_le_ratio μ V U
    (isOpen_trainingEvent tanh_lipschitzWith.continuous _ _ s).measurableSet
  apply hratio.trans
  have hbound : μ.real U/μ.real V ≤
      Real.exp (-(11/10)*((r : ℝ)+1)/σ^2)/Real.exp (-slowEnergyCeiling r/(2*σ^2)-(N : ℝ)*P) :=
    div_le_div₀ (Real.exp_nonneg _) (hnum ω) (Real.exp_pos _) hden
  apply hbound.trans
  rw [←Real.exp_sub]
  have hs : 0<σ^2 := sq_pos_of_pos hσ
  have hex : -(11/10)*((r : ℝ)+1)/σ^2-(-slowEnergyCeiling r/(2*σ^2)-(N : ℝ)*P)≤-2 := by
    have he : -(11/10)*((r : ℝ)+1)/σ^2-(-slowEnergyCeiling r/(2*σ^2)-(N : ℝ)*P)=
        (-(11/10)*((r : ℝ)+1)+slowEnergyCeiling r/2+(N : ℝ)*σ^2*P)/σ^2 := by field_simp; ring
    rw [he]
    apply (div_le_iff₀ hs).mpr
    unfold slowEnergyCeiling
    nlinarith
  have hfinal : Real.exp (-2 : ℝ)≤1/3 := by
    rw [Real.exp_neg]
    simpa only [one_div] using
      (one_div_le_one_div_of_le (by norm_num : (0 : ℝ)<3) (by linarith [Real.add_one_le_exp (2 : ℝ)] : (3 : ℝ)≤Real.exp 2))
  exact (Real.exp_le_exp.mpr hex).trans hfinal

end NeuralGeneralization.BatchTwoContinuousDepthPower
