import NeuralGeneralization.BatchTwoNonGaussianGroupCylinder
import NeuralGeneralization.CylinderGeometry

/-! Small group averages and an unrestricted bulk matrix: deterministic
geometry for the non-Gaussian teacher cylinder. No rotational invariance. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel Compression

def groupRow {C k p N : ℕ} (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (σ : ℝ) (z : Fin N → ℝ) : Fin N → ℝ := fun j =>
  match e.symm j with
  | .inl (a,_) => σ/(k : ℝ)*∑ l : Fin k, z (e (.inl (a,l)))
  | .inr _ => 0

theorem groupRow_energy {C k p N : ℕ} (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (σ : ℝ) (z : Fin N → ℝ) :
    (∑ j, groupRow e σ z j^2) =
      σ^2*∑ a : Fin C, (normalizedSum k (fun l => z (e (.inl (a,l)))))^2 := by
  have hkR : (k : ℝ) ≠ 0 := by exact_mod_cast hk.ne'
  have hs := Real.sq_sqrt (Nat.cast_nonneg k : (0 : ℝ) ≤ k)
  have hsq : (Real.sqrt (k : ℝ)) ≠ 0 := (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hk)).ne'
  have he : (∑ j, groupRow e σ z j^2) =
      (k : ℝ)*∑ a : Fin C, (σ/(k : ℝ)*∑ l : Fin k, z (e (.inl (a,l))))^2 := by
    convert sum_copies e (fun a => (σ/(k : ℝ)*∑ l : Fin k, z (e (.inl (a,l))))^2) using 1
    apply Finset.sum_congr rfl
    intro j _
    cases hj : e.symm j <;> simp [groupRow,hj]
  rw [he, Finset.mul_sum, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro a _
  unfold normalizedSum
  rw [div_pow, hs]
  field_simp

theorem groupRow_energy_le {C k p N : ℕ} (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (σ : ℝ) (z : Fin N → ℝ)
    {ρ : ℝ} (hρ : 0 ≤ ρ) (hz : z ∈ groupCylinder e ρ) :
    (∑ j, groupRow e σ z j^2) ≤ σ^2*(C : ℝ)*ρ^2 := by
  rw [groupRow_energy hk]
  have h := Finset.sum_le_sum (s := Finset.univ) (fun (a : Fin C) _ =>
    (sq_le_sq₀ (abs_nonneg _) hρ).mpr (hz a))
  simp only [sq_abs, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] at h
  exact (mul_le_mul_of_nonneg_left h (sq_nonneg σ)).trans_eq (by ring)

theorem groupRow_matrix_energy_le {C k p N : ℕ} (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (σ : ℝ) (z : Fin N → Fin N → ℝ)
    {ρ : ℝ} (hρ : 0 ≤ ρ) (hz : ∀ i, z i ∈ groupCylinder e ρ)
    (hscale : (N : ℝ)*σ^2 ≤ 1) :
    (∑ i, ∑ j, groupRow e σ (z i) j^2) ≤ ρ^2*(C : ℝ) := by
  calc
    _ ≤ ∑ _ : Fin N, σ^2*(C : ℝ)*ρ^2 :=
      Finset.sum_le_sum (fun i _ => groupRow_energy_le hk e σ (z i) hρ (hz i))
    _ = ((N : ℝ)*σ^2)*((C : ℝ)*ρ^2) := by simp; ring
    _ ≤ 1*((C : ℝ)*ρ^2) := mul_le_mul_of_nonneg_right hscale (by positivity)
    _ = _ := by ring

theorem groupRow_annihilation {C k p N : ℕ} (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (σ : ℝ) (z : Fin N → ℝ)
    (h : Fin C → ℝ) (φ : ℝ → ℝ) (hφ : φ 0=0) :
    (∑ j, (σ*z j-groupRow e σ z j)*clonedHidden φ e h j)=0 := by
  have hkR : (k : ℝ) ≠ 0 := by exact_mod_cast hk.ne'
  rw [← e.sum_comp (fun j => (σ*z j-groupRow e σ z j)*clonedHidden φ e h j)]
  simp only [Fintype.sum_sum_type, Fintype.sum_prod_type, groupRow, clonedHidden,
    e.symm_apply_apply, hφ, mul_zero, Finset.sum_const_zero, add_zero]
  apply Finset.sum_eq_zero
  intro a _
  simp only [sub_mul, Finset.sum_sub_distrib, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  rw [← Finset.sum_mul, ← Finset.mul_sum]
  field_simp
  ring

theorem groupResidual_action_bound {C k p N : ℕ} (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (σ : ℝ) (z : Fin N → Fin N → ℝ)
    {ρ b : ℝ} (hρ : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (hb : 0 ≤ b)
    (hz : ∀ i, z i ∈ groupCylinder e ρ) (hscale : (N : ℝ)*σ^2 ≤ 1)
    (hZ : matrixActionBound (fun i j => σ*z i j) b) :
    matrixActionBound (fun i j => σ*z i j-groupRow e σ (z i) j) (2*(b+C+1)) := by
  intro v
  have hR := (matrix_action_squaredSum_le (fun i j => groupRow e σ (z i) j) v).trans
    (mul_le_mul_of_nonneg_right (groupRow_matrix_energy_le hk e σ z hρ hz hscale)
      (Finset.sum_nonneg (fun _ _ => sq_nonneg _)))
  have hZ' := hZ v
  have hsplit : (∑ i, (∑ j, (σ*z i j-groupRow e σ (z i) j)*v j)^2) ≤
      2*(∑ i, (∑ j, σ*z i j*v j)^2)+2*(∑ i, (∑ j, groupRow e σ (z i) j*v j)^2) := by
    simp_rw [sub_mul, Finset.sum_sub_distrib]
    calc
      _ ≤ ∑ i, (2*(∑ j, σ*z i j*v j)^2+2*(∑ j, groupRow e σ (z i) j*v j)^2) := by
        apply Finset.sum_le_sum
        intro i _
        nlinarith [sq_nonneg ((∑ j, σ*z i j*v j)+(∑ j, groupRow e σ (z i) j*v j))]
      _ = _ := by rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
  have hρ2 : ρ^2 ≤ 1 := pow_le_one₀ hρ hρ1
  have hc : 0 ≤ (C : ℝ) := Nat.cast_nonneg _
  have hv : 0 ≤ ∑ j, v j^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hcoeff : 2*b^2+2*ρ^2*C ≤ (2*(b+C+1))^2 := by nlinarith [sq_nonneg b, sq_nonneg (C : ℝ)]
  have hm := mul_le_mul_of_nonneg_right hcoeff hv
  nlinarith

end NeuralGeneralization.BatchTwoNonGaussian
