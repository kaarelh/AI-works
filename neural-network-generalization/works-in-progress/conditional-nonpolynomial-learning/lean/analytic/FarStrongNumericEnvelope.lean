import FarStrongPrefixSelection
import FarStrongCompressionResources

noncomputable section
set_option maxHeartbeats 1500000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

def farStrongNumericExponent (B:ℝ) : ℕ :=
  farStrongAnchorExponent B+5+farStrongReadoutExponent B+farStrongGainExponent B+10+
    farStrongCentersExponent B+2

def farStrongStepTolerance (J:ℕ) (L:ℝ) : ℝ := 1/(64*((J:ℝ)+1)*(L+1))

lemma farStrongNumericExponent_one (B:ℝ) : 1≤farStrongNumericExponent B := by
  unfold farStrongNumericExponent
  omega

lemma farStrongStepTolerance_pos {J:ℕ} {L:ℝ} (hL:0≤L) : 0<farStrongStepTolerance J L := by
  unfold farStrongStepTolerance
  positivity

lemma farStrongStepTolerance_le_one {J:ℕ} {L:ℝ} (hL:0≤L) : farStrongStepTolerance J L≤1 := by
  unfold farStrongStepTolerance
  apply (div_le_one (by positivity)).mpr
  have hj:=Nat.cast_nonneg (α:=ℝ) J
  have hm:=mul_nonneg hj hL
  nlinarith

/-- One power of the original input/depth scale dominates every resource
required by the normalized prefix grid and its separated-center classifier. -/
theorem farStrong_numeric_envelope {B L:ℝ} {d H R:ℕ}
    (hB:0≤B) (hR:2≤R) (hres:d+H+1≤R)
    (hpad:farStrongDepthPadding B*Nat.log2 R≤H)
    {S:Finset (Cube d)} {states:ℕ→CanonicalProgramState d}
    (hS:(S.card:ℝ)≤(R:ℝ)^(farStrongAnchorExponent B))
    (hdim:∀j≤H,(states j).dimension≤d+1+j*(S.card+1))
    (hL:0≤L) (hLup:L≤(R:ℝ)^(farStrongReadoutExponent B+farStrongGainExponent B)) :
    let W:ℝ:=(R:ℝ)^farStrongNumericExponent B
    let J:=farStrongPrefixLength B R
    2≤W ∧ J≤H ∧ (J:ℝ)≤W ∧ L≤W ∧ (2:ℝ)^J≤W ∧
      (farStrongStepTolerance J L)⁻¹≤W ∧
      (∀j≤H,((states j).dimension:ℝ)≤W) ∧
      (∀j≤H,((states j).dimension:ℝ)+(S.card:ℝ)≤W) := by
  intro W J
  have hRr:(2:ℝ)≤R := by exact_mod_cast hR
  have hR0:(0:ℝ)≤R := by positivity
  have hRbig:(R:ℝ)≤W := by
    dsimp [W]
    simpa only [pow_one] using resource_pow_mono hRr (farStrongNumericExponent_one B)
  have hW:2≤W := hRr.trans hRbig
  obtain ⟨hP,hJpos,hJH,hJlog,hJC⟩:=farStrong_prefix_length_bounds hB hR hpad
  have hHR:(H:ℝ)≤R := by exact_mod_cast (show H≤R by omega)
  have hdR:(d:ℝ)+1≤R := by exact_mod_cast (show d+1≤R by omega)
  have hJR:(J:ℝ)≤R := (show (J:ℝ)≤H by exact_mod_cast hJH).trans hHR
  have hJW:(J:ℝ)≤W := hJR.trans hRbig
  have hLW:L≤W := hLup.trans (resource_pow_mono hRr (by unfold farStrongNumericExponent;omega))
  have hCW:(2:ℝ)^J≤W := hJC.trans (resource_pow_mono hRr (by unfold farStrongNumericExponent;omega))
  have h64:(64:ℝ)≤(R:ℝ)^6 := by
    have hh:=pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hRr 6
    norm_num at hh
    exact hh
  have hJ1:(J:ℝ)+1≤(R:ℝ)^2 := by simpa only [pow_one] using resource_add_one hRr (a:=1) (by simpa using hJR)
  have hL1:=resource_add_one hRr hLup
  have hprod:=resource_mul hRr (resource_mul hRr h64 hJ1 (by positivity)) hL1 (by linarith : 0≤L+1)
  have hδ:(farStrongStepTolerance J L)⁻¹≤W := by
    simp only [farStrongStepTolerance,one_div,inv_inv]
    exact hprod.trans (resource_pow_mono hRr (by unfold farStrongNumericExponent;omega))
  have hds:=farStrong_state_dimension_bound hRr hdR hHR hS hdim
  have hdW:∀j≤H,((states j).dimension:ℝ)≤W := by
    intro j hj
    exact (hds j hj).trans (resource_pow_mono hRr (by unfold farStrongNumericExponent;omega))
  have hrankW:∀j≤H,((states j).dimension:ℝ)+(S.card:ℝ)≤W := by
    intro j hj
    exact (resource_add_same hRr (hds j hj)
      (hS.trans (resource_pow_mono hRr (by omega)))).trans
      (resource_pow_mono hRr (by unfold farStrongNumericExponent;omega))
  exact ⟨hW,hJH,hJW,hLW,hCW,hδ,hdW,hrankW⟩

theorem farStrong_action_envelope_from_padding {B t:ℝ} {d H R:ℕ} {f:BooleanFunction d}
    (P:ControlledMarginPath d H t f) (hB:0≤B) (hH:1≤H) (hR:2≤R)
    (hres:d+H+1≤R) (hpad:farStrongDepthPadding B*Nat.log2 R≤H)
    (ha:1/4≤(t^2)⁻¹-1) (hnear:P.action≤denominatorBudget B t R H) :
    ((∑j∈Finset.range H,physicalLayerCost P j)-(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal)/((t^2)⁻¹-1)≤
      farStrongExcessCoefficient B*(1+Real.log (R:ℝ)) ∧
    physicalGainProduct P H≤(R:ℝ)^(farStrongGainExponent B) ∧
      ‖P.readout‖≤(R:ℝ)^(farStrongReadoutExponent B) := by
  have hRr:(2:ℝ)≤R := by exact_mod_cast hR
  have hHR:(H:ℝ)+1≤R := by exact_mod_cast (show H+1≤R by omega)
  have hP:1≤farStrongDepthPadding B := by unfold farStrongDepthPadding;omega
  have hlogH:Real.log (R:ℝ)≤2*(H:ℝ) := by
    have hkle:Nat.log2 R≤farStrongDepthPadding B*Nat.log2 R := by
      simpa only [one_mul] using Nat.mul_le_mul_right (Nat.log2 R) hP
    have hk:Nat.log2 R≤H := hkle.trans hpad
    have hkR:(Nat.log2 R:ℝ)≤H := by exact_mod_cast hk
    linarith [real_log_le_twice_log2 hR]
  exact ⟨(farStrong_action_bounds P hH hB hRr hHR hlogH ha hnear).1,
    farStrong_gain_bound P hH hB hRr hHR hlogH ha hnear⟩

/-- Final natural circuit resource conversion for a prefix evaluator whose
universal circuit exponent is `e`. -/
theorem farStrong_classifier_resource_conversion {B:ℝ} {d R e:ℕ} (hB:0≤B) (hR:2≤R)
    (c:ThresholdCircuit d)
    (hsize:(c.size:ℝ)≤((R:ℝ)^farStrongNumericExponent B)^e)
    (hdepth:c.depth≤80*farStrongPrefixLength B R+17) :
    let k:=naturalCircuitResourceExponent (farStrongNumericExponent B*e)
      (80*(farStrongPrefixCoefficient B+1)+17)
    c.size≤R^k ∧ c.depth≤k*Nat.log2 R := by
  intro k
  have hC:=farStrongPrefixCoefficient_pos hB
  have hlog:0≤Real.log (R:ℝ) := Real.log_nonneg (by exact_mod_cast (show 1≤R by omega))
  have hceil:=Nat.ceil_lt_add_one (mul_nonneg hC.le (by linarith : 0≤1+Real.log (R:ℝ)))
  have hlen:(farStrongPrefixLength B R:ℝ)≤(farStrongPrefixCoefficient B+1)*(1+Real.log (R:ℝ)) := by
    dsimp [farStrongPrefixLength]
    nlinarith only [hceil,hlog]
  have hd:(c.depth:ℝ)≤(80*(farStrongPrefixCoefficient B+1)+17)*(1+Real.log (R:ℝ)) := by
    have hh:(c.depth:ℝ)≤80*(farStrongPrefixLength B R:ℝ)+17 := by exact_mod_cast hdepth
    nlinarith
  have hs:(c.size:ℝ)≤(R:ℝ)^(farStrongNumericExponent B*e) := by simpa only [←pow_mul] using hsize
  exact natural_circuit_resource_bounds_uniform _ (by linarith : 0≤80*(farStrongPrefixCoefficient B+1)+17) hR hs hd

#print axioms farStrong_numeric_envelope
#print axioms farStrong_action_envelope_from_padding
#print axioms farStrong_classifier_resource_conversion
end ConditionalNonpolynomial.Analytic
