import NeuralGeneralization.BatchTwoNonGaussianRows
import NeuralGeneralization.BatchTwoNonGaussianSamplingBudget
import NeuralGeneralization.TowerCompression

/-! Finite realization of the paper's mixed tower: the first law remains
non-Gaussian and every later reference field is Gaussian. -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel GaussianTowerConstruction TowerNetwork GaussianFieldTilt
open GaussianAngularPrice TanhDifferential TowerCompression

/-- Stagewise selection realizes the mixed covariance tower in ordinary finite
network parameters. The only premises on the tower are its defining identities. -/
theorem exists_mixed_finite_tower (ν : CoordinateLaw) {d N : ℕ}
    (hd : 0 < d) (hN : 0 < N)
    (Q R Γ : ℕ → Cube d → Cube d → ℝ) {G η B : ℝ}
    (hG : 0 ≤ G) (hη : 0 ≤ η) (hB : 0 ≤ B)
    (hbase : ∀ x y, Q 0 x y = actualTiltedMoment ν (inputMatrix d) (Γ 0) x y)
    (hgram : ∀ s x y, gram (R s) x y = Q s x y)
    (hinputBudget : 2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * ν.comparisonFactor ν.lowerCurvature * (N : ℝ) * (d + 1 : ℝ) *
        Real.exp (2 * G - ν.lowerCurvature * B ^ 2 / 2) < 1)
    (hhiddenBudget : 2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * (N : ℝ) * (N : ℝ) * Real.exp (2 * G - B ^ 2 / 2) < 1) :
    ∀ r : ℕ, (∀ s, s ≤ r → couplingMass (Γ s) ≤ G) →
      (∀ s, s < r → ∀ x y, Q (s + 1) x y = tiltedMoment (R s) (Γ (s + 1)) x y) →
      ∃ w : Weights d N r, (∀ i, |w i| ≤ B) ∧ ∀ x y,
        |finalCovariance Real.tanh w x y - Q r x y| ≤
          (r + 1 : ℝ) * (8 * (1 + G) ^ 2) ^ r * η := by
  intro r
  induction r with
  | zero =>
    intro hΓ hstep
    obtain ⟨w, hw, hc⟩ := exists_actual_input_covariance ν hd hN (Γ 0) hη hB
      (hΓ 0 le_rfl) hinputBudget
    refine ⟨w, hw, ?_⟩
    intro x y
    simpa only [hbase, Nat.cast_zero, zero_add, pow_zero, mul_one, one_mul] using hc x y
  | succ r ih =>
    intro hΓ hstep
    obtain ⟨w, hw, hc⟩ := ih (fun s hs => hΓ s (Nat.le_trans hs (Nat.le_succ r)))
      (fun s hs => hstep s (Nat.lt_trans hs (Nat.lt_succ_self r)))
    have he : 0 ≤ (r + 1 : ℝ) * (8 * (1 + G) ^ 2) ^ r * η := by positivity
    obtain ⟨v, hv, hvc⟩ := exists_append_covariance hN w (R r) (Γ (r + 1))
      hG he hη hB hw (hΓ (r + 1) le_rfl)
      (fun x y => by rw [hgram]; exact hc x y) hhiddenBudget
    refine ⟨v, hv, ?_⟩
    intro x y
    rw [hstep r (Nat.lt_succ_self r)]
    apply (hvc x y).trans
    have hb : 1 ≤ 8 * (1 + G) ^ 2 := by nlinarith
    have hp : 1 ≤ (8 * (1 + G) ^ 2) ^ (r + 1) := one_le_pow₀ hb
    have he' := mul_le_mul_of_nonneg_right hp hη
    simp only [one_mul] at he'
    calc
      _ ≤ (8 * (1 + G) ^ 2) ^ (r + 1) * η +
          8 * (1 + G) ^ 2 * ((r + 1 : ℝ) * (8 * (1 + G) ^ 2) ^ r * η) :=
        add_le_add he' le_rfl
      _ = _ := by rw [pow_succ]; push_cast; ring

def mixedCompressedBound (ν : CoordinateLaw) (d r K G : ℕ) : ℕ :=
  actualRowBound ν d (precision r K G) G + 4 * K

/-- The finite-realization proposition, with explicit polynomial width and
coefficient bound and all probability budgets discharged. -/
theorem exists_mixed_compressed_network (ν : CoordinateLaw) {d r K G : ℕ}
    (hd : 0 < d) (hK : 0 < K)
    (Q R Γ : ℕ → Cube d → Cube d → ℝ) (β : Cube d → ℝ) (f : BooleanFunction d)
    (hbase : ∀ x y, Q 0 x y = actualTiltedMoment ν (inputMatrix d) (Γ 0) x y)
    (hgram : ∀ s x y, gram (R s) x y = Q s x y)
    (hstep : ∀ s, s < r → ∀ x y, Q (s + 1) x y = tiltedMoment (R s) (Γ (s + 1)) x y)
    (hΓ : ∀ s, s ≤ r → couplingMass (Γ s) ≤ (G : ℝ))
    (hβ : (∑ x, |β x|) ≤ 4 * (K : ℝ))
    (hmargin : ∀ x, (7 / 8 : ℝ) ≤ labelReal (f x) * ∑ y, β y * Q r x y) :
    ∃ w : Weights d (compressedWidth d r K G) r,
      w ∈ marginEvent Real.tanh (1 / 2) f ∧
      boundedWeights (mixedCompressedBound ν d r K G) w := by
  let E := precision r K G
  let N := compressedWidth d r K G
  let B := actualRowBound ν d E G
  have hE : 0 < E := precision_pos r K G hK
  have hN : 0 < N := TowerSamplingBudget.width_pos d E hE
  have hbudgets := actual_sampling_budgets ν d E G hE (Nat.cast_nonneg G) le_rfl
  obtain ⟨w, hw, hc⟩ := exists_mixed_finite_tower ν hd hN Q R Γ (Nat.cast_nonneg G)
    (by positivity : (0 : ℝ) ≤ 1 / (E : ℝ)) (Nat.cast_nonneg B) hbase hgram
    hbudgets.1 hbudgets.2 r hΓ hstep
  let v := withReadout w (covarianceReadout Real.tanh w β)
  refine ⟨v, ?_, ?_⟩
  · intro x
    have he := covariance_action_difference_bound (finalCovariance Real.tanh w) (Q r) β
      (show 0 ≤ (r + 1 : ℝ) * (8 * (1 + (G : ℝ)) ^ 2) ^ r * (1 / (E : ℝ)) by positivity)
      hβ hc x
    rw [show (4 * (K : ℝ)) * ((r + 1 : ℝ) * (8 * (1 + (G : ℝ)) ^ 2) ^ r *
      (1 / (E : ℝ))) = 1 / 8 from precision_error r K G hK] at he
    have hs : |labelReal (f x) * (networkOutput Real.tanh v x - ∑ y, β y * Q r x y)| ≤ 1 / 8 := by
      rw [abs_mul, abs_labelReal, one_mul]
      exact (covarianceReadout_output Real.tanh w β x) ▸ he
    have hl := (abs_le.mp hs).1
    have hm := hmargin x
    change (1 / 2 : ℝ) < labelReal (f x) * networkOutput Real.tanh v x
    nlinarith
  · intro i
    change |v i| ≤ (mixedCompressedBound ν d r K G : ℝ)
    have hBR : (B : ℝ) ≤ (mixedCompressedBound ν d r K G : ℝ) := by
      change (actualRowBound ν d E G : ℝ) ≤ ((actualRowBound ν d E G + 4 * K : ℕ) : ℝ)
      exact_mod_cast Nat.le_add_right _ _
    rcases i with ij | (sij | j)
    · exact (hw (.inl ij)).trans hBR
    · exact (hw (.inr (.inl sij))).trans hBR
    · have hb := covarianceReadout_bound w β hβ (i := j)
      have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
      have h4 := div_le_self (by positivity : (0 : ℝ) ≤ 4 * (K : ℝ)) hN1
      have hreadout : |covarianceReadout Real.tanh w β j| ≤ 4 * (K : ℝ) := hb.trans h4
      have hKR : 4 * (K : ℝ) ≤ (mixedCompressedBound ν d r K G : ℝ) := by
        simp only [mixedCompressedBound, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat]
        exact le_add_of_nonneg_left (Nat.cast_nonneg _)
      exact hreadout.trans hKR

end NeuralGeneralization.BatchTwoNonGaussian
