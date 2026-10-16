import NeuralGeneralization.MeanFieldFunctionClass
import NeuralGeneralization.TowerCompression

/-! Actual finite tilted towers belong to the counted mean-field class. -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.MeanFieldFunctionClass
open ConcreteModel MeanFieldBudgets GaussianAngularPrice GaussianFieldTilt
open TanhDifferential GaussianTowerConstruction

/-- Every exact ideal tower with the proved backward-budget maximum and a
suitable dual readout has a representative in the fixed counted class. -/
theorem mem_functions_of_tower {d r K : ℕ} (hd : 0 < d) (hK : 0 < K)
    (R Γ : ℕ → Cube d → Cube d → ℝ) (β : Cube d → ℝ) (f : BooleanFunction d)
    (hbase : ∀ x y, gram (R 0) x y = gram (inputMatrix d) x y)
    (hstep : ∀ s, s < r → ∀ x y, gram (R (s+1)) x y = tiltedMoment (R s) (Γ s) x y)
    (hΓ : ∀ s, s ≤ r → couplingMass (Γ s) ≤ (maxTiltBudget r K : ℝ))
    (hβ : (∑ x, |β x|) ≤ 4*(K : ℝ))
    (hmargin : ∀ x, (7/8 : ℝ) ≤ labelReal (f x)*
      ∑ y, β y*tiltedMoment (R r) (Γ r) x y) :
    f ∈ functions d r K := by
  apply (mem_functions f).mpr
  exact TowerCompression.exists_compressed_tower_network hd hK R Γ β f hbase hstep hΓ hβ hmargin

end NeuralGeneralization.MeanFieldFunctionClass
