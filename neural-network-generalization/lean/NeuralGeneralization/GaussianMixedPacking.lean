import NeuralGeneralization.GaussianQuadraticPacking

/-!
# Simultaneous row and image packing from one Gaussian set

Intersecting a row strip and an ellipsoid replaces the two-cover
pigeonhole argument. Their actual Gaussian probabilities give a single
symmetric set of mass at least one half.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianTranslatePacking
variable {I J H : Type*} [Fintype I] [Fintype J] [Fintype H]

omit [Fintype H] in
theorem gaussian_rowStrip_three_quarters (a : J → I → ℝ) (V t : ℝ)
    (hV : 0 < V) (ht : 0 ≤ t) (hvar : ∀ j, (∑ i, a j i^2) ≤ V)
    (hsize : 8*(Fintype.card J : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1) :
    (3:ℝ)/4 ≤ (standardGaussian (I := I)).real (rowStrip a t) := by
  have htail (j : J) : (standardGaussian (I := I)).real
      {y | t ≤ |rowForm (a j) y|} ≤ 2*Real.exp (-t^2/(2*V)) := by
    apply GaussianTail.gaussian_linear_form_abs_tail (fun _ : I => 1) (a j) V t hV ht
    simpa only [NNReal.coe_one, mul_one] using hvar j
  have hcompl : (rowStrip a t)ᶜ = ⋃ j : J, {y | t ≤ |rowForm (a j) y|} := by
    ext y
    simp only [rowStrip, Set.mem_compl_iff, Set.mem_setOf_eq, not_forall, not_lt, Set.mem_iUnion]
  have hbound := (measureReal_iUnion_fintype_le (μ := standardGaussian (I := I))
    (fun j : J => {y | t ≤ |rowForm (a j) y|})).trans
    (Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => htail j))
  rw [← hcompl, probReal_compl_eq_one_sub (measurableSet_rowStrip a t)] at hbound
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at hbound
  nlinarith only [hbound, hsize]

omit [Fintype H] in
theorem gaussian_quadraticBall_three_quarters (a : J → I → ℝ) (V : ℝ) (hV : 0 < V)
    (htrace : (∑ j, ∑ i, a j i^2) ≤ V) :
    (3:ℝ)/4 ≤ (standardGaussian (I := I)).real (quadraticBall a (4*V)) := by
  have hm := mul_meas_ge_le_integral_of_nonneg
    (ae_of_all _ (squaredImageNorm_nonneg a)) (integrable_squaredImageNorm a) (4*V)
  rw [integral_squaredImageNorm] at hm
  have hc : {y | 4*V ≤ squaredImageNorm a y} = (quadraticBall a (4*V))ᶜ := by
    ext y
    simp only [quadraticBall, Set.mem_compl_iff, Set.mem_setOf_eq, not_lt]
  rw [hc, probReal_compl_eq_one_sub (measurableSet_quadraticBall a (4*V))] at hm
  nlinarith only [hm, htrace, hV]

theorem gaussian_mixedBall_halfmass (a : J → I → ℝ) (b : H → I → ℝ) (V W t : ℝ)
    (hV : 0 < V) (hW : 0 < W) (ht : 0 ≤ t)
    (hvar : ∀ j, (∑ i, a j i^2) ≤ V)
    (hsize : 8*(Fintype.card J : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1)
    (htrace : (∑ j, ∑ i, b j i^2) ≤ W) :
    (1:ℝ)/2 ≤ (standardGaussian (I := I)).real (rowStrip a t ∩ quadraticBall b (4*W)) := by
  have hA := gaussian_rowStrip_three_quarters a V t hV ht hvar hsize
  have hB := gaussian_quadraticBall_three_quarters b W hW htrace
  have hid := measureReal_union_add_inter (μ := standardGaussian (I := I))
    (s := rowStrip a t) (measurableSet_quadraticBall b (4*W))
  have hle := measureReal_mono (μ := standardGaussian (I := I))
    (Set.subset_univ (rowStrip a t ∪ quadraticBall b (4*W)))
  rw [probReal_univ] at hle
  linarith

/-- Either kind of pairwise separation suffices. The resulting estimate
is from one Gaussian packing and has no extra product of covering counts. -/
theorem gaussian_mixed_packing {K : Type*} [Fintype K]
    (a : J → I → ℝ) (b : H → I → ℝ) (x : K → I → ℝ) (V W t R : ℝ)
    (hV : 0 < V) (hW : 0 < W) (ht : 0 ≤ t)
    (hvar : ∀ j, (∑ i, a j i^2) ≤ V)
    (hsize : 8*(Fintype.card J : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1)
    (htrace : (∑ j, ∑ i, b j i^2) ≤ W)
    (hsep : ∀ i j, i ≠ j →
      (∃ l, 2*t ≤ |rowForm (a l) (x i-x j)|) ∨
        16*W ≤ squaredImageNorm b (x i-x j))
    (hR : ∀ j, (∑ i, x j i^2) ≤ R) :
    (Fintype.card K : ℝ) ≤ 2*Real.exp (R/2) := by
  apply gaussian_translate_packing x (rowStrip a t ∩ quadraticBall b (4*W))
    ((measurableSet_rowStrip a t).inter (measurableSet_quadraticBall b (4*W)))
    (fun y => by simp only [Set.mem_inter_iff, rowStrip_symmetric, quadraticBall_symmetric])
    (gaussian_mixedBall_halfmass a b V W t hV hW ht hvar hsize htrace) _ R hR
  intro i j hij
  rcases hsep i j hij with hs | hs
  · exact (rowStrip_translates_disjoint a t (x i) (x j) hs).mono
      (fun _ h => h.1) (fun _ h => h.1)
  · have hdis := quadraticBall_translates_disjoint b (2*W) (x i) (x j) (by linarith only [hs])
    have hset : 2*(2*W) = 4*W := by ring
    rw [hset] at hdis
    exact hdis.mono (fun _ h => h.2) (fun _ h => h.2)

end NeuralGeneralization.GaussianTranslatePacking
