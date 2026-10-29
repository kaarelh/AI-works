import PhysicalLongPrefixCover
import PhysicalLogarithmicGain
import FarStrongActionEnvelope
import GeneralActionReadoutEnvelope

noncomputable section
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

lemma uniformLogGainCoefficient_nonneg {B : ℝ} (hB : 0≤B) :
    0≤uniformLogGainCoefficient B := by
  unfold uniformLogGainCoefficient
  positivity [lastExitLinearConstant_nonneg]

lemma long_time_bounds {d H R : ℕ} (hd : 1≤d) (hR : 2≤R) (hres : d+H+1≤R) :
    1≤2*Real.log (R:ℝ) ∧ Real.log ((H:ℝ)+2)≤2*Real.log (R:ℝ) := by
  have hRr : (2:ℝ)≤R := by exact_mod_cast hR
  have hl2 := Real.log_le_log (by norm_num : (0:ℝ)<2) hRr
  have hl : (1:ℝ)/2≤Real.log (R:ℝ) := by
    have h := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at h
    linarith
  have hHR : (H:ℝ)+2≤R := by exact_mod_cast (show H+2≤R by omega)
  have hh := Real.log_le_log (by positivity : (0:ℝ)<H+2) hHR
  constructor <;> linarith

lemma long_action_enlarged {d H R : ℕ} {t B : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hH : 1≤H) (hR : 2≤R) (hB : 0≤B)
    (hact : P.action≤denominatorBudget B t R H) :
    P.action≤(H:ℝ)*subcriticalCostBaseline (physicalVariance P)+scalarBaseline.toReal+
      B*(((physicalVariance P:ℝ)⁻¹-1)*(2*Real.log (R:ℝ))+
        (2*Real.log (R:ℝ))^2/(H:ℝ)) := by
  have hlog : 0≤Real.log (R:ℝ) := Real.log_nonneg (by exact_mod_cast (show 1≤R by omega))
  have hH0 : (0:ℝ)<H := by exact_mod_cast (show 0<H by omega)
  have ha : 0≤(t^2)⁻¹-1 := by
    have hh := (one_le_inv₀ (sq_pos_of_pos P.scale_positive)).mpr
      (by nlinarith [P.scale_positive,P.scale_le_one] : t^2≤1)
    linarith
  have hsq : (Real.log (R:ℝ))^2/(H:ℝ)≤(2*Real.log (R:ℝ))^2/(H:ℝ) := by
    apply div_le_div_of_nonneg_right _ hH0.le
    nlinarith [sq_nonneg (Real.log (R:ℝ))]
  have hprod : ((t^2)⁻¹-1)*Real.log (R:ℝ)≤((t^2)⁻¹-1)*(2*Real.log (R:ℝ)) := by
    nlinarith [mul_nonneg ha hlog]
  have hm := mul_le_mul_of_nonneg_left (add_le_add hprod hsq) hB
  unfold denominatorBudget at hact
  rw [physicalVariance_coe]
  change P.action≤(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+_
  linarith

lemma long_actual_excess {d H R : ℕ} {t B : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H) (hR : 2≤R)
    (hres : d+H+1≤R) (hB : 0≤B)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1)
    (hlong : 2*Real.log (R:ℝ)≤((physicalVariance P:ℝ)⁻¹-1)*(H:ℝ))
    (hact : P.action≤denominatorBudget B t R H) :
    physicalActionExcess P≤(2*B+1)*((physicalVariance P:ℝ)⁻¹-1)*(2*Real.log (R:ℝ)) := by
  have hh := long_scale_excess (show (0:ℝ)<H by exact_mod_cast (show 0<H by omega))
    ha (long_time_bounds hd hR hres).1 hB hlong (long_action_enlarged P hH hR hB hact)
  change physicalActionExcess P/((physicalVariance P:ℝ)⁻¹-1)≤_ at hh
  have hm := (div_le_iff₀ ha).mp hh
  nlinarith only [hm]

lemma long_actual_gain {d H R : ℕ} {t B : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H) (hR : 2≤R)
    (hres : d+H+1≤R) (hB : 0≤B)
    (hlong : 2*Real.log (R:ℝ)≤((physicalVariance P:ℝ)⁻¹-1)*(H:ℝ))
    (hact : P.action≤denominatorBudget B t R H) :
    physicalGainProduct P H≤Real.exp (uniformLogGainCoefficient B*(2*Real.log (R:ℝ))) := by
  have htime := long_time_bounds hd hR hres
  have hlog := (Real.log_le_log (by positivity : (0:ℝ)<H+1)
    (show (H:ℝ)+1≤H+2 by linarith)).trans htime.2
  exact physicalGainProduct_logarithmic P hd hH hB htime.1 hlog hlong
    (long_action_enlarged P hH hR hB hact)

def longActualExcessConstant (B : ℝ) : ℝ := 2*B+1
def longActualAdjustedConstant (B : ℝ) : ℝ := longActualExcessConstant B+526336

lemma exists_long_actual_prefix_constants {B G : ℝ} (hB : 0≤B) (hG : 0≤G) :
    ∃K Q : ℝ, 1≤K ∧ 1≤Q ∧ 2≤Q ∧
      2*longPrefixDepthConstant (longActualExcessConstant B) K≤Q ∧
      2*longBlockSpan≤K ∧ longActualAdjustedConstant B+1≤K ∧
      16*longBlockSpan*longPrefixNonlinearCoefficient (longActualAdjustedConstant B)≤
        longCoverNonlinearThreshold*Real.sqrt K ∧
      4*longBlockSpan*(longActualAdjustedConstant B+G+16)≤K := by
  have hC : 0≤longActualAdjustedConstant B := by
    unfold longActualAdjustedConstant longActualExcessConstant
    linarith
  obtain ⟨K,hK,hspan,hKC,hKs,hKr⟩ := exists_longBlock_prefix_constant
    (longPrefixNonlinearCoefficient_pos (longActualAdjustedConstant B)).le hC
    longCoverNonlinearThreshold_pos
    (show 0≤longActualAdjustedConstant B+G+16 by linarith)
  refine ⟨K,max 2 (2*longPrefixDepthConstant (longActualExcessConstant B) K),
    hK,le_trans (by norm_num) (le_max_left _ _),le_max_left _ _,le_max_right _ _,
    hspan,hKC,hKs,?_⟩
  have hs : 0≤longBlockSpan := by norm_num [longBlockSpan,longBlockContraction]
  have hh := mul_nonneg hs (show 0≤longActualAdjustedConstant B+G+16 by linarith)
  linarith

theorem long_actual_prefix {d H R : ℕ} {t B K Q : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H) (hR : 2≤R)
    (hres : d+H+1≤R) (hB : 0≤B) (hK : 1≤K) (hQ : 2≤Q)
    (hQdepth : 2*longPrefixDepthConstant (longActualExcessConstant B) K≤Q)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1) (ha1 : (physicalVariance P:ℝ)⁻¹-1≤1/4)
    (hlong : Q*Real.log (R:ℝ)≤((physicalVariance P:ℝ)⁻¹-1)*(H:ℝ))
    (hact : P.action≤denominatorBudget B t R H) :
    let T := 2*Real.log (R:ℝ)
    let a := (physicalVariance P:ℝ)⁻¹-1
    let J := longPrefixLength K T a
    1≤J ∧ J≤H ∧ K*T/a≤(J:ℝ) ∧ (J:ℝ)≤(K+1)*T/a ∧
      (∑j∈Finset.range J,physicalAdjustedCost P j)≤longActualAdjustedConstant B*a*T ∧
      Real.log ((J:ℝ)+2)≤T := by
  have htime := long_time_bounds hd hR hres
  have hlog : 0≤Real.log (R:ℝ) := Real.log_nonneg (by exact_mod_cast (show 1≤R by omega))
  have hlong2 := (mul_le_mul_of_nonneg_right hQ hlog).trans hlong
  have he := long_actual_excess P hd hH hR hres hB ha hlong2 hact
  have hdepth : longPrefixDepthConstant (longActualExcessConstant B) K*(2*Real.log (R:ℝ))/
      ((physicalVariance P:ℝ)⁻¹-1)≤(H:ℝ) := by
    apply (div_le_iff₀ ha).mpr
    have hh := (mul_le_mul_of_nonneg_right hQdepth hlog).trans hlong
    nlinarith only [hh]
  have hp := controlledMarginPath_long_prefix_of_action P hd
    (show 0≤longActualExcessConstant B by unfold longActualExcessConstant;linarith)
    (show 0<K by linarith) htime.1 ha (show (physicalVariance P:ℝ)⁻¹-1≤1 by linarith)
    he hdepth
  dsimp only
  refine ⟨hp.1,hp.2.2.2.2.1,hp.2.1,hp.2.2.1,?_,?_⟩
  · have hm := mul_le_mul_of_nonneg_left htime.1
      (show 0≤526336*((physicalVariance P:ℝ)⁻¹-1) by positivity)
    have hsum := hp.2.2.2.2.2.1
    unfold longActualAdjustedConstant longActualExcessConstant
    nlinarith only [he,hm,hsum]
  · have hJr : (longPrefixLength K (2*Real.log (R:ℝ)) ((physicalVariance P:ℝ)⁻¹-1):ℝ)≤H :=
      by exact_mod_cast hp.2.2.2.2.1
    exact (Real.log_le_log (by positivity) (by linarith :
      (longPrefixLength K (2*Real.log (R:ℝ)) ((physicalVariance P:ℝ)⁻¹-1):ℝ)+2≤(H:ℝ)+2)).trans htime.2

#print axioms long_actual_prefix

def longActualGainExponent (B : ℝ) : ℕ := ⌈2*uniformLogGainCoefficient B⌉₊
def longActualResourceExponent (B : ℝ) : ℕ :=
  1+longActualGainExponent B+generalActionReadoutExponent B
def longActualProductCoefficient (B : ℝ) : ℝ :=
  uniformLogGainCoefficient B+(generalActionReadoutExponent B:ℝ)

lemma longActualProductCoefficient_nonneg {B : ℝ} (hB : 0≤B) :
    0≤longActualProductCoefficient B := by
  unfold longActualProductCoefficient
  positivity [uniformLogGainCoefficient_nonneg hB]

theorem long_actual_polynomial_resources {d H R : ℕ} {t B : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H) (hR : 2≤R)
    (hres : d+H+1≤R) (hB : 0≤B)
    (hlong : 2*Real.log (R:ℝ)≤((physicalVariance P:ℝ)⁻¹-1)*(H:ℝ))
    (hact : P.action≤denominatorBudget B t R H) :
    (H:ℝ)+1≤(R:ℝ)^(longActualResourceExponent B) ∧
    (d:ℝ)+1≤(R:ℝ)^(longActualResourceExponent B) ∧
    ‖P.readout‖≤(R:ℝ)^(longActualResourceExponent B) ∧
    physicalGainProduct P H≤(R:ℝ)^(longActualResourceExponent B) ∧
    ‖P.readout‖*physicalGainProduct P H≤
      Real.exp (longActualProductCoefficient B*(2*Real.log (R:ℝ))) := by
  have hRr : (2:ℝ)≤R := by exact_mod_cast hR
  have hR0 : (0:ℝ)<R := by linarith
  have hlog : 0≤Real.log (R:ℝ) := Real.log_nonneg (by linarith)
  have hHR : (H:ℝ)+1≤R := by exact_mod_cast (show H+1≤R by omega)
  have hdR : (d:ℝ)+1≤R := by exact_mod_cast (show d+1≤R by omega)
  have hg := long_actual_gain P hd hH hR hres hB hlong hact
  have hw := general_action_readout_polynomial P hH hB hRr hHR hact
  have heq (e : ℕ) : Real.exp ((e:ℝ)*Real.log (R:ℝ))=(R:ℝ)^e := by
    rw [Real.exp_nat_mul,Real.exp_log hR0]
  have hgn : physicalGainProduct P H≤(R:ℝ)^(longActualGainExponent B) := by
    have hn := Nat.le_ceil (2*uniformLogGainCoefficient B)
    have hm := mul_le_mul_of_nonneg_right hn hlog
    apply hg.trans
    rw [←heq]
    apply Real.exp_le_exp.mpr
    unfold longActualGainExponent
    nlinarith only [hm]
  have hmono (e : ℕ) (he : e≤longActualResourceExponent B) :
      (R:ℝ)^e≤(R:ℝ)^(longActualResourceExponent B) :=
    pow_le_pow_right₀ (by linarith) he
  refine ⟨hHR.trans ?_,hdR.trans ?_,hw.trans (hmono _ ?_),hgn.trans (hmono _ ?_),?_⟩
  · simpa only [pow_one] using hmono 1 (by unfold longActualResourceExponent;omega)
  · simpa only [pow_one] using hmono 1 (by unfold longActualResourceExponent;omega)
  · unfold longActualResourceExponent;omega
  · unfold longActualResourceExponent;omega
  · have hwe : ‖P.readout‖≤Real.exp ((generalActionReadoutExponent B:ℝ)*(2*Real.log (R:ℝ))) := by
      apply hw.trans
      rw [←heq]
      apply Real.exp_le_exp.mpr
      have hh := mul_nonneg (Nat.cast_nonneg (α:=ℝ) (generalActionReadoutExponent B)) hlog
      nlinarith
    have hh := mul_le_mul hwe hg (physicalGainProduct_pos P H).le (Real.exp_pos _).le
    rw [←Real.exp_add] at hh
    have hid : (generalActionReadoutExponent B:ℝ)*(2*Real.log (R:ℝ))+
        uniformLogGainCoefficient B*(2*Real.log (R:ℝ))=
        longActualProductCoefficient B*(2*Real.log (R:ℝ)) := by
      unfold longActualProductCoefficient
      ring
    rw [hid] at hh
    exact hh

#print axioms long_actual_polynomial_resources
end ConditionalNonpolynomial.Analytic
