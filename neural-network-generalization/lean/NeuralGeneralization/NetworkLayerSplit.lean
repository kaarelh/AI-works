import NeuralGeneralization.TowerNetwork
import NeuralGeneralization.Model
import Mathlib.MeasureTheory.Integral.Prod

/-! Exact decomposition of the network prior into a shorter network and its
last hidden matrix. This is the independence used for finite-width certificates. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.NetworkLayerSplit
open ConcreteModel TowerNetwork

def indexJoin (d N r : ℕ) : WeightIndex d N r ⊕ (Fin N × Fin N) ≃ WeightIndex d N (r + 1) where
  toFun
    | .inl (.inl ij) => .inl ij
    | .inl (.inr (.inl (s, i, j))) => .inr (.inl (s.castSucc, i, j))
    | .inl (.inr (.inr j)) => .inr (.inr j)
    | .inr (i, j) => .inr (.inl (Fin.last r, i, j))
  invFun
    | .inl ij => .inl (.inl ij)
    | .inr (.inl (s, i, j)) => Fin.lastCases (.inr (i, j))
        (fun t => .inl (.inr (.inl (t, i, j)))) s
    | .inr (.inr j) => .inl (.inr (.inr j))
  left_inv := by
    intro i
    rcases i with (ij | (⟨s, i, j⟩ | j)) | ⟨i, j⟩ <;> simp
  right_inv := by
    intro i
    rcases i with ij | (⟨s, i, j⟩ | j)
    · rfl
    · refine Fin.lastCases ?_ (fun t => ?_) s <;> simp
    · rfl

def split (d N r : ℕ) : Weights d N (r + 1) ≃ᵐ
    Weights d N r × (Fin N × Fin N → ℝ) :=
  ((MeasurableEquiv.piCongrLeft (fun _ : WeightIndex d N (r + 1) => ℝ)
    (indexJoin d N r)).symm).trans
      (MeasurableEquiv.sumPiEquivProdPi (fun _ : WeightIndex d N r ⊕ (Fin N × Fin N) => ℝ))

theorem split_symm_apply {d N r : ℕ} (w : Weights d N r) (a : Fin N × Fin N → ℝ) :
    (split d N r).symm (w, a) = appendLayer w (fun i j => a (i, j)) := by
  funext i
  rcases i with ij | (⟨s, i, j⟩ | j)
  · rfl
  · refine Fin.lastCases ?_ (fun t => ?_) s <;> simp [split, indexJoin, appendLayer,
      MeasurableEquiv.piCongrLeft, MeasurableEquiv.sumPiEquivProdPi, Equiv.piCongrLeft, Equiv.sumPiEquivProdPi]
  · rfl

def previousWeights {d N r : ℕ} (w : Weights d N (r + 1)) : Weights d N r :=
  (split d N r w).1

def lastMatrix {d N r : ℕ} (w : Weights d N (r + 1)) : Fin N × Fin N → ℝ :=
  (split d N r w).2

theorem append_prefix_last {d N r : ℕ} (w : Weights d N (r + 1)) :
    appendLayer (previousWeights w) (fun i j => lastMatrix w (i, j)) = w := by
  rw [← split_symm_apply]
  exact (split d N r).symm_apply_apply w

@[simp] theorem split_appendLayer {d N r : ℕ} (w : Weights d N r) (a : Fin N → Fin N → ℝ) :
    split d N r (appendLayer w a) = (w, fun ij => a ij.1 ij.2) := by
  rw [← split_symm_apply w (fun ij => a ij.1 ij.2)]
  exact (split d N r).apply_symm_apply _

@[simp] theorem previousWeights_appendLayer {d N r : ℕ}
    (w : Weights d N r) (a : Fin N → Fin N → ℝ) : previousWeights (appendLayer w a) = w := by
  simp only [previousWeights, split_appendLayer]

@[simp] theorem lastMatrix_appendLayer {d N r : ℕ}
    (w : Weights d N r) (a : Fin N → Fin N → ℝ) :
    lastMatrix (appendLayer w a) = fun ij => a ij.1 ij.2 := by
  simp only [lastMatrix, split_appendLayer]

@[fun_prop] theorem continuous_previousWeights {d N r : ℕ} :
    Continuous (@previousWeights d N r) := by
  apply continuous_pi
  intro i
  change Continuous (fun w : Weights d N (r + 1) => w ((indexJoin d N r) (.inl i)))
  fun_prop

@[fun_prop] theorem continuous_lastMatrix {d N r : ℕ} :
    Continuous (@lastMatrix d N r) := by
  apply continuous_pi
  intro i
  change Continuous (fun w : Weights d N (r + 1) => w ((indexJoin d N r) (.inr i)))
  fun_prop

def matrixPrior (N : ℕ) (γ : ℝ) : Measure (Fin N × Fin N → ℝ) :=
  Measure.pi (fun _ => gaussianReal 0 ((N : ℝ) ^ (-γ)).toNNReal)

instance matrixPrior_probability (N : ℕ) (γ : ℝ) : IsProbabilityMeasure (matrixPrior N γ) := by
  unfold matrixPrior
  infer_instance

theorem variance_indexJoin (d N r : ℕ) (γ : ℝ) (i : WeightIndex d N r ⊕ (Fin N × Fin N)) :
    powerVariance d N (r + 1) γ ((indexJoin d N r) i) =
      Sum.elim (powerVariance d N r γ) (fun _ => (N : ℝ) ^ (-γ)) i := by
  rcases i with (ij | (⟨s, i, j⟩ | j)) | ⟨i, j⟩ <;> rfl

/-- Exact independence of the newly appended matrix from the shorter
network, under the original Gaussian parameter prior. -/
theorem measurePreserving_split (d N r : ℕ) (γ : ℝ) :
    MeasurePreserving (split d N r) (powerPrior d N (r + 1) γ)
      ((powerPrior d N r γ).prod (matrixPrior N γ)) := by
  let μ : WeightIndex d N (r + 1) → Measure ℝ :=
    fun i => gaussianReal 0 (powerVariance d N (r + 1) γ i).toNNReal
  have h1 := measurePreserving_piCongrLeft (α := fun _ : WeightIndex d N (r + 1) => ℝ)
    μ (indexJoin d N r)
  have h2 := measurePreserving_sumPiEquivProdPi_symm
    (fun i => μ ((indexJoin d N r) i))
  have h := h1.comp h2
  have hs : MeasurePreserving (split d N r).symm
      ((powerPrior d N r γ).prod (matrixPrior N γ)) (powerPrior d N (r + 1) γ) := by
    convert h using 1
    · rfl
    · simp only [μ, variance_indexJoin, Sum.elim_inl, Sum.elim_inr]
      rfl
    · rfl
  exact MeasurePreserving.symm (split d N r).symm hs

end NeuralGeneralization.NetworkLayerSplit
end
