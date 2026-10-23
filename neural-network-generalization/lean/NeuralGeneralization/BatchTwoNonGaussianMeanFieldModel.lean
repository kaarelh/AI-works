import NeuralGeneralization.BatchTwoNonGaussianDualContinuity
import NeuralGeneralization.BatchTwoNonGaussianNoiseCylinder
import NeuralGeneralization.MeanFieldCoefficientSequence

/-! The original mean-field learner expressed in independent unscaled
non-Gaussian coordinates; its recursive layer events remain events of this law. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
open ConcreteModel GaussianTowerConstruction NetworkLayerSplit
open TanhDifferential FiniteDifferential GaussianDualLayer ActualDualContinuity

def weights {d N r : ℕ} (z : Weights d N r) : Weights d N r
  | .inl ij => z (.inl ij)/Real.sqrt d
  | .inr (.inl sij) => z (.inr (.inl sij))/Real.sqrt N
  | .inr (.inr i) => z (.inr (.inr i))/(N : ℝ)

theorem continuous_weights (d N r : ℕ) : Continuous (@weights d N r) := by
  apply continuous_pi
  intro q
  rcases q with ij | (sij | j) <;> simp only [weights] <;> fun_prop

@[simp] theorem weights_previous {d N r : ℕ} (z : Weights d N (r+1)) :
    previousWeights (weights z)=weights (previousWeights z) := by
  funext q
  rcases q with ij | (sij | j) <;> rfl

def inputRows {d N : ℕ} (z : Weights d N 0) : Fin N → Fin (d+1) → ℝ :=
  fun i j => z (.inl (i,j))

def lastRows {d N r : ℕ} (z : Weights d N (r+1)) : Fin N → Fin N → ℝ :=
  fun i j => z (.inr (.inl (Fin.last r,i,j)))

def inputBad (ν : CoordinateLaw) {d N : ℕ} (G K : ℝ) : Set (Weights d N 0) :=
  {z | inputRows z ∈ actualBadRows ν (inputMatrix d) N G K}

def lastBad (ν : CoordinateLaw) {d N r : ℕ} (G K : ℝ) : Set (Weights d N (r+1)) :=
  {z | lastRows z ∈ actualBadRows ν (activationMatrix (weights (previousWeights z))) N G K}

def GoodHidden (ν : CoordinateLaw) (d N : ℕ) : (r : ℕ) → (ℕ → ℝ) → ℝ → Weights d N r → Prop
  | 0,G,K,z => z ∉ inputBad ν (G 0) K
  | r+1,G,K,z => GoodHidden ν d N r G K (previousWeights z) ∧ z ∉ lastBad ν (G (r+1)) K

theorem isOpen_inputBad (ν : CoordinateLaw) {d N : ℕ} (G K : ℝ) :
    IsOpen (@inputBad ν d N G K) := by
  apply (isOpen_badFieldPair (J := Fin (d+1)) (N := N) ν G K).preimage
    (f := fun z : Weights d N 0 => (inputMatrix d,rows (inputMatrix d) (inputRows z)))
  apply continuous_const.prodMk
  apply continuous_pi
  intro i
  apply continuous_pi
  intro x
  simp only [rows,fieldLinear_apply,inputRows]
  fun_prop

theorem isOpen_lastBad (ν : CoordinateLaw) {d N r : ℕ} (G K : ℝ) :
    IsOpen (@lastBad ν d N r G K) := by
  apply (isOpen_badFieldPair (J := Fin N) (N := N) ν G K).preimage
    (f := fun z : Weights d N (r+1) =>
      (activationMatrix (weights (previousWeights z)),
        rows (activationMatrix (weights (previousWeights z))) (lastRows z)))
  have hw := (continuous_weights d N r).comp continuous_previousWeights
  have ha : Continuous (fun z : Weights d N (r+1) => activationMatrix (weights (previousWeights z))) := by
    apply continuous_pi
    intro x
    apply continuous_pi
    intro j
    exact ((continuous_finalHidden continuous_tanh x j).comp hw).div_const _
  apply ha.prodMk
  apply continuous_pi
  intro i
  apply continuous_pi
  intro x
  simp only [rows,fieldLinear_apply,lastRows]
  apply continuous_finsetSum
  intro j _
  exact ((continuous_apply j).comp ((continuous_apply x).comp ha)).mul (continuous_apply _)

theorem isClosed_GoodHidden (ν : CoordinateLaw) (d N r : ℕ) (G : ℕ → ℝ) (K : ℝ) :
    IsClosed {z | GoodHidden ν d N r G K z} := by
  induction r with
  | zero => exact (isOpen_inputBad ν (G 0) K).isClosed_compl
  | succ r ih =>
    exact (ih.preimage continuous_previousWeights).inter (isOpen_lastBad ν (G (r+1)) K).isClosed_compl

end NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
