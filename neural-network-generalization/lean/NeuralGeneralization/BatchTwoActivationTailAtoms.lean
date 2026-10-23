import NeuralGeneralization.BatchTwoActivationBulkCovariance

/-!
# Exact normalized tail-atom representation

Tail atoms use unit Euclidean source vectors. Their auxiliary scalar
activations may vary with the source radius; this does not change their global
Lipschitz bound. This is an auxiliary representation and does not alter the
activation used by the Bayesian learner.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation

variable {I : Type*} [Fintype I] {n : ℕ}

def tailActivation (φ : ℝ→ℝ) (δ t : ℝ) : ℝ := φ (δ*t)/δ

theorem tailActivation_admissible {φ : ℝ→ℝ} {ℓ δ : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hδ : 0≤δ) :
    zeroLipschitzActivation ℓ (tailActivation φ δ) := by
  constructor
  · simp [tailActivation,hφ.1]
  · intro x y
    by_cases hz : δ=0
    · have hℓ : 0≤ℓ := (abs_nonneg (φ 1-φ 0)).trans (by simpa using hφ.2 1 0)
      simpa [tailActivation,hz] using mul_nonneg hℓ (abs_nonneg (x-y))
    have hp : 0<δ := lt_of_le_of_ne hδ (Ne.symm hz)
    have h := hφ.2 (δ*x) (δ*y)
    rw [show δ*x-δ*y=δ*(x-y) by ring,abs_mul,abs_of_pos hp] at h
    simp only [tailActivation,←sub_div,abs_div,abs_of_pos hp]
    exact (div_le_iff₀ hp).mpr (by nlinarith)

theorem tailActivation_reconstruct {φ : ℝ→ℝ} {ℓ δ : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (x : ℝ) :
    φ (δ*x)=δ*tailActivation φ δ x := by
  by_cases hz : δ=0
  · simp [tailActivation,hz,hφ.1]
  · simp [tailActivation,mul_div_cancel₀ _ hz]

theorem linearObservation_smul (a : I→Fin n→ℝ) (t : ℝ)
    (x : EuclideanSpace ℝ (Fin n)) (i : I) :
    linearObservation a (t • x) i=t*linearObservation a x i := by
  simp only [linearObservation,PiLp.smul_apply,smul_eq_mul,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem tail_atom_reconstruction (a : I→Fin n→ℝ) {φ : ℝ→ℝ} {ℓ : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (u : EuclideanSpace ℝ (Fin n)) (i : I) :
    φ (linearObservation a u i)=‖u‖*
      tailActivation φ ‖u‖ (linearObservation a (unitDirection u) i) := by
  rw [←tailActivation_reconstruct hφ]
  rw [←linearObservation_smul,norm_smul_unitDirection]

/-- Exact covariance equality and a radius-squared mixture budget. -/
theorem tail_covariance_representation {J : Type*} [Fintype J]
    (a : I→Fin n→ℝ) {φ : ℝ→ℝ} {ℓ A : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ)
    (u : J→EuclideanSpace ℝ (Fin n)) (w : J→ℝ)
    (hw : ∀j, 0≤w j) (hw1 : ∀j, w j≤1)
    (henergy : (∑ j, ‖u j‖^2)≤A) :
    (∀j, ‖unitDirection (u j)‖≤1) ∧
    (∀j, zeroLipschitzActivation ℓ (tailActivation φ ‖u j‖)) ∧
    (∀j, 0≤w j*‖u j‖^2) ∧
    (∑ j, w j*‖u j‖^2)≤A ∧
    ∀i k, (∑ j, w j*φ (linearObservation a (u j) i)*φ (linearObservation a (u j) k))=
      ∑ j, (w j*‖u j‖^2)*
        tailActivation φ ‖u j‖ (linearObservation a (unitDirection (u j)) i)*
        tailActivation φ ‖u j‖ (linearObservation a (unitDirection (u j)) k) := by
  refine ⟨fun j => norm_unitDirection_le _,
    fun j => tailActivation_admissible hφ (norm_nonneg _),
    fun j => mul_nonneg (hw j) (sq_nonneg _),?_,?_⟩
  · apply le_trans (Finset.sum_le_sum (fun j _ => ?_)) henergy
    exact mul_le_of_le_one_left (sq_nonneg _) (hw1 j)
  · intro i k
    apply Finset.sum_congr rfl
    intro j _
    rw [tail_atom_reconstruction a hφ (u j) i,tail_atom_reconstruction a hφ (u j) k]
    ring

end NeuralGeneralization.BatchTwoActivation
