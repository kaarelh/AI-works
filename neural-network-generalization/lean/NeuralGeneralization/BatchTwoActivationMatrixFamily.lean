import NeuralGeneralization.BatchTwoActivationDepthIteration
import NeuralGeneralization.BatchTwoActivationRescaling

/-!
# Matrix layers represented by the normalized family

The row length is absorbed into an auxiliary activation exactly. Thus the
width-free moment argument applies to ordinary matrices with Frobenius norm
at most one, including nonhomogeneous activations.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling

variable {U : Type*} [Nonempty U]

def matrixFamilyState {n : ℕ} (w : ℕ → U → ℕ)
    (φ : ∀ s p, Fin (w (s+1) p) → UnitActivation)
    (A : ∀ s p, Fin (w (s+1) p) → EuclideanSpace ℝ (Fin (w s p)))
    (input : ∀ p, Fin n → EuclideanSpace ℝ (Fin (w 0 p))) :
    ∀ s p, Fin n → EuclideanSpace ℝ (Fin (w s p))
  | 0 => input
  | s+1 => fun p i => WithLp.toLp 2 (fun j =>
      (φ s p j).val ⟪A s p j, matrixFamilyState w φ A input s p i⟫)

def matrixRowActivation (w : ℕ → U → ℕ)
    (φ : ∀ s p, Fin (w (s+1) p) → UnitActivation)
    (A : ∀ s p, Fin (w (s+1) p) → EuclideanSpace ℝ (Fin (w s p)))
    (s : ℕ) (p : U) (j : Fin (w (s+1) p)) : UnitActivation :=
  rescaledUnitActivation (φ s p j) ‖A s p j‖ (norm_nonneg _)

theorem matrixFamilyState_eq_normalized {n : ℕ} (w : ℕ → U → ℕ)
    (φ : ∀ s p, Fin (w (s+1) p) → UnitActivation)
    (A : ∀ s p, Fin (w (s+1) p) → EuclideanSpace ℝ (Fin (w s p)))
    (input : ∀ p, Fin n → EuclideanSpace ℝ (Fin (w 0 p))) (s : ℕ) :
    matrixFamilyState w φ A input s =
      normalizedFamilyState w (matrixRowActivation w φ A)
        (fun s p j => ‖A s p j‖) (fun s p j => unitDirection (A s p j)) input s := by
  induction s with
  | zero => rfl
  | succ s ih =>
    funext p i
    apply PiLp.ext
    intro j
    change (φ s p j).val ⟪A s p j, matrixFamilyState w φ A input s p i⟫ = _
    rw [unitActivation_inner_normalized, ih]
    rfl

theorem matrixFamilyState_norm_le {n : ℕ} (w : ℕ → U → ℕ)
    (hw : ∀ s p, 0 < w s p)
    (φ : ∀ s p, Fin (w (s+1) p) → UnitActivation)
    (A : ∀ s p, Fin (w (s+1) p) → EuclideanSpace ℝ (Fin (w s p)))
    (input : ∀ p, Fin n → EuclideanSpace ℝ (Fin (w 0 p)))
    (hA : ∀ s p, (∑ j, ‖A s p j‖^2) ≤ 1)
    {R : ℝ} (hinput : ∀ p i, ‖input p i‖ ≤ R) (s : ℕ) :
    ∀ p i, ‖matrixFamilyState w φ A input s p i‖ ≤ R := by
  rw [matrixFamilyState_eq_normalized]
  exact normalizedFamilyState_norm_le w hw _ _ _ input hA
    (fun s p j => norm_unitDirection_le _) hinput s

theorem matrixFamilyState_mgf {n q : ℕ} (hq : 0 < q) (w : ℕ → U → ℕ)
    (hw : ∀ s p, 0 < w s p)
    (φ : ∀ s p, Fin (w (s+1) p) → UnitActivation)
    (A : ∀ s p, Fin (w (s+1) p) → EuclideanSpace ℝ (Fin (w s p)))
    (input : ∀ p, Fin n → EuclideanSpace ℝ (Fin (w 0 p)))
    (hA : ∀ s p, (∑ j, ‖A s p j‖^2) ≤ 1)
    {R : ℝ} (hR : 0 < R) (hinput : ∀ p i, ‖input p i‖ ≤ R)
    (a : ℝ) (ha : 0 ≤ a) (s : ℕ) :
    finiteMean (fun ε : Fin n → Bool =>
      Real.exp (a * dependentVectorProcess (matrixFamilyState w φ A input s) ε)) ≤
      (activationPeelingFactor n q R a)^s *
        finiteMean (fun ε : Fin n → Bool => Real.exp (a * dependentVectorProcess input ε)) := by
  rw [matrixFamilyState_eq_normalized]
  exact normalizedFamilyState_mgf hq w hw _ _ _ input hA
    (fun s p j => norm_unitDirection_le _) hR hinput a ha s

end NeuralGeneralization.BatchTwoActivation
