import NeuralGeneralization.OnlineLowerPosterior
import NeuralGeneralization.OnlineLowerFiniteDraws

/-!
# Actual online mistake counts implied by the posterior limits

The expectation is the sum of the actual posterior error probabilities.
For independent fresh posterior draws, the probability that every designated
round is wrong is the finite product of those same probabilities. No random
input-order assumption occurs: the permutation is fixed throughout.

These consequences do not supply the missing target/order construction.
They turn a proved `AllLargeWidthsFail` result into literal mistake counts.
-/

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open Filter Classical

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

/-- Rounds whose correct-label probability is below the specified threshold.
At threshold `1/2`, every such round is a strict majority-prediction error. -/
def thresholdErrorRounds {d : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (π : InputOrder d) (N : ℕ) (σ θ : ℝ) :
    Finset (Fin (Fintype.card (Cube d))) := by
  classical
  exact Finset.univ.filter (fun j => correctAt φ f π N σ j < θ)

/-- Expected number of mistakes on the designated rounds under fresh draws. -/
def expectedDesignatedMistakes {d : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (π : InputOrder d) (N : ℕ) (σ : ℝ)
    (J : Finset (Fin (Fintype.card (Cube d)))) : ℝ :=
  ∑ j ∈ J, (1 - correctAt φ f π N σ j)

/-- Probability that all designated predictions are wrong when a fresh
posterior label is sampled independently at every prediction. -/
def independentAllWrongProbability {d : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (π : InputOrder d) (N : ℕ) (σ : ℝ)
    (J : Finset (Fin (Fintype.card (Cube d)))) : ℝ :=
  ∏ j ∈ J, (1 - correctAt φ f π N σ j)

/-- Actual joint weight of fresh posterior hypotheses on the designated
rounds. The posterior at a fixed revealed sequence is independent of the
previous sampled predictions. -/
def designatedJointWeight {d : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (π : InputOrder d) (N : ℕ) (σ : ℝ)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (draw : J → BooleanFunction d) : ℝ :=
  freshJointWeight (fun j : J => posteriorAt φ f π N σ j.val) draw

/-- Literal count of errors made by a joint sample of posterior hypotheses. -/
def designatedSampledMistakes {d : ℕ} (f : BooleanFunction d) (π : InputOrder d)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (draw : J → BooleanFunction d) : ℝ :=
  ∑ j : J, if draw j (π j.val) = f (π j.val) then 0 else 1

theorem designatedSampledMistakes_eq_card_of_all_wrong {d : ℕ}
    (f : BooleanFunction d) (π : InputOrder d)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (draw : J → BooleanFunction d)
    (hwrong : ∀ j : J, draw j (π j.val) ≠ f (π j.val)) :
    designatedSampledMistakes f π J draw = (J.card : ℝ) := by
  simp [designatedSampledMistakes, hwrong]

theorem designatedJointWeight_probability {d N : ℕ}
    (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d) (σ : ℝ)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (hden : ∀ j ∈ J, 0 < denominatorAt φ f π N σ j) :
    (∀ draw, 0 ≤ designatedJointWeight φ f π N σ J draw) ∧
      (∑ draw, designatedJointWeight φ f π N σ J draw) = 1 := by
  constructor
  · exact freshJointWeight_nonneg (I := J) (H := BooleanFunction d)
      (fun j : J => posteriorAt φ f π N σ j.val) (fun j g =>
      posteriorAt_nonneg_of_denominator_pos φ f π σ j.val (hden j.val j.property) g)
  · exact freshJointWeight_sum (I := J) (H := BooleanFunction d)
      (fun j : J => posteriorAt φ f π N σ j.val) (fun j =>
      posteriorAt_sum_of_denominator_pos φ f π σ j.val (hden j.val j.property))

/-- The product in `independentAllWrongProbability` is exactly the event
probability under the actual normalized finite joint posterior law. -/
theorem designated_all_wrong_probability_identity {d N : ℕ}
    (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d) (σ : ℝ)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (hden : ∀ j ∈ J, 0 < denominatorAt φ f π N σ j) :
    (∑ draw : J → BooleanFunction d,
      if ∀ j : J, draw j (π j.val) ≠ f (π j.val)
      then designatedJointWeight φ f π N σ J draw else 0) =
      independentAllWrongProbability φ f π N σ J := by
  classical
  rw [show (∑ draw : J → BooleanFunction d,
      if ∀ j : J, draw j (π j.val) ≠ f (π j.val)
      then designatedJointWeight φ f π N σ J draw else 0) =
      ∏ j : J, ∑ g, if g (π j.val) ≠ f (π j.val)
        then posteriorAt φ f π N σ j.val g else 0 from
    fresh_all_events_probability (I := J) (H := BooleanFunction d)
      (fun j : J => posteriorAt φ f π N σ j.val)
      (fun j g => g (π j.val) ≠ f (π j.val))]
  have hj (j : J) : (∑ g, if g (π j.val) ≠ f (π j.val)
      then posteriorAt φ f π N σ j.val g else 0) =
      1 - correctAt φ f π N σ j.val :=
    finite_error_complement (posteriorAt φ f π N σ j.val)
      (posteriorAt_sum_of_denominator_pos φ f π σ j.val (hden j.val j.property))
      (fun g => g (π j.val) = f (π j.val))
  simp_rw [hj]
  exact Finset.prod_coe_sort J (fun j => 1 - correctAt φ f π N σ j)

/-- The sum of error probabilities is exactly the expectation of the
literal number of sampled mistakes under that same finite joint law. -/
theorem designated_expected_count_identity {d N : ℕ}
    (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d) (σ : ℝ)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (hden : ∀ j ∈ J, 0 < denominatorAt φ f π N σ j) :
    (∑ draw : J → BooleanFunction d,
      designatedJointWeight φ f π N σ J draw * designatedSampledMistakes f π J draw) =
      expectedDesignatedMistakes φ f π N σ J := by
  classical
  rw [show (∑ draw : J → BooleanFunction d,
      designatedJointWeight φ f π N σ J draw * designatedSampledMistakes f π J draw) =
      ∑ j : J, ∑ g, posteriorAt φ f π N σ j.val g *
        (if g (π j.val) = f (π j.val) then 0 else 1) from
    fresh_expected_sum (I := J) (H := BooleanFunction d)
      (fun j : J => posteriorAt φ f π N σ j.val) (fun j =>
        posteriorAt_sum_of_denominator_pos φ f π σ j.val (hden j.val j.property))
      (fun j g => if g (π j.val) = f (π j.val) then 0 else 1)]
  have hj (j : J) : (∑ g, posteriorAt φ f π N σ j.val g *
      (if g (π j.val) = f (π j.val) then 0 else 1)) =
      1 - correctAt φ f π N σ j.val := by
    have he := finite_error_complement (posteriorAt φ f π N σ j.val)
      (posteriorAt_sum_of_denominator_pos φ f π σ j.val (hden j.val j.property))
      (fun g => g (π j.val) = f (π j.val))
    unfold correctAt correctConfidence
    rw [← he]
    apply Finset.sum_congr rfl
    intro g hg
    by_cases h : g (π j.val) = f (π j.val) <;> simp [h]
  simp_rw [hj]
  exact Finset.sum_coe_sort J (fun j => 1 - correctAt φ f π N σ j)

theorem expectedDesignatedMistakes_tendsto_card
    {d N : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (hlim : ∀ j ∈ J, Tendsto (fun σ : ℝ => correctAt φ f π N σ j)
      (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ))) :
    Tendsto (fun σ : ℝ => expectedDesignatedMistakes φ f π N σ J)
      (𝓝[>] (0 : ℝ)) (𝓝 (J.card : ℝ)) := by
  have ht (j) (hj : j ∈ J) :
      Tendsto (fun σ : ℝ => (1 : ℝ) - correctAt φ f π N σ j)
        (𝓝[>] (0 : ℝ)) (𝓝 ((1 : ℝ) - 0)) :=
    tendsto_const_nhds.sub (hlim j hj)
  simpa [expectedDesignatedMistakes] using tendsto_finsetSum J ht

theorem independentAllWrongProbability_tendsto_one
    {d N : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (hlim : ∀ j ∈ J, Tendsto (fun σ : ℝ => correctAt φ f π N σ j)
      (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ))) :
    Tendsto (fun σ : ℝ => independentAllWrongProbability φ f π N σ J)
      (𝓝[>] (0 : ℝ)) (𝓝 (1 : ℝ)) := by
  have ht (j) (hj : j ∈ J) :
      Tendsto (fun σ : ℝ => (1 : ℝ) - correctAt φ f π N σ j)
        (𝓝[>] (0 : ℝ)) (𝓝 ((1 : ℝ) - 0)) :=
    tendsto_const_nhds.sub (hlim j hj)
  simpa [independentAllWrongProbability] using tendsto_finsetProd J ht

/-- Every fixed positive correctness threshold counts all designated rounds
as errors at a common sufficiently small prior scale. -/
theorem finite_scale_threshold_error_count
    {d N : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (hlim : ∀ j ∈ J, Tendsto (fun σ : ℝ => correctAt φ f π N σ j)
      (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ))) (θ : ℝ) (hθ : 0 < θ) :
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      J.card ≤ (thresholdErrorRounds φ f π N σ θ).card := by
  classical
  obtain ⟨σ₀, hσ₀, hsmall⟩ := finite_designated_scale φ f π J hlim θ hθ
  refine ⟨σ₀, hσ₀, ?_⟩
  intro σ hσ hσlt
  apply Finset.card_le_card
  intro j hj
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, hsmall σ hσ hσlt j hj⟩

/-- Finite-scale, high-probability version for independent fresh predictions. -/
theorem finite_scale_all_wrong_probability
    {d N : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (hlim : ∀ j ∈ J, Tendsto (fun σ : ℝ => correctAt φ f π N σ j)
      (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ))) (η : ℝ) (hη : 0 < η) :
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      1 - η < independentAllWrongProbability φ f π N σ J := by
  have ht := independentAllWrongProbability_tendsto_one φ f π J hlim
  have he := ht.eventually (lt_mem_nhds (by linarith : 1 - η < (1 : ℝ)))
  obtain ⟨σ₀, hσ₀, hsub⟩ := mem_nhdsGT_iff_exists_Ioo_subset.mp he
  exact ⟨σ₀, hσ₀, fun σ hσ hσlt => hsub ⟨hσ, hσlt⟩⟩

/-- The product above lies in `[0,1]` whenever every actual posterior is
normalized. This applies to every positive scale in `AllLargeWidthsFail`. -/
theorem independentAllWrongProbability_mem_Icc
    {d N : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d)
    (σ : ℝ) (J : Finset (Fin (Fintype.card (Cube d))))
    (hden : ∀ j ∈ J, 0 < denominatorAt φ f π N σ j) :
    independentAllWrongProbability φ f π N σ J ∈ Set.Icc (0 : ℝ) 1 := by
  have hprob (j) (hj : j ∈ J) := correctAt_mem_Icc_of_denominator_pos φ f π σ j (hden j hj)
  constructor
  · exact Finset.prod_nonneg (fun j hj => sub_nonneg.mpr (hprob j hj).2)
  · exact Finset.prod_le_one (fun j hj => sub_nonneg.mpr (hprob j hj).2)
      (fun j hj => by linarith [(hprob j hj).1])

/-- The literal count consequences at all large widths, with the width fixed
before the scale limit. The third clause includes majority prediction at
`θ = 1/2`, and the fourth gives at least `J.card` sampled errors with
probability approaching one. -/
theorem AllLargeWidthsFail.mistake_count_limits
    {d C : ℕ} {φ : ℝ → ℝ} {f : BooleanFunction d} {π : InputOrder d}
    {J : Finset (Fin (Fintype.card (Cube d)))}
    (hfail : AllLargeWidthsFail φ f C π J) :
    ∃ N₀ : ℕ, C ≤ N₀ ∧ 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N →
      Tendsto (fun σ : ℝ => expectedDesignatedMistakes φ f π N σ J)
        (𝓝[>] (0 : ℝ)) (𝓝 (J.card : ℝ)) ∧
      Tendsto (fun σ : ℝ => independentAllWrongProbability φ f π N σ J)
        (𝓝[>] (0 : ℝ)) (𝓝 (1 : ℝ)) ∧
      (∀ θ : ℝ, 0 < θ → ∃ σ₀ : ℝ, 0 < σ₀ ∧
        ∀ σ : ℝ, 0 < σ → σ < σ₀ →
          J.card ≤ (thresholdErrorRounds φ f π N σ θ).card) ∧
      (∀ η : ℝ, 0 < η → ∃ σ₀ : ℝ, 0 < σ₀ ∧
        ∀ σ : ℝ, 0 < σ → σ < σ₀ →
          1 - η < independentAllWrongProbability φ f π N σ J) := by
  obtain ⟨N₀, hCN₀, hN₀, hlarge⟩ := hfail
  refine ⟨N₀, hCN₀, hN₀, ?_⟩
  intro N hN
  have hlim := (hlarge N hN).2
  exact ⟨expectedDesignatedMistakes_tendsto_card φ f π J hlim,
    independentAllWrongProbability_tendsto_one φ f π J hlim,
    finite_scale_threshold_error_count φ f π J hlim,
    finite_scale_all_wrong_probability φ f π J hlim⟩

end NeuralGeneralization.OnlineLower
