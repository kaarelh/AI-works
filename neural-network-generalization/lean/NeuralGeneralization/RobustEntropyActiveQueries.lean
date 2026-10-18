import NeuralGeneralization.RobustEntropyProjection

/-! # Actual finite input queries and their conditional Gaussian entropy cost -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal RealInnerProductSpace BigOperators

set_option maxHeartbeats 400000
namespace NeuralGeneralization.RobustEntropy
open RobustGaussianGeometry

variable {N M : ℕ}
local notation "E" => EuclideanSpace ℝ (Fin N)

def maskedInputs (b : Fin M → E) (S : Finset (Fin M)) : Fin M → E :=
  fun i => if i ∈ S then b i else 0

def inputSpan (b : Fin M → E) (S : Finset (Fin M)) : Submodule ℝ E :=
  Submodule.span ℝ (b '' (S : Set (Fin M)))

theorem span_maskedInputs (b : Fin M → E) (S : Finset (Fin M)) :
    Submodule.span ℝ (Set.range (maskedInputs b S)) = inputSpan b S := by
  classical
  apply le_antisymm
  · apply Submodule.span_le.mpr
    rintro _ ⟨i,rfl⟩
    by_cases hi : i ∈ S
    · simpa [maskedInputs,hi,inputSpan] using
        (Submodule.subset_span (show b i ∈ b '' (S : Set (Fin M)) from ⟨i,hi,rfl⟩))
    · simp [maskedInputs,hi]
  · apply Submodule.span_le.mpr
    rintro _ ⟨i,hi,rfl⟩
    apply Submodule.subset_span
    exact ⟨i, by simpa only [maskedInputs, if_pos (show i ∈ S from hi)]⟩

theorem inputSpan_insert (b : Fin M → E) (S : Finset (Fin M)) (i : Fin M) :
    inputSpan b (insert i S) = inputSpan b S ⊔ Submodule.span ℝ {b i} := by
  classical
  simp [inputSpan, Finset.coe_insert, Set.image_insert_eq, Submodule.span_insert, sup_comm]

@[fun_prop] theorem measurable_maskedInputs (S : Finset (Fin M)) :
    Measurable (fun b : Fin M → E => maskedInputs b S) := by
  classical
  apply measurable_pi_lambda
  intro i
  by_cases hi : i ∈ S
  · simpa only [maskedInputs,if_pos hi] using (measurable_pi_apply i : Measurable (fun b : Fin M → E => b i))
  · simp only [maskedInputs,if_neg hi]
    exact measurable_const

/-- Projection onto an input-dependent active span is measurably defined even
when its rank changes. -/
theorem measurable_inputSpan_projection (S : Finset (Fin M)) :
    Measurable (fun p : (Fin M → E) × E => (inputSpan p.1 S).starProjection p.2) := by
  have h := (measurable_activeProjection (N := N) (m := M)).comp
    (((measurable_maskedInputs (N := N) S).comp measurable_fst).prodMk measurable_snd)
  change Measurable (fun p : (Fin M → E) × E => activeProjection (maskedInputs p.1 S) p.2) at h
  simpa only [activeProjection_eq_starProjection,span_maskedInputs] using h

def inputRowProjection (R : ℕ) (S : Finset (Fin M)) :
    (Fin M → E) × (Fin R → E) → (Fin R → E) :=
  fun p => rowProjection R (inputSpan p.1 S) p.2

theorem measurable_inputRowProjection (R : ℕ) (S : Finset (Fin M)) :
    Measurable (inputRowProjection (N := N) R S) := by
  unfold inputRowProjection rowProjection
  apply measurable_pi_lambda
  intro j
  have hm : Measurable (fun p : (Fin M → E) × (Fin R → E) => (p.1,p.2 j)) :=
    measurable_fst.prodMk ((measurable_pi_apply j).comp measurable_snd)
  have hh := (measurable_inputSpan_projection (N := N) S).comp hm
  simpa only [Function.comp_def] using hh

/-- Removing a vector's old projection does not change the span extension. -/
theorem sup_span_residual (K : Submodule ℝ E) (x : E) :
    K ⊔ Submodule.span ℝ {x-K.starProjection x} = K ⊔ Submodule.span ℝ {x} := by
  apply le_antisymm
  · apply sup_le le_sup_left
    apply Submodule.span_le.mpr
    intro y hy
    have hy' : y = x-K.starProjection x := Set.mem_singleton_iff.mp hy
    subst y
    exact Submodule.sub_mem _
      (Submodule.mem_sup_right (Submodule.subset_span (Set.mem_singleton x)))
      (Submodule.mem_sup_left (K.starProjection_apply_mem x))
  · apply sup_le le_sup_left
    apply Submodule.span_le.mpr
    intro y hy
    have hy' : y = x := Set.mem_singleton_iff.mp hy
    subst y
    have hh : (x-K.starProjection x)+K.starProjection x ∈
        K ⊔ Submodule.span ℝ {x-K.starProjection x} :=
      Submodule.add_mem _
        (Submodule.mem_sup_right (Submodule.subset_span (Set.mem_singleton _)))
        (Submodule.mem_sup_left (K.starProjection_apply_mem x))
    change x ∈ K ⊔ Submodule.span ℝ {x-K.starProjection x}
    simpa only [sub_add_cancel] using hh

theorem inputSpan_insert_residual (b : Fin M → E) (S : Finset (Fin M)) (i : Fin M)
    (h : queryResidual (maskedInputs b S) (b i) ≠ 0) :
    inputSpan b (insert i S) = inputSpan b S ⊔
      Submodule.span ℝ {normalizedQueryResidual (maskedInputs b S) (b i)} := by
  rw [inputSpan_insert]
  unfold normalizedQueryResidual
  rw [Submodule.span_singleton_smul_eq
    (isUnit_iff_ne_zero.mpr (inv_ne_zero (norm_ne_zero_iff.mpr h)))]
  unfold queryResidual
  rw [activeProjection_eq_starProjection,span_maskedInputs,sup_span_residual]

/-- Conditional Gaussian cost for a genuine query from a finite input set. -/
theorem input_query_conditional_cost (R : ℕ) (Q : Measure (Fin R → E))
    [IsProbabilityMeasure Q] (hfin : klDiv Q (rowGaussian R N) ≠ ∞)
    (b : Fin M → E) (S : Finset (Fin M)) (i : Fin M)
    (h : queryResidual (maskedInputs b S) (b i) ≠ 0) (δ : ℝ)
    (hinc :
      (klDiv (Q.map (rowProjection R (inputSpan b (insert i S))))
        ((rowGaussian R N).map (rowProjection R (inputSpan b (insert i S))))).toReal -
      (klDiv (Q.map (rowProjection R (inputSpan b S)))
        ((rowGaussian R N).map (rowProjection R (inputSpan b S)))).toReal ≤ δ) :
    klDiv (Q.map (rowQuery R (inputSpan b S)
      (normalizedQueryResidual (maskedInputs b S) (b i))))
      ((Q.map (rowProjection R (inputSpan b S))).prod
        (Measure.pi fun _ : Fin R => gaussianReal 0 1)) ≤ ENNReal.ofReal δ := by
  apply row_query_conditional_cost R Q hfin _ _ _
    (norm_normalizedQueryResidual _ _ h) δ
  · rwa [inputSpan_insert_residual b S i h] at hinc
  · simpa only [span_maskedInputs] using normalizedQueryResidual_mem_orthogonal
      (maskedInputs b S) (b i)

/-- The complete finite-query selection step for a genuine conditional Gaussian
row law. Its measurable input-dependent projection, query budget, and remaining
conditional entropy are all consequences, with no entropy oracle assumption. -/
theorem exists_measurable_active_queries
    {A : Type*} [MeasurableSpace A] [MeasurableSpace (Finset (Fin M))]
    (R : ℕ) (κ : Kernel A (Fin R → E)) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b) (δ : ℝ) (hδ : 0 ≤ δ) :
    ∃ J : A → Finset (Fin M), Measurable J ∧
      (∀ a, klDiv (κ a) (rowGaussian R N) ≠ ∞ →
        δ*(J a).card ≤ (klDiv (κ a) (rowGaussian R N)).toReal) ∧
      (∀ a, klDiv (κ a) (rowGaussian R N) ≠ ∞ →
        ∀ i, queryResidual (maskedInputs (b a) (J a)) (b a i) ≠ 0 →
        klDiv ((κ a).map (rowQuery R (inputSpan (b a) (J a))
          (normalizedQueryResidual (maskedInputs (b a) (J a)) (b a i))))
          (((κ a).map (rowProjection R (inputSpan (b a) (J a)))).prod
            (Measure.pi fun _ : Fin R => gaussianReal 0 1)) ≤ ENNReal.ofReal δ) := by
  let F : Finset (Fin M) → A × (Fin R → E) → (Fin R → E) :=
    fun S p => rowProjection R (inputSpan (b p.1) S) p.2
  have hF (S : Finset (Fin M)) : Measurable (F S) := by
    have hm : Measurable (fun p : A × (Fin R → E) => (b p.1,p.2)) :=
      (hb.comp measurable_fst).prodMk measurable_snd
    have hh := (measurable_inputRowProjection (N := N) R S).comp hm
    simpa only [Function.comp_def, inputRowProjection, F] using hh
  obtain ⟨J,hJ,hbudget,hstop⟩ := exists_measurable_entropy_queries
    κ (Kernel.const A (rowGaussian R N)) F hF δ hδ
  refine ⟨J,hJ,?_,?_⟩
  · simpa only [Kernel.const_apply] using hbudget
  · intro a ha i hi
    apply input_query_conditional_cost R (κ a) ha (b a) (J a) i hi δ
    simpa only [queryEntropy, Kernel.const_apply, F] using hstop a i

end NeuralGeneralization.RobustEntropy
