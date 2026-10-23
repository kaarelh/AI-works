import NeuralGeneralization.BatchTwoNonGaussianMeanFieldLearningBudget

/-! The actual non-Gaussian mean-field learning theorem at every width above
teacher complexity, with the paper's posterior and confidence criterion. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
open ConcreteModel LearningBudget

theorem learning (ν : CoordinateLaw) (r a p : ℕ)
    (hcost : ∀ d C, targetMassCost ν d C r ≤ (a : ℝ)*(1+(d : ℝ)+C)^p)
    {d C : ℕ} (hd : 1 ≤ d) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r := r) Real.tanh f C)
    (ε δ : ℝ) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (n : ℕ)
    (hn : (6/ε)*((sampleBudget ν a p r d (C+⌈Real.log (1/ε)⌉₊) : ℝ)+
      Real.log (6/(ε*δ))) ≤ (n : ℝ)) :
    ∀ N : ℕ, C ≤ N →
      (∀ s : Fin n → Cube d,
        0 < posteriorDenominator Real.tanh (1/2) (powerPrior ν d N r 1) f s) ∧
      ∀ D : InputLaw d, 1-δ ≤ sampleProbability D n (fun s =>
        posteriorRisk D f (networkPosterior Real.tanh (1/2) (powerPrior ν d N r 1) f s) ≤ ε/3 ∧
        ConcreteModel.confidenceFailure D f (networkPosterior Real.tanh (1/2) (powerPrior ν d N r 1) f s) ≤ ε) := by
  let t := Real.log (1/ε)
  let S := C+⌈t⌉₊
  let K := energyBudget ν a p r d S
  let T := learnerThreshold ν a p r d S
  let P : ℝ := sampleBudget ν a p r d S
  let B := targetMassCost ν d C r
  have hK : 8*tailScale ν ≤ K := energyBudget_ge ν a p r d S
  have hcap : (capacity ν d r K : ℝ) ≤ P := by
    dsimp only [K, P]
    exact_mod_cast sampleBudget_ge_capacity ν a p r d S
  have hsmall : B*(T : ℝ) ≤ P := sampleBudget_ge_smallWidth ν a p r hcost d C t
  apply all_width_learning_reduction ν (by omega) tanh_continuous f hf T
    (functions ν d r K) (capacity ν d r K) (B*(T : ℝ)) P (functions_card_le_exp ν d r K)
    hcap hsmall ε δ hε hε1 hδ _ _ n _
  · intro N hCN hTN
    have hN : 0 < N := (Nat.succ_le_iff.mp hf.1).trans_le hCN
    have htail := aggregate_tail ν r d hd K hK N hTN
    have hmass := powerPrior_target_mass_all_width ν (by omega) f hf hCN (γ := 1) le_rfl
    simp only [Real.rpow_one] at hmass
    apply NeuralGeneralization.exponential_tail_ratio_prefactor_le _ _ ((r : ℝ)+2) B
      ((K : ℝ)/(8*(tailScale ν : ℝ))) (N : ℝ) (ε/6) _
      (by simpa only [B,neg_mul] using hmass)
      (by have hr : (0 : ℝ) ≤ r := Nat.cast_nonneg r; linarith)
      (by exact_mod_cast hN) (by linarith) (by linarith) _
    · have he : -((K : ℝ)/(8*(tailScale ν : ℝ)))*(N : ℝ)=
          -(N : ℝ)*(K : ℝ)/(8*(tailScale ν : ℝ)) := by ring
      rw [he]
      exact htail
    · have he : ((r : ℝ)+2)/(ε/6)=6*((r : ℝ)+2)/ε := by ring
      rw [he]
      exact energyBudget_rate_gap ν a p r hcost d C ε hε
  · intro N hCN hNT
    have hmass := powerPrior_target_mass_all_width ν (by omega) f hf hCN (γ := 1) le_rfl
    simp only [Real.rpow_one] at hmass
    apply le_trans _ hmass
    apply Real.exp_le_exp.mpr
    apply neg_le_neg
    exact mul_le_mul_of_nonneg_left (by exact_mod_cast hNT.le) (targetMassCost_nonneg ν d C r)
  · have he : (P+Real.log (1/(δ*(ε/6))))/(ε/6)=
        (6/ε)*(P+Real.log (6/(ε*δ))) := by
      have harg : 1/(δ*(ε/6))=6/(ε*δ) := by field_simp
      rw [harg]
      ring
    rw [he]
    exact hn

/-- Exact γ=1 specialization of the paper's finite-scale main statement. -/
theorem meanField :
    ∀ r : ℕ, ∀ ν : CoordinateLaw, ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ d : ℕ, 1 ≤ d → ∀ f : BooleanFunction d, ∀ C : ℕ,
      isComplexity (r := r) Real.tanh f C →
    ∀ N : ℕ, C ≤ N → ∀ D : InputLaw d,
    ∀ ε δ : ℝ, 0 < ε → ε < 1 → 0 < δ → δ < 1 →
    ∀ n : ℕ,
      (6/ε)*(MainStatements.polynomialEnvelope A m d C (Real.log (1/ε))+
        Real.log (6/(ε*δ))) ≤ (n : ℝ) →
      (∀ s : Fin n → Cube d,
        0 < posteriorDenominator Real.tanh (1/2) (powerPrior ν d N r 1) f s) ∧
      1-δ ≤ sampleProbability D n (fun s =>
        posteriorRisk D f (networkPosterior Real.tanh (1/2) (powerPrior ν d N r 1) f s) ≤ ε/3 ∧
        ConcreteModel.confidenceFailure D f
          (networkPosterior Real.tanh (1/2) (powerPrior ν d N r 1) f s) ≤ ε) := by
  intro r ν
  obtain ⟨A₀,hA₀,p,hpoly⟩ := targetMassCost_polynomial_envelope ν r
  let a := ⌈A₀⌉₊
  have hcost : ∀ d C, targetMassCost ν d C r ≤ (a : ℝ)*(1+(d : ℝ)+C)^p := by
    intro d C
    exact (hpoly d C).trans (mul_le_mul_of_nonneg_right (Nat.le_ceil A₀) (by positivity))
  obtain ⟨A,hA,m,hbudget⟩ := sampleBudget_real_envelope ν a p r
  refine ⟨A,hA,m,?_⟩
  intro d hd f C hc N hCN D ε δ hε hε1 hδ _ n hn
  have ht : 0 ≤ Real.log (1/ε) := Real.log_nonneg ((one_le_div hε).mpr hε1.le)
  have henv := hbudget d C (Real.log (1/ε)) ht
  have hsize : (6/ε)*((sampleBudget ν a p r d (C+⌈Real.log (1/ε)⌉₊) : ℝ)+
      Real.log (6/(ε*δ))) ≤ (n : ℝ) := by
    apply le_trans _ hn
    exact mul_le_mul_of_nonneg_left (add_le_add henv le_rfl) (by positivity)
  obtain ⟨hden,hprob⟩ := learning ν r a p hcost hd f hc.1 ε δ hε hε1 hδ n hsize N hCN
  exact ⟨hden,hprob D⟩

end NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
