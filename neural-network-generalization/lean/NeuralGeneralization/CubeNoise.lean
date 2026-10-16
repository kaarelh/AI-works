import NeuralGeneralization.ArcsineTail

/-! Finite cube noise weights and their exact Walsh moments. -/

noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

/-- Product noise about the all-positive cube vertex, expressed by its
finite Fourier expansion. -/
def cubeNoiseWeight (d : ℕ) (ρ : ℝ) (x : ClippingCube d) : ℝ :=
  walshExpansion (fun S => ρ ^ S.card) x / (Fintype.card (ClippingCube d) : ℝ)

theorem cubeNoiseWeight_product (d : ℕ) (ρ : ℝ) (x : ClippingCube d) :
    cubeNoiseWeight d ρ x =
      (∏ i, (1 + ρ * cubeCoordinateSign (x i))) /
        (Fintype.card (ClippingCube d) : ℝ) := by
  unfold cubeNoiseWeight walshExpansion walshCharacter
  congr 1
  have h := Fintype.prod_add (fun i : Fin d => ρ * cubeCoordinateSign (x i))
    (fun _ => (1 : ℝ))
  simp only [Finset.prod_mul_distrib, Finset.prod_const, one_pow, mul_one] at h
  simpa only [add_comm] using h.symm

theorem cubeNoiseWeight_nonneg (d : ℕ) {ρ : ℝ} (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1)
    (x : ClippingCube d) : 0 ≤ cubeNoiseWeight d ρ x := by
  rw [cubeNoiseWeight_product]
  apply div_nonneg _ (Nat.cast_nonneg _)
  apply Finset.prod_nonneg
  intro i hi
  cases hx : x i <;> simp only [cubeCoordinateSign, Bool.false_eq_true,
    if_false, if_true, mul_neg, mul_one] <;> linarith

theorem cubeNoiseWeight_walsh_moment (d : ℕ) (ρ : ℝ) (S : Finset (Fin d)) :
    (∑ x : ClippingCube d, cubeNoiseWeight d ρ x * walshCharacter S x) = ρ ^ S.card := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  simp only [cubeNoiseWeight, div_mul_eq_mul_div, ← Finset.sum_div]
  rw [walshExpansion_pairing]
  field_simp

theorem cubeNoiseWeight_sum (d : ℕ) (ρ : ℝ) :
    (∑ x : ClippingCube d, cubeNoiseWeight d ρ x) = 1 := by
  simpa [walshCharacter] using cubeNoiseWeight_walsh_moment d ρ ∅

def cubeNoiseMean {d : ℕ} (ρ : ℝ) (P : ClippingCube d → ℝ) : ℝ :=
  ∑ x : ClippingCube d, cubeNoiseWeight d ρ x * P x

theorem cubeNoiseMean_walsh {d : ℕ} (ρ : ℝ) (P : ClippingCube d → ℝ) :
    cubeNoiseMean ρ P = ∑ S, walshCoefficients P S * ρ ^ S.card := by
  classical
  unfold cubeNoiseMean
  conv_lhs => arg 2; ext x; arg 2; rw [← walshExpansion_coefficients P x]
  unfold walshExpansion
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro S hS
  rw [← cubeNoiseWeight_walsh_moment d ρ S, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x hx
  ring

theorem cubeNoiseMean_const {d : ℕ} (ρ c : ℝ) :
    cubeNoiseMean (d := d) ρ (fun _ => c) = c := by
  simp only [cubeNoiseMean, ← Finset.sum_mul, cubeNoiseWeight_sum, one_mul]

theorem cubeNoiseMean_sub {d : ℕ} (ρ : ℝ) (P Q : ClippingCube d → ℝ) :
    cubeNoiseMean ρ (fun x => P x - Q x) = cubeNoiseMean ρ P - cubeNoiseMean ρ Q := by
  simp [cubeNoiseMean, mul_sub, Finset.sum_sub_distrib]

theorem cubeNoiseMean_nonneg {d : ℕ} {ρ : ℝ} (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1)
    (P : ClippingCube d → ℝ) (hP : ∀ x, 0 ≤ P x) : 0 ≤ cubeNoiseMean ρ P :=
  Finset.sum_nonneg (fun x _ => mul_nonneg (cubeNoiseWeight_nonneg d hρ0 hρ1 x) (hP x))

theorem cubeNoiseMean_mono {d : ℕ} {ρ : ℝ} (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1)
    (P Q : ClippingCube d → ℝ) (hPQ : ∀ x, P x ≤ Q x) :
    cubeNoiseMean ρ P ≤ cubeNoiseMean ρ Q :=
  Finset.sum_le_sum (fun x _ =>
    mul_le_mul_of_nonneg_left (hPQ x) (cubeNoiseWeight_nonneg d hρ0 hρ1 x))

theorem cubeNoiseMean_square_le {d : ℕ} {ρ : ℝ} (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1)
    (P : ClippingCube d → ℝ) :
    cubeNoiseMean ρ P ^ 2 ≤ cubeNoiseMean ρ (fun x => P x ^ 2) := by
  have h := Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul Finset.univ
    (r := fun x => cubeNoiseWeight d ρ x * P x)
    (f := fun x => cubeNoiseWeight d ρ x)
    (g := fun x => cubeNoiseWeight d ρ x * P x ^ 2)
    (fun x _ => cubeNoiseWeight_nonneg d hρ0 hρ1 x)
    (fun x _ => mul_nonneg (cubeNoiseWeight_nonneg d hρ0 hρ1 x) (sq_nonneg _))
    (fun x _ => by ring_nf; rfl)
  simpa only [cubeNoiseWeight_sum, one_mul, cubeNoiseMean] using h

/-- The noisy mean of the actual biased base profile is affine in `ρ`. -/
theorem cubeNoiseMean_biasedProfile_id (d : ℕ) (ρ : ℝ) :
    cubeNoiseMean ρ (biasedProfile (d := d) id) = (1 + d * ρ) / (d + 1 : ℝ) := by
  have hcoord (i : Fin d) : cubeNoiseMean ρ (fun x : ClippingCube d =>
      cubeCoordinateSign (x i)) = ρ := by
    simpa [cubeNoiseMean, walshCharacter] using cubeNoiseWeight_walsh_moment d ρ {i}
  unfold cubeNoiseMean biasedProfile
  simp only [id_eq, ← mul_div_assoc, ← Finset.sum_div, mul_add, mul_one,
    Finset.sum_add_distrib, cubeNoiseWeight_sum, Finset.mul_sum]
  rw [Finset.sum_comm]
  change (1 + ∑ i : Fin d, cubeNoiseMean ρ (fun x => cubeCoordinateSign (x i))) /
    (d + 1 : ℝ) = _
  simp [hcoord]

/-- For nonnegative spectrum, noise dissipation controls every degree tail. -/
theorem walshSpectralTail_noise_le {d r : ℕ} {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (P : ClippingCube d → ℝ)
    (hP : ∀ S, 0 ≤ walshCoefficients P S) (hone : P (fun _ => true) = 1) :
    (1 - ρ ^ r) * walshSpectralTail P r ≤ cubeNoiseMean ρ (fun x => 1 - P x) := by
  classical
  have hsum : (∑ S, walshCoefficients P S) = 1 := by
    have h := walshExpansion_coefficients P (fun _ => true)
    simpa [walshExpansion, walshCharacter, cubeCoordinateSign, hone] using h
  have hdiss : cubeNoiseMean ρ (fun x => 1 - P x) =
      ∑ S, (walshCoefficients P S - walshCoefficients P S * ρ ^ S.card) := by
    rw [cubeNoiseMean_sub, cubeNoiseMean_const, cubeNoiseMean_walsh, ← hsum,
      ← Finset.sum_sub_distrib]
  rw [hdiss]
  let A := Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card)
  calc
    _ ≤ ∑ S ∈ A, (walshCoefficients P S - walshCoefficients P S * ρ ^ S.card) := by
      unfold walshSpectralTail
      rw [Finset.mul_sum]
      apply Finset.sum_le_sum
      intro S hS
      have hdeg := (Finset.mem_filter.mp hS).2
      have hp : ρ ^ S.card ≤ ρ ^ r := pow_le_pow_of_le_one hρ0 hρ1 hdeg
      nlinarith [mul_le_mul_of_nonneg_left hp (hP S)]
    _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun S hS hnot => by
        have hp : ρ ^ S.card ≤ 1 := pow_le_one₀ hρ0 hρ1
        nlinarith [mul_le_mul_of_nonneg_left hp (hP S)])

end NeuralGeneralization
