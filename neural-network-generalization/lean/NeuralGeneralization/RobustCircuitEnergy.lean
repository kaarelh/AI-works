import NeuralGeneralization.RobustCircuitCloning

/-! # Polynomial energy of the explicit saturated clone -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {d C N r k p : ℕ}

theorem finite_sum_sq_le_card_mul {I : Type*} [Fintype I]
    (z : I → ℝ) {B : ℝ} (hB : 0 ≤ B) (hz : ∀ i, |z i| ≤ B) :
    (∑ i, z i^2) ≤ (Fintype.card I : ℝ)*B^2 := by
  calc
    _ ≤ ∑ _i : I, B^2 := Finset.sum_le_sum fun i _ => by
      simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg _) hB).mpr (hz i)
    _ = _ := by simp

namespace LayeredBooleanCircuit

theorem saturatedClone_input_abs (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) {A a : ℝ} (hA : 0 ≤ A)
    (i : Fin N) (j : Fin (d+1)) :
    |B.saturatedClone e A a (.inl (i,j))| ≤ 3*A := by
  simp only [saturatedClone, abs_mul, abs_of_nonneg hA]
  have hh := mul_le_mul_of_nonneg_left ((B.cloneInputGate e i).abs_coeff_le 0 j) hA
  nlinarith

theorem saturatedClone_internal_abs (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) {A a : ℝ} (hA : 0 ≤ A)
    (s : Fin r) (i j : Fin N) :
    |B.saturatedClone e A a (.inr (.inl (s,i,j)))| ≤ 3*A/(k:ℝ) := by
  cases hj : e.symm j with
  | inl ab =>
    simp only [saturatedClone, hj, abs_div, abs_mul, abs_of_nonneg hA,
      abs_of_nonneg (Nat.cast_nonneg k : (0:ℝ) ≤ k)]
    apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg k)
    have hh := mul_le_mul_of_nonneg_left
      ((B.cloneInternalGate e s i).abs_coeff_le B.constant ab.1) hA
    nlinarith
  | inr z =>
    simp only [saturatedClone, hj, abs_zero]
    positivity

theorem saturatedClone_readout_abs (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) {A a : ℝ} (ha : 0 ≤ a) (i : Fin N) :
    |B.saturatedClone e A a (.inr (.inr i))| ≤ a/(k:ℝ) := by
  simp only [saturatedClone]
  split
  · split_ifs
    · exact le_of_eq (abs_of_nonneg (div_nonneg ha (Nat.cast_nonneg k)))
    · simp only [abs_zero]; positivity
  · simp only [abs_zero]; positivity

/-- A loose polynomial bound suffices: no constant in this energy bound is
raised to the network depth. -/
theorem saturatedClone_energy_le (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (hN : 0 < N) (hk : 0 < k) (hwidth : N ≤ 2*C*k)
    {A a : ℝ} (hA : 0 ≤ A) (ha : 0 ≤ a) :
    weightedSquaredNorm (B.saturatedClone e A a) ≤
      9*(d:ℝ)*((d:ℝ)+1)*A^2 + 36*(r:ℝ)*(C:ℝ)^2*A^2 + 4*(C:ℝ)^2*a^2 := by
  have hNR : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hkR : (0:ℝ)<k := Nat.cast_pos.mpr hk
  have hNC : (N:ℝ)/(k:ℝ) ≤ 2*(C:ℝ) := by
    apply (div_le_iff₀ hkR).mpr
    exact_mod_cast hwidth
  have hfirst : (∑ i, ∑ j, B.saturatedClone e A a (.inl (i,j))^2) ≤
      (N:ℝ)*((d:ℝ)+1)*(3*A)^2 := by
    calc
      _ ≤ ∑ _i : Fin N, ((d:ℝ)+1)*(3*A)^2 :=
        Finset.sum_le_sum fun i _ => by
          simpa only [Fintype.card_fin, Nat.cast_add, Nat.cast_one] using
            finite_sum_sq_le_card_mul _ (by positivity) (B.saturatedClone_input_abs e hA i)
      _ = _ := by simp; ring
  have hinternal (s : Fin r) :
      (∑ i, ∑ j, B.saturatedClone e A a (.inr (.inl (s,i,j)))^2) ≤
        (N:ℝ)^2*(3*A/(k:ℝ))^2 := by
    calc
      _ ≤ ∑ _i : Fin N, (N:ℝ)*(3*A/(k:ℝ))^2 :=
        Finset.sum_le_sum fun i _ => by
          simpa only [Fintype.card_fin] using finite_sum_sq_le_card_mul _
            (by positivity) (B.saturatedClone_internal_abs e hA s i)
      _ = _ := by simp; ring
  have hreadout : (∑ i, B.saturatedClone e A a (.inr (.inr i))^2) ≤
      (N:ℝ)*(a/(k:ℝ))^2 := by
    simpa only [Fintype.card_fin] using finite_sum_sq_le_card_mul _
      (by positivity) (B.saturatedClone_readout_abs e ha)
  have hratsq : ((N:ℝ)/(k:ℝ))^2 ≤ (2*(C:ℝ))^2 :=
    (sq_le_sq₀ (by positivity) (by positivity)).mpr hNC
  have hinternal' (s : Fin r) :
      (∑ i, ∑ j, B.saturatedClone e A a (.inr (.inl (s,i,j)))^2) ≤
        36*(C:ℝ)^2*A^2 := by
    apply (hinternal s).trans
    have hh := mul_le_mul_of_nonneg_right hratsq (sq_nonneg (3*A))
    convert hh using 1 <;> try field_simp <;> ring
  have hreadout' : (N:ℝ)*(∑ i, B.saturatedClone e A a (.inr (.inr i))^2) ≤
      4*(C:ℝ)^2*a^2 := by
    have hh := mul_le_mul_of_nonneg_left hreadout hNR.le
    have hh' := mul_le_mul_of_nonneg_right hratsq (sq_nonneg a)
    have hcalc : (N:ℝ)*((N:ℝ)*(a/(k:ℝ))^2) = ((N:ℝ)/(k:ℝ))^2*a^2 := by ring
    rw [hcalc] at hh
    nlinarith
  have hfirst' : (d:ℝ)/(N:ℝ)*(∑ i, ∑ j, B.saturatedClone e A a (.inl (i,j))^2) ≤
      9*(d:ℝ)*((d:ℝ)+1)*A^2 := by
    have hh := mul_le_mul_of_nonneg_left hfirst (by positivity : 0 ≤ (d:ℝ)/(N:ℝ))
    apply hh.trans_eq
    field_simp
    ring
  have hintotal : (∑ s, ∑ i, ∑ j, B.saturatedClone e A a (.inr (.inl (s,i,j)))^2) ≤
      36*(r:ℝ)*(C:ℝ)^2*A^2 := by
    calc
      _ ≤ ∑ _s : Fin r, 36*(C:ℝ)^2*A^2 := Finset.sum_le_sum fun s _ => hinternal' s
      _ = _ := by simp; ring
  unfold weightedSquaredNorm
  linarith

end LayeredBooleanCircuit
end NeuralGeneralization.ConcreteModel
