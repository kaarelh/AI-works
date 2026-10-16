import NeuralGeneralization.RankOneGeometry
import Mathlib.Analysis.Convex.Topology

/-! A concrete quasimetric and convex balls for the rank-one process. -/
noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators

def rankOneDistance {m D : ℕ} (a : Fin m → Fin D → ℝ) (u v : Fin D → ℝ) : ℝ :=
  Real.sqrt (rankOneMetricSquared a u v)

lemma signedSquare_difference_sq (x y : ℝ) :
    (x*|x|-y*|y|)^2 = x^4+y^4-2*(x*y)*|x*y| := by
  rw [sub_sq, mul_pow, mul_pow, sq_abs, sq_abs, abs_mul]
  ring

lemma scalarRankDistanceSquared_le_signedSquare (x y : ℝ) :
    scalarRankDistanceSquared x y ≤ 2*(x*|x|-y*|y|)^2 := by
  rw [signedSquare_difference_sq]
  unfold scalarRankDistanceSquared
  by_cases hxy : 0 ≤ x*y
  · rw [abs_of_nonneg hxy]
    have h := mul_nonneg (sq_nonneg (x-y))
      (show 0 ≤ x^2+y^2+4*x*y by nlinarith only [sq_nonneg x, sq_nonneg y, hxy])
    nlinarith only [h]
  · rw [abs_of_neg (lt_of_not_ge hxy)]
    have h := mul_nonneg (sq_nonneg (x+y)) (add_nonneg (sq_nonneg x) (sq_nonneg y))
    nlinarith only [h]

lemma signedSquare_le_scalarRankDistanceSquared (x y : ℝ) :
    (x*|x|-y*|y|)^2 ≤ 2*scalarRankDistanceSquared x y := by
  rw [signedSquare_difference_sq]
  unfold scalarRankDistanceSquared
  by_cases hxy : 0 ≤ x*y
  · rw [abs_of_nonneg hxy]
    nlinarith only [sq_nonneg ((x-y)^2)]
  · rw [abs_of_neg (lt_of_not_ge hxy)]
    have h := mul_nonneg (add_nonneg (sq_nonneg x) (sq_nonneg y))
      (show 0 ≤ x^2+y^2-4*x*y by nlinarith only [sq_nonneg x, sq_nonneg y, lt_of_not_ge hxy])
    nlinarith only [h]

lemma scalarRankDistanceSquared_triangle (x y z : ℝ) :
    scalarRankDistanceSquared x y ≤
      8*(scalarRankDistanceSquared x z+scalarRankDistanceSquared z y) := by
  have hxy := scalarRankDistanceSquared_le_signedSquare x y
  have hxz := signedSquare_le_scalarRankDistanceSquared x z
  have hzy := signedSquare_le_scalarRankDistanceSquared z y
  have htri : (x*|x|-y*|y|)^2 ≤ 2*((x*|x|-z*|z|)^2+(z*|z|-y*|y|)^2) := by
    nlinarith only [sq_nonneg (x*|x|+y*|y|-2*z*|z|)]
  linarith

lemma rankOneMetricSquared_nonneg {m D : ℕ} (a : Fin m → Fin D → ℝ) (u v : Fin D → ℝ) :
    0 ≤ rankOneMetricSquared a u v := by
  unfold rankOneMetricSquared
  positivity

lemma rankOneMetricSquared_triangle {m D : ℕ} (a : Fin m → Fin D → ℝ) (u v w : Fin D → ℝ) :
    rankOneMetricSquared a u v ≤ 8*(rankOneMetricSquared a u w+rankOneMetricSquared a w v) := by
  have h := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
    scalarRankDistanceSquared_triangle (linearEvaluation (a i) u)
      (linearEvaluation (a i) v) (linearEvaluation (a i) w))
  simpa only [scalarRankDistanceSquared, rankOneMetricSquared,
    Finset.sum_add_distrib, ← Finset.mul_sum] using h

lemma rankOneDistance_nonneg {m D : ℕ} (a : Fin m → Fin D → ℝ) (u v : Fin D → ℝ) :
    0 ≤ rankOneDistance a u v := Real.sqrt_nonneg _

lemma rankOneDistance_sq {m D : ℕ} (a : Fin m → Fin D → ℝ) (u v : Fin D → ℝ) :
    rankOneDistance a u v ^ 2 = rankOneMetricSquared a u v :=
  Real.sq_sqrt (rankOneMetricSquared_nonneg a u v)

@[simp] lemma rankOneDistance_self {m D : ℕ} (a : Fin m → Fin D → ℝ) (u : Fin D → ℝ) :
    rankOneDistance a u u = 0 := by simp [rankOneDistance, rankOneMetricSquared]

lemma rankOneDistance_symm {m D : ℕ} (a : Fin m → Fin D → ℝ) (u v : Fin D → ℝ) :
    rankOneDistance a u v = rankOneDistance a v u := by
  unfold rankOneDistance
  congr 1
  unfold rankOneMetricSquared
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- The concrete distance obeys a uniform quasi-triangle inequality. -/
theorem rankOneDistance_triangle {m D : ℕ} (a : Fin m → Fin D → ℝ) (u v w : Fin D → ℝ) :
    rankOneDistance a u v ≤ 4*(rankOneDistance a u w+rankOneDistance a w v) := by
  have h := rankOneMetricSquared_triangle a u v w
  rw [← rankOneDistance_sq, ← rankOneDistance_sq, ← rankOneDistance_sq] at h
  have hpos := mul_nonneg (rankOneDistance_nonneg a u w) (rankOneDistance_nonneg a w v)
  have hsum : 0 ≤ 4*(rankOneDistance a u w+rankOneDistance a w v) := by
    exact mul_nonneg (by norm_num) (add_nonneg (rankOneDistance_nonneg a u w) (rankOneDistance_nonneg a w v))
  exact (sq_le_sq₀ (rankOneDistance_nonneg a u v) hsum).mp (by nlinarith only [h, hpos])

/-- Exact convexity of actual rank-one squared-distance sublevel sets. -/
theorem convex_rankOneMetricSquared_sublevel {m D : ℕ} (a : Fin m → Fin D → ℝ)
    (x : Fin D → ℝ) (R : ℝ) : Convex ℝ {y | rankOneMetricSquared a x y ≤ R} := by
  intro u hu v hv s t hs ht hst
  have h := rankOneMetricSquared_convex_ball a (fun i : Fin 2 => if i=0 then s else t)
    (fun i : Fin 2 => if i=0 then u else v)
    (fun i => by
      fin_cases i
      · simpa using hs
      · simpa using ht)
    (by simpa [Fin.sum_univ_two] using hst) x R
    (fun i => by
      fin_cases i
      · simpa using hu
      · simpa using hv)
  have heq : (fun j => s*u j+t*v j) = s • u+t • v := by ext j; rfl
  change rankOneMetricSquared a x (s • u+t • v) ≤ R
  rw [← heq]
  simpa [Fin.sum_univ_two] using h

/-- Zero rank-one distance identifies all actual row evaluations, even
when the row map has a nontrivial kernel. -/
theorem row_evaluation_eq_of_rankOneDistance_zero {m D : ℕ}
    (a : Fin m → Fin D → ℝ) (u v : Fin D → ℝ)
    (hzero : rankOneDistance a u v = 0) (i : Fin m) :
    linearEvaluation (a i) u = linearEvaluation (a i) v := by
  have hs : rankOneMetricSquared a u v = 0 := by
    rw [← rankOneDistance_sq, hzero]
    norm_num
  have hterm : (linearEvaluation (a i) u-linearEvaluation (a i) v)^2 *
      (linearEvaluation (a i) u^2+linearEvaluation (a i) v^2) ≤ rankOneMetricSquared a u v := by
    unfold rankOneMetricSquared
    exact Finset.single_le_sum
      (f := fun j : Fin m => (linearEvaluation (a j) u-linearEvaluation (a j) v)^2 *
        (linearEvaluation (a j) u^2+linearEvaluation (a j) v^2))
      (fun j _ => mul_nonneg (sq_nonneg _) (add_nonneg (sq_nonneg _) (sq_nonneg _)))
      (Finset.mem_univ i)
  rw [hs] at hterm
  have hzero' : (linearEvaluation (a i) u-linearEvaluation (a i) v)^2 *
      (linearEvaluation (a i) u^2+linearEvaluation (a i) v^2) = 0 :=
    le_antisymm hterm (mul_nonneg (sq_nonneg _) (add_nonneg (sq_nonneg _) (sq_nonneg _)))
  rcases mul_eq_zero.mp hzero' with h | h
  · exact sub_eq_zero.mp (sq_eq_zero_iff.mp h)
  · have hu : linearEvaluation (a i) u ^ 2 = 0 := by nlinarith only [h, sq_nonneg (linearEvaluation (a i) u), sq_nonneg (linearEvaluation (a i) v)]
    have hv : linearEvaluation (a i) v ^ 2 = 0 := by nlinarith only [h, sq_nonneg (linearEvaluation (a i) u), sq_nonneg (linearEvaluation (a i) v)]
    rw [sq_eq_zero_iff.mp hu, sq_eq_zero_iff.mp hv]

end NeuralGeneralization.SquaredSampling
