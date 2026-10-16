import NeuralGeneralization.NetworkLayerSplit
import NeuralGeneralization.GaussianTowerConstruction
import NeuralGeneralization.SamplingNetwork

/-! The actual layer coefficient sequence of a finite network, with its
input covariance, empirical hidden covariances, and prefix consistency. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.MeanFieldCoefficientSequence
open ConcreteModel NetworkLayerSplit TowerNetwork GaussianTowerConstruction
open GaussianAngularPrice CompressionSampling FiniteDifferential

def StageIndex (d N : ℕ) : ℕ → Type
  | 0 => Fin (d + 1)
  | _ + 1 => Fin N

instance stageIndexFintype (d N s : ℕ) : Fintype (StageIndex d N s) := by
  cases s <;> dsimp [StageIndex] <;> infer_instance

instance stageIndexDecidableEq (d N s : ℕ) : DecidableEq (StageIndex d N s) := by
  cases s <;> dsimp [StageIndex] <;> infer_instance

def coefficient {d N r : ℕ} (w : Weights d N r) :
    (s : ℕ) → Cube d → StageIndex d N s → ℝ
  | 0 => inputMatrix d
  | s + 1 => fun x j => hiddenPrefix Real.tanh w x s j / Real.sqrt N

@[simp] theorem coefficient_zero {d N r : ℕ} (w : Weights d N r) :
    coefficient w 0 = inputMatrix d := rfl

@[simp] theorem coefficient_final {d N r : ℕ} (w : Weights d N r) :
    coefficient w (r + 1) = activationMatrix w := by
  ext x j
  simp only [coefficient, activationMatrix, hiddenPrefix_last]

theorem gram_coefficient_final {d N r : ℕ} (hN : 0 < N) (w : Weights d N r)
    (x y : Cube d) :
    gram (coefficient w (r + 1)) x y = finalCovariance Real.tanh w x y := by
  rw [coefficient_final]
  change gram (activationMatrix w) x y = finalCovariance Real.tanh w x y
  exact gram_activationMatrix hN w x y

theorem hiddenPrefix_append {d N r : ℕ} (w : Weights d N r)
    (a : Fin N → Fin N → ℝ) {s : ℕ} (hs : s ≤ r) (x : Cube d) :
    hiddenPrefix Real.tanh (appendLayer w a) x s = hiddenPrefix Real.tanh w x s := by
  unfold hiddenPrefix
  rw [List.finRange_succ_last]
  rw [List.take_append_of_le_length (by simpa using hs)]
  simp only [← List.map_take, List.foldl_map, firstHidden_appendLayer,
    hiddenStep_appendLayer_castSucc]

theorem coefficient_append {d N r : ℕ} (w : Weights d N r)
    (a : Fin N → Fin N → ℝ) {s : ℕ} (hs : s ≤ r + 1) :
    coefficient (appendLayer w a) s = coefficient w s := by
  cases s with
  | zero => rfl
  | succ s =>
    ext x j
    simp only [coefficient, hiddenPrefix_append w a (show s ≤ r by omega)]

theorem coefficient_previous {d N r : ℕ} (w : Weights d N (r + 1))
    {s : ℕ} (hs : s ≤ r + 1) :
    coefficient w s = coefficient (previousWeights w) s := by
  conv_lhs => rw [← append_prefix_last w]
  exact coefficient_append _ _ hs

/-- Actual first-layer preactivation rows, before applying tanh. -/
def firstRows {d N r : ℕ} (w : Weights d N r) : Fin N → Cube d → ℝ :=
  fun i x => ∑ j, w (.inl (i, j)) * inputVector x j

/-- Actual last hidden preactivation rows. -/
def lastRows {d N r : ℕ} (w : Weights d N (r + 1)) : Fin N → Cube d → ℝ :=
  fun i x => ∑ j, lastMatrix w (i, j) * finalHidden Real.tanh (previousWeights w) x j

theorem gram_coefficient_one {d N r : ℕ} (w : Weights d N r) (x y : Cube d) :
    gram (coefficient w 1) x y =
      (∑ i, Real.tanh (firstRows w i x) * Real.tanh (firstRows w i y)) / (N : ℝ) := by
  simp only [gram, coefficient, hiddenPrefix_zero, firstHidden, firstRows]
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i hi
  rw [div_mul_div_comm, ← sq, Real.sq_sqrt (Nat.cast_nonneg N)]

theorem finalHidden_lastRows {d N r : ℕ} (w : Weights d N (r + 1)) (x : Cube d) (i : Fin N) :
    finalHidden Real.tanh w x i = Real.tanh (lastRows w i x) := by
  conv_lhs => rw [← append_prefix_last w, finalHidden_appendLayer]
  rfl

theorem gram_coefficient_last {d N r : ℕ} (hN : 0 < N) (w : Weights d N (r + 1))
    (x y : Cube d) :
    gram (coefficient w (r + 2)) x y =
      (∑ i, Real.tanh (lastRows w i x) * Real.tanh (lastRows w i y)) / (N : ℝ) := by
  rw [show r + 2 = (r + 1) + 1 by omega, gram_coefficient_final hN]
  simp only [finalCovariance, finalHidden_lastRows]

end NeuralGeneralization.MeanFieldCoefficientSequence
