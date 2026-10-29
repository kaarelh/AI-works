import PhysicalShortSign

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel

def criticalFieldCoefficient (B : ℝ) : ℝ :=
  Real.sqrt (526336+526337*B)+(1+1/Real.log 2)*dyadicBlockConstant 526336

def criticalEntropyCoefficient (B : ℝ) : ℝ :=
  Real.sqrt (257+B)+criticalFieldCoefficient B

def criticalVarianceCoefficient (B : ℝ) : ℝ :=
  (2/driftDissipation)*(driftDissipation+
    ((driftDissipation/2)*varianceEntropyConstant+3)*criticalFieldCoefficient B+
    Real.log 8+2*Real.sqrt (257+B))

def criticalNonlinearCoefficient (B : ℝ) : ℝ :=
  448*criticalVarianceCoefficient B+448+224*criticalEntropyCoefficient B

lemma sqrt_log_envelope {a b B L : ℝ} (ha : 0≤a) (hB : 0≤B)
    (hL : 1≤L) (hb : b≤B*L^2) : Real.sqrt (a+b)≤Real.sqrt (a+B)*L := by
  apply (Real.sqrt_le_iff).mpr
  constructor
  · positivity
  · rw [mul_pow,Real.sq_sqrt (add_nonneg ha hB)]
    have hL2 : 1≤L^2 := by nlinarith
    have hh := mul_le_mul_of_nonneg_left hL2 ha
    nlinarith

lemma nat_log2_log_envelope {H : ℕ} {R : ℝ} (hH : 1≤H) (hHR : (H:ℝ)≤R) (hR : 2≤R) :
    ((Nat.log2 H+1:ℕ):ℝ)≤(1+1/Real.log 2)*(1+Real.log R) := by
  have hlog : 0<Real.log 2 := Real.log_pos (by norm_num)
  have hRlog : 0≤Real.log R := Real.log_nonneg (by linarith)
  have hHpos : 0<(H:ℝ) := by exact_mod_cast (Nat.zero_lt_of_lt hH)
  have hpow : (2:ℝ)^(Nat.log2 H)≤(H:ℝ) := by
    exact_mod_cast (show 2^(Nat.log2 H)≤H by
      rw [Nat.log2_eq_log_two]
      exact Nat.pow_log_le_self 2 (by omega))
  have hh := Real.log_le_log (by positivity : 0<(2:ℝ)^(Nat.log2 H)) (hpow.trans hHR)
  rw [Real.log_pow] at hh
  have hl : (Nat.log2 H:ℝ)≤Real.log R/Real.log 2 := (le_div_iff₀ hlog).mpr hh
  rw [Nat.cast_add,Nat.cast_one]
  have hi : 0≤1/Real.log 2 := by positivity
  simp only [div_eq_mul_inv,one_mul] at hl hi ⊢
  nlinarith

lemma critical_budget_log_envelope {H : ℕ} {ε B R : ℝ}
    (hH : 1≤H) (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) :
    criticalEntropyBudget H ε≤criticalEntropyCoefficient B*(1+Real.log R) ∧
    criticalVarianceBudget H ε≤criticalVarianceCoefficient B*(1+Real.log R) := by
  let L := 1+Real.log R
  have hlog : 0≤Real.log R := Real.log_nonneg (by linarith)
  have hL : 1≤L := by dsimp [L]; linarith
  have hHreal : (1:ℝ)≤H := by exact_mod_cast hH
  have he : ε≤B*L^2 := by
    have hh : ε≤(H:ℝ)*ε := by nlinarith
    exact hh.trans hgap
  have hroot : Real.sqrt (257+ε)≤Real.sqrt (257+B)*L :=
    sqrt_log_envelope (by norm_num) hB hL he
  have hsub : ((H-1:ℕ):ℝ)≤H := by exact_mod_cast Nat.sub_le H 1
  have hsmall : 526337*((H-1:ℕ):ℝ)*ε≤(526337*B)*L^2 := by
    have hm := mul_le_mul_of_nonneg_right hsub hε
    nlinarith [hgap]
  have hroot2 : Real.sqrt (526337*((H-1:ℕ):ℝ)*ε+526336)≤
      Real.sqrt (526336+526337*B)*L := by
    simpa only [add_comm] using sqrt_log_envelope (by norm_num : (0:ℝ)≤526336)
      (by positivity : 0≤526337*B) hL hsmall
  have hnat : H-1+1=H := Nat.sub_add_cancel hH
  have hj := nat_log2_log_envelope hH hHR hR
  have hfield : fieldEntropyOccupationBound (H-1) ε≤criticalFieldCoefficient B*L := by
    unfold fieldEntropyOccupationBound criticalFieldCoefficient
    rw [hnat]
    have hd : 0≤dyadicBlockConstant 526336 := Real.sqrt_nonneg _
    have hprod := mul_le_mul_of_nonneg_right hj hd
    nlinarith
  have hx : 0<257+ε := by linarith
  have hs : 0<Real.sqrt (257+ε) := Real.sqrt_pos.mpr hx
  have hlogsqrt := Real.log_le_sub_one_of_pos hs
  rw [Real.log_sqrt hx.le] at hlogsqrt
  have hlogx : Real.log (8*(257+ε))≤Real.log 8+2*Real.sqrt (257+B)*L := by
    rw [Real.log_mul (by norm_num : (8:ℝ)≠0) hx.ne']
    linarith
  constructor
  · unfold criticalEntropyBudget criticalEntropyCoefficient
    nlinarith
  · unfold criticalVarianceBudget criticalVarianceCoefficient
    rw [mul_assoc]
    apply mul_le_mul_of_nonneg_left _ (div_nonneg (by norm_num) driftDissipation_pos.le)
    have hcoef : 0≤(driftDissipation/2)*varianceEntropyConstant+3 := by
      have hc := driftDissipation_pos
      have hv := varianceEntropyConstant_nonneg
      positivity
    have hm := mul_le_mul_of_nonneg_left hfield hcoef
    have hdc := mul_le_mul_of_nonneg_left hL driftDissipation_pos.le
    have hl8 : 0≤Real.log 8 := Real.log_nonneg (by norm_num)
    have hlc := mul_le_mul_of_nonneg_left hL hl8
    dsimp only [L] at *
    nlinarith

lemma canonicalSignPrecision_depth_square {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : (H:ℝ)*(canonicalSignPrecision P)^2≤1 := by
  have hpos := canonicalSignPrecision_pos P
  have hsmall : canonicalSignPrecision P≤1/((H:ℝ)+1) := by
    unfold canonicalSignPrecision
    apply one_div_le_one_div_of_le (by positivity)
    have hr := norm_nonneg P.readout
    have hH := Nat.cast_nonneg (α:=ℝ) H
    nlinarith
  have hmul : ((H:ℝ)+1)*canonicalSignPrecision P≤1 := by
    simpa only [mul_comm] using (le_div_iff₀ (by positivity : 0<(H:ℝ)+1)).mp hsmall
  have h1 := canonicalSignPrecision_le_one P
  have hproduct := mul_le_mul_of_nonneg_right hmul hpos.le
  have hH := Nat.cast_nonneg (α:=ℝ) H
  nlinarith

/-- The actual canonical normal form has logarithmic budgets throughout the
near-critical envelope H ε ≤ B(1+log R)^2, including the target-steering scale. -/
theorem critical_normal_form_log_budgets {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H)
    {ε B R : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε) :
    canonicalEntropySum P≤2*criticalEntropyCoefficient B*(1+Real.log R) ∧
    canonicalNonlinearBudget P (canonicalSignPrecision P)≤criticalNonlinearCoefficient B*(1+Real.log R) := by
  obtain ⟨hE,hV⟩ := critical_budget_log_envelope hH hε hB hR hHR hgap
  obtain ⟨he,hl⟩ := critical_canonical_budget_bounds P hd hH hε hnear (η:=canonicalSignPrecision P)
  constructor
  · nlinarith
  · have hs := canonicalSignPrecision_depth_square P
    have hlog := Real.log_nonneg (show 1≤R by linarith)
    unfold criticalNonlinearCoefficient
    nlinarith

#print axioms critical_normal_form_log_budgets
end ConditionalNonpolynomial.Analytic.PhysicalShort
