import NeuralGeneralization.BatchTwoContinuousStrongMain

/-! One sample event controls all learner widths and all low-energy
interpolants, including arbitrary probability mixtures. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling BatchTwoSurvivalStatistics

theorem low_energy_interpolants_and_mixtures {d r K R : ℕ}
    (hd : 1≤d) (hK : 1≤K) (hR : 1≤R)
    (f : RealInput d → ℝ) (hf : Continuous f)
    (X : Set (RealInput d)) (hX : X.Nonempty) (hcompact : IsCompact X)
    (hball : ∀ x∈X, ∑ j,x j^2≤1)
    (D : Measure (RealInput d)) [IsProbabilityMeasure D] (hDX : D Xᶜ=0)
    {τ ε δ H : ℝ} (hτ : 0<τ) (hε : 0<ε) (hδ : 0<δ)
    (haccuracy : 1/(3*(R : ℝ))≤τ/8)
    (hcard : (Fintype.card (UniformCoverCode d r K R) : ℝ)≤Real.exp H)
    (n : ℕ) (hsize : (3/ε)*(H+Real.log (1/δ))≤(n : ℝ)) :
    ∃ G : Set (Fin n → RealInput d), MeasurableSet G ∧
      1-δ≤(iidSamples D n).real G ∧
      ∀ sample∈G,
        (∀ N : ℕ, 0<N → ∀ w : Weights d N r,
          weightedSquaredNorm w≤(K : ℝ) →
          (∀ i, |output Real.tanh w (sample i)-f (sample i)|≤τ/2) →
          D.real {x | τ < |output Real.tanh w x-f x|} ≤ ε/3) ∧
        (∀ N : ℕ, 0<N → ∀ Q : Measure (Weights d N r), IsProbabilityMeasure Q →
          (∀ᵐ w ∂Q, weightedSquaredNorm w≤(K : ℝ) ∧
            ∀ i, |output Real.tanh w (sample i)-f (sample i)|≤τ/2) →
          risk Real.tanh D Q f τ≤ε/3 ∧ confidenceFailure Real.tanh D Q f τ≤ε) := by
  classical
  let g := uniformCoverOutput d r K R Real.tanh
  let a : ℝ := 1/(3*(R : ℝ))
  let ρ : ℝ := 5*τ/8
  let A := regressionComparison f g ρ a
  letI : Nonempty (UniformCoverCode d r K R) := ⟨fun _ => ⟨0,by simp⟩⟩
  have hA : ∀ q, MeasurableSet (A q) := measurable_regressionComparison hf.measurable g
    (fun q => (continuous_output_input tanh_continuous _).measurable) _ _
  let G := (badSamples D A n (ε/3))ᶜ ∩ {sample | ∀ i, sample i∈X}
  have hdomain : MeasurableSet {sample : Fin n → RealInput d | ∀ i,sample i∈X} := by
    simp only [setOf_forall]
    exact MeasurableSet.iInter (fun i => hcompact.measurableSet.preimage (measurable_pi_apply i))
  have hprob := goodSamples_probability_log D A hA n hδ hcard (by
    apply (div_le_iff₀ (by positivity : 0<ε/3)).mp
    have he : (H+Real.log (1/δ))/(ε/3)=(3/ε)*(H+Real.log (1/δ)) := by ring
    rwa [he])
  have hG : MeasurableSet G := (measurable_badSamples D A hA n (ε/3)).compl.inter hdomain
  have hprobG : 1-δ≤(iidSamples D n).real G := by
    apply hprob.trans
    apply ENNReal.toReal_mono (measure_ne_top _ _)
    apply measure_mono_ae
    filter_upwards [iid_domain_ae D X hDX] with sample hs
    exact fun h => ⟨h,hs⟩
  refine ⟨G,hG,hprobG,?_⟩
  intro sample hs
  have hfit {N : ℕ} {w : Weights d N r}
      (hw : ∀ i, |output Real.tanh w (sample i)-f (sample i)|≤τ/2) :
      w∈trainingEvent Real.tanh f ρ sample := by
    intro i
    have hh := hw i
    change |output Real.tanh w (sample i)-f (sample i)|<5*τ/8
    linarith
  have hgap : ρ+2*a≤τ := by dsimp only [ρ,a]; linarith
  have hmix (N : ℕ) (hN : 0<N) (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
      (hQ : ∀ᵐ w ∂Q, weightedSquaredNorm w≤(K : ℝ) ∧
        ∀ i, |output Real.tanh w (sample i)-f (sample i)|≤τ/2) :
      risk Real.tanh D Q f τ≤ε/3 ∧ confidenceFailure Real.tanh D Q f τ≤ε := by
    have hr := regression_cover_posterior_risk D Q Real.tanh tanh_continuous f hf.measurable
      g X hDX sample hs.2 (u:=ε/3) (β:=0) (by positivity) hgap hs.1
      ∅ MeasurableSet.empty (by simp) (by
        filter_upwards [hQ] with w hw
        exact ⟨hfit hw.2,fun _ => exists_uniform_cover hd hN hK hR Real.tanh tanh_admissible
          w hw.1 X hX hball⟩)
    have hc := confidenceFailure_le_three_risk tanh_continuous D Q hf.measurable τ
    constructor <;> linarith
  constructor
  · intro N hN w he hw
    have hh := hmix N hN (Measure.dirac w) (by
      simp only [ae_dirac_eq]
      exact ⟨he,hw⟩)
    have hid : risk Real.tanh D (Measure.dirac w) f τ=
        D.real {x | τ < |output Real.tanh w x-f x|} := by
      unfold risk
      rw [Measure.prod_dirac]
      rw [map_measureReal_apply (by fun_prop) (measurable_jointErrorEvent tanh_continuous hf.measurable τ)]
      rfl
    rw [hid] at hh
    exact hh.1
  · intro N hN Q hprob hQ
    letI : IsProbabilityMeasure Q := hprob
    exact hmix N hN Q hQ

end NeuralGeneralization.BatchTwoContinuous
