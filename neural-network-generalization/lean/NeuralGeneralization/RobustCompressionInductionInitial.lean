import NeuralGeneralization.RobustCompressionInductionLaw
import NeuralGeneralization.RobustCompressionFirstLayer
import NeuralGeneralization.RobustCompressionInductionHistory
import NeuralGeneralization.RobustCompressionInductionPath

/-! # Actual initial clipped prefix and retained original future -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy RobustCompressionBlockMoments
open RobustCompressionFirstLayer RobustCompressionClipping

/-- Reconstitute a physical first-layer row from the actual standardized block. -/
def initialPhysicalRow (d N r : ℕ) (σ : ℝ) (z : FirstBlock d N) (i : Fin N) :
    EuclideanSpace ℝ (Fin (d+1)) :=
  WithLp.toLp 2 (fun j => Real.sqrt (d : ℝ) * coordinateScale d N r (Sum.inl (i,j)) *
    σ * z (i,j))

def initialPrefix (d N m r : ℕ) (σ B : ℝ) (z : FirstBlock d N) : ActivePrefix d N m 0 :=
  (true,fun i j => wholeClip B (initialPhysicalRow d N r σ z i) j / Real.sqrt (d : ℝ))

theorem measurable_initialPrefix (d N m r : ℕ) (σ B : ℝ) :
    Measurable (initialPrefix d N m r σ B) := by
  apply measurable_const.prodMk
  apply measurable_pi_lambda
  intro i
  apply measurable_pi_lambda
  intro j
  apply Measurable.div_const
  have hr : Measurable (fun z : FirstBlock d N => initialPhysicalRow d N r σ z i) := by
    unfold initialPhysicalRow
    exact (WithLp.measurable_toLp 2 (Fin (d+1) → ℝ)).comp (by fun_prop)
  exact (EuclideanSpace.proj j).measurable.comp ((measurable_wholeClip B).comp hr)

def initialState {d N r : ℕ} (m : ℕ) (σ B : ℝ) (w : Weights d N r) :
    ActivePrefix d N m 0 × FutureWeights N r :=
  let z := splitFirst d N r (standardizedWeights σ w)
  (initialPrefix d N m r σ B z.1,z.2)

theorem measurable_initialState (d N m r : ℕ) (σ B : ℝ) :
    Measurable (initialState (d:=d) (N:=N) (r:=r) m σ B) :=
  ((measurable_initialPrefix d N m r σ B).prodMap measurable_id).comp
    ((splitFirst d N r).measurable.comp (measurable_standardizedWeights σ))

theorem initialPhysicalRow_actual {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (w : Weights d N r) (i : Fin N) :
    initialPhysicalRow d N r σ (splitFirst d N r (standardizedWeights σ w)).1 i =
      firstPhysicalRow w i := by
  ext j
  change Real.sqrt (d : ℝ) * coordinateScale d N r (Sum.inl (i,j)) * σ *
    ((w (Sum.inl (i,j)) / coordinateScale d N r (Sum.inl (i,j))) / σ) =
      Real.sqrt (d : ℝ) * w (Sum.inl (i,j))
  field_simp [(coordinateScale_pos hd hN (Sum.inl (i,j))).ne',hσ.ne']

theorem initialState_hidden {d N m r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (B : ℝ) (φ : ℝ → ℝ) (w : Weights d N r)
    (x : Cube d) : activeHidden φ (initialState m σ B w).1 x =
      clippedFirstHidden φ B w x := by
  funext i
  simp only [initialState,initialPrefix,activeHidden,↓reduceIte,payloadHidden,firstHidden,
    firstRowsWeights,Sum.elim_inl,clippedFirstHidden,firstRowEvaluation]
  rw [initialPhysicalRow_actual hd hN hσ]

/-- The prior pushforward factors after clipping the first block. -/
theorem initialState_reference {d N m r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (B : ℝ) :
    (smallPrior d N r σ).map (initialState m σ B) =
      ((firstBlockPrior d N).map (initialPrefix d N m r σ B)).prod (futurePrior N r) := by
  change (smallPrior d N r σ).map
    ((Prod.map (initialPrefix d N m r σ B) id) ∘
      (fun w => splitFirst d N r (standardizedWeights σ w))) = _
  have hs : Measurable (fun w : Weights d N r => splitFirst d N r (standardizedWeights σ w)) :=
    (splitFirst d N r).measurable.comp (measurable_standardizedWeights σ)
  rw [← Measure.map_map ((measurable_initialPrefix d N m r σ B).prodMap measurable_id) hs,
    actual_standardized_splitFirst_law hd hN hσ,
    ← Measure.map_prod_map _ _ (measurable_initialPrefix d N m r σ B) measurable_id,
    Measure.map_id]

def initialLaw {d N r : ℕ} (m : ℕ) (σ B : ℝ) (Q : Measure (Weights d N r)) :=
  Q.map (initialState m σ B)

instance initialLaw_probability {d N m r : ℕ} (σ B : ℝ)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q] :
    IsProbabilityMeasure (initialLaw m σ B Q) :=
  Measure.isProbabilityMeasure_map (measurable_initialState d N m r σ B).aemeasurable

/-- Entropy starts at the actual posterior KL, without a prefix reference assumption. -/
theorem initialLaw_futureEntropy_le {d N m r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (B : ℝ)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q] :
    futureEntropy (initialLaw m σ B Q) (futurePrior N r) ≤
      InformationTheory.klDiv Q (smallPrior d N r σ) := by
  let ν := (firstBlockPrior d N).map (initialPrefix d N m r σ B)
  letI : IsProbabilityMeasure ν :=
    Measure.isProbabilityMeasure_map (measurable_initialPrefix d N m r σ B).aemeasurable
  have hdata := RobustEntropy.klDiv_map_le Q (smallPrior d N r σ)
    (measurable_initialState d N m r σ B)
  rw [initialState_reference hd hN hσ] at hdata
  exact (futureEntropy_le_reference (initialLaw m σ B Q) ν (futurePrior N r)).trans hdata

end NeuralGeneralization.RobustCompressionInduction
