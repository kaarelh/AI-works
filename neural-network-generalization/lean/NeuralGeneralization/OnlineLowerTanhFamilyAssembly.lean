import NeuralGeneralization.OnlineLowerTanhCodeNetwork
import NeuralGeneralization.OnlineLowerTanhConstraintBridge
import NeuralGeneralization.OnlineLowerTanhFinalBridge
import NeuralGeneralization.OnlineLowerTanhGeometryProtocol

/-! # Actual tanh family, protocol, and Gaussian energy-gap assembly

This module eliminates the network, calibration, score-minimum, finite-width,
and posterior interfaces for the literal shared-carrier family. The remaining
inputs are explicitly the sharp intrinsic parity inequalities and scalar
inequalities for the actual optimized parity costs. The final theorem must
instantiate those inputs; this intermediate assembly is not the main theorem.
-/

noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open ConcreteModel OnlineLower OnlineLowerGeometry

abbrev familyCost (R H k : ℕ) (hR : 0<R) (hH : 0<H) :=
  codeBalancedCost (physicalCode R H k hR hH)

def rectangleStabilityBudget (R H k : ℕ) : ℝ :=
  82948*((pairDim R H k*R:ℕ):ℝ)^2

def rectangleVarianceBudget (R H k : ℕ) (hR : 0<R) (hH : 0<H) (Bcap : ℝ) : ℝ :=
  16*((2*Real.sqrt (dimension R H k:ℝ))*Bcap)/
    rectangleCommonA (familyCost R H k hR hH) (shiftPoint k)+
      5*rectangleStabilityBudget R H k*Bcap

/-- Explicit scalar inequalities on the actual cost function. In particular,
this certificate contains no neural, posterior, energy-gap, or minimizer
assumption. Each field is to be proved by the scalar path construction. -/
structure RectangleScalarCertificate (R H k : ℕ) (hR : 0<R) (hH : 0<H)
    (hk : 3≤k) (W Bcap : ℝ) : Prop where
  cost_conditions : RectangleCostConditions (familyCost R H k hR hH) (shiftPoint k)
  coset_order : ∀z,cubeTranslation (referencePoint k false) z∈(calibrationSubgroup k).carrier →
    0≤rectangleWeightTransform (familyCost R H k hR hH) z ∧
      rectangleWeightTransform (familyCost R H k hR hH) z≤
        rectangleWeightTransform (familyCost R H k hR hH) (cubeTranslation (shiftPoint k) z)
  candidate_injective : Function.Injective (fun digits=>
    rectangleEffectiveCost (familyCost R H k hR hH) (shiftPoint k)
      (candidatePoint k (by omega) false digits))
  envelope_nonneg : 0≤W
  envelope : ∀z,cubeTranslation (referencePoint k false) z∈(calibrationSubgroup k).carrier →
    |rectangleEffectiveCost (familyCost R H k hR hH) (shiftPoint k) z|≤W
  candidate_negative : ∀digits,
    rectangleEffectiveCost (familyCost R H k hR hH) (shiftPoint k)
      (candidatePoint k (by omega) false digits)<0
  cap_nonneg : 0≤Bcap
  candidate_cap : ∀digits,
    rectangleBaselineCost (familyCost R H k hR hH) (shiftPoint k)+
      rectangleEffectiveCost (familyCost R H k hR hH) (shiftPoint k)
        (candidatePoint k (by omega) false digits)<Bcap
  absorption : W*(44*Fintype.card (ClippingCube (logicalDim k))*
    (1/rectangleWeightTransform (familyCost R H k hR hH) (shiftPoint k)+
      1/rectangleCommonA (familyCost R H k hR hH) (shiftPoint k))+
        4*(Fintype.card (ClippingCube (logicalDim k))*rectangleVarianceBudget R H k hR hH Bcap))<1

/-- For the literal family, all actual network and closed-history hypotheses
are discharged. Only intrinsic parity and scalar cost inequalities remain. -/
theorem concrete_stage_gaps_of_intrinsic_and_scalar :
    ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀R H k:ℕ,∀hR:6≤R,∀heven:Even R,∀hH:0<H,Even H → ∀hk:3≤k,
      144<dimension R H k → p₀≤pairDim R H k →
      (k₀:ℝ)*Real.log ((pairDim R H k:ℝ)+2)^2≤R →
      (∀s,IntrinsicParityBound ((physicalCode R H k (by omega) hH).support s).card
        (familyCost R H k (by omega) hH s)) →
      ∀W Bcap:ℝ,RectangleScalarCertificate R H k (by omega) hH hk W Bcap →
      ∃π:InputOrder (dimension R H k),
      ∃J:Finset (Fin (Fintype.card (Cube (dimension R H k)))),
        J.card=2^(k-1) ∧ ∀j∈J,
          ∃N₀:ℕ,0<N₀ ∧ ∀N:ℕ,N₀≤N → HasStageEnergyGap Real.tanh (target R H k) π N j := by
  obtain ⟨k₀,p₀,hk₀,hp₀,hnetwork⟩:=actual_tanh_network_bounds_of_intrinsic
  refine ⟨k₀,p₀,hk₀,hp₀,?_⟩
  intro R H k hR heven hH hevenH hk hd hp hthreshold hsharp W Bcap hscalar
  have hR0:0<R:=by omega
  let C:=physicalCode R H k hR0 hH
  let w:=familyCost R H k hR0 hH
  let G:=calibrationSubgroup k
  let v:=referencePoint k false
  let u:=shiftPoint k
  have hevenR:=heven
  obtain ⟨r,hr⟩:=heven
  have hReq:R=2*r:=by omega
  have hlo:∀i b,2*r≤size R H k i b:=by
    intro i b
    cases b <;> simp only [size_false,size_true] <;> omega
  have hhi:∀i b,size R H k i b≤4*r:=by
    intro i b
    have hi:=(increment_bounds R H k hR i).2
    cases b <;> simp only [size_false,size_true] <;> omega
  have hn : ∀N:ℕ,0<N → ∀net:Weights (dimension R H k) N 0,
      weightedWalshCost w (C.logicalProjection (networkOutput Real.tanh net))≤networkVariationBudget net ∧
      uniformCubeMean (fun x=>(networkOutput Real.tanh net x-
        fourierProject (carrierOddDownwardSupports (size R H k) (column R H k))
          (networkOutput Real.tanh net) x)^2)≤
        rectangleStabilityBudget R H k*networkVariationBudget net*
          (networkVariationBudget net-weightedWalshCost w (C.logicalProjection (networkOutput Real.tanh net))) := by
    intro N hN net
    have ht:=hnetwork (pairDim R H k) r (logicalDim k) hp (by simpa only [←hReq] using hthreshold)
      (size R H k) hlo hhi (size_even R H k hevenR hevenH) (column R H k)
      C (physicalCode_support R H k hR0 hH) hsharp N hN net
    simpa only [←hReq,rectangleStabilityBudget] using ht
  obtain ⟨order,horder⟩:=exists_rectangle_cost_order k (by omega) false w hscalar.candidate_injective
  obtain ⟨π,J,hJ,hcount,hprotocol⟩:=exists_concrete_rectangle_protocol R H k hR0 hH hk false order
  refine ⟨π,J,hcount,?_⟩
  intro j hj
  rw [hJ,designated_round_mem_iff] at hj
  obtain ⟨i,rfl⟩:=hj
  obtain ⟨_,hhistory,hfits,hwrong⟩:=hprotocol i
  let zstar:=orderedCandidate k (by omega) false order i
  let live:=liveAt k (by omega) false order i
  have hz:cubeTranslation v zstar∈G.carrier:=orderedCandidate_mem k (by omega) false order i
  have hnegative:rectangleLiveCost w G v u zstar<0:=by
    rw [rectangleLiveCost,if_pos hz]
    exact hscalar.candidate_negative (order i)
  have hstrict:∀z,live z → zstar≠z → rectangleLiveCost w G v u zstar<rectangleLiveCost w G v u z:=by
    intro z hl hne
    have hzc:=liveAt_mem k (by omega) false order i z hl
    rw [rectangleLiveCost,if_pos hz,rectangleLiveCost,if_pos hzc]
    exact liveAt_strict_cost k (by omega) false order w horder i z hl hne
  have hscale:0<2*Real.sqrt (dimension R H k:ℝ):=
    mul_pos (by norm_num) (Real.sqrt_pos.mpr (Nat.cast_pos.mpr (by omega)))
  have hcap:2*Real.sqrt (dimension R H k:ℝ)*
      (rectangleBaselineCost w u+rectangleLiveCost w G v u zstar)<
        (2*Real.sqrt (dimension R H k:ℝ))*Bcap:=by
    rw [rectangleLiveCost,if_pos hz]
    exact mul_lt_mul_of_pos_left (hscalar.candidate_cap (order i)) hscale
  have hdegree:∀s,(C.support s).card=2*((C.support s).card/2)+1:=by
    intro s
    have ho:Odd ((C.support s).card):=support_odd R H k hevenR hevenH s
    obtain ⟨n,hn⟩:=ho
    omega
  apply tanh_stage_gaps_of_rectangle_constraints hd C w (fun s=>(C.support s).card/2)
    hdegree (fun _=>rfl) G v u zstar hscalar.cost_conditions
    (shiftPoint_not_subgroup k) (referencePoint_not_enlargedSubgroup k false)
    (enlarged_difference_card k false) (concrete_negative_observed_density k false)
    hscalar.coset_order (distinguishedCharacter k) (distinguishedCharacter_mem_difference k false)
    (distinguishedCharacter_shift k) live (rectangleVarianceBudget R H k hR0 hH Bcap) W
    ((2*Real.sqrt (dimension R H k:ℝ))*Bcap) hz
    (by intro he; apply shiftPoint_not_subgroup k; change u∈G.carrier; rw [he]; exact G.one_mem)
    (orderedCandidate_ne_anchor k (by omega) false order i)
    (orderedCandidate_ne_shift k (by omega) false order i)
    hscalar.envelope_nonneg
    (rectangleLiveCost_abs_bound w G v u W hscalar.envelope_nonneg hscalar.envelope)
    hnegative hstrict hscalar.absorption hcap (target R H k) π
    (π.symm (firstInput R H k hR0 hH hk false order i))
    (rectangleClassifier R H k hR0 hH hk false order i)
    ((hfits i).mpr le_rfl)
    (rectanglePhysicalScore_margin R H k hR0 hH hk false order i)
    (lt_of_eq_of_lt hwrong (by norm_num))
  intro N hN net hfeas hcapnet
  obtain ⟨hcost,hdown⟩:=hn N hN net
  exact actual_tanh_mem_rectangle_constraints (size R H k) (column R H k)
    (size_pos R H k hR0) (size_even R H k hevenR hevenH) hN C
    (physicalCode_support R H k hR0 hH) w G v u live hscalar.cost_conditions
    (shiftPoint_not_subgroup k) (referencePoint_not_enlargedSubgroup k false)
    (enlarged_difference_card k false) (concrete_unobserved_independence R H k false)
    net (rectangleStabilityBudget R H k) Bcap (by unfold rectangleStabilityBudget;positivity)
    hscalar.cap_nonneg hfeas.1
    (history_calibration_margins R H k hR0 hH hk false order π i hhistory _ hfeas.2)
    (history_removed_live_mass R H k hR0 hH hk false order π i hhistory _ hfeas.2)
    hcapnet hcost hdown

end NeuralGeneralization.OnlineLowerTanh.Family
