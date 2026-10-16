import NeuralGeneralization.SquaredProcessIncrements

/-!
# Geometry of the actual rank-one increment distance

The squared rank-one distance has convex balls. This is stronger than the
approximate convexity available for arbitrary seminorms in the usual
chaining argument. All estimates below concern literal finite sums.
-/

noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators

lemma weighted_square_jensen {ι : Type*} [Fintype ι]
    (w x : ι → ℝ) (hw : ∀ i, 0 ≤ w i) (hs : ∑ i, w i = 1) :
    (∑ i, w i * x i) ^ 2 ≤ ∑ i, w i * x i ^ 2 := by
  let μ := ∑ i, w i * x i
  have hnonneg : 0 ≤ ∑ i, w i * (x i - μ) ^ 2 :=
    Finset.sum_nonneg (fun i _ => mul_nonneg (hw i) (sq_nonneg _))
  have heq : (∑ i, w i * (x i - μ) ^ 2) = (∑ i, w i * x i ^ 2) - μ ^ 2 := by
    have hpoint (i : ι) : w i * (x i - μ) ^ 2 =
        w i * x i ^ 2 - 2 * μ * (w i * x i) + μ ^ 2 * w i := by ring
    simp_rw [hpoint]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, hs]
    dsimp only [μ]
    ring
  rw [heq] at hnonneg
  exact sub_nonneg.mp hnonneg

lemma weighted_fourth_jensen {ι : Type*} [Fintype ι]
    (w x : ι → ℝ) (hw : ∀ i, 0 ≤ w i) (hs : ∑ i, w i = 1) :
    (∑ i, w i * x i) ^ 4 ≤ ∑ i, w i * x i ^ 4 := by
  have hfirst := weighted_square_jensen w x hw hs
  have hsquare := pow_le_pow_left₀ (sq_nonneg (∑ i, w i * x i)) hfirst 2
  have hsecond := weighted_square_jensen w (fun i => x i ^ 2) hw hs
  have heq (r : ℝ) : (r ^ 2) ^ 2 = r ^ 4 := by ring
  simp only [heq] at hsquare hsecond
  exact hsquare.trans hsecond

def scalarRankDistanceSquared (x y : ℝ) : ℝ := (x-y)^2*(x^2+y^2)

lemma scalarRankDistanceSquared_decomposition (x y : ℝ) :
    scalarRankDistanceSquared x y =
      (y - x/2)^4 + (x^2/2)*(y - x/2)^2 - x^3*(y - x/2) + 5*x^4/16 := by
  unfold scalarRankDistanceSquared
  ring

/-- The scalar quartic defining the rank-one distance is convex in each
endpoint. The proof is a direct weighted Jensen calculation. -/
theorem scalarRankDistanceSquared_weighted_jensen {ι : Type*} [Fintype ι]
    (w y : ι → ℝ) (hw : ∀ i, 0 ≤ w i) (hs : ∑ i, w i = 1) (x : ℝ) :
    scalarRankDistanceSquared x (∑ i, w i * y i) ≤
      ∑ i, w i * scalarRankDistanceSquared x (y i) := by
  let z := fun i => y i - x/2
  have hz : (∑ i, w i * z i) = (∑ i, w i * y i) - x/2 := by
    simp only [z, mul_sub, Finset.sum_sub_distrib, ← Finset.sum_mul, hs, one_mul]
  have h₂ := mul_le_mul_of_nonneg_left (weighted_square_jensen w z hw hs)
    (show 0 ≤ x^2/2 by positivity)
  have h₄ := weighted_fourth_jensen w z hw hs
  have heq : (∑ i, w i * scalarRankDistanceSquared x (y i)) =
      (∑ i, w i * z i ^ 4) + (x^2/2)*(∑ i, w i * z i ^ 2) -
        x^3*(∑ i, w i * z i) + 5*x^4/16 := by
    simp_rw [scalarRankDistanceSquared_decomposition]
    have hpoint (i : ι) : w i *
        ((y i-x/2)^4 + (x^2/2)*(y i-x/2)^2 - x^3*(y i-x/2) + 5*x^4/16) =
        w i * z i ^ 4 + (x^2/2)*(w i * z i ^ 2) - x^3*(w i * z i) + (5*x^4/16)*w i := by
      dsimp only [z]
      ring
    simp_rw [hpoint]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_add_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum, hs, mul_one]
  rw [heq, scalarRankDistanceSquared_decomposition, ← hz]
  linarith only [h₂, h₄]

lemma linearEvaluation_weighted_mean {ι : Type*} [Fintype ι] {D : ℕ}
    (a : Fin D → ℝ) (w : ι → ℝ) (u : ι → Fin D → ℝ) :
    linearEvaluation a (fun j => ∑ i, w i * u i j) =
      ∑ i, w i * linearEvaluation a (u i) := by
  unfold linearEvaluation
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  ring

/-- Exact convexity of every ball of the actual squared rank-one distance,
expressed for arbitrary finite convex combinations. -/
theorem rankOneMetricSquared_weighted_jensen {ι : Type*} [Fintype ι] {m D : ℕ}
    (a : Fin m → Fin D → ℝ) (w : ι → ℝ) (u : ι → Fin D → ℝ)
    (hw : ∀ i, 0 ≤ w i) (hs : ∑ i, w i = 1) (x : Fin D → ℝ) :
    rankOneMetricSquared a x (fun j => ∑ i, w i * u i j) ≤
      ∑ i, w i * rankOneMetricSquared a x (u i) := by
  unfold rankOneMetricSquared
  simp_rw [linearEvaluation_weighted_mean, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_le_sum
  intro j _
  exact scalarRankDistanceSquared_weighted_jensen w
    (fun i => linearEvaluation (a j) (u i)) hw hs (linearEvaluation (a j) x)

theorem rankOneMetricSquared_convex_ball {ι : Type*} [Fintype ι] {m D : ℕ}
    (a : Fin m → Fin D → ℝ) (w : ι → ℝ) (u : ι → Fin D → ℝ)
    (hw : ∀ i, 0 ≤ w i) (hs : ∑ i, w i = 1) (x : Fin D → ℝ)
    (R : ℝ) (hball : ∀ i, rankOneMetricSquared a x (u i) ≤ R) :
    rankOneMetricSquared a x (fun j => ∑ i, w i * u i j) ≤ R := by
  apply (rankOneMetricSquared_weighted_jensen a w u hw hs x).trans
  calc
    _ ≤ ∑ i, w i * R := Finset.sum_le_sum (fun i _ => mul_le_mul_of_nonneg_left (hball i) (hw i))
    _ = R := by rw [← Finset.sum_mul, hs, one_mul]

/-- In the rank-one case the geometric energy is an actual quadratic
form, with an additional Euclidean term. -/
def rankOneEnergy {m D : ℕ} (a : Fin m → Fin D → ℝ) (u : Fin D → ℝ) : ℝ :=
  (∑ j, u j ^ 2) + ∑ i, linearEvaluation (a i) u ^ 2

lemma linearEvaluation_sub {D : ℕ} (a u v : Fin D → ℝ) :
    linearEvaluation a (fun j => u j - v j) = linearEvaluation a u - linearEvaluation a v := by
  simp only [linearEvaluation, mul_sub, Finset.sum_sub_distrib]

lemma linearEvaluation_midpoint {D : ℕ} (a u v : Fin D → ℝ) :
    linearEvaluation a (fun j => (u j + v j) / 2) =
      (linearEvaluation a u + linearEvaluation a v) / 2 := by
  unfold linearEvaluation
  rw [← Finset.sum_add_distrib, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j _
  ring

lemma rankOneEnergy_nonneg {m D : ℕ} (a : Fin m → Fin D → ℝ) (u : Fin D → ℝ) :
    0 ≤ rankOneEnergy a u := by
  unfold rankOneEnergy
  positivity

lemma finiteSum_midpoint_identity {ι : Type*} [Fintype ι] (x y : ι → ℝ) :
      (∑ i, (x i - y i)^2) = 2*(∑ i, x i^2) + 2*(∑ i, y i^2) -
        4*(∑ i, ((x i+y i)/2)^2) := by
    rw [Finset.mul_sum, Finset.mul_sum, Finset.mul_sum,
      ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro i _
    ring

theorem rankOneEnergy_midpoint_identity {m D : ℕ} (a : Fin m → Fin D → ℝ)
    (u v : Fin D → ℝ) :
    rankOneEnergy a (fun j => u j - v j) =
      2 * rankOneEnergy a u + 2 * rankOneEnergy a v -
        4 * rankOneEnergy a (fun j => (u j + v j) / 2) := by
  simp only [rankOneEnergy, linearEvaluation_sub, linearEvaluation_midpoint]
  rw [finiteSum_midpoint_identity u v,
    finiteSum_midpoint_identity (fun i => linearEvaluation (a i) u) (fun i => linearEvaluation (a i) v)]
  ring

/-- A midpoint comparison at a minimizer controls the full quadratic
distance to that minimizer. This also controls the individual row-value
differences, stronger than the corresponding absolute-value estimate. -/
theorem rankOneEnergy_minimizer_gap {m D : ℕ} (a : Fin m → Fin D → ℝ)
    (u z : Fin D → ℝ)
    (hmin : rankOneEnergy a z ≤ rankOneEnergy a (fun j => (u j+z j)/2)) :
    rankOneEnergy a (fun j => u j-z j) ≤ 2 * (rankOneEnergy a u - rankOneEnergy a z) := by
  rw [rankOneEnergy_midpoint_identity]
  linarith

lemma rankOneEnergy_controls_rows {m D : ℕ} (a : Fin m → Fin D → ℝ)
    (u z : Fin D → ℝ) :
    (∑ i, (linearEvaluation (a i) u-linearEvaluation (a i) z)^2) ≤
      rankOneEnergy a (fun j => u j-z j) := by
  simp only [rankOneEnergy, linearEvaluation_sub]
  exact le_add_of_nonneg_left (Finset.sum_nonneg (fun j _ => sq_nonneg _))

/-- The local metric comparison used in the geometric chaining step.
Both the rowwise oscillation bound and the row-energy distances are
explicit finite sums of actual linear evaluations. -/
theorem rankOneMetricSquared_local_comparison {m D : ℕ}
    (a : Fin m → Fin D → ℝ) (x y z : Fin D → ℝ) (R : ℝ)
    (hR : ∀ i, (linearEvaluation (a i) x-linearEvaluation (a i) y)^2 ≤ R) :
    rankOneMetricSquared a x y ≤
      2*R*((∑ i, (linearEvaluation (a i) x-linearEvaluation (a i) z)^2) +
        ∑ i, (linearEvaluation (a i) y-linearEvaluation (a i) z)^2) +
      4*∑ i, (linearEvaluation (a i) x-linearEvaluation (a i) y)^2 *
        linearEvaluation (a i) z ^ 2 := by
  have hpoint (i : Fin m) :
      (linearEvaluation (a i) x-linearEvaluation (a i) y)^2 *
        (linearEvaluation (a i) x^2+linearEvaluation (a i) y^2) ≤
      2*R*((linearEvaluation (a i) x-linearEvaluation (a i) z)^2+
        (linearEvaluation (a i) y-linearEvaluation (a i) z)^2) +
      4*(linearEvaluation (a i) x-linearEvaluation (a i) y)^2 * linearEvaluation (a i) z^2 := by
    let X := linearEvaluation (a i) x
    let Y := linearEvaluation (a i) y
    let Z := linearEvaluation (a i) z
    have h₁ : X^2 + Y^2 ≤ 2*((X-Z)^2+(Y-Z)^2)+4*Z^2 := by
      nlinarith only [sq_nonneg (X-2*Z), sq_nonneg (Y-2*Z)]
    have h₂ := mul_le_mul_of_nonneg_left h₁ (sq_nonneg (X-Y))
    have h₃ := mul_le_mul_of_nonneg_right (hR i)
      (show 0 ≤ (X-Z)^2+(Y-Z)^2 by positivity)
    change (X-Y)^2*(X^2+Y^2) ≤ 2*R*((X-Z)^2+(Y-Z)^2)+4*(X-Y)^2*Z^2
    nlinarith only [h₂, h₃]
  have hsum := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hpoint i)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, mul_assoc] at hsum
  simpa only [rankOneMetricSquared, Finset.sum_add_distrib, mul_assoc] using hsum

end NeuralGeneralization.SquaredSampling
