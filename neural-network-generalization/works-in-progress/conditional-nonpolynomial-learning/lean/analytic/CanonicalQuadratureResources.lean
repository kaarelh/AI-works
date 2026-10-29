import CanonicalResidualRealMap
import ArithmeticResourceBounds

noncomputable section
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open ConditionalNonpolynomial.AnalyticLookup

lemma resource_ceil_add_one {R x : ℝ} {a : ℕ} (hR : 2≤R) (hx0 : 0≤x) (hx : x≤R^a) :
    ((⌈x⌉₊+1:ℕ):ℝ)≤R^(a+2) := by
  have hc := Nat.ceil_lt_add_one hx0
  have hh := resource_add_one hR (resource_add_one hR hx)
  push_cast
  nlinarith

/-- The importance-quadrature mesh and sample count are genuine polynomial
resources, with universal exponents independent of layer dimension. -/
theorem canonicalQuadrature_resources {d : ℕ} {Z δ R : ℝ}
    (hR : 2≤R) (hd : (d:ℝ)≤R) (hZ0 : 0≤Z) (hZ : Z≤R)
    (hδ : 0<δ) (hi : δ⁻¹≤R) :
    (canonicalQuadratureMesh d Z δ:ℝ)≤R^16 ∧
    (canonicalQuadratureSamples d Z δ:ℝ)≤R^54 := by
  have hR0 : 0≤R := by linarith
  have htwo : (2:ℝ)≤R^1 := by simpa using hR
  have hfour : (4:ℝ)≤R^2 := by nlinarith
  have h1024 : (1024:ℝ)≤R^10 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hR 10
    norm_num at hh
    exact hh
  have hd1 : (d:ℝ)+1≤R^2 := by simpa using resource_add_one hR (a:=1) (by simpa using hd)
  have hD : ((d:ℝ)+1)*4≤R^4 := resource_mul hR hd1 hfour (by norm_num)
  have hD0 : 0≤((d:ℝ)+1)*4 := by positivity
  have hM : 1+2*(((d:ℝ)+1)*4)≤R^6 := by
    have hh := resource_add_one hR (resource_mul hR htwo hD hD0)
    simpa only [add_comm] using hh
  have hinside : Z*(((d:ℝ)+1)*(1+2*(((d:ℝ)+1)*4)))≤R^9 :=
    resource_mul hR (a:=1) (by simpa using hZ) (resource_mul hR hd1 hM (by positivity)) (by positivity)
  have hnum : 4*(Z*(((d:ℝ)+1)*(1+2*(((d:ℝ)+1)*4))))*4≤R^13 :=
    resource_mul hR (resource_mul hR hfour hinside (by positivity)) hfour (by norm_num)
  have hratio : (4*(Z*(((d:ℝ)+1)*(1+2*(((d:ℝ)+1)*4))))*4)/δ≤R^14 := by
    rw [div_eq_mul_inv]
    exact resource_mul hR hnum (b:=1) (by simpa using hi) (inv_nonneg.mpr hδ.le)
  have hmesh : (canonicalQuadratureMesh d Z δ:ℝ)≤R^16 := by
    exact resource_ceil_add_one hR (by positivity) hratio
  refine ⟨hmesh,?_⟩
  have hDsq := resource_pow hR hD hD0 2
  have hsum : (((d:ℝ)+1)*4)+(((d:ℝ)+1)*4)^2≤R^9 :=
    resource_add_same hR (hD.trans (resource_pow_mono hR (by norm_num))) hDsq
  have hZprod : Z*((((d:ℝ)+1)*4)+(((d:ℝ)+1)*4)^2)≤R^10 :=
    resource_mul hR (a:=1) (by simpa using hZ) hsum (by positivity)
  have hZsq : (Z*((((d:ℝ)+1)*4)+(((d:ℝ)+1)*4)^2))^2≤R^20 :=
    resource_pow hR hZprod (by positivity) 2
  have hprefix : 1024*(Z*((((d:ℝ)+1)*4)+(((d:ℝ)+1)*4)^2))^2≤R^30 :=
    resource_mul hR h1024 hZsq (by positivity)
  have htarg : 2*(canonicalQuadratureMesh d Z δ:ℝ)+1≤R^18 :=
    resource_add_one hR (resource_mul hR htwo hmesh (Nat.cast_nonneg _))
  have hlog : Real.log (2*(canonicalQuadratureMesh d Z δ:ℝ)+1)≤R^18 :=
    (Real.log_le_self (by positivity : 0≤2*(canonicalQuadratureMesh d Z δ:ℝ)+1)).trans htarg
  have hlog0 : 0≤Real.log (2*(canonicalQuadratureMesh d Z δ:ℝ)+1) :=
    Real.log_nonneg (by have hh := Nat.cast_nonneg (α:=ℝ) (canonicalQuadratureMesh d Z δ);linarith)
  have hfactor : 1+(d:ℝ)*Real.log (2*(canonicalQuadratureMesh d Z δ:ℝ)+1)≤R^20 := by
    have hh := resource_add_one hR (resource_mul hR (a:=1) (by simpa using hd) hlog hlog0)
    simpa only [add_comm] using hh
  have hbudget : 1024*(Z*((((d:ℝ)+1)*4)+(((d:ℝ)+1)*4)^2))^2*
      (1+(d:ℝ)*Real.log (2*(canonicalQuadratureMesh d Z δ:ℝ)+1))≤R^50 :=
    resource_mul hR hprefix hfactor (by positivity)
  have hisq : (δ⁻¹)^2≤R^2 := by
    simpa only [pow_one] using (resource_pow hR (a:=1) (by simpa using hi) (inv_nonneg.mpr hδ.le) 2)
  have hr2 : (1024*(Z*((((d:ℝ)+1)*4)+(((d:ℝ)+1)*4)^2))^2*
      (1+(d:ℝ)*Real.log (2*(canonicalQuadratureMesh d Z δ:ℝ)+1)))/δ^2≤R^52 := by
    rw [div_eq_mul_inv,← inv_pow]
    exact resource_mul hR hbudget hisq (sq_nonneg _)
  exact resource_ceil_add_one hR (by positivity) hr2

#print axioms canonicalQuadrature_resources
end ConditionalNonpolynomial.Analytic
