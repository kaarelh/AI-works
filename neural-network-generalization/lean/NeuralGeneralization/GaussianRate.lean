import NeuralGeneralization.GaussianRateReduction
import NeuralGeneralization.GaussianTail
import NeuralGeneralization.GaussianSmallBall

/-!
# The finite-dimensional Gaussian small-variance rate

For every nonempty open set of a finite real coordinate space, the actual
isotropic Gaussian measure has exponential rate one half of the infimum
squared Euclidean norm. The proof uses a near-optimal contained rectangle
for the lower bound and the exact quadratic Gaussian Chernoff estimate for
the upper bound. No large-deviation principle is assumed as a hypothesis.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators Topology NNReal

namespace NeuralGeneralization.GaussianRate

variable {ι : Type*} [Fintype ι]

/-- The actual finite product of centered Gaussians of variance `t`, converted
to real mass. Only positive `t` is used by the right-neighborhood limit. -/
def isotropicMass (V : Set (ι → ℝ)) (t : ℝ) : ℝ :=
  (Measure.pi fun _ : ι => gaussianReal 0 t.toNNReal).real V

/-- A fixed positive prefactor lower bound for rectangles, uniformly over
variances at most one. This avoids any asymptotic logarithmic-volume claim. -/
theorem rectangle_mass_lower_fixed_prefactor (a : ι → ℝ) (r : ℝ) (hr : 0 < r)
    (t : ℝ) (ht : 0 < t) (ht1 : t ≤ 1) :
    ((2 * r) * (Real.sqrt (2 * Real.pi))⁻¹) ^ Fintype.card ι *
      Real.exp (-(∑ i, (|a i| + r) ^ 2) / (2 * t)) ≤
        isotropicMass (Set.pi Set.univ fun i => Set.Icc (a i - r) (a i + r)) t := by
  classical
  have htv : (t.toNNReal : ℝ) = t := Real.coe_toNNReal t ht.le
  have htn : t.toNNReal ≠ 0 := by
    intro h
    have hh := congrArg (fun z : ℝ≥0 => (z : ℝ)) h
    rw [htv] at hh
    exact ht.ne' hh
  have hsmall := GaussianTail.gaussian_rectangle_mass_lower a (fun _ => r)
    (fun _ => hr.le) (fun _ => t.toNNReal) (fun _ => htn)
  simp only [htv] at hsmall
  exact (rectangle_prefactor_product_le a r hr t ht ht1).trans hsmall

/-- The actual finite-dimensional isotropic Gaussian small-variance rate for
any nonempty open event, including the zero-dimensional coordinate space. -/
theorem gaussian_open_event_hasExponentialRate {V : Set (ι → ℝ)}
    (hV : IsOpen V) (hne : V.Nonempty) :
    HasExponentialRate (𝓝[>] (0 : ℝ)) (fun t => 1 / t)
      (isotropicMass V) (squareInf V / 2) := by
  apply open_event_rate_of_gaussian_bounds (isotropicMass (ι := ι))
  · intro t A B hAB
    exact measureReal_mono hAB
  · exact rectangle_mass_lower_fixed_prefactor
  · intro t ht b θ hθ0 hθ1
    have htv : (t.toNNReal : ℝ) = t := Real.coe_toNNReal t ht.le
    have h := GaussianTail.gaussian_squaredNorm_rate_upper (ι := ι)
      t.toNNReal (by rwa [htv]) b θ hθ0 hθ1
    simpa only [htv, isotropicMass] using h
  · exact hV
  · exact hne

end NeuralGeneralization.GaussianRate
