import NeuralGeneralization.OnlineLowerTanhCodeVanishing
import Mathlib.Analysis.Normed.Module.FiniteDimension

/-! Cubic vanishing of every competing support with three inactive coordinates. -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu ConcreteModel

/-- A coefficient with three coordinates outside the reference support
vanishes cubically at every affine vector supported on that support. -/
theorem affine_walsh_cubic_offsupport {d : ℕ} (A B : Finset (Fin d))
    (hthree : 3 ≤ (B\A).card) (z₀ z : Fin (d+1)→ℝ)
    (hz₀ : ∀i,i∉A → z₀ i.succ=0) :
    |walshCoefficients (fun x=>Real.tanh (z 0+incomingLinear (fun i=>z i.succ) x)) B| ≤
      27*‖z-z₀‖^3 := by
  obtain ⟨J,hJ,hcard⟩ := Finset.exists_subset_card_eq hthree
  have hJB : J⊆B := fun i hi=>(Finset.mem_sdiff.mp (hJ hi)).1
  have hcoord (i : Fin d) (hi : i∈J) : |z i.succ|≤‖z-z₀‖ := by
    have hz := hz₀ i (Finset.mem_sdiff.mp (hJ hi)).2
    simpa only [Pi.sub_apply,hz,sub_zero,Real.norm_eq_abs] using norm_le_pi_norm (z-z₀) i.succ
  have h := tanh_walshCoefficient_partial_uniform J B hJB (fun i=>z i.succ) (z 0)
    ‖z-z₀‖ (norm_nonneg _) hcoord
  rw [hcard] at h
  norm_num at h
  nlinarith only [h]

/-- The entire finite weighted competing mass has one cubic bound. -/
theorem affine_weighted_walsh_cubic_offsupport {d : ℕ}
    (C : Finset (Finset (Fin d))) (A : Finset (Fin d))
    (weight : Finset (Fin d)→ℝ) (hw : ∀B∈C,0≤weight B)
    (hthree : ∀B∈C.erase A,3≤(B\A).card)
    (z₀ z : Fin (d+1)→ℝ) (hz₀ : ∀i,i∉A → z₀ i.succ=0) :
    (∑B∈C.erase A,weight B*|walshCoefficients
      (fun x=>Real.tanh (z 0+incomingLinear (fun i=>z i.succ) x)) B|) ≤
      (27*∑B∈C.erase A,weight B)*‖z-z₀‖^3 := by
  have h := Finset.sum_le_sum (s:=C.erase A) (fun B hB=>mul_le_mul_of_nonneg_left
    (affine_walsh_cubic_offsupport A B (hthree B hB) z₀ z hz₀)
    (hw B (Finset.mem_erase.mp hB).2))
  calc
    _ ≤ ∑B∈C.erase A,weight B*(27*‖z-z₀‖^3) := h
    _ = _ := by rw [←Finset.sum_mul];ring

/-- A positive quadratic drop absorbs an arbitrary cubic remainder, without
requiring the remainder to be differentiable near the base point. -/
theorem strict_local_maximum_of_quadratic_cubic {E : Type*}
    [NormedAddCommGroup E] (z₀ : E) (f rem radius : E→ℝ)
    (w c M r : ℝ) (hw : 0<w) (hc : 0<c) (hM : 0≤M) (hr : 0<r)
    (hgap : ∀ᶠ z in nhds z₀,f z≤f z₀-c*‖z-z₀‖^2)
    (hradius : ∀ᶠ z in nhds z₀,r≤radius z)
    (hrem : ∀z,rem z≤M*‖z-z₀‖^3) :
    ∀ᶠ z in nhds z₀,z≠z₀ → w*f z+rem z/radius z<w*f z₀ := by
  let δ := w*c*r/(M+1)
  have hδ : 0<δ := by dsimp [δ];positivity
  filter_upwards [hgap,hradius,Metric.ball_mem_nhds z₀ hδ] with z hz hrad hzball hne
  have ht : 0<‖z-z₀‖ := norm_pos_iff.mpr (sub_ne_zero.mpr hne)
  have htδ : ‖z-z₀‖<δ := by simpa only [Metric.mem_ball,dist_eq_norm] using hzball
  have hsmall : M*‖z-z₀‖<w*c*r := by
    have hh := (lt_div_iff₀ (show 0<M+1 by linarith)).mp htδ
    nlinarith only [hh,ht]
  have hradpos : 0<radius z := hr.trans_le hrad
  have hsmall' : M*‖z-z₀‖<w*c*radius z := hsmall.trans_le
    (mul_le_mul_of_nonneg_left hrad (mul_pos hw hc).le)
  have hrem_lt : rem z/radius z<w*c*‖z-z₀‖^2 := by
    apply (div_lt_iff₀ hradpos).mpr
    have hm := mul_lt_mul_of_pos_right hsmall' (sq_pos_of_pos ht)
    have he : M*‖z-z₀‖^3 < (w*c*‖z-z₀‖^2)*radius z := by
      nlinarith only [hm]
    exact (hrem z).trans_lt he
  have hg := mul_le_mul_of_nonneg_left hz hw.le
  nlinarith only [hg,hrem_lt]

end NeuralGeneralization.OnlineLowerTanh
