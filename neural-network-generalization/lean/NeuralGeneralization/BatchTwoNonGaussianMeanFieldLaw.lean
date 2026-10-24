import NeuralGeneralization.BatchTwoNonGaussianMeanFieldModel
import NeuralGeneralization.BatchTwoNonGaussianPowerScale
import NeuralGeneralization.BatchTwoNonGaussianScaledTail

/-! Exact mean-field prior pushforward and readout tail in unscaled coordinates. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
open ConcreteModel

theorem weights_eq_powerScale {d N r : ℕ} (z : Weights d N r) :
    weights z=fun i => powerScale d N r 1 i*z i := by
  funext i
  rcases i with ij | (sij | j)
  · simp [weights,powerScale,div_eq_mul_inv,mul_comm]
  · simp only [weights,powerScale]
    rw [Real.rpow_div_two_eq_sqrt (-1) (Nat.cast_nonneg N),Real.rpow_neg_one]
    ring
  · simp only [weights,powerScale]
    norm_num
    rw [Real.rpow_neg_one]
    ring

theorem map_weights_eq_powerPrior (ν : CoordinateLaw) (d N r : ℕ) :
    (rawPrior ν d N r).map weights=powerPrior ν d N r 1 := by
  rw [powerPrior,productPrior_eq_map]
  congr 1
  exact funext weights_eq_powerScale

theorem readout_map (ν : CoordinateLaw) (d N r : ℕ) :
    (rawPrior ν d N r).map (fun z : Weights d N r => fun i : Fin N => z (.inr (.inr i)))=
      Measure.pi (fun _ : Fin N => ν.law) := by
  induction r with
  | zero => exact (measurePreserving_snd.comp (rawPrior_input_split ν d N)).map_eq
  | succ r ih =>
    have hp : MeasurePreserving (@NetworkLayerSplit.previousWeights d N r)
        (rawPrior ν d N (r+1)) (rawPrior ν d N r) :=
      measurePreserving_fst.comp (rawPrior_layer_split ν d N r)
    rw [←ih,←hp.map_eq,Measure.map_map (by fun_prop) hp.measurable]
    rfl

theorem readout_energy {d N r : ℕ} (hN : 0 < N) (z : Weights d N r) :
    (N : ℝ)*(∑ i, weights z (.inr (.inr i))^2)=
      (∑ i, z (.inr (.inr i))^2)/(N : ℝ) := by
  simp only [weights,div_pow,←Finset.sum_div]
  field_simp [(Nat.cast_pos.mpr hN : (0 : ℝ) < N).ne']
  <;> ring

theorem readout_bad_tail (ν : CoordinateLaw) {d N r : ℕ} (hN : 0 < N)
    {K : ℝ} (hK : 8*subGaussianVariance ν ≤ K) :
    (rawPrior ν d N r).real {z | K < (N : ℝ)*(∑ i, weights z (.inr (.inr i))^2)} ≤
      Real.exp (-(N : ℝ)*K/(8*subGaussianVariance ν)) := by
  have ht := scaled_squaredNorm_upper_tail (I := Fin N) ν (σ := 1) (by norm_num) ((N : ℝ)*K)
    (by simpa only [Fintype.card_fin,one_pow,one_mul,mul_assoc,mul_comm,mul_left_comm] using mul_le_mul_of_nonneg_left hK (Nat.cast_nonneg N : (0 : ℝ) ≤ N))
  have hscale : scaledCoordinates ν (Fin N) 1=Measure.pi (fun _ : Fin N => ν.law) := by
    simp only [scaledCoordinates,one_mul]
    congr 1
    funext i
    exact Measure.map_id
  rw [hscale] at ht
  have hm : (rawPrior ν d N r).real {z | (N : ℝ)*K ≤ ∑ i, z (.inr (.inr i))^2}=
      (Measure.pi fun _ : Fin N => ν.law).real {a | (N : ℝ)*K ≤ ∑ i, a i^2} := by
    rw [←readout_map ν d N r]
    simp only [Measure.real]
    rw [Measure.map_apply (by fun_prop) (measurableSet_le measurable_const (by fun_prop))]
    rfl
  have hsub : {z : Weights d N r | K < (N : ℝ)*(∑ i, weights z (.inr (.inr i))^2)} ⊆
      {z | (N : ℝ)*K ≤ ∑ i, z (.inr (.inr i))^2} := by
    intro z hz
    change K < (N : ℝ)*(∑ i, weights z (.inr (.inr i))^2) at hz
    rw [readout_energy hN] at hz
    have hh := (lt_div_iff₀ (Nat.cast_pos.mpr hN)).mp hz
    dsimp
    linarith
  have h := (measureReal_mono (μ := rawPrior ν d N r) hsub).trans (hm.le.trans ht)
  simpa only [one_pow,one_mul,neg_mul] using h

end NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
