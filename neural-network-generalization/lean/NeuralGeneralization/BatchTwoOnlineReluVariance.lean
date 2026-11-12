import NeuralGeneralization.GaussianModelRate
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-! Exact parameter-count times variance budgets, including the L=2 boundary. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel

theorem relu_parameter_count (d N r : ℕ) :
    (Fintype.card (WeightIndex d N r):ℝ)=(N:ℝ)*((d:ℝ)+2)+(r:ℝ)*(N:ℝ)^2 := by
  simp only [WeightIndex,Fintype.card_sum,Fintype.card_prod,Fintype.card_fin,
    Nat.cast_add,Nat.cast_mul,Nat.cast_one]
  ring

theorem relu_variance_budget {N : ℕ} (hN : 0<N) {γ : ℝ} (hγ : 0≤γ) :
    0<(N:ℝ)^(-γ) ∧ (N:ℝ)^(-γ)≤1 := by
  have hNR : (1:ℝ)≤N := by exact_mod_cast hN
  exact ⟨Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _,Real.rpow_le_one_of_one_le_of_nonpos hNR (neg_nonpos.mpr hγ)⟩

theorem relu_dimension_variance_budget {d N r : ℕ} (hN : 0<N) {γ : ℝ} (hγ : 2≤γ) :
    (Fintype.card (WeightIndex d N r):ℝ)*(N:ℝ)^(-γ)≤(d:ℝ)+(r+2:ℝ) := by
  have hNR : (1:ℝ)≤N := by exact_mod_cast hN
  have hp : 0<(N:ℝ) := Nat.cast_pos.mpr hN
  have hv : (N:ℝ)^(-γ)≤(N:ℝ)^(-2:ℝ) := Real.rpow_le_rpow_of_exponent_le hNR (by linarith)
  have hc : (Fintype.card (WeightIndex d N r):ℝ)≤((d:ℝ)+(r+2:ℝ))*(N:ℝ)^2 := by
    rw [relu_parameter_count]
    have hn : (N:ℝ)≤(N:ℝ)^2 := by nlinarith
    have hh := mul_le_mul_of_nonneg_left hn (show 0≤(d:ℝ)+2 by positivity)
    nlinarith
  calc
    _ ≤ ((d:ℝ)+(r+2:ℝ))*(N:ℝ)^2*(N:ℝ)^(-2:ℝ) :=
      mul_le_mul hc hv (Real.rpow_pos_of_pos hp _).le (by positivity)
    _ = _ := by rw [Real.rpow_neg hp.le,Real.rpow_two]; field_simp

theorem relu_shallow_dimension_variance_budget {d N : ℕ} (hN : 0<N) {γ : ℝ} (hγ : 1≤γ) :
    (Fintype.card (WeightIndex d N 0):ℝ)*(N:ℝ)^(-γ)≤(d:ℝ)+2 := by
  have hNR : (1:ℝ)≤N := by exact_mod_cast hN
  have hp : 0<(N:ℝ) := Nat.cast_pos.mpr hN
  have hv : (N:ℝ)^(-γ)≤(N:ℝ)^(-1:ℝ) := Real.rpow_le_rpow_of_exponent_le hNR (by linarith)
  rw [relu_parameter_count]
  simp only [Nat.cast_zero,zero_mul,add_zero]
  calc
    _ ≤ (N:ℝ)*((d:ℝ)+2)*(N:ℝ)^(-1:ℝ) := mul_le_mul_of_nonneg_left hv (by positivity)
    _ = _ := by rw [Real.rpow_neg_one]; field_simp

end NeuralGeneralization.BatchTwoOnlineReluFinite
