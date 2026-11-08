import NeuralGeneralization.OnlineLowerHomogeneousWitness

/-!
# Exact finite-width energy for homogeneous activations

Each nonzero atom is placed in one neuron and rescaled individually to
balance its incoming and readout contributions to the Gaussian cost. Thus
the weighted atomic cost is attained exactly at every width at least the
number of atoms. The width threshold is independent of any later energy gap.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

def balancingScale (A c N : ℝ) : ℝ := Real.sqrt (N * |c| / Real.sqrt A)

theorem balancingScale_pos {A c N : ℝ} (hA : 0 < A) (hc : c ≠ 0) (hN : 0 < N) :
    0 < balancingScale A c N :=
  Real.sqrt_pos.mpr (div_pos (mul_pos hN (abs_pos.mpr hc)) (Real.sqrt_pos.mpr hA))

theorem balancingScale_sq {A c N : ℝ} (hA : 0 < A) (hc : c ≠ 0) (hN : 0 < N) :
    balancingScale A c N ^ 2 = N * |c| / Real.sqrt A :=
  Real.sq_sqrt (le_of_lt (div_pos (mul_pos hN (abs_pos.mpr hc)) (Real.sqrt_pos.mpr hA)))

theorem balanced_neuron_energy {A c N : ℝ} (hA : 0 < A) (hc : c ≠ 0) (hN : 0 < N) :
    A * balancingScale A c N ^ 2 / N +
      N * (c / balancingScale A c N) ^ 2 = 2 * |c| * Real.sqrt A := by
  have hNr : N ≠ 0 := ne_of_gt hN
  have hcr : |c| ≠ 0 := abs_ne_zero.mpr hc
  have hs : Real.sqrt A ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr hA)
  have hAquot : A / Real.sqrt A = Real.sqrt A := by
    apply (div_eq_iff hs).mpr
    nlinarith [Real.sq_sqrt hA.le]
  have hcquot : c ^ 2 / |c| = |c| := by
    rw [← sq_abs c, pow_two, mul_div_cancel_right₀ _ hcr]
  rw [div_pow, balancingScale_sq hA hc hN]
  calc
    _ = |c| * (A / Real.sqrt A) + (c ^ 2 / |c|) * Real.sqrt A := by
      field_simp
    _ = 2 * |c| * Real.sqrt A := by rw [hAquot, hcquot]; ring

/-- Exact output and exact weighted energy at every width `N ≥ q`.
Incoming coefficients are rescaled separately; no cloning-count approximation
or allocation-slack premise is needed for a homogeneous activation. -/
theorem homogeneous_atomic_exact_at_width {d q N : ℕ}
    (φ : ℝ → ℝ) (hφ : ∀ scale : ℝ, 0 < scale → ∀ t, φ (scale * t) = scale * φ t)
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hc : ∀ j, c j ≠ 0)
    (hN : 0 < N) (hqN : q ≤ N) :
    ∃ w : Weights d N 0,
      (∀ x, networkOutput φ w x = atomicScore φ a c x) ∧
      weightedSquaredNorm w = atomicWeightedCost a c := by
  classical
  let scale : Fin q → ℝ := fun j => balancingScale (incomingAtomCost (a j)) (c j) N
  have hs : ∀ j, 0 < scale j := fun j =>
    balancingScale_pos (ha j) (hc j) (by exact_mod_cast hN)
  let a' : Fin q → Fin (d + 1) → ℝ := fun j k => scale j * a j k
  let c' : Fin q → ℝ := fun j => c j / scale j
  have hcap : (∑ _j : Fin q, (1 : ℕ)) ≤ N := by simpa using hqN
  let e := allocationEquiv (fun _j : Fin q => 1) hcap
  let w := allocatedWeights (fun _j : Fin q => 1) e a' c'
  refine ⟨w, ?_, ?_⟩
  · intro x
    rw [networkOutput_allocated _ (fun _ => by norm_num)]
    unfold atomicScore
    apply Finset.sum_congr rfl
    intro j hj
    have hin : (∑ k, a' j k * inputVector x k) =
        scale j * ∑ k, a j k * inputVector x k := by
      dsimp [a']
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro k hk
      ring
    rw [hin, hφ (scale j) (hs j)]
    dsimp only [c']
    field_simp [ne_of_gt (hs j)]
  · rw [weightedSquaredNorm_allocated _ (fun _ => by norm_num)]
    unfold atomicWeightedCost
    apply Finset.sum_congr rfl
    intro j hj
    have hAj : incomingAtomCost (a' j) = scale j ^ 2 * incomingAtomCost (a j) :=
      incomingAtomCost_scale (a j) (scale j)
    have he := balanced_neuron_energy (ha j) (hc j) (show (0 : ℝ) < N by exact_mod_cast hN)
    simp only [Nat.cast_one, mul_one, div_one]
    dsimp only [c']
    change incomingAtomCost (a' j) / N + (N : ℝ) * (c j / scale j) ^ 2 = _
    rw [hAj]
    simpa only [mul_comm] using he

/-- Closed margin can be made strict without changing the explicit width
threshold: readout scaling and exact balancing are performed at that width. -/
theorem homogeneous_closed_score_strict_witness_at_width {d q N : ℕ}
    (φ : ℝ → ℝ) (hφ : ∀ scale : ℝ, 0 < scale → ∀ t, φ (scale * t) = scale * φ t)
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hc : ∀ j, c j ≠ 0)
    (g : BooleanFunction d)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g x) * atomicScore φ a c x)
    (B : ℝ) (hbudget : atomicWeightedCost a c < B)
    (hN : 0 < N) (hqN : q ≤ N) :
    ∃ w : Weights d N 0, w ∈ marginEvent φ (1 / 2) g ∧ weightedSquaredNorm w < B := by
  obtain ⟨scale, hs, _, hcost⟩ := exists_budget_preserving_scale
    0 (atomicWeightedCost a c) B (by norm_num)
    (atomicWeightedCost_nonneg a c) (by norm_num) hbudget
  have hspos : 0 < scale := by linarith
  have hc' : ∀ j, scale * c j ≠ 0 := fun j => mul_ne_zero (ne_of_gt hspos) (hc j)
  obtain ⟨w, hw, he⟩ := homogeneous_atomic_exact_at_width
    φ hφ a (fun j => scale * c j) ha hc' hN hqN
  refine ⟨w, ?_, ?_⟩
  · intro x
    rw [hw x, atomicScore_scale]
    have hx := hmargin x
    have hh : (1 / 2 : ℝ) < scale * (labelReal (g x) * atomicScore φ a c x) := by
      nlinarith
    simpa only [mul_comm, mul_left_comm, mul_assoc] using hh
  · rw [he, atomicWeightedCost_scale a c scale hspos.le]
    exact hcost

end NeuralGeneralization.OnlineLower
