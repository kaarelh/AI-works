import NeuralGeneralization.BatchTwoContinuousDepthCriticalCooling
import NeuralGeneralization.RobustEntropyMoments
import NeuralGeneralization.RobustCompressionGaussian

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization
open BatchTwoContinuousDepthCritical

def varianceTest (q z : ℝ) : ℝ := (Real.tanh (Real.sqrt q*z))^2

def driftRate : ℝ := coolingConstant/128

def driftDissipation : ℝ := coolingConstant/2

lemma coolingConstant_le_one : coolingConstant ≤ 1 := by
  have h := coolingSecondMoment_quadratic (q:=1) (by norm_num) (by norm_num)
  have h0 := coolingSecondMoment_nonneg 1
  norm_num at h
  linarith

lemma driftRate_pos : 0 < driftRate := div_pos coolingConstant_pos (by norm_num)
lemma driftRate_le_one : driftRate ≤ 1 := by
  unfold driftRate
  linarith [coolingConstant_le_one]
lemma driftDissipation_pos : 0 < driftDissipation := div_pos coolingConstant_pos (by norm_num)
lemma driftDissipation_le_half : driftDissipation ≤ 1/2 := by
  unfold driftDissipation
  linarith [coolingConstant_le_one]

lemma varianceTest_nonneg (q z : ℝ) : 0 ≤ varianceTest q z := sq_nonneg _
lemma varianceTest_le_one (q z : ℝ) : varianceTest q z ≤ 1 :=
  (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le

lemma varianceTest_integrable (Q : Measure ℝ) [IsProbabilityMeasure Q] (q : ℝ) :
    Integrable (varianceTest q) Q := by
  apply Integrable.of_bound (by unfold varianceTest; fun_prop) 1
  filter_upwards [] with z
  rw [Real.norm_eq_abs, abs_of_nonneg (varianceTest_nonneg q z)]
  exact varianceTest_le_one q z

lemma varianceTest_sq_integrable (Q : Measure ℝ) [IsProbabilityMeasure Q] (q : ℝ) :
    Integrable (fun z => (varianceTest q z)^2) Q := by
  apply Integrable.of_bound (by unfold varianceTest; fun_prop) 1
  filter_upwards [] with z
  rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
  nlinarith [varianceTest_nonneg q z, varianceTest_le_one q z]

lemma varianceTest_fourth_bound {q : ℝ} (hq : 0 ≤ q) :
    (∫ z, (varianceTest q z)^2 ∂gaussianReal 0 1) ≤ 64*q^2 := by
  have hpoint (z:ℝ) : (varianceTest q z)^2 ≤ q^2*z^4 := by
    have h := pow_le_pow_left₀ (abs_nonneg _) (BatchTwoNonGaussian.abs_tanh_le_abs (Real.sqrt q*z)) 2
    simp only [sq_abs,mul_pow,Real.sq_sqrt hq] at h
    have hh := pow_le_pow_left₀ (varianceTest_nonneg q z) h 2
    unfold varianceTest at hh ⊢
    nlinarith only [hh]
  have hh := integral_mono (varianceTest_sq_integrable (gaussianReal 0 1) q)
    ((RobustCompressionGaussian.gaussian_power_integrable 0 1 4).const_mul (q^2)) hpoint
  rw [integral_const_mul] at hh
  have hg := mul_le_mul_of_nonneg_left
    (RobustCompressionGaussian.gaussian_fourth_moment_le 1 (by norm_num)) (sq_nonneg q)
  nlinarith

lemma varianceTest_exp_integrable (Q : Measure ℝ) [IsProbabilityMeasure Q] (q : ℝ) :
    Integrable (fun z => Real.exp (driftRate*varianceTest q z)) Q := by
  apply Integrable.of_bound (by unfold varianceTest; fun_prop) (Real.exp driftRate)
  filter_upwards [] with z
  rw [Real.norm_eq_abs, abs_of_nonneg (Real.exp_nonneg _)]
  apply Real.exp_le_exp.mpr
  exact (mul_le_mul_of_nonneg_left (varianceTest_le_one q z) driftRate_pos.le).trans_eq (mul_one _)

/-- An actual Gaussian exponential-moment estimate with a quadratic variance
loss. It is derived from bounded exp Taylor, free Gaussian cooling, and the
Gaussian fourth moment; no concentration/MGF assertion is assumed. -/
theorem varianceTest_mgf {q : ℝ} (hq : 0 ≤ q) (hq1 : q ≤ 1) :
    (∫ z, Real.exp (driftRate*varianceTest q z) ∂gaussianReal 0 1) ≤
      Real.exp (driftRate*(q-driftDissipation*q^2)) := by
  have hpoint (z:ℝ) : Real.exp (driftRate*varianceTest q z) ≤
      1+driftRate*varianceTest q z+driftRate^2*(varianceTest q z)^2 := by
    have harg0 : 0 ≤ driftRate*varianceTest q z := mul_nonneg driftRate_pos.le (varianceTest_nonneg q z)
    have harg1 : driftRate*varianceTest q z ≤ 1 :=
      (mul_le_mul_of_nonneg_left (varianceTest_le_one q z) driftRate_pos.le).trans (by simpa using driftRate_le_one)
    have hh := Real.abs_exp_sub_one_sub_id_le (show |driftRate*varianceTest q z|≤1 by
      rw [abs_of_nonneg harg0]; exact harg1)
    have hu := (le_abs_self (Real.exp (driftRate*varianceTest q z)-1-driftRate*varianceTest q z)).trans hh
    nlinarith only [hu]
  have hpoly : Integrable (fun z:ℝ =>
      1+driftRate*varianceTest q z+driftRate^2*(varianceTest q z)^2) (gaussianReal 0 1) :=
    ((integrable_const 1).add ((varianceTest_integrable _ q).const_mul driftRate)).add
      ((varianceTest_sq_integrable _ q).const_mul (driftRate^2))
  have hi := integral_mono (varianceTest_exp_integrable _ q) hpoly hpoint
  have hi1 : Integrable (fun z:ℝ => 1+driftRate*varianceTest q z) (gaussianReal 0 1) :=
    (integrable_const 1).add ((varianceTest_integrable (gaussianReal 0 1) q).const_mul driftRate)
  have hi2 : Integrable (fun z:ℝ => driftRate^2*(varianceTest q z)^2) (gaussianReal 0 1) :=
    (varianceTest_sq_integrable (gaussianReal 0 1) q).const_mul (driftRate^2)
  have hi3 : Integrable (fun z:ℝ => driftRate*varianceTest q z) (gaussianReal 0 1) :=
    (varianceTest_integrable (gaussianReal 0 1) q).const_mul driftRate
  rw [integral_add hi1 hi2, integral_add (integrable_const 1) hi3,
    integral_const_mul, integral_const_mul] at hi
  simp only [integral_const,probReal_univ,one_smul] at hi
  have hF := mul_le_mul_of_nonneg_left (coolingSecondMoment_quadratic hq hq1) driftRate_pos.le
  change driftRate*(∫z,varianceTest q z ∂gaussianReal 0 1) ≤ driftRate*(q-coolingConstant*q^2) at hF
  have h4 := mul_le_mul_of_nonneg_left (varianceTest_fourth_bound hq) (sq_nonneg driftRate)
  have halg : driftRate*(q-coolingConstant*q^2)+driftRate^2*(64*q^2) =
      driftRate*(q-driftDissipation*q^2) := by
    unfold driftRate driftDissipation
    ring
  have hexp := Real.add_one_le_exp (driftRate*(q-driftDissipation*q^2))
  linarith

/-- Actual finite-KL scalar drift for the standard Gaussian reference. -/
theorem scalar_entropy_drift (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1) ≠ ∞) {q : ℝ}
    (hq : 0 ≤ q) (hq1 : q ≤ 1) :
    (∫ z, varianceTest q z ∂Q)-q ≤ -driftDissipation*q^2+
      (klDiv Q (gaussianReal 0 1)).toReal/driftRate := by
  have hdual := RobustEntropyMoments.integral_le_kl_add_exponential_bound
    Q (gaussianReal 0 1) hKL (fun z => driftRate*varianceTest q z)
    (by unfold varianceTest; fun_prop)
    (fun z => mul_nonneg driftRate_pos.le (varianceTest_nonneg q z))
    (varianceTest_exp_integrable _ q)
    (driftRate*(q-driftDissipation*q^2)) (varianceTest_mgf hq hq1)
  rw [integral_const_mul] at hdual
  have hmul : driftRate*((∫ z, varianceTest q z ∂Q)-q+driftDissipation*q^2) ≤
      (klDiv Q (gaussianReal 0 1)).toReal := by linarith
  have hdiv : (∫ z, varianceTest q z ∂Q)-q+driftDissipation*q^2 ≤
      (klDiv Q (gaussianReal 0 1)).toReal/driftRate :=
    (le_div_iff₀ driftRate_pos).mpr (by simpa only [mul_comm] using hmul)
  linarith

/-- Uniform canonical-scale version: the reference variance a may be smaller
than the preceding variance q. In particular a=t²q for any0≤t≤1. -/
theorem scalar_entropy_drift_subcritical (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1) ≠ ∞) {a q : ℝ}
    (ha : 0 ≤ a) (haq : a ≤ q) (hq1 : q ≤ 1) :
    (∫ z, varianceTest a z ∂Q)-q ≤ -driftDissipation*q^2+
      (klDiv Q (gaussianReal 0 1)).toReal/driftRate := by
  have h := scalar_entropy_drift Q hKL ha (haq.trans hq1)
  have hq : 0 ≤ q := ha.trans haq
  have hfactor : 0 ≤ 1-driftDissipation*(q+a) := by
    have hb := mul_le_mul_of_nonneg_left (show q+a≤2 by linarith) driftDissipation_pos.le
    nlinarith [driftDissipation_le_half]
  have hprod := mul_nonneg (sub_nonneg.mpr haq) hfactor
  nlinarith

lemma occupation_of_drift (q e : ℕ → ℝ) (m : ℕ)
    (hstep : ∀ j<m, q (j+1)-q j ≤ -driftDissipation*(q j)^2+e j/driftRate) :
    driftDissipation*(∑ j ∈ Finset.range m, (q j)^2)+q m ≤
      q 0+∑ j ∈ Finset.range m, e j/driftRate := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hi := ih (fun j hj => hstep j (Nat.lt_succ_of_lt hj))
    have hs := hstep m (Nat.lt_succ_self m)
    simp only [Finset.sum_range_succ]
    nlinarith

/-- Quadratic occupation for a genuine finite sequence of finite-KL changes of
Gaussian row law. Every next state is an actual tanh-square integral. The inputs
a_j may use any canonical contraction relative to q_j. -/
theorem controlled_variance_occupation (m : ℕ) (q a : ℕ → ℝ)
    (Q : ℕ → Measure ℝ)
    (hprob : ∀ j<m, IsProbabilityMeasure (Q j))
    (hKL : ∀ j<m, klDiv (Q j) (gaussianReal 0 1) ≠ ∞)
    (ha : ∀ j<m, 0 ≤ a j)
    (haq : ∀ j<m, a j ≤ q j)
    (hq1 : ∀ j<m, q j ≤ 1)
    (htransition : ∀ j<m, q (j+1)=∫ z, varianceTest (a j) z ∂Q j)
    (hfinal : 0 ≤ q m) :
    driftDissipation*(∑ j ∈ Finset.range m, (q j)^2) ≤
      q 0+∑ j ∈ Finset.range m, (klDiv (Q j) (gaussianReal 0 1)).toReal/driftRate := by
  have hstep (j : ℕ) (hj : j<m) : q (j+1)-q j ≤
      -driftDissipation*(q j)^2+(klDiv (Q j) (gaussianReal 0 1)).toReal/driftRate := by
    letI := hprob j hj
    rw [htransition j hj]
    exact scalar_entropy_drift_subcritical (Q j) (hKL j hj) (ha j hj) (haq j hj) (hq1 j hj)
  have hh := occupation_of_drift q (fun j => (klDiv (Q j) (gaussianReal 0 1)).toReal) m hstep
  linarith

#print axioms scalar_entropy_drift_subcritical
#print axioms controlled_variance_occupation

#print axioms scalar_entropy_drift
end ConditionalNonpolynomial.Analytic
