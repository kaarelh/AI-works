import NeuralGeneralization.OnlineLowerGeometryReluClosed
import NeuralGeneralization.OnlineLowerReluCodeWitness

/-! # From the checked calibrated geometry to actual fixed-width stage gaps -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu OnlineLowerGeometry

/-- This final deterministic bridge uses the literal closed score
constraints and exact finite ReLU star witness. All network widths above
the displayed orbit count work; the Gaussian scale is not part of this
construction and is sent to zero only afterwards. -/
theorem relu_stage_gaps_of_calibrated_constraints {d m : ℕ}
    (hd : 0 < d) (C : WalshCodeMap d m)
    (weight : Finset (Fin m) → ℝ) (r : Finset (Fin m) → ℕ)
    (hdegree : ∀ s, (C.support s).card = 2 * r s + 2)
    (hweight : ∀ s, weight s = evenReluCost (r s))
    (H : CubeSubgroup m) (v zstar : ClippingCube m)
    (live : ClippingCube m → Prop) (β W cap : ℝ)
    (hv : v ∉ H.carrier) (hw0 : 0 < weight ∅) (hw : ∀ s, weight ∅ ≤ weight s)
    (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hM : 4 ≤ Fintype.card (ClippingCube m))
    (hsum : 6 * weight ∅ ≤ ∑ s, weight s)
    (hcostsign : ∀ z, z ≠ cubeOne m → walshExpansion weight z ≤ 0)
    (hzlive : live zstar) (hzcoset : cubeTranslation v zstar ∈ H.carrier)
    (hW : 0 ≤ W) (hν : ∀ z, |reluLiveCost weight H v z| ≤ W)
    (hnegative : reluLiveCost weight H v zstar < 0)
    (hstrict : ∀ z, live z → zstar ≠ z →
      reluLiveCost weight H v zstar < reluLiveCost weight H v z)
    (hsmall : W * (45 * ((Fintype.card (ClippingCube m) : ℝ) / (2 * weight ∅)) +
      6 * ((Fintype.card (ClippingCube m) : ℝ) * β)) < 1)
    (hcap : (2 * Real.sqrt (d : ℝ)) *
      (reluCalibrationConstant weight H v + reluLiveCost weight H v zstar) < cap)
    (f : BooleanFunction d) (π : InputOrder d) (j : Fin (Fintype.card (Cube d)))
    (g₀ : BooleanFunction d) (hkeep : consistent f (observedPrefix π j) g₀)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g₀ x) *
      (C.base x * reluStar zstar (C.syndrome x)))
    (hwrong : labelReal (f (π j)) *
      (C.base (π j) * reluStar zstar (C.syndrome (π j))) < (1 : ℝ) / 2)
    (hactual : ∀ N : ℕ, 0 < N → ∀ net : Weights d N 0,
      ClosedOnlineFeasible (fun t => max 0 t) f (observedPrefix π j) net →
      weightedSquaredNorm net ≤ cap →
        (weightedSquaredNorm net, networkOutput (fun t => max 0 t) net) ∈
          C.reluScoreConstraints weight H v live (2 * Real.sqrt (d : ℝ)) β) :
    ∀ N : ℕ, 0 < N → 2 ^ m * Fintype.card (Cube d) ≤ N →
      HasStageEnergyGap (fun t => max 0 t) f π N j := by
  have hscale : 0 < 2 * Real.sqrt (d : ℝ) :=
    mul_pos (by norm_num) (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd))
  obtain ⟨δ, hδ, hbarrier⟩ := C.uniform_relu_correct_cost_gap hd weight H v zstar live
    (2 * Real.sqrt (d : ℝ)) β W cap hscale hv hw0 hw hcard hsum hcostsign
    hzlive hzcoset hW hν hnegative hstrict hsmall hcap f (observedPrefix π j) (π j) hwrong hactual
  intro N hN hwidth
  exact relu_star_stage_gap_at_width hd C weight r hdegree hweight H v zstar hv hzcoset
    (by omega) hM f π j g₀ hkeep hmargin δ hδ (hbarrier N hN) hN hwidth

end NeuralGeneralization.OnlineLower
