import NeuralGeneralization.OnlineLowerTanhMoments
import NeuralGeneralization.Activation

/-! # Elementary exact bounds for actual finite-cube tanh coefficients -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

theorem parityCorrelation_eq_cubeMean {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    parityCorrelation u b = cubeMean (fun x => paritySign x * Real.tanh (b + incomingLinear u x)) := by
  simp only [parityCorrelation, cubeMean, Cube, Fintype.card_fun, Fintype.card_bool,
    Fintype.card_fin, Nat.cast_pow, Nat.cast_ofNat]

theorem cubeMean_nonneg {n : ℕ} (f : Cube n → ℝ) (h : ∀ x, 0 ≤ f x) :
    0 ≤ cubeMean f :=
  mul_nonneg (inv_nonneg.mpr (pow_nonneg (by norm_num) _))
    (Finset.sum_nonneg (fun x _ => h x))

theorem cubeMean_mono {n : ℕ} (f g : Cube n → ℝ) (h : ∀ x, f x ≤ g x) :
    cubeMean f ≤ cubeMean g :=
  mul_le_mul_of_nonneg_left (Finset.sum_le_sum (fun x _ => h x))
    (inv_nonneg.mpr (pow_nonneg (by norm_num) _))

theorem cubeMean_neg {n : ℕ} (f : Cube n → ℝ) :
    cubeMean (fun x => -f x) = -cubeMean f := by
  simp [cubeMean, Finset.sum_neg_distrib]

theorem cubeMean_sub {n : ℕ} (f g : Cube n → ℝ) :
    cubeMean (fun x => f x - g x) = cubeMean f - cubeMean g := by
  simp [cubeMean, Finset.sum_sub_distrib, mul_sub]

theorem cubeMean_equiv {n : ℕ} (e : Cube n ≃ Cube n) (f : Cube n → ℝ) :
    cubeMean (fun x => f (e x)) = cubeMean f := by
  unfold cubeMean
  rw [e.sum_comp]

theorem abs_cubeMean_le {n : ℕ} (f : Cube n → ℝ) :
    |cubeMean f| ≤ cubeMean (fun x => |f x|) := by
  unfold cubeMean
  rw [abs_mul, abs_of_nonneg (by positivity : 0 ≤ ((2 : ℝ)^n)⁻¹)]
  exact mul_le_mul_of_nonneg_left (Finset.abs_sum_le_sum_abs _ _) (by positivity)

theorem incomingEnergy_nonneg {n : ℕ} (u : Fin n → ℝ) : 0 ≤ incomingEnergy u :=
  Finset.sum_nonneg (fun _ _ => sq_nonneg _)

theorem coordinate_sq_le_energy {n : ℕ} (u : Fin n → ℝ) (i : Fin n) :
    u i ^ 2 ≤ incomingEnergy u :=
  Finset.single_le_sum (fun _ _ => sq_nonneg _) (Finset.mem_univ _)

theorem tanh_abs_sub_le (a b : ℝ) : |Real.tanh a - Real.tanh b| ≤ |a-b| := by
  simpa only [Real.dist_eq, NNReal.coe_one, one_mul] using
    tanh_lipschitzWith.dist_le_mul a b

/-- A selected-coordinate finite difference gives a bound without any
intrinsic sharp-parity hypothesis, in every degree and at every bias. -/
theorem parityCorrelation_abs_le_coordinate {n : ℕ}
    (u : Fin n → ℝ) (b : ℝ) (i : Fin n) : |parityCorrelation u b| ≤ |u i| := by
  let f := fun x : Cube n => paritySign x * Real.tanh (b + incomingLinear u x)
  have hflip : cubeMean (fun x => paritySign x *
      Real.tanh (b + incomingLinear u (cubeFlip i x))) = -parityCorrelation u b := by
    calc
      _ = -cubeMean (fun x => f (cubeFlip i x)) := by
        rw [← cubeMean_neg]
        apply cubeMean_congr
        intro x
        simp only [f, paritySign_flip]
        ring
      _ = -parityCorrelation u b := by rw [cubeMean_equiv, parityCorrelation_eq_cubeMean]
  have hdiff : cubeMean (fun x => paritySign x *
      (Real.tanh (b + incomingLinear u x) - Real.tanh (b + incomingLinear u (cubeFlip i x)))) =
        2 * parityCorrelation u b := by
    simp_rw [mul_sub]
    rw [cubeMean_sub, hflip, ← parityCorrelation_eq_cubeMean]
    ring
  have hpoint (x : Cube n) : |paritySign x *
      (Real.tanh (b + incomingLinear u x) - Real.tanh (b + incomingLinear u (cubeFlip i x)))| ≤
        2 * |u i| := by
    rw [abs_mul, abs_paritySign, one_mul]
    apply (tanh_abs_sub_le _ _).trans
    rw [incomingLinear_flip]
    have he : b + incomingLinear u x - (b + (incomingLinear u x - 2 * u i * labelReal (x i))) =
        2 * u i * labelReal (x i) := by ring
    rw [he, abs_mul, abs_mul]
    cases h : x i <;> simp [labelReal]
  have habs := (abs_cubeMean_le _).trans (cubeMean_mono _ _ hpoint)
  rw [hdiff, cubeMean_const, abs_mul] at habs
  norm_num at habs
  linarith

/-- The exact bias-transfer identity upgrades a sharp intrinsic bound to
the full selected-coordinate affine bound. -/
theorem intrinsicParityBound_affine {n : ℕ} (hn : Odd n) (w : ℝ) (hw : 0 ≤ w)
    (hsharp : IntrinsicParityBound n w) (u : Fin n → ℝ) (b : ℝ) :
    w * |parityCorrelation u b| ≤ Real.sqrt (b^2 + incomingEnergy u) := by
  let i : Fin n := ⟨0, hn.pos⟩
  have h := intrinsic_bound_biasTransfer hn w hw hsharp u i b
  have hpair := sqrtPair_le (incomingEnergy u + b^2) (2*u i*b)
    (biasTransfer_abs_le _ _ _ (coordinate_sq_le_energy u i))
  exact (h.trans hpair).trans_eq (by congr 1; ring)

end NeuralGeneralization.OnlineLowerTanh
