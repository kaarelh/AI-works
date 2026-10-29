import FeatureGramGluing
import HilbertCovarianceRepair

/-! Compose querywise Hilbert couplings without changing the common anchors.
Only the Gram matrix of the anchors and the middle query is required. -/
noncomputable section
open scoped BigOperators InnerProductSpace
namespace ConditionalNonpolynomial.Analytic

variable {J E F : Type*} [Fintype J]
variable [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [NormedAddCommGroup F] [InnerProductSpace ℝ F]

def anchoredFamily (a : J → E) (u : E) : J ⊕ Unit → E :=
  Sum.elim a (fun _ => u)

/-- Glue along the actual middle query and every anchor. This does not assert
equality of Gram entries between two different queries. -/
theorem glue_anchored_query (a : J → E) (b : J → F)
    (u v : E) (v' w : F)
    (hgram : ∀ i j, inner ℝ (anchoredFamily b v' i) (anchoredFamily b v' j) =
      inner ℝ (anchoredFamily a v i) (anchoredFamily a v j))
    {δ η : ℝ} (huv : ‖u-v‖ ≤ δ) (hvw : ‖v'-w‖ ≤ η) :
    ∃ U : E →ₗᵢ[ℝ] WithLp 2 (F × E),
      ∃ W : F →ₗᵢ[ℝ] WithLp 2 (F × E),
        (∀ j, U (a j) = W (b j)) ∧ U v = W v' ∧ ‖U u-W w‖ ≤ δ+η := by
  obtain ⟨U,W,heq⟩ := equal_gram_common_embedding
    (anchoredFamily a v) (anchoredFamily b v') hgram
  have hmid : U v = W v' := heq (.inr ())
  refine ⟨U,W,(fun j => heq (.inl j)),hmid,?_⟩
  calc
    ‖U u-W w‖ ≤ ‖U u-U v‖+‖U v-W w‖ := by
      simpa only [dist_eq_norm] using dist_triangle (U u) (U v) (W w)
    _ = ‖u-v‖+‖v'-w‖ := by
      rw [← U.map_sub,U.norm_map,hmid,← W.map_sub,W.norm_map]
    _ ≤ δ+η := add_le_add huv hvw

theorem anchoredFamily_gram_eq (a : J → E) (b : J → F) (v : E) (v' : F)
    (haa : ∀ i j, inner ℝ (b i) (b j) = inner ℝ (a i) (a j))
    (hav : ∀ i, inner ℝ (b i) v' = inner ℝ (a i) v)
    (hvv : ‖v'‖^2 = ‖v‖^2) :
    ∀ i j, inner ℝ (anchoredFamily b v' i) (anchoredFamily b v' j) =
      inner ℝ (anchoredFamily a v i) (anchoredFamily a v j) := by
  rintro (i | ⟨⟩) (j | ⟨⟩)
  · exact haa i j
  · exact hav i
  · change inner ℝ v' (b j) = inner ℝ v (a j)
    calc
      inner ℝ v' (b j) = inner ℝ (b j) v' := real_inner_comm _ _
      _ = inner ℝ (a j) v := hav j
      _ = inner ℝ v (a j) := real_inner_comm _ _
  · change inner ℝ v' v' = inner ℝ v v
    simpa only [real_inner_self_eq_norm_sq] using hvv

/-- Fixed finite-dimensional endpoint coupling, preserving all Gram entries
within either endpoint family and the common anchors exactly. -/
theorem glue_anchored_query_finite (a : J → E) (b : J → F)
    (u v : E) (v' w : F)
    (hgram : ∀ i j, inner ℝ (anchoredFamily b v' i) (anchoredFamily b v' j) =
      inner ℝ (anchoredFamily a v i) (anchoredFamily a v j))
    {δ η : ℝ} (huv : ‖u-v‖ ≤ δ) (hvw : ‖v'-w‖ ≤ η) :
    ∃ A B : J ⊕ Unit → EuclideanSpace ℝ ((J ⊕ Unit) ⊕ (J ⊕ Unit)),
      (∀ i j, inner ℝ (A i) (A j) =
        inner ℝ (anchoredFamily a u i) (anchoredFamily a u j)) ∧
      (∀ i j, inner ℝ (B i) (B j) =
        inner ℝ (anchoredFamily b w i) (anchoredFamily b w j)) ∧
      (∀ j, A (.inl j) = B (.inl j)) ∧
      ‖A (.inr ())-B (.inr ())‖ ≤ δ+η := by
  classical
  obtain ⟨U,W,hanchor,hmid,herror⟩ := glue_anchored_query a b u v v' w hgram huv hvw
  obtain ⟨A,B,hA,hB,hcross,hdist⟩ := compress_feature_pair
    (fun i => U (anchoredFamily a u i)) (fun i => W (anchoredFamily b w i))
  refine ⟨A,B,?_,?_,?_,?_⟩
  · intro i j
    rw [hA,U.inner_map_map]
  · intro i j
    rw [hB,W.inner_map_map]
  · intro j
    apply sub_eq_zero.mp
    apply norm_eq_zero.mp
    rw [hdist]
    change ‖U (a j)-W (b j)‖=0
    rw [hanchor,sub_self,norm_zero]
  · rw [hdist]
    exact herror

#print axioms glue_anchored_query_finite
end ConditionalNonpolynomial.Analytic
