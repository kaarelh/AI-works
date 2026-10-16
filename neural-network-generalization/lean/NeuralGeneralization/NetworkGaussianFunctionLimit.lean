import NeuralGeneralization.OrthantContinuity
import NeuralGeneralization.NetworkWeakLimit
import NeuralGeneralization.NetworkPosteriorLimits
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

/-! Actual function-mass and posterior limits for gamma <= 0, obtained from
the proved finite-network weak limit and moving orthant continuity. -/
noncomputable section
open MeasureTheory ProbabilityTheory Filter WithLp
open scoped Topology
open scoped BigOperators
namespace NeuralGeneralization.NetworkGaussianFunctionLimit
open ConcreteModel NetworkOutputLaw NetworkWeakLimit

def gaussianFunctionMass (d r : ℕ) (a : ℝ) (g : BooleanFunction d) : ℝ :=
  (WalshGaussianLaw.arcsineLaw d r).real (WalshGaussianLaw.orthant g a)

theorem normalized_orthant_preimage {d N r : ℕ} (hN : 0 < N) (φ : ℝ → ℝ)
    (γ a : ℝ) (g : BooleanFunction d) :
    normalizedOutput (N := N) (r := r) φ γ ⁻¹'
      WalshGaussianLaw.orthant g ((N : ℝ)^(γ/2)*a) = marginEvent φ a g := by
  have hc : 0 < (N : ℝ)^(γ/2) := Real.rpow_pos_of_pos (by exact_mod_cast hN) _
  ext w
  change (∀ x, (N : ℝ)^(γ/2)*a < labelReal (g x)*
    ((N : ℝ)^(γ/2)*networkOutput φ w x)) ↔ ∀ x, a < labelReal (g x)*networkOutput φ w x
  constructor
  · intro h x
    apply (mul_lt_mul_iff_right₀ hc).mp
    simpa only [mul_left_comm] using h x
  · intro h x
    have hh := (mul_lt_mul_iff_right₀ hc).mpr (h x)
    simpa only [mul_left_comm] using hh

theorem functionMass_eq_normalized_orthant {d N r : ℕ} (hN : 0 < N) (γ a : ℝ)
    (g : BooleanFunction d) :
    functionMass Real.tanh a (powerPrior d N r γ) g =
      (NetworkOutputLaw.law d N r Real.tanh γ).real
        (WalshGaussianLaw.orthant g ((N : ℝ)^(γ/2)*a)) := by
  rw [measureReal_def, NetworkOutputLaw.law,
    Measure.map_apply (continuous_normalizedOutput tanh_lipschitzWith.continuous γ).measurable
      (WalshGaussianLaw.isOpen_orthant g _).measurableSet,
    normalized_orthant_preimage hN]
  rfl

theorem functionMass_tendsto_of_scaled_margin {d : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 1) (a b : ℝ)
    (ha : Tendsto (fun N : ℕ => (N : ℝ)^(γ/2)*a) atTop (𝓝 b))
    (g : BooleanFunction d) :
    Tendsto (fun N => functionMass Real.tanh a (powerPrior d N r γ) g) atTop
      (𝓝 (gaussianFunctionMass d r b g)) := by
  have h := OrthantContinuity.moving_orthant_tendsto
    (actual_network_weak_limit hd r hγ) g
    (WalshGaussianLaw.coordinate_boundary_null _ (iterated_arcsine_coefficient_pos d r)) ha
  apply h.congr'
  filter_upwards [eventually_gt_atTop (0 : ℕ)] with N hN
  exact (functionMass_eq_normalized_orthant hN γ a g).symm

theorem gamma_zero_functionMass_tendsto {d : ℕ} (hd : 0 < d) (r : ℕ) (a : ℝ)
    (g : BooleanFunction d) :
    Tendsto (fun N => functionMass Real.tanh a (powerPrior d N r 0) g) atTop
      (𝓝 (gaussianFunctionMass d r a g)) := by
  apply functionMass_tendsto_of_scaled_margin hd r (by norm_num : (0 : ℝ) < 1) a a
  simpa only [zero_div, Real.rpow_zero, one_mul] using tendsto_const_nhds (x := a)

theorem negative_scaled_margin_tendsto {γ : ℝ} (hγ : γ < 0) (a : ℝ) :
    Tendsto (fun N : ℕ => (N : ℝ)^(γ/2)*a) atTop (𝓝 (0 : ℝ)) := by
  have hh := (tendsto_rpow_neg_atTop (show (0 : ℝ) < -(γ/2) by linarith)).comp
    (tendsto_natCast_atTop_atTop : Tendsto (fun N : ℕ => (N : ℝ)) atTop atTop)
  simpa only [Function.comp_def, neg_neg, zero_mul] using hh.mul_const a

theorem gamma_negative_functionMass_tendsto {d : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 0) (a : ℝ) (g : BooleanFunction d) :
    Tendsto (fun N => functionMass Real.tanh a (powerPrior d N r γ) g) atTop
      (𝓝 (gaussianFunctionMass d r 0 g)) :=
  functionMass_tendsto_of_scaled_margin hd r (by linarith) a 0
    (negative_scaled_margin_tendsto hγ a) g

theorem gaussianFunctionMass_pos (d r : ℕ) (a : ℝ) (g : BooleanFunction d) :
    0 < gaussianFunctionMass d r a g :=
  ENNReal.toReal_pos (WalshGaussianLaw.orthant_pos _ (iterated_arcsine_coefficient_pos d r) g a).ne'
    (measure_ne_top _ _)

theorem gaussian_normalizer_pos {d n : ℕ} (r : ℕ) (a : ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) :
    0 < normalizer (gaussianFunctionMass d r a) (consistent f sample) := by
  classical
  exact normalizer_pos (gaussianFunctionMass d r a) (consistent f sample)
    (fun g => (gaussianFunctionMass_pos d r a g).le) f (fun _ => rfl)
    (gaussianFunctionMass_pos d r a f)

theorem gamma_zero_networkPosterior_tendsto {d n : ℕ} (hd : 0 < d) (r : ℕ) (a : ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) (g : BooleanFunction d) :
    Tendsto (fun N => networkPosterior Real.tanh a (powerPrior d N r 0) f sample g) atTop
      (𝓝 (posterior (gaussianFunctionMass d r a) (consistent f sample) g)) :=
  networkPosterior_tendsto_of_functionMass Real.tanh a (fun N => powerPrior d N r 0)
    (gaussianFunctionMass d r a) f sample (gamma_zero_functionMass_tendsto hd r a)
    (gaussian_normalizer_pos r a f sample) g

theorem gamma_negative_networkPosterior_tendsto {d n : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 0) (a : ℝ) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (g : BooleanFunction d) :
    Tendsto (fun N => networkPosterior Real.tanh a (powerPrior d N r γ) f sample g) atTop
      (𝓝 (posterior (gaussianFunctionMass d r 0) (consistent f sample) g)) :=
  networkPosterior_tendsto_of_functionMass Real.tanh a (fun N => powerPrior d N r γ)
    (gaussianFunctionMass d r 0) f sample (gamma_negative_functionMass_tendsto hd r hγ a)
    (gaussian_normalizer_pos r 0 f sample) g

theorem gamma_zero_confidence_liminf {d n : ℕ} (hd : 0 < d) (r : ℕ) (a : ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) (D : InputLaw d)
    (b : ℝ) (hb : b < 2/3) :
    (∑ x, if correctConfidence f
        (posterior (gaussianFunctionMass d r a) (consistent f sample)) x ≤ b
      then D.mass x else 0) ≤
      Filter.liminf (fun N => ConcreteModel.confidenceFailure D f
        (networkPosterior Real.tanh a (powerPrior d N r 0) f sample)) atTop :=
  network_confidence_liminf_of_functionMass Real.tanh a (fun N => powerPrior d N r 0)
    (gaussianFunctionMass d r a) f sample (gamma_zero_functionMass_tendsto hd r a)
    (gaussian_normalizer_pos r a f sample) D b hb

theorem gamma_negative_confidence_liminf {d n : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 0) (a : ℝ) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (D : InputLaw d) (b : ℝ) (hb : b < 2/3) :
    (∑ x, if correctConfidence f
        (posterior (gaussianFunctionMass d r 0) (consistent f sample)) x ≤ b
      then D.mass x else 0) ≤
      Filter.liminf (fun N => ConcreteModel.confidenceFailure D f
        (networkPosterior Real.tanh a (powerPrior d N r γ) f sample)) atTop :=
  network_confidence_liminf_of_functionMass Real.tanh a (fun N => powerPrior d N r γ)
    (gaussianFunctionMass d r 0) f sample (gamma_negative_functionMass_tendsto hd r hγ a)
    (gaussian_normalizer_pos r 0 f sample) D b hb

end NeuralGeneralization.NetworkGaussianFunctionLimit
end
