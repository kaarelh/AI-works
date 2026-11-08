import NeuralGeneralization.OnlineLowerGeometryReluMinimum
import NeuralGeneralization.OnlineLowerGeometryContinuity
import NeuralGeneralization.OnlineLowerCompactBridge

/-! # Closed physical score constraints and a uniform correct-score gap -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

namespace WalshCodeMap

variable {d m : ℕ} (C : WalshCodeMap d m)

/-- Every entry is a closed inequality on the actual scalar cost and the
entire finite-cube score. The normalized budget is `cost / scale`. -/
def reluScoreConstraints (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m)
    (v : ClippingCube m) (live : ClippingCube m → Prop) (scale β : ℝ) :
    Set (ℝ × (ClippingCube d → ℝ)) := {q |
  (∀ x, (1 : ℝ) / 2 ≤ |q.2 x|) ∧
  (∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
    (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * q.2 x)) ∧
  weightedWalshCost w (C.logicalProjection q.2) ≤ q.1 / scale ∧
  (q.1 / scale) / w ∅ ≤ 10 ∧
  (∀ z, ¬ live z → reluLiveMass H v (C.logicalProjection q.2) z ≤ 0) ∧
  uniformCubeMean (fun x => (q.2 x - C.project q.2 x) ^ 2) ≤
    β * (reluDualDeficit w H v (C.logicalProjection q.2) (q.1 / scale) +
      reluCalibrationSlack w H v (C.logicalProjection q.2))}

theorem isClosed_reluScoreConstraints (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m)
    (v : ClippingCube m) (live : ClippingCube m → Prop) (scale β : ℝ) :
    IsClosed (C.reluScoreConstraints w H v live scale β) := by
  let F : (ℝ × (ClippingCube d → ℝ)) → ClippingCube d → ℝ := Prod.snd
  have hF (x : ClippingCube d) : Continuous (fun q => F q x) :=
    (continuous_apply x).comp continuous_snd
  have hg (z : ClippingCube m) : Continuous (fun q => C.logicalProjection (F q) z) :=
    C.continuous_logical_projection F hF z
  have hB : Continuous (fun q : ℝ × (ClippingCube d → ℝ) => q.1 / scale) :=
    continuous_fst.div_const scale
  have hmargin : IsClosed {q : ℝ × (ClippingCube d → ℝ) | ∀ x, (1 : ℝ) / 2 ≤ |q.2 x|} := by
    rw [Set.setOf_forall]
    exact isClosed_iInter fun x => isClosed_le continuous_const (hF x).abs
  have hcal : IsClosed {q : ℝ × (ClippingCube d → ℝ) | ∀ x,
      cubeTranslation v (C.syndrome x) ∉ H.carrier →
        (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * q.2 x)} := by
    simp only [Set.setOf_forall]
    exact isClosed_iInter fun x => isClosed_iInter fun _ =>
      isClosed_le continuous_const (continuous_const.mul (continuous_const.mul (hF x)))
  have hcost : IsClosed {q : ℝ × (ClippingCube d → ℝ) |
      weightedWalshCost w (C.logicalProjection q.2) ≤ q.1 / scale} :=
    isClosed_le (continuous_weighted_walsh_cost w _ hg) hB
  have hbudget : IsClosed {q : ℝ × (ClippingCube d → ℝ) | (q.1 / scale) / w ∅ ≤ 10} :=
    isClosed_le (hB.div_const _) continuous_const
  have hremoved : IsClosed {q : ℝ × (ClippingCube d → ℝ) | ∀ z, ¬ live z →
      reluLiveMass H v (C.logicalProjection q.2) z ≤ 0} := by
    simp only [Set.setOf_forall]
    exact isClosed_iInter fun z => isClosed_iInter fun _ =>
      isClosed_le (continuous_relu_live_mass H v _ hg z) continuous_const
  have hvar : IsClosed {q : ℝ × (ClippingCube d → ℝ) |
      uniformCubeMean (fun x => (q.2 x - C.project q.2 x) ^ 2) ≤
        β * (reluDualDeficit w H v (C.logicalProjection q.2) (q.1 / scale) +
          reluCalibrationSlack w H v (C.logicalProjection q.2))} := by
    apply isClosed_le
    · exact continuous_cube_mean _ (fun x => ((hF x).sub (C.continuous_project F hF x)).pow 2)
    · exact continuous_const.mul ((continuous_relu_deficit w H v _ hg _ hB).add
        (continuous_relu_slack w H v _ hg))
  exact hmargin.inter (hcal.inter (hcost.inter (hbudget.inter (hremoved.inter hvar))))

/-- The previously proved physical minimum theorem applies to every point
of this closed constraint set, including limits of neural output pairs. -/
theorem reluScoreConstraints_minimum
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v zstar : ClippingCube m)
    (live : ClippingCube m → Prop) (scale β W : ℝ)
    (hscale : 0 < scale) (hv : v ∉ H.carrier)
    (hw0 : 0 < w ∅) (hw : ∀ s, w ∅ ≤ w s)
    (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hsum : 6 * w ∅ ≤ ∑ s, w s)
    (hcostsign : ∀ z, z ≠ cubeOne m → walshExpansion w z ≤ 0)
    (hzlive : live zstar) (hzcoset : cubeTranslation v zstar ∈ H.carrier)
    (hW : 0 ≤ W) (hν : ∀ z, |reluLiveCost w H v z| ≤ W)
    (hnegative : reluLiveCost w H v zstar < 0)
    (hstrict : ∀ z, live z → zstar ≠ z → reluLiveCost w H v zstar < reluLiveCost w H v z)
    (hsmall : W * (45 * ((Fintype.card (ClippingCube m) : ℝ) / (2 * w ∅)) +
      6 * ((Fintype.card (ClippingCube m) : ℝ) * β)) < 1)
    (q : ℝ × (ClippingCube d → ℝ))
    (hq : q ∈ C.reluScoreConstraints w H v live scale β) :
    scale * (reluCalibrationConstant w H v + reluLiveCost w H v zstar) ≤ q.1 ∧
      (q.1 = scale * (reluCalibrationConstant w H v + reluLiveCost w H v zstar) →
        q.2 = fun x => C.base x * reluStar zstar (C.syndrome x)) := by
  obtain ⟨hmargin, hcal, hcost, hbudget, hremoved, hvariance⟩ := hq
  obtain ⟨hlower, hequal⟩ := C.relu_calibrated_score_minimum w H v zstar live q.2
    (q.1 / scale) W β hv hw0 hw hcard hsum hcostsign hmargin hcal hcost hbudget
    hremoved hzlive hzcoset hW hν hnegative hstrict hvariance hsmall
  constructor
  · have hh := (le_div_iff₀ hscale).mp hlower
    nlinarith
  · intro heq
    apply hequal
    rw [heq]
    simp only [mul_div_cancel_left₀ _ hscale.ne']
    exact le_rfl



/-- The actual finite neural model inherits a positive correct-score cost
barrier from these closed constraints, uniformly over every positive width.
The interface only asks that feasible capped network outputs obey the
separately proved analytic and observed-margin inequalities. -/
theorem uniform_relu_correct_cost_gap
    {n : ℕ} (hd : 0 < d)
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v zstar : ClippingCube m)
    (live : ClippingCube m → Prop) (scale β W cap : ℝ)
    (hscale : 0 < scale) (hv : v ∉ H.carrier)
    (hw0 : 0 < w ∅) (hw : ∀ s, w ∅ ≤ w s)
    (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hsum : 6 * w ∅ ≤ ∑ s, w s)
    (hcostsign : ∀ z, z ≠ cubeOne m → walshExpansion w z ≤ 0)
    (hzlive : live zstar) (hzcoset : cubeTranslation v zstar ∈ H.carrier)
    (hW : 0 ≤ W) (hν : ∀ z, |reluLiveCost w H v z| ≤ W)
    (hnegative : reluLiveCost w H v zstar < 0)
    (hstrict : ∀ z, live z → zstar ≠ z → reluLiveCost w H v zstar < reluLiveCost w H v z)
    (hsmall : W * (45 * ((Fintype.card (ClippingCube m) : ℝ) / (2 * w ∅)) +
      6 * ((Fintype.card (ClippingCube m) : ℝ) * β)) < 1)
    (hcap : scale * (reluCalibrationConstant w H v + reluLiveCost w H v zstar) < cap)
    (f : ConcreteModel.BooleanFunction d) (sample : Fin n → ConcreteModel.Cube d)
    (x : ConcreteModel.Cube d)
    (hwrong : ConcreteModel.labelReal (f x) *
      (C.base x * reluStar zstar (C.syndrome x)) < (1 : ℝ) / 2)
    (hactual : ∀ N : ℕ, 0 < N → ∀ net : ConcreteModel.Weights d N 0,
      OnlineLower.ClosedOnlineFeasible (fun t => max 0 t) f sample net →
      ConcreteModel.weightedSquaredNorm net ≤ cap →
        (ConcreteModel.weightedSquaredNorm net, ConcreteModel.networkOutput (fun t => max 0 t) net) ∈
          C.reluScoreConstraints w H v live scale β) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ N : ℕ, 0 < N → ∀ net : ConcreteModel.Weights d N 0,
      OnlineLower.ClosedOnlineFeasible (fun t => max 0 t) f sample net →
      (1 : ℝ) / 2 ≤ ConcreteModel.labelReal (f x) *
        ConcreteModel.networkOutput (fun t => max 0 t) net x →
      scale * (reluCalibrationConstant w H v + reluLiveCost w H v zstar) + δ ≤
        ConcreteModel.weightedSquaredNorm net := by
  apply OnlineLower.uniform_neural_cost_gap_of_closed_constraints hd (fun t => max 0 t)
    (fun t => by rw [abs_of_nonneg (le_max_left _ _)]; exact max_le (abs_nonneg _) (le_abs_self _))
    f sample x (C.reluScoreConstraints w H v live scale β)
    (C.isClosed_reluScoreConstraints w H v live scale β)
    (scale * (reluCalibrationConstant w H v + reluLiveCost w H v zstar)) cap hcap
    (fun x => C.base x * reluStar zstar (C.syndrome x)) hactual
  · intro q hq
    exact (C.reluScoreConstraints_minimum w H v zstar live scale β W hscale hv hw0 hw hcard
      hsum hcostsign hzlive hzcoset hW hν hnegative hstrict hsmall q hq.2).1
  · intro q hq heq
    exact (C.reluScoreConstraints_minimum w H v zstar live scale β W hscale hv hw0 hw hcard
      hsum hcostsign hzlive hzcoset hW hν hnegative hstrict hsmall q hq.2).2 heq
  · exact hwrong

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
