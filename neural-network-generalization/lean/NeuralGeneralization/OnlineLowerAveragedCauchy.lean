import Mathlib.Analysis.Complex.MeanValue
import Mathlib.Tactic

/-! Averaged Cauchy estimates retain one rather than two powers of the order. -/
noncomputable section
open scoped BigOperators
open Complex Metric Set MeasureTheory Real
namespace NeuralGeneralization.OnlineLowerTanh

lemma disk_ne_zero {u r : ℝ} (hr : r<u) (hu : 0<u)
    {z:ℂ} (hz:z∈closedBall (u:ℂ) r) : z≠0 := by
  intro h
  subst z
  have hh:=Metric.mem_closedBall.mp hz
  simp only [dist_zero_right,dist_zero_left,Complex.norm_real,Real.norm_eq_abs,abs_of_pos hu] at hh
  linarith

lemma sphere_re_mobius {u r:ℝ} (hu:0<u) (hr:0≤r) (hru:r<u)
    {z:ℂ} (hz:z∈sphere (u:ℂ) r) :
    (((2*u:ℝ):ℂ)-z).re*z.re + (((2*u:ℝ):ℂ)-z).im*z.im = u^2-r^2 := by
  have hh : Complex.normSq (z-(u:ℂ))=r^2 := by
    rw [Complex.normSq_eq_norm_sq,mem_sphere_iff_norm.mp hz]
  simp only [Complex.normSq_apply,Complex.sub_re,Complex.sub_im,Complex.ofReal_re,
    Complex.ofReal_im,sub_zero] at hh ⊢
  nlinarith

/-- Exact average of the reciprocal squared distance on an off-center circle. -/
theorem circleAverage_inv_norm_sq (u r:ℝ) (hr:0≤r) (hru:r<u) :
    circleAverage (fun z:ℂ=>1/‖z‖^2) (u:ℂ) r = 1/(u^2-r^2) := by
  have hu : 0<u := lt_of_le_of_lt hr hru
  let g : ℂ→ℂ := fun z=>(((2*u:ℝ):ℂ)-z)/z
  have hg : DifferentiableOn ℂ g (closedBall (u:ℂ) r) := by
    intro z hz
    exact ((differentiableAt_const _).sub differentiableAt_id).div
      differentiableAt_id (disk_ne_zero hru hu hz) |>.differentiableWithinAt
  have hgc : CircleIntegrable g (u:ℂ) r :=
    (hg.continuousOn.mono sphere_subset_closedBall).circleIntegrable hr
  have hmean : circleAverage g (u:ℂ) r=1 := by
    have hgc' : DiffContOnCl ℂ g (ball (u:ℂ) |r|) := by
      simpa only [abs_of_nonneg hr] using (hg.mono closure_ball_subset_closedBall).diffContOnCl
    have h := hgc'.circleAverage
    rw [h]
    dsimp [g]
    have un : (u:ℂ)≠0 := by exact_mod_cast hu.ne'
    push_cast
    field_simp
    ring
  have hre := Complex.reCLM.circleAverage_comp_comm hgc
  rw [hmean] at hre
  have heq : circleAverage (fun z:ℂ=>(u^2-r^2)*(1/‖z‖^2)) (u:ℂ) r=1 := by
    rw [← show circleAverage (Complex.reCLM ∘ g) (u:ℂ) r=
      circleAverage (fun z:ℂ=>(u^2-r^2)*(1/‖z‖^2)) (u:ℂ) r from ?_]
    simpa using hre
    apply circleAverage_congr_sphere
    intro z hz
    rw [abs_of_nonneg hr] at hz
    change (g z).re=_
    dsimp [g]
    rw [Complex.div_re,←add_div,←Complex.normSq_eq_norm_sq,
      sphere_re_mobius hu hr hru hz]
    ring
  have hfactor : circleAverage (fun z:ℂ=>(u^2-r^2)*(1/‖z‖^2)) (u:ℂ) r=
      (u^2-r^2)*circleAverage (fun z:ℂ=>1/‖z‖^2) (u:ℂ) r := by
    unfold circleAverage
    simp only [smul_eq_mul]
    rw [intervalIntegral.integral_const_mul]
    ring
  rw [hfactor] at heq
  have hpos : 0<u^2-r^2 := by nlinarith
  apply (eq_div_iff hpos.ne').mpr
  nlinarith

/-- Cauchy's derivative estimate using the average boundary norm. -/
theorem iteratedDeriv_norm_le_circleAverage (f:ℂ→ℂ) (u:ℂ) (r:ℝ)
    (hr:0<r) (hf:DifferentiableOn ℂ f (closedBall u r)) (j:ℕ) :
    ‖iteratedDeriv j f u‖ ≤ (j.factorial:ℝ)*
      circleAverage (fun z=>‖f z‖) u r * r⁻¹^j := by
  have hp := hf.hasFPowerSeriesOnBall (R:=⟨r,hr.le⟩) hr
  have hd := hp.factorial_smul 1 j
  rw [iteratedFDeriv_apply_eq_iteratedDeriv_mul_prod,Finset.prod_const_one,one_smul] at hd
  rw [←hd,←Nat.cast_smul_eq_nsmul ℂ,norm_smul,Complex.norm_natCast]
  have heval := (cauchyPowerSeries f u r j).le_opNorm (fun _=>1)
  simp only [norm_one,Finset.prod_const_one,mul_one] at heval
  calc
    _ ≤ (j.factorial:ℝ)*‖cauchyPowerSeries f u r j‖ := by
      exact mul_le_mul_of_nonneg_left heval (Nat.cast_nonneg _)
    _ ≤ _ := by
      have hc:=norm_cauchyPowerSeries_le f u r j
      rw [abs_of_pos hr] at hc
      change ‖cauchyPowerSeries f u r j‖≤circleAverage (fun z=>‖f z‖) u r*r⁻¹^j at hc
      nlinarith [Nat.cast_nonneg (α:=ℝ) j.factorial]

/-- A quadratic holomorphic remainder has a sharp averaged Cauchy bound. -/
theorem quadraticRemainder_deriv_bound (f:ℂ→ℂ) (u r K:ℝ)
    (hr:0<r) (hru:r<u) (hf:DifferentiableOn ℂ f (closedBall (u:ℂ) r))
    (hbound:∀z∈sphere (u:ℂ) r, ‖f z‖≤K/‖z‖^2) (j:ℕ) :
    ‖iteratedDeriv j f (u:ℂ)‖ ≤ (j.factorial:ℝ)*K/(u^2-r^2)*r⁻¹^j := by
  have hu:0<u := hr.trans hru
  have hi : CircleIntegrable (fun z:ℂ=>1/‖z‖^2) (u:ℂ) r := by
    apply ContinuousOn.circleIntegrable hr.le
    apply continuousOn_const.div (continuous_norm.continuousOn.pow 2)
    intro z hz
    exact pow_ne_zero _ (norm_ne_zero_iff.mpr (disk_ne_zero hru hu (sphere_subset_closedBall hz)))
  have hfi := ((hf.continuousOn.mono sphere_subset_closedBall).norm).circleIntegrable hr.le
  have hm := circleAverage_mono hfi (hi.const_fun_smul (a:=K)) (fun z hz=>by
    rw [abs_of_pos hr] at hz
    simpa only [Pi.smul_apply,smul_eq_mul,div_eq_mul_inv,one_mul] using hbound z hz)
  change circleAverage (fun z=>‖f z‖) (u:ℂ) r ≤
    circleAverage (K • (fun z:ℂ=>1/‖z‖^2)) (u:ℂ) r at hm
  rw [circleAverage_smul,circleAverage_inv_norm_sq u r hr.le hru] at hm
  change circleAverage (fun z=>‖f z‖) (u:ℂ) r ≤ K*(1/(u^2-r^2)) at hm
  have hc:=iteratedDeriv_norm_le_circleAverage f (u:ℂ) r hr hf j
  calc
    _ ≤ (j.factorial:ℝ)*circleAverage (fun z=>‖f z‖) (u:ℂ) r*r⁻¹^j := hc
    _ ≤ (j.factorial:ℝ)*(K*(1/(u^2-r^2)))*r⁻¹^j := by gcongr
    _ = _ := by ring

end NeuralGeneralization.OnlineLowerTanh
