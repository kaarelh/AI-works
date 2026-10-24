import NeuralGeneralization.BatchTwoContinuousDepthPowerMemorizerMass
import NeuralGeneralization.BatchTwoContinuousDepthSlowSample

/-! A single measurable high-probability sample event with a sharp Gaussian
normalizer lower bound at every width and every admissible scale. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1400000
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoContinuous BatchTwoNonGaussian BatchTwoContinuousDepthLower

def powerInterpolationSamples (r n : ℕ) : Set (Fin n → RealInput 2) :=
  slowInterpolationSamples r n ∩ {s | ∀i,∑j,s i j^2≤1}

theorem powerInterpolationSamples_measurable (r n : ℕ) :
    MeasurableSet (powerInterpolationSamples r n) := by
  apply (slowInterpolationSamples_measurable r n).inter
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro i
  exact measurableSet_le (by fun_prop) measurable_const

theorem iid_sample_unit_ball (n : ℕ) :
    ∀ᵐ s ∂(Measure.pi (fun _ : Fin n => inputLaw)), ∀i,∑j,s i j^2≤1 := by
  have he : ∀ᵐ x ∂inputLaw, ∑j,x j^2=1 :=
    (mem_ae_iff_prob_eq_one (measurableSet_eq_fun (by fun_prop) measurable_const)).mpr inputLaw_sphere
  apply eventually_all.mpr
  intro i
  filter_upwards [(Measure.tendsto_eval_ae_ae (μ := fun _ : Fin n => inputLaw) (i := i)).eventually he] with s hs
  exact hs.le

theorem powerInterpolationSamples_probability {n : ℕ} (hn : 0<n) (r : ℕ) :
    (49/50 : ℝ)≤(Measure.pi (fun _ : Fin n=>inputLaw)).real (powerInterpolationSamples r n) := by
  have he : powerInterpolationSamples r n =ᵐ[Measure.pi (fun _ : Fin n=>inputLaw)]
      slowInterpolationSamples r n := by
    filter_upwards [iid_sample_unit_ball n] with s hs
    exact propext (and_iff_left hs)
  rw [measureReal_congr he]
  exact slowInterpolationSamples_probability hn r

theorem sample_event_sharp_denominator {r n N : ℕ} (hr : sharpInterpolationDepthThreshold≤r)
    (hn : 0<n) (hnr : (n : ℝ)≤Real.exp (((r : ℝ)+2)/100))
    (hN : interpolationWidth n≤N) (s : Fin n→RealInput 2)
    (hs : s∈powerInterpolationSamples r n) {ρ σ : ℝ} (hρ : 0<ρ) (hσ : 0<σ)
    (hscale : (N : ℝ)*σ^2≤1) :
    Real.exp (-slowEnergyCeiling r/(2*σ^2)-(N : ℝ)*slowEntropyCost (interpolationWidth n) r ρ) ≤
      (ConcreteModel.smallPrior 2 N (r+1) σ).real
        (trainingEvent Real.tanh (depthTarget (r+2)) ρ s) := by
  obtain ⟨w,hw,henergy,hout⟩ := slow_memorizer_on_sample_event hr hn hnr
    (le_refl (interpolationWidth n)) s hs.1
  have hwidth := (interpolationWidth_ge hn).1
  apply gaussian_training_sharp_mass (by norm_num) (by omega) hN
    (by unfold slowEnergyCeiling; positivity) hρ hσ w ?_ _ s hw hs.2 hscale
  rw [hout]
  unfold slowEnergyCeiling
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthPower
