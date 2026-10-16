import NeuralGeneralization.KernelComposition
import NeuralGeneralization.ArcsineSeries

/-!
# Positive spectrum of the actual iterated arcsine covariance

The scalar link is the normalized arcsine map, with its proven closed-interval
series. The first layer is strictly positive in every Walsh direction through
an explicit odd tensor feature. Every later layer retains this lower bound
times the positive linear coefficient. No spectral-positivity hypothesis for
the neural covariance is assumed.
-/

noncomputable section

namespace NeuralGeneralization

open Filter
open scoped BigOperators Topology

/-- The actual normalized arcsine recurrence. -/
def iteratedArcsine : ℕ → ℝ → ℝ
  | 0, t => t
  | k + 1, t => arcsineLink (iteratedArcsine k t)

def arcsineProfile (d k : ℕ) : ClippingCube d → ℝ :=
  biasedProfile (iteratedArcsine k)

def arcsineCovariance (d k : ℕ) (x y : ClippingCube d) : ℝ :=
  iteratedArcsine k (biasedDot x y)

theorem abs_biasedProfile_id_le_one {d : ℕ} (x : ClippingCube d) :
    |biasedProfile id x| ≤ 1 := by
  have hsign (i : Fin d) : |cubeCoordinateSign (x i)| = 1 := by
    cases x i <;> simp [cubeCoordinateSign]
  have hsum : |∑ i, cubeCoordinateSign (x i)| ≤ (d : ℝ) := by
    calc
      _ ≤ ∑ i, |cubeCoordinateSign (x i)| := Finset.abs_sum_le_sum_abs _ _
      _ = (d : ℝ) := by simp [hsign]
  have hbound : |1 + ∑ i, cubeCoordinateSign (x i)| ≤ (d + 1 : ℝ) := by
    have h := abs_add_le (1 : ℝ) (∑ i, cubeCoordinateSign (x i))
    norm_num at h
    linarith
  unfold biasedProfile
  simp only [id_eq, abs_div, abs_of_pos (show (0 : ℝ) < d + 1 by positivity)]
  exact (div_le_one (by positivity : (0 : ℝ) < d + 1)).mpr hbound

theorem abs_iteratedArcsine_le_one {t : ℝ} (ht : |t| ≤ 1) (k : ℕ) :
    |iteratedArcsine k t| ≤ 1 := by
  cases k with
  | zero => exact ht
  | succ k => exact abs_arcsineLink_le_one _

theorem abs_arcsineProfile_le_one (d k : ℕ) (x : ClippingCube d) :
    |arcsineProfile d k x| ≤ 1 :=
  abs_iteratedArcsine_le_one (abs_biasedProfile_id_le_one x) k

theorem arcsineProfile_series (d k : ℕ) (x : ClippingCube d) :
    Tendsto (fun N => ∑ n ∈ Finset.range N,
      arcsineLinkCoefficient n * arcsineProfile d k x ^ (2 * n + 1))
      atTop (𝓝 (arcsineProfile d (k + 1) x)) := by
  exact (hasSum_arcsineLink_closed (abs_arcsineProfile_le_one d k x)).tendsto_sum_nat

/-- An explicit strictly positive bound for every first-layer population
Walsh eigenvalue, including the parity direction. -/
theorem first_arcsine_coefficient_lower (d : ℕ) (S : Finset (Fin d)) :
    arcsineLinkCoefficient d / (d + 1 : ℝ) ^ (2 * d + 1) ≤
      walshCoefficients (arcsineProfile d 1) S := by
  have hbase : ∀ T, 0 ≤ walshCoefficients (arcsineProfile d 0) T := by
    intro T
    simpa only [arcsineProfile, iteratedArcsine, pow_one] using
      biasedDot_power_coefficient_nonneg (d := d) 1 T
  have hterm := profile_series_coefficient_term_lower
    (arcsineProfile d 0) (arcsineProfile d 1) arcsineLinkCoefficient (fun n => 2 * n + 1)
    hbase (fun n => (arcsineLinkCoefficient_pos n).le) (arcsineProfile_series d 0) d S
  have hpower : 1 / (d + 1 : ℝ) ^ (2 * d + 1) ≤
      walshCoefficients (fun x => arcsineProfile d 0 x ^ (2 * d + 1)) S := by
    have he : d + (d + 1) = 2 * d + 1 := by omega
    have h := biasedDot_power_coefficient_lower S (d + 1)
    rw [he] at h
    exact h
  have hlower := mul_le_mul_of_nonneg_left hpower (arcsineLinkCoefficient_pos d).le
  have hlower' : arcsineLinkCoefficient d / (d + 1 : ℝ) ^ (2 * d + 1) ≤
      arcsineLinkCoefficient d *
        walshCoefficients (fun x => arcsineProfile d 0 x ^ (2 * d + 1)) S := by
    simpa only [mul_one_div] using hlower
  exact hlower'.trans hterm

theorem first_arcsine_coefficient_pos (d : ℕ) (S : Finset (Fin d)) :
    0 < walshCoefficients (arcsineProfile d 1) S := by
  exact (div_pos (arcsineLinkCoefficient_pos d) (by positivity)).trans_le
    (first_arcsine_coefficient_lower d S)

/-- Every additional depth retains at least the positive linear fraction of
each first-layer coefficient. -/
theorem iterated_arcsine_coefficient_lower (d k : ℕ) (S : Finset (Fin d)) :
    (2 / Real.pi) ^ k * walshCoefficients (arcsineProfile d 1) S ≤
      walshCoefficients (arcsineProfile d (k + 1)) S := by
  have h := iterated_profile_coefficient_lower (fun j => arcsineProfile d (j + 1))
    arcsineLinkCoefficient (fun n => 2 * n + 1)
    (fun T => (first_arcsine_coefficient_pos d T).le)
    (fun n => (arcsineLinkCoefficient_pos n).le) (by norm_num)
    (fun j => arcsineProfile_series d (j + 1)) k S
  simpa only [arcsineLinkCoefficient_zero] using h

theorem iterated_arcsine_coefficient_pos (d k : ℕ) (S : Finset (Fin d)) :
    0 < walshCoefficients (arcsineProfile d (k + 1)) S := by
  have hp : 0 < (2 / Real.pi : ℝ) ^ k := pow_pos (div_pos (by norm_num) Real.pi_pos) _
  exact (mul_pos hp (first_arcsine_coefficient_pos d S)).trans_le
    (iterated_arcsine_coefficient_lower d k S)

/-- Exact diagonalization of the actual recurrence on biased cube inputs. -/
theorem arcsineCovariance_walsh (d k : ℕ) (x y : ClippingCube d) :
    arcsineCovariance d k x y = walshKernel (walshCoefficients (arcsineProfile d k)) x y :=
  biasedDot_kernel_walsh (iteratedArcsine k) x y

/-- Explicit inverse kernel, using normalized Walsh eigenvalues. -/
def arcsinePrecision (d k : ℕ) : ClippingCube d → ClippingCube d → ℝ :=
  walshPrecisionKernel (walshCoefficients (arcsineProfile d k))

theorem arcsineCovariance_precision_mul (d k : ℕ) (x y : ClippingCube d) :
    (∑ z : ClippingCube d, arcsineCovariance d (k + 1) x z *
      arcsinePrecision d (k + 1) z y) = if x = y then (1 : ℝ) else 0 := by
  simpa only [arcsineCovariance_walsh, arcsinePrecision] using
    walshKernel_precision_mul (walshCoefficients (arcsineProfile d (k + 1)))
      (fun S => ne_of_gt (iterated_arcsine_coefficient_pos d k S)) x y

theorem arcsinePrecision_energy (d k : ℕ) (P : ClippingCube d → ℝ) :
    finiteQuadratic (arcsinePrecision d (k + 1)) P =
      featureEnergy (walshCoefficients (arcsineProfile d (k + 1))) (walshCoefficients P) :=
  walshPrecision_energy _ P (fun S => ne_of_gt (iterated_arcsine_coefficient_pos d k S))

/-- The actual iterated arcsine covariance is strictly positive definite
on the entire finite cube, not just positive semidefinite on a sample. -/
theorem arcsineCovariance_positiveDefinite (d k : ℕ) (b : ClippingCube d → ℝ)
    (hb : ∃ x, b x ≠ 0) : 0 < finiteQuadratic (arcsineCovariance d (k + 1)) b := by
  classical
  have hex : ∃ S, walshCoefficients b S ≠ 0 := by
    by_contra h
    push Not at h
    obtain ⟨x, hx⟩ := hb
    have he := walshExpansion_coefficients b x
    simp only [walshExpansion, h, zero_mul, Finset.sum_const_zero] at he
    exact hx he.symm
  obtain ⟨S, hS⟩ := hex
  have hsum : (∑ x : ClippingCube d, b x * walshCharacter S x) ≠ 0 := by
    intro h
    apply hS
    simp only [walshCoefficients, uniformCubeMean, h, zero_div]
  have hK : arcsineCovariance d (k + 1) =
      walshKernel (walshCoefficients (arcsineProfile d (k + 1))) :=
    funext fun x => funext fun y => arcsineCovariance_walsh d (k + 1) x y
  rw [hK]
  unfold walshKernel
  rw [show (fun x y => featureKernel walshCharacter
      (walshCoefficients (arcsineProfile d (k + 1))) x y) =
      (fun x y => featureKernel walshCharacter
        (walshCoefficients (arcsineProfile d (k + 1))) (id x) (id y)) from rfl]
  rw [featureKernel_quadratic]
  simp only [id_eq]
  exact (mul_pos (iterated_arcsine_coefficient_pos d k S) (sq_pos_of_ne_zero hsum)).trans_le
    (Finset.single_le_sum (fun T hT =>
      mul_nonneg (iterated_arcsine_coefficient_pos d k T).le (sq_nonneg (∑ x : ClippingCube d, b x * walshCharacter T x))) (Finset.mem_univ S))

end NeuralGeneralization
