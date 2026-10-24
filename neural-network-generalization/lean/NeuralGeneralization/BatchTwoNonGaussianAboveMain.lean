import NeuralGeneralization.BatchTwoNonGaussianNetworkSpectralTail
import NeuralGeneralization.BatchTwoNonGaussianAllWidthStatistics
import NeuralGeneralization.BatchTwoNonGaussianAboveBudget

/-! The actual non-Gaussian γ>1 learning theorem, at every width at least the
bounded teacher complexity, with no remaining probabilistic premises. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian.NonGaussianAbove
open ConcreteModel NonGaussianMeanField

theorem learning (ν : CoordinateLaw) (γ : ℝ) (hγ : 1 < γ) :
    ∃ N₀ : ℕ, ∀ r a p : ℕ,
    (∀ d C, targetMassCost ν d C r ≤ (a : ℝ)*(1+(d : ℝ)+C)^p) →
    ∀ mγ pγ : ℕ, 2 ≤ (mγ : ℝ)*((γ-1)/2) → γ ≤ (pγ : ℝ) →
    ∀ {d C : ℕ}, 1 ≤ d → ∀ f : BooleanFunction d,
      realizesAtComplexity (r := r) Real.tanh f C →
    ∀ ε δ : ℝ, 0 < ε → ε < 1 → 0 < δ →
    ∀ n : ℕ,
      (6/ε)*((sampleBudget ν a p r N₀ mγ pγ d (C+⌈Real.log (1/ε)⌉₊) : ℝ)+
        Real.log (6/(ε*δ))) ≤ (n : ℝ) →
    ∀ N : ℕ, C ≤ N →
      (∀ s : Fin n → Cube d,
        0 < posteriorDenominator Real.tanh (1/2) (powerPrior ν d N r γ) f s) ∧
      ∀ D : InputLaw d, 1-δ ≤ sampleProbability D n (fun s =>
        posteriorRisk D f (networkPosterior Real.tanh (1/2) (powerPrior ν d N r γ) f s) ≤ ε/3 ∧
        ConcreteModel.confidenceFailure D f
          (networkPosterior Real.tanh (1/2) (powerPrior ν d N r γ) f s) ≤ ε) := by
  obtain ⟨N₀,hN₀⟩ := Filter.eventually_atTop.mp
    (eventually_spectralFunctions_complement_mass_tail ν γ hγ)
  refine ⟨N₀,?_⟩
  intro r a p hcost mγ pγ hmγ hpγ d C hd f hf ε δ hε hε1 hδ n hn
  let t := Real.log (1/ε)
  let S := C+⌈t⌉₊
  let K := energyBudget ν a p r d S
  let T := widthThreshold ν a p r N₀ mγ d S
  let P : ℝ := sampleBudget ν a p r N₀ mγ pγ d S
  let B := targetMassCost ν d C r
  have hcap : (spectralCapacity d r K : ℝ) ≤ P := by
    dsimp only [K,P]
    exact_mod_cast sampleBudget_ge_capacity ν a p r N₀ mγ pγ d S
  have hsmall : B*(T : ℝ)^γ ≤ P := sampleBudget_ge_smallWidth ν a p r hcost N₀ mγ pγ d C t γ hpγ
  apply all_width_learning_reduction ν γ (by omega) tanh_continuous f hf T
    (spectralFunctions d r K Real.tanh) (spectralCapacity d r K) (B*(T : ℝ)^γ) P
    (spectralFunctions_card_le_exp d r K Real.tanh tanh_admissible) hcap hsmall
    ε δ hε hε1 hδ _ _ n _
  · intro N hCN hTN
    have hN : 0 < N := (Nat.succ_le_iff.mp hf.1).trans_le hCN
    have hKN : (K : ℝ) ≤ (N : ℝ)^2 :=
      (widthThreshold_energy_sq ν a p r N₀ mγ d S).trans
        (pow_le_pow_left₀ (Nat.cast_nonneg T) (by exact_mod_cast hTN) 2)
    have ha := matrixTruncationScale_le_radius hN γ hγ r K mγ hmγ
      ((widthThreshold_ge_truncation ν a p r N₀ mγ d S).trans hTN)
    have htail := hN₀ N ((widthThreshold_ge_start ν a p r N₀ mγ d S).trans hTN)
      d r K hd (energyBudget_ge_first ν a p r d S) hKN ha
    have hmass := powerPrior_target_mass_all_width ν (by omega) f hf hCN hγ.le
    apply exponential_tail_ratio_prefactor_le _ _ (2*((r : ℝ)+1)) B
      ((K : ℝ)/(64*(tailScale ν : ℝ))) ((N : ℝ)^γ) (ε/6) _
      (by simpa only [B,neg_mul] using hmass)
      (by have hh : (0 : ℝ) ≤ r := Nat.cast_nonneg r; linarith)
      (one_le_width_power hN hγ.le) (by linarith) (by linarith) _
    · have he : -((K : ℝ)/(64*(tailScale ν : ℝ)))*(N : ℝ)^γ=
          -(K : ℝ)*(N : ℝ)^γ/(64*(tailScale ν : ℝ)) := by ring
      rw [he]
      exact htail
    · have he : 2*((r : ℝ)+1)/(ε/6)=12*((r : ℝ)+1)/ε := by ring
      rw [he]
      exact energyBudget_rate_gap ν a p r hcost d C ε hε
  · intro N hCN hNT
    apply le_trans _ (powerPrior_target_mass_all_width ν (by omega) f hf hCN hγ.le)
    apply Real.exp_le_exp.mpr
    simp only [neg_mul,neg_le_neg_iff]
    apply mul_le_mul_of_nonneg_left _ (targetMassCost_nonneg ν d C r)
    exact Real.rpow_le_rpow (Nat.cast_nonneg N) (by exact_mod_cast hNT.le) (by linarith)
  · have he : (P+Real.log (1/(δ*(ε/6))))/(ε/6)=
        (6/ε)*(P+Real.log (6/(ε*δ))) := by
      have harg : 1/(δ*(ε/6))=6/(ε*δ) := by field_simp
      rw [harg]
      ring
    rw [he]
    exact hn

/-- Exact γ>1 specialization of the paper's finite-scale main proposition. -/
theorem aboveMeanField :
    ∀ r : ℕ, ∀ ν : CoordinateLaw, ∀ γ : ℝ, 1 < γ →
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ d : ℕ, 1 ≤ d → ∀ f : BooleanFunction d, ∀ C : ℕ,
      isComplexity (r := r) Real.tanh f C →
    ∀ N : ℕ, C ≤ N → ∀ D : InputLaw d,
    ∀ ε δ : ℝ, 0 < ε → ε < 1 → 0 < δ → δ < 1 →
    ∀ n : ℕ,
      (6/ε)*(MainStatements.polynomialEnvelope A m d C (Real.log (1/ε))+
        Real.log (6/(ε*δ))) ≤ (n : ℝ) →
      (∀ s : Fin n → Cube d,
        0 < posteriorDenominator Real.tanh (1/2) (powerPrior ν d N r γ) f s) ∧
      1-δ ≤ sampleProbability D n (fun s =>
        posteriorRisk D f (networkPosterior Real.tanh (1/2) (powerPrior ν d N r γ) f s) ≤ ε/3 ∧
        ConcreteModel.confidenceFailure D f
          (networkPosterior Real.tanh (1/2) (powerPrior ν d N r γ) f s) ≤ ε) := by
  intro r ν γ hγ
  obtain ⟨N₀,hlearn⟩ := learning ν γ hγ
  obtain ⟨A₀,hA₀,p,hpoly⟩ := targetMassCost_polynomial_envelope ν r
  let a := ⌈A₀⌉₊
  have hcost : ∀ d C, targetMassCost ν d C r ≤ (a : ℝ)*(1+(d : ℝ)+C)^p := by
    intro d C
    exact (hpoly d C).trans (mul_le_mul_of_nonneg_right (Nat.le_ceil A₀) (by positivity))
  obtain ⟨mγ,hmγ⟩ := exists_truncation_polynomial_degree γ hγ
  let pγ := ⌈γ⌉₊
  obtain ⟨A,hA,m,hbudget⟩ := sampleBudget_real_envelope ν a p r N₀ mγ pγ
  refine ⟨A,hA,m,?_⟩
  intro d hd f C hc N hCN D ε δ hε hε1 hδ _ n hn
  have ht : 0 ≤ Real.log (1/ε) := Real.log_nonneg ((one_le_div hε).mpr hε1.le)
  have henv := hbudget d C (Real.log (1/ε)) ht
  have hsize : (6/ε)*((sampleBudget ν a p r N₀ mγ pγ d (C+⌈Real.log (1/ε)⌉₊) : ℝ)+
      Real.log (6/(ε*δ))) ≤ (n : ℝ) := by
    apply le_trans _ hn
    exact mul_le_mul_of_nonneg_left (add_le_add henv le_rfl) (by positivity)
  obtain ⟨hden,hprob⟩ := hlearn r a p hcost mγ pγ hmγ (Nat.le_ceil γ) hd f hc.1
    ε δ hε hε1 hδ n hsize N hCN
  exact ⟨hden,hprob D⟩

end NeuralGeneralization.BatchTwoNonGaussian.NonGaussianAbove
