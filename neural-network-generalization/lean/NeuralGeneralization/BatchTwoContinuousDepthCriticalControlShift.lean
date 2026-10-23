import NeuralGeneralization.GaussianTranslatePacking
import NeuralGeneralization.GaussianLinear

/-! Gaussian controls for the critical-width interpolation construction.
These estimates apply to arbitrary measurable good events, without a symmetry
assumption. They will be applied conditionally to each independent matrix. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open GaussianTranslatePacking GaussianProductDensity
set_option maxHeartbeats 1000000
variable {I:Type*} [Fintype I]

private theorem standard_density_control (c z:I→ℝ) {E:ℝ} (hE:0≤E)
    (hc:(∑i,c i^2)≤E) (hz:(∑i,c i*z i)≤E+4):
    Real.exp (-2*E-4)*density 1 z≤density 1 (c+z):=by
  have he:(∑i,(c+z) i^2)=(∑i,c i^2)+(∑i,z i^2)+2*(∑i,c i*z i):=by
    simp only [Pi.add_apply,add_sq,Finset.sum_add_distrib]
    rw [Finset.mul_sum]
    have hi:(∑i,2*c i*z i)=∑i,2*(c i*z i):=by
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [hi]
    ring
  rw [standard_density_eq,standard_density_eq,he]
  have hexp:Real.exp (-2*E-4-(∑i,z i^2)/2)≤
      Real.exp (-((∑i,c i^2)+(∑i,z i^2)+2*(∑i,c i*z i))/2):=by
    exact Real.exp_le_exp.mpr (by linarith)
  have hh:=mul_le_mul_of_nonneg_left hexp
    (show 0≤(Real.sqrt (2*Real.pi))⁻¹^Fintype.card I by positivity)
  have heexp:Real.exp (-2*E-4-(∑i,z i^2)/2)=
      Real.exp (-2*E-4)*Real.exp (-(∑i,z i^2)/2):=by
    rw [←Real.exp_add]
    congr 1
    ring
  rw [heexp] at hh
  nlinarith only [hh]

/-- A measurable event of standard Gaussian probability at least three quarters
retains exponentially controlled mass after an arbitrary Cameron--Martin shift.
The additive constant is independent of dimension and hence disappears in a
width-normalized rate. -/
theorem gaussian_control_translate_lower (c:I→ℝ) (B:Set (I→ℝ)) (hB:MeasurableSet B)
    {E:ℝ} (hE:0≤E) (hc:(∑i,c i^2)≤E)
    (hprob:(3:ℝ)/4≤(standardGaussian (I:=I)).real B):
    (1:ℝ)/2*Real.exp (-2*E-4)≤(standardGaussian (I:=I)).real (translateSet c B):=by
  classical
  let D:Set (I→ℝ):={z|E+4≤|∑i,c i*z i|}
  have hD:MeasurableSet D:=measurableSet_le measurable_const (by fun_prop)
  have htail:(standardGaussian (I:=I)).real D≤(1:ℝ)/4:=by
    have ht:=GaussianTail.gaussian_linear_form_abs_tail (fun _ : I=>(1:ℝ≥0)) c (E+1) (E+4)
      (by linarith) (by linarith) (by simpa using hc.trans (by linarith : E≤E+1))
    have hexp:Real.exp (-(E+4)^2/(2*(E+1)))≤Real.exp (-4):=by
      apply Real.exp_le_exp.mpr
      apply (div_le_iff₀ (by positivity : 0<2*(E+1))).mpr
      nlinarith [sq_nonneg E]
    have he4:(8:ℝ)≤Real.exp 4:=by
      have hh:=Real.add_one_le_exp (2:ℝ)
      have he:Real.exp 4=(Real.exp 2)^2:=by rw [←Real.exp_nat_mul]; norm_num
      rw [he]
      nlinarith [Real.exp_pos 2]
    have hsmall:2*Real.exp (-4)≤(1:ℝ)/4:=by
      rw [Real.exp_neg]
      rw [←div_eq_mul_inv]
      exact (div_le_iff₀ (Real.exp_pos 4)).mpr (by linarith)
    exact ht.trans ((mul_le_mul_of_nonneg_left hexp (by norm_num)).trans hsmall)
  let C:=B\D
  have hC:MeasurableSet C:=hB.diff hD
  have hCmass:(1:ℝ)/2≤(standardGaussian (I:=I)).real C:=by
    have hh:=le_measureReal_sdiff (μ:=standardGaussian (I:=I)) (s₁:=B) (s₂:=D)
    dsimp [C]
    linarith
  have hplus:Integrable (fun z:I→ℝ=>density 1 (c+z)) volume:=
    (measurePreserving_add_left volume c).integrable_comp_of_integrable (integrable_density 1)
  have hi:=integral_mono_ae
    (((integrable_density (I:=I) 1).const_mul (Real.exp (-2*E-4))).restrict (s:=C))
    (hplus.restrict (s:=C))
    (show ∀ᵐ z ∂(volume:Measure (I→ℝ)).restrict C,
      Real.exp (-2*E-4)*density 1 z≤density 1 (c+z) from by
      filter_upwards [ae_restrict_mem hC] with z hz
      exact standard_density_control c z hE hc ((le_abs_self _).trans (le_of_lt (lt_of_not_ge hz.2))))
  rw [integral_const_mul,←gaussian_real_set_eq_density_integral C hC,
    ←gaussian_translate_integral_density c C hC] at hi
  have hsubset:translateSet c C⊆translateSet c B:=by intro z hz; exact hz.1
  exact (by nlinarith [Real.exp_pos (-2*E-4)] : (1:ℝ)/2*Real.exp (-2*E-4)≤
    Real.exp (-2*E-4)*(standardGaussian (I:=I)).real C).trans
      (hi.trans (measureReal_mono hsubset))

end NeuralGeneralization.BatchTwoContinuousDepthCritical
