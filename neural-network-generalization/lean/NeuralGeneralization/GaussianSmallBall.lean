import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.MeasureTheory.Constructions.Pi
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

/-!
# Quantitative Gaussian interval mass

This density estimate is one coordinate of the cloning-cylinder lower bound.
It is proved for the actual Gaussian measure and does not assume a small-ball
probability as an abstract hypothesis. The multidimensional cloning-cylinder
construction and its free-direction operator bound remain separate obligations.
-/

noncomputable section

open MeasureTheory ProbabilityTheory
open scoped ENNReal NNReal
open scoped BigOperators

namespace NeuralGeneralization.GaussianTail

/-- Uniform lower bound for a Gaussian density on a centered finite interval. -/
theorem gaussianPDFReal_lower_on_interval (a r : ℝ) (hr : 0 ≤ r)
    (v : ℝ≥0) (x : ℝ) (hx : x ∈ Set.Icc (a - r) (a + r)) :
    (Real.sqrt (2 * Real.pi * (v : ℝ)))⁻¹ *
      Real.exp (-((|a| + r) ^ 2) / (2 * (v : ℝ))) ≤ gaussianPDFReal 0 v x := by
  have habs : |x| ≤ |a| + r := by
    apply abs_le.mpr
    constructor
    · linarith [hx.1, neg_abs_le a]
    · linarith [hx.2, le_abs_self a]
  have hsq : x ^ 2 ≤ (|a| + r) ^ 2 := by
    have hh := (sq_le_sq₀ (abs_nonneg x) (add_nonneg (abs_nonneg a) hr)).mpr habs
    simpa only [sq_abs] using hh
  rw [gaussianPDFReal_def]
  simp only [sub_zero]
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply Real.exp_le_exp.mpr
  exact div_le_div_of_nonneg_right (neg_le_neg hsq) (by positivity)

/-- Quantitative small-ball lower bound for a nondegenerate real Gaussian.
The radius is allowed to be zero; the lower bound is then zero. -/
theorem gaussian_interval_mass_lower (a r : ℝ) (hr : 0 ≤ r)
    (v : ℝ≥0) (hv : v ≠ 0) :
    (2 * r) * (Real.sqrt (2 * Real.pi * (v : ℝ)))⁻¹ *
      Real.exp (-((|a| + r) ^ 2) / (2 * (v : ℝ))) ≤
        (gaussianReal 0 v).real (Set.Icc (a - r) (a + r)) := by
  let c : ℝ := (Real.sqrt (2 * Real.pi * (v : ℝ)))⁻¹ *
    Real.exp (-((|a| + r) ^ 2) / (2 * (v : ℝ)))
  have hc : 0 ≤ c := by dsimp [c]; positivity
  have hmass : ENNReal.ofReal c * ENNReal.ofReal ((a + r) - (a - r)) ≤
      gaussianReal 0 v (Set.Icc (a - r) (a + r)) := by
    rw [gaussianReal_apply 0 hv, ← Real.volume_Icc, ← setLIntegral_const]
    apply setLIntegral_mono (measurable_gaussianPDF 0 v)
    intro x hx
    apply ENNReal.ofReal_le_ofReal
    exact gaussianPDFReal_lower_on_interval a r hr v x hx
  have hfinite := measure_ne_top (gaussianReal 0 v) (Set.Icc (a - r) (a + r))
  have hh := ENNReal.toReal_mono hfinite hmass
  rw [ENNReal.toReal_mul, ENNReal.toReal_ofReal hc,
    ENNReal.toReal_ofReal (by linarith : 0 ≤ (a + r) - (a - r))] at hh
  change c * ((a + r) - (a - r)) ≤ _ at hh
  calc
    _ = c * ((a + r) - (a - r)) := by dsimp [c]; ring
    _ ≤ _ := hh

/-- Product form of the interval estimate for independent Gaussian coordinates.
This is useful after selecting and rotating the constrained cylinder coordinates;
the rotation and the free-direction event require their own proofs. -/
theorem gaussian_rectangle_mass_lower {ι : Type*} [Fintype ι]
    (a r : ι → ℝ) (hr : ∀ i, 0 ≤ r i)
    (v : ι → ℝ≥0) (hv : ∀ i, v i ≠ 0) :
    (∏ i, (2 * r i) * (Real.sqrt (2 * Real.pi * (v i : ℝ)))⁻¹ *
      Real.exp (-((|a i| + r i) ^ 2) / (2 * (v i : ℝ)))) ≤
      (Measure.pi fun i => gaussianReal 0 (v i)).real
        (Set.pi Set.univ fun i => Set.Icc (a i - r i) (a i + r i)) := by
  classical
  have hprod := Finset.prod_le_prod
    (s := Finset.univ)
    (f := fun i => (2 * r i) * (Real.sqrt (2 * Real.pi * (v i : ℝ)))⁻¹ *
      Real.exp (-((|a i| + r i) ^ 2) / (2 * (v i : ℝ))))
    (g := fun i => (gaussianReal 0 (v i)).real (Set.Icc (a i - r i) (a i + r i)))
    (fun i _ => by
      have hi := hr i
      positivity)
    (fun i _ => gaussian_interval_mass_lower (a i) (r i) (hr i) (v i) (hv i))
  unfold Measure.real
  rw [Measure.pi_pi, ENNReal.toReal_prod]
  exact hprod

end NeuralGeneralization.GaussianTail
