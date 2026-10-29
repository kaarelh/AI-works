import FarStrongActionEnvelope

noncomputable section
set_option maxHeartbeats 1200000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

def farStrongPrefixCoefficient (B:ℝ) : ℝ :=
  40*(farStrongExcessCoefficient B+Real.log 128+(farStrongReadoutExponent B:ℝ))
def farStrongPrefixLength (B R:ℝ) : ℕ := ⌈farStrongPrefixCoefficient B*(1+Real.log R)⌉₊
def farStrongDepthPadding (B:ℝ) : ℕ := ⌈3*(farStrongPrefixCoefficient B+1)⌉₊+1
def farStrongCentersExponent (B:ℝ) : ℕ := ⌈(farStrongPrefixCoefficient B+1)*(1+1/Real.log 2)⌉₊

lemma farStrongPrefixCoefficient_pos {B:ℝ} (hB:0≤B) : 0<farStrongPrefixCoefficient B := by
  have hh:=Real.log_pos (show (1:ℝ)<128 by norm_num)
  unfold farStrongPrefixCoefficient farStrongExcessCoefficient
  positivity

lemma farStrong_prefix_length_bounds {B:ℝ} {R H:ℕ} (hB:0≤B) (hR:2≤R)
    (hpad:farStrongDepthPadding B*Nat.log2 R≤H) :
    1≤farStrongDepthPadding B ∧ 1≤farStrongPrefixLength B R ∧
      farStrongPrefixLength B R≤H ∧
      (farStrongPrefixLength B R:ℝ)≤(farStrongPrefixCoefficient B+1)*(1+Real.log (R:ℝ)) ∧
      (2:ℝ)^(farStrongPrefixLength B R)≤(R:ℝ)^(farStrongCentersExponent B) := by
  have hRr:(2:ℝ)≤R := by exact_mod_cast hR
  have hlog:0≤Real.log (R:ℝ) := Real.log_nonneg (by linarith)
  have hC:=farStrongPrefixCoefficient_pos hB
  have hceil:=Nat.ceil_lt_add_one (mul_nonneg hC.le (by linarith : 0≤1+Real.log (R:ℝ)))
  have hlen:(farStrongPrefixLength B R:ℝ)≤(farStrongPrefixCoefficient B+1)*(1+Real.log (R:ℝ)) := by
    dsimp [farStrongPrefixLength]
    nlinarith only [hceil,hlog]
  have hlarge:=Nat.le_ceil (farStrongPrefixCoefficient B*(1+Real.log (R:ℝ)))
  have hlenpos:1≤farStrongPrefixLength B R := by
    have hp:0<(farStrongPrefixLength B R:ℝ) := lt_of_lt_of_le (by positivity) hlarge
    exact Nat.one_le_iff_ne_zero.mpr (by intro h;rw [h,Nat.cast_zero] at hp;linarith)
  have hcoeff:3*(farStrongPrefixCoefficient B+1)≤(farStrongDepthPadding B:ℝ) := by
    have hh:=Nat.le_ceil (3*(farStrongPrefixCoefficient B+1))
    unfold farStrongDepthPadding
    push_cast
    linarith
  have hl:=mul_le_mul_of_nonneg_left (one_add_real_log_le_three_log2 hR) (by linarith : 0≤farStrongPrefixCoefficient B+1)
  have hp:=mul_le_mul_of_nonneg_right hcoeff (Nat.cast_nonneg (α:=ℝ) (Nat.log2 R))
  have hJH:farStrongPrefixLength B R≤H := by
    have hpadR:((farStrongDepthPadding B:ℝ)*(Nat.log2 R:ℝ))≤H := by exact_mod_cast hpad
    have hh:(farStrongPrefixLength B R:ℝ)≤H := by nlinarith only [hlen,hl,hp,hpadR]
    exact_mod_cast hh
  have hpow:(2:ℝ)^(farStrongPrefixLength B R)≤(R:ℝ)^(farStrongCentersExponent B) := by
    have hl2:Real.log 2≤1 := by linarith [Real.log_le_sub_one_of_pos (show (0:ℝ)<2 by norm_num)]
    have hjlog: (farStrongPrefixLength B R:ℝ)*Real.log 2≤(farStrongPrefixLength B R:ℝ) :=
      mul_le_of_le_one_right (Nat.cast_nonneg _) hl2
    rw [←Real.exp_log (pow_pos (show (0:ℝ)<2 by norm_num) _),Real.log_pow]
    exact (Real.exp_le_exp.mpr (hjlog.trans hlen)).trans
      (exp_log_envelope_pow (by linarith : 0≤farStrongPrefixCoefficient B+1) hRr)
  exact ⟨by unfold farStrongDepthPadding;omega,hlenpos,hJH,hlen,hpow⟩

lemma farStrong_prefix_large_enough {B R a E c:ℝ} (hB:0≤B) (hR:2≤R) (hc:0<c)
    (hE:E/a≤farStrongExcessCoefficient B*(1+Real.log R))
    (hcR:c≤R^(farStrongReadoutExponent B)) :
    40*(E/a+Real.log (128*c))≤(farStrongPrefixLength B R:ℝ) := by
  have hlog:0≤Real.log R := Real.log_nonneg (by linarith)
  have h128:0≤Real.log 128 := Real.log_nonneg (by norm_num)
  have hcLog:=Real.log_le_log hc hcR
  rw [Real.log_pow] at hcLog
  rw [Real.log_mul (by norm_num : (128:ℝ)≠0) hc.ne']
  have hh:40*(E/a+(Real.log 128+Real.log c))≤farStrongPrefixCoefficient B*(1+Real.log R) := by
    unfold farStrongPrefixCoefficient
    nlinarith [Nat.cast_nonneg (α:=ℝ) (farStrongReadoutExponent B)]
  exact hh.trans (Nat.le_ceil _)

#print axioms farStrong_prefix_length_bounds
#print axioms farStrong_prefix_large_enough
end ConditionalNonpolynomial.Analytic
