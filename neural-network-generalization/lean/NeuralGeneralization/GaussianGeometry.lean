import Mathlib.Topology.Algebra.Ring.Real
import Mathlib.Topology.MetricSpace.Pseudo.Pi
import Mathlib.Topology.Algebra.Monoid
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.Linarith

/-!
# Near-minimal rectangles in open sets

This file proves the finite-dimensional geometric step in the small-variance
Gaussian rate: every nonempty open set contains a positive-radius rectangle
whose worst coordinatewise quadratic energy approaches the infimum energy.
-/

noncomputable section
open scoped BigOperators Topology
open Filter

namespace NeuralGeneralization.GaussianRate

variable {ι : Type*} [Fintype ι]

/-- The unnormalized squared Euclidean norm of a coordinate vector. -/
def squareSum (x : ι → ℝ) : ℝ := ∑ i, x i ^ 2

/-- Infimum of the squared Euclidean norm on an event. -/
def squareInf (V : Set (ι → ℝ)) : ℝ := sInf (squareSum '' V)

lemma squareSum_nonneg (x : ι → ℝ) : 0 ≤ squareSum x :=
  Finset.sum_nonneg fun i _ => sq_nonneg (x i)

lemma squareInf_bddBelow (V : Set (ι → ℝ)) : BddBelow (squareSum '' V) := by
  refine ⟨0, ?_⟩
  rintro y ⟨x, hx, rfl⟩
  exact squareSum_nonneg x

lemma squareInf_nonneg {V : Set (ι → ℝ)} (hV : V.Nonempty) :
    0 ≤ squareInf V := by
  apply le_csInf (hV.image squareSum)
  rintro y ⟨x, hx, rfl⟩
  exact squareSum_nonneg x

lemma squareInf_le {V : Set (ι → ℝ)} {x : ι → ℝ} (hx : x ∈ V) :
    squareInf V ≤ squareSum x :=
  csInf_le (squareInf_bddBelow V) (Set.mem_image_of_mem squareSum hx)

/-- A closed coordinate rectangle of positive radius fits inside any open
neighborhood, while its coordinatewise quadratic upper bound can be made
arbitrarily close to the squared norm of its center. -/
theorem exists_rectangle_near_center {V : Set (ι → ℝ)} (hV : IsOpen V)
    (a : ι → ℝ) (ha : a ∈ V) (b : ℝ) (hb : squareSum a < b) :
    ∃ r : ℝ, 0 < r ∧
      (Set.pi Set.univ fun i => Set.Icc (a i - r) (a i + r)) ⊆ V ∧
      (∑ i, (|a i| + r) ^ 2) < b := by
  classical
  obtain ⟨ρ, hρ, hball⟩ := Metric.isOpen_iff.mp hV a ha
  have hc : Continuous (fun r : ℝ => ∑ i, (|a i| + r) ^ 2) := by fun_prop
  have he0 : (∑ i, (|a i| + (0 : ℝ)) ^ 2) < b := by
    simpa [squareSum] using hb
  have hevent : ∀ᶠ r : ℝ in 𝓝 0, (∑ i, (|a i| + r) ^ 2) < b :=
    hc.continuousAt.eventually (gt_mem_nhds he0)
  have hright : ∀ᶠ r : ℝ in 𝓝[>] 0,
      0 < r ∧ r < ρ ∧ (∑ i, (|a i| + r) ^ 2) < b := by
    filter_upwards [self_mem_nhdsWithin,
      (eventually_lt_nhds hρ).filter_mono nhdsWithin_le_nhds,
      hevent.filter_mono nhdsWithin_le_nhds] with r hr hrρ hre
    exact ⟨hr, hrρ, hre⟩
  obtain ⟨r, hr, hrρ, hre⟩ := hright.exists
  refine ⟨r, hr, ?_, hre⟩
  intro x hx
  apply hball
  apply lt_of_le_of_lt ?_ hrρ
  apply (dist_pi_le_iff hr.le).mpr
  intro i
  have hi := hx i (Set.mem_univ i)
  rw [Real.dist_eq]
  exact abs_le.mpr ⟨by linarith [hi.1], by linarith [hi.2]⟩

/-- Every nonempty open set contains a rectangle with positive side length and
quadratic upper bound within any prescribed positive error of the infimum. -/
theorem exists_rectangle_near_inf {V : Set (ι → ℝ)} (hV : IsOpen V)
    (hne : V.Nonempty) (ε : ℝ) (hε : 0 < ε) :
    ∃ a : ι → ℝ, ∃ r : ℝ, 0 < r ∧
      (Set.pi Set.univ fun i => Set.Icc (a i - r) (a i + r)) ⊆ V ∧
      (∑ i, (|a i| + r) ^ 2) < squareInf V + ε := by
  obtain ⟨y, ⟨a, ha, rfl⟩, hy⟩ :=
    exists_lt_of_csInf_lt (hne.image squareSum)
      (show sInf (squareSum '' V) < squareInf V + ε by
        unfold squareInf
        linarith)
  obtain ⟨r, hr, hrect, henergy⟩ := exists_rectangle_near_center hV a ha _ hy
  exact ⟨a, r, hr, hrect, henergy⟩

end NeuralGeneralization.GaussianRate
