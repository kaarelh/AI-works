import NeuralGeneralization.RobustCircuitMargin
import NeuralGeneralization.RobustModelBounds

/-! # The actual readout lower bound and calibrated noise radius -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {d C N r k p : ℕ}

namespace LayeredBooleanCircuit

theorem saturatedClone_readout_eq (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (A a : ℝ) (h : Fin N → ℝ) :
    (∑ i, B.saturatedClone e A a (.inr (.inr i))*h i) = a*cloneMean e h B.output := by
  rw [← e.sum_comp]
  simp only [Fintype.sum_sum_type, Fintype.sum_prod_type, saturatedClone,
    Equiv.symm_apply_apply, zero_mul, Finset.sum_const_zero, add_zero]
  rw [Finset.sum_comm]
  simp only [ite_mul, zero_mul, Finset.sum_ite_eq', Finset.mem_univ, ite_true]
  simp only [cloneMean, ← Finset.mul_sum]
  ring

theorem saturatedClone_sum_readout (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (hk : 0 < k) (A a : ℝ) :
    (∑ i, B.saturatedClone e A a (.inr (.inr i))) = a := by
  have hh := B.saturatedClone_readout_eq e A a (fun _ => 1)
  have hkR : (k:ℝ) ≠ 0 := by exact_mod_cast hk.ne'
  simpa [cloneMean, hkR] using hh

end LayeredBooleanCircuit

/-- The whole readout perturbation has bounded pairing with every vector
whose coordinates have absolute value at most one. -/
theorem readout_coordinate_error_pairing (hN : 0 < N)
    (w v : Weights d N r) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (herr : ∀ i, |w (.inr (.inr i))-v (.inr (.inr i))| ≤ ρ/(N:ℝ))
    (h : Fin N → ℝ) (hh : ∀ i, |h i| ≤ 1) :
    |(∑ i,w (.inr (.inr i))*h i)-(∑ i,v (.inr (.inr i))*h i)| ≤ ρ := by
  have hNR : (N:ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  rw [← Finset.sum_sub_distrib]
  calc
    _ ≤ ∑ i, |w (.inr (.inr i))*h i-v (.inr (.inr i))*h i| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : Fin N, ρ/(N:ℝ) := Finset.sum_le_sum fun i _ => by
      rw [← sub_mul, abs_mul]
      exact (mul_le_mul (herr i) (hh i) (abs_nonneg _) (by positivity)).trans_eq (mul_one _)
    _ = ρ := by simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]; field_simp

/-- Uniform scalar readout bounds imply a lower energy bound at every width. -/
theorem readoutEnergy_lower_of_sum (hN : 0 < N)
    (w v : Weights d N r) {a ρ : ℝ} (hρ : 0 ≤ ρ) (haρ : ρ ≤ a/2)
    (hsum : (∑ i,v (.inr (.inr i)))=a)
    (herr : ∀ i, |w (.inr (.inr i))-v (.inr (.inr i))| ≤ ρ/(N:ℝ)) :
    a^2/4 ≤ readoutEnergy w := by
  have he := readout_coordinate_error_pairing hN w v hρ herr (fun _ => 1)
    (fun _ => by norm_num)
  simp only [mul_one, hsum] at he
  have hsumw : a/2 ≤ ∑ i,w (.inr (.inr i)) := by
    have hh := (abs_le.mp he).1
    linarith
  have ha : 0 ≤ a/2 := hρ.trans haρ
  have hsq := (sq_le_sq₀ ha (ha.trans hsumw)).mpr hsumw
  have hc := Finset.sum_mul_sq_le_sq_mul_sq (s:=Finset.univ)
    (fun _ : Fin N => (1:ℝ)) (fun i => w (.inr (.inr i)))
  simp only [one_mul, one_pow, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, mul_one] at hc
  unfold readoutEnergy
  nlinarith

/-- Polynomial readout amplification makes the calibrated ball fit inside
the finite digital noise ball. -/
theorem robustRadius_le_of_readoutEnergy (w : Weights d N r)
    {a c τ : ℝ} (ha : 0 ≤ a) (hτ : 0 ≤ τ)
    (henergy : a^2/4 ≤ readoutEnergy w) (hcal : 2*c ≤ τ*a) :
    robustRadius c w ≤ τ := by
  have hpos : 0 < 1+((r:ℝ)+1)*readoutEnergy w := by
    have := readoutEnergy_nonneg w
    positivity
  have hs : a/2 ≤ Real.sqrt (1+((r:ℝ)+1)*readoutEnergy w) := by
    apply (Real.le_sqrt (by positivity) (le_of_lt hpos)).mpr
    have hh := readoutEnergy_nonneg w
    have hr : 0 ≤ (r:ℝ)*readoutEnergy w := mul_nonneg (Nat.cast_nonneg r) hh
    nlinarith
  unfold robustRadius
  apply (div_le_iff₀ (Real.sqrt_pos.mpr hpos)).mpr
  have hh := mul_le_mul_of_nonneg_left hs hτ
  nlinarith

end NeuralGeneralization.ConcreteModel
