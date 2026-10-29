import CovarianceFeatureRepair
import FeatureGramGluing
import Mathlib.Analysis.InnerProductSpace.GramMatrix
import Mathlib.Tactic.Ring

open scoped BigOperators InnerProductSpace Matrix
open Matrix
namespace ConditionalNonpolynomial.Analytic

variable {ι E : Type*} [Fintype ι] [DecidableEq ι]
variable [NormedAddCommGroup E] [InnerProductSpace ℝ E]

noncomputable def matrixRowFeature (F : Matrix ι ι ℝ) (i : ι) : EuclideanSpace ℝ ι :=
  WithLp.toLp 2 (F i)

omit [DecidableEq ι] in
lemma matrixRowFeature_inner (F : Matrix ι ι ℝ) (i j : ι) :
    inner ℝ (matrixRowFeature F i) (matrixRowFeature F j) = ∑ k, F i k*F j k := by
  simp only [matrixRowFeature, PiLp.inner_apply, Real.inner_apply]

omit [DecidableEq ι] in
lemma matrixRowFeature_close (F G : Matrix ι ι ℝ) (a : ℝ) (ha : 0 ≤ a)
    (hFG : ∀ i j, |F i j-G i j| ≤ a) (i : ι) :
    ‖matrixRowFeature F i-matrixRowFeature G i‖ ≤ (Fintype.card ι:ℝ)*a := by
  have hn : (1:ℝ) ≤ Fintype.card ι := by
    have : 0 < Fintype.card ι := Fintype.card_pos_iff.mpr ⟨i⟩
    exact_mod_cast this
  have hsq : ‖matrixRowFeature F i-matrixRowFeature G i‖^2 ≤
      (Fintype.card ι:ℝ)*a^2 := by
    rw [EuclideanSpace.norm_sq_eq]
    calc
      _ = ∑ k, |F i k-G i k|^2 := by
        simp only [matrixRowFeature, ← WithLp.toLp_sub, WithLp.ofLp_toLp,
          Pi.sub_apply, Real.norm_eq_abs]
      _ ≤ ∑ _k : ι, a^2 := by
        apply Finset.sum_le_sum
        intro k hk
        exact (sq_le_sq₀ (abs_nonneg _) ha).mpr (hFG i k)
      _ = _ := by simp
  apply (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp
  have hn2 : (Fintype.card ι:ℝ) ≤ (Fintype.card ι:ℝ)^2 := by nlinarith
  have h := hsq.trans (mul_le_mul_of_nonneg_right hn2 (sq_nonneg a))
  simpa only [mul_pow] using h

/-- Repair a Gram defect while retaining an arbitrary existing Hilbert-space
embedding. In particular, distances to already-coupled vectors remain exact.
Only the newly introduced covariance defect incurs a square-root cost. -/
theorem repair_hilbert_features (u : ι → E) {A : Matrix ι ι ℝ} (hA : A.PosSemidef)
    (ε : ℝ) (hε : 0 ≤ ε)
    (hclose : ∀ i j, |inner ℝ (u i) (u j)-A i j| ≤ ε^2) :
    ∃ U : E →ₗᵢ[ℝ] WithLp 2 (E × EuclideanSpace ℝ ι),
      ∃ v : ι → WithLp 2 (E × EuclideanSpace ℝ ι),
        (∀ i j, inner ℝ (v i) (v j)=A i j) ∧
        ∀ i, ‖U (u i)-v i‖ ≤ (Fintype.card ι:ℝ)^4*ε := by
  obtain ⟨F,G,hF,hG,hFG⟩ := psd_close_features (Matrix.posSemidef_gram ℝ u) hA ε hε hclose
  have hgram : ∀ i j, inner ℝ (u i) (u j) =
      inner ℝ (matrixRowFeature F i) (matrixRowFeature F j) := by
    intro i j
    rw [matrixRowFeature_inner]
    exact (congrFun (congrFun hF i) j).symm
  obtain ⟨V,U,hVU⟩ := equal_gram_common_embedding (matrixRowFeature F) u hgram
  refine ⟨U,fun i => V (matrixRowFeature G i),?_,?_⟩
  · intro i j
    rw [V.inner_map_map,matrixRowFeature_inner]
    exact congrFun (congrFun hG i) j
  · intro i
    rw [← hVU i,← V.map_sub,V.norm_map]
    have h := matrixRowFeature_close F G ((Fintype.card ι:ℝ)^3*ε)
      (by positivity) hFG i
    convert h using 1
    ring

/-- Combine the transported error with a fresh covariance defect in one
linear error update, preserving both endpoint Gram matrices exactly. -/
theorem repair_coupled_hilbert_features (u w : ι → E) {A : Matrix ι ι ℝ}
    (hA : A.PosSemidef) (ε e : ℝ) (hε : 0 ≤ ε)
    (hclose : ∀ i j, |inner ℝ (u i) (u j)-A i j| ≤ ε^2)
    (huw : ∀ i, ‖w i-u i‖ ≤ e) :
    ∃ U : E →ₗᵢ[ℝ] WithLp 2 (E × EuclideanSpace ℝ ι),
      ∃ v : ι → WithLp 2 (E × EuclideanSpace ℝ ι),
        (∀ i j, inner ℝ (v i) (v j)=A i j) ∧
        ∀ i, ‖U (w i)-v i‖ ≤ e+(Fintype.card ι:ℝ)^4*ε := by
  obtain ⟨U,v,hv,herror⟩ := repair_hilbert_features u hA ε hε hclose
  refine ⟨U,v,hv,?_⟩
  intro i
  calc
    ‖U (w i)-v i‖ ≤ ‖U (w i)-U (u i)‖+‖U (u i)-v i‖ := by
      simpa only [dist_eq_norm] using dist_triangle (U (w i)) (U (u i)) (v i)
    _ = ‖w i-u i‖+‖U (u i)-v i‖ := by rw [← U.map_sub,U.norm_map]
    _ ≤ _ := add_le_add (huw i) (herror i)

/-- Exact finite-dimensional compression by factoring the actual joint Gram. -/
noncomputable def compressHilbertFeatures (u : ι → E) : ι → EuclideanSpace ℝ ι :=
  matrixRowFeature (psdSpectrum (Matrix.posSemidef_gram ℝ u)).root

lemma compressHilbertFeatures_inner (u : ι → E) (i j : ι) :
    inner ℝ (compressHilbertFeatures u i) (compressHilbertFeatures u j) =
      inner ℝ (u i) (u j) := by
  rw [compressHilbertFeatures,matrixRowFeature_inner]
  exact congrFun (congrFun (psdSpectrum (Matrix.posSemidef_gram ℝ u)).root_gram i) j

lemma compressHilbertFeatures_distance (u : ι → E) (i j : ι) :
    ‖compressHilbertFeatures u i-compressHilbertFeatures u j‖ = ‖u i-u j‖ := by
  apply (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  simp only [← real_inner_self_eq_norm_sq,inner_sub_left,inner_sub_right,
    compressHilbertFeatures_inner]

/-- Compress two coupled m-row families jointly to 2m coordinates. Their
individual Gram matrices, cross-Gram matrix, and coupled distances are all
preserved. The Gaussian source dimension therefore need not grow with depth. -/
theorem compress_feature_pair (u v : ι → E) :
    ∃ U V : ι → EuclideanSpace ℝ (ι ⊕ ι),
      (∀ i j, inner ℝ (U i) (U j)=inner ℝ (u i) (u j)) ∧
      (∀ i j, inner ℝ (V i) (V j)=inner ℝ (v i) (v j)) ∧
      (∀ i j, inner ℝ (U i) (V j)=inner ℝ (u i) (v j)) ∧
      (∀ i, ‖U i-V i‖=‖u i-v i‖) := by
  let z := compressHilbertFeatures (Sum.elim u v)
  refine ⟨fun i => z (Sum.inl i), fun i => z (Sum.inr i),?_,?_,?_,?_⟩
  · intro i j
    exact compressHilbertFeatures_inner (Sum.elim u v) (Sum.inl i) (Sum.inl j)
  · intro i j
    exact compressHilbertFeatures_inner (Sum.elim u v) (Sum.inr i) (Sum.inr j)
  · intro i j
    exact compressHilbertFeatures_inner (Sum.elim u v) (Sum.inl i) (Sum.inr j)
  · intro i
    exact compressHilbertFeatures_distance (Sum.elim u v) (Sum.inl i) (Sum.inr i)

end ConditionalNonpolynomial.Analytic
