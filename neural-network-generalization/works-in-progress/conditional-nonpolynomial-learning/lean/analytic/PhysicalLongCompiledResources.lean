import PhysicalGainPrefixEvaluator
import PhysicalGainPrefixChosenResources
import VolterraGridResources
import PhysicalLongResourceEnvelope

noncomputable section
set_option maxHeartbeats 1500000
set_option maxRecDepth 20000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort

def longCompiledPrefixResourceExponent : ℕ :=
  (105*984)*(VolterraGridSystem.programStepResourceExponent+80)

namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

/-- Polynomial resources for the literal arithmetic/Picard threshold graph.
The primitive premise contains only numerical bounds on its actual data. -/
theorem compiledPrefix_polynomial_size (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    {W η : ℝ} (h : M.PrimitiveResources W η) (hη : 0<η) (hη1 : η≤1)
    (hI : (Fintype.card (M.gridSystem T hT).InputIndex:ℝ)≤W)
    (hK : (Fintype.card (M.gridSystem T hT).StateIndex:ℝ)≤W)
    (hJ : ((J+1:ℕ):ℝ)≤W) (hTotal : (M.gridSystem T hT).totalBound≤W)
    (k : ℕ) (hk : (k:ℝ)≤W) :
    ((M.compiledPrefix T hT η hη hη1 k).size:ℝ)≤W^longCompiledPrefixResourceExponent := by
  let G:=M.gridSystem T hT
  have hn:=G.numeric_resources h.scale hη hI hK h.dimension h.tolerance hTotal
  have hW105 : W≤W^105 := by simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤105)
  have hprim : M.PrimitiveResources (W^105) (G.tolerance η) :=
    ⟨h.scale.trans hW105,h.dimension.trans hW105,h.anchors.trans hW105,
      fun j=>(h.floor j).trans hW105,hn.2.2.1.trans (resource_pow_mono h.scale (by norm_num))⟩
  have hp (j : Fin (J+1)):=M.chosenResidualProgram_resources hprim
    (G.tolerance_pos hη) (G.tolerance_one hη hη1) j
  simp only [←pow_mul] at hp
  have hWbig : W≤W^(105*984) := by
    simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤105*984)
  have hmono (a : ℕ) (ha : a≤105*984) : W^a≤W^(105*984) := resource_pow_mono h.scale ha
  have hsize:=G.programEvaluator_polynomial_size
    (M.selectedResidualProgram T hT η hη hη1) M.allResidualCoefficientBudget
    (fun j=>(M.chosenResidualProgram_spec _ _ _ j).2.1)
    hη (h.scale.trans hWbig)
    (fun j=>(M.chosenResidualProgram_spec _ _ _ j).1)
    (fun j=>(hp j).1) (fun j=>(hp j).2)
    (h.dimension.trans hWbig) (hI.trans hWbig) (hK.trans hWbig) (hJ.trans hWbig)
    (hn.2.2.2.1.trans (hmono 105 (by norm_num)))
    (hn.2.1.trans (hmono 7 (by norm_num)))
    (hn.2.2.2.2.trans (hmono 42 (by norm_num)))
    (hn.2.2.1.trans (hmono 98 (by norm_num))) k (hk.trans hWbig)
  exact hsize.trans_eq (pow_mul W (105*984) (VolterraGridSystem.programStepResourceExponent+80)).symm

#print axioms compiledPrefix_polynomial_size
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
