import AffineGridInitialization
import PicardGridResourceBounds

noncomputable section
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ι J : Type*} [Fintype ι] [Fintype J]

 theorem baseGridCircuit_size {d : ℕ}
    (A : J→EuclideanSpace ℝ (Fin (d+1))→L[ℝ]EuclideanSpace ℝ ι)
    (hA : ∀j,‖A j‖≤1) (Q N V : ℕ) :
    (baseGridCircuit A Q N V).size≤
      arithmeticLayerSize (d+1) (Fintype.card (J×ι)) Q 1 N V+
        coordinateRecodeSize (Fintype.card (J×ι)) Q V Q N := by
  unfold baseGridCircuit
  rw [CircuitMap.size_then]
  apply Nat.add_le_add
  · simpa only [Fintype.card_fin] using affineGridCircuit_size (baseVectorCoefficients A)
      (fun _=>0) Q 1 N V (fun z i=>by simpa only [Nat.cast_one,baseVectorCoefficients] using
        (linearCoefficients_bound (A z.1) z.2 i).trans (hA z.1))
  · exact coordinateRecodeSize_bound _ _ _ _

 theorem booleanAffineInitializer_polynomial_size {d : ℕ}
    (A : J→EuclideanSpace ℝ (Fin (d+1))→L[ℝ]EuclideanSpace ℝ ι)
    (hA : ∀j,‖A j‖≤1) {R : ℝ} (hR : 2≤R) (Q N V : ℕ)
    (hd : ((d+1:ℕ):ℝ)≤R) (hK : (Fintype.card (J×ι):ℝ)≤R)
    (hI : (Fintype.card (Fin (d+1)⊕(J×ι)):ℝ)≤R)
    (hQ : (Q:ℝ)≤R) (hN : (N:ℝ)≤R) (hV : (V:ℝ)≤R) :
    ((booleanAffineInitializer A Q N V).size:ℝ)≤R^64 := by
  have hg := scalarGrid_card_resource hR hQ hN
  have hthree : (3:ℝ)≤R^2 := by nlinarith
  have hsource := resource_mul hR hthree
    (resource_mul hR (a:=1) (by simpa only [pow_one] using hd) hg (Nat.cast_nonneg _)) (by positivity)
  have hs : ((booleanGridInput Q N (normalizedInputSources d)).size:ℝ)≤R^8 := by
    have hh : ((booleanGridInput Q N (normalizedInputSources d)).size:ℝ)≤3*((d+1:ℕ)* (Fintype.card (ScalarGrid Q N):ℝ)) := by
      have hb := booleanGridInput_size Q N (normalizedInputSources d)
      simp only [Fintype.card_fin] at hb
      exact_mod_cast hb
    exact hh.trans hsource
  have haf := arithmeticLayerSize_resource (B:=1) hR hd hK hQ (by norm_num;linarith) hN hV
  have hrec := coordinateRecodeSize_resource hR hK hQ hV hQ hN
  have hb : ((baseGridCircuit A Q N V).size:ℝ)≤R^51 := by
    have hh : ((baseGridCircuit A Q N V).size:ℝ)≤
        (arithmeticLayerSize (d+1) (Fintype.card (J×ι)) Q 1 N V:ℝ)+
        (coordinateRecodeSize (Fintype.card (J×ι)) Q V Q N:ℝ) := by
      exact_mod_cast baseGridCircuit_size A hA Q N V
    exact hh.trans (resource_add_same hR haf hrec)
  have hthen : (((booleanGridInput Q N (normalizedInputSources d)).then (baseGridCircuit A Q N V)).size:ℝ)≤R^52 := by
    rw [CircuitMap.size_then,Nat.cast_add]
    exact resource_add_same hR (hs.trans (resource_pow_mono hR (by norm_num))) hb
  have hsum := resource_add_same hR (hs.trans (resource_pow_mono hR (show 8≤52 by norm_num))) hthen
  have hwidth := resource_mul hR (a:=1) (by simpa only [pow_one] using hI) hg (Nat.cast_nonneg _)
  have hresult := resource_mul hR hwidth hsum (by positivity)
  have hh : ((booleanAffineInitializer A Q N V).size:ℝ)≤
      ((Fintype.card (Fin (d+1)⊕(J×ι)):ℝ)*(Fintype.card (ScalarGrid Q N):ℝ))*
        (((booleanGridInput Q N (normalizedInputSources d)).size:ℝ)+
          (((booleanGridInput Q N (normalizedInputSources d)).then (baseGridCircuit A Q N V)).size:ℝ)) := by
    exact_mod_cast sumGridCircuits_size (booleanGridInput Q N (normalizedInputSources d))
      ((booleanGridInput Q N (normalizedInputSources d)).then (baseGridCircuit A Q N V))
  exact hh.trans (hresult.trans (resource_pow_mono hR (by norm_num : 1+5+(52+1)≤64)))

#print axioms booleanAffineInitializer_polynomial_size
end ConditionalNonpolynomial.AnalyticLookup
