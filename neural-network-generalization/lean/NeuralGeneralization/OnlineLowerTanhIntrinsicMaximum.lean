import NeuralGeneralization.OnlineLowerTanhOptimizer
import NeuralGeneralization.OnlineLowerTanhCentralValues

/-! # Finite reductions for the eventual sharp intrinsic theorem -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma intrinsicGain_constant (r : ℕ) (a : ℝ) (ha : 1 ≤ a) :
    intrinsicGain (fun _ : Fin (2*r+1) => a)=balancedRatio r a/Real.sqrt (2*r+1:ℕ) := by
  have ha0 : 0 < a := by linarith
  unfold intrinsicGain
  rw [odd_central_abs_eq_balancedParity r ha]
  have he : incomingEnergy (fun _ : Fin (2*r+1) => a)=(2*r+1:ℕ)*a^2 := by
    simp [incomingEnergy]
  rw [he,Real.sqrt_mul (by positivity),Real.sqrt_sq ha0.le]
  unfold balancedRatio
  ring

lemma intrinsicGain_constant_le (r : ℕ) (a : ℝ) (ha : a ∈ Icc (1:ℝ) 2) :
    intrinsicGain (fun _ : Fin (2*r+1) => a) ≤ 1/balancedCost r := by
  rw [←intrinsicGain_balanced r,intrinsicGain_constant r a ha.1,
    intrinsicGain_constant r (balancedGain r) (balancedGain_mem r).1]
  exact div_le_div_of_nonneg_right (balancedGain_max r ha) (Real.sqrt_nonneg _)

lemma intrinsicParityBound_of_gain_bound (r : ℕ)
    (h : ∀ u : Fin (2*r+1) → ℝ,intrinsicGain u ≤ 1/balancedCost r) :
    IntrinsicParityBound (2*r+1) (balancedCost r) := by
  intro u
  by_cases hu : u=0
  · subst u
    simp [parityCorrelation,incomingLinear,incomingEnergy]
  have hroot := Real.sqrt_pos.mpr (incomingEnergy_pos_of_ne_zero u hu)
  have hh := (div_le_div_iff₀ hroot (balancedCost_pos r)).mp (h u)
  simpa only [one_mul,mul_comm] using hh

/-- Failure of the literal sharp inequality supplies an actual global
maximizer whose normalized coefficient is strictly above the balanced cost. -/
lemma exists_bad_intrinsic_maximizer (r : ℕ) (hr : 1 ≤ r)
    (hbad : ¬IntrinsicParityBound (2*r+1) (balancedCost r)) :
    ∃ u : Fin (2*r+1) → ℝ,IsIntrinsicMaximizer u ∧ 1/balancedCost r < intrinsicGain u := by
  have hnot : ¬∀ v : Fin (2*r+1) → ℝ,intrinsicGain v ≤ 1/balancedCost r :=
    fun h => hbad (intrinsicParityBound_of_gain_bound r h)
  push Not at hnot
  obtain ⟨v,hv⟩ := hnot
  obtain ⟨u,_,hu⟩ := exists_intrinsic_maximizer r hr
  exact ⟨u,hu,hv.trans_le (hu v)⟩

end NeuralGeneralization.OnlineLowerTanh
