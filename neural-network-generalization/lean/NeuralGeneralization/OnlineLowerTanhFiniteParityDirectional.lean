import NeuralGeneralization.OnlineLowerTanhFiniteParityQuadratic

/-! All affine directional second derivatives of the actual finite tanh numerator. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

def finiteLineTanh (z a t:ℝ) : ℝ := Real.tanh (z+a*t)
def finiteLineTanhFirst (z a t:ℝ) : ℝ := a*tanhFirst (z+a*t)
def finiteLineTanhSecond (z a t:ℝ) : ℝ := a^2*tanhSecond (z+a*t)
lemma hasDerivAt_finiteLineTanh (z a t:ℝ) :
    HasDerivAt (finiteLineTanh z a) (finiteLineTanhFirst z a t) t := by
  have h:=(hasDerivAt_tanh_first (z+a*t)).comp t (((hasDerivAt_id t).const_mul a).const_add z)
  convert h using 1 <;> (try rfl)
  simp only [finiteLineTanhFirst,mul_one]
  ring
lemma hasDerivAt_finiteLineTanhFirst (z a t:ℝ) :
    HasDerivAt (finiteLineTanhFirst z a) (finiteLineTanhSecond z a t) t := by
  have h:=((hasDerivAt_tanhFirst (z+a*t)).comp t (((hasDerivAt_id t).const_mul a).const_add z)).const_mul a
  convert h using 1 <;> (try rfl)
  simp only [finiteLineTanhSecond,mul_one]
  ring

def signedAffineNumeratorLine {n:ℕ} (s a b:ℝ) (v:Fin n→ℝ) (t:ℝ) : ℝ :=
  cubeMean (fun x:Cube n=>s*paritySign x*finiteLineTanh (a*spinSum x) (b+incomingLinear v x) t)
def signedAffineNumeratorLineFirst {n:ℕ} (s a b:ℝ) (v:Fin n→ℝ) (t:ℝ) : ℝ :=
  cubeMean (fun x:Cube n=>s*paritySign x*finiteLineTanhFirst (a*spinSum x) (b+incomingLinear v x) t)
def signedAffineNumeratorLineSecond {n:ℕ} (s a b:ℝ) (v:Fin n→ℝ) (t:ℝ) : ℝ :=
  cubeMean (fun x:Cube n=>s*paritySign x*finiteLineTanhSecond (a*spinSum x) (b+incomingLinear v x) t)

lemma hasDerivAt_cubeMean {n:ℕ} (f f':Cube n→ℝ→ℝ) (t:ℝ)
    (h:∀x,HasDerivAt (f x) (f' x t) t) :
    HasDerivAt (fun t=>cubeMean (fun x=>f x t)) (cubeMean (fun x=>f' x t)) t := by
  have hh:=(HasDerivAt.sum (u:=Finset.univ) (fun x _=>h x)).const_mul ((2:ℝ)^n)⁻¹
  convert hh using 1 <;> (try rfl)
  funext t
  simp only [cubeMean,Finset.sum_apply]

lemma hasDerivAt_signedAffineNumeratorLine {n:ℕ} (s a b:ℝ) (v:Fin n→ℝ) (t:ℝ) :
    HasDerivAt (signedAffineNumeratorLine s a b v) (signedAffineNumeratorLineFirst s a b v t) t := by
  unfold signedAffineNumeratorLine signedAffineNumeratorLineFirst
  exact hasDerivAt_cubeMean (n:=n)
    (fun x u=>s*paritySign x*finiteLineTanh (a*spinSum x) (b+incomingLinear v x) u)
    (fun x u=>s*paritySign x*finiteLineTanhFirst (a*spinSum x) (b+incomingLinear v x) u) t
    (fun x=>(hasDerivAt_finiteLineTanh _ _ t).const_mul (s*paritySign x))

lemma hasDerivAt_signedAffineNumeratorLineFirst {n:ℕ} (s a b:ℝ) (v:Fin n→ℝ) (t:ℝ) :
    HasDerivAt (signedAffineNumeratorLineFirst s a b v) (signedAffineNumeratorLineSecond s a b v t) t := by
  unfold signedAffineNumeratorLineFirst signedAffineNumeratorLineSecond
  exact hasDerivAt_cubeMean (n:=n)
    (fun x u=>s*paritySign x*finiteLineTanhFirst (a*spinSum x) (b+incomingLinear v x) u)
    (fun x u=>s*paritySign x*finiteLineTanhSecond (a*spinSum x) (b+incomingLinear v x) u) t
    (fun x=>(hasDerivAt_finiteLineTanhFirst _ _ t).const_mul (s*paritySign x))

lemma signedAffineNumeratorLine_eq_actual {n:ℕ} (s a b:ℝ) (v:Fin n→ℝ) (t:ℝ) :
    signedAffineNumeratorLine s a b v t=s*parityCorrelation (fun i=>a+t*v i) (t*b) := by
  rw [parityCorrelation_eq_cubeMean,←cubeMean_const_mul]
  apply cubeMean_congr
  intro x
  unfold finiteLineTanh
  have he:incomingLinear (fun i=>a+t*v i) x=a*spinSum x+t*incomingLinear v x:=by
    unfold incomingLinear spinSum
    simp_rw [add_mul,Finset.sum_add_distrib,Finset.mul_sum]
    apply congrArg₂ (·+·) rfl
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [he,show a*spinSum x+(b+incomingLinear v x)*t=t*b+(a*spinSum x+t*incomingLinear v x) by ring]
  ring

lemma signedAffineNumeratorLineSecond_zero {n:ℕ} (s a b:ℝ) (v:Fin n→ℝ) :
    signedAffineNumeratorLineSecond s a b v 0=
      cubeMean (fun x:Cube n=>signedCurvatureKernel n s a x*(b+incomingLinear v x)^2) := by
  apply cubeMean_congr
  intro x
  simp only [finiteLineTanhSecond,mul_zero,add_zero,signedCurvatureKernel]
  ring

/-- Every nonzero affine direction has strictly negative actual second
numerator derivative at each balanced point of gain at least one. This is the
full mixed-direction assertion, not just tests on coordinate or pair axes. -/
theorem signedAffineNumeratorLine_second_neg (r:ℕ) (a:ℝ) (ha:1≤a)
    (b:ℝ) (v:Fin (2*r+3)→ℝ) (hnon:b≠0 ∨ v≠0) :
    deriv (deriv (fun t=>((-1:ℝ)^(r+1))*parityCorrelation (fun i=>a+t*v i) (t*b))) 0<0 := by
  have he:(fun t=>((-1:ℝ)^(r+1))*parityCorrelation (fun i=>a+t*v i) (t*b))=
      signedAffineNumeratorLine ((-1:ℝ)^(r+1)) a b v:=
    funext (fun t=>(signedAffineNumeratorLine_eq_actual _ _ _ _ t).symm)
  rw [he]
  have hd:deriv (signedAffineNumeratorLine ((-1:ℝ)^(r+1)) a b v)=
      signedAffineNumeratorLineFirst ((-1:ℝ)^(r+1)) a b v:=
    funext (fun t=>(hasDerivAt_signedAffineNumeratorLine _ _ _ _ t).deriv)
  rw [hd,(hasDerivAt_signedAffineNumeratorLineFirst _ _ _ _ 0).deriv,
    signedAffineNumeratorLineSecond_zero]
  exact signedCurvatureKernel_affine_negative r a ha b v hnon

end NeuralGeneralization.OnlineLowerTanh
