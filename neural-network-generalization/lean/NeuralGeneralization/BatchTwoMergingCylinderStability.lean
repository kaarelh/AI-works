import NeuralGeneralization.BatchTwoMergingStability
import NeuralGeneralization.CylinderStability

/-! # Cylinder stability for Lipschitz activations with bounded teacher states

The student states are not assumed bounded. The small projected perturbation
is evaluated on the teacher; its action on the student error is included in
the recurrence coefficient.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel Compression CompressionSampling

private theorem sum_sq_add_four_le {N : ℕ} (a b c e : Fin N → ℝ) :
    (∑ i,(a i+b i+c i+e i)^2) ≤
      4*((∑ i,a i^2)+(∑ i,b i^2)+(∑ i,c i^2)+∑ i,e i^2) := by
  calc
    _ ≤ ∑ i,4*(a i^2+b i^2+c i^2+e i^2) := by
      apply Finset.sum_le_sum
      intro i _
      nlinarith [sq_nonneg (a i-b i),sq_nonneg (a i-c i),sq_nonneg (a i-e i),
        sq_nonneg (b i-c i),sq_nonneg (b i-e i),sq_nonneg (c i-e i)]
    _ = _ := by rw [← Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.sum_add_distrib]

theorem unbounded_cylinder_hiddenStep {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : LipschitzZero φ) (w v : Weights d N r)
    (R E : Fin r → Fin N → Fin N → ℝ) {K G B ρ : ℝ}
    (hK : 0 ≤ K) (hG : 0 ≤ G) (hρ : 0 ≤ ρ) (hρ1 : ρ ≤ 1)
    (hdecomp : ∀ s i j,w (Sum.inr (Sum.inl (s,i,j))) =
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hv : weightedSquaredNorm v ≤ K)
    (hR : ∀ s,(∑ i,∑ j,R s i j^2) ≤ ρ^2*G)
    (hE : ∀ s,matrixActionBound (E s) B)
    (u z : Fin N → ℝ) (hz : ∀ i,|z i| ≤ 1)
    (hkill : ∀ s i,(∑ j,E s i j*z j)=0) (s : Fin r) :
    squaredDistance (hiddenStep φ w u s) (hiddenStep φ v z s) ≤
      4*(K+B^2+G)*squaredDistance u z+4*ρ^2*G*N := by
  have hdiff (i : Fin N) :
      (∑ j,w (Sum.inr (Sum.inl (s,i,j)))*u j)-
        (∑ j,v (Sum.inr (Sum.inl (s,i,j)))*z j) =
      (∑ j,v (Sum.inr (Sum.inl (s,i,j)))*(u j-z j))+
      (∑ j,E s i j*(u j-z j))+(∑ j,R s i j*(u j-z j))+(∑ j,R s i j*z j) := by
    simp_rw [hdecomp,add_mul,mul_sub]
    simp only [Finset.sum_add_distrib,Finset.sum_sub_distrib,hkill s i]
    ring
  have hnormz : (∑ i,z i^2) ≤ (N : ℝ) := by
    calc
      _ ≤ ∑ _i : Fin N,(1 : ℝ) := Finset.sum_le_sum fun i _ => by
        have hh := (sq_le_sq₀ (abs_nonneg (z i)) (by norm_num : (0 : ℝ)≤1)).2 (hz i)
        simpa only [sq_abs,one_pow] using hh
      _ = _ := by simp
  have hR' (s : Fin r) : (∑ i,∑ j,R s i j^2) ≤ G := by
    have hsq : ρ^2 ≤ 1 := by nlinarith
    exact (hR s).trans (by nlinarith)
  have ht := (matrix_action_squaredSum_le
    (fun i j => v (Sum.inr (Sum.inl (s,i,j)))) (fun i => u i-z i)).trans
    (mul_le_mul_of_nonneg_right ((internal_squaredNorm_le_cost v s).trans hv)
      (Finset.sum_nonneg fun i _ => sq_nonneg _))
  have hr := (matrix_action_squaredSum_le (R s) (fun i => u i-z i)).trans
    (mul_le_mul_of_nonneg_right (hR' s) (Finset.sum_nonneg fun i _ => sq_nonneg _))
  have he := hE s (fun i => u i-z i)
  have hsmall := (matrix_action_squaredSum_le (R s) z).trans
    (mul_le_mul (hR s) hnormz (Finset.sum_nonneg fun i _ => sq_nonneg _)
      (mul_nonneg (sq_nonneg ρ) hG))
  calc
    _ ≤ ∑ i,((∑ j,w (Sum.inr (Sum.inl (s,i,j)))*u j)-
        (∑ j,v (Sum.inr (Sum.inl (s,i,j)))*z j))^2 :=
      lipschitz_activation_squaredDistance φ hφ.2 _ _
    _ = ∑ i,((∑ j,v (Sum.inr (Sum.inl (s,i,j)))*(u j-z j))+
      (∑ j,E s i j*(u j-z j))+(∑ j,R s i j*(u j-z j))+(∑ j,R s i j*z j))^2 := by
      simp_rw [hdiff]
    _ ≤ _ := by
      have hh := sum_sq_add_four_le
        (fun i => ∑ j,v (Sum.inr (Sum.inl (s,i,j)))*(u j-z j))
        (fun i => ∑ j,E s i j*(u j-z j))
        (fun i => ∑ j,R s i j*(u j-z j)) (fun i => ∑ j,R s i j*z j)
      unfold squaredDistance
      nlinarith

def unboundedCylinderAmplification (K G B : ℝ) : ℝ := 4*(K+B^2+G)+4*G+1

theorem unbounded_cylinder_firstHidden {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : LipschitzZero φ) (w v : Weights d N r) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hfirst : ∀ i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ ρ) (x : Cube d) :
    squaredDistance (firstHidden φ w x) (firstHidden φ v x) ≤
      (N : ℝ)*ρ^2*cylinderInputFactor d := by
  have hpoint (i : Fin N) : |firstHidden φ w x i-firstHidden φ v x i| ≤ (d+1 : ℝ)*ρ := by
    apply (hφ.2 _ _).trans
    rw [← Finset.sum_sub_distrib]
    calc
      _ ≤ ∑ j,|w (Sum.inl (i,j))*inputVector x j-v (Sum.inl (i,j))*inputVector x j| :=
        Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _j : Fin (d+1),ρ := Finset.sum_le_sum fun j _ => by
        rw [← sub_mul,abs_mul,abs_inputVector,mul_one]
        exact hfirst i j
      _ = _ := by simp
  calc
    _ ≤ ∑ _i : Fin N,((d+1 : ℝ)*ρ)^2 := by
      apply Finset.sum_le_sum
      intro i _
      simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg _) (by positivity)).2 (hpoint i)
    _ ≤ _ := by
      simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
      unfold cylinderInputFactor
      nlinarith [mul_nonneg (Nat.cast_nonneg N : (0 : ℝ)≤N) (sq_nonneg ρ)]


theorem unbounded_cylinder_hiddenFold {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : LipschitzZero φ) (w v : Weights d N r)
    (R E : Fin r → Fin N → Fin N → ℝ) {K G B ρ : ℝ}
    (hK : 0 ≤ K) (hG : 0 ≤ G) (hρ : 0 ≤ ρ) (hρ1 : ρ ≤ 1)
    (hdecomp : ∀ s i j,w (Sum.inr (Sum.inl (s,i,j))) =
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hv : weightedSquaredNorm v ≤ K)
    (hR : ∀ s,(∑ i,∑ j,R s i j^2) ≤ ρ^2*G)
    (hE : ∀ s,matrixActionBound (E s) B)
    (hfirst : ∀ i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ ρ)
    (hbounded : ∀ (x : Cube d) (ss : List (Fin r)) i,
      |ss.foldl (hiddenStep φ v) (firstHidden φ v x) i| ≤ 1)
    (hkill : ∀ (x : Cube d) (ss : List (Fin r)) (s : Fin r) (i : Fin N),
      (∑ j,E s i j*ss.foldl (hiddenStep φ v) (firstHidden φ v x) j)=0)
    (ss : List (Fin r)) (x : Cube d) :
    squaredDistance (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
      (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) ≤
        (N : ℝ)*ρ^2*cylinderInputFactor d*(unboundedCylinderAmplification K G B)^ss.length := by
  have hA : 1 ≤ unboundedCylinderAmplification K G B := by
    unfold unboundedCylinderAmplification
    nlinarith [sq_nonneg B]
  have hD : 1 ≤ cylinderInputFactor d := by
    unfold cylinderInputFactor
    nlinarith [sq_nonneg ((d : ℝ)+1)]
  induction ss using List.reverseRecOn with
  | nil => simpa using unbounded_cylinder_firstHidden hφ w v hρ hfirst x
  | append_singleton ss s ih =>
      simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,List.length_append,
        List.length_singleton,pow_add,pow_one]
      have hs := unbounded_cylinder_hiddenStep hφ w v R E hK hG hρ hρ1 hdecomp hv hR hE
        (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
        (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) (hbounded x ss) (hkill x ss) s
      have hp : 1 ≤ (unboundedCylinderAmplification K G B)^ss.length := one_le_pow₀ hA
      have hscale : 0 ≤ (N : ℝ)*ρ^2 := mul_nonneg (Nat.cast_nonneg N) (sq_nonneg ρ)
      have hlarge : (N : ℝ)*ρ^2 ≤
          (N : ℝ)*ρ^2*cylinderInputFactor d*(unboundedCylinderAmplification K G B)^ss.length := by
        calc
          _ = (N : ℝ)*ρ^2*1*1 := by ring
          _ ≤ _ := mul_le_mul (mul_le_mul_of_nonneg_left hD hscale) hp (by positivity) (by positivity)
      have hstep := mul_le_mul_of_nonneg_left ih (by positivity : 0 ≤ 4*(K+B^2+G))
      have hrest := mul_le_mul_of_nonneg_left hlarge (by positivity : 0 ≤ 4*G)
      unfold unboundedCylinderAmplification at *
      nlinarith

def unboundedCylinderOutputFactor (d r : ℕ) (K G B : ℝ) : ℝ :=
  3*(K+1)*cylinderInputFactor d*(unboundedCylinderAmplification K G B)^r+3

theorem unbounded_cylinder_output_sq {d N r : ℕ} (hN : 0 < N) {φ : ℝ → ℝ}
    (hφ : LipschitzZero φ) (w v : Weights d N r)
    (R E : Fin r → Fin N → Fin N → ℝ) {K G B ρ : ℝ}
    (hK : 0 ≤ K) (hG : 0 ≤ G) (hρ : 0 ≤ ρ) (hρ1 : ρ ≤ 1)
    (hdecomp : ∀ s i j,w (Sum.inr (Sum.inl (s,i,j))) =
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hv : weightedSquaredNorm v ≤ K)
    (hR : ∀ s,(∑ i,∑ j,R s i j^2) ≤ ρ^2*G)
    (hE : ∀ s,matrixActionBound (E s) B)
    (hfirst : ∀ i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ ρ)
    (hread : ∀ i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))| ≤ ρ/N)
    (hbounded : ∀ (x : Cube d) (ss : List (Fin r)) i,
      |ss.foldl (hiddenStep φ v) (firstHidden φ v x) i| ≤ 1)
    (hkill : ∀ (x : Cube d) (ss : List (Fin r)) (s : Fin r) (i : Fin N),
      (∑ j,E s i j*ss.foldl (hiddenStep φ v) (firstHidden φ v x) j)=0)
    (x : Cube d) :
    (networkOutput φ w x-networkOutput φ v x)^2 ≤
      ρ^2*unboundedCylinderOutputFactor d r K G B := by
  have hn : (0 : ℝ)<N := by exact_mod_cast hN
  let u := finalHidden φ w x
  let z := finalHidden φ v x
  let dv := fun i => w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))
  let a := ∑ i,v (Sum.inr (Sum.inr i))*(u i-z i)
  let b := ∑ i,dv i*(u i-z i)
  let c := ∑ i,dv i*z i
  have heq : networkOutput φ w x-networkOutput φ v x=a+b+c := by
    dsimp [networkOutput,a,b,c,dv,u,z]
    simp_rw [mul_sub,sub_mul]
    simp only [Finset.sum_sub_distrib]
    ring
  have hdv : (∑ i,dv i^2) ≤ ρ^2/(N : ℝ) := by
    calc
      _ ≤ ∑ _i : Fin N,(ρ/(N : ℝ))^2 := Finset.sum_le_sum fun i _ => by
        simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg (dv i)) (div_nonneg hρ hn.le)).2 (hread i)
      _ = _ := by simp; field_simp <;> ring
  have hc : |c| ≤ ρ := by
    calc
      _ ≤ ∑ i,|dv i*z i| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _i : Fin N,ρ/(N : ℝ) := Finset.sum_le_sum fun i _ => by
        rw [abs_mul]
        exact (mul_le_mul (hread i) (hbounded x (List.finRange r) i)
          (abs_nonneg _) (div_nonneg hρ hn.le)).trans_eq (mul_one _)
      _ = ρ := by simp [mul_div_cancel₀ ρ hn.ne']
  have hc2 : c^2 ≤ ρ^2 := by simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg c) hρ).2 hc
  have hh := unbounded_cylinder_hiddenFold hφ w v R E hK hG hρ hρ1 hdecomp hv hR hE
    hfirst hbounded hkill (List.finRange r) x
  simp only [List.length_finRange] at hh
  have hnrm := output_squaredNorm_le_of_cost hN v hv
  have ha := (Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun i => v (Sum.inr (Sum.inr i))) (fun i => u i-z i)).trans
    (mul_le_mul hnrm hh (by positivity) (div_nonneg hK hn.le))
  have hb := (Finset.sum_mul_sq_le_sq_mul_sq Finset.univ dv (fun i => u i-z i)).trans
    (mul_le_mul hdv hh (by positivity) (div_nonneg (sq_nonneg ρ) hn.le))
  change a^2 ≤ _ at ha
  change b^2 ≤ _ at hb
  have hcancel (T : ℝ) : T/(N : ℝ)*((N : ℝ)*ρ^2*cylinderInputFactor d*
      (unboundedCylinderAmplification K G B)^r)=
      T*ρ^2*cylinderInputFactor d*(unboundedCylinderAmplification K G B)^r := by field_simp
  rw [hcancel] at ha hb
  have hsmall : ρ^2 ≤ 1 := by nlinarith
  have hfac : 0 ≤ ρ^2*cylinderInputFactor d*(unboundedCylinderAmplification K G B)^r := by
    unfold cylinderInputFactor unboundedCylinderAmplification
    positivity
  have hb' : b^2 ≤ ρ^2*cylinderInputFactor d*(unboundedCylinderAmplification K G B)^r := by
    have hm := mul_le_mul_of_nonneg_right hsmall hfac
    nlinarith
  rw [heq]
  unfold unboundedCylinderOutputFactor
  nlinarith [sq_nonneg (a-b),sq_nonneg (a-c),sq_nonneg (b-c)]

end NeuralGeneralization.BatchTwoMerging
