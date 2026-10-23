import NeuralGeneralization.PositiveCDFTransport
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Log.Deriv

/-!
# The scalar Gaussian transport inequality on a compact interval

This is a foundational lemma for the improved original-support compressor.
The transport is the actual increasing CDF transport, rather than a coupling
postulated to satisfy an entropy bound. Extension to arbitrary measures and
tensorization are separate obligations; this file alone is not the learning
theorem.
-/

noncomputable section
open MeasureTheory Set
open scoped Topology

namespace NeuralGeneralization.BatchTwoImprovedGaussianTransport
open PositiveCDFTransport

/-- The unnormalized standard Gaussian density. -/
def gaussianWeight (x : ℝ) : ℝ := Real.exp (-(x ^ 2) / 2)

@[fun_prop] theorem continuous_gaussianWeight : Continuous gaussianWeight := by
  unfold gaussianWeight
  fun_prop

theorem gaussianWeight_pos (x : ℝ) : 0 < gaussianWeight x := Real.exp_pos _

theorem hasDerivAt_gaussianWeight (x : ℝ) :
    HasDerivAt gaussianWeight (-x * gaussianWeight x) x := by
  have h := ((((hasDerivAt_id x).pow 2).neg.div_const 2).exp)
  convert h using 1
  · funext y
    simp only [gaussianWeight, id_eq, Pi.pow_apply, Pi.neg_apply]
  · simp only [gaussianWeight, id_eq, Pi.pow_apply, Pi.neg_apply, Nat.cast_ofNat,
      Nat.reduceSub, pow_one, mul_one]
    ring

/-- Gaussian integration by parts for a continuously differentiable displacement
that fixes the two endpoints. The boundary term is exactly zero. -/
theorem gaussian_transport_stein {a b : ℝ} (hab : a < b)
    (T D : ℝ → ℝ) (hT : Continuous T) (hD : Continuous D)
    (hderiv : ∀ x ∈ Ioo a b, HasDerivAt T (D x) x)
    (ha : T a = a) (hb : T b = b) :
    (∫ x in a..b, gaussianWeight x * (D x - 1)) =
      ∫ x in a..b, gaussianWeight x * x * (T x - x) := by
  have hderiv' (x : ℝ) (hx : x ∈ Ioo (min a b) (max a b)) :
      HasDerivAt (fun y => T y - y) (D x - 1) x := by
    have hx' : x ∈ Ioo a b := by
      simpa only [min_eq_left hab.le, max_eq_right hab.le] using hx
    exact (hderiv x hx').sub (hasDerivAt_id x)
  have hs := intervalIntegral.integral_mul_deriv_eq_deriv_mul_of_hasDerivAt
    continuous_gaussianWeight.continuousOn (hT.sub continuous_id).continuousOn
    (fun x _ => hasDerivAt_gaussianWeight x)
    hderiv'
    ((continuous_id.neg.mul continuous_gaussianWeight).intervalIntegrable a b)
    ((hD.sub continuous_const).intervalIntegrable a b)
  simp only [Pi.sub_apply, id_eq, ha, hb, sub_self, mul_zero, zero_sub,
    ← intervalIntegral.integral_neg, neg_mul, neg_neg] at hs
  convert hs using 1 <;> congr 1 <;> funext x <;> ring

/-- The elementary entropy inequality after the change of variables. The exact
coefficient two comes from Gaussian integration by parts and `log u ≤ u - 1`.
No transport-entropy estimate occurs among the premises. -/
theorem gaussian_transport_cost_le {a b : ℝ} (hab : a < b)
    (T D : ℝ → ℝ) (hT : Continuous T) (hD : Continuous D)
    (hDpos : ∀ x, 0 < D x)
    (hderiv : ∀ x ∈ Ioo a b, HasDerivAt T (D x) x)
    (ha : T a = a) (hb : T b = b) :
    (∫ x in a..b, gaussianWeight x * (T x - x)^2) ≤
      2 * ∫ x in a..b, gaussianWeight x *
        ((T x ^ 2 - x ^ 2) / 2 - Real.log (D x)) := by
  have hlog : Continuous (fun x => Real.log (D x)) :=
    hD.log (fun x => (hDpos x).ne')
  have hcost : Continuous (fun x => gaussianWeight x * (T x - x)^2) :=
    continuous_gaussianWeight.mul ((hT.sub continuous_id).pow 2)
  have hcross : Continuous (fun x => gaussianWeight x * x * (T x - x)) :=
    (continuous_gaussianWeight.mul continuous_id).mul (hT.sub continuous_id)
  have hrest : Continuous (fun x => gaussianWeight x * (D x - 1)) :=
    continuous_gaussianWeight.mul (hD.sub continuous_const)
  have hlogw : Continuous (fun x => gaussianWeight x * Real.log (D x)) :=
    continuous_gaussianWeight.mul hlog
  have hineq : (∫ x in a..b, gaussianWeight x * Real.log (D x)) ≤
      ∫ x in a..b, gaussianWeight x * (D x - 1) := by
    apply intervalIntegral.integral_mono_on hab.le
      (hlogw.intervalIntegrable a b) (hrest.intervalIntegrable a b)
    intro x _
    exact mul_le_mul_of_nonneg_left (Real.log_le_sub_one_of_pos (hDpos x))
      (gaussianWeight_pos x).le
  rw [gaussian_transport_stein hab T D hT hD hderiv ha hb] at hineq
  have heq : (∫ x in a..b, gaussianWeight x *
      ((T x ^ 2 - x ^ 2) / 2 - Real.log (D x))) =
      (∫ x in a..b, gaussianWeight x * (T x - x)^2) / 2 +
      (∫ x in a..b, gaussianWeight x * x * (T x - x)) -
      (∫ x in a..b, gaussianWeight x * Real.log (D x)) := by
    have hpoint : (fun x => gaussianWeight x *
        ((T x ^ 2 - x ^ 2) / 2 - Real.log (D x))) =
        (fun x => gaussianWeight x * (T x - x)^2 / 2 +
          gaussianWeight x * x * (T x - x) -
          gaussianWeight x * Real.log (D x)) := by
      funext x
      ring
    rw [hpoint, intervalIntegral.integral_sub
      ((hcost.div_const 2).intervalIntegrable a b |>.add (hcross.intervalIntegrable a b))
      (hlogw.intervalIntegrable a b),
      intervalIntegral.integral_add ((hcost.div_const 2).intervalIntegrable a b)
        (hcross.intervalIntegrable a b), intervalIntegral.integral_div]
  rw [heq]
  linarith


/-- The positive derivative of the concrete CDF transport. -/
def transportDerivative {f g : ℝ → ℝ} {a b : ℝ}
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b) (x : ℝ) : ℝ :=
  (mass g a b / g (transport hg hgpos hab f x)) * (f x / mass f a b)

theorem continuous_transportDerivative {f g : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hg : Continuous g) (hgpos : ∀ x, 0 < g x)
    (hab : a < b) : Continuous (transportDerivative (f := f) hg hgpos hab) := by
  unfold transportDerivative
  exact (continuous_const.div (hg.comp (continuous_transport hf hg hgpos hab))
    (fun x => (hgpos _).ne')).mul (hf.div_const _)

theorem transportDerivative_pos {f g : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x)
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x)
    (hab : a < b) (x : ℝ) :
    0 < transportDerivative (f := f) hg hgpos hab x :=
  mul_pos (div_pos (mass_pos hg hgpos hab) (hgpos _))
    (div_pos (hfpos _) (mass_pos hf hfpos hab))

/-- The actual CDF transport pushes the normalized source density to the
normalized target density, tested against every continuous function. -/
theorem transport_normalized_integral {f g u : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x)
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x)
    (hu : Continuous u) (hab : a < b) :
    (∫ x in a..b, (f x / mass f a b) * u (transport hg hgpos hab f x)) =
      ∫ y in a..b, (g y / mass g a b) * u y := by
  let T := transport hg hgpos hab f
  let D := transportDerivative (f := f) hg hgpos hab
  have hT := continuous_transport hf hg hgpos hab
  have hD := continuous_transportDerivative hf hg hgpos hab
  have hTa : T a = a := by
    dsimp only [T, transport]
    rw [cdf_left, quantile_zero]
  have hTb : T b = b := by
    dsimp only [T, transport]
    rw [cdf_right hf hfpos hab, quantile_one]
  have hs := intervalIntegral.integral_comp_mul_deriv'' (a := a) (b := b)
    hT.continuousOn
    (fun x hx => (hasDerivAt_transport hf hfpos hg hgpos hab
      (by simpa only [min_eq_left hab.le, max_eq_right hab.le] using hx)).hasDerivWithinAt)
    hD.continuousOn ((hg.div_const (mass g a b)).mul hu).continuousOn
  change (∫ x in a..b, (g (T x) / mass g a b * u (T x)) * D x) =
    ∫ y in T a..T b, (g y / mass g a b) * u y at hs
  rw [hTa, hTb] at hs
  rw [← hs]
  apply intervalIntegral.integral_congr
  intro x _
  dsimp [D, transportDerivative, T]
  field_simp [(mass_pos hf hfpos hab).ne', (mass_pos hg hgpos hab).ne', (hgpos _).ne']

/-- Log density of a positive continuous target relative to the normalized
Gaussian density on the same interval. -/
def compactGaussianLogRatio (g : ℝ → ℝ) (a b x : ℝ) : ℝ :=
  Real.log (g x) + Real.log (mass gaussianWeight a b) -
    Real.log (mass g a b) + x^2/2

theorem compactGaussianLogRatio_eq {g : ℝ → ℝ} {a b : ℝ}
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b) (x : ℝ) :
    compactGaussianLogRatio g a b x =
      Real.log ((g x / mass g a b) /
        (gaussianWeight x / mass gaussianWeight a b)) := by
  rw [Real.log_div (div_pos (hgpos x) (mass_pos hg hgpos hab)).ne'
      (div_pos (gaussianWeight_pos x)
        (mass_pos continuous_gaussianWeight gaussianWeight_pos hab)).ne',
    Real.log_div (hgpos x).ne' (mass_pos hg hgpos hab).ne',
    Real.log_div (gaussianWeight_pos x).ne'
      (mass_pos continuous_gaussianWeight gaussianWeight_pos hab).ne']
  simp only [compactGaussianLogRatio, gaussianWeight, Real.log_exp]
  ring

theorem continuous_compactGaussianLogRatio {g : ℝ → ℝ} {a b : ℝ}
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) :
    Continuous (compactGaussianLogRatio g a b) := by
  unfold compactGaussianLogRatio
  exact (((hg.log (fun x => (hgpos x).ne')).add continuous_const).sub
    continuous_const).add ((continuous_id.pow 2).div_const 2)

/-- Exact entropy change-of-variables identity for the CDF transport. -/
theorem compactGaussianLogRatio_transport {g : ℝ → ℝ} {a b : ℝ}
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b) (x : ℝ) :
    compactGaussianLogRatio g a b (transport hg hgpos hab gaussianWeight x) =
      ((transport hg hgpos hab gaussianWeight x)^2 - x^2)/2 -
        Real.log (transportDerivative (f := gaussianWeight) hg hgpos hab x) := by
  unfold transportDerivative
  rw [Real.log_mul
      (div_pos (mass_pos hg hgpos hab) (hgpos _)).ne'
      (div_pos (gaussianWeight_pos x)
        (mass_pos continuous_gaussianWeight gaussianWeight_pos hab)).ne',
    Real.log_div (mass_pos hg hgpos hab).ne' (hgpos _).ne',
    Real.log_div (gaussianWeight_pos x).ne'
      (mass_pos continuous_gaussianWeight gaussianWeight_pos hab).ne']
  simp only [compactGaussianLogRatio, gaussianWeight, Real.log_exp]
  ring

/-- The scalar Gaussian transport-entropy inequality for arbitrary strictly
positive continuous target densities on an arbitrary compact interval. Both
sides use their actual normalized densities, and the coupling is the concrete
increasing CDF transport. -/
theorem compact_gaussian_transport_entropy {g : ℝ → ℝ} {a b : ℝ}
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b) :
    (∫ x in a..b, (gaussianWeight x / mass gaussianWeight a b) *
      (transport hg hgpos hab gaussianWeight x - x)^2) ≤
      2 * ∫ y in a..b, (g y / mass g a b) *
        Real.log ((g y / mass g a b) /
          (gaussianWeight y / mass gaussianWeight a b)) := by
  let T := transport hg hgpos hab gaussianWeight
  let D := transportDerivative (f := gaussianWeight) hg hgpos hab
  have hT := continuous_transport continuous_gaussianWeight hg hgpos hab
  have hD := continuous_transportDerivative continuous_gaussianWeight hg hgpos hab
  have hDpos := transportDerivative_pos continuous_gaussianWeight gaussianWeight_pos hg hgpos hab
  have hTa : T a = a := by
    dsimp only [T, transport]
    rw [cdf_left, quantile_zero]
  have hTb : T b = b := by
    dsimp only [T, transport]
    rw [cdf_right continuous_gaussianWeight gaussianWeight_pos hab, quantile_one]
  have hraw := gaussian_transport_cost_le hab T D hT hD hDpos
    (fun x hx => hasDerivAt_transport continuous_gaussianWeight gaussianWeight_pos hg hgpos hab hx)
    hTa hTb
  have hmass := mass_pos continuous_gaussianWeight gaussianWeight_pos hab
  have hnormalized := div_le_div_of_nonneg_right hraw hmass.le
  have hratio (x : ℝ) : (T x^2 - x^2)/2 - Real.log (D x) =
      compactGaussianLogRatio g a b (T x) := by
    exact (compactGaussianLogRatio_transport hg hgpos hab x).symm
  simp_rw [hratio] at hnormalized
  have hchange := transport_normalized_integral continuous_gaussianWeight gaussianWeight_pos
    hg hgpos (continuous_compactGaussianLogRatio (a := a) (b := b) hg hgpos) hab
  have hleft : (∫ x in a..b, gaussianWeight x * (T x - x)^2) /
      mass gaussianWeight a b =
      ∫ x in a..b, (gaussianWeight x / mass gaussianWeight a b) * (T x - x)^2 := by
    rw [← intervalIntegral.integral_div]
    apply intervalIntegral.integral_congr
    intro x _
    ring
  have hright : (2 * ∫ x in a..b, gaussianWeight x *
      compactGaussianLogRatio g a b (T x)) / mass gaussianWeight a b =
      2 * ∫ y in a..b, (g y / mass g a b) * compactGaussianLogRatio g a b y := by
    rw [mul_div_assoc, ← intervalIntegral.integral_div]
    have heq : (fun x => gaussianWeight x * compactGaussianLogRatio g a b (T x) /
        mass gaussianWeight a b) =
        (fun x => (gaussianWeight x / mass gaussianWeight a b) *
          compactGaussianLogRatio g a b (T x)) := by
      funext x
      ring
    rw [heq, hchange]
  rw [hleft, hright] at hnormalized
  simpa only [compactGaussianLogRatio_eq hg hgpos hab, T] using hnormalized

end NeuralGeneralization.BatchTwoImprovedGaussianTransport
