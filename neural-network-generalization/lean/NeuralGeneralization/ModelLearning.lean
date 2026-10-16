import NeuralGeneralization.FunctionPriorFacts
import NeuralGeneralization.FiniteLearning
import Mathlib.Topology.Order.LeftRightNhds

/-!
# The finite learning theorem for the actual network posterior

This module connects the generic finite probability proof to the concrete
Gaussian network masses and the `Fin n → Cube d` IID sample space. The neural
compression/mass-ratio estimate is an explicit hypothesis. Thus these are
verified implications for the actual model, not proofs of the four main
research claims.
-/

noncomputable section


namespace NeuralGeneralization.ConcreteModel

open scoped BigOperators Topology
open MeasureTheory Filter
open Classical
attribute [local instance] Classical.propDecidable

lemma functionError_eq_eventError {d : ℕ} (D : InputLaw d)
    (f g : BooleanFunction d) :
    functionError D f g = NeuralGeneralization.eventError D.mass (fun x => g x = f x) := by
  unfold functionError NeuralGeneralization.eventError
  apply Finset.sum_congr rfl
  intro x _
  by_cases hx : g x = f x <;> simp [hx]

lemma posteriorRisk_eq_averageRisk {d : ℕ} (D : InputLaw d)
    (f : BooleanFunction d) (p : BooleanFunction d → ℝ) :
    posteriorRisk D f p = NeuralGeneralization.averageRisk p D.mass (fun g x => g x) f := by
  rw [NeuralGeneralization.averageRisk_eq_sum_hypothesis]
  unfold posteriorRisk functionError NeuralGeneralization.hypothesisError
  apply Finset.sum_congr rfl
  intro g _
  congr 1
  apply Finset.sum_congr rfl
  intro x _
  by_cases hx : g x = f x <;> simp [hx]

lemma confidenceFailure_eq_generic {d : ℕ} (D : InputLaw d)
    (f : BooleanFunction d) (p : BooleanFunction d → ℝ) :
    confidenceFailure D f p =
      NeuralGeneralization.confidenceFailure p D.mass (fun g x => g x) f := rfl

lemma networkPosterior_nonneg {d N r n : ℕ} (φ : ℝ → ℝ) (margin : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d)
    (sample : Fin n → Cube d) (hf : 0 < functionMass φ margin μ f)
    (g : BooleanFunction d) : 0 ≤ networkPosterior φ margin μ f sample g := by
  exact NeuralGeneralization.posterior_nonneg (functionMass φ margin μ)
    (consistent f sample) (functionMass_nonneg φ margin μ) f (fun _ => rfl) hf g

/-- The strict confidence convention holds for the actual normalized network posterior. -/
theorem network_confidenceFailure_le_three_risk {d N r n : ℕ}
    (φ : ℝ → ℝ) (margin : ℝ) (μ : Measure (Weights d N r))
    (D : InputLaw d) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (hf : 0 < functionMass φ margin μ f) :
    confidenceFailure D f (networkPosterior φ margin μ f sample) ≤
      3 * posteriorRisk D f (networkPosterior φ margin μ f sample) := by
  rw [confidenceFailure_eq_generic, posteriorRisk_eq_averageRisk]
  exact NeuralGeneralization.confidenceFailure_le_three_risk
    (networkPosterior φ margin μ f sample) D.mass (fun g x => g x) f
    (networkPosterior_nonneg φ margin μ f sample hf)
    (networkPosterior_sum φ margin μ f sample hf) D.nonneg

lemma networkPosterior_eq_finite {d N r n : ℕ}
    (φ : ℝ → ℝ) (margin : ℝ) (μ : Measure (Weights d N r))
    (f : BooleanFunction d) (sample : Fin n → Cube d) :
    networkPosterior φ margin μ f sample =
      NeuralGeneralization.posterior (functionMass φ margin μ)
        (fun g => NeuralGeneralization.allObservations (fun x => g x = f x) n sample) := by
  funext g
  unfold networkPosterior NeuralGeneralization.posterior NeuralGeneralization.normalizer
  congr 1

/-- The exact finite relevant-class theorem, instantiated with Gaussian network
sign-event masses and the manuscript's IID sample distribution. -/
theorem network_finite_class_bound {d N r : ℕ}
    (φ : ℝ → ℝ) (margin : ℝ) (μ : Measure (Weights d N r))
    (D : InputLaw d) (f : BooleanFunction d)
    (hf : 0 < functionMass φ margin μ f)
    (A : Finset (BooleanFunction d)) (a τ : ℝ) (ha : 0 ≤ a) (ha1 : a ≤ 1)
    (htail : (∑ g ∈ Finset.univ \ A, functionMass φ margin μ g) /
      functionMass φ margin μ f ≤ τ) (n : ℕ) :
    sampleProbability D n (fun sample =>
      a + τ < posteriorRisk D f (networkPosterior φ margin μ f sample)) ≤
      (A.card : ℝ) * Real.exp (-(n : ℝ) * a) := by
  simpa only [sampleProbability, posteriorRisk, networkPosterior_eq_finite,
    functionError_eq_eventError, NeuralGeneralization.iidWeight] using
    NeuralGeneralization.finite_class_posterior_bound D.mass D.nonneg D.sum_one
      (functionMass φ margin μ) (functionMass_nonneg φ margin μ)
      (fun g x => g x = f x) f (fun _ => rfl) hf A a τ ha ha1
        (by
          have hflat : ((∑ g, functionMass φ margin μ g) -
              ∑ g ∈ A, functionMass φ margin μ g) / functionMass φ margin μ f ≤ τ := by
            simpa only [Finset.sum_sdiff_eq_sub (Finset.subset_univ A)] using htail
          letI : DecidableEq (BooleanFunction d) := fun a b => Classical.propDecidable (a = b)
          simpa only [Finset.sum_sdiff_eq_sub (Finset.subset_univ A)] using hflat) n

lemma sampleProbability_mono {d : ℕ} (D : InputLaw d) (n : ℕ)
    (E F : (Fin n → Cube d) → Prop) (hEF : ∀ s, E s → F s) :
    sampleProbability D n E ≤ sampleProbability D n F := by
  unfold sampleProbability
  apply Finset.sum_le_sum
  intro s _
  by_cases hs : E s
  · simp [hs, hEF s hs]
  · simp only [if_neg hs]
    split_ifs
    · exact Finset.prod_nonneg (fun i _ => D.nonneg (s i))
    · exact le_refl 0

lemma sampleProbability_compl {d : ℕ} (D : InputLaw d) (n : ℕ)
    (E : (Fin n → Cube d) → Prop) :
    sampleProbability D n (fun s => ¬ E s) = 1 - sampleProbability D n E := by
  have hs : sampleProbability D n (fun s => ¬ E s) + sampleProbability D n E = 1 := by
    unfold sampleProbability
    rw [← Finset.sum_add_distrib]
    have hprod : (∑ s : Fin n → Cube d, ∏ i, D.mass (s i)) = 1 := by
      rw [← Fintype.sum_pow, D.sum_one, one_pow]
    rw [← hprod]
    apply Finset.sum_congr rfl
    intro s _
    by_cases hE : E s <;> simp [hE]
  linarith

/-- The conventional high-probability formulation, with both risk and strict
confidence conclusions in the same event. The numerical exponential bound
can be supplied by the manuscript's logarithmic sample-size inequality. -/
theorem network_finite_class_learning {d N r : ℕ}
    (φ : ℝ → ℝ) (margin : ℝ) (μ : Measure (Weights d N r))
    (D : InputLaw d) (f : BooleanFunction d)
    (hf : 0 < functionMass φ margin μ f)
    (A : Finset (BooleanFunction d)) (a τ δ : ℝ) (ha : 0 ≤ a) (ha1 : a ≤ 1)
    (htail : (∑ g ∈ Finset.univ \ A, functionMass φ margin μ g) /
      functionMass φ margin μ f ≤ τ) (n : ℕ)
    (hsize : (A.card : ℝ) * Real.exp (-(n : ℝ) * a) ≤ δ) :
    1 - δ ≤ sampleProbability D n (fun sample =>
      posteriorRisk D f (networkPosterior φ margin μ f sample) ≤ a + τ ∧
      confidenceFailure D f (networkPosterior φ margin μ f sample) ≤ 3 * (a + τ)) := by
  have ht := network_finite_class_bound φ margin μ D f hf A a τ ha ha1 htail n
  have hgood : 1 - δ ≤ sampleProbability D n (fun sample =>
      ¬ (a + τ < posteriorRisk D f (networkPosterior φ margin μ f sample))) := by
    rw [sampleProbability_compl]
    linarith
  apply le_trans hgood
  apply sampleProbability_mono
  intro sample hs
  have hr := le_of_not_gt hs
  have hc := network_confidenceFailure_le_three_risk φ margin μ D f sample hf
  exact ⟨hr, by linarith⟩

/-- The finite-class bound directly in the user's strict `> 2/3` criterion. -/
theorem network_finite_class_confidence_bound {d N r : ℕ}
    (φ : ℝ → ℝ) (margin : ℝ) (μ : Measure (Weights d N r))
    (D : InputLaw d) (f : BooleanFunction d)
    (hf : 0 < functionMass φ margin μ f)
    (A : Finset (BooleanFunction d)) (a τ : ℝ) (ha : 0 ≤ a) (ha1 : a ≤ 1)
    (htail : (∑ g ∈ Finset.univ \ A, functionMass φ margin μ g) /
      functionMass φ margin μ f ≤ τ) (n : ℕ) :
    sampleProbability D n (fun sample =>
      3 * (a + τ) < confidenceFailure D f (networkPosterior φ margin μ f sample)) ≤
      (A.card : ℝ) * Real.exp (-(n : ℝ) * a) := by
  calc
    _ ≤ sampleProbability D n (fun sample =>
        a + τ < posteriorRisk D f (networkPosterior φ margin μ f sample)) := by
      apply sampleProbability_mono
      intro sample hs
      have hb := network_confidenceFailure_le_three_risk φ margin μ D f sample hf
      linarith
    _ ≤ _ := network_finite_class_bound φ margin μ D f hf A a τ ha ha1 htail n

/-- The individual-target-mass bound for the actual Gaussian model. The total
mass bound is proved from disjoint neural sign events, rather than assumed. -/
theorem network_target_mass_bound {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (margin : ℝ) (hmargin : 0 ≤ margin)
    (μ : Measure (Weights d N r)) [IsProbabilityMeasure μ]
    (D : InputLaw d) (f : BooleanFunction d)
    (hf : 0 < functionMass φ margin μ f)
    (a b : ℝ) (ha : 0 ≤ a) (ha1 : a ≤ 1) (hb : 0 < b) (n : ℕ) :
    sampleProbability D n (fun sample =>
      a + b < posteriorRisk D f (networkPosterior φ margin μ f sample)) ≤
      Real.exp (-(n : ℝ) * a) / (functionMass φ margin μ f * b) := by
  simpa only [sampleProbability, posteriorRisk, networkPosterior_eq_finite,
    functionError_eq_eventError, NeuralGeneralization.iidWeight] using
    NeuralGeneralization.target_mass_posterior_bound D.mass D.nonneg D.sum_one
      (functionMass φ margin μ) (functionMass_nonneg φ margin μ)
      (functionMass_sum_le_one hφ hmargin μ)
      (fun g x => g x = f x) f (fun _ => rfl) hf a b ha ha1 hb n

/-- The corresponding high-probability risk and strict-confidence guarantee. -/
theorem network_target_mass_learning {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (margin : ℝ) (hmargin : 0 ≤ margin)
    (μ : Measure (Weights d N r)) [IsProbabilityMeasure μ]
    (D : InputLaw d) (f : BooleanFunction d)
    (hf : 0 < functionMass φ margin μ f)
    (a b δ : ℝ) (ha : 0 ≤ a) (ha1 : a ≤ 1) (hb : 0 < b) (n : ℕ)
    (hsize : Real.exp (-(n : ℝ) * a) / (functionMass φ margin μ f * b) ≤ δ) :
    1 - δ ≤ sampleProbability D n (fun sample =>
      posteriorRisk D f (networkPosterior φ margin μ f sample) ≤ a + b ∧
      confidenceFailure D f (networkPosterior φ margin μ f sample) ≤ 3 * (a + b)) := by
  have ht := network_target_mass_bound hφ margin hmargin μ D f hf a b ha ha1 hb n
  have hgood : 1 - δ ≤ sampleProbability D n (fun sample =>
      ¬ (a + b < posteriorRisk D f (networkPosterior φ margin μ f sample))) := by
    rw [sampleProbability_compl]
    linarith
  apply le_trans hgood
  apply sampleProbability_mono
  intro sample hs
  have hr := le_of_not_gt hs
  have hc := network_confidenceFailure_le_three_risk φ margin μ D f sample hf
  exact ⟨hr, by linarith⟩

/-- Risk lower bounds also transfer to the exact neural posterior. -/
theorem network_confidenceFailure_lower {d N r n : ℕ}
    (φ : ℝ → ℝ) (margin : ℝ) (μ : Measure (Weights d N r))
    (D : InputLaw d) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (hf : 0 < functionMass φ margin μ f)
    (hrisk : (3 / 8 : ℝ) ≤ posteriorRisk D f (networkPosterior φ margin μ f sample)) :
    (1 / 16 : ℝ) ≤ confidenceFailure D f (networkPosterior φ margin μ f sample) := by
  rw [posteriorRisk_eq_averageRisk] at hrisk
  rw [confidenceFailure_eq_generic]
  exact NeuralGeneralization.one_sixteenth_le_confidenceFailure
    (networkPosterior φ margin μ f sample) D.mass (fun g x => g x) f
    (networkPosterior_nonneg φ margin μ f sample hf)
    (networkPosterior_sum φ margin μ f sample hf) D.nonneg D.sum_one hrisk

/-- A vanishing raw tail/target ratio supplies one prior-parameter neighborhood
that works for every input law, confidence parameter, and sample size. -/
theorem eventual_network_learning_of_tail_ratio
    {I : Type*} {l : Filter I} {d N r : ℕ}
    (φ : ℝ → ℝ) (margin : ℝ) (μ : I → Measure (Weights d N r))
    (f : BooleanFunction d) (A : Finset (BooleanFunction d))
    (hpos : ∀ᶠ t in l, 0 < functionMass φ margin (μ t) f)
    (htail : Tendsto (fun t =>
      (∑ g ∈ Finset.univ \ A, functionMass φ margin (μ t) g) /
        functionMass φ margin (μ t) f) l (𝓝 0))
    (ε : ℝ) (hε : 0 < ε) (hε1 : ε < 1) :
    ∀ᶠ t in l, ∀ D : InputLaw d, ∀ δ : ℝ, ∀ n : ℕ,
      (A.card : ℝ) * Real.exp (-(n : ℝ) * (ε / 2)) ≤ δ →
      1 - δ ≤ sampleProbability D n (fun sample =>
        posteriorRisk D f (networkPosterior φ margin (μ t) f sample) ≤ ε ∧
        confidenceFailure D f (networkPosterior φ margin (μ t) f sample) ≤ 3 * ε) := by
  have hsmall := (tendsto_order.mp htail).2 (ε / 2) (by linarith)
  filter_upwards [hpos, hsmall] with t hp ht
  intro D δ n hsize
  have h := network_finite_class_learning φ margin (μ t) D f hp A
    (ε / 2) (ε / 2) δ (by linarith) (by linarith) ht.le n hsize
  simpa only [add_halves] using h

/-- The neighborhood above is an actual positive variance threshold. Its
position before `D`, `δ`, and `n` is part of the formal statement. -/
theorem small_variance_network_learning_of_tail_ratio
    {d N r : ℕ} (φ : ℝ → ℝ) (margin : ℝ)
    (μ : ℝ → Measure (Weights d N r))
    (f : BooleanFunction d) (A : Finset (BooleanFunction d))
    (hpos : ∀ᶠ σ in 𝓝[>] (0 : ℝ), 0 < functionMass φ margin (μ σ) f)
    (htail : Tendsto (fun σ =>
      (∑ g ∈ Finset.univ \ A, functionMass φ margin (μ σ) g) /
        functionMass φ margin (μ σ) f) (𝓝[>] (0 : ℝ)) (𝓝 0))
    (ε : ℝ) (hε : 0 < ε) (hε1 : ε < 1) :
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      ∀ D : InputLaw d, ∀ δ : ℝ, ∀ n : ℕ,
        (A.card : ℝ) * Real.exp (-(n : ℝ) * (ε / 2)) ≤ δ →
        1 - δ ≤ sampleProbability D n (fun sample =>
          posteriorRisk D f (networkPosterior φ margin (μ σ) f sample) ≤ ε ∧
          confidenceFailure D f (networkPosterior φ margin (μ σ) f sample) ≤ 3 * ε) := by
  have he := eventual_network_learning_of_tail_ratio φ margin μ f A hpos htail ε hε hε1
  obtain ⟨σ₀, hσ₀, hsub⟩ := mem_nhdsGT_iff_exists_Ioo_subset.mp he
  exact ⟨σ₀, hσ₀, fun σ hσ hσlt => hsub ⟨hσ, hσlt⟩⟩

end NeuralGeneralization.ConcreteModel
