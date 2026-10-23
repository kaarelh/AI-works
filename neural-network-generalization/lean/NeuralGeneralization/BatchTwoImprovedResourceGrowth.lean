import NeuralGeneralization.BatchTwoImprovedResources
import NeuralGeneralization.BatchTwoMergingSharpGrowth

/-! Sharp global polynomial degrees of the actual resource formulas. -/
namespace NeuralGeneralization.BatchTwoImprovedResources
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open ConcreteModel

structure ResourceHypotheses (AK AR AA : ℝ) (p : Input) (S : ℝ) : Prop where
  size : 2≤S
  dimension : (p.dimension:ℝ)≤S
  depth : (p.depth:ℝ)≤S
  energy : (p.energy:ℝ)≤AK*S^3
  radius : (p.inverseRadius:ℝ)≤AR*S^3
  failure : (p.inverseFailure:ℝ)≤AA*S

def GlobalGrowth (AK AR AA : ℝ) (f : Input → ℕ) (k : ℕ) : Prop :=
  ∃a:ℝ,0<a ∧ ∀ p S,ResourceHypotheses AK AR AA p S → (f p:ℝ)≤a*S^k

namespace GlobalGrowth
variable {AK AR AA : ℝ}

theorem const (n : ℕ) : GlobalGrowth AK AR AA (fun _ => n) 0 := by
  refine ⟨n+1,by positivity,?_⟩
  intro p S hp
  simp

theorem dimension : GlobalGrowth AK AR AA RobustCompressionInput.dimension 1 :=
  ⟨1,by norm_num,fun _ _ hp => by simpa using hp.dimension⟩

theorem depth : GlobalGrowth AK AR AA RobustCompressionInput.depth 1 :=
  ⟨1,by norm_num,fun _ _ hp => by simpa using hp.depth⟩

theorem energy (hA : 0<AK) : GlobalGrowth AK AR AA RobustCompressionInput.energy 3 :=
  ⟨AK,hA,fun _ _ hp => hp.energy⟩

theorem radius (hA : 0<AR) : GlobalGrowth AK AR AA RobustCompressionInput.inverseRadius 3 :=
  ⟨AR,hA,fun _ _ hp => hp.radius⟩

theorem failure (hA : 0<AA) : GlobalGrowth AK AR AA RobustCompressionInput.inverseFailure 1 :=
  ⟨AA,hA,fun _ _ hp => by simpa using hp.failure⟩

theorem mono {f : Input→ℕ} {k l : ℕ} (hf : GlobalGrowth AK AR AA f k) (hkl : k≤l) :
    GlobalGrowth AK AR AA f l := by
  obtain ⟨a,ha,hf⟩ := hf
  refine ⟨a,ha,?_⟩
  intro p S hp
  exact (hf p S hp).trans (mul_le_mul_of_nonneg_left (pow_le_pow_right₀ (by linarith [hp.size]) hkl) ha.le)

theorem add {f g : Input→ℕ} {k : ℕ} (hf : GlobalGrowth AK AR AA f k) (hg : GlobalGrowth AK AR AA g k) :
    GlobalGrowth AK AR AA (fun p => f p+g p) k := by
  obtain ⟨a,ha,hf⟩ := hf
  obtain ⟨b,hb,hg⟩ := hg
  refine ⟨a+b,by positivity,?_⟩
  intro p S hp
  push_cast
  nlinarith only [hf p S hp,hg p S hp]

theorem mul {f g : Input→ℕ} {k l : ℕ} (hf : GlobalGrowth AK AR AA f k) (hg : GlobalGrowth AK AR AA g l) :
    GlobalGrowth AK AR AA (fun p => f p*g p) (k+l) := by
  obtain ⟨a,ha,hf⟩ := hf
  obtain ⟨b,hb,hg⟩ := hg
  refine ⟨a*b,by positivity,?_⟩
  intro p S hp
  have hS : 0≤S := by linarith [hp.size]
  have hh := mul_le_mul (hf p S hp) (hg p S hp) (Nat.cast_nonneg _) (by positivity)
  push_cast
  rw [pow_add]
  nlinarith only [hh]

theorem const_mul {f : Input→ℕ} {k : ℕ} (hf : GlobalGrowth AK AR AA f k) (n : ℕ) :
    GlobalGrowth AK AR AA (fun p => n*f p) k := by simpa using (const n).mul hf

theorem pow {f : Input→ℕ} {k : ℕ} (hf : GlobalGrowth AK AR AA f k) (n : ℕ) :
    GlobalGrowth AK AR AA (fun p => f p^n) (k*n) := by
  induction n with
  | zero => simpa using const 1
  | succ n ih => simpa only [pow_succ,Nat.mul_succ] using ih.mul hf

theorem sqrt_even {f : Input→ℕ} {k : ℕ} (hf : GlobalGrowth AK AR AA f (2*k)) :
    GlobalGrowth AK AR AA (fun p => Nat.sqrt (f p)) k := by
  obtain ⟨a,ha,hf⟩ := hf
  refine ⟨Real.sqrt a,Real.sqrt_pos.mpr ha,?_⟩
  intro p S hp
  have hS : 0≤S := by linarith [hp.size]
  have hs : (Nat.sqrt (f p):ℝ)^2≤(f p:ℝ) := by exact_mod_cast Nat.sqrt_le' (f p)
  have hb : (Real.sqrt a*S^k)^2=a*S^(2*k) := by
    rw [mul_pow,Real.sq_sqrt ha.le,←pow_mul,Nat.mul_comm k 2]
  apply (sq_le_sq₀ (Nat.cast_nonneg _) (by positivity)).mp
  rw [hb]
  exact hs.trans (hf p S hp)

theorem of_le {f g : Input→ℕ} {k : ℕ} (hg : GlobalGrowth AK AR AA g k) (hfg : ∀p,f p≤g p) :
    GlobalGrowth AK AR AA f k := by
  obtain ⟨a,ha,hg⟩ := hg
  exact ⟨a,ha,fun p S hp => (by exact_mod_cast hfg p : (f p:ℝ)≤g p).trans (hg p S hp)⟩

theorem congr {f g : Input→ℕ} {k : ℕ} (hf : GlobalGrowth AK AR AA f k) (he : ∀p,f p=g p) :
    GlobalGrowth AK AR AA g k := hf.of_le (fun p => (he p).ge)

end GlobalGrowth

variable {AK AR AA : ℝ} (hAK : 0<AK) (hAR : 0<AR) (hAA : 0<AA)

include hAR hAA in
theorem inverseError_global_growth : GlobalGrowth AK AR AA inverseError 8 := by
  have hd := GlobalGrowth.depth (AK:=AK) (AR:=AR) (AA:=AA) |>.add ((GlobalGrowth.const 1).mono (by omega))
  have ha := (GlobalGrowth.failure (AK:=AK) (AR:=AR) (AA:=AA) hAA).add ((GlobalGrowth.const 1).mono (by omega))
  have hr := (GlobalGrowth.radius (AK:=AK) (AR:=AR) (AA:=AA) hAR).add ((GlobalGrowth.const 1).mono (by omega))
  exact (((hd.const_mul 10000).mul ha).mul (hr.pow 2)).congr (fun _ => rfl)

include hAA in
theorem inverseFailure_global_growth : GlobalGrowth AK AR AA inverseFailure 2 := by
  have hd := GlobalGrowth.depth (AK:=AK) (AR:=AR) (AA:=AA) |>.add ((GlobalGrowth.const 1).mono (by omega))
  have ha := (GlobalGrowth.failure (AK:=AK) (AR:=AR) (AA:=AA) hAA).add ((GlobalGrowth.const 1).mono (by omega))
  exact ((hd.const_mul 100).mul ha).congr (fun _ => rfl)

include hAK hAR hAA in
theorem rank_global_growth : GlobalGrowth AK AR AA rank 13 := by
  have hk := (GlobalGrowth.energy (AK:=AK) (AR:=AR) (AA:=AA) hAK).add ((GlobalGrowth.const 1).mono (by omega))
  have hh := ((hk.const_mul 2).mul (inverseFailure_global_growth hAA)).mul (inverseError_global_growth hAR hAA)
  exact (hh.add ((GlobalGrowth.const 1).mono (by omega))).congr (fun _ => rfl)

include hAK hAR hAA in
theorem logEnvelope_global_growth : GlobalGrowth AK AR AA logEnvelope 4 := by
  have hd := GlobalGrowth.dimension (AK:=AK) (AR:=AR) (AA:=AA) |>.mono (by omega : 1≤4)
  have hl := GlobalGrowth.depth (AK:=AK) (AR:=AR) (AA:=AA) |>.mono (by omega : 1≤4)
  have hk := (GlobalGrowth.energy (AK:=AK) (AR:=AR) (AA:=AA) hAK).add ((GlobalGrowth.const 1).mono (by omega)) |>.mono (by omega : 3≤4)
  have hh := (inverseFailure_global_growth (AK:=AK) (AR:=AR) hAA).mono (by omega : 2≤4)
  have hr := (GlobalGrowth.radius (AK:=AK) (AR:=AR) (AA:=AA) hAR).mono (by omega : 3≤4)
  have he := (inverseError_global_growth (AK:=AK) hAR hAA).sqrt_even (k:=4)
  exact ((((((GlobalGrowth.const 1).mono (by omega)).add hd).add hl).add hk).add hh |>.add hr |>.add he).congr (by intro p;rfl)

include hAK hAA in
theorem readoutMoment_global_growth : GlobalGrowth AK AR AA readoutMoment 5 := by
  have hk := (GlobalGrowth.energy (AK:=AK) (AR:=AR) (AA:=AA) hAK).add ((GlobalGrowth.const 1).mono (by omega))
  have hn := (hk.const_mul 8).add ((GlobalGrowth.const 2).mono (by omega))
  exact (hn.mul (inverseFailure_global_growth hAA)).congr (fun _ => rfl)

include hAK hAR hAA in
theorem bankSize_global_growth : GlobalGrowth AK AR AA bankSize 21 := by
  have hq := rank_global_growth hAK hAR hAA
  have hk := (GlobalGrowth.energy (AK:=AK) (AR:=AR) (AA:=AA) hAK).mono (by omega : 3≤13)
  have hE := inverseError_global_growth (AK:=AK) hAR hAA
  have hH := inverseFailure_global_growth (AK:=AK) (AR:=AR) hAA
  have hT := logEnvelope_global_growth hAK hAR hAA
  have hR := (GlobalGrowth.radius (AK:=AK) (AR:=AR) (AA:=AA) hAR).add ((GlobalGrowth.const 1).mono (by omega))
  have hfirst : GlobalGrowth AK AR AA (fun p=>(p.energy+rank p+1)*inverseError p) 21 :=
    ((hk.add hq).add ((GlobalGrowth.const 1).mono (by omega))).mul hE
  have hsecond : GlobalGrowth AK AR AA (fun p=>rank p*(inverseFailure p)^2*logEnvelope p) 21 := by
    simpa using (hq.mul (hH.pow 2)).mul hT
  have hthird : GlobalGrowth AK AR AA (fun p=>readoutMoment p*inverseFailure p*(p.inverseRadius+1)^2) 21 :=
    (((readoutMoment_global_growth (AR:=AR) hAK hAA).mul hH).mul (hR.pow 2)).mono (by omega)
  exact ((((hfirst.add hsecond).add hthird).const_mul (2^256)).add
    ((GlobalGrowth.const 1).mono (by omega))).congr (fun _ => rfl)

include hAK hAR hAA in
theorem widthBound_global_growth : GlobalGrowth AK AR AA widthBound 21 := by
  have hL := GlobalGrowth.depth (AK:=AK) (AR:=AR) (AA:=AA) |>.add ((GlobalGrowth.const 1).mono (by omega))
  have hd := GlobalGrowth.dimension (AK:=AK) (AR:=AR) (AA:=AA) |>.add ((GlobalGrowth.const 1).mono (by omega))
  have hq := (rank_global_growth hAK hAR hAA).add ((GlobalGrowth.const 1).mono (by omega))
  have hs := (((hL.const_mul 2).mul hd).mul hq).mono (by omega : 15≤21)
  exact (((bankSize_global_growth hAK hAR hAA).add hs).add
    ((GlobalGrowth.const 1).mono (by omega))).congr (fun _ => rfl)


include hAK hAR hAA in
theorem firstSquared_global_growth : GlobalGrowth AK AR AA firstSquared 11 := by
  have hk := (GlobalGrowth.energy (AR:=AR) (AA:=AA) hAK).const_mul 4
  have hd := ((GlobalGrowth.dimension (AK:=AK) (AR:=AR) (AA:=AA)).add
    ((GlobalGrowth.const 1).mono (by omega))).const_mul 2 |>.mono (by omega : 1≤3)
  exact (((hk.add hd).const_mul 4).mul (inverseError_global_growth hAR hAA)).congr (fun _=>rfl)

include hAK hAR hAA in
theorem activeSquared_global_growth : GlobalGrowth AK AR AA activeSquared 21 := by
  have hk := (GlobalGrowth.energy (AR:=AR) (AA:=AA) hAK).const_mul 8 |>.mono (by omega : 3≤13)
  have hq := (rank_global_growth hAK hAR hAA).const_mul 2
  exact (((hk.add hq).const_mul 16).mul (inverseError_global_growth hAR hAA)).congr (fun _=>rfl)

include hAK hAR hAA in
theorem gaussianSquared_global_growth : GlobalGrowth AK AR AA gaussianSquared 29 := by
  exact (((bankSize_global_growth hAK hAR hAA).const_mul 512).mul
    (inverseError_global_growth hAR hAA)).congr (fun _=>rfl)

include hAK hAR hAA in
theorem readoutClip_global_growth : GlobalGrowth AK AR AA readoutClip 8 := by
  have hr := (GlobalGrowth.radius (AK:=AK) (AA:=AA) hAR).add ((GlobalGrowth.const 1).mono (by omega))
  exact (((readoutMoment_global_growth (AR:=AR) hAK hAA).const_mul 16).mul hr).congr (fun _=>rfl)

include hAK hAR hAA in
theorem parameterCount_global_growth :
    GlobalGrowth AK AR AA (fun p=>robustParameterCount p.dimension (widthBound p) (p.depth-2)) 43 := by
  have hm := widthBound_global_growth hAK hAR hAA
  have hd := (GlobalGrowth.dimension (AK:=AK) (AR:=AR) (AA:=AA)).add
    ((GlobalGrowth.const 1).mono (by omega))
  have hl : GlobalGrowth AK AR AA (fun p=>p.depth-2) 1 :=
    GlobalGrowth.depth.of_le (fun p=>Nat.sub_le _ _)
  exact ((((hm.mul hd).mono (by omega : 22≤43)).add ((hl.mul hm).mul hm)).add
    (hm.mono (by omega))).congr (fun _=>rfl)

include hAK hAR hAA in
theorem smallSquared_global_growth : GlobalGrowth AK AR AA smallSquared 44 := by
  have hm := widthBound_global_growth hAK hAR hAA
  have hk := GlobalGrowth.energy (AR:=AR) (AA:=AA) hAK
  have hp := (parameterCount_global_growth hAK hAR hAA).const_mul 2
  have ha := (GlobalGrowth.failure (AK:=AK) (AR:=AR) hAA).add ((GlobalGrowth.const 1).mono (by omega))
  exact ((((((hm.const_mul 4).mul hk).mono (by omega : 24≤43)).add hp).const_mul 4).mul ha).congr (fun _=>rfl)

include hAK hAR hAA in
theorem weightBound_global_growth : GlobalGrowth AK AR AA weightBound 24 := by
  have hs := (smallSquared_global_growth hAK hAR hAA).sqrt_even (k:=22) |>.mono (by omega : 22≤24)
  have hf := ((firstSquared_global_growth hAK hAR hAA).mono (by omega : 11≤12)).sqrt_even (k:=6) |>.mono (by omega : 6≤24)
  have ha := ((activeSquared_global_growth hAK hAR hAA).mono (by omega : 21≤22)).sqrt_even (k:=11)
  have hq := (rank_global_growth hAK hAR hAA).add ((GlobalGrowth.const 1).mono (by omega))
  have hag := (((ha.add ((GlobalGrowth.const 1).mono (by omega))).const_mul 2).mul hq)
  have hg := ((gaussianSquared_global_growth hAK hAR hAA).mono (by omega : 29≤30)).sqrt_even (k:=15)
  have hgg := ((hg.add ((GlobalGrowth.const 1).mono (by omega))).const_mul 2).mono (by omega : 15≤24)
  have hr := (readoutClip_global_growth hAK hAR hAA).mono (by omega : 8≤24)
  exact (((((hs.add hf).add hag).add hgg).add hr).add ((GlobalGrowth.const 4).mono (by omega))).congr (fun _=>rfl)

end
end NeuralGeneralization.BatchTwoImprovedResources
