import NeuralGeneralization.OnlineLowerGeometryRounding

/-!
# Exact minimum classification after finite logical rounding

The calibrated decomposition, the coefficient bound and the proved
rounding estimate imply absorption and uniqueness.  This file deliberately
does not package those finite inputs as an assumption named after the
neural theorem: the neural atomic and physical variance arguments remain
separate proof obligations.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

variable {ι : Type*} [Fintype ι]

def linearCost (ν p : ι → ℝ) : ℝ := ∑ i, ν i * p i

theorem linearCost_perturbation (ν p q : ι → ℝ) (W : ℝ)
    (hν : ∀ i, |ν i| ≤ W) :
    linearCost ν q - W * l1Distance p q ≤ linearCost ν p := by
  have h := dual_pairing_le_weightedL1 (fun _ : ι => W)
    (fun i => q i - p i) ν hν
  have hleft : (∑ i, ν i * (q i - p i)) = linearCost ν q - linearCost ν p := by
    simp only [mul_sub, Finset.sum_sub_distrib, linearCost]
  have hright : weightedL1 (fun _ : ι => W) (fun i => q i - p i) =
      W * l1Distance p q := by
    simp only [weightedL1, l1Distance, Finset.mul_sum, abs_sub_comm]
  rw [hleft, hright] at h
  linarith

theorem l1Distance_eq_zero_iff (p q : ι → ℝ) :
    l1Distance p q = 0 ↔ p = q := by
  constructor
  · intro h
    funext i
    have hle : |p i - q i| ≤ l1Distance p q := by
      exact Finset.single_le_sum (fun j _ => abs_nonneg (p j - q j))
        (Finset.mem_univ i)
    rw [h] at hle
    exact sub_eq_zero.mp (abs_eq_zero.mp (le_antisymm hle (abs_nonneg _)))
  · rintro rfl
    simp [l1Distance]

/-- The exact calibrated decomposition absorbs a rounding error when the
Fourier tail bound times the rounding constant is below one. -/
theorem calibrated_cost_lower (ν p q : ι → ℝ) (B C₀ D S W K : ℝ)
    (hW : 0 ≤ W) (hν : ∀ i, |ν i| ≤ W)
    (hdecomp : B = C₀ + D + S + linearCost ν p)
    (hround : l1Distance p q ≤ K * (D + S)) :
    C₀ + linearCost ν q + (1 - W * K) * (D + S) ≤ B := by
  have hcost := linearCost_perturbation ν p q W hν
  have herr := mul_le_mul_of_nonneg_left hround hW
  rw [hdecomp]
  nlinarith

/-- Inserting the proved `11 η + 4 V` estimate produces a candidate and
the full calibrated energy lower bound. -/
theorem calibrated_live_candidate_lower (ν p : ι → ℝ) (live : ι → Prop)
    (B C₀ D S W η a b : ℝ)
    (hW : 0 ≤ W) (hη : 0 ≤ η) (hν : ∀ i, |ν i| ≤ W)
    (hdecomp : B = C₀ + D + S + linearCost ν p)
    (hneg : (∑ i, negativePart (p i)) ≤ η)
    (hpos : (∑ i, positivePart (p i)) ≤ 1 + 3 * η)
    (hremoved : ∀ i, ¬ live i → p i ≤ 0)
    (hηbound : η ≤ a * (D + S))
    (hvariance : (∑ i, fractionalPenalty (p i)) ≤ b * (D + S)) :
    ∃ q, IsLiveCandidate live q ∧
      C₀ + linearCost ν q + (1 - W * (11 * a + 4 * b)) * (D + S) ≤ B := by
  obtain ⟨q, hq, hround⟩ := live_candidate_rounding p live η hη hneg hpos hremoved
  have hround' : l1Distance p q ≤ (11 * a + 4 * b) * (D + S) := by
    nlinarith
  exact ⟨q, hq, calibrated_cost_lower ν p q B C₀ D S W (11 * a + 4 * b)
    hW hν hdecomp hround'⟩

/-- The finite equality classification.  Once the candidate costs have
been proved distinct, every minimizing shifted logical score is the same
live point mass and both calibrated slacks vanish. -/
theorem unique_calibrated_minimum (ν p qstar : ι → ℝ) (live : ι → Prop)
    (B C₀ D S W K : ℝ)
    (hD : 0 ≤ D) (hS : 0 ≤ S) (hW : 0 ≤ W)
    (hν : ∀ i, |ν i| ≤ W) (hsmall : W * K < 1)
    (hdecomp : B = C₀ + D + S + linearCost ν p)
    (hround : ∃ q, IsLiveCandidate live q ∧ l1Distance p q ≤ K * (D + S))
    (hminimum : ∀ q, IsLiveCandidate live q → linearCost ν qstar ≤ linearCost ν q)
    (hunique : ∀ q, IsLiveCandidate live q →
      linearCost ν q = linearCost ν qstar → q = qstar)
    (hupper : B ≤ C₀ + linearCost ν qstar) :
    D = 0 ∧ S = 0 ∧ p = qstar := by
  obtain ⟨q, hq, hdist⟩ := hround
  have hlower := calibrated_cost_lower ν p q B C₀ D S W K hW hν hdecomp hdist
  have hmin := hminimum q hq
  have hgap : 0 ≤ (1 - W * K) * (D + S) :=
    mul_nonneg (by linarith) (add_nonneg hD hS)
  have hlowerstar : C₀ + linearCost ν qstar + (1 - W * K) * (D + S) ≤ B := by
    linarith
  have hBeq : B = C₀ + linearCost ν qstar := by linarith
  obtain ⟨hDz, hSz⟩ := cost_absorption_equality B (C₀ + linearCost ν qstar)
    D S W K hD hS hsmall hlowerstar hBeq
  have hpq : p = q := by
    apply (l1Distance_eq_zero_iff p q).mp
    apply le_antisymm
    · simpa only [hDz, hSz, add_zero, mul_zero] using hdist
    · exact l1Distance_nonneg p q
  have hcosteq : linearCost ν q = linearCost ν qstar := by
    rw [hDz, hSz] at hlower
    nlinarith
  exact ⟨hDz, hSz, hpq.trans (hunique q hq hcosteq)⟩

end NeuralGeneralization.OnlineLowerGeometry
