import NeuralGeneralization.BatchTwoImprovedResourceGrowth

/-! Cubic width growth of the actual compression resources. -/
namespace NeuralGeneralization.BatchTwoImprovedResources
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open ConcreteModel BatchTwoMerging

def FixedGrowth (p : ℕ→Input) (f : Input→ℕ) (a b : ℕ) : Prop :=
  WidthGrowth (fun C=>(f (p C):ℝ)) a b

namespace FixedGrowth
variable {p : ℕ→Input}

theorem const (n:ℕ) : FixedGrowth p (fun _=>n) 0 0 := WidthGrowth.const n

theorem mono {f : Input→ℕ} {a b a' b' : ℕ} (hf:FixedGrowth p f a b) (ha:a≤a') (hb:b≤b') :
    FixedGrowth p f a' b' := WidthGrowth.mono hf ha hb

theorem add {f g : Input→ℕ} {a b : ℕ} (hf:FixedGrowth p f a b) (hg:FixedGrowth p g a b) :
    FixedGrowth p (fun z=>f z+g z) a b := by
  exact (WidthGrowth.add hf hg).congr (fun _ _=>by push_cast;rfl)

theorem mul {f g : Input→ℕ} {a b a' b' : ℕ} (hf:FixedGrowth p f a b) (hg:FixedGrowth p g a' b') :
    FixedGrowth p (fun z=>f z*g z) (a+a') (b+b') := by
  exact (WidthGrowth.mul hf hg).congr (fun _ _=>by push_cast;rfl)

theorem const_mul {f : Input→ℕ} {a b:ℕ} (hf:FixedGrowth p f a b) (n:ℕ) :
    FixedGrowth p (fun z=>n*f z) a b := by simpa using (const n).mul hf

theorem pow {f : Input→ℕ} {a b:ℕ} (hf:FixedGrowth p f a b) (n:ℕ) :
    FixedGrowth p (fun z=>f z^n) (a*n) (b*n) := by
  exact (WidthGrowth.pow hf n).congr (fun _ _=>by push_cast;rfl)

theorem of_le {f g : Input→ℕ} {a b:ℕ} (hg:FixedGrowth p g a b)
    (hfg:∀C,1≤C→f (p C)≤g (p C)) : FixedGrowth p f a b := by
  obtain ⟨k,hk,hg⟩:=hg
  refine ⟨k,hk,?_⟩
  intro C hC
  rw [abs_of_nonneg (Nat.cast_nonneg _)]
  exact (by exact_mod_cast hfg C hC : (f (p C):ℝ)≤g (p C)).trans
    (by simpa only [abs_of_nonneg (Nat.cast_nonneg (g (p C)) : (0:ℝ)≤g (p C))] using hg C hC)

theorem congr {f g : Input→ℕ} {a b:ℕ} (hf:FixedGrowth p f a b)
    (he:∀z,f z=g z) : FixedGrowth p g a b := hf.of_le (fun C _=>(he (p C)).ge)

theorem sqrt {f : Input→ℕ} {a b:ℕ} (hf:FixedGrowth p f a b) :
    FixedGrowth p (fun z=>Nat.sqrt (f z)) a b := hf.of_le (fun _ _=>Nat.sqrt_le_self _)

end FixedGrowth

variable {p : ℕ→Input}
  (hd : FixedGrowth p RobustCompressionInput.dimension 0 0)
  (hL : FixedGrowth p RobustCompressionInput.depth 0 0)
  (hA : FixedGrowth p RobustCompressionInput.inverseFailure 0 0)
  (hK : FixedGrowth p RobustCompressionInput.energy 1 2)
  (hR : FixedGrowth p (fun z=>z.inverseRadius^2) 1 2)

include hR in
theorem radius_fixed_growth : FixedGrowth p RobustCompressionInput.inverseRadius 1 2 := by
  exact (hR.add ((FixedGrowth.const 1).mono (by omega) (by omega))).of_le (fun C _=>by
    exact (Nat.le_self_pow (by decide) _).trans (Nat.le_add_right _ _))

include hR in
theorem radiusPlusSq_fixed_growth : FixedGrowth p (fun z=>(z.inverseRadius+1)^2) 1 2 := by
  exact ((hR.const_mul 2).add ((FixedGrowth.const 2).mono (by omega) (by omega))).of_le (fun C _=>by
    have hh : ((p C).inverseRadius+1:ℝ)^2≤2*((p C).inverseRadius:ℝ)^2+2 := by
      nlinarith [sq_nonneg (((p C).inverseRadius:ℝ)-1)]
    exact_mod_cast hh)

include hL hA hR in
theorem inverseError_fixed_growth : FixedGrowth p inverseError 1 2 := by
  have hl:=hL.add (FixedGrowth.const 1)
  have ha:=hA.add (FixedGrowth.const 1)
  exact (((hl.const_mul 10000).mul ha).mul (radiusPlusSq_fixed_growth hR)).congr (fun _=>rfl)

include hL hA in
theorem inverseFailure_fixed_growth : FixedGrowth p inverseFailure 0 0 := by
  exact (((hL.add (FixedGrowth.const 1)).const_mul 100).mul (hA.add (FixedGrowth.const 1))).congr (fun _=>rfl)

include hL hA hK hR in
theorem rank_fixed_growth : FixedGrowth p rank 2 4 := by
  have hk:=hK.add ((FixedGrowth.const 1).mono (by omega) (by omega))
  have hh:=((hk.const_mul 2).mul (inverseFailure_fixed_growth hL hA)).mul (inverseError_fixed_growth hL hA hR)
  exact (hh.add ((FixedGrowth.const 1).mono (by omega) (by omega))).congr (fun _=>rfl)

include hd hL hA hK hR in
theorem logEnvelope_fixed_growth : FixedGrowth p logEnvelope 1 2 := by
  have hk:=hK.add ((FixedGrowth.const 1).mono (by omega) (by omega))
  have hH:=(inverseFailure_fixed_growth hL hA).mono (by omega : 0≤1) (by omega : 0≤2)
  have hE:=FixedGrowth.sqrt (inverseError_fixed_growth hL hA hR)
  exact (((((((FixedGrowth.const 1).mono (by omega) (by omega)).add
    (hd.mono (by omega) (by omega))).add (hL.mono (by omega) (by omega))).add hk).add hH).add
    (radius_fixed_growth hR) |>.add hE).congr (fun _=>rfl)

include hL hA hK in
theorem readoutMoment_fixed_growth : FixedGrowth p readoutMoment 1 2 := by
  have hk:=hK.add ((FixedGrowth.const 1).mono (by omega) (by omega))
  exact (((hk.const_mul 8).add ((FixedGrowth.const 2).mono (by omega) (by omega))).mul
    (inverseFailure_fixed_growth hL hA)).congr (fun _=>rfl)

include hd hL hA hK hR in
theorem bankSize_fixed_growth : FixedGrowth p bankSize 3 6 := by
  have hq:=rank_fixed_growth hL hA hK hR
  have he:=inverseError_fixed_growth hL hA hR
  have hh:=inverseFailure_fixed_growth hL hA
  have ht:=logEnvelope_fixed_growth hd hL hA hK hR
  have hk:=hK.mono (by omega : 1≤2) (by omega : 2≤4)
  have hfirst:=((hk.add hq).add ((FixedGrowth.const 1).mono (by omega) (by omega))).mul he
  have hsecond:=(hq.mul (hh.pow 2)).mul ht
  have hthird:=(((readoutMoment_fixed_growth hL hA hK).mul hh).mul
    (radiusPlusSq_fixed_growth hR)).mono (by omega : 2≤3) (by omega : 4≤6)
  exact ((((hfirst.add hsecond).add hthird).const_mul (2^256)).add
    ((FixedGrowth.const 1).mono (by omega) (by omega))).congr (fun _=>rfl)

include hd hL hA hK hR in
theorem widthBound_fixed_growth : FixedGrowth p widthBound 3 6 := by
  have hq:=(rank_fixed_growth hL hA hK hR).add ((FixedGrowth.const 1).mono (by omega) (by omega))
  have hs:=((((hL.add (FixedGrowth.const 1)).const_mul 2).mul (hd.add (FixedGrowth.const 1))).mul hq).mono
    (by omega : 2≤3) (by omega : 4≤6)
  exact (((bankSize_fixed_growth hd hL hA hK hR).add hs).add
    ((FixedGrowth.const 1).mono (by omega) (by omega))).congr (fun _=>rfl)


include hd hL hA hK hR in
theorem parameterCount_fixed_growth :
    FixedGrowth p (fun z=>robustParameterCount z.dimension (widthBound z) (z.depth-2)) 6 12 := by
  have hm:=widthBound_fixed_growth hd hL hA hK hR
  have hl:FixedGrowth p (fun z=>z.depth-2) 0 0 := hL.of_le (fun _ _=>Nat.sub_le _ _)
  exact ((((hm.mul (hd.add (FixedGrowth.const 1))).mono (by omega) (by omega)).add
    ((hl.mul hm).mul hm)).add (hm.mono (by omega) (by omega))).congr (fun _=>rfl)

include hd hL hA hK hR in
theorem smallSquared_fixed_growth : FixedGrowth p smallSquared 6 12 := by
  have hm:=widthBound_fixed_growth hd hL hA hK hR
  have hp:=(parameterCount_fixed_growth hd hL hA hK hR).const_mul 2
  exact ((((((hm.const_mul 4).mul hK).mono (by omega : 4≤6) (by omega : 8≤12)).add hp).const_mul 4).mul
    (hA.add (FixedGrowth.const 1))).congr (fun _=>rfl)

include hd hL hA hK hR in
theorem firstSquared_fixed_growth : FixedGrowth p firstSquared 2 4 := by
  have hh:=(hd.add (FixedGrowth.const 1)).const_mul 2 |>.mono (by omega : 0≤1) (by omega : 0≤2)
  exact ((((hK.const_mul 4).add hh).const_mul 4).mul (inverseError_fixed_growth hL hA hR)).congr (fun _=>rfl)

include hL hA hK hR in
theorem activeSquared_fixed_growth : FixedGrowth p activeSquared 3 6 := by
  have hk:=(hK.const_mul 8).mono (by omega : 1≤2) (by omega : 2≤4)
  have hq:=(rank_fixed_growth hL hA hK hR).const_mul 2
  exact (((hk.add hq).const_mul 16).mul (inverseError_fixed_growth hL hA hR)).congr (fun _=>rfl)

include hd hL hA hK hR in
theorem gaussianSquared_fixed_growth : FixedGrowth p gaussianSquared 4 8 := by
  exact (((bankSize_fixed_growth hd hL hA hK hR).const_mul 512).mul
    (inverseError_fixed_growth hL hA hR)).congr (fun _=>rfl)

include hL hA hK hR in
theorem readoutClip_fixed_growth : FixedGrowth p readoutClip 2 4 := by
  have hr:=(radius_fixed_growth hR).add ((FixedGrowth.const 1).mono (by omega) (by omega))
  exact (((readoutMoment_fixed_growth hL hA hK).const_mul 16).mul hr).congr (fun _=>rfl)

include hd hL hA hK hR in
theorem weightBound_fixed_growth : FixedGrowth p weightBound 6 12 := by
  have hs:=FixedGrowth.sqrt (smallSquared_fixed_growth hd hL hA hK hR)
  have hf:=(FixedGrowth.sqrt (firstSquared_fixed_growth hd hL hA hK hR)).mono (by omega : 2≤6) (by omega : 4≤12)
  have ha:=FixedGrowth.sqrt (activeSquared_fixed_growth hL hA hK hR)
  have hq:=(rank_fixed_growth hL hA hK hR).add ((FixedGrowth.const 1).mono (by omega) (by omega))
  have hag:=(((ha.add ((FixedGrowth.const 1).mono (by omega) (by omega))).const_mul 2).mul hq).mono
    (by omega : 5≤6) (by omega : 10≤12)
  have hg:=FixedGrowth.sqrt (gaussianSquared_fixed_growth hd hL hA hK hR)
  have hgg:=((hg.add ((FixedGrowth.const 1).mono (by omega) (by omega))).const_mul 2).mono
    (by omega : 4≤6) (by omega : 8≤12)
  have hr:=(readoutClip_fixed_growth hL hA hK hR).mono (by omega : 2≤6) (by omega : 4≤12)
  exact (((((hs.add hf).add hag).add hgg).add hr).add
    ((FixedGrowth.const 4).mono (by omega) (by omega))).congr (fun _=>rfl)

end
end NeuralGeneralization.BatchTwoImprovedResources
