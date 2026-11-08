import NeuralGeneralization.OnlineLowerTanhGeometryPhysicalMinimum
import NeuralGeneralization.OnlineLowerGeometryContinuity
import NeuralGeneralization.OnlineLowerCompactBridge

/-! # Closed rectangle constraints and the uniform actual-neural cost gap -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

variable {X : Type*} [TopologicalSpace X]

lemma continuous_rectangle_slack {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (g : X → ClippingCube m → ℝ)
    (hg : ∀ z, Continuous (fun q => g q z)) :
    Continuous (fun q => rectangleLogicalSlack w H v u (g q)) := by
  unfold rectangleLogicalSlack rectangleCalibrationSlack
  apply continuous_cube_mean
  intro z
  by_cases hz : z ∈ rectangleObserved H v u
  · simp only [if_pos hz]
    exact continuous_const.mul ((hg z).sub continuous_const)
  · simp only [if_neg hz]
    exact continuous_const

lemma continuous_rectangle_deficit {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (g : X → ClippingCube m → ℝ)
    (hg : ∀ z, Continuous (fun q => g q z)) (B : X → ℝ) (hB : Continuous B) :
    Continuous (fun q => rectangleLogicalDeficit w H v u (g q) (B q)) := by
  unfold rectangleLogicalDeficit fourierDualDeficit
  exact hB.sub (continuous_cube_mean _ (fun z => continuous_const.mul (hg z)))

namespace WalshCodeMap
variable {d m : ℕ} (C : WalshCodeMap d m)

/-- The constraint set consists only of closed inequalities on the
actual scalar cost and whole finite-cube output. -/
def rectangleScoreConstraints (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m)
    (v u : ClippingCube m) (live : ClippingCube m → Prop) (scale β : ℝ) :
    Set (ℝ × (ClippingCube d → ℝ)) := {q |
  (∀ x, (1 : ℝ) / 2 ≤ |q.2 x|) ∧
  (∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
    (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * q.2 x)) ∧
  weightedWalshCost w (C.logicalProjection q.2) ≤ q.1 / scale ∧
  (∀ z, ¬ live z → reluLiveMass H v (C.logicalProjection q.2) z ≤ 0) ∧
  uniformCubeMean (fun x => (q.2 x - C.project q.2 x)^2) ≤
    β * (rectangleLogicalDeficit w H v u (C.logicalProjection q.2) (q.1 / scale) +
      rectangleLogicalSlack w H v u (C.logicalProjection q.2))}

theorem isClosed_rectangleScoreConstraints (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m)
    (v u : ClippingCube m) (live : ClippingCube m → Prop) (scale β : ℝ) :
    IsClosed (C.rectangleScoreConstraints w H v u live scale β) := by
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
  have hremoved : IsClosed {q : ℝ × (ClippingCube d → ℝ) | ∀ z, ¬ live z →
      reluLiveMass H v (C.logicalProjection q.2) z ≤ 0} := by
    simp only [Set.setOf_forall]
    exact isClosed_iInter fun z => isClosed_iInter fun _ =>
      isClosed_le (continuous_relu_live_mass H v _ hg z) continuous_const
  have hvar : IsClosed {q : ℝ × (ClippingCube d → ℝ) |
      uniformCubeMean (fun x => (q.2 x - C.project q.2 x)^2) ≤
        β * (rectangleLogicalDeficit w H v u (C.logicalProjection q.2) (q.1 / scale) +
          rectangleLogicalSlack w H v u (C.logicalProjection q.2))} := by
    apply isClosed_le
    · exact continuous_cube_mean _ (fun x => ((hF x).sub (C.continuous_project F hF x)).pow 2)
    · exact continuous_const.mul ((continuous_rectangle_deficit w H v u _ hg _ hB).add
        (continuous_rectangle_slack w H v u _ hg))
  exact hmargin.inter (hcal.inter (hcost.inter (hremoved.inter hvar)))

theorem rectangleScoreConstraints_minimum (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u zstar : ClippingCube m) (hw : RectangleCostConditions w u)
    (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 2 ≤ ((H.adjoinPoint u).differenceAnnihilator v).card)
    (hdensity : (1 : ℝ) / 2 ≤ uniformCubeMean (fun z =>
      if z ∈ rectangleNegativeObserved H v u then 1 else 0))
    (horder : ∀ z, cubeTranslation v z ∈ H.carrier →
      0 ≤ rectangleWeightTransform w z ∧ rectangleWeightTransform w z ≤ rectangleWeightTransform w (cubeTranslation u z))
    (e : Finset (Fin m)) (he : e ∈ H.differenceAnnihilator v) (heu : walshCharacter e u = -1)
    (live : ClippingCube m → Prop) (scale β W : ℝ) (hscale : 0 < scale)
    (hW : 0 ≤ W) (hν : ∀ z, |rectangleLiveCost w H v u z| ≤ W)
    (hnegative : rectangleLiveCost w H v u zstar < 0)
    (hstrict : ∀ z, live z → zstar ≠ z → rectangleLiveCost w H v u zstar < rectangleLiveCost w H v u z)
    (hsmall : W * (44 * Fintype.card (ClippingCube m) *
      (1 / rectangleWeightTransform w u + 1 / rectangleCommonA w u) +
        4 * (Fintype.card (ClippingCube m) * β)) < 1)
    (q : ℝ × (ClippingCube d → ℝ)) (hq : q ∈ C.rectangleScoreConstraints w H v u live scale β) :
    scale * (rectangleBaselineCost w u + rectangleLiveCost w H v u zstar) ≤ q.1 ∧
      (q.1 = scale * (rectangleBaselineCost w u + rectangleLiveCost w H v u zstar) →
        q.2 = fun x => C.base x * rectangleScore u zstar (C.syndrome x)) := by
  obtain ⟨hmargin, hcal, hcost, hremoved, hvariance⟩ := hq
  obtain ⟨hlower, hequal⟩ := C.rectangle_calibrated_score_minimum w H v u zstar hw hu hv hE
    hdensity horder q.2 (q.1 / scale) W β hmargin hcal hcost e he heu live hremoved hW hν
    hnegative hstrict hvariance hsmall
  constructor
  · have hh := (le_div_iff₀ hscale).mp hlower
    nlinarith
  · intro heq
    apply hequal
    rw [heq]
    simp only [mul_div_cancel_left₀ _ hscale.ne']
    exact le_rfl

/-- Compactness supplies a positive actual-neural cost barrier uniformly
in width. The analytic and history interface asks only that actual capped
outputs satisfy the already proved closed scalar inequalities. -/
theorem uniform_rectangle_correct_cost_gap {n : ℕ} (hd : 0 < d)
    (φ : ℝ → ℝ) (hφ : ∀ t, |φ t| ≤ |t|)
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v u zstar : ClippingCube m)
    (hw : RectangleCostConditions w u) (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 2 ≤ ((H.adjoinPoint u).differenceAnnihilator v).card)
    (hdensity : (1 : ℝ) / 2 ≤ uniformCubeMean (fun z =>
      if z ∈ rectangleNegativeObserved H v u then 1 else 0))
    (horder : ∀ z, cubeTranslation v z ∈ H.carrier →
      0 ≤ rectangleWeightTransform w z ∧ rectangleWeightTransform w z ≤ rectangleWeightTransform w (cubeTranslation u z))
    (e : Finset (Fin m)) (he : e ∈ H.differenceAnnihilator v) (heu : walshCharacter e u = -1)
    (live : ClippingCube m → Prop) (scale β W cap : ℝ) (hscale : 0 < scale)
    (hW : 0 ≤ W) (hν : ∀ z, |rectangleLiveCost w H v u z| ≤ W)
    (hnegative : rectangleLiveCost w H v u zstar < 0)
    (hstrict : ∀ z, live z → zstar ≠ z → rectangleLiveCost w H v u zstar < rectangleLiveCost w H v u z)
    (hsmall : W * (44 * Fintype.card (ClippingCube m) *
      (1 / rectangleWeightTransform w u + 1 / rectangleCommonA w u) +
        4 * (Fintype.card (ClippingCube m) * β)) < 1)
    (hcap : scale * (rectangleBaselineCost w u + rectangleLiveCost w H v u zstar) < cap)
    (f : ConcreteModel.BooleanFunction d) (sample : Fin n → ConcreteModel.Cube d) (x : ConcreteModel.Cube d)
    (hwrong : ConcreteModel.labelReal (f x) *
      (C.base x * rectangleScore u zstar (C.syndrome x)) < (1 : ℝ) / 2)
    (hactual : ∀ N : ℕ, 0 < N → ∀ net : ConcreteModel.Weights d N 0,
      OnlineLower.ClosedOnlineFeasible φ f sample net → ConcreteModel.weightedSquaredNorm net ≤ cap →
        (ConcreteModel.weightedSquaredNorm net, ConcreteModel.networkOutput φ net) ∈
          C.rectangleScoreConstraints w H v u live scale β) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ N : ℕ, 0 < N → ∀ net : ConcreteModel.Weights d N 0,
      OnlineLower.ClosedOnlineFeasible φ f sample net →
      (1 : ℝ) / 2 ≤ ConcreteModel.labelReal (f x) * ConcreteModel.networkOutput φ net x →
      scale * (rectangleBaselineCost w u + rectangleLiveCost w H v u zstar) + δ ≤
        ConcreteModel.weightedSquaredNorm net := by
  apply OnlineLower.uniform_neural_cost_gap_of_closed_constraints hd φ hφ f sample x
    (C.rectangleScoreConstraints w H v u live scale β)
    (C.isClosed_rectangleScoreConstraints w H v u live scale β)
    (scale * (rectangleBaselineCost w u + rectangleLiveCost w H v u zstar)) cap hcap
    (fun x => C.base x * rectangleScore u zstar (C.syndrome x)) hactual
  · intro q hq
    exact (C.rectangleScoreConstraints_minimum w H v u zstar hw hu hv hE hdensity horder
      e he heu live scale β W hscale hW hν hnegative hstrict hsmall q hq.2).1
  · intro q hq heq
    exact (C.rectangleScoreConstraints_minimum w H v u zstar hw hu hv hE hdensity horder
      e he heu live scale β W hscale hW hν hnegative hstrict hsmall q hq.2).2 heq
  · exact hwrong

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
