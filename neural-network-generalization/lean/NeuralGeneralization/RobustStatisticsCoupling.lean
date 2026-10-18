import NeuralGeneralization.RobustStatistics
import NeuralGeneralization.RobustModel

/-! # Actual couplings and the clipped-margin comparison -/

noncomputable section
open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.RobustStatistics
open ConcreteModel

def marginRamp (u : ℝ) : ℝ := max 0 (min 1 (5 - 12 * u))

theorem marginRamp_bounds (u : ℝ) : 0 ≤ marginRamp u ∧ marginRamp u ≤ 1 := by
  exact ⟨le_max_left _ _, max_le (by norm_num) (min_le_left _ _)⟩

theorem measurable_marginRamp : Measurable marginRamp := by
  unfold marginRamp
  fun_prop

theorem marginRamp_eq_zero {u : ℝ} (hu : 5 / 12 ≤ u) : marginRamp u = 0 := by
  unfold marginRamp
  rw [min_eq_right (by linarith), max_eq_left (by linarith)]

theorem marginRamp_eq_one {u : ℝ} (hu : u ≤ 1 / 3) : marginRamp u = 1 := by
  unfold marginRamp
  rw [min_eq_left (by linarith), max_eq_right (by norm_num)]

theorem measurable_clippedScore : Measurable clippedScore := by
  unfold clippedScore
  fun_prop

theorem clippedScore_lipschitz (u v : ℝ) : |clippedScore u - clippedScore v| ≤ |u - v| := by
  have h₁ := abs_max_sub_max_le_max (-(1 / 2 : ℝ)) (min (1 / 2) u)
    (-(1 / 2 : ℝ)) (min (1 / 2) v)
  have h₂ := abs_min_sub_min_le_max (1 / 2 : ℝ) u (1 / 2 : ℝ) v
  simp only [sub_self, abs_zero] at h₁ h₂
  rw [max_eq_right (abs_nonneg (min (1 / 2 : ℝ) u - min (1 / 2) v))] at h₁
  rw [max_eq_right (abs_nonneg (u - v))] at h₂
  exact h₁.trans h₂

theorem signed_clippedScore_le_quarter (b : Bool) (z : ℝ)
    (hz : labelReal b * z ≤ 1 / 4) : labelReal b * clippedScore z ≤ 1 / 4 := by
  cases b
  · simp only [labelReal_false, neg_one_mul] at hz ⊢
    have hmin : -(1 / 4 : ℝ) ≤ min (1 / 2) z := le_min (by norm_num) (by linarith)
    have hmax : min (1 / 2 : ℝ) z ≤ clippedScore z := le_max_right _ _
    linarith
  · simp only [labelReal_true, one_mul] at hz ⊢
    exact max_le (by norm_num) ((min_le_right _ _).trans hz)

theorem successful_training_ramp (b : Bool) (z h : ℝ)
    (hz : 1 / 2 < labelReal b * z)
    (hclose : |clippedScore h - clippedScore z| ≤ 1 / 12) :
    marginRamp (labelReal b * clippedScore h) = 0 := by
  apply marginRamp_eq_zero
  rw [clippedScore_eq_label_of_margin b z hz.le] at hclose
  have hh := abs_le.mp hclose
  cases b <;> simp only [labelReal_false, labelReal_true, neg_one_mul, one_mul] at hh ⊢ <;> linarith

theorem successful_test_ramp (b : Bool) (z h : ℝ)
    (hz : labelReal b * z ≤ 1 / 4)
    (hclose : |clippedScore h - clippedScore z| ≤ 1 / 12) :
    marginRamp (labelReal b * clippedScore h) = 1 := by
  apply marginRamp_eq_one
  have hclip := signed_clippedScore_le_quarter b z hz
  have hh := abs_le.mp hclose
  cases b <;> simp only [labelReal_false, labelReal_true, neg_one_mul, one_mul] at hclip ⊢ <;> linarith

/-- The precise place where actual finite-noise network robustness is used.
The input is the concrete disturbed computation, not a surrogate activation.
-/
theorem robust_score_close_of_noisy_compression {d N depth : ℕ}
    (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N depth) (x : Cube d)
    (η : NetworkDisturbance N depth) (a radius : ℝ)
    (hw : w ∈ robustEvent φ c) (hr0 : 0 ≤ radius) (hr1 : radius ≤ 1 / 6)
    (hr : radius ≤ robustRadius c w)
    (hnoise : noiseBudgetSq η ≤ (radius / 2) ^ 2)
    (happrox : |a - noisyNetworkOutput φ w x η| ≤ radius / 8) :
    |clippedScore a - clippedScore (networkOutput φ w x)| ≤ 1 / 12 := by
  have hrad : 0 ≤ robustRadius c w := hr0.trans hr
  have hsq : (radius / 2) ^ 2 ≤ (robustRadius c w) ^ 2 := by nlinarith
  have hrob := hw x η (hnoise.trans hsq)
  have happ := (clippedScore_lipschitz a (noisyNetworkOutput φ w x η)).trans happrox
  have htri := abs_sub_le (clippedScore a) (clippedScore (noisyNetworkOutput φ w x η))
    (clippedScore (networkOutput φ w x))
  linarith

variable {W H : Type*} [MeasurableSpace W] [MeasurableSpace H]

/-- A genuine joint probability law, with the specified two marginal laws. -/
structure ProbabilityCoupling (Q : Measure W) (Γ : Measure H) where
  joint : Measure (W × H)
  probability : IsProbabilityMeasure joint
  left : joint.map Prod.fst = Q
  right : joint.map Prod.snd = Γ

attribute [instance] ProbabilityCoupling.probability

theorem ProbabilityCoupling.integral_left (Q : Measure W) (Γ : Measure H)
    (π : ProbabilityCoupling Q Γ) (g : W → ℝ) (hg : Measurable g) :
    (∫ p, g p.1 ∂π.joint) = ∫ w, g w ∂Q := by
  have he := integral_map_of_stronglyMeasurable (μ := π.joint) measurable_fst hg.stronglyMeasurable
  rw [π.left] at he
  exact he.symm

theorem ProbabilityCoupling.integral_right (Q : Measure W) (Γ : Measure H)
    (π : ProbabilityCoupling Q Γ) (g : H → ℝ) (hg : Measurable g) :
    (∫ p, g p.2 ∂π.joint) = ∫ h, g h ∂Γ := by
  have he := integral_map_of_stronglyMeasurable (μ := π.joint) measurable_snd hg.stronglyMeasurable
  rw [π.right] at he
  exact he.symm

theorem ProbabilityCoupling.left_event_le (Q : Measure W) (Γ : Measure H)
    (π : ProbabilityCoupling Q Γ) (E : Set W) (hE : MeasurableSet E)
    (B : Set (W × H)) (hB : MeasurableSet B)
    (loss : H → ℝ) (hloss : Measurable loss)
    (hbound : ∀ h, 0 ≤ loss h ∧ loss h ≤ 1)
    (hpoint : ∀ p : W × H, E.indicator (fun _ => (1 : ℝ)) p.1 ≤
      loss p.2 + B.indicator (fun _ => (1 : ℝ)) p) :
    Q.real E ≤ (∫ h, loss h ∂Γ) + π.joint.real B := by
  have hleft : Integrable (fun p : W × H => E.indicator (fun _ => (1 : ℝ)) p.1) π.joint := by
    apply Integrable.of_bound ((measurable_const.indicator hE).comp measurable_fst).aestronglyMeasurable 1
    exact Filter.Eventually.of_forall (fun p => by by_cases hp : p.1 ∈ E <;> simp [hp])
  have hright : Integrable (fun p : W × H => loss p.2) π.joint := by
    apply Integrable.of_bound (hloss.comp measurable_snd).aestronglyMeasurable 1
    exact Filter.Eventually.of_forall (fun p => by
      change ‖loss p.2‖ ≤ 1
      rw [Real.norm_eq_abs, abs_of_nonneg (hbound p.2).1]
      exact (hbound p.2).2)
  have hind : Integrable (B.indicator (fun _ => (1 : ℝ))) π.joint :=
    (integrable_const _).indicator hB
  have hh := integral_mono hleft (hright.add hind) hpoint
  simp only [Pi.add_apply] at hh
  rw [integral_add hright hind, π.integral_left Q Γ _ (measurable_const.indicator hE),
    π.integral_right Q Γ loss hloss] at hh
  have hiE : (∫ w, E.indicator (fun _ => (1 : ℝ)) w ∂Q) = Q.real E := integral_indicator_one hE
  have hiB : (∫ p, B.indicator (fun _ => (1 : ℝ)) p ∂π.joint) = π.joint.real B := integral_indicator_one hB
  simpa only [hiE, hiB] using hh

theorem ProbabilityCoupling.right_loss_le (Q : Measure W) (Γ : Measure H)
    (π : ProbabilityCoupling Q Γ) (E : Set W) (hE : MeasurableSet E)
    (B : Set (W × H)) (hB : MeasurableSet B)
    (loss : H → ℝ) (hloss : Measurable loss)
    (hbound : ∀ h, 0 ≤ loss h ∧ loss h ≤ 1)
    (hpoint : ∀ p : W × H, loss p.2 ≤
      E.indicator (fun _ => (1 : ℝ)) p.1 + B.indicator (fun _ => (1 : ℝ)) p) :
    (∫ h, loss h ∂Γ) ≤ Q.real E + π.joint.real B := by
  have hleft : Integrable (fun p : W × H => E.indicator (fun _ => (1 : ℝ)) p.1) π.joint := by
    apply Integrable.of_bound ((measurable_const.indicator hE).comp measurable_fst).aestronglyMeasurable 1
    exact Filter.Eventually.of_forall (fun p => by by_cases hp : p.1 ∈ E <;> simp [hp])
  have hright : Integrable (fun p : W × H => loss p.2) π.joint := by
    apply Integrable.of_bound (hloss.comp measurable_snd).aestronglyMeasurable 1
    exact Filter.Eventually.of_forall (fun p => by
      change ‖loss p.2‖ ≤ 1
      rw [Real.norm_eq_abs, abs_of_nonneg (hbound p.2).1]
      exact (hbound p.2).2)
  have hind : Integrable (B.indicator (fun _ => (1 : ℝ))) π.joint :=
    (integrable_const _).indicator hB
  have hh := integral_mono hright (hleft.add hind) hpoint
  simp only [Pi.add_apply] at hh
  rw [integral_add hleft hind, π.integral_left Q Γ _ (measurable_const.indicator hE),
    π.integral_right Q Γ loss hloss] at hh
  have hiE : (∫ w, E.indicator (fun _ => (1 : ℝ)) w ∂Q) = Q.real E := integral_indicator_one hE
  have hiB : (∫ p, B.indicator (fun _ => (1 : ℝ)) p ∂π.joint) = π.joint.real B := integral_indicator_one hB
  simpa only [hiE, hiB] using hh

def scoreFailure (z : W → ℝ) (a : H → ℝ) : Set (W × H) :=
  {p | 1 / 12 < |clippedScore (a p.2) - clippedScore (z p.1)|}

theorem measurable_scoreFailure (z : W → ℝ) (a : H → ℝ)
    (hz : Measurable z) (ha : Measurable a) : MeasurableSet (scoreFailure z a) := by
  apply measurableSet_lt measurable_const
  exact (((measurable_clippedScore.comp ha).comp measurable_snd).sub
    ((measurable_clippedScore.comp hz).comp measurable_fst)).abs

theorem coupled_training_loss (Q : Measure W) (Γ : Measure H)
    (π : ProbabilityCoupling Q Γ) (b : Bool) (z : W → ℝ) (a : H → ℝ)
    (hz : Measurable z) (ha : Measurable a) {α : ℝ}
    (htrain : Q.real {w | labelReal b * z w ≤ 1 / 2} = 0)
    (hfail : π.joint.real (scoreFailure z a) ≤ α) :
    (∫ h, marginRamp (labelReal b * clippedScore (a h)) ∂Γ) ≤ α := by
  let E : Set W := {w | labelReal b * z w ≤ 1 / 2}
  let B := scoreFailure z a
  let loss := fun h => marginRamp (labelReal b * clippedScore (a h))
  have hE : MeasurableSet E := measurableSet_le (hz.const_mul _) measurable_const
  have hB : MeasurableSet B := measurable_scoreFailure z a hz ha
  have hloss : Measurable loss :=
    measurable_marginRamp.comp ((measurable_clippedScore.comp ha).const_mul _)
  have hp (p : W × H) : loss p.2 ≤
      E.indicator (fun _ => (1 : ℝ)) p.1 + B.indicator (fun _ => (1 : ℝ)) p := by
    have hb := marginRamp_bounds (labelReal b * clippedScore (a p.2))
    by_cases he : p.1 ∈ E
    · by_cases hbad : p ∈ B
      · simp only [Set.indicator_of_mem he, Set.indicator_of_mem hbad]
        dsimp [loss]
        linarith [hb.2]
      · simp only [Set.indicator_of_mem he, Set.indicator_of_notMem hbad, add_zero]
        exact hb.2
    · by_cases hbad : p ∈ B
      · simp only [Set.indicator_of_notMem he, Set.indicator_of_mem hbad, zero_add]
        exact hb.2
      · have hzero := successful_training_ramp b (z p.1) (a p.2)
          (lt_of_not_ge he) (le_of_not_gt hbad)
        simp only [Set.indicator_of_notMem he, Set.indicator_of_notMem hbad, add_zero]
        exact hzero.le
  have hh := π.right_loss_le Q Γ E hE B hB loss hloss (fun h => marginRamp_bounds _) hp
  rw [htrain] at hh
  exact hh.trans (by simpa only [zero_add] using hfail)

theorem coupled_test_error (Q : Measure W) (Γ : Measure H)
    (π : ProbabilityCoupling Q Γ) (b : Bool) (z : W → ℝ) (a : H → ℝ)
    (hz : Measurable z) (ha : Measurable a) {α : ℝ}
    (hfail : π.joint.real (scoreFailure z a) ≤ α) :
    Q.real {w | labelReal b * z w ≤ 1 / 4} ≤
      α + ∫ h, marginRamp (labelReal b * clippedScore (a h)) ∂Γ := by
  let E : Set W := {w | labelReal b * z w ≤ 1 / 4}
  let B := scoreFailure z a
  let loss := fun h => marginRamp (labelReal b * clippedScore (a h))
  have hE : MeasurableSet E := measurableSet_le (hz.const_mul _) measurable_const
  have hB : MeasurableSet B := measurable_scoreFailure z a hz ha
  have hloss : Measurable loss :=
    measurable_marginRamp.comp ((measurable_clippedScore.comp ha).const_mul _)
  have hp (p : W × H) : E.indicator (fun _ => (1 : ℝ)) p.1 ≤
      loss p.2 + B.indicator (fun _ => (1 : ℝ)) p := by
    have hb := marginRamp_bounds (labelReal b * clippedScore (a p.2))
    by_cases he : p.1 ∈ E
    · by_cases hbad : p ∈ B
      · simp only [Set.indicator_of_mem he, Set.indicator_of_mem hbad]
        dsimp [loss]
        linarith [hb.1]
      · have hone := successful_test_ramp b (z p.1) (a p.2) he (le_of_not_gt hbad)
        simp only [Set.indicator_of_mem he, Set.indicator_of_notMem hbad, add_zero]
        exact hone.ge
    · by_cases hbad : p ∈ B
      · simp only [Set.indicator_of_notMem he, Set.indicator_of_mem hbad]
        dsimp [loss]
        linarith [hb.1]
      · simp only [Set.indicator_of_notMem he, Set.indicator_of_notMem hbad, add_zero]
        exact hb.1
  have hh := π.left_event_le Q Γ E hE B hB loss hloss (fun h => marginRamp_bounds _) hp
  linarith [hfail]

end NeuralGeneralization.RobustStatistics
