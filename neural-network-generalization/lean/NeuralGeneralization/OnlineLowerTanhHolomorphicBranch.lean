import NeuralGeneralization.OnlineLowerHolomorphicStationaryBranch
import NeuralGeneralization.OnlineLowerTanhHolomorphicGBounds

/-! # The actual holomorphic optimized-gain branch

A fixed disk around the certified real limiting optimizer contains one
holomorphic stationary root for every sufficiently large complex degree in
the right half-plane. All contraction hypotheses are proved for the actual
tanh series.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped Topology BigOperators
open Complex Set Metric Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma complexStationary_gain_differentiableOn {z:ℂ} (hz:0≤z.re) :
    DifferentiableOn ℂ (complexStationary z) {a:ℂ|1<a.re} := by
  have hw (j:ℕ) : ‖(-1:ℂ)^j*prefactoredRatio j z‖≤(1:ℝ)*((j:ℝ)+1)^0 := by
    simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul,pow_zero] using
      prefactoredRatio_norm_le_one j hz
  have hF : DifferentiableOn ℂ (complexF z) {a:ℂ|1<a.re} := by
    apply DifferentiableOn.sub (differentiableOn_const 1)
    apply DifferentiableOn.const_mul
    exact weightedLogistic_differentiableOn _ 1 0 hw
  have hD : DifferentiableOn ℂ (complexFDerivative z) {a:ℂ|1<a.re} := by
    apply DifferentiableOn.const_mul
    exact weightedLogisticFirst_differentiableOn _ 1 0 hw
  exact (differentiableOn_id.mul hD).sub hF

def stationaryUniformBound : ℝ := stationaryCoefficientBound 3 2+
  stationaryCoefficientBound 7 4+stationaryRemainderBound

lemma stationaryUniformBound_nonneg : 0≤stationaryUniformBound := by
  unfold stationaryUniformBound
  positivity [stationaryCoefficientBound_nonneg (K:=3) (by norm_num) 2,
    stationaryCoefficientBound_nonneg (K:=7) (by norm_num) 4,stationaryRemainderBound_nonneg]

lemma complexStationary_zeroth_error {z a:ℂ} (hz:0≤z.re) (hn:1≤‖z‖)
    (ha:1≤a.re) (haN:‖a‖≤2) :
    ‖complexStationary z a-complexStationary0 a‖≤stationaryUniformBound/‖z‖ := by
  have hp : 0<‖z‖ := lt_of_lt_of_le (by norm_num) hn
  have he : complexStationary z a-complexStationary0 a=
    (complexStationary z a-(complexStationary0 a+complexStationary1 a/z))+complexStationary1 a/z := by ring
  rw [he]
  apply (norm_add_le _ _).trans
  rw [norm_div]
  have hK : 0≤stationaryCoefficientBound 7 4+stationaryRemainderBound :=
    add_nonneg (stationaryCoefficientBound_nonneg (by norm_num) _) stationaryRemainderBound_nonneg
  calc
    _ ≤ (stationaryCoefficientBound 7 4+stationaryRemainderBound)/‖z‖^2+
      stationaryCoefficientBound 3 2/‖z‖ := add_le_add (complexStationary_first_expansion hz hn ha haN)
        (div_le_div_of_nonneg_right (complexStationary1_bound ha haN) hp.le)
    _ ≤ (stationaryCoefficientBound 7 4+stationaryRemainderBound)/‖z‖+
      stationaryCoefficientBound 3 2/‖z‖ := by
      apply add_le_add _ le_rfl
      exact div_le_div_of_nonneg_left hK hp (by nlinarith)
    _ = _ := by unfold stationaryUniformBound; ring

lemma limitingGain_disk_bounds {a:ℂ} (ha:dist a (limitingGain:ℂ)<(1/8:ℝ)) :
    1<a.re ∧ ‖a‖<2 := by
  obtain ⟨hl,hu⟩:=limitingGain_mem
  have hre : |a.re-limitingGain|≤‖a-(limitingGain:ℂ)‖ := by
    simpa using Complex.abs_re_le_norm (a-(limitingGain:ℂ))
  have hn := norm_add_le (a-(limitingGain:ℂ)) (limitingGain:ℂ)
  simp only [sub_add_cancel,Complex.norm_real,Real.norm_eq_abs,abs_of_pos limitingGain_pos] at hn
  rw [dist_eq_norm] at ha
  constructor
  · have hlow := neg_abs_le (a.re-limitingGain)
    linarith
  · linarith

/-- Actual stationary roots, fixed gain disk, and a residual-to-root bound. -/
theorem exists_actual_stationary_branch :
    ∃r T:ℝ,0<r ∧ 3*r<(1/8:ℝ) ∧ 1≤T ∧ ∃b:ℂ→ℂ,
      DifferentiableOn ℂ b {z:ℂ|0<z.re ∧ T<‖z‖} ∧
      ∀z:ℂ,0<z.re→T<‖z‖→
        b z∈closedBall (limitingGain:ℂ) r ∧ complexStationary z (b z)=0 ∧
        ∀a∈closedBall (limitingGain:ℂ) r,
          ‖b z-a‖≤2*‖complexStationary z a‖/‖deriv complexStationary0 (limitingGain:ℂ)‖ := by
  let a₀:ℂ := limitingGain
  let g₀:ℂ := deriv complexStationary0 a₀
  have hg : g₀≠0 := complexStationary0_limitingGain_deriv_ne
  have hopen : IsOpen {a:ℂ|1<a.re} := isOpen_lt continuous_const Complex.continuous_re
  have ha₀ : a₀∈{a:ℂ|1<a.re} := by
    change 1<limitingGain
    linarith [limitingGain_mem.1]
  have hcont : ContinuousAt (deriv complexStationary0) a₀ :=
    (complexStationary0_differentiableOn.deriv hopen).continuousOn.continuousAt (hopen.mem_nhds ha₀)
  obtain ⟨r,hr,hrsmall,hderiv⟩ := exists_stationary_gain_disk
    (deriv complexStationary0) a₀ (1/8) (by norm_num) hg hcont
  let T:ℝ := max 1 (4*stationaryUniformBound/(r*‖g₀‖))
  have hT : 1≤T := le_max_left _ _
  have hR (a:ℂ) (ha:a∈closedBall a₀ (3*r)) : 1<a.re ∧ ‖a‖<2 := by
    apply limitingGain_disk_bounds
    exact lt_of_le_of_lt ha hrsmall
  have hbound (z:ℂ) (hz:0<z.re) (hzT:T<‖z‖) :
      stationaryUniformBound/‖z‖≤r*‖g₀‖/4 := by
    have hzp:0<‖z‖ := lt_of_lt_of_le (by norm_num) (hT.trans hzT.le)
    have ht:4*stationaryUniformBound/(r*‖g₀‖)≤‖z‖ := (le_max_right _ _).trans hzT.le
    have ht' := (div_le_iff₀ (mul_pos hr (norm_pos_iff.mpr hg))).mp ht
    apply (div_le_iff₀ hzp).mpr
    nlinarith
  let U:Set ℂ := {z:ℂ|0<z.re ∧ T<‖z‖}
  have hU:IsOpen U := (isOpen_lt continuous_const Complex.continuous_re).inter
    (isOpen_lt continuous_const continuous_norm)
  have hGa (z:ℂ) (hz:z∈U) : DifferentiableOn ℂ (complexStationary z) (ball a₀ (3*r)) :=
    (complexStationary_gain_differentiableOn hz.1.le).mono (fun a ha=>(hR a (Metric.ball_subset_closedBall ha)).1)
  have hG0 : DifferentiableOn ℂ complexStationary0 (ball a₀ (3*r)) :=
    complexStationary0_differentiableOn.mono (fun a ha=>(hR a (Metric.ball_subset_closedBall ha)).1)
  have hd (z:ℂ) (hz:z∈U) (a:ℂ) (ha:a∈closedBall a₀ r) :
      HasDerivAt (complexStationary z) (deriv (complexStationary z) a) a := by
    exact ((hGa z hz).differentiableAt (isOpen_ball.mem_nhds (by
      change dist a a₀<3*r
      have hh:dist a a₀≤r:=ha
      linarith))).hasDerivAt
  have hclose (z:ℂ) (hz:z∈U) (a:ℂ) (ha:a∈closedBall a₀ r) :
      ‖deriv (complexStationary z) a-g₀‖≤‖g₀‖/2 := by
    have he := derivative_error_on_inner_disk (complexStationary z) complexStationary0 a₀ r
      (stationaryUniformBound/‖z‖) hr (hGa z hz) hG0 (fun c hc=>
        complexStationary_zeroth_error hz.1.le (hT.trans hz.2.le)
          (hR c (by exact (closedBall_subset_closedBall (by linarith)) hc)).1.le
          (hR c (by exact (closedBall_subset_closedBall (by linarith)) hc)).2.le) a ha
    have hb := hbound z hz.1 hz.2
    have he' : ‖deriv (complexStationary z) a-deriv complexStationary0 a‖≤‖g₀‖/4 := by
      exact he.trans ((div_le_iff₀ hr).mpr (by nlinarith))
    have h0 := hderiv a (by exact (closedBall_subset_closedBall (by linarith)) ha)
    have htri := norm_add_le (deriv (complexStationary z) a-deriv complexStationary0 a)
      (deriv complexStationary0 a-g₀)
    rw [sub_add_sub_cancel] at htri
    change ‖deriv complexStationary0 a-g₀‖≤‖g₀‖/8 at h0
    linarith [norm_nonneg g₀]
  have hcenter (z:ℂ) (hz:z∈U) : ‖complexStationary z a₀‖≤r*‖g₀‖/2 := by
    have he:=complexStationary_zeroth_error hz.1.le (hT.trans hz.2.le)
      (hR a₀ (mem_closedBall_self (by positivity))).1.le
      (hR a₀ (mem_closedBall_self (by positivity))).2.le
    rw [complexStationary0_limitingGain,sub_zero] at he
    have hb:=hbound z hz.1 hz.2
    nlinarith [norm_nonneg g₀]
  obtain ⟨b,hb,hbp⟩ := holomorphic_stationary_branch complexStationary
    (fun z=>deriv (complexStationary z)) hU a₀ g₀ r hr.le hg hd hclose hcenter (by
      intro a ha ham
      exact complexStationary_comp_differentiableOn a hU (fun z hz=>hz.1) ha
        (fun z hz=>(hR _ (by exact (closedBall_subset_closedBall (by linarith)) (ham hz))).1.le))
  exact ⟨r,T,hr,hrsmall,hT,b,hb,fun z hz hzT=>hbp z ⟨hz,hzT⟩⟩

end NeuralGeneralization.OnlineLowerTanh
