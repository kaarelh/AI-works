import NeuralGeneralization.BatchTwoContinuousDepthFiniteProjection

/-! The finite-scale approximation ceiling, with the manuscript's literal
width threshold, actual posterior and continuous choice of representative. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

def representativeEnergyEvent {d N r : ℕ} (K σ : ℝ) : Set (Weights d N r) :=
  {w | weightedSquaredNorm (residualRepresentative σ w) ≤ K+1}

theorem representativeEnergyEvent_closed (d N r : ℕ) (K σ : ℝ) :
    IsClosed (representativeEnergyEvent (d:=d) (N:=N) (r:=r) K σ) :=
  isClosed_le (continuous_weightedEnergy.comp (continuous_residualRepresentative d N r σ)) continuous_const

/-- Probability at the exact displayed width threshold, for any witness at
energy K. The event is closed and the representative is continuous. -/
theorem finite_representative_posterior_mass {d M N r n : ℕ} (hd : 0 < d)
    {K h ρ ζ β σ : ℝ} (hK : 0 ≤ K) (hh : 0 < h) (hρ : h < ρ)
    (hζ : 0 < ζ) (hβ : 0 < β) (hσ : 0 < σ)
    (hN : approximationWidth d M (r+2) K h ζ β ≤ N)
    (hscale : σ^2 ≤ (N : ℝ)^(-(1+ζ)))
    (f : RealInput d → ℝ) (s : Fin n → RealInput d) (hs : ∀ i,∑ j,(s i j)^2 ≤ 1)
    (w : Weights d N r) (hfit : w ∈ exactInterpolants Real.tanh f s)
    (henergy : weightedSquaredNorm w ≤ K) :
    1-β ≤ (BatchTwoContinuous.posterior Real.tanh (smallPrior d N r σ) f ρ s).real (representativeEnergyEvent K σ) := by
  have hwidth := approximationWidth_properties (by omega : 2 ≤ r+2) hK hh hζ hN hscale
  have hNp : 0 < N := by omega
  have hrad := approximationWidth_noise_radius (by omega : 2 ≤ r+2) hK hh hζ hσ.le hN hscale
  have hden := finite_training_mass_lower hd hNp hK hh hρ hσ hrad f s hs w hfit henergy
  have htrain : w ∈ trainingEvent Real.tanh f ρ s := by
    intro i
    rw [hfit i,sub_self,abs_zero]
    linarith
  let Q := BatchTwoContinuous.posterior Real.tanh (smallPrior d N r σ) f ρ s
  letI : IsProbabilityMeasure Q := posterior_probability hd hNp tanh_continuous f s hσ ⟨w,htrain⟩
  have hθ : 0 < 1/(2*(K+1)) := by positivity
  have htail := prior_residual_energy_tail (r:=r) hd hNp hσ hθ K
  have hbad : Q.real (representativeEnergyEvent (d:=d) (N:=N) (r:=r) K σ)ᶜ ≤ β := by
    have he : (representativeEnergyEvent (d:=d) (N:=N) (r:=r) K σ)ᶜ=
        {v | K+1 < weightedSquaredNorm (residualRepresentative σ v)} := by
      ext v
      simp only [representativeEnergyEvent,Set.mem_compl_iff,Set.mem_setOf_eq,not_le]
    rw [he]
    have hcond := RobustPosterior.cond_real_le_ratio (smallPrior d N r σ)
      (trainingEvent Real.tanh f ρ s) {v | K+1 < weightedSquaredNorm (residualRepresentative σ v)}
      (isOpen_trainingEvent tanh_continuous f ρ s).measurableSet
    apply hcond.trans
    calc
      _ ≤ Real.exp (Real.log 2/(1/(2*(K+1)))-((K+1)/σ^2)/(2*(1+1/(2*(K+1))))) /
          (smallPrior d N r σ).real (trainingEvent Real.tanh f ρ s) :=
        div_le_div_of_nonneg_right htail measureReal_nonneg
      _ ≤ Real.exp (Real.log 2/(1/(2*(K+1)))-((K+1)/σ^2)/(2*(1+1/(2*(K+1))))) /
          ((1/2)*Real.exp (-K/(2*σ^2))) :=
        div_le_div_of_nonneg_left (Real.exp_nonneg _) (by positivity) hden
      _ ≤ 2*Real.exp (-(N : ℝ)/2) := finite_energy_tail_ratio (by omega) hK hσ hwidth.2.2.2.2
      _ ≤ β := width_probability_tail hβ hwidth.2.2.1
  have hm := measureReal_add_measureReal_compl (μ:=Q) (representativeEnergyEvent_closed d N r K σ).measurableSet
  rw [probReal_univ] at hm
  change 1-β ≤ Q.real (representativeEnergyEvent K σ)
  linarith

/-- Literal finite-scale approximation ceiling: every sufficiently wide actual
posterior has mass at least 1-beta on networks uniformly h-close on the unit
ball to a representative with energy K+1 and the depth-independent Lambda.
The exact radius and width definitions above are the displayed manuscript formulas. -/
theorem finite_scale_approximation_ceiling {d M N r n : ℕ} (hd : 0 < d) (hr : 1 ≤ r)
    {T h ρ ζ β σ : ℝ} (hT : 1 ≤ T) (hh : 0 < h) (hρ : h < ρ)
    (hζ : 0 < ζ) (hβ : 0 < β) (_hβ1 : β < 1) (hσ : 0 < σ)
    (hN : approximationWidth d M (r+2) (energyBudget (r+2) T) h ζ β ≤ N)
    (hscale : σ^2 ≤ (N : ℝ)^(-(1+ζ)))
    (f : RealInput d → ℝ) (s : Fin n → RealInput d) (hs : ∀ i,∑ j,(s i j)^2 ≤ 1)
    (hwitness : ∀ J ≥ M,∃ w : Weights d J r,
      w ∈ exactInterpolants Real.tanh f s ∧ weightedSquaredNorm w ≤ energyBudget (r+2) T) :
    ∃ G : Set (Weights d N r), IsClosed G ∧
      1-β ≤ (BatchTwoContinuous.posterior Real.tanh (smallPrior d N r σ) f ρ s).real G ∧
      ∀ w ∈ G,∃ U : Weights d N r,
        weightedSquaredNorm U ≤ energyBudget (r+2) T+1 ∧
        outputLipschitz (lipschitzCeiling d T) U ∧
        ∀ x : RealInput d,(∑ i,x i^2 ≤ 1) → |output Real.tanh w x-output Real.tanh U x| ≤ h := by
  have hK := energyBudget_nonneg (L:=r+2) hT
  have hw := approximationWidth_properties (by omega : 2 ≤ r+2) hK hh hζ hN hscale
  have hNp : 0 < N := by omega
  obtain ⟨v,hv,hvE⟩ := hwitness N hw.1
  refine ⟨representativeEnergyEvent (energyBudget (r+2) T) σ,
    representativeEnergyEvent_closed d N r _ σ,
    finite_representative_posterior_mass hd hK hh hρ hζ hβ hσ hN hscale f s hs v hv hvE,?_⟩
  intro w hwG
  refine ⟨residualRepresentative σ w,hwG,energyBudget_output_lipschitz hd hNp hr hT _ hwG,?_⟩
  exact residualRepresentative_approximation hd hNp hK hh hσ
    (approximationWidth_noise_radius (by omega : 2 ≤ r+2) hK hh hζ hσ.le hN hscale) w hwG

end NeuralGeneralization.BatchTwoContinuousDepthPaper
