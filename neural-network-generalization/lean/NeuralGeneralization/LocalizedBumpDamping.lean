import NeuralGeneralization.LocalizedBumpEnergyBounds

/-! # Exact damping costs for the localized comparator

Low modes are damped by a scalar tau and high modes are left unchanged.
This changes the actual covariance, feature energy and determinant by the
explicit bounds below; no independence assumptions are introduced.
-/
noncomputable section
open scoped BigOperators NNReal
namespace NeuralGeneralization.LocalizedCubeBump
variable {d : ℕ}

def lowModes (d r : ℕ) : Finset (Finset (Fin d)) := Finset.univ.filter (fun S => S.card < r)

def damping (r : ℕ) (tau : ℝ≥0) (S : Finset (Fin d)) : ℝ≥0 :=
  if S.card < r then tau else 1

lemma damping_pos (r : ℕ) (tau : ℝ≥0) (htau : 0 < tau) (S : Finset (Fin d)) :
    0 < damping r tau S := by unfold damping; split_ifs <;> positivity

lemma damping_le_one (r : ℕ) (tau : ℝ≥0) (htau : tau ≤ 1) (S : Finset (Fin d)) :
    damping r tau S ≤ 1 := by unfold damping; split_ifs <;> order

lemma damping_empty (r : ℕ) (hr : 0 < r) (tau : ℝ≥0) :
    damping (d:=d) r tau ∅ = tau := by simp [damping, hr]

lemma damping_ge (r : ℕ) (tau : ℝ≥0) (htau : tau ≤ 1) (S : Finset (Fin d)) :
    tau ≤ damping r tau S := by unfold damping; split_ifs <;> order

/-- The actual damped pointwise variance is at most low damping plus the
undamped spectral tail. -/
theorem damping_variance_le (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (hsum : (∑ S, w S) ≤ 1) (r : ℕ) (tau : ℝ≥0) :
    (∑ S, w S*(damping r tau S : ℝ)) ≤ (tau : ℝ)+
      ∑ S ∈ Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card), w S := by
  classical
  have hpoint (S : Finset (Fin d)) :
      w S*(damping r tau S : ℝ) ≤ (tau : ℝ)*w S+(if r ≤ S.card then w S else 0) := by
    by_cases hS : S.card < r
    · simp [damping, hS, Nat.not_le_of_gt hS, mul_comm]
    · simp only [damping, if_neg hS, NNReal.coe_one, mul_one, if_pos (Nat.le_of_not_gt hS)]
      exact le_add_of_nonneg_left (mul_nonneg tau.coe_nonneg (hw S))
  calc
    _ ≤ ∑ S, ((tau : ℝ)*w S+(if r ≤ S.card then w S else 0)) := Finset.sum_le_sum fun S _ => hpoint S
    _ = (tau : ℝ)*(∑ S, w S)+
        ∑ S ∈ Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card), w S := by
      rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_filter]
    _ ≤ _ := add_le_add (by simpa using mul_le_mul_of_nonneg_left hsum tau.coe_nonneg) le_rfl

/-- Damping increases the original diagonal energy only through the
explicitly counted low modes. -/
theorem damping_diagonalEnergy_le (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (r : ℕ) (tau : ℝ≥0) (htau : 0 < tau) (B : ℝ)
    (hmax : ∀ S, coefficient d S.card^2/w S ≤ B) :
    diagonalEnergy (fun S => w S*(damping r tau S : ℝ)) ≤
      diagonalEnergy w+(lowModes d r).card*B/(tau : ℝ) := by
  classical
  have ht : (0:ℝ) < tau := htau
  have hpoint (S : Finset (Fin d)) :
      coefficient d S.card^2/(w S*(damping r tau S : ℝ)) ≤
        coefficient d S.card^2/w S+(if S.card < r then B/(tau : ℝ) else 0) := by
    by_cases hS : S.card < r
    · simp only [damping, if_pos hS]
      rw [← div_div]
      exact (div_le_div_of_nonneg_right (hmax S) ht.le).trans
        (le_add_of_nonneg_left (div_nonneg (sq_nonneg _) (hw S).le))
    · simp [damping, hS]
  unfold diagonalEnergy
  calc
    _ ≤ ∑ S, (coefficient d S.card^2/w S+(if S.card < r then B/(tau : ℝ) else 0)) :=
      Finset.sum_le_sum fun S _ => hpoint S
    _ = _ := by rw [Finset.sum_add_distrib, ← Finset.sum_filter]; simp [lowModes]; ring

/-- Every actual damped coordinate has the uniform maximum needed by
cross-energy concentration. -/
theorem damping_coefficient_max_le (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (r : ℕ) (tau : ℝ≥0) (htau : 0 < tau) (htau1 : tau ≤ 1)
    (B : ℝ) (hmax : ∀ S, coefficient d S.card^2/w S ≤ B) (S : Finset (Fin d)) :
    coefficient d S.card^2/(w S*(damping r tau S : ℝ)) ≤ B/(tau : ℝ) := by
  rw [← div_div]
  have hden : (tau : ℝ) ≤ damping r tau S := damping_ge r tau htau1 S
  exact (div_le_div_of_nonneg_left (div_nonneg (sq_nonneg _) (hw S).le) htau hden).trans
    (div_le_div_of_nonneg_right (hmax S) (le_of_lt htau))

/-- The Gaussian density comparison pays exactly half the number of low
modes times the logarithm of their variance damping. -/
theorem damping_log_determinant (r : ℕ) (tau : ℝ≥0) (htau : 0 < tau) :
    Real.log (∏ S : Finset (Fin d), Real.sqrt (damping r tau S : ℝ)) =
      ((lowModes d r).card:ℝ)/2*Real.log (tau : ℝ) := by
  classical
  rw [Real.log_prod (s:=Finset.univ)
    (f:=fun S : Finset (Fin d) => Real.sqrt (damping r tau S : ℝ))
    (fun S _ => (Real.sqrt_pos.mpr (damping_pos r tau htau S)).ne')]
  have hpoint (S : Finset (Fin d)) : Real.log (Real.sqrt (damping r tau S : ℝ)) =
      if S.card < r then Real.log (tau : ℝ)/2 else 0 := by
    by_cases hS : S.card < r
    · simp only [damping, if_pos hS]
      exact Real.log_sqrt (le_of_lt htau)
    · simp [damping, hS]
  simp_rw [hpoint]
  rw [← Finset.sum_filter]
  simp only [Finset.sum_const, nsmul_eq_mul]
  unfold lowModes
  ring

end NeuralGeneralization.LocalizedCubeBump
