import NeuralGeneralization.OnlineLowerTanhGeometryClosed
import NeuralGeneralization.OnlineLowerTanhCodeWitness
import NeuralGeneralization.Activation

/-! # The actual tanh posterior bridge

The closed rectangle constraints give a width-uniform positive correct-score
cost gap. Integer neuron allocation then gives strict wrong-score witnesses
at every sufficiently large width, after which the actual Gaussian posterior
concentrates on wrong predictions as its scale tends to zero.
-/
noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerTanh OnlineLowerGeometry

theorem tanh_stage_gaps_of_rectangle_constraints {d m:ℕ}
    (hd:144<d) (C:WalshCodeMap d m)
    (weight:Finset (Fin m) → ℝ) (r:Finset (Fin m) → ℕ)
    (hdegree:∀s,(C.support s).card=2*r s+1)
    (hweight:∀s,weight s=balancedCost (r s))
    (H:CubeSubgroup m) (v u zstar:ClippingCube m)
    (hw:RectangleCostConditions weight u) (hu:u∉H.carrier) (hv:v∉(H.adjoinPoint u).carrier)
    (hE:2≤((H.adjoinPoint u).differenceAnnihilator v).card)
    (hdensity:(1:ℝ)/2≤uniformCubeMean (fun z=>if z∈rectangleNegativeObserved H v u then 1 else 0))
    (horder:∀z,cubeTranslation v z∈H.carrier → 0≤rectangleWeightTransform weight z ∧
      rectangleWeightTransform weight z≤rectangleWeightTransform weight (cubeTranslation u z))
    (e:Finset (Fin m)) (he:e∈H.differenceAnnihilator v) (heu:walshCharacter e u=-1)
    (live:ClippingCube m → Prop) (β W cap:ℝ)
    (hzcoset:cubeTranslation v zstar∈H.carrier)
    (hu0:u≠cubeOne m) (hz0:zstar≠cubeOne m) (hzu:zstar≠u)
    (hW:0≤W) (hν:∀z,|rectangleLiveCost weight H v u z|≤W)
    (hnegative:rectangleLiveCost weight H v u zstar<0)
    (hstrict:∀z,live z → zstar≠z → rectangleLiveCost weight H v u zstar<rectangleLiveCost weight H v u z)
    (hsmall:W*(44*Fintype.card (ClippingCube m)*
      (1/rectangleWeightTransform weight u+1/rectangleCommonA weight u)+
        4*(Fintype.card (ClippingCube m)*β))<1)
    (hcap:2*Real.sqrt (d:ℝ)*(rectangleBaselineCost weight u+
      rectangleLiveCost weight H v u zstar)<cap)
    (f:BooleanFunction d) (π:InputOrder d) (j:Fin (Fintype.card (Cube d)))
    (g₀:BooleanFunction d) (hkeep:consistent f (observedPrefix π j) g₀)
    (hmargin:∀x,(1/2:ℝ)≤labelReal (g₀ x)*(C.base x*rectangleScore u zstar (C.syndrome x)))
    (hwrong:labelReal (f (π j))*(C.base (π j)*rectangleScore u zstar (C.syndrome (π j)))<(1:ℝ)/2)
    (hactual:∀N:ℕ,0<N → ∀net:Weights d N 0,
      ClosedOnlineFeasible Real.tanh f (observedPrefix π j) net → weightedSquaredNorm net≤cap → 
      (weightedSquaredNorm net,networkOutput Real.tanh net)∈
        C.rectangleScoreConstraints weight H v u live (2*Real.sqrt (d:ℝ)) β) :
    ∃N₀:ℕ,0<N₀ ∧ ∀N:ℕ,N₀≤N → HasStageEnergyGap Real.tanh f π N j := by
  have hd0:0<d:=by omega
  have hscale:0<2*Real.sqrt (d:ℝ):=mul_pos (by norm_num) (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd0))
  have hφ:∀t,|Real.tanh t|≤|t|:=fun t=>by
    simpa only [Real.tanh_zero,sub_zero] using tanh_admissible.2 t 0
  obtain ⟨δ,hδ,hbarrier⟩:=C.uniform_rectangle_correct_cost_gap hd0 Real.tanh hφ
    weight H v u zstar hw hu hv hE hdensity horder e he heu live (2*Real.sqrt (d:ℝ)) β W cap
    hscale hW hν hnegative hstrict hsmall hcap f (observedPrefix π j) (π j) hwrong hactual
  have hcost:weightedWalshCost weight (rectangleScore u zstar)=
      rectangleBaselineCost weight u+rectangleLiveCost weight H v u zstar:=by
    rw [rectangleScore_exact_cost]
    simp only [rectangleLiveCost,if_pos hzcoset]
  apply tanh_code_stage_gaps_all_large hd C weight r hdegree hweight
    (rectangleScore u zstar) (by rw [rectangleScore_algebraNorm u zstar hu0 hz0 hzu])
    f π j g₀ hkeep hmargin δ hδ
  intro N hN net hfeas hcorrect
  rw [hcost]
  exact hbarrier N hN net hfeas hcorrect

/-- Finitely many designated rounds share one width threshold; the order
and target are already fixed before this threshold is chosen. -/
theorem allLargeWidthsFail_of_eventual_energy_gaps {d C:ℕ} (hd:0<d)
    {φ:ℝ → ℝ} (hφ:Continuous φ) {f:BooleanFunction d} (hteacher:BoundedTeacher φ f C)
    (π:InputOrder d) (J:Finset (Fin (Fintype.card (Cube d))))
    (hgaps:∀j∈J,∃N₀:ℕ,∀N:ℕ,N₀≤N → HasStageEnergyGap φ f π N j) :
    AllLargeWidthsFail φ f C π J := by
  have he:∀ᶠN:ℕ in atTop,∀j∈J,HasStageEnergyGap φ f π N j:=by
    apply (eventually_all_finset J).mpr
    intro j hj
    exact eventually_atTop.mpr (hgaps j hj)
  obtain ⟨N₁,hN₁⟩:=eventually_atTop.mp he
  let N₀:=max C (max 1 N₁)
  apply allLargeWidthsFail_of_energy_gaps hd hφ hteacher π J
    (show C≤N₀ from le_max_left _ _) (show 0<N₀ by omega)
  intro N hN j hj
  exact hN₁ N (by dsimp [N₀] at hN; omega) j hj

end NeuralGeneralization.OnlineLower
