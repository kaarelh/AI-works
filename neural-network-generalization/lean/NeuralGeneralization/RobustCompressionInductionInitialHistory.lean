import NeuralGeneralization.RobustCompressionInductionInitial
import NeuralGeneralization.RobustCompressionInductionOriginal

/-! # Initial comparison retains the full actual network and virtual path -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustCompressionFirstLayer

abbrev OriginalHistory (d N r s : ℕ) := Weights d N r × HiddenPath N s

def initialHistoryPath {d N r : ℕ} (φ : ℝ → ℝ) (B : ℝ) (x : Cube d)
    (w : Weights d N r) : HiddenPath N 0 := fun _ => clippedFirstHidden φ B w x

theorem measurable_initialHistoryPath {d N r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    (B : ℝ) (x : Cube d) : Measurable (initialHistoryPath (N:=N) (r:=r) φ B x) := by
  apply measurable_pi_lambda
  intro s
  apply measurable_pi_lambda
  intro i
  exact measurable_clippedFirstHidden hφ.measurable B x i

def initialHistoryMap {d N m r : ℕ} (σ B : ℝ) (φ : ℝ → ℝ) (x : Cube d)
    (w : Weights d N r) : OriginalHistory d N r 0 ×
      (ActivePrefix d N m 0 × FutureWeights N r) :=
  ((w,initialHistoryPath φ B x w),initialState m σ B w)

theorem measurable_initialHistoryMap {d N m r : ℕ} (σ B : ℝ) {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x : Cube d) :
    Measurable (initialHistoryMap (N:=N) (m:=m) (r:=r) σ B φ x) :=
  (measurable_id.prodMk (measurable_initialHistoryPath hφ B x)).prodMk
    (measurable_initialState d N m r σ B)

def initialHistory {d N r : ℕ} (m : ℕ) (σ B : ℝ) {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x : Cube d) (Q : Measure (Weights d N r))
    [IsProbabilityMeasure Q] :
    CanonicalHistoryComparison Q (initialLaw m σ B Q)
      (Prod.fst : OriginalHistory d N r 0 → Weights d N r) where
  joint := Q.map (initialHistoryMap σ B φ x)
  probability := Measure.isProbabilityMeasure_map
    (measurable_initialHistoryMap σ B hφ x).aemeasurable
  original_marginal := by
    have ho : Measurable (fun z : OriginalHistory d N r 0 ×
        (ActivePrefix d N m 0 × FutureWeights N r) => z.1.1) :=
      measurable_fst.comp measurable_fst
    rw [Measure.map_map ho (measurable_initialHistoryMap σ B hφ x)]
    exact Measure.map_id
  state_marginal := by
    rw [Measure.map_map measurable_snd (measurable_initialHistoryMap σ B hφ x)]
    rfl

theorem originalPathCost_initial {d N r : ℕ} (φ : ℝ → ℝ) (B : ℝ)
    (w : Weights d N r) (x : Cube d) :
    originalPathCost (Nat.zero_le r) φ w x (initialHistoryPath φ B x w) =
      firstClippingError φ B w x := by
  unfold originalPathCost hiddenPathCost firstClippingError initialHistoryPath
  simp only [Finset.univ_eq_empty,Finset.sum_empty,add_zero]
  apply congrArg (fun a : ℝ => a/(N:ℝ))
  apply Finset.sum_congr rfl
  intro i hi
  change (clippedFirstHidden φ B w x i-firstHidden φ w x i)^2 =
    (firstHidden φ w x i-clippedFirstHidden φ B w x i)^2
  ring

/-- The initial complete-history comparison has the actual first-layer error
bound. Its canonical marginal is independent of the input. -/
theorem initialHistory_cost_le {d N m r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ K : ℝ} (hσ : 0 < σ) (hK : 0 ≤ K) (hscale : (N : ℝ)*σ^2 ≤ 1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : InformationTheory.klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (K/σ^2))
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hbound : ∀z,|φ z|≤1)
    (B : ℝ) (hB : 0 < B) (x : Cube d) :
    (∫⁻ z, ENNReal.ofReal (originalPathCost (Nat.zero_le r) φ z.1.1 x z.1.2)
      ∂(initialHistory m σ B hφ x Q).joint) ≤
      ENNReal.ofReal (4*(4*K+2*((d:ℝ)+1))/B^2) := by
  have hcost : Measurable (fun z : OriginalHistory d N r 0 ×
      (ActivePrefix d N m 0 × FutureWeights N r) =>
      ENNReal.ofReal (originalPathCost (Nat.zero_le r) φ z.1.1 x z.1.2)) := by
    unfold originalPathCost hiddenPathCost
    apply Measurable.ennreal_ofReal
    apply Measurable.div_const
    apply Measurable.add
    · apply Finset.measurable_sum
      intro i hi
      have hh : Measurable (fun z : OriginalHistory d N r 0 ×
          (ActivePrefix d N m 0 × FutureWeights N r) => z.1.2 0 i) := by fun_prop
      have hw : Measurable (fun z : OriginalHistory d N r 0 ×
          (ActivePrefix d N m 0 × FutureWeights N r) => firstHidden φ z.1.1 x i) :=
        (continuous_firstHidden hφ x i).measurable.comp measurable_fst.fst
      exact (hh.sub hw).pow_const 2
    · simp only [Finset.univ_eq_empty,Finset.sum_empty]
      exact measurable_const
  change (∫⁻ z, _ ∂Q.map (initialHistoryMap σ B φ x)) ≤ _
  rw [lintegral_map hcost (measurable_initialHistoryMap σ B hφ x)]
  simp only [initialHistoryMap,originalPathCost_initial]
  obtain ⟨hi,he⟩ := first_clipping_expected_error hd hN hσ hK hscale Q hKL hφ hbound B hB x
  rw [← ofReal_integral_eq_lintegral_ofReal hi
    (Filter.Eventually.of_forall (fun w => first_clipping_error_nonneg φ B w x))]
  exact ENNReal.ofReal_le_ofReal he

end NeuralGeneralization.RobustCompressionInduction
