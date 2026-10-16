import NeuralGeneralization.NetworkLayerSplit

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped NNReal
namespace NeuralGeneralization.NetworkInputSplit
open ConcreteModel

def indexJoin (d N : ℕ) : (Fin N × Fin (d + 1)) ⊕ Fin N ≃ WeightIndex d N 0 where
  toFun
    | .inl ij => .inl ij
    | .inr j => .inr (.inr j)
  invFun
    | .inl ij => .inl ij
    | .inr (.inl (s, _, _)) => Fin.elim0 s
    | .inr (.inr j) => .inr j
  left_inv := by intro i; cases i <;> rfl
  right_inv := by
    intro i
    rcases i with ij | (⟨s,i,j⟩ | j)
    · rfl
    · exact Fin.elim0 s
    · rfl

def split (d N : ℕ) : Weights d N 0 ≃ᵐ
    (Fin N × Fin (d + 1) → ℝ) × (Fin N → ℝ) :=
  ((MeasurableEquiv.piCongrLeft (fun _ : WeightIndex d N 0 => ℝ) (indexJoin d N)).symm).trans
    (MeasurableEquiv.sumPiEquivProdPi (fun _ : (Fin N × Fin (d + 1)) ⊕ Fin N => ℝ))

def inputPrior (d N : ℕ) (γ : ℝ) : Measure (Fin N × Fin (d + 1) → ℝ) :=
  Measure.pi (fun _ => gaussianReal 0 ((N : ℝ) ^ (1 - γ) / d).toNNReal)

def readoutPrior (N : ℕ) (γ : ℝ) : Measure (Fin N → ℝ) :=
  Measure.pi (fun _ => gaussianReal 0 ((N : ℝ) ^ (-γ - 1)).toNNReal)

instance inputPrior_probability (d N : ℕ) (γ : ℝ) : IsProbabilityMeasure (inputPrior d N γ) := by
  unfold inputPrior
  infer_instance

instance readoutPrior_probability (N : ℕ) (γ : ℝ) : IsProbabilityMeasure (readoutPrior N γ) := by
  unfold readoutPrior
  infer_instance

theorem measurePreserving_split (d N : ℕ) (γ : ℝ) :
    MeasurePreserving (split d N) (powerPrior d N 0 γ)
      ((inputPrior d N γ).prod (readoutPrior N γ)) := by
  let μ : WeightIndex d N 0 → Measure ℝ :=
    fun i => gaussianReal 0 (powerVariance d N 0 γ i).toNNReal
  have h1 := measurePreserving_piCongrLeft (α := fun _ : WeightIndex d N 0 => ℝ) μ (indexJoin d N)
  have h2 := measurePreserving_sumPiEquivProdPi_symm (fun i => μ ((indexJoin d N) i))
  have hs : MeasurePreserving (split d N).symm
      ((inputPrior d N γ).prod (readoutPrior N γ)) (powerPrior d N 0 γ) := h1.comp h2
  exact MeasurePreserving.symm (split d N).symm hs

end NeuralGeneralization.NetworkInputSplit
end
