import NeuralGeneralization.BatchTwoOnlineNetwork
import NeuralGeneralization.BatchTwoOnlineBounds
import NeuralGeneralization.MeanFieldAggregate
import NeuralGeneralization.MeanFieldLearningBudget
import NeuralGeneralization.AboveMeanFieldBudgetBounds
import NeuralGeneralization.NetworkSpectralTail
import NeuralGeneralization.ExponentialTailRatio

/-!
# Actual all-width Gaussian online-learning theorems

The relevant classes, raw Gaussian target masses and aggregate exceptional
masses below are supplied by proved neural structural theorems. There are
no capacity, Gaussian-tail or posterior-risk assumptions in the endpoints.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal Topology
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling ConcreteModel MeasureTheory Filter

def NetworkRandomOrderBounds {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d) (P : ℝ) : Prop :=
  RandomOrderBounds (functionMass φ a μ)
    (fun g i => g (cubeEnumeration d i)=f (cubeEnumeration d i)) P
    (1/(Fintype.card (Cube d) : ℝ))

lemma cube_card_eq (d : ℕ) : Fintype.card (Cube d)=2^d := by simp [Cube]

lemma cube_card_ge_two (d : ℕ) (hd : 1 ≤ d) : 2 ≤ Fintype.card (Cube d) := by
  rw [cube_card_eq]
  calc
    2 = (2 : ℕ)^1 := by norm_num
    _ ≤ 2^d := Nat.pow_le_pow_right (by omega) hd

lemma exp_neg_dimension_le_cube_inverse (d : ℕ) :
    Real.exp (-(d : ℝ)) ≤ 1/(Fintype.card (Cube d) : ℝ) := by
  have hm : (0 : ℝ) < Fintype.card (Cube d) := by exact_mod_cast Fintype.card_pos
  apply (le_div_iff₀ hm).mpr
  have htwo : (2 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
  have hpow := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 2) htwo d
  have hexp : (Real.exp (1 : ℝ))^d=Real.exp (d : ℝ) := by
    rw [← Real.exp_nat_mul]
    simp
  have hcard : (Fintype.card (Cube d) : ℝ) ≤ Real.exp (d : ℝ) := by
    rw [cube_card_eq, Nat.cast_pow, Nat.cast_ofNat]
    simpa only [hexp] using hpow
  calc
    _ ≤ Real.exp (-(d : ℝ))*Real.exp (d : ℝ) :=
      mul_le_mul_of_nonneg_left hcard (Real.exp_pos _).le
    _ = 1 := by rw [← Real.exp_add, neg_add_cancel, Real.exp_zero]

lemma exp_dimension_accuracy_log (d : ℕ) :
    Real.log (1/Real.exp (-(d : ℝ))) = d := by
  rw [one_div, ← Real.exp_neg, neg_neg, Real.log_exp]

lemma network_bounds_of_prior_mass {d N r : ℕ} (hd : 1 ≤ d)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (μ : Measure (Weights d N r)) [IsProbabilityMeasure μ]
    (f : BooleanFunction d) (P : ℝ) (hP : 0 ≤ P)
    (hmass : Real.exp (-P) ≤ functionMass φ (1/2) μ f) :
    NetworkRandomOrderBounds φ (1/2) μ f P := by
  apply bounds_of_prior_mass (cube_card_ge_two d hd) _ (functionMass_nonneg φ (1/2) μ)
    (functionMass_sum_le_one hφ (by norm_num) μ) _ f (fun _ => rfl) P _ hP (by positivity) hmass

/-- Strong-prior theorem with the actual expectation and both high-probability
online conclusions. One fixed sufficiently small variance covers the whole run. -/
theorem strongPrior_randomOrder_bounds {d C N r : ℕ}
    (hd : 1 ≤ d) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) :
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      NetworkRandomOrderBounds φ (1/2) (smallPrior d N r σ) f (strongCapacity d r C) := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hcontinuous := admissibleActivation_continuous hφ
  have hlim := network_highEnergy_tail_ratio_tendsto_zero (by omega) hN hcontinuous f
    (margin_witness_at_larger_width φ f hf hCN)
  let β : ℝ := 1/Fintype.card (Cube d)
  have hβ : 0 < β := by dsimp [β]; positivity
  have he := hlim.eventually (gt_mem_nhds hβ)
  obtain ⟨σ₀,hσ₀,hsub⟩ := mem_nhdsGT_iff_exists_Ioo_subset.mp he
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt
  have htail := hsub ⟨hσ,hσlt⟩
  change (∑ g∈Finset.univ \ lowEnergyFunctions (N := N) (r := r) φ f,
      functionMass φ (1/2) (smallPrior d N r σ) g)/functionMass φ (1/2) (smallPrior d N r σ) f < β at htail
  exact bounds_of_relevant_class Fintype.card_pos _ (functionMass_nonneg φ (1/2) _) _ f
    (fun _ => rfl) (small_functionMass_pos (by omega) hcontinuous f hf hCN hσ)
    (lowEnergyFunctions (N := N) (r := r) φ f) _ β (by positivity) hβ.le
    (lowEnergyFunctions_card_le_exp hd hφ f hf hCN) htail.le

/-- Mean-field tanh, every width above teacher complexity, with a single
explicit polynomial structural budget independent of width. -/
theorem meanField_randomOrder_bounds {d C N r : ℕ}
    (hd : 1 ≤ d) (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) Real.tanh f C)
    (hCN : C ≤ N) :
    NetworkRandomOrderBounds Real.tanh (1/2) (powerPrior d N r 1) f
      (MeanFieldLearningBudget.sampleBudget r d (C+d)) := by
  let ε := Real.exp (-(d : ℝ))
  let S := C+d
  let K := MeanFieldLearningBudget.energyBudget r d S
  let T := MeanFieldLearningBudget.widthThreshold r d S
  let P := MeanFieldLearningBudget.sampleBudget r d S
  let B := cylinderPolynomialCoefficient r*(1+(d : ℝ)+C)^cylinderPolynomialDegree r
  have hε : 0 < ε := Real.exp_pos _
  have hε1 : ε ≤ 1 := Real.exp_le_one_iff.mpr (neg_nonpos.mpr (Nat.cast_nonneg d))
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hmass := meanField_target_mass_polynomial (by omega) Real.tanh tanh_admissible f hf hCN
  by_cases hTN : T ≤ N
  · have htail := MeanFieldAggregate.aggregate_tail r d hd K
      (MeanFieldLearningBudget.energyBudget_ge_eight r d S) N hTN
    have hgap := MeanFieldLearningBudget.energyBudget_rate_gap r d C ε hε
    have he : C+⌈Real.log (1/ε)⌉₊=S := by
      dsimp [ε,S]
      rw [exp_dimension_accuracy_log, Nat.ceil_natCast]
    rw [he] at hgap
    have hratio : (∑ g∈Finset.univ \ MeanFieldFunctionClass.functions d r K,
        functionMass Real.tanh (1/2) (powerPrior d N r 1) g)/
        functionMass Real.tanh (1/2) (powerPrior d N r 1) f ≤ ε/6 := by
      apply exponential_tail_ratio_prefactor_le _ _ ((r : ℝ)+2) B ((K : ℝ)/8) N (ε/6)
        (by convert htail using 1 <;> congr 2 <;> ring)
        (by simpa only [B, neg_mul] using hmass)
        (by have := Nat.cast_nonneg r (α := ℝ); linarith) (by exact_mod_cast hN)
        (by positivity) (by linarith) _
      have harg : ((r : ℝ)+2)/(ε/6)=6*((r : ℝ)+2)/ε := by ring
      simpa only [harg] using hgap
    apply bounds_of_relevant_class Fintype.card_pos _ (functionMass_nonneg Real.tanh (1/2) _) _ f
      (fun _ => rfl) ((Real.exp_pos _).trans_le hmass) (MeanFieldFunctionClass.functions d r K)
      (P : ℝ) _ (by positivity) (by positivity)
    · apply (MeanFieldFunctionClass.functions_card_le_exp d r K).trans
      apply Real.exp_le_exp.mpr
      exact_mod_cast MeanFieldLearningBudget.sampleBudget_ge_capacity r d S
    · apply hratio.trans
      apply le_trans (show ε/6 ≤ ε by linarith) (exp_neg_dimension_le_cube_inverse d)
  · have hsmall := powerPrior_target_mass_below_threshold (by omega) Real.tanh tanh_admissible
      f hf hCN (le_of_not_ge hTN) (γ := 1) le_rfl
    have hbudget := MeanFieldLearningBudget.sampleBudget_ge_actual_smallWidth r d C (d : ℝ)
    simp only [Nat.ceil_natCast] at hbudget
    apply network_bounds_of_prior_mass hd tanh_continuous _ f (P : ℝ) (by positivity)
    apply le_trans _ hsmall
    apply Real.exp_le_exp.mpr
    simpa only [Real.rpow_one] using neg_le_neg hbudget

/-- The fixed-depth mean-field structural budget is polynomial in dimension
and teacher complexity, including the exponentially small relative tail. -/
theorem meanField_online_budget_polynomial (r : ℕ) :
    PolynomialGrowth2 (fun d C => MeanFieldLearningBudget.sampleBudget r d (C+d)) :=
  (MeanFieldLearningBudget.sampleBudget_polynomialGrowth r).compositionRight
    (PolynomialGrowth2.right.add PolynomialGrowth2.left)

/-- Every fixed above-mean-field exponent admits one polynomial online budget
uniform over all learner widths. The large-width branch uses the actual total
exceptional Gaussian mass; the small-width branch uses actual target mass. -/
theorem aboveMeanField_randomOrder_bounds (r : ℕ) (γ : ℝ) (hγ : 1 < γ) :
    ∃ P : ℕ → ℕ → ℕ, PolynomialGrowth2 P ∧
      ∀ d C N : ℕ, 1 ≤ d → ∀ φ : ℝ → ℝ, admissibleActivation φ →
        ∀ f : BooleanFunction d, realizesAtComplexity (r := r) φ f C → C ≤ N →
          NetworkRandomOrderBounds φ (1/2) (powerPrior d N r γ) f (P d C) := by
  obtain ⟨N₀,hN₀⟩ := Filter.eventually_atTop.mp (eventually_spectralFunctions_complement_mass_tail γ hγ)
  obtain ⟨q,hq⟩ := exists_truncation_polynomial_degree γ hγ
  let p : ℕ := ⌈γ⌉₊
  let P := fun d C => aboveSampleBudget r N₀ q p d (C+d)
  refine ⟨P, (aboveSampleBudget_polynomialGrowth r N₀ q p).compositionRight
    (PolynomialGrowth2.right.add PolynomialGrowth2.left), ?_⟩
  intro d C N hd φ hφ f hf hCN
  let ε := Real.exp (-(d : ℝ))
  let S := C+d
  let K := aboveEnergyBudget r d S
  let T := aboveWidthThreshold r N₀ q d S
  let B := cylinderPolynomialCoefficient r*(1+(d : ℝ)+C)^cylinderPolynomialDegree r
  have hε : 0 < ε := Real.exp_pos _
  have hε1 : ε ≤ 1 := Real.exp_le_one_iff.mpr (neg_nonpos.mpr (Nat.cast_nonneg d))
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hmass := powerPrior_target_mass_polynomial (by omega) φ hφ f hf hCN hγ.le
  by_cases hTN : T ≤ N
  · have hKN : (K : ℝ) ≤ (N : ℝ)^2 :=
      (aboveWidthThreshold_energy_sq r N₀ q d S).trans
        (pow_le_pow_left₀ (Nat.cast_nonneg T) (by exact_mod_cast hTN) 2)
    have htrunc := matrixTruncationScale_le_radius hN γ hγ r K q hq
      ((aboveWidthThreshold_ge_truncation r N₀ q d S).trans hTN)
    have htail := hN₀ N ((aboveWidthThreshold_ge_start r N₀ q d S).trans hTN)
      d r K hd (aboveEnergyBudget_ge_first r d S) hKN htrunc φ hφ
    have hgap := aboveEnergyBudget_rate_gap r d C ε hε
    have he : C+⌈Real.log (1/ε)⌉₊=S := by
      dsimp [ε,S]
      rw [exp_dimension_accuracy_log, Nat.ceil_natCast]
    rw [he] at hgap
    have hratio : (∑ g∈Finset.univ \ spectralFunctions d r K φ,
        functionMass φ (1/2) (powerPrior d N r γ) g)/
        functionMass φ (1/2) (powerPrior d N r γ) f ≤ ε/2 := by
      apply exponential_tail_ratio_prefactor_le _ _ (2*((r : ℝ)+1)) B ((K : ℝ)/64)
        ((N : ℝ)^γ) (ε/2)
        (by convert htail using 1 <;> congr 2 <;> ring)
        (by simpa only [B, neg_mul] using hmass)
        (by have := Nat.cast_nonneg r (α := ℝ); linarith)
        (one_le_width_power hN hγ.le) (by positivity) (by linarith) _
      have harg : 2*((r : ℝ)+1)/(ε/2)=4*((r : ℝ)+1)/ε := by ring
      simpa only [harg] using hgap
    apply bounds_of_relevant_class Fintype.card_pos _ (functionMass_nonneg φ (1/2) _) _ f
      (fun _ => rfl) ((Real.exp_pos _).trans_le hmass) (spectralFunctions d r K φ)
      (P d C : ℝ) _ (by positivity) (by positivity)
    · apply (spectralFunctions_card_le_exp d r K φ hφ).trans
      apply Real.exp_le_exp.mpr
      exact_mod_cast aboveSampleBudget_ge_capacity r N₀ q p d S
    · exact hratio.trans ((show ε/2 ≤ ε by linarith).trans (exp_neg_dimension_le_cube_inverse d))
  · apply network_bounds_of_prior_mass hd (admissibleActivation_continuous hφ) _ f (P d C : ℝ) (by positivity)
    exact powerPrior_target_mass_smallWidthBudget (by omega) φ hφ f hf hCN
      (show C ≤ S by dsimp [S]; omega) (le_of_not_ge hTN) hγ.le (Nat.le_ceil γ)

end NeuralGeneralization.BatchTwoOnline
