import NeuralGeneralization.BatchTwoGramPowerExpectation

/-! Independent-sample iteration of the polynomial covariance potential. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoGramPower
open Matrix BatchTwoImprovedWeightedSampling
variable {ι α : Type*} [Fintype ι] [DecidableEq ι] [Fintype α]

theorem QuadraticBounds.weaken {A : Matrix ι ι ℝ} {b a b' a' : ℝ}
    (h : QuadraticBounds A b a) (hb : b'≤b) (ha : a≤a') : QuadraticBounds A b' a' := by
  refine ⟨h.1,fun u=>?_⟩
  have hu : 0≤∑i,u i^2 := Finset.sum_nonneg fun _ _=>sq_nonneg _
  exact ⟨(mul_le_mul_of_nonneg_right hb hu).trans (h.2 u).1,
    (h.2 u).2.trans (mul_le_mul_of_nonneg_right ha hu)⟩

def sampleBarrier (a : ℝ) (v : α→ι→ℝ) {n : ℕ} (s : Fin n→α) : Matrix ι ι ℝ :=
  a • (1 : Matrix ι ι ℝ)-∑i,vecMulVec (v (s i)) (v (s i))

@[simp] theorem sampleBarrier_zero (a : ℝ) (v : α→ι→ℝ) (s : Fin 0→α) :
    sampleBarrier a v s=a • (1 : Matrix ι ι ℝ) := by simp [sampleBarrier]

@[simp] theorem sampleBarrier_cons (a : ℝ) (v : α→ι→ℝ) {n : ℕ} (x : α) (s : Fin n→α) :
    sampleBarrier a v (Fin.cons x s)=sampleBarrier a v s-vecMulVec (v x) (v x) := by
  simp only [sampleBarrier,Fin.sum_univ_succ,Fin.cons_zero,Fin.cons_succ]
  abel

theorem quadraticBounds_smul_one (a : ℝ) : QuadraticBounds (a • (1 : Matrix ι ι ℝ)) a a := by
  refine ⟨Matrix.isHermitian_one.smul (by rw [isSelfAdjoint_iff]; rfl),fun u=>?_⟩
  have hh : powerMoment (a • (1 : Matrix ι ι ℝ)) u 1=a*(∑i,u i^2) := by
    simp [powerMoment,Matrix.smul_mulVec,dotProduct,pow_two,Finset.mul_sum,mul_left_comm]
  simp only [hh,le_refl,and_self]

theorem sampleBarrier_bounds (a : ℝ) (v : α→ι→ℝ) {R : ℝ}
    (hv : ∀x,(∑i,v x i^2)≤R) (n : ℕ) (s : Fin n→α) :
    QuadraticBounds (sampleBarrier a v s) (a-(n:ℝ)*R) a := by
  induction n with
  | zero => simpa using quadraticBounds_smul_one (ι:=ι) a
  | succ n ih =>
    obtain ⟨⟨x,t⟩,rfl⟩ := (Fin.consEquiv (fun _ : Fin (n+1)=>α)).surjective s
    have h := (ih t).rankOnePath (v x) (hv x) (t:=1) (by constructor <;> norm_num)
    simpa [Fin.consEquiv,rankOnePath,Nat.cast_add,Nat.cast_one,add_mul,sub_sub] using h

theorem mean_trace_sampleBarrier (w : α→ℝ) (hw : ∀x,0≤w x) (hm : ∑x,w x=1)
    (v : α→ι→ℝ) (hiso : Isotropic w v) {R a : ℝ} (hR : 0≤R) (ha : 0<a)
    (hv : ∀x,(∑i,v x i^2)≤R) (p n : ℕ) (hc : 0≤1-3*((p:ℝ)+1)/(4*a))
    (hbudget : (2*(p:ℝ)+(n:ℝ))*R≤a) :
    mean (iidWeight w n) (fun s=>Matrix.trace ((sampleBarrier a v s)^(p+1)))≤
      (1-3*((p:ℝ)+1)/(4*a))^n*((Fintype.card ι:ℝ)*a^(p+1)) := by
  induction n with
  | zero =>
    simp only [sampleBarrier_zero,smul_pow,one_pow,Matrix.trace_smul,Matrix.trace_one,
      pow_zero,one_mul]
    rw [mean_const _ (iidWeight_mass w hm 0)]
    exact le_of_eq (mul_comm _ _)
  | succ n ih =>
    have hb : (2*(p:ℝ)+(n:ℝ))*R≤a := by
      push_cast at hbudget
      nlinarith
    have hi := ih hb
    rw [mean_iidWeight_succ,mean_comm]
    calc
      _ ≤mean (iidWeight w n) (fun s=>(1-3*((p:ℝ)+1)/(4*a))*
          Matrix.trace ((sampleBarrier a v s)^(p+1))) := by
        apply mean_mono _ (iidWeight_nonneg w hw n)
        intro s
        simp only [sampleBarrier_cons]
        apply mean_trace_rankOne_step w hw hm v hiso hR ha hv p
        apply (sampleBarrier_bounds a v hv n s).weaken _ (le_refl a)
        push_cast at hbudget
        nlinarith
      _ =(1-3*((p:ℝ)+1)/(4*a))*
          mean (iidWeight w n) (fun s=>Matrix.trace ((sampleBarrier a v s)^(p+1))) := mean_mul _ _ _
      _ ≤(1-3*((p:ℝ)+1)/(4*a))*
          ((1-3*((p:ℝ)+1)/(4*a))^n*((Fintype.card ι:ℝ)*a^(p+1))) :=
        mul_le_mul_of_nonneg_left hi hc
      _ =_ := by rw [pow_succ]; ring

end NeuralGeneralization.BatchTwoGramPower
