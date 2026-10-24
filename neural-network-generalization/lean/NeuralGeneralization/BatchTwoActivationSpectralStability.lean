import NeuralGeneralization.BatchTwoActivationStatements
import NeuralGeneralization.SpectralFunctionClass

/-! Spectral truncation for every zero-at-zero Lipschitz activation. The proof
controls the total squared hidden norm, without bounding individual neurons. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel Compression CompressionSampling
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {d N r:ℕ} {φ:ℝ→ℝ} {ℓ K a:ℝ}

def spectralInputFactor (d:ℕ) (ℓ K:ℝ):ℝ := ℓ^2*((d:ℝ)+1)*K
def spectralAmplification (ℓ K:ℝ):ℝ := 2*ℓ^2*(K+1)+1

theorem activation_squared_norm (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ)
    {ι:Type*} [Fintype ι] (u:ι→ℝ):
    (∑i,(φ (u i))^2)≤ℓ^2*∑i,u i^2 := by
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  simpa only [sq_abs,mul_pow] using
    (sq_le_sq₀ (abs_nonneg _) (mul_nonneg hℓ (abs_nonneg _))).mpr (activation_abs_le hφ (u i))

theorem activation_squared_distance (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ)
    {ι:Type*} [Fintype ι] (u v:ι→ℝ):
    (∑i,(φ (u i)-φ (v i))^2)≤ℓ^2*∑i,(u i-v i)^2 := by
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  simpa only [sq_abs,mul_pow] using
    (sq_le_sq₀ (abs_nonneg _) (mul_nonneg hℓ (abs_nonneg _))).mpr (hφ.2 (u i) (v i))

theorem spectral_firstHidden_squared (hd:1≤d) (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) (w:Weights d N r)
    (hfirst:(d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)≤K) (x:Cube d):
    (∑i,(firstHidden φ w x i)^2)≤(N:ℝ)*spectralInputFactor d ℓ K := by
  have hn:(0:ℝ)<N:=by exact_mod_cast hN
  have hd1:(1:ℝ)≤d:=by exact_mod_cast hd
  have hsum:0≤∑i,∑j,w (Sum.inl (i,j))^2:=by positivity
  have hh:=mul_le_mul_of_nonneg_right hfirst hn.le
  have he:(d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)*N=
      (d:ℝ)*(∑i,∑j,w (Sum.inl (i,j))^2):=by field_simp
  rw [he] at hh
  have hf:(∑i,∑j,w (Sum.inl (i,j))^2)≤(N:ℝ)*K:=by nlinarith
  have hi:(∑j,(inputVector x j)^2)=(d:ℝ)+1:=by
    calc
      _ = ∑_j:Fin (d+1),(1:ℝ):=by
        apply Finset.sum_congr rfl
        intro j _
        rw [←sq_abs,abs_inputVector]
        norm_num
      _ = _:=by simp
  have hm:=(matrix_action_squaredSum_le (fun i j=>w (Sum.inl (i,j))) (inputVector x)).trans
    (mul_le_mul_of_nonneg_right hf (by positivity))
  rw [hi] at hm
  have hh:=(activation_squared_norm hφ hℓ (fun i=>∑j,w (Sum.inl (i,j))*inputVector x j)).trans
    (mul_le_mul_of_nonneg_left hm (sq_nonneg ℓ))
  exact hh.trans_eq (by unfold spectralInputFactor;ring)

theorem spectral_hiddenStep_squared (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ)
    (w:Weights d N r) (H:Fin r→Fin N→Fin N→ℝ)
    (hH:∀s,(∑i,∑j,H s i j^2)≤K)
    (hres:∀s,matrixActionBound (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-H s i j) a)
    (u:Fin N→ℝ) (s:Fin r):
    (∑i,(hiddenStep φ w u s i)^2)≤2*ℓ^2*(K+a^2)*(∑i,u i^2) := by
  have ht:=(matrix_action_squaredSum_le (H s) u).trans
    (mul_le_mul_of_nonneg_right (hH s) (by positivity))
  have hr:=hres s u
  have he (i:Fin N): (∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)=
      (∑j,H s i j*u j)+(∑j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j):=by
    simp_rw [sub_mul];rw [Finset.sum_sub_distrib];ring
  have hs:(∑i,(∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)^2)≤
      2*(∑i,(∑j,H s i j*u j)^2)+2*(∑i,(∑j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j)^2):=by
    simp_rw [he]
    calc
      _ ≤ ∑i,(2*(∑j,H s i j*u j)^2+2*(∑j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j)^2):=by
        apply Finset.sum_le_sum
        intro i _
        nlinarith [sq_nonneg ((∑j,H s i j*u j)-(∑j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j))]
      _ = _:=by rw [Finset.sum_add_distrib,←Finset.mul_sum,←Finset.mul_sum]
  have hs':(∑i,(∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)^2)≤2*(K+a^2)*(∑i,u i^2):=by
    nlinarith only [ht,hr,hs]
  have ha:=(activation_squared_norm hφ hℓ (fun i=>∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)).trans
    (mul_le_mul_of_nonneg_left hs' (sq_nonneg ℓ))
  exact ha.trans_eq (by ring)

theorem spectral_hiddenStep_error (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ)
    (w:Weights d N r) (H:Fin r→Fin N→Fin N→ℝ)
    (hH:∀s,(∑i,∑j,H s i j^2)≤K)
    (hres:∀s,matrixActionBound (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-H s i j) a)
    (u z:Fin N→ℝ) (s:Fin r):
    squaredDistance (hiddenStep φ w u s) (hiddenStep φ (truncateInternal w H) z s)≤
      2*ℓ^2*K*squaredDistance u z+2*ℓ^2*a^2*(∑i,u i^2) := by
  have ht:=(matrix_action_squaredSum_le (H s) (fun i=>u i-z i)).trans
    (mul_le_mul_of_nonneg_right (hH s) (by positivity))
  have hr:=hres s u
  have he (i:Fin N): (∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)-(∑j,H s i j*z j)=
      (∑j,H s i j*(u j-z j))+(∑j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j):=by
    simp_rw [sub_mul,mul_sub];simp only [Finset.sum_sub_distrib];ring
  have hs:(∑i,((∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)-(∑j,H s i j*z j))^2)≤
      2*(∑i,(∑j,H s i j*(u j-z j))^2)+2*(∑i,(∑j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j)^2):=by
    simp_rw [he]
    calc
      _ ≤ ∑i,(2*(∑j,H s i j*(u j-z j))^2+2*(∑j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j)^2):=by
        apply Finset.sum_le_sum
        intro i _
        nlinarith [sq_nonneg ((∑j,H s i j*(u j-z j))-(∑j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j))]
      _ = _:=by rw [Finset.sum_add_distrib,←Finset.mul_sum,←Finset.mul_sum]
  have hs':(∑i,((∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)-(∑j,H s i j*z j))^2)≤
      2*K*squaredDistance u z+2*a^2*(∑i,u i^2):=by
    unfold squaredDistance
    nlinarith only [ht,hr,hs]
  have ha:=(activation_squared_distance hφ hℓ
    (fun i=>∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j) (fun i=>∑j,H s i j*z j)).trans
      (mul_le_mul_of_nonneg_left hs' (sq_nonneg ℓ))
  exact ha.trans_eq (by ring)


theorem spectral_hiddenFold_bounds (hd:1≤d) (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) (hK:0≤K) (ha:0≤a) (ha1:a≤1)
    (w:Weights d N r) (H:Fin r→Fin N→Fin N→ℝ)
    (hfirst:(d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)≤K)
    (hH:∀s,(∑i,∑j,H s i j^2)≤K)
    (hres:∀s,matrixActionBound (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-H s i j) a)
    (ss:List (Fin r)) (x:Cube d):
    (∑i,(ss.foldl (hiddenStep φ w) (firstHidden φ w x) i)^2)≤
      (N:ℝ)*spectralInputFactor d ℓ K*(spectralAmplification ℓ K)^ss.length ∧
    squaredDistance (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
      (ss.foldl (hiddenStep φ (truncateInternal w H)) (firstHidden φ w x))≤
      (N:ℝ)*a^2*spectralInputFactor d ℓ K*(spectralAmplification ℓ K)^ss.length := by
  have hF:0≤spectralInputFactor d ℓ K:=by unfold spectralInputFactor;positivity
  have hB:1≤spectralAmplification ℓ K:=by
    unfold spectralAmplification
    have hh:0≤2*ℓ^2*(K+1):=by positivity
    linarith
  have ha2:a^2≤1:=by nlinarith
  induction ss using List.reverseRecOn with
  | nil =>
    simp only [List.foldl_nil,List.length_nil,pow_zero,mul_one]
    refine ⟨spectral_firstHidden_squared hd hN hφ hℓ w hfirst x,?_⟩
    simp only [squaredDistance,sub_self,zero_pow (by decide : 2≠0),Finset.sum_const_zero]
    positivity
  | append_singleton ss s ih =>
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,List.length_append,List.length_singleton,pow_add,pow_one]
    have hM:0≤(N:ℝ)*spectralInputFactor d ℓ K*(spectralAmplification ℓ K)^ss.length:=by positivity
    have hMa:0≤(N:ℝ)*a^2*spectralInputFactor d ℓ K*(spectralAmplification ℓ K)^ss.length:=by positivity
    constructor
    · have hh:=(spectral_hiddenStep_squared hφ hℓ w H hH hres
        (ss.foldl (hiddenStep φ w) (firstHidden φ w x)) s).trans
        (mul_le_mul_of_nonneg_left ih.1 (by positivity : 0≤2*ℓ^2*(K+a^2)))
      have hc:2*ℓ^2*(K+a^2)≤spectralAmplification ℓ K:=by
        unfold spectralAmplification
        nlinarith [mul_le_mul_of_nonneg_left ha2 (sq_nonneg ℓ)]
      exact hh.trans ((mul_le_mul_of_nonneg_right hc hM).trans_eq (by ring))
    · have hh:=spectral_hiddenStep_error hφ hℓ w H hH hres
        (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
        (ss.foldl (hiddenStep φ (truncateInternal w H)) (firstHidden φ w x)) s
      have hh':=add_le_add
        (mul_le_mul_of_nonneg_left ih.2 (by positivity : 0≤2*ℓ^2*K))
        (mul_le_mul_of_nonneg_left ih.1 (by positivity : 0≤2*ℓ^2*a^2))
      apply (hh.trans hh').trans
      unfold spectralAmplification at *
      nlinarith only [hMa]

theorem spectral_networkOutput_error_sq (hd:1≤d) (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) (hK:0≤K) (ha:0≤a) (ha1:a≤1)
    (w:Weights d N r) (H:Fin r→Fin N→Fin N→ℝ)
    (hfirst:(d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)≤K)
    (hread:(N:ℝ)*(∑i,w (Sum.inr (Sum.inr i))^2)≤K)
    (hH:∀s,(∑i,∑j,H s i j^2)≤K)
    (hres:∀s,matrixActionBound (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-H s i j) a)
    (x:Cube d):
    (networkOutput φ w x-networkOutput φ (truncateInternal w H) x)^2≤
      K*a^2*spectralInputFactor d ℓ K*(spectralAmplification ℓ K)^r := by
  have hn:(0:ℝ)<N:=by exact_mod_cast hN
  have hr:(∑i,w (Sum.inr (Sum.inr i))^2)≤K/(N:ℝ):=by
    apply (le_div_iff₀ hn).mpr
    nlinarith only [hread]
  have hh:=(spectral_hiddenFold_bounds hd hN hφ hℓ hK ha ha1 w H hfirst hH hres (List.finRange r) x).2
  simp only [List.length_finRange] at hh
  have he:=(readout_squaredDistance_le
    (fun i=>w (Sum.inr (Sum.inr i))) (finalHidden φ w x)
      (finalHidden φ (truncateInternal w H) x)).trans
    (mul_le_mul hr hh (by positivity) (div_nonneg hK hn.le))
  exact he.trans_eq (by field_simp)

def activationSpectralRadius (d r:ℕ) (ℓ K:ℝ):ℝ :=
  (12*(K*spectralInputFactor d ℓ K*(spectralAmplification ℓ K)^r+1))⁻¹

theorem activationSpectralRadius_bounds (d r:ℕ) (ℓ:ℝ) {K:ℝ} (hK:0≤K):
    0<activationSpectralRadius d r ℓ K ∧ activationSpectralRadius d r ℓ K≤1 := by
  have hF:0≤spectralInputFactor d ℓ K:=by unfold spectralInputFactor;positivity
  have hB:0≤spectralAmplification ℓ K:=by unfold spectralAmplification;positivity
  have hP:0≤K*spectralInputFactor d ℓ K*(spectralAmplification ℓ K)^r:=by positivity
  unfold activationSpectralRadius
  constructor
  · positivity
  · apply inv_le_one_of_one_le₀
    linarith

theorem spectral_networkOutput_error (hd:1≤d) (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) (hK:0≤K)
    (w:Weights d N r) (H:Fin r→Fin N→Fin N→ℝ)
    (hfirst:(d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)≤K)
    (hread:(N:ℝ)*(∑i,w (Sum.inr (Sum.inr i))^2)≤K)
    (hH:∀s,(∑i,∑j,H s i j^2)≤K)
    (hres:∀s,matrixActionBound (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-H s i j)
      (activationSpectralRadius d r ℓ K)) (x:Cube d):
    |networkOutput φ (truncateInternal w H) x-networkOutput φ w x|≤1/12 := by
  have hb:=activationSpectralRadius_bounds d r ℓ hK
  have hh:=spectral_networkOutput_error_sq hd hN hφ hℓ hK hb.1.le hb.2 w H hfirst hread hH hres x
  let P:=K*spectralInputFactor d ℓ K*(spectralAmplification ℓ K)^r
  have hP:0≤P:=by dsimp [P,spectralInputFactor,spectralAmplification];positivity
  have hnum:K*(activationSpectralRadius d r ℓ K)^2*spectralInputFactor d ℓ K*
      (spectralAmplification ℓ K)^r≤(1/12:ℝ)^2:=by
    have he:K*(activationSpectralRadius d r ℓ K)^2*spectralInputFactor d ℓ K*
        (spectralAmplification ℓ K)^r=P/(144*(P+1)^2):=by
      dsimp [P,activationSpectralRadius]
      field_simp
      <;> ring
    rw [he]
    apply (div_le_iff₀ (by positivity : 0<144*(P+1)^2)).mpr
    nlinarith [sq_nonneg P]
  rw [abs_sub_comm]
  exact abs_le_of_sq_le_sq (hh.trans hnum) (by norm_num)

end NeuralGeneralization.BatchTwoActivation
