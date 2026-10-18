import NeuralGeneralization.RobustCompressionParameters
import NeuralGeneralization.RobustMainBounds
import NeuralGeneralization.RobustMainPosterior

/-!
# Universal polynomial envelope after substituting the actual posterior budgets

The target cylinder, readout truncation, reciprocal noise radius, finite grid,
and statistical inverse error are all instantiated. These are scalar resource
bounds; the separate compression theorem must still produce the coupling.
-/

noncomputable section

namespace NeuralGeneralization.RobustMainAssembly
open ConcreteModel RobustCompressionInput

theorem mainCompressionRadius_inv_le (d C r : ℕ) {c ε : ℝ}
    (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) :
    (mainCompressionRadius d C r c ε)⁻¹ ≤
      6 + (1+((r:ℝ)+1)*mainReadoutCap d C r c ε)/c := by
  let Q : ℝ := 1+((r:ℝ)+1)*mainReadoutCap d C r c ε
  have hcap := mainReadoutCap_ge_eight d C r c hε hε1
  have hQ : 1 ≤ Q := by
    dsimp [Q]
    have hr : (0:ℝ) ≤ r := Nat.cast_nonneg _
    nlinarith
  have hQ0 : 0 < Q := by linarith
  have hsqrt : Real.sqrt Q ≤ Q := by
    apply (Real.sqrt_le_iff).mpr
    constructor
    · linarith
    · nlinarith
  have hden : 0 < 6+Q/c := by positivity
  have hlower : 1/(6+Q/c) ≤ mainCompressionRadius d C r c ε := by
    apply le_min
    · exact one_div_le_one_div_of_le (by norm_num)
        (by have := div_nonneg hQ0.le hc.le; linarith)
    · change 1/(6+Q/c) ≤ c/Real.sqrt Q
      apply (div_le_div_iff₀ hden (Real.sqrt_pos.mpr hQ0)).mpr
      have heq : c*(6+Q/c) = 6*c+Q := by field_simp
      rw [one_mul, heq]
      linarith
  have hh := one_div_le_one_div_of_le (div_pos (by norm_num) hden) hlower
  simpa only [one_div, inv_inv] using hh

def mainCompressionResources (d C r : ℕ) (c ε : ℝ) : RobustCompressionInput :=
  ofRealParameters d (r+2) (digitalMassPolynomial d C r c+1)
    (mainCompressionRadius d C r c ε) (ε/12)

theorem mainCompressionResourceBase_le (d C r : ℕ) {c ε U : ℝ}
    (hU : 1 ≤ U) (hd : (d:ℝ)+1 ≤ U) (hC : (C:ℝ)+1 ≤ U)
    (hr : (r:ℝ)+1 ≤ U) (hc : 0 < c) (hcU : c ≤ U) (hci : c⁻¹ ≤ U)
    (hε : 0 < ε) (hε1 : ε < 1) (hei : ε⁻¹ ≤ U) :
    1+(d:ℝ)+(r+2:ℕ)+(digitalMassPolynomial d C r c+1)+
      (mainCompressionRadius d C r c ε)⁻¹+(ε/12)⁻¹ ≤ 1000000000000000*U^9 := by
  have hU0 : 0 ≤ U := by linarith
  have hD := digitalMassPolynomial_le_base d C r hU hd hC hr hc.le hcU
  have hcap := mainReadoutCap_le_base d C r hU hd hC hr hc.le hcU hε hei
  have hcap0 : 0 ≤ mainReadoutCap d C r c ε :=
    le_trans (by norm_num) (mainReadoutCap_ge_eight d C r c hε hε1)
  have h7 : U^7 ≤ U^9 := pow_le_pow_right₀ hU (by norm_num)
  have h8 : U^8 ≤ U^9 := pow_le_pow_right₀ hU (by norm_num)
  have h1 : U ≤ U^9 := by simpa using (pow_le_pow_right₀ hU (show 1≤9 by norm_num))
  have h9 : 1 ≤ U^9 := one_le_pow₀ hU
  have hQ : 1+((r:ℝ)+1)*mainReadoutCap d C r c ε ≤
      10000000000001*U^8 := by
    have hh : ((r:ℝ)+1)*mainReadoutCap d C r c ε ≤ U*(10000000000000*U^7) := by
      exact mul_le_mul hr hcap hcap0 hU0
    have hp : 1 ≤ U^8 := one_le_pow₀ hU
    nlinarith only [hh,hp]
  have hQdiv : (1+((r:ℝ)+1)*mainReadoutCap d C r c ε)/c ≤
      10000000000001*U^9 := by
    rw [div_eq_mul_inv]
    calc
      _ ≤ (10000000000001*U^8)*U :=
        mul_le_mul hQ hci (inv_nonneg.mpr hc.le) (by positivity)
      _ = _ := by ring
  have hrad := mainCompressionRadius_inv_le d C r hc hε hε1
  have heps : (ε/12)⁻¹ ≤ 12*U := by
    rw [inv_div]
    simpa only [div_eq_mul_inv] using mul_le_mul_of_nonneg_left hei (by norm_num : (0:ℝ)≤12)
  push_cast
  nlinarith

/-- Concrete entropy after substituting the actual target and posterior budgets. -/
theorem mainCompressionEntropy_polynomial :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
      ∀ (d C r : ℕ) (c ε U : ℝ),
        1 ≤ U → (d:ℝ)+1 ≤ U → (C:ℝ)+1 ≤ U → (r:ℝ)+1 ≤ U →
        0 < c → c ≤ U → c⁻¹ ≤ U → 0 < ε → ε < 1 → ε⁻¹ ≤ U →
        ((mainCompressionResources d C r c ε).entropyBudget : ℝ) ≤ A*U^m := by
  obtain ⟨A,hA,m,hbound⟩ := entropyBudget_real_polynomial
  refine ⟨A*(1000000000000000:ℝ)^m, mul_pos hA (by positivity), 9*m, ?_⟩
  intro d C r c ε U hU hd hC hr hc hcU hci hε hε1 hei
  have hR := mainCompressionRadius_pos d C r hc hε hε1
  have hK : 0 ≤ digitalMassPolynomial d C r c+1 := by
    have := digitalMassPolynomial_nonneg d C r c
    linarith
  have hh := hbound d (r+2) (digitalMassPolynomial d C r c+1)
    (mainCompressionRadius d C r c ε) (ε/12) hK hR (by positivity)
  have hbase := mainCompressionResourceBase_le d C r hU hd hC hr hc hcU hci hε hε1 hei
  have hbase0 : 0 ≤ 1+(d:ℝ)+(r+2:ℕ)+(digitalMassPolynomial d C r c+1)+
      (mainCompressionRadius d C r c ε)⁻¹+(ε/12)⁻¹ := by positivity
  calc
    _ ≤ A*(1+(d:ℝ)+(r+2:ℕ)+(digitalMassPolynomial d C r c+1)+
        (mainCompressionRadius d C r c ε)⁻¹+(ε/12)⁻¹)^m := hh
    _ ≤ A*(1000000000000000*U^9)^m :=
      mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hbase0 hbase m) hA.le
    _ = _ := by rw [mul_pow, ← pow_mul]; ring

def mainPolynomialBase (d C r : ℕ) (c ε δ : ℝ) : ℝ :=
  2+(d:ℝ)+C+r+c+c⁻¹+ε⁻¹+Real.log (1/δ)

theorem mainPolynomialBase_bounds (d C r : ℕ) {c ε δ : ℝ}
    (hc : 0 < c) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    let U := mainPolynomialBase d C r c ε δ
    1 ≤ U ∧ (d:ℝ)+1 ≤ U ∧ (C:ℝ)+1 ≤ U ∧ (r:ℝ)+1 ≤ U ∧
      c ≤ U ∧ c⁻¹ ≤ U ∧ ε⁻¹ ≤ U ∧ Real.log (2/δ) ≤ U := by
  have hlog : 0 ≤ Real.log (1/δ) :=
    Real.log_nonneg ((one_le_div hδ).mpr hδ1.le)
  have hci : 0 ≤ c⁻¹ := inv_nonneg.mpr hc.le
  have hei : 0 ≤ ε⁻¹ := inv_nonneg.mpr hε.le
  have hd := Nat.cast_nonneg (α := ℝ) d
  have hC := Nat.cast_nonneg (α := ℝ) C
  have hr := Nat.cast_nonneg (α := ℝ) r
  have hlog2 : Real.log 2 ≤ (1:ℝ) := by
    have hh := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at hh
    exact hh
  have hlogsplit : Real.log (2/δ) = Real.log 2 + Real.log (1/δ) := by
    rw [show (2:ℝ)/δ = 2*(1/δ) by ring, Real.log_mul (by norm_num) (by positivity)]
  dsimp [mainPolynomialBase]
  constructor
  · linarith
  constructor
  · linarith
  constructor
  · linarith
  constructor
  · linarith
  constructor
  · linarith
  constructor
  · linarith
  constructor
  · linarith
  · linarith

/-- The exact statistical budget is dominated by one universal polynomial
in the parameters of the main theorem, with no hidden dependence on depth. -/
theorem mainCompressionSampleBudget_polynomial :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
      ∀ (d C r : ℕ) (c ε δ : ℝ),
        0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
        2*(((mainCompressionResources d C r c ε).entropyBudget : ℝ)+
            Real.log (2/δ))/(ε/12)^2 ≤
          A*(mainPolynomialBase d C r c ε δ)^m := by
  obtain ⟨A,hA,m,hbound⟩ := mainCompressionEntropy_polynomial
  refine ⟨288*(A+1), by positivity, m+3, ?_⟩
  intro d C r c ε δ hc hε hε1 hδ hδ1
  let U := mainPolynomialBase d C r c ε δ
  obtain ⟨hU,hd,hC,hr,hcU,hci,hei,hlog⟩ :=
    mainPolynomialBase_bounds d C r hc hε hδ hδ1
  have hEnt := hbound d C r c ε U hU hd hC hr hc hcU hci hε hε1 hei
  have hUm : U^m ≤ U^(m+1) := pow_le_pow_right₀ hU (by omega)
  have hUone : U ≤ U^(m+1) := by
    simpa only [pow_one] using pow_le_pow_right₀ hU (show 1≤m+1 by omega)
  have hsum : ((mainCompressionResources d C r c ε).entropyBudget : ℝ)+
      Real.log (2/δ) ≤ (A+1)*U^(m+1) := by
    have hm := mul_le_mul_of_nonneg_left hUm hA.le
    nlinarith
  have hεsq : (ε⁻¹)^2 ≤ U^2 :=
    pow_le_pow_left₀ (inv_nonneg.mpr hε.le) hei 2
  have hnonneg : 0 ≤ (A+1)*U^(m+1) := by positivity
  calc
    _ = 288*((mainCompressionResources d C r c ε).entropyBudget+
        Real.log (2/δ))*(ε⁻¹)^2 := by field_simp; ring
    _ ≤ 288*((A+1)*U^(m+1))*U^2 := by
      apply mul_le_mul
      · exact mul_le_mul_of_nonneg_left hsum (by norm_num)
      · exact hεsq
      · positivity
      · positivity
    _ = _ := by rw [show m+3=(m+1)+2 by omega, pow_add]; ring

end NeuralGeneralization.RobustMainAssembly
