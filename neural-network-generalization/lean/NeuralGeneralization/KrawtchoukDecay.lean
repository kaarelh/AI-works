import NeuralGeneralization.BinomialModeBound
import NeuralGeneralization.PolynomialCoefficientMajorant
import Mathlib.Analysis.SpecialFunctions.Exp

/-!
# Real-variable decay of Krawtchouk coefficients

Pair opposite signs in the generating polynomial and replace
`1-X²` by its positive coefficient majorant `1+X²`. Evaluating at the
binomial mode gives an exponential decay bound with prefactor `D+1`.
-/

noncomputable section
namespace NeuralGeneralization.KrawtchoukDecay
open Polynomial PolynomialMajorant
open scoped BigOperators

def krawtchouk (negative positive j : ℕ) : ℝ :=
  ((1-X : ℝ[X])^negative*(1+X)^positive).coeff j

theorem polynomial_pairing (b r s : ℕ) :
    (1-X : ℝ[X])^(b+r)*(1+X)^(b+s) = pairedPolynomial b r s := by
  unfold pairedPolynomial
  rw [pow_add, pow_add, show (1-X^2 : ℝ[X])=(1-X)*(1+X) by ring, mul_pow]
  ring

theorem positive_ratio_bound (t : ℝ) (ht : 0 ≤ t) :
    (1+t^2)/(1+t)^2 ≤ Real.exp (-2*t/(1+t)^2) := by
  have hp : 1+t≠0 := ne_of_gt (by linarith : 0<1+t)
  have hh := Real.add_one_le_exp (-2*t/(1+t)^2)
  convert hh using 1 <;> field_simp <;> ring

theorem paired_coefficient_decay (b r s j : ℕ)
    (hj : 0 < j) (hjD : j < 2*b+r+s) :
    |(pairedPolynomial b r s).coeff j| / ((2*b+r+s).choose j:ℝ) ≤
      ((2*b+r+s+1:ℕ):ℝ)*Real.exp (-(2*(b:ℝ)*j*(2*b+r+s-j:ℕ))/((2*b+r+s:ℕ):ℝ)^2) := by
  let D : ℕ := 2*b+r+s
  let t : ℝ := (j:ℝ)/(D-j:ℕ)
  let q : ℝ := (1+t^2)/(1+t)^2
  have hden : (0:ℝ)<(D-j:ℕ) := by exact_mod_cast Nat.sub_pos_of_lt hjD
  have ht : 0 < t := by dsimp only [t]; positivity
  have htp : 0 < 1+t := by linarith
  have hq : 0 ≤ q := by dsimp only [q]; positivity
  have hpoly := paired_polynomial_bound b r s j t ht.le
  have hmode := BinomialMode.modal_mass_lower hjD
  change (1+t)^D ≤ (D+1:ℝ)*(D.choose j:ℝ)*t^j at hmode
  have heval : (1+t^2)^b*(1+t)^(r+s) = q^b*(1+t)^D := by
    change (1+t^2)^b*(1+t)^(r+s) = ((1+t^2)/(1+t)^2)^b*(1+t)^(2*b+r+s)
    rw [div_pow (1+t^2) ((1+t)^2) b, show 2*b+r+s=2*b+(r+s) by omega,
      pow_add (1+t) (2*b) (r+s), pow_mul (1+t) 2 b]
    field_simp
  rw [heval] at hpoly
  have hweighted := hpoly.trans (mul_le_mul_of_nonneg_left hmode (pow_nonneg hq b))
  have hraw : |(pairedPolynomial b r s).coeff j| ≤ q^b*(D+1:ℝ)*(D.choose j:ℝ) := by
    apply (mul_le_mul_iff_left₀ (pow_pos ht j)).mp
    convert hweighted using 1 <;> ring
  have hpower := pow_le_pow_left₀ hq (positive_ratio_bound t ht.le) b
  rw [← Real.exp_nat_mul] at hpower
  have hDpos : (0:ℝ)<D := by exact_mod_cast (hj.trans hjD)
  have he : (b:ℝ)*(-2*t/(1+t)^2) = -(2*(b:ℝ)*j*(D-j:ℕ))/(D:ℝ)^2 := by
    have hsum : 1+t = (D:ℝ)/(D-j:ℕ) := by
      dsimp only [t]
      apply (eq_div_iff (ne_of_gt hden)).mpr
      rw [add_mul, div_mul_cancel₀ _ (ne_of_gt hden), one_mul, Nat.cast_sub hjD.le]
      ring
    rw [hsum, div_pow]
    dsimp only [t]
    field_simp
  rw [he] at hpower
  have hc : (0:ℝ)<D.choose j := Nat.cast_pos.mpr (Nat.choose_pos hjD.le)
  have hfinal : |(pairedPolynomial b r s).coeff j| / (D.choose j:ℝ) ≤
      (D+1:ℝ)*Real.exp (-(2*(b:ℝ)*j*(D-j:ℕ))/(D:ℝ)^2) := by
    apply (div_le_iff₀ hc).mpr
    have hmul := mul_le_mul_of_nonneg_right hpower
      (by positivity : 0≤(D+1:ℝ)*(D.choose j:ℝ))
    nlinarith only [hraw, hmul]
  simpa only [D, Nat.cast_add, Nat.cast_one] using hfinal

/-- The coefficient bound is valid with any number of paired opposite
signs, including the smaller of the two sign counts. -/
theorem coefficient_decay (negative positive b j : ℕ)
    (hbneg : b ≤ negative) (hbpos : b ≤ positive)
    (hj : 0 < j) (hjD : j < negative+positive) :
    |krawtchouk negative positive j| / ((negative+positive).choose j:ℝ) ≤
      ((negative+positive+1:ℕ):ℝ)*
        Real.exp (-(2*(b:ℝ)*j*(negative+positive-j:ℕ))/((negative+positive:ℕ):ℝ)^2) := by
  have hD : 2*b+(negative-b)+(positive-b)=negative+positive := by omega
  have hh := paired_coefficient_decay b (negative-b) (positive-b) j hj (by omega)
  have he : pairedPolynomial b (negative-b) (positive-b) =
      (1-X : ℝ[X])^negative*(1+X)^positive := by
    rw [← polynomial_pairing, Nat.add_sub_of_le hbneg, Nat.add_sub_of_le hbpos]
  rw [he, hD] at hh
  simpa only [krawtchouk] using hh

end NeuralGeneralization.KrawtchoukDecay
