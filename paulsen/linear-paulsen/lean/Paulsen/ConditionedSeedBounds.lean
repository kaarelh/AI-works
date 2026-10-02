import Paulsen.TangentQuadraticMean
import Paulsen.TangentRemainderExpectation
import Paulsen.TangentDistance
import Paulsen.FrobeniusEnergy

/-!
# Covariance bounds for the actual conditioned seed

This connects the proved Gaussian mean and fluctuation estimates to the
deterministic near-Parseval expansion. The dense-core event is separate.
-/

namespace Paulsen

open MeasureTheory ProbabilityTheory
open scoped BigOperators

noncomputable def conditionedNoise {n d : ℕ} (X : Frame n d) (g : FrameVector n d) :
    Frame n d := frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g)

noncomputable def conditionedSeed {n d : ℕ} (X : Frame n d) (t : ℝ)
    (g : FrameVector n d) : Frame n d :=
  tangentSeed X (conditionedNoise X g) ((d : ℝ) / n) t

noncomputable def conditionedFluctuation {n d : ℕ} (X : Frame n d)
    (g : FrameVector n d) : EuclideanSpace ℝ (Fin d × Fin d) :=
  WithLp.toLp 2 (fun p => tangentQuadratic X (conditionedNoise X g) ((d : ℝ) / n) p.1 p.2 -
    tangentQuadraticMean X ((d : ℝ) / n) (tangentNoiseFactor X) p.1 p.2)

theorem matrixQuadratic_abs_le_frobenius {d : ℕ}
    (A : Matrix (Fin d) (Fin d) ℝ) (x : Fin d → ℝ) :
    |matrixQuadratic A x| ≤
      ‖(WithLp.toLp 2 (fun p : Fin d × Fin d => A p.1 p.2) :
        EuclideanSpace ℝ (Fin d × Fin d))‖ * vectorNormSq x := by
  let v : EuclideanSpace ℝ (Fin d × Fin d) := WithLp.toLp 2 (fun p => A p.1 p.2)
  let xx : EuclideanSpace ℝ (Fin d × Fin d) := WithLp.toLp 2 (fun p => x p.1 * x p.2)
  have heq : matrixQuadratic A x = inner ℝ v xx := by
    simp only [matrixQuadratic, PiLp.inner_apply, Real.inner_apply,
      v, xx, Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro j _
    apply Finset.sum_congr rfl
    intro k _
    ring
  rw [heq]
  have h := abs_real_inner_le_norm v xx
  rw [show ‖xx‖ = vectorNormSq x from vector_outer_norm x] at h
  exact h

theorem integrable_conditionedFluctuation_sq {n d : ℕ} (X : Frame n d) :
    Integrable (fun g => ‖conditionedFluctuation X g‖ ^ 2)
      (stdGaussian (FrameVector n d)) := by
  simp only [conditionedFluctuation, EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type]
  exact integrable_finsetSum _ (fun j _ => integrable_finsetSum _ (fun k _ =>
    (tangentQuadratic_centered_memLp X _ (tangentNoiseFactor X) j k).integrable_sq))

theorem integral_conditionedFluctuation_sq_le {n d : ℕ}
    (X : Frame n d) (hn : 0 < n) (hd : 0 < d) (hX : IsEqualNorm X) :
    (∫ g, ‖conditionedFluctuation X g‖ ^ 2 ∂stdGaussian (FrameVector n d)) ≤
      8 * (d : ℝ) ^ 2 / n := by
  simpa only [conditionedFluctuation, conditionedNoise, EuclideanSpace.real_norm_sq_eq,
    Fintype.sum_prod_type] using
    integral_sq_tangentQuadratic_conditioned_le hn X (by positivity) hX

theorem conditionedFluctuation_tail {n d : ℕ}
    (X : Frame n d) (hn : 0 < n) (hd : 0 < d) (hX : IsEqualNorm X)
    (s : ℝ) (hs : 0 < s) :
    (stdGaussian (FrameVector n d)).real {g | s ≤ ‖conditionedFluctuation X g‖ ^ 2} ≤
      (8 * (d : ℝ) ^ 2 / n) / s := by
  apply (le_div_iff₀ hs).mpr
  have h := mul_meas_ge_le_integral_of_nonneg
    (Filter.Eventually.of_forall (fun g => sq_nonneg ‖conditionedFluctuation X g‖))
    (integrable_conditionedFluctuation_sq X) s
  simpa only [mul_comm] using h.trans (integral_conditionedFluctuation_sq_le X hn hd hX)

theorem matrixQuadratic_one_eq {d : ℕ} (x : Fin d → ℝ) :
    matrixQuadratic (1 : Matrix (Fin d) (Fin d) ℝ) x = vectorNormSq x := by
  simp [matrixQuadratic, Matrix.one_apply, vectorNormSq, pow_two]

theorem conditionedQuadratic_bound {n d : ℕ} (X : Frame n d)
    (hn : 0 < n) (hd : 0 < d) (hX : IsEqualNorm X)
    (η b : ℝ) (hXp : IsNearlyParseval η X) (g : FrameVector n d)
    (hb : ‖conditionedFluctuation X g‖ ≤ b) (x : Fin d → ℝ) :
    |matrixQuadratic (tangentQuadratic X (conditionedNoise X g) ((d : ℝ) / n)) x| ≤
      (η + (d : ℝ) ^ 2 / n + b) * vectorNormSq x := by
  have hfl := (matrixQuadratic_abs_le_frobenius
    (tangentQuadratic X (conditionedNoise X g) ((d : ℝ) / n) -
      tangentQuadraticMean X ((d : ℝ) / n) (tangentNoiseFactor X)) x).trans
    (mul_le_mul_of_nonneg_right hb (vectorNormSq_nonneg x))
  have hmean := tangentQuadraticMean_conditioned_bias_le hn hd X hX x
  rw [matrixQuadratic_sub] at hfl
  rw [matrixQuadratic_sub, matrixQuadratic_sub, matrixQuadratic_one_eq,
    ← frameEnergy_eq_matrixQuadratic] at hmean
  obtain ⟨hfl₁, hfl₂⟩ := abs_le.mp hfl
  obtain ⟨hm₁, hm₂⟩ := abs_le.mp hmean
  obtain ⟨hX₁, hX₂⟩ := hXp x
  apply abs_le.mpr
  constructor <;> nlinarith

/-- On the stated two scalar good events, the actual seed has exact row
norms and the explicit covariance error used by the huge-row argument. -/
theorem conditionedSeed_equalNorm_and_nearParseval {n d : ℕ}
    (X : Frame n d) (hn : 0 < n) (hd : 0 < d) (hX : IsEqualNorm X)
    (η t b ρ : ℝ) (hXp : IsNearlyParseval η X) (g : FrameVector n d)
    (hb : ‖conditionedFluctuation X g‖ ≤ b)
    (hρ : tangentRemainderBudget (conditionedNoise X g) ((d : ℝ) / n) t ≤ ρ) :
    IsEqualNorm (conditionedSeed X t g) ∧
      IsNearlyParseval (η + t ^ 2 * (η + (d : ℝ) ^ 2 / n + b) + ρ)
        (conditionedSeed X t g) := by
  have ha : 0 < (d : ℝ) / n := by positivity
  have hc := tangentNoiseFactor_constraints X g
  refine ⟨tangentSeed_isEqualNorm X _ t ha hX hc.1, ?_⟩
  apply tangentSeed_isNearlyParseval_of_quadratic_bound X _ _ t η _ ρ ha hX hXp hc.2
  · exact conditionedQuadratic_bound X hn hd hX η b hXp g hb
  · simpa only [tangentRemainderBudget, Finset.sum_add_distrib, conditionedNoise] using hρ

end Paulsen
