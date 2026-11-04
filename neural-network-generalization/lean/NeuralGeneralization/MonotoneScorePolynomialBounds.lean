import NeuralGeneralization.MonotoneScoreResources
import NeuralGeneralization.RobustLocalizedPolynomial

/-! A fixed-degree polynomial bound uniform over all score transforms. The
transform enters only through the reciprocal of its positive endpoint gap. -/
noncomputable section
namespace NeuralGeneralization.ScoreTransform
open ConcreteModel RobustMainAssembly RobustCompressionInput

def polynomialBase (d C r M : ℕ) (c ε δ Δ : ℝ) : ℝ :=
  RobustLocalized.polynomialBase d C r M c ε δ+Δ⁻¹+1

lemma polynomialBase_bounds (d C r : ℕ) {M : ℕ} (hM : 0 < M) {c ε δ Δ : ℝ}
    (hc : 0 < c) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) (hΔ : 0 < Δ) :
    let U := polynomialBase d C r M c ε δ Δ
    1 ≤ U ∧ (d:ℝ)+1 ≤ U ∧ (C:ℝ)+1 ≤ U ∧ (r:ℝ)+1 ≤ U ∧
      c ≤ U ∧ c⁻¹ ≤ U ∧ ε⁻¹ ≤ U ∧ Real.log (M:ℝ) ≤ U ∧ Real.log (4/δ) ≤ U ∧ Δ⁻¹ ≤ U := by
  obtain ⟨h1,hd,hC,hr,hcU,hci,hei,hMlog,hδlog⟩ := RobustLocalized.polynomialBase_bounds d C r hM hc hε hδ hδ1
  have hi := inv_pos.mpr hΔ
  dsimp [polynomialBase]
  exact ⟨by linarith,by linarith,by linarith,by linarith,by linarith,
    by linarith,by linarith,by linarith,by linarith,by linarith⟩

lemma radius_inv_le (r : ℕ) {K c ε Δ : ℝ} (hK : 0 ≤ K) (hc : 0 < c)
    (hε : 0 < ε) (hε1 : ε < 1) (hΔ : 0 < Δ) :
    (radius r K c ε Δ)⁻¹ ≤ (RobustConditioned.radius r K c ε)⁻¹+2*Δ⁻¹ := by
  have hr := RobustConditioned.radius_pos r hK hc hε hε1
  have hd := inv_pos.mpr hΔ
  unfold radius
  rcases le_total (2*Δ/3) (RobustConditioned.radius r K c ε) with hh | hh
  · rw [min_eq_left hh]
    have heq : (2*Δ/3)⁻¹ = (3/2:ℝ)*Δ⁻¹ := by field_simp
    rw [heq]
    linarith [inv_pos.mpr hr]
  · rw [min_eq_right hh]
    linarith

lemma resourceBase_le (d C r : ℕ) {K c ε Δ U : ℝ}
    (hU : 1 ≤ U) (hd : (d:ℝ)+1 ≤ U) (hC : (C:ℝ)+1 ≤ U) (hr : (r:ℝ)+1 ≤ U)
    (hc : 0 < c) (hcU : c ≤ U) (hci : c⁻¹ ≤ U)
    (hε : 0 < ε) (hε1 : ε < 1) (hei : ε⁻¹ ≤ U) (hΔ : 0 < Δ) (hΔi : Δ⁻¹ ≤ U) (hK0 : 0 ≤ K)
    (hK : K ≤ 2000000000000*U^7) :
    1+(d:ℝ)+(r+2:ℕ)+(K+1)+(radius r K c ε Δ)⁻¹+(ε/12)⁻¹ ≤
      2000000000000000*U^9 := by
  have hnlog : -Real.log (ε/12) ≤ 12*U := by
    have hh := Real.neg_inv_le_log (show 0 ≤ ε/12 by positivity)
    have heq : (ε/12)⁻¹ = 12*ε⁻¹ := by field_simp
    rw [heq] at hh
    linarith
  have hU7 : U ≤ U^7 := by simpa using pow_le_pow_right₀ hU (show 1 ≤ 7 by omega)
  have h17 : 1 ≤ U^7 := one_le_pow₀ hU
  have hcap : RobustConditioned.cap K ε ≤ 10000000000000*U^7 := by
    dsimp [RobustConditioned.cap]; linarith
  have hcap0 : 0 ≤ RobustConditioned.cap K ε :=
    (show (0:ℝ) ≤ 8 by norm_num).trans (RobustConditioned.cap_ge_eight hK0 hε hε1)
  have hU0 : 0 ≤ U := by linarith
  have hQ : 1+((r:ℝ)+1)*RobustConditioned.cap K ε ≤ 10000000000001*U^8 := by
    have hh := mul_le_mul hr hcap hcap0 hU0
    have hp := one_le_pow₀ hU (n := 8)
    nlinarith only [hh,hp]
  have hQdiv : (1+((r:ℝ)+1)*RobustConditioned.cap K ε)/c ≤ 10000000000001*U^9 := by
    rw [div_eq_mul_inv]
    calc
      _ ≤ (10000000000001*U^8)*U := mul_le_mul hQ hci (inv_nonneg.mpr hc.le) (by positivity)
      _ = _ := by ring
  have hrad := RobustConditioned.radius_inv_le r hK0 hc hε hε1
  have hradnew := radius_inv_le r hK0 hc hε hε1 hΔ
  have heps : (ε/12)⁻¹ ≤ 12*U := by
    rw [inv_div]
    simpa only [div_eq_mul_inv] using mul_le_mul_of_nonneg_left hei (by norm_num : (0:ℝ) ≤ 12)
  have h7 : U^7 ≤ U^9 := pow_le_pow_right₀ hU (by norm_num)
  have h1 : U ≤ U^9 := by simpa using pow_le_pow_right₀ hU (show 1 ≤ 9 by omega)
  have h9 : 1 ≤ U^9 := one_le_pow₀ hU
  push_cast
  nlinarith

/-- Generic cost form, instantiated with the actual digital target cost
and with the localized component cost in the final theorem wrappers. -/
theorem sampleBudget_for_cost_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ d C r M : ℕ,0 < M → ∀ K c ε δ Δ : ℝ,
      0 ≤ K → 0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 → 0 < Δ →
      K ≤ 2000000000000*(polynomialBase d C r M c ε δ Δ)^7 →
      2*(Real.log (M:ℝ)+(resources d r K c ε Δ).entropyBudget+Real.log (4/δ))/(ε/12)^2 ≤
        A*(polynomialBase d C r M c ε δ Δ)^k := by
  obtain ⟨A,hA,k,hbound⟩ := entropyBudget_real_polynomial
  refine ⟨288*(A*(2000000000000000:ℝ)^k+2),by positivity,9*k+3,?_⟩
  intro d C r M hM K c ε δ Δ hK hc hε hε1 hδ hδ1 hΔ hKU
  let U := polynomialBase d C r M c ε δ Δ
  obtain ⟨hU,hd,hC,hr,hcU,hci,hei,hMlog,hδlog,hΔi⟩ := polynomialBase_bounds d C r hM hc hε hδ hδ1 hΔ
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

end NeuralGeneralization.ScoreTransform
