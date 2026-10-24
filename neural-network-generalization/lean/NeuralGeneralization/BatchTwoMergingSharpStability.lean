import NeuralGeneralization.BatchTwoMergingSharpNorm

/-! Layerwise cylinder estimates without paying the teacher's total depth in
every recurrence step. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel WithLp

theorem sharp_cylinder_firstHidden {d N r : ℕ} (φ:ℝ→ℝ) {a ρ:ℝ}
    (ha : 0≤a) (hρ : 0≤ρ) (hφ : ∀u v,|φ u-φ v|≤a*|u-v|)
    (w v:Weights d N r)
    (hfirst : ∀i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))|≤ρ) (x:Cube d) :
    coordinateNorm (fun i=>firstHidden φ w x i-firstHidden φ v x i)≤
      Real.sqrt (N:ℝ)*a*ρ*((d:ℝ)+1) := by
  have hp (i:Fin N) : |firstHidden φ w x i-firstHidden φ v x i|≤a*((d:ℝ)+1)*ρ := by
    apply (hφ _ _).trans
    rw [mul_assoc]
    apply mul_le_mul_of_nonneg_left _ ha
    rw [←Finset.sum_sub_distrib]
    calc
      _ ≤ ∑j,|w (Sum.inl (i,j))*inputVector x j-v (Sum.inl (i,j))*inputVector x j| :=
        Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑_j:Fin (d+1),ρ := Finset.sum_le_sum fun j _=>by
        rw [←sub_mul,abs_mul,abs_inputVector,mul_one]
        exact hfirst i j
      _ = _ := by simp
  have hh := coordinateNorm_of_pointwise
    (fun i=>firstHidden φ w x i-firstHidden φ v x i) (by positivity) hp
  simpa only [Fintype.card_fin,mul_assoc,mul_left_comm,mul_comm] using hh

theorem sharp_cylinder_hiddenFold {d N r : ℕ} (φ:ℝ→ℝ) {a K G B ρ A:ℝ}
    (ha : 0≤a) (hφ : ∀u v,|φ u-φ v|≤a*|u-v|)
    (hK : 0≤K) (hG : 0≤G) (hB : 0≤B) (hρ : 0≤ρ)
    (hA : 1≤A) (hamp : a*(Real.sqrt K+B+ρ*Real.sqrt G)≤A)
    (w v:Weights d N r) (R E:Fin r→Fin N→Fin N→ℝ)
    (hdecomp : ∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hv : ∀s,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤K)
    (hR : ∀s,(∑i,∑j,R s i j^2)≤ρ^2*G)
    (hE : ∀s,matrixActionBound (E s) B)
    (hfirst : ∀i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))|≤ρ)
    (hbounded : ∀(x:Cube d) (ss:List (Fin r)) i,
      |ss.foldl (hiddenStep φ v) (firstHidden φ v x) i|≤1)
    (hkill : ∀(x:Cube d) (ss:List (Fin r)) (s:Fin r) (i:Fin N),
      (∑j,E s i j*ss.foldl (hiddenStep φ v) (firstHidden φ v x) j)=0)
    (ss:List (Fin r)) (x:Cube d) :
    coordinateNorm (fun i=>ss.foldl (hiddenStep φ w) (firstHidden φ w x) i-
      ss.foldl (hiddenStep φ v) (firstHidden φ v x) i)≤
      Real.sqrt (N:ℝ)*a*ρ*((d:ℝ)+1+ss.length*Real.sqrt G)*A^ss.length := by
  induction ss using List.reverseRecOn with
  | nil => simpa using sharp_cylinder_firstHidden φ ha hρ hφ w v hfirst x
  | append_singleton ss s ih =>
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,List.length_append,List.length_singleton]
    have hh := sharp_cylinder_hiddenStep φ ha hφ hK hG hB hρ w v R E hdecomp hv hR hE
      (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
      (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) (hbounded x ss) (hkill x ss) s
    have hp : 1≤A^(ss.length+1) := one_le_pow₀ hA
    have hn0 : 0≤coordinateNorm (fun i=>ss.foldl (hiddenStep φ w) (firstHidden φ w x) i-
        ss.foldl (hiddenStep φ v) (firstHidden φ v x) i) := norm_nonneg _
    have hs := mul_le_mul_of_nonneg_right hamp hn0
    have hi := mul_le_mul_of_nonneg_left ih (by linarith : 0≤A)
    have hlast := mul_le_mul_of_nonneg_left hp
      (by positivity : 0≤Real.sqrt (N:ℝ)*a*ρ*Real.sqrt G)
    rw [pow_succ] at hlast ⊢
    push_cast
    nlinarith

theorem coordinate_dot_bound {I:Type*} [Fintype I] (u v:I→ℝ) :
    |∑i,u i*v i|≤coordinateNorm u*coordinateNorm v := by
  apply (sq_le_sq₀ (abs_nonneg _) (by positivity)).mp
  rw [sq_abs,mul_pow,coordinateNorm_sq,coordinateNorm_sq]
  exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _

theorem sharp_readout_difference {N:ℕ} (hN:0<N) (u z v dv:Fin N→ℝ) {K ρ e:ℝ}
    (hK:0≤K) (hρ:0≤ρ) (he:0≤e)
    (hv:(N:ℝ)*(∑i,v i^2)≤K)
    (hdv:∀i,|dv i|≤ρ/N) (hz:∀i,|z i|≤1)
    (huz:coordinateNorm (fun i=>u i-z i)≤Real.sqrt (N:ℝ)*e) :
    |(∑i,v i*(u i-z i))+(∑i,dv i*u i)|≤Real.sqrt K*e+ρ*(1+e) := by
  have hn:(0:ℝ)<N := by exact_mod_cast hN
  have hs:0<Real.sqrt (N:ℝ) := Real.sqrt_pos.mpr hn
  have hnv:coordinateNorm v≤Real.sqrt K/Real.sqrt (N:ℝ) := by
    apply coordinateNorm_bound (by positivity)
    rw [div_pow,Real.sq_sqrt hK,Real.sq_sqrt hn.le]
    apply (le_div_iff₀ hn).mpr
    nlinarith
  have hnd:coordinateNorm dv≤ρ/Real.sqrt (N:ℝ) := by
    have hh := coordinateNorm_of_pointwise dv (div_nonneg hρ hn.le) hdv
    simp only [Fintype.card_fin] at hh
    have heq : Real.sqrt (N:ℝ)*(ρ/(N:ℝ))=ρ/Real.sqrt (N:ℝ) := by
      have hh := Real.sq_sqrt hn.le
      field_simp
      nlinarith
    rwa [heq] at hh
  have hnz:coordinateNorm z≤Real.sqrt (N:ℝ) := by
    simpa only [Fintype.card_fin,mul_one] using coordinateNorm_of_pointwise z zero_le_one hz
  have hnu:coordinateNorm u≤Real.sqrt (N:ℝ)*(1+e) := by
    have hh := coordinateNorm_add (fun i=>u i-z i) z
    have heq:(fun i=>u i-z i+z i)=u := by funext i; ring
    rw [heq] at hh
    nlinarith
  have ht := (coordinate_dot_bound v (fun i=>u i-z i)).trans
    (mul_le_mul hnv huz (norm_nonneg _) (by positivity))
  have hd := (coordinate_dot_bound dv u).trans
    (mul_le_mul hnd hnu (norm_nonneg _) (by positivity))
  have hcancel (x y:ℝ) : (x/Real.sqrt (N:ℝ))*(Real.sqrt (N:ℝ)*y)=x*y := by field_simp
  rw [hcancel] at ht hd
  exact (abs_add_le _ _).trans (add_le_add ht hd)

theorem sharp_cylinder_output {d N r : ℕ} (hN:0<N) (φ:ℝ→ℝ) {a K G B ρ A V:ℝ}
    (ha : 0≤a) (hφ : ∀u v,|φ u-φ v|≤a*|u-v|)
    (hK : 0≤K) (hG : 0≤G) (hB : 0≤B) (hρ : 0≤ρ) (hV:0≤V)
    (hA : 1≤A) (hamp : a*(Real.sqrt K+B+ρ*Real.sqrt G)≤A)
    (w v:Weights d N r) (R E:Fin r→Fin N→Fin N→ℝ)
    (hdecomp : ∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hv : ∀s,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤K)
    (hR : ∀s,(∑i,∑j,R s i j^2)≤ρ^2*G)
    (hE : ∀s,matrixActionBound (E s) B)
    (hfirst : ∀i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))|≤ρ)
    (hread : ∀i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))|≤ρ/N)
    (hvread : readoutEnergy v≤V)
    (hbounded : ∀(x:Cube d) (ss:List (Fin r)) i,
      |ss.foldl (hiddenStep φ v) (firstHidden φ v x) i|≤1)
    (hkill : ∀(x:Cube d) (ss:List (Fin r)) (s:Fin r) (i:Fin N),
      (∑j,E s i j*ss.foldl (hiddenStep φ v) (firstHidden φ v x) j)=0)
    (x:Cube d) :
    |networkOutput φ w x-networkOutput φ v x|≤
      Real.sqrt V*(a*ρ*((d:ℝ)+1+r*Real.sqrt G)*A^r)+
        ρ*(1+a*ρ*((d:ℝ)+1+r*Real.sqrt G)*A^r) := by
  let e := a*ρ*((d:ℝ)+1+r*Real.sqrt G)*A^r
  have he:0≤e := by dsimp [e]; positivity
  have hh := sharp_cylinder_hiddenFold φ ha hφ hK hG hB hρ hA hamp w v R E
    hdecomp hv hR hE hfirst hbounded hkill (List.finRange r) x
  simp only [List.length_finRange] at hh
  have hnorm : coordinateNorm (fun i=>finalHidden φ w x i-finalHidden φ v x i)≤
      Real.sqrt (N:ℝ)*e := by
    convert hh using 1
    all_goals first | rfl | ring
  have hout := sharp_readout_difference hN (finalHidden φ w x) (finalHidden φ v x)
    (readoutVector v) (fun i=>readoutVector w i-readoutVector v i) hV hρ he
    hvread hread (hbounded x (List.finRange r)) hnorm
  have heq : networkOutput φ w x-networkOutput φ v x=
      (∑i,readoutVector v i*(finalHidden φ w x i-finalHidden φ v x i))+
        (∑i,(readoutVector w i-readoutVector v i)*finalHidden φ w x i) := by
    unfold networkOutput readoutVector
    simp only [mul_sub,sub_mul,Finset.sum_sub_distrib]
    ring
  rw [heq]
  exact hout

end NeuralGeneralization.BatchTwoMerging
