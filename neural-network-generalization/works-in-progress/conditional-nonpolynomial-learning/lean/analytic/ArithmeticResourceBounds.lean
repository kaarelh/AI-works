import ArithmeticProgramEvaluator

noncomputable section
set_option maxHeartbeats 2500000
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

lemma resource_pow_mono {R : ℝ} (hR : 2≤R) {a b : ℕ} (hab : a≤b) : R^a≤R^b :=
  pow_le_pow_right₀ (by linarith) hab

lemma resource_add_same {R x y : ℝ} {a : ℕ} (hR : 2≤R) (hx : x≤R^a) (hy : y≤R^a) :
    x+y≤R^(a+1) := by
  rw [pow_succ]
  have hh := mul_le_mul_of_nonneg_left hR (pow_nonneg (by linarith : 0≤R) a)
  linarith

lemma resource_add_one {R x : ℝ} {a : ℕ} (hR : 2≤R) (hx : x≤R^a) : x+1≤R^(a+1) :=
  resource_add_same hR hx (one_le_pow₀ (by linarith))

lemma resource_mul {R x y : ℝ} {a b : ℕ} (hR : 2≤R) (hx : x≤R^a) (hy : y≤R^b)
    (hy0 : 0≤y) : x*y≤R^(a+b) := by
  exact (mul_le_mul hx hy hy0 (pow_nonneg (by linarith) _)).trans_eq (pow_add R a b).symm

lemma resource_pow {R x : ℝ} {a : ℕ} (hR : 2≤R) (hx : x≤R^a) (hx0 : 0≤x) (n : ℕ) :
    x^n≤R^(a*n) := by
  exact (pow_le_pow_left₀ hx0 hx n).trans_eq (pow_mul R a n).symm

lemma layerRadius_resource {R : ℝ} (hR : 2≤R) {d B N : ℕ}
    (hd : (d:ℝ)≤R) (hB : (B:ℝ)≤R) (hN : (N:ℝ)≤R) :
    (layerRadius d B N:ℝ)≤R^6 := by
  have hd' : (d:ℝ)≤R^1 := by simpa using hd
  have hb : (B:ℝ)+1≤R^2 := by simpa using resource_add_one hR (a:=1) (by simpa using hB)
  have hn : (N:ℝ)+1≤R^2 := by simpa using resource_add_one hR (a:=1) (by simpa using hN)
  have hprod := resource_mul hR (resource_mul hR hd' hb (by positivity)) hn (by positivity)
  have hh := resource_add_one hR hprod
  simpa [layerRadius] using hh

lemma layerNextRange_resource {R : ℝ} (hR : 2≤R) {d B N : ℕ}
    (hd : (d:ℝ)≤R) (hB : (B:ℝ)≤R) (hN : (N:ℝ)≤R) :
    (layerNextRange d B N:ℝ)≤R^16 := by
  have hh := resource_add_one hR (resource_pow hR (layerRadius_resource hR hd hB hN) (by positivity) 2)
  have h13 : (layerNextRange d B N:ℝ)≤R^13 := by simpa [layerNextRange] using hh
  exact h13.trans (resource_pow_mono hR (by norm_num))

lemma layerAmplification_resource {R : ℝ} (hR : 2≤R) {d B N : ℕ}
    (hd : (d:ℝ)≤R) (hB : (B:ℝ)≤R) (hN : (N:ℝ)≤R) :
    (layerAmplification d B N:ℝ)≤R^16 := by
  have hd' : (d:ℝ)≤R^1 := by simpa using hd
  have hb : (B:ℝ)+(N:ℝ)≤R^2 := by
    simpa using resource_add_same hR (a:=1) (by simpa using hB) (by simpa using hN)
  have hsum : (B:ℝ)+(N:ℝ)+1≤R^3 := resource_add_one hR hb
  have hM : (d:ℝ)*((B:ℝ)+N+1)≤R^4 := resource_mul hR hd' hsum (by positivity)
  have hrad := layerRadius_resource hR hd hB hN
  have h2 : (2:ℝ)≤R^1 := by simpa using hR
  have hprod := resource_mul hR (resource_mul hR h2 hrad (by positivity)) hM (by positivity)
  have hm11 := hM.trans (resource_pow_mono hR (show 4≤1+6+4 by norm_num))
  have hsum12 := resource_add_same hR hprod hm11
  have h2big := h2.trans (resource_pow_mono hR (show 1≤1+6+4+1 by norm_num))
  have hsum13 := resource_add_same hR hsum12 h2big
  have hh : (layerAmplification d B N:ℝ)≤R^13 := by
    simpa [layerAmplification] using hsum13
  exact hh.trans (resource_pow_mono hR (by norm_num))

lemma arithmeticLayerSize_resource {R : ℝ} (hR : 2≤R) {di do' Q B Ni No : ℕ}
    (hdi : (di:ℝ)≤R) (hdo : (do':ℝ)≤R) (hQ : (Q:ℝ)≤R) (hB : (B:ℝ)≤R)
    (hNi : (Ni:ℝ)≤R) (hNo : (No:ℝ)≤R) :
    (arithmeticLayerSize di do' Q B Ni No:ℝ)≤R^50 := by
  have htwo : (2:ℝ)≤R^1 := by simpa using hR
  have hsmall (a b : ℕ) (ha : (a:ℝ)≤R) (hb : (b:ℝ)≤R) : (a:ℝ)*b+1≤R^3 := by
    exact resource_add_one hR (resource_mul hR (a:=1) (b:=1) (by simpa using ha)
      (by simpa using hb) (by positivity))
  have hgrid (a : ℕ) (ha : (a:ℝ)≤R) : 2*((Q:ℝ)*a+1)+1≤R^5 :=
    resource_add_one hR (resource_mul hR htwo (hsmall Q a hQ ha) (by positivity))
  have hqi := hgrid Ni hNi
  have hqo := hgrid No hNo
  let W : ℝ := ((di:ℝ)*(2*((Q:ℝ)*Ni+1)+1))*(((Q:ℝ)*B+1)*((Q:ℝ)*Ni+1))
  have hW : W≤R^12 := resource_mul hR
    (resource_mul hR (a:=1) (by simpa using hdi) hqi (by positivity))
    (resource_mul hR (hsmall Q B hQ hB) (hsmall Q Ni hQ hNi) (by positivity)) (by positivity)
  have hW0 : 0≤W := by dsimp [W]; positivity
  have h8 : (8:ℝ)≤R^4 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hR 4
    norm_num at hh
    linarith
  have h9 : (9:ℝ)≤R^4 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hR 4
    norm_num at hh
    linarith
  have h8W : 8*W≤R^16 := resource_mul hR h8 hW hW0
  have h8W9 : 8*W+9≤R^17 := resource_add_same hR h8W
    (h9.trans (resource_pow_mono hR (by norm_num)))
  have h2W1 : 2*W+1≤R^14 := resource_add_one hR (resource_mul hR htwo hW hW0)
  have hmid : (8*W+9)*(2*W+1)+1≤R^32 :=
    resource_add_one hR (resource_mul hR h8W9 h2W1 (by positivity))
  have hlast : ((do':ℝ)*(2*((Q:ℝ)*No+1)+1))*
      ((2*((Q:ℝ)*No+1)+1)*((8*W+9)*(2*W+1)+1))≤R^43 :=
    resource_mul hR (resource_mul hR (a:=1) (by simpa using hdo) hqo (by positivity))
      (resource_mul hR hqo hmid (by positivity)) (by positivity)
  have hh : (arithmeticLayerSize di do' Q B Ni No:ℝ)≤R^43 := by
    simpa [arithmeticLayerSize,W] using hlast
  exact hh.trans (resource_pow_mono hR (by norm_num))

#print axioms layerNextRange_resource
#print axioms layerAmplification_resource
#print axioms arithmeticLayerSize_resource
end ConditionalNonpolynomial.AnalyticLookup
