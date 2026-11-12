import NeuralGeneralization.BatchTwoContinuousSphereGaussianBand
import NeuralGeneralization.BatchTwoContinuousSphereLaw
import NeuralGeneralization.BatchTwoContinuousScoreSigns

/-! The literal 3 sqrt(d) tau spherical score-to-sign bound. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoContinuousSphere
open ConcreteModel

theorem direction_coordinate_mul_radius {d : ℕ} (x : Fin d → ℝ) (i : Fin d) :
    direction x i * radius x = x i := by
  by_cases h : radius x = 0
  · have hz := (radius_eq_zero_iff x).mp h
    simp [direction, hz]
  · exact div_mul_cancel₀ _ h

/-- The normalized Gaussian construction gives the full uniform spherical
law. The printed bound holds, in fact, for every positive tau. -/
theorem spherical_tanh_anticoncentration (n : ℕ) {τ : ℝ} (hτ : 0 < τ) :
    uniformSphere (n+1) {x | |Real.tanh (x 0)| ≤ τ} ≤
      ENNReal.ofReal (3*Real.sqrt ((n:ℝ)+1)*τ) := by
  have hroot : 1 ≤ Real.sqrt ((n:ℝ)+1) := by
    apply (Real.le_sqrt (by norm_num) (by positivity)).mpr
    simp
  by_cases hlarge : 1/3 ≤ τ
  · have hm : uniformSphere (n+1) {x | |Real.tanh (x 0)| ≤ τ} ≤ 1 := by
      simpa only [measure_univ] using
        (measure_mono (Set.subset_univ {x : Fin (n+1) → ℝ | |Real.tanh (x 0)| ≤ τ}) :
          uniformSphere (n+1) _ ≤ uniformSphere (n+1) Set.univ)
    apply hm.trans
    apply ENNReal.one_le_ofReal.mpr
    nlinarith
  · have hsmall : τ ≤ 1/3 := le_of_lt (lt_of_not_ge hlarge)
    have hset : MeasurableSet {x : Fin (n+1) → ℝ | |Real.tanh (x 0)| ≤ τ} :=
      measurableSet_le ((tanh_continuous.measurable.comp (measurable_pi_apply 0)).abs) measurable_const
    rw [uniformSphere, Measure.map_apply (measurable_direction (n+1)) hset]
    have hs := gaussian_coordinate_band n (by positivity : 0 ≤ 2*τ) (by linarith : 2*τ ≤ 2/3)
    apply le_trans (measure_mono ?_) (hs.trans_eq ?_)
    · intro x hx
      have ht : |direction x 0| ≤ 2*τ :=
        (abs_le_twice_abs_tanh (direction_coordinate_bound x 0)).trans
          (mul_le_mul_of_nonneg_left hx (by norm_num))
      have hh := mul_le_mul_of_nonneg_right ht (radius_nonneg x)
      have he : |direction x 0| * radius x = |x 0| := by
        rw [← abs_of_nonneg (radius_nonneg x), ← abs_mul, direction_coordinate_mul_radius]
      rw [he] at hh
      exact hh
    · congr 1
      ring

theorem spherical_tanh_anticoncentration_real (n : ℕ) {τ : ℝ} (hτ : 0 < τ) :
    (uniformSphere (n+1)).real {x | |Real.tanh (x 0)| ≤ τ} ≤
      3*Real.sqrt ((n:ℝ)+1)*τ := by
  have h := ENNReal.toReal_mono ENNReal.ofReal_ne_top (spherical_tanh_anticoncentration n hτ)
  simpa only [Measure.real, ENNReal.toReal_ofReal (by positivity : 0 ≤ 3*Real.sqrt ((n:ℝ)+1)*τ)] using h

/-- On the regression success event, epsilon/2 regression error with the
paper's tau gives at most epsilon sign-confidence failure over the sphere. -/
theorem spherical_score_to_sign {n N r : ℕ}
    (φ : ℝ → ℝ) (Q : Measure (Weights (n+1) N r)) [IsFiniteMeasure Q]
    {ε : ℝ} (hε : 0 < ε)
    (hreg : BatchTwoContinuous.confidenceFailure φ (uniformSphere (n+1)) Q
      (fun x => Real.tanh (x 0)) (ε/(6*Real.sqrt ((n:ℝ)+1))) ≤ ε/2) :
    BatchTwoContinuous.Classification.confidenceFailure φ (uniformSphere (n+1)) Q
      (BatchTwoContinuous.scoreLabel (fun x => Real.tanh (x 0))) ≤ ε := by
  have hr : 0 < Real.sqrt ((n:ℝ)+1) := Real.sqrt_pos.mpr (by positivity)
  have ht : 0 < ε/(6*Real.sqrt ((n:ℝ)+1)) := by positivity
  have hb := spherical_tanh_anticoncentration_real n ht
  have he : 3*Real.sqrt ((n:ℝ)+1)*(ε/(6*Real.sqrt ((n:ℝ)+1))) = ε/2 := by field_simp; ring
  rw [he] at hb
  exact (BatchTwoContinuous.score_to_sign_confidence φ (uniformSphere (n+1)) Q
    (fun x => Real.tanh (x 0)) ht.le).trans (by linarith)

end NeuralGeneralization.BatchTwoContinuousSphere
