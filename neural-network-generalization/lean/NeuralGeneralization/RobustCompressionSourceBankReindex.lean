import NeuralGeneralization.RobustCompressionSourceBankGoodEvent

/-! # Feature-index invariance of the actual source-bank event -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.RobustCompressionSourceBank
open RobustCompressionSampling
variable {N m q : ℕ} {X Y : Type*}

/-- Re-enumerating the complete feature family does not change the literal
Gram, mean and covariance success event. -/
theorem sourceBankGood_reindex (e : Y ≃ X)
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (h : X → Fin N → ℝ)
    (a T : ℝ) (I : Fin m → Fin N) :
    sourceBankGood u (fun y => h (e y)) a T I ↔ sourceBankGood u h a T I := by
  constructor
  · intro hg j
    rcases j with ⟨j,k⟩ | (⟨j,x⟩ | ⟨x,y⟩)
    · exact hg (Sum.inl (j,k))
    · simpa only [empiricalMean, populationMean, featureBank, Equiv.apply_symm_apply] using
        hg (Sum.inr (Sum.inl (j,e.symm x)))
    · simpa only [empiricalMean, populationMean, featureBank, Equiv.apply_symm_apply] using
        hg (Sum.inr (Sum.inr (e.symm x,e.symm y)))
  · intro hg j
    rcases j with ⟨j,k⟩ | (⟨j,x⟩ | ⟨x,y⟩)
    · exact hg (Sum.inl (j,k))
    · exact hg (Sum.inr (Sum.inl (j,e x)))
    · exact hg (Sum.inr (Sum.inr (e x,e y)))

/-- In particular the cube enumeration used in the entropy queries agrees
exactly with the cube-indexed canonical source-bank event. -/
theorem sourceBankGood_cube_reindex {d : ℕ}
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (h : ConcreteModel.Cube d → Fin N → ℝ)
    (a T : ℝ) (I : Fin m → Fin N) :
    sourceBankGood u (fun i => h ((Fintype.equivFin (ConcreteModel.Cube d)).symm i)) a T I ↔
      sourceBankGood u h a T I :=
  sourceBankGood_reindex (Fintype.equivFin (ConcreteModel.Cube d)).symm u h a T I

end NeuralGeneralization.RobustCompressionSourceBank
