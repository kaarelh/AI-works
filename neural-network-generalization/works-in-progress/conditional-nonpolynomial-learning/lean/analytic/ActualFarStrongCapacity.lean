import FarStrongCompressedProgram
import FarStrongPrefixCircuit
import UniformCapacityAssembly

/-! The actual far-strong threshold-circuit construction, including all
physical compression, prefix geometry, finite grid, Boolean initialization,
classifier and uniform polynomial resource choices. -/
noncomputable section
set_option maxHeartbeats 2400000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

def farStrongCapacityExponent (B:ℝ) : ℕ :=
  naturalCircuitResourceExponent (farStrongNumericExponent B*farStrongCompilerExponent)
    (80*(farStrongPrefixCoefficient B+1)+17)

theorem actualFarStrongPathCapacity : FarStrongPathCapacity := by
  classical
  intro B hB
  refine ⟨farStrongDepthPadding B,farStrongCapacityExponent B,
    by unfold farStrongDepthPadding;omega,naturalCircuitResourceExponent_one _ _,?_⟩
  intro d H R hd hH hR hres hpad t ht ht1 ha f path hnear
  have hnear':path.action≤denominatorBudget B t R H := hnear
  obtain ⟨S,states,c,sources,hsource,hcard,hstep,hu,hmargin,hcp,hJlarge,hW,hJ,hJW,hLW,hcenters,hi,hdim,hrank⟩:=
    exists_farStrong_compressed_program path hB hd hH hR hres hpad ha hnear'
  let J:=farStrongPrefixLength B R
  let W:ℝ:=(R:ℝ)^farStrongNumericExponent B
  let E:ℝ:=(∑j∈Finset.range H,physicalLayerCost path j)-(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal
  let a:ℝ:=(t^2)⁻¹-1
  have hta:t^2*(a+1)=1 := by dsimp [a];rw [sub_add_cancel,mul_inv_cancel₀ (sq_pos_of_pos ht).ne']
  choose M hrec using fun j hj=>(hstep j hj).layerModel
  have hbudget:(∑j∈Finset.range H,physicalLayerCost path j)-(H:ℝ)*twoBallEntropyBaseline a≤E := by
    dsimp [a,E]
    rw [farStrong_baseline_eq ht]
  have hjlarge:40*(E/a+Real.log (4*‖c‖/((1/4:ℝ)/8)))≤(J:ℝ) := by
    simpa only [show (2:ℝ)*2=4 by norm_num] using hJlarge
  have hdim':∀j≤J,(Fintype.card (states j).Index:ℝ)≤W := by
    intro j hj
    exact hdim j (hj.trans hJ)
  have hLW':‖c‖*sharpFiniteProduct t (physicalLayerCost path) H≤W := by
    rw [physical_sharp_product_eq path H]
    exact hLW
  have hi':(farStrongGridPrecision J (‖c‖*sharpFiniteProduct t (physicalLayerCost path) H))⁻¹≤W := by
    rw [physical_sharp_product_eq path H]
    exact hi
  have hcenters':((2^J:ℕ):ℝ)≤W := by simpa only [Nat.cast_pow,Nat.cast_ofNat] using hcenters
  obtain ⟨C,hsize,hdepth,hf⟩:=actual_farStrong_normalized_prefix_circuit M hcard ht ha hta
    (fun j=>(states j).feature) f hrec hu c hmargin sources hsource hbudget J hJ hjlarge
    hW hdim' hJW hcenters' hLW' hi'
  obtain ⟨hs,hdp⟩:=farStrong_classifier_resource_conversion hB hR C hsize hdepth
  exact ⟨C,hs,hdp,hf⟩

#print axioms actualFarStrongPathCapacity
end ConditionalNonpolynomial.Analytic
