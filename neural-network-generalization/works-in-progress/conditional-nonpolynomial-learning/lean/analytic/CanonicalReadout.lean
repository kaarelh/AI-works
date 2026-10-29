import CanonicalQueryProgram
import JointEntropyReadoutAnchors

noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic

variable {X E F : Type*} [Fintype X] [DecidableEq X]
variable [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable [NormedAddCommGroup F] [InnerProductSpace ℝ F]

lemma sum_smul_norm_of_gram {J : Type*} [Fintype J]
    (u : J → E) (v : J → F) (a : J → ℝ)
    (hgram : ∀i j,inner ℝ (v i) (v j)=inner ℝ (u i) (u j)) :
    ‖∑i,a i • v i‖=‖∑i,a i • u i‖ := by
  apply (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  rw [← real_inner_self_eq_norm_sq,← real_inner_self_eq_norm_sq]
  simpa only [Fintype.linearCombination_apply] using linearCombination_inner_of_gram_eq u v hgram a a

/-- The readout is the transported projection onto the anchor span. The same
readout works at every query, despite using separate query couplings. -/
theorem transport_anchored_readout (P : X → E) (B : X → F) (b : E) (S : Finset X)
    {ρ ε : ℝ} (hε : 0≤ε)
    (hanchors : ∀s∈S,∀t∈S,inner ℝ (B s) (B t)=inner ℝ (P s) (P t))
    (hclose : ∀x,QueryFeatureClose P B S x ε)
    (hproj : ∀x,|inner ℝ (b-(featureSpan P S).starProjection b) (P x)|≤ρ) :
    ∃c : F,‖c‖≤‖b‖ ∧
      ∀x,|inner ℝ b (P x)-inner ℝ c (B x)|≤ρ+‖b‖*ε := by
  let b₀ := (featureSpan P S).starProjection b
  have hmem : b₀∈Submodule.span ℝ (P '' (S : Set X)) :=
    (featureSpan P S).starProjection_apply_mem b
  obtain ⟨a,ha⟩ := (Submodule.mem_span_image_finset_iff_exists_fun ℝ).mp hmem
  let c := ∑s:S,a s • B s
  have hb₀ : ‖b₀‖≤‖b‖ := (featureSpan P S).norm_starProjection_apply_le b
  have hc : ‖c‖=‖b₀‖ := by
    have hh := sum_smul_norm_of_gram (fun s:S => P s) (fun s:S => B s) a
      (fun s t => hanchors s s.property t t.property)
    rw [ha] at hh
    exact hh
  refine ⟨c,hc.le.trans hb₀,?_⟩
  intro x
  obtain ⟨U,V,hU,hV,hanchor,hquery⟩ := hclose x
  let u := ∑s:S,a s • U s
  let v := ∑s:S,a s • V s
  have huv : u=v := by
    apply Finset.sum_congr rfl
    intro s hs
    rw [hanchor s s.property]
  have hu : ‖u‖=‖b₀‖ := by
    have hh := sum_smul_norm_of_gram (fun s:S => P s) (fun s:S => U s) a
      (fun s t => hU s t)
    rw [ha] at hh
    exact hh
  have houtP : inner ℝ u (U x)=inner ℝ b₀ (P x) := by
    rw [← ha]
    change inner ℝ (∑s:S,a s • U s) (U x)=_
    simp only [sum_inner,real_inner_smul_left,hU]
  have houtB : inner ℝ v (V x)=inner ℝ c (B x) := by
    change inner ℝ (∑s:S,a s • V s) (V x)=inner ℝ (∑s:S,a s • B s) (B x)
    simp only [sum_inner,real_inner_smul_left,hV]
  have hdiff : |inner ℝ b₀ (P x)-inner ℝ c (B x)|≤‖b‖*ε := by
    rw [← houtP,← houtB,← huv,← inner_sub_right]
    calc
      _ ≤ ‖u‖*‖U x-V x‖ := abs_real_inner_le_norm _ _
      _ ≤ ‖b‖*ε := mul_le_mul (hu.le.trans hb₀) hquery (norm_nonneg _) (norm_nonneg _)
  have heq : inner ℝ b (P x)-inner ℝ c (B x)=
      inner ℝ (b-b₀) (P x)+(inner ℝ b₀ (P x)-inner ℝ c (B x)) := by
    rw [inner_sub_left]
    ring
  rw [heq]
  exact (abs_add_le _ _).trans (add_le_add (hproj x) hdiff)

#print axioms transport_anchored_readout
end ConditionalNonpolynomial.Analytic
