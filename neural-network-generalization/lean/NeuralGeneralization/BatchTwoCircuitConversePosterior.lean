import NeuralGeneralization.BatchTwoCircuitConverseLogInversion

/-!
# Exact identification with the normalized consistency posterior

The circuit-prior converses below use the same posterior construction as the
other finite-function results, not a surrogate prediction rule.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped ENNReal BigOperators
noncomputable section
open Classical

variable {d : ℕ}

theorem function_event_mass (P : (Input d → Bool) → Prop) :
    (∑ g, if P g then circuitFunctionPrior d g else 0) =
      descriptionMass (fun c => P c.eval) := by
  have he := PMF.toOuterMeasure_map_apply Circuit.eval (circuitPrior d) {g | P g}
  rw [PMF.toOuterMeasure_apply, PMF.toOuterMeasure_apply] at he
  simp only [Set.indicator, Set.mem_setOf_eq, Set.mem_preimage,
    circuitPrior_apply, tsum_fintype] at he
  unfold circuitFunctionPrior descriptionMass
  convert he using 1
  · apply Finset.sum_congr rfl
    intro g hg
    by_cases hh : P g <;> simp only [hh, ↓reduceIte]

theorem function_normalizer_mass (P : (Input d → Bool) → Prop) :
    normalizer (functionWeight d) P = (descriptionMass (fun c => P c.eval)).toReal := by
  rw [← function_event_mass P]
  rw [ENNReal.toReal_sum (fun g _ => by
    split_ifs
    · exact (circuitFunctionPrior d).apply_ne_top g
    · exact ENNReal.zero_ne_top)]
  unfold normalizer
  apply Finset.sum_congr rfl
  intro g hg
  split_ifs <;> simp [functionWeight]

theorem history_iff_fits (f g : Input d → Bool) (query : ℕ → Input d) (n : ℕ) :
    BatchTwoOnline.history (fun h x => h x = f x) query n g ↔
      ∀ x ∈ history query n, g x = f x := by
  constructor
  · intro hh x hx
    obtain ⟨i, hi, rfl⟩ := Finset.mem_image.mp hx
    exact hh i (Finset.mem_range.mp hi)
  · intro hh i hi
    exact hh (query i) (Finset.mem_image.mpr ⟨i, Finset.mem_range.mpr hi, rfl⟩)

theorem history_normalizer_eq_versionMass (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    normalizer (functionWeight d)
      (BatchTwoOnline.history (fun g x => g x = f x) query n) =
      versionMass f (history query n) := by
  rw [function_normalizer_mass]
  unfold versionMass
  congr 1
  apply congrArg descriptionMass
  funext c
  exact propext (history_iff_fits f c.eval query n)

/-- The correct-label version-space ratio equals one minus the actual posterior
sampling error, not just a similar-looking estimate. -/
theorem correctProbability_eq_one_sub_onlineError (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    correctProbability f (history query n) (query n) =
      1 - BatchTwoOnline.onlineError (functionWeight d)
        (fun g x => g x = f x) query n := by
  have hs := BatchTwoOnline.normalizer_step (functionWeight d)
    (fun g x => g x = f x) query (functionWeight_nonneg d) f (fun _ => rfl)
    (functionWeight_pos f) n
  rw [history_normalizer_eq_versionMass, history_normalizer_eq_versionMass,
    history_succ] at hs
  unfold correctProbability
  apply (div_eq_iff (versionMass_pos f (history query n)).ne').mpr
  simpa only [mul_comm] using hs

theorem predictionMistakes_eq_cumulativeError (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    predictionMistakes f query n = BatchTwoOnline.cumulativeError (functionWeight d)
      (fun g x => g x = f x) query n := by
  unfold predictionMistakes BatchTwoOnline.cumulativeError
  apply Finset.sum_congr rfl
  intro i hi
  rw [correctProbability_eq_one_sub_onlineError]
  ring

/-- Exact finite-time geometric-prior circuit converse for the actual consistency
posterior. The numerical constants agree with the paper's inverted bound. -/
theorem geometric_posterior_circuit_converse (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    (complexity f (history query n) : ℝ) ≤
      (12*((3*d+3 : ℕ):ℝ)*
        BatchTwoOnline.cumulativeError (functionWeight d) (fun g x => g x = f x) query n /
          Real.log 2) *
      Real.log (((4*d+6 : ℕ):ℝ) + 12*((3*d+3 : ℕ):ℝ)*
        BatchTwoOnline.cumulativeError (functionWeight d) (fun g x => g x = f x) query n /
          Real.log 2) := by
  simpa only [predictionMistakes_eq_cumulativeError] using
    geometric_pathwise_circuit_converse f query n

end
end NeuralGeneralization.BatchTwoCircuitConverse
