import NeuralGeneralization.RobustCircuitEnergy

/-! # Signed gate margins from RMS error of the saturated clone -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {d C N r k p : ℕ}

theorem cloneMean_error_le (hk : 0 < k) (hwidth : N ≤ 2*C*k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (h : Fin N → ℝ) (b : Fin C → Bool) {ε δ : ℝ}
    (hδ : 0 ≤ δ) (hsmall : 2*(C:ℝ)*ε^2 ≤ δ^2)
    (hstate : (∑ i,(h i-saturatedCloneBits e b i)^2) ≤ (N:ℝ)*ε^2)
    (a : Fin C) : |cloneMean e h a-labelReal (b a)| ≤ δ := by
  have hkR : (0:ℝ)<k := Nat.cast_pos.mpr hk
  have hNratio : (N:ℝ)/(k:ℝ) ≤ 2*(C:ℝ) := by
    apply (div_le_iff₀ hkR).mpr
    exact_mod_cast hwidth
  have hh := cloneMean_error_sq hk e h b a
  have hh' := div_le_div_of_nonneg_right hstate hkR.le
  have hh'' := mul_le_mul_of_nonneg_right hNratio (sq_nonneg ε)
  apply (sq_le_sq₀ (abs_nonneg _) hδ).mp
  rw [sq_abs]
  calc
    _ ≤ (∑ i,(h i-saturatedCloneBits e b i)^2)/(k:ℝ) := hh
    _ ≤ ((N:ℝ)*ε^2)/(k:ℝ) := hh'
    _ = ((N:ℝ)/(k:ℝ))*ε^2 := by ring
    _ ≤ 2*(C:ℝ)*ε^2 := hh''
    _ ≤ _ := hsmall

/-- The exact Boolean constant is approximated as one of the counted wires. -/
theorem DigitalGate.signed_linear_near_bits {I : Type*}
    (g : DigitalGate I) (b : I → Bool) (h : I → ℝ) (constant : I)
    (hconstant : b constant = true)
    (hh : ∀ i, |h i-labelReal (b i)| ≤ (1/16:ℝ)) :
    (1/2:ℝ) ≤ labelReal (g.eval b)*g.linear (h constant) h := by
  have he := g.linear_error h (fun i=>labelReal (b i)) (h constant) 1 (1/16)
    (by norm_num) (by simpa only [hconstant, labelReal_true] using hh constant) hh
  have hm := g.signed_linear_margin b
  have habs := abs_le.mp he
  cases hb : g.eval b <;> simp only [hb, labelReal_false, labelReal_true, neg_one_mul,
    one_mul] at hm ⊢ <;> linarith

namespace LayeredBooleanCircuit

theorem cloneGate_eval_step (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (b : Fin C → Bool)
    (hc : b B.constant = true) (s : Fin r) (i : Fin N) :
    labelReal ((B.cloneInternalGate e s i).eval b) =
      saturatedCloneBits e (B.stepBits b s) i := by
  cases hi : e.symm i with
  | inl ab => simp [cloneInternalGate, saturatedCloneBits, stepBits, hi]
  | inr z => simp [cloneInternalGate, saturatedCloneBits, DigitalGate.eval, hc, hi]

/-- The full teacher preactivation retains at least half its signed gain. -/
theorem saturatedClone_signed_internal (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (hk : 0 < k) (hwidth : N ≤ 2*C*k)
    {A a ε : ℝ} (hA : 0 ≤ A) (hsmall : 2*(C:ℝ)*ε^2 ≤ (1/16:ℝ)^2)
    (h : Fin N → ℝ) (b : Fin C → Bool) (hc : b B.constant = true)
    (hstate : (∑ i,(h i-saturatedCloneBits e b i)^2) ≤ (N:ℝ)*ε^2)
    (s : Fin r) (i : Fin N) :
    A/2 ≤ saturatedCloneBits e (B.stepBits b s) i *
      (∑ j, B.saturatedClone e A a (.inr (.inl (s,i,j)))*h j) := by
  rw [saturatedClone_internal_preactivation, ← B.cloneGate_eval_step e b hc s i]
  have hh := (B.cloneInternalGate e s i).signed_linear_near_bits b (cloneMean e h)
    B.constant hc (cloneMean_error_le hk hwidth e h b (by norm_num) hsmall hstate)
  have hm := mul_le_mul_of_nonneg_left hh hA
  nlinarith

end LayeredBooleanCircuit
end NeuralGeneralization.ConcreteModel
