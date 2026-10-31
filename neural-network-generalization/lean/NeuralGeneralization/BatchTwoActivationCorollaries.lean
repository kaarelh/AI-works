import NeuralGeneralization.BatchTwoActivationManuscriptMain
import NeuralGeneralization.BatchTwoActivationGelu
import NeuralGeneralization.ParityNetworkShallow
import NeuralGeneralization.PowerPriorScaling

/-! Missing manuscript consequences: the GELU complexity bound, the literal
power-prior reparametrization, and strict confidence for the sharp strong-prior
sample formula. These statements keep the actual parameter prior. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel BatchTwoMerging

/-- Padding the exact compiler gives the bounded-weight complexity claimed
in the activation paper, including the small-width cases. -/
theorem gelu_realizesAtComplexity {d C r : ℕ} (B : LayeredNorCircuit d C r) :
    realizesAtComplexity (r := r) gelu B.computes (max 4 (2*C)) := by
  obtain ⟨w,hw,hout⟩ := exact_same_depth_gelu_compilation B
  obtain ⟨v,hv,hvout⟩ := ParityNetwork.exists_padded_bounded
    (by norm_num : (0:ℝ) ≤ 4) (le_max_right 4 (2*C)) gelu w hw
  refine ⟨by omega, v, ?_, ?_⟩
  · intro x
    rw [hvout x, hout x]
    cases B.computes x <;> norm_num [labelReal]
  · intro i
    exact (hv i).trans (by exact_mod_cast (le_max_left 4 (2*C)))

/-- The exponent convention is exactly a member of the all-scale band. -/
theorem powerPrior_eq_activationBandPrior {d N r : ℕ} (hN : 0<N) (γ : ℝ) :
    powerPrior d N r γ =
      activationBandPrior d N r (Real.sqrt (N:ℝ)*powerStandardDeviation N γ) := by
  rw [activationBandPrior, powerPrior_eq_smallPrior_standardDeviation hN γ]
  congr 1
  have hs : Real.sqrt (N:ℝ) ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN))
  field_simp

theorem powerBandScale_bounds {N : ℕ} (hN : 0<N) {γ : ℝ} (hγ : 1≤γ) :
    0<Real.sqrt (N:ℝ)*powerStandardDeviation N γ ∧
      Real.sqrt (N:ℝ)*powerStandardDeviation N γ≤1 := by
  have hs := Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN : (0:ℝ)<N)
  have hp := powerStandardDeviation_pos hN γ
  have he := width_mul_powerStandardDeviation_sq_le_one hN hγ
  have hsq := Real.sq_sqrt (Nat.cast_nonneg N : (0:ℝ)≤N)
  constructor
  · exact mul_pos hs hp
  · nlinarith [sq_nonneg (Real.sqrt (N:ℝ)*powerStandardDeviation N γ-1)]

/-- Strict confidence for the sharp `B(B_*+1)` sample formula. Taking the
accuracy argument to be `ε/3` gives confidence failure at most `ε`. -/
theorem strong_prior_manuscript_confidence {d C r : ℕ} (hd : 1≤d)
    {φ : ℝ→ℝ} {ℓ : ℝ} (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 1≤ℓ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C)
    {ε : ℝ} (hε : 0<ε) (hε1 : ε<1) :
    ∃σ₀ : ℕ→ℝ, (∀N,0<σ₀ N) ∧
      ∀D : InputLaw d, ∀δ : ℝ, 0<δ → ∀n : ℕ,
      (2/ε)*(manuscriptLogCapacity d r ℓ (sharpTeacherBudget d C r+1)+
        Real.log (1/δ))≤(n:ℝ) →
      (∀N,C≤N→∀σ,0<σ→σ<σ₀ N→∀s : Fin n→Cube d,
        0<posteriorDenominator φ (1/2) (smallPrior d N r σ) f s) ∧
      1-δ≤sampleProbability D n (fun s=>∀N,C≤N→∀σ,0<σ→σ<σ₀ N→
        posteriorRisk D f (networkPosterior φ (1/2) (smallPrior d N r σ) f s)≤ε ∧
        ConcreteModel.confidenceFailure D f (networkPosterior φ (1/2) (smallPrior d N r σ) f s)≤3*ε) := by
  obtain ⟨σ₀,hσ₀,hmain⟩ := strong_prior_manuscript_learning hd hφ hℓ f hf hε hε1
  refine ⟨σ₀,hσ₀,?_⟩
  intro D δ hδ n hn
  obtain ⟨hpos,hprob⟩ := hmain D δ hδ n hn
  refine ⟨hpos,hprob.trans (sampleProbability_mono D n _ _ ?_)⟩
  intro s hs N hCN σ hσ hσlt
  have hr := hs N hCN σ hσ hσlt
  have hm := small_functionMass_pos (by omega : 0<d)
    (zeroLipschitzActivation_continuous hφ (by linarith : 0≤ℓ)) f hf hCN hσ
  have hc := network_confidenceFailure_le_three_risk φ (1/2) (smallPrior d N r σ) D f s hm
  exact ⟨hr,by linarith⟩

/-- The literal uniform manuscript budget also gives strict confidence,
simultaneously at every band scale and hence every exponent γ≥1. -/
theorem uniform_manuscript_confidence (r : ℕ) (ℓ : ℝ) (hℓ : 1≤ℓ) :
    ∃A : ℝ,0<A ∧ ∃m : ℕ,
    ∀P J₀ : ℝ→ℝ→ℝ,(∀d K,0≤d→0≤K→0≤J₀ d K)→
    ∀φ : ℝ→ℝ,zeroLipschitzActivation ℓ φ→
    ∀d : ℕ,1≤d→∀f : BooleanFunction d,∀C : ℕ,realizesAtComplexity (r:=r) φ f C→
    ∀D : InputLaw d,∀ε δ : ℝ,0<ε→ε<1→0<δ→δ<1→∀n : ℕ,
    (2/ε)*(manuscriptLogCapacity d r ℓ
      (manuscriptCombinedEnergy P (manuscriptEnlargedEndpoint r A m J₀) d C r ℓ ε)+
      Real.log (1/δ))≤(n:ℝ)→
    1-δ≤sampleProbability D n (fun s=>
      (∀N,C≤N→∀t,0<t→t≤1→
        posteriorRisk D f (networkPosterior φ (1/2) (activationBandPrior d N r t) f s)≤ε ∧
        ConcreteModel.confidenceFailure D f
          (networkPosterior φ (1/2) (activationBandPrior d N r t) f s)≤3*ε) ∧
      (∀N,C≤N→∀γ : ℝ,1≤γ→
        0<posteriorDenominator φ (1/2) (powerPrior d N r γ) f s ∧
        posteriorRisk D f (networkPosterior φ (1/2) (powerPrior d N r γ) f s)≤ε ∧
        ConcreteModel.confidenceFailure D f
          (networkPosterior φ (1/2) (powerPrior d N r γ) f s)≤3*ε)) := by
  obtain ⟨A,hA,m,hmain⟩ := uniform_manuscript_sample_bound r ℓ hℓ
  refine ⟨A,hA,m,?_⟩
  intro P J₀ hJ₀ φ hφ d hd f C hf D ε δ hε hε1 hδ hδ1 n hn
  obtain ⟨hpos,hprob⟩ := hmain P J₀ hJ₀ φ hφ d hd f C hf D ε δ hε hε1 hδ hδ1 n hn
  apply hprob.trans (sampleProbability_mono D n _ _ ?_)
  intro s hs
  have hgood : ∀N,C≤N→∀t,0<t→t≤1→
      posteriorRisk D f (networkPosterior φ (1/2) (activationBandPrior d N r t) f s)≤ε ∧
      ConcreteModel.confidenceFailure D f
        (networkPosterior φ (1/2) (activationBandPrior d N r t) f s)≤3*ε := by
    intro N hCN t ht ht1
    have hN : 0<N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
    have hm := small_functionMass_pos (by omega : 0<d)
      (zeroLipschitzActivation_continuous hφ (by linarith : 0≤ℓ)) f hf hCN
      (div_pos ht (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN)))
    have hc := network_confidenceFailure_le_three_risk φ (1/2)
      (activationBandPrior d N r t) D f s hm
    exact ⟨hs N hCN t ht ht1,by linarith [hs N hCN t ht ht1]⟩
  refine ⟨hgood,?_⟩
  intro N hCN γ hγ
  have hN : 0<N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  obtain ⟨ht,ht1⟩ := powerBandScale_bounds hN hγ
  rw [powerPrior_eq_activationBandPrior hN γ]
  exact ⟨hpos N hCN _ ht ht1 s,hgood N hCN _ ht ht1⟩

end NeuralGeneralization.BatchTwoActivation
