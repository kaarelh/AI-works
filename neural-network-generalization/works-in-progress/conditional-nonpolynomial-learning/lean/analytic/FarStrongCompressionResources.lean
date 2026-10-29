import FarStrongActionEnvelope
import PhysicalCompressionSources

noncomputable section
set_option maxHeartbeats 1800000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
variable {d H:ℕ} {t:ℝ} {f:BooleanFunction d}

def farStrongCompressionPrecision (P:ControlledMarginPath d H t f) : ℝ :=
  (1/(1024*((H:ℝ)+1)*(‖P.readout‖+1)*(physicalGainProduct P H+1)))^8

def farStrongCompressionExponent (B:ℝ) : ℕ :=
  8*(farStrongReadoutExponent B+farStrongGainExponent B+14)
def farStrongAnchorExponent (B:ℝ) : ℕ :=
  farStrongCompressionExponent B+2*farStrongReadoutExponent B+12

theorem farStrongCompressionPrecision_pos (P:ControlledMarginPath d H t f) :
    0<farStrongCompressionPrecision P := by
  unfold farStrongCompressionPrecision
  positivity [physicalGainProduct_pos P H]

theorem farStrong_compression_prediction_error (P:ControlledMarginPath d H t f) :
    (1:ℝ)/16+‖P.readout‖*((H:ℝ)*normalizedAnchorError (farStrongCompressionPrecision P)*physicalGainProduct P H)≤1/8 := by
  have hh:=physical_compression_error_precision (H:=H) (norm_nonneg P.readout)
    (physicalGainProduct_pos P H).le (show (0:ℝ)<1/16 by norm_num) (show (1:ℝ)/16≤1 by norm_num)
  have he:(1:ℝ)/16/(64*((H:ℝ)+1)*(‖P.readout‖+1)*(physicalGainProduct P H+1))=
      1/(1024*((H:ℝ)+1)*(‖P.readout‖+1)*(physicalGainProduct P H+1)) := by field_simp <;> ring
  rw [he] at hh
  change 1/16+_≤1/8
  unfold farStrongCompressionPrecision
  linarith

theorem farStrong_compression_inverse_bound (P:ControlledMarginPath d H t f)
    {B R:ℝ} (hR:2≤R) (hHR:(H:ℝ)+1≤R)
    (hread:‖P.readout‖≤R^(farStrongReadoutExponent B))
    (hgain:physicalGainProduct P H≤R^(farStrongGainExponent B)) :
    (farStrongCompressionPrecision P)⁻¹≤R^(farStrongCompressionExponent B) := by
  have h1024:(1024:ℝ)≤R^10 := by
    have hh:=pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hR 10
    norm_num at hh
    exact hh
  have hr:=resource_add_one hR hread
  have hg:=resource_add_one hR hgain
  have hprod:=resource_mul hR (resource_mul hR (resource_mul hR h1024
    (b:=1) (by simpa using hHR) (by positivity)) hr (by positivity)) hg
    (by positivity [physicalGainProduct_pos P H])
  have he:(farStrongCompressionPrecision P)⁻¹=
      (1024*((H:ℝ)+1)*(‖P.readout‖+1)*(physicalGainProduct P H+1))^8 := by
    simp only [farStrongCompressionPrecision,one_div,inv_pow,inv_inv]
  rw [he]
  have hh:=resource_pow hR hprod (by positivity [physicalGainProduct_pos P H]) 8
  exact hh.trans (resource_pow_mono hR (by unfold farStrongCompressionExponent;omega))

theorem farStrong_anchor_card_bound (P:ControlledMarginPath d H t f)
    {B R:ℝ} (hR:2≤R) (hHR:(H:ℝ)+1≤R)
    (hread:‖P.readout‖≤R^(farStrongReadoutExponent B))
    (hgain:physicalGainProduct P H≤R^(farStrongGainExponent B))
    {S:Finset (Cube d)}
    (hS:(S.card:ℝ)≤(H:ℝ)/(2*farStrongCompressionPrecision P)+‖P.readout‖^2/(1/16)^2) :
    (S.card:ℝ)≤R^(farStrongAnchorExponent B) := by
  have hη:=farStrongCompressionPrecision_pos P
  have hinv:=farStrong_compression_inverse_bound P hR hHR hread hgain
  have hH:(H:ℝ)≤R := by linarith
  have hterm1:(H:ℝ)/(2*farStrongCompressionPrecision P)≤R^(1+farStrongCompressionExponent B) := by
    have hi:(2*farStrongCompressionPrecision P)⁻¹≤(farStrongCompressionPrecision P)⁻¹ :=
      inv_anti₀ hη (by linarith)
    rw [div_eq_mul_inv]
    exact (mul_le_mul_of_nonneg_left hi (Nat.cast_nonneg H)).trans
      (resource_mul hR (a:=1) (by simpa using hH) hinv (inv_nonneg.mpr hη.le))
  have h256:(256:ℝ)≤R^8 := by
    have hh:=pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hR 8
    norm_num at hh
    exact hh
  have hrs:=resource_pow hR hread (norm_nonneg _) 2
  have hterm2:‖P.readout‖^2/(1/16)^2≤R^(8+farStrongReadoutExponent B*2) := by
    have hh:=resource_mul hR h256 hrs (sq_nonneg _)
    convert hh using 1 <;> ring
  let E:=farStrongCompressionExponent B+2*farStrongReadoutExponent B+10
  have ht1:=hterm1.trans (resource_pow_mono hR (show 1+farStrongCompressionExponent B≤E by dsimp [E];omega))
  have ht2:=hterm2.trans (resource_pow_mono hR (show 8+farStrongReadoutExponent B*2≤E by dsimp [E];omega))
  exact hS.trans ((resource_add_same hR ht1 ht2).trans
    (resource_pow_mono hR (by unfold farStrongAnchorExponent;dsimp [E];omega)))

theorem farStrong_state_dimension_bound {S:Finset (Cube d)} {states:ℕ→CanonicalProgramState d}
    {B R:ℝ} (hR:2≤R) (hdR:(d:ℝ)+1≤R) (hHR:(H:ℝ)≤R)
    (hS:(S.card:ℝ)≤R^(farStrongAnchorExponent B))
    (hdim:∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) :
    ∀j≤H,((states j).dimension:ℝ)≤R^(farStrongAnchorExponent B+3) := by
  intro j hj
  have hjR:(j:ℝ)≤R := (show (j:ℝ)≤H by exact_mod_cast hj).trans hHR
  have hs1:=resource_add_one hR hS
  have hp:=resource_mul hR (a:=1) (by simpa using hjR) hs1 (by positivity)
  have hd:((states j).dimension:ℝ)≤(d:ℝ)+1+(j:ℝ)*((S.card:ℝ)+1) := by exact_mod_cast hdim j hj
  exact hd.trans ((resource_add_same hR
    (hdR.trans (by simpa only [pow_one] using resource_pow_mono hR (show 1≤1+(farStrongAnchorExponent B+1) by omega))) hp).trans_eq (by congr 1;omega))

#print axioms farStrong_compression_prediction_error
#print axioms farStrong_anchor_card_bound
#print axioms farStrong_state_dimension_bound
end ConditionalNonpolynomial.Analytic
