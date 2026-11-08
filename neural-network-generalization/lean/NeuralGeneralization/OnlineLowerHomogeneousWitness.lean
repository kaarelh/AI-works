import NeuralGeneralization.OnlineLowerStrictWitness

/-!
# ReLU homogeneity removes the atomic allocation-mass restriction

Rescaling each incoming vector by `scale > 0` and its readout by `1/scale`
preserves the score and weighted atomic cost for a positively homogeneous
activation. It divides the required allocation mass by `scale²`.
Consequently every finite nonzero ReLU atomic representation admits strict
finite-width witnesses at all sufficiently large widths, without a separate
allocation-mass hypothesis. This argument is not used for tanh.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

theorem incomingAtomCost_scale {d : ℕ} (a : Fin (d + 1) → ℝ) (scale : ℝ) :
    incomingAtomCost (fun k => scale * a k) = scale ^ 2 * incomingAtomCost a := by
  unfold incomingAtomCost
  simp_rw [mul_pow]
  rw [← Finset.mul_sum]
  ring

theorem sqrt_incomingAtomCost_scale {d : ℕ} (a : Fin (d + 1) → ℝ)
    (scale : ℝ) (hscale : 0 < scale) :
    Real.sqrt (incomingAtomCost (fun k => scale * a k)) =
      scale * Real.sqrt (incomingAtomCost a) := by
  rw [incomingAtomCost_scale, Real.sqrt_mul (sq_nonneg scale),
    Real.sqrt_sq_eq_abs, abs_of_pos hscale]

theorem homogeneous_atomicScore_rescale {d q : ℕ}
    (φ : ℝ → ℝ) (hφ : ∀ scale : ℝ, 0 < scale → ∀ t, φ (scale * t) = scale * φ t)
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (scale : ℝ) (hscale : 0 < scale) (x : Cube d) :
    atomicScore φ (fun j k => scale * a j k) (fun j => c j / scale) x =
      atomicScore φ a c x := by
  unfold atomicScore
  apply Finset.sum_congr rfl
  intro j hj
  have hin : (∑ k, scale * a j k * inputVector x k) =
      scale * ∑ k, a j k * inputVector x k := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro k hk
    ring
  rw [hin, hφ scale hscale]
  field_simp

theorem atomicAllocationMass_rescale {d q : ℕ}
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (scale : ℝ) (hscale : 0 < scale) :
    atomicAllocationMass (fun j k => scale * a j k) (fun j => c j / scale) =
      atomicAllocationMass a c / scale ^ 2 := by
  unfold atomicAllocationMass
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j hj
  rw [abs_div, abs_of_pos hscale, sqrt_incomingAtomCost_scale (a j) scale hscale]
  have hsqrt : Real.sqrt (incomingAtomCost (a j)) ≠ 0 :=
    ne_of_gt (Real.sqrt_pos.mpr (ha j))
  field_simp

theorem atomicWeightedCost_rescale {d q : ℕ}
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (scale : ℝ) (hscale : 0 < scale) :
    atomicWeightedCost (fun j k => scale * a j k) (fun j => c j / scale) =
      atomicWeightedCost a c := by
  unfold atomicWeightedCost
  apply Finset.sum_congr rfl
  intro j hj
  rw [abs_div, abs_of_pos hscale, sqrt_incomingAtomCost_scale (a j) scale hscale]
  field_simp

/-- A finite homogeneous representation can always be put strictly inside
the available neuron-allocation budget while preserving its exact score and cost. -/
theorem homogeneous_atomic_representation_with_slack {d q : ℕ}
    (φ : ℝ → ℝ) (hφ : ∀ scale : ℝ, 0 < scale → ∀ t, φ (scale * t) = scale * φ t)
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hc : ∀ j, c j ≠ 0) :
    ∃ a' : Fin q → Fin (d + 1) → ℝ, ∃ c' : Fin q → ℝ,
      (∀ j, 0 < incomingAtomCost (a' j)) ∧ (∀ j, c' j ≠ 0) ∧
      atomicAllocationMass a' c' < 1 ∧
      atomicWeightedCost a' c' = atomicWeightedCost a c ∧
      ∀ x, atomicScore φ a' c' x = atomicScore φ a c x := by
  let M := atomicAllocationMass a c
  let scale := M + 1
  have hM : 0 ≤ M := atomicAllocationMass_nonneg a c
  have hs : 0 < scale := by dsimp [scale]; linarith
  refine ⟨(fun j k => scale * a j k), (fun j => c j / scale), ?_, ?_, ?_,
    atomicWeightedCost_rescale a c scale hs, homogeneous_atomicScore_rescale φ hφ a c scale hs⟩
  · intro j
    rw [incomingAtomCost_scale]
    exact mul_pos (sq_pos_of_pos hs) (ha j)
  · intro j
    exact div_ne_zero (hc j) (ne_of_gt hs)
  · rw [atomicAllocationMass_rescale a c ha scale hs]
    apply (div_lt_iff₀ (sq_pos_of_pos hs)).mpr
    dsimp [scale, M] at *
    nlinarith

/-- Every finite nonzero homogeneous atomic score at closed margin has strict
actual witnesses at every sufficiently large width, at any cost above its
weighted variation cost. No allocation-mass assumption is needed. -/
theorem homogeneous_closed_score_strict_witness_all_large {d q : ℕ}
    (φ : ℝ → ℝ) (hφ : ∀ scale : ℝ, 0 < scale → ∀ t, φ (scale * t) = scale * φ t)
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (ha : ∀ j, 0 < incomingAtomCost (a j)) (hc : ∀ j, c j ≠ 0)
    (g : BooleanFunction d)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g x) * atomicScore φ a c x)
    (B : ℝ) (hbudget : atomicWeightedCost a c < B) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N →
      ∃ w : Weights d N 0, w ∈ marginEvent φ (1 / 2) g ∧ weightedSquaredNorm w < B := by
  obtain ⟨a', c', ha', hc', hslack, hcost, hscore⟩ :=
    homogeneous_atomic_representation_with_slack φ hφ a c ha hc
  apply closed_atomic_score_strict_witness_all_large φ a' c' ha' hc' hslack g
  · intro x
    simpa only [hscore x] using hmargin x
  · simpa only [hcost] using hbudget

/-- The usual ReLU activation satisfies precisely the homogeneity used above. -/
theorem relu_positive_homogeneous (scale : ℝ) (hscale : 0 < scale) (t : ℝ) :
    max 0 (scale * t) = scale * max 0 t := by
  rw [mul_max_of_nonneg _ _ hscale.le, mul_zero]

end NeuralGeneralization.OnlineLower
