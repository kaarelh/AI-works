import NeuralGeneralization.BatchTwoImprovedDensityApprox
import Mathlib.MeasureTheory.Integral.DominatedConvergence
import Mathlib.Analysis.SpecificLimits.Basic

/-! # Truncating arbitrary finite-entropy densities

Clipping to `[1/(n+1),n+1]` preserves mass and entropy in the limit. The
normalization is handled explicitly, so the approximants are genuine bounded
positive probability densities.
-/
noncomputable section
open MeasureTheory Set Filter
open scoped Topology

namespace NeuralGeneralization.BatchTwoImprovedDensityApprox

/-- A positive lower cutoff and a finite upper cutoff, both tending away from
every fixed positive density value. -/
def densityClip (n : ℕ) (x : ℝ) : ℝ := clamp (1 / ((n : ℝ)+1)) ((n : ℝ)+1) x

theorem densityClip_bounds (n : ℕ) (x : ℝ) :
    densityClip n x ∈ Icc (1 / ((n : ℝ)+1)) ((n : ℝ)+1) := by
  apply clamp_mem
  have hn : (1 : ℝ) ≤ (n : ℝ)+1 := by linarith [Nat.cast_nonneg (α := ℝ) n]
  have hi : 1 / ((n : ℝ)+1) ≤ 1 := by
    simpa only [div_one] using one_div_le_one_div_of_le (by norm_num : (0 : ℝ) < 1) hn
  exact hi.trans hn

theorem densityClip_pos (n : ℕ) (x : ℝ) : 0 < densityClip n x :=
  (by positivity : (0 : ℝ) < 1 / ((n : ℝ)+1)).trans_le (densityClip_bounds n x).1

@[fun_prop] theorem continuous_densityClip (n : ℕ) : Continuous (densityClip n) :=
  continuous_clamp _ _

theorem densityClip_le_add_one (n : ℕ) {x : ℝ} (hx : 0 ≤ x) :
    densityClip n x ≤ x+1 := by
  unfold densityClip clamp
  apply max_le
  · have h := one_div_le_one_div_of_le (by norm_num : (0 : ℝ) < 1)
      (by linarith [Nat.cast_nonneg (α := ℝ) n] : (1 : ℝ) ≤ (n : ℝ)+1)
    have h' : 1 / ((n : ℝ)+1) ≤ 1 := by simpa only [div_one] using h
    linarith
  · exact (min_le_right _ _).trans (by linarith)

theorem densityClip_tendsto {x : ℝ} (hx : 0 ≤ x) :
    Tendsto (fun n => densityClip n x) atTop (𝓝 x) := by
  have hn : ∀ᶠ n : ℕ in atTop, x ≤ (n : ℝ)+1 := by
    obtain ⟨k, hk⟩ := exists_nat_ge x
    filter_upwards [eventually_ge_atTop k] with n hkn
    have hc : (k : ℝ) ≤ n := by exact_mod_cast hkn
    linarith
  have heq : (fun n => densityClip n x) =ᶠ[atTop]
      (fun n => max (1 / ((n : ℝ)+1)) x) := by
    filter_upwards [hn] with n h
    simp only [densityClip, clamp, min_eq_right h]
  have ht := (tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).max
    (tendsto_const_nhds (x := x))
  rw [max_eq_right hx] at ht
  exact ht.congr' heq.symm

/-- A uniform integrable envelope for the clipped entropy integrands. -/
theorem abs_densityClip_mul_log_le (n : ℕ) {x : ℝ} (hx : 0 ≤ x) :
    |densityClip n x * Real.log (densityClip n x)| ≤ |x*Real.log x|+1 := by
  let y := densityClip n x
  have hy := densityClip_pos n x
  by_cases hx1 : x ≤ 1
  · have hy1 : y ≤ 1 := by
      unfold y densityClip clamp
      apply max_le
      · simpa using one_div_le_one_div_of_le (by norm_num : (0 : ℝ) < 1)
          (by linarith [Nat.cast_nonneg (α := ℝ) n] : (1 : ℝ) ≤ (n : ℝ)+1)
      · exact (min_le_right _ _).trans hx1
    have hlo := Real.self_sub_one_le_mul_log hy.le
    have hhi := Real.mul_log_nonpos hy.le hy1
    rw [abs_of_nonpos hhi]
    linarith [abs_nonneg (x*Real.log x)]
  · have hx1' : 1 ≤ x := (lt_of_not_ge hx1).le
    have hlow : 1 ≤ y := by
      unfold y densityClip clamp
      exact (le_min (by linarith [Nat.cast_nonneg (α := ℝ) n]) hx1').trans (le_max_right _ _)
    have hyx : y ≤ x := by
      unfold y densityClip clamp
      apply max_le
      · have hh := one_div_le_one_div_of_le (by norm_num : (0 : ℝ) < 1)
          (by linarith [Nat.cast_nonneg (α := ℝ) n] : (1 : ℝ) ≤ (n : ℝ)+1)
        have hh' : 1 / ((n : ℝ)+1) ≤ 1 := by simpa only [div_one] using hh
        exact hh'.trans hx1'
      · exact min_le_right _ _
    have hle : y * Real.log y ≤ x * Real.log x :=
      mul_le_mul hyx (Real.log_le_log hy hyx) (Real.log_nonneg hlow) hx
    rw [abs_of_nonneg (Real.mul_log_nonneg hlow),
      abs_of_nonneg (Real.mul_log_nonneg hx1')]
    linarith

/-- Clipped mass converges to the original mass. -/
theorem densityClip_integral_tendsto (μ : Measure ℝ) [IsFiniteMeasure μ]
    (ρ : ℝ → ℝ) (hi : Integrable ρ μ) (hpos : ∀ x, 0 ≤ ρ x) :
    Tendsto (fun n => ∫ x, densityClip n (ρ x) ∂μ) atTop
      (𝓝 (∫ x, ρ x ∂μ)) := by
  apply tendsto_integral_of_dominated_convergence (fun x => ρ x+1)
  · intro n
    exact (continuous_densityClip n).comp_aestronglyMeasurable hi.aestronglyMeasurable
  · exact hi.add (integrable_const 1)
  · intro n
    filter_upwards with x
    rw [Real.norm_eq_abs, abs_of_pos (densityClip_pos n _)]
    exact densityClip_le_add_one n (hpos x)
  · exact Eventually.of_forall (fun x => densityClip_tendsto (hpos x))

/-- Clipped entropy converges under exactly the finite-entropy integrability
assumption; neither boundedness nor a positive lower bound on the density is
required. -/
theorem densityClip_entropy_tendsto (μ : Measure ℝ) [IsFiniteMeasure μ]
    (ρ : ℝ → ℝ) (hm : AEStronglyMeasurable ρ μ)
    (hpos : ∀ x, 0 ≤ ρ x)
    (hent : Integrable (fun x => ρ x*Real.log (ρ x)) μ) :
    Tendsto (fun n => ∫ x, densityClip n (ρ x)*Real.log (densityClip n (ρ x)) ∂μ)
      atTop (𝓝 (∫ x, ρ x*Real.log (ρ x) ∂μ)) := by
  apply tendsto_integral_of_dominated_convergence (fun x => |ρ x*Real.log (ρ x)|+1)
  · intro n
    exact (Real.continuous_mul_log.comp (continuous_densityClip n)).comp_aestronglyMeasurable hm
  · exact hent.abs.add (integrable_const 1)
  · intro n
    filter_upwards with x
    rw [Real.norm_eq_abs]
    exact abs_densityClip_mul_log_le n (hpos x)
  · filter_upwards with x
    exact Real.continuous_mul_log.continuousAt.tendsto.comp (densityClip_tendsto (hpos x))

/-- The unnormalized clipped densities also converge in L1. -/
theorem densityClip_l1_tendsto (μ : Measure ℝ) [IsFiniteMeasure μ]
    (ρ : ℝ → ℝ) (hi : Integrable ρ μ) (hpos : ∀ x, 0 ≤ ρ x) :
    Tendsto (fun n => ∫ x, |densityClip n (ρ x)-ρ x| ∂μ) atTop (𝓝 0) := by
  have ht := tendsto_integral_of_dominated_convergence (μ := μ)
    (F := fun n x => |densityClip n (ρ x)-ρ x|) (f := fun _ => (0 : ℝ))
    (fun x => 2*ρ x+1) ?_ ?_ ?_ ?_
  · simpa using ht
  · intro n
    exact (((continuous_densityClip n).comp_aestronglyMeasurable hi.aestronglyMeasurable).sub
      hi.aestronglyMeasurable).norm
  · exact (hi.const_mul 2).add (integrable_const 1)
  · intro n
    filter_upwards with x
    rw [Real.norm_eq_abs, abs_abs]
    have h := abs_sub (densityClip n (ρ x)) (ρ x)
    rw [abs_of_pos (densityClip_pos n _), abs_of_nonneg (hpos x)] at h
    linarith [densityClip_le_add_one n (hpos x)]
  · filter_upwards with x
    simpa using ((densityClip_tendsto (hpos x)).sub (tendsto_const_nhds (x := ρ x))).abs


theorem integrable_densityClip (μ : Measure ℝ) [IsFiniteMeasure μ]
    (ρ : ℝ → ℝ) (hi : Integrable ρ μ) (hpos : ∀ x, 0 ≤ ρ x) (n : ℕ) :
    Integrable (fun x => densityClip n (ρ x)) μ := by
  apply (hi.add (integrable_const 1)).mono'
    ((continuous_densityClip n).comp_aestronglyMeasurable hi.aestronglyMeasurable)
  filter_upwards with x
  rw [Real.norm_eq_abs, abs_of_pos (densityClip_pos n _)]
  exact densityClip_le_add_one n (hpos x)

theorem densityClip_mass_pos (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (ρ : ℝ → ℝ) (hi : Integrable ρ μ) (hpos : ∀ x, 0 ≤ ρ x) (n : ℕ) :
    0 < ∫ x, densityClip n (ρ x) ∂μ := by
  have h := integral_mono (integrable_const (1/((n:ℝ)+1)))
    (integrable_densityClip μ ρ hi hpos n) (fun x => (densityClip_bounds n (ρ x)).1)
  simp only [integral_const, probReal_univ, one_smul] at h
  exact (by positivity : (0:ℝ) < 1/((n:ℝ)+1)).trans_le h

/-- Probability-preserving clipped density. -/
def normalizedDensityClip (μ : Measure ℝ) (ρ : ℝ → ℝ) (n : ℕ) (x : ℝ) : ℝ :=
  densityClip n (ρ x) / (∫ y, densityClip n (ρ y) ∂μ)

theorem normalizedDensityClip_properties (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (ρ : ℝ → ℝ) (hi : Integrable ρ μ) (hpos : ∀ x, 0 ≤ ρ x) (n : ℕ) :
    Integrable (normalizedDensityClip μ ρ n) μ ∧
      (∫ x, normalizedDensityClip μ ρ n x ∂μ) = 1 ∧
      ∃ a b : ℝ, 0 < a ∧ a ≤ b ∧
        ∀ x, normalizedDensityClip μ ρ n x ∈ Icc a b := by
  let z := ∫ y, densityClip n (ρ y) ∂μ
  have hz : 0 < z := densityClip_mass_pos μ ρ hi hpos n
  refine ⟨(integrable_densityClip μ ρ hi hpos n).div_const z, ?_, ?_⟩
  · unfold normalizedDensityClip
    rw [integral_div, div_self hz.ne']
  · refine ⟨(1/((n:ℝ)+1))/z, ((n:ℝ)+1)/z, by positivity, ?_, ?_⟩
    · exact div_le_div_of_nonneg_right ((densityClip_bounds n 0).1.trans
        (densityClip_bounds n 0).2) hz.le
    · intro x
      exact ⟨div_le_div_of_nonneg_right (densityClip_bounds n (ρ x)).1 hz.le,
        div_le_div_of_nonneg_right (densityClip_bounds n (ρ x)).2 hz.le⟩

theorem normalizedDensityClip_l1_tendsto (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (ρ : ℝ → ℝ) (hi : Integrable ρ μ) (hpos : ∀ x, 0 ≤ ρ x)
    (hmass : ∫ x, ρ x ∂μ = 1) :
    Tendsto (fun n => ∫ x, |normalizedDensityClip μ ρ n x - ρ x| ∂μ)
      atTop (𝓝 0) := by
  have hbound (n : ℕ) := normalized_l1_error_le μ
    (fun x => densityClip n (ρ x)) ρ (integrable_densityClip μ ρ hi hpos n) hi
    (fun x => (densityClip_pos n _).le) hmass (densityClip_mass_pos μ ρ hi hpos n)
  have ht := (densityClip_l1_tendsto μ ρ hi hpos).const_mul 2
  apply squeeze_zero (fun n => integral_nonneg (fun _ => abs_nonneg _)) hbound
  simpa only [mul_zero] using ht

/-- Exact entropy effect of normalization. This identity avoids domination
arguments for the normalized logarithm itself. -/
theorem normalized_entropy_identity (μ : Measure ℝ) (g : ℝ → ℝ)
    (hi : Integrable g μ) (hpos : ∀ x, 0 < g x)
    (hent : Integrable (fun x => g x*Real.log (g x)) μ)
    (hz : 0 < ∫ x, g x ∂μ) :
    (∫ x, (g x/(∫ y, g y ∂μ))*Real.log (g x/(∫ y, g y ∂μ)) ∂μ) =
      (∫ x, g x*Real.log (g x) ∂μ)/(∫ y, g y ∂μ) - Real.log (∫ y, g y ∂μ) := by
  let z := ∫ x, g x ∂μ
  have heq : (fun x => (g x/z)*Real.log (g x/z)) =
      (fun x => (g x*Real.log (g x))/z - (Real.log z/z)*g x) := by
    funext x
    rw [Real.log_div (hpos x).ne' hz.ne']
    ring
  change (∫ x, (g x/z)*Real.log (g x/z) ∂μ) = _
  rw [heq, integral_sub (hent.div_const z) (hi.const_mul _),
    integral_div, integral_const_mul]
  change (∫ x, g x*Real.log (g x) ∂μ)/z - (Real.log z/z)*z = _
  rw [div_mul_cancel₀ _ hz.ne']

theorem normalizedDensityClip_entropy_tendsto (μ : Measure ℝ)
    [IsProbabilityMeasure μ] (ρ : ℝ → ℝ) (hi : Integrable ρ μ)
    (hpos : ∀ x, 0 ≤ ρ x) (hmass : ∫ x, ρ x ∂μ = 1)
    (hent : Integrable (fun x => ρ x*Real.log (ρ x)) μ) :
    Tendsto (fun n => ∫ x, normalizedDensityClip μ ρ n x *
      Real.log (normalizedDensityClip μ ρ n x) ∂μ) atTop
      (𝓝 (∫ x, ρ x*Real.log (ρ x) ∂μ)) := by
  have hz : Tendsto (fun n => ∫ x, densityClip n (ρ x) ∂μ) atTop (𝓝 1) := by
    simpa only [hmass] using densityClip_integral_tendsto μ ρ hi hpos
  have he := densityClip_entropy_tendsto μ ρ hi.aestronglyMeasurable hpos hent
  have heq (n : ℕ) : (∫ x, normalizedDensityClip μ ρ n x *
      Real.log (normalizedDensityClip μ ρ n x) ∂μ) =
      (∫ x, densityClip n (ρ x)*Real.log (densityClip n (ρ x)) ∂μ) /
        (∫ x, densityClip n (ρ x) ∂μ) - Real.log (∫ x, densityClip n (ρ x) ∂μ) := by
    apply normalized_entropy_identity μ _ (integrable_densityClip μ ρ hi hpos n)
      (fun x => densityClip_pos n _) ?_ (densityClip_mass_pos μ ρ hi hpos n)
    exact integrable_mul_log_of_bounds μ _
      ((continuous_densityClip n).comp_aestronglyMeasurable hi.aestronglyMeasurable)
      (by positivity : (0:ℝ) < 1/((n:ℝ)+1))
      (Eventually.of_forall (fun x => densityClip_bounds n (ρ x)))
  simp_rw [heq]
  have ht := (he.div hz (by norm_num : (1:ℝ) ≠ 0)).sub
    (Real.continuousAt_log (by norm_num : (1:ℝ) ≠ 0) |>.tendsto.comp hz)
  simpa only [div_one, Real.log_one, sub_zero, Pi.div_apply, Function.comp_def] using ht

end NeuralGeneralization.BatchTwoImprovedDensityApprox
