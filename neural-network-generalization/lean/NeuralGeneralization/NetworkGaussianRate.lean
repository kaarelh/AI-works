import NeuralGeneralization.GaussianModelRate
import NeuralGeneralization.NetworkEnergy
import NeuralGeneralization.GaussianRate

/-!
# The small-variance rate for the actual neural-network sign event

This is the concrete finite-dimensional Gaussian-rate lemma used in the
strong-prior paper. The Gaussian rate is proved in `GaussianRate`; the exact
network change of variables is proved in `GaussianModelRate`. No rate theorem
for the neural network is assumed as a hypothesis here.
-/

noncomputable section

open scoped BigOperators Topology
open Filter MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.ConcreteModel

theorem tendsto_square_nhdsGT_zero :
    Tendsto (fun σ : ℝ => σ ^ 2) (𝓝[>] (0 : ℝ)) (𝓝[>] (0 : ℝ)) := by
  apply tendsto_nhdsWithin_iff.mpr
  constructor
  · simpa using ((continuous_pow 2).tendsto (0 : ℝ)).mono_left nhdsWithin_le_nhds
  · filter_upwards [self_mem_nhdsWithin] with σ hσ
    change (0 : ℝ) < σ ^ 2
    exact pow_pos (show (0 : ℝ) < σ from hσ) 2

theorem tendsto_inverse_square_nhdsGT_zero_atTop :
    Tendsto (fun σ : ℝ => 1 / σ ^ 2) (𝓝[>] (0 : ℝ)) atTop := by
  simpa only [one_div, Function.comp_def] using
    (tendsto_inv_nhdsGT_zero :
      Tendsto (fun t : ℝ => t⁻¹) (𝓝[>] (0 : ℝ)) atTop).comp tendsto_square_nhdsGT_zero

/-- The rate is one half the infimum weighted quadratic norm, with speed
`σ⁻²`, for the actual finite product Gaussian prior on the actual network. -/
theorem network_functionMass_hasExponentialRate {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (a : ℝ) (f : BooleanFunction d)
    (hne : (marginEvent (N := N) (r := r) φ a f).Nonempty) :
    HasExponentialRate (𝓝[>] (0 : ℝ)) (fun σ : ℝ => 1 / σ ^ 2)
      (fun σ => functionMass φ a (smallPrior d N r σ) f)
      (sInf (weightedSquaredNorm '' marginEvent (N := N) (r := r) φ a f) / 2) := by
  let V : Set (Weights d N r) := whitenedMarginEvent φ a f
  have hV : IsOpen V := isOpen_whitenedMarginEvent hφ a f
  have hVne : V.Nonempty := whitenedMarginEvent_nonempty hd hN φ a f hne
  have hrate :=
    (GaussianRate.gaussian_open_event_hasExponentialRate hV hVne).comp
      tendsto_square_nhdsGT_zero
  have heq : (fun σ : ℝ => GaussianRate.isotropicMass V (σ ^ 2)) =ᶠ[𝓝[>] (0 : ℝ)]
      (fun σ => functionMass φ a (smallPrior d N r σ) f) := by
    filter_upwards [self_mem_nhdsWithin] with σ hσ
    simpa only [GaussianRate.isotropicMass, Measure.real, functionMass, V] using
      congrArg ENNReal.toReal
        (smallPrior_marginEvent_eq_isotropic hd hN hφ a f (show 0 < σ from hσ)).symm
  have hresult := hrate.congr heq
  simpa only [V, GaussianRate.squareInf, GaussianRate.squareSum,
    whitened_energy_infimum hd hN φ a f] using hresult

/-- Representability at complexity `C` supplies the required nonempty sign
event at every width `N ≥ C`, by the formally proved cloning construction. -/
theorem network_functionMass_hasExponentialRate_of_complexity {d C N r : ℕ}
    (hd : 0 < d) {φ : ℝ → ℝ} (hφ : Continuous φ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) :
    HasExponentialRate (𝓝[>] (0 : ℝ)) (fun σ : ℝ => 1 / σ ^ 2)
      (fun σ => functionMass φ (1 / 2) (smallPrior d N r σ) f)
      (sInf (weightedSquaredNorm '' marginEvent (N := N) (r := r) φ (1 / 2) f) / 2) := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1) hCN
  exact network_functionMass_hasExponentialRate hd hN hφ (1 / 2) f
    (margin_witness_at_larger_width φ f hc hCN)

/-- This is the actual raw-mass tail estimate used by strong-prior learning.
It assumes neither neural Gaussian rates nor posterior concentration: both
are obtained from the proved finite-dimensional Gaussian construction. -/
theorem network_highEnergy_tail_ratio_tendsto_zero {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : BooleanFunction d)
    (hne : (marginEvent (N := N) (r := r) φ (1 / 2) f).Nonempty) :
    Tendsto (fun σ : ℝ =>
      (∑ g ∈ Finset.univ \ lowEnergyFunctions (N := N) (r := r) φ f,
        functionMass φ (1 / 2) (smallPrior d N r σ) g) /
          functionMass φ (1 / 2) (smallPrior d N r σ) f)
      (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
  apply high_energy_or_zero_tail_ratio_tendsto_zero
    (fun σ : ℝ => 1 / σ ^ 2)
    (fun σ g => functionMass φ (1 / 2) (smallPrior d N r σ) g)
    (networkEnergy (N := N) (r := r) φ (1 / 2))
    tendsto_inverse_square_nhdsGT_zero_atTop f
    (Finset.univ \ lowEnergyFunctions (N := N) (r := r) φ f)
    (network_functionMass_hasExponentialRate hd hN hφ (1 / 2) f hne)
  intro g hg
  letI : Decidable ((marginEvent (N := N) (r := r) φ (1 / 2) g).Nonempty) :=
    Classical.propDecidable _
  by_cases hgNonempty : (marginEvent (N := N) (r := r) φ (1 / 2) g).Nonempty
  · right
    refine ⟨network_functionMass_hasExponentialRate hd hN hφ (1 / 2) g hgNonempty, ?_⟩
    apply lt_of_not_ge
    intro hle
    exact (Finset.mem_sdiff.mp hg).2
      ((mem_lowEnergyFunctions φ f g).mpr ⟨hgNonempty, hle⟩)
  · left
    apply Filter.Eventually.of_forall
    intro σ
    have hempty : marginEvent (N := N) (r := r) φ (1 / 2) g = ∅ :=
      Set.not_nonempty_iff_eq_empty.mp hgNonempty
    change ((smallPrior d N r σ) (marginEvent φ (1 / 2) g)).toReal = 0
    rw [hempty]
    simp

end NeuralGeneralization.ConcreteModel
