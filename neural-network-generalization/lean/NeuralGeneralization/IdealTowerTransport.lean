import NeuralGeneralization.CovarianceFactor
import NeuralGeneralization.MeanFieldBudgets
import NeuralGeneralization.TowerCompression

/-! Deterministic transport from actual empirical covariance certificates to
an ideal tilted Gaussian tower, with the concrete backward budgets. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.IdealTowerTransport
open ConcreteModel GaussianAngularPrice GaussianFieldTilt CovarianceFactor TanhDifferential
open MeanFieldBudgets
variable {X : Type*} [Fintype X] [DecidableEq X]

def nextFactor (A : X → X → ℝ) (Γ : X → X → ℝ) : X → X → ℝ :=
  Classical.choose (tiltedMoment_has_gram_factor A Γ)

theorem nextFactor_spec (A : X → X → ℝ) (Γ : X → X → ℝ) (x y : X) :
    gram (nextFactor A Γ) x y = tiltedMoment A Γ x y :=
  Classical.choose_spec (tiltedMoment_has_gram_factor A Γ) x y

def idealTower (A₀ : X → X → ℝ) (Γ : ℕ → X → X → ℝ) : ℕ → X → X → ℝ
  | 0 => A₀
  | s + 1 => nextFactor (idealTower A₀ Γ s) (Γ s)

@[simp] theorem idealTower_zero (A₀ : X → X → ℝ) (Γ : ℕ → X → X → ℝ) :
    idealTower A₀ Γ 0 = A₀ := rfl

theorem idealTower_step (A₀ : X → X → ℝ) (Γ : ℕ → X → X → ℝ) (s : ℕ) (x y : X) :
    gram (idealTower A₀ Γ (s + 1)) x y = tiltedMoment (idealTower A₀ Γ s) (Γ s) x y :=
  nextFactor_spec _ _ _ _

/-- The actual empirical certificate errors are weighted by their own
backward budgets, so no dimension factor or exponential tilt density is lost. -/
theorem idealTower_error {J : ℕ → Type*} [∀ s, Fintype (J s)]
    (A : ∀ s, X → J s → ℝ) (A₀ : X → X → ℝ) (Γ : ℕ → X → X → ℝ)
    {r K : ℕ} (hK : 0 < K)
    (hbase : ∀ x y, gram A₀ x y = gram (A 0) x y)
    (hΓ : ∀ s, s ≤ r → couplingMass (Γ s) ≤ (layerBudget r K (s + 1) : ℝ))
    (hcert : ∀ s, s ≤ r → ∀ x y,
      |gram (A (s + 1)) x y - tiltedMoment (A s) (Γ s) x y| ≤
        (K : ℝ) / (layerBudget r K (s + 1) : ℝ)) :
    ∀ s, s ≤ r + 1 → ∀ x y,
      |gram (A s) x y - gram (idealTower A₀ Γ s) x y| ≤
        (s : ℝ) * (K : ℝ) / (layerBudget r K s : ℝ) := by
  intro s
  induction s with
  | zero =>
    intro hs x y
    simp only [idealTower_zero, hbase, sub_self, abs_zero, Nat.cast_zero, zero_mul, zero_div]
    exact le_rfl
  | succ s ih =>
    intro hs x y
    have hsr : s ≤ r := by omega
    have hss : s < r + 1 := by omega
    have hg : (0 : ℝ) < layerBudget r K (s + 1) := by exact_mod_cast layerBudget_pos r hK (s + 1)
    have he : 0 ≤ (s : ℝ) * (K : ℝ) / (layerBudget r K s : ℝ) := by positivity
    have hp := tiltedMoment_stability (idealTower A₀ Γ s) (A s) (Γ s) x y hg.le he
      (hΓ s hsr) (ih (by omega))
    rw [idealTower_step]
    apply (abs_sub_le _ _ _).trans
    apply (add_le_add (hcert s hsr x y) hp).trans
    have hback : (layerBudget r K s : ℝ) =
        8 * (1 + (layerBudget r K (s + 1) : ℝ)) ^ 2 * (layerBudget r K (s + 1) : ℝ) := by
      exact_mod_cast layerBudget_backward (K := K) hss
    rw [hback]
    have hb : 8 * (1 + (layerBudget r K (s + 1) : ℝ)) ^ 2 ≠ 0 := by positivity
    apply le_of_eq
    push_cast
    field_simp
    <;> ring

/-- Terminal error of the exact ideal tower, with no analytic hypothesis. -/
theorem idealTower_terminal_error {J : ℕ → Type*} [∀ s, Fintype (J s)]
    (A : ∀ s, X → J s → ℝ) (A₀ : X → X → ℝ) (Γ : ℕ → X → X → ℝ)
    {r K : ℕ} (hK : 0 < K)
    (hbase : ∀ x y, gram A₀ x y = gram (A 0) x y)
    (hΓ : ∀ s, s ≤ r → couplingMass (Γ s) ≤ (layerBudget r K (s + 1) : ℝ))
    (hcert : ∀ s, s ≤ r → ∀ x y,
      |gram (A (s + 1)) x y - tiltedMoment (A s) (Γ s) x y| ≤
        (K : ℝ) / (layerBudget r K (s + 1) : ℝ)) (x y : X) :
    |gram (A (r + 1)) x y - tiltedMoment (idealTower A₀ Γ r) (Γ r) x y| ≤
      1 / (32 * (K : ℝ)) := by
  have h := idealTower_error A A₀ Γ hK hbase hΓ hcert (r + 1) le_rfl x y
  rw [idealTower_step, layerBudget_terminal] at h
  have heq : ((r + 1 : ℕ) : ℝ) * (K : ℝ) / ((32 * (r + 1) * K ^ 2 : ℕ) : ℝ) =
      1 / (32 * (K : ℝ)) := by
    have hKR : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
    have hr : (r + 1 : ℝ) ≠ 0 := by positivity
    push_cast
    field_simp
  rwa [heq] at h

end NeuralGeneralization.IdealTowerTransport
