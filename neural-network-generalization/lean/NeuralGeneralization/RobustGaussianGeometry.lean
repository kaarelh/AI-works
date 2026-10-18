import NeuralGeneralization.GaussianResidualIndependence
import Mathlib.Analysis.InnerProductSpace.GramSchmidtOrtho

/-!
# Measurable Gram--Schmidt geometry and actual Gaussian query residuals

The Gram--Schmidt maps below allow dependent and zero input vectors.  There is
no choice of a measurable basis hidden in the definitions.  Gaussian statements
refer to the concrete product Gaussian, not an assumed conditional law.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InnerProductSpace Submodule
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.RobustGaussianGeometry
open GaussianOrthogonal GaussianResidualIndependence

variable {N m : ℕ}

/-- Gram--Schmidt is Borel measurable, including at rank-changing families. -/
theorem measurable_gramSchmidt (j : Fin m) :
    Measurable (fun f : Fin m → EuclideanSpace ℝ (Fin N) => gramSchmidt ℝ f j) := by
  classical
  induction j using WellFoundedLT.induction with
  | ind j ih =>
    have heq : (fun f : Fin m → EuclideanSpace ℝ (Fin N) => gramSchmidt ℝ f j) =
        fun f => f j - ∑ i ∈ Finset.Iio j,
          (inner ℝ (gramSchmidt ℝ f i) (f j) /
            ‖gramSchmidt ℝ f i‖ ^ 2) • gramSchmidt ℝ f i := by
      funext f
      rw [gramSchmidt_def]
      simp only [starProjection_singleton, RCLike.ofReal_real_eq_id, id_eq]
    rw [heq]
    apply (measurable_pi_apply j).sub
    apply Finset.measurable_sum
    intro i hi
    have hgi := ih i (Finset.mem_Iio.mp hi)
    have hi : Measurable (fun f : Fin m → EuclideanSpace ℝ (Fin N) =>
        inner ℝ (gramSchmidt ℝ f i) (f j)) :=
      (continuous_inner.measurable).comp (hgi.prodMk (measurable_pi_apply j))
    exact (hi.div (hgi.norm.pow_const 2)).smul hgi

/-- The zero-safe normalized Gram--Schmidt vectors are Borel measurable. -/
theorem measurable_gramSchmidtNormed (j : Fin m) :
    Measurable (fun f : Fin m → EuclideanSpace ℝ (Fin N) =>
      gramSchmidtNormed ℝ f j) := by
  unfold gramSchmidtNormed
  exact (measurable_gramSchmidt j).norm.inv.smul (measurable_gramSchmidt j)

/-- Simultaneous measurability of the entire finite normalized family. -/
theorem measurable_gramSchmidtNormed_family :
    Measurable (fun f : Fin m → EuclideanSpace ℝ (Fin N) =>
      gramSchmidtNormed ℝ f) :=
  measurable_pi_lambda _ measurable_gramSchmidtNormed

/-- A rank-independent formula for projection onto the active span. -/
def activeProjection (f : Fin m → EuclideanSpace ℝ (Fin N))
    (x : EuclideanSpace ℝ (Fin N)) : EuclideanSpace ℝ (Fin N) :=
  ∑ j, ⟪gramSchmidtNormed ℝ f j, x⟫ • gramSchmidtNormed ℝ f j

/-- Joint measurability permits the active span to depend on earlier layers. -/
theorem measurable_activeProjection :
    Measurable (fun p : (Fin m → EuclideanSpace ℝ (Fin N)) ×
        EuclideanSpace ℝ (Fin N) => activeProjection p.1 p.2) := by
  unfold activeProjection
  apply Finset.measurable_sum
  intro j hj
  have hg : Measurable (fun p : (Fin m → EuclideanSpace ℝ (Fin N)) ×
      EuclideanSpace ℝ (Fin N) => gramSchmidtNormed ℝ p.1 j) :=
    (measurable_gramSchmidtNormed j).comp measurable_fst
  have hi : Measurable (fun p : (Fin m → EuclideanSpace ℝ (Fin N)) ×
      EuclideanSpace ℝ (Fin N) => inner ℝ (gramSchmidtNormed ℝ p.1 j) p.2) :=
    continuous_inner.measurable.comp (hg.prodMk measurable_snd)
  exact hi.smul hg

/-- The explicit measurable sum is the actual orthogonal projection. -/
theorem activeProjection_eq_starProjection (f : Fin m → EuclideanSpace ℝ (Fin N))
    (x : EuclideanSpace ℝ (Fin N)) :
    activeProjection f x = (Submodule.span ℝ (Set.range f)).starProjection x := by
  classical
  let g := gramSchmidtNormed ℝ f
  have hspan : Submodule.span ℝ (Set.range g) = Submodule.span ℝ (Set.range f) := by
    change Submodule.span ℝ (Set.range (gramSchmidtNormed ℝ f)) = _
    rw [span_gramSchmidtNormed_range, span_gramSchmidt]
  have hp : activeProjection f x ∈ Submodule.span ℝ (Set.range g) := by
    apply Submodule.sum_mem
    intro j hj
    exact Submodule.smul_mem _ _ (Submodule.subset_span (Set.mem_range_self j))
  have hi (j : Fin m) : ⟪g j, activeProjection f x⟫ = ⟪g j, x⟫ := by
    change ⟪g j, ∑ k, ⟪g k, x⟫ • g k⟫ = _
    rw [inner_sum]
    by_cases hj : g j = 0
    · simp [hj]
    · have ho : ∀ k, ⟪g j, g k⟫ = if j = k then 1 else 0 := by
        intro k
        split_ifs with h
        · subst k
          rw [real_inner_self_eq_norm_sq, gramSchmidtNormed_unit_length' hj]
          norm_num
        · dsimp [g, gramSchmidtNormed]
          simp [inner_smul_left, inner_smul_right, gramSchmidt_orthogonal ℝ f h]
      simp only [inner_smul_right, ho]
      simp
  symm
  apply Submodule.eq_starProjection_of_mem_of_inner_eq_zero
  · rw [← hspan]
    exact hp
  · intro y hy
    rw [← hspan] at hy
    induction hy using Submodule.span_induction with
    | mem y hy =>
      rcases hy with ⟨j, rfl⟩
      rw [inner_sub_left, real_inner_comm (g j) x,
        real_inner_comm (g j) (activeProjection f x), hi]
      exact sub_self _
    | zero => simp
    | add a b ha hb ha' hb' => simp [inner_add_right, ha', hb']
    | smul a y hy hy' => simp [inner_smul_right, hy']

/-- The new query direction after removing its active-span component. -/
def queryResidual (f : Fin m → EuclideanSpace ℝ (Fin N))
    (x : EuclideanSpace ℝ (Fin N)) := x - activeProjection f x

theorem measurable_queryResidual :
    Measurable (fun p : (Fin m → EuclideanSpace ℝ (Fin N)) ×
        EuclideanSpace ℝ (Fin N) => queryResidual p.1 p.2) :=
  measurable_snd.sub measurable_activeProjection

theorem queryResidual_mem_orthogonal (f : Fin m → EuclideanSpace ℝ (Fin N))
    (x : EuclideanSpace ℝ (Fin N)) :
    queryResidual f x ∈ (Submodule.span ℝ (Set.range f))ᗮ := by
  unfold queryResidual
  rw [activeProjection_eq_starProjection]
  exact (Submodule.span ℝ (Set.range f)).sub_starProjection_mem_orthogonal x

/-- Active evaluations of a single Gaussian row. -/
def evaluations (b : Fin m → EuclideanSpace ℝ (Fin N))
    (g : EuclideanSpace ℝ (Fin N)) : Fin m → ℝ := fun j => ⟪b j, g⟫

@[fun_prop] theorem measurable_evaluations (b : Fin m → EuclideanSpace ℝ (Fin N)) :
    Measurable (evaluations b) := by
  unfold evaluations
  fun_prop

/-- All observed linear forms are independent of a form orthogonal to their span. -/
theorem evaluations_indep_orthogonal (K : Submodule ℝ (EuclideanSpace ℝ (Fin N)))
    (b : Fin m → EuclideanSpace ℝ (Fin N)) (hb : ∀ j, b j ∈ K)
    (v : EuclideanSpace ℝ (Fin N)) (hv : v ∈ Kᗮ) :
    IndepFun (evaluations b) (fun g => ⟪v, g⟫) (euclideanGaussian (ι := Fin N) 1) := by
  have hind := (orthogonal_projections_independent K).comp
    (measurable_evaluations b) (innerSL ℝ v).continuous.measurable
  have hleft : evaluations b ∘ K.starProjection = evaluations b := by
    funext g j
    dsimp [evaluations]
    rw [← K.inner_starProjection_left_eq_right, K.starProjection_eq_self_iff.mpr (hb j)]
  have hright : (fun g => ⟪v, g⟫) ∘ Kᗮ.starProjection = (fun g => ⟪v, g⟫) := by
    funext g
    dsimp
    rw [← Kᗮ.inner_starProjection_left_eq_right, Kᗮ.starProjection_eq_self_iff.mpr hv]
  change IndepFun (evaluations b ∘ K.starProjection)
    ((fun g => ⟪v, g⟫) ∘ Kᗮ.starProjection) _ at hind
  simpa only [hleft, hright] using hind

/-- The joint law is exactly the active law times the new scalar Gaussian. -/
theorem evaluations_pair_law (K : Submodule ℝ (EuclideanSpace ℝ (Fin N)))
    (b : Fin m → EuclideanSpace ℝ (Fin N)) (hb : ∀ j, b j ∈ K)
    (v : EuclideanSpace ℝ (Fin N)) (hv : v ∈ Kᗮ) :
    (euclideanGaussian (ι := Fin N) 1).map
      (fun g => (evaluations b g, ⟪v, g⟫)) =
      ((euclideanGaussian (ι := Fin N) 1).map (evaluations b)).prod
        (gaussianReal 0 (‖v‖^2).toNNReal) := by
  rw [(evaluations_indep_orthogonal K b hb v hv).map_prod_eq_prod_map_map
    (measurable_evaluations b).aemeasurable (by fun_prop), map_inner_eq_gaussian]

/-- A nonzero residual, normalized without any basis selection. -/
def normalizedQueryResidual (f : Fin m → EuclideanSpace ℝ (Fin N))
    (x : EuclideanSpace ℝ (Fin N)) : EuclideanSpace ℝ (Fin N) :=
  ‖queryResidual f x‖⁻¹ • queryResidual f x

theorem measurable_normalizedQueryResidual :
    Measurable (fun p : (Fin m → EuclideanSpace ℝ (Fin N)) ×
        EuclideanSpace ℝ (Fin N) => normalizedQueryResidual p.1 p.2) :=
  measurable_queryResidual.norm.inv.smul measurable_queryResidual

theorem norm_normalizedQueryResidual (f : Fin m → EuclideanSpace ℝ (Fin N))
    (x : EuclideanSpace ℝ (Fin N)) (h : queryResidual f x ≠ 0) :
    ‖normalizedQueryResidual f x‖ = 1 := by
  unfold normalizedQueryResidual
  simp [norm_smul, norm_inv, h]

theorem normalizedQueryResidual_mem_orthogonal (f : Fin m → EuclideanSpace ℝ (Fin N))
    (x : EuclideanSpace ℝ (Fin N)) :
    normalizedQueryResidual f x ∈ (Submodule.span ℝ (Set.range f))ᗮ :=
  Submodule.smul_mem _ _ (queryResidual_mem_orthogonal f x)

/-- For a fixed active set, the normalized unobserved scalar is standard normal
and independent of the complete vector of active evaluations. -/
theorem new_query_pair_law (b : Fin m → EuclideanSpace ℝ (Fin N))
    (x : EuclideanSpace ℝ (Fin N)) (h : queryResidual b x ≠ 0) :
    (euclideanGaussian (ι := Fin N) 1).map
      (fun g => (evaluations b g, ⟪normalizedQueryResidual b x, g⟫)) =
      ((euclideanGaussian (ι := Fin N) 1).map (evaluations b)).prod
        (gaussianReal 0 1) := by
  rw [evaluations_pair_law (Submodule.span ℝ (Set.range b)) b
    (fun j => Submodule.subset_span (Set.mem_range_self j))
    (normalizedQueryResidual b x) (normalizedQueryResidual_mem_orthogonal b x),
    norm_normalizedQueryResidual b x h]
  norm_num

/-- Exact independent-row block law. No conditional-Gaussian hypothesis is used:
the source measure is the finite product of actual standard Gaussian rows. -/
theorem new_query_matrix_pair_law (R : ℕ) (b : Fin m → EuclideanSpace ℝ (Fin N))
    (x : EuclideanSpace ℝ (Fin N)) (h : queryResidual b x ≠ 0) :
    (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)).map
      (fun g => ((fun i => evaluations b (g i)),
        (fun i => ⟪normalizedQueryResidual b x, g i⟫))) =
      (Measure.pi (fun _ : Fin R =>
        (euclideanGaussian (ι := Fin N) 1).map (evaluations b))).prod
        (Measure.pi (fun _ : Fin R => gaussianReal 0 1)) := by
  let G := euclideanGaussian (ι := Fin N) 1
  let F : EuclideanSpace ℝ (Fin N) → (Fin m → ℝ) × ℝ :=
    fun g => (evaluations b g, ⟪normalizedQueryResidual b x, g⟫)
  have hF : Measurable F := (measurable_evaluations b).prodMk (by fun_prop)
  letI : IsProbabilityMeasure (G.map F) := Measure.isProbabilityMeasure_map hF.aemeasurable
  letI : IsProbabilityMeasure (G.map (evaluations b)) :=
    Measure.isProbabilityMeasure_map (measurable_evaluations b).aemeasurable
  let e := MeasurableEquiv.arrowProdEquivProdArrow (Fin m → ℝ) ℝ (Fin R)
  have heq : (fun g : Fin R → EuclideanSpace ℝ (Fin N) =>
      ((fun i => evaluations b (g i)),
       (fun i => ⟪normalizedQueryResidual b x, g i⟫))) =
      e ∘ (fun g i => F (g i)) := rfl
  rw [heq, ← Measure.map_map e.measurable (by fun_prop)]
  rw [Measure.pi_map_pi (fun _ => hF.aemeasurable)]
  change (Measure.pi (fun _ : Fin R => G.map F)).map e = _
  have hrow : G.map F = (G.map (evaluations b)).prod (gaussianReal 0 1) :=
    new_query_pair_law b x h
  simp_rw [hrow]
  exact (measurePreserving_arrowProdEquivProdArrow (Fin m → ℝ) ℝ (Fin R)
    (fun _ => G.map (evaluations b)) (fun _ => gaussianReal 0 1)).map_eq


end NeuralGeneralization.RobustGaussianGeometry
