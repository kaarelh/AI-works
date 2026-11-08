import NeuralGeneralization.OnlineLowerFiniteHolder
import NeuralGeneralization.OnlineLowerTanhCodeClarkson
import Mathlib.MeasureTheory.Integral.Bochner.SumMeasure

/-! # Finite Hölder zipping of arbitrary rail coordinates -/

noncomputable section
open scoped BigOperators
open MeasureTheory
namespace NeuralGeneralization.OnlineLowerTanh

/-- The two-term generalized Hölder inequality used to zip the two rails of
a pair into equal-exponent coordinate columns. -/
theorem two_term_product_holder {ι : Type*} [Fintype ι]
    (hn : 0 < Fintype.card ι) (a b : ι → ℝ)
    (ha : ∀ i,0≤a i) (hb : ∀ i,0≤b i) :
    (∏ i,a i)+(∏ i,b i) ≤
      ∏ i,(a i^Fintype.card ι+b i^Fintype.card ι)^(1/(Fintype.card ι:ℝ)) := by
  let f : ι→Bool→ℝ := fun i s => if s then a i else b i
  have h := OnlineLower.integrable_prod_and_integral_prod_le
    (Measure.count : Measure Bool) hn f
    (fun i s => by cases s;exact hb i;exact ha i)
    (fun i => Measurable.of_discrete.aestronglyMeasurable)
    (fun _ => Integrable.of_finite)
  simpa [integral_count,Fintype.sum_bool,f,add_comm] using h.2

/-- A single balanced column's positive trigonometric factor. -/
def columnPair (R : ℕ) (a b t : ℝ) : ℝ :=
  |Real.sin (a*t)|^R*|Real.cos (b*t)|^R+
    |Real.cos (a*t)|^R*|Real.sin (b*t)|^R

theorem columnPair_nonneg (R : ℕ) (a b t : ℝ) : 0≤columnPair R a b t := by
  unfold columnPair
  positivity

/-- For arbitrary weights in the two rails, generalized Hölder leaves a
product of balanced columns. This is a literal finite-coordinate statement. -/
theorem rail_pair_zip (R : ℕ) (hR : 0<R) (a b : Fin R→ℝ) (t : ℝ) :
    (∏ k,|Real.sin (a k*t)| *|Real.cos (b k*t)|)+
      (∏ k,|Real.cos (a k*t)| *|Real.sin (b k*t)|) ≤
        ∏ k,(columnPair R (a k) (b k) t)^(1/(R:ℝ)) := by
  have h := two_term_product_holder (ι:=Fin R) (by simpa using hR)
    (fun k => |Real.sin (a k*t)| *|Real.cos (b k*t)|)
    (fun k => |Real.cos (a k*t)| *|Real.sin (b k*t)|)
    (fun _ => by positivity) (fun _ => by positivity)
  simpa [Fintype.card_fin,mul_pow,columnPair] using h

/-- Clarkson and convexity at power q bound the column by two ordinary
sine moments. The final exponent R*q may subsequently be an integer even
when q itself is half-integral. -/
theorem columnPair_rpow_bound (R : ℕ) (hR : Even R) (hR2 : 2≤R)
    (a b t q : ℝ) (hq : 1≤q) :
    (columnPair R a b t)^q ≤
      ((|Real.sin ((a+b)*t)|^R : ℝ)^q+(|Real.sin ((a-b)*t)|^R : ℝ)^q)/2 := by
  have hc := sine_pair_clarkson R hR hR2 a b t
  have hp := Real.rpow_le_rpow (columnPair_nonneg R a b t) hc (by linarith : 0≤q)
  exact hp.trans (rpow_midpoint_le _ _ q (by positivity) (by positivity) hq)

/-- Zipping all rail pairs keeps the product form needed for ordinary
finite-product Hölder under the frequency measure. -/
theorem all_pairs_zip (p R : ℕ) (hR : 0<R)
    (a b : Fin p→Fin R→ℝ) (t : ℝ) :
    (∏ i, ((∏ k,|Real.sin (a i k*t)| *|Real.cos (b i k*t)|)+
      (∏ k,|Real.cos (a i k*t)| *|Real.sin (b i k*t)|))) ≤
        ∏ i, ∏ k,(columnPair R (a i k) (b i k) t)^(1/(R:ℝ)) := by
  exact Finset.prod_le_prod
    (fun i _ => add_nonneg (Finset.prod_nonneg fun _ _ => by positivity)
      (Finset.prod_nonneg fun _ _ => by positivity))
    (fun i _ => rail_pair_zip R hR (a i) (b i) t)

end NeuralGeneralization.OnlineLowerTanh
