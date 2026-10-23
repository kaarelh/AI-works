import NeuralGeneralization.BatchTwoActivationSharpInputMomentCore
import NeuralGeneralization.EmpiricalSquareBootstrap

/-! The dimension-free Euclidean Rademacher input moment, with the literal
bounded-difference constant used by the manuscript. -/
noncomputable section
set_option maxHeartbeats 1600000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling
variable {J : Type*} [Fintype J]

theorem bool_norm_square_mean (u v : EuclideanSpace ℝ J) :
    finiteMean (fun b : Bool=>‖cubeCoordinateSign b • u+v‖^2)=‖u‖^2+‖v‖^2 := by
  have hh := parallelogram_law_with_norm ℝ v u
  simp only [finiteMean,Fintype.sum_bool,Fintype.card_bool,Nat.cast_ofNat,
    cubeCoordinateSign,Bool.false_eq_true,if_false,if_true,one_smul,neg_one_smul]
  rw [add_comm u v,neg_add_eq_sub]
  linarith

theorem sign_vector_second_moment (n : ℕ) (x : Fin n→EuclideanSpace ℝ J) :
    finiteMean (fun ε : Fin n→Bool=>‖∑i,cubeCoordinateSign (ε i) • x i‖^2)=∑i,‖x i‖^2 := by
  induction n with
  | zero => simp [finiteMean]
  | succ n ih =>
    rw [finiteMean_sign_succ,finiteMean_comm]
    simp_rw [Fin.sum_univ_succ,Fin.cons_zero,Fin.cons_succ,bool_norm_square_mean]
    rw [finiteMean_add,finiteMean_const,ih]

theorem sign_vector_norm_mean (n : ℕ) (x : Fin n→EuclideanSpace ℝ J)
    {R : ℝ} (hR : 0≤R) (hx : ∀i,‖x i‖≤R) :
    finiteMean (fun ε : Fin n→Bool=>‖∑i,cubeCoordinateSign (ε i) • x i‖)≤R*Real.sqrt n := by
  have hj := finiteMean_square_jensen (fun ε : Fin n→Bool=>‖∑i,cubeCoordinateSign (ε i) • x i‖)
  rw [sign_vector_second_moment] at hj
  have hsum : (∑i,‖x i‖^2)≤(n : ℝ)*R^2 := by
    calc
      _ ≤ ∑_i : Fin n,R^2 := Finset.sum_le_sum (fun i _=>pow_le_pow_left₀ (norm_nonneg _) (hx i) 2)
      _ = _ := by simp
  apply (sq_le_sq₀ (finiteMean_nonneg (fun _=>norm_nonneg _)) (by positivity)).mp
  rw [mul_pow,Real.sq_sqrt (Nat.cast_nonneg n)]
  nlinarith only [hj,hsum]

theorem sign_vector_norm_bounded_differences (n : ℕ) (x : Fin n→EuclideanSpace ℝ J)
    {R : ℝ} (hR : 0≤R) (hx : ∀i,‖x i‖≤R) :
    CubeBoundedDifferences (fun ε : Fin n→Bool=>‖∑i,cubeCoordinateSign (ε i) • x i‖) R := by
  classical
  intro i ε η hsame
  have he : (∑j,cubeCoordinateSign (ε j) • x j)-(∑j,cubeCoordinateSign (η j) • x j)=
      (cubeCoordinateSign (ε i)-cubeCoordinateSign (η i)) • x i := by
    rw [←Finset.sum_sub_distrib]
    calc
      _ = ∑j,if j=i then (cubeCoordinateSign (ε i)-cubeCoordinateSign (η i)) • x i else 0 := by
        apply Finset.sum_congr rfl
        intro j _
        by_cases hj : j=i
        · subst j
          simp [sub_smul]
        · simp [hj,hsame j hj]
      _ = _ := by simp
  have hsign (b : Bool) : |cubeCoordinateSign b|=1 := by cases b <;> norm_num [cubeCoordinateSign]
  have hdiff : |cubeCoordinateSign (ε i)-cubeCoordinateSign (η i)|≤2 := by
    have hh := abs_sub (cubeCoordinateSign (ε i)) (cubeCoordinateSign (η i))
    simpa only [hsign,one_add_one_eq_two] using hh
  calc
    _ ≤ ‖(∑j,cubeCoordinateSign (ε j) • x j)-(∑j,cubeCoordinateSign (η j) • x j)‖ := abs_norm_sub_norm_le _ _
    _ = |cubeCoordinateSign (ε i)-cubeCoordinateSign (η i)| * ‖x i‖ := by rw [he,norm_smul,Real.norm_eq_abs]
    _ ≤ 2*R := mul_le_mul hdiff (hx i) (norm_nonneg _) (by norm_num)

/-- Exact dimension-free MGF of the input norm, for the actual uniform sign
cube. It holds even for a zero-dimensional input space. -/
theorem sharp_input_vector_sign_mgf (n : ℕ) (x : Fin n→EuclideanSpace ℝ J)
    {R a : ℝ} (hR : 0≤R) (hx : ∀i,‖x i‖≤R) (ha : 0≤a) :
    finiteMean (fun ε : Fin n→Bool=>Real.exp (a*‖∑i,cubeCoordinateSign (ε i) • x i‖))≤
      Real.exp (a*R*Real.sqrt n+a^2*(n : ℝ)*R^2/2) := by
  have hh := finite_cube_bounded_difference_mgf n _ hR
    (sign_vector_norm_bounded_differences n x hR hx) a
  apply hh.trans
  apply Real.exp_le_exp.mpr
  have hm := mul_le_mul_of_nonneg_left (sign_vector_norm_mean n x hR hx) ha
  linarith

end NeuralGeneralization.BatchTwoActivation
