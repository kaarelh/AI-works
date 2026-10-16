import NeuralGeneralization.TiltedGaussianRows
import NeuralGeneralization.TowerNetwork

/-! Actual finite network realization of successive tilted Gaussian covariance steps. -/
noncomputable section
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianTowerConstruction
open ConcreteModel TowerNetwork FiniteDifferential GaussianAngularPrice GaussianFieldTilt
open TiltedGaussianRows TanhDifferential

def inputMatrix (d : ℕ) (x : Cube d) (j : Fin (d + 1)) : ℝ :=
  inputVector x j / Real.sqrt d

def inputWeights {d N : ℕ} (a : Fin N → Fin (d + 1) → ℝ) : Weights d N 0
  | .inl (i, j) => a i j / Real.sqrt d
  | .inr (.inl (s, _, _)) => Fin.elim0 s
  | .inr (.inr _) => 0

theorem finalHidden_inputWeights {d N : ℕ} (a : Fin N → Fin (d + 1) → ℝ)
    (x : Cube d) (i : Fin N) :
    finalHidden Real.tanh (inputWeights a) x i =
      Real.tanh (fieldLinear (inputMatrix d) (a i) x) := by
  simp only [finalHidden, List.finRange_zero, List.foldl_nil, firstHidden, inputWeights,
    fieldLinear_apply, inputMatrix]
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem inputWeights_bound {d N : ℕ} (hd : 0 < d) (a : Fin N → Fin (d + 1) → ℝ)
    {B : ℝ} (hB : 0 ≤ B) (ha : ∀ i j, |a i j| ≤ B) :
    ∀ i, |inputWeights a i| ≤ B := by
  have hsqrt : 1 ≤ Real.sqrt (d : ℝ) := Real.one_le_sqrt.mpr (by exact_mod_cast hd)
  intro i
  rcases i with ⟨i,j⟩ | (⟨s,i,j⟩ | j)
  · change |a i j / Real.sqrt (d : ℝ)| ≤ B
    rw [abs_div, abs_of_nonneg (Real.sqrt_nonneg _)]
    exact (div_le_self (abs_nonneg _) hsqrt).trans (ha i j)
  · exact Fin.elim0 s
  · simpa [inputWeights] using hB

def activationMatrix {d N r : ℕ} (w : Weights d N r) (x : Cube d) (j : Fin N) : ℝ :=
  finalHidden Real.tanh w x j / Real.sqrt N

theorem gram_activationMatrix {d N r : ℕ} (hN : 0 < N) (w : Weights d N r)
    (x y : Cube d) : gram (activationMatrix w) x y = finalCovariance Real.tanh w x y := by
  unfold gram activationMatrix finalCovariance
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j hj
  rw [div_mul_div_comm]
  rw [← sq, Real.sq_sqrt (Nat.cast_nonneg N)]

def normalizedRows {N : ℕ} (a : Fin N → Fin N → ℝ) (i j : Fin N) : ℝ :=
  a i j / Real.sqrt N

theorem normalizedRows_bound {N : ℕ} (hN : 0 < N) (a : Fin N → Fin N → ℝ)
    {B : ℝ} (ha : ∀ i j, |a i j| ≤ B) : ∀ i j, |normalizedRows a i j| ≤ B := by
  have hsqrt : 1 ≤ Real.sqrt (N : ℝ) := Real.one_le_sqrt.mpr (by exact_mod_cast hN)
  intro i j
  unfold normalizedRows
  rw [abs_div, abs_of_nonneg (Real.sqrt_nonneg _)]
  exact (div_le_self (abs_nonneg _) hsqrt).trans (ha i j)

set_option maxHeartbeats 1000000 in
theorem finalHidden_append_normalizedRows {d N r : ℕ} (w : Weights d N r)
    (a : Fin N → Fin N → ℝ) (x : Cube d) (i : Fin N) :
    finalHidden Real.tanh (appendLayer w (normalizedRows a)) x i =
      Real.tanh (fieldLinear (activationMatrix w) (a i) x) := by
  rw [finalHidden_appendLayer]
  apply congrArg Real.tanh
  simp only [fieldLinear_apply, activationMatrix, normalizedRows]
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- One actual hidden layer approximates the desired tilted moment, with
its input covariance discrepancy propagated by the proved Price bound. -/
theorem exists_append_covariance {d N r : ℕ} (hN : 0 < N) (w : Weights d N r)
    (R : Cube d → Cube d → ℝ) (Γ : Cube d → Cube d → ℝ) {G e η B : ℝ}
    (hG : 0 ≤ G) (he : 0 ≤ e) (hη : 0 ≤ η) (hB : 0 ≤ B)
    (hw : ∀ i, |w i| ≤ B) (hΓ : couplingMass Γ ≤ G)
    (hcov : ∀ x y, |finalCovariance Real.tanh w x y - gram R x y| ≤ e)
    (hbudget : 2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * (N : ℝ) * (N : ℝ) * Real.exp (2 * G - B ^ 2 / 2) < 1) :
    ∃ v : Weights d N (r + 1), (∀ i, |v i| ≤ B) ∧ ∀ x y,
      |finalCovariance Real.tanh v x y - tiltedMoment R Γ x y| ≤
        η + 8 * (1 + G) ^ 2 * e := by
  obtain ⟨a, ha, hacov⟩ := exists_bounded_tanh_rows (activationMatrix w) Γ hΓ hN hη hB
    (by simpa using hbudget)
  refine ⟨appendLayer w (normalizedRows a),
    appendLayer_bound w _ hw (normalizedRows_bound hN a (fun i j => (ha i j).le)), ?_⟩
  intro x y
  have hsample : |finalCovariance Real.tanh (appendLayer w (normalizedRows a)) x y -
      tiltedMoment (activationMatrix w) Γ x y| ≤ η := by
    simpa only [finalCovariance, finalHidden_append_normalizedRows] using (hacov x y).le
  have hprice := tiltedMoment_stability R (activationMatrix w) Γ x y hG he hΓ
    (fun p q => by simpa only [gram_activationMatrix hN] using hcov p q)
  exact (abs_sub_le _ _ _).trans (add_le_add hsample hprice)

/-- The first actual Gaussian input layer has the required bounded parameters. -/
theorem exists_input_covariance {d N : ℕ} (hd : 0 < d) (hN : 0 < N)
    (R : Cube d → Cube d → ℝ) (Γ : Cube d → Cube d → ℝ) {G η B : ℝ}
    (hG : 0 ≤ G) (hη : 0 ≤ η) (hB : 0 ≤ B) (hΓ : couplingMass Γ ≤ G)
    (hcov : ∀ x y, gram R x y = gram (inputMatrix d) x y)
    (hbudget : 2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * (N : ℝ) * (d + 1 : ℝ) * Real.exp (2 * G - B ^ 2 / 2) < 1) :
    ∃ w : Weights d N 0, (∀ i, |w i| ≤ B) ∧ ∀ x y,
      |finalCovariance Real.tanh w x y - tiltedMoment R Γ x y| ≤ η := by
  obtain ⟨a, ha, hacov⟩ := exists_bounded_tanh_rows (inputMatrix d) Γ hΓ hN hη hB
    (by simpa using hbudget)
  refine ⟨inputWeights a, inputWeights_bound hd a hB (fun i j => (ha i j).le), ?_⟩
  intro x y
  have hprice := tiltedMoment_stability R (inputMatrix d) Γ x y hG (le_refl 0) hΓ
    (fun p q => by rw [hcov]; simp)
  have heq : tiltedMoment (inputMatrix d) Γ x y = tiltedMoment R Γ x y := by
    apply sub_eq_zero.mp
    exact abs_eq_zero.mp (le_antisymm (by simpa using hprice) (abs_nonneg _))
  simpa only [finalCovariance, finalHidden_inputWeights, heq] using (hacov x y).le


/-- Stagewise selection realizes an entire prescribed actual tilted covariance
tower. Each use of probability is on a fixed row law after the previous finite
network has already been selected. -/
theorem exists_finite_tower {d N : ℕ} (hd : 0 < d) (hN : 0 < N)
    (R Γ : ℕ → Cube d → Cube d → ℝ) {G η B : ℝ}
    (hG : 0 ≤ G) (hη : 0 ≤ η) (hB : 0 ≤ B)
    (hbase : ∀ x y, gram (R 0) x y = gram (inputMatrix d) x y)
    (hinputBudget : 2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * (N : ℝ) * (d + 1 : ℝ) * Real.exp (2 * G - B ^ 2 / 2) < 1)
    (hhiddenBudget : 2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * (N : ℝ) * (N : ℝ) * Real.exp (2 * G - B ^ 2 / 2) < 1) :
    ∀ r : ℕ, (∀ s, s ≤ r → couplingMass (Γ s) ≤ G) →
      (∀ s, s < r → ∀ x y, gram (R (s + 1)) x y = tiltedMoment (R s) (Γ s) x y) →
      ∃ w : Weights d N r, (∀ i, |w i| ≤ B) ∧ ∀ x y,
        |finalCovariance Real.tanh w x y - tiltedMoment (R r) (Γ r) x y| ≤
          (r + 1 : ℝ) * (8 * (1 + G) ^ 2) ^ r * η := by
  intro r
  induction r with
  | zero =>
    intro hΓ hstep
    simpa using exists_input_covariance hd hN (R 0) (Γ 0) hG hη hB
      (hΓ 0 le_rfl) hbase hinputBudget
  | succ r ih =>
    intro hΓ hstep
    obtain ⟨w, hw, hcov⟩ := ih (fun s hs => hΓ s (Nat.le_trans hs (Nat.le_succ r)))
      (fun s hs => hstep s (Nat.lt_trans hs (Nat.lt_succ_self r)))
    have herr : 0 ≤ (r + 1 : ℝ) * (8 * (1 + G) ^ 2) ^ r * η := by positivity
    obtain ⟨v, hv, hvcov⟩ := exists_append_covariance hN w (R (r + 1)) (Γ (r + 1))
      hG herr hη hB hw (hΓ (r + 1) le_rfl)
      (fun x y => by rw [hstep r (Nat.lt_succ_self r)]; exact hcov x y) hhiddenBudget
    refine ⟨v, hv, ?_⟩
    intro x y
    apply (hvcov x y).trans
    have hb : 1 ≤ 8 * (1 + G) ^ 2 := by nlinarith
    have hp : 1 ≤ (8 * (1 + G) ^ 2) ^ (r + 1) := one_le_pow₀ hb
    have he := mul_le_mul_of_nonneg_right hp hη
    simp only [one_mul] at he
    calc
      _ ≤ (8 * (1 + G) ^ 2) ^ (r + 1) * η +
          8 * (1 + G) ^ 2 * ((r + 1 : ℝ) * (8 * (1 + G) ^ 2) ^ r * η) :=
        add_le_add he le_rfl
      _ = _ := by rw [pow_succ]; push_cast; ring

end NeuralGeneralization.GaussianTowerConstruction
