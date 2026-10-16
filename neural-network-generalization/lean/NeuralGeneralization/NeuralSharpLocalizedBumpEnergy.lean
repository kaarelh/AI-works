import NeuralGeneralization.NeuralLocalizedInterpolation
import NeuralGeneralization.IteratedArcsineLevelBounds

/-! # Sharp localized-bump energy for every actual neural depth

The depth-dependent eigenvalue lower bound gives energy of order
(d+1)^(1/2^(k+1)), with an exponentially small high-degree remainder.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel

def sharpLowConstant (k : ℕ) : ℝ := (iteratedArcsine_low_level_floor k).choose
lemma sharpLowConstant_pos (k : ℕ) : 0 < sharpLowConstant k :=
  (iteratedArcsine_low_level_floor k).choose_spec.1
lemma sharp_low_floor {d : ℕ} (hd : 101 ≤ d) (k : ℕ)
    (S : Finset (Fin d)) (hdeg : 100*S.card < 49*d) :
    sharpLowConstant k/((d:ℝ)+1)^(1+1/(2:ℝ)^(k+1)) ≤
      (d.choose S.card:ℝ)*walshCoefficients (arcsineProfile d (k+1)) S :=
  (iteratedArcsine_low_level_floor k).choose_spec.2 d hd S hdeg

def sharpEnergyBudget (d k : ℕ) : ℝ :=
  (40000/sharpLowConstant k)*((d:ℝ)+1)^(1/(2:ℝ)^(k+1))+
    (99/100:ℝ)^d/neuralFloor d k

lemma sharpEnergyBudget_pos (d k : ℕ) : 0 < sharpEnergyBudget d k := by
  unfold sharpEnergyBudget
  have := sharpLowConstant_pos k
  have := neuralFloor_pos d k
  positivity

/-- Actual diagonal bump energy with the exact neural depth exponent. -/
theorem sharp_diagonalEnergy_bound {d : ℕ} (hd : 101 ≤ d) (k : ℕ) :
    diagonalEnergy (walshCoefficients (arcsineProfile d (k+1))) ≤ sharpEnergyBudget d k := by
  have hc := sharpLowConstant_pos k
  have hD : 0 < (d:ℝ)+1 := by positivity
  have hb := diagonalEnergy_le_low_plus_exponential
    (walshCoefficients (arcsineProfile d (k+1))) (iterated_arcsine_coefficient_pos d k)
    (neuralFloor d k) (sharpLowConstant k/((d:ℝ)+1)^(1+1/(2:ℝ)^(k+1)))
    (neuralFloor_pos d k) (div_pos hc (by positivity))
    (iterated_arcsine_full_coefficient_polynomial_lower (by omega) k)
    (sharp_low_floor hd k)
  have he : 40000/(((d:ℝ)+1)*(sharpLowConstant k/((d:ℝ)+1)^(1+1/(2:ℝ)^(k+1)))) =
      (40000/sharpLowConstant k)*((d:ℝ)+1)^(1/(2:ℝ)^(k+1)) := by
    rw [Real.rpow_add hD, Real.rpow_one]
    field_simp
  simpa only [he, sharpEnergyBudget] using hb

theorem sharp_bump_energy_bound {d : ℕ} (hd : 101 ≤ d) (k : ℕ) (z : ClippingCube d) :
    featureEnergy (walshCoefficients (arcsineProfile d (k+1))) (walshCoefficients (bump z)) ≤
      sharpEnergyBudget d k := by
  rw [bump_energy]
  exact sharp_diagonalEnergy_bound hd k

/-- The actual global interpolant, simultaneously for all labelings, has
sharp depth-dependent energy on a quantitatively probable sample event. -/
theorem sharp_global_interpolant_probability {d : ℕ} (hd : 101 ≤ d)
    (k n R : ℕ) (hR : 0 < R) (A q : ℝ) (hA : 0 < A) (hq : 0 < q)
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20) :
    1-(n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*R)-
      (n:ℝ)^2*Real.sqrt (neuralCoordinateBudget d k*sharpEnergyBudget d k)/q ≤
    sampleProbability (uniformLaw d) n (fun s => ∀ f : BooleanFunction d,
      ∃ P : ClippingCube d → ℝ, (∀ x, A < |P x|) ∧
        (∀ i, A < labelReal (f (s i))*P (s i)) ∧
        featureEnergy (walshCoefficients (arcsineProfile d (k+1))) (walshCoefficients P) ≤
          8*A^2*(1/walshCoefficients (arcsineProfile d (k+1)) ∅+
            4*((n:ℝ)*sharpEnergyBudget d k+q))) := by
  have hb := sharp_diagonalEnergy_bound hd k
  have hh := global_interpolant_probability
    (walshCoefficients (arcsineProfile d (k+1))) (iterated_arcsine_coefficient_pos d k)
    A (sharpEnergyBudget d k) (neuralCoordinateBudget d k) q hA
    (neuralCoordinateBudget_pos d k).le hq hb
    (neural_coefficient_energy_max (by omega) k) R hR hsmall
  refine le_trans ?_ hh
  have hs := Real.sqrt_le_sqrt (mul_le_mul_of_nonneg_left hb (neuralCoordinateBudget_pos d k).le)
  have hm := div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left hs (sq_nonneg (n:ℝ))) hq.le
  linarith

end NeuralGeneralization.LocalizedCubeBump
