import NeuralGeneralization.LocalizedBumpEnergy

/-! # Actual population cross energy of localized bumps -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
variable {d : ℕ}

lemma uniformCubeMean_mono {P Q : ClippingCube d → ℝ} (h : ∀ x, P x ≤ Q x) :
    uniformCubeMean P ≤ uniformCubeMean Q := by
  unfold uniformCubeMean
  exact div_le_div_of_nonneg_right (Finset.sum_le_sum fun x _ => h x) (by positivity)

lemma uniformCubeMean_const (a : ℝ) :
    uniformCubeMean (fun _ : ClippingCube d => a) = a := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  simp [uniformCubeMean]

lemma uniformCubeMean_abs_sq_le (F : ClippingCube d → ℝ) :
    uniformCubeMean (fun x => |F x|)^2 ≤ uniformCubeMean (fun x => F x^2) := by
  have hM : (0:ℝ) < Fintype.card (ClippingCube d) := Nat.cast_pos.mpr Fintype.card_pos
  have hh := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset (ClippingCube d))
    (fun x => |F x|) (fun _ => (1:ℝ))
  simp only [mul_one, sq_abs, one_pow, Finset.sum_const, Finset.card_univ,
    nsmul_eq_mul] at hh
  unfold uniformCubeMean
  rw [div_pow]
  apply (div_le_iff₀ (sq_pos_of_pos hM)).mpr
  convert! hh using 1
  field_simp

lemma pairEnergy_row_square_mean (w : Finset (Fin d) → ℝ) (x : ClippingCube d) :
    uniformCubeMean (fun y => pairEnergy w x y^2) =
      ∑ S, (coefficient d S.card^2/w S)^2 := by
  have hh := uniformCubeMean_walshExpansion_sq
    (fun S => (coefficient d S.card^2/w S)*walshCharacter S x)
  change uniformCubeMean (fun y => pairEnergy w x y^2) = _ at hh
  rw [hh]
  apply Finset.sum_congr rfl
  intro S hS
  rw [mul_pow, walshCharacter_sq, mul_one]

/-- Parseval plus the maximum spectral coordinate gives the actual row
second moment. No independence or sign assumptions on the center are used. -/
theorem pairEnergy_row_square_mean_le (w : Finset (Fin d) → ℝ)
    (hw : ∀ S, 0 ≤ w S) (v : ℝ)
    (hv : ∀ S, coefficient d S.card^2/w S ≤ v) (x : ClippingCube d) :
    uniformCubeMean (fun y => pairEnergy w x y^2) ≤ v*diagonalEnergy w := by
  rw [pairEnergy_row_square_mean]
  unfold diagonalEnergy
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro S hS
  exact (by simpa only [pow_two] using
    mul_le_mul_of_nonneg_right (hv S) (div_nonneg (sq_nonneg _) (hw S)))

/-- This row bound gives the population absolute cross-energy needed for
Markov control of all selected label subsets. -/
theorem pairEnergy_abs_mean_le (w : Finset (Fin d) → ℝ)
    (hw : ∀ S, 0 ≤ w S) (v : ℝ) (hv0 : 0 ≤ v)
    (hv : ∀ S, coefficient d S.card^2/w S ≤ v) (x : ClippingCube d) :
    uniformCubeMean (fun y => |pairEnergy w x y|) ≤ Real.sqrt (v*diagonalEnergy w) := by
  have hh := (uniformCubeMean_abs_sq_le (pairEnergy w x)).trans
    (pairEnergy_row_square_mean_le w hw v hv x)
  have hs := Real.sq_sqrt (mul_nonneg hv0 (diagonalEnergy_nonneg w hw))
  have hp := Real.sqrt_nonneg (v*diagonalEnergy w)
  nlinarith

/-- The exact double uniform expectation is bounded by the same quantity. -/
theorem pairEnergy_abs_double_mean_le (w : Finset (Fin d) → ℝ)
    (hw : ∀ S, 0 ≤ w S) (v : ℝ) (hv0 : 0 ≤ v)
    (hv : ∀ S, coefficient d S.card^2/w S ≤ v) :
    uniformCubeMean (fun x => uniformCubeMean (fun y => |pairEnergy w x y|)) ≤
      Real.sqrt (v*diagonalEnergy w) := by
  exact (uniformCubeMean_mono (fun x => pairEnergy_abs_mean_le w hw v hv0 hv x)).trans_eq
    (uniformCubeMean_const _)

end NeuralGeneralization.LocalizedCubeBump
