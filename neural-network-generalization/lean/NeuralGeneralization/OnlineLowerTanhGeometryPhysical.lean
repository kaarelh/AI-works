import NeuralGeneralization.OnlineLowerTanhGeometryLogical
import NeuralGeneralization.OnlineLowerTanhGeometryCarrierDefect

/-! # Physical calibration and odd-downward variance for rectangle scores -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry
namespace WalshCodeMap
variable {d m : ℕ} (C : WalshCodeMap d m)

/-- The actual conditional second moment on any observed set is bounded
by its logical deviation from the target's half-margin reference. -/
theorem observed_set_variance_deviation (O : Set (ClippingCube m))
    (F : ClippingCube d → ℝ) (L : ℝ) (hL : 0 ≤ L) (hcap : ∀ x, |F x| ≤ L)
    (hcal : ∀ x, C.syndrome x ∈ O →
      (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * F x)) :
    uniformCubeMean (fun x => if C.syndrome x ∈ O then
      (F x - C.project F x)^2 else 0) ≤
      4 * L * uniformCubeMean (fun z => if z ∈ O then
        |C.logicalProjection F z - reluReference z| else 0) := by
  have hpoint (z : ClippingCube m) :
      (if z ∈ O then C.fiberMean (fun x => (F x - C.project F x)^2) z else 0) ≤
        4 * L * (if z ∈ O then |C.logicalProjection F z - reluReference z| else 0) := by
    by_cases hz : z ∈ O
    · simp only [if_pos hz]
      by_cases hz0 : z = cubeOne m
      · subst z
        have hm := C.logical_margin_of_fiber_margin F 1 (1 / 2) (cubeOne m) (by
          intro x hx
          simpa only [hx, if_true] using hcal x (hx ▸ hz))
        have hb := C.observed_fiber_squared_residual F 1 (1 / 2) L (cubeOne m)
          (by norm_num) hL hcap (by
            intro x hx
            simpa only [hx, if_true] using hcal x (hx ▸ hz))
        have href : reluReference (cubeOne m) = (1 : ℝ) / 2 := by
          norm_num [reluReference, pointIndicator]
        rw [href, abs_of_nonneg (by linarith)]
        simpa only [one_mul, fiberMean] using hb
      · have hm := C.logical_margin_of_fiber_margin F (-1) (1 / 2) z (by
          intro x hx
          simpa only [hx, if_neg hz0] using hcal x (hx ▸ hz))
        have hb := C.observed_fiber_squared_residual F (-1) (1 / 2) L z
          (by norm_num) hL hcap (by
            intro x hx
            simpa only [hx, if_neg hz0] using hcal x (hx ▸ hz))
        have href : reluReference z = -(1 : ℝ) / 2 := by
          simp [reluReference, pointIndicator, hz0]
        rw [href, abs_of_nonpos (by linarith)]
        change (∑ x, C.fiberWeight z x * (F x - C.project F x)^2) ≤ _
        nlinarith
    · simp [hz]
  have hmean := uniformCubeMean_mono _ _ hpoint
  rw [uniformCubeMean_mul] at hmean
  have heq : uniformCubeMean (fun z => if z ∈ O then
      C.fiberMean (fun x => (F x - C.project F x)^2) z else 0) =
        uniformCubeMean (fun x => if C.syndrome x ∈ O then
          (F x - C.project F x)^2 else 0) := by
    calc
      _ = uniformCubeMean (fun z => C.fiberMean (fun x => if C.syndrome x ∉ Oᶜ then
          (F x - C.project F x)^2 else 0) z) := by
        congr 1
        funext z
        simpa only [Set.mem_compl_iff, not_not] using
          (C.fiberMean_restrict (fun x => (F x - C.project F x)^2) Oᶜ z).symm
      _ = _ := by
        simpa only [fiberMean, Set.mem_compl_iff, not_not] using C.mean_fiber_mean
          (fun x => if C.syndrome x ∉ Oᶜ then (F x - C.project F x)^2 else 0)
  rwa [heq] at hmean

theorem rectangle_observed_variance_bound (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (hw : RectangleCostConditions w u)
    (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 0 < ((H.adjoinPoint u).differenceAnnihilator v).card)
    (F : ClippingCube d → ℝ) (L : ℝ) (hL : 0 ≤ L) (hcap : ∀ x, |F x| ≤ L)
    (hcal : ∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
      (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * F x)) :
    uniformCubeMean (fun x => if C.syndrome x ∈ rectangleObserved H v u then
      (F x - C.project F x)^2 else 0) ≤
      (4 * L / rectangleCommonA w u) * rectangleLogicalSlack w H v u (C.logicalProjection F) := by
  have hvH : v ∉ H.carrier := fun hh => hv (H.subset_adjoinPoint u hh)
  have hu0 : u ≠ cubeOne m := fun hh => hu (hh ▸ H.one_mem)
  obtain ⟨hanchor, hnegative⟩ := C.relu_projection_calibration_margins H v hvH F hcal
  have hobs := C.observed_set_variance_deviation (rectangleObserved H v u) F L hL hcap
    (fun x hx => hcal x (fun hh => hx.1 (H.subset_adjoinPoint u hh)))
  have hdev := rectangle_calibration_deviation_bound H v u (rectangleLogicalDual w H v u)
    (C.logicalProjection F) (rectangleCommonA w u)
    (hw.positive_anchor (H.adjoinPoint u) v hv hu0 hE)
    (hw.logical_dual_negative H v hv hE) hanchor
    (fun z hz => hnegative z (fun hh => hz.1.1 (H.subset_adjoinPoint u hh)) hz.2)
  have ha := hw.parameter_bounds.2.2.1
  have h₁ := mul_le_mul_of_nonneg_left hobs ha.le
  have h₂ := mul_le_mul_of_nonneg_left hdev (show 0 ≤ 4 * L by positivity)
  rw [show (4 * L / rectangleCommonA w u) * rectangleLogicalSlack w H v u (C.logicalProjection F) =
      (4 * L * rectangleLogicalSlack w H v u (C.logicalProjection F)) / rectangleCommonA w u by ring]
  apply (le_div_iff₀ ha).mpr
  change _ ≤ 4 * L * rectangleCalibrationSlack (rectangleLogicalDual w H v u) H v u
    (C.logicalProjection F)
  nlinarith

end WalshCodeMap

open OnlineLowerRelu OnlineLowerTanh

/-- Full physical variance estimate. The only analytic remainder is the
actual squared projection error outside the odd downward Fourier space. -/
theorem actual_carrier_rectangle_variance {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (heven : ∀ i b, Even (size i b))
    (C : WalshCodeMap (carrierDimension size) m)
    (hsupport : ∀ s, C.support s = carrierSupport size column s)
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v u : ClippingCube m)
    (hw : RectangleCostConditions w u) (hu : u ∉ H.carrier)
    (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 0 < ((H.adjoinPoint u).differenceAnnihilator v).card)
    (hind : ∀ i z, z ∉ rectangleObserved H v u →
      cubeTranslation (logicalColumnPoint column i) z ∈ rectangleObserved H v u)
    (F : ClippingCube (carrierDimension size) → ℝ) (L : ℝ)
    (hL : 0 ≤ L) (hcap : ∀ x, |F x| ≤ L)
    (hcal : ∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
      (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * F x)) :
    uniformCubeMean (fun x => (F x - C.project F x)^2) ≤
      (16 * L / rectangleCommonA w u) * rectangleLogicalSlack w H v u (C.logicalProjection F) +
        5 * uniformCubeMean (fun x =>
          (F x - fourierProject (carrierOddDownwardSupports size column) F x)^2) := by
  let PD := fourierProject (carrierOddDownwardSupports size column) F
  let J : Set (ClippingCube m) := (rectangleObserved H v u)ᶜ
  let O : Set (ClippingCube (carrierDimension size)) := {x | C.syndrome x ∈ rectangleObserved H v u}
  have hsub : C.supports ⊆ carrierOddDownwardSupports size column := by
    intro S hS
    obtain ⟨s, _, rfl⟩ := Finset.mem_image.mp hS
    rw [hsupport]
    exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, carrierSupport_odd size column heven s,
      s, Finset.Subset.refl _⟩
  have horth : uniformCubeMean (fun x => (PD x - C.project F x) * (F x - PD x)) = 0 := by
    rw [C.project_eq_fourierProject]
    exact fourierProject_residual_orthogonal C.supports (carrierOddDownwardSupports size column) hsub F
  have hobs := actual_carrier_odd_observability size column hsize heven C hsupport F J
    (fun i z hz => by simpa only [J, Set.mem_compl_iff, not_not] using hind i z hz)
  have hvar := uniform_observability_variance_bound
    (fun x => F x - C.project F x) (fun x => PD x - C.project F x)
    (fun x => F x - PD x) O (fun x => by ring) horth
    (by simpa only [J, O, PD, Set.mem_setOf_eq, Set.mem_compl_iff, not_not] using hobs)
  have hcalobs := C.rectangle_observed_variance_bound w H v u hw hu hv hE F L hL hcap hcal
  have hvar' : uniformCubeMean (fun x => (F x - C.project F x)^2) ≤
      4 * uniformCubeMean (fun x => if C.syndrome x ∈ rectangleObserved H v u then
        (F x - C.project F x)^2 else 0) +
      5 * uniformCubeMean (fun x => (F x - PD x)^2) := hvar
  have hmul := mul_le_mul_of_nonneg_left hcalobs (by norm_num : (0 : ℝ) ≤ 4)
  have hcoef : 4 * ((4 * L / rectangleCommonA w u) *
      rectangleLogicalSlack w H v u (C.logicalProjection F)) =
      (16 * L / rectangleCommonA w u) * rectangleLogicalSlack w H v u (C.logicalProjection F) := by ring
  rw [hcoef] at hmul
  change _ ≤ (16 * L / rectangleCommonA w u) * rectangleLogicalSlack w H v u (C.logicalProjection F) +
    5 * uniformCubeMean (fun x => (F x - PD x)^2)
  linarith only [hvar', hmul]

end NeuralGeneralization.OnlineLowerGeometry
