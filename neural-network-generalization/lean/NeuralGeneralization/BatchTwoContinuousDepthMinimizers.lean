import NeuralGeneralization.BatchTwoContinuousMinimizers
import NeuralGeneralization.BatchTwoContinuousDepthStrongMain
import NeuralGeneralization.BatchTwoContinuousDepthPairRisk

/-! The exact-interpolation corollary: minimum-energy networks exist, and
every probability mixture of them fails even the one-half confidence level. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

theorem low_energy_mixture_pair_change {N r : ℕ} (hN : 0 < N) (hr : 6 ≤ r)
    (Q : Measure (Weights 2 N (r+1))) [IsProbabilityMeasure Q]
    (hQ : ∀ᵐ w ∂Q, weightedSquaredNorm w ≤ 4*(r : ℝ)+5) (ω : SignStream) :
    Q.real {w | (1/2 : ℝ) ≤ |output Real.tanh w (sphereCoding ω) -
      output Real.tanh w (sphereCoding (flipCoordinate (r+2) ω))|} ≤ 0 := by
  have hzero : Q {w | (1/2 : ℝ) ≤ |output Real.tanh w (sphereCoding ω) -
      output Real.tanh w (sphereCoding (flipCoordinate (r+2) ω))|} = 0 := by
    apply measure_eq_zero_iff_ae_notMem.mpr
    filter_upwards [hQ] with w hw
    have he : weightedSquaredNorm w ≤ 4*((r+1 : ℕ)+2 : ℝ) := by
      push_cast
      linarith
    have hl := output_energy_lipschitz hN w he (sphereCoding ω)
      (sphereCoding (flipCoordinate (r+2) ω))
    have hdist := sphereCoding_pair_distance (r+2) ω
    have hpow := channel_lipschitz_below_teacher_expansion hr
    have hscale : ((3 : ℝ)^(r+2)/10)*((13/5 : ℝ)*(1/3)^(r+2)) = 13/50 := by
      rw [one_div, inv_pow]
      field_simp
      <;> ring
    have hb : |output Real.tanh w (sphereCoding ω) -
        output Real.tanh w (sphereCoding (flipCoordinate (r+2) ω))| ≤ 13/50 := by
      apply hl.trans
      calc
        _ ≤ ((3 : ℝ)^(r+2)/10)*inputDistance (sphereCoding ω)
            (sphereCoding (flipCoordinate (r+2) ω)) :=
          mul_le_mul_of_nonneg_right (by simpa [Nat.add_assoc] using hpow)
            (Real.sqrt_nonneg _)
        _ ≤ ((3 : ℝ)^(r+2)/10)*((13/5 : ℝ)*(1/3)^(r+2)) :=
          mul_le_mul_of_nonneg_left hdist (by positivity)
        _ = _ := hscale
    change ¬ (1/2 : ℝ) ≤ _
    linarith
  simp only [measureReal_def, hzero, ENNReal.toReal_zero, le_refl]

theorem low_energy_mixture_failure {N r : ℕ} (hN : 0 < N) (hr : 6 ≤ r)
    (Q : Measure (Weights 2 N (r+1))) [IsProbabilityMeasure Q]
    (hQ : ∀ᵐ w ∂Q, weightedSquaredNorm w ≤ 4*(r : ℝ)+5) :
    (1/2 : ℝ) ≤ risk Real.tanh inputLaw Q (depthTarget (r+2)) (1/4) ∧
    (1/2 : ℝ) ≤ inputLaw.real {x |
      correctProbability Real.tanh Q (depthTarget (r+2)) (1/4) x ≤ 1/2} := by
  have hp := low_energy_mixture_pair_change hN hr Q hQ
  constructor
  · simpa using paired_gibbs_risk_lower Q (r+2) hp
  · rw [← inputLaw_balanced_pair (r+2)]
    apply paired_confidence_failure signLaw sphereCoding (sphereCoding ∘ flipCoordinate (r+2))
      sphereCoding_measurable (sphereCoding_measurable.comp (flipCoordinate_measurable (r+2)))
      _ (measurable_correctProbability tanh_continuous Q (continuous_target (r+2)).measurable _) (1/2)
    intro ω
    exact (correct_probability_pair_sum Q (r+2) hp ω).trans (by norm_num)

theorem separated_sample_exact_minimizers {r n N : ℕ}
    (hr : max 6 interpolationDepthThreshold ≤ r) (hn : 0 < n)
    (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100))
    (hN : interpolationWidth n ≤ N) :
    ∀ᵐ s ∂(Measure.pi (fun _ : Fin n => inputLaw)), s ∈ separatedSample n →
      (energyMinimizers (N := N) (r := r+1) Real.tanh (depthTarget (r+2)) s).Nonempty ∧
      (∀ w ∈ energyMinimizers (N := N) (r := r+1) Real.tanh (depthTarget (r+2)) s,
        weightedSquaredNorm w ≤ 4*(r : ℝ)+5) ∧
      (∀ Q : Measure (Weights 2 N (r+1)), IsProbabilityMeasure Q →
        (∀ᵐ w ∂Q, w ∈ energyMinimizers Real.tanh (depthTarget (r+2)) s) →
        (1/2 : ℝ) ≤ risk Real.tanh inputLaw Q (depthTarget (r+2)) (1/4) ∧
        (1/2 : ℝ) ≤ inputLaw.real {x |
          correctProbability Real.tanh Q (depthTarget (r+2)) (1/4) x ≤ 1/2}) := by
  filter_upwards [iid_sample_bounds (r+2) n] with s hs
  intro hsep
  have hwidth := interpolationWidth_ge hn
  obtain ⟨v, hv, hcost⟩ := exists_channel_memorizer hn hN hwidth.1
    (sampleSeparation_pos hn) ((sampleSeparation_le hn).trans (by norm_num)) s
    (fun i => depthTarget (r+2) (s i)) hs.1 hs.2 hsep hwidth.2
    (interpolation_channel_energy_small hn (le_trans (le_max_right _ _) hr) hnr)
  have hNpos : 0 < N := by omega
  have hv' : v ∈ exactInterpolants Real.tanh (depthTarget (r+2)) s := hv
  have he : ∀ w ∈ energyMinimizers (N := N) (r := r+1) Real.tanh (depthTarget (r+2)) s,
      weightedSquaredNorm w ≤ 4*(r : ℝ)+5 :=
    fun w hw => (energyMinimizers_energy_le hv' hw).trans hcost
  refine ⟨energyMinimizers_nonempty (by norm_num) hNpos tanh_continuous _ _ ⟨v, hv'⟩, he, ?_⟩
  intro Q hprob hQ
  letI : IsProbabilityMeasure Q := hprob
  apply low_energy_mixture_failure hNpos (le_trans (le_max_left _ _) hr) Q
  filter_upwards [hQ] with w hw
  exact he w hw

def ExactMinimizerFailure (r n N : ℕ) (s : Fin n → RealInput 2) : Prop :=
  (energyMinimizers (N := N) (r := r+1) Real.tanh (depthTarget (r+2)) s).Nonempty ∧
    ∀ Q : Measure (Weights 2 N (r+1)), IsProbabilityMeasure Q →
      (∀ᵐ w ∂Q, w ∈ energyMinimizers Real.tanh (depthTarget (r+2)) s) →
      (1/2 : ℝ) ≤ risk Real.tanh inputLaw Q (depthTarget (r+2)) (1/4) ∧
      (1/2 : ℝ) ≤ inputLaw.real {x |
        correctProbability Real.tanh Q (depthTarget (r+2)) (1/4) x ≤ 1/2}

/-- A measurable event of probability at least 49/50 simultaneously controls
every width, every exact minimizer, and every mixture of exact minimizers. -/
theorem exact_minimizer_all_width_event {r n : ℕ}
    (hr : max 6 interpolationDepthThreshold ≤ r) (hn : 0 < n)
    (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100)) :
    ∃ G : Set (Fin n → RealInput 2), MeasurableSet G ∧
      (49/50 : ℝ) ≤ (Measure.pi (fun _ : Fin n => inputLaw)).real G ∧
      ∀ s ∈ G, ∀ N : ℕ, interpolationWidth n ≤ N → ExactMinimizerFailure r n N s := by
  let μ := Measure.pi (fun _ : Fin n => inputLaw)
  have hwidth (N : ℕ) : ∀ᵐ s ∂μ, s ∈ separatedSample n →
      interpolationWidth n ≤ N → ExactMinimizerFailure r n N s := by
    by_cases hN : interpolationWidth n ≤ N
    · filter_upwards [separated_sample_exact_minimizers hr hn hnr hN] with s hs
      intro hsep _
      exact ⟨(hs hsep).1, (hs hsep).2.2⟩
    · exact Eventually.of_forall (fun _ _ hh => (hN hh).elim)
  let A := {s : Fin n → RealInput 2 | s ∈ separatedSample n →
    ∀ N : ℕ, interpolationWidth n ≤ N → ExactMinimizerFailure r n N s}
  have hA : ∀ᵐ s ∂μ, s ∈ A := by
    filter_upwards [ae_all_iff.mpr hwidth] with s hs
    exact fun hsep N hN => hs N hsep hN
  have hnull : μ Aᶜ = 0 := ae_iff.mp hA
  let B := toMeasurable μ Aᶜ
  have hB : MeasurableSet B := measurableSet_toMeasurable μ _
  have hnullB : μ B = 0 := by simpa only [B, measure_toMeasurable] using hnull
  let G := separatedSample n ∩ Bᶜ
  refine ⟨G, (separatedSample_measurable n).inter hB.compl, ?_, ?_⟩
  · apply (separatedSample_probability hn).trans
    apply ENNReal.toReal_mono (measure_ne_top μ G)
    apply measure_mono_ae
    filter_upwards [measure_eq_zero_iff_ae_notMem.mp hnullB] with s hs
    exact fun hsep => ⟨hsep, hs⟩
  · intro s hs
    have hsA : s ∈ A := by
      by_contra hh
      exact hs.2 (subset_toMeasurable μ Aᶜ hh)
    exact hsA hs.1

end NeuralGeneralization.BatchTwoContinuousDepthLower
