import PicardGridBudgets
import ArithmeticProgramResources

noncomputable section
set_option maxHeartbeats 1000000
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

 theorem picard_grid_numeric_resources {R η : ℝ} (hR : 2≤R) (hη : 0<η)
    {A K D N : ℕ} (hA : (A:ℝ)≤R) (hK : (K:ℝ)≤R) (hD : (D:ℝ)≤R) (hN : (N:ℝ)≤R)
    (hi : η⁻¹≤R) :
    (picardInnerTolerance A K D η)⁻¹≤R^14 ∧
    (picardOuterMesh A K D N η:ℝ)≤R^15 ∧
    (1+A*2*(N+1):ℕ)≤R^6 := by
  have h2 : (2:ℝ)≤R^1 := by simpa using hR
  have h4 : (4:ℝ)≤R^2 := by nlinarith
  have hA' : (A:ℝ)≤R^1 := by simpa using hA
  have hK1 : (K:ℝ)+1≤R^2 := resource_add_one hR (a:=1) (by simpa using hK)
  have hA1 : (A:ℝ)+1≤R^2 := resource_add_one hR hA'
  have hN1 : (N:ℝ)+1≤R^2 := resource_add_one hR (a:=1) (by simpa using hN)
  have hD1 : (D:ℝ)+1≤R^2 := resource_add_one hR (a:=1) (by simpa using hD)
  have hD2 : (D:ℝ)+2≤R^3 := by
    have hh := resource_add_one hR hD1
    norm_num at hh
    linarith
  have hL : (picardAmplifier A K:ℝ)≤R^7 := by
    have hh := resource_mul hR (resource_mul hR (resource_mul hR hK1 hA' (by positivity)) hA1 (by positivity)) hK1 (by positivity)
    simpa only [picardAmplifier,Nat.cast_mul,Nat.cast_add,Nat.cast_one] using hh
  have hL1 := resource_add_one hR hL
  have ht : (picardInnerTolerance A K D η)⁻¹≤R^14 := by
    rw [←one_div,picardInnerTolerance_inverse A K D hη,div_eq_mul_inv]
    exact resource_mul hR (resource_mul hR (resource_mul hR h4 hL1 (by positivity)) hD2 (by positivity))
      (b:=1) (by simpa using hi) (inv_nonneg.mpr hη.le)
  have hLD := resource_mul hR hL hD1 (by positivity : 0≤(D:ℝ)+1)
  have hAN := resource_mul hR hA' hN1 (by positivity : 0≤(N:ℝ)+1)
  have hAN2 : (A:ℝ)*((N:ℝ)+1)+2≤R^4 := resource_add_same hR hAN
    (h2.trans (resource_pow_mono hR (by norm_num)))
  have hKprod := resource_mul hR hK1 hAN2 (by positivity : 0≤(A:ℝ)*((N:ℝ)+1)+2)
  have hW : (picardRoundingWeight A K D N:ℝ)≤R^11 := by
    have hh := resource_add_one hR (resource_add_same hR hLD
      (hKprod.trans (resource_pow_mono hR (show 6≤9 by norm_num))))
    simpa only [picardRoundingWeight,Nat.cast_add,Nat.cast_mul,Nat.cast_one, Nat.cast_ofNat] using hh
  have hbody : 2*(picardRoundingWeight A K D N:ℝ)/η≤R^13 := by
    rw [div_eq_mul_inv]
    exact resource_mul hR (resource_mul hR h2 hW (Nat.cast_nonneg _))
      (b:=1) (by simpa using hi) (inv_nonneg.mpr hη.le)
  have hmesh : (picardOuterMesh A K D N η:ℝ)≤R^15 := by
    have hh := resource_add_same hR hbody (h2.trans (resource_pow_mono hR (by norm_num)))
    exact (picardOuterMesh_upper A K D N hη).le.trans
      (hh.trans (resource_pow_mono hR (show 14≤15 by norm_num)))
  refine ⟨ht,hmesh,?_⟩
  have hh := resource_add_one hR (resource_mul hR (resource_mul hR hA' h2 (by norm_num)) hN1 (by positivity))
  push_cast
  have hh' : (A:ℝ)*2*((N:ℝ)+1)+1≤R^5 := hh
  exact (by linarith : 1+(A:ℝ)*2*((N:ℝ)+1)≤R^5).trans (resource_pow_mono hR (by norm_num))

 theorem scalarGrid_card_resource {R : ℝ} (hR : 2≤R) {Q N : ℕ}
    (hQ : (Q:ℝ)≤R) (hN : (N:ℝ)≤R) : (Fintype.card (ScalarGrid Q N):ℝ)≤R^5 := by
  have hh := resource_add_one hR (resource_mul hR (a:=1) (by simpa using hR)
    (resource_add_one hR (resource_mul hR (a:=1) (b:=1) (by simpa using hQ)
      (by simpa using hN) (Nat.cast_nonneg N))) (by positivity))
  simpa only [scalarGrid_card,Nat.cast_add,Nat.cast_mul,Nat.cast_one,Nat.cast_ofNat] using hh

 theorem coordinateRecodeSize_resource {R : ℝ} (hR : 2≤R) {D Q Ni Q' No : ℕ}
    (hD : (D:ℝ)≤R) (hQ : (Q:ℝ)≤R) (hNi : (Ni:ℝ)≤R)
    (hQ' : (Q':ℝ)≤R) (hNo : (No:ℝ)≤R) :
    (coordinateRecodeSize D Q Ni Q' No:ℝ)≤R^50 := by
  have htwo : (2:ℝ)≤R^1 := by simpa using hR
  have hsmall (a b : ℕ) (ha : (a:ℝ)≤R) (hb : (b:ℝ)≤R) : (a:ℝ)*b+1≤R^3 :=
    resource_add_one hR (resource_mul hR (a:=1) (b:=1) (by simpa using ha) (by simpa using hb) (by positivity))
  have hgrid (a b : ℕ) (ha : (a:ℝ)≤R) (hb : (b:ℝ)≤R) : 2*((a:ℝ)*b+1)+1≤R^5 :=
    resource_add_one hR (resource_mul hR htwo (hsmall a b ha hb) (by positivity))
  have hqi := hgrid Q Ni hQ hNi
  have hqo := hgrid Q' No hQ' hNo
  let W : ℝ := ((D:ℝ)*(2*((Q:ℝ)*Ni+1)+1))*((Q:ℝ)*Ni+1)
  have hW : W≤R^9 := resource_mul hR (resource_mul hR (a:=1) (by simpa using hD) hqi (by positivity))
    (hsmall Q Ni hQ hNi) (by positivity)
  have hW0 : 0≤W := by dsimp [W];positivity
  have h8 : (8:ℝ)≤R^4 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hR 4
    norm_num at hh
    linarith
  have h9 : (9:ℝ)≤R^4 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hR 4
    norm_num at hh
    linarith
  have h8W9 : 8*W+9≤R^14 := resource_add_same hR (resource_mul hR h8 hW hW0)
    (h9.trans (resource_pow_mono hR (by norm_num)))
  have h2W1 : 2*W+1≤R^11 := resource_add_one hR (resource_mul hR htwo hW hW0)
  have hmid := resource_add_one hR (resource_mul hR h8W9 h2W1 (by positivity : 0≤2*W+1))
  have hlast := resource_mul hR (resource_mul hR (a:=1) (by simpa using hD) hqo (by positivity))
    (resource_mul hR hqo hmid (by positivity : 0≤(8*W+9)*(2*W+1)+1)) (by positivity)
  have hh : (coordinateRecodeSize D Q Ni Q' No:ℝ)≤R^37 := by
    simpa only [coordinateRecodeSize,Nat.cast_add,Nat.cast_mul,Nat.cast_one,Nat.cast_ofNat,W] using hlast
  exact hh.trans (resource_pow_mono hR (by norm_num))

#print axioms picard_grid_numeric_resources
#print axioms coordinateRecodeSize_resource
end ConditionalNonpolynomial.AnalyticLookup
