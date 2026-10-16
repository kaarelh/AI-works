import NeuralGeneralization.GaussianPolyhedronLogConcave
import NeuralGeneralization.GaussianSignCone
import Mathlib.Analysis.SpecificLimits.Basic

/-! Actual CDF numerator under finite strict Gaussian sign conditioning.
Strict inequalities are recovered as increasing positive-margin events. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.GaussianSignCDF
open PrekopaLeindlerInterval GaussianCoordinateIntegration GaussianPolyhedronLogConcave
variable {I J : Type*} [Fintype I] [Fintype J]

def linear (u : I → ℝ) (z : I → ℝ) : ℝ := ∑ i, u i*z i

def strictCDFSet (A : J → I → ℝ) (u : I → ℝ) (t : ℝ) : Set (I → ℝ) :=
  {z | (∀ j, 0 < linear (A j) z) ∧ linear u z ≤ t}

def closedCDFSet (A : J → I → ℝ) (u : I → ℝ) (ε t : ℝ) : Set (I → ℝ) :=
  {z | (∀ j, ε ≤ linear (A j) z) ∧ linear u z ≤ t}

def augmentedA (A : J → I → ℝ) (u : I → ℝ) : Option J → I → ℝ
  | none => u
  | some j => fun i => -A j i

def augmentedSlope : Option J → ℝ
  | none => 1
  | some _ => 0

def augmentedOffset (ε : ℝ) : Option J → ℝ
  | none => 0
  | some _ => -ε

theorem region_eq_closedCDFSet (A : J → I → ℝ) (u : I → ℝ) (ε t : ℝ) :
    region (augmentedA A u) augmentedSlope (augmentedOffset ε) t = closedCDFSet A u ε t := by
  ext z
  simp only [region, closedCDFSet, mem_setOf_eq, Option.forall, GaussianConvexPenalty.residual,
    augmentedA, augmentedSlope, augmentedOffset, one_mul, sub_zero, zero_mul, neg_mul,
    Finset.sum_neg_distrib, sub_neg_eq_add]
  constructor
  · rintro ⟨hu,hA⟩
    exact ⟨fun j => by have hj := hA j; dsimp only [linear]; linarith,
      by dsimp only [linear]; linarith⟩
  · rintro ⟨hA,hu⟩
    exact ⟨by dsimp only [linear] at hu; linarith,
      fun j => by have hj := hA j; dsimp only [linear] at hj; linarith⟩

theorem closedCDF_mass_logConcave (A : J → I → ℝ) (u : I → ℝ) (ε s t : ℝ)
    {θ : ℝ} (hθ : θ ∈ Icc 0 1) :
    ((law I).real (closedCDFSet A u ε s)) ^ (1-θ) *
      ((law I).real (closedCDFSet A u ε t)) ^ θ ≤
      (law I).real (closedCDFSet A u ε (mix θ s t)) := by
  simpa only [region_eq_closedCDFSet] using
    region_mass_logConcave (augmentedA A u) augmentedSlope (augmentedOffset ε) s t hθ

theorem measurableSet_closedCDFSet (A : J → I → ℝ) (u : I → ℝ) (ε t : ℝ) :
    MeasurableSet (closedCDFSet A u ε t) := by
  rw [← region_eq_closedCDFSet]
  exact (isClosed_region _ _ _ _).measurableSet

theorem strictCDFSet_eq (A : J → I → ℝ) (u : I → ℝ) (t : ℝ) :
    strictCDFSet A u t = GaussianSignCone.signCone A ∩ (linear u ⁻¹' Iic t) := rfl

theorem measurableSet_strictCDFSet (A : J → I → ℝ) (u : I → ℝ) (t : ℝ) :
    MeasurableSet (strictCDFSet A u t) :=
  (GaussianSignCone.measurableSet_signCone A).inter
    (measurableSet_Iic.preimage (show Measurable (linear u) by unfold linear; fun_prop))

def positiveMargin (n : ℕ) : ℝ := 1 / ((n : ℝ)+1)

theorem positiveMargin_pos (n : ℕ) : 0 < positiveMargin n := by unfold positiveMargin; positivity

theorem positiveMargin_tendsto : Tendsto positiveMargin atTop (𝓝 0) :=
  tendsto_one_div_add_atTop_nhds_zero_nat

theorem closedCDF_subset_strict (A : J → I → ℝ) (u : I → ℝ) (t : ℝ) (n : ℕ) :
    closedCDFSet A u (positiveMargin n) t ⊆ strictCDFSet A u t :=
  fun _ hz => ⟨fun j => (positiveMargin_pos n).trans_le (hz.1 j), hz.2⟩

theorem indicator_closedCDF_tendsto (A : J → I → ℝ) (u : I → ℝ) (t : ℝ) (z : I → ℝ) :
    Tendsto (fun n => (closedCDFSet A u (positiveMargin n) t).indicator (fun _ => (1 : ℝ)) z)
      atTop (𝓝 ((strictCDFSet A u t).indicator (fun _ => (1 : ℝ)) z)) := by
  classical
  by_cases hz : z ∈ strictCDFSet A u t
  · have hev : ∀ᶠ n in atTop, ∀ j, positiveMargin n < linear (A j) z :=
      Filter.eventually_all.2 fun j => positiveMargin_tendsto.eventually (gt_mem_nhds (hz.1 j))
    apply tendsto_const_nhds.congr'
    filter_upwards [hev] with n hn
    rw [indicator_of_mem hz, indicator_of_mem (show z ∈ closedCDFSet A u (positiveMargin n) t from
      ⟨fun j => (hn j).le, hz.2⟩)]
  · have hn (n : ℕ) : z ∉ closedCDFSet A u (positiveMargin n) t :=
      fun hc => hz (closedCDF_subset_strict A u t n hc)
    simpa only [indicator_of_notMem hz, indicator_of_notMem (hn _)] using
      tendsto_const_nhds (x := (0 : ℝ))

theorem closedCDF_mass_tendsto (A : J → I → ℝ) (u : I → ℝ) (t : ℝ) :
    Tendsto (fun n => (law I).real (closedCDFSet A u (positiveMargin n) t)) atTop
      (𝓝 ((law I).real (strictCDFSet A u t))) := by
  have hi (n : ℕ) : AEStronglyMeasurable
      ((closedCDFSet A u (positiveMargin n) t).indicator (fun _ => (1 : ℝ))) (law I) :=
    (measurable_const.indicator (measurableSet_closedCDFSet A u _ t)).aestronglyMeasurable
  have h := tendsto_integral_of_dominated_convergence (μ := law I) (fun _ => (1 : ℝ)) hi
    (integrable_const 1) (fun n => Eventually.of_forall fun z => by
      by_cases hz : z ∈ closedCDFSet A u (positiveMargin n) t <;> simp [hz])
    (Eventually.of_forall (indicator_closedCDF_tendsto A u t))
  have h1 (n : ℕ) : (∫ z, (closedCDFSet A u (positiveMargin n) t).indicator (fun _ => (1 : ℝ)) z ∂law I)
      = (law I).real (closedCDFSet A u (positiveMargin n) t) :=
    integral_indicator_one (measurableSet_closedCDFSet A u _ t)
  have h2 : (∫ z, (strictCDFSet A u t).indicator (fun _ => (1 : ℝ)) z ∂law I) =
      (law I).real (strictCDFSet A u t) := integral_indicator_one (measurableSet_strictCDFSet A u t)
  simpa only [h1, h2] using h

theorem strictCDF_mass_logConcave (A : J → I → ℝ) (u : I → ℝ) (s t : ℝ)
    {θ : ℝ} (hθ : θ ∈ Icc 0 1) :
    ((law I).real (strictCDFSet A u s)) ^ (1-θ) *
      ((law I).real (strictCDFSet A u t)) ^ θ ≤
      (law I).real (strictCDFSet A u (mix θ s t)) :=
  le_of_tendsto_of_tendsto
    (((closedCDF_mass_tendsto A u s).rpow_const (Or.inr (sub_nonneg.mpr hθ.2))).mul
      ((closedCDF_mass_tendsto A u t).rpow_const (Or.inr hθ.1)))
    (closedCDF_mass_tendsto A u (mix θ s t))
    (Eventually.of_forall fun n => closedCDF_mass_logConcave A u (positiveMargin n) s t hθ)

end NeuralGeneralization.GaussianSignCDF
end
