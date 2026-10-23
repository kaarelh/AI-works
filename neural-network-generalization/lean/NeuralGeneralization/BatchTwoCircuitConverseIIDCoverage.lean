import NeuralGeneralization.BatchTwoCircuitConversePrefixSampling
import Mathlib.Probability.Independence.Basic

/-!
# Almost-sure finite support coverage for arbitrary finite-valued iid inputs

No positive lower bound on atom probabilities is imposed. The proof uses the
exact finite avoidance probability and convergence of a geometric sequence.
-/
namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped ENNReal BigOperators
open MeasureTheory ProbabilityTheory
noncomputable section
open Classical

variable {Ω X : Type*} [MeasurableSpace Ω] [MeasurableSpace X]
  [MeasurableSingletonClass X]

/-- Each positive-probability atom is eventually observed under an iid sequence. -/
theorem iid_eventually_hits_atom (μ : Measure Ω) [IsProbabilityMeasure μ]
    (p : PMF X) (query : Ω → ℕ → X)
    (hmeas : ∀ n, Measurable (fun ω => query ω n))
    (hind : iIndepFun (fun n ω => query ω n) μ)
    (hlaw : ∀ n x, μ {ω | query ω n = x} = p x)
    (x : X) (hpx : p x ≠ 0) : ∀ᵐ ω ∂μ, ∃ n, query ω n = x := by
  let never : Set Ω := {ω | ∀ n, query ω n ≠ x}
  have havoid (n : ℕ) : μ never ≤ (1-p x)^n := by
    have hsub : never ⊆ ⋂ i ∈ Finset.range n, (fun ω => query ω i) ⁻¹' ({x}ᶜ) := by
      intro ω hω
      simp only [Set.mem_iInter, Set.mem_preimage, Set.mem_compl_iff, Set.mem_singleton_iff]
      intro i hi
      exact hω i
    have hind' := hind.measure_inter_preimage_eq_mul (Finset.range n)
      (sets := fun _ => ({x}ᶜ)) (fun _ _ => (measurableSet_singleton x).compl)
    have he (i : ℕ) : μ ((fun ω => query ω i) ⁻¹' ({x}ᶜ)) = 1-p x := by
      rw [Set.preimage_compl, measure_compl ((measurableSet_singleton x).preimage (hmeas i))
        (measure_ne_top _ _), measure_univ]
      exact congrArg (fun z => (1:ℝ≥0∞)-z) (hlaw i x)
    have hmass : μ (⋂ i ∈ Finset.range n, (fun ω => query ω i) ⁻¹' ({x}ᶜ)) =
        (1-p x)^n := by
      rw [hind']
      simp only [he, Finset.prod_const, Finset.card_range]
    exact (measure_mono hsub).trans_eq hmass
  have hzero : μ never = 0 := le_antisymm
    (ge_of_tendsto (ENNReal.tendsto_pow_atTop_nhds_zero_of_lt_one
      (ENNReal.sub_lt_self ENNReal.one_ne_top one_ne_zero hpx))
      (Filter.Eventually.of_forall havoid)) zero_le
  apply ae_iff.mpr
  simpa only [not_exists, never] using hzero

/-- All queries lie in the PMF's support almost surely, including zero-mass atoms. -/
theorem iid_queries_in_support [Countable X] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (p : PMF X) (query : Ω → ℕ → X)
    (hlaw : ∀ n x, μ {ω | query ω n = x} = p x) :
    ∀ᵐ ω ∂μ, ∀ n, p (query ω n) ≠ 0 := by
  have hzero : ∀ x : X, ∀ n : ℕ, ∀ᵐ ω ∂μ, p x = 0 → query ω n ≠ x := by
    intro x n
    by_cases hx : p x = 0
    · apply ae_iff.mpr
      simpa only [hx, true_implies, not_not] using (hlaw n x).trans hx
    · exact Filter.Eventually.of_forall (fun _ h => (hx h).elim)
  have hh : ∀ᵐ ω ∂μ, ∀ x : X, ∀ n : ℕ, p x = 0 → query ω n ≠ x :=
    ae_all_iff.mpr (fun x => ae_all_iff.mpr (hzero x))
  filter_upwards [hh] with ω hω n hn
  exact hω (query ω n) n hn rfl

variable {d : ℕ}

/-- Finite sets whose every element occurs have a finite covering prefix. -/
theorem exists_covering_history (query : ℕ → Input d) (A : Finset (Input d))
    (hoccurs : ∀ x ∈ A, ∃ n, query n = x)
    (hin : ∀ n, query n ∈ A) : ∃ n, history query n = A := by
  have hfinite : ∀ B : Finset (Input d),
      (∀ x ∈ B, ∃ n, query n = x) → ∃ n, B ⊆ history query n := by
    intro B
    induction B using Finset.induction_on with
    | empty => intro _; exact ⟨0, Finset.empty_subset _⟩
    | @insert x B hx ih =>
      intro ho
      obtain ⟨k, hk⟩ := ho x (Finset.mem_insert_self _ _)
      obtain ⟨n, hn⟩ := ih (fun z hz => ho z (Finset.mem_insert_of_mem hz))
      refine ⟨max (k+1) n, Finset.insert_subset ?_ ?_⟩
      · apply Finset.mem_image.mpr
        exact ⟨k, Finset.mem_range.mpr (lt_of_lt_of_le (Nat.lt_succ_self k) (le_max_left _ _)), hk⟩
      · exact hn.trans (Finset.image_subset_image (Finset.range_mono (le_max_right _ _)))
  obtain ⟨n, hn⟩ := hfinite A hoccurs
  refine ⟨n, Finset.Subset.antisymm ?_ hn⟩
  intro x hx
  obtain ⟨i, hi, rfl⟩ := Finset.mem_image.mp hx
  exact hin i

/-- An iid sequence on the Boolean cube covers its exact positive-probability
support at a finite (not necessarily bounded) time, almost surely. -/
theorem iid_finite_support_cover
    [MeasurableSpace (Input d)] [MeasurableSingletonClass (Input d)]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (p : PMF (Input d)) (query : Ω → ℕ → Input d)
    (hmeas : ∀ n, Measurable (fun ω => query ω n))
    (hind : iIndepFun (fun n ω => query ω n) μ)
    (hlaw : ∀ n x, μ {ω | query ω n = x} = p x) :
    ∀ᵐ ω ∂μ, (∀ n, p (query ω n) ≠ 0) ∧
      ∃ n, history (query ω) n = Finset.univ.filter (fun x => p x ≠ 0) := by
  have heach : ∀ᵐ ω ∂μ, ∀ x : Input d, p x ≠ 0 → ∃ n, query ω n = x := by
    apply ae_all_iff.mpr
    intro x
    by_cases hx : p x = 0
    · exact Filter.Eventually.of_forall (fun _ h => (h hx).elim)
    · exact (iid_eventually_hits_atom μ p query hmeas hind hlaw x hx).mono
        (fun ω h _ => h)
  filter_upwards [heach, iid_queries_in_support μ p query hlaw] with ω hω hin
  refine ⟨hin, exists_covering_history (query ω) _ ?_ ?_⟩
  · intro x hx
    exact hω x (Finset.mem_filter.mp hx).2
  · intro n
    exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, hin n⟩

end
end NeuralGeneralization.BatchTwoCircuitConverse
