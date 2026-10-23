import NeuralGeneralization.BatchTwoShallowVoteLoss
import NeuralGeneralization.BatchTwoShallowRobust
import NeuralGeneralization.BatchTwoRelativeStatistics
import NeuralGeneralization.RobustConfidence

/-! One common sample event controls every retained network separately.
Integration then gives the theorem for arbitrary posterior mixtures; there
is no measurable-choice assumption about compression. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel CompressionSampling

theorem shallow_pointwise_risk {d N n : ℕ} (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (f : BooleanFunction d) {B : ℝ} (hB : 0 < B) (m : ℕ) (hm : 0 < m)
    (sample : Fin n → Cube d) (hn : 0 < n) {τ : ℝ}
    (hs : sample ∈ BatchTwoRelativeStatistics.generalizationEvent D (voteLoss f B m) n τ)
    (w : Weights d N 0) (hE : readoutEnergy w ≤ B^2)
    (htrain : ∀ i, (1 : ℝ)/2 < labelReal (f (sample i))*networkOutput Real.tanh w (sample i)) :
    (∫ x, (if labelReal (f x)*networkOutput Real.tanh w x ≤ 1/4 then (1 : ℝ) else 0) ∂D) ≤
      3*(2*Real.exp (-(m : ℝ)/(512*B^2)))+τ := by
  let b := fun i j => w (Sum.inl (i,j))
  let v := fun i => w (Sum.inr (Sum.inr i))
  have hv : BoundedDual.entryL1 v ≤ B := readoutL1_le_of_energy w hB.le hE
  let P := iidSamples (mixtureLaw hB b v hv) m
  let z := fun x => if labelReal (f x)*networkOutput Real.tanh w x ≤ 1/4 then (1 : ℝ) else 0
  have hout (x : Cube d) : (∑ i, v i*Real.tanh (dot (b i) (inputVector x))) =
      networkOutput Real.tanh w x := by rw [shallow_output]; rfl
  have hc (x : Cube d) := test_voteLoss f hB b v hv m hm x
  simp_rw [hout] at hc
  have ht (i : Fin n) := train_voteLoss f hB b v hv m hm (sample i) (by rw [hout]; exact htrain i)
  have hh := BatchTwoRelativeStatistics.risk_on_generalization_event D (voteLoss f B m) hn sample hs
    P z z (β := 0) (fun x => by simp) hc ht
  simpa only [zero_add] using hh

theorem shallow_posterior_risk {d N n : ℕ} (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (Q : Measure (Weights d N 0)) [IsProbabilityMeasure Q]
    (f : BooleanFunction d) {B : ℝ} (hB : 0 < B) (m : ℕ) (hm : 0 < m)
    (sample : Fin n → Cube d) (hn : 0 < n) {τ β : ℝ} (hτ : 0 ≤ τ)
    (hs : sample ∈ BatchTwoRelativeStatistics.generalizationEvent D (voteLoss f B m) n τ)
    (htail : Q.real {w | B^2 < readoutEnergy w} ≤ β)
    (htrain : ∀ᵐ w ∂Q, ∀ i, (1 : ℝ)/2 < labelReal (f (sample i))*networkOutput Real.tanh w (sample i)) :
    RobustConfidence.gibbsMarginRisk D Q (fun x => labelReal (f x))
      (networkOutput Real.tanh) (1/4) ≤ β+3*(2*Real.exp (-(m : ℝ)/(512*B^2)))+τ := by
  classical
  let E : Set (Weights d N 0) := {w | B^2 < readoutEnergy w}
  let a := 3*(2*Real.exp (-(m : ℝ)/(512*B^2)))+τ
  have ha : 0 ≤ a := by dsimp [a]; positivity
  let risk : Weights d N 0 → ℝ := fun w => ∫ x,
    (if labelReal (f x)*networkOutput Real.tanh w x ≤ (1/4 : ℝ) then (1 : ℝ) else 0) ∂D
  have hmeas (x : Cube d) : MeasurableSet
      {w : Weights d N 0 | labelReal (f x)*networkOutput Real.tanh w x ≤ (1/4 : ℝ)} :=
    measurableSet_le (((continuous_networkOutput tanh_lipschitzWith.continuous x).measurable).const_mul _) measurable_const
  have hi (x : Cube d) : Integrable
      (fun w : Weights d N 0 => if labelReal (f x)*networkOutput Real.tanh w x ≤ (1/4 : ℝ) then (1 : ℝ) else 0) Q :=
    (integrable_const 1).indicator (hmeas x)
  have hrisk : risk = fun w => ∑ x, D.real {x} *
      (if labelReal (f x)*networkOutput Real.tanh w x ≤ (1/4 : ℝ) then (1 : ℝ) else 0) := by
    funext w
    exact integral_fintype (RobustStatistics.integrable_finite_domain D _)
  have hirisk : Integrable risk Q := by
    rw [hrisk]
    exact integrable_finsetSum _ (fun x _ => (hi x).const_mul (D.real {x}))
  have hupper (w : Weights d N 0) : risk w ≤ 1 := by
    have h := integral_mono (RobustStatistics.integrable_finite_domain D
      (fun x => if labelReal (f x)*networkOutput Real.tanh w x ≤ (1/4 : ℝ) then (1 : ℝ) else 0))
      (integrable_const 1) (fun x => by split_ifs <;> norm_num)
    simpa [risk] using h
  have hpoint : ∀ᵐ w ∂Q, risk w ≤ a+E.indicator (fun _ => (1 : ℝ)) w := by
    filter_upwards [htrain] with w hw
    by_cases he : w ∈ E
    · simp only [Set.indicator_of_mem he]
      linarith [hupper w]
    · simp only [Set.indicator_of_notMem he, add_zero]
      exact shallow_pointwise_risk D f hB m hm sample hn hs w (le_of_not_gt he) hw
  have hE : MeasurableSet E := measurableSet_lt measurable_const continuous_readoutEnergy.measurable
  have hiE : Integrable (E.indicator (fun _ => (1 : ℝ))) Q := (integrable_const 1).indicator hE
  have hb := integral_mono_ae hirisk ((integrable_const a).add hiE) hpoint
  simp only [Pi.add_apply] at hb
  have hind : (∫ w, E.indicator (fun _ => (1 : ℝ)) w ∂Q) = Q.real E :=
    integral_indicator_one hE
  rw [integral_add (integrable_const a) hiE, integral_const, probReal_univ,
    smul_eq_mul, one_mul, hind] at hb
  rw [RobustConfidence.gibbsMarginRisk_eq_iterated_indicator D Q _ (networkOutput Real.tanh)
    (fun x => (continuous_networkOutput tanh_lipschitzWith.continuous x).measurable)]
  dsimp [risk, a, E] at hb
  linarith

end NeuralGeneralization.BatchTwoShallow
