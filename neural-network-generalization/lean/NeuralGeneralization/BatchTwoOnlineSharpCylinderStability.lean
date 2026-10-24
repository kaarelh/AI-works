import NeuralGeneralization.BatchTwoOnlineSharpCylinderTeacher
import NeuralGeneralization.BatchTwoOnlineSharpSpectralStability

/-! Linear Euclidean error propagation for the exact online target cylinder. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel Compression CompressionSampling

 theorem cylinder_step_norm {d N r C : ℕ} {ρ B : ℝ} (hρ : 0≤ρ) (hB : 0≤B)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w v : Weights d N r)
    (R E : Fin r→Fin N→Fin N→ℝ)
    (hdecomp : ∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hv : ∀s,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤(C:ℝ)^4)
    (hR : ∀s,(∑i,∑j,R s i j^2)≤ρ^2*((C:ℝ)+1))
    (hE : ∀s,matrixActionBound (E s) B)
    (u z : Fin N→ℝ) (hu : ∀i,|u i|≤1) (s : Fin r)
    (hkill : ∀i,(∑j,E s i j*z j)=0) :
    euclideanNorm (fun i=>hiddenStep φ w u s i-hiddenStep φ v z s i)≤
      ((C:ℝ)^2+B)*euclideanNorm (fun i=>u i-z i)+ρ*Real.sqrt ((C:ℝ)+1)*Real.sqrt N := by
  let A:Fin N→ℝ:=fun i=>∑j,v (Sum.inr (Sum.inl (s,i,j)))*(u j-z j)
  let F:Fin N→ℝ:=fun i=>∑j,E s i j*(u j-z j)
  let D:Fin N→ℝ:=fun i=>∑j,R s i j*u j
  have hA:euclideanNorm A≤(C:ℝ)^2*euclideanNorm (fun i=>u i-z i) := by
    apply euclideanNorm_le_of_sum_sq _ (by positivity)
    rw [mul_pow,euclideanNorm_sq]
    have hh:=(matrix_action_squaredSum_le (fun i j=>v (Sum.inr (Sum.inl (s,i,j)))) (fun i=>u i-z i)).trans
      (mul_le_mul_of_nonneg_right (hv s) (by positivity))
    simpa only [A,←pow_mul,show 2*2=4 by norm_num] using hh
  have hF:euclideanNorm F≤B*euclideanNorm (fun i=>u i-z i) := by
    apply euclideanNorm_le_of_sum_sq _ (by positivity)
    rw [mul_pow,euclideanNorm_sq]
    exact hE s _
  have hu2:(∑i,u i^2)≤(N:ℝ):=by
    calc
      _ ≤ ∑_i : Fin N,(1:ℝ):=Finset.sum_le_sum fun i _=>by
        simpa only [sq_abs,one_pow] using (sq_le_sq₀ (abs_nonneg _) (by norm_num : (0:ℝ)≤1)).mpr (hu i)
      _ = _:=by simp
  have hD:euclideanNorm D≤ρ*Real.sqrt ((C:ℝ)+1)*Real.sqrt N := by
    apply euclideanNorm_le_of_sum_sq _ (by positivity)
    rw [mul_pow,mul_pow,Real.sq_sqrt (by positivity : 0≤(C:ℝ)+1),Real.sq_sqrt (Nat.cast_nonneg N)]
    exact (matrix_action_squaredSum_le (R s) u).trans (mul_le_mul (hR s) hu2 (by positivity) (by positivity))
  have he (i : Fin N) :
      (∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)-(∑j,v (Sum.inr (Sum.inl (s,i,j)))*z j)=A i+F i+D i := by
    dsimp [A,F,D]
    simp_rw [hdecomp,add_mul,mul_sub]
    simp only [Finset.sum_add_distrib,Finset.sum_sub_distrib,hkill]
    ring
  have ha:euclideanNorm (fun i=>hiddenStep φ w u s i-hiddenStep φ v z s i)≤
      euclideanNorm (fun i=>A i+F i+D i) := by
    apply euclideanNorm_le_of_sum_sq _ (norm_nonneg _)
    rw [euclideanNorm_sq]
    have hh:=lipschitz_activation_squaredDistance φ hφ.2
      (fun i=>∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j) (fun i=>∑j,v (Sum.inr (Sum.inl (s,i,j)))*z j)
    simpa only [squaredDistance,he,hiddenStep] using hh
  have ht:euclideanNorm (fun i=>A i+F i+D i)≤euclideanNorm A+euclideanNorm F+euclideanNorm D:=
    (euclideanNorm_add (fun i=>A i+F i) D).trans (add_le_add (euclideanNorm_add A F) le_rfl)
  have hh:=ha.trans ht
  linarith

theorem cylinderGrowth_bounds {C r : ℕ} (hC : 1≤C) :
    1≤cylinderGrowth C r ∧ (C:ℝ)^2+cylinderBulkBound r≤cylinderGrowth C r ∧
      Real.sqrt ((C:ℝ)+1)≤cylinderGrowth C r := by
  have hCR:1≤(C:ℝ):=by exact_mod_cast hC
  have hb:=cylinderBulkBound_nonneg r
  have hs:Real.sqrt ((C:ℝ)+1)≤(C:ℝ)+1:=by
    apply (Real.sqrt_le_iff).mpr
    exact ⟨by positivity,by nlinarith⟩
  unfold cylinderGrowth
  constructor
  · nlinarith [sq_nonneg (C:ℝ)]
  constructor
  · nlinarith [sq_nonneg (C:ℝ)]
  · nlinarith [sq_nonneg ((C:ℝ)-1)]

theorem cylinder_fold_norm {d N r C : ℕ} {ρ : ℝ} (hC : 1≤C) (hρ : 0≤ρ)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w v : Weights d N r)
    (R E : Fin r→Fin N→Fin N→ℝ)
    (hdecomp : ∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hv : ∀s,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤(C:ℝ)^4)
    (hR : ∀s,(∑i,∑j,R s i j^2)≤ρ^2*((C:ℝ)+1))
    (hE : ∀s,matrixActionBound (E s) (cylinderBulkBound r))
    (hfirst : ∀i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))|≤ρ)
    (hkill : ∀(x : Cube d) (ss : List (Fin r)) (s : Fin r) (i : Fin N),
      (∑j,E s i j*ss.foldl (hiddenStep φ v) (firstHidden φ v x) j)=0)
    (ss : List (Fin r)) (x : Cube d) :
    euclideanNorm (fun i=>ss.foldl (hiddenStep φ w) (firstHidden φ w x) i-
      ss.foldl (hiddenStep φ v) (firstHidden φ v x) i)≤
      ρ*Real.sqrt N*((d:ℝ)+2+ss.length)*(cylinderGrowth C r)^ss.length := by
  obtain ⟨hA,hcoeff,hroot⟩:=cylinderGrowth_bounds (r:=r) hC
  induction ss using List.reverseRecOn with
  | nil =>
    simp only [List.foldl_nil,List.length_nil,pow_zero,Nat.cast_zero,add_zero,mul_one]
    apply euclideanNorm_le_of_sum_sq _ (by positivity)
    have hh:=cylinder_firstHidden_error φ hφ w v ρ hρ hfirst x
    have hd0:0≤(d:ℝ):=Nat.cast_nonneg _
    rw [mul_pow,mul_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
    have hm:0≤(N:ℝ)*ρ^2:=by positivity
    unfold squaredDistance cylinderInputFactor at hh
    nlinarith [mul_nonneg hm (show 0≤((d:ℝ)+2)^2-(((d:ℝ)+1)^2+1) by nlinarith)]
  | append_singleton ss s ih =>
    have hh:=cylinder_step_norm hρ (cylinderBulkBound_nonneg r) φ hφ w v R E hdecomp hv hR hE
      (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
      (ss.foldl (hiddenStep φ v) (firstHidden φ v x))
      (fun i=>hiddenFold_bounded φ hφ w ss x i) s (hkill x ss s)
    have hmult:=mul_le_mul hcoeff ih (norm_nonneg _)
      (le_trans (by norm_num : (0:ℝ)≤1) hA)
    have hpow:1≤(cylinderGrowth C r)^ss.length:=one_le_pow₀ hA
    have hf:Real.sqrt ((C:ℝ)+1)≤(cylinderGrowth C r)^(ss.length+1):=by
      calc
        _ ≤ cylinderGrowth C r:=hroot
        _ ≤ (cylinderGrowth C r)^(ss.length+1):=by
          simpa only [pow_one] using pow_le_pow_right₀ hA (show 1≤ss.length+1 by omega)
    have hforce:=mul_le_mul_of_nonneg_left hf (show 0≤ρ*Real.sqrt (N:ℝ) by positivity)
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,List.length_append,List.length_singleton,
      Nat.cast_add,Nat.cast_one,pow_succ] at *
    nlinarith

theorem cylinder_output_error {d N r C : ℕ} (hN : 0<N) (hC : 1≤C)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w v : Weights d N r)
    (R E : Fin r→Fin N→Fin N→ℝ)
    (hdecomp : ∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hv : ∀s,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤(C:ℝ)^4)
    (hvread : (N:ℝ)*(∑i,v (Sum.inr (Sum.inr i))^2)≤18*(C:ℝ)^4)
    (hR : ∀s,(∑i,∑j,R s i j^2)≤(cylinderRadius d C r)^2*((C:ℝ)+1))
    (hE : ∀s,matrixActionBound (E s) (cylinderBulkBound r))
    (hfirst : ∀i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))|≤cylinderRadius d C r)
    (hread : ∀i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))|≤cylinderRadius d C r/N)
    (hkill : ∀(x : Cube d) (ss : List (Fin r)) (s : Fin r) (i : Fin N),
      (∑j,E s i j*ss.foldl (hiddenStep φ v) (firstHidden φ v x) j)=0)
    (x : Cube d) : |networkOutput φ w x-networkOutput φ v x|≤1 := by
  let ρ:=cylinderRadius d C r
  have hρ:0<ρ:=cylinderRadius_pos _ _ _
  have hn:0<(N:ℝ):=by exact_mod_cast hN
  have hC1:1≤(C:ℝ):=by exact_mod_cast hC
  have hA:1≤cylinderGrowth C r:=(cylinderGrowth_bounds hC).1
  let u:=finalHidden φ w x
  let z:=finalHidden φ v x
  let a:=∑i,v (Sum.inr (Sum.inr i))*(u i-z i)
  let b:=∑i,(w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i)))*u i
  have heq:networkOutput φ w x-networkOutput φ v x=a+b:=by
    dsimp [networkOutput,a,b,u,z]
    simp_rw [mul_sub,sub_mul]
    simp only [Finset.sum_sub_distrib]
    ring
  have hb:|b|≤ρ:=by
    calc
      _ ≤ ∑i,|(w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i)))*u i|:=Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑_i : Fin N,ρ/(N:ℝ):=Finset.sum_le_sum fun i _=>by
        rw [abs_mul]
        exact (mul_le_mul (hread i) (hiddenFold_bounded φ hφ w (List.finRange r) x i)
          (abs_nonneg _) (div_nonneg hρ.le hn.le)).trans_eq (mul_one _)
      _ = ρ:=by simp [mul_div_cancel₀ ρ hn.ne']
  have hfold:=cylinder_fold_norm hC hρ.le φ hφ w v R E hdecomp hv hR hE hfirst hkill (List.finRange r) x
  simp only [List.length_finRange] at hfold
  have hdist:(∑i,(u i-z i)^2)≤(ρ*Real.sqrt N*((d:ℝ)+2+r)*(cylinderGrowth C r)^r)^2:=by
    rw [←euclideanNorm_sq]
    exact (sq_le_sq₀ (norm_nonneg _) (by positivity)).mpr hfold
  have hr:(∑i,v (Sum.inr (Sum.inr i))^2)≤18*(C:ℝ)^4/(N:ℝ):=by
    apply (le_div_iff₀ hn).mpr
    nlinarith only [hvread]
  have ha2: a^2≤(5*(C:ℝ)^2*ρ*((d:ℝ)+2+r)*(cylinderGrowth C r)^r)^2:=by
    have hh:=(Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (fun i=>v (Sum.inr (Sum.inr i))) (fun i=>u i-z i)).trans
      (mul_le_mul hr hdist (by positivity) (by positivity))
    change a^2≤_ at hh
    have he:18*(C:ℝ)^4/(N:ℝ)*(ρ*Real.sqrt N*((d:ℝ)+2+r)*(cylinderGrowth C r)^r)^2=
        18*(C:ℝ)^4*ρ^2*((d:ℝ)+2+r)^2*((cylinderGrowth C r)^r)^2:=by
      simp only [mul_pow,Real.sq_sqrt hn.le]
      field_simp
    rw [he] at hh
    nlinarith [sq_nonneg ((C:ℝ)^2*ρ*((d:ℝ)+2+r)*(cylinderGrowth C r)^r)]
  have ha:|a|≤5*(C:ℝ)^2*ρ*((d:ℝ)+2+r)*(cylinderGrowth C r)^r:=
    abs_le_of_sq_le_sq ha2 (by positivity)
  have hpoly:5*(C:ℝ)^2*((d:ℝ)+2+r)*(cylinderGrowth C r)^r+1≤
      2+9*(C:ℝ)^2*((d:ℝ)+r+3)*(cylinderGrowth C r)^r:=by
    have hh:0≤(C:ℝ)^2*(cylinderGrowth C r)^r:=by positivity
    have hd0:0≤(d:ℝ):=Nat.cast_nonneg _
    have hr0:0≤(r:ℝ):=Nat.cast_nonneg _
    nlinarith [mul_nonneg hh (show 0≤4*(d:ℝ)+4*r+17 by positivity)]
  have hfin:5*(C:ℝ)^2*ρ*((d:ℝ)+2+r)*(cylinderGrowth C r)^r+ρ≤1:=by
    have hh:=mul_le_mul_of_nonneg_left hpoly hρ.le
    have hid:ρ*(2+9*(C:ℝ)^2*((d:ℝ)+r+3)*(cylinderGrowth C r)^r)=1:=by
      dsimp [ρ,cylinderRadius]
      exact inv_mul_cancel₀ (by positivity)
    rw [hid] at hh
    nlinarith only [hh]
  rw [heq]
  exact (abs_add_le a b).trans ((add_le_add ha hb).trans hfin)

end NeuralGeneralization.BatchTwoOnlineSharp
