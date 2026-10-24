import NeuralGeneralization.BatchTwoActivationStatements
import NeuralGeneralization.BatchTwoMergingCloneGeometry
import NeuralGeneralization.MarginRescaling

/-! Uniform bounds on the actual hidden states of a bounded teacher and its
equal-population clone. No boundedness of the activation is assumed. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel CompressionSampling BatchTwoMerging

def teacherGrowth (C : ℕ) (ℓ : ℝ) : ℝ := 1+ℓ*(C:ℝ)^2
def teacherStateBound (d C r : ℕ) (ℓ : ℝ) : ℝ :=
  ((d:ℝ)+1)*(teacherGrowth C ℓ)^(r+1)

theorem teacherGrowth_ge_one (C : ℕ) {ℓ : ℝ} (hℓ : 0≤ℓ) : 1≤teacherGrowth C ℓ := by
  unfold teacherGrowth
  have h : 0≤ℓ*(C:ℝ)^2 := by positivity
  linarith

theorem teacherStateBound_ge_one (d C r : ℕ) {ℓ : ℝ} (hℓ : 0≤ℓ) :
    1≤teacherStateBound d C r ℓ := by
  unfold teacherStateBound
  exact one_le_mul_of_one_le_of_one_le (by linarith [(Nat.cast_nonneg d : (0:ℝ)≤d)])
    (one_le_pow₀ (teacherGrowth_ge_one C hℓ))

theorem teacher_firstHidden_bound {d C r : ℕ} (hC : 0<C) {φ : ℝ→ℝ} {ℓ : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ)
    (w : Weights d C r) (hw : boundedWeights C w) (x : Cube d) (i : Fin C) :
    |firstHidden φ w x i|≤((d:ℝ)+1)*teacherGrowth C ℓ := by
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hsum : |∑ j,w (Sum.inl (i,j))*inputVector x j|≤((d:ℝ)+1)*C := by
    calc
      _ ≤ ∑ j,|w (Sum.inl (i,j))*inputVector x j| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _j : Fin (d+1),(C:ℝ) := Finset.sum_le_sum fun j _ => by
        rw [abs_mul,abs_inputVector,mul_one]
        exact hw _
      _ = _ := by simp
  have hact := (activation_abs_le hφ _).trans (mul_le_mul_of_nonneg_left hsum hℓ)
  have hC2 : (C:ℝ)≤(C:ℝ)^2 := by nlinarith
  have hmul := mul_le_mul_of_nonneg_left hC2 (mul_nonneg hℓ (by positivity : (0:ℝ)≤d+1))
  unfold firstHidden teacherGrowth
  nlinarith

theorem teacher_hiddenStep_bound {d C r : ℕ} {φ : ℝ→ℝ} {ℓ T : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ) (hT : 0≤T)
    (w : Weights d C r) (hw : boundedWeights C w)
    (u : Fin C→ℝ) (hu : ∀i,|u i|≤T) (s : Fin r) (i : Fin C) :
    |hiddenStep φ w u s i|≤teacherGrowth C ℓ*T := by
  have hsum : |∑ j,w (Sum.inr (Sum.inl (s,i,j)))*u j|≤(C:ℝ)^2*T := by
    calc
      _ ≤ ∑ j,|w (Sum.inr (Sum.inl (s,i,j)))*u j| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _j : Fin C,(C:ℝ)*T := Finset.sum_le_sum fun j _ => by
        rw [abs_mul]
        exact mul_le_mul (hw _) (hu j) (abs_nonneg _) (Nat.cast_nonneg C)
      _ = _ := by simp; ring
  have hh := (activation_abs_le hφ _).trans (mul_le_mul_of_nonneg_left hsum hℓ)
  unfold hiddenStep teacherGrowth
  nlinarith

theorem teacher_hiddenFold_bound {d C r : ℕ} (hC : 0<C) {φ : ℝ→ℝ} {ℓ : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ)
    (w : Weights d C r) (hw : boundedWeights C w) (x : Cube d)
    (ss : List (Fin r)) (i : Fin C) :
    |ss.foldl (hiddenStep φ w) (firstHidden φ w x) i|≤
      ((d:ℝ)+1)*(teacherGrowth C ℓ)^(ss.length+1) := by
  induction ss using List.reverseRecOn generalizing i with
  | nil => simpa using teacher_firstHidden_bound hC hφ hℓ w hw x i
  | append_singleton ss s ih =>
      simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,List.length_append,List.length_singleton]
      have ht : 0≤((d:ℝ)+1)*(teacherGrowth C ℓ)^(ss.length+1) := by
        have := teacherGrowth_ge_one C hℓ
        positivity
      have hh := teacher_hiddenStep_bound hφ hℓ ht w hw _ ih s i
      convert hh using 1
      rw [pow_succ]
      ring

theorem cloned_teacher_hidden_bound {d C r k p N : ℕ} (hC : 0<C) (hk : 0<k)
    {φ : ℝ→ℝ} {ℓ : ℝ} (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (w : Weights d C r) (hw : boundedWeights C w)
    (a : ℝ) (x : Cube d) (ss : List (Fin r)) (i : Fin N) (hlen : ss.length≤r) :
    |ss.foldl (hiddenStep φ (clonedWeights e (rescaleReadout a w)))
      (firstHidden φ (clonedWeights e (rescaleReadout a w)) x) i|≤teacherStateBound d C r ℓ := by
  rw [firstHidden_cloned,hiddenFold_cloned hk]
  have hfold : ss.foldl (hiddenStep φ (rescaleReadout a w)) (firstHidden φ (rescaleReadout a w) x)=
      ss.foldl (hiddenStep φ w) (firstHidden φ w x) := rfl
  rw [hfold]
  cases hi : e.symm i with
  | inl ab =>
    simp only [clonedHidden,hi]
    have hh := teacher_hiddenFold_bound hC hφ hℓ w hw x ss ab.1
    apply hh.trans
    unfold teacherStateBound
    exact mul_le_mul_of_nonneg_left (pow_le_pow_right₀ (teacherGrowth_ge_one C hℓ) (by omega)) (by positivity)
  | inr z =>
    simp only [clonedHidden,hi,hφ.1,abs_zero]
    exact (by norm_num : (0:ℝ)≤1).trans (teacherStateBound_ge_one d C r hℓ)

end NeuralGeneralization.BatchTwoActivation
