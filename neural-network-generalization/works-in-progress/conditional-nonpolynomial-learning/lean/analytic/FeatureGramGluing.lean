import Mathlib.Analysis.InnerProductSpace.ProdL2
import Mathlib.Analysis.InnerProductSpace.Projection.FiniteDimensional
import Mathlib.Analysis.InnerProductSpace.LinearMap
import Mathlib.LinearAlgebra.Isomorphisms
import Mathlib.LinearAlgebra.Finsupp.LinearCombination
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

open scoped BigOperators InnerProductSpace
namespace ConditionalNonpolynomial.Analytic

variable {V E F : Type*} [AddCommGroup V] [Module ℝ V]
variable [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [NormedAddCommGroup F] [InnerProductSpace ℝ F]

lemma ker_le_of_inner_eq (f : V →ₗ[ℝ] E) (g : V →ₗ[ℝ] F)
    (h : ∀ x y, inner ℝ (g x) (g y) = inner ℝ (f x) (f y)) :
    f.ker ≤ g.ker := by
  intro x hx
  have hh := h x x
  have hfx : f x = 0 := hx
  rw [hfx, inner_zero_left] at hh
  exact (inner_self_eq_zero).mp hh

/-- Transport across identical Gram forms on the range of a linear map. -/
noncomputable def gramRangeTransport (f : V →ₗ[ℝ] E) (g : V →ₗ[ℝ] F)
    (h : ∀ x y, inner ℝ (g x) (g y) = inner ℝ (f x) (f y)) :
    f.range →ₗ[ℝ] F :=
  (f.ker.liftQ g (ker_le_of_inner_eq f g h)).comp f.quotKerEquivRange.symm.toLinearMap

lemma gramRangeTransport_image (f : V →ₗ[ℝ] E) (g : V →ₗ[ℝ] F)
    (h : ∀ x y, inner ℝ (g x) (g y) = inner ℝ (f x) (f y)) (x : V) :
    gramRangeTransport f g h ⟨f x, LinearMap.mem_range_self f x⟩ = g x := by
  simp only [gramRangeTransport, LinearMap.comp_apply, LinearEquiv.coe_coe,
    LinearMap.quotKerEquivRange_symm_apply_image, Submodule.mkQ_apply,
    Submodule.liftQ_apply]

noncomputable def gramRangeIsometry (f : V →ₗ[ℝ] E) (g : V →ₗ[ℝ] F)
    (h : ∀ x y, inner ℝ (g x) (g y) = inner ℝ (f x) (f y)) :
    f.range →ₗᵢ[ℝ] F :=
  (gramRangeTransport f g h).isometryOfInner (by
    intro x y
    obtain ⟨a,ha⟩ := x.property
    obtain ⟨b,hb⟩ := y.property
    have hx : x = ⟨f a, LinearMap.mem_range_self f a⟩ := Subtype.ext ha.symm
    have hy : y = ⟨f b, LinearMap.mem_range_self f b⟩ := Subtype.ext hb.symm
    rw [hx,hy,gramRangeTransport_image,gramRangeTransport_image]
    exact h a b)

lemma gramRangeIsometry_image (f : V →ₗ[ℝ] E) (g : V →ₗ[ℝ] F)
    (h : ∀ x y, inner ℝ (g x) (g y) = inner ℝ (f x) (f y)) (x : V) :
    gramRangeIsometry f g h ⟨f x, LinearMap.mem_range_self f x⟩ = g x :=
  gramRangeTransport_image f g h x

/-- Extension of the span isometry into a common enlarged Hilbert space.
The orthogonal complement is retained in a fresh summand. -/
noncomputable def gramAmbientIsometry (f : V →ₗ[ℝ] E) (g : V →ₗ[ℝ] F)
    [f.range.HasOrthogonalProjection]
    (h : ∀ x y, inner ℝ (g x) (g y) = inner ℝ (f x) (f y)) :
    E →ₗᵢ[ℝ] WithLp 2 (F × E) :=
  ((gramRangeIsometry f g h).withLpProdMap 2 f.rangeᗮ.subtypeₗᵢ).comp
    f.range.orthogonalDecomposition.toLinearIsometry

lemma gramAmbientIsometry_image (f : V →ₗ[ℝ] E) (g : V →ₗ[ℝ] F)
    [f.range.HasOrthogonalProjection]
    (h : ∀ x y, inner ℝ (g x) (g y) = inner ℝ (f x) (f y)) (x : V) :
    gramAmbientIsometry f g h (f x) = WithLp.toLp 2 (g x, 0) := by
  have hproj : f.range.orthogonalProjectionOnto (f x) =
      ⟨f x, LinearMap.mem_range_self f x⟩ :=
    Submodule.orthogonalProjectionOnto_mem_subspace_eq_self
      (⟨f x, LinearMap.mem_range_self f x⟩ : f.range)
  have horth : f.rangeᗮ.orthogonalProjectionOnto (f x) = 0 := by
    apply Submodule.orthogonalProjectionOnto_eq_zero_iff.mpr
    exact f.range.le_orthogonal_orthogonal (LinearMap.mem_range_self f x)
  simp only [gramAmbientIsometry, LinearIsometry.coe_comp, Function.comp_apply,
    LinearIsometryEquiv.coe_toLinearIsometry, Submodule.orthogonalDecomposition_apply,
    hproj, horth]
  change WithLp.toLp 2 (gramRangeIsometry f g h
    ⟨f x, LinearMap.mem_range_self f x⟩, (0:E)) = _
  rw [gramRangeIsometry_image]

/-- The left summand inclusion as a linear isometry. -/
noncomputable def hilbertLeftEmbedding : F →ₗᵢ[ℝ] WithLp 2 (F × E) :=
  (((WithLp.linearEquiv 2 ℝ (F×E)).symm.toLinearMap).comp (LinearMap.inl ℝ F E)).isometryOfInner
    (by intro x y; simp)

lemma hilbertLeftEmbedding_apply (x : F) :
    (hilbertLeftEmbedding (E := E) (F := F)) x = WithLp.toLp 2 (x,0) := rfl

variable {ι : Type*} [Fintype ι]

lemma linearCombination_inner_of_gram_eq (u : ι → E) (v : ι → F)
    (h : ∀ i j, inner ℝ (v i) (v j) = inner ℝ (u i) (u j)) (a b : ι → ℝ) :
    inner ℝ (Fintype.linearCombination ℝ v a) (Fintype.linearCombination ℝ v b) =
      inner ℝ (Fintype.linearCombination ℝ u a) (Fintype.linearCombination ℝ u b) := by
  simp only [Fintype.linearCombination_apply, sum_inner, inner_sum,
    real_inner_smul_left, real_inner_smul_right, h]

/-- Equal Gram matrices allow exact identification of every feature row,
while preserving the whole original ambient space isometrically. -/
theorem equal_gram_common_embedding (u : ι → E) (v : ι → F)
    (h : ∀ i j, inner ℝ (v i) (v j) = inner ℝ (u i) (u j)) :
    ∃ U : E →ₗᵢ[ℝ] WithLp 2 (F×E),
      ∃ W : F →ₗᵢ[ℝ] WithLp 2 (F×E), ∀ i, U (u i)=W (v i) := by
  classical
  let f := Fintype.linearCombination ℝ u
  let g := Fintype.linearCombination ℝ v
  have hh := linearCombination_inner_of_gram_eq u v h
  refine ⟨gramAmbientIsometry f g hh, hilbertLeftEmbedding, ?_⟩
  intro i
  have he := gramAmbientIsometry_image f g hh (Pi.single i 1)
  simpa only [f,g,Fintype.linearCombination_apply_single,one_smul,
    hilbertLeftEmbedding_apply] using he

/-- Join two already constructed feature couplings along their common Gram
matrix. The errors add linearly; no new square root is taken of the propagated
error. This is the geometric step preventing exponential loss of precision
in repeated covariance-path repair. -/
theorem glue_feature_pairs (u v : ι → E) (a b : ι → F)
    (hgram : ∀ i j, inner ℝ (a i) (a j) = inner ℝ (v i) (v j))
    (e δ : ℝ) (huv : ∀ i, ‖u i-v i‖ ≤ e) (hab : ∀ i, ‖a i-b i‖ ≤ δ) :
    ∃ U : E →ₗᵢ[ℝ] WithLp 2 (F×E),
      ∃ W : F →ₗᵢ[ℝ] WithLp 2 (F×E),
        (∀ i, U (v i)=W (a i)) ∧ ∀ i, ‖U (u i)-W (b i)‖ ≤ e+δ := by
  obtain ⟨U,W,heq⟩ := equal_gram_common_embedding v a hgram
  refine ⟨U,W,heq,?_⟩
  intro i
  calc
    ‖U (u i)-W (b i)‖ ≤ ‖U (u i)-U (v i)‖+‖U (v i)-W (b i)‖ :=
      by simpa only [dist_eq_norm] using dist_triangle (U (u i)) (U (v i)) (W (b i))
    _ = ‖u i-v i‖+‖a i-b i‖ := by
      rw [← U.map_sub,U.norm_map,heq i,← W.map_sub,W.norm_map]
    _ ≤ e+δ := add_le_add (huv i) (hab i)

end ConditionalNonpolynomial.Analytic
