import NeuralGeneralization.OnlineLowerCostRelu

/-! # Compulsory prefix loops preserve the strict scalar order -/

noncomputable section
open MeasureTheory Set
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

def prefixDegree (P : ℕ) (s : ClippingCube P) : ℝ :=
  ∑ i, 2 * (1 - cubeCoordinateSign (s i))

def prefixParity (P : ℕ) (s : ClippingCube P) : ℝ :=
  ∏ i, cubeCoordinateSign (s i)

def prefixLaplaceFactor (P : ℕ) (t : ℝ) : ℝ :=
  ((1 - Real.exp (-4*t))/2)^P

theorem prefixDegree_nonneg (P : ℕ) (s : ClippingCube P) : 0 ≤ prefixDegree P s := by
  apply Finset.sum_nonneg
  intro i _
  cases h : s i <;> norm_num [cubeCoordinateSign, h]

theorem prefixLaplaceFactor_pos (P : ℕ) {t : ℝ} (ht : 0 < t) :
    0 < prefixLaplaceFactor P t := by
  have he : Real.exp (-4*t) < 1 := Real.exp_lt_one_iff.mpr (by linarith)
  unfold prefixLaplaceFactor
  apply pow_pos
  positivity

theorem prefix_laplace_sum (P : ℕ) (t : ℝ) :
    (∑ s : ClippingCube P, prefixParity P s * Real.exp (-prefixDegree P s*t)) /
      (2 : ℝ)^P = prefixLaplaceFactor P t := by
  classical
  have he (s : ClippingCube P) :
      prefixParity P s * Real.exp (-prefixDegree P s*t) =
      ∏ i, (cubeCoordinateSign (s i) * Real.exp (-(2*(1-cubeCoordinateSign (s i)))*t)) := by
    unfold prefixDegree prefixParity
    rw [show -(∑ i : Fin P, 2 * (1-cubeCoordinateSign (s i)))*t =
      ∑ i : Fin P, -(2*(1-cubeCoordinateSign (s i)))*t by
        rw [← Finset.sum_mul, Finset.sum_neg_distrib]]
    rw [Real.exp_sum, Finset.prod_mul_distrib]
  simp_rw [he]
  rw [← Fintype.prod_sum (fun (_ : Fin P) (b : Bool) =>
    cubeCoordinateSign b * Real.exp (-(2*(1-cubeCoordinateSign b))*t))]
  have hbit : (∑ b : Bool, cubeCoordinateSign b *
      Real.exp (-(2*(1-cubeCoordinateSign b))*t)) = 1-Real.exp (-4*t) := by
    norm_num [cubeCoordinateSign]
    ring
  simp only [hbit, Finset.prod_const, Finset.card_univ, Fintype.card_fin]
  exact (div_pow _ _ P).symm

theorem pathLaplacePrefactor_shift (n₀ u t : ℝ) {n : ℕ} (edge : Fin n → ℝ) :
    pathLaplacePrefactor (n₀+u) t 4 edge =
      Real.exp (-u*t) * pathLaplacePrefactor n₀ t 4 edge := by
  unfold pathLaplacePrefactor
  rw [show -(n₀+u)*t=(-u*t)+(-n₀*t) by ring, Real.exp_add]
  ring

def prefixedCandidateCost (P : ℕ) (n₀ : ℝ) (cost : ℝ → ℝ)
    (endpoint : Bool) (digits : List Bool) : ℝ :=
  (∑ s : ClippingCube P, prefixParity P s *
    fixedCandidateCost (n₀+prefixDegree P s) cost endpoint digits) / (2 : ℝ)^P

theorem prefix_integral_exchange (μ : Measure ℝ) (P : ℕ) (G : ℝ → ℝ)
    (hint : ∀ s : ClippingCube P,
      Integrable (fun t => Real.exp (-prefixDegree P s*t) * G t) μ) :
    (∑ s : ClippingCube P, prefixParity P s *
      (-(∫ t, Real.exp (-prefixDegree P s*t)*G t ∂μ))) / (2 : ℝ)^P =
        -(∫ t, prefixLaplaceFactor P t * G t ∂μ) := by
  have hi := fun s (_ : s ∈ (Finset.univ : Finset (ClippingCube P))) =>
    (hint s).const_mul (prefixParity P s)
  have hpoint (t : ℝ) :
      (∑ s : ClippingCube P, prefixParity P s *
        (Real.exp (-prefixDegree P s*t)*G t)) / (2 : ℝ)^P =
      prefixLaplaceFactor P t * G t := by
    rw [← prefix_laplace_sum P t, div_mul_eq_mul_div, Finset.sum_mul]
    congr 1
    apply Finset.sum_congr rfl
    intro s _
    ring
  rw [← integral_congr_ae (Filter.Eventually.of_forall hpoint)]
  rw [integral_div, integral_finsetSum _ hi]
  simp only [integral_const_mul, mul_neg, Finset.sum_neg_distrib, neg_div]

theorem prefix_integrable (μ : Measure ℝ) (P : ℕ) (G : ℝ → ℝ)
    (hint : ∀ s : ClippingCube P,
      Integrable (fun t => Real.exp (-prefixDegree P s*t) * G t) μ) :
    Integrable (fun t => prefixLaplaceFactor P t * G t) μ := by
  have hi := (integrable_finsetSum (Finset.univ : Finset (ClippingCube P))
    (fun s _ => (hint s).const_mul (prefixParity P s))).div_const ((2 : ℝ)^P)
  apply hi.congr
  filter_upwards [] with t
  rw [← prefix_laplace_sum P t, div_mul_eq_mul_div, Finset.sum_mul]
  congr 1
  apply Finset.sum_congr rfl
  intro s _
  ring

open OnlineLowerBernstein

def reluPathBaseIntegrand (n₀ : ℝ) (endpoint : Bool) (digits : List Bool) (t : ℝ) : ℝ :=
  (reluCostDensity t * pathLaplacePrefactor n₀ t 4
    (@alternatingEdgeIncrement (2*(digits.length+1)))) *
      candidatePathEnumerator (Real.exp (-2*t)) endpoint digits

theorem reluPathBaseIntegrand_shift (n₀ u t : ℝ) (endpoint : Bool) (digits : List Bool) :
    reluPathBaseIntegrand (n₀+u) endpoint digits t =
      Real.exp (-u*t) * reluPathBaseIntegrand n₀ endpoint digits t := by
  unfold reluPathBaseIntegrand
  rw [pathLaplacePrefactor_shift]
  ring

theorem reluPathBaseIntegrand_integrable (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) (digits : List Bool) :
    IntegrableOn (reluPathBaseIntegrand n₀ endpoint digits) (Ioi 0) :=
  fixedCandidateCost_integrable _ n₀ reluCostDensity endpoint digits
    (fun _n hn => reluCostDensity_laplaceIntegrable (lt_of_lt_of_le hn₀ hn))

theorem reluCandidateCost_eq_integral (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) (digits : List Bool) (hlen : 2 ≤ digits.length) :
    fixedCandidateCost n₀ gammaCost endpoint digits =
      -(∫ t in Ioi (0 : ℝ), reluPathBaseIntegrand n₀ endpoint digits t) := by
  have h := fixedCandidateCost_bernstein (volume.restrict (Ioi 0)) n₀
    reluCostSlope reluCostIntercept gammaCost reluCostDensity endpoint digits hlen
    (fun s => reluCostDensity_laplaceIntegrable
      (lt_of_lt_of_le hn₀ (fixedPathDegree_ge n₀ _ s)))
    (fun s => gammaCost_bernstein (lt_of_lt_of_le hn₀ (fixedPathDegree_ge n₀ _ s)))
  simpa only [integratedEnumeratorCost, zero_sub, reluPathBaseIntegrand] using h

theorem reluPrefix_shift_integrable (P : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) (digits : List Bool) (s : ClippingCube P) :
    IntegrableOn (fun t => Real.exp (-prefixDegree P s*t) *
      reluPathBaseIntegrand n₀ endpoint digits t) (Ioi 0) := by
  have hn : 1 < n₀ + prefixDegree P s := by
    have h := prefixDegree_nonneg P s
    linarith
  have hi := reluPathBaseIntegrand_integrable (n₀+prefixDegree P s) hn endpoint digits
  apply hi.congr
  filter_upwards [] with t
  exact reluPathBaseIntegrand_shift n₀ (prefixDegree P s) t endpoint digits

theorem reluPrefixedCost_eq_integral (P : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) (digits : List Bool) (hlen : 2 ≤ digits.length) :
    prefixedCandidateCost P n₀ gammaCost endpoint digits =
      -(∫ t in Ioi (0 : ℝ), prefixLaplaceFactor P t *
        reluPathBaseIntegrand n₀ endpoint digits t) := by
  have hrep (s : ClippingCube P) :
      fixedCandidateCost (n₀+prefixDegree P s) gammaCost endpoint digits =
        -(∫ t in Ioi (0 : ℝ), Real.exp (-prefixDegree P s*t) *
          reluPathBaseIntegrand n₀ endpoint digits t) := by
    have hn : 1 < n₀+prefixDegree P s := by
      have h := prefixDegree_nonneg P s
      linarith
    rw [reluCandidateCost_eq_integral _ hn endpoint digits hlen]
    simp only [reluPathBaseIntegrand_shift]
  unfold prefixedCandidateCost
  simp_rw [hrep]
  exact prefix_integral_exchange _ P _ (reluPrefix_shift_integrable P n₀ hn₀ endpoint digits)

theorem reluPrefixedIntegrand_integrable (P : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) (digits : List Bool) :
    IntegrableOn (fun t => prefixLaplaceFactor P t *
      reluPathBaseIntegrand n₀ endpoint digits t) (Ioi 0) :=
  prefix_integrable _ P _ (reluPrefix_shift_integrable P n₀ hn₀ endpoint digits)

theorem reluPrefixedCost_strict (P : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) {xs ys : List Bool} (hlen : xs.length = ys.length)
    (hlarge : 2 ≤ xs.length) (hlex : digitLexLt xs ys) :
    prefixedCandidateCost P n₀ gammaCost endpoint ys <
      prefixedCandidateCost P n₀ gammaCost endpoint xs := by
  have hpoint : ∀ᵐ t ∂(volume.restrict (Ioi (0 : ℝ))),
      prefixLaplaceFactor P t * reluPathBaseIntegrand n₀ endpoint xs t <
        prefixLaplaceFactor P t * reluPathBaseIntegrand n₀ endpoint ys t := by
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    change 0 < t at ht
    have hx0 := Real.exp_pos (-2*t)
    have hx1 : Real.exp (-2*t) < 1 := Real.exp_lt_one_iff.mpr (by simpa using (show -2*t<0 by linarith))
    have hp := congrArg (fun n => pathLaplacePrefactor n₀ t 4
      (@alternatingEdgeIncrement (2*(n+1)))) hlen
    unfold reluPathBaseIntegrand
    rw [← hp]
    exact mul_lt_mul_of_pos_left
      (mul_lt_mul_of_pos_left (candidatePathEnumerator_lt _ hx0 hx1 endpoint hlen hlex)
        (mul_pos (reluCostDensity_pos t) (pathLaplacePrefactor_pos _ _ _ _)))
      (prefixLaplaceFactor_pos P ht)
  have hint := integral_strict_mono_of_ae_lt (volume.restrict (Ioi (0 : ℝ)))
    (by simp) (reluPrefixedIntegrand_integrable P n₀ hn₀ endpoint xs)
    (reluPrefixedIntegrand_integrable P n₀ hn₀ endpoint ys) hpoint
  rw [reluPrefixedCost_eq_integral P n₀ hn₀ endpoint xs hlarge,
    reluPrefixedCost_eq_integral P n₀ hn₀ endpoint ys (by omega)]
  linarith

theorem reluPrefixedCost_ne_of_ne (P : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) {xs ys : List Bool} (hlen : xs.length = ys.length)
    (hlarge : 2 ≤ xs.length) (hne : xs ≠ ys) :
    prefixedCandidateCost P n₀ gammaCost endpoint xs ≠
      prefixedCandidateCost P n₀ gammaCost endpoint ys := by
  rcases digitLexLt_or_reverse hlen hne with h | h
  · exact (reluPrefixedCost_strict P n₀ hn₀ endpoint hlen hlarge h).ne'
  · exact (reluPrefixedCost_strict P n₀ hn₀ endpoint hlen.symm (by omega) h).ne

/-- `k` counts triangular blocks, matching the concrete rail family.
There are `k-1` independent digits and `2k+1` path vertices. -/
def reluPrefixedBlockCost (P : ℕ) (n₀ : ℝ) (endpoint : Bool) (k : ℕ)
    (digits : Fin (k-1) → Bool) : ℝ :=
  prefixedCandidateCost P n₀ gammaCost endpoint (List.ofFn digits)

theorem reluPrefixedBlockCost_injective (P : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) (k : ℕ) (hk : 3 ≤ k) :
    Function.Injective (reluPrefixedBlockCost P n₀ endpoint k) := by
  intro xs ys he
  by_contra hne
  exact reluPrefixedCost_ne_of_ne P n₀ hn₀ endpoint (by simp) (by simp; omega)
    (fun h => hne (List.ofFn_injective h)) he

theorem reluPrefixedBlockCost_card (P : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) (k : ℕ) (hk : 3 ≤ k) :
    (Finset.univ.image (reluPrefixedBlockCost P n₀ endpoint k)).card = 2^(k-1) := by
  classical
  rw [Finset.card_image_of_injective _
    (reluPrefixedBlockCost_injective P n₀ hn₀ endpoint k hk)]
  simp

end NeuralGeneralization.OnlineLower
