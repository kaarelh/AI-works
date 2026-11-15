import NeuralGeneralization.OnlineLowerReluLayerVariance

/-! The paper's optional arbitrary-positive-layer-variance extension,
for the actual Gaussian posterior and the original explicit width threshold. -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerRelu
open ConcreteModel OnlineLower

theorem twoLayer_networkPosterior_eq_smallPrior {d N n : ℕ}
    (hd : 0 < d) (hN : 0 < N) (α β : ℝ) (hα : 0 < α) (hβ : 0 < β)
    (σ a : ℝ) (f : BooleanFunction d) (s : Fin n → Cube d) :
    networkPosterior relu a (twoLayerPrior d N α β σ) f s =
      networkPosterior relu a (smallPrior d N 0 (layerScaleFactor d α β*σ)) f s := by
  unfold networkPosterior
  congr 1
  funext g
  exact twoLayer_functionMass_eq_smallPrior hd hN α β hα hβ σ a g

theorem twoLayer_denominator_eq_smallPrior {d N n : ℕ}
    (hd : 0 < d) (hN : 0 < N) (α β : ℝ) (hα : 0 < α) (hβ : 0 < β)
    (σ a : ℝ) (f : BooleanFunction d) (s : Fin n → Cube d) :
    posteriorDenominator relu a (twoLayerPrior d N α β σ) f s =
      posteriorDenominator relu a (smallPrior d N 0 (layerScaleFactor d α β*σ)) f s := by
  unfold posteriorDenominator
  congr 1
  funext g
  exact twoLayer_functionMass_eq_smallPrior hd hN α β hα hβ σ a g

/-- Confidence for the same global-margin and exact-sign learner, with
literal variances ασ² and βσ² for incoming and readout weights respectively. -/
def twoLayerCorrectAt {d : ℕ} (f : BooleanFunction d) (π : InputOrder d)
    (N : ℕ) (α β σ : ℝ) (j : Fin (Fintype.card (Cube d))) : ℝ :=
  correctConfidence f (networkPosterior relu (1/2) (twoLayerPrior d N α β σ)
    f (observedPrefix π j)) (π j)

def twoLayerDenominatorAt {d : ℕ} (f : BooleanFunction d) (π : InputOrder d)
    (N : ℕ) (α β σ : ℝ) (j : Fin (Fintype.card (Cube d))) : ℝ :=
  posteriorDenominator relu (1/2) (twoLayerPrior d N α β σ) f (observedPrefix π j)

theorem twoLayerCorrectAt_eq {d N : ℕ} (hd : 0 < d) (hN : 0 < N)
    (f : BooleanFunction d) (π : InputOrder d) (α β : ℝ)
    (hα : 0 < α) (hβ : 0 < β) (σ : ℝ) (j : Fin (Fintype.card (Cube d))) :
    twoLayerCorrectAt f π N α β σ j =
      OnlineLower.correctAt relu f π N (layerScaleFactor d α β*σ) j := by
  unfold twoLayerCorrectAt OnlineLower.correctAt posteriorAt
  rw [twoLayer_networkPosterior_eq_smallPrior hd hN α β hα hβ]

theorem tendsto_positive_scale_zero (c : ℝ) (hc : 0 < c) :
    Tendsto (fun σ : ℝ=>c*σ) (𝓝[>] (0:ℝ)) (𝓝[>] (0:ℝ)) := by
  change Filter.map (fun σ : ℝ=>c*σ) (𝓝[>] (0:ℝ)) ≤ (𝓝[>] (0:ℝ))
  rw [Filter.map_le_iff_le_comap,comap_mulLeft_nhdsGT_zero hc]

/-- For every fixed width above the original explicit threshold, every pair
of positive layer variances gives the same zero-correct-confidence limit.
The variances may therefore be selected separately at each fixed width. -/
theorem arbitrary_layer_variances_of_protocol {k : ℕ}
    {π : InputOrder (reluConcreteDimension k)}
    {J : Finset (Fin (Fintype.card (Cube (reluConcreteDimension k))))}
    (h : ReluConcreteProtocol k π J) (N : ℕ) (hN : reluConcreteThreshold k ≤ N)
    (α β : ℝ) (hα : 0 < α) (hβ : 0 < β) :
    (∀ σ : ℝ,0 < σ → ∀ j,0 < twoLayerDenominatorAt (reluConcreteTarget k) π N α β σ j) ∧
    (∀ j ∈ J,Tendsto (fun σ : ℝ=>twoLayerCorrectAt (reluConcreteTarget k) π N α β σ j)
      (𝓝[>] (0:ℝ)) (𝓝 (0:ℝ))) := by
  have hd := reluConcreteDimension_pos k
  have hNp := (reluConcreteThreshold_pos k).trans_le hN
  have hq := layerScaleFactor_pos hd hα hβ
  constructor
  · intro σ hσ j
    unfold twoLayerDenominatorAt
    rw [twoLayer_denominator_eq_smallPrior hd hNp α β hα hβ]
    exact (h.2 N hN).1 _ (mul_pos hq hσ) j
  · intro j hj
    have ht := ((h.2 N hN).2 j hj).comp
      (tendsto_positive_scale_zero _ hq)
    simpa only [Function.comp_def,←twoLayerCorrectAt_eq hd hNp _ _ α β hα hβ] using ht

/-- Complete existence theorem for every positive pair of layer variances,
with the original target, teacher resources, count, and explicit width threshold. -/
theorem relu_arbitrary_layer_variance_main :
    ∃ k₀ : ℕ,3 ≤ k₀ ∧ ∀ k : ℕ,k₀ ≤ k →
      BoundedTeacher relu (reluConcreteTarget k) (reluConcreteTeacherWidth k) ∧
      HasCircuitAtMost (reluConcreteTarget k) (17*reluConcreteDimension k+5) ∧
      ∃ π : InputOrder (reluConcreteDimension k),
      ∃ J : Finset (Fin (Fintype.card (Cube (reluConcreteDimension k)))),
        ReluConcreteProtocol k π J ∧
        ∀ N : ℕ,reluConcreteThreshold k ≤ N → ∀ α β : ℝ,0 < α → 0 < β →
          (∀ σ : ℝ,0 < σ → ∀ j,0 < twoLayerDenominatorAt (reluConcreteTarget k) π N α β σ j) ∧
          (∀ j ∈ J,Tendsto (fun σ : ℝ=>twoLayerCorrectAt (reluConcreteTarget k) π N α β σ j)
            (𝓝[>] (0:ℝ)) (𝓝 (0:ℝ))) := by
  obtain ⟨k₀,hk₀,hfamily⟩ := relu_concrete_main
  refine ⟨k₀,hk₀,?_⟩
  intro k hk
  obtain ⟨ht,hc,π,J,hprotocol⟩ := hfamily k hk
  exact ⟨ht,hc,π,J,hprotocol,arbitrary_layer_variances_of_protocol hprotocol⟩

/-- Actual finite joint probability of the specified number of mistakes under
independent fresh posterior draws with arbitrary positive layer variances. -/
def twoLayerAtLeastProbability {d : ℕ} (f : BooleanFunction d) (π : InputOrder d)
    (N : ℕ) (α β σ : ℝ) (J : Finset (Fin (Fintype.card (Cube d)))) (T : ℕ) : ℝ :=
  ∑ draw : J → BooleanFunction d,
    if (T:ℝ) ≤ designatedSampledMistakes f π J draw then
      freshJointWeight (fun j : J => networkPosterior relu (1/2) (twoLayerPrior d N α β σ)
        f (observedPrefix π j.val)) draw else 0

theorem twoLayerAtLeastProbability_eq {d N : ℕ} (hd : 0 < d) (hN : 0 < N)
    (f : BooleanFunction d) (π : InputOrder d) (α β : ℝ)
    (hα : 0 < α) (hβ : 0 < β) (σ : ℝ)
    (J : Finset (Fin (Fintype.card (Cube d)))) (T : ℕ) :
    twoLayerAtLeastProbability f π N α β σ J T =
      designatedAtLeastProbability relu f π N (layerScaleFactor d α β*σ) J T := by
  unfold twoLayerAtLeastProbability designatedAtLeastProbability designatedJointWeight posteriorAt
  simp_rw [twoLayer_networkPosterior_eq_smallPrior hd hN α β hα hβ]

/-- All three finite-scale prediction conclusions transfer to the literal
arbitrary-layer-variance posterior at one common positive threshold. -/
theorem arbitrary_layer_variances_finite_scale {k N : ℕ}
    {π : InputOrder (reluConcreteDimension k)}
    {J : Finset (Fin (Fintype.card (Cube (reluConcreteDimension k))))}
    (h : ReluConcreteProtocol k π J) (hN : reluConcreteThreshold k ≤ N)
    (α β : ℝ) (hα : 0 < α) (hβ : 0 < β) (η : ℝ) (hη : 0 < η) :
    ∃ σ₀ : ℝ,0 < σ₀ ∧ ∀ σ : ℝ,0 < σ → σ < σ₀ →
      (1-η < twoLayerAtLeastProbability (reluConcreteTarget k) π N α β σ J (reluConcreteCount k)) ∧
      (∀ j ∈ J,twoLayerCorrectAt (reluConcreteTarget k) π N α β σ j < (1/2:ℝ) ∧
        twoLayerCorrectAt (reluConcreteTarget k) π N α β σ j < (2/3:ℝ)) := by
  have hd := reluConcreteDimension_pos k
  have hNp := (reluConcreteThreshold_pos k).trans_le hN
  have hq := layerScaleFactor_pos hd hα hβ
  obtain ⟨σ₁,hσ₁,hsmall⟩ := h.finite_scale hN η hη
  refine ⟨σ₁/layerScaleFactor (reluConcreteDimension k) α β,div_pos hσ₁ hq,?_⟩
  intro σ hσ hσlt
  have hs : layerScaleFactor (reluConcreteDimension k) α β*σ < σ₁ := by
    simpa only [mul_comm] using (lt_div_iff₀ hq).mp hσlt
  have hh := hsmall _ (mul_pos hq hσ) hs
  simpa only [twoLayerAtLeastProbability_eq hd hNp _ _ α β hα hβ,
    twoLayerCorrectAt_eq hd hNp _ _ α β hα hβ] using hh

end NeuralGeneralization.OnlineLowerRelu
