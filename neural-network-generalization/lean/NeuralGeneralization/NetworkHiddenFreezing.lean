import NeuralGeneralization.NetworkGramConcentration
import NeuralGeneralization.NetworkReadout

/-! The actual Gram-freezing bound expressed under the hidden-weight marginal
used by the exact Gaussian readout mixture. -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped BigOperators Topology NNReal
namespace NeuralGeneralization.NetworkHiddenFreezing
open ConcreteModel NetworkReadout NetworkGramConcentration

theorem finalCovariance_assemble {d N r : ℕ} (φ : ℝ → ℝ)
    (h : HiddenIndex d N r → ℝ) (a : Fin N → ℝ) (x y : Cube d) :
    finalCovariance φ (assemble h a) x y = empiricalGram φ h x y := rfl

@[fun_prop] theorem continuous_assemble {d N r : ℕ} (a : Fin N → ℝ) :
    Continuous (fun h : HiddenIndex d N r → ℝ => assemble h a) := by
  apply continuous_pi
  intro i
  rcases i with ij | (sij | j) <;> dsimp [assemble] <;> fun_prop

def hiddenGramBad {d N r : ℕ} (K : Cube d → Cube d → ℝ) (ε : ℝ) :
    Set (HiddenIndex d N r → ℝ) :=
  {h | ∃ x y, ε ≤ |empiricalGram Real.tanh h x y - K x y|}

theorem measurableSet_hiddenGramBad {d N r : ℕ} (K : Cube d → Cube d → ℝ) (ε : ℝ) :
    MeasurableSet (hiddenGramBad (N := N) (r := r) K ε) := by
  have he : hiddenGramBad (N := N) (r := r) K ε =
      (fun h => assemble h 0) ⁻¹' gramBad K ε := rfl
  rw [he]
  exact (measurableSet_gramBad K ε).preimage (continuous_assemble 0).measurable

theorem empiricalGram_weightSplit {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (x y : Cube d) :
    empiricalGram φ (weightSplit d N r w).1 x y = finalCovariance φ w x y := by
  have hw : assemble (weightSplit d N r w).1 (weightSplit d N r w).2 = w := by
    rw [← weightSplit_symm]
    exact (weightSplit d N r).symm_apply_apply w
  calc
    _ = finalCovariance φ (assemble (weightSplit d N r w).1 (weightSplit d N r w).2) x y := rfl
    _ = _ := by rw [hw]

/-- Exact equality of the hidden marginal event mass and the original full
parameter-prior event mass. -/
theorem hiddenGramBad_mass {d N r : ℕ} (γ : ℝ) (K : Cube d → Cube d → ℝ) (ε : ℝ) :
    (hiddenPrior d N r γ).real (hiddenGramBad K ε) =
      (powerPrior d N r γ).real (gramBad K ε) := by
  have hp : MeasurePreserving (fun w : Weights d N r => (weightSplit d N r w).1)
      (powerPrior d N r γ) (hiddenPrior d N r γ) :=
    measurePreserving_fst.comp (measurePreserving_weightSplit d N r γ)
  have he : (fun w : Weights d N r => (weightSplit d N r w).1) ⁻¹' hiddenGramBad K ε =
      gramBad K ε := by
    ext w
    simp only [Set.mem_preimage, hiddenGramBad, gramBad, Set.mem_setOf_eq, empiricalGram_weightSplit]
  have hm := hp.measure_preimage (measurableSet_hiddenGramBad K ε).nullMeasurableSet
  rw [he] at hm
  exact (congrArg ENNReal.toReal hm).symm

theorem hidden_gram_exponential_freezing {d : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 1) {ε : ℝ} (hε : 0 < ε) :
    ∃ C : ℝ, 0 < C ∧ ∃ c : ℝ, 0 < c ∧ ∀ᶠ N : ℕ in atTop,
      (hiddenPrior d N r γ).real (hiddenGramBad (arcsineCovariance d (r + 1)) ε) ≤
        C * Real.exp (-c * N) := by
  simpa only [hiddenGramBad_mass] using actual_gram_exponential_freezing hd r hγ hε

theorem hidden_gram_bad_probability_tendsto_zero {d : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 1) {ε : ℝ} (hε : 0 < ε) :
    Tendsto (fun N : ℕ => (hiddenPrior d N r γ).real
      (hiddenGramBad (arcsineCovariance d (r + 1)) ε)) atTop (𝓝 (0 : ℝ)) := by
  simpa only [hiddenGramBad_mass] using actual_gram_bad_probability_tendsto_zero hd r hγ hε

end NeuralGeneralization.NetworkHiddenFreezing
