import NeuralGeneralization.RobustModel
import NeuralGeneralization.FunctionPrior
import Mathlib.Topology.Order.OrderClosed

/-! # Measurability of the actual robustness conditioning event -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {d N r : ℕ}

def scaleDisturbance (a : ℝ) (η : NetworkDisturbance N r) : NetworkDisturbance N r :=
  (fun s i => a * η.1 s i, a * η.2)

theorem noiseBudgetSq_scale (a : ℝ) (η : NetworkDisturbance N r) :
    noiseBudgetSq (scaleDisturbance a η) = a^2 * noiseBudgetSq η := by
  unfold noiseBudgetSq scaleDisturbance
  simp only [mul_pow, ← Finset.mul_sum]
  ring

theorem scaleDisturbance_mul (a b : ℝ) (η : NetworkDisturbance N r) :
    scaleDisturbance a (scaleDisturbance b η) = scaleDisturbance (a*b) η := by
  ext <;> simp [scaleDisturbance, mul_assoc]

@[simp] theorem scaleDisturbance_one (η : NetworkDisturbance N r) :
    scaleDisturbance 1 η = η := by
  ext <;> simp [scaleDisturbance]

/-- Rescaling a fixed unit ball removes the parameter-dependent quantifier
from the support definition. -/
theorem mem_robustEvent_iff_unitBall (φ : ℝ → ℝ) {c : ℝ} (hc : 0 < c)
    (w : Weights d N r) :
    w ∈ robustEvent φ c ↔ ∀ (x : Cube d) (η : NetworkDisturbance N r),
      noiseBudgetSq η ≤ 1 →
      |clippedScore (noisyNetworkOutput φ w x (scaleDisturbance (robustRadius c w) η)) -
        clippedScore (networkOutput φ w x)| ≤ (1/16 : ℝ) := by
  have hr := robustRadius_pos hc w
  constructor
  · intro hw x η hη
    apply hw x
    rw [noiseBudgetSq_scale]
    simpa only [mul_one] using mul_le_mul_of_nonneg_left hη (sq_nonneg _)
  · intro hw x η hη
    let ζ := scaleDisturbance (robustRadius c w)⁻¹ η
    have hζ : noiseBudgetSq ζ ≤ 1 := by
      dsimp [ζ]
      rw [noiseBudgetSq_scale]
      have hh := mul_le_mul_of_nonneg_left hη (sq_nonneg (robustRadius c w)⁻¹)
      simpa [← mul_pow, hr.ne'] using hh
    have hh := hw x ζ hζ
    have hid : scaleDisturbance (robustRadius c w) ζ = η := by
      dsimp [ζ]
      rw [scaleDisturbance_mul, mul_inv_cancel₀ hr.ne', scaleDisturbance_one]
    simpa only [hid] using hh

theorem continuous_clippedScore : Continuous clippedScore := by
  exact continuous_const.max (continuous_const.min continuous_id)

theorem continuous_readoutEnergy : Continuous (readoutEnergy : Weights d N r → ℝ) := by
  unfold readoutEnergy
  exact continuous_const.mul (continuous_finsetSum _ fun i _ =>
    (continuous_apply (Sum.inr (Sum.inr i))).pow 2)

theorem continuous_robustRadius (c : ℝ) :
    Continuous (robustRadius c : Weights d N r → ℝ) := by
  unfold robustRadius
  apply continuous_const.div
    ((continuous_const.add (continuous_const.mul continuous_readoutEnergy)).sqrt)
  intro w
  apply ne_of_gt
  apply Real.sqrt_pos.mpr
  change 0 < 1 + ((r : ℝ) + 1) * readoutEnergy w
  have := readoutEnergy_nonneg w
  positivity

/-- Continuous noisy computation with any continuously varying disturbance. -/
theorem continuous_noisyNetworkOutput {φ : ℝ → ℝ} (hφ : Continuous φ)
    (x : Cube d) (η : Weights d N r → NetworkDisturbance N r)
    (hη : Continuous η) :
    Continuous (fun w => noisyNetworkOutput φ w x (η w)) := by
  have hcoord (s : Fin (r+1)) (i : Fin N) :
      Continuous (fun w => (η w).1 s i) :=
    (continuous_apply i).comp ((continuous_apply s).comp (continuous_fst.comp hη))
  have hfirst (i : Fin N) : Continuous (fun w => noisyFirstHidden φ w x (η w) i) :=
    (continuous_firstHidden hφ x i).add (hcoord 0 i)
  have hfold (ss : List (Fin r)) (H : Weights d N r → Fin N → ℝ)
      (hH : ∀ i, Continuous (fun w => H w i)) (i : Fin N) :
      Continuous (fun w => ss.foldl (noisyHiddenStep φ w (η w)) (H w) i) := by
    induction ss generalizing H with
    | nil => exact hH i
    | cons s ss ih =>
      apply ih
      intro j
      exact (continuous_hiddenStep hφ H hH s j).add (hcoord s.succ j)
  have hfinal (i : Fin N) :
      Continuous (fun w => noisyFinalHidden φ w x (η w) i) :=
    hfold _ _ hfirst i
  exact (continuous_finsetSum _ fun i _ =>
    (continuous_apply (Sum.inr (Sum.inr i))).mul (hfinal i)).add
      (continuous_snd.comp hη)

/-- The quantifier ranges over a fixed ball; an arbitrary intersection of
closed inequalities is closed. No finite-net approximation is involved. -/
theorem isClosed_robustEvent {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c : ℝ} (hc : 0 < c) : IsClosed (robustEvent (d:=d) (N:=N) (r:=r) φ c) := by
  have heq : robustEvent (d:=d) (N:=N) (r:=r) φ c =
      ⋂ (x : Cube d) (η : NetworkDisturbance N r) (_ : noiseBudgetSq η ≤ 1),
        {w | |clippedScore (noisyNetworkOutput φ w x
          (scaleDisturbance (robustRadius c w) η)) -
          clippedScore (networkOutput φ w x)| ≤ (1/16 : ℝ)} := by
    ext w
    simp only [Set.mem_iInter, Set.mem_setOf_eq, mem_robustEvent_iff_unitBall φ hc]
  rw [heq]
  apply isClosed_iInter
  intro x
  apply isClosed_iInter
  intro η
  apply isClosed_iInter
  intro _hη
  apply isClosed_le _ continuous_const
  apply Continuous.abs
  apply Continuous.sub
  · apply continuous_clippedScore.comp
    apply continuous_noisyNetworkOutput hφ x
    apply Continuous.prodMk
    · apply continuous_pi
      intro s
      apply continuous_pi
      intro i
      exact (continuous_robustRadius c).mul continuous_const
    · exact (continuous_robustRadius c).mul continuous_const
  · exact continuous_clippedScore.comp (continuous_networkOutput hφ x)

theorem measurableSet_robustEvent {φ : ℝ → ℝ} (hφ : Continuous φ)
    {c : ℝ} (hc : 0 < c) : MeasurableSet (robustEvent (d:=d) (N:=N) (r:=r) φ c) :=
  (isClosed_robustEvent hφ hc).measurableSet

end NeuralGeneralization.ConcreteModel
