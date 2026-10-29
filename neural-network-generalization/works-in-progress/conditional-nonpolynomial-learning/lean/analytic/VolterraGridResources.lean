import VolterraGridSizeBounds
import UniformProgramGridResources
import AffineGridInitializationResources

noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
namespace VolterraGridSystem
variable {ζ ι : Type} [Fintype ζ] [Fintype ι] {H : ℕ}

def programStepResourceExponent : ℕ :=uniformProgramResourceExponent 14+70

theorem numeric_resources (M : VolterraGridSystem ζ ι H) {W η : ℝ} (hW : 2≤W) (hη : 0<η)
    (hI : (Fintype.card M.InputIndex:ℝ)≤W) (hK : (Fintype.card M.StateIndex:ℝ)≤W)
    (hD : (Fintype.card ι:ℝ)≤W) (hηinv : η⁻¹≤W) (hTotal : M.totalBound≤W) :
    (M.stateRange:ℝ)≤W^6 ∧ ((M.stateRange+1:ℕ):ℝ)≤W^7 ∧
      (M.tolerance η)⁻¹≤W^98 ∧ (M.mesh η:ℝ)≤W^105 ∧ (M.affineRange:ℝ)≤W^42 := by
  have hthree:(3:ℝ)≤W^2:=by nlinarith
  have hres:M.totalBound≤W^2:=hTotal.trans (by nlinarith)
  have hR3:=resource_add_same hW hthree hres
  have hK1 : (Fintype.card M.StateIndex:ℝ)+1≤W^2:=resource_add_one hW (a:=1) (by simpa only [pow_one] using hK)
  have hprod:=resource_mul hW hK1 hR3 (by linarith [M.totalBound_nonneg])
  have hN:(M.stateRange:ℝ)≤W^6:=(M.stateRange_upper).le.trans
    (resource_add_same hW hprod (hthree.trans (resource_pow_mono hW (by norm_num))))
  have hU:((M.stateRange+1:ℕ):ℝ)≤W^7:=by exact_mod_cast resource_add_one hW hN
  have hW7:W≤W^7:=by simpa only [pow_one] using resource_pow_mono hW (by norm_num : 1≤7)
  have hp:=picard_grid_numeric_resources (hW.trans hW7) hη (hI.trans hW7) (hK.trans hW7)
    (hD.trans hW7) (hN.trans (resource_pow_mono hW (by norm_num))) (hηinv.trans hW7)
  rw [←pow_mul,←pow_mul,←pow_mul] at hp
  exact ⟨hN,hU,hp.1,hp.2.1,hp.2.2⟩

 theorem programStep_polynomial_size (M : VolterraGridSystem ζ ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (hB : ∀j,(P j).bounded (B j)) {η R : ℝ} (hη : 0<η) (hR : 2≤R)
    (hP : ∀j,(P j).length≤14) (hDim : ∀j,((P j).maxDimension:ℝ)≤R) (hBudget : ∀j,(B j:ℝ)≤R)
    (hD : (Fintype.card ι:ℝ)≤R) (hI : (Fintype.card M.InputIndex:ℝ)≤R)
    (hK : (Fintype.card M.StateIndex:ℝ)≤R) (hH : ((H+1:ℕ):ℝ)≤R)
    (hQ : (M.mesh η:ℝ)≤R) (hU : ((M.stateRange+1:ℕ):ℝ)≤R)
    (hV : (M.affineRange:ℝ)≤R) (hτ : (M.tolerance η)⁻¹≤R) :
    ((M.programStep P B η).size:ℝ)≤R^programStepResourceExponent := by
  let E:=uniformProgramResourceExponent 14
  have hN:(M.stateRange:ℝ)≤R:=by push_cast at hU;linarith
  have hblocks:∀j,(M.programGridSizeBudget P B η j:ℝ)≤R^E:=by
    intro j
    exact uniformProgramGrid_budget_resource (P j) hR (B j) (M.stateRange+1) (M.mesh η) M.stateRange 14
      (M.tolerance_pos hη) (hP j) hD hD (hDim j) (hBudget j) hU hQ hN hτ
  have hsum:(∑j:Fin (H+1),(M.programGridSizeBudget P B η j:ℝ))≤R^(E+1):=by
    calc
      _ ≤ ∑_j:Fin (H+1),R^E:=Finset.sum_le_sum fun j _=>hblocks j
      _ = (H+1:ℕ)*R^E:=by simp
      _ ≤ R^(1+E):=resource_mul hR (a:=1) (by simpa only [pow_one] using hH) (le_refl _) (by positivity)
      _ = _:=by rw [add_comm]
  have hg:=scalarGrid_card_resource hR hQ hN
  have hi:=resource_mul hR (a:=1) (by simpa only [pow_one] using hI) hg (Nat.cast_nonneg _)
  have hk:=resource_mul hR (a:=1) (by simpa only [pow_one] using hK) hg (Nat.cast_nonneg _)
  have hbank:=resource_mul hR hi (resource_mul hR hk hsum (by positivity)) (by positivity)
  have haf:=arithmeticLayerSize_resource (B:=1) hR hI hK hQ (by norm_num;linarith) hN hV
  have hrec:=coordinateRecodeSize_resource hR hK hQ hV hQ hN
  have hb:=hbank.trans (resource_pow_mono hR (a:=1+5+(1+5+(E+1))) (b:=E+50) (by omega))
  have ha:=haf.trans (resource_pow_mono hR (show 50≤E+50 by omega))
  have hr:=hrec.trans (resource_pow_mono hR (show 50≤E+51 by omega))
  have hs:=resource_add_same hR (resource_add_same hR hb ha) hr
  have hraw:=M.programStep_size P B hB η
  have hrawR:((M.programStep P B η).size:ℝ)≤
      ((Fintype.card M.InputIndex:ℝ)*(Fintype.card (ScalarGrid (M.mesh η) M.stateRange):ℝ))*
      (((Fintype.card M.StateIndex:ℝ)*(Fintype.card (ScalarGrid (M.mesh η) M.stateRange):ℝ))*
        (∑j:Fin (H+1),(M.programGridSizeBudget P B η j:ℝ)))+
      (arithmeticLayerSize (Fintype.card M.InputIndex) (Fintype.card M.StateIndex) (M.mesh η) 1 M.stateRange M.affineRange:ℝ)+
      (coordinateRecodeSize (Fintype.card M.StateIndex) (M.mesh η) M.affineRange (M.mesh η) M.stateRange:ℝ):=by
    exact_mod_cast hraw
  exact hrawR.trans (hs.trans (resource_pow_mono hR (by unfold programStepResourceExponent;dsimp [E];omega)))

 theorem programEvaluator_polynomial_size {d : ℕ} (M : VolterraGridSystem (Fin (d+1)) ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (hB : ∀j,(P j).bounded (B j)) {η R : ℝ} (hη : 0<η) (hR : 2≤R)
    (hP : ∀j,(P j).length≤14) (hDim : ∀j,((P j).maxDimension:ℝ)≤R) (hBudget : ∀j,(B j:ℝ)≤R)
    (hD : (Fintype.card ι:ℝ)≤R) (hI : (Fintype.card M.InputIndex:ℝ)≤R)
    (hK : (Fintype.card M.StateIndex:ℝ)≤R) (hH : ((H+1:ℕ):ℝ)≤R)
    (hQ : (M.mesh η:ℝ)≤R) (hU : ((M.stateRange+1:ℕ):ℝ)≤R)
    (hV : (M.affineRange:ℝ)≤R) (hτ : (M.tolerance η)⁻¹≤R) (k : ℕ) (hk : (k:ℝ)≤R) :
    ((M.programEvaluator P B η k).size:ℝ)≤R^(programStepResourceExponent+80) := by
  have hN:(M.stateRange:ℝ)≤R:=by push_cast at hU;linarith
  have hdI:((d+1:ℕ):ℝ)≤(Fintype.card M.InputIndex:ℝ):=by
    simp only [InputIndex,Fintype.card_sum,Fintype.card_fin,Nat.cast_add]
    exact le_add_of_nonneg_right (Nat.cast_nonneg _)
  have hi:=booleanAffineInitializer_polynomial_size M.base M.base_norm hR (M.mesh η) M.stateRange M.affineRange
    (hdI.trans hI) hK hI hQ hN hV
  have hs:=M.programStep_polynomial_size P B hB hη hR hP hDim hBudget hD hI hK hH hQ hU hV hτ
  have hg:=scalarGrid_card_resource hR hQ hN
  have hwidth:=resource_mul hR (a:=1) (by simpa only [pow_one] using hI) hg (Nat.cast_nonneg _)
  have hiter:=resource_mul hR (resource_mul hR (a:=1) (by simpa only [pow_one] using hk) hwidth (by positivity)) hs (Nat.cast_nonneg _)
  have hp:=(gridIteration_bounds (M.programStep P B η) k).1
  have hraw:((M.programEvaluator P B η k).size:ℝ)≤((M.initialGrid η).size:ℝ)+
      (k:ℝ)*((Fintype.card M.InputIndex:ℝ)*(Fintype.card (ScalarGrid (M.mesh η) M.stateRange):ℝ))*
        ((M.programStep P B η).size:ℝ):=by
    unfold programEvaluator
    rw [CircuitMap.size_then,Nat.cast_add]
    apply add_le_add (le_refl _)
    exact_mod_cast hp
  have hlarge:64≤1+(1+5)+programStepResourceExponent:=by unfold programStepResourceExponent;omega
  have hsum:=resource_add_same hR (hi.trans (resource_pow_mono hR hlarge)) hiter
  exact hraw.trans (hsum.trans (resource_pow_mono hR (by omega)))

#print axioms programStep_polynomial_size
#print axioms programEvaluator_polynomial_size
end VolterraGridSystem
end ConditionalNonpolynomial.AnalyticLookup
