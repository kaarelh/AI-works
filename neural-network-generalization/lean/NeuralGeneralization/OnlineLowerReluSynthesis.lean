import NeuralGeneralization.OnlineLowerOrbitSynthesis
import NeuralGeneralization.OnlineLowerReluSupportWalsh
import NeuralGeneralization.OnlineLowerReluCostVariation

/-!
# Exact ReLU realization of arbitrary even-support Fourier scores

The balanced coefficient formula is proved for actual ambient cube atoms.
Its character orbit then gives concrete networks with exactly the weighted
Fourier cost at every width above the explicit full-orbit count.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu

private theorem relu_conventions : (fun t : ℝ => max 0 t) = (fun t : ℝ => max t 0) :=
  funext (fun t => max_comm 0 t)

theorem relu_support_coefficient_abs {d : ℕ} (S : Finset (Fin d)) (r : ℕ)
    (hcard : S.card = 2 * r + 2) :
    |walshCoefficients (atomOutput (fun t => max 0 t) (supportIncoming S)) S| =
      evenReluKappa r := by
  rw [relu_conventions]
  exact support_relu_walsh_abs S r hcard

theorem relu_support_coefficient_ne_zero {d : ℕ} (S : Finset (Fin d)) (r : ℕ)
    (hcard : S.card = 2 * r + 2) :
    walshCoefficients (atomOutput (fun t => max 0 t) (supportIncoming S)) S ≠ 0 := by
  apply abs_ne_zero.mp
  rw [relu_support_coefficient_abs S r hcard]
  exact ne_of_gt (evenReluKappa_pos r)

theorem relu_support_incoming_positive {d : ℕ} (hd : 0 < d)
    (S : Finset (Fin d)) (r : ℕ) (hcard : S.card = 2 * r + 2) :
    0 < incomingAtomCost (supportIncoming S) := by
  rw [supportIncoming_cost, hcard]
  exact mul_pos (Nat.cast_pos.mpr hd) (by positivity)

theorem relu_support_orbit_cost {d : ℕ} (S : Finset (Fin d)) (r : ℕ)
    (hcard : S.card = 2 * r + 2) (v : ℝ) :
    2 * |v| * Real.sqrt (incomingAtomCost (supportIncoming S)) /
      |walshCoefficients (atomOutput (fun t => max 0 t) (supportIncoming S)) S| =
      2 * Real.sqrt (d : ℝ) * (|v| * evenReluCost r) := by
  rw [relu_support_coefficient_abs S r hcard, supportIncoming_cost,
    Real.sqrt_mul (Nat.cast_nonneg d), hcard]
  have hdegree : ((2 * r + 2 : ℕ) : ℝ) = 2 * (r + 1 : ℝ) := by norm_num; ring
  rw [hdegree]
  unfold evenReluCost
  ring

/-- Exact output and exact Gaussian weighted cost, with no asymptotic premise. -/
theorem relu_even_fourier_score_exact_at_width {d k N : ℕ} (hd : 0 < d)
    (S : Fin k → Finset (Fin d)) (r : Fin k → ℕ) (v : Fin k → ℝ)
    (hcard : ∀ j, (S j).card = 2 * r j + 2) (hv : ∀ j, v j ≠ 0)
    (hN : 0 < N) (hwidth : k * Fintype.card (Cube d) ≤ N) :
    ∃ w : Weights d N 0,
      (∀ x, networkOutput (fun t => max 0 t) w x = ∑ j, v j * walshCharacter (S j) x) ∧
      weightedSquaredNorm w =
        2 * Real.sqrt (d : ℝ) * (∑ j, |v j| * evenReluCost (r j)) := by
  obtain ⟨w, hw, he⟩ := homogeneous_fourier_score_exact_at_width
    (fun t => max 0 t) relu_positive_homogeneous S (fun j => supportIncoming (S j)) v
    (fun j => relu_support_coefficient_ne_zero (S j) (r j) (hcard j))
    (fun j => relu_support_incoming_positive hd (S j) (r j) (hcard j)) hv hN hwidth
  refine ⟨w, hw, ?_⟩
  rw [he, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  exact relu_support_orbit_cost (S j) (r j) (hcard j) (v j)

/-- A closed-margin even-support Fourier witness becomes a strict actual
ReLU witness below any larger cost at the same explicit width threshold. -/
theorem relu_even_fourier_strict_witness_at_width {d k N : ℕ} (hd : 0 < d)
    (S : Fin k → Finset (Fin d)) (r : Fin k → ℕ) (v : Fin k → ℝ)
    (hcard : ∀ j, (S j).card = 2 * r j + 2) (hv : ∀ j, v j ≠ 0)
    (g : BooleanFunction d)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g x) * (∑ j, v j * walshCharacter (S j) x))
    (B : ℝ) (hbudget : 2 * Real.sqrt (d : ℝ) *
      (∑ j, |v j| * evenReluCost (r j)) < B)
    (hN : 0 < N) (hwidth : k * Fintype.card (Cube d) ≤ N) :
    ∃ w : Weights d N 0,
      w ∈ marginEvent (fun t => max 0 t) (1 / 2) g ∧ weightedSquaredNorm w < B := by
  apply homogeneous_fourier_score_strict_witness_at_width
    (fun t => max 0 t) relu_positive_homogeneous S (fun j => supportIncoming (S j)) v
    (fun j => relu_support_coefficient_ne_zero (S j) (r j) (hcard j))
    (fun j => relu_support_incoming_positive hd (S j) (r j) (hcard j)) hv g hmargin B
  · have he : (∑ j, 2 * |v j| * Real.sqrt (incomingAtomCost (supportIncoming (S j))) /
        |walshCoefficients (atomOutput (fun t => max 0 t) (supportIncoming (S j))) (S j)|) =
        2 * Real.sqrt (d : ℝ) * (∑ j, |v j| * evenReluCost (r j)) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j hj
      exact relu_support_orbit_cost (S j) (r j) (hcard j) (v j)
    rw [he]
    exact hbudget
  · exact hN
  · exact hwidth

end NeuralGeneralization.OnlineLower
