import NeuralGeneralization.OnlineLowerTanhFiniteParityMoments
import NeuralGeneralization.OnlineLowerTanhOptimizer

/-! Strict negative definiteness of the literal finite-cube numerator quadratic form. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

lemma incomingVariance_nonneg {n:ℕ} (hn:0<n) (v:Fin n→ℝ) :
    0 ≤ incomingEnergy v-(∑i,v i)^2/(n:ℝ) := by
  have hnp:(0:ℝ)<n:=Nat.cast_pos.mpr hn
  have he:(∑i,(v i-(∑j,v j)/(n:ℝ))^2)=incomingEnergy v-(∑i,v i)^2/(n:ℝ):=by
    simp_rw [sub_sq,Finset.sum_add_distrib,Finset.sum_sub_distrib]
    simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
    unfold incomingEnergy
    rw [←Finset.sum_mul,←Finset.mul_sum]
    field_simp
    <;> ring
  rw [←he]
  exact Finset.sum_nonneg (fun i _=>sq_nonneg _)

lemma exchangeable_quadratic_neg {n:ℕ} (hn:0<n) (D O b:ℝ) (v:Fin n→ℝ)
    (hD:D<0) (hT:D-O<0) (hQ:(n:ℝ)*(D-O)+(n:ℝ)^2*O<0)
    (hnon:b≠0 ∨ v≠0) : D*b^2+(D-O)*incomingEnergy v+O*(∑i,v i)^2<0 := by
  let V:=incomingEnergy v-(∑i,v i)^2/(n:ℝ)
  let S:=∑i,v i
  let Q:=(n:ℝ)*(D-O)+(n:ℝ)^2*O
  have hnp:(0:ℝ)<n:=Nat.cast_pos.mpr hn
  have hV:0≤V:=incomingVariance_nonneg hn v
  have hA:D*b^2≤0:=mul_nonpos_of_nonpos_of_nonneg hD.le (sq_nonneg _)
  have hB:(D-O)*V≤0:=mul_nonpos_of_nonpos_of_nonneg hT.le hV
  have hC:Q/(n:ℝ)^2*S^2≤0:=mul_nonpos_of_nonpos_of_nonneg
    (div_neg_of_neg_of_pos hQ (by positivity)).le (sq_nonneg _)
  have he:D*b^2+(D-O)*incomingEnergy v+O*S^2=D*b^2+(D-O)*V+Q/(n:ℝ)^2*S^2:=by
    dsimp [V,Q,S]
    field_simp
    <;> ring
  rw [he]
  by_cases hb:b=0
  · have hv:v≠0:=hnon.resolve_left (not_not.mpr hb)
    by_cases hS:S=0
    · have hVp:0<V:=by
        change 0 < incomingEnergy v-S^2/(n:ℝ)
        rw [hS]
        simpa using incomingEnergy_pos_of_ne_zero v hv
      have hh:(D-O)*V<0:=mul_neg_of_neg_of_pos hT hVp
      linarith
    · have hh:Q/(n:ℝ)^2*S^2<0:=mul_neg_of_neg_of_pos
        (div_neg_of_neg_of_pos hQ (by positivity)) (sq_pos_of_ne_zero hS)
      linarith
  · have hh:D*b^2<0:=mul_neg_of_neg_of_pos hD (sq_pos_of_ne_zero hb)
    linarith

lemma curvatureKernel_spinSum_squared (r:ℕ) (a:ℝ) :
    cubeMean (fun x:Cube (2*r+1)=>signedCurvatureKernel (2*r+1) ((-1:ℝ)^r) a x*(spinSum x)^2)=
      balancedParitySecond r a := by
  unfold cubeMean signedCurvatureKernel balancedParitySecond
  simp only [ConcreteModel.Cube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin,
    Nat.cast_pow,Nat.cast_ofNat]
  rw [←mul_assoc]
  simp_rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x _
  ring

/-- The signed actual numerator has a negative-definite affine quadratic form
at every balanced gain at least one, for all odd degrees at least three. -/
theorem signedCurvatureKernel_affine_negative (r:ℕ) (a:ℝ) (ha:1≤a)
    (b:ℝ) (v:Fin (2*r+3)→ℝ) (hnon:b≠0 ∨ v≠0) :
    cubeMean (fun x:Cube (2*r+3)=>signedCurvatureKernel (2*r+3) ((-1:ℝ)^(r+1)) a x*
      (b+incomingLinear v x)^2)<0 := by
  let D:=cubeMean (signedCurvatureKernel (2*r+3) ((-1:ℝ)^(r+1)) a)
  let O:=curvatureMoment ((-1:ℝ)^(r+1)) a (0:Fin (2*r+3)) 1
  have hD:D=balancedBiasCurvature (r+1) a:=by
    unfold D
    rw [show 2*r+3=2*(r+1)+1 by omega,signedCurvatureKernel_mean]
    rfl
  have hT:D-O=balancedBiasCurvature r a:=by
    have hh:=curvatureMoment_diag_sub_offdiag (2*r+1) ((-1:ℝ)^(r+1)) a
    change D-O=_ at hh
    rw [hh]
    unfold balancedBiasCurvature
    rw [pow_succ]
    ring
  have hQ:((2*r+3:ℕ):ℝ)*(D-O)+((2*r+3:ℕ):ℝ)^2*O=balancedParitySecond (r+1) a:=by
    have hh:=signedCurvatureKernel_quadratic ((-1:ℝ)^(r+1)) a
      (0:Fin (2*r+3)) 1 (by intro h;have hh:=congrArg Fin.val h;norm_num at hh) (fun _=>1)
    have hleft: cubeMean (fun x:Cube (2*r+3)=>signedCurvatureKernel (2*r+3) ((-1:ℝ)^(r+1)) a x*
        (incomingLinear (fun _=>1) x)^2)=balancedParitySecond (r+1) a:=by
      have hh:=curvatureKernel_spinSum_squared (r+1) a
      rw [show 2*(r+1)+1=2*r+3 by omega] at hh
      simpa only [incomingLinear_constant,one_mul] using hh
    rw [hleft] at hh
    simp only [incomingEnergy,Finset.sum_const,Finset.card_univ,Fintype.card_fin,
      one_pow,nsmul_eq_mul,mul_one] at hh
    change balancedParitySecond (r+1) a=(D-O)*((2*r+3:ℕ):ℝ)+O*((2*r+3:ℕ):ℝ)^2 at hh
    nlinarith only [hh]
  rw [signedCurvatureKernel_affine_quadratic (by exact ⟨r+1,by omega⟩)
    ((-1:ℝ)^(r+1)) a b (0:Fin (2*r+3)) 1 (by intro h;have hh:=congrArg Fin.val h;norm_num at hh) v]
  exact exchangeable_quadratic_neg (by omega) D O b v
    (hD.symm ▸ balancedBiasCurvature_neg (r+1) a ha)
    (hT.symm ▸ balancedBiasCurvature_neg r a ha)
    (hQ.symm ▸ balancedParitySecond_neg (r+1) a ha) hnon

end NeuralGeneralization.OnlineLowerTanh
