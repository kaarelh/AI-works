import PhysicalShortChosenProgramResources

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

def canonicalPicardResourceExponent : ℕ := 656*uniformProgramResourceExponent 14+70

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 theorem actualPicardGrid_polynomial_size (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    {W τ ε : ℝ} (h : M.PrimitiveResources W τ) (hτ : 0<τ) (hτ1 : τ≤1)
    (Q N U V : ℕ) (hQ : (Q:ℝ)≤W) (hN : (N:ℝ)≤W) (hU : (U:ℝ)≤W) (hV : (V:ℝ)≤W)
    (hε : 0<ε) (hεinv : ε⁻¹≤W)
    (hI : (Fintype.card M.PicardInputIndex:ℝ)≤W) (hK : (Fintype.card M.PicardStateIndex:ℝ)≤W)
    (hH : (H+1:ℕ)≤W) :
    ((M.actualPicardGrid hd T τ hτ hτ1 Q N U V ε).size:ℝ)≤W^canonicalPicardResourceExponent := by
  let E := 656*uniformProgramResourceExponent 14
  have hsum : (∑j:Fin (H+1),(M.residualGridSizeBudget hd τ hτ hτ1 Q N U ε j:ℝ))≤W^(E+1) := by
    calc
      _ ≤ ∑_j:Fin (H+1),W^E := Finset.sum_le_sum (fun j _=>M.residualGridSizeBudget_polynomial hd h hτ hτ1 Q N U hQ hN hU hε hεinv j)
      _ = (H+1:ℕ)*W^E := by simp
      _ ≤ W^(1+E) := resource_mul h.scale (a:=1) (by simpa only [pow_one] using hH) (le_refl _) (pow_nonneg (by linarith [h.scale]) _)
      _ = _ := by rw [add_comm]
  have hg := scalarGrid_card_resource h.scale hQ hN
  have hIgrid := resource_mul h.scale (a:=1) (by simpa only [pow_one] using hI) hg (Nat.cast_nonneg _)
  have hKgrid := resource_mul h.scale (a:=1) (by simpa only [pow_one] using hK) hg (Nat.cast_nonneg _)
  have hbank := resource_mul h.scale hIgrid (resource_mul h.scale hKgrid hsum (by positivity)) (by positivity)
  have haf := arithmeticLayerSize_resource (B:=1) h.scale hI hK hQ
    (by norm_num;linarith [h.scale]) hN hV
  have hrec := coordinateRecodeSize_resource h.scale hK hQ hV hQ hN
  have hb : ((Fintype.card M.PicardInputIndex:ℝ)*(Fintype.card (ScalarGrid Q N):ℝ))*
      (((Fintype.card M.PicardStateIndex:ℝ)*(Fintype.card (ScalarGrid Q N):ℝ))*
        (∑j:Fin (H+1),(M.residualGridSizeBudget hd τ hτ hτ1 Q N U ε j:ℝ)))≤W^(E+50) :=
    hbank.trans (resource_pow_mono h.scale (a:=1+5+(1+5+(E+1))) (b:=E+50) (by omega))
  have ha := haf.trans (resource_pow_mono h.scale (show 50≤E+50 by omega))
  have hr := hrec.trans (resource_pow_mono h.scale (show 50≤E+51 by omega))
  have hs := resource_add_same h.scale (resource_add_same h.scale hb ha) hr
  have hraw : ((M.actualPicardGrid hd T τ hτ hτ1 Q N U V ε).size:ℝ)≤
      ((Fintype.card M.PicardInputIndex:ℝ)*(Fintype.card (ScalarGrid Q N):ℝ))*
        (((Fintype.card M.PicardStateIndex:ℝ)*(Fintype.card (ScalarGrid Q N):ℝ))*
          (∑j:Fin (H+1),(M.residualGridSizeBudget hd τ hτ hτ1 Q N U ε j:ℝ)))+
      (arithmeticLayerSize (Fintype.card M.PicardInputIndex) (Fintype.card M.PicardStateIndex) Q 1 N V:ℝ)+
      (coordinateRecodeSize (Fintype.card M.PicardStateIndex) Q V Q N:ℝ) := by
    exact_mod_cast M.actualPicardGrid_size hd T hT τ hτ hτ1 Q N U V ε
  exact hraw.trans (hs.trans (resource_pow_mono h.scale (by unfold canonicalPicardResourceExponent;dsimp [E];omega)))

#print axioms actualPicardGrid_polynomial_size
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
