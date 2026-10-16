import NeuralGeneralization.LocalizedBumpGeometry
import NeuralGeneralization.WalshGaussianEnergy
import Mathlib.Algebra.BigOperators.Group.Finset.Powerset

/-! # Exact energy identities for localized cube comparators

All coefficients below are the Fourier coefficients of the actual spatial
bumps. The pair kernel records cross energies, allowing a random sample
bound to hold simultaneously for every subset of negative labels.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
variable {d n : ℕ}

def diagonalEnergy (w : Finset (Fin d) → ℝ) : ℝ :=
  ∑ S, coefficient d S.card^2/w S

def pairEnergy (w : Finset (Fin d) → ℝ) (x y : ClippingCube d) : ℝ :=
  ∑ S, (coefficient d S.card^2/w S)*walshCharacter S x*walshCharacter S y

lemma bump_energy (w : Finset (Fin d) → ℝ) (z : ClippingCube d) :
    featureEnergy w (walshCoefficients (bump z)) = diagonalEnergy w := by
  unfold featureEnergy diagonalEnergy
  apply Finset.sum_congr rfl
  intro S hS
  rw [bump_walsh, mul_pow, walshCharacter_sq, mul_one]

lemma pairEnergy_self (w : Finset (Fin d) → ℝ) (z : ClippingCube d) :
    pairEnergy w z z = diagonalEnergy w := by
  unfold pairEnergy diagonalEnergy
  apply Finset.sum_congr rfl
  intro S hS
  rw [mul_assoc, ← pow_two, walshCharacter_sq, mul_one]

lemma diagonalEnergy_nonneg (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S) :
    0 ≤ diagonalEnergy w := Finset.sum_nonneg fun S _ => div_nonneg (sq_nonneg _) (hw S)

lemma walshCoefficients_finset_sum {ι : Type*} (T : Finset ι)
    (P : ι → ClippingCube d → ℝ) (S : Finset (Fin d)) :
    walshCoefficients (fun x => ∑ i ∈ T, P i x) S = ∑ i ∈ T, walshCoefficients (P i) S := by
  unfold walshCoefficients uniformCubeMean
  simp_rw [Finset.sum_mul]
  rw [Finset.sum_comm, Finset.sum_div]

lemma centerSum_walsh (s : Fin n → ClippingCube d) (T : Finset (Fin n))
    (S : Finset (Fin d)) :
    walshCoefficients (centerSum s T) S = coefficient d S.card*∑ i ∈ T, walshCharacter S (s i) := by
  unfold centerSum
  rw [walshCoefficients_finset_sum]
  simp_rw [bump_walsh]
  rw [Finset.mul_sum]

/-- The complete selected-subset energy is the corresponding pair sum. -/
theorem centerSum_energy (w : Finset (Fin d) → ℝ)
    (s : Fin n → ClippingCube d) (T : Finset (Fin n)) :
    featureEnergy w (walshCoefficients (centerSum s T)) =
      ∑ i ∈ T, ∑ j ∈ T, pairEnergy w (s i) (s j) := by
  unfold featureEnergy pairEnergy
  simp_rw [centerSum_walsh, mul_pow, pow_two, Finset.sum_mul, Finset.mul_sum,
    Finset.sum_div]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j hj
  apply Finset.sum_congr rfl
  intro S hS
  ring

/-- A single absolute off-diagonal pair bound controls every label subset. -/
theorem centerSum_energy_le (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (s : Fin n → ClippingCube d) (T : Finset (Fin n)) :
    featureEnergy w (walshCoefficients (centerSum s T)) ≤
      (n:ℝ)*diagonalEnergy w + ∑ i, ∑ j ∈ Finset.univ.erase i,
        |pairEnergy w (s i) (s j)| := by
  classical
  have hD := diagonalEnergy_nonneg w hw
  rw [centerSum_energy]
  calc
    _ ≤ ∑ i ∈ T, (diagonalEnergy w + ∑ j ∈ Finset.univ.erase i,
        |pairEnergy w (s i) (s j)|) := by
      apply Finset.sum_le_sum
      intro i hi
      rw [← Finset.add_sum_erase T (fun j => pairEnergy w (s i) (s j)) hi, pairEnergy_self]
      gcongr
      calc
        _ ≤ ∑ j ∈ T.erase i, |pairEnergy w (s i) (s j)| :=
          Finset.sum_le_sum fun j hj => le_abs_self _
        _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.erase_subset_erase i (Finset.subset_univ T))
          (fun j _ _ => abs_nonneg _)
    _ ≤ ∑ i : Fin n, (diagonalEnergy w + ∑ j ∈ Finset.univ.erase i,
        |pairEnergy w (s i) (s j)|) :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ T)
        (fun i _ _ => add_nonneg hD (Finset.sum_nonneg fun j _ => abs_nonneg _))
    _ = _ := by simp [Finset.sum_add_distrib]

lemma walshCoefficients_one (S : Finset (Fin d)) :
    walshCoefficients (fun _ : ClippingCube d => (1:ℝ)) S = if S=∅ then 1 else 0 := by
  have h := walshCharacter_orthogonal (∅ : Finset (Fin d)) S
  have he (x : ClippingCube d) : walshCharacter ∅ x = 1 := by simp [walshCharacter]
  simp only [he, one_mul] at h
  unfold walshCoefficients uniformCubeMean
  simp only [one_mul]
  rw [h]
  by_cases hh : S=∅
  · simp [hh]
  · simp [hh, Ne.symm hh]

lemma featureEnergy_one (w : Finset (Fin d) → ℝ) :
    featureEnergy w (walshCoefficients (fun _ : ClippingCube d => (1:ℝ))) = 1/w ∅ := by
  classical
  simp only [featureEnergy, walshCoefficients_one]
  rw [Finset.sum_eq_single ∅]
  · simp
  · intro S _ hS; simp [hS]
  · simp

/-- The concrete globally margin-separated comparator has energy controlled
by one constant mode and the selected bump sum. -/
theorem comparator_energy_le (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (A : ℝ) (s : Fin n → ClippingCube d) (T : Finset (Fin n)) :
    featureEnergy w (walshCoefficients (comparator A s T)) ≤
      8*A^2*(1/w ∅+4*featureEnergy w (walshCoefficients (centerSum s T))) := by
  have hpoint (S : Finset (Fin d)) :
      walshCoefficients (comparator A s T) S^2/w S ≤
        8*A^2*(walshCoefficients (fun _ : ClippingCube d => (1:ℝ)) S^2/w S+
          4*(walshCoefficients (centerSum s T) S^2/w S)) := by
    unfold comparator
    rw [walshCoefficients_const_mul, walshCoefficients_sub, walshCoefficients_const_mul]
    have hh := sq_nonneg (walshCoefficients (fun _ : ClippingCube d => (1:ℝ)) S+
      2*walshCoefficients (centerSum s T) S)
    apply (div_le_iff₀ (hw S)).mpr
    field_simp [ne_of_gt (hw S)]
    nlinarith [mul_nonneg (sq_nonneg A) hh]
  calc
    _ ≤ ∑ S, 8*A^2*(walshCoefficients (fun _ : ClippingCube d => (1:ℝ)) S^2/w S+
          4*(walshCoefficients (centerSum s T) S^2/w S)) := Finset.sum_le_sum fun S _ => hpoint S
    _ = 8*A^2*(featureEnergy w (walshCoefficients (fun _ : ClippingCube d => (1:ℝ)))+
        4*featureEnergy w (walshCoefficients (centerSum s T))) := by
      simp only [← Finset.mul_sum, Finset.sum_add_distrib, featureEnergy]
    _ = _ := by rw [featureEnergy_one]

end NeuralGeneralization.LocalizedCubeBump
