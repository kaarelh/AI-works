import NeuralGeneralization.BatchTwoParameterPriorRate
import NeuralGeneralization.BatchTwoContinuousDepthEnergyLipschitz

/-! Actual small-Gaussian posterior concentration above the energy of an
interpolating witness. There is no condition on unobserved inputs. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open MeasureTheory ProbabilityTheory Filter
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous BatchTwoParameterPriorRate

theorem continuous_energy {d N r : ℕ} : Continuous (weightedSquaredNorm (d := d) (N := N) (r := r)) := by
  unfold weightedSquaredNorm
  fun_prop

theorem posterior_energy_concentration {d N r n : ℕ} (hd : 0 < d) (hN : 0 < N)
    (f : RealInput d → ℝ) (s : Fin n → RealInput d) {ρ K : ℝ}
    (w : Weights d N r) (hw : w ∈ trainingEvent Real.tanh f ρ s)
    (hcost : weightedSquaredNorm w ≤ K) :
    ∀ᶠ σ in 𝓝[>] (0 : ℝ),
      IsProbabilityMeasure (BatchTwoContinuous.posterior Real.tanh (smallPrior d N r σ) f ρ s) ∧
      (BatchTwoContinuous.posterior Real.tanh (smallPrior d N r σ) f ρ s).real
        {v | K+1 < weightedSquaredNorm v} ≤ (1/3 : ℝ) := by
  let V := trainingEvent (N := N) (r := r) Real.tanh f ρ s
  let U : Set (Weights d N r) := {v | K+1 < weightedSquaredNorm v}
  have hV : IsOpen V := isOpen_trainingEvent tanh_lipschitzWith.continuous f ρ s
  have hU : IsOpen U := isOpen_lt continuous_const continuous_energy
  have hVne : V.Nonempty := ⟨w,hw⟩
  have hrateV := gaussian_open_rate hd hN V hV hVne
  have hratio : Tendsto (fun σ => (smallPrior d N r σ).real U/(smallPrior d N r σ).real V)
      (𝓝[>] (0 : ℝ)) (𝓝 0) := by
    by_cases hUne : U.Nonempty
    · have hrateU := gaussian_open_rate hd hN U hU hUne
      have hElow := eventEnergy_ge hUne (K := K+1) (fun v hv => hv.le)
      have hEhigh := (eventEnergy_le (show w∈V from hw)).trans (div_le_div_of_nonneg_right hcost (by norm_num))
      exact hrateU.ratio_tendsto_zero hrateV (by linarith) tendsto_inverse_square_nhdsGT_zero_atTop
    · have hzero : U=∅ := Set.not_nonempty_iff_eq_empty.mp hUne
      simpa only [hzero,measureReal_empty,zero_div] using
        (tendsto_const_nhds : Tendsto (fun _ : ℝ => (0 : ℝ)) (𝓝[>] (0 : ℝ)) (𝓝 0))
  have hsmall := hratio.eventually (gt_mem_nhds (show (0 : ℝ)<1/3 by norm_num))
  filter_upwards [hrateV.eventually_pos,hsmall] with σ hpos hs
  have hne : smallPrior d N r σ V≠0 := by
    intro hh
    simp only [Measure.real,hh,ENNReal.toReal_zero] at hpos
    exact hpos.false
  refine ⟨cond_isProbabilityMeasure hne,?_⟩
  exact (RobustPosterior.cond_real_le_ratio (smallPrior d N r σ) V U hV.measurableSet).trans hs.le

/-- Conditional on a low-energy interpolant, all sufficiently strong priors
place at least half the input law in the specified confidence-error set. -/
theorem strong_prior_barrier_of_witness {N r n : ℕ} (hN : 0 < N)
    (s : Fin n → RealInput 2) (w : Weights 2 N (r+1))
    (hw : w ∈ trainingEvent Real.tanh (depthTarget (r+2)) (1/8) s)
    (hcost : weightedSquaredNorm w ≤ 4*(r : ℝ)+5)
    (hdepth : (2 : ℝ)^(r+3)≤(3 : ℝ)^(r+2)/10) :
    ∀ᶠ σ in 𝓝[>] (0 : ℝ),
      (1/2 : ℝ) ≤ BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
        (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ) (depthTarget (r+2)) (1/8) s)
        (depthTarget (r+2)) (1/4) := by
  filter_upwards [posterior_energy_concentration (by norm_num) hN _ s w hw hcost] with σ hσ
  let Q := BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ) (depthTarget (r+2)) (1/8) s
  letI : IsProbabilityMeasure Q := hσ.1
  let G : Set (Weights 2 N (r+1)) := {v | weightedSquaredNorm v ≤ 4*(r : ℝ)+6}
  apply inputLaw_mixture_barrier Q (output Real.tanh)
    (fun x => (continuous_output_weights tanh_lipschitzWith.continuous x).measurable) (r+2) G
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
