import NeuralGeneralization.RobustLocalizedMain

/-! Universal polynomial bounds for localization. The family enters only
through log M; the degree and coefficient precede all problem parameters. -/
noncomputable section
namespace NeuralGeneralization.RobustConditioned
open ConcreteModel RobustMainAssembly RobustCompressionInput
theorem radius_inv_le (r : ℕ) {K c ε : ℝ} (hK : 0 ≤ K)
    (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) :
    (radius r K c ε)⁻¹ ≤
      6 + (1+((r:ℝ)+1)*cap K ε)/c := by
  let Q : ℝ := 1+((r:ℝ)+1)*cap K ε
  have hcap := cap_ge_eight hK hε hε1
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
  have hlower : 1/(6+Q/c) ≤ radius r K c ε := by
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

end NeuralGeneralization.RobustConditioned
namespace NeuralGeneralization.RobustLocalized
open ConcreteModel RobustMainAssembly RobustCompressionInput

def polynomialBase (d C r M : ℕ) (c ε δ : ℝ) : ℝ :=
  mainPolynomialBase d C r c ε δ + Real.log (M:ℝ)+2

lemma polynomialBase_bounds (d C r : ℕ) {M : ℕ} (hM : 0 < M) {c ε δ : ℝ}
    (hc : 0 < c) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    let U := polynomialBase d C r M c ε δ
    1 ≤ U ∧ (d:ℝ)+1 ≤ U ∧ (C:ℝ)+1 ≤ U ∧ (r:ℝ)+1 ≤ U ∧
      c ≤ U ∧ c⁻¹ ≤ U ∧ ε⁻¹ ≤ U ∧ Real.log (M:ℝ) ≤ U ∧ Real.log (4/δ) ≤ U := by
  have hh := mainPolynomialBase_bounds d C r hc hε hδ hδ1
  have hlog : 0 ≤ Real.log (M:ℝ) := Real.log_nonneg (by exact_mod_cast hM)
  have hlog2 : Real.log (2:ℝ) ≤ 1 := by
    have hh := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at hh
    exact hh
  have hid : Real.log (4/δ) = Real.log (2:ℝ)+Real.log (2/δ) := by
    rw [← Real.log_mul (by norm_num) (by positivity)]; congr 1; ring
  dsimp [polynomialBase]
  rcases hh with ⟨h1,hd,hC,hr,hcU,hci,hei,hlogδ⟩
  refine ⟨by linarith,by linarith,by linarith,by linarith,by linarith,by linarith,by linarith,by linarith,?_⟩
  linarith

lemma componentCost_le_base (d C r : ℕ) {M : ℕ} (hM : 0 < M) {c ε U : ℝ}
    (hU : 1 ≤ U) (hd : (d:ℝ)+1 ≤ U) (hC : (C:ℝ)+1 ≤ U) (hr : (r:ℝ)+1 ≤ U)
    (hc : 0 < c) (hcU : c ≤ U) (hε : 0 < ε) (hei : ε⁻¹ ≤ U) (hMlog : Real.log (M:ℝ) ≤ U) :
    componentCost d C r M c ε ≤ 2000000000000*U^7 := by
  have hD := digitalMassPolynomial_le_base d C r hU hd hC hr hc.le hcU
  have hnlog : -Real.log (ε/12) ≤ 12*U := by
    have hh := Real.neg_inv_le_log (show 0 ≤ ε/12 by positivity)
    have heq : (ε/12)⁻¹ = 12*ε⁻¹ := by field_simp
    rw [heq] at hh
    linarith
  have hU7 : U ≤ U^7 := by simpa using pow_le_pow_right₀ hU (show 1 ≤ 7 by omega)
  unfold componentCost
  rw [Real.log_div (by positivity) (by positivity)]
  linarith

lemma resourceBase_le (d C r : ℕ) {M : ℕ} (hM : 0 < M) {c ε U : ℝ}
    (hU : 1 ≤ U) (hd : (d:ℝ)+1 ≤ U) (hC : (C:ℝ)+1 ≤ U) (hr : (r:ℝ)+1 ≤ U)
    (hc : 0 < c) (hcU : c ≤ U) (hci : c⁻¹ ≤ U)
    (hε : 0 < ε) (hε1 : ε < 1) (hei : ε⁻¹ ≤ U) (hMlog : Real.log (M:ℝ) ≤ U) :
    let K := componentCost d C r M c ε
    1+(d:ℝ)+(r+2:ℕ)+(K+1)+(RobustConditioned.radius r K c ε)⁻¹+(ε/12)⁻¹ ≤
      1000000000000000*U^9 := by
  let K := componentCost d C r M c ε
  have hK0 := componentCost_nonneg d C r hM c hε hε1
  have hK : K ≤ 2000000000000*U^7 := componentCost_le_base d C r hM hU hd hC hr hc hcU hε hei hMlog
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
  have heps : (ε/12)⁻¹ ≤ 12*U := by
    rw [inv_div]
    simpa only [div_eq_mul_inv] using mul_le_mul_of_nonneg_left hei (by norm_num : (0:ℝ) ≤ 12)
  have h7 : U^7 ≤ U^9 := pow_le_pow_right₀ hU (by norm_num)
  have h1 : U ≤ U^9 := by simpa using pow_le_pow_right₀ hU (show 1 ≤ 9 by omega)
  have h9 : 1 ≤ U^9 := one_le_pow₀ hU
  dsimp only
  push_cast
  nlinarith

/-- The labeled budget is one fixed-degree polynomial in d, C, depth,
c+c⁻¹, log M, ε⁻¹ and log(1/δ), independent of N and σ. -/
theorem sampleBudget_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ d C r M : ℕ,0 < M → ∀ c ε δ : ℝ,
      0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      2*(Real.log (M:ℝ)+
        (RobustConditioned.resources d r (componentCost d C r M c ε) c ε).entropyBudget+
        Real.log (4/δ))/(ε/12)^2 ≤ A*(polynomialBase d C r M c ε δ)^k := by
  obtain ⟨A,hA,k,hbound⟩ := entropyBudget_real_polynomial
  refine ⟨288*(A*(1000000000000000:ℝ)^k+2),by positivity,9*k+3,?_⟩
  intro d C r M hM c ε δ hc hε hε1 hδ hδ1
  let U := polynomialBase d C r M c ε δ
  let K := componentCost d C r M c ε
  obtain ⟨hU,hd,hC,hr,hcU,hci,hei,hMlog,hδlog⟩ := polynomialBase_bounds d C r hM hc hε hδ hδ1
  have hK := componentCost_nonneg d C r hM c hε hε1
  have hradius := RobustConditioned.radius_pos r hK hc hε hε1
  have hb := hbound d (r+2) (K+1) (RobustConditioned.radius r K c ε) (ε/12)
    (by positivity) hradius (by positivity)
  have hbase := resourceBase_le d C r hM hU hd hC hr hc hcU hci hε hε1 hei hMlog
  have hent : (RobustConditioned.resources d r K c ε).entropyBudget ≤
      (A*(1000000000000000:ℝ)^k)*U^(9*k) := by
    calc
      _ ≤ A*(1+(d:ℝ)+(r+2:ℕ)+(K+1)+(RobustConditioned.radius r K c ε)⁻¹+(ε/12)⁻¹)^k := hb
      _ ≤ A*(1000000000000000*U^9)^k :=
        mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (by positivity) hbase k) hA.le
      _ = _ := by rw [mul_pow,← pow_mul]; ring
  have hpow : U^(9*k) ≤ U^(9*k+1) := pow_le_pow_right₀ hU (by omega)
  have hUone : U ≤ U^(9*k+1) := by simpa using pow_le_pow_right₀ hU (show 1 ≤ 9*k+1 by omega)
  have hsum : Real.log (M:ℝ)+(RobustConditioned.resources d r K c ε).entropyBudget+Real.log (4/δ) ≤
      (A*(1000000000000000:ℝ)^k+2)*U^(9*k+1) := by
    have hh := mul_le_mul_of_nonneg_left hpow (show 0 ≤ A*(1000000000000000:ℝ)^k by positivity)
    nlinarith only [hent,hh,hMlog,hδlog,hUone]
  have heps : (ε⁻¹)^2 ≤ U^2 := pow_le_pow_left₀ (inv_nonneg.mpr hε.le) hei 2
  calc
    _ = 288*(Real.log (M:ℝ)+(RobustConditioned.resources d r K c ε).entropyBudget+Real.log (4/δ))*(ε⁻¹)^2 := by field_simp; ring
    _ ≤ 288*((A*(1000000000000000:ℝ)^k+2)*U^(9*k+1))*U^2 := by
      apply mul_le_mul
      · exact mul_le_mul_of_nonneg_left hsum (by norm_num)
      · exact heps
      · positivity
      · positivity
    _ = _ := by rw [show 9*k+3=(9*k+1)+2 by omega,pow_add]; ring


open MeasureTheory ProbabilityTheory RobustConfidence

/-- The paper's localized-union theorem: universal polynomial labeled
complexity, logarithmic-family validation complexity, and a single event
simultaneous in all eligible network widths and Gaussian scales. -/
theorem localized_union_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ d C r M : ℕ,0 < d → ∀ T : LayeredBooleanCircuit d C r,
      ∀ B : Fin M → Set (Cube d),∀ j0 : Fin M,B j0 = ∅ →
      ∀ c ρ ε δ : ℝ,0 < c → 0 ≤ ρ → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ D : Measure (Cube d),IsProbabilityMeasure D →
      ∀ m n : ℕ,2*(Real.log (M:ℝ)+Real.log (4/δ))/(ε/12)^2 ≤ m →
        A*(polynomialBase d C r M c ε δ)^k ≤ n →
      ∃ E : Set ((Fin m → Cube d) × (Fin n → Cube d)),MeasurableSet E ∧
        1-δ ≤ ((Measure.pi (fun _ : Fin m => D)).prod (Measure.pi (fun _ : Fin n => D))).real E ∧
        ∀ VS ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
          gibbsMarginRisk D (posterior (N := N) (r := r) B c ρ σ T.computes VS.1 VS.2)
            (fun x => labelReal (T.computes x)) (networkOutput Real.tanh) (1/4) ≤ ρ+ε := by
  obtain ⟨A,hA,k,hpoly⟩ := sampleBudget_polynomial
  refine ⟨A,hA,k,?_⟩
  intro d C r M hd T B j0 hzero c ρ ε δ hc hρ hε hε1 hδ hδ1 D hD m n hm hn
  letI := hD
  have hM : 0 < M := Nat.zero_lt_of_lt j0.isLt
  have hbase := (polynomialBase_bounds d C r hM hc hε hδ hδ1).1
  have hnpos : 0 < n := by
    have hh : 0 < A*(polynomialBase d C r M c ε δ)^k := by positivity
    exact_mod_cast hh.trans_le hn
  have hlogM : 0 ≤ Real.log (M:ℝ) := Real.log_nonneg (by exact_mod_cast hM)
  have hlogδ : 0 < Real.log (4/δ) := Real.log_pos ((lt_div_iff₀ hδ).mpr (by linarith))
  have hmpos : 0 < m := by
    have hh : 0 < 2*(Real.log (M:ℝ)+Real.log (4/δ))/(ε/12)^2 := by positivity
    exact_mod_cast hh.trans_le hm
  have heps : 0 < (ε/12)^2 := sq_pos_of_pos (by positivity)
  apply localized_union_learning hd T B j0 hzero hc hρ hε hε1 hδ hδ1 D m n hmpos hnpos
  · exact (div_le_iff₀ heps).mp hm
  · exact (div_le_iff₀ heps).mp ((hpoly d C r M hM c ε δ hc hε hε1 hδ hδ1).trans hn)

/-- The same universal polynomial suffices when validation and training use
the same IID inputs. No independent validation data are required. -/
theorem localized_same_inputs_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ d C r M : ℕ,0 < d → ∀ T : LayeredBooleanCircuit d C r,
      ∀ B : Fin M → Set (Cube d),∀ j0 : Fin M,B j0 = ∅ →
      ∀ c ρ ε δ : ℝ,0 < c → 0 ≤ ρ → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ D : Measure (Cube d),IsProbabilityMeasure D →
      ∀ n : ℕ,A*(polynomialBase d C r M c ε δ)^k ≤ n →
      ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
        1-δ ≤ (Measure.pi (fun _ : Fin n => D)).real E ∧
        ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
          gibbsMarginRisk D (posterior (N := N) (r := r) B c ρ σ T.computes S S)
            (fun x => labelReal (T.computes x)) (networkOutput Real.tanh) (1/4) ≤ ρ+ε := by
  obtain ⟨A,hA,k,hpoly⟩ := sampleBudget_polynomial
  refine ⟨A,hA,k,?_⟩
  intro d C r M hd T B j0 hzero c ρ ε δ hc hρ hε hε1 hδ hδ1 D hD n hn
  letI := hD
  have hM : 0 < M := Nat.zero_lt_of_lt j0.isLt
  have hbase := (polynomialBase_bounds d C r hM hc hε hδ hδ1).1
  have hnpos : 0 < n := by
    have hh : 0 < A*(polynomialBase d C r M c ε δ)^k := by positivity
    exact_mod_cast hh.trans_le hn
  have hb := (div_le_iff₀ (sq_pos_of_pos (by positivity : 0 < ε/12))).mp
    ((hpoly d C r M hM c ε δ hc hε hε1 hδ hδ1).trans hn)
  apply localized_same_inputs hd T B j0 hzero hc hρ hε hε1 hδ D n hnpos _ hb
  have he : (0:ℝ) ≤ (RobustConditioned.resources d r (componentCost d C r M c ε) c ε).entropyBudget := Nat.cast_nonneg _
  linarith

#print axioms localized_union_polynomial
#print axioms localized_same_inputs_polynomial
end NeuralGeneralization.RobustLocalized
