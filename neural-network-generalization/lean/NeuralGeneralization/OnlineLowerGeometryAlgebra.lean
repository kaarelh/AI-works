import NeuralGeneralization.OnlineLowerGeometryCoset
import NeuralGeneralization.OnlineLowerReluRailCode

/-! # The finite Walsh algebra norm on the existing cube -/

noncomputable section
open scoped BigOperators Classical symmDiff

namespace NeuralGeneralization.OnlineLowerGeometry

theorem abs_walshCharacter {d : ℕ} (S : Finset (Fin d)) (x : ClippingCube d) :
    |walshCharacter S x| = 1 := by
  nlinarith [walshCharacter_sq S x, sq_abs (walshCharacter S x),
    abs_nonneg (walshCharacter S x)]

def supportTranslation {d : ℕ} (T : Finset (Fin d)) :
    Finset (Fin d) ≃ Finset (Fin d) where
  toFun S := T ∆ S
  invFun S := T ∆ S
  left_inv S := by
    ext i
    by_cases hT : i ∈ T <;> by_cases hS : i ∈ S <;> simp [Finset.mem_symmDiff, hT, hS]
  right_inv S := by
    ext i
    by_cases hT : i ∈ T <;> by_cases hS : i ∈ S <;> simp [Finset.mem_symmDiff, hT, hS]

theorem walshCoefficients_mul_character {d : ℕ} (F : ClippingCube d → ℝ)
    (S T : Finset (Fin d)) :
    walshCoefficients (fun x => F x * walshCharacter S x) T =
      walshCoefficients F (S ∆ T) := by
  unfold walshCoefficients
  congr 1
  funext x
  rw [OnlineLowerRelu.walshCharacter_symmDiff]
  ring

theorem walshCoefficients_product {d : ℕ} (F G : ClippingCube d → ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (fun x => F x * G x) S =
      ∑ T, walshCoefficients F T * walshCoefficients G (S ∆ T) := by
  have h := walsh_inner_identity F (fun x => G x * walshCharacter S x)
  simp only [walshCoefficients_mul_character] at h
  rw [← h]
  unfold walshCoefficients
  congr 1
  funext x
  ring

def walshAlgebraNorm {d : ℕ} (F : ClippingCube d → ℝ) : ℝ :=
  ∑ S, |walshCoefficients F S|

theorem walshAlgebraNorm_nonneg {d : ℕ} (F : ClippingCube d → ℝ) :
    0 ≤ walshAlgebraNorm F := Finset.sum_nonneg fun _ _ => abs_nonneg _

theorem walshAlgebraNorm_add {d : ℕ} (F G : ClippingCube d → ℝ) :
    walshAlgebraNorm (fun x => F x + G x) ≤ walshAlgebraNorm F + walshAlgebraNorm G := by
  unfold walshAlgebraNorm
  simp_rw [walshCoefficients_add]
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun S _ => abs_add_le _ _

theorem walshAlgebraNorm_const {d : ℕ} (c : ℝ) :
    walshAlgebraNorm (fun _ : ClippingCube d => c) = |c| := by
  simp [walshAlgebraNorm, walshCoefficients_const, abs_ite]

/-- Pointwise multiplication is contractive for the product of the
literal finite Walsh algebra norms. -/
theorem walshAlgebraNorm_product {d : ℕ} (F G : ClippingCube d → ℝ) :
    walshAlgebraNorm (fun x => F x * G x) ≤ walshAlgebraNorm F * walshAlgebraNorm G := by
  have hsum (T : Finset (Fin d)) :
      (∑ S, |walshCoefficients G (S ∆ T)|) = walshAlgebraNorm G := by
    have h := (supportTranslation T).sum_comp (fun S => |walshCoefficients G S|)
    simpa only [supportTranslation, Equiv.coe_fn_mk, symmDiff_comm, walshAlgebraNorm] using h
  unfold walshAlgebraNorm
  simp_rw [walshCoefficients_product]
  calc
    _ ≤ ∑ S, ∑ T, |walshCoefficients F T * walshCoefficients G (S ∆ T)| :=
      Finset.sum_le_sum fun S _ => Finset.abs_sum_le_sum_abs _ _
    _ = _ := by
      simp_rw [abs_mul]
      rw [Finset.sum_comm]
      simp_rw [← Finset.mul_sum, hsum]
      rw [← Finset.sum_mul]
      rfl

theorem walshAlgebraNorm_coset {d : ℕ} (H : CubeSubgroup d) (v : ClippingCube d) :
    walshAlgebraNorm (H.cosetIndicator v) = 1 := by
  have hratio : 0 ≤ (H.carrier.card : ℝ) / Fintype.card (ClippingCube d) :=
    div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
  unfold walshAlgebraNorm
  simp_rw [H.coset_coefficient, abs_mul, abs_walshCharacter, one_mul]
  have hterm (S : Finset (Fin d)) :
      |if H.Annihilates S then (H.carrier.card : ℝ) / Fintype.card (ClippingCube d) else 0| =
        if S ∈ H.annihilator then (H.carrier.card : ℝ) / Fintype.card (ClippingCube d) else 0 := by
    simp only [CubeSubgroup.annihilator, Finset.mem_filter, Finset.mem_univ, true_and]
    split_ifs
    · exact abs_of_nonneg hratio
    · exact abs_zero
  simp_rw [hterm]
  simp only [Fintype.sum_ite_mem, Finset.sum_const, nsmul_eq_mul]
  rw [mul_comm]
  exact H.annihilator_card_mul

theorem walshAlgebraNorm_le_weighted {d : ℕ} (w : Finset (Fin d) → ℝ)
    (w0 : ℝ) (hw0 : 0 < w0) (hw : ∀ S, w0 ≤ w S) (F : ClippingCube d → ℝ) :
    walshAlgebraNorm F ≤ weightedWalshCost w F / w0 := by
  apply (le_div_iff₀ hw0).mpr
  unfold walshAlgebraNorm weightedWalshCost weightedL1
  rw [Finset.sum_mul]
  exact Finset.sum_le_sum fun S _ =>
    by simpa only [mul_comm] using mul_le_mul_of_nonneg_right (hw S) (abs_nonneg (walshCoefficients F S))

end NeuralGeneralization.OnlineLowerGeometry
