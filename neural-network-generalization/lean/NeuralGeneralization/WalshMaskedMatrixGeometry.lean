import NeuralGeneralization.MatrixOperatorGeometry
import NeuralGeneralization.WalshKernelOperatorBound

/-! The full and deterministically masked Walsh kernels as actual Euclidean
matrices, including every cardinality normalization. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators Matrix.Norms.L2Operator
open SquaredSampling Classical
attribute [local instance] Classical.propDecidable

lemma operatorNorm_le_of_square_action {m D : ℕ} (A : Matrix (Fin m) (Fin D) ℝ)
    (B : ℝ) (hB : 0 ≤ B)
    (h : ∀ u : Fin D → ℝ, (∑ i, (∑ j, A i j*u j)^2) ≤ B^2*∑ j, u j^2) :
    operatorNorm A ≤ B := by
  obtain ⟨u, hu, he⟩ := exists_unit_maximizer A
  have hh := (h u).trans (mul_le_mul_of_nonneg_left hu (sq_nonneg B))
  change (∑ i, linearEvaluation (A i) u^2) ≤ B^2*1 at hh
  rw [he, mul_one] at hh
  exact (sq_le_sq₀ (norm_nonneg _) hB).mp hh

variable {d : ℕ}
def cubeIndex (d : ℕ) : Fin (Fintype.card (ClippingCube d)) ≃ ClippingCube d :=
  (Fintype.equivFin (ClippingCube d)).symm

def indexedKernel (K : ClippingCube d → ClippingCube d → ℝ) :
    Matrix (Fin (Fintype.card (ClippingCube d))) (Fin (Fintype.card (ClippingCube d))) ℝ :=
  fun i j => K (cubeIndex d i) (cubeIndex d j)

lemma indexedKernel_square_action (K : ClippingCube d → ClippingCube d → ℝ)
    (u : Fin (Fintype.card (ClippingCube d)) → ℝ) :
    (∑ i, (∑ j, indexedKernel K i j*u j)^2) =
      ∑ x, (∑ y, K x y*u ((cubeIndex d).symm y))^2 := by
  have he (i : Fin (Fintype.card (ClippingCube d))) :
      (∑ j, indexedKernel K i j*u j) = ∑ y, K (cubeIndex d i) y*u ((cubeIndex d).symm y) := by
    simpa only [indexedKernel, Equiv.symm_apply_apply] using
      (cubeIndex d).sum_comp (fun y => K (cubeIndex d i) y*u ((cubeIndex d).symm y))
  simp_rw [he]
  exact (cubeIndex d).sum_comp (fun x => (∑ y, K x y*u ((cubeIndex d).symm y))^2)

lemma indexedKernel_operatorNorm_le (K : ClippingCube d → ClippingCube d → ℝ)
    (B : ℝ) (hB : 0 ≤ B)
    (h : ∀ u : ClippingCube d → ℝ, (∑ x, (∑ y, K x y*u y)^2) ≤ B^2*∑ y, u y^2) :
    operatorNorm (indexedKernel K) ≤ B := by
  apply operatorNorm_le_of_square_action _ B hB
  intro u
  rw [indexedKernel_square_action]
  have hh := h (fun y => u ((cubeIndex d).symm y))
  rw [(cubeIndex d).symm.sum_comp (fun j => u j^2)] at hh
  exact hh

lemma indexedWalsh_operatorNorm_le (w : Finset (Fin d) → ℝ) (ell : ℝ)
    (hell : 0 ≤ ell) (hw : ∀ S, |w S| ≤ ell) :
    operatorNorm (indexedKernel (walshKernel w)) ≤ Fintype.card (ClippingCube d)*ell :=
  indexedKernel_operatorNorm_le _ _ (by positivity) (walshKernel_square_action_le w ell hell hw)

lemma indexedWalsh_square_row (w : Finset (Fin d) → ℝ)
    (i : Fin (Fintype.card (ClippingCube d))) :
    (∑ j, indexedKernel (walshKernel w) i j^2) =
      Fintype.card (ClippingCube d)*∑ S, w S^2 := by
  rw [show (∑ j, indexedKernel (walshKernel w) i j^2) =
      ∑ y, walshKernel w (cubeIndex d i) y^2 from (cubeIndex d).sum_comp (fun y => walshKernel w (cubeIndex d i) y^2)]
  have h := walshKernel_square_row w (cubeIndex d i)
  unfold uniformCubeMean at h
  have hc : (Fintype.card (ClippingCube d):ℝ) ≠ 0 := by positivity
  exact (eq_div_iff hc).mp h.symm |>.symm.trans (mul_comm _ _)

def maskedKernel (K : ClippingCube d → ClippingCube d → ℝ)
    (keep : ClippingCube d → ClippingCube d → Prop) :
    ClippingCube d → ClippingCube d → ℝ := fun x y => if keep x y then K x y else 0

lemma indexedMaskedWalsh_square_row_le (w : Finset (Fin d) → ℝ)
    (keep : ClippingCube d → ClippingCube d → Prop)
    (i : Fin (Fintype.card (ClippingCube d))) :
    (∑ j, indexedKernel (maskedKernel (walshKernel w) keep) i j^2) ≤
      Fintype.card (ClippingCube d)*∑ S, w S^2 := by
  exact (masked_square_row_le (indexedKernel (walshKernel w))
    (fun i j => keep (cubeIndex d i) (cubeIndex d j)) i).trans_eq
      (indexedWalsh_square_row w i)

lemma indexedMaskedWalsh_square_col_le (w : Finset (Fin d) → ℝ)
    (keep : ClippingCube d → ClippingCube d → Prop)
    (j : Fin (Fintype.card (ClippingCube d))) :
    (∑ i, indexedKernel (maskedKernel (walshKernel w) keep) i j^2) ≤
      Fintype.card (ClippingCube d)*∑ S, w S^2 := by
  have h := indexedMaskedWalsh_square_row_le w (fun x y => keep y x) j
  have he (i : Fin (Fintype.card (ClippingCube d))) :
      indexedKernel (maskedKernel (walshKernel w) keep) i j =
      indexedKernel (maskedKernel (walshKernel w) (fun x y => keep y x)) j i := by
    simp only [indexedKernel, maskedKernel]
    split_ifs <;> simp only [walshKernel_symm]
  simpa only [he] using h

/-- A symmetric entry mask loses at most trace times the number of removed
entries in each row. Both norms are the actual Euclidean matrix norm. -/
lemma indexedMaskedWalsh_operatorNorm_le (w : Finset (Fin d) → ℝ)
    (hw : ∀ S, 0 ≤ w S) (keep : ClippingCube d → ClippingCube d → Prop)
    (hsymm : ∀ x y, keep x y ↔ keep y x)
    (ell b : ℝ) (hell : 0 ≤ ell) (hb : 0 ≤ b) (hmax : ∀ S, w S ≤ ell)
    (hcount : ∀ x, ((Finset.univ.filter (fun y => ¬ keep x y)).card:ℝ) ≤ b) :
    operatorNorm (indexedKernel (maskedKernel (walshKernel w) keep)) ≤
      Fintype.card (ClippingCube d)*ell+(∑ S, w S)*b := by
  let R := maskedKernel (walshKernel w) (fun x y => ¬ keep x y)
  have ht : 0 ≤ ∑ S, w S := Finset.sum_nonneg (fun S _ => hw S)
  have hrow (x : ClippingCube d) : (∑ y, |R x y|) ≤ (∑ S,w S)*b := by
    have hh := masked_abs_row_le (walshKernel w) (fun x y => ¬ keep x y) _ b ht
      (walshKernel_abs_le_trace w hw) hcount x
    convert hh using 1
    congr 1
    funext y
    by_cases h : keep x y <;> simp [R, maskedKernel, h]
  have hcol (y : ClippingCube d) : (∑ x, |R x y|) ≤ (∑ S,w S)*b := by
    have he (x : ClippingCube d) : R x y=R y x := by
      dsimp only [R, maskedKernel]
      by_cases h : keep x y
      · simp [h, (hsymm x y).mp h]
      · simp [h, (hsymm x y).not.mp h, walshKernel_symm w x y]
    simpa only [he] using hrow y
  have hR := indexedKernel_operatorNorm_le R _ (mul_nonneg ht hb)
    (square_action_le_of_abs_row_column R _ (mul_nonneg ht hb) hrow hcol)
  have hfull := indexedWalsh_operatorNorm_le w ell hell
    (fun S => by rw [abs_of_nonneg (hw S)]; exact hmax S)
  have he : indexedKernel (maskedKernel (walshKernel w) keep) =
      indexedKernel (walshKernel w)-indexedKernel R := by
    ext i j
    simp only [indexedKernel, maskedKernel, Matrix.sub_apply, R]
    split_ifs <;> simp_all
  rw [he]
  change ‖indexedKernel (walshKernel w)-indexedKernel R‖ ≤ _
  exact (norm_sub_le _ _).trans (add_le_add hfull hR)

end NeuralGeneralization.RandomRestriction
