import CanonicalProjectionGeometry
import FiniteEnergyAnchors

noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace ConditionalAnalytic

variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℝ H] [CompleteSpace H]

lemma nested_projection_energy (U V : Submodule ℝ H)
    [U.HasOrthogonalProjection] [V.HasOrthogonalProjection] (hUV : U≤V) (b : H) :
    ‖V.starProjection b‖^2 = ‖U.starProjection b‖^2+
      ‖V.starProjection b-U.starProjection b‖^2 := by
  have he : U.starProjection (V.starProjection b)=U.starProjection b :=
    DFunLike.congr_fun (Submodule.starProjection_comp_starProjection_of_le hUV) b
  have hh := Submodule.norm_sq_eq_add_norm_sq_starProjection (V.starProjection b) U
  rw [he,U.starProjection_orthogonal,sub_apply,ContinuousLinearMap.id_apply,he] at hh
  exact hh

theorem nested_projection_error (U V : Submodule ℝ H)
    [U.HasOrthogonalProjection] [V.HasOrthogonalProjection]
    (hUV : U≤V) (b v : H) (hv : v∈V) (hn : ‖v‖≤1) :
    ⟪b-U.starProjection b,v⟫^2 ≤ ‖V.starProjection b‖^2-‖U.starProjection b‖^2 := by
  have hi : ⟪b-U.starProjection b,v⟫=⟪V.starProjection b-U.starProjection b,v⟫ := by
    rw [inner_sub_left,inner_sub_left,V.inner_starProjection_left_eq_right,
      Submodule.starProjection_eq_self_iff.mpr hv]
  rw [hi,nested_projection_energy U V hUV b]
  have hcs := abs_real_inner_le_norm (V.starProjection b-U.starProjection b) v
  have hh := mul_le_mul_of_nonneg_left hn (norm_nonneg (V.starProjection b-U.starProjection b))
  have h := pow_le_pow_left₀ (abs_nonneg _) (hcs.trans (by simpa using hh)) 2
  simpa only [sq_abs,add_sub_cancel_left] using h

variable {X : Type*} [Fintype X] [DecidableEq X]

def featureSpan (v : X → H) (S : Finset X) : Submodule ℝ H :=
  Submodule.span ℝ (v '' (S : Set X))

instance featureSpan_finite (v : X → H) (S : Finset X) :
    FiniteDimensional ℝ (featureSpan v S) := by
  unfold featureSpan
  exact FiniteDimensional.span_of_finite ℝ ((S.finite_toSet).image v)

def readoutAnchorEnergy (v : X → H) (b : H) (S : Finset X) : ℝ :=
  ‖(featureSpan v S).starProjection b‖^2

lemma featureSpan_mono (v : X → H) : Monotone (featureSpan v) := by
  intro S T hST
  exact Submodule.span_mono (Set.image_mono hST)

lemma readoutAnchorEnergy_monotone (v : X → H) (b : H) :
    Monotone (readoutAnchorEnergy v b) := by
  intro S T hST
  have h := nested_projection_energy (featureSpan v S) (featureSpan v T)
    (featureSpan_mono v hST) b
  unfold readoutAnchorEnergy
  linarith [sq_nonneg (‖(featureSpan v T).starProjection b-(featureSpan v S).starProjection b‖)]

lemma readoutAnchorEnergy_le (v : X → H) (b : H) (S : Finset X) :
    readoutAnchorEnergy v b S ≤ ‖b‖^2 :=
  pow_le_pow_left₀ (norm_nonneg _) ((featureSpan v S).norm_starProjection_apply_le b) 2

/-- A small marginal projection-energy increase controls the actual readout
error at every bounded query, precisely the anchor-selection stopping rule. -/
theorem readout_anchor_error (v : X → H) (b : H) (S : Finset X)
    (hv : ∀ x,‖v x‖≤1) {ρ : ℝ} (hρ : 0≤ρ)
    (hinc : ∀ x,readoutAnchorEnergy v b (insert x S)-readoutAnchorEnergy v b S≤ρ^2) :
    ∀ x,|⟪b-(featureSpan v S).starProjection b,v x⟫|≤ρ := by
  intro x
  have hm : v x∈featureSpan v (insert x S) :=
    Submodule.subset_span ⟨x,Finset.mem_insert_self x S,rfl⟩
  have h := nested_projection_error (featureSpan v S) (featureSpan v (insert x S))
    (featureSpan_mono v (Finset.subset_insert x S)) b (v x) hm (hv x)
  have hh := h.trans (hinc x)
  exact (sq_le_sq₀ (abs_nonneg _) hρ).mp (by simpa only [sq_abs] using hh)

#print axioms readout_anchor_error
end ConditionalAnalytic
