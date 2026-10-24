import NeuralGeneralization.BatchTwoActivationInputMoment

/-!
# Iterating heterogeneous peeling over actual normalized layers

Candidate networks can have different widths at every depth. Their states
are defined by the literal row operations; neither their norm bounds nor the
resulting exponential-moment inequality is assumed.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling

variable {U : Type*} [Nonempty U]

def normalizedFamilyState {n : ℕ} (w : ℕ → U → ℕ)
    (ψ : ∀ s p, Fin (w (s+1) p) → UnitActivation)
    (r : ∀ s p, Fin (w (s+1) p) → ℝ)
    (u : ∀ s p, Fin (w (s+1) p) → EuclideanSpace ℝ (Fin (w s p)))
    (input : ∀ p, Fin n → EuclideanSpace ℝ (Fin (w 0 p))) :
    ∀ s p, Fin n → EuclideanSpace ℝ (Fin (w s p))
  | 0 => input
  | s+1 => dependentWeightedArrayLayer (r s)
      (fun p j i => (ψ s p j).val ⟪u s p j, normalizedFamilyState w ψ r u input s p i⟫)

theorem normalizedFamilyState_norm_le {n : ℕ} (w : ℕ → U → ℕ)
    (hw : ∀ s p, 0 < w s p)
    (ψ : ∀ s p, Fin (w (s+1) p) → UnitActivation)
    (r : ∀ s p, Fin (w (s+1) p) → ℝ)
    (u : ∀ s p, Fin (w (s+1) p) → EuclideanSpace ℝ (Fin (w s p)))
    (input : ∀ p, Fin n → EuclideanSpace ℝ (Fin (w 0 p)))
    (hr : ∀ s p, (∑ j, r s p j^2) ≤ 1) (hu : ∀ s p j, ‖u s p j‖ ≤ 1)
    {R : ℝ} (hinput : ∀ p i, ‖input p i‖ ≤ R) (s : ℕ) :
    ∀ p i, ‖normalizedFamilyState w ψ r u input s p i‖ ≤ R := by
  induction s with
  | zero => exact hinput
  | succ s ih =>
    intro p i
    letI : Nonempty (Fin (w (s+1) p)) := ⟨⟨0, hw (s+1) p⟩⟩
    have h := heterogeneousRowLayer_norm_le (ψ s p) (r s p) (u s p)
      (normalizedFamilyState w ψ r u input s p i) (hr s p) (hu s p)
    exact h.trans (ih p i)

def activationPeelingFactor (n q : ℕ) (R a : ℝ) : ℝ :=
  2 * (Fintype.card (ActivationCode q) : ℝ) * Real.exp (a*((n : ℝ)*(4*R/(q : ℝ))))

theorem activationPeelingFactor_nonneg (n q : ℕ) (R a : ℝ) :
    0 ≤ activationPeelingFactor n q R a := by
  unfold activationPeelingFactor
  positivity

/-- A complete finite-depth moment bound for the actual evaluated family,
uniformly over all the widths appearing in that family. -/
theorem normalizedFamilyState_mgf {n q : ℕ} (hq : 0 < q) (w : ℕ → U → ℕ)
    (hw : ∀ s p, 0 < w s p)
    (ψ : ∀ s p, Fin (w (s+1) p) → UnitActivation)
    (r : ∀ s p, Fin (w (s+1) p) → ℝ)
    (u : ∀ s p, Fin (w (s+1) p) → EuclideanSpace ℝ (Fin (w s p)))
    (input : ∀ p, Fin n → EuclideanSpace ℝ (Fin (w 0 p)))
    (hr : ∀ s p, (∑ j, r s p j^2) ≤ 1) (hu : ∀ s p j, ‖u s p j‖ ≤ 1)
    {R : ℝ} (hR : 0 < R) (hinput : ∀ p i, ‖input p i‖ ≤ R)
    (a : ℝ) (ha : 0 ≤ a) (s : ℕ) :
    finiteMean (fun ε : Fin n → Bool =>
      Real.exp (a * dependentVectorProcess (normalizedFamilyState w ψ r u input s) ε)) ≤
      (activationPeelingFactor n q R a)^s *
        finiteMean (fun ε : Fin n → Bool => Real.exp (a * dependentVectorProcess input ε)) := by
  induction s with
  | zero => simp [normalizedFamilyState]
  | succ s ih =>
    letI : ∀ p, Nonempty (Fin (w (s+1) p)) := fun p => ⟨⟨0, hw (s+1) p⟩⟩
    have hprev := normalizedFamilyState_norm_le w hw ψ r u input hr hu hinput s
    have hstep := dependentHeterogeneousRowLayer_exp_peeling hq (ψ s) (r s) (u s)
      (normalizedFamilyState w ψ r u input s) (hr s) (hu s) hR hprev a ha
    change finiteMean (fun ε : Fin n → Bool =>
      Real.exp (a * dependentVectorProcess (normalizedFamilyState w ψ r u input (s+1)) ε)) ≤
        activationPeelingFactor n q R a *
          finiteMean (fun ε : Fin n → Bool =>
            Real.exp (a * dependentVectorProcess (normalizedFamilyState w ψ r u input s) ε)) at hstep
    have hmul := mul_le_mul_of_nonneg_left ih (activationPeelingFactor_nonneg n q R a)
    apply (hstep.trans hmul).trans_eq
    rw [pow_succ]
    ring

end NeuralGeneralization.BatchTwoActivation
