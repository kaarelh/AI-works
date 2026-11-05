import NeuralGeneralization.MonotoneScorePolynomialBounds

/-! A universal fixed-degree sample envelope, polynomial also in the training
margin and reciprocal training/test score gap. -/
noncomputable section
namespace NeuralGeneralization.GeneralMargin
open ConcreteModel RobustMainAssembly RobustCompressionInput
open ScoreTransform (radius radius_pos resources resourceBase_le)

def polynomialBase (d C r M : ℕ) (m c ε δ Δ : ℝ) : ℝ :=
  ScoreTransform.polynomialBase d C r M c ε δ Δ+m+1

lemma polynomialBase_bounds (d C r : ℕ) {M : ℕ} (hM : 0 < M) {m c ε δ Δ : ℝ}
    (hm : 0 ≤ m) (hc : 0 < c) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) (hΔ : 0 < Δ) :
    let U := polynomialBase d C r M m c ε δ Δ
    1 ≤ U ∧ (d:ℝ)+1 ≤ U ∧ (C:ℝ)+1 ≤ U ∧ (r:ℝ)+1 ≤ U ∧
      c ≤ U ∧ c⁻¹ ≤ U ∧ ε⁻¹ ≤ U ∧ Real.log (M:ℝ) ≤ U ∧ Real.log (4/δ) ≤ U ∧ Δ⁻¹ ≤ U ∧
      c+m+1 ≤ U := by
  obtain ⟨h1,hd,hC,hr,hcU,hci,hei,hMlog,hδlog,hΔi⟩ :=
    ScoreTransform.polynomialBase_bounds d C r hM hc hε hδ hδ1 hΔ
  dsimp [polynomialBase]
  exact ⟨by linarith,by linarith,by linarith,by linarith,by linarith,
    by linarith,by linarith,by linarith,by linarith,by linarith,by linarith⟩

/-- Generic cost form, instantiated with the actual digital target cost
and with the localized component cost in the final theorem wrappers. -/
theorem sampleBudget_for_cost_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ d C r M : ℕ,0 < M → ∀ m K c ε δ Δ : ℝ,
      0 ≤ m → 0 ≤ K → 0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 → 0 < Δ →
      K ≤ 2000000000000*(polynomialBase d C r M m c ε δ Δ)^7 →
      2*(Real.log (M:ℝ)+(resources d r K c ε Δ).entropyBudget+Real.log (4/δ))/(ε/12)^2 ≤
        A*(polynomialBase d C r M m c ε δ Δ)^k := by
  obtain ⟨A,hA,k,hbound⟩ := entropyBudget_real_polynomial
  refine ⟨288*(A*(2000000000000000:ℝ)^k+2),by positivity,9*k+3,?_⟩
  intro d C r M hM m K c ε δ Δ hm hK hc hε hε1 hδ hδ1 hΔ hKU
  let U := polynomialBase d C r M m c ε δ Δ
  obtain ⟨hU,hd,hC,hr,hcU,hci,hei,hMlog,hδlog,hΔi,hcm⟩ := polynomialBase_bounds d C r hM hm hc hε hδ hδ1 hΔ
  have hradius := radius_pos r hK hc hε hε1 hΔ
  have hb := hbound d (r+2) (K+1) (radius r K c ε Δ) (ε/12)
    (by positivity) hradius (by positivity)
  have hbase := resourceBase_le d C r hU hd hC hr hc hcU hci hε hε1 hei hΔ hΔi hK hKU
  have hent : (resources d r K c ε Δ).entropyBudget ≤
      (A*(2000000000000000:ℝ)^k)*U^(9*k) := by
    calc
      _ ≤ A*(1+(d:ℝ)+(r+2:ℕ)+(K+1)+(radius r K c ε Δ)⁻¹+(ε/12)⁻¹)^k := hb
      _ ≤ A*(2000000000000000*U^9)^k :=
        mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (by positivity) hbase k) hA.le
      _ = _ := by rw [mul_pow,← pow_mul]; ring
  have hpow : U^(9*k) ≤ U^(9*k+1) := pow_le_pow_right₀ hU (by omega)
  have hUone : U ≤ U^(9*k+1) := by simpa using pow_le_pow_right₀ hU (show 1 ≤ 9*k+1 by omega)
  have hsum : Real.log (M:ℝ)+(resources d r K c ε Δ).entropyBudget+Real.log (4/δ) ≤
      (A*(2000000000000000:ℝ)^k+2)*U^(9*k+1) := by
    have hh := mul_le_mul_of_nonneg_left hpow (show 0 ≤ A*(2000000000000000:ℝ)^k by positivity)
    nlinarith only [hent,hh,hMlog,hδlog,hUone]
  have heps : (ε⁻¹)^2 ≤ U^2 := pow_le_pow_left₀ (inv_nonneg.mpr hε.le) hei 2
  calc
    _ = 288*(Real.log (M:ℝ)+(resources d r K c ε Δ).entropyBudget+Real.log (4/δ))*(ε⁻¹)^2 := by field_simp; ring
    _ ≤ 288*((A*(2000000000000000:ℝ)^k+2)*U^(9*k+1))*U^2 := by
      apply mul_le_mul
      · exact mul_le_mul_of_nonneg_left hsum (by norm_num)
      · exact heps
      · positivity
      · positivity
    _ = _ := by rw [show 9*k+3=(9*k+1)+2 by omega,pow_add]; ring

end NeuralGeneralization.GeneralMargin
