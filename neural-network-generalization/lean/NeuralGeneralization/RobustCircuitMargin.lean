import NeuralGeneralization.RobustCircuitEnergy

/-! # Signed gate margins from RMS error of the saturated clone -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {d C N r k p : ℕ}

theorem cloneMean_error_le (hk : 0 < k) (hwidth : N ≤ 2*C*k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (h : Fin N → ℝ) (padding : Fin C) (b : Fin C → Bool) {ε δ : ℝ}
    (hδ : 0 ≤ δ) (hsmall : 2*(C:ℝ)*ε^2 ≤ δ^2)
    (hstate : (∑ i,(h i-saturatedCloneBits e padding b i)^2) ≤ (N:ℝ)*ε^2)
    (a : Fin C) : |cloneMean e h a-labelReal (b a)| ≤ δ := by
  have hkR : (0:ℝ)<k := Nat.cast_pos.mpr hk
  have hNratio : (N:ℝ)/(k:ℝ) ≤ 2*(C:ℝ) := by
    apply (div_le_iff₀ hkR).mpr
    exact_mod_cast hwidth
  have hh := cloneMean_error_sq hk e h padding b a
  have hh' := div_le_div_of_nonneg_right hstate hkR.le
  have hh'' := mul_le_mul_of_nonneg_right hNratio (sq_nonneg ε)
  apply (sq_le_sq₀ (abs_nonneg _) hδ).mp
  rw [sq_abs]
  calc
    _ ≤ (∑ i,(h i-saturatedCloneBits e padding b i)^2)/(k:ℝ) := hh
    _ ≤ ((N:ℝ)*ε^2)/(k:ℝ) := hh'
    _ = ((N:ℝ)/(k:ℝ))*ε^2 := by ring
    _ ≤ 2*(C:ℝ)*ε^2 := hh''
    _ ≤ _ := hsmall

/-- The exact Boolean constant is approximated as one of the counted wires. -/
theorem DigitalGate.signed_linear_near_bits {I : Type*}
    (g : DigitalGate I) (b : I → Bool) (h : I → ℝ) (constant : I)
    (hconstant : ∀ j k, g = .nand j k → b constant = true)
    (hh : ∀ i, |h i-labelReal (b i)| ≤ (1/16:ℝ)) :
    (1/2:ℝ) ≤ labelReal (g.eval b)*g.linear (h constant) h := by
  cases g with
  | copy i =>
    have hi := abs_le.mp (hh i)
    cases hb : b i <;> simp [DigitalGate.eval, DigitalGate.linear, hb, labelReal] at * <;> linarith
  | negate i =>
    have hi := abs_le.mp (hh i)
    cases hb : b i <;> simp [DigitalGate.eval, DigitalGate.linear, hb, labelReal] at * <;> linarith
  | nand i j =>
    have hc := hconstant i j rfl
    have he := (DigitalGate.nand i j).linear_error h (fun k => labelReal (b k))
      (h constant) 1 (1/16) (by norm_num)
      (by simpa only [hc, labelReal_true] using hh constant) hh
    have hm := (DigitalGate.nand i j).signed_linear_margin b
    have habs := abs_le.mp he
    cases hb : (DigitalGate.nand i j).eval b <;>
      simp only [hb, labelReal_false, labelReal_true, neg_one_mul, one_mul] at hm ⊢ <;> linarith

namespace LayeredBooleanCircuit

theorem cloneGate_eval_step (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (b : Fin C → Bool)
    (s : Fin r) (i : Fin N) :
    labelReal ((B.cloneInternalGate e s i).eval b) =
      saturatedCloneBits e B.constant (B.stepBits b s) i := by
  cases hi : e.symm i with
  | inl ab => simp [cloneInternalGate, saturatedCloneBits, stepBits, hi]
  | inr z => simp [cloneInternalGate, saturatedCloneBits, stepBits, hi]

/-- The full teacher preactivation retains at least half its signed gain. -/
theorem saturatedClone_signed_internal (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (hk : 0 < k) (hwidth : N ≤ 2*C*k)
    {A a ε : ℝ} (hA : 0 ≤ A) (hsmall : 2*(C:ℝ)*ε^2 ≤ (1/16:ℝ)^2)
    (h : Fin N → ℝ) (b : Fin C → Bool) (s : Fin r) (hc : ∀ i j k, B.internal s i = .nand j k → b B.constant = true)
    (hstate : (∑ i,(h i-saturatedCloneBits e B.constant b i)^2) ≤ (N:ℝ)*ε^2)
    (i : Fin N) :
    A/2 ≤ saturatedCloneBits e B.constant (B.stepBits b s) i *
      (∑ j, B.saturatedClone e A a (.inr (.inl (s,i,j)))*h j) := by
  rw [saturatedClone_internal_preactivation, ← B.cloneGate_eval_step e b s i]
  have hh := (B.cloneInternalGate e s i).signed_linear_near_bits b (cloneMean e h)
    B.constant (by
      intro j k hgate
      cases hi : e.symm i with
      | inl ab => exact hc ab.1 j k (by simpa [cloneInternalGate, hi] using hgate)
      | inr z => exact hc B.constant j k (by simpa [cloneInternalGate, hi] using hgate))
    (cloneMean_error_le hk hwidth e h B.constant b (by norm_num) hsmall hstate)
  have hm := mul_le_mul_of_nonneg_left hh hA
  nlinarith

end LayeredBooleanCircuit
end NeuralGeneralization.ConcreteModel
