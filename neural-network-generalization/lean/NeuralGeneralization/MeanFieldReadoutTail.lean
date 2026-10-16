import NeuralGeneralization.NetworkSpectralTail

/-! The actual mean-field readout failure has an exponential width tail. -/

noncomputable section
open scoped BigOperators
open MeasureTheory
namespace NeuralGeneralization.MeanFieldReadoutTail
open ConcreteModel

/-- The true mean-field readout, with variance N^(-2), pays rate NK/4. -/
theorem readout_bad_tail_quarter {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (K : ℝ) (hK : 8 ≤ K) :
    (powerPrior d N r 1).real
      {w | K < (N : ℝ)*(∑ i, w (.inr (.inr i))^2)} ≤
      Real.exp (-(N : ℝ)*K/4) := by
  have hNR : (N : ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  have hscale : 8*(N : ℝ)*(N : ℝ)^(-(1 : ℝ)) = 8 := by
    rw [Real.rpow_neg_one]
    field_simp
  have ht := powerPrior_readout_energy_tail (r := r) hd hN 1 K
    (by simpa only [hscale] using hK)
  have hid : -K/(4*(N : ℝ)^(-(1 : ℝ))) = -(N : ℝ)*K/4 := by
    rw [Real.rpow_neg_one]
    field_simp
  rw [hid] at ht
  apply le_trans _ ht
  apply measureReal_mono _ (measure_ne_top _ _)
  intro w hw
  change K < (N : ℝ)*(∑ i, w (.inr (.inr i))^2) at hw
  exact hw.le

/-- A common rate NK/8 permits a single union bound over all hidden layers
and the readout. Equality at the energy threshold is not a failure. -/
theorem readout_bad_tail {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (K : ℝ) (hK : 8 ≤ K) :
    (powerPrior d N r 1).real
      {w | K < (N : ℝ)*(∑ i, w (.inr (.inr i))^2)} ≤
      Real.exp (-(N : ℝ)*K/8) := by
  apply (readout_bad_tail_quarter hd hN K hK).trans
  apply Real.exp_le_exp.mpr
  have hprod : 0 ≤ (N : ℝ)*K := mul_nonneg (Nat.cast_nonneg N) (by linarith)
  linarith

end NeuralGeneralization.MeanFieldReadoutTail
