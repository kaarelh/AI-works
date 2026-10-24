import NeuralGeneralization.BatchTwoNonGaussianMeanFieldModel
import NeuralGeneralization.BatchTwoNonGaussianMeanFieldExtraction
import NeuralGeneralization.BatchTwoContinuousFreeze

/-! Actual non-Gaussian mean-field networks evaluated on arbitrary finite real
query tables. The number of query bits and the input dimension are separate. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteQuery
open ConcreteModel BatchTwoNonGaussian GaussianTowerConstruction NetworkLayerSplit
open FiniteDifferential TanhDifferential GaussianAngularPrice MeanFieldCoefficientSequence
open GaussianDualLayer ActualDualContinuity

variable {d q N r : ℕ}

def inputMatrix (xs : Cube q → RealInput d) : Cube q → Fin (d+1) → ℝ :=
  fun x j => augmentedInput (xs x) j/Real.sqrt d

def activationMatrix (xs : Cube q → RealInput d) (w : Weights d N r) : Cube q → Fin N → ℝ :=
  fun x j => BatchTwoContinuous.finalHidden Real.tanh w (xs x) j/Real.sqrt N

def covariance (xs : Cube q → RealInput d) (w : Weights d N r) (x y : Cube q) : ℝ :=
  (∑ j, BatchTwoContinuous.finalHidden Real.tanh w (xs x) j*
    BatchTwoContinuous.finalHidden Real.tanh w (xs y) j)/(N : ℝ)

def coefficient (xs : Cube q → RealInput d) (w : Weights d N r) :
    (s : ℕ) → Cube q → StageIndex d N s → ℝ
  | 0 => inputMatrix xs
  | s+1 => fun x => MeanFieldCoefficientSequence.coefficient (freezeInput (xs x) w) (s+1) (fun _ => false)

@[simp] theorem coefficient_final (xs : Cube q → RealInput d) (w : Weights d N r) :
    coefficient xs w (r+1)=activationMatrix xs w := by
  ext x j
  simp only [coefficient,MeanFieldCoefficientSequence.coefficient_final,
    GaussianTowerConstruction.activationMatrix,activationMatrix,finalHidden_freeze]

theorem gram_coefficient_final (hN : 0<N) (xs : Cube q → RealInput d) (w : Weights d N r)
    (x y : Cube q) : gram (coefficient xs w (r+1)) x y=covariance xs w x y := by
  rw [coefficient_final]
  simp only [gram,activationMatrix,covariance,div_mul_div_comm,←sq,
    Real.sq_sqrt (Nat.cast_nonneg N),Finset.sum_div]
  rfl

@[simp] theorem freeze_previous (x : RealInput d) (w : Weights d N (r+1)) :
    freezeInput x (previousWeights w)=previousWeights (freezeInput x w) := by
  funext i
  rcases i with ij|(sij|j) <;> rfl

theorem coefficient_previous (xs : Cube q → RealInput d) (w : Weights d N (r+1))
    {s : ℕ} (hs : s≤r+1) : coefficient xs w s=coefficient xs (previousWeights w) s := by
  cases s with
  | zero => rfl
  | succ s =>
    ext x j
    simp only [coefficient,freeze_previous]
    rw [MeanFieldCoefficientSequence.coefficient_previous (freezeInput (xs x) w) hs]

def firstRows (xs : Cube q → RealInput d) (w : Weights d N r) : Fin N → Cube q → ℝ :=
  fun i x => ∑ j,w (.inl (i,j))*augmentedInput (xs x) j

def lastRows (xs : Cube q → RealInput d) (w : Weights d N (r+1)) : Fin N → Cube q → ℝ :=
  fun i x => ∑ j,lastMatrix w (i,j)*BatchTwoContinuous.finalHidden Real.tanh (previousWeights w) (xs x) j

theorem gram_coefficient_one (xs : Cube q → RealInput d) (w : Weights d N r) (x y : Cube q) :
    gram (coefficient xs w 1) x y=
      (∑ i,Real.tanh (firstRows xs w i x)*Real.tanh (firstRows xs w i y))/(N : ℝ) := by
  simp only [gram,coefficient,MeanFieldCoefficientSequence.coefficient,
    CompressionSampling.hiddenPrefix_zero,firstHidden_freeze,BatchTwoContinuous.firstHidden,firstRows,
    div_mul_div_comm,←sq,Real.sq_sqrt (Nat.cast_nonneg N),Finset.sum_div]
  rfl

theorem finalHidden_lastRows (xs : Cube q → RealInput d) (w : Weights d N (r+1)) (x : Cube q) (i : Fin N) :
    BatchTwoContinuous.finalHidden Real.tanh w (xs x) i=Real.tanh (lastRows xs w i x) := by
  have hh := MeanFieldCoefficientSequence.finalHidden_lastRows (freezeInput (xs x) w) (fun _ => false) i
  rw [finalHidden_freeze] at hh
  simp only [MeanFieldCoefficientSequence.lastRows,←freeze_previous,finalHidden_freeze] at hh
  have hl : lastMatrix (freezeInput (xs x) w)=lastMatrix w := rfl
  rw [hl] at hh
  exact hh

theorem gram_coefficient_last (hN : 0<N) (xs : Cube q → RealInput d)
    (w : Weights d N (r+1)) (x y : Cube q) :
    gram (coefficient xs w (r+2)) x y=
      (∑ i,Real.tanh (lastRows xs w i x)*Real.tanh (lastRows xs w i y))/(N : ℝ) := by
  rw [show r+2=(r+1)+1 by omega,gram_coefficient_final hN]
  simp only [covariance,finalHidden_lastRows]

def inputBad (ν : CoordinateLaw) (xs : Cube q → RealInput d) {N : ℕ} (G K : ℝ) : Set (Weights d N 0) :=
  {z | NonGaussianMeanField.inputRows z∈actualBadRows ν (inputMatrix xs) N G K}

def lastBad (ν : CoordinateLaw) (xs : Cube q → RealInput d) {N r : ℕ} (G K : ℝ) : Set (Weights d N (r+1)) :=
  {z | NonGaussianMeanField.lastRows z∈actualBadRows ν
    (activationMatrix xs (NonGaussianMeanField.weights (previousWeights z))) N G K}

def GoodHidden (ν : CoordinateLaw) (xs : Cube q → RealInput d) (N : ℕ) :
    (r : ℕ) → (ℕ → ℝ) → ℝ → Weights d N r → Prop
  | 0,G,K,z => z∉inputBad ν xs (G 0) K
  | r+1,G,K,z => GoodHidden ν xs N r G K (previousWeights z) ∧ z∉lastBad ν xs (G (r+1)) K

theorem isOpen_inputBad (ν : CoordinateLaw) (xs : Cube q → RealInput d) {N : ℕ} (G K : ℝ) :
    IsOpen (@inputBad d q ν xs N G K) := by
  apply (isOpen_badFieldPair (J := Fin (d+1)) (N := N) ν G K).preimage
    (f := fun z : Weights d N 0 => (inputMatrix xs,rows (inputMatrix xs) (NonGaussianMeanField.inputRows z)))
  apply continuous_const.prodMk
  apply continuous_pi
  intro i
  apply continuous_pi
  intro x
  simp only [rows,fieldLinear_apply,NonGaussianMeanField.inputRows]
  fun_prop

theorem isOpen_lastBad (ν : CoordinateLaw) (xs : Cube q → RealInput d) {N r : ℕ} (G K : ℝ) :
    IsOpen (@lastBad d q ν xs N r G K) := by
  apply (isOpen_badFieldPair (J := Fin N) (N := N) ν G K).preimage
    (f := fun z : Weights d N (r+1) =>
      (activationMatrix xs (NonGaussianMeanField.weights (previousWeights z)),
        rows (activationMatrix xs (NonGaussianMeanField.weights (previousWeights z)))
          (NonGaussianMeanField.lastRows z)))
  have hw := (NonGaussianMeanField.continuous_weights d N r).comp continuous_previousWeights
  have ha : Continuous (fun z : Weights d N (r+1) => activationMatrix xs (NonGaussianMeanField.weights (previousWeights z))) := by
    apply continuous_pi
    intro x
    apply continuous_pi
    intro j
    exact (((continuous_finalHidden_joint tanh_continuous j).comp
      (continuous_id.prodMk continuous_const)).comp hw).div_const _
  apply ha.prodMk
  apply continuous_pi
  intro i
  apply continuous_pi
  intro x
  simp only [rows,fieldLinear_apply,NonGaussianMeanField.lastRows]
  apply continuous_finsetSum
  intro j _
  exact ((continuous_apply j).comp ((continuous_apply x).comp ha)).mul (continuous_apply _)

theorem isClosed_GoodHidden (ν : CoordinateLaw) (xs : Cube q → RealInput d) (N r : ℕ) (G : ℕ → ℝ) (K : ℝ) :
    IsClosed {z | GoodHidden ν xs N r G K z} := by
  induction r with
  | zero => exact (isOpen_inputBad ν xs (G 0) K).isClosed_compl
  | succ r ih =>
    exact (ih.preimage continuous_previousWeights).inter (isOpen_lastBad ν xs (G (r+1)) K).isClosed_compl

end NeuralGeneralization.BatchTwoContinuous.FiniteQuery
