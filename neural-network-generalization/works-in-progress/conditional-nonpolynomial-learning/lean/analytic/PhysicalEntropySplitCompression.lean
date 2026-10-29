import PhysicalEntropySplitProgram
import PhysicalAbsoluteCompression

/-! Full actual compression with Gaussian and non-Gaussian row budgets
retained by the same chosen canonical model at every layer. -/
noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel
open NeuralGeneralization.GaussianFieldTilt

theorem physical_entropy_split_query_program {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (S : Finset (Cube d))
    {η : ℝ} (hη : 0<η)
    (hgap : ∀j<H,∀x,coordinateEntropy (P.law j)
      (fieldLaw (scaledFeatureCoefficients t (P.feature j))) (insert x S)-
      coordinateEntropy (P.law j) (fieldLaw (scaledFeatureCoefficients t (P.feature j))) S≤
      η*gaussianEntropyGain (physicalLayerCost P j)) :
    ∃states : ℕ → CanonicalProgramState d,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (∀j≤H,(states j).physicalAnchorInvariant P S j) ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      (∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1))) ∧
      ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x
        ((j:ℝ)*normalizedAnchorError η*physicalGainProduct P j) := by
  obtain ⟨states,hzero,hanchor,hdim,hstep⟩ := physical_entropy_split_anchor_program P S
  refine ⟨states,hzero,hanchor,hdim,hstep,?_⟩
  intro j
  induction j with
  | zero =>
    intro hj x
    simp only [Nat.cast_zero,zero_mul]
    apply queryFeatureClose_of_gram_eq
    intro u v
    exact (P.initial u v).trans (hzero u v).symm
  | succ j ih =>
    intro hj x
    have hjlt : j<H := by omega
    letI := P.probability j hjlt
    have hηj : 0<η*gaussianEntropyGain (physicalLayerCost P j) :=
      mul_pos hη (lt_of_lt_of_le zero_lt_one (gaussianEntropyGain_one_le _))
    have he : 0≤(j:ℝ)*normalizedAnchorError η*physicalGainProduct P j :=
      mul_nonneg (mul_nonneg (Nat.cast_nonneg _) (normalizedAnchorError_nonneg _))
        (physicalGainProduct_pos P j).le
    have hs := physical_canonical_query_step_scaled (P.feature j) (states j).feature
      (P.feature (j+1)) (states (j+1)).feature (P.law j) P.scale_positive.le
      (P.finiteKL j hjlt) S x he hηj (ih (by omega) x) (hgap j hjlt x)
      (P.recursion j hjlt) ((hstep j hjlt).physicalStep.queryMoments x)
    apply hs.mono
    have hb := physical_anchor_error_normalized P hd j (by omega) x hη
    change _+(t*Real.sqrt (gaussianEntropyGain (physicalLayerCost P j)))*_≤_
    rw [← physicalLayerGain_eq,physicalGainProduct_succ,Nat.cast_add,Nat.cast_one]
    rw [physicalGainProduct_succ] at hb
    nlinarith only [hb]


theorem physical_entropy_split_normalized_compression {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 0<H)
    {η ρ : ℝ} (hη : 0<η) (hρ : 0<ρ) :
    ∃S : Finset (Cube d), ∃states : ℕ → CanonicalProgramState d,
      ∃c : EuclideanSpace ℝ (states H).Index,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (S.card:ℝ)≤(H:ℝ)/(2*η)+‖P.readout‖^2/ρ^2 ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      (∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1))) ∧
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
  obtain ⟨states,hzero,hanchor,hdim,hstep,hquery⟩ := physical_entropy_split_query_program P hd S hη
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


variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

theorem physical_entropy_split_absolute_compression (P : ControlledMarginPath d H t f)
    (hd : 1≤d) (hH : 0<H) {ε ρ : ℝ} (hε : 0<ε) (hε1 : ε≤1) (hρ : 0<ρ) :
    ∃S : Finset (Cube d), ∃states : ℕ→CanonicalProgramState d,
      ∃c : EuclideanSpace ℝ (states H).Index,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (S.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P ε)+‖P.readout‖^2/ρ^2 ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      (∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1))) ∧
      (∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x ε) ∧
      ‖c‖≤‖P.readout‖ ∧
      ∀x,|inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x)|≤ρ+‖P.readout‖*ε := by
  obtain ⟨S,states,c,hzero,hcard,hdim,hstep,hquery,hc,herr⟩ :=
    physical_entropy_split_normalized_compression P hd hH (physicalAbsolutePrecision_pos P hε) hρ
  refine ⟨S,states,c,hzero,hcard,hdim,hstep,?_,hc,?_⟩
  · intro j hj x
    exact (hquery j hj x).mono (physicalAbsolutePrecision_error P hε hε1 j hj)
  · intro x
    exact (herr x).trans (add_le_add le_rfl (mul_le_mul_of_nonneg_left
      (physicalAbsolutePrecision_error P hε hε1 H le_rfl) (norm_nonneg _)))

#print axioms physical_entropy_split_absolute_compression
end ConditionalNonpolynomial.Analytic
