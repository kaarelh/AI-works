import Paulsen.SmoothGraphConcentration
import Mathlib.Analysis.Complex.ExponentialBounds

/-! A fixed failure probability for the actual centered tangent graph. -/
namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory Matrix.Norms.Elementwise
noncomputable section

local instance {n : ℕ} : ContinuousENorm (Matrix (Fin n) (Fin n) ℝ) :=
  inferInstanceAs (ContinuousENorm (Fin n → Fin n → ℝ))

/-- Dimension logarithmic in the number of rows suffices for uniform graph concentration. -/
theorem retainedTangentGraph_operator_failure_le {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) (hd : 0 < d) {ρ δ : ℝ}
    (hρ : 0 ≤ ρ) (hδ : 0 < δ) (hδ1 : δ ≤ 1)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n)
    (hlarge : 1000000000000 * (Real.log n + 2) ≤ δ ^ 2 * d) :
    (stdGaussian (FrameVector n d)).real {g | δ * d / n <
      ‖matrixEuclideanOperator (graphLaplacian
        (centeredGaussianSchurSquare (retainedTangentFactor U ρ) g))‖} ≤ 1 / 100 := by
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr (Nat.pos_of_ne_zero (NeZero.ne n))
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne n)
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have hL : 0 ≤ Real.log n := Real.log_nonneg hn1
  have hδsq : δ ^ 2 ≤ 1 := by nlinarith
  have hδsq' : δ ^ 2 ≤ δ := by nlinarith
  have hcap := mul_le_mul_of_nonneg_right hδsq hdR.le
  have hcap' := mul_le_mul_of_nonneg_right hδsq' hdR.le
  have hlog : Real.log n ≤ (d : ℝ) := by nlinarith
  have ht : 0 < δ * d / (2 * n) := by positivity
  have htail := retainedTangentGraph_operator_tail hU hd hρ ht ht hnear hlog
  have hthreshold : δ * (d : ℝ) / (2 * n) + δ * d / (2 * n) = δ * d / n := by ring
  have hexp1 : (n : ℝ)^2 * (δ * d / (2 * n))^2 / (192 * d) = δ^2 * d / 768 := by
    field_simp
    ring
  have hexp2 : (n : ℝ) * (δ * d / (2 * n)) / 32 = δ * d / 64 := by
    field_simp
    ring
  rw [hthreshold, hexp1, hexp2] at htail
  have hmin : Real.log n + 400 ≤ min (δ ^ 2 * d / 768) (δ * d / 64) := by
    apply le_min <;> nlinarith
  have hdegree : 2 * (n : ℝ) * Real.exp (-min (δ ^ 2 * d / 768) (δ * d / 64)) ≤ 1 / 200 := by
    calc
      _ ≤ 2 * n * Real.exp (-(Real.log n + 400)) := by gcongr
      _ = 2 * Real.exp (-400) := by
        rw [neg_add, Real.exp_add, Real.exp_neg (Real.log n), Real.exp_log hn]
        field_simp
      _ ≤ 1 / 200 := by
        rw [Real.exp_neg, ← div_eq_mul_inv]
        apply (div_le_iff₀ (Real.exp_pos _)).mpr
        linarith [Real.add_one_le_exp (400 : ℝ)]
  have hA : 80 * Real.exp 1 * (d : ℝ) * (Real.log n + 2) ≤
      (δ * d / 1600) ^ 2 := by
    have hA3 : 80 * Real.exp 1 * (d : ℝ) * (Real.log n + 2) ≤
        240 * d * (Real.log n + 2) := by
      have := mul_le_mul_of_nonneg_right Real.exp_one_lt_three.le
        (show 0 ≤ 80 * (d : ℝ) * (Real.log n + 2) by positivity)
      nlinarith
    have hbig := mul_le_mul_of_nonneg_right hlarge hdR.le
    nlinarith
  have hsqrt : Real.sqrt (80 * Real.exp 1 * (d : ℝ) * (Real.log n + 2)) ≤ δ * d / 1600 :=
    (Real.sqrt_le_iff).mpr ⟨by positivity, hA⟩
  have hschur : (4 * Real.sqrt (80 * Real.exp 1 * (d : ℝ) * (Real.log n + 2)) / n) /
      (δ * d / (2 * n)) ≤ 1 / 200 := by
    have he : (4 * Real.sqrt (80 * Real.exp 1 * (d : ℝ) * (Real.log n + 2)) / n) /
        (δ * d / (2 * n)) =
        8 * Real.sqrt (80 * Real.exp 1 * (d : ℝ) * (Real.log n + 2)) / (δ * d) := by
      field_simp
      ring
    rw [he]
    apply (div_le_iff₀ (mul_pos hδ hdR)).mpr
    linarith
  exact htail.trans (by linarith)

end
end Paulsen.Smooth
