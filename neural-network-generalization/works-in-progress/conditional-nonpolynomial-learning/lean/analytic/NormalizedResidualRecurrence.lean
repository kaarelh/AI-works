import StrictCausalPicard

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

def normalizingScale (α : ℕ → ℝ) : ℕ → ℝ
  | 0 => 1
  | j+1 => α j*normalizingScale α j

lemma normalizingScale_one_le (α : ℕ → ℝ) (hα : ∀j,1≤α j) (j : ℕ) :
    1≤normalizingScale α j := by
  induction j with
  | zero => exact le_rfl
  | succ j ih =>
    exact le_trans (by norm_num : (1:ℝ)≤1*1)
      (mul_le_mul (hα j) ih (by norm_num) (by linarith [hα j]))

lemma normalizingScale_mono (α : ℕ → ℝ) (hα : ∀j,1≤α j) : Monotone (normalizingScale α) := by
  apply monotone_nat_of_le_succ
  intro j
  have hh := mul_le_mul_of_nonneg_right (hα j) (by linarith [normalizingScale_one_le α hα j])
  simpa only [one_mul,normalizingScale] using hh

def normalizedLinear (α : ℕ → ℝ) (A : ℕ → E →L[ℝ] E) (j : ℕ) : E →L[ℝ] E :=
  (α j)⁻¹ • A j

def normalizedResidual (α : ℕ → ℝ) (N : ℕ → E → E) (j : ℕ) (x : E) : E :=
  (normalizingScale α (j+1))⁻¹ • N j (normalizingScale α j • x)

def normalizedState (α : ℕ → ℝ) (u : ℕ → E) (j : ℕ) : E :=
  (normalizingScale α j)⁻¹ • u j

theorem normalizedLinear_norm_le (α : ℕ → ℝ) (A : ℕ → E →L[ℝ] E)
    (hα : ∀j,1≤α j) (hA : ∀j,‖A j‖≤α j) (j : ℕ) :
    ‖normalizedLinear α A j‖≤1 := by
  have hp : 0<α j := by linarith [hα j]
  rw [normalizedLinear,norm_smul,Real.norm_eq_abs,abs_of_pos (inv_pos.mpr hp)]
  calc
    _ ≤ (α j)⁻¹ * α j := mul_le_mul_of_nonneg_left (hA j) (inv_nonneg.mpr hp.le)
    _ = 1 := inv_mul_cancel₀ hp.ne'

theorem normalizedResidual_lipschitz (α : ℕ → ℝ) (N : ℕ → E → E) (ℓ : ℕ → ℝ)
    (hα : ∀j,1≤α j) (hℓ : ∀j,0≤ℓ j)
    (hN : ∀j x y,‖N j x-N j y‖≤ℓ j*‖x-y‖) (j : ℕ) (x y : E) :
    ‖normalizedResidual α N j x-normalizedResidual α N j y‖≤ℓ j*‖x-y‖ := by
  have hp : 0<normalizingScale α j := by linarith [normalizingScale_one_le α hα j]
  have hn : 0<normalizingScale α (j+1) := by linarith [normalizingScale_one_le α hα (j+1)]
  have hmono := normalizingScale_mono α hα (Nat.le_succ j)
  have hratio : (normalizingScale α (j+1))⁻¹*normalizingScale α j≤1 := by
    rw [inv_mul_le_iff₀ hn]
    simpa only [mul_one] using hmono
  rw [normalizedResidual,normalizedResidual,← smul_sub,norm_smul,
    Real.norm_eq_abs,abs_of_pos (inv_pos.mpr hn)]
  calc
    _ ≤ (normalizingScale α (j+1))⁻¹*
        (ℓ j*‖normalizingScale α j • x-normalizingScale α j • y‖) :=
      mul_le_mul_of_nonneg_left (hN j _ _) (inv_nonneg.mpr hn.le)
    _ = ((normalizingScale α (j+1))⁻¹*normalizingScale α j)*(ℓ j*‖x-y‖) := by
      rw [← smul_sub,norm_smul,Real.norm_eq_abs,abs_of_pos hp]
      ring
    _ ≤ 1*(ℓ j*‖x-y‖) := mul_le_mul_of_nonneg_right hratio (mul_nonneg (hℓ j) (norm_nonneg _))
    _ = _ := one_mul _

theorem normalizedResidual_range (α : ℕ → ℝ) (N : ℕ → E → E) (B : ℕ → ℝ)
    (hα : ∀j,1≤α j) (hN : ∀j x,‖N j x‖≤B j) (j : ℕ) (x : E) :
    ‖normalizedResidual α N j x‖≤B j := by
  have hn : 0<normalizingScale α (j+1) := by linarith [normalizingScale_one_le α hα (j+1)]
  have hi : (normalizingScale α (j+1))⁻¹≤1 := by
    exact inv_le_one_of_one_le₀ (normalizingScale_one_le α hα (j+1))
  have hB : 0≤B j := (norm_nonneg _).trans (hN j 0)
  rw [normalizedResidual,norm_smul,Real.norm_eq_abs,abs_of_pos (inv_pos.mpr hn)]
  exact (mul_le_mul hi (hN j _) (norm_nonneg _) (by norm_num)).trans_eq (one_mul _)

theorem normalizedState_recursion (α : ℕ → ℝ) (A : ℕ → E →L[ℝ] E)
    (N : ℕ → E → E) (u : ℕ → E) (hα : ∀j,1≤α j)
    (hu : ∀j,u (j+1)=A j (u j)+N j (u j)) (j : ℕ) :
    normalizedState α u (j+1)=normalizedLinear α A j (normalizedState α u j)+
      normalizedResidual α N j (normalizedState α u j) := by
  have hs : normalizingScale α j≠0 := ne_of_gt (by linarith [normalizingScale_one_le α hα j])
  have hc : normalizingScale α j • normalizedState α u j=u j := by
    rw [normalizedState,smul_smul,mul_inv_cancel₀ hs,one_smul]
  rw [normalizedResidual,hc,normalizedState,hu,smul_add]
  congr 1
  simp only [normalizedLinear,normalizedState,ContinuousLinearMap.smul_apply,map_smul,smul_smul,
    normalizingScale,mul_inv_rev]

theorem normalizingScale_le_exp (w : ℕ → ℝ) (hw : ∀j,0≤w j) (j : ℕ) :
    normalizingScale (fun i => 1+w i) j≤Real.exp (∑i∈Finset.range j,w i) := by
  induction j with
  | zero => simp [normalizingScale]
  | succ j ih =>
    rw [normalizingScale,Finset.sum_range_succ,Real.exp_add]
    have hh := mul_le_mul (by simpa only [add_comm] using Real.add_one_le_exp (w j)) ih
      (by linarith [normalizingScale_one_le (fun i => 1+w i) (fun i => by linarith [hw i]) j])
      (Real.exp_nonneg _)
    simpa only [mul_comm,add_comm] using hh

#print axioms normalizedState_recursion
#print axioms normalizedResidual_lipschitz
#print axioms normalizingScale_le_exp
end ConditionalNonpolynomial.Analytic
