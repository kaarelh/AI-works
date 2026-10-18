import NeuralGeneralization.RobustGaussianGeometry
import NeuralGeneralization.GaussianFieldCovariance

/-! # Actual diagonal Gaussian law and energy of zero-safe active coordinates -/
noncomputable section
open MeasureTheory ProbabilityTheory InnerProductSpace Matrix WithLp
open scoped BigOperators RealInnerProductSpace NNReal
namespace NeuralGeneralization.RobustGaussianGeometry
open GaussianOrthogonal
variable {N q R : ℕ}

/-- Zero columns are retained, avoiding rank-dependent ambient types. -/
def activeVariance (b : Fin q → EuclideanSpace ℝ (Fin N)) (j : Fin q) : ℝ≥0 :=
  (‖gramSchmidtNormed ℝ b j‖^2).toNNReal

theorem gramSchmidtNormed_norm_zero_or_one
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (j : Fin q) :
    ‖gramSchmidtNormed ℝ b j‖ = 0 ∨ ‖gramSchmidtNormed ℝ b j‖ = 1 := by
  by_cases h : gramSchmidtNormed ℝ b j = 0
  · exact Or.inl (by simp [h])
  · exact Or.inr (gramSchmidtNormed_unit_length' h)

theorem activeVariance_le_one (b : Fin q → EuclideanSpace ℝ (Fin N)) (j : Fin q) :
    activeVariance b j ≤ 1 := by
  rcases gramSchmidtNormed_norm_zero_or_one b j with h | h <;> simp [activeVariance, h]

theorem activeVariance_zero_or_one (b : Fin q → EuclideanSpace ℝ (Fin N)) (j : Fin q) :
    activeVariance b j = 0 ∨ activeVariance b j = 1 := by
  rcases gramSchmidtNormed_norm_zero_or_one b j with h | h <;> simp [activeVariance, h]

theorem active_inner_eq_diagonal (b : Fin q → EuclideanSpace ℝ (Fin N)) (j k : Fin q) :
    ⟪gramSchmidtNormed ℝ b j, gramSchmidtNormed ℝ b k⟫ =
      if j = k then ‖gramSchmidtNormed ℝ b j‖^2 else 0 := by
  split_ifs with h
  · subst k
    exact real_inner_self_eq_norm_sq _
  · simp [gramSchmidtNormed, inner_smul_left, inner_smul_right, gramSchmidt_orthogonal ℝ b h]

/-- The full q-vector has independent Gaussian coordinates, some exactly zero. -/
theorem active_coordinates_law (b : Fin q → EuclideanSpace ℝ (Fin N)) :
    (euclideanGaussian (ι := Fin N) 1).map (evaluations (gramSchmidtNormed ℝ b)) =
      Measure.pi (fun j : Fin q => gaussianReal 0 (activeVariance b j)) := by
  let A : Fin q → Fin N → ℝ := fun j i => gramSchmidtNormed ℝ b j i
  let B : Fin q → Fin q → ℝ := fun j k => if j = k then ‖gramSchmidtNormed ℝ b j‖ else 0
  have heq : evaluations (gramSchmidtNormed ℝ b) ∘ toLp 2 = FiniteDifferential.fieldLinear A := by
    funext x j
    simp [evaluations, A, FiniteDifferential.fieldLinear_apply,
      EuclideanSpace.inner_eq_star_dotProduct, dotProduct, mul_comm]
  have hg : ∀ j k, GaussianAngularPrice.gram A j k = GaussianAngularPrice.gram B j k := by
    intro j k
    have hinner := active_inner_eq_diagonal b j k
    have hA : GaussianAngularPrice.gram A j k =
        ⟪gramSchmidtNormed ℝ b j, gramSchmidtNormed ℝ b k⟫ := by
      simp [A, GaussianAngularPrice.gram, EuclideanSpace.inner_eq_star_dotProduct, dotProduct, mul_comm]
    rw [hA, hinner]
    by_cases h : j = k
    · subst k
      simp [GaussianAngularPrice.gram, B, pow_two]
    · simp [GaussianAngularPrice.gram, B, h]
  unfold euclideanGaussian
  rw [Measure.map_map (measurable_evaluations _) (WithLp.measurable_toLp 2 (Fin N → ℝ)), heq]
  change GaussianFieldTilt.fieldLaw A = _
  rw [GaussianFieldCovariance.fieldLaw_eq_of_gram_eq A B hg]
  have hB : (FiniteDifferential.fieldLinear B : (Fin q → ℝ) → (Fin q → ℝ)) =
      fun x => fun j => ‖gramSchmidtNormed ℝ b j‖ * x j := by
    funext x j
    simp [FiniteDifferential.fieldLinear_apply, B]
  unfold GaussianFieldTilt.fieldLaw GaussianAngularFields.standardLaw
  rw [hB, Measure.pi_map_pi (fun _ => by fun_prop)]
  congr 1
  funext j
  rw [gaussianReal_map_const_mul]
  simp [activeVariance, Real.toNNReal_of_nonneg (sq_nonneg _)]

/-- Active coordinate squared norm is exactly projected-row energy. -/
theorem active_energy_eq_projection (b : Fin q → EuclideanSpace ℝ (Fin N))
    (g : EuclideanSpace ℝ (Fin N)) :
    (∑ j, (evaluations (gramSchmidtNormed ℝ b) g j)^2) = ‖activeProjection b g‖^2 := by
  have h := (Submodule.span ℝ (Set.range b)).re_inner_starProjection_eq_normSq g
  rw [← activeProjection_eq_starProjection] at h
  change ⟪activeProjection b g, g⟫ = _ at h
  have hn : ‖(Submodule.span ℝ (Set.range b)).orthogonalProjectionOnto g‖ =
      ‖activeProjection b g‖ := by
    rw [activeProjection_eq_starProjection]
    rfl
  rw [hn] at h
  rw [← h]
  simp [activeProjection, evaluations, sum_inner, inner_smul_left, pow_two]

/-- Flattening a finite product of finite products preserves the actual product measure. -/
theorem map_flatten_pi (v : Fin R → Fin q → ℝ≥0) :
    (Measure.pi (fun i : Fin R => Measure.pi (fun j : Fin q => gaussianReal 0 (v i j)))).map
      (fun x : Fin R → Fin q → ℝ => fun ij : Fin R × Fin q => x ij.1 ij.2) =
      Measure.pi (fun ij : Fin R × Fin q => gaussianReal 0 (v ij.1 ij.2)) := by
  apply (Measure.pi_eq fun s hs => ?_).symm
  rw [Measure.map_apply (by fun_prop) (MeasurableSet.univ_pi hs)]
  have heq : (fun x : Fin R → Fin q → ℝ => fun ij : Fin R × Fin q => x ij.1 ij.2) ⁻¹'
      Set.univ.pi s = Set.univ.pi (fun i => Set.univ.pi (fun j => s (i,j))) := by
    ext x
    simp [Set.mem_pi, Prod.forall]
  rw [heq, Measure.pi_pi]
  simp_rw [Measure.pi_pi]
  simp only [Fintype.prod_prod_type]

/-- Every active matrix entry is an independent Gaussian of variance 0 or 1.
The total number of coordinates is R*q, irrespective of ambient width N. -/
theorem active_matrix_coordinates_law (R : ℕ) (b : Fin q → EuclideanSpace ℝ (Fin N)) :
    (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)).map
      (fun x => fun ij : Fin R × Fin q =>
        evaluations (gramSchmidtNormed ℝ b) (x ij.1) ij.2) =
      Measure.pi (fun ij : Fin R × Fin q => gaussianReal 0 (activeVariance b ij.2)) := by
  let F := evaluations (gramSchmidtNormed ℝ b)
  have hF : Measurable F := measurable_evaluations _
  letI : IsProbabilityMeasure ((euclideanGaussian (ι := Fin N) 1).map F) :=
    Measure.isProbabilityMeasure_map hF.aemeasurable
  have heq : (fun x : Fin R → EuclideanSpace ℝ (Fin N) => fun ij : Fin R × Fin q =>
      F (x ij.1) ij.2) =
      (fun y : Fin R → Fin q → ℝ => fun ij : Fin R × Fin q => y ij.1 ij.2) ∘
        (fun x i => F (x i)) := rfl
  rw [heq, ← Measure.map_map (by fun_prop) (by fun_prop),
    Measure.pi_map_pi (fun _ => hF.aemeasurable)]
  change (Measure.pi (fun _ : Fin R =>
    (euclideanGaussian (ι := Fin N) 1).map (evaluations (gramSchmidtNormed ℝ b)))).map _ = _
  simp_rw [active_coordinates_law]
  exact map_flatten_pi (fun _ => activeVariance b)

/-- Both the covariance entries and active coordinates vary measurably with
parameter-dependent input features, including changing rank. -/
theorem measurable_activeVariance (j : Fin q) :
    Measurable (fun b : Fin q → EuclideanSpace ℝ (Fin N) => activeVariance b j) :=
  ((measurable_gramSchmidtNormed j).norm.pow_const 2).real_toNNReal

theorem measurable_active_coordinates :
    Measurable (fun p : (Fin q → EuclideanSpace ℝ (Fin N)) × EuclideanSpace ℝ (Fin N) =>
      evaluations (gramSchmidtNormed ℝ p.1) p.2) := by
  apply measurable_pi_lambda
  intro j
  have hg : Measurable (fun p : (Fin q → EuclideanSpace ℝ (Fin N)) × EuclideanSpace ℝ (Fin N) =>
      gramSchmidtNormed ℝ p.1 j) :=
    (measurable_gramSchmidtNormed j).comp measurable_fst
  exact continuous_inner.measurable.comp (hg.prodMk measurable_snd)

theorem measurable_active_matrix_coordinates :
    Measurable (fun p : (Fin q → EuclideanSpace ℝ (Fin N)) ×
        (Fin R → EuclideanSpace ℝ (Fin N)) => fun ij : Fin R × Fin q =>
      evaluations (gramSchmidtNormed ℝ p.1) (p.2 ij.1) ij.2) := by
  apply measurable_pi_lambda
  intro ij
  exact (measurable_pi_apply ij.2).comp
    (measurable_active_coordinates.comp
      (measurable_fst.prodMk ((measurable_pi_apply ij.1).comp measurable_snd)))

theorem active_matrix_energy_eq_projection
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (X : Fin R → EuclideanSpace ℝ (Fin N)) :
    (∑ ij : Fin R × Fin q, (evaluations (gramSchmidtNormed ℝ b) (X ij.1) ij.2)^2) =
      ∑ i : Fin R, ‖activeProjection b (X i)‖^2 := by
  rw [Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro i hi
  exact active_energy_eq_projection b (X i)


end NeuralGeneralization.RobustGaussianGeometry
