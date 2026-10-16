import NeuralGeneralization.LocalizedBumpHighDegree
import NeuralGeneralization.LocalizedBumpDamping
import NeuralGeneralization.FirstLayerLevelLower
import NeuralGeneralization.KernelMixing

/-! # Unconditional actual neural localized-bump energy

The first layer has the sharp square-root dimension bound. The positive
linear term propagates this bound to every fixed depth, with an explicit
depth constant. This all-depth estimate is weaker than the sharp d^beta
estimate, but it has no unproved spectral premise.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump

def neuralFloor (d k : ℕ) : ℝ := (2/Real.pi)^k/(24*((d:ℝ)+1)^3)

def neuralLowFloor (d k : ℕ) : ℝ :=
  (2/Real.pi)^k*firstLayerLowLevelConstant/((d:ℝ)+1)^(3/2:ℝ)

lemma neuralFloor_pos (d k : ℕ) : 0 < neuralFloor d k := by unfold neuralFloor; positivity
lemma neuralLowFloor_pos (d k : ℕ) : 0 < neuralLowFloor d k := by
  unfold neuralLowFloor
  exact div_pos (mul_pos (by positivity) firstLayerLowLevelConstant_pos) (by positivity)

lemma neural_low_mode_floor {d : ℕ} (hd : 101 ≤ d) (k : ℕ)
    (S : Finset (Fin d)) (hdeg : 100*S.card < 49*d) :
    neuralLowFloor d k ≤ (d.choose S.card:ℝ)*walshCoefficients (arcsineProfile d (k+1)) S := by
  have hl := first_arcsine_low_level_floor hd S hdeg
  have hp := iterated_arcsine_coefficient_lower d k S
  have hm := mul_le_mul_of_nonneg_left hl (show 0 ≤ (2/Real.pi)^k by positivity)
  have hc := mul_le_mul_of_nonneg_left hp (show 0 ≤ (d.choose S.card:ℝ) by positivity)
  calc
    neuralLowFloor d k = (2/Real.pi)^k*(firstLayerLowLevelConstant/((d:ℝ)+1)^(3/2:ℝ)) := by unfold neuralLowFloor; ring
    _ ≤ (2/Real.pi)^k*((d.choose S.card:ℝ)*walshCoefficients (arcsineProfile d 1) S) := hm
    _ = (d.choose S.card:ℝ)*((2/Real.pi)^k*walshCoefficients (arcsineProfile d 1) S) := by ring
    _ ≤ _ := hc

/-- Explicit actual neural energy bound, including its exponentially small
high-degree remainder, valid at every fixed positive depth. -/
theorem neural_diagonalEnergy_bound {d : ℕ} (hd : 101 ≤ d) (k : ℕ) :
    diagonalEnergy (walshCoefficients (arcsineProfile d (k+1))) ≤
      40000/((d+1:ℝ)*neuralLowFloor d k)+(99/100:ℝ)^d/neuralFloor d k := by
  exact diagonalEnergy_le_low_plus_exponential _ (iterated_arcsine_coefficient_pos d k)
    (neuralFloor d k) (neuralLowFloor d k) (neuralFloor_pos d k) (neuralLowFloor_pos d k)
    (iterated_arcsine_full_coefficient_polynomial_lower (by omega) k)
    (neural_low_mode_floor hd k)

/-- The leading term is an explicit depth constant times sqrt(d+1). -/
lemma neural_leading_energy_eq (d k : ℕ) :
    40000/((d+1:ℝ)*neuralLowFloor d k) =
      (40000/((2/Real.pi)^k*firstLayerLowLevelConstant))*((d:ℝ)+1)^(1/2:ℝ) := by
  have hD : 0 < (d:ℝ)+1 := by positivity
  have hc : (2/Real.pi)^k*firstLayerLowLevelConstant ≠ 0 :=
    (mul_pos (by positivity) firstLayerLowLevelConstant_pos).ne'
  have he : ((d:ℝ)+1)^(3/2:ℝ)=((d:ℝ)+1)*((d:ℝ)+1)^(1/2:ℝ) := by
    rw [show (3/2:ℝ)=1+1/2 by norm_num, Real.rpow_add hD, Real.rpow_one]
  unfold neuralLowFloor
  rw [he]
  field_simp

/-- A concrete O_L(sqrt d) energy bound for the actual localized bump. -/
theorem neural_bump_energy_bound {d : ℕ} (hd : 101 ≤ d) (k : ℕ) (z : ClippingCube d) :
    featureEnergy (walshCoefficients (arcsineProfile d (k+1))) (walshCoefficients (bump z)) ≤
      (40000/((2/Real.pi)^k*firstLayerLowLevelConstant))*((d:ℝ)+1)^(1/2:ℝ)+
        (99/100:ℝ)^d/neuralFloor d k := by
  rw [bump_energy]
  simpa only [neural_leading_energy_eq] using neural_diagonalEnergy_bound hd k

/-- Uniform actual coordinate control for the random cross-energy bound. -/
theorem neural_coefficient_energy_max {d : ℕ} (hd : 1 ≤ d) (k : ℕ)
    (S : Finset (Fin d)) :
    coefficient d S.card^2/walshCoefficients (arcsineProfile d (k+1)) S ≤
      (18/25:ℝ)^d/neuralFloor d k :=
  coefficient_energy_max_le _ (iterated_arcsine_coefficient_pos d k)
    (neuralFloor d k) (neuralFloor_pos d k)
    (iterated_arcsine_full_coefficient_polynomial_lower hd k) S

end NeuralGeneralization.LocalizedCubeBump
