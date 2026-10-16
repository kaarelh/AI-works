import NeuralGeneralization.GaussianSignConfidence

/-! Deterministic rank/trace bounds for the actual Gaussian regression
residual variance. Orthonormal coordinates replace a pseudoinverse argument. -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal RealInnerProductSpace
namespace NeuralGeneralization.GaussianResidualTrace
open GaussianResidualIndependence
variable {I X : Type*} [Fintype I] [Fintype X]

theorem residualVariance_decomposition (K : Submodule ℝ (EuclideanSpace ℝ I))
    (b : EuclideanSpace ℝ I) :
    ‖b‖ ^ 2 = ‖K.starProjection b‖ ^ 2 + residualVariance K b :=
  Submodule.norm_sq_eq_add_norm_sq_starProjection b K

theorem projection_norm_sq_eq_sum (K : Submodule ℝ (EuclideanSpace ℝ I))
    (b : EuclideanSpace ℝ I) :
    ‖K.starProjection b‖ ^ 2 =
      ∑ j, ⟪((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I), b⟫ ^ 2 := by
  have h := (stdOrthonormalBasis ℝ K).sum_sq_norm_inner_right (K.orthogonalProjectionOnto b)
  simp only [Submodule.inner_orthogonalProjectionOnto_eq_of_mem_left, Real.norm_eq_abs, sq_abs] at h
  exact h.symm

/-- The removed covariance has population trace at most dimension times
operator norm. Its rank is controlled by the actual observation span. -/
theorem average_projection_sq_le (K : Submodule ℝ (EuclideanSpace ℝ I))
    (b : X → EuclideanSpace ℝ I) (ell : ℝ)
    (hcov : ∀ u : EuclideanSpace ℝ I,
      (∑ x, ⟪u, b x⟫ ^ 2) / Fintype.card X ≤ ell * ‖u‖ ^ 2) :
    (∑ x, ‖K.starProjection (b x)‖ ^ 2) / Fintype.card X ≤
      Module.finrank ℝ K * ell := by
  simp_rw [projection_norm_sq_eq_sum]
  rw [Finset.sum_comm, Finset.sum_div]
  calc
    _ ≤ ∑ _j : Fin (Module.finrank ℝ K), ell := by
      apply Finset.sum_le_sum
      intro j hj
      have hn : ‖((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I)‖ = 1 :=
        (stdOrthonormalBasis ℝ K).norm_eq_one j
      simpa only [hn, one_pow, mul_one] using
        hcov (((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I))
    _ = _ := by simp

/-- At most `2 rank ell / tau` of the inputs have Gaussian residual variance
below half the diagonal variance lower bound. -/
theorem small_residual_fraction_le [Nonempty X]
    (K : Submodule ℝ (EuclideanSpace ℝ I)) (b : X → EuclideanSpace ℝ I)
    (ell tau : ℝ) (htau : 0 < tau)
    (hdiag : ∀ x, tau ≤ ‖b x‖ ^ 2)
    (hcov : ∀ u : EuclideanSpace ℝ I,
      (∑ x, ⟪u, b x⟫ ^ 2) / Fintype.card X ≤ ell * ‖u‖ ^ 2) :
    ((Finset.univ.filter (fun x => residualVariance K (b x) < tau / 2)).card : ℝ) /
      Fintype.card X ≤ 2 * Module.finrank ℝ K * ell / tau := by
  classical
  let S := Finset.univ.filter (fun x => residualVariance K (b x) < tau / 2)
  have hD : (0 : ℝ) < Fintype.card X := Nat.cast_pos.mpr Fintype.card_pos
  have hs : (S.card : ℝ) * (tau / 2) ≤ ∑ x, ‖K.starProjection (b x)‖ ^ 2 := by
    calc
      _ = ∑ _x ∈ S, tau / 2 := by simp
      _ ≤ ∑ x ∈ S, ‖K.starProjection (b x)‖ ^ 2 := by
        apply Finset.sum_le_sum
        intro x hx
        have hb := (Finset.mem_filter.mp hx).2
        have hd := hdiag x
        have hp := residualVariance_decomposition K (b x)
        linarith
      _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun x _ _ => sq_nonneg _)
  have hm := average_projection_sq_le K b ell hcov
  have hm' := (div_le_iff₀ hD).mp hm
  change (S.card : ℝ) / Fintype.card X ≤ _
  apply (div_le_iff₀ hD).mpr
  rw [div_mul_eq_mul_div]
  apply (le_div_iff₀ htau).mpr
  nlinarith [hs, hm']

/-- Dropping feature coordinates and enlarging the corresponding observed
subspace can only decrease residual variance. This is the conditioning-on-
the-entire-low-degree-field step, proved by projection contraction. -/
theorem residualVariance_contraction
    (K K' : Submodule ℝ (EuclideanSpace ℝ I))
    (T : EuclideanSpace ℝ I →L[ℝ] EuclideanSpace ℝ I)
    (hT : ∀ x, ‖T x‖ ≤ ‖x‖)
    (hmap : ∀ x ∈ K, T x ∈ K') (b : EuclideanSpace ℝ I) :
    residualVariance K' (T b) ≤ residualVariance K b := by
  have hz : K'ᗮ.starProjection (T (K.starProjection b)) = 0 := by
    rw [K'.starProjection_orthogonal]
    simp only [ContinuousLinearMap.sub_apply, ContinuousLinearMap.id_apply]
    have ht : T (K.starProjection b) ∈ K' :=
      hmap _ (K.orthogonalProjectionOnto b).property
    rw [Submodule.starProjection_eq_self_iff.mpr ht, sub_self]
  have heq : K'ᗮ.starProjection (T b) = K'ᗮ.starProjection (T (Kᗮ.starProjection b)) := by
    nth_rw 1 [← K.starProjection_add_starProjection_orthogonal b]
    rw [map_add, map_add, hz, zero_add]
  have hn : ‖K'ᗮ.starProjection (T b)‖ ≤ ‖Kᗮ.starProjection b‖ := by
    rw [heq]
    exact (K'ᗮ.norm_starProjection_apply_le _).trans (hT _)
  exact pow_le_pow_left₀ (norm_nonneg _) hn 2

end NeuralGeneralization.GaussianResidualTrace
