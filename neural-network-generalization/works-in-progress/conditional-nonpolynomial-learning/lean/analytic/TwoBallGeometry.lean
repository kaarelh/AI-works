import Mathlib.Analysis.InnerProductSpace.SingularValues
import Mathlib.Analysis.InnerProductSpace.Trace
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.NormNum

open scoped BigOperators RealInnerProductSpace
open Finset

namespace BooleanDepthResearch

variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E] [NormedAddCommGroup F] [InnerProductSpace ℝ F]
  [FiniteDimensional ℝ F]

/-- Squared Hilbert--Schmidt (Frobenius) norm, defined without a choice of basis. -/
noncomputable def frobeniusSq (A : E →ₗ[ℝ] F) : ℝ :=
  LinearMap.trace ℝ E (A.adjoint ∘ₗ A)

/-- Frobenius norm of a rectangular linear map. -/
noncomputable def frobeniusNorm (A : E →ₗ[ℝ] F) : ℝ :=
  Real.sqrt (frobeniusSq A)

theorem frobeniusSq_eq_sum_norm_sq {ι : Type*} [Fintype ι]
    (A : E →ₗ[ℝ] F) (b : OrthonormalBasis ι ℝ E) :
    frobeniusSq A = ∑ i, ‖A (b i)‖ ^ 2 := by
  rw [frobeniusSq, LinearMap.trace_eq_sum_inner _ b]
  simp only [LinearMap.comp_apply, LinearMap.adjoint_inner_right,
    real_inner_self_eq_norm_sq]

/-- The trace definition agrees with the conventional sum of squared matrix entries,
for every pair of orthonormal coordinate systems, including rectangular matrices. -/
theorem frobeniusSq_eq_matrix_sum {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    (A : E →ₗ[ℝ] F) (b : OrthonormalBasis ι ℝ E) (c : OrthonormalBasis κ ℝ F) :
    frobeniusSq A = ∑ i, ∑ j, (LinearMap.toMatrix b.toBasis c.toBasis A j i) ^ 2 := by
  rw [frobeniusSq_eq_sum_norm_sq A b]
  apply Finset.sum_congr rfl
  intro i _
  simp_rw [LinearMap.toMatrix_apply, OrthonormalBasis.coe_toBasis_repr_apply,
    OrthonormalBasis.coe_toBasis, OrthonormalBasis.repr_apply_apply]
  exact (c.sum_sq_inner_right (A (b i))).symm

theorem frobeniusSq_eq_sum_eigenvalues (A : E →ₗ[ℝ] F) :
    frobeniusSq A = ∑ i, A.isSymmetric_adjoint_comp_self.eigenvalues rfl i := by
  exact A.isSymmetric_adjoint_comp_self.trace_eq_sum_eigenvalues rfl

theorem frobeniusSq_nonneg (A : E →ₗ[ℝ] F) : 0 ≤ frobeniusSq A := by
  rw [frobeniusSq_eq_sum_eigenvalues]
  exact Finset.sum_nonneg fun i _ ↦ A.isPositive_adjoint_comp_self.nonneg_eigenvalues rfl i

theorem frobeniusNorm_sq (A : E →ₗ[ℝ] F) : frobeniusNorm A ^ 2 = frobeniusSq A :=
  Real.sq_sqrt (frobeniusSq_nonneg A)

/-- The squared image norm is the eigenvalue-weighted squared coordinate norm.
This derives the needed singular-axis geometry from mathlib's spectral theorem. -/
theorem image_norm_sq_spectral (A : E →ₗ[ℝ] F) (x : E) :
    ‖A x‖ ^ 2 = ∑ i, A.isSymmetric_adjoint_comp_self.eigenvalues rfl i *
      ((A.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl).repr x i) ^ 2 := by
  let b := A.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl
  rw [← real_inner_self_eq_norm_sq, ← A.adjoint_inner_right]
  change ⟪x, (A.adjoint ∘ₗ A) x⟫ = _
  rw [← b.sum_inner_mul_inner x ((A.adjoint ∘ₗ A) x)]
  apply Finset.sum_congr rfl
  intro i _
  rw [← b.repr_apply_apply, A.isSymmetric_adjoint_comp_self.eigenvectorBasis_apply_self_apply]
  rw [real_inner_comm, ← b.repr_apply_apply]
  simp only [b, RCLike.ofReal_real_eq_id, id_eq]
  ring

/-- A scalar endpoint estimate in squared-axis coordinates. -/
theorem weighted_endpoint_bound (L B k t : ℝ) (hL : 0 < L) (hB : 0 ≤ B)
    (hBL : B ≤ L) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (hk : 2 * L * k = L - B) :
    L * t ^ 2 + B * (1 - t ^ 2) - 2 * k * L * t + k ^ 2 * L ≤
      (L + B) / 2 := by
  have hprod : 0 ≤ (L - B) * t * (1 - t) :=
    mul_nonneg (mul_nonneg (sub_nonneg.mpr hBL) ht0) (sub_nonneg.mpr ht1)
  have hkt : 2 * L * k * t = (L - B) * t := congrArg (· * t) hk
  have hquad : L * t ^ 2 + B * (1 - t ^ 2) - 2 * k * L * t + k ^ 2 * L ≤
      k ^ 2 * L + B := by nlinarith
  apply hquad.trans
  apply (mul_le_mul_iff_right₀ hL).mp
  have hksq := congrArg (fun z : ℝ ↦ z ^ 2) hk
  have hBs : B ^ 2 ≤ L ^ 2 := by nlinarith
  nlinarith

/-- If no squared axis is larger than half the total, one centered ball suffices. -/
theorem weighted_small_axes {ι : Type*} [Fintype ι] (w v : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i) (hv : ∑ i, v i ^ 2 ≤ 1)
    (hsmall : ∀ i, w i ≤ (∑ j, w j) / 2) :
    ∑ i, w i * v i ^ 2 ≤ (∑ i, w i) / 2 := by
  have hS : 0 ≤ ∑ i, w i := Finset.sum_nonneg fun i _ ↦ hw i
  calc
    ∑ i, w i * v i ^ 2 ≤ ∑ i, ((∑ j, w j) / 2) * v i ^ 2 := by
      exact Finset.sum_le_sum fun i _ ↦ mul_le_mul_of_nonneg_right (hsmall i) (sq_nonneg _)
    _ = ((∑ j, w j) / 2) * ∑ i, v i ^ 2 := by rw [Finset.mul_sum]
    _ ≤ (∑ j, w j) / 2 := by nlinarith

/-- A dominant squared axis yields an explicit antipodal pair of centers.
No ordering or nonemptiness assumptions on the finite coordinate type are needed. -/
theorem weighted_dominant_center {ι : Type*} [Fintype ι] (w : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i) (j : ι) (hdom : (∑ i, w i) / 2 < w j) :
    ∃ k : ℝ, ∀ v : ι → ℝ, (∑ i, v i ^ 2 ≤ 1) →
      (∑ i, w i * v i ^ 2) - 2 * k * w j * |v j| + k ^ 2 * w j ≤
        (∑ i, w i) / 2 := by
  classical
  let B : ℝ := ∑ i ∈ Finset.univ.erase j, w i
  have hB : 0 ≤ B := Finset.sum_nonneg fun i _ ↦ hw i
  have hsum : B + w j = ∑ i, w i := Finset.sum_erase_add _ _ (Finset.mem_univ j)
  have hBL : B ≤ w j := by linarith
  have hL : 0 < w j := by linarith
  let k := (w j - B) / (2 * w j)
  have hk : 2 * w j * k = w j - B := by
    dsimp [k]
    field_simp
  refine ⟨k, fun v hv ↦ ?_⟩
  have hj2 : v j ^ 2 ≤ 1 :=
    (Finset.single_le_sum (fun i _ ↦ sq_nonneg (v i)) (Finset.mem_univ j)).trans hv
  have ht1 : |v j| ≤ 1 := by nlinarith [sq_abs (v j), abs_nonneg (v j)]
  have htail : (∑ i ∈ Finset.univ.erase j, w i * v i ^ 2) ≤
      B * (1 - v j ^ 2) := by
    calc
      (∑ i ∈ Finset.univ.erase j, w i * v i ^ 2) ≤
          ∑ i ∈ Finset.univ.erase j, B * v i ^ 2 := by
        apply Finset.sum_le_sum
        intro i hi
        apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
        exact Finset.single_le_sum (fun i _ ↦ hw i) hi
      _ = B * ∑ i ∈ Finset.univ.erase j, v i ^ 2 := by rw [Finset.mul_sum]
      _ ≤ B * (1 - v j ^ 2) := by
        apply mul_le_mul_of_nonneg_left _ hB
        have := Finset.sum_erase_add Finset.univ (fun i ↦ v i ^ 2) (Finset.mem_univ j)
        linarith
  have hfull := Finset.sum_erase_add Finset.univ (fun i ↦ w i * v i ^ 2)
    (Finset.mem_univ j)
  have hend := weighted_endpoint_bound (w j) B k |v j| hL hB hBL (abs_nonneg _) ht1 hk
  rw [sq_abs] at hend
  linarith

/-- Inner products with a principal image axis, derived from the adjoint eigenvector equation. -/
theorem image_inner_spectral_axis (A : E →ₗ[ℝ] F) (x : E)
    (j : Fin (Module.finrank ℝ E)) :
    ⟪A x, A (A.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl j)⟫ =
      A.isSymmetric_adjoint_comp_self.eigenvalues rfl j *
        ((A.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl).repr x j) := by
  rw [← A.adjoint_inner_right]
  change ⟪x, (A.adjoint ∘ₗ A)
    (A.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl j)⟫ = _
  rw [A.isSymmetric_adjoint_comp_self.apply_eigenvectorBasis,
    real_inner_smul_right, real_inner_comm, ← OrthonormalBasis.repr_apply_apply]
  rfl

theorem image_spectral_axis_norm_sq (A : E →ₗ[ℝ] F)
    (j : Fin (Module.finrank ℝ E)) :
    ‖A (A.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl j)‖ ^ 2 =
      A.isSymmetric_adjoint_comp_self.eigenvalues rfl j := by
  rw [← real_inner_self_eq_norm_sq, image_inner_spectral_axis,
    OrthonormalBasis.repr_apply_apply, real_inner_self_eq_norm_sq,
    OrthonormalBasis.norm_eq_one]
  ring

/-- Full geometric unit-ball covering, in squared-radius form. The centers are actual
codomain vectors, and the spectral geometry is proved rather than assumed. -/
theorem unit_ball_two_centers_sq (A : E →ₗ[ℝ] F) :
    ∃ c : F, ∀ x : E, ‖x‖ ≤ 1 →
      ‖A x - c‖ ^ 2 ≤ frobeniusSq A / 2 ∨
      ‖A x + c‖ ^ 2 ≤ frobeniusSq A / 2 := by
  classical
  let b := A.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl
  let w := A.isSymmetric_adjoint_comp_self.eigenvalues rfl
  have hw : ∀ i, 0 ≤ w i := A.isPositive_adjoint_comp_self.nonneg_eigenvalues rfl
  have hsum : frobeniusSq A = ∑ i, w i := frobeniusSq_eq_sum_eigenvalues A
  have hcoord (x : E) : ∑ i, (b.repr x i) ^ 2 = ‖x‖ ^ 2 := by
    simp_rw [b.repr_apply_apply]
    exact b.sum_sq_inner_right x
  have hnorm (x : E) : ‖A x‖ ^ 2 = ∑ i, w i * (b.repr x i) ^ 2 :=
    image_norm_sq_spectral A x
  by_cases hsmall : ∀ i, w i ≤ (∑ j, w j) / 2
  · refine ⟨0, fun x hx ↦ Or.inl ?_⟩
    rw [sub_zero, hsum, hnorm]
    apply weighted_small_axes w (fun i ↦ b.repr x i) hw _ hsmall
    rw [hcoord]
    nlinarith [norm_nonneg x]
  · push Not at hsmall
    obtain ⟨j, hj⟩ := hsmall
    obtain ⟨k, hk⟩ := weighted_dominant_center w hw j hj
    let c : F := k • A (b j)
    refine ⟨c, fun x hx ↦ ?_⟩
    have hc : ‖c‖ ^ 2 = k ^ 2 * w j := by
      dsimp [c]
      rw [norm_smul, mul_pow, Real.norm_eq_abs, sq_abs, image_spectral_axis_norm_sq]
    have hcx : ⟪A x, c⟫ = k * w j * b.repr x j := by
      dsimp [c]
      rw [real_inner_smul_right, image_inner_spectral_axis]
      ring
    have hv : ∑ i, (b.repr x i) ^ 2 ≤ 1 := by
      rw [hcoord]
      nlinarith [norm_nonneg x]
    have h := hk (fun i ↦ b.repr x i) hv
    rw [← hsum, ← hnorm] at h
    by_cases hsign : 0 ≤ b.repr x j
    · left
      rw [abs_of_nonneg hsign] at h
      rw [norm_sub_sq_real, hc, hcx]
      nlinarith
    · right
      rw [abs_of_neg (lt_of_not_ge hsign)] at h
      rw [norm_add_sq_real, hc, hcx]
      nlinarith

/-- The usual Frobenius radius for the unit ball. -/
theorem unit_ball_two_centers (A : E →ₗ[ℝ] F) :
    ∃ c : F, ∀ x : E, ‖x‖ ≤ 1 →
      ‖A x - c‖ ≤ frobeniusNorm A / Real.sqrt 2 ∨
      ‖A x + c‖ ≤ frobeniusNorm A / Real.sqrt 2 := by
  have hR : 0 ≤ frobeniusNorm A / Real.sqrt 2 := by
    unfold frobeniusNorm
    positivity
  have hR2 : (frobeniusNorm A / Real.sqrt 2) ^ 2 = frobeniusSq A / 2 := by
    rw [div_pow, frobeniusNorm_sq, Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2)]
  obtain ⟨c, hc⟩ := unit_ball_two_centers_sq A
  refine ⟨c, fun x hx ↦ ?_⟩
  rcases hc x hx with h | h
  · left
    exact (sq_le_sq₀ (norm_nonneg _) hR).mp (by rwa [hR2])
  · right
    exact (sq_le_sq₀ (norm_nonneg _) hR).mp (by rwa [hR2])

/-- Dimension-independent two-ball Frobenius covering in norm form, at any radius. -/
theorem ball_two_centers (A : E →ₗ[ℝ] F) (r : ℝ) (hr : 0 ≤ r) :
    ∃ c : F, ∀ x : E, ‖x‖ ≤ r →
      ‖A x - c‖ ≤ r * frobeniusNorm A / Real.sqrt 2 ∨
      ‖A x + c‖ ≤ r * frobeniusNorm A / Real.sqrt 2 := by
  rcases eq_or_lt_of_le hr with rfl | hr
  · refine ⟨0, fun x hx ↦ Or.inl ?_⟩
    have hx0 : x = 0 := norm_eq_zero.mp (le_antisymm hx (norm_nonneg x))
    simp [hx0]
  obtain ⟨c, hc⟩ := unit_ball_two_centers A
  refine ⟨r • c, fun x hx ↦ ?_⟩
  have hy : ‖r⁻¹ • x‖ ≤ 1 := by
    rw [norm_smul, Real.norm_eq_abs, abs_inv, abs_of_pos hr]
    exact (inv_mul_le_iff₀ hr).mpr (by simpa using hx)
  have hsub : A x - r • c = r • (A (r⁻¹ • x) - c) := by
    simp [smul_sub, map_smul, smul_smul, ne_of_gt hr]
  have hadd : A x + r • c = r • (A (r⁻¹ • x) + c) := by
    simp [smul_add, map_smul, smul_smul, ne_of_gt hr]
  rcases hc (r⁻¹ • x) hy with h | h
  · left
    rw [hsub, norm_smul, Real.norm_eq_abs, abs_of_pos hr]
    simpa only [mul_div_assoc] using mul_le_mul_of_nonneg_left h (le_of_lt hr)
  · right
    rw [hadd, norm_smul, Real.norm_eq_abs, abs_of_pos hr]
    simpa only [mul_div_assoc] using mul_le_mul_of_nonneg_left h (le_of_lt hr)

/-- The full two-ball Frobenius covering lemma for a rectangular linear map between
arbitrary finite-dimensional real inner-product spaces. There are no positive-dimension,
positive-rank, or invertibility assumptions. The two centers may coincide. -/
theorem two_ball_frobenius_cover (A : E →ₗ[ℝ] F) (r : ℝ) (hr : 0 ≤ r) :
    ∃ c : F,
      A '' Metric.closedBall (0 : E) r ⊆
        Metric.closedBall c (r * frobeniusNorm A / Real.sqrt 2) ∪
        Metric.closedBall (-c) (r * frobeniusNorm A / Real.sqrt 2) := by
  obtain ⟨c, hc⟩ := ball_two_centers A r hr
  refine ⟨c, ?_⟩
  rintro y ⟨x, hx, rfl⟩
  have hx' : ‖x‖ ≤ r := by simpa only [Metric.mem_closedBall, dist_zero_right] using hx
  simpa only [Set.mem_union, Metric.mem_closedBall, dist_eq_norm, sub_neg_eq_add]
    using hc x hx'

/-- The covering radius uses precisely the conventional Frobenius norm in any
orthonormal domain and codomain coordinates. -/
theorem frobeniusNorm_eq_matrix_sum_sqrt {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ] (A : E →ₗ[ℝ] F)
    (b : OrthonormalBasis ι ℝ E) (c : OrthonormalBasis κ ℝ F) :
    frobeniusNorm A = Real.sqrt
      (∑ i, ∑ j, (LinearMap.toMatrix b.toBasis c.toBasis A j i) ^ 2) := by
  rw [frobeniusNorm, frobeniusSq_eq_matrix_sum A b c]

/-- Equivalently, the squared Frobenius norm is the sum of squared singular values. -/
theorem frobeniusSq_eq_sum_singularValues_sq (A : E →ₗ[ℝ] F) :
    frobeniusSq A = ∑ i : Fin (Module.finrank ℝ E), A.singularValues i ^ 2 := by
  rw [frobeniusSq_eq_sum_eigenvalues]
  simp_rw [A.sq_singularValues_fin rfl]

/-- The same two-ball cover for a ball centered at an arbitrary domain point. -/
theorem two_ball_frobenius_cover_at (A : E →ₗ[ℝ] F) (z : E)
    (r : ℝ) (hr : 0 ≤ r) :
    ∃ c₁ c₂ : F,
      A '' Metric.closedBall z r ⊆
        Metric.closedBall c₁ (r * frobeniusNorm A / Real.sqrt 2) ∪
        Metric.closedBall c₂ (r * frobeniusNorm A / Real.sqrt 2) := by
  obtain ⟨c, hc⟩ := ball_two_centers A r hr
  refine ⟨A z + c, A z - c, ?_⟩
  rintro y ⟨x, hx, rfl⟩
  have hx' : ‖x - z‖ ≤ r := by simpa only [Metric.mem_closedBall, dist_eq_norm] using hx
  have h₁ : A x - (A z + c) = A (x - z) - c := by rw [map_sub]; abel
  have h₂ : A x - (A z - c) = A (x - z) + c := by rw [map_sub]; abel
  simpa only [Set.mem_union, Metric.mem_closedBall, dist_eq_norm, h₁, h₂]
    using hc (x - z) hx'

/-- A finite family of at most two closed balls covers the linear image.
This form records the covering cardinality explicitly. -/
theorem two_ball_frobenius_cover_finset (A : E →ₗ[ℝ] F) (z : E)
    (r : ℝ) (hr : 0 ≤ r) :
    ∃ C : Finset F, C.card ≤ 2 ∧
      ∀ y ∈ A '' Metric.closedBall z r, ∃ c ∈ C,
        y ∈ Metric.closedBall c (r * frobeniusNorm A / Real.sqrt 2) := by
  classical
  obtain ⟨c₁, c₂, hc⟩ := two_ball_frobenius_cover_at A z r hr
  refine ⟨{c₁, c₂}, Finset.card_le_two, ?_⟩
  intro y hy
  rcases hc hy with h | h
  · exact ⟨c₁, by simp, h⟩
  · exact ⟨c₂, by simp, h⟩

/-- Entire covering statement with the conventional coordinate-sum Frobenius radius,
so its meaning is independent of the trace definition used internally. -/
theorem two_ball_matrix_frobenius_cover {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ] (A : E →ₗ[ℝ] F)
    (b : OrthonormalBasis ι ℝ E) (d : OrthonormalBasis κ ℝ F)
    (z : E) (r : ℝ) (hr : 0 ≤ r) :
    ∃ C : Finset F, C.card ≤ 2 ∧
      ∀ y ∈ A '' Metric.closedBall z r, ∃ c ∈ C,
        y ∈ Metric.closedBall c
          (r * Real.sqrt (∑ i, ∑ j,
            (LinearMap.toMatrix b.toBasis d.toBasis A j i) ^ 2) / Real.sqrt 2) := by
  simpa only [frobeniusNorm_eq_matrix_sum_sqrt A b d]
    using two_ball_frobenius_cover_finset A z r hr

#print axioms two_ball_frobenius_cover
#print axioms two_ball_matrix_frobenius_cover

end BooleanDepthResearch
