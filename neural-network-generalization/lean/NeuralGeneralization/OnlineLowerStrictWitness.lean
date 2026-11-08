import NeuralGeneralization.OnlineLowerVariationWitness

/-!
# Turning a closed-margin atomic witness into strict finite-width witnesses

The posterior is conditioned on strict margins. An atomic score certified
only at closed margin `1/2` is therefore not itself a permissible witness.
This module rescales its readout by a factor strictly larger than one while
preserving allocation slack and any given strict energy upper budget. Exact
integer copying then gives a strict witness at every sufficiently large width.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

theorem atomicAllocationMass_nonneg {d q : ℕ}
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) :
    0 ≤ atomicAllocationMass a c := by
  exact Finset.sum_nonneg (fun j _ => div_nonneg (abs_nonneg _) (Real.sqrt_nonneg _))

theorem atomicWeightedCost_nonneg {d q : ℕ}
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) :
    0 ≤ atomicWeightedCost a c := by
  exact Finset.sum_nonneg (fun j _ => mul_nonneg
    (mul_nonneg (by norm_num) (abs_nonneg _)) (Real.sqrt_nonneg _))

theorem atomicScore_scale {d q : ℕ} (φ : ℝ → ℝ)
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) (scale : ℝ) (x : Cube d) :
    atomicScore φ a (fun j => scale * c j) x = scale * atomicScore φ a c x := by
  unfold atomicScore
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem atomicAllocationMass_scale {d q : ℕ}
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) (scale : ℝ) (hscale : 0 ≤ scale) :
    atomicAllocationMass a (fun j => scale * c j) = scale * atomicAllocationMass a c := by
  unfold atomicAllocationMass
  simp_rw [abs_mul, abs_of_nonneg hscale]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem atomicWeightedCost_scale {d q : ℕ}
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) (scale : ℝ) (hscale : 0 ≤ scale) :
    atomicWeightedCost a (fun j => scale * c j) = scale * atomicWeightedCost a c := by
  unfold atomicWeightedCost
  simp_rw [abs_mul, abs_of_nonneg hscale]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- Strict slack in two linear budgets survives a common scale larger than one. -/
theorem exists_budget_preserving_scale (M E B : ℝ)
    (hM : 0 ≤ M) (hE : 0 ≤ E) (hslack : M < 1) (hbudget : E < B) :
    ∃ scale : ℝ, 1 < scale ∧ scale * M < 1 ∧ scale * E < B := by
  let ε := min ((1 - M) / (2 * (M + 1))) ((B - E) / (2 * (E + 1)))
  have hdenM : 0 < 2 * (M + 1) := by linarith
  have hdenE : 0 < 2 * (E + 1) := by linarith
  have hε : 0 < ε := lt_min
    (div_pos (by linarith) hdenM) (div_pos (by linarith) hdenE)
  have heM : ε * (2 * (M + 1)) ≤ 1 - M :=
    (le_div_iff₀ hdenM).mp (min_le_left _ _)
  have heE : ε * (2 * (E + 1)) ≤ B - E :=
    (le_div_iff₀ hdenE).mp (min_le_right _ _)
  refine ⟨1 + ε, by linarith, ?_, ?_⟩ <;> nlinarith

/-- Actual strict-margin witnesses at every large width, with any energy
budget strictly above the closed atomic cost. No minimum at the boundary
of an open Gaussian event is assumed to be attained. -/
theorem closed_atomic_score_strict_witness_all_large {d q : ℕ}
    (φ : ℝ → ℝ) (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hc : ∀ j, c j ≠ 0)
    (hslack : atomicAllocationMass a c < 1) (g : BooleanFunction d)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g x) * atomicScore φ a c x)
    (B : ℝ) (hbudget : atomicWeightedCost a c < B) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N →
      ∃ w : Weights d N 0, w ∈ marginEvent φ (1 / 2) g ∧ weightedSquaredNorm w < B := by
  obtain ⟨scale, hscale, hm, he⟩ := exists_budget_preserving_scale
    (atomicAllocationMass a c) (atomicWeightedCost a c) B
    (atomicAllocationMass_nonneg a c) (atomicWeightedCost_nonneg a c) hslack hbudget
  have hscalepos : 0 < scale := by linarith
  have hc' : ∀ j, scale * c j ≠ 0 := fun j => mul_ne_zero (ne_of_gt hscalepos) (hc j)
  have hm' : atomicAllocationMass a (fun j => scale * c j) < 1 := by
    rw [atomicAllocationMass_scale a c scale hscalepos.le]
    exact hm
  have he' : atomicWeightedCost a (fun j => scale * c j) < B := by
    rw [atomicWeightedCost_scale a c scale hscalepos.le]
    exact he
  obtain ⟨N₀, hN₀, hlarge⟩ := atomicScore_exists_at_every_large_width
    φ a (fun j => scale * c j) ha hc' hm'
    (B - atomicWeightedCost a (fun j => scale * c j)) (sub_pos.mpr he')
  refine ⟨N₀, hN₀, ?_⟩
  intro N hN
  obtain ⟨w, hw, hcost⟩ := hlarge N hN
  refine ⟨w, ?_, by linarith⟩
  intro x
  rw [hw x, atomicScore_scale]
  have hx := hmargin x
  have hstrict : (1 / 2 : ℝ) < scale * (labelReal (g x) * atomicScore φ a c x) := by
    nlinarith
  simpa only [mul_assoc, mul_left_comm, mul_comm] using hstrict

end NeuralGeneralization.OnlineLower
