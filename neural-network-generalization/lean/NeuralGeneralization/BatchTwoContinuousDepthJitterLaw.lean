import NeuralGeneralization.BatchTwoContinuousDepthJitterGeometry
import NeuralGeneralization.BatchTwoContinuousDepthStrongConcentration

/-! Independent bounded jitter preserves the balanced pairing obstruction.
The results here apply to every probability law on the stated jitter interval. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set Filter MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal ENNReal Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous BatchTwoParameterPriorRate

variable (r : ℕ) (ν : Measure (Jitter r)) [IsProbabilityMeasure ν]

def jitteredScalar (r : ℕ) (z : SignStream × Jitter r) : ℝ := scalarCoding z.1 + z.2.val

theorem jitteredScalar_measurable : Measurable (jitteredScalar r) :=
  (scalarCoding_measurable.comp measurable_fst).add (measurable_subtype_coe.comp measurable_snd)

theorem jitteredCoding_measurable : Measurable (jitteredCoding r) :=
  sphereArc_continuous.measurable.comp (jitteredScalar_measurable r)

def jitteredScalarLaw : Measure ℝ := (signLaw.prod ν).map (jitteredScalar r)
def jitteredInputLaw : Measure (RealInput 2) := (signLaw.prod ν).map (jitteredCoding r)

instance jitteredScalarLaw_probability : IsProbabilityMeasure (jitteredScalarLaw r ν) :=
  Measure.isProbabilityMeasure_map (jitteredScalar_measurable r).aemeasurable
instance jitteredInputLaw_probability : IsProbabilityMeasure (jitteredInputLaw r ν) :=
  Measure.isProbabilityMeasure_map (jitteredCoding_measurable r).aemeasurable

theorem jitteredInputLaw_scalar : (jitteredInputLaw r ν).map (fun x => x 0) =
    jitteredScalarLaw r ν := by
  rw [jitteredInputLaw, Measure.map_map (measurable_pi_apply 0) (jitteredCoding_measurable r)]
  rfl

theorem jitteredInputLaw_arc : (jitteredScalarLaw r ν).map sphereArc = jitteredInputLaw r ν := by
  rw [jitteredScalarLaw, Measure.map_map sphereArc_continuous.measurable (jitteredScalar_measurable r)]
  rfl

theorem jitteredInputLaw_sphere : (jitteredInputLaw r ν) {x | ∑ i, x i^2 = 1} = 1 := by
  rw [jitteredInputLaw, Measure.map_apply (jitteredCoding_measurable r)
    (measurableSet_eq_fun (by fun_prop) measurable_const)]
  have he : jitteredCoding r ⁻¹' {x | ∑ i, x i^2 = 1} = univ := by
    ext z
    simp only [mem_preimage, mem_setOf_eq, mem_univ, iff_true]
    exact jitteredCoding_on_sphere r z
  rw [he, measure_univ]

theorem jitteredInputLaw_label_bound :
    ∀ᵐ x ∂jitteredInputLaw r ν, |depthTarget r x| ≤ (13/20 : ℝ) := by
  unfold depthTarget
  rw [jitteredInputLaw, ae_map_iff (jitteredCoding_measurable r).aemeasurable
    (measurableSet_le (continuous_target r).measurable.abs measurable_const)]
  exact Filter.Eventually.of_forall (jittered_label_bound r)

def jitterFlip (r : ℕ) : SignStream × Jitter r → SignStream × Jitter r :=
  Prod.map (flipCoordinate r) id

theorem jitterFlip_measurable : Measurable (jitterFlip r) :=
  (flipCoordinate_measurable r).prodMap measurable_id

theorem jitterFlip_preserves : (signLaw.prod ν).map (jitterFlip r) = signLaw.prod ν := by
  rw [jitterFlip, ← Measure.map_prod_map _ _ (flipCoordinate_measurable r) measurable_id,
    signLaw_flip, Measure.map_id]

theorem jitteredInputLaw_balanced_pair :
    balancedPairLaw (signLaw.prod ν) (jitteredCoding r) (jitteredCoding r ∘ jitterFlip r) =
      jitteredInputLaw r ν := by
  have he : (signLaw.prod ν).map (jitteredCoding r ∘ jitterFlip r) = jitteredInputLaw r ν := by
    rw [← Measure.map_map (jitteredCoding_measurable r) (jitterFlip_measurable r),
      jitterFlip_preserves]
    rfl
  rw [balancedPairLaw, he]
  change (1/2 : ℝ≥0) • jitteredInputLaw r ν + (1/2 : ℝ≥0) • jitteredInputLaw r ν = _
  rw [← add_smul]
  norm_num

/-- Literal confidence-failure mass for arbitrary posterior mixtures after jitter. -/
theorem jitteredInputLaw_mixture_barrier {W : Type*} [MeasurableSpace W]
    (Q : Measure W) [IsProbabilityMeasure Q] (z : W → RealInput 2 → ℝ)
    (hz : ∀ x, Measurable (fun w => z w x)) (G : Set W)
    (hbad : Q.real Gᶜ ≤ (1/3 : ℝ))
    (hgood : ∀ w ∈ G, ∃ g : RealInput 2 → ℝ,
      (∀ x, (∑ i, x i^2=1) → |z w x-g x|≤(1/32 : ℝ)) ∧
      (∀ x y, |g x-g y|≤((3:ℝ)^r/10)*inputDistance x y))
    (hq : Measurable (fun x => Q.real {w | |z w x-depthTarget r x|≤(1/4 : ℝ)})) :
    (1/2 : ℝ) ≤ (jitteredInputLaw r ν).real
      {x | Q.real {w | |z w x-depthTarget r x|≤(1/4 : ℝ)}≤2/3} := by
  rw [← jitteredInputLaw_balanced_pair r ν]
  apply paired_confidence_failure (signLaw.prod ν) (jitteredCoding r)
    (jitteredCoding r ∘ jitterFlip r) (jitteredCoding_measurable r)
    ((jitteredCoding_measurable r).comp (jitterFlip_measurable r)) _ hq (2/3)
  intro ω
  have h := posterior_pair_sum_le Q z hz (depthTarget r) G hbad
    (jitteredCoding r ω) (jitteredCoding r (jitterFlip r ω)) (by
      intro w hw
      obtain ⟨g, hclose, hlip⟩ := hgood w hw
      apply jittered_approximate_pair_incompatible (jittered_pair_target_gap r ω)
      · have hscale : ((3:ℝ)^r/10)*((13/5 : ℝ)*(1/3)^r) = 13/50 := by
          have hp : (3:ℝ)^r≠0 := by positivity
          rw [one_div,inv_pow]
          field_simp
          <;> ring
        exact (hlip _ _).trans ((mul_le_mul_of_nonneg_left (jittered_pair_distance r ω)
          (by positivity)).trans_eq hscale)
      · exact hclose _ (jitteredCoding_on_sphere r ω)
      · exact hclose _ (jitteredCoding_on_sphere r (jitterFlip r ω))
      · exact le_rfl)
  change _+_≤2*(2/3 : ℝ)
  norm_num only at *
  exact h

/-- The actual small-Gaussian posterior inherits the same strong-prior barrier. -/
theorem jittered_strong_prior_barrier_of_witness {N r n : ℕ}
    (ν : Measure (Jitter (r+2))) [IsProbabilityMeasure ν] (hN : 0 < N)
    (s : Fin n → RealInput 2) (w : Weights 2 N (r+1))
    (hw : w ∈ trainingEvent Real.tanh (depthTarget (r+2)) (1/8) s)
    (hcost : weightedSquaredNorm w ≤ 4*(r : ℝ)+5)
    (hdepth : (2 : ℝ)^(r+3)≤(3 : ℝ)^(r+2)/10) :
    ∀ᶠ σ in 𝓝[>] (0 : ℝ),
      (1/2 : ℝ) ≤ BatchTwoContinuous.confidenceFailure Real.tanh (jitteredInputLaw (r+2) ν)
        (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ) (depthTarget (r+2)) (1/8) s)
        (depthTarget (r+2)) (1/4) := by
  filter_upwards [posterior_energy_concentration (by norm_num) hN _ s w hw hcost] with σ hσ
  let Q := BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ) (depthTarget (r+2)) (1/8) s
  letI : IsProbabilityMeasure Q := hσ.1
  let G : Set (Weights 2 N (r+1)) := {v | weightedSquaredNorm v ≤ 4*(r : ℝ)+6}
  apply jitteredInputLaw_mixture_barrier (r+2) ν Q (output Real.tanh)
    (fun x => (continuous_output_weights tanh_lipschitzWith.continuous x).measurable) G
  · simpa only [G,Set.compl_setOf,not_le,show (4*(r : ℝ)+5)+1=4*(r : ℝ)+6 by ring] using hσ.2
  · intro v hv
    refine ⟨output Real.tanh v,?_,?_⟩
    · intro x _
      simp
    · intro x y
      have hc : weightedSquaredNorm v ≤ 4*(((r+1 : ℕ) : ℝ)+2) := by
        dsimp [G] at hv
        push_cast
        linarith
      have h := output_energy_lipschitz hN v hc x y
      have he : r+1+2=r+3 := by omega
      rw [he] at h
      exact h.trans (mul_le_mul_of_nonneg_right hdepth (by unfold inputDistance; positivity))
  · exact measurable_correctProbability tanh_lipschitzWith.continuous Q
      (continuous_target (r+2)).measurable (1/4)

end NeuralGeneralization.BatchTwoContinuousDepthLower
