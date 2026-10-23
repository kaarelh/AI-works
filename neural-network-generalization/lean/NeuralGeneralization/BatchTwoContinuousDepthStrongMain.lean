import NeuralGeneralization.BatchTwoContinuousDepthMemorizer
import NeuralGeneralization.BatchTwoContinuousDepthResourceDecay
import NeuralGeneralization.BatchTwoContinuousDepthSampleMeasurability
import Mathlib.MeasureTheory.Measure.Support

/-! The strong-prior main theorem of the continuous depth lower-bound paper.
The fixed input law, actual width-three bounded-weight teacher, unrestricted
Gaussian prior, tolerance conditioning, and posterior confidence criterion
are all the literal objects from the manuscript. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Topology ENNReal
open MeasureTheory ProbabilityTheory Filter
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

theorem depthTarget_support_bound (r : ℕ) (x : RealInput 2) (hx : x∈inputLaw.support) :
    |depthTarget r x| ≤ 13/20 :=
  Measure.support_subset_of_isClosed
    (isClosed_le (continuous_target r).abs continuous_const) (depthTarget_ae_bound r) hx

theorem separatedSample_measurable (n : ℕ) : MeasurableSet (separatedSample n) := by
  simp only [separatedSample,Set.setOf_forall]
  apply MeasurableSet.iInter
  intro i
  apply MeasurableSet.iInter
  intro j
  apply MeasurableSet.iInter
  intro _
  exact measurableSet_le measurable_const (by fun_prop)

theorem iid_sample_bounds (r n : ℕ) :
    ∀ᵐ s ∂(Measure.pi (fun _ : Fin n => inputLaw)),
      (∀ i, |s i 0| ≤ 1) ∧ (∀ i, |depthTarget r (s i)| ≤ 13/20) := by
  have hi : ∀ᵐ x ∂inputLaw, |x 0| ≤ 1 := by
    filter_upwards [depthTarget_ae_bound 0] with x hx
    change |x 0| ≤ 13/20 at hx
    exact hx.trans (by norm_num)
  have ha : ∀ᵐ s ∂(Measure.pi (fun _ : Fin n => inputLaw)), ∀ i, |s i 0| ≤ 1 := by
    apply eventually_all.mpr
    intro i
    exact (Measure.tendsto_eval_ae_ae (μ := fun _ : Fin n => inputLaw) (i := i)).eventually hi
  have hb : ∀ᵐ s ∂(Measure.pi (fun _ : Fin n => inputLaw)), ∀ i, |depthTarget r (s i)| ≤ 13/20 := by
    apply eventually_all.mpr
    intro i
    exact (Measure.tendsto_eval_ae_ae (μ := fun _ : Fin n => inputLaw) (i := i)).eventually (depthTarget_ae_bound r)
  exact ha.and hb

/-- For almost every separated sample, the actual posterior has confidence
error at least one half for all sufficiently small positive scales. -/
theorem separated_sample_strong_prior_failure {r n N : ℕ}
    (hr : max 6 interpolationDepthThreshold ≤ r) (hn : 0 < n)
    (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100))
    (hN : interpolationWidth n ≤ N) :
    ∀ᵐ s ∂(Measure.pi (fun _ : Fin n => inputLaw)), s∈separatedSample n →
      ∀ᶠ σ in 𝓝[>] (0 : ℝ),
      (1/2 : ℝ) ≤ BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
        (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ)
          (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4) := by
  filter_upwards [iid_sample_bounds (r+2) n] with s hs
  intro hsep
  have hwidth := interpolationWidth_ge hn
  obtain ⟨w,hw,hcost⟩ := exists_channel_memorizer hn hN hwidth.1
    (sampleSeparation_pos hn) ((sampleSeparation_le hn).trans (by norm_num)) s
    (fun i => depthTarget (r+2) (s i)) hs.1 hs.2 hsep hwidth.2
    (interpolation_channel_energy_small hn (le_trans (le_max_right _ _) hr) hnr)
  have hNpos : 0 < N := by omega
  apply strong_prior_barrier_of_witness hNpos s w ?_ hcost
    (channel_lipschitz_below_teacher_expansion (le_trans (le_max_left _ _) hr))
  intro i
  rw [hw]
  norm_num

/-- Exact strong-prior lower limit, in extended-real measure form. -/
theorem strong_prior_sample_lower_bound_ennreal {r n N : ℕ}
    (hr : max 6 interpolationDepthThreshold ≤ r) (hn : 0 < n)
    (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100))
    (hN : interpolationWidth n ≤ N) :
    ENNReal.ofReal (49/50 : ℝ) ≤
      liminf (fun σ : ℝ => (Measure.pi (fun _ : Fin n => inputLaw))
        {s | (1/2 : ℝ) ≤ BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
          (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ)
            (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4)}) (𝓝[>] (0 : ℝ)) := by
  have hp := separatedSample_probability hn
  have hpE : ENNReal.ofReal (49/50 : ℝ) ≤
      (Measure.pi (fun _ : Fin n => inputLaw)) (separatedSample n) :=
    (ENNReal.ofReal_le_iff_le_toReal (measure_ne_top _ _)).2 hp
  apply hpE.trans
  apply measure_event_le_liminf _ (separatedSample n) (separatedSample_measurable n)
  · intro σ
    exact measurableSet_le measurable_const
      (measurable_sample_confidenceFailure (smallPrior 2 N (r+1) σ) inputLaw
        (depthTarget (r+2)) (continuous_target (r+2)) (1/8) (1/4))
  · exact separated_sample_strong_prior_failure hr hn hnr hN

/-- The literal real-probability conclusion of the strong-prior main theorem.
The teacher has depth `r+3`, so the sample range is `exp((depth-1)/100)`. -/
theorem strong_prior_sample_lower_bound {r n N : ℕ}
    (hr : max 6 interpolationDepthThreshold ≤ r) (hn : 0 < n)
    (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100))
    (hN : interpolationWidth n ≤ N) :
    (49/50 : ℝ) ≤
      liminf (fun σ : ℝ => (Measure.pi (fun _ : Fin n => inputLaw)).real
        {s | (1/2 : ℝ) ≤ BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
          (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ)
            (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4)}) (𝓝[>] (0 : ℝ)) := by
  let A := fun σ : ℝ => {s : Fin n → RealInput 2 |
    (1/2 : ℝ) ≤ BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
      (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ)
        (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4)}
  let μ := Measure.pi (fun _ : Fin n => inputLaw)
  have hbd : ∀ᶠ σ : ℝ in 𝓝[>] (0 : ℝ), μ (A σ) ≤ 1 := Eventually.of_forall (fun σ => prob_le_one)
  have hlim : liminf (fun σ => μ (A σ)) (𝓝[>] (0 : ℝ)) ≤ 1 :=
    liminf_le_of_frequently_le' hbd.frequently
  have htop : liminf (fun σ => μ (A σ)) (𝓝[>] (0 : ℝ))≠∞ := ne_top_of_le_ne_top (by simp) hlim
  have h := (ENNReal.ofReal_le_iff_le_toReal htop).1
    (strong_prior_sample_lower_bound_ennreal hr hn hnr hN)
  rw [← ENNReal.liminf_toReal_eq (by simp : (1 : ℝ≥0∞)≠∞) hbd] at h
  exact h

/-- The target of the lower bound is an actual bounded-weight width-three
teacher at the same depth as the learner. -/
theorem strong_prior_target_implementation (r : ℕ) :
    (∀ x : RealInput 2, output Real.tanh (teacherWeights (r+1)) x=depthTarget (r+2) x) ∧
    boundedWeights 30 (teacherWeights (r+1)) ∧
    (∀ x∈inputLaw.support, |depthTarget (r+2) x|≤13/20) := by
  refine ⟨?_,teacher_weights_bounded (r+1),depthTarget_support_bound (r+2)⟩
  intro x
  exact teacher_output (r+1) x

/-- The main result in the manuscript's original depth index: `R` iterations,
teacher and learner depth `R+1`, at every width `N ≥ max {30,M_n}`. -/
theorem strong_prior_depth_lower_bound :
    ∃ R₀ : ℕ, ∀ R ≥ R₀, ∀ n N : ℕ,
      0 < n → (n : ℝ) ≤ Real.exp ((R : ℝ)/100) → max 30 (interpolationWidth n) ≤ N →
      (49/50 : ℝ) ≤
        liminf (fun σ : ℝ => (Measure.pi (fun _ : Fin n => inputLaw)).real
          {s | (1/2 : ℝ) ≤ BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
            (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (R-1) σ)
              (depthTarget R) (1/8) s) (depthTarget R) (1/4)}) (𝓝[>] (0 : ℝ)) := by
  refine ⟨max 6 interpolationDepthThreshold+2,?_⟩
  intro R hR n N hn hnr hN
  have hR2 : 2 ≤ R := by omega
  obtain ⟨r,hr⟩ := Nat.exists_eq_add_of_le hR2
  have he : R=r+2 := by omega
  cases he
  have hh := strong_prior_sample_lower_bound (r := r) (by omega) hn
    (by simpa only [Nat.cast_add,Nat.cast_ofNat] using hnr) (le_trans (le_max_right _ _) hN)
  have hi : r+2-1=r+1 := by omega
  have heq := congrArg (fun q : ℕ =>
    liminf (fun σ : ℝ => (Measure.pi (fun _ : Fin n => inputLaw)).real
      {s | (1/2 : ℝ) ≤ BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
        (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N q σ)
          (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4)}) (𝓝[>] (0 : ℝ))) hi
  rw [heq]
  exact hh

/-- The teacher witnesses exist at every positive iteration depth, including
the finitely many depths before the lower-bound threshold. -/
theorem target_implementation_all_depths {R : ℕ} (hR : 0 < R) :
    (∀ x : RealInput 2, output Real.tanh (teacherWeights (R-1)) x=depthTarget R x) ∧
    boundedWeights 30 (teacherWeights (R-1)) ∧
    (∀ x∈inputLaw.support, |depthTarget R x|≤13/20) := by
  refine ⟨?_,teacher_weights_bounded (R-1),depthTarget_support_bound R⟩
  intro x
  have h := teacher_output (R-1) x
  simpa only [show R-1+1=R by omega,depthTarget] using h

end NeuralGeneralization.BatchTwoContinuousDepthLower
