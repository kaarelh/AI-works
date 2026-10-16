import NeuralGeneralization.GaussianAmplitudePopulation
import NeuralGeneralization.SmallSampleCutoff

/-! Explicit scalar budgets for the large-output Gaussian argument. -/
noncomputable section
open Filter
open scoped Topology
namespace NeuralGeneralization.GaussianAmplitude

def scalarEnvelope (x : ℝ) : ℝ :=
  (16*Real.sqrt (2*Real.pi)*Real.exp (3/2))*Real.exp (-x/8)+24/x+32*Real.exp (-14*x)

lemma sqrt_add_one_le_exp (x : ℝ) (hx : 0 ≤ x) :
    Real.sqrt x+1 ≤ 8*Real.exp (x/8) := by
  have hs := Real.sq_sqrt hx
  have hn := Real.sqrt_nonneg x
  have he := Real.add_one_le_exp (x/8)
  nlinarith [sq_nonneg (Real.sqrt x-1)]

lemma smallBall_ratio_identity (x : ℝ) (hx : 0 ≤ x) :
    Real.exp (x/4)/smallBall (Real.sqrt x)/Real.exp x =
      2*Real.sqrt (2*Real.pi)*Real.exp (3/2)*(Real.sqrt x+1)*Real.exp (-x/4) := by
  have hp := Real.exp_pos (-(3/2:ℝ))
  have hs := Real.sqrt_pos.mpr (mul_pos (by norm_num : (0:ℝ)<2) Real.pi_pos)
  have ht : 0 < Real.sqrt x+1 := by positivity
  unfold smallBall
  rw [Real.sq_sqrt hx]
  have he : Real.exp (3/2)*Real.exp (-x/4)*
      (Real.exp (-(3/2:ℝ))*Real.exp (-x/2)*Real.exp x)=Real.exp (x/4) := by
    simp only [←Real.exp_add]
    congr 1
    ring
  field_simp
  simp only [← Real.exp_add]
  congr 1
  ring

/-- Actual amplitude expression, controlled uniformly over the conditioned
law's entropy D, the auxiliary sample size m, and its covariance floor. -/
theorem amplitude_scalar_bound (a sigma D m B x : ℝ)
    (hx : 0 < x) (hsigma : 0 < sigma) (ha : 0 ≤ a)
    (hD0 : 0 ≤ D) (hD : D ≤ Real.exp (x/4))
    (hmlo : Real.exp x ≤ m) (hmhi : m ≤ 2*Real.exp x)
    (hB : Real.exp (16*x-Real.log 2) ≤ B) :
    (D/smallBall (Real.sqrt x)+(4*sigma^2/(a+sigma*Real.sqrt x)^2)*(2*m+4*D))/m+
      4*m^2/B ≤ scalarEnvelope x := by
  have hm : 0 < m := (Real.exp_pos x).trans_le hmlo
  have hB0 : 0 < B := (Real.exp_pos _).trans_le hB
  have hp : 0 < smallBall (Real.sqrt x) := smallBall_pos (Real.sqrt_nonneg _)
  have ht : 0 < Real.sqrt x := Real.sqrt_pos.mpr hx
  have hden : 0 < a+sigma*Real.sqrt x := by positivity
  have hDm : D ≤ m := hD.trans ((Real.exp_le_exp.mpr (by linarith : x/4≤x)).trans hmlo)
  have hfirst : D/smallBall (Real.sqrt x)/m ≤
      (16*Real.sqrt (2*Real.pi)*Real.exp (3/2))*Real.exp (-x/8) := by
    calc
      _ ≤ Real.exp (x/4)/smallBall (Real.sqrt x)/Real.exp x := by gcongr
      _ = 2*Real.sqrt (2*Real.pi)*Real.exp (3/2)*(Real.sqrt x+1)*Real.exp (-x/4) :=
        smallBall_ratio_identity x hx.le
      _ ≤ 2*Real.sqrt (2*Real.pi)*Real.exp (3/2)*(8*Real.exp (x/8))*Real.exp (-x/4) := by
        gcongr
        exact sqrt_add_one_le_exp x hx.le
      _ = _ := by
        have he : Real.exp (x/8)*Real.exp (-x/4)=Real.exp (-x/8) := by
          rw [←Real.exp_add]
          congr 1
          ring
        rw [← he]
        ring
  have hfrac : 4*sigma^2/(a+sigma*Real.sqrt x)^2 ≤ 4/x := by
    apply (div_le_div_iff₀ (sq_pos_of_pos hden) hx).mpr
    have hh : sigma*Real.sqrt x ≤ a+sigma*Real.sqrt x := by linarith
    have hs := pow_le_pow_left₀ (mul_nonneg hsigma.le ht.le) hh 2
    rw [mul_pow, Real.sq_sqrt hx.le] at hs
    nlinarith only [hs]
  have hsecond : ((4*sigma^2/(a+sigma*Real.sqrt x)^2)*(2*m+4*D))/m ≤ 24/x := by
    have hfactor : (2*m+4*D)/m ≤ 6 := (div_le_iff₀ hm).mpr (by linarith)
    calc
      _ = (4*sigma^2/(a+sigma*Real.sqrt x)^2)*((2*m+4*D)/m) := by ring
      _ ≤ (4/x)*6 := mul_le_mul hfrac hfactor (by positivity) (by positivity)
      _ = _ := by ring
  have hthird : 4*m^2/B ≤ 32*Real.exp (-14*x) := by
    calc
      _ ≤ 4*(2*Real.exp x)^2/Real.exp (16*x-Real.log 2) := by gcongr
      _ = _ := by
        rw [Real.exp_sub, Real.exp_log (by norm_num : (0:ℝ)<2)]
        have he : Real.exp (-14*x)*Real.exp (16*x)=(Real.exp x)^2 := by
          rw [←Real.exp_add, show -14*x+16*x=x+x by ring, Real.exp_add, pow_two]
        calc
          _ = 32*(Real.exp x)^2/Real.exp (16*x) := by ring
          _ = _ := by rw [← he]; field_simp
  unfold scalarEnvelope
  rw [add_div]
  linarith

lemma scalarEnvelope_tendsto : Tendsto scalarEnvelope atTop (𝓝 0) := by
  have h₁ : Tendsto (fun x : ℝ => Real.exp (-x/8)) atTop (𝓝 0) := by
    have h := Real.tendsto_exp_neg_atTop_nhds_zero.comp
      (Filter.Tendsto.atTop_mul_const (by norm_num : (0:ℝ)<1/8) tendsto_id)
    simpa only [Function.comp_def, div_eq_mul_inv, neg_mul, id_eq, one_mul] using h
  have h₂ : Tendsto (fun x : ℝ => 24/x) atTop (𝓝 0) := tendsto_const_nhds.div_atTop tendsto_id
  have h₃ : Tendsto (fun x : ℝ => Real.exp (-14*x)) atTop (𝓝 0) := by
    have h := Real.tendsto_exp_neg_atTop_nhds_zero.comp
      (Filter.Tendsto.const_mul_atTop (by norm_num : (0:ℝ)<14) tendsto_id)
    simpa only [Function.comp_def, neg_mul, id_eq] using h
  unfold scalarEnvelope
  simpa only [mul_zero, add_zero] using
    ((h₁.const_mul (16*Real.sqrt (2*Real.pi)*Real.exp (3/2))).add h₂).add (h₃.const_mul 32)

/-- No entropy or sample-size asymptotic is assumed in the scalar endpoint:
the concrete envelope itself tends to zero. -/
theorem eventually_amplitude_scalar_bound : ∀ᶠ x : ℝ in atTop,
    ∀ a sigma D m B : ℝ, 0 < sigma → 0 ≤ a → 0 ≤ D → D ≤ Real.exp (x/4) →
      Real.exp x ≤ m → m ≤ 2*Real.exp x → Real.exp (16*x-Real.log 2) ≤ B →
      (D/smallBall (Real.sqrt x)+(4*sigma^2/(a+sigma*Real.sqrt x)^2)*(2*m+4*D))/m+
        4*m^2/B ≤ 1/32 := by
  filter_upwards [eventually_gt_atTop (0:ℝ), scalarEnvelope_tendsto.eventually
    (eventually_le_nhds (by norm_num : (0:ℝ)<1/32))] with x hx henv
  intro a sigma D m B hs ha hD0 hD hmlo hmhi hB
  exact (amplitude_scalar_bound a sigma D m B x hx hs ha hD0 hD hmlo hmhi hB).trans henv

end NeuralGeneralization.GaussianAmplitude
