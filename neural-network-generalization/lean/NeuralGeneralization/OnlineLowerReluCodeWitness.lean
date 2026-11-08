import NeuralGeneralization.OnlineLowerExplicitThreshold
import NeuralGeneralization.OnlineLowerGeometryReluCalibration
import NeuralGeneralization.OnlineLowerGeometryReluMinimum

/-! # Concrete finite-width neural witnesses for the calibrated code scores -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu OnlineLowerGeometry

theorem code_fourier_lift {d m : ℕ} (C : WalshCodeMap d m)
    (g : ClippingCube m → ℝ) (x : Cube d) :
    (∑ s, walshCoefficients g s * walshCharacter (C.support s) x) =
      C.base x * g (C.syndrome x) := by
  calc
    _ = C.base x * walshExpansion (walshCoefficients g) (C.syndrome x) := by
      unfold walshExpansion
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro s _
      rw [C.character s x]
      change walshCoefficients g s * (C.base x * walshCharacter s (C.syndrome x)) = _
      ring
    _ = _ := by rw [walshExpansion_coefficients]

theorem code_fourier_weighted_cost {d m : ℕ} (C : WalshCodeMap d m)
    (weight : Finset (Fin m) → ℝ) (r : Finset (Fin m) → ℕ)
    (hweight : ∀ s, weight s = evenReluCost (r s)) (g : ClippingCube m → ℝ) :
    (∑ s, |walshCoefficients g s| * evenReluCost (r s)) = weightedWalshCost weight g := by
  unfold weightedWalshCost weightedL1
  apply Finset.sum_congr rfl
  intro s _
  rw [hweight]
  ring

/-- The physical lift of an arbitrary logical Fourier score has an actual
strict neural witness at the displayed finite width, including zero
Fourier coefficients and without any limiting allocation argument. -/
theorem relu_code_score_strict_witness_at_width {d m N : ℕ}
    (hd : 0 < d) (C : WalshCodeMap d m)
    (weight : Finset (Fin m) → ℝ) (r : Finset (Fin m) → ℕ)
    (hcard : ∀ s, (C.support s).card = 2 * r s + 2)
    (hweight : ∀ s, weight s = evenReluCost (r s))
    (g : ClippingCube m → ℝ) (f : BooleanFunction d)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (f x) * (C.base x * g (C.syndrome x)))
    (B : ℝ) (hbudget : 2 * Real.sqrt (d : ℝ) * weightedWalshCost weight g < B)
    (hN : 0 < N) (hwidth : 2 ^ m * Fintype.card (Cube d) ≤ N) :
    ∃ net : Weights d N 0,
      net ∈ marginEvent (fun t => max 0 t) (1 / 2) f ∧ weightedSquaredNorm net < B := by
  apply relu_fourier_strict_witness_at_width hd C.support r (walshCoefficients g) hcard f
  · intro x
    rw [code_fourier_lift]
    exact hmargin x
  · rw [code_fourier_weighted_cost C weight r hweight g]
    exact hbudget
  · exact hN
  · simpa using hwidth

/-- The common-dual star's exact logical cost is precisely the cost used
in the compact correct-score barrier, and hence supplies the actual
Gaussian stage gap at every width above `2^m * 2^d`. -/
theorem relu_star_stage_gap_at_width {d m N : ℕ}
    (hd : 0 < d) (C : WalshCodeMap d m)
    (weight : Finset (Fin m) → ℝ) (r : Finset (Fin m) → ℕ)
    (hcard : ∀ s, (C.support s).card = 2 * r s + 2)
    (hweight : ∀ s, weight s = evenReluCost (r s))
    (H : CubeSubgroup m) (v zstar : ClippingCube m)
    (hv : v ∉ H.carrier) (hz : cubeTranslation v zstar ∈ H.carrier)
    (hE : 0 < (H.differenceAnnihilator v).card) (hM : 4 ≤ Fintype.card (ClippingCube m))
    (f : BooleanFunction d) (π : InputOrder d) (j : Fin (Fintype.card (Cube d)))
    (g₀ : BooleanFunction d) (hkeep : consistent f (observedPrefix π j) g₀)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g₀ x) *
      (C.base x * reluStar zstar (C.syndrome x)))
    (δ : ℝ) (hδ : 0 < δ)
    (hbarrier : ∀ net : Weights d N 0,
      ClosedOnlineFeasible (fun t => max 0 t) f (observedPrefix π j) net →
      (1 / 2 : ℝ) ≤ labelReal (f (π j)) * networkOutput (fun t => max 0 t) net (π j) →
        2 * Real.sqrt (d : ℝ) * (reluCalibrationConstant weight H v +
          reluLiveCost weight H v zstar) + δ ≤ weightedSquaredNorm net)
    (hN : 0 < N) (hwidth : 2 ^ m * Fintype.card (Cube d) ≤ N) :
    HasStageEnergyGap (fun t => max 0 t) f π N j := by
  have hcost : weightedWalshCost weight (reluStar zstar) =
      reluCalibrationConstant weight H v + reluLiveCost weight H v zstar := by
    rw [reluStar_exact_cost weight H v zstar hv hz hE hM]
    simp only [reluLiveCost, if_pos hz]
  apply relu_stage_gap_of_fourier_witness_at_width hd f π j C.support r
    (walshCoefficients (reluStar zstar)) hcard g₀ hkeep
  · intro x
    rw [code_fourier_lift]
    exact hmargin x
  · exact hδ
  · intro net hfeas hcorrect
    rw [code_fourier_weighted_cost C weight r hweight, hcost]
    exact hbarrier net hfeas hcorrect
  · exact hN
  · simpa using hwidth

end NeuralGeneralization.OnlineLower
