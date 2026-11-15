import NeuralGeneralization.OnlineLowerTanhInverseLaplaceInversion

/-! # The generic positive inverse-Laplace lemma from the tanh paper -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped Topology FourierTransform
open Filter Set MeasureTheory Complex
namespace NeuralGeneralization.OnlineLowerTanh

/-- The literal generic analytic lemma: a holomorphic quadratic remainder
has a continuous real inverse-Laplace correction, of exponential growth,
and a positive constant leading inverse kernel stays positive near zero.
The premise describes a complex holomorphic extension of the real cost. -/
theorem positive_inverse_laplace_kernel
    (w E:ℂ→ℂ) (a K A B C:ℝ)
    (H:HalfPlaneQuadraticRemainder E a K) (hC:0<C)
    (hexpansion:∀z:ℂ,a<z.re→w z=(A:ℂ)*z+B+(C:ℂ)/z+E z)
    (hreal:∀n:ℝ,a<n→(w (n:ℂ)).im=0) :
    ∃ρ:ℝ→ℝ,Continuous ρ ∧
      (∃M r:ℝ,0<M ∧ 0<r ∧ ∀t≥0,|ρ t|≤M*Real.exp (r*t)) ∧
      (∃δ:ℝ,0<δ ∧ ∀t:ℝ,0<t→t<δ→C/2≤ρ t) ∧
      (∃n₀:ℝ,0<n₀ ∧ ∀n:ℝ,n₀<n→
        IntegrableOn (fun t:ℝ=>Real.exp (-n*t)*ρ t) (Ioi 0) ∧
        w (n:ℂ)=((A*n+B+∫t:ℝ in Ioi 0,Real.exp (-n*t)*ρ t):ℝ)) := by
  let c:ℝ:=max (a+1) 1
  have hc:a<c := lt_of_lt_of_le (by linarith) (le_max_left _ _)
  have hc0:0<c := lt_of_lt_of_le zero_lt_one (le_max_right _ _)
  let ρ:ℝ→ℝ:=fun t=>C+(H.bromwich c t).re
  have hK:=H.constant_nonneg
  have hρcont:Continuous ρ := continuous_const.add
    (Complex.continuous_re.comp (H.continuous_bromwich hc hc0))
  refine ⟨ρ,hρcont,?_,?_,?_⟩
  · refine ⟨C+K/(2*c),c,by positivity,hc0,?_⟩
    intro t ht
    have he : 1≤Real.exp (c*t) := Real.one_le_exp_iff.mpr (mul_nonneg hc0.le ht)
    calc
      |ρ t| ≤ C+|(H.bromwich c t).re| := by
        simpa only [ρ,abs_of_pos hC] using abs_add_le C (H.bromwich c t).re
      _ ≤ C+K*Real.exp (c*t)/(2*c) := by
        have hh := (Complex.abs_re_le_norm _).trans (H.norm_bromwich_le hc hc0 t)
        linarith
      _ ≤ (C+K/(2*c))*Real.exp (c*t) := by
        have hh := mul_le_mul_of_nonneg_left he hC.le
        nlinarith [show K*Real.exp (c*t)/(2*c)=K/(2*c)*Real.exp (c*t) by ring]
  · let δ:ℝ:=min ((|a|+1)⁻¹) (C/(Real.exp 1*K+1))
    have hδ:0<δ := by dsimp [δ]; positivity
    refine ⟨δ,hδ,?_⟩
    intro t ht htd
    have ht1:t<(|a|+1)⁻¹ := htd.trans_le (min_le_left _ _)
    have ht2:t<C/(Real.exp 1*K+1) := htd.trans_le (min_le_right _ _)
    have hat:a<t⁻¹ := by
      have hh := (lt_inv_comm₀ ht (by positivity : 0 < |a|+1)).mp ht1
      exact (lt_of_le_of_lt (le_abs_self a) (by linarith)).trans hh
    have hkt:Real.exp 1*K*t<C := by
      have hh := (lt_div_iff₀ (show 0<Real.exp 1*K+1 by positivity)).mp ht2
      nlinarith
    have hb := H.bromwich_small_time_bound hc hc0 ht hat
    have hr := (Complex.abs_re_le_norm (H.bromwich c t)).trans hb
    have hr' := (abs_le.mp hr).1
    change C/2≤C+(H.bromwich c t).re
    linarith
  · refine ⟨c,hc0,?_⟩
    intro n hn
    have hn0:=hc0.trans hn
    have hni:=H.inverse_laplace_integrable hc hc0 hn
    have hre:IntegrableOn (fun t:ℝ=>Real.exp (-n*t)*(H.bromwich c t).re) (Ioi 0) := by
      have h:=hni.re
      apply h.congr
      filter_upwards with t
      simp [←Complex.ofReal_mul,←Complex.ofReal_neg,Complex.mul_re,Complex.exp_ofReal_re]
    have hconst:IntegrableOn (fun t:ℝ=>Real.exp (-n*t)*C) (Ioi 0) :=
      (integrableOn_exp_mul_Ioi (neg_neg_of_pos hn0) 0).mul_const C
    have hi:IntegrableOn (fun t:ℝ=>Real.exp (-n*t)*ρ t) (Ioi 0) := by
      convert! hconst.add hre using 1
      funext t
      dsimp [ρ]
      ring
    have hir:(∫t:ℝ in Ioi 0,Real.exp (-n*t)*(H.bromwich c t).re)=(E (n:ℂ)).re := by
      have h:=integral_re hni
      change (∫t:ℝ in Ioi 0,(Complex.exp (-n*t)*H.bromwich c t).re)=
        (∫t:ℝ in Ioi 0,Complex.exp (-n*t)*H.bromwich c t).re at h
      rw [H.inverse_laplace_identity hc hc0 hn] at h
      convert! h using 1
      congr 1
      funext t
      simp [←Complex.ofReal_mul,←Complex.ofReal_neg,Complex.mul_re,Complex.exp_ofReal_re]
    have hint:(∫t:ℝ in Ioi 0,Real.exp (-n*t)*ρ t)=C/n+(E (n:ℂ)).re := by
      calc
        _ = (∫t:ℝ in Ioi 0,Real.exp (-n*t)*C)+
            (∫t:ℝ in Ioi 0,Real.exp (-n*t)*(H.bromwich c t).re) := by
          rw [←integral_add hconst hre]
          congr 1
          funext t
          dsimp [ρ]
          ring
        _ = _ := by
          rw [hir,integral_mul_const,integral_exp_mul_Ioi (neg_neg_of_pos hn0) 0]
          simp
          ring
    refine ⟨hi,?_⟩
    apply Complex.ext
    · rw [hint,hexpansion (n:ℂ) (by simpa using hc.trans hn)]
      simp
      ring
    · simpa using hreal n (hc.trans hn)

end NeuralGeneralization.OnlineLowerTanh
