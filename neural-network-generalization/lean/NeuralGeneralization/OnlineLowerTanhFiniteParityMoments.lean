import NeuralGeneralization.OnlineLowerTanhFiniteParityLocalSign

/-! Exact permutation and reflection identities for the affine curvature matrix. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

def signedCurvatureKernel (n:ℕ) (s a:ℝ) (x:Cube n) : ℝ :=
  s*paritySign x*tanhSecond (a*spinSum x)

def curvatureMoment {n:ℕ} (s a:ℝ) (i j:Fin n) : ℝ :=
  cubeMean (fun x=>signedCurvatureKernel n s a x*labelReal (x i)*labelReal (x j))

lemma spinSum_coordinateCubeEquiv {n m:ℕ} (e:Fin n≃Fin m) (x:Cube m) :
    spinSum (coordinateCubeEquiv e x)=spinSum x := by
  exact e.sum_comp (fun i=>labelReal (x i))

lemma signedCurvatureKernel_equiv {n:ℕ} (s a:ℝ) (e:Equiv.Perm (Fin n)) (x:Cube n) :
    signedCurvatureKernel n s a (coordinateCubeEquiv e x)=signedCurvatureKernel n s a x := by
  simp only [signedCurvatureKernel,paritySign_coordinateCubeEquiv,spinSum_coordinateCubeEquiv]

lemma curvatureMoment_equiv {n:ℕ} (s a:ℝ) (e:Equiv.Perm (Fin n)) (i j:Fin n) :
    curvatureMoment s a (e i) (e j)=curvatureMoment s a i j := by
  have hh:=cubeMean_equiv (coordinateCubeEquiv e)
    (fun x=>signedCurvatureKernel n s a x*labelReal (x i)*labelReal (x j))
  simp_rw [signedCurvatureKernel_equiv s a e] at hh
  exact hh

lemma curvatureMoment_diag {n:ℕ} (s a:ℝ) (i:Fin n) :
    curvatureMoment s a i i=cubeMean (signedCurvatureKernel n s a) := by
  apply cubeMean_congr
  intro x
  have hx:labelReal (x i)^2=1:=by cases x i <;> norm_num [labelReal]
  nlinarith only [congrArg (fun t:ℝ=>signedCurvatureKernel n s a x*t) hx]

lemma pairPerm_exists {n:ℕ} (i₀ j₀ i j:Fin n) (h₀:i₀≠j₀) (hij:i≠j) :
    ∃e:Equiv.Perm (Fin n),e i₀=i ∧ e j₀=j := by
  let e:Equiv.Perm (Fin n):=(Equiv.swap i₀ i).trans (Equiv.swap ((Equiv.swap i₀ i) j₀) j)
  have ha:i≠(Equiv.swap i₀ i) j₀:=by
    intro hh
    apply h₀
    apply (Equiv.swap i₀ i).injective
    simpa using hh
  refine ⟨e,?_,?_⟩
  · simp only [e,Equiv.trans_apply,Equiv.swap_apply_left]
    exact Equiv.swap_apply_of_ne_of_ne ha hij
  · simp [e]

lemma curvatureMoment_offdiag {n:ℕ} (s a:ℝ) (i₀ j₀ i j:Fin n)
    (h₀:i₀≠j₀) (hij:i≠j) : curvatureMoment s a i j=curvatureMoment s a i₀ j₀ := by
  obtain ⟨e,he₀,he₁⟩:=pairPerm_exists i₀ j₀ i j h₀ hij
  simpa only [he₀,he₁] using curvatureMoment_equiv s a e i₀ j₀

lemma spinSum_negateInputs {n:ℕ} (x:Cube n) : spinSum (negateInputs n x) = -spinSum x := by
  simp [spinSum,negateInputs,Finset.sum_neg_distrib]

lemma signedCurvatureKernel_negate {n:ℕ} (hn:Odd n) (s a:ℝ) (x:Cube n) :
    signedCurvatureKernel n s a (negateInputs n x)=signedCurvatureKernel n s a x := by
  simp only [signedCurvatureKernel,paritySign_negate,hn.neg_one_pow,spinSum_negateInputs]
  simp [tanhSecond,tanhFirst,mul_neg,Real.tanh_neg]

/-- Every bias--weight mixed entry of the actual numerator Hessian vanishes. -/
theorem signedCurvatureKernel_first_moment_zero {n:ℕ} (hn:Odd n) (s a:ℝ) (i:Fin n) :
    cubeMean (fun x=>signedCurvatureKernel n s a x*labelReal (x i))=0 := by
  have hh:=cubeMean_equiv (negateInputs n)
    (fun x=>signedCurvatureKernel n s a x*labelReal (x i))
  have he (x:Cube n):signedCurvatureKernel n s a (negateInputs n x)*labelReal (negateInputs n x i)=
      -(signedCurvatureKernel n s a x*labelReal (x i)):=by
    rw [signedCurvatureKernel_negate hn]
    simp [negateInputs]
  simp_rw [he] at hh
  rw [cubeMean_neg] at hh
  linarith

lemma cubeMean_sum {n:ℕ} {ι:Type*} [Fintype ι] (f:ι→Cube n→ℝ) :
    cubeMean (fun x=>∑i,f i x)=∑i,cubeMean (f i) := by
  unfold cubeMean
  rw [Finset.sum_comm,Finset.mul_sum]

/-- Exact exchangeable quadratic form of the weight block of the actual
numerator Hessian; it retains all diagonal and mixed-coordinate terms. -/
theorem signedCurvatureKernel_quadratic {n:ℕ} (s a:ℝ) (i₀ j₀:Fin n) (h₀:i₀≠j₀)
    (v:Fin n→ℝ) :
    cubeMean (fun x=>signedCurvatureKernel n s a x*(incomingLinear v x)^2)=
      (cubeMean (signedCurvatureKernel n s a)-curvatureMoment s a i₀ j₀)*incomingEnergy v+
        curvatureMoment s a i₀ j₀*(∑i,v i)^2 := by
  have hex (x:Cube n):signedCurvatureKernel n s a x*(incomingLinear v x)^2=
      ∑i,∑j,(v i*v j)*(signedCurvatureKernel n s a x*labelReal (x i)*labelReal (x j)):=by
    unfold incomingLinear
    rw [pow_two,Finset.sum_mul,Finset.mul_sum]
    simp_rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring
  have hexcube : cubeMean (fun x=>signedCurvatureKernel n s a x*(incomingLinear v x)^2)=
      ∑i,∑j,(v i*v j)*curvatureMoment s a i j := by
    rw [show (fun x=>signedCurvatureKernel n s a x*(incomingLinear v x)^2)=
      (fun x=>∑i,∑j,(v i*v j)*(signedCurvatureKernel n s a x*labelReal (x i)*labelReal (x j))) from funext hex]
    rw [cubeMean_sum]
    apply Finset.sum_congr rfl
    intro i _
    rw [cubeMean_sum]
    apply Finset.sum_congr rfl
    intro j _
    exact cubeMean_const_mul _ _
  rw [hexcube]
  have hm (i j:Fin n):curvatureMoment s a i j=
      (if j=i then cubeMean (signedCurvatureKernel n s a)-curvatureMoment s a i₀ j₀ else 0)+
        curvatureMoment s a i₀ j₀:=by
    split_ifs with hji
    · subst j;rw [curvatureMoment_diag];ring
    · rw [curvatureMoment_offdiag s a i₀ j₀ i j h₀ (Ne.symm hji)];ring
  have hre:(∑i,∑j,(v i*v j)*curvatureMoment s a i j)=
      ∑i,∑j,(v i*v j)*((if j=i then cubeMean (signedCurvatureKernel n s a)-
        curvatureMoment s a i₀ j₀ else 0)+curvatureMoment s a i₀ j₀):=by
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    exact congrArg (fun z:ℝ=>(v i*v j)*z) (hm i j)
  rw [hre]
  simp_rw [mul_add,Finset.sum_add_distrib,mul_ite,mul_zero]
  simp only [Finset.sum_ite_eq',Finset.mem_univ,ite_true]
  unfold incomingEnergy
  rw [Finset.mul_sum]
  congr 1
  · apply Finset.sum_congr rfl
    intro i _
    ring
  · rw [pow_two,Finset.sum_mul,Finset.mul_sum]
    simp_rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring


lemma signedCurvatureKernel_mean {n:ℕ} (s a:ℝ) :
    cubeMean (signedCurvatureKernel n s a)=s*parityBiasSecond (fun _:Fin n=>a) 0 := by
  unfold cubeMean signedCurvatureKernel parityBiasSecond
  simp only [zero_add,incomingLinear_constant,ConcreteModel.Cube,Fintype.card_fun,
    Fintype.card_bool,Fintype.card_fin,Nat.cast_pow,Nat.cast_ofNat]
  rw [←mul_assoc,Finset.mul_sum,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x _
  ring

/-- Conditioning the first two signs to differ gives the exact transverse
curvature as a lower-degree parity derivative. -/
theorem curvatureMoment_diag_sub_offdiag (n:ℕ) (s a:ℝ) :
    cubeMean (signedCurvatureKernel (n+2) s a)-
      curvatureMoment s a (0:Fin (n+2)) 1 =
      -s*parityBiasSecond (fun _:Fin n=>a) 0 := by
  change cubeMean (signedCurvatureKernel (n+2) s a)-
    cubeMean (fun x=>signedCurvatureKernel (n+2) s a x*labelReal (x 0)*labelReal (x 1))=_
  rw [←cubeMean_sub,cubeMean_succ,cubeMean_succ,cubeMean_succ]
  have ht (b c:Bool) (x:Cube n) :
      signedCurvatureKernel (n+2) s a (Fin.cons b (Fin.cons c x))-
        signedCurvatureKernel (n+2) s a (Fin.cons b (Fin.cons c x))*
          labelReal ((Fin.cons b (Fin.cons c x):Cube (n+2)) 0)*labelReal ((Fin.cons b (Fin.cons c x):Cube (n+2)) 1)=
      if b=c then 0 else -2*s*paritySign x*tanhSecond (a*spinSum x) := by
    cases b <;> cases c <;>
      simp [signedCurvatureKernel,spinSum,paritySign,Fin.sum_univ_succ,Fin.prod_univ_succ,labelReal,add_assoc] <;> ring
  simp_rw [ht]
  simp
  have he: cubeMean (fun x:Cube n=>-2*s*paritySign x*tanhSecond (a*spinSum x))=
      -2*cubeMean (signedCurvatureKernel n s a):=by
    rw [←cubeMean_const_mul]
    apply cubeMean_congr
    intro x
    unfold signedCurvatureKernel
    ring
  simp only [neg_mul] at he
  rw [he,signedCurvatureKernel_mean]
  ring

/-- Adding a bias direction creates no mixed bias--weight quadratic term. -/
theorem signedCurvatureKernel_affine_quadratic {n:ℕ} (hn:Odd n) (s a b:ℝ)
    (i₀ j₀:Fin n) (h₀:i₀≠j₀) (v:Fin n→ℝ) :
    cubeMean (fun x=>signedCurvatureKernel n s a x*(b+incomingLinear v x)^2)=
      cubeMean (signedCurvatureKernel n s a)*b^2+
      (cubeMean (signedCurvatureKernel n s a)-curvatureMoment s a i₀ j₀)*incomingEnergy v+
        curvatureMoment s a i₀ j₀*(∑i,v i)^2 := by
  have hlin:cubeMean (fun x=>signedCurvatureKernel n s a x*incomingLinear v x)=0:=by
    have he (x:Cube n):signedCurvatureKernel n s a x*incomingLinear v x=
        ∑i,v i*(signedCurvatureKernel n s a x*labelReal (x i)):=by
      unfold incomingLinear
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      ring
    simp_rw [he]
    rw [cubeMean_sum]
    simp_rw [cubeMean_const_mul,signedCurvatureKernel_first_moment_zero hn,mul_zero]
    simp
  have hp (x:Cube n):signedCurvatureKernel n s a x*(b+incomingLinear v x)^2=
      b^2*signedCurvatureKernel n s a x+2*b*(signedCurvatureKernel n s a x*incomingLinear v x)+
        signedCurvatureKernel n s a x*(incomingLinear v x)^2:=by ring
  simp_rw [hp]
  rw [cubeMean_add,cubeMean_add,cubeMean_const_mul,cubeMean_const_mul,hlin]
  rw [signedCurvatureKernel_quadratic s a i₀ j₀ h₀ v]
  ring

end NeuralGeneralization.OnlineLowerTanh
