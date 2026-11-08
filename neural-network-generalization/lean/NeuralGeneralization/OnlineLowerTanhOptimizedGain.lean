import NeuralGeneralization.OnlineLowerTanhHolomorphicBranch
import NeuralGeneralization.OnlineLowerAnalyticTaylorJet
import NeuralGeneralization.OnlineLowerTanhComplexScalarJet
import Mathlib.Analysis.Normed.Field.Lemmas

noncomputable section
open scoped Topology BigOperators
open Complex Set Metric Filter Asymptotics
namespace NeuralGeneralization.OnlineLowerTanh

/-- Complex degrees tend uniformly to infinity within the right half-plane. -/
def rightDegreeInfinity : Filter ℂ := Bornology.cobounded ℂ ⊓ 𝓟 {z:ℂ|0<z.re}

lemma rightDegree_norm_tendsto : Tendsto (norm:ℂ→ℝ) rightDegreeInfinity atTop :=
  tendsto_norm_cobounded_atTop.mono_left inf_le_left
lemma rightDegree_inv_tendsto : Tendsto (fun z:ℂ=>z⁻¹) rightDegreeInfinity (𝓝 0) :=
  tendsto_inv₀_cobounded.mono_left inf_le_left
lemma rightDegree_re_eventually : ∀ᶠz in rightDegreeInfinity,0<z.re :=
  (eventually_principal.mpr (fun z hz=>hz)).filter_mono inf_le_right
lemma rightDegree_large (T:ℝ) : ∀ᶠz in rightDegreeInfinity,T<‖z‖ :=
  rightDegree_norm_tendsto.eventually_gt_atTop T

structure ActualGainBranch where
  radius : ℝ
  threshold : ℝ
  gain : ℂ→ℂ
  radius_pos : 0<radius
  radius_small : 3*radius<(1/8:ℝ)
  threshold_ge : 1≤threshold
  analytic : DifferentiableOn ℂ gain {z:ℂ|0<z.re ∧ threshold<‖z‖}
  root : ∀z:ℂ,0<z.re→threshold<‖z‖→
    gain z∈closedBall (limitingGain:ℂ) radius ∧ complexStationary z (gain z)=0 ∧
    ∀a∈closedBall (limitingGain:ℂ) radius,
      ‖gain z-a‖≤2*‖complexStationary z a‖/‖deriv complexStationary0 (limitingGain:ℂ)‖

lemma actualGainBranch_exists : Nonempty ActualGainBranch := by
  obtain ⟨r,T,hr,hrs,hT,b,hb,hp⟩:=exists_actual_stationary_branch
  exact ⟨⟨r,T,b,hr,hrs,hT,hb,hp⟩⟩

def actualGainBranch : ActualGainBranch := Classical.choice actualGainBranch_exists

lemma rightDegree_uniform_bigO (f:ℂ→ℂ) (n:ℕ) (K:ℝ)
    (hb:∀ᶠz in rightDegreeInfinity,‖f z‖≤K/‖z‖^n) :
    f=O[rightDegreeInfinity] (fun z:ℂ=>z⁻¹^n) := by
  apply isBigO_iff.mpr
  refine ⟨K,?_⟩
  filter_upwards [hb] with z hz
  simpa only [norm_pow,norm_inv,inv_pow,div_eq_mul_inv] using hz

lemma actualGainBranch_displacement_bigO (b:ActualGainBranch) :
    (fun z=>b.gain z-(limitingGain:ℂ))=O[rightDegreeInfinity] (fun z:ℂ=>z⁻¹) := by
  have hg:0<‖deriv complexStationary0 (limitingGain:ℂ)‖ :=
    norm_pos_iff.mpr complexStationary0_limitingGain_deriv_ne
  apply (rightDegree_uniform_bigO _ 1
    (2*stationaryUniformBound/‖deriv complexStationary0 (limitingGain:ℂ)‖) ?_).congr_right
    (fun z=>pow_one _)
  filter_upwards [rightDegree_re_eventually,rightDegree_large b.threshold] with z hz hzT
  have hr:= (b.root z hz hzT).2.2 _ (mem_closedBall_self b.radius_pos.le)
  have ha:1≤(limitingGain:ℂ).re := by simp only [ofReal_re]; linarith [limitingGain_mem.1]
  have haN:‖(limitingGain:ℂ)‖≤2 := by
    simp only [Complex.norm_real,Real.norm_eq_abs,abs_of_pos limitingGain_pos]
    linarith [limitingGain_mem.2]
  have he:=complexStationary_zeroth_error hz.le (b.threshold_ge.trans hzT.le) ha haN
  rw [complexStationary0_limitingGain,sub_zero] at he
  calc
    _ ≤ 2*‖complexStationary z (limitingGain:ℂ)‖/‖deriv complexStationary0 (limitingGain:ℂ)‖ := hr
    _ ≤ 2*(stationaryUniformBound/‖z‖)/‖deriv complexStationary0 (limitingGain:ℂ)‖ := by gcongr
    _ = _ := by ring

lemma actualGainBranch_tendsto (b:ActualGainBranch) :
    Tendsto b.gain rightDegreeInfinity (𝓝 (limitingGain:ℂ)) := by
  have hh: Tendsto (fun z=>b.gain z-(limitingGain:ℂ)) rightDegreeInfinity (𝓝 0) :=
    (actualGainBranch_displacement_bigO b).trans_tendsto rightDegree_inv_tendsto
  convert hh.add_const (limitingGain:ℂ) using 1 <;> simp

def optimizedGainFirstCoefficient : ℂ :=
  -complexStationary1 (limitingGain:ℂ)/deriv complexStationary0 (limitingGain:ℂ)

/-- First-order optimizer expansion. The remaining analyticity input is a
local property of the explicitly defined coefficient series. -/
lemma actualGainBranch_first_order (b:ActualGainBranch) :
    (fun z=>b.gain z-(limitingGain:ℂ)-optimizedGainFirstCoefficient*z⁻¹)
      =O[rightDegreeInfinity] (fun z:ℂ=>z⁻¹^2) := by
  let a₀:ℂ:=limitingGain
  let a₁:ℂ:=optimizedGainFirstCoefficient
  let g₀:ℂ:=deriv complexStationary0 a₀
  let h:ℂ→ℂ:=fun z=>z⁻¹
  let δ:ℂ→ℂ:=fun z=>a₁*h z
  have hh:Tendsto h rightDegreeInfinity (𝓝 0):=rightDegree_inv_tendsto
  have hδ:Tendsto δ rightDegreeInfinity (𝓝 0):=by simpa [δ] using hh.const_mul a₁
  have hδO:δ=O[rightDegreeInfinity] h := (isBigO_refl h _).const_mul_left a₁
  have ha0:1<a₀.re:=by change 1<limitingGain; linarith [limitingGain_mem.1]
  have hG₁:AnalyticAt ℂ complexStationary1 a₀ := complexStationary1_differentiableOn.analyticAt
    ((isOpen_lt continuous_const Complex.continuous_re).mem_nhds ha0)
  have hG₀:AnalyticAt ℂ complexStationary0 a₀ := complexStationary0_differentiableOn.analyticAt
    ((isOpen_lt continuous_const Complex.continuous_re).mem_nhds ha0)
  have h0: (fun z=>complexStationary0 (a₀+δ z)-g₀*δ z)=O[rightDegreeInfinity] (fun z=>h z^2) := by
    have ht := (analytic_taylor_bigO complexStationary0 a₀ hG₀ 2).comp_tendsto hδ
    have hs : (fun z=>complexStationary0 (a₀+δ z)-g₀*δ z)=O[rightDegreeInfinity] (fun z=>δ z^2) := by
      simpa [Function.comp_def,Finset.sum_range_succ,iteratedDeriv_zero,iteratedDeriv_one,a₀,g₀,
        complexStationary0_limitingGain] using ht
    exact hs.trans (hδO.pow 2)
  have h1: (fun z=>complexStationary1 (a₀+δ z)-complexStationary1 a₀)=O[rightDegreeInfinity] h := by
    have ht := (analytic_taylor_bigO complexStationary1 a₀ hG₁ 1).comp_tendsto hδ
    have hs : (fun z=>complexStationary1 (a₀+δ z)-complexStationary1 a₀)=O[rightDegreeInfinity] δ := by
      simpa [Function.comp_def,Finset.sum_range_succ,iteratedDeriv_zero] using ht
    exact hs.trans hδO
  have hnear : ∀ᶠz in rightDegreeInfinity,a₀+δ z∈ball a₀ b.radius := by
    have ht:Tendsto (fun z=>a₀+δ z) rightDegreeInfinity (𝓝 a₀):=by
      simpa using hδ.const_add a₀
    exact ht.eventually (ball_mem_nhds a₀ b.radius_pos)
  have haBounds : ∀ᶠz in rightDegreeInfinity,1<(a₀+δ z).re ∧ ‖a₀+δ z‖<2 := by
    filter_upwards [hnear] with z hz
    apply limitingGain_disk_bounds
    have hh:dist (a₀+δ z) a₀<b.radius:=hz
    linarith [b.radius_small,b.radius_pos]
  have h2 : (fun z=>complexStationary z (a₀+δ z)-
      (complexStationary0 (a₀+δ z)+complexStationary1 (a₀+δ z)*h z))
        =O[rightDegreeInfinity] (fun z=>h z^2) := by
    apply rightDegree_uniform_bigO _ 2 (stationaryCoefficientBound 7 4+stationaryRemainderBound)
    filter_upwards [rightDegree_re_eventually,rightDegree_large 1,haBounds] with z hz hzN ha
    simpa [h,div_eq_mul_inv] using complexStationary_first_expansion hz.le hzN.le ha.1.le ha.2.le
  have happrox : (fun z=>complexStationary z (a₀+δ z))=O[rightDegreeInfinity] (fun z=>h z^2) := by
    have hm : (fun z=>(complexStationary1 (a₀+δ z)-complexStationary1 a₀)*h z)
        =O[rightDegreeInfinity] (fun z=>h z^2) := by
      simpa only [pow_two] using h1.mul (isBigO_refl h _)
    have hs:=h2.add (h0.add hm)
    apply hs.congr_left
    intro z
    dsimp [δ,a₁,g₀,optimizedGainFirstCoefficient]
    field_simp [complexStationary0_limitingGain_deriv_ne]
    <;> ring
  obtain ⟨K,hK⟩:=isBigO_iff.mp happrox
  apply isBigO_iff.mpr
  refine ⟨2*K/‖g₀‖,?_⟩
  filter_upwards [rightDegree_re_eventually,rightDegree_large b.threshold,hnear,hK] with z hz hzT hzn hKz
  have hr := (b.root z hz hzT).2.2 _ (Metric.ball_subset_closedBall hzn)
  have he : b.gain z-(limitingGain:ℂ)-optimizedGainFirstCoefficient*z⁻¹=b.gain z-(a₀+δ z):=by
    dsimp [a₀,δ,a₁,h]; ring
  rw [he]
  calc
    _ ≤ 2*‖complexStationary z (a₀+δ z)‖/‖g₀‖ := hr
    _ ≤ 2*(K*‖h z^2‖)/‖g₀‖ := by gcongr
    _ = _ := by ring

end NeuralGeneralization.OnlineLowerTanh
