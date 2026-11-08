import NeuralGeneralization.OnlineLowerAffineIntegral

noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- Truncating the positive half-line to finitely many adjacent lattice
cells loses only the lower and upper tails of any integrable majorant. -/
theorem integral_sub_truncated_cells_abs_le (f g:ℝ→ℝ)
    (hf:IntegrableOn f (Ioi 0)) (hg:IntegrableOn g (Ioi 0))
    (hdom:∀x:ℝ,0<x→|f x|≤g x)
    (h ρ:ℝ) (hh:0<h) (hρ:0<ρ) (L:ℕ) (hH:ρ≤(L:ℝ)*h) :
    |(∫x:ℝ in Ioi 0,f x)-
      ∑l∈Finset.range L,∫x:ℝ in Ioc ((l:ℝ)*h) (((l:ℝ)+1)*h) ∩ Ici ρ,f x|≤
      (∫x:ℝ in Ioc 0 ρ,g x)+(∫x:ℝ in Ioi ((L:ℝ)*h),g x) := by
  let H:ℝ:=(L:ℝ)*h
  have hH0:0≤H:=by exact hρ.le.trans hH
  have hfr:IntegrableOn f (Ioi ρ):=hf.mono_set (Ioi_subset_Ioi hρ.le)
  have hfH:IntegrableOn f (Ioi H):=hf.mono_set (Ioi_subset_Ioi hH0)
  have hsum : (∑l∈Finset.range L,∫x:ℝ in Ioc ((l:ℝ)*h) (((l:ℝ)+1)*h) ∩ Ici ρ,f x)=
      ∫x:ℝ in Ioc ρ H,f x := by
    rw [sum_integral_truncated_cells f hf h ρ hh L,setIntegral_indicator measurableSet_Ici]
    have hae:(Ioc 0 H ∩ Ici ρ:Set ℝ)=ᵐ[volume] Ioc ρ H:=by
      filter_upwards [Ioi_ae_eq_Ici (μ:=volume) (a:=ρ)] with x hx
      apply propext
      change (x∈Ioc 0 H ∧ x∈Ici ρ)↔x∈Ioc ρ H
      change (x∈Ioi ρ)=(x∈Ici ρ) at hx
      rw [←hx]
      simp only [mem_Ioc,mem_Ioi]
      constructor
      · rintro ⟨⟨h0,h1⟩,h2⟩; exact ⟨h2,h1⟩
      · rintro ⟨h1,h2⟩; exact ⟨⟨hρ.trans h1,h2⟩,h1⟩
    exact setIntegral_congr_set hae
  rw [hsum]
  have hlow:=intervalIntegral.integral_interval_add_Ioi hf hfr
  rw [intervalIntegral.integral_of_le hρ.le] at hlow
  have hhigh:=intervalIntegral.integral_interval_add_Ioi hfr hfH
  rw [intervalIntegral.integral_of_le hH] at hhigh
  have he : (∫x:ℝ in Ioi 0,f x)-(∫x:ℝ in Ioc ρ H,f x)=
      (∫x:ℝ in Ioc 0 ρ,f x)+(∫x:ℝ in Ioi H,f x):=by linarith
  rw [he]
  apply (abs_add_le _ _).trans
  apply add_le_add
  · have hb:=norm_integral_le_of_norm_le (f:=f) (hg.mono_set (s:=Ioc 0 ρ) Ioc_subset_Ioi_self) ?_
    · simpa only [Real.norm_eq_abs] using hb
    · filter_upwards [ae_restrict_mem measurableSet_Ioc] with x hx
      simpa only [Real.norm_eq_abs] using hdom x hx.1
  · have hb:=norm_integral_le_of_norm_le (f:=f) (hg.mono_set (s:=Ioi H) (Ioi_subset_Ioi hH0)) ?_
    · simpa only [Real.norm_eq_abs] using hb
    · filter_upwards [ae_restrict_mem measurableSet_Ioi] with x hx
      simpa only [Real.norm_eq_abs] using hdom x (lt_of_le_of_lt hH0 hx)

end NeuralGeneralization.OnlineLowerTanh
