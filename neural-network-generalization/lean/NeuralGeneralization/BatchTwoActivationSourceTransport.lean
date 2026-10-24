import NeuralGeneralization.BatchTwoActivationSourceCertificate

/-! Stable transport of source certificates under entrywise covariance
perturbations, without a lower eigenvalue assumption. -/
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
variable {I E : Type*} [Fintype I] [DecidableEq I]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

def sourceGram (a : I→E) (i j : I) : ℝ := inner ℝ (a i) (a j)

theorem matrix_action_perturbation (Q Q' : I→I→ℝ) (β : I→ℝ) {e : ℝ}
    (hQ : ∀i j,|Q' i j-Q i j|≤e) (i : I) :
    |(∑j,β j*Q' i j)-(∑j,β j*Q i j)|≤e*(∑j,|β j|) := by
  rw [←Finset.sum_sub_distrib]
  calc
    _ ≤ ∑j,|β j*Q' i j-β j*Q i j| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑j,|β j| *|Q' i j-Q i j| := by simp only [←mul_sub,abs_mul]
    _ ≤ ∑j,|β j| *e := Finset.sum_le_sum (fun j _=>mul_le_mul_of_nonneg_left (hQ i j) (abs_nonneg _))
    _ = _ := by rw [←Finset.sum_mul,mul_comm]

/-- A single chosen certificate remains valid at every nearby covariance. -/
theorem exists_stable_source_certificate (a : I→E) (u : E) (hu : ‖u‖≤1)
    {η : ℝ} (hη : 0<η) :
    ∃β:I→ℝ, (∑i,|β i|)≤1/(4*η) ∧ ‖∑i,β i • a i‖≤1 ∧
      ∀Q':I→I→ℝ, ∀e:ℝ, 0≤e → (∀i j,|Q' i j-sourceGram a i j|≤e) →
      ∀i, |(∑j,β j*Q' i j)-inner ℝ (a i) u|≤η+e/(4*η) := by
  obtain ⟨β,hβ,hnorm,happrox⟩ := exists_source_l1_certificate a u hu hη
  refine ⟨β,hβ,hnorm,?_⟩
  intro Q' e he hQ i
  have he₁ := matrix_action_perturbation (sourceGram a) Q' β hQ i
  have he₂ := happrox i
  simp only [inner_sum,real_inner_smul_right,sourceGram] at he₂
  calc
    _ ≤ |(∑j,β j*Q' i j)-(∑j,β j*sourceGram a i j)|+
        |(∑j,β j*sourceGram a i j)-inner ℝ (a i) u| := abs_sub_le _ _ _
    _ ≤ e*(∑j,|β j|)+η := add_le_add he₁ he₂
    _ ≤ e*(1/(4*η))+η := add_le_add (mul_le_mul_of_nonneg_left hβ he) (le_refl η)
    _ = _ := by ring

/-- The deterministic finite realization really is a linear combination of
preceding features. These are ordinary feedforward weights. -/
theorem weighted_feature_action {J : Type*} [Fintype J]
    (h : J→I→ℝ) (c : J→ℝ) (β : I→ℝ) (i : I) :
    (∑j,β j*(∑k,c k*h k i*h k j))=
      ∑k,(c k*(∑j,β j*h k j))*h k i := by
  simp only [Finset.mul_sum,Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro k hk
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem weighted_feature_weight_bound {J : Type*} [Fintype J]
    (h : J→I→ℝ) (c : J→ℝ) (β : I→ℝ) {B V G : ℝ}
    (hB : 0≤B) (hV : 0≤V) (hG : (∑j,|β j|)≤G)
    (hc : ∀k,|c k|≤V) (hh : ∀k j,|h k j|≤B) (k : J) :
    |c k*(∑j,β j*h k j)|≤V*G*B := by
  rw [abs_mul]
  calc
    _ ≤ V*(∑j,|β j| *|h k j|) := mul_le_mul (hc k)
      (by simpa only [abs_mul] using Finset.abs_sum_le_sum_abs (fun j=>β j*h k j) Finset.univ)
      (abs_nonneg _) hV
    _ ≤ V*(∑j,|β j| *B) := mul_le_mul_of_nonneg_left
      (Finset.sum_le_sum (fun j _=>mul_le_mul_of_nonneg_left (hh k j) (abs_nonneg _))) hV
    _ = V*((∑j,|β j|)*B) := by rw [Finset.sum_mul]
    _ ≤ _ := by
      rw [mul_assoc]
      exact mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_right hG hB) hV

end NeuralGeneralization.BatchTwoActivation
