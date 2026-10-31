import NeuralGeneralization.QuadraticTailEnvelopes
import NeuralGeneralization.GaussianPrefactors

/-! Exact strong-prior rates for positive continuous coordinate densities
whose two quadratic log tails have a common coefficient. -/
noncomputable section
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators Topology
namespace NeuralGeneralization

/-- The exponential estimates imply the usual logarithmic limit. -/
theorem HasExponentialRate.log_tendsto {I : Type*} {l : Filter I}
    {speed w : I → ℝ} {E : ℝ} (h : HasExponentialRate l speed w E)
    (hs : Tendsto speed l atTop) :
    Tendsto (fun i => Real.log (w i)/speed i) l (𝓝 (-E)) := by
  apply tendsto_order.mpr
  constructor
  · intro b hb
    have he : 0 < (-E-b)/2 := by linarith
    filter_upwards [h _ he, hs.eventually_gt_atTop 0] with i hi hsi
    have hw : 0 < w i := (Real.exp_pos _).trans_le hi.1
    have hlo := (Real.le_log_iff_exp_le hw).mpr hi.1
    apply (lt_div_iff₀ hsi).mpr
    have : b < -(E+(-E-b)/2) := by linarith
    exact (mul_lt_mul_of_pos_right this hsi).trans_le hlo
  · intro b hb
    have he : 0 < (b+E)/2 := by linarith
    filter_upwards [h _ he, hs.eventually_gt_atTop 0] with i hi hsi
    have hw : 0 < w i := (Real.exp_pos _).trans_le hi.1
    have hhi := Real.log_le_log hw hi.2
    rw [Real.log_exp] at hhi
    apply (div_lt_iff₀ hsi).mpr
    have : -(E-(b+E)/2) < b := by linarith
    exact hhi.trans_lt (mul_lt_mul_of_pos_right this hsi)

namespace QuadraticTail
open ConcreteModel

private theorem choose_tail_error {a E δ : ℝ} (ha : 0 < a) (hE : 0 ≤ E) (hδ : 0 < δ) :
    ∃ η : ℝ, 0 < η ∧ η < a ∧ 2*η*E ≤ δ/2 := by
  let η := min (a/2) (δ/(4*(E+1)))
  have hden : 0 < 4*(E+1) := by positivity
  have hη : 0 < η := lt_min (by linarith) (div_pos hδ hden)
  have hηa : η ≤ a/2 := min_le_left _ _
  have hh := (le_div_iff₀ hden).mp (min_le_right (a/2) (δ/(4*(E+1))))
  exact ⟨η, hη, by linarith, by dsimp only [η] at *; nlinarith⟩

/-- The coefficient is `2*a*networkEnergy = a*κ`, matching the paper's
normalization of the weighted squared norm κ. -/
theorem functionMass_hasExponentialRate {d N r : ℕ} {a : ℝ}
    (ν : WeightIndex d N r → Coordinate a) (ha : 0 < a)
    (hd : 0 < d) (hN : 0 < N) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : BooleanFunction d) (hf : (marginEvent (N:=N) (r:=r) φ (1/2) f).Nonempty) :
    HasExponentialRate (𝓝[>] (0:ℝ)) (fun σ : ℝ => 1/σ^2)
      (fun σ => functionMass φ (1/2) (smallPrior ν σ) f)
      (2*a*networkEnergy (N:=N) (r:=r) φ (1/2) f) := by
  let E := networkEnergy (N:=N) (r:=r) φ (1/2) f
  have hE : 0 ≤ E := networkEnergy_nonneg φ (1/2) f hf
  apply GaussianRate.hasExponentialRate_of_prefactors _ _ _
    tendsto_inverse_square_nhdsGT_zero_atTop
  · intro δ hδ
    obtain ⟨η, hη, hηa, hηE⟩ := choose_tail_error ha hE hδ
    let env := fun i => (ν i).envelope hη
    have hb : 0 < 2*(a+η) := by positivity
    have hr := BatchTwoNonGaussian.rescaled_gaussian_mass_rate hd hN hφ (1/2) f hf _ hb
    refine ⟨QuadraticEnvelope.lowerProduct env, QuadraticEnvelope.lowerProduct_pos env hb, ?_⟩
    filter_upwards [hr (δ/2) (by linarith)] with σ hσ
    have hs : 0 ≤ 1/σ^2 := by positivity
    have he : 2*(a+η)*E+δ/2 ≤ 2*a*E+δ := by nlinarith
    have hcomp := QuadraticEnvelope.smallMass_gaussian_lower env hd hN hb σ φ f
    rw [envelope_smallPrior] at hcomp
    apply le_trans _ hcomp
    apply mul_le_mul_of_nonneg_left _ (QuadraticEnvelope.lowerProduct_pos env hb).le
    exact (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_right (neg_le_neg he) hs)).trans hσ.1
  · intro δ hδ
    obtain ⟨η, hη, hηa, hηE⟩ := choose_tail_error ha hE hδ
    let env := fun i => (ν i).envelope hη
    have hc : 0 < 2*(a-η) := by linarith
    have hr := BatchTwoNonGaussian.rescaled_gaussian_mass_rate hd hN hφ (1/2) f hf _ hc
    refine ⟨QuadraticEnvelope.upperProduct env, QuadraticEnvelope.upperProduct_pos env hc, ?_⟩
    filter_upwards [hr (δ/2) (by linarith)] with σ hσ
    have hs : 0 ≤ 1/σ^2 := by positivity
    have he : 2*a*E-δ ≤ 2*(a-η)*E-δ/2 := by nlinarith
    have hcomp := QuadraticEnvelope.smallMass_gaussian_upper env hd hN hc σ φ f
    rw [envelope_smallPrior] at hcomp
    apply le_trans hcomp
    apply mul_le_mul_of_nonneg_left _ (QuadraticEnvelope.upperProduct_pos env hc).le
    exact hσ.2.trans (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_right (neg_le_neg he) hs))

/-- The literal logarithmic limit in the unchanged-ordering proposition. -/
theorem functionMass_log_limit {d N r : ℕ} {a : ℝ}
    (ν : WeightIndex d N r → Coordinate a) (ha : 0 < a)
    (hd : 0 < d) (hN : 0 < N) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : BooleanFunction d) (hf : (marginEvent (N:=N) (r:=r) φ (1/2) f).Nonempty) :
    Tendsto (fun σ : ℝ => σ^2*Real.log (functionMass φ (1/2) (smallPrior ν σ) f))
      (𝓝[>] (0:ℝ)) (𝓝 (-(2*a*networkEnergy (N:=N) (r:=r) φ (1/2) f))) := by
  simpa only [div_eq_mul_inv, one_mul, mul_one, inv_inv, mul_comm] using
    (functionMass_hasExponentialRate ν ha hd hN hφ f hf).log_tendsto
      tendsto_inverse_square_nhdsGT_zero_atTop

/-- Strict energy order gives a vanishing ratio for the actual raw masses. -/
theorem functionMass_ratio_tendsto_zero {d N r : ℕ} {a : ℝ}
    (ν : WeightIndex d N r → Coordinate a) (ha : 0 < a)
    (hd : 0 < d) (hN : 0 < N) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f g : BooleanFunction d)
    (hf : (marginEvent (N:=N) (r:=r) φ (1/2) f).Nonempty)
    (hg : (marginEvent (N:=N) (r:=r) φ (1/2) g).Nonempty)
    (hgap : networkEnergy (N:=N) (r:=r) φ (1/2) f < networkEnergy (N:=N) (r:=r) φ (1/2) g) :
    Tendsto (fun σ => functionMass φ (1/2) (smallPrior ν σ) g /
      functionMass φ (1/2) (smallPrior ν σ) f) (𝓝[>] (0:ℝ)) (𝓝 0) :=
  (functionMass_hasExponentialRate ν ha hd hN hφ g hg).ratio_tendsto_zero
    (functionMass_hasExponentialRate ν ha hd hN hφ f hf)
    (mul_lt_mul_of_pos_left hgap (by positivity)) tendsto_inverse_square_nhdsGT_zero_atTop

end QuadraticTail
end NeuralGeneralization
