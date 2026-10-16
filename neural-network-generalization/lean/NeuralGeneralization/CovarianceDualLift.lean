import NeuralGeneralization.ActualBoundedDual
import NeuralGeneralization.SymmetricTilt

/-!
# Symmetric bounded tilts for covariance observables

This instantiates the actual dual-lift theorem on products of bounded
activation coordinates. The reference law is any probability measure on
fields; singular Gaussian laws are included without an invertibility premise.
Symmetrization preserves the actual tilted law and its entropy, not merely
the value of a formal quadratic expression.
-/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.CovarianceDualLift
open BoundedDual BoundedTilt ActualBoundedDual
variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

def parameter (A : X → X → ℝ) (p : X × X) : ℝ := A p.1 p.2

def features (φ : ℝ → ℝ) (p : X × X) (z : X → ℝ) : ℝ :=
  φ (z p.1) * φ (z p.2)

omit [Fintype X] [DecidableEq X] [Nonempty X] in
lemma measurable_features (φ : ℝ → ℝ) (hφ : Measurable φ) (p : X × X) :
    Measurable (features φ p) :=
  (hφ.comp (measurable_pi_apply p.1)).mul (hφ.comp (measurable_pi_apply p.2))

omit [Fintype X] [DecidableEq X] [Nonempty X] in
lemma features_bound (φ : ℝ → ℝ) (hφ : ∀ z, |φ z| ≤ 1)
    (p : X × X) (z : X → ℝ) : |features φ p z| ≤ 1 := by
  rw [features, abs_mul]
  exact (mul_le_mul (hφ _) (hφ _) (abs_nonneg _) zero_le_one).trans_eq (one_mul 1)

omit [DecidableEq X] [Nonempty X] in
lemma potential_parameter (φ : ℝ → ℝ) (A : X → X → ℝ) (z : X → ℝ) :
    potential (features φ) (parameter A) z = SymmetricTilt.quadratic A (fun i => φ (z i)) := by
  simp only [potential, pairing, parameter, features, SymmetricTilt.quadratic,
    Fintype.sum_prod_type, mul_assoc]

omit [DecidableEq X] [Nonempty X] in
lemma potential_symmPart (φ : ℝ → ℝ) (A : X → X → ℝ) :
    potential (features φ) (parameter (SymmetricTilt.symmPart A)) =
      potential (features φ) (parameter A) := by
  funext z
  rw [potential_parameter, potential_parameter, SymmetricTilt.quadratic_symmPart]

omit [DecidableEq X] [Nonempty X] in
lemma mean_symmPart (μ : Measure (X → ℝ)) (φ : ℝ → ℝ) (A : X → X → ℝ) :
    mean μ (features φ) (parameter (SymmetricTilt.symmPart A)) =
      mean μ (features φ) (parameter A) := by
  funext p
  unfold mean
  rw [potential_symmPart]

omit [DecidableEq X] [Nonempty X] in
lemma entropy_symmPart (μ : Measure (X → ℝ)) (φ : ℝ → ℝ) (A : X → X → ℝ) :
    entropy μ (features φ) (parameter (SymmetricTilt.symmPart A)) =
      entropy μ (features φ) (parameter A) := by
  unfold entropy
  rw [potential_symmPart]

/-- The covariance lift has a symmetric matrix parameter with the same
entropy and coordinate accuracy as the abstract bounded-dual lift. -/
theorem exists_symmetric_covariance_lift
    (μ : Measure (X → ℝ)) [IsProbabilityMeasure μ]
    (φ : ℝ → ℝ) (hφmeas : Measurable φ) (hφbound : ∀ z, |φ z| ≤ 1)
    (q : X × X → ℝ) {G K : ℝ} (hG : 0 < G)
    (hrate : ∀ v : X × X → ℝ, entryL1 v ≤ G →
      objective μ (features φ) q v ≤ K) :
    ∃ A : X → X → ℝ, (∀ i j, A i j = A j i) ∧
      SymmetricTilt.entryL1 A ≤ G ∧
      entropy μ (features φ) (parameter A) ≤ K ∧
      maxAbs (q - mean μ (features φ) (parameter A)) ≤ K / G := by
  obtain ⟨v, hv, hentropy, herror⟩ := exists_bounded_dual_lift_of_rate_bound μ
    (features φ) (measurable_features φ hφmeas) (features_bound φ hφbound) q hG hrate
  let A : X → X → ℝ := fun i j => v (i, j)
  have hparameter : parameter A = v := by funext p; cases p; rfl
  refine ⟨SymmetricTilt.symmPart A, SymmetricTilt.symmPart_symmetric A, ?_, ?_, ?_⟩
  · have h := SymmetricTilt.entryL1_symmPart_le A
    have hnorm : SymmetricTilt.entryL1 A = entryL1 v := by
      rw [← SymmetricTilt.flatten_entryL1]
    exact h.trans (hnorm.trans_le hv)
  · rw [entropy_symmPart, hparameter]
    exact hentropy
  · rw [mean_symmPart, hparameter]
    exact herror

end NeuralGeneralization.CovarianceDualLift
end
