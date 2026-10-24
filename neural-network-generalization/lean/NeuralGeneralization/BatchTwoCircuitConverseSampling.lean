import NeuralGeneralization.BatchTwoCircuitConverseRandomReveal
import Mathlib.MeasureTheory.Function.ConditionalExpectation.Basic

/-!
# Actual sampled mistakes and the predictable posterior-error sum

A binary posterior sampler is specified by its conditional error law, relative
to the information available before the fresh prediction. The tower property
and Tonelli convert that law into equality of expected total counts, including
unbounded stopping times. No complexity conclusion is assumed in this bridge.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped ENNReal BigOperators
open MeasureTheory
noncomputable section
open Classical

/-- A generic conditional-sampling bridge, allowing infinitely many rounds. -/
theorem expected_counts_equal_of_conditional_law
    {Ω : Type*} [mΩ : MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (information : ℕ → MeasurableSpace Ω) (hinfo : ∀ n, information n ≤ mΩ)
    (actual predicted : ℕ → Ω → ℝ)
    (hmeas : ∀ n, AEStronglyMeasurable (actual n) μ)
    (hactual : ∀ n ω, 0 ≤ actual n ω ∧ actual n ω ≤ 1)
    (hpredicted : ∀ n ω, 0 ≤ predicted n ω ∧ predicted n ω ≤ 1)
    (hlaw : ∀ n, μ[actual n | information n] =ᵐ[μ] predicted n) :
    (∫⁻ ω, ∑' n, ENNReal.ofReal (actual n ω) ∂μ) =
      ∫⁻ ω, ∑' n, ENNReal.ofReal (predicted n ω) ∂μ := by
  have hpmeas : ∀ n, AEStronglyMeasurable (predicted n) μ := fun n =>
    (integrable_condExp (μ := μ) (f := actual n) (m := information n)).aestronglyMeasurable.congr
      (hlaw n)
  have hai : ∀ n, Integrable (actual n) μ := fun n =>
    (integrable_const (1:ℝ)).mono' (hmeas n) (Filter.Eventually.of_forall (fun ω => by
      rw [Real.norm_eq_abs, abs_of_nonneg (hactual n ω).1]
      exact (hactual n ω).2))
  have hpi : ∀ n, Integrable (predicted n) μ := fun n =>
    (integrable_const (1:ℝ)).mono' (hpmeas n) (Filter.Eventually.of_forall (fun ω => by
      rw [Real.norm_eq_abs, abs_of_nonneg (hpredicted n ω).1]
      exact (hpredicted n ω).2))
  rw [lintegral_tsum (f := fun n ω => ENNReal.ofReal (actual n ω))
      (fun n => ENNReal.measurable_ofReal.comp_aemeasurable (hmeas n).aemeasurable),
    lintegral_tsum (f := fun n ω => ENNReal.ofReal (predicted n ω))
      (fun n => ENNReal.measurable_ofReal.comp_aemeasurable (hpmeas n).aemeasurable)]
  apply tsum_congr
  intro n
  rw [← ofReal_integral_eq_lintegral_ofReal (hai n)
      (Filter.Eventually.of_forall (fun ω => (hactual n ω).1)),
    ← ofReal_integral_eq_lintegral_ofReal (hpi n)
      (Filter.Eventually.of_forall (fun ω => (hpredicted n ω).1))]
  congr 1
  rw [← integral_condExp (hinfo n)]
  exact integral_congr_ae (hlaw n)

variable {d : ℕ} {Ω : Type*}

/-- A literal 0/1 prediction error, counted only before stopping. -/
def stoppedSampledError (f : Input d → Bool) (query : Ω → ℕ → Input d)
    (prediction : Ω → ℕ → Bool) (stop : Ω → ℕ) (n : ℕ) (ω : Ω) : ℝ :=
  if n < stop ω then if prediction ω n = f (query ω n) then 0 else 1 else 0

/-- The exact consistency-posterior error on the same stopped path. -/
def stoppedPosteriorError (f : Input d → Bool) (query : Ω → ℕ → Input d)
    (stop : Ω → ℕ) (n : ℕ) (ω : Ω) : ℝ :=
  if n < stop ω then BatchTwoOnline.onlineError (functionWeight d)
    (fun g x => g x = f x) (query ω) n else 0

def sampledMistakeCount (f : Input d → Bool) (query : Ω → ℕ → Input d)
    (prediction : Ω → ℕ → Bool) (stop : Ω → ℕ) (ω : Ω) : ℕ :=
  ∑ n ∈ Finset.range (stop ω), if prediction ω n = f (query ω n) then 0 else 1

theorem tsum_stoppedSampledError (f : Input d → Bool) (query : Ω → ℕ → Input d)
    (prediction : Ω → ℕ → Bool) (stop : Ω → ℕ) (ω : Ω) :
    (∑' n, ENNReal.ofReal (stoppedSampledError f query prediction stop n ω)) =
      (sampledMistakeCount f query prediction stop ω : ℝ≥0∞) := by
  rw [tsum_eq_sum (s := Finset.range (stop ω)) (fun n hn => by
    simp only [Finset.mem_range] at hn
    simp [stoppedSampledError, hn])]
  unfold sampledMistakeCount
  rw [Nat.cast_sum]
  apply Finset.sum_congr rfl
  intro n hn
  simp only [Finset.mem_range] at hn
  simp only [stoppedSampledError, hn, ↓reduceIte]
  split_ifs <;> norm_num

theorem tsum_stoppedPosteriorError (f : Input d → Bool) (query : Ω → ℕ → Input d)
    (stop : Ω → ℕ) (ω : Ω) :
    (∑' n, ENNReal.ofReal (stoppedPosteriorError f query stop n ω)) =
      ENNReal.ofReal (BatchTwoOnline.cumulativeError (functionWeight d)
        (fun g x => g x = f x) (query ω) (stop ω)) := by
  rw [tsum_eq_sum (s := Finset.range (stop ω)) (fun n hn => by
    simp only [Finset.mem_range] at hn
    simp [stoppedPosteriorError, hn])]
  unfold BatchTwoOnline.cumulativeError
  rw [ENNReal.ofReal_sum_of_nonneg (fun n _ =>
    BatchTwoOnline.onlineError_nonneg _ _ _ (functionWeight_nonneg d) f (fun _ => rfl)
      (functionWeight_pos f) n)]
  apply Finset.sum_congr rfl
  intro n hn
  simp only [Finset.mem_range] at hn
  simp only [stoppedPosteriorError, hn, ↓reduceIte]

/-- Equality between expected actual stopped mistakes and expected posterior
error sums under the binary posterior conditional law. This handles arbitrary
unbounded finite stopping indices and does not require a fixed reveal order. -/
theorem expected_sampled_mistakes_eq_compensator
    [mΩ : MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (information : ℕ → MeasurableSpace Ω) (hinfo : ∀ n, information n ≤ mΩ)
    (f : Input d → Bool) (A : Finset (Input d)) (query : Ω → ℕ → Input d)
    (prediction : Ω → ℕ → Bool) (stop : Ω → ℕ)
    (hcover : ∀ᵐ ω ∂μ, history (query ω) (stop ω) = A)
    (hmeas : ∀ n, AEStronglyMeasurable (stoppedSampledError f query prediction stop n) μ)
    (hcompmeas : AEStronglyMeasurable (fun ω =>
      BatchTwoOnline.cumulativeError (functionWeight d)
        (fun g x => g x = f x) (query ω) (stop ω)) μ)
    (hlaw : ∀ n, μ[stoppedSampledError f query prediction stop n | information n]
      =ᵐ[μ] stoppedPosteriorError f query stop n) :
    (∫⁻ ω, (sampledMistakeCount f query prediction stop ω : ℝ≥0∞) ∂μ) =
      ENNReal.ofReal (∫ ω, BatchTwoOnline.cumulativeError (functionWeight d)
        (fun g x => g x = f x) (query ω) (stop ω) ∂μ) := by
  have hactual : ∀ n ω, 0 ≤ stoppedSampledError f query prediction stop n ω ∧
      stoppedSampledError f query prediction stop n ω ≤ 1 := by
    intro n ω
    unfold stoppedSampledError
    split_ifs <;> norm_num
  have hpred : ∀ n ω, 0 ≤ stoppedPosteriorError f query stop n ω ∧
      stoppedPosteriorError f query stop n ω ≤ 1 := by
    intro n ω
    unfold stoppedPosteriorError
    split_ifs
    · exact ⟨BatchTwoOnline.onlineError_nonneg _ _ _ (functionWeight_nonneg d)
        f (fun _ => rfl) (functionWeight_pos f) n,
        BatchTwoOnline.onlineError_le_one _ _ _ (functionWeight_nonneg d)
        f (fun _ => rfl) (functionWeight_pos f) n⟩
    · norm_num
  have he := expected_counts_equal_of_conditional_law μ information hinfo _ _
    hmeas hactual hpred hlaw
  simp_rw [tsum_stoppedSampledError, tsum_stoppedPosteriorError] at he
  let m := fun ω => BatchTwoOnline.cumulativeError (functionWeight d)
    (fun g x => g x = f x) (query ω) (stop ω)
  have hnonneg : ∀ ω, 0 ≤ m ω := by
    intro ω
    dsimp [m]
    rw [← predictionMistakes_eq_cumulativeError]
    exact predictionMistakes_nonneg _ _ _
  have hupper : ∀ᵐ ω ∂μ, m ω ≤ versionLoss f A := hcover.mono (fun ω hcoverω => by
    simpa only [hcoverω, predictionMistakes_eq_cumulativeError] using
      predictionMistakes_le_versionLoss f (query ω) (stop ω))
  have hmInt : Integrable m μ := (integrable_const (versionLoss f A)).mono' hcompmeas
    (hupper.mono (fun ω hupperω => by
      rw [Real.norm_eq_abs, abs_of_nonneg (hnonneg ω)]
      exact hupperω))
  exact he.trans (ofReal_integral_eq_lintegral_ofReal hmInt
    (Filter.Eventually.of_forall hnonneg)).symm


/-- Main geometric-prior theorem for actual sampled prediction mistakes, including
random/adaptive complete reveals and unbounded finite stopping indices. The
conditional-law hypothesis is exactly the binary posterior-sampling convention. -/
theorem geometric_sampled_circuit_converse
    [mΩ : MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (information : ℕ → MeasurableSpace Ω) (hinfo : ∀ n, information n ≤ mΩ)
    (f : Input d → Bool) (A : Finset (Input d)) (query : Ω → ℕ → Input d)
    (prediction : Ω → ℕ → Bool) (stop : Ω → ℕ)
    (hcover : ∀ᵐ ω ∂μ, history (query ω) (stop ω) = A)
    (hmeas : ∀ n, AEStronglyMeasurable (stoppedSampledError f query prediction stop n) μ)
    (hcompmeas : AEStronglyMeasurable (fun ω =>
      BatchTwoOnline.cumulativeError (functionWeight d)
        (fun g x => g x = f x) (query ω) (stop ω)) μ)
    (hlaw : ∀ n, μ[stoppedSampledError f query prediction stop n | information n]
      =ᵐ[μ] stoppedPosteriorError f query stop n) :
    let E := ∫⁻ ω, (sampledMistakeCount f query prediction stop ω : ℝ≥0∞) ∂μ
    let M := E.toReal
    E ≠ ⊤ ∧
    ((complexity f A : ℝ)*Real.log 2) /
      (2*predictiveCost d ((complexity f A : ℝ)*Real.log 2)) ≤ M ∧
    (complexity f A : ℝ) ≤ (12*((3*d+3 : ℕ):ℝ)*M/Real.log 2) *
      Real.log (((4*d+6 : ℕ):ℝ) + 12*((3*d+3 : ℕ):ℝ)*M/Real.log 2) ∧
    M ≤ gateBudget d (complexity f A) := by
  have he := expected_sampled_mistakes_eq_compensator μ information hinfo f A
    query prediction stop hcover hmeas hcompmeas hlaw
  have hnonneg : 0 ≤ ∫ ω, BatchTwoOnline.cumulativeError (functionWeight d)
      (fun g x => g x = f x) (query ω) (stop ω) ∂μ := by
    apply integral_nonneg
    intro ω
    dsimp only [Pi.zero_apply]
    rw [← predictionMistakes_eq_cumulativeError]
    exact predictionMistakes_nonneg _ _ _
  dsimp only
  rw [he, ENNReal.toReal_ofReal hnonneg]
  exact ⟨ENNReal.ofReal_ne_top,
    geometric_random_reveal_compensator_bounds μ f A query stop hcover hcompmeas⟩

end
end NeuralGeneralization.BatchTwoCircuitConverse
