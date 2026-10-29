import GridEndpointClassifier
import UniformProgramGridResources
import ResidualProgramResources

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {κ ι J : Type} [Fintype κ] [Fintype ι] [Fintype J] [DecidableEq ι] [DecidableEq J]

 theorem distanceProgramBlock_dimension (centers : J→EuclideanSpace ℝ ι) :
    (distanceProgramBlock centers).maxDimension≤Fintype.card ι+Fintype.card J*Fintype.card ι+Fintype.card J+1 := by
  unfold distanceProgramBlock
  apply ArithmeticProgram.maxDimension_fromRun
  intro j hj
  interval_cases j <;> simp [distanceCoordinates] <;> omega

 theorem coordinateAugmentGrid_polynomial_size (p : ι→κ) (Q N Q' U : ℕ) {R : ℝ} (hR : 2≤R)
    (hD : (Fintype.card ι:ℝ)≤R) (hQ : (Q:ℝ)≤R) (hN : (N:ℝ)≤R)
    (hQ' : (Q':ℝ)≤R) (hU : (U:ℝ)≤R) :
    ((coordinateAugmentGrid p Q N Q' U).size:ℝ)≤R^64 := by
  have hrec:=coordinateRecodeSize_resource hR hD hQ hN hQ' hU
  have hleft:(((projectGridCoordinates Q N p).then (recodeCoordinates (ι:=ι) Q N Q' U)).size:ℝ)≤R^50:=by
    rw [CircuitMap.size_then]
    simp only [projectGridCoordinates,CircuitMap.rewire_size,zero_add]
    have hh:((recodeCoordinates (ι:=ι) Q N Q' U).size:ℝ)≤coordinateRecodeSize (Fintype.card ι) Q N Q' U:=by
      exact_mod_cast coordinateRecodeSize_bound (κ:=ι) Q N Q' U
    exact hh.trans hrec
  have hg:=scalarGrid_card_resource hR hQ' hU
  have hthree:(3:ℝ)≤R^2:=by nlinarith
  have hconstant:((booleanGridInput (d:=Fintype.card κ*Fintype.card (ScalarGrid Q N)) Q' U
      (fun _:Unit=>BooleanInputSource.constant 1)).size:ℝ)≤R^7:=by
    have hh:=booleanGridInput_size (d:=Fintype.card κ*Fintype.card (ScalarGrid Q N)) Q' U
      (fun _:Unit=>BooleanInputSource.constant 1)
    simp only [Fintype.card_unit,one_mul] at hh
    have hhR : ((booleanGridInput (d:=Fintype.card κ*Fintype.card (ScalarGrid Q N)) Q' U
      (fun _:Unit=>BooleanInputSource.constant 1)).size:ℝ)≤3*(Fintype.card (ScalarGrid Q' U):ℝ):=by exact_mod_cast hh
    exact hhR.trans (resource_mul hR hthree hg (Nat.cast_nonneg _))
  have hdim:(Fintype.card (ι⊕Unit):ℝ)≤R^2:=by
    simpa only [Fintype.card_sum,Fintype.card_unit,Nat.cast_add,Nat.cast_one] using
      resource_add_one hR (a:=1) (by simpa only [pow_one] using hD)
  have hwidth:=resource_mul hR hdim hg (Nat.cast_nonneg _)
  have hsum:=resource_add_same hR hleft (hconstant.trans (resource_pow_mono hR (by norm_num)))
  have hmul:=resource_mul hR hwidth hsum (by positivity)
  have hraw:=sumGridCircuits_size
    ((projectGridCoordinates Q N p).then (recodeCoordinates (ι:=ι) Q N Q' U))
    (booleanGridInput (d:=Fintype.card κ*Fintype.card (ScalarGrid Q N)) Q' U (fun _:Unit=>BooleanInputSource.constant 1))
  have hrawR:((coordinateAugmentGrid p Q N Q' U).size:ℝ)≤
      ((Fintype.card (ι⊕Unit):ℝ)*(Fintype.card (ScalarGrid Q' U):ℝ))*
      ((((projectGridCoordinates Q N p).then (recodeCoordinates (ι:=ι) Q N Q' U)).size:ℝ)+
        ((booleanGridInput (d:=Fintype.card κ*Fintype.card (ScalarGrid Q N)) Q' U (fun _:Unit=>BooleanInputSource.constant 1)).size:ℝ)):=by
    exact_mod_cast hraw
  exact hrawR.trans (hmul.trans (resource_pow_mono hR (by norm_num : 2+5+(50+1)≤64)))

 def distanceClassifierResourceExponent : ℕ :=
  (ArithmeticProgram.resourceExponent 2+1)*(ArithmeticProgram.resourceExponent 2+200)

 theorem coordinateDistanceClassifier_polynomial_size (p : ι→κ) (Q N : ℕ)
    (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool) (r : ℝ) (B U : ℕ)
    (hB : 1≤B) (hc : ∀j i,|centers j i|≤(B:ℝ)) {ε R : ℝ} (hε : 0<ε) (hR : 2≤R)
    (hD : (Fintype.card ι:ℝ)≤R) (hJ : (Fintype.card J:ℝ)≤R)
    (hDim : ((distanceProgramBlock centers).maxDimension:ℝ)≤R)
    (hBudget : (B:ℝ)≤R) (hU : (U:ℝ)≤R) (hQ : (Q:ℝ)≤R) (hN : (N:ℝ)≤R) (hεinv : ε⁻¹≤R) :
    ((coordinateDistanceClassifier p Q N centers labels r B U ε).size:ℝ)≤R^distanceClassifierResourceExponent := by
  let P:=distanceProgramBlock centers
  let E:=ArithmeticProgram.resourceExponent 2
  have hlen:P.length≤2:=(distanceProgramBlock_length centers).le
  have hp:=P.compiled_resources hR B U 2 hε hlen hDim hBudget hU (by simpa only [one_div] using hεinv)
  have hactual:=P.compiled_circuit_resources hR B U 2 hε hlen (distanceProgramBlock_bounded centers B hB hc)
    hDim hBudget hU (by simpa only [one_div] using hεinv)
  have hE:1≤E:=ArithmeticProgram.resourceExponent_pos 2
  have hbig:R≤R^(E+1):=by simpa only [pow_one] using resource_pow_mono hR (by omega : 1≤E+1)
  have hscale:2≤R^(E+1):=hR.trans hbig
  have haug:=coordinateAugmentGrid_polynomial_size p Q N (P.mesh B U ε) U hscale
    (hD.trans hbig) (hQ.trans hbig) (hN.trans hbig) hp.2.1 (hU.trans hbig)
  rw [←pow_mul] at haug
  have hg:=scalarGrid_card_resource hscale hp.2.1
    (hp.1.trans (resource_pow_mono hR (by omega : E≤E+1)))
  have hjbig:(Fintype.card J:ℝ)≤(R^(E+1))^1:=by simpa only [pow_one] using hJ.trans hbig
  have hball0:=resource_add_one hscale (resource_mul hscale hjbig hg (Nat.cast_nonneg _))
  rw [←pow_mul] at hball0
  have hball:((gridBallClassifier (P.mesh B U ε) (P.outputRange B U) labels r).size:ℝ)≤R^((E+1)*7):=by
    have hh:((gridBallClassifier (P.mesh B U ε) (P.outputRange B U) labels r).size:ℝ)≤
        (Fintype.card J:ℝ)*(Fintype.card (ScalarGrid (P.mesh B U ε) (P.outputRange B U)):ℝ)+1:=by
      exact_mod_cast gridBallClassifier_size (P.mesh B U ε) (P.outputRange B U) labels r
    exact hh.trans hball0
  let K:=(E+1)*(E+100)
  have haugK:=haug.trans (resource_pow_mono hR (show (E+1)*64≤K from Nat.mul_le_mul_left _ (by omega)))
  have hcompileK:=hactual.2.trans (resource_pow_mono hR (show (E+1)*E≤K from Nat.mul_le_mul_left _ (by omega)))
  have hballK:=hball.trans (resource_pow_mono hR (show (E+1)*7≤K+1 from (Nat.mul_le_mul_left (E+1) (show 7≤E+100 by omega)).trans (Nat.le_succ K)))
  have hsum:=resource_add_same hR (resource_add_same hR haugK hcompileK) hballK
  have hraw:((coordinateDistanceClassifier p Q N centers labels r B U ε).size:ℝ)=
      ((coordinateAugmentGrid p Q N (P.mesh B U ε) U).size:ℝ)+
      ((P.compile (P.mesh B U ε) B U).size:ℝ)+
      ((gridBallClassifier (P.mesh B U ε) (P.outputRange B U) labels r).size:ℝ):=by
    unfold coordinateDistanceClassifier distanceThresholdEvaluator
    rw [substituteCircuit_size,substituteCircuit_size]
    simp only [P,CircuitMap.size,Nat.cast_add]
    ring
  rw [hraw]
  have hslack (e : ℕ) : (e+1)*(e+100)+1+1≤(e+1)*(e+200) := by nlinarith
  exact hsum.trans (resource_pow_mono hR (hslack E))

#print axioms coordinateDistanceClassifier_polynomial_size
end ConditionalNonpolynomial.AnalyticLookup
