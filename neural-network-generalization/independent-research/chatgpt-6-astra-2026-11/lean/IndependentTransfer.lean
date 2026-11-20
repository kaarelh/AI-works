import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.InnerProductSpace.Orthonormal
import Mathlib.Tactic

/-!
Selected deterministic lemmas for the independent-research transfer papers.
This file does not formalize Bayesian conditioning, the Fourier-integral bounds,
or the asymptotic theorems. Its scope is finite-dimensional geometry and the
square-objective identity. No results from the new papers are assumed as axioms.
-/

noncomputable section
namespace IndependentResearch
open scoped BigOperators InnerProductSpace

/-- The exact source square-risk decomposition, separated from the analytic
proof that `deficit` is nonnegative for a ReLU network. -/
theorem square_objective_identity (energy correlation squareNorm rho : ℝ) :
    rho * energy + (1 - 2 * correlation + squareNorm) - 3 / 4 =
      (rho * energy - correlation) + (squareNorm - correlation + 1 / 4) := by
  ring

/-- A nonnegative regularized objective gap controls both nonnegative terms. -/
theorem nonnegative_gap_controls_terms {deficit error gap : ℝ}
    (hd : 0 ≤ deficit) (he : 0 ≤ error) (h : deficit + error ≤ gap) :
    deficit ≤ gap ∧ error ≤ gap := by
  constructor <;> linarith

section Hilbert
variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℝ H]

/-- Weighted Cauchy--Schwarz for a finite sum of feature errors. -/
theorem norm_sum_weighted_sq_le {ι : Type*} [Fintype ι]
    (coeff : ι → ℝ) (errors : ι → H) :
    ‖∑ i, coeff i • errors i‖ ^ 2 ≤
      (∑ i, |coeff i|) * ∑ i, |coeff i| * ‖errors i‖ ^ 2 := by
  have hn : ‖∑ i, coeff i • errors i‖ ≤ ∑ i, |coeff i| * ‖errors i‖ := by
    simpa only [norm_smul, Real.norm_eq_abs] using
      (norm_sum_le (s := Finset.univ) (f := fun i => coeff i • errors i))
  have hs := mul_self_le_mul_self (norm_nonneg _) hn
  have hc := Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul Finset.univ
    (r := fun i => |coeff i| * ‖errors i‖)
    (f := fun i => |coeff i|) (g := fun i => |coeff i| * ‖errors i‖ ^ 2)
    (fun i _ => abs_nonneg _) (fun i _ => mul_nonneg (abs_nonneg _) (sq_nonneg _))
    (fun i _ => le_of_eq (by ring))
  have hs' : ‖∑ i, coeff i • errors i‖ ^ 2 ≤ (∑ i, |coeff i| * ‖errors i‖) ^ 2 := by
    simpa only [← pow_two] using hs
  exact hs'.trans hc

/-- Product-weighted directional deficits control the full output error.
In the ReLU application `coeff i = a_i R_i / N`, and the errors are
the unit incoming-feature changes after projection to critical directions. -/
theorem norm_sum_sq_le_of_deficit {ι : Type*} [Fintype ι]
    (coeff : ι → ℝ) (errors : ι → H) (deficit : ι → ℝ) (E d : ℝ)
    (hE : 0 ≤ E) (hmass : ∑ i, |coeff i| ≤ E)
    (hdeficit : ∑ i, |coeff i| * deficit i ≤ d)
    (herror : ∀ i, ‖errors i‖ ^ 2 ≤ 2 * deficit i) :
    ‖∑ i, coeff i • errors i‖ ^ 2 ≤ 2 * E * d := by
  have hsum : (∑ i, |coeff i| * ‖errors i‖ ^ 2) ≤ 2 * d := by
    calc
      _ ≤ ∑ i, |coeff i| * (2 * deficit i) := Finset.sum_le_sum fun i _ =>
        mul_le_mul_of_nonneg_left (herror i) (abs_nonneg _)
      _ = 2 * ∑ i, |coeff i| * deficit i := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro i _
        ring
      _ ≤ 2 * d := mul_le_mul_of_nonneg_left hdeficit (by norm_num)
  calc
    _ ≤ (∑ i, |coeff i|) * ∑ i, |coeff i| * ‖errors i‖ ^ 2 :=
      norm_sum_weighted_sq_le coeff errors
    _ ≤ E * ∑ i, |coeff i| * ‖errors i‖ ^ 2 :=
      mul_le_mul_of_nonneg_right hmass
        (Finset.sum_nonneg fun i _ => mul_nonneg (abs_nonneg _) (sq_nonneg _))
    _ ≤ E * (2 * d) := mul_le_mul_of_nonneg_left hsum hE
    _ = _ := by ring

/-- A bounded modulation operator transports source approximation after
two controlled feature projections. The Fourier coefficient-ratio bound
supplies `hT` in the parity-transfer application. -/
theorem modulation_transfer_error (T : H →L[ℝ] H)
    (original projected modulated source : H) (u v C : ℝ)
    (hC : 0 ≤ C) (hT : ‖T‖ ≤ C)
    (hp : ‖projected - original‖ ≤ v)
    (hm : ‖modulated - T projected‖ ≤ v)
    (hs : ‖original - source‖ ≤ u) :
    ‖modulated - T source‖ ≤ (1 + C) * v + C * u := by
  have hps : ‖projected - source‖ ≤ v + u :=
    (norm_sub_le_norm_sub_add_norm_sub projected original source).trans (add_le_add hp hs)
  calc
    _ ≤ ‖modulated - T projected‖ + ‖T projected - T source‖ :=
      norm_sub_le_norm_sub_add_norm_sub _ _ _
    _ ≤ v + ‖T (projected - source)‖ := by rw [map_sub]; exact add_le_add hm le_rfl
    _ ≤ v + C * ‖projected - source‖ := by
      gcongr
      exact (T.le_opNorm _).trans (mul_le_mul_of_nonneg_right hT (norm_nonneg _))
    _ ≤ v + C * (v + u) := add_le_add le_rfl (mul_le_mul_of_nonneg_left hps hC)
    _ = _ := by ring

/-- Approximation of a unit target forces a positive correlation. -/
theorem approximation_correlation_lower (f g : H) (a : ℝ)
    (hf : ‖f‖ = 1) (happrox : ‖g - f‖ ≤ a) :
    1 - a ≤ ⟪g, f⟫_ℝ := by
  have hcs := abs_real_inner_le_norm (g - f) f
  rw [hf, mul_one] at hcs
  have hi : ⟪g - f, f⟫_ℝ = ⟪g, f⟫_ℝ - 1 := by
    rw [inner_sub_left, real_inner_self_eq_norm_sq, hf]
    norm_num
  rw [hi] at hcs
  have hlo := neg_abs_le (⟪g, f⟫_ℝ - 1)
  linarith

/-- The feature representation's correlation obeys coefficient Cauchy--Schwarz. -/
theorem finite_feature_correlation_bound {ι : Type*} [Fintype ι]
    (coeff featureCorrelation : ι → ℝ) :
    (∑ i, coeff i * featureCorrelation i) ^ 2 ≤
      (∑ i, coeff i ^ 2) * (∑ i, featureCorrelation i ^ 2) := by
  exact Finset.sum_mul_sq_le_sq_mul_sq Finset.univ coeff featureCorrelation


/-- Bessel's inequality summed over a finite feature map. All inner products
use the Hilbert-space normalization selected by the caller. -/
theorem total_feature_correlation_le_trace {ι J : Type*}
    [Fintype ι] [Fintype J] (features : ι → H) (targets : J → H)
    (horth : Orthonormal ℝ targets) :
    (∑ j, ∑ i, ⟪targets j, features i⟫_ℝ ^ 2) ≤
      ∑ i, ‖features i‖ ^ 2 := by
  rw [Finset.sum_comm]
  apply Finset.sum_le_sum
  intro i hi
  simpa using horth.sum_inner_products_le (s := Finset.univ) (features i)

/-- A trace budget limits how many orthogonal targets have accurate
representatives with a common squared coefficient-norm budget. -/
theorem orthogonal_approximation_capacity {ι J : Type*}
    [Fintype ι] [Fintype J] (features : ι → H) (targets : J → H)
    (coeff : J → ι → ℝ) (a B : ℝ)
    (horth : Orthonormal ℝ targets) (ha : a < 1) (hB : 0 ≤ B)
    (hbudget : ∀ j, (∑ i, coeff j i ^ 2) ≤ B)
    (happrox : ∀ j, ‖(∑ i, coeff j i • features i) - targets j‖ ≤ a) :
    (Fintype.card J : ℝ) * (1 - a) ^ 2 ≤ B * ∑ i, ‖features i‖ ^ 2 := by
  have hpoint (j : J) : (1 - a) ^ 2 ≤ B * ∑ i, ⟪targets j, features i⟫_ℝ ^ 2 := by
    have hlower := approximation_correlation_lower (targets j)
      (∑ i, coeff j i • features i) a (horth.norm_eq_one j) (happrox j)
    have hpair : ⟪∑ i, coeff j i • features i, targets j⟫_ℝ =
        ∑ i, coeff j i * ⟪targets j, features i⟫_ℝ := by
      rw [sum_inner]
      apply Finset.sum_congr rfl
      intro i hi
      rw [real_inner_smul_left, real_inner_comm]
    rw [hpair] at hlower
    have hsq : (1 - a) ^ 2 ≤ (∑ i, coeff j i * ⟪targets j, features i⟫_ℝ) ^ 2 := by
      nlinarith [sq_nonneg ((∑ i, coeff j i * ⟪targets j, features i⟫_ℝ) - (1 - a))]
    have hcs := finite_feature_correlation_bound (coeff j)
      (fun i => ⟪targets j, features i⟫_ℝ)
    have hnonneg : 0 ≤ ∑ i, ⟪targets j, features i⟫_ℝ ^ 2 :=
      Finset.sum_nonneg fun i hi => sq_nonneg _
    exact hsq.trans (hcs.trans (mul_le_mul_of_nonneg_right (hbudget j) hnonneg))
  calc
    (Fintype.card J : ℝ) * (1 - a) ^ 2 = ∑ j : J, (1 - a) ^ 2 := by simp
    _ ≤ ∑ j : J, B * ∑ i, ⟪targets j, features i⟫_ℝ ^ 2 :=
      Finset.sum_le_sum fun j hj => hpoint j
    _ = B * ∑ j : J, ∑ i, ⟪targets j, features i⟫_ℝ ^ 2 := by rw [Finset.mul_sum]
    _ ≤ B * ∑ i, ‖features i‖ ^ 2 :=
      mul_le_mul_of_nonneg_left (total_feature_correlation_le_trace features targets horth) hB

/-- A separating functional gives an approximation obstruction for every
linear combination of a family of features. This includes an intercept
when the functional annihilates the constant feature. -/
theorem annihilated_feature_approximation {ι : Type*} [Fintype ι]
    (features : ι → H) (coeff : ι → ℝ) (target witness : H)
    (hzero : ∀ i, ⟪features i, witness⟫_ℝ = 0)
    (htarget : ⟪target, witness⟫_ℝ = 1) :
    1 ≤ ‖(∑ i, coeff i • features i) - target‖ * ‖witness‖ := by
  have hsum : ⟪∑ i, coeff i • features i, witness⟫_ℝ = 0 := by
    simp only [sum_inner, real_inner_smul_left, hzero, mul_zero, Finset.sum_const_zero]
  have hcs := abs_real_inner_le_norm ((∑ i, coeff i • features i) - target) witness
  rw [inner_sub_left, hsum, htarget] at hcs
  norm_num at hcs
  exact hcs

/-- Small feature perturbations preserve an approximation obstruction unless
the coefficient norm becomes large. The features here include their 1/sqrt(N)
normalization, so the error budget is a sum, not an average. -/
theorem perturbed_annihilator_bound {ι : Type*} [Fintype ι]
    (base features : ι → H) (coeff : ι → ℝ) (target witness : H)
    (a e : ℝ) (ha : 0 ≤ 1 - a * ‖witness‖)
    (hzero : ∀ i, ⟪base i, witness⟫_ℝ = 0)
    (htarget : ⟪target, witness⟫_ℝ = 1)
    (herror : ∑ i, ‖features i - base i‖ ^ 2 ≤ e ^ 2)
    (happrox : ‖(∑ i, coeff i • features i) - target‖ ≤ a) :
    (1 - a * ‖witness‖) ^ 2 ≤
      (∑ i, coeff i ^ 2) * e ^ 2 * ‖witness‖ ^ 2 := by
  let g := ∑ i, coeff i • features i
  have hnear := abs_real_inner_le_norm (g - target) witness
  rw [inner_sub_left, htarget] at hnear
  have hnear' : |⟪g, witness⟫_ℝ - 1| ≤ a * ‖witness‖ :=
    hnear.trans (mul_le_mul_of_nonneg_right happrox (norm_nonneg _))
  have hlower : 1 - a * ‖witness‖ ≤ ⟪g, witness⟫_ℝ := by
    have := neg_abs_le (⟪g, witness⟫_ℝ - 1)
    linarith
  have hpair : ⟪g, witness⟫_ℝ =
      ∑ i, coeff i * ⟪features i - base i, witness⟫_ℝ := by
    dsimp [g]
    simp only [sum_inner, real_inner_smul_left, inner_sub_left, hzero, sub_zero]
  have hcs := finite_feature_correlation_bound coeff
    (fun i => ⟪features i - base i, witness⟫_ℝ)
  have hpoint (i : ι) : ⟪features i - base i, witness⟫_ℝ ^ 2 ≤
      ‖features i - base i‖ ^ 2 * ‖witness‖ ^ 2 := by
    have h := abs_real_inner_le_norm (features i - base i) witness
    have hs := mul_self_le_mul_self (abs_nonneg _) h
    simpa only [← pow_two, sq_abs, mul_pow] using hs
  have hsum : (∑ i, ⟪features i - base i, witness⟫_ℝ ^ 2) ≤ e ^ 2 * ‖witness‖ ^ 2 := by
    calc
      _ ≤ ∑ i, ‖features i - base i‖ ^ 2 * ‖witness‖ ^ 2 :=
        Finset.sum_le_sum fun i _ => hpoint i
      _ = (∑ i, ‖features i - base i‖ ^ 2) * ‖witness‖ ^ 2 := by rw [Finset.sum_mul]
      _ ≤ _ := mul_le_mul_of_nonneg_right herror (sq_nonneg _)
  have hsq : (1 - a * ‖witness‖) ^ 2 ≤ ⟪g, witness⟫_ℝ ^ 2 := by
    nlinarith [sq_nonneg (⟪g, witness⟫_ℝ - (1 - a * ‖witness‖))]
  rw [hpair] at hsq
  calc
    _ ≤ (∑ i, coeff i * ⟪features i - base i, witness⟫_ℝ) ^ 2 := hsq
    _ ≤ (∑ i, coeff i ^ 2) * ∑ i, ⟪features i - base i, witness⟫_ℝ ^ 2 := hcs
    _ ≤ (∑ i, coeff i ^ 2) * (e ^ 2 * ‖witness‖ ^ 2) :=
      mul_le_mul_of_nonneg_left hsum (Finset.sum_nonneg fun i _ => sq_nonneg _)
    _ = _ := by ring

end Hilbert

/-- A ridge objective no larger than the zero predictor bounds coefficient norm.
The nonnegative residual term is kept explicit, including repeated observations. -/
theorem ridge_coefficient_budget {loss normSq v n : ℝ}
    (hloss : 0 ≤ loss) (hv : 0 < v)
    (hobjective : loss + v * normSq ≤ n) :
    normSq ≤ n / v := by
  apply (le_div_iff₀ hv).2
  nlinarith

end IndependentResearch
