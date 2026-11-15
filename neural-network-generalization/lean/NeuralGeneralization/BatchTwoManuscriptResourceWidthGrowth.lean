import NeuralGeneralization.BatchTwoManuscriptResources
import NeuralGeneralization.BatchTwoMergingSharpGrowth

/-! Width growth of the literal real-valued compression allocation. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoMerging.WidthGrowth

theorem nonnegative_le {f g : ℕ→ℝ} {a b : ℕ} (hg : WidthGrowth g a b)
    (hf : ∀C,1≤C→0≤f C) (hfg : ∀C,1≤C→f C≤g C) : WidthGrowth f a b := by
  obtain ⟨k,hk,hg⟩ := hg
  exact ⟨k,hk,fun C hC=>by rw [abs_of_nonneg (hf C hC)]; exact (hfg C hC).trans ((le_abs_self _).trans (hg C hC))⟩

theorem divide_ge_one {f g : ℕ→ℝ} {a b : ℕ} (hf : WidthGrowth f a b)
    (hg : ∀C,1≤C→1≤g C) : WidthGrowth (fun C=>f C/g C) a b := by
  obtain ⟨k,hk,hf⟩ := hf
  refine ⟨k,hk,?_⟩
  intro C hC
  rw [abs_div,abs_of_nonneg ((by norm_num : (0:ℝ)≤1).trans (hg C hC))]
  exact (div_le_self (abs_nonneg _) (hg C hC)).trans (hf C hC)

end NeuralGeneralization.BatchTwoMerging.WidthGrowth
namespace NeuralGeneralization.BatchTwoManuscriptResources
open BatchTwoMerging
variable {p : ℕ→Input} {d L : ℕ}
  (hd : ∀C,(p C).dimension=d) (hL : ∀C,(p C).depth=L)
  (hF : WidthGrowth (fun C=>(p C).failure⁻¹) 0 0)
  (hK : WidthGrowth (fun C=>(p C).energy) 1 2)
  (hR : WidthGrowth (fun C=>(p C).radius⁻¹^2) 1 2)

include hL hF hR in
theorem localError_inverse_width_growth : WidthGrowth (fun C=>(localError (p C))⁻¹) 1 2 := by
  exact ((hF.const_mul (1000*(L:ℝ))).mul hR).congr (by
    intro C _
    unfold localError
    rw [hL]
    field_simp)

include hL hF in
theorem localFailure_inverse_width_growth : WidthGrowth (fun C=>(localFailure (p C))⁻¹) 0 0 := by
  exact (hF.const_mul (100*(L:ℝ))).congr (by intro C _; unfold localFailure; rw [hL]; field_simp)

include hL hF hK hR in
theorem rank_width_growth : WidthGrowth (fun C=>(rank (p C):ℝ)) 2 4 := by
  have hh := ((hK.const_mul 2).mul (localError_inverse_width_growth hL hF hR)).mul
    (localFailure_inverse_width_growth hL hF)
  exact hh.ceil.congr (by intro C _; congr 1; unfold rank; congr 1; field_simp)

include hd hL hF hK hR in
theorem messageCost_width_growth : WidthGrowth (fun C=>messageCost (p C)) 2 4 := by
  exact (((rank_width_growth hL hF hK hR).const_mul ((d:ℝ)+1) |>.add
    ((WidthGrowth.const 2).mono (by omega) (by omega))).const_mul (Real.log 2)).congr (by
      intro C _; unfold messageCost; rw [hd]; ring)

include hL hF hK hR in
theorem activeEnergy_width_growth : WidthGrowth (fun C=>activeEnergy (p C)) 2 4 := by
  exact ((hK.const_mul 8).mono (by omega) (by omega)).add ((rank_width_growth hL hF hK hR).const_mul 2)

include hL hF hK in
theorem readoutEnergy_width_growth : WidthGrowth (fun C=>readoutEnergy (p C)) 1 2 := by
  exact (((hK.const_mul 4).add ((WidthGrowth.const (2*Real.log 2)).mono (by omega) (by omega))).mul
    (localFailure_inverse_width_growth hL hF)).congr (by intro C _; unfold readoutEnergy; field_simp)

include hd hL hF hK hR in
theorem bankSize_width_growth : WidthGrowth (fun C=>(bankSize (p C):ℝ)) 3 6 := by
  have hq := rank_width_growth hL hF hK hR
  have hqp := hq.add ((WidthGrowth.const 1).mono (by omega) (by omega))
  have he := localError_inverse_width_growth hL hF hR
  have hη := localFailure_inverse_width_growth hL hF
  have hfirst := ((((activeEnergy_width_growth hL hF hK hR).add hq).add
    ((WidthGrowth.const 1).mono (by omega) (by omega))).mul he).const_mul 10000
  have harg : WidthGrowth (fun C=>4*((rank (p C):ℝ)+1)/localFailure (p C)) 2 4 :=
    ((hqp.const_mul 4).mul hη).congr (by intro C _; field_simp)
  have hlog := harg.log (by
    intro C _
    apply (le_div_iff₀ (localFailure_pos (p C))).mpr
    have hh := localFailure_le_one (p C)
    nlinarith [Nat.cast_nonneg (α:=ℝ) (rank (p C))])
  have hsecond := ((hqp.mul hlog).const_mul 64).mono (by omega : 2≤3) (by omega : 5≤6)
  have harg2 : WidthGrowth (fun C=>2/localFailure (p C)) 0 0 :=
    (hη.const_mul 2).congr (by intro C _; field_simp)
  have hlog2 := harg2.log (by
    intro C _
    apply (le_div_iff₀ (localFailure_pos (p C))).mpr
    linarith [localFailure_le_one (p C)])
  have hfactor := ((WidthGrowth.const ((d:ℝ)*Real.log 2)).mono (by omega) (by omega) |>.add hlog2).add
    ((WidthGrowth.const 1).mono (by omega) (by omega))
  have hthird := ((((readoutEnergy_width_growth hL hF hK).mul hR).mul hfactor).const_mul 512).mono
    (by omega : 2≤3) (by omega : 5≤6)
  exact ((hfirst.max_growth hsecond).max_growth hthird).ceil.congr (by
    intro C _
    unfold bankSize sampleCost
    rw [hd]
    congr 2 <;> field_simp <;> ring)

include hd hL hF hK hR in
theorem widthBound_width_growth : WidthGrowth (fun C=>(widthBound (p C):ℝ)) 3 6 := by
  have hm := bankSize_width_growth hd hL hF hK hR
  have hother := ((messageCost_width_growth hd hL hF hK hR).const_mul (L:ℝ)).divide_ge_one
    (fun C _=>(p C).energy_ge_one)
  have ho := hother.ceil.mono (by omega : 2≤3) (by omega : 4≤6)
  exact ((hm.max_growth ho).max_growth ((WidthGrowth.const 1).mono (by omega) (by omega))).congr (by
    intro C _
    unfold widthBound
    rw [hL]
    simp only [Nat.cast_max,Nat.cast_one])

include hd hL hF hK hR in
theorem parameterCount_width_growth :
    WidthGrowth (fun C=>(parameterCount (p C).dimension (widthBound (p C)) (p C).depth:ℝ)) 6 12 := by
  have hm := widthBound_width_growth hd hL hF hK hR
  have hf := (hm.const_mul ((d:ℝ)+1)).mono (by omega : 3≤6) (by omega : 6≤12)
  have hi := (hm.pow 2).const_mul ((L-2:ℕ):ℝ)
  exact ((hf.add hi).add (hm.mono (by omega) (by omega))).congr (by
    intro C _
    unfold parameterCount
    rw [hd,hL]
    push_cast
    ring)

include hd hL hF hK hR in
theorem smallBound_width_growth : WidthGrowth (fun C=>smallBound (p C)) 6 12 := by
  have hm := widthBound_width_growth hd hL hF hK hR
  have hp := parameterCount_width_growth hd hL hF hK hR
  have hh := (((hm.mul hK).const_mul 4).mono (by omega : 4≤6) (by omega : 8≤12)).add
    (hp.const_mul (2*Real.log 2))
  exact ((hh.mul hF).const_mul 4).sqrt.congr (by intro C _; unfold smallBound; congr 1; field_simp <;> ring)

include hd hL hF hK hR in
theorem firstBound_width_growth : WidthGrowth (fun C=>firstBound (p C)) 2 4 := by
  have hnum := (hK.const_mul 4).add ((WidthGrowth.const (2*((d:ℝ)+1)*Real.log 2)).mono (by omega) (by omega))
  exact ((hnum.mul (localError_inverse_width_growth hL hF hR)).const_mul 4).sqrt.congr (by
    intro C _; unfold firstBound; rw [hd]; congr 1; field_simp <;> ring)

include hL hF hK hR in
theorem activeBound_width_growth : WidthGrowth (fun C=>activeBound (p C)) 3 6 := by
  exact (((activeEnergy_width_growth hL hF hK hR).mul
    (localError_inverse_width_growth hL hF hR)).const_mul 4).sqrt.congr (by
      intro C _; unfold activeBound; congr 1; field_simp)

include hd hL hF hK hR in
theorem gaussianBound_width_growth : WidthGrowth (fun C=>gaussianBound (p C)) 0 1 := by
  have harg : WidthGrowth (fun C=>6*(bankSize (p C):ℝ)/localError (p C)) 4 8 :=
    (((bankSize_width_growth hd hL hF hK hR).mul (localError_inverse_width_growth hL hF hR)).const_mul 6).congr
      (by intro C _; field_simp)
  have hlog := harg.log (by
    intro C _
    apply (le_div_iff₀ (localError_pos (p C))).mpr
    have hfirst := bankSize_first_allocation (p C)
    have he := localError_pos (p C)
    have hh := (div_le_iff₀ he).mp hfirst
    have hK := energy_pos (p C)
    have hE : localError (p C)≤1 := by
      unfold localError
      apply (div_le_one (by have := depth_pos (p C); positivity)).mpr
      have hr := (p C).radius_le_one
      have hr0 := (p C).radius_pos
      have hf := (p C).failure_le_eighth
      have hf0 := (p C).failure_pos
      have hd2 : (2:ℝ)≤(p C).depth := by exact_mod_cast (p C).depth_ge_two
      nlinarith [mul_le_mul_of_nonneg_left (show (p C).radius^2≤1 by nlinarith) hf0.le]
    have hm : (1:ℝ)≤bankSize (p C) := by exact_mod_cast bankSize_pos (p C)
    linarith)
  exact ((WidthGrowth.const 2).mono (by omega) (by omega) |>.max_growth (hlog.sqrt.const_mul 2))

include hd hL hF hK hR in
theorem weightBound_width_growth : WidthGrowth (fun C=>weightBound (p C)) 6 12 := by
  have hsmall := smallBound_width_growth hd hL hF hK hR
  have hfirst := (firstBound_width_growth hd hL hF hK hR).mono (by omega : 2≤6) (by omega : 4≤12)
  have hqp := (rank_width_growth hL hF hK hR).add ((WidthGrowth.const 1).mono (by omega) (by omega))
  have hact := (((activeBound_width_growth hL hF hK hR).mul hqp.sqrt).const_mul 2).divide_ge_one (g:=fun C=>(bankSize (p C):ℝ))
    (fun C _=>by exact_mod_cast bankSize_pos (p C))
  have hgauss := ((gaussianBound_width_growth hd hL hF hK hR).const_mul (Real.sqrt 2)).divide_ge_one (g:=fun C=>Real.sqrt (bankSize (p C):ℝ))
    (fun C _=>by
      have hh : (1:ℝ)≤bankSize (p C) := by exact_mod_cast bankSize_pos (p C)
      simpa using Real.sqrt_le_sqrt hh)
  have hmid := (hact.mono (by omega : 5≤6) (by omega : 10≤12)).add
    (hgauss.mono (by omega : 0≤6) (by omega : 1≤12))
  have hread := (readoutEnergy_width_growth hL hF hK).sqrt.divide_ge_one (g:=fun C=>(bankSize (p C):ℝ))
    (fun C _=>by exact_mod_cast bankSize_pos (p C))
  have hone := (WidthGrowth.const 1).mono (by omega : 0≤6) (by omega : 0≤12)
  exact ((hsmall.max_growth (((hfirst.max_growth hmid).max_growth
    (hread.mono (by omega) (by omega))).max_growth hone)).max_growth hone).congr (by
      intro C _
      unfold weightBound largeBound
      simp only [mul_assoc])

include hd hL hF hK hR in
theorem gridEntropy_width_growth : WidthGrowth (fun C=>gridEntropy (p C)) 6 13 := by
  have hm := widthBound_width_growth hd hL hF hK hR
  have hB := weightBound_width_growth hd hL hF hK hR
  have hBplus := hB.add ((WidthGrowth.const 1).mono (by omega) (by omega))
  have hbase := (hm.mul hBplus).const_mul 2
  have hpow := hbase.pow L
  have hr := (hR.add ((WidthGrowth.const 1).mono (by omega) (by omega))).nonnegative_le
    (fun C _=>inv_nonneg.mpr (p C).radius_pos.le) (fun C _=>by nlinarith [sq_nonneg ((p C).radius⁻¹-1)])
  have hproduct := (((hB.mul hpow).mul hr).const_mul (32*((d:ℝ)+L+1)))
  have harg := ((WidthGrowth.const 3).mono (show 0≤6+9*L+1 by omega) (show 0≤12+18*L+2 by omega)).add hproduct
  have harg' : WidthGrowth (fun C=>3+32*weightBound (p C)*((p C).dimension+(p C).depth+1)*
      (2*(widthBound (p C):ℝ)*(weightBound (p C)+1))^(p C).depth/(p C).radius) (6+9*L+1) (12+18*L+2) :=
    harg.congr (by intro C _; rw [hd,hL]; field_simp <;> ring)
  have hlog := harg'.log (by
    intro C _
    have hB0 : 0≤weightBound (p C) := (by norm_num : (0:ℝ)≤1).trans (le_max_right _ _)
    have hr0 := (p C).radius_pos
    have hm0 := Nat.cast_nonneg (α:=ℝ) (widthBound (p C))
    have hd0 := Nat.cast_nonneg (α:=ℝ) (p C).dimension
    have hl0 := Nat.cast_nonneg (α:=ℝ) (p C).depth
    have hterm : 0≤32*weightBound (p C)*((p C).dimension+(p C).depth+1)*
        (2*(widthBound (p C):ℝ)*(weightBound (p C)+1))^(p C).depth/(p C).radius := by positivity
    linarith)
  exact (parameterCount_width_growth hd hL hF hK hR).mul hlog

end NeuralGeneralization.BatchTwoManuscriptResources
