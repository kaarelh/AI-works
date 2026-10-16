import NeuralGeneralization.NeuralLocalizedBumpEnergy
import NeuralGeneralization.LocalizedBumpInterpolationProbability

/-! # Explicit all-depth neural global-margin interpolation

This is the actual neural-kernel instantiation of the finite localized
comparator. Its O_L(sqrt d) energy is deliberately distinguished from the
sharper depth-dependent exponent still needed by the strongest argument.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel

def neuralEnergyBudget (d k : ℕ) : ℝ :=
  40000/((d+1:ℝ)*neuralLowFloor d k)+(99/100:ℝ)^d/neuralFloor d k

def neuralCoordinateBudget (d k : ℕ) : ℝ := (18/25:ℝ)^d/neuralFloor d k

lemma neuralEnergyBudget_pos (d k : ℕ) : 0 < neuralEnergyBudget d k := by
  unfold neuralEnergyBudget
  have := neuralLowFloor_pos d k
  have := neuralFloor_pos d k
  positivity

lemma neuralCoordinateBudget_pos (d k : ℕ) : 0 < neuralCoordinateBudget d k := by
  unfold neuralCoordinateBudget
  exact div_pos (by positivity) (neuralFloor_pos d k)

/-- All spectral terms in this success probability are explicit scalar
functions of dimension and depth; the kernel is the actual arcsine kernel. -/
theorem neural_global_interpolant_probability {d : ℕ} (hd : 101 ≤ d)
    (k n R : ℕ) (hR : 0 < R) (A q : ℝ) (hA : 0 < A) (hq : 0 < q)
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20) :
    1-(n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*R)-
      (n:ℝ)^2*Real.sqrt (neuralCoordinateBudget d k*neuralEnergyBudget d k)/q ≤
    sampleProbability (uniformLaw d) n (fun s => ∀ f : BooleanFunction d,
      ∃ P : ClippingCube d → ℝ, (∀ x, A < |P x|) ∧
        (∀ i, A < labelReal (f (s i))*P (s i)) ∧
        featureEnergy (walshCoefficients (arcsineProfile d (k+1))) (walshCoefficients P) ≤
          8*A^2*(1/walshCoefficients (arcsineProfile d (k+1)) ∅+
            4*((n:ℝ)*neuralEnergyBudget d k+q))) := by
  have hb := neural_diagonalEnergy_bound hd k
  have hh := global_interpolant_probability
    (walshCoefficients (arcsineProfile d (k+1))) (iterated_arcsine_coefficient_pos d k)
    A (neuralEnergyBudget d k) (neuralCoordinateBudget d k) q hA
    (neuralCoordinateBudget_pos d k).le hq hb
    (neural_coefficient_energy_max (by omega) k) R hR hsmall
  refine le_trans ?_ hh
  have hs := Real.sqrt_le_sqrt (mul_le_mul_of_nonneg_left hb (neuralCoordinateBudget_pos d k).le)
  have hm := div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left hs (sq_nonneg (n:ℝ))) hq.le
  dsimp only [neuralEnergyBudget]
  linarith

end NeuralGeneralization.LocalizedCubeBump
