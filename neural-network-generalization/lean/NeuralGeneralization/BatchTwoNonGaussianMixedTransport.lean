import NeuralGeneralization.BatchTwoNonGaussianTower
import NeuralGeneralization.IdealTowerTransport
import NeuralGeneralization.MeanFieldReadout

/-! Transport for the mixed ideal covariance tower. The first reference is
its actual non-Gaussian tilt; later references are Gaussian tilts with the
same backward error budgets. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel GaussianAngularPrice GaussianFieldTilt MeanFieldBudgets
open IdealTowerTransport MeanFieldReadout GaussianTowerConstruction TanhDifferential
variable {X : Type*} [Fintype X] [DecidableEq X]

def mixedTower (R₀ : X → X → ℝ) (Γ : ℕ → X → X → ℝ) : ℕ → X → X → ℝ
  | 0 => R₀
  | s+1 => nextFactor (mixedTower R₀ Γ s) (Γ (s+1))

theorem mixedTower_step (R₀ : X → X → ℝ) (Γ : ℕ → X → X → ℝ) (s : ℕ) (x y : X) :
    gram (mixedTower R₀ Γ (s+1)) x y=tiltedMoment (mixedTower R₀ Γ s) (Γ (s+1)) x y :=
  nextFactor_spec _ _ _ _

theorem mixedTower_error {J : ℕ → Type*} [∀ s, Fintype (J s)]
    (A : ∀ s, X → J s → ℝ) (R₀ : X → X → ℝ) (Γ : ℕ → X → X → ℝ)
    {r K : ℕ} (hK : 0 < K)
    (hbase : ∀ x y, |gram (A 1) x y-gram R₀ x y| ≤
      (K : ℝ)/(layerBudget r K 1 : ℝ))
    (hΓ : ∀ s, s ≤ r → couplingMass (Γ s) ≤ (layerBudget r K (s+1) : ℝ))
    (hcert : ∀ s, 1 ≤ s → s ≤ r → ∀ x y,
      |gram (A (s+1)) x y-tiltedMoment (A s) (Γ s) x y| ≤
        (K : ℝ)/(layerBudget r K (s+1) : ℝ)) :
    ∀ s, s ≤ r → ∀ x y,
      |gram (A (s+1)) x y-gram (mixedTower R₀ Γ s) x y| ≤
        (s+1 : ℝ)*(K : ℝ)/(layerBudget r K (s+1) : ℝ) := by
  intro s
  induction s with
  | zero =>
    intro hs x y
    simpa only [mixedTower,Nat.zero_add,Nat.cast_zero,zero_add,one_mul] using hbase x y
  | succ s ih =>
    intro hs x y
    have hsr : s+1 ≤ r := hs
    have hg : (0 : ℝ) < layerBudget r K (s+2) := by exact_mod_cast layerBudget_pos r hK (s+2)
    have he : 0 ≤ (s+1 : ℝ)*(K : ℝ)/(layerBudget r K (s+1) : ℝ) := by positivity
    have hp := tiltedMoment_stability (mixedTower R₀ Γ s) (A (s+1)) (Γ (s+1)) x y hg.le he
      (hΓ (s+1) hsr) (ih (by omega))
    rw [mixedTower_step]
    apply (abs_sub_le _ _ _).trans
    apply (add_le_add (hcert (s+1) (by omega) hsr x y) hp).trans
    have hback : (layerBudget r K (s+1) : ℝ)=
        8*(1+(layerBudget r K (s+2) : ℝ))^2*(layerBudget r K (s+2) : ℝ) := by
      exact_mod_cast layerBudget_backward (r := r) (K := K) (s := s+1) (by omega)
    rw [hback]
    have hb : 8*(1+(layerBudget r K (s+2) : ℝ))^2 ≠ 0 := by positivity
    apply le_of_eq
    push_cast
    field_simp
    <;> ring

theorem mixedTower_terminal_error {J : ℕ → Type*} [∀ s, Fintype (J s)]
    (A : ∀ s, X → J s → ℝ) (R₀ : X → X → ℝ) (Γ : ℕ → X → X → ℝ)
    {r K : ℕ} (hK : 0 < K)
    (hbase : ∀ x y, |gram (A 1) x y-gram R₀ x y| ≤
      (K : ℝ)/(layerBudget r K 1 : ℝ))
    (hΓ : ∀ s, s ≤ r → couplingMass (Γ s) ≤ (layerBudget r K (s+1) : ℝ))
    (hcert : ∀ s, 1 ≤ s → s ≤ r → ∀ x y,
      |gram (A (s+1)) x y-tiltedMoment (A s) (Γ s) x y| ≤
        (K : ℝ)/(layerBudget r K (s+1) : ℝ)) (x y : X) :
    |gram (A (r+1)) x y-gram (mixedTower R₀ Γ r) x y| ≤ 1/(32*(K : ℝ)) := by
  have ht := mixedTower_error A R₀ Γ hK hbase hΓ hcert r le_rfl x y
  rw [layerBudget_terminal] at ht
  have he : (r+1 : ℝ)*(K : ℝ)/((32*(r+1)*K^2 : ℕ) : ℝ)=1/(32*(K : ℝ)) := by
    have hKR : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
    have hr : (r+1 : ℝ) ≠ 0 := by positivity
    push_cast
    field_simp
  rwa [he] at ht

/-- Closed finite reconstruction from the paper's mixed certificates. -/
theorem exists_compressed_of_mixed_certificates (ν : CoordinateLaw)
    {d N r K : ℕ} (hd : 0 < d) (hN : 0 < N) (hK : 0 < K)
    (w : Weights d N r) (f : BooleanFunction d)
    {J : ℕ → Type*} [∀ s, Fintype (J s)]
    (A : ∀ s, Cube d → J s → ℝ) (Γ : ℕ → Cube d → Cube d → ℝ)
    (hmargin : w ∈ marginEvent Real.tanh (1/2) f)
    (henergy : (N : ℝ)*(∑ i, w (.inr (.inr i))^2) ≤ (K : ℝ))
    (hfinal : ∀ x y, gram (A (r+1)) x y=finalCovariance Real.tanh w x y)
    (hΓ : ∀ s, s ≤ r → couplingMass (Γ s) ≤ (layerBudget r (2*K) (s+1) : ℝ))
    (hfirst : ∀ x y, |gram (A 1) x y-actualTiltedMoment ν (inputMatrix d) (Γ 0) x y| ≤
      (K : ℝ)/(layerBudget r (2*K) 1 : ℝ))
    (hcert : ∀ s, 1 ≤ s → s ≤ r → ∀ x y,
      |gram (A (s+1)) x y-tiltedMoment (A s) (Γ s) x y| ≤
        2*(K : ℝ)/(layerBudget r (2*K) (s+1) : ℝ)) :
    ∃ v : Weights d (TowerCompression.compressedWidth d r K (maxTiltBudget r (2*K))) r,
      v ∈ marginEvent Real.tanh (1/2) f ∧
        boundedWeights (mixedCompressedBound ν d r K (maxTiltBudget r (2*K))) v := by
  obtain ⟨R₀,hR₀⟩ := actualTiltedMoment_has_gram_factor ν (inputMatrix d) (Γ 0)
  let R := mixedTower R₀ Γ
  have hKK : 0 < 2*K := by omega
  have hbase : ∀ x y, |gram (A 1) x y-gram R₀ x y| ≤
      ((2*K : ℕ) : ℝ)/(layerBudget r (2*K) 1 : ℝ) := by
    intro x y
    rw [hR₀]
    exact (hfirst x y).trans (div_le_div_of_nonneg_right (by push_cast; nlinarith [Nat.cast_nonneg K (α := ℝ)]) (by positivity))
  have hcert' : ∀ s, 1 ≤ s → s ≤ r → ∀ x y,
      |gram (A (s+1)) x y-tiltedMoment (A s) (Γ s) x y| ≤
        ((2*K : ℕ) : ℝ)/(layerBudget r (2*K) (s+1) : ℝ) := by
    simpa only [Nat.cast_mul,Nat.cast_ofNat] using hcert
  obtain ⟨β,hβ,hβmargin⟩ := exists_unit_margin_dual hN w f hmargin henergy
  have hcov : ∀ x y, |finalCovariance Real.tanh w x y-gram (R r) x y| ≤ 1/(32*(K : ℝ)) := by
    intro x y
    rw [←hfinal]
    have ht := mixedTower_terminal_error A R₀ Γ hKK hbase hΓ hcert' x y
    apply ht.trans
    apply one_div_le_one_div_of_le (by positivity : (0 : ℝ) < 32*K)
    push_cast
    nlinarith [Nat.cast_nonneg K (α := ℝ)]
  have hm := transported_margin (finalCovariance Real.tanh w) (gram (R r)) β f
    (by exact_mod_cast hK) hβ hβmargin hcov
  apply exists_mixed_compressed_network ν hd hK (fun s => gram (R s)) R Γ β f
  · exact hR₀
  · intro s x y
    rfl
  · intro s hs x y
    exact mixedTower_step R₀ Γ s x y
  · intro s hs
    exact (hΓ s hs).trans (by exact_mod_cast layerBudget_le_max r (2*K) (show 1 ≤ s+1 by omega))
  · exact hβ
  · exact hm

end NeuralGeneralization.BatchTwoNonGaussian
