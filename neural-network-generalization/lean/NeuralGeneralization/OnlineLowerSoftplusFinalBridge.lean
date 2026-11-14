import NeuralGeneralization.OnlineLowerSoftplusEmbedding
import NeuralGeneralization.OnlineLowerSoftplusCompact
import NeuralGeneralization.OnlineLowerReluCodeWitness

/-! # The same calibrated star gaps for actual standard-softplus networks -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerSoftplus
open ConcreteModel OnlineLower OnlineLowerRelu OnlineLowerGeometry

theorem softplus_code_strict_witness_all_large {d m : ℕ}
    (hd : 0< d) (C : WalshCodeMap d m)
    (weight : Finset (Fin m)  →  ℝ) (r : Finset (Fin m)  →  ℕ)
    (hcard : ∀ s,(C.support s).card=2*r s+2)
    (hweight : ∀ s,weight s=evenReluCost (r s))
    (g : ClippingCube m → ℝ) (f : BooleanFunction d)
    (hmargin : ∀ x,(1/2:ℝ)≤ labelReal (f x)*(C.base x*g (C.syndrome x)))
    (B : ℝ) (hbudget : 2*Real.sqrt (d:ℝ)*weightedWalshCost weight g< B) :
    ∃N₀:ℕ,0< N₀ ∧ ∀N:ℕ,N₀≤ N → ∃w:Weights d N 0,
      w ∈ marginEvent softplus (1/2) f ∧ weightedSquaredNorm w< B := by
  let q := max 1 (2^m*Fintype.card (Cube d))
  have hq : 0< q := lt_of_lt_of_le (by norm_num) (le_max_left _ _)
  obtain ⟨w,hw,hcost⟩ := relu_code_score_strict_witness_at_width hd C weight r hcard hweight
    g f hmargin B hbudget hq (le_max_right _ _)
  obtain ⟨N₀,hN₀,hlarge⟩ := strict_relu_witness_all_large hq w f hw
  refine ⟨N₀,hN₀,?_⟩
  intro N hN
  obtain ⟨v,hv,he⟩ := hlarge N hN
  exact ⟨v,hv,he.trans_lt hcost⟩

theorem softplus_stage_gaps_of_calibrated_constraints {d m : ℕ}
    (hd : 0< d) (C : WalshCodeMap d m)
    (weight : Finset (Fin m) → ℝ) (r : Finset (Fin m) → ℕ)
    (hdegree : ∀s,(C.support s).card=2*r s+2)
    (hweight : ∀s,weight s=evenReluCost (r s))
    (H : CubeSubgroup m) (v zstar : ClippingCube m)
    (live : ClippingCube m → Prop) (β W cap Hcap : ℝ)
    (hv : v ∉ H.carrier) (hw0 : 0< weight ∅) (hw : ∀s,weight ∅≤ weight s)
    (hcard : 2≤(H.differenceAnnihilator v).card)
    (hM : 4≤ Fintype.card (ClippingCube m))
    (hsum : 6*weight ∅≤∑s,weight s)
    (hcostsign : ∀z,z ≠ cubeOne m → walshExpansion weight z≤0)
    (hzlive : live zstar) (hzcoset : cubeTranslation v zstar ∈ H.carrier)
    (hW : 0≤ W) (hν : ∀z,|reluLiveCost weight H v z|≤ W)
    (hnegative : reluLiveCost weight H v zstar<0)
    (hstrict : ∀z,live z → zstar ≠ z → reluLiveCost weight H v zstar< reluLiveCost weight H v z)
    (hsmall : W*(45*((Fintype.card (ClippingCube m):ℝ)/(2*weight ∅))+
      6*((Fintype.card (ClippingCube m):ℝ)*β))<1)
    (hcap : (2*Real.sqrt (d:ℝ))*(reluCalibrationConstant weight H v+
      reluLiveCost weight H v zstar)< cap)
    (f : BooleanFunction d) (π : InputOrder d) (j : Fin (Fintype.card (Cube d)))
    (g₀ : BooleanFunction d) (hkeep : consistent f (observedPrefix π j) g₀)
    (hmargin : ∀x,(1/2:ℝ)≤ labelReal (g₀ x)*(C.base x*reluStar zstar (C.syndrome x)))
    (hwrong : labelReal (f (π j))*(C.base (π j)*reluStar zstar (C.syndrome (π j)))<(1:ℝ)/2)
    (hout : ∀N:ℕ,0< N → ∀net:Weights d N 0,weightedSquaredNorm net≤ cap → 
      ∀x,|networkOutput softplus net x|≤ Hcap)
    (hactual : ∀N:ℕ,0< N → ∀net:Weights d N 0,
      ClosedOnlineFeasible softplus f (observedPrefix π j) net → weightedSquaredNorm net≤ cap → 
      (weightedSquaredNorm net,networkOutput softplus net) ∈ 
        C.reluScoreConstraints weight H v live (2*Real.sqrt (d:ℝ)) β) :
    ∃N₀:ℕ,0< N₀ ∧ ∀N:ℕ,N₀≤ N → HasStageEnergyGap softplus f π N j := by
  have hs : 0<2*Real.sqrt (d:ℝ) := mul_pos (by norm_num) (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd))
  obtain ⟨δ,hδ,hbarrier⟩ := C.uniform_relu_geometry_gap_with_output_cap softplus
    weight H v zstar live (2*Real.sqrt (d:ℝ)) β W cap Hcap hs hv hw0 hw hcard hsum
    hcostsign hzlive hzcoset hW hν hnegative hstrict hsmall hcap f (observedPrefix π j)
    (π j) hwrong hout hactual
  let B := (2*Real.sqrt (d:ℝ))*(reluCalibrationConstant weight H v+reluLiveCost weight H v zstar)+δ
  have hcost : weightedWalshCost weight (reluStar zstar)=
      reluCalibrationConstant weight H v+reluLiveCost weight H v zstar := by
    rw [reluStar_exact_cost weight H v zstar hv hzcoset (by omega) hM]
    simp only [reluLiveCost,if_pos hzcoset]
  obtain ⟨N₀,hN₀,hlarge⟩ := softplus_code_strict_witness_all_large hd C weight r hdegree hweight
    (reluStar zstar) g₀ hmargin B (by rw [hcost]; dsimp [B]; linarith)
  refine ⟨N₀,hN₀,?_⟩
  intro N hN
  obtain ⟨w₀,hw₀,hcostw⟩ := hlarge N hN
  refine ⟨g₀,hkeep,⟨w₀,hw₀⟩,?_⟩
  intro g hgkeep hgcorrect hgne
  apply networkEnergy_gap_of_cost_barrier softplus g₀ g w₀ hw₀ B hcostw hgne
  intro w hw
  apply hbarrier N (hN₀.trans_le hN) w
    (closedOnlineFeasible_of_consistent_margin softplus f g (observedPrefix π j) hgkeep w hw)
  simpa only [hgcorrect] using (hw (π j)).le

end NeuralGeneralization.OnlineLowerSoftplus
