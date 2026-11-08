import NeuralGeneralization.Network
import Mathlib.Data.Fintype.EquivFin
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Algebra.Order.Floor.Semiring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity.Basic

/-!
# Integer allocation and exact copying of shallow neurons

A finite atomic representation is realized at every sufficiently large width
by allocating `ceil (N * p j)` copies to atom `j`. Incoming coefficients are
unchanged; the readout is divided among the copies. Thus this construction
works for nonhomogeneous activations such as tanh, and not merely for ReLU.

The algebraic cost identity and the `O(1/N)` bound are proved here. They do
not assume an infinite-width neural representation theorem or the online
lower-bound conclusion.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

/-- Integer numbers of copies at width `N`. -/
def roundedCopies {q : ℕ} (p : Fin q → ℝ) (N : ℕ) (j : Fin q) : ℕ :=
  ⌈(N : ℝ) * p j⌉₊

theorem roundedCopies_pos {q N : ℕ} {p : Fin q → ℝ}
    (hN : 0 < N) (hp : ∀ j, 0 < p j) (j : Fin q) :
    0 < roundedCopies p N j := by
  apply Nat.one_le_ceil_iff.mpr
  exact mul_pos (by exact_mod_cast hN) (hp j)

/-- The unused allocation mass absorbs all integer-rounding overhead. -/
theorem roundedCopies_capacity {q N : ℕ} {p : Fin q → ℝ}
    (hp : ∀ j, 0 ≤ p j)
    (hcapacity : (q : ℝ) ≤ (N : ℝ) * (1 - ∑ j, p j)) :
    ∑ j, roundedCopies p N j ≤ N := by
  have hterm (j : Fin q) : (roundedCopies p N j : ℝ) ≤ (N : ℝ) * p j + 1 :=
    (Nat.ceil_lt_add_one (mul_nonneg (Nat.cast_nonneg _) (hp j))).le
  have hsum := Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hterm j)
  have hreal : (∑ j, (roundedCopies p N j : ℝ)) ≤ (N : ℝ) := by
    calc
      _ ≤ ∑ j, ((N : ℝ) * p j + 1) := hsum
      _ = (N : ℝ) * (∑ j, p j) + q := by
        simp [Finset.sum_add_distrib, Finset.mul_sum]
      _ ≤ (N : ℝ) := by nlinarith
  exact_mod_cast hreal

/-- Strict allocation slack gives feasible positive counts at every large width. -/
theorem roundedCopies_eventually_feasible {q : ℕ} {p : Fin q → ℝ}
    (hp : ∀ j, 0 < p j) (hslack : (∑ j, p j) < 1) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N →
      (∀ j, 0 < roundedCopies p N j) ∧ (∑ j, roundedCopies p N j ≤ N) := by
  have hden : 0 < 1 - ∑ j, p j := sub_pos.mpr hslack
  obtain ⟨M, hM⟩ := exists_nat_ge ((q : ℝ) / (1 - ∑ j, p j))
  refine ⟨max M 1, by omega, ?_⟩
  intro N hN
  have hNpos : 0 < N := by omega
  have hMN : (M : ℝ) ≤ (N : ℝ) := by exact_mod_cast (le_trans (le_max_left M 1) hN)
  constructor
  · exact fun j => roundedCopies_pos hNpos hp j
  · apply roundedCopies_capacity (fun j => (hp j).le)
    exact (div_le_iff₀ hden).mp (hM.trans hMN)

/-- The exact one-atom excess above the real-valued optimal allocation. -/
theorem allocation_excess_identity (A p N r : ℝ) (hN : N ≠ 0) (hr : r ≠ 0) :
    A * r / N + N * A * p ^ 2 / r - 2 * A * p =
      (A / N) * (r - N * p) ^ 2 / r := by
  field_simp
  ring

/-- A rounded atom costs at most `A/N` more than its exact allocation. -/
theorem rounded_allocation_excess {N : ℕ} (hN : 0 < N)
    {A p : ℝ} (hA : 0 ≤ A) (hp : 0 < p) :
    0 ≤ A * (⌈(N : ℝ) * p⌉₊ : ℝ) / N +
      (N : ℝ) * A * p ^ 2 / ⌈(N : ℝ) * p⌉₊ - 2 * A * p ∧
    A * (⌈(N : ℝ) * p⌉₊ : ℝ) / N +
      (N : ℝ) * A * p ^ 2 / ⌈(N : ℝ) * p⌉₊ - 2 * A * p ≤ A / N := by
  have hNR : 0 < (N : ℝ) := by exact_mod_cast hN
  have hrN : 1 ≤ ⌈(N : ℝ) * p⌉₊ := Nat.one_le_ceil_iff.mpr (mul_pos hNR hp)
  have hr : (1 : ℝ) ≤ (⌈(N : ℝ) * p⌉₊ : ℝ) := by exact_mod_cast hrN
  have hrpos : 0 < (⌈(N : ℝ) * p⌉₊ : ℝ) := lt_of_lt_of_le zero_lt_one hr
  rw [allocation_excess_identity A p N _ (ne_of_gt hNR) (ne_of_gt hrpos)]
  have hlo := Nat.le_ceil ((N : ℝ) * p)
  have hhi := Nat.ceil_lt_add_one (mul_nonneg hNR.le hp.le)
  have hsq : ((⌈(N : ℝ) * p⌉₊ : ℝ) - (N : ℝ) * p) ^ 2 ≤ 1 := by nlinarith
  have hAN : 0 ≤ A / (N : ℝ) := div_nonneg hA hNR.le
  constructor
  · positivity
  · apply (div_le_iff₀ hrpos).mpr
    calc
      _ ≤ (A / (N : ℝ)) * 1 := mul_le_mul_of_nonneg_left hsq hAN
      _ ≤ (A / (N : ℝ)) * (⌈(N : ℝ) * p⌉₊ : ℝ) :=
        mul_le_mul_of_nonneg_left hr hAN

/-- Total exact cost of the integer allocation. -/
def allocationCost {q : ℕ} (A p : Fin q → ℝ) (N : ℕ) : ℝ :=
  ∑ j, (A j * (roundedCopies p N j : ℝ) / N +
    (N : ℝ) * A j * p j ^ 2 / roundedCopies p N j)

theorem allocationCost_error_bound {q N : ℕ} {A p : Fin q → ℝ}
    (hN : 0 < N) (hA : ∀ j, 0 ≤ A j) (hp : ∀ j, 0 < p j) :
    0 ≤ allocationCost A p N - ∑ j, 2 * A j * p j ∧
    allocationCost A p N - ∑ j, 2 * A j * p j ≤ (∑ j, A j) / N := by
  have hj (j : Fin q) := rounded_allocation_excess hN (hA j) (hp j)
  constructor
  · rw [allocationCost, ← Finset.sum_sub_distrib]
    exact Finset.sum_nonneg (fun j _ => (hj j).1)
  · rw [allocationCost, ← Finset.sum_sub_distrib, Finset.sum_div]
    exact Finset.sum_le_sum (fun j _ => (hj j).2)

/-- A neuron index contains either an atom and one of its copies or a pad. -/
abbrev CopyIndex {q : ℕ} (r : Fin q → ℕ) (P : ℕ) :=
  (Σ j : Fin q, Fin (r j)) ⊕ Fin P

/-- Exact shallow implementation of a finite atomic sum. -/
def allocatedWeights {d q N P : ℕ} (r : Fin q → ℕ)
    (e : CopyIndex r P ≃ Fin N)
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) : Weights d N 0
  | Sum.inl (i, j) => match e.symm i with
      | Sum.inl v => a v.1 j
      | Sum.inr _ => 0
  | Sum.inr (Sum.inl (s, _, _)) => Fin.elim0 s
  | Sum.inr (Sum.inr i) => match e.symm i with
      | Sum.inl v => c v.1 / r v.1
      | Sum.inr _ => 0

/-- Summing a quantity constant on each group of copies. -/
theorem sum_allocated_copies {q N P : ℕ} (r : Fin q → ℕ)
    (e : CopyIndex r P ≃ Fin N) (F : Fin q → ℝ) :
    (∑ i : Fin N, match e.symm i with
      | Sum.inl v => F v.1
      | Sum.inr _ => 0) = ∑ j, (r j : ℝ) * F j := by
  classical
  let G : CopyIndex r P → ℝ := fun i => match i with
    | Sum.inl v => F v.1
    | Sum.inr _ => 0
  change (∑ i, G (e.symm i)) = _
  rw [e.symm.sum_comp]
  simp [G, Fintype.sum_sigma]

/-- The copying preserves the real output for every activation, with no
homogeneity or zero-at-zero assumption. -/
theorem networkOutput_allocated {d q N P : ℕ} (r : Fin q → ℕ)
    (hr : ∀ j, 0 < r j) (e : CopyIndex r P ≃ Fin N)
    (φ : ℝ → ℝ) (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (x : Cube d) :
    networkOutput φ (allocatedWeights r e a c) x =
      ∑ j, c j * φ (∑ k, a j k * inputVector x k) := by
  classical
  unfold networkOutput finalHidden
  simp only [List.finRange_zero, List.foldl_nil]
  calc
    _ = ∑ i : Fin N, match e.symm i with
      | Sum.inl v => (c v.1 / r v.1) * φ (∑ k, a v.1 k * inputVector x k)
      | Sum.inr _ => 0 := by
        apply Finset.sum_congr rfl
        intro i hi
        cases hi' : e.symm i <;> simp [allocatedWeights, firstHidden, hi']
    _ = ∑ j, (r j : ℝ) *
        ((c j / r j) * φ (∑ k, a j k * inputVector x k)) :=
      sum_allocated_copies r e (fun j => (c j / r j) * φ (∑ k, a j k * inputVector x k))
    _ = _ := by
      apply Finset.sum_congr rfl
      intro j hj
      have hrR : (r j : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt (hr j))
      field_simp

/-- Exact cost of the copied network in the paper's weighted Gaussian norm. -/
theorem weightedSquaredNorm_allocated {d q N P : ℕ} (r : Fin q → ℕ)
    (hr : ∀ j, 0 < r j) (e : CopyIndex r P ≃ Fin N)
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) :
    weightedSquaredNorm (allocatedWeights r e a c) =
      ∑ j, ((d : ℝ) * (r j : ℝ) * (∑ k, a j k ^ 2) / N +
        (N : ℝ) * c j ^ 2 / r j) := by
  classical
  have hfirst : (∑ i, ∑ k, allocatedWeights r e a c (.inl (i, k)) ^ 2) =
      ∑ j, (r j : ℝ) * ∑ k, a j k ^ 2 := by
    calc
      _ = ∑ i : Fin N, match e.symm i with
          | Sum.inl v => ∑ k, a v.1 k ^ 2
          | Sum.inr _ => 0 := by
        apply Finset.sum_congr rfl
        intro i hi
        cases hi' : e.symm i <;> simp [allocatedWeights, hi']
      _ = _ := sum_allocated_copies r e (fun j => ∑ k, a j k ^ 2)
  have hlast : (∑ i, allocatedWeights r e a c (.inr (.inr i)) ^ 2) =
      ∑ j, c j ^ 2 / r j := by
    calc
      _ = ∑ i : Fin N, match e.symm i with
          | Sum.inl v => (c v.1 / r v.1) ^ 2
          | Sum.inr _ => 0 := by
        apply Finset.sum_congr rfl
        intro i hi
        cases hi' : e.symm i <;> simp [allocatedWeights, hi']
      _ = ∑ j, (r j : ℝ) * (c j / r j) ^ 2 :=
        sum_allocated_copies r e (fun j => (c j / r j) ^ 2)
      _ = _ := by
        apply Finset.sum_congr rfl
        intro j hj
        have hrR : (r j : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt (hr j))
        field_simp
  unfold weightedSquaredNorm
  rw [hfirst, hlast]
  simp only [Finset.univ_eq_empty, Finset.sum_empty, add_zero]
  rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- A finite injection of active copies, completed by disconnected padding. -/
def allocationEquiv {q N : ℕ} (r : Fin q → ℕ) (hcap : ∑ j, r j ≤ N) :
    CopyIndex r (N - ∑ j, r j) ≃ Fin N :=
  Fintype.equivOfCardEq (by simp [CopyIndex, Fintype.card_sigma, Nat.add_sub_of_le hcap])

/-- Every fixed finite atomic score with allocation slack has an exact
implementation at every sufficiently large width, with the limiting energy
approached from above. The hypotheses `A = d‖a‖²` and `c² = A p²` express the
optimal real-valued allocation and are explicit algebraic equalities. -/
theorem exists_allocated_network_all_large {d q : ℕ}
    (φ : ℝ → ℝ) (a : Fin q → Fin (d + 1) → ℝ) (c A p : Fin q → ℝ)
    (hA : ∀ j, A j = (d : ℝ) * ∑ k, a j k ^ 2)
    (hc : ∀ j, c j ^ 2 = A j * p j ^ 2)
    (hp : ∀ j, 0 < p j) (hslack : (∑ j, p j) < 1)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N →
      ∃ w : Weights d N 0,
        (∀ x, networkOutput φ w x =
          ∑ j, c j * φ (∑ k, a j k * inputVector x k)) ∧
        weightedSquaredNorm w < (∑ j, 2 * A j * p j) + ε := by
  classical
  have hAnonneg : ∀ j, 0 ≤ A j := by
    intro j
    rw [hA j]
    exact mul_nonneg (Nat.cast_nonneg _) (Finset.sum_nonneg (fun k _ => sq_nonneg _))
  obtain ⟨M, hM, hfeasible⟩ := roundedCopies_eventually_feasible hp hslack
  obtain ⟨K, hK⟩ := exists_nat_gt ((∑ j, A j) / ε)
  refine ⟨max M K, lt_of_lt_of_le hM (le_max_left _ _), ?_⟩
  intro N hN
  have hMN : M ≤ N := (le_max_left _ _).trans hN
  have hKN : K ≤ N := (le_max_right _ _).trans hN
  have hNpos : 0 < N := hM.trans_le hMN
  obtain ⟨hr, hcap⟩ := hfeasible N hMN
  let e := allocationEquiv (roundedCopies p N) hcap
  let w := allocatedWeights (roundedCopies p N) e a c
  refine ⟨w, fun x => networkOutput_allocated _ hr e φ a c x, ?_⟩
  have hw : weightedSquaredNorm w = allocationCost A p N := by
    rw [weightedSquaredNorm_allocated _ hr]
    unfold allocationCost
    apply Finset.sum_congr rfl
    intro j hj
    rw [hc j, hA j]
    ring
  have hbound := (allocationCost_error_bound hNpos hAnonneg hp).2
  have hNR : 0 < (N : ℝ) := by exact_mod_cast hNpos
  have hKNreal : (K : ℝ) ≤ (N : ℝ) := by exact_mod_cast hKN
  have herror : (∑ j, A j) / (N : ℝ) < ε := by
    apply (div_lt_iff₀ hNR).mpr
    have he := (div_lt_iff₀ hε).mp (hK.trans_le hKNreal)
    simpa [mul_comm] using he
  rw [hw]
  linarith

end NeuralGeneralization.OnlineLower
