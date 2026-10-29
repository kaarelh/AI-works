import NetworkBallCover
import NeuralGeneralization.FiniteParameterGrid
import Mathlib.Algebra.BigOperators.Field

open scoped BigOperators RealInnerProductSpace

noncomputable section

namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch NeuralGeneralization.ParameterGrid

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def activeAxes (w : ι → ℝ) (ε : ℝ) : Finset ι :=
  Finset.univ.filter fun i => ε ^ 2 < w i

def sparseGridValue (I : Finset ι) (T : ℕ) (q : {i // i ∈ I} → GridInt T) (i : ι) : ℝ :=
  if h : i ∈ I then decode T q ⟨i, h⟩ else 0

theorem activeAxes_card_bound (w : ι → ℝ) (ε : ℝ) (hw : ∀ i, 0 ≤ w i) :
    ε ^ 2 * ((activeAxes w ε).card : ℝ) ≤ ∑ i, w i := by
  calc
    ε ^ 2 * ((activeAxes w ε).card : ℝ) = ∑ _i ∈ activeAxes w ε, ε ^ 2 := by simp [mul_comm]
    _ ≤ ∑ i ∈ activeAxes w ε, w i := Finset.sum_le_sum fun i hi =>
      le_of_lt (Finset.mem_filter.mp hi).2
    _ ≤ ∑ i, w i := Finset.sum_le_univ_sum_of_nonneg hw

/-- Quantize only axes with squared weight above ε². Their number is controlled
by the total squared Hilbert--Schmidt norm; inactive axes cost at most ε². -/
theorem exists_sparse_weighted_grid (w v : ι → ℝ) (ε : ℝ) (T : ℕ)
    (hT : 0 < T) (hw : ∀ i, 0 ≤ w i) (hv : ∑ i, v i ^ 2 ≤ 1) :
    ∃ q : {i // i ∈ activeAxes w ε} → GridInt T,
      ∑ i, w i * (v i - sparseGridValue (activeAxes w ε) T q i) ^ 2 ≤
        (∑ i, w i) / (T : ℝ)^2 + ε ^ 2 := by
  classical
  have hvi (i : ι) : |v i| ≤ 1 := by
    have hh := (Finset.single_le_sum (fun j _ => sq_nonneg (v j))
      (Finset.mem_univ i)).trans hv
    nlinarith [sq_abs (v i), abs_nonneg (v i)]
  obtain ⟨q, hq⟩ := exists_close_grid T hT
    (fun i : {i // i ∈ activeAxes w ε} => v i) (fun i => hvi i)
  refine ⟨q, ?_⟩
  have hTpos : (0 : ℝ) < T := by exact_mod_cast hT
  have hterm (i : ι) : w i * (v i - sparseGridValue (activeAxes w ε) T q i)^2 ≤
      w i / (T : ℝ)^2 + ε^2 * v i^2 := by
    by_cases hi : i ∈ activeAxes w ε
    · have hh := hq ⟨i, hi⟩
      have herr : (v i - decode T q ⟨i, hi⟩)^2 ≤ 1 / (T : ℝ)^2 := by
        have hsq := mul_self_le_mul_self (abs_nonneg _) hh
        simpa only [← sq, sq_abs, div_pow, one_pow] using hsq
      simp only [sparseGridValue, dif_pos hi]
      have hmul := mul_le_mul_of_nonneg_left herr (hw i)
      have hnon : 0 ≤ ε^2 * v i^2 := mul_nonneg (sq_nonneg _) (sq_nonneg _)
      simpa only [mul_one_div] using le_trans hmul (le_add_of_nonneg_right hnon)
    · have hsmall : w i ≤ ε^2 := by
        simpa [activeAxes, not_lt] using hi
      simp only [sparseGridValue, dif_neg hi, sub_zero]
      have hh := mul_le_mul_of_nonneg_right hsmall (sq_nonneg (v i))
      have hnon : 0 ≤ w i / (T : ℝ)^2 := div_nonneg (hw i) (sq_nonneg _)
      linarith
  calc
    _ ≤ ∑ i, (w i / (T : ℝ)^2 + ε^2 * v i^2) := Finset.sum_le_sum fun i _ => hterm i
    _ = (∑ i, w i) / (T : ℝ)^2 + ε^2 * ∑ i, v i^2 := by
      rw [Finset.sum_add_distrib, ← Finset.sum_div, ← Finset.mul_sum]
    _ ≤ (∑ i, w i) / (T : ℝ)^2 + ε^2 := by
      have hh := mul_le_mul_of_nonneg_left hv (sq_nonneg ε)
      linarith

theorem sparse_grid_card (I : Finset ι) (T : ℕ) :
    Fintype.card ({i // i ∈ I} → GridInt T) = (2 * T + 1)^I.card := by
  rw [Fintype.card_fun, gridInt_card, Fintype.card_coe]

section LinearCover
variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E] [NormedAddCommGroup F] [InnerProductSpace ℝ F]
  [FiniteDimensional ℝ F]

/-- A dimension-independent ellipsoid covering bound. The number of retained
axes is bounded by `frobeniusSq A / ε²`, and each uses only `2T+1` grid values.
Both the centers and their covering property are constructed explicitly. -/
theorem spectral_grid_unit_ball_cover (A : E →ₗ[ℝ] F) (ε : ℝ) (T : ℕ)
    (hT : 0 < T) :
    FiniteBallCover (A '' Metric.closedBall (0 : E) 1)
      ((2 * T + 1) ^ (activeAxes
        (A.isSymmetric_adjoint_comp_self.eigenvalues rfl) ε).card)
      (Real.sqrt (frobeniusSq A / (T : ℝ)^2 + ε^2)) := by
  classical
  let b := A.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl
  let w := A.isSymmetric_adjoint_comp_self.eigenvalues rfl
  let I := activeAxes w ε
  let Code := {i // i ∈ I} → GridInt T
  let center : Code → F := fun q => A (b.repr.symm
    (WithLp.toLp 2 (sparseGridValue I T q)))
  refine ⟨Finset.univ.image center, ?_, ?_⟩
  · calc
      (Finset.univ.image center).card ≤ Fintype.card Code := by
        exact Finset.card_image_le.trans_eq (Finset.card_univ)
      _ = (2 * T + 1)^I.card := sparse_grid_card I T
  · rintro y ⟨x, hx, rfl⟩
    have hxn : ‖x‖ ≤ 1 := by simpa using hx
    have hcoord : ∑ i, (b.repr x i)^2 = ‖x‖^2 := by
      simp_rw [b.repr_apply_apply]
      exact b.sum_sq_inner_right x
    have hv : ∑ i, (b.repr x i)^2 ≤ 1 := by
      rw [hcoord]
      nlinarith [norm_nonneg x]
    have hw : ∀ i, 0 ≤ w i := A.isPositive_adjoint_comp_self.nonneg_eigenvalues rfl
    obtain ⟨q, hq⟩ := exists_sparse_weighted_grid w (fun i => b.repr x i) ε T hT hw hv
    refine ⟨center q, Finset.mem_image_of_mem _ (Finset.mem_univ q), ?_⟩
    have he : dist (A x) (center q)^2 ≤ frobeniusSq A / (T : ℝ)^2 + ε^2 := by
      rw [dist_eq_norm]
      dsimp only [center]
      rw [← map_sub, image_norm_sq_spectral]
      have hrepr (i) : b.repr (x - b.repr.symm
          (WithLp.toLp 2 (sparseGridValue I T q))) i =
          b.repr x i - sparseGridValue I T q i := by
        simp
      have heq : (∑ i, w i) = frobeniusSq A := (frobeniusSq_eq_sum_eigenvalues A).symm
      rw [heq] at hq
      change (∑ i, w i * (b.repr (x - b.repr.symm
        (WithLp.toLp 2 (sparseGridValue I T q))) i)^2) ≤ _
      simp_rw [hrepr]
      exact hq
    have hh := Real.sqrt_le_sqrt he
    simpa only [Real.sqrt_sq (dist_nonneg)] using hh

/-- A small operator can be added without increasing the number of cover
centers; its operator-radius bound is added to the cover radius. -/
theorem small_operator_add_cover (U A : E →ₗ[ℝ] F) (σ δ : ℝ) (M : ℕ)
    (hσ : 0 ≤ σ) (hU : ∀ x, ‖U x‖ ≤ σ * ‖x‖)
    (hc : FiniteBallCover (A '' Metric.closedBall (0 : E) 1) M δ) :
    FiniteBallCover ((U + A) '' Metric.closedBall (0 : E) 1) M (σ + δ) := by
  classical
  obtain ⟨C, hCM, hC⟩ := hc
  refine ⟨C, hCM, ?_⟩
  rintro y ⟨x, hx, rfl⟩
  obtain ⟨c, hc, hxc⟩ := hC (A x) ⟨x, hx, rfl⟩
  refine ⟨c, hc, ?_⟩
  have hxn : ‖x‖ ≤ 1 := by simpa using hx
  have hu : ‖U x‖ ≤ σ := (hU x).trans (by nlinarith)
  calc
    dist ((U + A) x) c ≤ dist ((U + A) x) (A x) + dist (A x) c := dist_triangle _ _ _
    _ ≤ σ + δ := by simpa using add_le_add hu hxc

/-- Scaling and translation of an actual linear-image cover. -/
theorem linear_ball_cover_of_unit (A : E →ₗ[ℝ] F) (z : E) (r δ : ℝ) (M : ℕ)
    (hr : 0 < r) (hc : FiniteBallCover (A '' Metric.closedBall (0 : E) 1) M δ) :
    FiniteBallCover (A '' Metric.closedBall z r) M (r * δ) := by
  classical
  obtain ⟨C, hCM, hC⟩ := hc
  let trans : F → F := fun c => A z + r • c
  refine ⟨C.image trans, Finset.card_image_le.trans hCM, ?_⟩
  rintro y ⟨x, hx, rfl⟩
  let u : E := r⁻¹ • (x - z)
  have hu : u ∈ Metric.closedBall (0 : E) 1 := by
    have hh : ‖x - z‖ ≤ r := by simpa only [Metric.mem_closedBall, dist_eq_norm] using hx
    rw [Metric.mem_closedBall, dist_eq_norm]
    simp only [sub_zero, u, norm_smul, Real.norm_eq_abs, abs_inv, abs_of_pos hr]
    exact (inv_mul_le_one₀ hr).mpr hh
  obtain ⟨c, hc, huc⟩ := hC (A u) ⟨u, hu, rfl⟩
  refine ⟨trans c, Finset.mem_image_of_mem trans hc, ?_⟩
  have hxu : x = z + r • u := by
    simp only [u, smul_smul, mul_inv_cancel₀ (ne_of_gt hr), one_smul]
    abel
  calc
    dist (A x) (trans c) = r * dist (A u) c := by
      rw [hxu]
      simp only [map_add, map_smul, trans, dist_add_left, dist_smul₀,
        Real.norm_eq_abs, abs_of_pos hr]
    _ ≤ r * δ := mul_le_mul_of_nonneg_left huc hr.le

/-- Fixed Hilbert--Schmidt and operator budgets give a cover bound independent
of the dimensions of the domain and codomain. -/
theorem bounded_perturbation_ball_cover (U A : E →ₗ[ℝ] F) (z : E)
    (r σ ε : ℝ) (T K : ℕ) (hr : 0 < r) (hσ : 0 ≤ σ) (hε : 0 < ε)
    (hT : 0 < T) (hU : ∀ x, ‖U x‖ ≤ σ * ‖x‖)
    (hHS : frobeniusSq A ≤ ε^2 * K) :
    FiniteBallCover ((U + A) '' Metric.closedBall z r) ((2 * T + 1)^K)
      (r * (σ + Real.sqrt (frobeniusSq A / (T : ℝ)^2 + ε^2))) := by
  have hc := spectral_grid_unit_ball_cover A ε T hT
  have hb := activeAxes_card_bound (A.isSymmetric_adjoint_comp_self.eigenvalues rfl) ε
    (A.isPositive_adjoint_comp_self.nonneg_eigenvalues rfl)
  rw [← frobeniusSq_eq_sum_eigenvalues A] at hb
  have hk : (activeAxes (A.isSymmetric_adjoint_comp_self.eigenvalues rfl) ε).card ≤ K := by
    have hh : ((activeAxes (A.isSymmetric_adjoint_comp_self.eigenvalues rfl) ε).card : ℝ) ≤ K :=
      (mul_le_mul_iff_right₀ (sq_pos_of_pos hε)).mp (hb.trans hHS)
    exact_mod_cast hh
  obtain ⟨C, hCM, hC⟩ := linear_ball_cover_of_unit (U + A) z r _ _ hr
    (small_operator_add_cover U A σ _ _ hσ hU hc)
  refine ⟨C, hCM.trans ?_, hC⟩
  exact Nat.pow_le_pow_right (by omega : 0 < 2 * T + 1) hk

end LinearCover

#print axioms bounded_perturbation_ball_cover
#print axioms spectral_grid_unit_ball_cover
#print axioms activeAxes_card_bound
#print axioms exists_sparse_weighted_grid
#print axioms sparse_grid_card

end ConditionalNonpolynomial.Analytic
