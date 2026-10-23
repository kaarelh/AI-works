import NeuralGeneralization.BatchTwoContinuousFiniteMeanFieldLearningBudget

/-! Actual all-width continuous regression at the mean-field exponent. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteMeanField
open ConcreteModel CompressionSampling BatchTwoNonGaussian NonGaussianMeanField

theorem learning (ν : CoordinateLaw) :
    ∀ r a p d C S : ℕ,
    1≤d → 1≤C → ∀ B ρ τ ε δ : ℝ, 0≤B → 0<ρ → ρ<τ → 0<ε → ε<1 → 0<δ →
    inverseGap ρ τ≤(S : ℝ) → Real.log (1/ε)≤(S : ℝ) →
    FiniteTarget.targetCost ν d C r B ρ≤(targetBudget a p d S : ℝ) →
    ∀ teacher : Weights d C r, boundedWeights B teacher →
    ∀ X : Set (RealInput d), admissibleDomain X →
    ∀ N : ℕ, C≤N → ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ=0 →
    ∀ n : ℕ,
    (6/ε)*((sampleBudget ν a p r d S : ℝ)+Real.log (6/(ε*δ)))≤(n : ℝ) →
    1-δ≤(iidSamples D n).real {s |
      let Q := posterior Real.tanh (powerPrior ν d N r 1) (output Real.tanh teacher) ρ s
      risk Real.tanh D Q (output Real.tanh teacher) τ≤ε/3 ∧
      confidenceFailure Real.tanh D Q (output Real.tanh teacher) τ≤ε} := by
  classical
  intro r a p d C S hd hC B ρ τ ε δ hB hρ hgap hε hε1 hδ hu ht hcost
    teacher hteacher X hX N hCN D hD hDX n hn
  letI : IsProbabilityMeasure D := hD
  let K := energyBudget ν a p r d S
  let R := accuracyBudget S
  let T := thresholdBudget ν a p r d S
  let J := smallEnergyBudget ν a p r d S
  let μ := powerPrior ν d N r 1
  let f := output Real.tanh teacher
  let V := uniformTube (N:=N) (r:=r) Real.tanh f X ρ
  let cost := FiniteTarget.targetCost ν d C r B ρ
  have hN : 0<N := (by omega : 0<C).trans_le hCN
  have hK : 1≤K := energyBudget_pos ν a p r d S
  have hR : 1≤R := by dsimp [R,accuracyBudget]; omega
  have hmass : Real.exp (-cost*(N : ℝ)^(1 : ℝ))≤μ.real V := by
    simpa only [neg_mul] using FiniteTarget.powerPrior_uniformTube_mass ν
      (by omega) (by omega) hCN hB hρ (by norm_num : (1 : ℝ)≤1) teacher hteacher X hX.2.1 hX.2.2
  have hpos : 0<μ.real V := (Real.exp_pos _).trans_le hmass
  have hrate : cost+Real.log (24*((r : ℝ)+1)/ε)≤(K : ℝ)/(64*(tailScale ν : ℝ)) :=
    energyBudget_rate_gap ν a p r d S hcost hε ht
  have hacc : ρ+2*(2/(3*(R : ℝ)))≤τ := accuracyBudget_gap hgap hu
  have hlog : Real.log (1/δ)≤Real.log (6/(ε*δ)) := by
    apply Real.log_le_log (one_div_pos.mpr hδ)
    apply (div_le_div_iff₀ hδ (mul_pos hε hδ)).mpr
    nlinarith
  have hsize : (sampleBudget ν a p r d S : ℝ)+Real.log (1/δ)≤(n : ℝ)*(ε/6) := by
    have he : (6/ε)*((sampleBudget ν a p r d S : ℝ)+Real.log (6/(ε*δ)))=
      ((sampleBudget ν a p r d S : ℝ)+Real.log (6/(ε*δ)))/(ε/6) := by ring
    rw [he] at hn
    have hh := (div_le_iff₀ (by positivity : 0<ε/6)).mp hn
    linarith
  have hsimplify : ε/6+ε/6=ε/3 := by ring
  have hsimplify' : 3*(ε/3)=ε := by ring
  by_cases hTN : T≤N
  · obtain ⟨xs,hxs,hnear⟩ := FiniteQuery.exists_cube_input_net d
      (FiniteQuery.inputMesh ν r K R) (FiniteQuery.inputMesh_pos ν r hK hR) X hX.1 hX.2.2
    have hxsball : ∀ y, ∑ j,xs y j^2≤1 := fun y => hX.2.2 _ (hxs y)
    have htail := cover_complement_tail ν (by omega) hR
      (energyBudget_ge_first ν a p r d S) xs hxsball X hnear hTN
    have hrate' : cost+Real.log (18*((r : ℝ)+1)/ε)≤(K : ℝ)/(8*(tailScale ν : ℝ)) := by
      have hl : Real.log (18*((r : ℝ)+1)/ε)≤Real.log (24*((r : ℝ)+1)/ε) := by
        apply Real.log_le_log (by positivity)
        apply div_le_div_of_nonneg_right _ hε.le
        nlinarith [Nat.cast_nonneg r (α := ℝ)]
      have hden : (0 : ℝ)<8*(tailScale ν : ℝ) := by have := tailScale_ge_one ν; positivity
      have hh := div_le_div_of_nonneg_left (Nat.cast_nonneg K) hden
        (show 8*(tailScale ν : ℝ)≤64*(tailScale ν : ℝ) by have := tailScale_ge_one ν; linarith)
      linarith
    have hratio : μ.real (coverEvent ν d N r K R xs X)ᶜ/μ.real V≤ε/6 := by
      apply exponential_tail_ratio_prefactor_le _ _ (3*((r : ℝ)+1)) cost
        ((K : ℝ)/(8*(tailScale ν : ℝ))) ((N : ℝ)^(1 : ℝ)) (ε/6) _ hmass
        (by linarith [Nat.cast_nonneg r (α := ℝ)]) (one_le_width_power hN (by norm_num))
        (by positivity) (by linarith) _
      · convert htail using 1 <;> dsimp only [K] <;> simp only [Real.rpow_one] <;> ring
      · have he : 3*((r : ℝ)+1)/(ε/6)=18*((r : ℝ)+1)/ε := by ring
        rwa [he]
    letI : Nonempty (Code ν d r K R) := ⟨fun _ => ⟨0,by simp⟩⟩
    have hlearn := regression_learning_of_cover μ Real.tanh tanh_continuous f
      (continuous_output_input tanh_continuous teacher) X
      (codeOutput ν d r K R xs)
      (fun q => FiniteQuery.measurable_extensionOutput xs _ q)
      (coverEvent ν d N r K R xs X)
      (isClosed_coverEvent ν d N r K R xs X).measurableSet
      (a:=2/(3*(R : ℝ))) (u:=ε/6) (β:=ε/6) (by positivity) hacc
      (fun _ hw => hw) (code_card_le_exp ν d r K R) hpos hratio
      D hDX hδ n (by
        apply le_trans _ hsize
        gcongr
        exact_mod_cast (show capacity ν d r K R≤sampleBudget ν a p r d S by
          dsimp only [sampleBudget,K,R]; omega))
    simpa only [hsimplify',hsimplify] using hlearn
  · have hNT : N≤T := (lt_of_not_ge hTN).le
    have hJ : 1≤J := by dsimp [J,smallEnergyBudget]; have := hK; dsimp [K] at this; omega
    have hq := tailScale_ge_variance ν
    have hq0 := tailScale_ge_one ν
    have hv := subGaussianVariance_pos ν
    have hJK : K≤J := by dsimp [J,smallEnergyBudget,K]; omega
    have hb : 8*subGaussianVariance ν*((d : ℝ)+2+(r : ℝ)*T)≤(J : ℝ) := by
      have hh := mul_le_mul_of_nonneg_right hq
        (show 0≤8*((d : ℝ)+2+(r : ℝ)*T) by positivity)
      dsimp only [J,smallEnergyBudget]
      push_cast
      dsimp only [T] at hh
      nlinarith [Nat.cast_nonneg (energyBudget ν a p r d S) (α := ℝ)]
    have heTail := Above.powerPrior_energy_tail ν (by omega) hN hNT 1 (J : ℝ) (by norm_num : (1 : ℝ)≤1) hb
    have hrate' : cost+Real.log (1/(ε/6))≤(J : ℝ)/(8*subGaussianVariance ν) := by
      have hl : Real.log (1/(ε/6))≤Real.log (24*((r : ℝ)+1)/ε) := by
        apply Real.log_le_log (by positivity)
        apply (div_le_div_iff₀ (by positivity : 0<ε/6) hε).mpr
        have := Nat.cast_nonneg r (α := ℝ)
        nlinarith
      have hden : 8*subGaussianVariance ν≤64*(tailScale ν : ℝ) := by linarith
      have hh := div_le_div_of_nonneg_left (Nat.cast_nonneg K) (by positivity : 0<8*subGaussianVariance ν) hden
      have hj : (K : ℝ)≤J := by exact_mod_cast hJK
      have hh' := div_le_div_of_nonneg_right hj (by positivity : 0≤8*subGaussianVariance ν)
      linarith
    have hratio : μ.real {w | (J : ℝ)<weightedSquaredNorm w}/μ.real V≤ε/6 :=
      exponential_tail_ratio_le _ _ cost ((J : ℝ)/(8*subGaussianVariance ν))
        ((N : ℝ)^(1 : ℝ)) (ε/6) heTail hmass (one_le_width_power hN (by norm_num : (1 : ℝ)≤1))
        (by positivity) (by linarith) hrate'
    have hacc' : ρ+2*(1/(3*(R : ℝ)))≤τ := by
      have hp : (0 : ℝ)<R := by exact_mod_cast hR
      have hh : 1/(3*(R : ℝ))≤2/(3*(R : ℝ)) := div_le_div_of_nonneg_right (by norm_num) (by positivity)
      linarith
    have hlearn := regression_learning_of_tail hd hN hJ hR μ Real.tanh tanh_admissible tanh_continuous
      f (continuous_output_input tanh_continuous teacher) X hX.1 hX.2.1 hX.2.2
      (u:=ε/6) (β:=ε/6) (by positivity) hacc' hpos hratio D hDX hδ n (by
        apply le_trans _ hsize
        gcongr
        exact_mod_cast (show coverEntropy d r J R≤sampleBudget ν a p r d S by
          dsimp only [sampleBudget,J,R]; omega))
    simpa only [hsimplify',hsimplify] using hlearn

end NeuralGeneralization.BatchTwoContinuous.FiniteMeanField
