import NeuralGeneralization.CubeNoise
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds

/-!
# Spectral trace upper tails at every fixed depth

A direct proof uses cube noise and the elementary endpoint square-root
bound for the actual arcsine link. It does not require pointwise
asymptotics of the coefficients of the composed scalar series.
-/

noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

/-- The actual normalized arcsine link has a global square-root endpoint
bound on its full relevant interval. -/
theorem arcsineLink_endpoint_square {t : ℝ} (ht : |t| ≤ 1) :
    (1 - arcsineLink t) ^ 2 ≤ 2 * (1 - t) := by
  have hcos := Real.cos_le_one_sub_mul_cos_sq
    (x := Real.arccos t) (by
      rw [abs_of_nonneg (Real.arccos_nonneg t)]
      exact Real.arccos_le_pi t)
  rw [Real.cos_arccos (abs_le.mp ht).1 (abs_le.mp ht).2] at hcos
  have he : (1 - arcsineLink t) ^ 2 =
      2 * (2 / Real.pi ^ 2 * Real.arccos t ^ 2) := by
    unfold arcsineLink Real.arccos
    field_simp
  rw [he]
  linarith

def arcsineNoiseGap (d k : ℕ) (ρ : ℝ) : ℝ :=
  cubeNoiseMean ρ (fun x => 1 - arcsineProfile d k x)

theorem arcsineNoiseGap_nonneg (d k : ℕ) {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) : 0 ≤ arcsineNoiseGap d k ρ :=
  cubeNoiseMean_nonneg hρ0 hρ1 _ (fun x =>
    sub_nonneg.mpr (abs_le.mp (abs_arcsineProfile_le_one d k x)).2)

theorem arcsineNoiseGap_zero_le (d : ℕ) {ρ : ℝ} (hρ1 : ρ ≤ 1) :
    arcsineNoiseGap d 0 ρ ≤ 1 - ρ := by
  unfold arcsineNoiseGap
  rw [cubeNoiseMean_sub, cubeNoiseMean_const]
  change 1 - cubeNoiseMean ρ (biasedProfile (d := d) id) ≤ 1 - ρ
  rw [cubeNoiseMean_biasedProfile_id]
  apply sub_le_sub_left
  apply (le_div_iff₀ (by positivity : (0 : ℝ) < d + 1)).mpr
  nlinarith

/-- Each actual layer takes at most a square root of the mean endpoint
deficit, by finite weighted Cauchy--Schwarz. -/
theorem arcsineNoiseGap_square_le (d k : ℕ) {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) :
    arcsineNoiseGap d (k + 1) ρ ^ 2 ≤ 2 * arcsineNoiseGap d k ρ := by
  have hcs := cubeNoiseMean_square_le hρ0 hρ1 (fun x => 1 - arcsineProfile d (k + 1) x)
  have hm := cubeNoiseMean_mono hρ0 hρ1
    (fun x => (1 - arcsineProfile d (k + 1) x) ^ 2)
    (fun x => 2 * (1 - arcsineProfile d k x))
    (fun x => arcsineLink_endpoint_square (abs_arcsineProfile_le_one d k x))
  have he : cubeNoiseMean ρ (fun x => 2 * (1 - arcsineProfile d k x)) =
      2 * arcsineNoiseGap d k ρ := by
    unfold arcsineNoiseGap cubeNoiseMean
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro x hx
    ring
  exact hcs.trans (hm.trans_eq he)

/-- The exponent `2^(-k)` is obtained directly from the exact recurrence.
Natural powers avoid any ambiguity about real-power conventions. -/
theorem arcsineNoiseGap_power_le (d k : ℕ) {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) :
    (arcsineNoiseGap d k ρ / 2) ^ (2 ^ k) ≤ (1 - ρ) / 2 := by
  induction k with
  | zero =>
    simpa only [pow_zero, pow_one] using
      div_le_div_of_nonneg_right (arcsineNoiseGap_zero_le d hρ1) (by norm_num : (0 : ℝ) ≤ 2)
  | succ k ih =>
    have hrec : (arcsineNoiseGap d (k + 1) ρ / 2) ^ 2 ≤ arcsineNoiseGap d k ρ / 2 := by
      have h := arcsineNoiseGap_square_le d k hρ0 hρ1
      nlinarith
    calc
      _ = ((arcsineNoiseGap d (k + 1) ρ / 2) ^ 2) ^ (2 ^ k) := by
        rw [← pow_mul, pow_succ]
        congr 1
        omega
      _ ≤ (arcsineNoiseGap d k ρ / 2) ^ (2 ^ k) :=
        pow_le_pow_left₀ (sq_nonneg _) hrec _
      _ ≤ _ := ih

/-- An elementary reciprocal Bernoulli bound, including the endpoints. -/
theorem one_sub_pow_mul_le_one {t : ℝ} (ht1 : t ≤ 1) (r : ℕ) :
    (1 - t) ^ r * (1 + r * t) ≤ 1 := by
  induction r with
  | zero => simp
  | succ r ih =>
    have hfactor : (1 - t) * (1 + (r + 1 : ℝ) * t) ≤ 1 + r * t := by
      nlinarith [mul_nonneg (Nat.cast_nonneg (α := ℝ) r) (sq_nonneg t)]
    simp only [pow_succ, Nat.cast_add, Nat.cast_one]
    calc
      (1 - t) ^ r * (1 - t) * (1 + (r + 1 : ℝ) * t) =
          (1 - t) ^ r * ((1 - t) * (1 + (r + 1 : ℝ) * t)) := by ring
      _ ≤ (1 - t) ^ r * (1 + r * t) :=
        mul_le_mul_of_nonneg_left hfactor (pow_nonneg (by linarith) _)
      _ ≤ _ := ih

/-- All actual iterated arcsine profiles have normalized diagonal one. -/
theorem arcsineProfile_one (d k : ℕ) : arcsineProfile d k (fun _ => true) = 1 := by
  have hbase : biasedProfile (d := d) id (fun _ => true) = 1 := by
    simp [biasedProfile, cubeCoordinateSign, add_comm, show (d + 1 : ℝ) ≠ 0 by positivity]
  induction k with
  | zero => exact hbase
  | succ k ih =>
    change arcsineLink (arcsineProfile d k (fun _ => true)) = 1
    rw [ih, arcsineLink_one]

/-- Nonnegativity at depth zero follows from the degree-one power kernel. -/
theorem arcsineProfile_coefficient_nonneg (d k : ℕ) (S : Finset (Fin d)) :
    0 ≤ walshCoefficients (arcsineProfile d k) S := by
  cases k with
  | zero =>
    simpa only [arcsineProfile, iteratedArcsine, pow_one] using
      biasedDot_power_coefficient_nonneg (d := d) 1 S
  | succ k => exact (iterated_arcsine_coefficient_pos d k S).le

/-- A dimension-uniform, all-depth spectral trace bound. If `T_r` is the
sum of actual normalized eigenvalues of degree at least `r >= 1`, then
`2*r*(T_r/4)^(2^k) <= 1`, i.e. `T_r = O(r^(-2^(-k)))`.
This theorem is an upper-tail estimate, not the sample-complexity theorem. -/
theorem iterated_arcsine_spectral_tail_power (d k r : ℕ) (hr : 0 < r) :
    (2 * r : ℝ) * (walshSpectralTail (arcsineProfile d k) r / 4) ^ (2 ^ k) ≤ 1 := by
  classical
  have hr0 : (0 : ℝ) < r := Nat.cast_pos.mpr hr
  have hr1 : (1 : ℝ) ≤ r := by exact_mod_cast hr
  let ρ : ℝ := 1 - 1 / r
  have ht0 : 0 ≤ (1 / r : ℝ) := (one_div_pos.mpr hr0).le
  have ht1 : (1 / r : ℝ) ≤ 1 := (div_le_one hr0).mpr hr1
  have hρ0 : 0 ≤ ρ := by dsimp [ρ]; linarith
  have hρ1 : ρ ≤ 1 := by dsimp [ρ]; linarith
  have hpow : ρ ^ r ≤ 1 / 2 := by
    have h := one_sub_pow_mul_le_one ht1 r
    have he : (r : ℝ) * (1 / r : ℝ) = 1 := by field_simp
    rw [he] at h
    change ρ ^ r * (1 + 1) ≤ 1 at h
    linarith
  have htail0 : 0 ≤ walshSpectralTail (arcsineProfile d k) r :=
    Finset.sum_nonneg (fun S hS => arcsineProfile_coefficient_nonneg d k S)
  have hnoise := walshSpectralTail_noise_le (r := r) hρ0 hρ1 (arcsineProfile d k)
    (arcsineProfile_coefficient_nonneg d k) (arcsineProfile_one d k)
  have hscale : walshSpectralTail (arcsineProfile d k) r / 4 ≤ arcsineNoiseGap d k ρ / 2 := by
    change (1 - ρ ^ r) * walshSpectralTail (arcsineProfile d k) r ≤ arcsineNoiseGap d k ρ at hnoise
    nlinarith [mul_nonneg htail0 (sub_nonneg.mpr hpow)]
  have hpower := (pow_le_pow_left₀ (div_nonneg htail0 (by norm_num)) hscale (2 ^ k)).trans
    (arcsineNoiseGap_power_le d k hρ0 hρ1)
  have hfinal := mul_le_mul_of_nonneg_left hpower (show (0 : ℝ) ≤ 2 * r by positivity)
  have he : (2 * r : ℝ) * ((1 - ρ) / 2) = 1 := by
    dsimp [ρ]
    field_simp
    ring
  exact hfinal.trans_eq he

end NeuralGeneralization
