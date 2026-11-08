import NeuralGeneralization.OnlineLowerReluWeightedComparison

/-! # Euclidean energy and distance to the balanced dominant-rail ray -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

variable {ι : Type*} [Fintype ι]

def weightedRailEnergy (p q a b : ι → ℝ) : ℝ :=
  (∑ i, p i * a i ^ 2) + ∑ i, q i * b i ^ 2

def weightedRailMean (p a : ι → ℝ) (D : ℝ) : ℝ := (∑ i, p i * a i) / D

def balancedRaySquaredDistance (p q a b : ι → ℝ) (D : ℝ) : ℝ :=
  (∑ i, p i * (a i - weightedRailMean p a D) ^ 2) + ∑ i, q i * b i ^ 2

theorem weightedRailMean_nonneg (p a : ι → ℝ) (D : ℝ)
    (hp : ∀ i, 0 ≤ p i) (ha : ∀ i, 0 ≤ a i) (hD : 0 ≤ D) :
    0 ≤ weightedRailMean p a D :=
  div_nonneg (Finset.sum_nonneg (fun i _ => mul_nonneg (hp i) (ha i))) hD

theorem balancedRaySquaredDistance_nonneg (p q a b : ι → ℝ) (D : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) :
    0 ≤ balancedRaySquaredDistance p q a b D :=
  add_nonneg (Finset.sum_nonneg (fun i _ => mul_nonneg (hp i) (sq_nonneg _)))
    (Finset.sum_nonneg (fun i _ => mul_nonneg (hq i) (sq_nonneg _)))

theorem weighted_variance_expand (p a : ι → ℝ) (μ D : ℝ) (hD : ∑ i, p i = D) :
    (∑ i, p i * (a i - μ) ^ 2) =
      (∑ i, p i * a i ^ 2) - 2 * μ * (∑ i, p i * a i) + μ ^ 2 * D := by
  have hterm (i : ι) : p i * (a i - μ) ^ 2 =
      p i * a i ^ 2 - 2 * μ * (p i * a i) + μ ^ 2 * p i := by ring
  simp_rw [hterm, Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, hD]

/-- Exact orthogonal-projection identity in the actual weighted incoming energy. -/
theorem balancedRaySquaredDistance_eq (p q a b : ι → ℝ) (D : ℝ)
    (hD : 0 < D) (hsum : ∑ i, p i = D) :
    balancedRaySquaredDistance p q a b D =
      weightedRailEnergy p q a b - (∑ i, p i * a i) ^ 2 / D := by
  unfold balancedRaySquaredDistance weightedRailEnergy
  rw [weighted_variance_expand p a _ D hsum]
  unfold weightedRailMean
  field_simp [hD.ne']
  ring

/-- The weighted projection bound supplies both the balanced norm and a
quantitative distance bound, without an extra geometric assumption. -/
theorem balancedRay_stability_of_projection (p q a b : ι → ℝ) (D Q : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) (hD : 0 < D)
    (hsum : ∑ i, p i = D) (hQ : 0 ≤ Q)
    (hproj : Q ≤ (∑ i, p i * a i) / Real.sqrt D) :
    balancedRaySquaredDistance p q a b D ≤ weightedRailEnergy p q a b - Q ^ 2 ∧
      Q ^ 2 ≤ weightedRailEnergy p q a b := by
  have hsq := mul_self_le_mul_self hQ hproj
  have hsqrt : Real.sqrt D ^ 2 = D := Real.sq_sqrt hD.le
  have hsq' : Q ^ 2 ≤ (∑ i, p i * a i) ^ 2 / D := by
    simpa only [← pow_two, div_pow, hsqrt] using hsq
  have hdist := balancedRaySquaredDistance_nonneg p q a b D hp hq
  rw [balancedRaySquaredDistance_eq p q a b D hD hsum] at hdist ⊢
  constructor <;> linarith

end NeuralGeneralization.OnlineLowerRelu
