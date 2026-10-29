import ScalarPathEntropy
import ScalarMomentEntropy

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

def varianceEntropyConstant : ℝ := Real.sqrt (2/(driftRate*driftDissipation))

lemma varianceEntropyConstant_nonneg : 0≤varianceEntropyConstant := Real.sqrt_nonneg _

lemma varianceEntropyConstant_sq : varianceEntropyConstant^2=2/(driftRate*driftDissipation) := by
  unfold varianceEntropyConstant
  apply Real.sq_sqrt
  exact div_nonneg (by norm_num) (mul_nonneg driftRate_pos.le driftDissipation_pos.le)

/-- Combining dissipative drift with an entropy bound on multiplicative
variance gain gives a one-step logarithmic potential inequality. -/
theorem variance_log_potential {q r e G : ℝ} (hq : 0<q) (hr : 0<r)
    (he : 0≤e) (hG : 0≤G)
    (hd : r-q≤-driftDissipation*q^2+e/driftRate)
    (hg : Real.log r-Real.log q≤G*Real.sqrt e) :
    (driftDissipation/2)*q≤
      ((driftDissipation/2)*varianceEntropyConstant+G)*Real.sqrt e+
        Real.log q-Real.log r := by
  have hrate := driftRate_pos
  have hc := driftDissipation_pos
  have hB := varianceEntropyConstant_nonneg
  have hs := Real.sq_sqrt he
  have hs0 := Real.sqrt_nonneg e
  by_cases hlarge : (driftRate*driftDissipation/2)*q^2≤e
  · have hb : q≤varianceEntropyConstant*Real.sqrt e := by
      have hmul := mul_le_mul_of_nonneg_left hlarge (sq_nonneg varianceEntropyConstant)
      rw [varianceEntropyConstant_sq] at hmul
      have hid : (2/(driftRate*driftDissipation))*(driftRate*driftDissipation/2)=1 := by
        field_simp
      have hmul' : q^2≤varianceEntropyConstant^2*e := by
        rw [varianceEntropyConstant_sq]
        nlinarith [hmul,hid]
      nlinarith [mul_nonneg hB hs0]
    have hh := mul_le_mul_of_nonneg_left hb (show 0≤driftDissipation/2 by positivity)
    nlinarith
  · have hel : e/driftRate<(driftDissipation/2)*q^2 := by
      apply (div_lt_iff₀ driftRate_pos).mpr
      nlinarith
    have hratio : r/q≤1-(driftDissipation/2)*q := by
      apply (div_le_iff₀ hq).mpr
      nlinarith
    have hlog := Real.log_le_sub_one_of_pos (div_pos hr hq)
    rw [Real.log_div hr.ne' hq.ne'] at hlog
    have hpositive : 0≤((driftDissipation/2)*varianceEntropyConstant+G)*Real.sqrt e := by
      exact mul_nonneg (add_nonneg (mul_nonneg (div_nonneg hc.le (by norm_num)) hB) hG) hs0
    linarith

/-- The logarithmic potential telescopes. This lemma is purely algebraic;
its entropy gain premise is separately discharged by Gaussian moment KL. -/
theorem variance_sum_from_entropy_gain (H : ℕ) (q e : ℕ → ℝ) {G : ℝ}
    (hG : 0≤G) (hq : ∀j≤H,0<q j) (he : ∀j<H,0≤e j)
    (hd : ∀j<H,q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
    (hg : ∀j<H,Real.log (q (j+1))-Real.log (q j)≤G*Real.sqrt (e j)) :
    (driftDissipation/2)*(∑j ∈ Finset.range H,q j)≤
      ((driftDissipation/2)*varianceEntropyConstant+G)*
        (∑j ∈ Finset.range H,Real.sqrt (e j))+Real.log (q 0)-Real.log (q H) := by
  induction H with
  | zero => simp
  | succ H ih =>
    have hi := ih (fun j hj => hq j (by omega)) (fun j hj => he j (by omega))
      (fun j hj => hd j (by omega)) (fun j hj => hg j (by omega))
    have hs := variance_log_potential (hq H (by omega)) (hq (H+1) le_rfl)
      (he H (Nat.lt_succ_self H)) hG (hd H (Nat.lt_succ_self H)) (hg H (Nat.lt_succ_self H))
    rw [Finset.sum_range_succ,Finset.sum_range_succ]
    nlinarith

/-- Finite Gaussian KL bounds the logarithmic gain of an actual tanh
second moment. No entropy-to-variance comparison is assumed. -/
theorem scalar_transition_log_gain (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hfinite : klDiv Q (gaussianReal 0 1)≠∞) {a q r : ℝ}
    (ha : 0≤a) (haq : a≤q) (hq : 0<q) (hr : 0<r)
    (htrans : r≤scalarTransition a Q) :
    Real.log r-Real.log q≤3*Real.sqrt ((klDiv Q (gaussianReal 0 1)).toReal) := by
  let M := ∫z:ℝ,z^2 ∂Q
  have hM : 0<M := scalar_gaussian_second_moment_pos Q hfinite
  have hi := scalar_gaussian_second_moment_integrable Q hfinite
  have hpoint (z:ℝ) : varianceTest a z≤a*z^2 := by
    have hh := pow_le_pow_left₀ (abs_nonneg _) (NeuralGeneralization.BatchTwoNonGaussian.abs_tanh_le_abs
      (Real.sqrt a*z)) 2
    simpa only [sq_abs,mul_pow,Real.sq_sqrt ha,varianceTest] using hh
  have hmoment := integral_mono (varianceTest_integrable Q a) (hi.const_mul a) hpoint
  rw [integral_const_mul] at hmoment
  change scalarTransition a Q≤a*M at hmoment
  have hratio : r/q≤M := by
    apply (div_le_iff₀ hq).mpr
    have hm := mul_le_mul_of_nonneg_right haq hM.le
    nlinarith
  have hlog := Real.log_le_log (div_pos hr hq) hratio
  rw [Real.log_div hr.ne' hq.ne'] at hlog
  have hsM : 0<Real.sqrt M := Real.sqrt_pos.mpr hM
  have hls := Real.log_le_sub_one_of_pos hsM
  rw [Real.log_sqrt hM.le] at hls
  have hpol := scalar_gaussian_polar_deviation Q hfinite
  change (Real.sqrt M-1)^2≤_ at hpol
  have hs := Real.sq_sqrt (ENNReal.toReal_nonneg (a:=klDiv Q (gaussianReal 0 1)))
  have hs0 := Real.sqrt_nonneg ((klDiv Q (gaussianReal 0 1)).toReal)
  have hh : 2*(Real.sqrt M-1)≤3*Real.sqrt ((klDiv Q (gaussianReal 0 1)).toReal) := by
    nlinarith
  linarith

/-- Actual controlled scalar paths have logarithmic total variance occupation
up to the same square-root excess term. The final logarithm is bounded solely
by the scalar readout cost, rather than by the smallest intermediate variance. -/
theorem controlled_path_variance_sum (H : ℕ) (q a e : ℕ → ℝ) (Q : ℕ → Measure ℝ)
    {ε readout : ℝ} (hε : 0≤ε)
    (hq : ∀j≤H,0<q j) (hq1 : ∀j≤H,q j≤1)
    (ha : ∀j<H,0≤a j) (haq : ∀j<H,a j≤q j)
    (hprob : ∀j<H,IsProbabilityMeasure (Q j))
    (hfinite : ∀j<H,klDiv (Q j) (gaussianReal 0 1)≠∞)
    (hcharge : ∀j<H,(klDiv (Q j) (gaussianReal 0 1)).toReal≤e j)
    (htrans : ∀j<H,q (j+1)≤scalarTransition (a j) (Q j))
    (hreadout : 1/(8*q H)≤readout)
    (hnear : (∑j ∈ Finset.range H,e j)+readout≤scalarBaseline.toReal+ε) :
    (driftDissipation/2)*(∑j ∈ Finset.range H,q j)≤
      ((driftDissipation/2)*varianceEntropyConstant+3)*
        (Real.sqrt (526337*(H:ℝ)*ε+526336)+
          ((Nat.log2 (H+1)+1:ℕ):ℝ)*dyadicBlockConstant 526336)+
      Real.log (8*(257+ε)) := by
  have he (j:ℕ) (hj:j<H) : 0≤e j := ENNReal.toReal_nonneg.trans (hcharge j hj)
  have hd (j:ℕ) (hj:j<H) :
      q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate := by
    letI := hprob j hj
    have hh := scalar_entropy_drift_subcritical (Q j) (hfinite j hj)
      (ha j hj) (haq j hj) (hq1 j (by omega))
    have hch := div_le_div_of_nonneg_right (hcharge j hj) driftRate_pos.le
    have ht := htrans j hj
    change q (j+1)≤∫z,varianceTest (a j) z ∂Q j at ht
    linarith
  have hg (j:ℕ) (hj:j<H) : Real.log (q (j+1))-Real.log (q j)≤3*Real.sqrt (e j) := by
    letI := hprob j hj
    have hh := scalar_transition_log_gain (Q j) (hfinite j hj) (ha j hj) (haq j hj)
      (hq j (by omega)) (hq (j+1) (by omega)) (htrans j hj)
    have hs := Real.sqrt_le_sqrt (hcharge j hj)
    linarith
  have hv := variance_sum_from_entropy_gain H q e (by norm_num : (0:ℝ)≤3) hq he hd hg
  have hs := controlled_path_sqrt_entropy H q a e Q hε hq hq1 ha haq hprob hfinite hcharge htrans hreadout hnear
  have hk : 0≤(driftDissipation/2)*varianceEntropyConstant+3 := by
    have hc := driftDissipation_pos
    have hb := varianceEntropyConstant_nonneg
    positivity
  have hscaled := mul_le_mul_of_nonneg_left hs hk
  have hsum0 : 0≤∑j ∈ Finset.range H,e j :=
    Finset.sum_nonneg fun j hj => he j (Finset.mem_range.mp hj)
  have hread : readout≤257+ε := by linarith [scalarBaseline_le]
  have hrecip : 1/q H≤8*(257+ε) := by
    have hqH := hq H le_rfl
    have hid : 1/q H=8*(1/(8*q H)) := by field_simp
    rw [hid]
    linarith
  have hlog := Real.log_le_log (one_div_pos.mpr (hq H le_rfl)) hrecip
  rw [Real.log_div one_ne_zero (hq H le_rfl).ne',Real.log_one] at hlog
  have hlog0 : Real.log (q 0)≤0 := Real.log_nonpos (hq 0 (by omega)).le (hq1 0 (by omega))
  linarith

#print axioms variance_log_potential
#print axioms scalar_transition_log_gain
#print axioms controlled_path_variance_sum
end ConditionalNonpolynomial.Analytic
