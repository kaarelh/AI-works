import NeuralGeneralization.OnlineLowerTanhSigns
import NeuralGeneralization.OnlineLowerTanhScalarBounds
import NeuralGeneralization.OnlineLowerReluMonotone

/-! The sharp monotone Boolean-cube cap for an actual tanh coefficient.
This bound is independent of the incoming scale and bias. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLowerRelu

theorem tanh_monotone : Monotone Real.tanh :=
  (strictMono_of_hasDerivAt_pos ConcreteModel.hasDerivAt_tanh
    (fun x => by positivity)).monotone

theorem incomingLinear_negativeSet {n : ℕ} (u : Fin n → ℝ) (S : Finset (Fin n)) :
    incomingLinear u ((negativeSetEquiv n).symm S) = (∑ i, u i)-2*∑ i ∈ S, u i := by
  unfold incomingLinear
  have hsign (i : Fin n) : labelReal ((negativeSetEquiv n).symm S i) =
      if i ∈ S then -1 else 1 := negativeSet_sign n S i
  simp_rw [hsign]
  have hterm (i : Fin n) : u i * (if i ∈ S then (-1:ℝ) else 1) =
      u i - 2*(if i ∈ S then u i else 0) := by split_ifs <;> ring
  simp_rw [hterm, Finset.sum_sub_distrib, ← Finset.mul_sum]
  simp

theorem sum_subset_parity_zero (n : ℕ) :
    (∑ S : Finset (Fin (n+1)), (-1:ℝ)^S.card) = 0 := by
  have hzero : (∑ x : Cube (n+1), paritySign x) = 0 := by
    have h := (cubeFlip (0 : Fin (n+1))).sum_comp (fun x => paritySign x)
    simp only [paritySign_flip, Finset.sum_neg_distrib] at h
    linarith
  have h := (negativeSetEquiv (n+1)).symm.sum_comp (fun x => paritySign x)
  have hp (S : Finset (Fin (n+1))) :
      paritySign ((negativeSetEquiv (n+1)).symm S) = (-1:ℝ)^S.card :=
    negativeSet_full_parity _ S
  simp_rw [hp] at h
  exact h.trans hzero

theorem parityCorrelation_negativeSet {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    parityCorrelation u b =
      (∑ S : Finset (Fin n), (-1:ℝ)^S.card *
        Real.tanh (b+(∑ i, u i)-2*∑ i ∈ S, u i)) / 2^n := by
  unfold parityCorrelation
  rw [← Equiv.sum_comp (negativeSetEquiv n).symm]
  have hp (S : Finset (Fin n)) :
      paritySign ((negativeSetEquiv n).symm S) = (-1:ℝ)^S.card :=
    negativeSet_full_parity _ S
  simp_rw [hp, incomingLinear_negativeSet]
  simp only [Cube, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin,
    Nat.cast_pow, Nat.cast_ofNat]
  rw [div_eq_mul_inv, mul_comm]
  congr 1
  apply Finset.sum_congr rfl
  intro S _
  congr 2
  ring

/-- The unnormalized monotone estimate transfers through the actual
negative-set cube bijection. -/
theorem parityCorrelation_monotone_cap_nonneg (r : ℕ) (u : Fin (2*r+1) → ℝ)
    (hu : ∀ i, 0 ≤ u i) (b : ℝ) :
    |parityCorrelation u b| ≤ oddParityKappa r := by
  let score : Finset (Fin (2*r+1)) → ℝ :=
    fun S => b+(∑ i, u i)-2*∑ i ∈ S, u i
  let f : Finset (Fin (2*r+1)) → ℝ := fun S => (1-Real.tanh (score S))/2
  have hmono : Monotone f := by
    intro S T hST
    have hsum : (∑ i ∈ S, u i) ≤ ∑ i ∈ T, u i :=
      Finset.sum_le_sum_of_subset_of_nonneg hST (fun i _ _ => hu i)
    have hscore : score T ≤ score S := by dsimp [score]; linarith
    have h := tanh_monotone hscore
    dsimp [f]
    linarith
  have hzero (S) : 0 ≤ f S := by
    have h := (abs_lt.mp (Real.abs_tanh_lt_one (score S))).2
    dsimp [f]
    linarith
  have hone (S) : f S ≤ 1 := by
    have h := (abs_lt.mp (Real.abs_tanh_lt_one (score S))).1
    dsimp [f]
    linarith
  have hcap := monotone_subset_parity_bound (2*r) f hmono hzero hone
  have hsum : (∑ S : Finset (Fin (2*r+1)), (-1:ℝ)^S.card * Real.tanh (score S)) =
      -2 * ∑ S : Finset (Fin (2*r+1)), (-1:ℝ)^S.card * f S := by
    have hp := sum_subset_parity_zero (2*r)
    rw [Finset.mul_sum]
    have hpoint (S : Finset (Fin (2*r+1))) :
        -2*((-1:ℝ)^S.card*f S) = (-1:ℝ)^S.card*Real.tanh (score S)-
          (-1:ℝ)^S.card := by dsimp [f]; ring
    simp_rw [hpoint]
    rw [Finset.sum_sub_distrib, hp]
    ring
  rw [parityCorrelation_negativeSet]
  change |(∑ S : Finset (Fin (2*r+1)), (-1:ℝ)^S.card*Real.tanh (score S))/2^(2*r+1)| ≤ _
  rw [hsum, abs_div, abs_mul]
  rw [abs_of_pos (by positivity : (0:ℝ)<2^(2*r+1))]
  norm_num only [abs_neg, abs_of_pos (by norm_num : (0:ℝ)<2)]
  have hscale : (2:ℝ)^(2*r+1) = 2*4^r := by rw [pow_add, pow_mul]; norm_num; ring
  rw [hscale]
  have hcap' : |∑ S, (-1:ℝ)^S.card*f S| ≤ (Nat.centralBinom r:ℝ) := by
    simpa [Nat.centralBinom] using hcap
  unfold oddParityKappa
  calc
    2*|∑ S, (-1:ℝ)^S.card*f S|/(2*4^r) ≤
        2*(Nat.centralBinom r:ℝ)/(2*4^r) := by
      exact div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left hcap' (by norm_num)) (by positivity)
    _ = (Nat.centralBinom r:ℝ)/4^r := by field_simp

/-- Arbitrary incoming signs and arbitrary bias satisfy the same cap. -/
theorem parityCorrelation_monotone_cap (r : ℕ) (u : Fin (2*r+1) → ℝ) (b : ℝ) :
    |parityCorrelation u b| ≤ oddParityKappa r := by
  rw [parityCorrelation_abs_weights]
  exact parityCorrelation_monotone_cap_nonneg r _ (fun i => abs_nonneg _) b

/-- A simple explicit square-root normalization sufficient for localization. -/
theorem parityCorrelation_sqrt_cap (r : ℕ) (u : Fin (2*r+1) → ℝ) (b : ℝ) :
    Real.sqrt (2*r+1:ℕ)*|parityCorrelation u b| ≤ 2 := by
  have hcap := parityCorrelation_monotone_cap r u b
  have hk := evenReluKappa_mul_sqrt_le_one r
  have hroot : Real.sqrt (2*r+1:ℕ) ≤ Real.sqrt (2*(r+1:ℝ)) := by
    apply Real.sqrt_le_sqrt
    push_cast
    linarith
  rw [oddParityKappa_eq_twice_relu] at hcap
  have h := mul_le_mul_of_nonneg_left hcap (Real.sqrt_nonneg (2*r+1:ℕ))
  have hh := mul_le_mul_of_nonneg_left hroot (evenReluKappa_pos r).le
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
