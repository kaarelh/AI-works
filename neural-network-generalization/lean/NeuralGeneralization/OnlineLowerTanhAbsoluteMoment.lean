import NeuralGeneralization.OnlineLowerTanhSineIntegrable
import NeuralGeneralization.OnlineLowerTanhSinePowers
import Mathlib.MeasureTheory.Integral.DominatedConvergence

/-! # Actual absolute sine moments for global parity localization -/
noncomputable section
open scoped Topology
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

def absoluteSineKernel (p : ℕ) (a t : ℝ) : ℝ :=
  |Real.sin (a*t)|^p / Real.sinh (Real.pi*t/2)

def absoluteSineMoment (p : ℕ) (a : ℝ) : ℝ :=
  ∫ t : ℝ in Ioi 0, absoluteSineKernel p a t

theorem absoluteSineKernel_measurable (p : ℕ) (a : ℝ) : Measurable (absoluteSineKernel p a) := by
  unfold absoluteSineKernel
  fun_prop

theorem absoluteSineKernel_nonneg (p : ℕ) (a t : ℝ) (ht : 0 < t) :
    0 ≤ absoluteSineKernel p a t := by
  unfold absoluteSineKernel
  exact div_nonneg (pow_nonneg (abs_nonneg _) _) (Real.sinh_pos_iff.mpr (by positivity)).le

theorem absoluteSineKernel_abs_le_sine (p : ℕ) (hp : 1 ≤ p) (a t : ℝ) :
    |absoluteSineKernel p a t| ≤ |Real.sin (a*t)/Real.sinh (Real.pi*t/2)| := by
  unfold absoluteSineKernel
  simp only [abs_div,abs_pow,abs_abs]
  apply div_le_div_of_nonneg_right _ (abs_nonneg _)
  simpa only [pow_one] using pow_le_pow_of_le_one (abs_nonneg (Real.sin (a*t)))
    (Real.abs_sin_le_one _) hp

theorem absoluteSineKernel_integrable (p : ℕ) (hp : 1 ≤ p) (a : ℝ) :
    IntegrableOn (absoluteSineKernel p a) (Ioi 0) := by
  apply (tanh_sine_integrable a).norm.mono'
  · exact (absoluteSineKernel_measurable p a).aestronglyMeasurable
  · filter_upwards [] with t
    simpa only [Real.norm_eq_abs] using absoluteSineKernel_abs_le_sine p hp a t

theorem absoluteSineMoment_nonneg (p : ℕ) (a : ℝ) : 0 ≤ absoluteSineMoment p a := by
  apply integral_nonneg_of_ae
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
  exact absoluteSineKernel_nonneg p a t ht

theorem absoluteSineMoment_antitone (a : ℝ) {p q : ℕ} (hp : 1 ≤ p) (hpq : p ≤ q) :
    absoluteSineMoment q a ≤ absoluteSineMoment p a := by
  apply integral_mono_ae (absoluteSineKernel_integrable q (hp.trans hpq) a)
    (absoluteSineKernel_integrable p hp a)
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
  have ht0 : 0 < t := ht
  apply div_le_div_of_nonneg_right _ (Real.sinh_pos_iff.mpr (by positivity : 0 < Real.pi*t/2)).le
  exact pow_le_pow_of_le_one (abs_nonneg _) (Real.abs_sin_le_one _) hpq

@[simp] theorem absoluteSineMoment_neg (p : ℕ) (a : ℝ) :
    absoluteSineMoment p (-a) = absoluteSineMoment p a := by
  simp [absoluteSineMoment,absoluteSineKernel,neg_mul]

/-- Continuity includes zero gain. The same elementary exponential
majorant works for all powers at least one on each bounded gain interval. -/
theorem continuous_absoluteSineMoment (p : ℕ) (hp : 1 ≤ p) : Continuous (absoluteSineMoment p) := by
  apply continuous_iff_continuousAt.mpr
  intro a₀
  let M := |a₀|+1
  let b := Real.pi/2
  let bound : ℝ → ℝ := fun t => (2*M/b)*Real.exp (-(b/2)*t)
  have hb : 0 < b := by dsimp [b]; positivity
  have hM : 0 < M := by dsimp [M]; positivity
  have hnear : ∀ᶠ a in 𝓝 a₀, |a| ≤ M := by
    have hh := continuous_abs.continuousAt.eventually (gt_mem_nhds (show |a₀| < M by dsimp [M]; linarith))
    exact hh.mono (fun _ h => h.le)
  change Tendsto (fun a => ∫ t : ℝ in Ioi 0, absoluteSineKernel p a t) (𝓝 a₀)
    (𝓝 (∫ t : ℝ in Ioi 0, absoluteSineKernel p a₀ t))
  apply tendsto_integral_filter_of_dominated_convergence bound
  · exact Eventually.of_forall (fun a => (absoluteSineKernel_measurable p a).aestronglyMeasurable)
  · filter_upwards [hnear] with a ha
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    rw [Real.norm_eq_abs]
    apply (absoluteSineKernel_abs_le_sine p hp a t).trans
    have hs := sine_sinh_bound a b t hb ht
    have he : Real.pi*t/2 = b*t := by dsimp [b]; ring
    rw [he]
    apply hs.trans
    dsimp [bound]
    gcongr
  · exact (integrableOn_exp_mul_Ioi (show -(b/2)<0 by linarith) 0).const_mul (2*M/b)
  · filter_upwards [] with t
    exact (by unfold absoluteSineKernel; fun_prop : ContinuousAt (fun a => absoluteSineKernel p a t) a₀)

end NeuralGeneralization.OnlineLowerTanh
