import NeuralGeneralization.GaussianSmallBall
import Mathlib.Tactic.FieldSimp

/-!
# A genuine Gaussian interval bound for the conditional amplitude argument

The bound is uniform over a bounded translated mean. It is proved directly
from the standard Gaussian density on an explicitly constructed interval,
without a normal-CDF estimate or a tail-probability assumption.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped NNReal
namespace NeuralGeneralization.GaussianAmplitude

/-- The length of the short standard-normal interval used below. -/
def intervalLength (t : ℝ) : ℝ := 1/(2*(t+1))

/-- A positive lower bound for entering the forbidden fixed-margin interval. -/
def smallBall (t : ℝ) : ℝ :=
  Real.exp (-(3/2 : ℝ))*Real.exp (-t^2/2)/(2*Real.sqrt (2*Real.pi)*(t+1))

theorem intervalLength_pos {t : ℝ} (ht : 0 ≤ t) : 0 < intervalLength t := by
  unfold intervalLength
  positivity

theorem intervalLength_le_half {t : ℝ} (ht : 0 ≤ t) : intervalLength t ≤ 1/2 := by
  unfold intervalLength
  apply (div_le_iff₀ (by positivity : 0 < 2*(t+1))).2
  linarith

theorem smallBall_pos {t : ℝ} (ht : 0 ≤ t) : 0 < smallBall t := by
  unfold smallBall
  positivity

/-- A nonnegative translated mean admits an interval close enough to zero.
The Gaussian noise scale is the actual standard deviation. -/
theorem exists_interval_nonneg_mean (a σ t h : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (hh0 : 0 ≤ h) (hh : h ≤ a+σ*t) :
    ∃ c : ℝ, |c|+intervalLength t/2 ≤ t+intervalLength t ∧
      Set.Icc (c-intervalLength t/2) (c+intervalLength t/2) ⊆
        {z | |h+σ*z| ≤ a} := by
  let q := max 0 ((h-a)/σ)
  let δ := intervalLength t
  have hδ : 0 < δ := intervalLength_pos ht
  have hδhalf : δ ≤ 1/2 := intervalLength_le_half ht
  have hq0 : 0 ≤ q := le_max_left _ _
  have hqt : q ≤ t := max_le ht ((div_le_iff₀ hσ).2 (by linarith))
  have hσδ : σ*δ ≤ a := by nlinarith
  refine ⟨-q-δ/2, ?_, ?_⟩
  · rw [abs_of_nonpos (by linarith : -q-δ/2 ≤ 0)]
    dsimp [δ]
    linarith
  · intro z hz
    have hz1 : -q-δ ≤ z := by linarith [hz.1]
    have hz2 : z ≤ -q := by linarith [hz.2]
    change |h+σ*z| ≤ a
    apply abs_le.mpr
    by_cases hha : h ≤ a
    · have hq : q = 0 := max_eq_left (div_nonpos_of_nonpos_of_nonneg (by linarith) hσ.le)
      rw [hq] at hz1 hz2
      constructor <;> nlinarith
    · have hq : q = (h-a)/σ := max_eq_right (div_nonneg (by linarith) hσ.le)
      have hqσ : σ*q = h-a := by rw [hq]; field_simp
      constructor <;> nlinarith

/-- Both mean signs are handled by reflecting the constructed interval. -/
theorem exists_interval (a σ t h : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (hh : |h| ≤ a+σ*t) :
    ∃ c : ℝ, |c|+intervalLength t/2 ≤ t+intervalLength t ∧
      Set.Icc (c-intervalLength t/2) (c+intervalLength t/2) ⊆
        {z | |h+σ*z| ≤ a} := by
  by_cases hh0 : 0 ≤ h
  · exact exists_interval_nonneg_mean a σ t h hσ ht ha hh0
      (by simpa only [abs_of_nonneg hh0] using hh)
  · have hhn : 0 ≤ -h := by linarith
    obtain ⟨c,hc,hI⟩ := exists_interval_nonneg_mean a σ t (-h) hσ ht ha hhn
      (by simpa only [abs_of_neg (lt_of_not_ge hh0)] using hh)
    refine ⟨-c, by simpa only [abs_neg] using hc, ?_⟩
    intro z hz
    have hz' : -z ∈ Set.Icc (c-intervalLength t/2) (c+intervalLength t/2) := by
      constructor <;> linarith [hz.1,hz.2]
    have hs := hI hz'
    change |-h+σ*(-z)| ≤ a at hs
    change |h+σ*z| ≤ a
    simpa only [mul_neg, ← neg_add, abs_neg] using hs

/-- A direct finite-density lower bound, valid for every bounded mean. -/
theorem shifted_interval_mass_lower (a σ t h : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (hh : |h| ≤ a+σ*t) :
    smallBall t ≤ (gaussianReal 0 1).real {z | |h+σ*z| ≤ a} := by
  obtain ⟨c,hc,hI⟩ := exists_interval a σ t h hσ ht ha hh
  let δ := intervalLength t
  have hδ : 0 < δ := intervalLength_pos ht
  have hδhalf : δ ≤ 1/2 := intervalLength_le_half ht
  have hδeq : δ*(2*(t+1)) = 1 := by
    dsimp [δ, intervalLength]
    field_simp
  have htd : t*δ ≤ 1/2 := by nlinarith
  have hsq : (|c|+δ/2)^2 ≤ t^2+3 := by
    have hs : (|c|+δ/2)^2 ≤ (t+δ)^2 :=
      (sq_le_sq₀ (by positivity) (by positivity)).2 hc
    have hδsq : δ^2 ≤ 1/4 := by nlinarith
    nlinarith
  have hmass := GaussianTail.gaussian_interval_mass_lower c (δ/2) (by positivity)
    (1 : ℝ≥0) (by norm_num)
  simp only [NNReal.coe_one, mul_one] at hmass
  calc
    smallBall t = δ*(Real.sqrt (2*Real.pi))⁻¹*Real.exp (-(t^2+3)/2) := by
      unfold smallBall
      rw [show -(t^2+3)/2 = -(3/2 : ℝ)+(-t^2/2) by ring, Real.exp_add]
      dsimp [δ, intervalLength]
      simp only [div_eq_mul_inv, mul_inv_rev]
      ring
    _ ≤ (2*(δ/2))*(Real.sqrt (2*Real.pi))⁻¹*Real.exp (-((|c|+δ/2)^2)/2) := by
      have he : Real.exp (-(t^2+3)/2) ≤ Real.exp (-((|c|+δ/2)^2)/2) :=
        Real.exp_le_exp.mpr (by linarith)
      have hp := mul_le_mul_of_nonneg_left he
        (by positivity : 0 ≤ δ*(Real.sqrt (2*Real.pi))⁻¹)
      simpa only [show 2*(δ/2)=δ by ring] using hp
    _ ≤ _ := hmass.trans (measureReal_mono hI (measure_ne_top _ _))

end NeuralGeneralization.GaussianAmplitude
