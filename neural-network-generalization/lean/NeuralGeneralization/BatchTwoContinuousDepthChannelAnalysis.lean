import NeuralGeneralization.BatchTwoContinuousDepthStepNetwork
import NeuralGeneralization.TanhScalarJet
import Mathlib.Analysis.Convex.Deriv

/-! Sharp scalar estimates for the paper's depth-varying channel. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open Set Filter
open scoped Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoNeuralConverse TanhDifferential

theorem hasDerivAt_artanh {x : ℝ} (hx : x ∈ Ioo (-1 : ℝ) 1) :
    HasDerivAt Real.artanh (1/(1-x^2)) x := by
  have hp : 1+x ≠ 0 := by linarith [hx.1]
  have hm : 1-x ≠ 0 := by linarith [hx.2]
  have hd := ((((hasDerivAt_const x (1 : ℝ)).add (hasDerivAt_id x)).log hp).sub
    (((hasDerivAt_const x (1 : ℝ)).sub (hasDerivAt_id x)).log hm)).const_mul (1/2 : ℝ)
  have he : Real.artanh =ᶠ[𝓝 x] fun y => (1/2 : ℝ)*(Real.log (1+y)-Real.log (1-y)) := by
    filter_upwards [Ioo_mem_nhds hx.1 hx.2] with y hy
    rw [Real.artanh_eq_half_log ⟨hy.1.le,hy.2.le⟩,
      Real.log_div (by linarith [hy.1] : 1+y≠0) (by linarith [hy.2] : 1-y≠0)]
  have hz : 1-x^2 ≠ 0 := by
    have h := mul_pos (show 0 < 1+x by linarith [hx.1]) (show 0 < 1-x by linarith [hx.2])
    nlinarith
  convert! hd.congr_of_eventuallyEq he using 1 <;> norm_num <;> field_simp [hz] <;> ring

theorem tanh_concave_nonnegative : ConcaveOn ℝ (Ici (0 : ℝ)) Real.tanh := by
  apply AntitoneOn.concaveOn_of_deriv (convex_Ici _) tanh_continuous.continuousOn
    (fun x _ => (hasDerivAt_tanh_first x).differentiableAt.differentiableWithinAt)
  intro x hx y hy hxy
  rw [(hasDerivAt_tanh_first x).deriv,(hasDerivAt_tanh_first y).deriv]
  unfold tanhFirst
  have hx0 : 0 ≤ x := (interior_subset hx)
  have htx : 0 ≤ Real.tanh x := by simpa only [Real.tanh_zero] using tanh_monotone hx0
  have ht := tanh_monotone hxy
  nlinarith

theorem tanh_chord {a t : ℝ} (ha : 0 ≤ a) (ht : t ∈ Icc (0 : ℝ) 1) :
    t*Real.tanh a ≤ Real.tanh (a*t) := by
  have h := tanh_concave_nonnegative.2 (show (0 : ℝ) ∈ Ici 0 by simp)
    (show a ∈ Ici 0 from ha) (show 0 ≤ 1-t by linarith [ht.2]) ht.1 (by ring : (1-t)+t=1)
  simpa only [smul_eq_mul,Real.tanh_zero,mul_zero,add_zero,zero_add,mul_comm t a] using h

/-- The exact elementary artanh estimate used in the channel budget. -/
theorem artanh_le_cubic {x : ℝ} (hx : x ∈ Icc (0 : ℝ) (1/2)) :
    Real.artanh x ≤ x+(4/9 : ℝ)*x^3 := by
  let F : ℝ → ℝ := fun t => t+(4/9 : ℝ)*t^3-Real.artanh t
  have hd (t : ℝ) (ht : t ∈ Icc (0 : ℝ) (1/2)) :
      HasDerivAt F (1+(4/3 : ℝ)*t^2-1/(1-t^2)) t := by
    have hh := ((hasDerivAt_id t).add (((hasDerivAt_id t).pow 3).const_mul (4/9 : ℝ))).sub
      (hasDerivAt_artanh (by constructor <;> linarith [ht.1,ht.2]))
    convert! hh using 1 <;> simp only [id_eq] <;> ring
  have hmono : MonotoneOn F (Icc (0 : ℝ) (1/2)) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc _ _) (fun t ht => (hd t ht).continuousAt.continuousWithinAt)
      (fun t ht => (hd t (interior_subset ht)).differentiableAt.differentiableWithinAt)
    intro t ht
    have ht' : t ∈ Icc (0 : ℝ) (1/2) := interior_subset ht
    rw [(hd t ht').deriv]
    have hsq : t^2 ≤ 1/4 := by nlinarith [ht'.1,ht'.2]
    have hp : 0 < 1-t^2 := by linarith
    have hprod : 0 ≤ t^2*(1-4*t^2) := mul_nonneg (sq_nonneg t) (by linarith)
    have hb : 1/(1-t^2) ≤ 1+(4/3 : ℝ)*t^2 := by
      apply (div_le_iff₀ hp).mpr
      nlinarith
    linarith
  have h := hmono (by constructor <;> norm_num) hx hx.1
  simpa only [F,Real.artanh_zero,zero_pow (by omega : 3≠0),mul_zero,add_zero,sub_zero,
    sub_nonneg] using h

theorem artanh_sq_bound {x : ℝ} (hx : x ∈ Icc (0 : ℝ) (1/2)) :
    (Real.artanh x)^2 ≤ x^2+x^4 := by
  have h := artanh_le_cubic hx
  have ha := Real.artanh_nonneg hx.1
  have hsq := pow_le_pow_left₀ ha h 2
  have hx2 : x^2 ≤ 1/4 := by nlinarith [hx.1,hx.2]
  have hp : 0 ≤ x^4*(1-4*x^2) := mul_nonneg (pow_nonneg hx.1 _) (by linarith)
  nlinarith

end NeuralGeneralization.BatchTwoContinuousDepthPaper
