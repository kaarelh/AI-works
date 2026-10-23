import NeuralGeneralization.BatchTwoCircuitConverseInfiniteSampling

/-!
# Infinite-iid corollaries for the explicit circuit-induction rules

The distribution may have arbitrary positive atom probabilities; only its
support enters the target complexity. The expected total below counts the
actual sampled 0/1 errors, not a finite horizon or an assumed compensator.
-/
namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped ENNReal BigOperators
open MeasureTheory ProbabilityTheory
noncomputable section
open Classical
variable {d : ℕ} {Ω : Type*}

def supportSet (p : PMF (Input d)) : Finset (Input d) :=
  Finset.univ.filter (fun x => p x ≠ 0)

theorem iid_complete_support
    [MeasurableSpace Ω] [MeasurableSpace (Input d)] [MeasurableSingletonClass (Input d)]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (p : PMF (Input d)) (query : Ω → ℕ → Input d)
    (hmeas : ∀ n, Measurable (fun ω => query ω n))
    (hind : iIndepFun (fun n ω => query ω n) μ)
    (hlaw : ∀ n x, μ {ω | query ω n = x} = p x) :
    ∀ᵐ ω ∂μ, (∀ i, query ω i ∈ supportSet p) ∧
      ∃ n, history (query ω) n = supportSet p :=
  (iid_finite_support_cover μ p query hmeas hind hlaw).mono (fun ω hω =>
    ⟨fun i => Finset.mem_filter.mpr ⟨Finset.mem_univ _, hω.1 i⟩, hω.2⟩)

/-- The exact geometric-prior bounds for total mistakes under any iid input law. -/
theorem geometric_iid_sampled_circuit_converse
    [mΩ : MeasurableSpace Ω] [MeasurableSpace (Input d)] [MeasurableSingletonClass (Input d)]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (information : ℕ → MeasurableSpace Ω) (hinfo : ∀ n, information n ≤ mΩ)
    (p : PMF (Input d)) (query : Ω → ℕ → Input d)
    (hquery : ∀ n, Measurable (fun ω => query ω n))
    (hind : iIndepFun (fun n ω => query ω n) μ)
    (hquerylaw : ∀ n x, μ {ω | query ω n = x} = p x)
    (f : Input d → Bool) (prediction : Ω → ℕ → Bool)
    (hmeas : ∀ n, AEStronglyMeasurable (sampledError f query prediction n) μ)
    (hlaw : ∀ n, μ[sampledError f query prediction n | information n] =ᵐ[μ]
      fun ω => BatchTwoOnline.onlineError (functionWeight d)
        (fun g x => g x = f x) (query ω) n) :
    let E := ∫⁻ ω, infiniteSampledMistakes f query prediction ω ∂μ
    let C := complexity f (supportSet p)
    let M := E.toReal
    E ≠ ⊤ ∧ ((C:ℝ)*Real.log 2)/(2*predictiveCost d ((C:ℝ)*Real.log 2)) ≤ M ∧
    (C:ℝ) ≤ (12*((3*d+3:ℕ):ℝ)*M/Real.log 2)*
      Real.log (((4*d+6:ℕ):ℝ)+12*((3*d+3:ℕ):ℝ)*M/Real.log 2) ∧
    M ≤ gateBudget d C := by
  have hcomplete := iid_complete_support μ p query hquery hind hquerylaw
  have hh := infinite_sampled_bounds_of_complete_paths μ information hinfo
    (functionWeight d) (functionWeight_nonneg d) (functionWeight_sum d).le
    f (functionWeight_pos f) (supportSet p) query prediction hcomplete hmeas hlaw
    (versionLoss f (supportSet p)) (2*predictiveCost d (versionLoss f (supportSet p)))
    (fun q n hn => by
      constructor
      · simpa only [hn, predictionMistakes_eq_cumulativeError] using
          predictionMistakes_le_versionLoss f q n
      · simpa only [hn, predictionMistakes_eq_cumulativeError] using
          geometric_pathwise_loss f q n)
  dsimp only at hh ⊢
  exact ⟨hh.1, complexity_lower_of_loss_bound f (supportSet p) hh.2.1,
    complexity_bound_of_loss_bound f (supportSet p) ENNReal.toReal_nonneg hh.2.1,
    hh.2.2.trans (versionLoss_le_budget f (supportSet p))⟩

/-- Literal total mistakes of a deterministic minimum-consistent-circuit learner. -/
def totalOccamMistakes (f : Input d → Bool) (query : ℕ → Input d)
    (c : ℕ → Circuit d) : ℝ≥0∞ :=
  ∑' i, if (c i).eval (query i) = f (query i) then 0 else 1

theorem deterministic_total_eq_prefix (f : Input d → Bool) (query : ℕ → Input d)
    (c : ℕ → Circuit d) (hc : IsOccam f query c) (A : Finset (Input d)) (n : ℕ)
    (hn : history query n = A) (hin : ∀ i, query i ∈ A) :
    totalOccamMistakes f query c = (mistakes f query c n : ℝ≥0∞) := by
  unfold totalOccamMistakes
  rw [tsum_eq_sum (s := Finset.range n) (fun i hi => by
    have hni : n ≤ i := Nat.le_of_not_gt (fun hh => hi (Finset.mem_range.mpr hh))
    have hx : query i ∈ history query n := hn.symm ▸ hin i
    have hsub : history query n ⊆ history query i :=
      Finset.image_subset_image (Finset.range_mono hni)
    exact if_pos ((hc i).1 (query i) (hsub hx)))]
  unfold mistakes
  rw [Nat.cast_sum]
  apply Finset.sum_congr rfl
  intro i hi
  split_ifs <;> norm_num

theorem deterministic_iid_circuit_converse
    [MeasurableSpace Ω] [MeasurableSpace (Input d)] [MeasurableSingletonClass (Input d)]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (p : PMF (Input d)) (query : Ω → ℕ → Input d)
    (hquery : ∀ n, Measurable (fun ω => query ω n))
    (hind : iIndepFun (fun n ω => query ω n) μ)
    (hquerylaw : ∀ n x, μ {ω | query ω n = x} = p x)
    (f : Input d → Bool) (c : Ω → ℕ → Circuit d)
    (hc : ∀ ω, IsOccam f (query ω) (c ω)) :
    ∀ᵐ ω ∂μ, totalOccamMistakes f (query ω) (c ω) ≠ ⊤ ∧
      (complexity f (supportSet p) : ℝ≥0∞) ≤
        (3*d+3)*totalOccamMistakes f (query ω) (c ω) := by
  filter_upwards [iid_complete_support μ p query hquery hind hquerylaw] with ω hω
  obtain ⟨hin, n, hn⟩ := hω
  rw [deterministic_total_eq_prefix f (query ω) (c ω) (hc ω) _ n hn hin]
  refine ⟨by finiteness, ?_⟩
  exact_mod_cast deterministic_complete_reveal f (query ω) (c ω) (hc ω) n (supportSet p) hn

namespace Prefix

/-- The exact prefix-exception-prior bounds for total mistakes under any iid input law. -/
theorem prefix_iid_sampled_circuit_converse
    [mΩ : MeasurableSpace Ω] [MeasurableSpace (Input d)] [MeasurableSingletonClass (Input d)]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (information : ℕ → MeasurableSpace Ω) (hinfo : ∀ n, information n ≤ mΩ)
    (p : PMF (Input d)) (query : Ω → ℕ → Input d)
    (hquery : ∀ n, Measurable (fun ω => query ω n))
    (hind : iIndepFun (fun n ω => query ω n) μ)
    (hquerylaw : ∀ n x, μ {ω | query ω n = x} = p x)
    (f : Input d → Bool) (prediction : Ω → ℕ → Bool)
    (hmeas : ∀ n, AEStronglyMeasurable (sampledError f query prediction n) μ)
    (hlaw : ∀ n, μ[sampledError f query prediction n | information n] =ᵐ[μ]
      fun ω => BatchTwoOnline.onlineError (functionWeight d)
        (fun g x => g x = f x) (query ω) n) :
    let E := ∫⁻ ω, infiniteSampledMistakes f query prediction ω ∂μ
    let C := complexity f (supportSet p)
    let K := codeComplexity f (supportSet p)
    let M := E.toReal
    E ≠ ⊤ ∧ (C:ℝ) ≤ (6*(d+2)/(1-beta d))*M+12 ∧
    M ≤ 2*K*Real.log 2 ∧ K ≤ 3+C+2*C*Nat.clog 2 (d+C+1) := by
  have hcomplete := iid_complete_support μ p query hquery hind hquerylaw
  have hh := infinite_sampled_bounds_of_complete_paths μ information hinfo
    (functionWeight d) (functionWeight_nonneg d) (functionWeight_sum d).le
    f (functionWeight_pos f) (supportSet p) query prediction hcomplete hmeas hlaw
    (versionLoss f (supportSet p)) (cost d)
    (fun q n hn => by
      constructor
      · simpa only [hn, predictionMistakes_eq_cumulativeError] using
          predictionMistakes_le_versionLoss f q n
      · simpa only [hn, predictionMistakes_eq_cumulativeError] using
          prefix_pathwise_loss f q n)
  dsimp only at hh ⊢
  exact ⟨hh.1, complexity_bound_of_loss_bound f (supportSet p) hh.2.1,
    hh.2.2.trans (versionLoss_le_code f (supportSet p)),
    codeComplexity_le_gate_code f (supportSet p)⟩

end Prefix
end
end NeuralGeneralization.BatchTwoCircuitConverse
