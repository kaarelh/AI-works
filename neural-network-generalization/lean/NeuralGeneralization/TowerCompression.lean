import NeuralGeneralization.GaussianTowerConstruction
import NeuralGeneralization.TowerSamplingBudget

/-! Polynomial-width finite realization of an actual bounded tilted covariance tower. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.TowerCompression
open ConcreteModel TowerNetwork GaussianTowerConstruction GaussianAngularPrice GaussianFieldTilt
open TanhDifferential

def precision (r K G : ℕ) : ℕ := 32 * K * (r + 1) * (8 * (1 + G) ^ 2) ^ r
def compressedWidth (d r K G : ℕ) : ℕ := TowerSamplingBudget.width d (precision r K G)
def compressedBound (d r K G : ℕ) : ℕ := TowerSamplingBudget.rowBound d (precision r K G) G + 4 * K

theorem precision_pos (r K G : ℕ) (hK : 0 < K) : 0 < precision r K G := by
  unfold precision
  positivity

theorem precision_error (r K G : ℕ) (hK : 0 < K) :
    (4 * (K : ℝ)) * ((r + 1 : ℝ) * (8 * (1 + (G : ℝ)) ^ 2) ^ r *
      (1 / (precision r K G : ℝ))) = 1 / 8 := by
  have hKR : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  have hr : (r + 1 : ℝ) ≠ 0 := by positivity
  have hb : (8 * (1 + (G : ℝ)) ^ 2) ^ r ≠ 0 := by positivity
  simp only [precision, Nat.cast_mul, Nat.cast_add, Nat.cast_pow, Nat.cast_ofNat, Nat.cast_one]
  field_simp
  <;> ring

/-- Entrywise covariance approximation controls every bounded l1 dual readout. -/
theorem covariance_action_difference_bound {X : Type*} [Fintype X]
    (A Q : X → X → ℝ) (β : X → ℝ) {K e : ℝ} (he : 0 ≤ e)
    (hβ : (∑ x, |β x|) ≤ K) (hAQ : ∀ x y, |A x y - Q x y| ≤ e) (x : X) :
    |(∑ y, β y * A x y) - ∑ y, β y * Q x y| ≤ K * e := by
  rw [← Finset.sum_sub_distrib]
  calc
    _ ≤ ∑ y, |β y * A x y - β y * Q x y| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ y, |β y| * |A x y - Q x y| := by
      simp only [← mul_sub, abs_mul]
    _ ≤ ∑ y, |β y| * e :=
      Finset.sum_le_sum (fun y hy => mul_le_mul_of_nonneg_left (hAQ x y) (abs_nonneg _))
    _ = (∑ y, |β y|) * e := (Finset.sum_mul _ _ _).symm
    _ ≤ K * e := mul_le_mul_of_nonneg_right hβ he

/-- All probability budgets are discharged by the displayed natural
polynomials. The conclusion is an ordinary finite network in the exact model. -/
theorem exists_compressed_tower_network {d r K G : ℕ} (hd : 0 < d) (hK : 0 < K)
    (R Γ : ℕ → Cube d → Cube d → ℝ) (β : Cube d → ℝ) (f : BooleanFunction d)
    (hbase : ∀ x y, gram (R 0) x y = gram (inputMatrix d) x y)
    (hstep : ∀ s, s < r → ∀ x y, gram (R (s + 1)) x y = tiltedMoment (R s) (Γ s) x y)
    (hΓ : ∀ s, s ≤ r → couplingMass (Γ s) ≤ (G : ℝ))
    (hβ : (∑ x, |β x|) ≤ 4 * (K : ℝ))
    (hmargin : ∀ x, (7 / 8 : ℝ) ≤ labelReal (f x) *
      ∑ y, β y * tiltedMoment (R r) (Γ r) x y) :
    ∃ w : Weights d (compressedWidth d r K G) r,
      w ∈ marginEvent Real.tanh (1 / 2) f ∧ boundedWeights (compressedBound d r K G) w := by
  let E := precision r K G
  let N := compressedWidth d r K G
  let B := TowerSamplingBudget.rowBound d E G
  have hE : 0 < E := precision_pos r K G hK
  have hN : 0 < N := TowerSamplingBudget.width_pos d E hE
  have hbudgets := TowerSamplingBudget.sampling_budgets d E G hE
    (Nat.cast_nonneg G : (0 : ℝ) ≤ G) le_rfl
  obtain ⟨w, hw, hcov⟩ := exists_finite_tower hd hN R Γ (Nat.cast_nonneg G)
    (by positivity : (0 : ℝ) ≤ 1 / (E : ℝ)) (Nat.cast_nonneg B) hbase
    hbudgets.1 hbudgets.2 r hΓ hstep
  let v := withReadout w (covarianceReadout Real.tanh w β)
  refine ⟨v, ?_, ?_⟩
  · intro x
    have herror := covariance_action_difference_bound (finalCovariance Real.tanh w)
      (tiltedMoment (R r) (Γ r)) β
      (show 0 ≤ (r + 1 : ℝ) * (8 * (1 + (G : ℝ)) ^ 2) ^ r * (1 / (E : ℝ)) by positivity)
      hβ hcov x
    rw [show (4 * (K : ℝ)) * ((r + 1 : ℝ) * (8 * (1 + (G : ℝ)) ^ 2) ^ r *
      (1 / (E : ℝ))) = 1 / 8 from precision_error r K G hK] at herror
    have hsigned : |labelReal (f x) * (networkOutput Real.tanh v x -
        ∑ y, β y * tiltedMoment (R r) (Γ r) x y)| ≤ 1 / 8 := by
      rw [abs_mul, abs_labelReal, one_mul]
      exact (covarianceReadout_output Real.tanh w β x) ▸ herror
    have hlow := (abs_le.mp hsigned).1
    have hm := hmargin x
    change (1 / 2 : ℝ) < labelReal (f x) * networkOutput Real.tanh v x
    nlinarith
  · intro i
    change |v i| ≤ (compressedBound d r K G : ℝ)
    have hBR : (B : ℝ) ≤ (compressedBound d r K G : ℝ) := by
      change (TowerSamplingBudget.rowBound d E G : ℝ) ≤
        ((TowerSamplingBudget.rowBound d E G + 4 * K : ℕ) : ℝ)
      exact_mod_cast Nat.le_add_right _ _
    rcases i with ij | (sij | j)
    · exact (hw (.inl ij)).trans hBR
    · exact (hw (.inr (.inl sij))).trans hBR
    · have hb := covarianceReadout_bound w β hβ (i := j)
      have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
      have h4 := div_le_self (by positivity : (0 : ℝ) ≤ 4 * (K : ℝ)) hN1
      have hreadout : |covarianceReadout Real.tanh w β j| ≤ 4 * (K : ℝ) := hb.trans h4
      have hKR : 4 * (K : ℝ) ≤ (compressedBound d r K G : ℝ) := by
        simp only [compressedBound, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat]
        exact le_add_of_nonneg_left (Nat.cast_nonneg _)
      exact hreadout.trans hKR

end NeuralGeneralization.TowerCompression
