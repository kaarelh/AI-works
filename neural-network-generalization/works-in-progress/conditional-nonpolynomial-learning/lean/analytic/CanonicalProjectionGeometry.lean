import NeuralGeneralization.GaussianResidualTrace
import Mathlib.Analysis.InnerProductSpace.PiL2

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace ConditionalAnalytic

variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℝ H]
    [CompleteSpace H] (V : Submodule ℝ H) [FiniteDimensional ℝ V]

/-- Coordinates in the projection span, followed by one residual-norm
coordinate. This preserves anchored Gram data, not arbitrary pairwise Grams. -/
def canonicalVector (z : H) : EuclideanSpace ℝ (Fin (Module.finrank ℝ V) ⊕ Unit) :=
  WithLp.toLp 2 (Sum.elim (fun i => ⟪((stdOrthonormalBasis ℝ V i : V) : H),z⟫)
    (fun _ => ‖Vᗮ.starProjection z‖))

lemma projection_norm_sq_basis (z : H) :
    ‖V.starProjection z‖^2 =
      ∑ i, ⟪((stdOrthonormalBasis ℝ V i : V) : H),z⟫^2 := by
  have h := (stdOrthonormalBasis ℝ V).sum_sq_norm_inner_right (V.orthogonalProjectionOnto z)
  simp only [Submodule.inner_orthogonalProjectionOnto_eq_of_mem_left,
    Real.norm_eq_abs,sq_abs] at h
  exact h.symm

theorem canonicalVector_norm_sq (z : H) : ‖canonicalVector V z‖^2=‖z‖^2 := by
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [canonicalVector,WithLp.ofLp_toLp,Fintype.sum_sum_type,
    Sum.elim_inl,Sum.elim_inr,Fintype.sum_unique]
  rw [← projection_norm_sq_basis]
  exact (Submodule.norm_sq_eq_add_norm_sq_starProjection z V).symm

theorem canonicalVector_norm (z : H) : ‖canonicalVector V z‖=‖z‖ :=
  (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp (canonicalVector_norm_sq V z)

theorem canonicalVector_distance (z w : H) :
    ‖canonicalVector V z-canonicalVector V w‖ ≤ ‖z-w‖ := by
  apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [canonicalVector,WithLp.ofLp_sub,WithLp.ofLp_toLp,Pi.sub_apply,
    Fintype.sum_sum_type,Sum.elim_inl,Sum.elim_inr,Fintype.sum_unique]
  have heq : (∑ i, (⟪((stdOrthonormalBasis ℝ V i : V) : H),z⟫-
      ⟪((stdOrthonormalBasis ℝ V i : V) : H),w⟫)^2) = ‖V.starProjection (z-w)‖^2 := by
    simp only [← inner_sub_right]
    exact (projection_norm_sq_basis V (z-w)).symm
  rw [heq]
  have hn := abs_norm_sub_norm_le (Vᗮ.starProjection z) (Vᗮ.starProjection w)
  have hn2 := pow_le_pow_left₀ (abs_nonneg _) hn 2
  simp only [sq_abs,← map_sub] at hn2
  have hpy := Submodule.norm_sq_eq_add_norm_sq_starProjection (z-w) V
  linarith

theorem canonicalVector_inner_anchor (z a : H) (ha : a∈V) :
    ⟪canonicalVector V z,canonicalVector V a⟫=⟪z,a⟫ := by
  have hzero : Vᗮ.starProjection a=0 := by
    rw [V.starProjection_orthogonal,sub_apply,
      ContinuousLinearMap.id_apply,Submodule.starProjection_eq_self_iff.mpr ha,sub_self]
  have haexp : (∑ i, ⟪((stdOrthonormalBasis ℝ V i : V) : H),a⟫ •
      ((stdOrthonormalBasis ℝ V i : V) : H)) = a := by
    simpa using congrArg (fun v : V => (v : H))
      ((stdOrthonormalBasis ℝ V).sum_repr' (⟨a,ha⟩ : V))
  rw [PiLp.inner_apply]
  simp only [canonicalVector,WithLp.ofLp_toLp,Fintype.sum_sum_type,
    Sum.elim_inl,Sum.elim_inr,Fintype.sum_unique,hzero,norm_zero,inner_zero_right,add_zero]
  conv_rhs => rw [← haexp,inner_sum]
  apply Finset.sum_congr rfl
  intro i hi
  simp only [inner_smul_right,Real.inner_apply,real_inner_comm]
  ring

/-- The retained linear coordinates have no residual-norm entry. -/
def canonicalLinear : H →ₗ[ℝ] EuclideanSpace ℝ (Fin (Module.finrank ℝ V) ⊕ Unit) where
  toFun z := WithLp.toLp 2 (Sum.elim
    (fun i => ⟪((stdOrthonormalBasis ℝ V i : V) : H),z⟫) (fun _ => 0))
  map_add' x y := by
    ext i
    cases i <;> simp [inner_add_right]
  map_smul' c x := by
    ext i
    cases i <;> simp [inner_smul_right]

/-- Adding a vector in the retained span only changes the linear coordinates. -/
theorem canonicalVector_add_mem (z l : H) (hl : l∈V) :
    canonicalVector V (z+l)=canonicalVector V z+canonicalLinear V l := by
  have hzero : Vᗮ.starProjection l=0 := by
    rw [V.starProjection_orthogonal,sub_apply,
      ContinuousLinearMap.id_apply,Submodule.starProjection_eq_self_iff.mpr hl,sub_self]
  ext i
  cases i <;> simp [canonicalVector,canonicalLinear,inner_add_right,map_add,hzero]

/-- This gives exactly the nonlinear-residual contraction used in canonical
layers whenever the original linear feature functions lie in the span. -/
theorem canonicalVector_residual_distance (z w l k : H) (hl : l∈V) (hk : k∈V) :
    ‖(canonicalVector V z-canonicalLinear V l)-
      (canonicalVector V w-canonicalLinear V k)‖ ≤ ‖(z-l)-(w-k)‖ := by
  have he (u v : H) (hv : v∈V) :
      canonicalVector V u-canonicalLinear V v = canonicalVector V (u-v) := by
    have hh := canonicalVector_add_mem V (u-v) v hv
    rw [sub_add_cancel] at hh
    exact sub_eq_iff_eq_add.mpr hh
  rw [he z l hl,he w k hk]
  exact canonicalVector_distance V _ _

section FiniteFamily
variable {K Q : Type*} [Fintype K] [Fintype Q]

/-- The retained space contains the linear Gaussian coordinate features and
all anchor features. Its dimension grows additively at each canonical layer. -/
def canonicalFeatureSpan (linear : K → H) (anchors : Q → H) : Submodule ℝ H :=
  Submodule.span ℝ (Set.range (Sum.elim linear anchors))

instance canonicalFeatureSpan_finite (linear : K → H) (anchors : Q → H) :
    FiniteDimensional ℝ (canonicalFeatureSpan linear anchors) := by
  unfold canonicalFeatureSpan
  exact FiniteDimensional.span_of_finite ℝ (Set.finite_range _)

theorem canonicalFeatureSpan_dimension (linear : K → H) (anchors : Q → H) :
    Module.finrank ℝ (canonicalFeatureSpan linear anchors)+1 ≤
      Fintype.card K+Fintype.card Q+1 := by
  have hh := finrank_range_le_card (R := ℝ) (Sum.elim linear anchors)
  simpa only [Set.finrank,canonicalFeatureSpan,Fintype.card_sum] using Nat.add_le_add_right hh 1

theorem linear_feature_mem (linear : K → H) (anchors : Q → H) (u : K → ℝ) :
    (∑ k,u k • linear k)∈canonicalFeatureSpan linear anchors := by
  apply Submodule.sum_mem
  intro k hk
  apply Submodule.smul_mem
  exact Submodule.subset_span ⟨Sum.inl k,rfl⟩

theorem canonical_anchor_data (linear : K → H) (anchors : Q → H) (z : H) (a : Q) :
    ⟪canonicalVector (canonicalFeatureSpan linear anchors) z,
      canonicalVector (canonicalFeatureSpan linear anchors) (anchors a)⟫ = ⟪z,anchors a⟫ :=
  canonicalVector_inner_anchor _ _ _ (Submodule.subset_span ⟨Sum.inr a,rfl⟩)
end FiniteFamily

#print axioms canonicalFeatureSpan_dimension
#print axioms canonical_anchor_data
#print axioms canonicalVector_inner_anchor
#print axioms canonicalVector_residual_distance
#print axioms canonicalVector_distance
end ConditionalAnalytic
