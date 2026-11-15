import NeuralGeneralization.OnlineLowerGeometryReluClosed

/-! Compact separation with independent energy and output caps.
This permits activations with a nonzero value at the origin, including softplus.
The cap hypothesis is an intermediate deterministic interface, not an assumption
of the eventual softplus learning theorem. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLower
open ConcreteModel

def independentScorePairBox (d : ℕ) (cap outputCap : ℝ) : Set (ℝ × (Cube d → ℝ)) :=
  Set.Icc (0,fun _ => -outputCap) (cap,fun _ => outputCap)

theorem isCompact_independentScorePairBox (d : ℕ) (cap outputCap : ℝ) :
    IsCompact (independentScorePairBox d cap outputCap) := isCompact_Icc

theorem actual_score_pair_mem_independent_box {d N : ℕ}
    (φ : ℝ → ℝ) (w : Weights d N 0) (cap outputCap : ℝ)
    (hcap : weightedSquaredNorm w ≤ cap)
    (hout : ∀x, |networkOutput φ w x| ≤ outputCap) :
    (weightedSquaredNorm w,networkOutput φ w) ∈ independentScorePairBox d cap outputCap := by
  exact ⟨⟨weightedSquaredNorm_nonneg w,fun x => (abs_le.mp (hout x)).1⟩,
    ⟨hcap,fun x => (abs_le.mp (hout x)).2⟩⟩

/-- A uniform energy gap using any proved width-independent output cap. -/
theorem uniform_neural_cost_gap_with_output_cap
    {d n : ℕ} (φ : ℝ → ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) (x : Cube d)
    (constraints : Set (ℝ × (Cube d → ℝ))) (hclosed : IsClosed constraints)
    (cstar cap outputCap : ℝ) (hcap : cstar < cap) (Fstar : Cube d → ℝ)
    (hout : ∀N : ℕ, 0 < N → ∀w : Weights d N 0,
      weightedSquaredNorm w ≤ cap → ∀x, |networkOutput φ w x| ≤ outputCap)
    (hactual : ∀N : ℕ, 0 < N → ∀w : Weights d N 0,
      ClosedOnlineFeasible φ f sample w → weightedSquaredNorm w ≤ cap →
        (weightedSquaredNorm w,networkOutput φ w) ∈ constraints)
    (hmin : ∀p ∈ independentScorePairBox d cap outputCap ∩ constraints,cstar ≤ p.1)
    (hclass : ∀p ∈ independentScorePairBox d cap outputCap ∩ constraints,
      p.1 = cstar → p.2 = Fstar)
    (hwrong : labelReal (f x)*Fstar x < (1/2 : ℝ)) :
    ∃δ : ℝ, 0 < δ ∧ ∀N : ℕ, 0 < N → ∀w : Weights d N 0,
      ClosedOnlineFeasible φ f sample w →
      (1/2 : ℝ) ≤ labelReal (f x)*networkOutput φ w x →
      cstar+δ ≤ weightedSquaredNorm w := by
  have hc : IsCompact (independentScorePairBox d cap outputCap ∩ constraints) :=
    (isCompact_independentScorePairBox d cap outputCap).inter_right hclosed
  obtain ⟨δ,hδ,hgap⟩ := OnlineLowerGeometry.compact_score_pair_gap
    (independentScorePairBox d cap outputCap ∩ constraints) cstar (1/2)
    (labelReal (f x)) Fstar x hc hmin hclass hwrong
  refine ⟨min δ (cap-cstar),lt_min hδ (sub_pos.mpr hcap),?_⟩
  intro N hN w hw hcorrect
  by_cases hbelow : weightedSquaredNorm w ≤ cap
  · have hp : (weightedSquaredNorm w,networkOutput φ w) ∈
        independentScorePairBox d cap outputCap ∩ constraints :=
      ⟨actual_score_pair_mem_independent_box φ w cap outputCap hbelow (hout N hN w hbelow),
        hactual N hN w hw hbelow⟩
    have h := hgap _ hp hcorrect
    have hm := min_le_left δ (cap-cstar)
    linarith
  · have hm := min_le_right δ (cap-cstar)
    linarith
end NeuralGeneralization.OnlineLower

namespace NeuralGeneralization.OnlineLowerGeometry.WalshCodeMap
variable {d m : ℕ} (C : WalshCodeMap d m)

/-- The ReLU-type closed score geometry applies to any activation once its
actual outputs satisfy the proved geometric inequalities and a uniform cap. -/
theorem uniform_relu_geometry_gap_with_output_cap
    {n : ℕ} (φ : ℝ → ℝ)
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v zstar : ClippingCube m)
    (live : ClippingCube m → Prop) (scale β W cap outputCap : ℝ)
    (hscale : 0 < scale) (hv : v ∉ H.carrier)
    (hw0 : 0 < w ∅) (hw : ∀s,w ∅ ≤ w s)
    (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hsum : 6*w ∅ ≤ ∑s,w s)
    (hcostsign : ∀z,z ≠ cubeOne m → walshExpansion w z ≤ 0)
    (hzlive : live zstar) (hzcoset : cubeTranslation v zstar ∈ H.carrier)
    (hW : 0 ≤ W) (hν : ∀z, |reluLiveCost w H v z| ≤ W)
    (hnegative : reluLiveCost w H v zstar < 0)
    (hstrict : ∀z,live z → zstar ≠ z → reluLiveCost w H v zstar < reluLiveCost w H v z)
    (hsmall : W*(45*((Fintype.card (ClippingCube m) : ℝ)/(2*w ∅))+
      6*((Fintype.card (ClippingCube m) : ℝ)*β)) < 1)
    (hcap : scale*(reluCalibrationConstant w H v+reluLiveCost w H v zstar) < cap)
    (f : ConcreteModel.BooleanFunction d) (sample : Fin n → ConcreteModel.Cube d)
    (x : ConcreteModel.Cube d)
    (hwrong : ConcreteModel.labelReal (f x)*(C.base x*reluStar zstar (C.syndrome x)) < (1/2 : ℝ))
    (hout : ∀N : ℕ,0 < N → ∀net : ConcreteModel.Weights d N 0,
      ConcreteModel.weightedSquaredNorm net ≤ cap → ∀x, |ConcreteModel.networkOutput φ net x| ≤ outputCap)
    (hactual : ∀N : ℕ,0 < N → ∀net : ConcreteModel.Weights d N 0,
      OnlineLower.ClosedOnlineFeasible φ f sample net → ConcreteModel.weightedSquaredNorm net ≤ cap →
      (ConcreteModel.weightedSquaredNorm net,ConcreteModel.networkOutput φ net) ∈
        C.reluScoreConstraints w H v live scale β) :
    ∃δ : ℝ,0 < δ ∧ ∀N : ℕ,0 < N → ∀net : ConcreteModel.Weights d N 0,
      OnlineLower.ClosedOnlineFeasible φ f sample net →
      (1/2 : ℝ) ≤ ConcreteModel.labelReal (f x)*ConcreteModel.networkOutput φ net x →
      scale*(reluCalibrationConstant w H v+reluLiveCost w H v zstar)+δ ≤
        ConcreteModel.weightedSquaredNorm net := by
  apply OnlineLower.uniform_neural_cost_gap_with_output_cap φ f sample x
    (C.reluScoreConstraints w H v live scale β) (C.isClosed_reluScoreConstraints w H v live scale β)
    (scale*(reluCalibrationConstant w H v+reluLiveCost w H v zstar)) cap outputCap hcap
    (fun x => C.base x*reluStar zstar (C.syndrome x)) hout hactual
  · intro q hq
    exact (C.reluScoreConstraints_minimum w H v zstar live scale β W hscale hv hw0 hw hcard
      hsum hcostsign hzlive hzcoset hW hν hnegative hstrict hsmall q hq.2).1
  · intro q hq heq
    exact (C.reluScoreConstraints_minimum w H v zstar live scale β W hscale hv hw0 hw hcard
      hsum hcostsign hzlive hzcoset hW hν hnegative hstrict hsmall q hq.2).2 heq
  · exact hwrong
end NeuralGeneralization.OnlineLowerGeometry.WalshCodeMap
