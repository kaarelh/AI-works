import NeuralGeneralization.JacobianTriangularTransport
import NeuralGeneralization.CylinderGeometry
import NeuralGeneralization.TanhQuadraticRemainder

/-! Operator and coordinate bounds for the actual stacked preactivation map. -/
noncomputable section
open scoped BigOperators
open WithLp
namespace NeuralGeneralization.JacobianCertificate
open ConcreteModel
variable {N r : ℕ}

/-- Maximum internal operator norm, including the empty-depth value zero. -/
def maxBlockNorm (C : Fin r → Fin N → Fin N → ℝ) : ℝ :=
  (Finset.univ.sup (fun s => ‖coordinateMatrixOperator (fun ij => C s ij.1 ij.2)‖₊) : NNReal)

/-- Maximum Euclidean row norm, also zero when there are no internal rows. -/
def maxRowNorm (C : Fin r → Fin N → Fin N → ℝ) : ℝ :=
  (Finset.univ.sup (fun si : Fin r × Fin N => ‖toLp 2 (C si.1 si.2)‖₊) : NNReal)

lemma maxBlockNorm_nonneg (C : Fin r → Fin N → Fin N → ℝ) : 0 ≤ maxBlockNorm C :=
  NNReal.coe_nonneg _
lemma maxRowNorm_nonneg (C : Fin r → Fin N → Fin N → ℝ) : 0 ≤ maxRowNorm C :=
  NNReal.coe_nonneg _

lemma blockNorm_le (C : Fin r → Fin N → Fin N → ℝ) (s : Fin r) :
    ‖coordinateMatrixOperator (fun ij => C s ij.1 ij.2)‖ ≤ maxBlockNorm C := by
  unfold maxBlockNorm
  exact_mod_cast (Finset.le_sup (f := fun s =>
    ‖coordinateMatrixOperator (fun ij => C s ij.1 ij.2)‖₊) (Finset.mem_univ s))

lemma rowNorm_le (C : Fin r → Fin N → Fin N → ℝ) (s : Fin r) (i : Fin N) :
    ‖toLp 2 (C s i)‖ ≤ maxRowNorm C := by
  unfold maxRowNorm
  exact_mod_cast (Finset.le_sup (f := fun si : Fin r × Fin N =>
    ‖toLp 2 (C si.1 si.2)‖₊) (Finset.mem_univ (s,i)))

lemma block_energy_le (X : Stack N r) (s : Fin (r+1)) :
    (∑ i, X (s,i)^2) ≤ ‖X‖^2 := by
  rw [EuclideanSpace.real_norm_sq_eq,Fintype.sum_prod_type]
  exact Finset.single_le_sum (f := fun t => ∑ i, X (t,i)^2)
    (fun t _ => Finset.sum_nonneg fun i _ => sq_nonneg _) (Finset.mem_univ s)

/-- Distinct block rows read distinct preceding blocks, with no depth factor. -/
theorem shift_norm_le (C : Fin r → Fin N → Fin N → ℝ) (X : Stack N r) :
    ‖shift C X‖ ≤ maxBlockNorm C * ‖X‖ := by
  apply (sq_le_sq₀ (norm_nonneg _) (mul_nonneg (maxBlockNorm_nonneg C) (norm_nonneg _))).mp
  rw [EuclideanSpace.real_norm_sq_eq,Fintype.sum_prod_type,Fin.sum_univ_succ]
  simp only [shift_zero,zero_pow (by norm_num : (2 : ℕ) ≠ 0),Finset.sum_const_zero,zero_add,shift_succ]
  calc
    _ ≤ ∑ s : Fin r, (maxBlockNorm C)^2 * ∑ j, X (s.castSucc,j)^2 := by
      apply Finset.sum_le_sum
      intro s _
      exact coordinateMatrix_action_squared_le (fun ij => C s ij.1 ij.2) _
        (maxBlockNorm_nonneg C) (blockNorm_le C s) _
    _ = (maxBlockNorm C)^2 * ∑ s : Fin r, ∑ j, X (s.castSucc,j)^2 := by rw [Finset.mul_sum]
    _ ≤ (maxBlockNorm C)^2 * ‖X‖^2 := by
      apply mul_le_mul_of_nonneg_left _ (sq_nonneg _)
      rw [EuclideanSpace.real_norm_sq_eq,Fintype.sum_prod_type,Fin.sum_univ_castSucc]
      exact le_add_of_nonneg_right (Finset.sum_nonneg fun i _ => sq_nonneg _)
    _ = _ := by ring

/-- The separate largest-row bound is sharper than replacing it by `b`. -/
theorem shift_coordinate_le (C : Fin r → Fin N → Fin N → ℝ) (X : Stack N r)
    (p : Fin (r+1) × Fin N) :
    |shift C X p| ≤ maxRowNorm C * ‖X‖ := by
  rcases p with ⟨s,i⟩
  induction s using Fin.cases with
  | zero => simp only [shift_zero,abs_zero]; exact mul_nonneg (maxRowNorm_nonneg C) (norm_nonneg _)
  | succ s =>
    rw [shift_succ]
    apply (sq_le_sq₀ (abs_nonneg _) (mul_nonneg (maxRowNorm_nonneg C) (norm_nonneg _))).mp
    rw [sq_abs,mul_pow]
    have hc := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (C s i) (fun j => X (s.castSucc,j))
    have hr := (sq_le_sq₀ (norm_nonneg _) (maxRowNorm_nonneg C)).mpr (rowNorm_le C s i)
    rw [EuclideanSpace.real_norm_sq_eq] at hr
    exact hc.trans (mul_le_mul hr (block_energy_le X s.castSucc)
      (Finset.sum_nonneg fun j _ => sq_nonneg _) (sq_nonneg _))

/-- Coordinatewise quadratic remainder and the two actual block norms give
exactly the paper's factor `b * b∞ / 2`. -/
theorem stacked_remainder_bound (C : Fin r → Fin N → Fin N → ℝ)
    (X e : Stack N r)
    (he : ∀ p, |e p| ≤ (shift C X p)^2/2) :
    ‖e‖ ≤ maxBlockNorm C * maxRowNorm C / 2 * ‖X‖^2 := by
  have hb := maxBlockNorm_nonneg C
  have hi := maxRowNorm_nonneg C
  apply (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp
  calc
    ‖e‖^2 = ∑ p,e p^2 := EuclideanSpace.real_norm_sq_eq _
    _ ≤ ∑ p, (maxRowNorm C)^2*‖X‖^2/4*(shift C X p)^2 := by
      apply Finset.sum_le_sum
      intro p _
      have h1 := (sq_le_sq₀ (abs_nonneg _) (by positivity)).mpr (he p)
      rw [sq_abs] at h1
      have h2 := (sq_le_sq₀ (abs_nonneg _) (mul_nonneg hi (norm_nonneg _))).mpr
        (shift_coordinate_le C X p)
      rw [sq_abs,mul_pow] at h2
      have h3 := mul_le_mul_of_nonneg_right h2 (sq_nonneg (shift C X p))
      nlinarith
    _ = (maxRowNorm C)^2*‖X‖^2/4*‖shift C X‖^2 := by
      rw [EuclideanSpace.real_norm_sq_eq (shift C X),Finset.mul_sum]
    _ ≤ (maxRowNorm C)^2*‖X‖^2/4*((maxBlockNorm C)*‖X‖)^2 := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      exact (sq_le_sq₀ (norm_nonneg _) (mul_nonneg hb (norm_nonneg _))).mpr (shift_norm_le C X)
    _ = _ := by ring

end NeuralGeneralization.JacobianCertificate
