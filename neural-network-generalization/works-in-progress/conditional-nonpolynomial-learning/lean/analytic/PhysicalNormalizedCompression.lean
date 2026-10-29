import PhysicalNormalizedAnchors

/-! Full readout compression of actual physical controlled paths. The entropy
anchor count is independent of scale, width, and raw physical KL: no inverse
power of t appears. The sole prediction amplification is the actual final
sharp gain product and the original readout norm. -/
noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel
open NeuralGeneralization.GaussianFieldTilt

theorem physical_normalized_compression {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 0<H)
    {η ρ : ℝ} (hη : 0<η) (hρ : 0<ρ) :
    ∃S : Finset (Cube d), ∃states : ℕ → CanonicalProgramState d,
      ∃c : EuclideanSpace ℝ (states H).Index,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (S.card:ℝ)≤(H:ℝ)/(2*η)+‖P.readout‖^2/ρ^2 ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      (∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1))) ∧
      (∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x
        ((j:ℝ)*normalizedAnchorError η*physicalGainProduct P j)) ∧
      ‖c‖≤‖P.readout‖ ∧
      ∀x,|inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x)|≤
        ρ+‖P.readout‖*((H:ℝ)*normalizedAnchorError η*physicalGainProduct P H) := by
  have hterminal : ∀x,‖P.feature H x‖≤1 := by
    intro x
    have hh := P.hidden_norm_le_one (H-1) (by omega) x
    simpa only [Nat.sub_add_cancel hH] using hh
  have hδ : ∀j:Fin H,0<η*gaussianEntropyGain (physicalLayerCost P j) := by
    intro j
    exact mul_pos hη (lt_of_lt_of_le zero_lt_one (gaussianEntropyGain_one_le _))
  obtain ⟨S,hcard,hgap,hreadout⟩ := joint_entropy_readout_anchors
    (fun j:Fin H => P.law j)
    (fun j:Fin H => fieldLaw (scaledFeatureCoefficients t (P.feature j)))
    (fun j => P.probability j j.isLt) (fun j => inferInstance)
    (fun j => P.finiteKL j j.isLt)
    (fun j:Fin H => η*gaussianEntropyGain (physicalLayerCost P j)) hδ
    (P.feature H) P.readout hterminal hρ
  obtain ⟨states,hzero,hanchor,hdim,hstep,hquery⟩ := physical_normalized_query_program P hd S hη
    (fun j hj x => hgap ⟨j,hj⟩ x)
  have he : 0≤(H:ℝ)*normalizedAnchorError η*physicalGainProduct P H :=
    mul_nonneg (mul_nonneg (Nat.cast_nonneg _) (normalizedAnchorError_nonneg _))
      (physicalGainProduct_pos P H).le
  obtain ⟨c,hc,herror⟩ := transport_anchored_readout (P.feature H) (states H).feature
    P.readout S he (hanchor H le_rfl) (hquery H le_rfl) hreadout
  refine ⟨S,states,c,hzero,?_,hdim,hstep,hquery,hc,herror⟩
  apply hcard.trans
  apply add_le_add _ le_rfl
  calc
    _ ≤ ∑_j:Fin H,1/(2*η) := Finset.sum_le_sum fun j _ =>
      gaussianEntropyGain_cost_ratio ENNReal.toReal_nonneg hη
    _ = (H:ℝ)/(2*η) := by simp; ring

#print axioms physical_normalized_compression
end ConditionalNonpolynomial.Analytic
