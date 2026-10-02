import Paulsen.EuclideanNets
import Paulsen.GaussianRotationConcentration
import Paulsen.GaussianRowMoments

/-!
# Constant-scale operator tails for correlated Gaussian matrices

Two finite half-nets reduce the matrix operator norm to scalar Gaussian tails.
The covariance bound is imposed on the full vectorized factor; no independence
of matrix entries is needed.
-/

namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory Set
open scoped BigOperators ProbabilityTheory
noncomputable section

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E]

theorem stdGaussian_dual_upper_tail (D : StrongDual ℝ E) (v u : ℝ)
    (hv : 0 < v) (hu : 0 ≤ u) (hD : ‖D‖ ^ 2 ≤ v) :
    (stdGaussian E).real {g | u ≤ D g} ≤ Real.exp (-u ^ 2 / (2*v)) := by
  have hc := measure_ge_le_exp_mul_mgf u (div_nonneg hu hv.le)
    (integrable_exp_dual_stdGaussian D (u/v))
  change (stdGaussian E).real {g | u ≤ D g} ≤
    Real.exp (-(u/v)*u) * (∫ g, Real.exp ((u/v)*D g) ∂stdGaussian E) at hc
  rw [integral_exp_dual_stdGaussian, ← Real.exp_add] at hc
  apply hc.trans (Real.exp_le_exp.mpr ?_)
  have hm := mul_le_mul_of_nonneg_right hD (sq_nonneg (u/v))
  have heq : -(u/v)*u + v*(u/v)^2/2 = -u^2/(2*v) := by field_simp; ring
  rw [← heq]
  linarith

theorem stdGaussian_dual_abs_tail (D : StrongDual ℝ E) (v u : ℝ)
    (hv : 0 < v) (hu : 0 ≤ u) (hD : ‖D‖ ^ 2 ≤ v) :
    (stdGaussian E).real {g | u ≤ |D g|} ≤ 2 * Real.exp (-u ^ 2 / (2*v)) := by
  have heq : {g : E | u ≤ |D g|} = {g | u ≤ D g} ∪ {g | u ≤ (-D) g} := by
    ext g
    simp only [mem_setOf_eq, mem_union, le_abs, _root_.neg_apply]
  rw [heq]
  calc
    _ ≤ _ := measureReal_union_le _ _
    _ ≤ Real.exp (-u^2/(2*v)) + Real.exp (-u^2/(2*v)) :=
      add_le_add (stdGaussian_dual_upper_tail D v u hv hu hD)
        (stdGaussian_dual_upper_tail (-D) v u hv hu (by simpa using hD))
    _ = _ := by ring

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

def matrixBilinearDual {n d : ℕ} (C : Matrix (Fin n × Fin d) κ ℝ)
    (x : EuclideanSpace ℝ (Fin d)) (y : EuclideanSpace ℝ (Fin n)) :
    StrongDual ℝ (EuclideanSpace ℝ κ) :=
  (innerSL ℝ (WithLp.toLp 2 (fun p : Fin n × Fin d => y p.1 * x p.2))).comp
    (Matrix.toEuclideanLin C).toContinuousLinearMap

theorem matrixBilinearDual_apply {n d : ℕ} (C : Matrix (Fin n × Fin d) κ ℝ)
    (x : EuclideanSpace ℝ (Fin d)) (y : EuclideanSpace ℝ (Fin n)) (g : EuclideanSpace ℝ κ) :
    matrixBilinearDual C x y g =
      inner ℝ y (Matrix.toEuclideanLin (frameOfVector (Matrix.toEuclideanLin C g)) x) := by
  change inner ℝ (WithLp.toLp 2 (fun p : Fin n × Fin d => y p.1 * x p.2))
    (Matrix.toEuclideanLin C g) = _
  simp only [PiLp.inner_apply, Real.inner_apply, Fintype.sum_prod_type,
    Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, frameOfVector, Finset.mul_sum, Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro k _
  ring

theorem matrixBilinearDual_norm_sq_le {n d : ℕ} (C : Matrix (Fin n × Fin d) κ ℝ)
    (x : EuclideanSpace ℝ (Fin d)) (y : EuclideanSpace ℝ (Fin n))
    (hx : ‖x‖ ≤ 1) (hy : ‖y‖ ≤ 1) (v : ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v) :
    ‖matrixBilinearDual C x y‖ ^ 2 ≤ v := by
  let z := WithLp.toLp 2 (fun p : Fin n × Fin d => y p.1 * x p.2)
  have hz : ‖z‖ ^ 2 = ‖y‖ ^ 2 * ‖x‖ ^ 2 := by
    simp only [z, EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type,
      mul_pow, Finset.sum_mul, Finset.mul_sum]
    exact Finset.sum_comm
  have hz1 : ‖z‖ ≤ 1 := by
    have hh := mul_le_mul (pow_le_pow_left₀ (norm_nonneg y) hy 2)
      (pow_le_pow_left₀ (norm_nonneg x) hx 2) (sq_nonneg _) (by positivity)
    rw [← hz] at hh
    norm_num at hh
    nlinarith [norm_nonneg z]
  have hn : ‖matrixBilinearDual C x y‖ ≤ ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ := by
    calc
      _ ≤ ‖innerSL ℝ z‖ * ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ :=
        ContinuousLinearMap.opNorm_comp_le _ _
      _ ≤ 1 * ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ := by
        rw [innerSL_apply_norm]
        exact mul_le_mul_of_nonneg_right hz1 (norm_nonneg _)
      _ = _ := one_mul _
  exact (pow_le_pow_left₀ (norm_nonneg _) hn 2).trans hC

/-- Quantitative operator tail, uniform over all Gaussian covariance factors. -/
theorem gaussian_matrix_operator_net_tail {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (v u : ℝ) (hv : 0 < v) (hu : 0 ≤ u)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v) :
    (stdGaussian (EuclideanSpace ℝ κ)).real {g |
      4*u < ‖(Matrix.toEuclideanLin (frameOfVector (Matrix.toEuclideanLin C g))).toContinuousLinearMap‖} ≤
        2 * (5 : ℝ) ^ (n+d) * Real.exp (-u^2/(2*v)) := by
  classical
  obtain ⟨s, hscard, hsunit, hscover⟩ := exists_half_unit_ball_net (E := EuclideanSpace ℝ (Fin d))
  obtain ⟨t, htcard, htunit, htcover⟩ := exists_half_unit_ball_net (E := EuclideanSpace ℝ (Fin n))
  let bad (p : s × t) : Set (EuclideanSpace ℝ κ) := {g | u ≤ |matrixBilinearDual C p.1 p.2 g|}
  have hsub : {g | 4*u <
      ‖(Matrix.toEuclideanLin (frameOfVector (Matrix.toEuclideanLin C g))).toContinuousLinearMap‖} ⊆
      ⋃ p : s × t, bad p := by
    intro g hg
    by_contra h
    have hpair : ∀ x ∈ s, ∀ y ∈ t,
        |inner ℝ y (Matrix.toEuclideanLin (frameOfVector (Matrix.toEuclideanLin C g)) x)| ≤ u := by
      intro x hx y hy
      have hn : g ∉ bad (⟨x,hx⟩,⟨y,hy⟩) := fun hm => h (mem_iUnion.mpr ⟨_,hm⟩)
      dsimp only [bad, mem_setOf_eq] at hn
      rw [matrixBilinearDual_apply] at hn
      exact (lt_of_not_ge hn).le
    have hb := operator_norm_le_four_of_half_nets
      (Matrix.toEuclideanLin (frameOfVector (Matrix.toEuclideanLin C g))).toContinuousLinearMap
      s t hscover htcover u hu hpair
    exact (not_lt_of_ge hb) hg
  calc
    _ ≤ (stdGaussian (EuclideanSpace ℝ κ)).real (⋃ p : s × t, bad p) := measureReal_mono hsub
    _ ≤ ∑ p : s × t, (stdGaussian (EuclideanSpace ℝ κ)).real (bad p) := measureReal_iUnion_fintype_le bad
    _ ≤ ∑ _p : s × t, 2 * Real.exp (-u^2/(2*v)) := by
      apply Finset.sum_le_sum
      intro p _
      exact stdGaussian_dual_abs_tail _ v u hv hu (matrixBilinearDual_norm_sq_le C p.1 p.2
        (hsunit _ p.1.property) (htunit _ p.2.property) v hC)
    _ ≤ _ := by
      have hs : (s.card : ℝ) ≤ (5 : ℝ)^d := by
        simpa using (Nat.cast_le (α := ℝ)).mpr hscard
      have ht : (t.card : ℝ) ≤ (5 : ℝ)^n := by
        simpa using (Nat.cast_le (α := ℝ)).mpr htcard
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_prod, Fintype.card_coe,
        nsmul_eq_mul, Nat.cast_mul]
      have hc := mul_le_mul hs ht (Nat.cast_nonneg _) (by positivity)
      have hm := mul_le_mul_of_nonneg_right hc (show 0 ≤ 2 * Real.exp (-u^2/(2*v)) by positivity)
      calc
        _ ≤ (5 : ℝ)^d * 5^n * (2 * Real.exp (-u^2/(2*v))) := hm
        _ = _ := by rw [pow_add]; ring

/-- A fixed operator budget with failure below one percent when d≤n. -/
theorem gaussian_matrix_operator_failure_le {n d : ℕ} (hn : 0 < n) (hdn : d ≤ n)
    (C : Matrix (Fin n × Fin d) κ ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ)) :
    (stdGaussian (EuclideanSpace ℝ κ)).real {g |
      128 < ‖(Matrix.toEuclideanLin (frameOfVector (Matrix.toEuclideanLin C g))).toContinuousLinearMap‖} ≤
        1 / 100 := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hdnR : (d : ℝ) ≤ n := by exact_mod_cast hdn
  have ht := gaussian_matrix_operator_net_tail C (1 / (n : ℝ)) 32 (by positivity) (by norm_num) hC
  norm_num only [show (4:ℝ)*32 = 128 by norm_num] at ht
  have h5 : (5 : ℝ) ≤ Real.exp 5 := by linarith [Real.add_one_le_exp (5 : ℝ)]
  have hpow := pow_le_pow_left₀ (by norm_num : (0:ℝ) ≤ 5) h5 (n+d)
  rw [← Real.exp_nat_mul] at hpow
  have he : -(1024 : ℝ)/(2*(1/(n:ℝ))) = -512*n := by field_simp; ring
  rw [he] at ht
  apply ht.trans
  calc
    2 * (5:ℝ)^(n+d) * Real.exp (-512*n) ≤
        2 * Real.exp ((n+d:ℕ)*5) * Real.exp (-512*n) := by gcongr
    _ = 2 * Real.exp (5*((n:ℝ)+d)-512*n) := by
      rw [mul_assoc, ← Real.exp_add]
      push_cast
      congr 2
      ring
    _ ≤ 2 * Real.exp (-502*n) := by gcongr; linarith
    _ ≤ 2 * Real.exp (-502) := by gcongr; linarith
    _ ≤ 1/100 := by
      rw [Real.exp_neg, ← div_eq_mul_inv]
      apply (div_le_iff₀ (Real.exp_pos _)).mpr
      linarith [Real.add_one_le_exp (502 : ℝ)]

end
end Paulsen
