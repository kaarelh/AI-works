import RepresentativeGridClassifier
import GridEndpointResources

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {d Q N : ℕ} {κ ι J : Type} [Fintype κ] [Fintype ι] [Fintype J]
variable [DecidableEq ι] [DecidableEq J]

 theorem representativeClassifierAfter_polynomial_size
    (C : CircuitMap d (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (p : ι→κ)
    (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool) {A R : ℝ} (hA : 1≤A) (hR : 3≤R)
    (hcenter : ∀j,‖centers j‖≤2) (hAR : A≤R)
    (hD : (Fintype.card ι:ℝ)≤R) (hJ : (Fintype.card J:ℝ)≤R)
    (hQ : (Q:ℝ)≤R) (hN : (N:ℝ)≤R) (K : ℕ) (hC : (C.size:ℝ)≤R^K) :
    ((representativeClassifierAfter C p centers labels A).size:ℝ)≤
      R^(K+14*distanceClassifierResourceExponent+1) := by
  have hR2:2≤R:=by linarith
  have hR0:0≤R:=by linarith
  have hA0:0≤A:=by linarith
  have hRbig:R≤R^14:=by simpa only [pow_one] using resource_pow_mono hR2 (by norm_num : 1≤14)
  have hscale:2≤R^14:=hR2.trans hRbig
  have hJ1:(Fintype.card J:ℝ)+1≤R^2:=resource_add_one hR2 (a:=1) (by simpa only [pow_one] using hJ)
  have hA2:A^2≤R^2:=pow_le_pow_left₀ hA0 hAR 2
  have h1024:(1024:ℝ)≤R^10:=by
    have hh:=pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hR2 10
    norm_num at hh
    exact hh
  have hεinv:(representativeDistanceTolerance A (Fintype.card J))⁻¹≤R^14:=by
    rw [representativeDistanceTolerance_inverse]
    exact resource_mul hR2 (resource_mul hR2 h1024 hA2 (sq_nonneg _)) hJ1 (by positivity)
  have hprod:(Fintype.card J:ℝ)*(Fintype.card ι:ℝ)≤R^2:=
    resource_mul hR2 (a:=1) (by simpa only [pow_one] using hJ) (b:=1) (by simpa only [pow_one] using hD) (Nat.cast_nonneg _)
  have hdim:((distanceProgramBlock centers).maxDimension:ℝ)≤R^5:=by
    have hh:((distanceProgramBlock centers).maxDimension:ℝ)≤
        (Fintype.card ι:ℝ)+(Fintype.card J:ℝ)*(Fintype.card ι:ℝ)+(Fintype.card J:ℝ)+1:=by
      exact_mod_cast distanceProgramBlock_dimension centers
    have hs1:=resource_add_same hR2 (hD.trans (by nlinarith)) hprod
    have hs2:=resource_add_same hR2 hs1 (hJ.trans (by
      have hp:=resource_pow_mono hR2 (by norm_num : 1≤3)
      simpa only [pow_one] using hp))
    exact hh.trans (resource_add_one hR2 hs2)
  have hcoeff:∀j i,|centers j i|≤((2:ℕ):ℝ):=fun j i=>(PiLp.norm_apply_le _ i).trans (hcenter j)
  have hdistance:=coordinateDistanceClassifier_polynomial_size p Q N centers labels
    (representativeDistanceThreshold A) 2 3 (by norm_num) hcoeff
    (representativeDistanceTolerance_pos (by linarith : 0<A) (Fintype.card J)) hscale
    (hD.trans hRbig) (hJ.trans hRbig) (hdim.trans (resource_pow_mono hR2 (by norm_num)))
    (hR2.trans hRbig) (hR.trans hRbig) (hQ.trans hRbig) (hN.trans hRbig) hεinv
  rw [←pow_mul] at hdistance
  have hCbig:=hC.trans (resource_pow_mono hR2 (show K≤K+14*distanceClassifierResourceExponent by omega))
  have hDbig:=hdistance.trans (resource_pow_mono hR2 (show 14*distanceClassifierResourceExponent≤K+14*distanceClassifierResourceExponent by omega))
  rw [representativeClassifierAfter_size,Nat.cast_add]
  exact resource_add_same hR2 hCbig hDbig

#print axioms representativeClassifierAfter_polynomial_size
end ConditionalNonpolynomial.AnalyticLookup
