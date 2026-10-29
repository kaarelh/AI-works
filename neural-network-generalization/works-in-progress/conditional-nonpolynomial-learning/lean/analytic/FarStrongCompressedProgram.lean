import FarStrongNumericEnvelope

noncomputable section
set_option maxHeartbeats 2200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

/-- An actual canonical compression with its original Boolean initializer,
strict target margin and all resource premises of the far-strong compiler.
The powers and depth padding depend only on the excess-action coefficient. -/
theorem exists_farStrong_compressed_program {B t:ℝ} {d H R:ℕ} {f:BooleanFunction d}
    (P:ControlledMarginPath d H t f) (hB:0≤B) (hd:1≤d) (hH:1≤H) (hR:2≤R)
    (hres:d+H+1≤R) (hpad:farStrongDepthPadding B*Nat.log2 R≤H)
    (ha:1/4≤(t^2)⁻¹-1) (hnear:P.action≤denominatorBudget B t R H) :
    let W:ℝ:=(R:ℝ)^farStrongNumericExponent B
    let J:=farStrongPrefixLength B R
    ∃S:Finset (Cube d),∃states:ℕ→CanonicalProgramState d,
      ∃c:EuclideanSpace ℝ (states H).Index,
      ∃sources:(states 0).Index→BooleanInputSource d,
      (∀x i,(sources i).eval x=(states 0).feature x i) ∧
      2≤Fintype.card (states 0).Index ∧
      (∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1))) ∧
      (∀x,‖(states 0).feature x‖≤2) ∧
      (∀x,(1:ℝ)/4≤labelReal (f x)*inner ℝ c ((states H).feature x)) ∧
      0<‖c‖ ∧
      40*((((∑j∈Finset.range H,physicalLayerCost P j)-(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal)/((t^2)⁻¹-1))+
        Real.log (2*2*‖c‖/((1/4)/8)))≤(J:ℝ) ∧
      2≤W ∧ J≤H ∧ (J:ℝ)≤W ∧ ‖c‖*physicalGainProduct P H≤W ∧ (2:ℝ)^J≤W ∧
      (farStrongStepTolerance J (‖c‖*physicalGainProduct P H))⁻¹≤W ∧
      (∀j≤H,((states j).dimension:ℝ)≤W) ∧
      (∀j≤H,((states j).dimension:ℝ)+(S.card:ℝ)≤W) := by
  classical
  intro W J
  obtain ⟨hex,hgain,hread⟩:=farStrong_action_envelope_from_padding P hB hH hR hres hpad ha hnear
  obtain ⟨S,states,c,sources,hsource,hidx,hzero,hcard,hdim,hstep,hquery,hc,herror⟩:=
    physical_normalized_compression_sources P hd (by omega)
      (farStrongCompressionPrecision_pos P) (show (0:ℝ)<1/16 by norm_num)
  have hRr:(2:ℝ)≤R := by exact_mod_cast hR
  have hHR:(H:ℝ)+1≤R := by exact_mod_cast (show H+1≤R by omega)
  have hS:=farStrong_anchor_card_bound P hRr hHR hread hgain hcard
  have hmargin:∀x,(1:ℝ)/4≤labelReal (f x)*inner ℝ c ((states H).feature x) := by
    intro x
    have herr:|inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x)|≤1/8 :=
      (herror x).trans (farStrong_compression_prediction_error P)
    have hl:|labelReal (f x)*(inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x))|≤1/8 := by
      simpa only [abs_mul,abs_labelReal,one_mul] using herr
    have hu:labelReal (f x)*(inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x))≤1/8 := (abs_le.mp hl).2
    have hm:=P.margin x
    rw [mul_sub] at hu
    linarith
  have hcp:0<‖c‖ := by
    apply norm_pos_iff.mpr
    intro hz
    have hh:=hmargin (fun _=>false)
    simp only [hz,inner_zero_left,mul_zero] at hh
    norm_num at hh
  have hL:0≤‖c‖*physicalGainProduct P H := mul_nonneg (norm_nonneg _) (physicalGainProduct_pos P H).le
  have hLup:‖c‖*physicalGainProduct P H≤(R:ℝ)^(farStrongReadoutExponent B+farStrongGainExponent B) :=
    resource_mul hRr (hc.trans hread) hgain (physicalGainProduct_pos P H).le
  have hn:=farStrong_numeric_envelope hB hR hres hpad hS hdim hL hLup
  have hJlarge:=farStrong_prefix_large_enough hB hRr hcp hex (hc.trans hread)
  have hinitdim:2≤Fintype.card (states 0).Index := by
    have hh:=Fintype.card_congr (Equiv.cast hidx)
    simp only [Fintype.card_fin] at hh
    omega
  have hnorm:∀x,‖(states 0).feature x‖≤2 := by
    intro x
    have he:=hzero x x
    rw [real_inner_self_eq_norm_sq,real_inner_self_eq_norm_sq] at he
    have hb:=normalizedInputFeature_norm_sq_le_two hd x
    nlinarith [norm_nonneg ((states 0).feature x)]
  refine ⟨S,states,c,sources,hsource,hinitdim,hstep,hnorm,hmargin,hcp,?_,hn⟩
  convert hJlarge using 1 <;> norm_num <;> ring

#print axioms exists_farStrong_compressed_program
end ConditionalNonpolynomial.Analytic
