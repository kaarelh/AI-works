import Mathlib.Analysis.SpecialFunctions.Gaussian.FourierTransform
import Mathlib.Tactic

noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- Exact affine change of variables on an arbitrary measurable real set. -/
theorem setIntegral_affine_preimage (f:ℝ→ℝ) (S:Set ℝ) (hS:MeasurableSet S)
    (c s:ℝ) (hs:0<s) :
    (∫x:ℝ in S,f x)=s*∫y:ℝ in ((fun y=>c+s*y) ⁻¹' S),f (c+s*y) := by
  have hh:=Measure.integral_comp_mul_left (fun x:ℝ=>S.indicator f (c+x)) s
  rw [integral_add_left_eq_self] at hh
  rw [abs_of_pos (inv_pos.mpr hs),smul_eq_mul,integral_indicator hS] at hh
  have hpre:MeasurableSet ((fun y:ℝ=>c+s*y) ⁻¹' S) := hS.preimage (by fun_prop)
  have he : (∫y:ℝ,S.indicator f (c+s*y))=
      ∫y:ℝ in ((fun y=>c+s*y) ⁻¹' S),f (c+s*y) := by
    rw [←integral_indicator hpre]
    apply integral_congr_ae
    filter_upwards [] with y
    exact (Set.indicator_comp_right (fun y:ℝ=>c+s*y)).symm
  rw [he] at hh
  calc
    _ = s*(s⁻¹*(∫x:ℝ in S,f x)) := by rw [←mul_assoc,mul_inv_cancel₀ hs.ne',one_mul]
    _ = _ := by rw [←hh]

/-- The affine preimage of a truncated lattice cell, with endpoints preserved. -/
theorem setIntegral_truncated_cell (f:ℝ→ℝ) (p h ρ s:ℝ) (hs:0<s) :
    (∫x:ℝ in Ioc (p-h) (p+h) ∩ Ici ρ,f x)=
      s*∫y:ℝ in {y| -h<s*y ∧ s*y≤h ∧ ρ≤p+s*y},f (p+s*y) := by
  rw [setIntegral_affine_preimage f _ (measurableSet_Ioc.inter measurableSet_Ici) p s hs]
  have he : ((fun y:ℝ=>p+s*y) ⁻¹' (Ioc (p-h) (p+h) ∩ Ici ρ))=
      {y:ℝ| -h<s*y ∧ s*y≤h ∧ ρ≤p+s*y} := by
    ext y
    simp only [Set.mem_preimage,Set.mem_inter_iff,Set.mem_Ioc,Set.mem_Ici,Set.mem_setOf_eq]
    constructor
    · rintro ⟨⟨h1,h2⟩,h3⟩
      exact ⟨by linarith,by linarith,h3⟩
    · rintro ⟨h1,h2,h3⟩
      exact ⟨⟨by linarith,by linarith⟩,h3⟩
  rw [he]

/-- A single cell endpoint has zero Lebesgue measure, so a closed symmetric
window can be used in the rescaled integral. -/
theorem setIntegral_truncated_cell_closed (f:ℝ→ℝ) (p h ρ s:ℝ) (hs:0<s) :
    (∫x:ℝ in Ioc (p-h) (p+h) ∩ Ici ρ,f x)=
      s*∫y:ℝ, {y:ℝ| |y*s|≤h ∧ ρ≤p+s*y}.indicator
        (fun y=>f (p+s*y)) y := by
  have he : (Ioc (p-h) (p+h) ∩ Ici ρ : Set ℝ) =ᵐ[volume]
      (Icc (p-h) (p+h) ∩ Ici ρ : Set ℝ) := by
    filter_upwards [Ioc_ae_eq_Icc (μ:=volume) (a:=p-h) (b:=p+h)] with x hx
    exact congrArg (fun P:Prop=>P ∧ ρ≤x) hx
  rw [setIntegral_congr_set he,
    setIntegral_affine_preimage f _ (measurableSet_Icc.inter measurableSet_Ici) p s hs]
  have hset : ((fun y:ℝ=>p+s*y) ⁻¹' (Icc (p-h) (p+h) ∩ Ici ρ))=
      {y:ℝ| |y*s|≤h ∧ ρ≤p+s*y} := by
    ext y
    simp only [Set.mem_preimage,Set.mem_inter_iff,Set.mem_Icc,Set.mem_Ici,
      Set.mem_setOf_eq,abs_le]
    constructor
    · rintro ⟨⟨h1,h2⟩,h3⟩
      exact ⟨⟨by nlinarith,by nlinarith⟩,h3⟩
    · rintro ⟨⟨h1,h2⟩,h3⟩
      exact ⟨⟨by nlinarith,by nlinarith⟩,h3⟩
  rw [hset,integral_indicator]
  exact (measurableSet_le (show Measurable (fun y:ℝ=>|y*s|) by fun_prop) measurable_const).inter
    (measurableSet_le measurable_const (show Measurable (fun y:ℝ=>p+s*y) by fun_prop))

/-- Finite adjacent cells exactly telescope, including a common truncation. -/
theorem sum_integral_truncated_cells (f:ℝ→ℝ) (hf:IntegrableOn f (Ioi 0))
    (h ρ:ℝ) (hh:0<h) (L:ℕ) :
    (∑l∈Finset.range L, ∫x:ℝ in Ioc ((l:ℝ)*h) (((l:ℝ)+1)*h) ∩ Ici ρ,f x)=
      ∫x:ℝ in Ioc 0 ((L:ℝ)*h),(Ici ρ).indicator f x := by
  have hfi:IntegrableOn ((Ici ρ).indicator f) (Ioi 0) :=
    hf.indicator measurableSet_Ici
  have hmono (l:ℕ) : (l:ℝ)*h≤((l:ℝ)+1)*h := by nlinarith
  have hint (l:ℕ) : IntervalIntegrable ((Ici ρ).indicator f) volume
      ((l:ℝ)*h) (((l:ℝ)+1)*h) := by
    apply (intervalIntegrable_iff_integrableOn_Ioc_of_le (hmono l)).mpr
    apply hfi.mono_set
    intro x hx
    have hl:0≤(l:ℝ)*h := mul_nonneg (Nat.cast_nonneg _) hh.le
    exact lt_of_le_of_lt hl hx.1
  have he:=intervalIntegral.sum_integral_adjacent_intervals
    (a:=fun l:ℕ=>(l:ℝ)*h) (n:=L) (fun l _=>by simpa only [Nat.cast_add,Nat.cast_one] using hint l)
  simp only [Nat.cast_zero,zero_mul] at he
  rw [intervalIntegral.integral_of_le (mul_nonneg (Nat.cast_nonneg _) hh.le)] at he
  rw [←he]
  apply Finset.sum_congr rfl
  intro l hl
  rw [intervalIntegral.integral_of_le (by push_cast; exact hmono l),
    setIntegral_indicator measurableSet_Ici]
  push_cast
  rfl

end NeuralGeneralization.OnlineLowerTanh
