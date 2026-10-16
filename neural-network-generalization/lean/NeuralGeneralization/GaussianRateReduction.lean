import NeuralGeneralization.GaussianGeometry
import NeuralGeneralization.GaussianPrefactors
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

/-!
# From Gaussian rectangle and norm bounds to the open-event rate

This intermediate theorem isolates the geometric and exponential algebra. The
actual Gaussian law is instantiated in `GaussianRate`, using separately proved
Gaussian density and Chernoff estimates.
-/

noncomputable section
open Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.GaussianRate
variable {ι : Type*} [Fintype ι]
/-- Gaussian rectangle prefactors admit a positive bound independent of small variance. -/
theorem rectangle_prefactor_product_le (a : ι → ℝ) (r : ℝ) (hr : 0 < r)
    (t : ℝ) (ht : 0 < t) (ht1 : t ≤ 1) :
    ((2 * r) * (Real.sqrt (2 * Real.pi))⁻¹) ^ Fintype.card ι *
      Real.exp (-(∑ i, (|a i| + r) ^ 2) / (2 * t)) ≤
      ∏ i : ι, ((2 * r) * (Real.sqrt (2 * Real.pi * t))⁻¹) *
        Real.exp (-((|a i| + r) ^ 2) / (2 * t)) := by
  classical
  have hsqrt : Real.sqrt (2 * Real.pi * t) ≤ Real.sqrt (2 * Real.pi) := by
    apply Real.sqrt_le_sqrt
    simpa only [mul_one] using
      mul_le_mul_of_nonneg_left ht1 (show 0 ≤ 2 * Real.pi by positivity)
  have hinv : (Real.sqrt (2 * Real.pi))⁻¹ ≤
      (Real.sqrt (2 * Real.pi * t))⁻¹ :=
    (inv_le_inv₀ (by positivity) (by positivity)).mpr hsqrt
  have hterm (i : ι) :
      ((2 * r) * (Real.sqrt (2 * Real.pi))⁻¹) *
        Real.exp (-((|a i| + r) ^ 2) / (2 * t)) ≤
      ((2 * r) * (Real.sqrt (2 * Real.pi * t))⁻¹) *
        Real.exp (-((|a i| + r) ^ 2) / (2 * t)) :=
    mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hinv (by positivity))
      (Real.exp_pos _).le
  have hp := Finset.prod_le_prod
    (s := Finset.univ)
    (f := fun i => ((2 * r) * (Real.sqrt (2 * Real.pi))⁻¹) *
      Real.exp (-((|a i| + r) ^ 2) / (2 * t)))
    (g := fun i => ((2 * r) * (Real.sqrt (2 * Real.pi * t))⁻¹) *
      Real.exp (-((|a i| + r) ^ 2) / (2 * t)))
    (fun i _ => by positivity) (fun i _ => hterm i)
  have hprod :
      (∏ i : ι, ((2 * r) * (Real.sqrt (2 * Real.pi))⁻¹) *
        Real.exp (-((|a i| + r) ^ 2) / (2 * t))) =
      ((2 * r) * (Real.sqrt (2 * Real.pi))⁻¹) ^ Fintype.card ι *
        Real.exp (-(∑ i, (|a i| + r) ^ 2) / (2 * t)) := by
    rw [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ, ← Real.exp_sum]
    congr 2
    simp only [← Finset.sum_div, Finset.sum_neg_distrib]
  rw [hprod] at hp
  exact hp

variable (mass : Set (ι → ℝ) → ℝ → ℝ)
  (hmassmono : ∀ t, Monotone (fun V => mass V t))
  (hrectlower : ∀ (a : ι → ℝ) (r : ℝ), 0 < r → ∀ (t : ℝ), 0 < t → t ≤ 1 →
    ((2 * r) * (Real.sqrt (2 * Real.pi))⁻¹) ^ Fintype.card ι *
      Real.exp (-(∑ i, (|a i| + r) ^ 2) / (2 * t)) ≤
        mass (Set.pi Set.univ fun i => Set.Icc (a i - r) (a i + r)) t)
  (hnormupper : ∀ (t : ℝ), 0 < t → ∀ (b θ : ℝ), 0 < θ → θ ≤ 1 →
    mass {x : ι → ℝ | b ≤ ∑ i, x i ^ 2} t ≤
      Real.exp (-((1 - θ) * b) / (2 * t)) * (Real.sqrt θ)⁻¹ ^ Fintype.card ι)

include hmassmono hrectlower in
/-- Lower estimate for every open nonempty event, with the actual infimum
energy and a fixed positive prefactor. -/
theorem gaussian_bounds_open_lower {V : Set (ι → ℝ)} (hV : IsOpen V)
    (hne : V.Nonempty) (δ : ℝ) (hδ : 0 < δ) :
    ∃ c : ℝ, 0 < c ∧ ∀ᶠ t : ℝ in 𝓝[>] 0,
      c * Real.exp (-(squareInf V / 2 + δ) * (1 / t)) ≤ mass V t := by
  obtain ⟨a, r, hr, hrect, henergy⟩ := exists_rectangle_near_inf hV hne δ hδ
  let c : ℝ := ((2 * r) * (Real.sqrt (2 * Real.pi))⁻¹) ^ Fintype.card ι
  have hc : 0 < c := by dsimp [c]; positivity
  refine ⟨c, hc, ?_⟩
  have htle : ∀ᶠ t : ℝ in 𝓝[>] 0, t ≤ 1 := by
    filter_upwards [(eventually_lt_nhds (show (0 : ℝ) < 1 by norm_num)).filter_mono
      nhdsWithin_le_nhds] with t ht
    exact ht.le
  filter_upwards [self_mem_nhdsWithin, htle] with t ht ht1
  have htpos : 0 < t := ht
  have hexp : -(squareInf V / 2 + δ) * (1 / t) ≤
      -(∑ i, (|a i| + r) ^ 2) / (2 * t) := by
    have hh : -(squareInf V / 2 + δ) ≤ -(∑ i, (|a i| + r) ^ 2) / 2 := by
      linarith
    have hh' := div_le_div_of_nonneg_right hh htpos.le
    convert hh' using 1 <;> first | rfl | ring
  calc
    c * Real.exp (-(squareInf V / 2 + δ) * (1 / t)) ≤
        c * Real.exp (-(∑ i, (|a i| + r) ^ 2) / (2 * t)) :=
      mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hexp) hc.le
    _ ≤ mass (Set.pi Set.univ fun i => Set.Icc (a i - r) (a i + r)) t :=
      hrectlower a r hr t htpos ht1
    _ ≤ mass V t := hmassmono t hrect

include hmassmono hnormupper in
/-- Upper estimate with an arbitrarily small rate error, for every nonempty
event. Openness is used only by the matching lower estimate. -/
theorem gaussian_bounds_upper {V : Set (ι → ℝ)} (hne : V.Nonempty)
    (δ : ℝ) (hδ : 0 < δ) :
    ∃ C : ℝ, 0 < C ∧ ∀ᶠ t : ℝ in 𝓝[>] 0,
      mass V t ≤ C * Real.exp (-(squareInf V / 2 - δ) * (1 / t)) := by
  let b := squareInf V
  have hb : 0 ≤ b := squareInf_nonneg hne
  let θ : ℝ := min 1 (δ / (b + 1))
  have hθ0 : 0 < θ := lt_min zero_lt_one (div_pos hδ (by linarith))
  have hθ1 : θ ≤ 1 := min_le_left _ _
  have hθb : θ * b ≤ δ := by
    have hh : θ * (b + 1) ≤ δ :=
      (le_div_iff₀ (by linarith : 0 < b + 1)).mp (min_le_right _ _)
    nlinarith
  let C : ℝ := (Real.sqrt θ)⁻¹ ^ Fintype.card ι
  have hC : 0 < C := by dsimp [C]; positivity
  refine ⟨C, hC, ?_⟩
  filter_upwards [self_mem_nhdsWithin] with t ht
  have htpos : 0 < t := ht
  have htail := hnormupper t htpos b θ hθ0 hθ1
  have hexp : -((1 - θ) * b) / (2 * t) ≤
      -(squareInf V / 2 - δ) * (1 / t) := by
    have hh : -((1 - θ) * b) / 2 ≤ -(b / 2 - δ) := by nlinarith
    have hh' := div_le_div_of_nonneg_right hh htpos.le
    change -((1 - θ) * b) / (2 * t) ≤ -(b / 2 - δ) * (1 / t)
    convert hh' using 1 <;> first | rfl | ring
  calc
    mass V t ≤
        mass {x : ι → ℝ | b ≤ ∑ i, x i ^ 2} t := by
      apply hmassmono t
      intro x hx
      exact squareInf_le hx
    _ ≤ Real.exp (-((1 - θ) * b) / (2 * t)) * C := htail
    _ ≤ Real.exp (-(squareInf V / 2 - δ) * (1 / t)) * C :=
      mul_le_mul_of_nonneg_right (Real.exp_le_exp.mpr hexp) hC.le
    _ = C * Real.exp (-(squareInf V / 2 - δ) * (1 / t)) := mul_comm _ _

include hmassmono hrectlower hnormupper in
/-- Gaussian rectangle and norm estimates imply the exact open-event rate. -/
theorem open_event_rate_of_gaussian_bounds {V : Set (ι → ℝ)}
    (hV : IsOpen V) (hne : V.Nonempty) :
    HasExponentialRate (𝓝[>] (0 : ℝ)) (fun t => 1 / t)
      (mass V) (squareInf V / 2) := by
  apply hasExponentialRate_of_prefactors
  · simpa only [one_div] using (tendsto_inv_nhdsGT_zero :
      Tendsto (fun t : ℝ => t⁻¹) (𝓝[>] 0) atTop)
  · exact gaussian_bounds_open_lower mass hmassmono hrectlower hV hne
  · exact gaussian_bounds_upper mass hmassmono hnormupper hne

end NeuralGeneralization.GaussianRate
