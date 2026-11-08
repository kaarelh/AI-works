import NeuralGeneralization.OnlineLowerHolomorphicContraction
import Mathlib.Analysis.Calculus.MeanValue

/-! # Quantitative holomorphic roots from a stationary equation

This is a reusable analytic lemma. Its derivative and residual hypotheses
are explicit and must be verified for the actual tanh stationary series.
-/
noncomputable section
open scoped Topology
open Complex Set Metric Filter
namespace NeuralGeneralization.OnlineLowerTanh

/-- A derivative uniformly close to a nonzero scalar turns Newton's
constant-derivative iteration into a half contraction. -/
theorem stationary_iteration_contraction
    (G G' : ℂ→ℂ) (a₀ g₀ : ℂ) (r : ℝ) (hg₀ : g₀≠0)
    (hd : ∀a∈closedBall a₀ r,HasDerivAt G (G' a) a)
    (hclose : ∀a∈closedBall a₀ r,‖G' a-g₀‖≤‖g₀‖/2) :
    ∀a∈closedBall a₀ r,∀b∈closedBall a₀ r,
      dist (a-G a/g₀) (b-G b/g₀)≤(1/2:ℝ)*dist a b := by
  let T : ℂ→ℂ := fun a=>a-G a/g₀
  have hT (a:ℂ) (ha:a∈closedBall a₀ r) : HasDerivAt T (1-G' a/g₀) a :=
    (hasDerivAt_id a).sub ((hd a ha).div_const g₀)
  have hbound (a:ℂ) (ha:a∈closedBall a₀ r) : ‖deriv T a‖≤(1/2:ℝ) := by
    rw [(hT a ha).deriv]
    have he : 1-G' a/g₀=-(G' a-g₀)/g₀ := by field_simp; ring
    rw [he,norm_div,norm_neg]
    exact (div_le_iff₀ (norm_pos_iff.mpr hg₀)).mpr (by linarith [hclose a ha])
  intro a ha b hb
  have hh := (convex_closedBall a₀ r).norm_image_sub_le_of_norm_deriv_le
    (fun c hc=>(hT c hc).differentiableAt) hbound hb ha
  simpa only [dist_eq_norm,T] using hh

/-- A holomorphic stationary root with an explicit residual-to-root error
bound, constructed by iteration on one fixed gain disk. -/
theorem holomorphic_stationary_branch
    (G G' : ℂ→ℂ→ℂ) {U:Set ℂ} (hU:IsOpen U)
    (a₀ g₀:ℂ) (r:ℝ) (hr:0≤r) (hg₀:g₀≠0)
    (hd:∀z∈U,∀a∈closedBall a₀ r,HasDerivAt (G z) (G' z a) a)
    (hclose:∀z∈U,∀a∈closedBall a₀ r,‖G' z a-g₀‖≤‖g₀‖/2)
    (hcenter:∀z∈U,‖G z a₀‖≤r*‖g₀‖/2)
    (hcomp:∀a:ℂ→ℂ,DifferentiableOn ℂ a U→MapsTo a U (closedBall a₀ r)→
      DifferentiableOn ℂ (fun z=>G z (a z)) U) :
    ∃b:ℂ→ℂ,DifferentiableOn ℂ b U ∧ ∀z∈U,
      b z∈closedBall a₀ r ∧ G z (b z)=0 ∧
      ∀a∈closedBall a₀ r,‖b z-a‖≤2*‖G z a‖/‖g₀‖ := by
  let T : ℂ→ℂ→ℂ := fun z a=>a-G z a/g₀
  have hcon (z:ℂ) (hz:z∈U) := stationary_iteration_contraction (G z) (G' z)
    a₀ g₀ r hg₀ (hd z hz) (hclose z hz)
  have hmap (z:ℂ) (hz:z∈U) : MapsTo (T z) (closedBall a₀ r) (closedBall a₀ r) := by
    intro a ha
    have hc := hcon z hz a ha a₀ (mem_closedBall_self hr)
    have hbase : dist (T z a₀) a₀≤r/2 := by
      rw [dist_eq_norm]
      change ‖a₀-G z a₀/g₀-a₀‖≤r/2
      rw [show a₀-G z a₀/g₀-a₀=-(G z a₀/g₀) by ring,norm_neg,norm_div]
      exact (div_le_iff₀ (norm_pos_iff.mpr hg₀)).mpr (by linarith [hcenter z hz])
    have ht := dist_triangle (T z a) (T z a₀) a₀
    change dist (T z a) a₀≤r
    change dist a a₀≤r at ha
    change dist (T z a) (T z a₀)≤(1/2:ℝ)*dist a a₀ at hc
    linarith
  have hTc (a:ℂ→ℂ) (ha:DifferentiableOn ℂ a U) (ham:MapsTo a U (closedBall a₀ r)) :
      DifferentiableOn ℂ (fun z=>T z (a z)) U := ha.sub ((hcomp a ha ham).div_const g₀)
  obtain ⟨b,hb,hpoint⟩ := holomorphic_contraction_branch T hU a₀ r hr hmap hcon hTc
  refine ⟨b,hb,?_⟩
  intro z hz
  obtain ⟨hm,hfix,hres⟩ := hpoint z hz
  have hzero : G z (b z)=0 := by
    have hdiv : G z (b z)/g₀=0 := by dsimp [T] at hfix; linear_combination -hfix
    exact (div_eq_zero_iff).mp hdiv |>.resolve_right hg₀
  refine ⟨hm,hzero,?_⟩
  intro a ha
  have hh := hres a ha
  change dist a (b z)≤2*dist a (a-G z a/g₀) at hh
  rw [dist_comm a (b z),dist_eq_norm,dist_eq_norm,
    show a-(a-G z a/g₀)=G z a/g₀ by ring,norm_div] at hh
  simpa only [mul_div_assoc] using hh

/-- Substituting a first-order approximate root gives a uniform quadratic
error for the actual analytic root; no differentiability at infinity is
required. -/
theorem stationary_branch_first_order
    (G : ℂ→ℂ→ℂ) (b:ℂ→ℂ) (a₀ a₁ g₀:ℂ) (r K:ℝ)
    (z:ℂ) (hg₀:g₀≠0)
    (hres:∀a∈closedBall a₀ r,‖b z-a‖≤2*‖G z a‖/‖g₀‖)
    (happrox:a₀+a₁/z∈closedBall a₀ r)
    (herror:‖G z (a₀+a₁/z)‖≤K/‖z‖^2) :
    ‖b z-(a₀+a₁/z)‖≤(2*K/‖g₀‖)/‖z‖^2 := by
  calc
    _ ≤ 2*‖G z (a₀+a₁/z)‖/‖g₀‖ := hres _ happrox
    _ ≤ 2*(K/‖z‖^2)/‖g₀‖ := by gcongr
    _ = _ := by ring

/-- Uniform function error on a surrounding disk controls derivative error
on the inner disk, with no derivative-series expansion. -/
theorem derivative_error_on_inner_disk
    (f g:ℂ→ℂ) (a₀:ℂ) (r K:ℝ) (hr:0<r)
    (hf:DifferentiableOn ℂ f (ball a₀ (3*r)))
    (hg:DifferentiableOn ℂ g (ball a₀ (3*r)))
    (hbound:∀a∈closedBall a₀ (2*r),‖f a-g a‖≤K)
    (a:ℂ) (ha:a∈closedBall a₀ r) :
    ‖deriv f a-deriv g a‖≤K/r := by
  have hsub : closedBall a r⊆ball a₀ (3*r) := by
    intro b hb
    have hh := dist_triangle b a a₀
    change dist b a≤r at hb
    change dist a a₀≤r at ha
    change dist b a₀<3*r
    linarith
  have hc := Complex.norm_cderiv_le (f:=fun a=>f a-g a) hr
    (M:=K) (z:=a) (fun b hb=>hbound b (by
      have h1 : dist b a=r := Metric.mem_sphere.mp hb
      have h2 : dist a a₀≤r := ha
      have h3 := dist_triangle b a a₀
      change dist b a₀≤2*r
      linarith))
  change ‖Complex.cderiv r (f-g) a‖≤K/r at hc
  rw [Complex.cderiv_eq_deriv isOpen_ball (hf.sub hg) hr hsub] at hc
  have hain : a∈ball a₀ (3*r) := hsub (mem_closedBall_self hr.le)
  have hfa := hf.differentiableAt (isOpen_ball.mem_nhds hain)
  have hga := hg.differentiableAt (isOpen_ball.mem_nhds hain)
  rw [(hfa.hasDerivAt.sub hga.hasDerivAt).deriv] at hc
  exact hc

/-- Continuity at a nondegenerate scalar derivative supplies one fixed
disk for all sufficiently large complex degrees. -/
theorem exists_stationary_gain_disk
    (g:ℂ→ℂ) (a₀:ℂ) (ρ:ℝ) (hρ:0<ρ) (hg:g a₀≠0)
    (hcont:ContinuousAt g a₀) :
    ∃r:ℝ,0<r ∧ 3*r<ρ ∧ ∀a∈closedBall a₀ (3*r),
      ‖g a-g a₀‖≤‖g a₀‖/8 := by
  have he:0<‖g a₀‖/8 := div_pos (norm_pos_iff.mpr hg) (by norm_num)
  obtain ⟨δ,hδ,hclose⟩ := Metric.continuousAt_iff.mp hcont (‖g a₀‖/8) he
  refine ⟨min ρ δ/4,by positivity,?_,?_⟩
  · have hm := min_le_left ρ δ
    linarith
  · intro a ha
    have hdist:dist a a₀<δ := by
      change dist a a₀≤3*(min ρ δ/4) at ha
      have hm:=min_le_right ρ δ
      linarith
    simpa only [dist_eq_norm] using (show dist (g a) (g a₀)<‖g a₀‖/8 from hclose hdist).le

end NeuralGeneralization.OnlineLowerTanh
