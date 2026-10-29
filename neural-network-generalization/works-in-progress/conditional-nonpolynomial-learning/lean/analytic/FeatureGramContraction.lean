import FeatureGramGluing

/-! An exact Gram identification extends to a contraction on the ambient
Hilbert space by discarding the orthogonal complement of the source span. -/
noncomputable section
open scoped BigOperators InnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {ι E F : Type*} [Fintype ι]
variable [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [NormedAddCommGroup F] [InnerProductSpace ℝ F]

theorem equal_gram_contraction (u : ι → E) (v : ι → F)
    (hgram : ∀i j,inner ℝ (v i) (v j)=inner ℝ (u i) (u j)) :
    ∃T : E →L[ℝ] F, ‖T‖≤1 ∧ ∀i,T (u i)=v i := by
  classical
  let f := Fintype.linearCombination ℝ u
  let g := Fintype.linearCombination ℝ v
  have hh := linearCombination_inner_of_gram_eq u v hgram
  let U := gramRangeIsometry f g hh
  let T : E →L[ℝ] F := U.toContinuousLinearMap.comp f.range.orthogonalProjectionOnto
  refine ⟨T,?_,?_⟩
  · apply T.opNorm_le_bound (by norm_num)
    intro x
    change ‖U (f.range.orthogonalProjectionOnto x)‖≤1*‖x‖
    rw [U.norm_map,one_mul]
    exact f.range.norm_orthogonalProjectionOnto_apply_le x
  · intro i
    let a : ι → ℝ := Pi.single i 1
    have hfa : f a=u i := by simp [f,a]
    have hga : g a=v i := by simp [g,a]
    have hproj : f.range.orthogonalProjectionOnto (f a)=
        ⟨f a,LinearMap.mem_range_self f a⟩ :=
      Submodule.orthogonalProjectionOnto_mem_subspace_eq_self
        (⟨f a,LinearMap.mem_range_self f a⟩ : f.range)
    change U (f.range.orthogonalProjectionOnto (u i))=v i
    rw [← hfa,hproj]
    exact (gramRangeIsometry_image f g hh a).trans hga

#print axioms equal_gram_contraction
end ConditionalNonpolynomial.Analytic
