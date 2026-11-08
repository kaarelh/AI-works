import NeuralGeneralization.OnlineLowerAllocation
import Mathlib.Analysis.Real.Sqrt

/-!
# From an actual finite atomic representation to every large finite width

For incoming vectors `a j` and signed readouts `c j`, the continuum weighted
cost is `2 * sqrt d * ∑ |c j| * ‖a j‖`. We write the equivalent expression
using `sqrt (d * ∑ a²)` to avoid any choice of Euclidean-space coercion.
The total neuron allocation mass is `∑ |c j| / sqrt (d * ∑ a²)`.
Strict mass below one gives exact score preservation and convergence of the
actual finite-network Gaussian cost. Zero atoms are excluded explicitly.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

/-- The squared incoming cost of one atom, including its constant coordinate. -/
def incomingAtomCost {d : ℕ} (a : Fin (d + 1) → ℝ) : ℝ :=
  (d : ℝ) * ∑ k, a k ^ 2

/-- Exact finite atomic score on the Boolean cube. -/
def atomicScore {d q : ℕ} (φ : ℝ → ℝ)
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) (x : Cube d) : ℝ :=
  ∑ j, c j * φ (∑ k, a j k * inputVector x k)

/-- The real-valued optimal neuron allocation mass. -/
def atomicAllocationMass {d q : ℕ}
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) : ℝ :=
  ∑ j, |c j| / Real.sqrt (incomingAtomCost (a j))

/-- The actual limiting weighted parameter cost of this finite representation. -/
def atomicWeightedCost {d q : ℕ}
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) : ℝ :=
  ∑ j, 2 * |c j| * Real.sqrt (incomingAtomCost (a j))

theorem optimal_allocation_square {A c : ℝ} (hA : 0 < A) :
    c ^ 2 = A * (|c| / Real.sqrt A) ^ 2 := by
  rw [div_pow, Real.sq_sqrt hA.le, sq_abs]
  field_simp

theorem optimal_allocation_cost {A c : ℝ} (hA : 0 < A) :
    2 * A * (|c| / Real.sqrt A) = 2 * |c| * Real.sqrt A := by
  have hs : Real.sqrt A ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr hA)
  have hsq := Real.sq_sqrt hA.le
  have hcancel : A / Real.sqrt A = Real.sqrt A := by
    apply (div_eq_iff hs).mpr
    nlinarith
  calc
    2 * A * (|c| / Real.sqrt A) = 2 * |c| * (A / Real.sqrt A) := by ring
    _ = 2 * |c| * Real.sqrt A := by rw [hcancel]

/-- The converse cost comparison for one actual neuron is just a square.
Unlike the copying theorem, this applies without allocation slack. -/
theorem atomic_cost_le_neuron_energy (A c N : ℝ) (hA : 0 ≤ A) (hN : 0 < N) :
    2 * |c| * Real.sqrt A ≤ A / N + N * c ^ 2 := by
  have hs := sq_nonneg (Real.sqrt A - N * |c|)
  rw [sub_sq, mul_pow, Real.sq_sqrt hA, sq_abs] at hs
  calc
    2 * |c| * Real.sqrt A ≤ (A + N ^ 2 * c ^ 2) / N := by
      apply (le_div_iff₀ hN).mpr
      nlinarith
    _ = A / N + N * c ^ 2 := by
      field_simp

/-- The list of incoming vectors of an actual shallow network. -/
def incomingAtoms {d N : ℕ} (w : Weights d N 0) : Fin N → Fin (d + 1) → ℝ :=
  fun j k => w (.inl (j, k))

/-- Its actual readout coefficients. -/
def readoutAtoms {d N : ℕ} (w : Weights d N 0) : Fin N → ℝ :=
  fun j => w (.inr (.inr j))

theorem networkOutput_eq_atomicScore {d N : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N 0) (x : Cube d) :
    networkOutput φ w x = atomicScore φ (incomingAtoms w) (readoutAtoms w) x := by
  simp [networkOutput, finalHidden, firstHidden, atomicScore, incomingAtoms, readoutAtoms]

/-- Every actual shallow network has atomic weighted cost at most its
Gaussian energy. This direction has no width asymptotics and no assumptions
on the activation or the output signs. -/
theorem atomicWeightedCost_le_weightedSquaredNorm {d N : ℕ}
    (hN : 0 < N) (w : Weights d N 0) :
    atomicWeightedCost (incomingAtoms w) (readoutAtoms w) ≤ weightedSquaredNorm w := by
  have hNR : 0 < (N : ℝ) := by exact_mod_cast hN
  have hj (j : Fin N) := atomic_cost_le_neuron_energy
    (incomingAtomCost (incomingAtoms w j)) (readoutAtoms w j) N
    (mul_nonneg (Nat.cast_nonneg _) (Finset.sum_nonneg (fun k _ => sq_nonneg _))) hNR
  calc
    atomicWeightedCost (incomingAtoms w) (readoutAtoms w) ≤
      ∑ j, (incomingAtomCost (incomingAtoms w j) / (N : ℝ) +
        (N : ℝ) * readoutAtoms w j ^ 2) :=
      Finset.sum_le_sum (fun j _ => hj j)
    _ = weightedSquaredNorm w := by
      unfold incomingAtomCost incomingAtoms readoutAtoms weightedSquaredNorm
      simp only [Finset.univ_eq_empty, Finset.sum_empty, add_zero,
        Finset.sum_add_distrib]
      rw [← Finset.sum_div, ← Finset.mul_sum, ← Finset.mul_sum]
      ring

/-- Literal finite-width witness theorem for an arbitrary activation.
Neither homogeneity nor `φ 0 = 0` is required. -/
theorem atomicScore_exists_at_every_large_width {d q : ℕ}
    (φ : ℝ → ℝ) (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hc : ∀ j, c j ≠ 0)
    (hslack : atomicAllocationMass a c < 1) (ε : ℝ) (hε : 0 < ε) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N →
      ∃ w : Weights d N 0,
        (∀ x, networkOutput φ w x = atomicScore φ a c x) ∧
        weightedSquaredNorm w < atomicWeightedCost a c + ε := by
  let A : Fin q → ℝ := fun j => incomingAtomCost (a j)
  let p : Fin q → ℝ := fun j => |c j| / Real.sqrt (A j)
  have hp : ∀ j, 0 < p j := fun j =>
    div_pos (abs_pos.mpr (hc j)) (Real.sqrt_pos.mpr (ha j))
  have hbalance : ∀ j, c j ^ 2 = A j * p j ^ 2 :=
    fun j => optimal_allocation_square (ha j)
  have heq : (∑ j, 2 * A j * p j) = atomicWeightedCost a c := by
    apply Finset.sum_congr rfl
    intro j hj
    exact optimal_allocation_cost (ha j)
  obtain ⟨N₀, hN₀, hlarge⟩ := exists_allocated_network_all_large φ a c A p
    (fun j => rfl) hbalance hp hslack ε hε
  refine ⟨N₀, hN₀, ?_⟩
  intro N hN
  obtain ⟨w, hw, hcost⟩ := hlarge N hN
  exact ⟨w, hw, by simpa only [heq] using hcost⟩

end NeuralGeneralization.OnlineLower
