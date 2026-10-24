import NeuralGeneralization.BatchTwoActivationCoarseModulus

/-! Explicit polynomial jet budgets for the concrete cutoff construction. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoActivation

def BoundedJet.weaken {I : Type*} [Fintype I] {b₀ b₁ b₂ c₀ c₁ c₂ : ℝ}
    (F : BoundedJet I b₀ b₁ b₂) (h₀ : b₀≤c₀) (h₁ : b₁≤c₁) (h₂ : b₂≤c₂) :
    BoundedJet I c₀ c₁ c₂ :=
  { F with value_bound := fun z => (F.value_bound z).trans h₀
           grad_bound := fun z => (F.grad_bound z).trans h₁
           hess_bound := fun z => (F.hess_bound z).trans h₂ }

theorem power_coefficient_enlarge {x a : ℝ} (hx : 1≤x) (ha : a≤x) {n m : ℕ}
    (hnm : n+1≤m) : a*x^n≤x^m := by
  calc
    _ ≤ x*x^n := mul_le_mul_of_nonneg_right ha (pow_nonneg (by linarith) n)
    _ = x^(n+1) := by rw [pow_succ]; ring
    _ ≤ _ := pow_le_pow_right₀ hx hnm

theorem cutoff_value_budget_polynomial {x ℓ : ℝ} (hx : 16≤x) (hℓ : ℓ≤x) :
    1*(4*ℓ*x^8)≤x^16 := by
  have hx0 : 0≤x := by linarith
  have h := mul_le_mul_of_nonneg_right hℓ (pow_nonneg hx0 8)
  have he : 4*x*x^8=4*x^9 := by ring
  calc
    _ ≤ 4*x*x^8 := by nlinarith
    _ = 4*x^9 := he
    _ ≤ _ := power_coefficient_enlarge (by linarith) (by linarith) (by omega)

theorem cutoff_first_budget_polynomial {x ℓ B : ℝ} (hx : 16≤x)
    (hℓ0 : 0≤ℓ) (hB0 : 0≤B) (hℓ : ℓ≤x) (hB : B≤x) :
    (B/x^8)*(4*ℓ*x^8)+1*ℓ≤x^16 := by
  have hx0 : 0<x := by linarith
  have he : (B/x^8)*(4*ℓ*x^8)+1*ℓ=4*B*ℓ+ℓ := by field_simp <;> ring
  rw [he]
  have hprod := mul_le_mul hB hℓ hℓ0 hx0.le
  have hx1 : 1≤x := by linarith
  have hxx : x≤x^2 := by nlinarith
  calc
    _ ≤ 5*x^2 := by nlinarith
    _ ≤ _ := power_coefficient_enlarge hx1 (by linarith) (by omega)

theorem cutoff_second_budget_polynomial {x ℓ B a : ℝ} (hx : 16≤x)
    (hℓ0 : 0≤ℓ) (hB0 : 0≤B) (ha0 : 0≤a) (hℓ : ℓ≤x) (hB : B≤x) (ha : a≤x) :
    (B/(x^8)^2+2*a*B/x^8)*(4*ℓ*x^8)+2*(B/x^8)*ℓ+1*(ℓ/(1/x^12))≤x^16 := by
  have hx0 : 0<x := by linarith
  have hx1 : 1≤x := by linarith
  have hT : 1≤x^8 := one_le_pow₀ hx1
  have he : (B/(x^8)^2+2*a*B/x^8)*(4*ℓ*x^8)+2*(B/x^8)*ℓ+1*(ℓ/(1/x^12))=
      6*B*ℓ/x^8+8*a*B*ℓ+ℓ*x^12 := by field_simp <;> ring
  rw [he]
  have hBL : B*ℓ≤x^2 := by nlinarith [mul_le_mul hB hℓ hℓ0 hx0.le]
  have h₁ : 6*B*ℓ/x^8≤6*x^2 := by
    have hdiv : 6*B*ℓ/x^8≤6*B*ℓ := div_le_self (by positivity) hT
    nlinarith
  have h₂ : 8*a*B*ℓ≤8*x^3 := by
    have hm := mul_le_mul ha hBL (mul_nonneg hB0 hℓ0) hx0.le
    nlinarith
  have h₃ : ℓ*x^12≤x^13 := by
    have hm := mul_le_mul_of_nonneg_right hℓ (pow_nonneg hx0.le 12)
    nlinarith
  have h213 := pow_le_pow_right₀ hx1 (show 2≤13 by omega)
  have h313 := pow_le_pow_right₀ hx1 (show 3≤13 by omega)
  calc
    _ ≤ 15*x^13 := by linarith
    _ ≤ _ := power_coefficient_enlarge hx1 (by linarith) (by omega)

variable {I : Type*} [Fintype I] [Nonempty I] [DecidableEq I]

def polynomialCutoffJet {φ : ℝ → ℝ} {ℓ B x : ℝ} (hx : 16≤x)
    (hℓ0 : 0≤ℓ) (hB0 : 0≤B) (hℓ : ℓ≤x) (hB : B≤x)
    (hlog : Real.log (2*Fintype.card I)≤x)
    (hφ : zeroLipschitzActivation ℓ φ)
    (hb : ∀t,|deriv scalarCutoff t|≤B) (hbb : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (p : I) : BoundedJet I (x^16) (x^16) (x^16) := by
  have hx0 : 0<x := by linarith
  have hT : 0<x^8 := pow_pos hx0 _
  have ha := cutoffRate_pos (I:=I) hT
  have ha' : cutoffRate I (x^8)≤x := by
    unfold cutoffRate
    have hlog0 : 0≤Real.log (2*Fintype.card I) := by
      have hc : (1:ℝ)≤Fintype.card I := Nat.one_le_cast.mpr Fintype.card_pos
      exact Real.log_nonneg (by linarith)
    exact (div_le_self hlog0 (one_le_pow₀ (by linarith : (1:ℝ)≤x))).trans hlog
  exact (cutoffFeatureJet hℓ0 ha hT (by positivity : 0<1/x^12) hB0 hφ hb hbb p).weaken
    (cutoff_value_budget_polynomial hx hℓ)
    (cutoff_first_budget_polynomial hx hℓ0 hB0 hℓ hB)
    (cutoff_second_budget_polynomial hx hℓ0 hB0 ha.le hℓ hB ha')

end NeuralGeneralization.BatchTwoActivation
