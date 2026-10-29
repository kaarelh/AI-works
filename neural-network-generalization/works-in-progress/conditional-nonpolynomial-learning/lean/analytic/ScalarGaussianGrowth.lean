import ScalarBellman

noncomputable section
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization
open BatchTwoContinuousDepthCritical

lemma tanh_square_lower_quartic (x : ℝ) : x^2-x^4 ≤ (Real.tanh x)^2 := by
  have hpos (y : ℝ) (hy : 0≤y) : y^2-y^4 ≤ (Real.tanh y)^2 := by
    have hp : 0<1+y^2 := by positivity
    have hl := BatchTwoNeuralConverse.tanh_lower_square_root hy
    have hs := pow_le_pow_left₀ (show 0≤y/Real.sqrt (1+y^2) by positivity) hl 2
    rw [div_pow,Real.sq_sqrt hp.le] at hs
    have hs' := (div_le_iff₀ hp).mp hs
    have hu := pow_le_pow_left₀ (abs_nonneg _) (BatchTwoNonGaussian.abs_tanh_le_abs y) 2
    simp only [sq_abs] at hu
    have hm := mul_nonneg (sq_nonneg y) (sub_nonneg.mpr hu)
    nlinarith
  rcases le_total 0 x with hx | hx
  · exact hpos x hx
  · have hh := hpos (-x) (by linarith)
    simpa only [Real.tanh_neg,neg_sq,show (-x)^4=x^4 by ring] using hh

lemma coolingSecondMoment_lower_coarse {q : ℝ} (hq : 0≤q) :
    q-64*q^2 ≤ coolingSecondMoment q := by
  have hpoint (z : ℝ) : q*z^2-q^2*z^4 ≤ varianceTest q z := by
    have hh := tanh_square_lower_quartic (Real.sqrt q*z)
    have h4 : (Real.sqrt q*z)^4=q^2*z^4 := by
      rw [mul_pow,show (Real.sqrt q)^4=((Real.sqrt q)^2)^2 by ring,Real.sq_sqrt hq]
    simpa only [varianceTest,mul_pow,Real.sq_sqrt hq,h4] using hh
  have hi2 := (RobustCompressionGaussian.gaussian_power_integrable 0 1 2).const_mul q
  have hi4 := (RobustCompressionGaussian.gaussian_power_integrable 0 1 4).const_mul (q^2)
  have hh := integral_mono (hi2.sub hi4) (varianceTest_integrable (gaussianReal 0 1) q) hpoint
  simp only [Pi.sub_apply] at hh
  rw [integral_sub hi2 hi4,integral_const_mul,integral_const_mul] at hh
  have hz2 : (∫z:ℝ,z^2 ∂gaussianReal 0 1)=1 := BatchTwoNonGaussian.standardGaussian.square_integral
  rw [hz2,mul_one] at hh
  have hb := mul_le_mul_of_nonneg_left
    (RobustCompressionGaussian.gaussian_fourth_moment_le 1 (by norm_num)) (sq_nonneg q)
  change _≤coolingSecondMoment q at hh
  linarith

def growthState (q : ℝ) : ℝ := coolingSecondMoment ((1+256*q)*q)

theorem growthState_bounds {q : ℝ} (hq : 0≤q) (hqsmall : q≤1/2048) :
    q+128*q^2 ≤ growthState q ∧ growthState q≤q+256*q^2 := by
  have hu : 0≤(1+256*q)*q := by positivity
  have huupper : (1+256*q)*q ≤ (9/8:ℝ)*q := by nlinarith
  have hsq := pow_le_pow_left₀ hu huupper 2
  have hlo := coolingSecondMoment_lower_coarse hu
  have hhi := coolingSecondMoment_le ((1+256*q)*q) hu
  change _≤growthState q at hlo
  change growthState q≤_ at hhi
  constructor <;> nlinarith

def stoppedGrowth (p a : ℝ) : ℕ → ℝ
  | 0 => a
  | n+1 => if stoppedGrowth p a n < p then growthState (stoppedGrowth p a n)
      else stoppedGrowth p a n

lemma stoppedGrowth_bounds {p a : ℝ} (ha : 0<a) (hap : a≤p) (hp : p≤1/2048)
    (n : ℕ) : a≤stoppedGrowth p a n ∧ stoppedGrowth p a n≤p+256*p^2 := by
  induction n with
  | zero => simp only [stoppedGrowth]; constructor <;> nlinarith
  | succ n ih =>
    simp only [stoppedGrowth]
    split_ifs with hn
    · have hq0 : 0≤stoppedGrowth p a n := ha.le.trans ih.1
      have hqb := growthState_bounds hq0 (hn.le.trans hp)
      constructor
      · nlinarith [sq_nonneg (stoppedGrowth p a n)]
      · have hs := pow_le_pow_left₀ hq0 hn.le 2
        nlinarith
    · exact ih

/-- Full Gaussian-growth steps reach p in finitely many iterations. Overshoot
is retained, avoiding an intermediate-value/exact-hitting assumption. -/
theorem stoppedGrowth_reaches {p a : ℝ} (ha : 0<a) (hap : a≤p) (hp : p≤1/2048) :
    ∃ n, p≤stoppedGrowth p a n := by
  by_contra hn
  have hbelow (n:ℕ) : stoppedGrowth p a n<p := by
    exact lt_of_not_ge (fun h => hn ⟨n,h⟩)
  have hlinear (n:ℕ) : a+(n:ℝ)*(128*a^2)≤stoppedGrowth p a n := by
    induction n with
    | zero => simp [stoppedGrowth]
    | succ n ih =>
      have hb := stoppedGrowth_bounds ha hap hp n
      have hq0 := ha.le.trans hb.1
      have hg := (growthState_bounds hq0 ((hbelow n).le.trans hp)).1
      have hs := pow_le_pow_left₀ ha.le hb.1 2
      simp only [stoppedGrowth,if_pos (hbelow n),Nat.cast_add,Nat.cast_one]
      nlinarith
  have hden : 0<128*a^2 := by positivity
  obtain ⟨n,hn'⟩ := exists_nat_gt (p/(128*a^2))
  have hm := (div_lt_iff₀ hden).mp hn'
  have hl := hlinear n
  have hb := hbelow n
  linarith

def inflationLaw (q : ℝ) : Measure ℝ :=
  gaussianReal 0 (Real.toNNReal (1+256*q))

instance inflationLaw_probability (q : ℝ) : IsProbabilityMeasure (inflationLaw q) := by
  unfold inflationLaw
  infer_instance

/-- The actual Gaussian variance-inflation control produces the growth map. -/
theorem inflationLaw_transition {q : ℝ} (hq : 0≤q) :
    scalarTransition q (inflationLaw q)=growthState q := by
  have hv : 0≤1+256*q := by positivity
  have hmap : (gaussianReal 0 1).map (fun z:ℝ => Real.sqrt (1+256*q)*z)=inflationLaw q := by
    rw [gaussianReal_map_const_mul]
    unfold inflationLaw
    congr 1
    · ring
    · apply NNReal.eq
      simp only [NNReal.coe_mul,NNReal.coe_mk,NNReal.coe_one,mul_one,
        Real.sq_sqrt hv,Real.coe_toNNReal _ hv]
  unfold scalarTransition
  rw [← hmap,integral_map (by fun_prop) (by unfold varianceTest; fun_prop)]
  unfold growthState BatchTwoContinuousDepthCritical.coolingSecondMoment
  apply integral_congr_ae
  filter_upwards [] with z
  unfold varianceTest
  rw [Real.sqrt_mul hv]
  congr 2
  ring

#print axioms inflationLaw_transition

#print axioms growthState_bounds
#print axioms stoppedGrowth_reaches
end ConditionalNonpolynomial.Analytic
