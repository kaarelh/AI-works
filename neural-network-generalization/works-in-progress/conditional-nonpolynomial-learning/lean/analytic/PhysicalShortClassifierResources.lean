import PhysicalShortActualClassifier
import PhysicalShortSelectedGridResources
import AffineGridInitializationResources

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

def canonicalClassifierResourceExponent : ℕ := 105*canonicalPicardResourceExponent+7010

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 theorem selected_readout_numeric_resources (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (c : EuclideanSpace ℝ (states H).Index)
    {W η : ℝ} (h : M.PrimitiveResources W η) (hη : 0<η)
    (hI : (Fintype.card M.PicardInputIndex:ℝ)≤W)
    (hK : (Fintype.card M.PicardStateIndex:ℝ)≤W)
    (hΛ : canonicalNonlinearBudget P (canonicalSignPrecision P)≤W)
    (hc : normalizingScale M.linearGain H*‖c‖≤W) :
    (M.readoutGridBudget c:ℝ)≤W^3 ∧ (M.readoutGridRange c:ℝ)≤W^13 := by
  have hs : 0≤normalizingScale M.linearGain H := by linarith [normalizingScale_one_le _ M.linearGain_one_le H]
  have hB : (M.readoutGridBudget c:ℝ)≤W^3 := resource_ceil_add_one h.scale
    (mul_nonneg hs (norm_nonneg _)) (a:=1) (by simpa only [pow_one] using hc)
  have hb1 := resource_add_one h.scale hB
  have hU := (M.selected_grid_numeric_resources hd h hη hI hK hΛ).2.1
  have hm := resource_mul h.scale (resource_mul h.scale (a:=1) (by simpa only [pow_one] using hK)
    hb1 (by positivity)) hU (Nat.cast_nonneg _)
  have he : (M.readoutGridRange c:ℝ)≤W^13 := by
    have hh := resource_add_same h.scale (hB.trans (resource_pow_mono h.scale (show 3≤1+4+7 by norm_num))) hm
    simpa only [readoutGridRange,Nat.cast_add,Nat.cast_mul,Nat.cast_one] using hh
  exact ⟨hB,he⟩

 theorem selectedReadoutGrid_polynomial_size (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (c : EuclideanSpace ℝ (states H).Index)
    {W η : ℝ} (h : M.PrimitiveResources W η) (hη : 0<η)
    (hI : (Fintype.card M.PicardInputIndex:ℝ)≤W)
    (hK : (Fintype.card M.PicardStateIndex:ℝ)≤W)
    (hΛ : canonicalNonlinearBudget P (canonicalSignPrecision P)≤W)
    (hc : normalizingScale M.linearGain H*‖c‖≤W) :
    ((M.selectedReadoutGrid c η).size:ℝ)≤W^5250 := by
  have hn := M.selected_grid_numeric_resources hd h hη hI hK hΛ
  have hr := M.selected_readout_numeric_resources hd c h hη hI hK hΛ hc
  have hW : W≤W^105 := by simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤105)
  have hh := arithmeticLayerSize_resource (do':=1) (h.scale.trans hW) (hK.trans hW)
    (by norm_num;linarith [h.scale.trans hW]) hn.2.2.2.1
    (hr.1.trans (resource_pow_mono h.scale (by norm_num)))
    (hn.1.trans (resource_pow_mono h.scale (by norm_num)))
    (hr.2.trans (resource_pow_mono h.scale (by norm_num)))
  rw [←pow_mul] at hh
  have hb : ((M.selectedReadoutGrid c η).size:ℝ)≤
      (arithmeticLayerSize (Fintype.card M.PicardStateIndex) 1 (M.gridMesh η) (M.readoutGridBudget c)
        M.gridStateRange (M.readoutGridRange c):ℝ) := by
    have hs := affineGridCircuit_size (fun _:Unit=>M.readoutCoefficient c) (fun _=>0)
      (M.gridMesh η) (M.readoutGridBudget c) M.gridStateRange (M.readoutGridRange c)
      (fun _=>M.readoutGridBudget_bound c)
    simp only [Fintype.card_unit] at hs
    unfold selectedReadoutGrid
    rw [CircuitMap.size_then]
    simp only [projectGridCoordinates,CircuitMap.rewire_size,zero_add]
    exact_mod_cast hs
  exact hb.trans hh

 theorem selectedInitializerGrid_polynomial_size (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    {W η : ℝ} (h : M.PrimitiveResources W η) (hη : 0<η)
    (hI : (Fintype.card M.PicardInputIndex:ℝ)≤W)
    (hK : (Fintype.card M.PicardStateIndex:ℝ)≤W)
    (hΛ : canonicalNonlinearBudget P (canonicalSignPrecision P)≤W) :
    ((M.selectedInitializerGrid T η).size:ℝ)≤W^6720 := by
  have hn := M.selected_grid_numeric_resources hd h hη hI hK hΛ
  have hW : W≤W^105 := by simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤105)
  have hdI : ((d+1:ℕ):ℝ)≤(Fintype.card M.PicardInputIndex:ℝ) := by
    simp only [PicardInputIndex,Fintype.card_sum,Fintype.card_fin,Nat.cast_add]
    exact le_add_of_nonneg_right (Nat.cast_nonneg _)
  have hh := booleanAffineInitializer_polynomial_size (M.baseCoordinates T) (M.baseCoordinates_norm T hT)
    (h.scale.trans hW) (M.gridMesh η) M.gridStateRange M.gridAffineRange
    (hdI.trans (hI.trans hW)) (hK.trans hW) (hI.trans hW) hn.2.2.2.1
    (hn.1.trans (resource_pow_mono h.scale (by norm_num)))
    (hn.2.2.2.2.trans (resource_pow_mono h.scale (by norm_num)))
  simpa only [selectedInitializerGrid,←pow_mul] using hh

 theorem selectedClassifier_polynomial_size (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (c : EuclideanSpace ℝ (states H).Index)
    {W η : ℝ} (h : M.PrimitiveResources W η) (hη : 0<η) (hη1 : η≤1)
    (hI : (Fintype.card M.PicardInputIndex:ℝ)≤W)
    (hK : (Fintype.card M.PicardStateIndex:ℝ)≤W) (hH : ((H+1:ℕ):ℝ)≤W)
    (hΛ : canonicalNonlinearBudget P (canonicalSignPrecision P)≤W)
    (hc : normalizingScale M.linearGain H*‖c‖≤W) (hk : (canonicalSignIterations P:ℝ)≤W) :
    ((M.selectedClassifier hd T c η hη hη1).size:ℝ)≤W^canonicalClassifierResourceExponent := by
  have hi := M.selectedInitializerGrid_polynomial_size hd T hT h hη hI hK hΛ
  have hs := M.selected_actualPicardGrid_polynomial_size hd T hT h hη hη1 hI hK hH hΛ
  have hr := M.selectedReadoutGrid_polynomial_size hd c h hη hI hK hΛ hc
  have hn := M.selected_grid_numeric_resources hd h hη hI hK hΛ
  have hnr := (M.selected_readout_numeric_resources hd c h hη hI hK hΛ hc).2
  have hW : W≤W^105 := by simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤105)
  have hg := scalarGrid_card_resource (h.scale.trans hW) hn.2.2.2.1
    (hn.1.trans (resource_pow_mono h.scale (by norm_num)))
  have hgr := scalarGrid_card_resource (h.scale.trans hW) hn.2.2.2.1
    (hnr.trans (resource_pow_mono h.scale (by norm_num)))
  rw [←pow_mul] at hg hgr
  have hwidth := resource_mul h.scale (a:=1) (by simpa only [pow_one] using hI) hg (Nat.cast_nonneg _)
  have hiter := resource_mul h.scale (resource_mul h.scale (a:=1) (by simpa only [pow_one] using hk)
    hwidth (by positivity)) hs (Nat.cast_nonneg _)
  let E := 105*canonicalPicardResourceExponent+7000
  have hiE := hi.trans (resource_pow_mono h.scale (show 6720≤E by dsimp [E];omega))
  have hsE := hiter.trans (resource_pow_mono h.scale
    (show 1+(1+105*5)+105*canonicalPicardResourceExponent≤E by dsimp [E];omega))
  have hrE := hr.trans (resource_pow_mono h.scale (show 5250≤E+1 by dsimp [E];omega))
  have hgE := hgr.trans (resource_pow_mono h.scale (show 105*5≤E+2 by dsimp [E];omega))
  have hsum := resource_add_one h.scale (resource_add_same h.scale (resource_add_same h.scale
    (resource_add_same h.scale hiE hsE) hrE) hgE)
  have hraw := assembledGridClassifier_size (M.selectedInitializerGrid T η)
    (M.selectedPicardGrid hd T η hη hη1) (canonicalSignIterations P) (M.selectedReadoutGrid c η)
  have hrawR : ((M.selectedClassifier hd T c η hη hη1).size:ℝ)≤
      ((M.selectedInitializerGrid T η).size:ℝ)+
      (canonicalSignIterations P:ℝ)*((Fintype.card M.PicardInputIndex:ℝ)*(Fintype.card (ScalarGrid (M.gridMesh η) M.gridStateRange):ℝ))*
        ((M.selectedPicardGrid hd T η hη hη1).size:ℝ)+
      ((M.selectedReadoutGrid c η).size:ℝ)+(Fintype.card (ScalarGrid (M.gridMesh η) (M.readoutGridRange c)):ℝ)+1 := by
    exact_mod_cast hraw
  exact hrawR.trans (hsum.trans (resource_pow_mono h.scale (by unfold canonicalClassifierResourceExponent;dsimp [E];omega)))

#print axioms selectedClassifier_polynomial_size
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
