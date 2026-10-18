import NeuralGeneralization.RobustEntropyQueryKernel

/-! # Lifting zero-safe queries back to the complete original Gaussian rows -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal RealInnerProductSpace Classical

namespace NeuralGeneralization.RobustEntropy
open RobustGaussianGeometry
set_option maxHeartbeats 400000

variable {A : Type*} [MeasurableSpace A] {N M R : ℕ}
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
local notation "E" => EuclideanSpace ℝ (Fin N)

def augmentedQueryObservation
    (b : A → Fin M → E) (J : A → Finset (Fin M)) (i : Fin M)
    (p : A × ((Fin R → E) × (Fin R → ℝ))) : (Fin R → E) × (Fin R → ℝ) :=
  (rowProjection R (inputSpan (b p.1) (J p.1)) p.2.1,
    if queryResidual (maskedInputs (b p.1) (J p.1)) (b p.1 i) = 0 then p.2.2
    else fun j => ⟪normalizedQueryResidual (maskedInputs (b p.1) (J p.1)) (b p.1 i),p.2.1 j⟫)

theorem measurable_augmentedQueryObservation
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) :
    Measurable (augmentedQueryObservation (R := R) b J i) := by
  have hm : Measurable (fun p : A × ((Fin R → E) × (Fin R → ℝ)) => (p.1,p.2.1)) :=
    measurable_fst.prodMk measurable_snd.fst
  have hpair := (measurable_selected_query (R := R) b hb J hJ i).comp hm
  have hz : MeasurableSet {p : A × ((Fin R → E) × (Fin R → ℝ)) |
      queryResidual (maskedInputs (b p.1) (J p.1)) (b p.1 i) = 0} :=
    (((measurable_selected_residual b hb J hJ i).comp measurable_fst)
      (measurableSet_singleton 0))
  unfold augmentedQueryObservation
  exact hpair.fst.prodMk (Measurable.ite hz measurable_snd.snd hpair.snd)

/-- The genuine complete row field can always be retained: on the zero branch
only an independent dummy Gaussian is added, and its activation coefficient is
zero. Thus the query law is not an assumed conditional distribution. -/
theorem safeQueryKernel_augmented_law
    (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A → Finset (Fin M)) (hJ : Measurable J) (i : Fin M) (a : A) :
    ((κ a).prod (RobustCoupling.standardGaussianVector R)).map
      (fun p => augmentedQueryObservation b J i (a,p)) =
      safeQueryKernel κ b hb J hJ i a := by
  rw [safeQueryKernel_apply]
  split_ifs with hz
  · rw [activeQueryKernel_apply κ b hb J hJ]
    have hh := Measure.map_prod_map (κ a) (RobustCoupling.standardGaussianVector R)
      (measurable_rowProjection R (inputSpan (b a) (J a))) measurable_id
    simpa only [Measure.map_id,Measure.map_id',Prod.map_def,Function.id_def,augmentedQueryObservation,if_pos hz]
      using hh.symm
  · rw [pairQueryKernel_apply κ b hb J hJ i]
    have hp : ((κ a).prod (RobustCoupling.standardGaussianVector R)).map Prod.fst = κ a := by
      simp only [Measure.map_fst_prod,measure_univ,one_smul]
    have hh := congrArg (fun μ => μ.map (rowQuery R (inputSpan (b a) (J a))
      (normalizedQueryResidual (maskedInputs (b a) (J a)) (b a i)))) hp
    rw [Measure.map_map (measurable_rowQuery _ _ _) measurable_fst] at hh
    simpa only [Function.comp_def,rowQuery,augmentedQueryObservation,if_neg hz] using hh

omit [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))] in
/-- Exact active-plus-residual evaluation, including zero residual directions. -/
theorem query_inner_decomposition (f : Fin M → E) (x g : E) :
    ⟪x,g⟫ = ⟪x,activeProjection f g⟫ +
      ‖queryResidual f x‖ * ⟪normalizedQueryResidual f x,g⟫ := by
  have hr : ‖queryResidual f x‖ • normalizedQueryResidual f x = queryResidual f x := by
    unfold normalizedQueryResidual
    by_cases h : queryResidual f x = 0
    · simp [h]
    · rw [smul_smul, mul_inv_cancel₀ (norm_ne_zero_iff.mpr h),one_smul]
  have he : x = activeProjection f x + queryResidual f x := by
    unfold queryResidual
    abel
  have hp : ⟪activeProjection f x,g⟫ = ⟪x,activeProjection f g⟫ := by
    simp only [activeProjection_eq_starProjection]
    exact (Submodule.span ℝ (Set.range f)).inner_starProjection_left_eq_right x g
  calc
    ⟪x,g⟫ = ⟪activeProjection f x + queryResidual f x,g⟫ := congrArg (fun z => ⟪z,g⟫) he
    _ = ⟪activeProjection f x,g⟫+⟪queryResidual f x,g⟫ := inner_add_left _ _ _
    _ = _ := by
      have hir : ⟪queryResidual f x,g⟫ =
          ‖queryResidual f x‖ * ⟪normalizedQueryResidual f x,g⟫ := by
        calc
          _ = ⟪‖queryResidual f x‖ • normalizedQueryResidual f x,g⟫ :=
            congrArg (fun z => ⟪z,g⟫) hr.symm
          _ = _ := by simp only [inner_smul_left,RCLike.conj_to_real]
      rw [hp,hir]

/-- Decoding the augmented query reproduces every original preactivation. -/
theorem augmentedQueryObservation_evaluation
    (b : A → Fin M → E) (J : A → Finset (Fin M)) (i : Fin M)
    (a : A) (g : Fin R → E) (z : Fin R → ℝ) (j : Fin R) :
    ⟪b a i,(augmentedQueryObservation b J i (a,(g,z))).1 j⟫ +
      ‖queryResidual (maskedInputs (b a) (J a)) (b a i)‖ *
        (augmentedQueryObservation b J i (a,(g,z))).2 j = ⟪b a i,g j⟫ := by
  have hh := query_inner_decomposition (maskedInputs (b a) (J a)) (b a i) (g j)
  rw [activeProjection_eq_starProjection,span_maskedInputs] at hh
  unfold augmentedQueryObservation rowProjection
  split_ifs with hz
  · simpa only [hz,norm_zero,zero_mul,add_zero] using hh.symm
  · exact hh.symm

end NeuralGeneralization.RobustEntropy
