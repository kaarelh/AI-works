import AnchorQueryFeatures

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory Set
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic

variable {X E F G : Type*} [Fintype X] [DecidableEq X]
variable [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [NormedAddCommGroup F] [InnerProductSpace ℝ F]
variable [NormedAddCommGroup G] [InnerProductSpace ℝ G]

/-- A coupling of one query and its anchors can be extended to the entire
endpoint feature families. No distances between other paired queries are
claimed. The resulting common ambient dimension is at most twice |X|. -/
theorem extend_anchor_query_coupling (P : X → E) (Q : X → F) (S : Finset X) (x : X)
    (u v : S ⊕ Unit → G)
    (hu : ∀i j,inner ℝ (u i) (u j)=
      inner ℝ (P (anchorQueryIndex S x i)) (P (anchorQueryIndex S x j)))
    (hv : ∀i j,inner ℝ (v i) (v j)=
      inner ℝ (Q (anchorQueryIndex S x i)) (Q (anchorQueryIndex S x j)))
    (hanchor : ∀s:S,u (.inl s)=v (.inl s)) {ε : ℝ}
    (herror : ‖u (.inr ())-v (.inr ())‖≤ε) :
    ∃U V : X → EuclideanSpace ℝ (X ⊕ X),
      (∀i j,inner ℝ (U i) (U j)=inner ℝ (P i) (P j)) ∧
      (∀i j,inner ℝ (V i) (V j)=inner ℝ (Q i) (Q j)) ∧
      (∀s∈S,U s=V s) ∧ ‖U x-V x‖≤ε := by
  obtain ⟨PE,GE,hP⟩ := equal_gram_common_embedding
    (fun i => P (anchorQueryIndex S x i)) u hu
  obtain ⟨QF,HG,hQ⟩ := equal_gram_common_embedding
    (fun i => Q (anchorQueryIndex S x i)) (fun i => GE (v i)) (by
      intro i j
      rw [GE.inner_map_map,hv])
  let U₀ : X → WithLp 2 ((WithLp 2 (G × E)) × F) := fun i => HG (PE (P i))
  let V₀ : X → WithLp 2 ((WithLp 2 (G × E)) × F) := fun i => QF (Q i)
  have hanchors : ∀s∈S,U₀ s=V₀ s := by
    intro s hs
    have hp := hP (.inl ⟨s,hs⟩)
    have hq := hQ (.inl ⟨s,hs⟩)
    change PE (P s)=GE (u (.inl ⟨s,hs⟩)) at hp
    change QF (Q s)=HG (GE (v (.inl ⟨s,hs⟩))) at hq
    simp only [U₀,V₀,hp,hanchor,hq]
  have hdist : ‖U₀ x-V₀ x‖≤ε := by
    have hp := hP (.inr ())
    have hq := hQ (.inr ())
    change PE (P x)=GE (u (.inr ())) at hp
    change QF (Q x)=HG (GE (v (.inr ()))) at hq
    simp only [U₀,V₀,hp,hq,← HG.map_sub,HG.norm_map,← GE.map_sub,GE.norm_map]
    exact herror
  obtain ⟨U,V,hU,hV,hcross,hd⟩ := compress_feature_pair U₀ V₀
  refine ⟨U,V,?_,?_,?_,?_⟩
  · intro i j
    rw [hU]
    exact (HG.inner_map_map _ _).trans (PE.inner_map_map _ _)
  · intro i j
    rw [hV]
    exact QF.inner_map_map _ _
  · intro s hs
    apply sub_eq_zero.mp
    apply norm_eq_zero.mp
    rw [hd,hanchors s hs,sub_self,norm_zero]
  · rw [hd]
    exact hdist

#print axioms extend_anchor_query_coupling
end ConditionalNonpolynomial.Analytic
