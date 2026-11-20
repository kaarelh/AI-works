import NeuralGeneralization.OnlineLowerReluCoverageMinimumCoordinate
import NeuralGeneralization.OnlineLowerReluLipschitz
import Mathlib.Tactic

/-!
Actual single-neuron stability used by the independent cold-prior transfer
papers. The sharp minimum-coordinate inequality is imported from the existing
repository formalization; the quantitative projection deduction is new here.
No posterior-concentration or integral-asymptotic claim is formalized here.
-/
noncomputable section
open scoped BigOperators
namespace IndependentResearch
open NeuralGeneralization
open NeuralGeneralization.OnlineLowerRelu

def signChoice (t : ℝ) : ℝ := if 0 ≤ t then 1 else -1

theorem normalized_direction_distance {n : ℕ} (b g q : ℝ) (w : Fin n → ℝ)
    (hq : 0 < q) (hdim : q ^ 2 = n)
    (hunit : b ^ 2 + ∑ i, w i ^ 2 = 1)
    (hcoord : ∀ i, g ≤ q * |w i|) :
    b ^ 2 + ∑ i, (w i - signChoice (w i) / q) ^ 2 ≤ 2 * (1 - g) := by
  have hq0 : q ≠ 0 := ne_of_gt hq
  have hp (i : Fin n) : (w i - signChoice (w i) / q) ^ 2 =
      w i ^ 2 - 2 * |w i| / q + 1 / q ^ 2 := by
    by_cases hi : 0 ≤ w i
    · simp only [signChoice, if_pos hi, abs_of_nonneg hi]
      field_simp
      ring
    · simp only [signChoice, if_neg hi, abs_of_neg (lt_of_not_ge hi)]
      field_simp
      ring
  have hc (i : Fin n) : g / q ≤ |w i| := by
    apply (div_le_iff₀ hq).2
    simpa only [mul_comm] using hcoord i
  have hsum : (n : ℝ) * (g / q) ≤ ∑ i, |w i| := by
    simpa using (Finset.sum_le_sum (s := Finset.univ) fun i _ => hc i)
  have hng : (n : ℝ) * (g / q) = g * q := by
    rw [← hdim]
    field_simp
  rw [hng] at hsum
  have havg : g ≤ (∑ i, |w i|) / q := (le_div_iff₀ hq).2 hsum
  have hone : (n : ℝ) / q ^ 2 = 1 := by rw [← hdim]; exact div_self (pow_ne_zero _ hq0)
  have hdist : b ^ 2 + (∑ i, (w i - signChoice (w i) / q) ^ 2) =
      b ^ 2 + (∑ i, w i ^ 2) - 2 * (∑ i, |w i|) / q + (n : ℝ) / q ^ 2 := by
    simp_rw [hp]
    simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.sum_div, ← Finset.mul_sum, Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    ring
  rw [hunit, hone] at hdist
  rw [mul_div_assoc] at hdist
  linarith

def parityAtomRho (n : ℕ) : ℝ :=
  (((n-2).choose ((n-2)/2) : ℝ) / (2 : ℝ)^(n-1)) / Real.sqrt n

theorem parityAtomRho_pos (n : ℕ) (hn : 2 ≤ n) : 0 < parityAtomRho n := by
  unfold parityAtomRho
  apply div_pos
  · apply div_pos
    · exact_mod_cast Nat.choose_pos (Nat.div_le_self (n-2) 2)
    · positivity
  · apply Real.sqrt_pos.2
    exact_mod_cast (show 0 < n by omega)

/-- An actual normalized affine ReLU direction lies close to its balanced,
zero-bias sign direction whenever its full-parity coefficient is near sharp. -/
theorem relu_unit_direction_projection (n : ℕ) (hn : 2 ≤ n)
    (b : ℝ) (w : Fin n → ℝ) (hunit : b ^ 2 + ∑ i, w i ^ 2 = 1) :
    b ^ 2 + ∑ i, (w i - signChoice (w i) / Real.sqrt n) ^ 2 ≤
      2 * (1 - |walshCoefficients (fun x => max (cubeAffine b w x) 0) Finset.univ|
                    / parityAtomRho n) := by
  have hn0 : (0 : ℝ) < n := by exact_mod_cast (show 0 < n by omega)
  have hs : 0 < Real.sqrt (n : ℝ) := Real.sqrt_pos.2 hn0
  apply normalized_direction_distance b _ (Real.sqrt n) w hs (Real.sq_sqrt hn0.le) hunit
  intro i
  apply (div_le_iff₀ (parityAtomRho_pos n hn)).2
  have h := relu_minimum_coordinate_parity_bound n hn b w i
  calc
    _ ≤ (((n-2).choose ((n-2)/2) : ℝ)/(2 : ℝ)^(n-1)) * |w i| := h
    _ = _ := by
      unfold parityAtomRho
      field_simp

/-- The corresponding error is measured on the actual uniform Boolean cube,
using the repository's affine ReLU definition and population-L2 convention. -/
theorem relu_unit_feature_projection (n : ℕ) (hn : 2 ≤ n)
    (b : ℝ) (w : Fin n → ℝ) (hunit : b ^ 2 + ∑ i, w i ^ 2 = 1) :
    uniformCubeMean (fun x =>
      (max (cubeAffine b w x) 0 -
       max (cubeAffine 0 (fun i => signChoice (w i) / Real.sqrt n) x) 0) ^ 2) ≤
      2 * (1 - |walshCoefficients (fun x => max (cubeAffine b w x) 0) Finset.univ|
                    / parityAtomRho n) := by
  have h := relu_neuron_l2_difference_le b 0 w (fun i => signChoice (w i) / Real.sqrt n)
  simp only [sub_zero] at h
  exact h.trans (relu_unit_direction_projection n hn b w hunit)

/-- Finite weighted Cauchy--Schwarz and cube averaging, stated independently
of ReLU so that both the original and sign-modulated coefficients can use it. -/
theorem cube_weighted_projection_bound {n : ℕ} {ι : Type*} [Fintype ι]
    (coeff : ι → ℝ) (error : ι → ClippingCube n → ℝ) (gap : ι → ℝ)
    (E d : ℝ) (hE : 0 ≤ E) (hmass : ∑ i, |coeff i| ≤ E)
    (hgap : ∑ i, |coeff i| * gap i ≤ d)
    (herror : ∀ i, uniformCubeMean (fun x => error i x ^ 2) ≤ 2 * gap i) :
    uniformCubeMean (fun x => (∑ i, coeff i * error i x) ^ 2) ≤ 2 * E * d := by
  have hpoint (x : ClippingCube n) :
      (∑ i, coeff i * error i x) ^ 2 ≤
      (∑ i, |coeff i|) * ∑ i, |coeff i| * error i x ^ 2 := by
    apply Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul Finset.univ
      (f := fun i => |coeff i|) (g := fun i => |coeff i| * error i x ^ 2)
      (fun i _ => abs_nonneg _) (fun i _ => mul_nonneg (abs_nonneg _) (sq_nonneg _))
    intro i _
    have he : (coeff i * error i x) ^ 2 = |coeff i| * (|coeff i| * error i x ^ 2) := by
      rw [mul_pow, ← sq_abs (coeff i)]
      ring
    exact he.le
  have havg : uniformCubeMean (fun x => (∑ i, |coeff i|) * ∑ i, |coeff i| * error i x ^ 2) =
      (∑ i, |coeff i|) * ∑ i, |coeff i| * uniformCubeMean (fun x => error i x ^ 2) := by
    simp only [uniformCubeMean, div_eq_mul_inv, Finset.mul_sum, Finset.sum_mul]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro x _
    apply Finset.sum_congr rfl
    intro l _
    ring
  have hnonneg : 0 ≤ ∑ i, |coeff i| * uniformCubeMean (fun x => error i x ^ 2) := by
    apply Finset.sum_nonneg
    intro i _
    apply mul_nonneg (abs_nonneg _)
    unfold uniformCubeMean
    positivity
  have htotal : (∑ i, |coeff i| * uniformCubeMean (fun x => error i x ^ 2)) ≤ 2 * d := by
    calc
      _ ≤ ∑ i, |coeff i| * (2 * gap i) := Finset.sum_le_sum fun i _ =>
        mul_le_mul_of_nonneg_left (herror i) (abs_nonneg _)
      _ = 2 * ∑ i, |coeff i| * gap i := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro i _
        ring
      _ ≤ 2 * d := mul_le_mul_of_nonneg_left hgap (by norm_num)
  calc
    _ ≤ uniformCubeMean (fun x => (∑ i, |coeff i|) * ∑ i, |coeff i| * error i x ^ 2) :=
      uniformCubeMean_mono _ _ hpoint
    _ = (∑ i, |coeff i|) * ∑ i, |coeff i| * uniformCubeMean (fun x => error i x ^ 2) := havg
    _ ≤ E * ∑ i, |coeff i| * uniformCubeMean (fun x => error i x ^ 2) :=
      mul_le_mul_of_nonneg_right hmass hnonneg
    _ ≤ E * (2 * d) := mul_le_mul_of_nonneg_left htotal hE
    _ = _ := by ring

/-- The actual finite normalized-neuron projection estimate. The readouts
may have arbitrary signs. In the paper their values are `a_i R_i / N`,
and `d` is the product-weighted parity deficit divided by `rho`. -/
theorem relu_finite_network_projection (n : ℕ) (hn : 2 ≤ n)
    {ι : Type*} [Fintype ι] (coeff bias : ι → ℝ) (weights : ι → Fin n → ℝ)
    (E d : ℝ) (hE : 0 ≤ E) (hmass : ∑ i, |coeff i| ≤ E)
    (hunit : ∀ i, bias i ^ 2 + ∑ l, weights i l ^ 2 = 1)
    (hgap : ∑ i, |coeff i| *
      (1 - |walshCoefficients (fun x => max (cubeAffine (bias i) (weights i) x) 0) Finset.univ|
          / parityAtomRho n) ≤ d) :
    uniformCubeMean (fun x => (∑ i, coeff i *
      (max (cubeAffine (bias i) (weights i) x) 0 -
       max (cubeAffine 0 (fun l => signChoice (weights i l) / Real.sqrt n) x) 0)) ^ 2) ≤
      2 * E * d := by
  apply cube_weighted_projection_bound coeff _ _ E d hE hmass hgap
  intro i
  exact relu_unit_feature_projection n hn (bias i) (weights i) (hunit i)

end IndependentResearch
