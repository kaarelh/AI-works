import NeuralGeneralization.IdealTowerTransport
import NeuralGeneralization.MeanFieldReadout
import NeuralGeneralization.MeanFieldTowerClass

/-! The full deterministic mean-field compression bridge: actual network,
actual covariance certificates, actual tilted Gaussian tower, then the checked
finite class of bounded ordinary networks. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.MeanFieldCompression
open ConcreteModel GaussianAngularPrice GaussianFieldTilt CovarianceFactor TanhDifferential
open MeanFieldBudgets IdealTowerTransport MeanFieldReadout MeanFieldFunctionClass

/-- Every actual half-margin network with the bounded readout and covariance
certificates belongs to the explicitly counted polynomial-size class. -/
theorem mem_functions_of_covariance_certificates
    {d N r K : ℕ} (hd : 0 < d) (hN : 0 < N) (hK : 0 < K)
    (w : Weights d N r) (f : BooleanFunction d)
    {J : ℕ → Type*} [∀ s, Fintype (J s)]
    (A : ∀ s, Cube d → J s → ℝ) (Γ : ℕ → Cube d → Cube d → ℝ)
    (hmargin : w ∈ marginEvent Real.tanh (1 / 2) f)
    (henergy : (N : ℝ) * (∑ i, w (.inr (.inr i)) ^ 2) ≤ (K : ℝ))
    (hbase : ∀ x y, gram (A 0) x y = gram (GaussianTowerConstruction.inputMatrix d) x y)
    (hfinal : ∀ x y, gram (A (r + 1)) x y = finalCovariance Real.tanh w x y)
    (hΓ : ∀ s, s ≤ r → couplingMass (Γ s) ≤ (layerBudget r K (s + 1) : ℝ))
    (hcert : ∀ s, s ≤ r → ∀ x y,
      |gram (A (s + 1)) x y - tiltedMoment (A s) (Γ s) x y| ≤
        (K : ℝ) / (layerBudget r K (s + 1) : ℝ)) :
    f ∈ functions d r K := by
  obtain ⟨A₀, hA₀⟩ := gram_has_square_factor (A 0)
  let R := idealTower A₀ Γ
  obtain ⟨β, hβ, hβmargin⟩ := exists_unit_margin_dual hN w f hmargin henergy
  have hcov : ∀ x y, |finalCovariance Real.tanh w x y - tiltedMoment (R r) (Γ r) x y| ≤
      1 / (32 * (K : ℝ)) := by
    intro x y
    rw [← hfinal x y]
    exact idealTower_terminal_error A A₀ Γ hK hA₀ hΓ hcert x y
  have hmargin' := transported_margin (finalCovariance Real.tanh w)
    (tiltedMoment (R r) (Γ r)) β f (by exact_mod_cast hK) hβ hβmargin hcov
  apply mem_functions_of_tower hd hK R Γ β f
  · intro x y
    exact (hA₀ x y).trans (hbase x y)
  · intro s hs x y
    exact idealTower_step A₀ Γ s x y
  · intro s hs
    apply (hΓ s hs).trans
    exact_mod_cast layerBudget_le_max r K (show 1 ≤ s + 1 by omega)
  · exact hβ
  · exact hmargin'

end NeuralGeneralization.MeanFieldCompression
