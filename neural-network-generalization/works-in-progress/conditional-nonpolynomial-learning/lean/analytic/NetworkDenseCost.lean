import AdaptiveGaussianCost
import ControlledCovariancePath
import NeuralGeneralization.BatchTwoActivationFullNetworkEventsLaw

/-! Exponential moment of the aggregate dense-dual cost for all hidden layers
of the actual finite-width Gaussian tanh network. Layer sources depend on the
previous sampled layers. No law of large numbers, Gaussian-trajectory
assumption, or entropy certificate is a hypothesis. -/
noncomputable section
set_option linter.unusedSectionVars false
set_option maxHeartbeats 1200000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.BatchTwoActivation
open NeuralGeneralization.NetworkLayerSplit NeuralGeneralization.TanhDifferential

/-- The sum of all hidden-layer costs; there are r+1 hidden layers. -/
def hiddenDenseCost (d N : ℕ) (σ G : ℝ) (M : ℕ) :
    (r : ℕ) → Weights d N r → ℝ
  | 0,w => gaussianDenseCost (activationInputSource d N σ) G M N (activationInputRows σ w)
  | r+1,w => hiddenDenseCost d N σ G M r (previousWeights w) +
      gaussianDenseCost (activationLastSource Real.tanh σ (previousWeights w))
        G M N (activationLastRows σ w)

@[fun_prop] theorem measurable_hiddenDenseCost (d N : ℕ) (σ G : ℝ) (M r : ℕ) :
    Measurable (hiddenDenseCost d N σ G M r) := by
  induction r with
  | zero => exact (measurable_gaussianDenseCost _ G M N).comp (measurable_activationInputRows σ)
  | succ r ih =>
    apply (ih.comp continuous_previousWeights.measurable).add
    have hh := (continuous_gaussianDenseCost (d:=d) (J:=Fin N) G M N).measurable.comp
      (((measurable_activationLastSource (d:=d) (N:=N) (r:=r) continuous_tanh σ).comp
        continuous_previousWeights.measurable).prodMk (measurable_activationLastRows σ))
    exact hh

/-- Exact finite-width MGF of the sum of all hidden-layer test costs. -/
theorem hiddenDenseCost_mgf (d N : ℕ) (hd : 0<d) (hN : 0<N)
    (σ G : ℝ) (hσ : 0<σ) (M : ℕ) : ∀ r,
    Integrable (fun w : Weights d N r => Real.exp ((N:ℝ)*hiddenDenseCost d N σ G M r w))
      (smallPrior d N r σ) ∧
    (∫ w : Weights d N r, Real.exp ((N:ℝ)*hiddenDenseCost d N σ G M r w)
      ∂smallPrior d N r σ) = denseOverhead d N M G^(r+1) := by
  intro r
  induction r with
  | zero =>
    have hlaw := activationInputRows_law (r:=0) hd hN hσ
    have hi := gaussianDenseCost_integrable (activationInputSource d N σ) G M hN
    have hm := gaussianDenseCost_mgf (activationInputSource d N σ) G M hN
    rw [←hlaw] at hi hm
    have hE : Measurable (fun a => Real.exp ((N:ℝ)*
        gaussianDenseCost (activationInputSource d N σ) G M N a)) :=
      Real.measurable_exp.comp (measurable_const.mul (measurable_gaussianDenseCost _ G M N))
    rw [integral_map (measurable_activationInputRows σ).aemeasurable hE.aestronglyMeasurable] at hm
    exact ⟨hi.comp_measurable (measurable_activationInputRows σ), by simpa only [hiddenDenseCost, denseOverhead, Nat.zero_add, pow_one] using hm⟩
  | succ r ih =>
    obtain ⟨hi,hm⟩ := adaptive_gaussian_dense_mgf
      (smallPrior d N r σ) (activationMatrixPrior N σ)
      (activationLastSource Real.tanh σ) (measurable_activationLastSource continuous_tanh σ)
      (activationMatrixRows σ) (measurable_activationMatrixRows σ) (activationMatrixRows_law hσ)
      (fun w => Real.exp ((N:ℝ)*hiddenDenseCost d N σ G M r w))
      (Real.measurable_exp.comp (measurable_const.mul (measurable_hiddenDenseCost d N σ G M r)))
      (fun _ => (Real.exp_pos _).le) ih.1 G M hN
    let F := fun p : Weights d N r × (Fin N × Fin N → ℝ) =>
      Real.exp ((N:ℝ)*hiddenDenseCost d N σ G M r p.1)*
      Real.exp ((N:ℝ)*gaussianDenseCost (activationLastSource Real.tanh σ p.1)
        G M N (activationMatrixRows σ p.2))
    have hfun : (fun w : Weights d N (r+1) => Real.exp ((N:ℝ)*hiddenDenseCost d N σ G M (r+1) w)) =
        F ∘ split d N r := by
      funext w
      simp only [hiddenDenseCost, mul_add, Real.exp_add]
      rfl
    constructor
    · rw [hfun]
      exact (activationSmallPrior_split d N r σ).integrable_comp_of_integrable hi
    · rw [hfun]
      change (∫ w, F (split d N r w) ∂smallPrior d N (r+1) σ) = _
      rw [(activationSmallPrior_split d N r σ).integral_comp' F]
      rw [hm,ih.2]
      exact (pow_succ _ (r+1)).symm

#print axioms hiddenDenseCost_mgf
end ConditionalNonpolynomial.Analytic
