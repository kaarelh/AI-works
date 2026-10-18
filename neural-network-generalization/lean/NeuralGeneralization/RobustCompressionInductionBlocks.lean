import NeuralGeneralization.RobustCompressionBlockMoments
import NeuralGeneralization.RobustCompressionInductionEntropy

/-! # Exact original Gaussian blocks for the depth recursion

The remaining original matrices and readout use one flat finite coordinate
index. This is measurably equivalent to the usual tuple of matrices and avoids
any independence assumption about the posterior. Independence below is proved
only for the actual standardized reference prior.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustCompressionBlockMoments

abbrev FirstBlock (d N : ℕ) := Fin N × Fin (d+1) → ℝ
abbrev InternalBlock (N : ℕ) := Fin N × Fin N → ℝ
abbrev FutureIndex (N r : ℕ) := (Fin r × Fin N × Fin N) ⊕ Fin N
abbrev FutureWeights (N r : ℕ) := FutureIndex N r → ℝ

def firstBlockPrior (d N : ℕ) : Measure (FirstBlock d N) :=
  Measure.pi (fun _ => gaussianReal 0 1)
def internalBlockPrior (N : ℕ) : Measure (InternalBlock N) :=
  Measure.pi (fun _ => gaussianReal 0 1)
def futurePrior (N r : ℕ) : Measure (FutureWeights N r) :=
  Measure.pi (fun _ => gaussianReal 0 1)

instance firstBlockPrior_probability (d N : ℕ) : IsProbabilityMeasure (firstBlockPrior d N) := by
  unfold firstBlockPrior
  infer_instance
instance internalBlockPrior_probability (N : ℕ) : IsProbabilityMeasure (internalBlockPrior N) := by
  unfold internalBlockPrior
  infer_instance
instance futurePrior_probability (N r : ℕ) : IsProbabilityMeasure (futurePrior N r) := by
  unfold futurePrior
  infer_instance

def splitFirst (d N r : ℕ) : Weights d N r ≃ᵐ FirstBlock d N × FutureWeights N r :=
  MeasurableEquiv.sumPiEquivProdPi (fun _ : WeightIndex d N r => ℝ)

theorem standardized_splitFirst_law (d N r : ℕ) :
    (Measure.pi (fun _ : WeightIndex d N r => gaussianReal 0 1)).map (splitFirst d N r) =
      (firstBlockPrior d N).prod (futurePrior N r) :=
  (measurePreserving_sumPiEquivProdPi (fun _ : WeightIndex d N r => gaussianReal 0 1)).map_eq

theorem actual_standardized_splitFirst_law {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ) :
    (smallPrior d N r σ).map (fun w => splitFirst d N r (standardizedWeights σ w)) =
      (firstBlockPrior d N).prod (futurePrior N r) := by
  change (smallPrior d N r σ).map ((splitFirst d N r) ∘ standardizedWeights σ) = _
  rw [← Measure.map_map (splitFirst d N r).measurable (measurable_standardizedWeights σ),
    smallPrior_standardized hd hN hσ,standardized_splitFirst_law]

def futureIndexJoin (N r : ℕ) : (Fin N × Fin N) ⊕ FutureIndex N r ≃ FutureIndex N (r+1) where
  toFun
    | .inl (i,j) => .inl (0,i,j)
    | .inr (.inl (s,i,j)) => .inl (s.succ,i,j)
    | .inr (.inr i) => .inr i
  invFun
    | .inl (s,i,j) => Fin.cases (.inl (i,j)) (fun k => .inr (.inl (k,i,j))) s
    | .inr i => .inr (.inr i)
  left_inv := by
    intro i
    rcases i with ⟨i,j⟩ | (⟨s,i,j⟩ | i) <;> simp
  right_inv := by
    intro i
    rcases i with ⟨s,i,j⟩ | i
    · induction s using Fin.cases <;> simp
    · rfl

def splitFuture (N r : ℕ) : FutureWeights N (r+1) ≃ᵐ
    InternalBlock N × FutureWeights N r :=
  ((MeasurableEquiv.piCongrLeft (fun _ : FutureIndex N (r+1) => ℝ)
    (futureIndexJoin N r)).symm).trans
    (MeasurableEquiv.sumPiEquivProdPi (fun _ : (Fin N × Fin N) ⊕ FutureIndex N r => ℝ))

@[simp] theorem splitFuture_current (N r : ℕ) (w : FutureWeights N (r+1)) (i j : Fin N) :
    (splitFuture N r w).1 (i,j) = w (Sum.inl (0,i,j)) := rfl

@[simp] theorem splitFuture_later (N r : ℕ) (w : FutureWeights N (r+1))
    (s : Fin r) (i j : Fin N) :
    (splitFuture N r w).2 (Sum.inl (s,i,j)) = w (Sum.inl (s.succ,i,j)) := rfl

@[simp] theorem splitFuture_readout (N r : ℕ) (w : FutureWeights N (r+1)) (i : Fin N) :
    (splitFuture N r w).2 (Sum.inr i) = w (Sum.inr i) := rfl

/-- Exact Gaussian independence of the current original block and every
remaining original coefficient under the reference law. -/
theorem splitFuture_reference (N r : ℕ) :
    (futurePrior N (r+1)).map (splitFuture N r) =
      (internalBlockPrior N).prod (futurePrior N r) := by
  let μ : FutureIndex N (r+1) → Measure ℝ := fun _ => gaussianReal 0 1
  have h1 := measurePreserving_piCongrLeft (α := fun _ : FutureIndex N (r+1) => ℝ)
    μ (futureIndexJoin N r)
  have h2 := measurePreserving_sumPiEquivProdPi_symm
    (fun i => μ (futureIndexJoin N r i))
  have hs : MeasurePreserving (splitFuture N r).symm
      ((internalBlockPrior N).prod (futurePrior N r)) (futurePrior N (r+1)) := h1.comp h2
  exact (MeasurePreserving.symm (splitFuture N r).symm hs).map_eq

/-- Terminal future: only the original standardized scalar readout remains. -/
theorem terminal_readout_reference (N : ℕ) :
    (futurePrior N 0).map (fun w i => w (Sum.inr i)) =
      Measure.pi (fun _ : Fin N => gaussianReal 0 1) :=
  productGaussian_map_subfamily 1 Sum.inr Sum.inr_injective

end NeuralGeneralization.RobustCompressionInduction
