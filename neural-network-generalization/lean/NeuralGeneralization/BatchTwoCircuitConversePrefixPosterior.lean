import NeuralGeneralization.BatchTwoCircuitConversePrefixPrediction
import NeuralGeneralization.BatchTwoCircuitConverseSampling

/-!
# The prefix-program consistency posterior and exact finite-path bounds
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix

open scoped ENNReal BigOperators
noncomputable section
open Classical
variable {d : ℕ}

def functionPrior (d : ℕ) : PMF (Input d → Bool) := (prior d).map Program.eval

def functionWeight (d : ℕ) (f : Input d → Bool) : ℝ := (functionPrior d f).toReal

theorem functionWeight_nonneg (d : ℕ) (f : Input d → Bool) : 0 ≤ functionWeight d f :=
  ENNReal.toReal_nonneg

theorem functionWeight_sum (d : ℕ) : ∑ f, functionWeight d f = 1 := by
  unfold functionWeight
  rw [← ENNReal.toReal_sum (fun f _ => (functionPrior d).apply_ne_top f)]
  have h : ∑ f, functionPrior d f = 1 := by
    simpa only [tsum_fintype] using (functionPrior d).tsum_coe
  rw [h, ENNReal.toReal_one]

theorem function_event_mass (P : (Input d → Bool) → Prop) :
    (∑ g, if P g then functionPrior d g else 0) = eventMass (fun p => P p.eval) := by
  have he := PMF.toOuterMeasure_map_apply Program.eval (prior d) {g | P g}
  rw [PMF.toOuterMeasure_apply, PMF.toOuterMeasure_apply] at he
  simp only [Set.indicator, Set.mem_setOf_eq, Set.mem_preimage, tsum_fintype] at he
  rw [eventMass_eq_tsum]
  unfold functionPrior
  convert he using 1
  · apply Finset.sum_congr rfl
    intro g hg
    by_cases hh : P g <;> simp only [hh, ↓reduceIte]

theorem function_normalizer_mass (P : (Input d → Bool) → Prop) :
    normalizer (functionWeight d) P = (eventMass (fun p => P p.eval)).toReal := by
  rw [← function_event_mass P]
  rw [ENNReal.toReal_sum (fun g _ => by
    split_ifs
    · exact (functionPrior d).apply_ne_top g
    · exact ENNReal.zero_ne_top)]
  unfold normalizer
  apply Finset.sum_congr rfl
  intro g hg
  split_ifs <;> simp [functionWeight]

theorem functionWeight_pos (f : Input d → Bool) : 0 < functionWeight d f := by
  have h := eventMass_real_pos (fun p : Program d => p.Fits f Finset.univ)
    (Classical.choose (exists_fitting_program f Finset.univ))
    (Classical.choose_spec (exists_fitting_program f Finset.univ))
  have he : eventMass (fun p : Program d => p.Fits f Finset.univ) = functionPrior d f := by
    have hp : (fun p : Program d => p.Fits f Finset.univ) = (fun p => p.eval = f) := by
      funext p
      apply propext
      constructor
      · intro hfit
        funext x
        exact hfit x (Finset.mem_univ x)
      · intro he x hx
        exact congrFun he x
    rw [hp, ← function_event_mass (fun g => g = f)]
    convert (Finset.sum_ite_eq' Finset.univ f (functionPrior d)) using 1
    · apply Finset.sum_congr rfl
      intro g hg
      by_cases hh : g = f <;> simp only [hh, ↓reduceIte]
    · simp
  rw [he] at h
  exact h

@[simp] theorem versionMass_empty (f : Input d → Bool) : versionMass f ∅ = 1 := by
  unfold versionMass
  rw [eventMass_eq_tsum]
  have he : (fun p : Program d => if p.Fits f ∅ then prior d p else 0) = prior d := by
    funext p
    simp [Program.Fits, Circuit.Fits]
  rw [he, (prior d).tsum_coe, ENNReal.toReal_one]

@[simp] theorem versionLoss_empty (f : Input d → Bool) : versionLoss f ∅ = 0 := by
  simp [versionLoss]

theorem history_normalizer_eq_versionMass (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    normalizer (functionWeight d)
      (BatchTwoOnline.history (fun g x => g x = f x) query n) =
      versionMass f (history query n) := by
  rw [function_normalizer_mass]
  unfold versionMass
  congr 1
  apply congrArg eventMass
  funext p
  exact propext (history_iff_fits f p.eval query n)

theorem correctProbability_eq_one_sub_onlineError (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    correctProbability f (history query n) (query n) =
      1 - BatchTwoOnline.onlineError (functionWeight d)
        (fun g x => g x = f x) query n := by
  have hs := BatchTwoOnline.normalizer_step (functionWeight d)
    (fun g x => g x = f x) query (functionWeight_nonneg d) f (fun _ => rfl)
    (functionWeight_pos f) n
  rw [history_normalizer_eq_versionMass, history_normalizer_eq_versionMass, history_succ] at hs
  unfold correctProbability
  apply (div_eq_iff (versionMass_pos f (history query n)).ne').mpr
  simpa only [mul_comm] using hs

def predictionMistakes (f : Input d → Bool) (query : ℕ → Input d) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, (1 - correctProbability f (history query i) (query i))

theorem predictionMistakes_nonneg (f : Input d → Bool) (query : ℕ → Input d) (n : ℕ) :
    0 ≤ predictionMistakes f query n := by
  unfold predictionMistakes
  exact Finset.sum_nonneg (fun i _ => sub_nonneg.mpr (correctProbability_le_one _ _ _))

theorem predictionMistakes_eq_cumulativeError (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    predictionMistakes f query n = BatchTwoOnline.cumulativeError (functionWeight d)
      (fun g x => g x = f x) query n := by
  unfold predictionMistakes BatchTwoOnline.cumulativeError
  apply Finset.sum_congr rfl
  intro i hi
  rw [correctProbability_eq_one_sub_onlineError]
  ring

theorem versionLoss_insert (f : Input d → Bool) (A : Finset (Input d)) (x : Input d) :
    versionLoss f (insert x A) - versionLoss f A = -Real.log (correctProbability f A x) := by
  unfold versionLoss correctProbability
  rw [Real.log_div (versionMass_pos f (insert x A)).ne' (versionMass_pos f A).ne']
  ring

theorem versionLoss_eq_sum_log (f : Input d → Bool) (query : ℕ → Input d) (n : ℕ) :
    versionLoss f (history query n) =
      ∑ i ∈ Finset.range n, -Real.log (correctProbability f (history query i) (query i)) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [history_succ, Finset.sum_range_succ]
    have hs := versionLoss_insert f (history query n) (query n)
    rw [ih] at hs
    linarith

theorem prefix_pathwise_loss (f : Input d → Bool) (query : ℕ → Input d) (n : ℕ) :
    versionLoss f (history query n) ≤ cost d * predictionMistakes f query n := by
  rw [versionLoss_eq_sum_log]
  have hs := Finset.sum_le_sum (s := Finset.range n)
    (fun i _ => neg_log_correctProbability_le_error f (history query i) (query i))
  rw [← Finset.mul_sum] at hs
  exact hs

theorem predictionMistakes_le_versionLoss (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    predictionMistakes f query n ≤ versionLoss f (history query n) := by
  rw [versionLoss_eq_sum_log]
  unfold predictionMistakes
  apply Finset.sum_le_sum
  intro i hi
  have h := Real.log_le_sub_one_of_pos (correctProbability_pos f (history query i) (query i))
  linarith

/-- Exact linear gate-complexity bound, with the manuscript's additive constant. -/
theorem complexity_bound_of_loss_bound (f : Input d → Bool) (A : Finset (Input d))
    {M : ℝ} (h : versionLoss f A ≤ cost d * M) :
    (complexity f A : ℝ) ≤ (6*(d+2)/(1-beta d))*M + 12 := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hcode := code_log_lower f A
  have hc : (complexity f A : ℝ) ≤ 3*(codeComplexity f A : ℝ) := by
    exact_mod_cast circuit_complexity_le_code f A
  have he : 3*cost d*M/Real.log 2 = (6*(d+2)/(1-beta d))*M := by
    unfold cost
    field_simp
    <;> ring
  have hbound : (complexity f A : ℝ)*Real.log 2 ≤ 3*cost d*M+12*Real.log 2 := by
    nlinarith
  have hb := (le_div_iff₀ hlog2).mpr hbound
  have hsplit : (3*cost d*M+12*Real.log 2)/Real.log 2 = 3*cost d*M/Real.log 2+12 := by
    field_simp
  rwa [hsplit, he] at hb

theorem prefix_posterior_circuit_converse (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    (complexity f (history query n) : ℝ) ≤ (6*(d+2)/(1-beta d))*
      BatchTwoOnline.cumulativeError (functionWeight d) (fun g x => g x = f x) query n +12 := by
  simpa only [predictionMistakes_eq_cumulativeError] using
    complexity_bound_of_loss_bound f (history query n) (prefix_pathwise_loss f query n)

end
end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
