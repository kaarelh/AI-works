import NeuralGeneralization.OnlineLowerTanhFiniteParityDirectional

/-! The complete affine first derivative at a balanced point. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators Topology
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

def signedSlopeKernel (n:ℕ) (s a:ℝ) (x:Cube n) : ℝ :=
  s*paritySign x*tanhFirst (a*spinSum x)

lemma signedSlopeKernel_equiv {n:ℕ} (s a:ℝ) (e:Equiv.Perm (Fin n)) (x:Cube n) :
    signedSlopeKernel n s a (coordinateCubeEquiv e x)=signedSlopeKernel n s a x := by
  simp only [signedSlopeKernel,paritySign_coordinateCubeEquiv,spinSum_coordinateCubeEquiv]

lemma signedSlopeKernel_moment_eq {n:ℕ} (s a:ℝ) (i j:Fin n) :
    cubeMean (fun x=>signedSlopeKernel n s a x*labelReal (x i))=
      cubeMean (fun x=>signedSlopeKernel n s a x*labelReal (x j)) := by
  have h:=cubeMean_equiv (coordinateCubeEquiv (Equiv.swap j i))
    (fun x=>signedSlopeKernel n s a x*labelReal (x j))
  simp_rw [signedSlopeKernel_equiv] at h
  simpa only [coordinateCubeEquiv,Equiv.coe_fn_mk,
    Equiv.swap_apply_left] using h

lemma signedSlopeKernel_mean_zero {n:ℕ} (hn:Odd n) (s a:ℝ) :
    cubeMean (signedSlopeKernel n s a)=0 := by
  have he:cubeMean (signedSlopeKernel n s a)=s*parityBiasFirst (fun _:Fin n=>a) 0:=by
    unfold cubeMean signedSlopeKernel parityBiasFirst
    simp only [zero_add,incomingLinear_constant,ConcreteModel.Cube,Fintype.card_fun,
      Fintype.card_bool,Fintype.card_fin,Nat.cast_pow,Nat.cast_ofNat]
    rw [←mul_assoc,Finset.mul_sum,Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro x _
    ring
  rw [he,parityBiasFirst_zero_of_odd hn,mul_zero]

lemma signedSlopeKernel_moment (r:ℕ) (a:ℝ) (i:Fin (2*r+1)) :
    cubeMean (fun x=>signedSlopeKernel (2*r+1) ((-1:ℝ)^r) a x*labelReal (x i))=
      balancedParityFirst r a/(2*r+1:ℕ) := by
  have he:balancedParityFirst r a=
      ∑j:Fin (2*r+1),cubeMean (fun x=>signedSlopeKernel (2*r+1) ((-1:ℝ)^r) a x*labelReal (x j)):=by
    rw [←cubeMean_sum]
    unfold balancedParityFirst cubeMean signedSlopeKernel spinSum
    simp only [ConcreteModel.Cube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin,
      Nat.cast_pow,Nat.cast_ofNat]
    rw [←mul_assoc,Finset.mul_sum,Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro x _
    simp_rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    ring
  simp_rw [signedSlopeKernel_moment_eq ((-1:ℝ)^r) a _ i] at he
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul] at he
  apply (eq_div_iff (by positivity : ((2*r+1:ℕ):ℝ)≠0)).mpr
  nlinarith only [he]

theorem signedAffineNumeratorLineFirst_zero (r:ℕ) (a b:ℝ) (v:Fin (2*r+1)→ℝ) :
    signedAffineNumeratorLineFirst ((-1:ℝ)^r) a b v 0=
      balancedParityFirst r a/(2*r+1:ℕ)*(∑i,v i) := by
  have he (x:Cube (2*r+1)):
      (-1:ℝ)^r*paritySign x*finiteLineTanhFirst (a*spinSum x) (b+incomingLinear v x) 0=
      b*signedSlopeKernel (2*r+1) ((-1:ℝ)^r) a x+
        ∑i,v i*(signedSlopeKernel (2*r+1) ((-1:ℝ)^r) a x*labelReal (x i)):=by
    simp only [finiteLineTanhFirst,mul_zero,add_zero,signedSlopeKernel,incomingLinear]
    rw [add_mul,mul_add]
    congr 1
    · ring
    · rw [Finset.sum_mul,Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      ring
  unfold signedAffineNumeratorLineFirst
  simp_rw [he]
  rw [cubeMean_add,cubeMean_const_mul,signedSlopeKernel_mean_zero (show Odd (2*r+1) from ⟨r,by omega⟩),
    mul_zero,zero_add,cubeMean_sum]
  simp_rw [cubeMean_const_mul,signedSlopeKernel_moment]
  rw [←Finset.sum_mul]
  ring

theorem signedAffineNumeratorLineFirst_at_gain (r:ℕ) (hr:2≤r)
    (b:ℝ) (v:Fin (2*r+1)→ℝ) :
    signedAffineNumeratorLineFirst ((-1:ℝ)^r) (balancedGain r) b v 0=
      balancedParity r (balancedGain r)/((2*r+1:ℕ)*balancedGain r)*(∑i,v i) := by
  rw [signedAffineNumeratorLineFirst_zero]
  have hz:balancedGain r*balancedParityFirst r (balancedGain r)-balancedParity r (balancedGain r)=0:=
    (balancedGain_interior_and_stationary r hr).2
  have ha:=balancedGain_pos r
  congr 1
  field_simp
  nlinarith only [hz]

end NeuralGeneralization.OnlineLowerTanh
