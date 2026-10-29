import PhysicalEntropySplitCompression
import CanonicalSignBudgets
import CanonicalQuadratureResources

noncomputable section
set_option maxHeartbeats 1200000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

def longCompressionPrecision (P : ControlledMarginPath d H t f) : ℝ :=
  1/(64*((H:ℝ)+1)*(‖P.readout‖+1)*(physicalGainProduct P H+1))
def longEvaluationPrecision (P : ControlledMarginPath d H t f) : ℝ :=
  1/(256*(1+‖P.readout‖*physicalGainProduct P H))
def longEvaluationIterations (Λ ξ : ℝ) : ℕ := causalSignIterations 0 Λ ξ⁻¹
def longEvaluationRounding (Λ ξ : ℝ) : ℝ := causalSignRounding 0 Λ ξ⁻¹

lemma longCompressionPrecision_pos (P : ControlledMarginPath d H t f) : 0<longCompressionPrecision P := by
  unfold longCompressionPrecision
  positivity [physicalGainProduct_pos P H]
lemma longEvaluationPrecision_pos (P : ControlledMarginPath d H t f) : 0<longEvaluationPrecision P := by
  unfold longEvaluationPrecision
  positivity [physicalGainProduct_pos P H]
lemma longEvaluationRounding_pos {Λ ξ : ℝ} (hξ : 0<ξ) : 0<longEvaluationRounding Λ ξ :=
  causalSignRounding_pos _ _ (inv_nonneg.mpr hξ.le)

lemma longCompressionPrecision_bounds (P : ControlledMarginPath d H t f) :
    longCompressionPrecision P≤1 ∧ (H:ℝ)*longCompressionPrecision P≤1 ∧
      ‖P.readout‖*longCompressionPrecision P≤1/64 := by
  have hH : 0≤(H:ℝ) := Nat.cast_nonneg _
  have hW : 0≤‖P.readout‖ := norm_nonneg _
  have hG : 0≤physicalGainProduct P H := (physicalGainProduct_pos P H).le
  have h1 : 1≤((H:ℝ)+1)*(‖P.readout‖+1)*(physicalGainProduct P H+1) := by
    nlinarith [mul_nonneg hH hW,mul_nonneg (show 0≤((H:ℝ)+1)*(‖P.readout‖+1) by positivity) hG]
  have h2 : (H:ℝ)≤((H:ℝ)+1)*(‖P.readout‖+1)*(physicalGainProduct P H+1) := by
    nlinarith [mul_nonneg hH hW,mul_nonneg (show 0≤((H:ℝ)+1)*(‖P.readout‖+1) by positivity) hG]
  have h3 : ‖P.readout‖≤((H:ℝ)+1)*(‖P.readout‖+1)*(physicalGainProduct P H+1) := by
    nlinarith [mul_nonneg hH hW,mul_nonneg (show 0≤((H:ℝ)+1)*(‖P.readout‖+1) by positivity) hG]
  have hp : 0<64*((H:ℝ)+1)*(‖P.readout‖+1)*(physicalGainProduct P H+1) := by positivity
  unfold longCompressionPrecision
  constructor
  · exact (div_le_iff₀ hp).mpr (by nlinarith)
  constructor <;> rw [mul_one_div]
  · exact (div_le_iff₀ hp).mpr (by nlinarith)
  · exact (div_le_iff₀ hp).mpr (by nlinarith)

lemma longCompressionPrecision_prefix_square (P : ControlledMarginPath d H t f) {J : ℕ} (hJ : J≤H) :
    (J:ℝ)*(longCompressionPrecision P)^2≤1 := by
  have hp := longCompressionPrecision_pos P
  obtain ⟨h1,hH,hW⟩ := longCompressionPrecision_bounds P
  have hj : (J:ℝ)≤H := by exact_mod_cast hJ
  have hh : (longCompressionPrecision P)^2≤longCompressionPrecision P := by nlinarith
  exact (mul_le_mul_of_nonneg_left hh (Nat.cast_nonneg _)).trans
    ((mul_le_mul_of_nonneg_right hj hp.le).trans hH)

lemma longEvaluationRounding_small {Λ ξ : ℝ} (hΛ : 0≤Λ) (hξ : 0<ξ) :
    longEvaluationRounding Λ ξ≤1/64 := by
  have he := Real.one_le_exp hΛ
  have hi := inv_nonneg.mpr hξ.le
  have hden : 64≤64*(1+ξ⁻¹)*Real.exp Λ := by nlinarith [mul_nonneg hi (sub_nonneg.mpr he)]
  simpa only [longEvaluationRounding,causalSignRounding,zero_add] using
    one_div_le_one_div_of_le (by norm_num : (0:ℝ)<64) hden

lemma longEvaluation_error_budget {Λ ξ : ℝ} (hΛ : 0≤Λ) (hξ : 0<ξ) :
    4*Λ^(longEvaluationIterations Λ ξ)/(Nat.factorial (longEvaluationIterations Λ ξ):ℝ)+
      longEvaluationRounding Λ ξ*Real.exp Λ≤ξ/32 := by
  have hh := causalSignBudgets (E:=0) hΛ (inv_nonneg.mpr hξ.le)
    (show (0:ℝ)≤0 from le_rfl) (show (0:ℝ)≤1 by norm_num)
  simp only [Real.exp_zero,one_mul,mul_zero,add_zero] at hh
  change ξ⁻¹*(4*Λ^(longEvaluationIterations Λ ξ)/(Nat.factorial (longEvaluationIterations Λ ξ):ℝ)+
    longEvaluationRounding Λ ξ*Real.exp Λ)≤1/32 at hh
  have hm := mul_le_mul_of_nonneg_left hh hξ.le
  have hne := hξ.ne'
  field_simp at hm ⊢
  nlinarith

 theorem long_precision_primitive_resources (P : ControlledMarginPath d H t f)
    {W : ℝ} (hW : 2≤W) (hH : (H:ℝ)+1≤W) (hr : ‖P.readout‖≤W)
    (hG : physicalGainProduct P H≤W) :
    (physicalPartialGainBound P+1)≤W^4 ∧
      (longCompressionPrecision P)⁻¹≤W^11 ∧
      (longEvaluationPrecision P)⁻¹≤W^11 ∧
      (physicalAbsolutePrecision P (longCompressionPrecision P))⁻¹≤W^184 := by
  have hW0 : 0≤W := by linarith
  have htwo : (2:ℝ)≤W^1 := by simpa only [pow_one] using hW
  have h64 : (64:ℝ)≤W^6 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hW 6
    norm_num at hh
    exact hh
  have h128 : (128:ℝ)≤W^7 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hW 7
    norm_num at hh
    exact hh
  have h256 : (256:ℝ)≤W^8 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hW 8
    norm_num at hh
    exact hh
  have hrg := resource_mul hW (a:=1) (b:=1) (by simpa only [pow_one] using hr)
    (by simpa only [pow_one] using hG) (physicalGainProduct_pos P H).le
  have htworg := resource_mul hW htwo hrg (by positivity [physicalGainProduct_pos P H])
  have hpartial : physicalPartialGainBound P+1≤W^4 := by
    have hh := resource_add_same hW htworg (htwo.trans (resource_pow_mono hW (show 1≤3 by norm_num)))
    norm_num at hh
    unfold physicalPartialGainBound
    nlinarith only [hh]
  have hr1 := resource_add_one hW (a:=1) (by simpa only [pow_one] using hr)
  have hG1 := resource_add_one hW (a:=1) (by simpa only [pow_one] using hG)
  have hc : (longCompressionPrecision P)⁻¹≤W^11 := by
    simp only [longCompressionPrecision,one_div,inv_inv]
    exact resource_mul hW (resource_mul hW (resource_mul hW h64 (b:=1)
      (by simpa only [pow_one] using hH) (by positivity)) hr1 (by positivity)) hG1 (by positivity [physicalGainProduct_pos P H])
  have hξ : (longEvaluationPrecision P)⁻¹≤W^11 := by
    simp only [longEvaluationPrecision,one_div,inv_inv]
    have hh : 1+‖P.readout‖*physicalGainProduct P H≤W^3 := by
      have hh:=resource_add_one hW hrg
      norm_num at hh
      linarith
    exact resource_mul hW h256 hh (by positivity [physicalGainProduct_pos P H])
  have hprod := resource_mul hW (resource_mul hW (resource_mul hW h128 (b:=1)
    (by simpa only [pow_one] using hH) (by positivity)) hpartial (by linarith [physicalPartialGainBound_pos P])) hc
    (inv_nonneg.mpr (longCompressionPrecision_pos P).le)
  have hpow := resource_pow hW hprod (by positivity [physicalPartialGainBound_pos P,longCompressionPrecision_pos P]) 8
  have he : (physicalAbsolutePrecision P (longCompressionPrecision P))⁻¹=
      (128*((H:ℝ)+1)*(physicalPartialGainBound P+1)*(longCompressionPrecision P)⁻¹)^8 := by
    rw [physicalAbsolutePrecision,←inv_pow,inv_div,div_eq_mul_inv]
  exact ⟨hpartial,hc,hξ,by rw [he];exact hpow⟩

#print axioms longEvaluation_error_budget
#print axioms long_precision_primitive_resources
end ConditionalNonpolynomial.Analytic.PhysicalLong
