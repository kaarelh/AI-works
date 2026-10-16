import NeuralGeneralization.WalshGaussianLaw
import NeuralGeneralization.GaussianDampedField

/-!
# Exact Walsh-feature energy of actual Gaussian comparators

Population Fourier energy is exactly Euclidean squared energy in the scalar
Gaussian coefficients. The equality also holds after damping selected feature
variances, and supplies the actual Gaussian conditioning denominator.
-/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal
namespace NeuralGeneralization.WalshGaussianEnergy
open FiniteDifferential GaussianAngularFields GaussianFieldTilt
variable {d : ℕ}

def matrix (w : Finset (Fin d) → ℝ) (x : ClippingCube d) (S : Finset (Fin d)) : ℝ :=
  WalshGaussianLaw.features w S x

def coefficients (w : Finset (Fin d) → ℝ) (P : ClippingCube d → ℝ) (S : Finset (Fin d)) : ℝ :=
  walshCoefficients P S/Real.sqrt (w S)

theorem field_coefficients (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (P : ClippingCube d → ℝ) : fieldLinear (matrix w) (coefficients w P) = P := by
  funext x
  rw [fieldLinear_apply]
  change (∑ S, (Real.sqrt (w S)*walshCharacter S x)*(walshCoefficients P S/Real.sqrt (w S))) = P x
  have he (S : Finset (Fin d)) :
      (Real.sqrt (w S)*walshCharacter S x)*(walshCoefficients P S/Real.sqrt (w S)) =
      walshCoefficients P S*walshCharacter S x := by
    field_simp [(Real.sqrt_pos.mpr (hw S)).ne']
  simp_rw [he]
  exact walshExpansion_coefficients P x

theorem coefficient_energy (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (P : ClippingCube d → ℝ) :
    (∑ S, coefficients w P S^2) = featureEnergy w (walshCoefficients P) := by
  unfold coefficients featureEnergy
  apply Finset.sum_congr rfl
  intro S hS
  rw [div_pow, Real.sq_sqrt (hw S)]

/-- The plain-function field and the actual Euclidean Walsh Gaussian used by
weak convergence are exactly the same law under the canonical identification. -/
theorem map_toLp_fieldLaw (w : Finset (Fin d) → ℝ) :
    (fieldLaw (matrix w)).map (toLp 2) = WalshGaussianLaw.law w := by
  unfold fieldLaw WalshGaussianLaw.law
  rw [Measure.map_map (WithLp.measurable_toLp 2 _) (fieldLinear (matrix w)).continuous.measurable]
  rw [GaussianFieldCovariance.toLp_field_eq_readout]
  rfl

def dampedCoefficients (w : Finset (Fin d) → ℝ) (v : Finset (Fin d) → ℝ≥0)
    (P : ClippingCube d → ℝ) (S : Finset (Fin d)) : ℝ :=
  walshCoefficients P S/(Real.sqrt (w S)*Real.sqrt (v S : ℝ))

theorem damped_field_coefficients (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (v : Finset (Fin d) → ℝ≥0) (hv : ∀ S, 0 < v S) (P : ClippingCube d → ℝ) :
    fieldLinear (fun x S => matrix w x S*Real.sqrt (v S : ℝ)) (dampedCoefficients w v P) = P := by
  funext x
  rw [fieldLinear_apply]
  change (∑ S, ((Real.sqrt (w S)*walshCharacter S x)*Real.sqrt (v S : ℝ))*
    (walshCoefficients P S/(Real.sqrt (w S)*Real.sqrt (v S : ℝ)))) = P x
  have he (S : Finset (Fin d)) :
      ((Real.sqrt (w S)*walshCharacter S x)*Real.sqrt (v S : ℝ))*
        (walshCoefficients P S/(Real.sqrt (w S)*Real.sqrt (v S : ℝ))) =
      walshCoefficients P S*walshCharacter S x := by
    have hvS : Real.sqrt (v S : ℝ) ≠ 0 := (Real.sqrt_pos.mpr (hv S)).ne'
    field_simp [(Real.sqrt_pos.mpr (hw S)).ne', hvS]
  simp_rw [he]
  exact walshExpansion_coefficients P x

theorem damped_coefficient_energy (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (v : Finset (Fin d) → ℝ≥0) (P : ClippingCube d → ℝ) :
    (∑ S, dampedCoefficients w v P S^2) =
      featureEnergy (fun S => w S*(v S : ℝ)) (walshCoefficients P) := by
  unfold dampedCoefficients featureEnergy
  apply Finset.sum_congr rfl
  intro S hS
  rw [div_pow, mul_pow, Real.sq_sqrt (hw S), Real.sq_sqrt (v S).coe_nonneg]

theorem damped_row_variance (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (v : Finset (Fin d) → ℝ≥0) (x : ClippingCube d) :
    (∑ S, (matrix w x S*Real.sqrt (v S : ℝ))^2) = ∑ S, w S*(v S : ℝ) := by
  apply Finset.sum_congr rfl
  intro S hS
  simp only [matrix, WalshGaussianLaw.features, mul_pow, Real.sq_sqrt (hw S),
    Real.sq_sqrt (v S).coe_nonneg, walshCharacter_sq, mul_one]

/-- The actual Gaussian event cost follows from the comparator's normalized
Walsh energy, with no unproved identification of energy and probability. -/
theorem damped_walsh_comparator_cost (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (v : Finset (Fin d) → ℝ≥0) (hv : ∀ S, 0 < v S) (hv1 : ∀ S, v S ≤ 1)
    (P : ClippingCube d → ℝ) (V t R : ℝ) (hV : 0 < V) (ht : 0 ≤ t)
    (hvar : (∑ S, w S*(v S : ℝ)) ≤ V)
    (hsize : 4*(Fintype.card (ClippingCube d) : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1)
    (henergy : featureEnergy (fun S => w S*(v S : ℝ)) (walshCoefficients P) ≤ R)
    (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hbuffer : ∀ z : ClippingCube d → ℝ, (∀ x, |z x-P x| < t) → z ∈ E) :
    Real.log (1/(fieldLaw (matrix w)).real E) ≤
      Real.log 2+R/2-Real.log (∏ S, Real.sqrt (v S : ℝ)) := by
  apply GaussianDiagonalComparison.damped_comparator_cost (matrix w) v hv hv1
    (dampedCoefficients w v P) V t R hV ht
  · intro x
    rw [damped_row_variance w (fun S => (hw S).le)]
    exact hvar
  · exact hsize
  · rwa [damped_coefficient_energy w (fun S => (hw S).le)]
  · exact hE
  · rw [damped_field_coefficients w hw v hv P]
    exact hbuffer

end NeuralGeneralization.WalshGaussianEnergy
