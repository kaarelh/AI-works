import NeuralGeneralization.GaussianDualContinuity
import NeuralGeneralization.GaussianTowerConstruction
import NeuralGeneralization.NetworkInputSplit

/-! The actual finite-width hidden-layer certificate event. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.MeanFieldGoodEvent
open ConcreteModel FiniteDifferential GaussianAngularFields GaussianFieldTilt
open GaussianDualLayer GaussianDualContinuity GaussianTowerConstruction NetworkLayerSplit
open TanhDifferential CovarianceDualLift DualCertificate

def inputFeatures (d : ℕ) (x : Cube d) (j : Fin (d + 1)) : ℝ := inputVector x j

def inputRows {d N : ℕ} (w : Weights d N 0) : Fin N → Fin (d + 1) → ℝ :=
  fun i j => w (.inl (i, j))

def incomingFeatures {d N r : ℕ} (w : Weights d N r) (x : Cube d) (j : Fin N) : ℝ :=
  finalHidden Real.tanh w x j

def lastRows {d N r : ℕ} (w : Weights d N (r + 1)) : Fin N → Fin N → ℝ :=
  fun i j => lastMatrix w (i, j)

def inputBad {d N : ℕ} (G K : ℝ) : Set (Weights d N 0) :=
  {w | inputRows w ∈ rawBadRows (inputMatrix d) (inputFeatures d) N G K}

def lastBad {d N r : ℕ} (G K : ℝ) : Set (Weights d N (r + 1)) :=
  {w | lastRows w ∈ rawBadRows (activationMatrix (previousWeights w))
    (incomingFeatures (previousWeights w)) N G K}

/-- The first hidden layer is numbered zero; the last layer of depth r+2
is numbered r. All events use the original network weights. -/
def GoodHidden (d N : ℕ) : (r : ℕ) → (ℕ → ℝ) → ℝ → Weights d N r → Prop
  | 0, G, K, w => w ∉ inputBad (G 0) K
  | r + 1, G, K, w => GoodHidden d N r G K (previousWeights w) ∧ w ∉ lastBad (G (r + 1)) K

theorem isOpen_inputBad {d N : ℕ} (G K : ℝ) : IsOpen (@inputBad d N G K) := by
  apply (isOpen_badFieldPair (J := Fin (d + 1)) (N := N) G K).preimage
    (f := fun w : Weights d N 0 => (inputMatrix d, rows (inputFeatures d) (inputRows w)))
  apply continuous_const.prodMk
  apply continuous_pi
  intro i
  apply continuous_pi
  intro x
  simp only [rows, fieldLinear_apply, inputRows, inputFeatures]
  fun_prop

theorem isOpen_lastBad {d N r : ℕ} (G K : ℝ) : IsOpen (@lastBad d N r G K) := by
  apply (isOpen_badFieldPair (J := Fin N) (N := N) G K).preimage
    (f := fun w : Weights d N (r + 1) => (activationMatrix (previousWeights w),
      rows (incomingFeatures (previousWeights w)) (lastRows w)))
  apply Continuous.prodMk
  · apply continuous_pi
    intro x
    apply continuous_pi
    intro j
    exact ((continuous_finalHidden continuous_tanh x j).comp continuous_previousWeights).div_const _
  · apply continuous_pi
    intro i
    apply continuous_pi
    intro x
    simp only [rows, fieldLinear_apply, incomingFeatures, lastRows]
    apply continuous_finsetSum
    intro j hj
    exact ((continuous_finalHidden continuous_tanh x j).comp continuous_previousWeights).mul
      ((continuous_apply (i, j)).comp continuous_lastMatrix)

theorem isClosed_GoodHidden (d N r : ℕ) (G : ℕ → ℝ) (K : ℝ) :
    IsClosed {w | GoodHidden d N r G K w} := by
  induction r with
  | zero => exact (isOpen_inputBad (G 0) K).isClosed_compl
  | succ r ih =>
    exact (ih.preimage continuous_previousWeights).inter (isOpen_lastBad (G (r+1)) K).isClosed_compl

end NeuralGeneralization.MeanFieldGoodEvent
end
