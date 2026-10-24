import NeuralGeneralization.BatchTwoShallowStability
import NeuralGeneralization.RobustModelContinuity

/-! In one hidden layer the calibrated simultaneous perturbation ball changes
the output by at most the calibration. A margin buffer therefore certifies
the original (not neuron-merging) prior restriction. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel

theorem weighted_cauchy {ι : Type*} [Fintype ι] (a b : ι → ℝ) (c : ℝ)
    {s : ℝ} (hs : 0 < s) :
    ((∑ i, a i*b i)+c)^2 ≤ (1+s*(∑ i, a i^2))*((∑ i, b i^2)/s+c^2) := by
  classical
  let A : Option ι → ℝ := fun i => match i with
    | none => 1
    | some j => Real.sqrt s*a j
  let B : Option ι → ℝ := fun i => match i with
    | none => c
    | some j => b j/Real.sqrt s
  have hp : 0 < Real.sqrt s := Real.sqrt_pos.mpr hs
  have hab : (∑ i : Option ι, A i*B i) = (∑ i, a i*b i)+c := by
    simp only [Fintype.sum_option, A, B, one_mul]
    have he (i : ι) : Real.sqrt s*a i*(b i/Real.sqrt s) = a i*b i := by field_simp
    simp_rw [he]
    ring
  have ha : (∑ i : Option ι, A i^2) = 1+s*∑ i, a i^2 := by
    simp only [Fintype.sum_option, A, one_pow, mul_pow, Real.sq_sqrt hs.le, Finset.mul_sum]
  have hb : (∑ i : Option ι, B i^2) = (∑ i, b i^2)/s+c^2 := by
    simp only [Fintype.sum_option, B, div_pow, Real.sq_sqrt hs.le, Finset.sum_div]
    ring
  have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ A B
  rwa [hab, ha, hb] at h

theorem shallow_noisy_diff {d N : ℕ} (φ : ℝ → ℝ) (w : Weights d N 0)
    (x : Cube d) (η : NetworkDisturbance N 0) :
    noisyNetworkOutput φ w x η-networkOutput φ w x =
      (∑ i, w (Sum.inr (Sum.inr i))*η.1 0 i)+η.2 := by
  simp only [noisyNetworkOutput, networkOutput, noisyFinalHidden, finalHidden,
    List.finRange_zero, List.foldl_nil, noisyFirstHidden]
  simp only [mul_add, Finset.sum_add_distrib]
  ring

theorem shallow_noise_bound {d N : ℕ} (hN : 0 < N) (φ : ℝ → ℝ) (w : Weights d N 0)
    (x : Cube d) (η : NetworkDisturbance N 0) {c : ℝ} (hc : 0 ≤ c)
    (hη : noiseBudgetSq η ≤ (robustRadius c w)^2) :
    |noisyNetworkOutput φ w x η-networkOutput φ w x| ≤ c := by
  have hNpos : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  have he : 0 < 1+readoutEnergy w := by have := readoutEnergy_nonneg w; linarith
  have hsqrt : 0 < Real.sqrt (1+readoutEnergy w) := Real.sqrt_pos.mpr he
  have hbudget : noiseBudgetSq η = (∑ i, (η.1 0 i)^2)/(N : ℝ)+η.2^2 := by
    simp [noiseBudgetSq]
  have hCS := weighted_cauchy (fun i => w (Sum.inr (Sum.inr i))) (η.1 0) η.2 hNpos
  rw [← readoutEnergy, ← hbudget, ← shallow_noisy_diff φ w x η] at hCS
  have hmul := mul_le_mul_of_nonneg_left hη he.le
  have heq : (1+readoutEnergy w)*(robustRadius c w)^2 = c^2 := by
    simp only [robustRadius, Nat.cast_zero, zero_add, one_mul, div_pow, Real.sq_sqrt he.le]
    field_simp
  rw [heq] at hmul
  apply (sq_le_sq₀ (abs_nonneg _) hc).mp
  rw [sq_abs]
  exact hCS.trans hmul

theorem shallow_robust_of_margin {d N : ℕ} (hN : 0 < N) (φ : ℝ → ℝ)
    (w : Weights d N 0) (f : BooleanFunction d) {c : ℝ} (hc : 0 ≤ c)
    (hmargin : ∀ x, c+1/2 ≤ labelReal (f x)*networkOutput φ w x) :
    w ∈ robustEvent φ c := by
  apply mem_robustEvent_of_uniform_noisy_margin φ c w f
  intro x η hη
  have hn := shallow_noise_bound hN φ w x η hc hη
  have he : |labelReal (f x)*(noisyNetworkOutput φ w x η-networkOutput φ w x)| ≤ c := by
    simpa only [abs_mul, abs_labelReal, one_mul] using hn
  have hdiff := (abs_le.mp he).1
  nlinarith [hmargin x]

theorem readoutL1_sq_le_energy {d N : ℕ} (w : Weights d N 0) :
    (readoutL1 w)^2 ≤ readoutEnergy w := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun i : Fin N => |w (Sum.inr (Sum.inr i))|) (fun _ => (1 : ℝ))
  simpa only [readoutL1, readoutEnergy, mul_one, one_pow, sq_abs,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one, mul_comm, one_mul] using h

theorem readoutL1_le_of_energy {d N : ℕ} (w : Weights d N 0) {B : ℝ}
    (hB : 0 ≤ B) (hE : readoutEnergy w ≤ B^2) : readoutL1 w ≤ B := by
  exact (sq_le_sq₀ (Finset.sum_nonneg fun _ _ => abs_nonneg _) hB).mp
    ((readoutL1_sq_le_energy w).trans hE)

end NeuralGeneralization.BatchTwoShallow
