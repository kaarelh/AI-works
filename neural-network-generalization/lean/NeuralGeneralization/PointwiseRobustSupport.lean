import NeuralGeneralization.RobustModelContinuity
import NeuralGeneralization.RobustStatisticsCoupling

/-! The exact pointwise stability predicate, with its actual parameter-dependent
noise radius. This does not infer global stability from finitely many checks. -/
noncomputable section
open MeasureTheory Set
open Classical
namespace NeuralGeneralization.ConcreteModel
variable {d N r : ℕ}

def stableAt (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) : Prop :=
  ∀ η : NetworkDisturbance N r, noiseBudgetSq η ≤ (robustRadius c w)^2 →
    |clippedScore (noisyNetworkOutput φ w x η)-clippedScore (networkOutput φ w x)| ≤ 1/16

lemma robustEvent_iff_stableAt (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) :
    w ∈ robustEvent φ c ↔ ∀ x,stableAt φ c w x := Iff.rfl

lemma stableAt_iff_unitBall (φ : ℝ → ℝ) {c : ℝ} (hc : 0 < c)
    (w : Weights d N r) (x : Cube d) :
    stableAt φ c w x ↔ ∀ η : NetworkDisturbance N r, noiseBudgetSq η ≤ 1 →
      |clippedScore (noisyNetworkOutput φ w x (scaleDisturbance (robustRadius c w) η))-
        clippedScore (networkOutput φ w x)| ≤ 1/16 := by
  have hr := robustRadius_pos hc w
  constructor
  · intro hw η hη
    apply hw
    rw [noiseBudgetSq_scale]
    simpa only [mul_one] using mul_le_mul_of_nonneg_left hη (sq_nonneg _)
  · intro hw η hη
    let ζ := scaleDisturbance (robustRadius c w)⁻¹ η
    have hζ : noiseBudgetSq ζ ≤ 1 := by
      dsimp [ζ]
      rw [noiseBudgetSq_scale]
      have hh := mul_le_mul_of_nonneg_left hη (sq_nonneg (robustRadius c w)⁻¹)
      simpa [← mul_pow,hr.ne'] using hh
    have hh := hw ζ hζ
    have hid : scaleDisturbance (robustRadius c w) ζ = η := by
      dsimp [ζ]
      rw [scaleDisturbance_mul,mul_inv_cancel₀ hr.ne',scaleDisturbance_one]
    simpa only [hid] using hh

lemma isClosed_stableAt {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c)
    (x : Cube d) : IsClosed {w : Weights d N r | stableAt φ c w x} := by
  have heq : {w : Weights d N r | stableAt φ c w x} =
      ⋂ (η : NetworkDisturbance N r) (_ : noiseBudgetSq η ≤ 1),
        {w | |clippedScore (noisyNetworkOutput φ w x (scaleDisturbance (robustRadius c w) η))-
          clippedScore (networkOutput φ w x)| ≤ (1/16:ℝ)} := by
    ext w
    simp only [Set.mem_iInter,Set.mem_setOf_eq,stableAt_iff_unitBall φ hc]
  rw [heq]
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

lemma measurable_stableAt {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c) :
    MeasurableSet {p : Weights d N r × Cube d | stableAt φ c p.1 p.2} := by
  have heq : {p : Weights d N r × Cube d | stableAt φ c p.1 p.2} =
      ⋃ x : Cube d, {w | stableAt φ c w x} ×ˢ {x} := by
    ext p
    simp
  rw [heq]
  apply MeasurableSet.iUnion
  intro x
  exact (isClosed_stableAt hφ hc x).measurableSet.prod (measurableSet_singleton x)

lemma pointwise_score_close_of_noisy_compression
    (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) (a radius : ℝ)
    (hw : stableAt φ c w x) (hr0 : 0 ≤ radius) (hr1 : radius ≤ 1/6)
    (hr : radius ≤ robustRadius c w)
    (hnoise : noiseBudgetSq η ≤ (radius/2)^2)
    (happrox : |a-noisyNetworkOutput φ w x η| ≤ radius/8) :
    |clippedScore a-clippedScore (networkOutput φ w x)| ≤ 1/12 := by
  have hrad : 0 ≤ robustRadius c w := hr0.trans hr
  have hsq : (radius/2)^2 ≤ (robustRadius c w)^2 := by nlinarith
  have hrob := hw η (hnoise.trans hsq)
  have happ := (RobustStatistics.clippedScore_lipschitz a (noisyNetworkOutput φ w x η)).trans happrox
  have htri := abs_sub_le (clippedScore a) (clippedScore (noisyNetworkOutput φ w x η))
    (clippedScore (networkOutput φ w x))
  linarith

end NeuralGeneralization.ConcreteModel
