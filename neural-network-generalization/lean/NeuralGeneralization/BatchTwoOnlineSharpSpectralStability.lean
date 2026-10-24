import NeuralGeneralization.SpectralFunctionClass
import NeuralGeneralization.BatchTwoOnlineSharpMain

/-! Sharp bounded-activation spectral truncation at the exact radius of the
online appendix. Only the readout is rescaled, keeping total energy (L+3)K. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel Compression CompressionSampling

abbrev euclideanNorm {N : ℕ} (z : Fin N→ℝ) : ℝ := ‖(WithLp.toLp 2 z : EuclideanN N)‖

theorem euclideanNorm_sq {N : ℕ} (z : Fin N→ℝ) : euclideanNorm z^2=∑i,z i^2 :=
  EuclideanSpace.real_norm_sq_eq _

theorem euclideanNorm_le_of_sum_sq {N : ℕ} (z : Fin N→ℝ) {A : ℝ}
    (hA : 0≤A) (h : (∑i,z i^2)≤A^2) : euclideanNorm z≤A := by
  rw [←euclideanNorm_sq] at h
  exact (sq_le_sq₀ (norm_nonneg _) hA).mp h

theorem euclideanNorm_add {N : ℕ} (u v : Fin N→ℝ) :
    euclideanNorm (fun i=>u i+v i)≤euclideanNorm u+euclideanNorm v := by
  exact norm_add_le (WithLp.toLp 2 u : EuclideanN N) (WithLp.toLp 2 v)

theorem truncated_step_norm {d N r : ℕ} {K a : ℝ} (hK : 0≤K) (ha : 0≤a)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w : Weights d N r)
    (H : Fin r→Fin N→Fin N→ℝ)
    (hH : ∀s,(∑i,∑j,H s i j^2)≤K)
    (hres : ∀s,matrixActionBound (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-H s i j) a)
    (u z : Fin N→ℝ) (hu : ∀i,|u i|≤1) (s : Fin r) :
    euclideanNorm (fun i=>hiddenStep φ w u s i-hiddenStep φ (truncateInternal w H) z s i)≤
      Real.sqrt K*euclideanNorm (fun i=>u i-z i)+a*Real.sqrt N := by
  let A : Fin N→ℝ:=fun i=>∑j,H s i j*(u j-z j)
  let B : Fin N→ℝ:=fun i=>∑j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j
  have hA : euclideanNorm A≤Real.sqrt K*euclideanNorm (fun i=>u i-z i) := by
    apply euclideanNorm_le_of_sum_sq _ (by positivity)
    rw [mul_pow,Real.sq_sqrt hK,euclideanNorm_sq]
    exact (matrix_action_squaredSum_le (H s) (fun i=>u i-z i)).trans
      (mul_le_mul_of_nonneg_right (hH s) (by positivity))
  have hu2:(∑i,u i^2)≤(N:ℝ):=by
    calc
      _ ≤ ∑_i : Fin N,(1:ℝ):=Finset.sum_le_sum fun i _=>by
        simpa only [sq_abs,one_pow] using (sq_le_sq₀ (abs_nonneg _) (by norm_num : (0:ℝ)≤1)).mpr (hu i)
      _ = _:=by simp
  have hB : euclideanNorm B≤a*Real.sqrt N := by
    apply euclideanNorm_le_of_sum_sq _ (by positivity)
    rw [mul_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
    exact (hres s u).trans (mul_le_mul_of_nonneg_left hu2 (sq_nonneg a))
  have he (i : Fin N) :
      (∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)-(∑j,H s i j*z j)=A i+B i := by
    dsimp [A,B]
    simp_rw [mul_sub,sub_mul]
    simp only [Finset.sum_sub_distrib]
    ring
  have hφnorm : euclideanNorm (fun i=>hiddenStep φ w u s i-hiddenStep φ (truncateInternal w H) z s i)≤
      euclideanNorm (fun i=>A i+B i) := by
    apply euclideanNorm_le_of_sum_sq _ (norm_nonneg _)
    rw [euclideanNorm_sq]
    have hh:=lipschitz_activation_squaredDistance φ hφ.2
      (fun i=>∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j) (fun i=>∑j,H s i j*z j)
    simpa only [squaredDistance,he,hiddenStep,truncateInternal] using hh
  exact hφnorm.trans ((euclideanNorm_add A B).trans (add_le_add hA hB))

theorem truncated_fold_norm {d N r : ℕ} {K a : ℝ} (hK : 1≤K) (ha : 0≤a)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w : Weights d N r)
    (H : Fin r→Fin N→Fin N→ℝ)
    (hH : ∀s,(∑i,∑j,H s i j^2)≤K)
    (hres : ∀s,matrixActionBound (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-H s i j) a)
    (ss : List (Fin r)) (x : Cube d) :
    euclideanNorm (fun i=>ss.foldl (hiddenStep φ w) (firstHidden φ w x) i-
      ss.foldl (hiddenStep φ (truncateInternal w H)) (firstHidden φ w x) i)≤
      (ss.length:ℝ)*a*Real.sqrt N*(Real.sqrt K+1)^(ss.length-1) := by
  have hB:1≤Real.sqrt K+1:=by linarith [Real.sqrt_nonneg K]
  induction ss using List.reverseRecOn with
  | nil => simp [euclideanNorm];rfl
  | append_singleton ss s ih =>
    have hh:=truncated_step_norm (by linarith : 0≤K) ha φ hφ w H hH hres
      (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
      (ss.foldl (hiddenStep φ (truncateInternal w H)) (firstHidden φ w x))
      (fun i=>hiddenFold_bounded φ hφ w ss x i) s
    have hb:=mul_le_mul_of_nonneg_left ih (Real.sqrt_nonneg K)
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,List.length_append,List.length_singleton]
    apply hh.trans
    apply (add_le_add hb le_rfl).trans
    by_cases hs : ss.length=0
    · simp [hs]
    · have hs1:1≤ss.length:=by omega
      have hp:1≤(Real.sqrt K+1)^(ss.length-1):=one_le_pow₀ hB
      have hlen:0≤(ss.length:ℝ):=Nat.cast_nonneg _
      have hfac:0≤a*Real.sqrt (N:ℝ):=by positivity
      have hpow:(Real.sqrt K+1)^ss.length=(Real.sqrt K+1)^(ss.length-1)*(Real.sqrt K+1):=by
        rw [←pow_succ]
        congr 1
        omega
      simp only [Nat.add_sub_cancel,Nat.cast_add,Nat.cast_one,hpow]
      have hh1:=mul_le_mul_of_nonneg_left hp hfac
      have hh2:0≤(ss.length:ℝ)*(Real.sqrt K+1)^(ss.length-1)*(a*Real.sqrt (N:ℝ)):=by positivity
      have hh3:0≤Real.sqrt K*(Real.sqrt K+1)^(ss.length-1)*(a*Real.sqrt (N:ℝ)):=by positivity
      nlinarith

def spectralRadius (r : ℕ) (K : ℝ) : ℝ :=
  (8*((r:ℝ)+2)*(Real.sqrt K+1)^r)⁻¹

theorem spectralRadius_pos (r : ℕ) (K : ℝ) : 0<spectralRadius r K := by
  unfold spectralRadius
  positivity

theorem truncated_output_paper {d N r : ℕ} {K : ℝ} (hN : 0<N) (hK : 1≤K)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w : Weights d N r)
    (H : Fin r→Fin N→Fin N→ℝ)
    (hH : ∀s,(∑i,∑j,H s i j^2)≤K)
    (hres : ∀s,matrixActionBound (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-H s i j) (spectralRadius r K))
    (hread : (N:ℝ)*(∑i,w (Sum.inr (Sum.inr i))^2)≤K) (x : Cube d) :
    |networkOutput φ w x-networkOutput φ (truncateInternal w H) x|≤1/8 := by
  have hn:0<(N:ℝ):=by exact_mod_cast hN
  have hs:0<Real.sqrt (N:ℝ):=Real.sqrt_pos.mpr hn
  have hK0:0≤K:=by linarith
  have hrad:0<spectralRadius r K:=spectralRadius_pos _ _
  have hfold:=truncated_fold_norm hK hrad.le φ hφ w H hH hres (List.finRange r) x
  simp only [List.length_finRange] at hfold
  have hread':(∑i,w (Sum.inr (Sum.inr i))^2)≤K/(N:ℝ):=by
    apply (le_div_iff₀ hn).mpr
    nlinarith only [hread]
  have he:=readout_squaredDistance_le (fun i=>w (Sum.inr (Sum.inr i)))
    (finalHidden φ w x) (finalHidden φ (truncateInternal w H) x)
  have hdist:squaredDistance (finalHidden φ w x) (finalHidden φ (truncateInternal w H) x)≤
      ((r:ℝ)*spectralRadius r K*Real.sqrt N*(Real.sqrt K+1)^(r-1))^2 := by
    unfold squaredDistance
    rw [←euclideanNorm_sq]
    apply (sq_le_sq₀ (norm_nonneg _) (by positivity)).mpr
    exact hfold
  have hout:(networkOutput φ w x-networkOutput φ (truncateInternal w H) x)^2≤
      (K/(N:ℝ))*((r:ℝ)*spectralRadius r K*Real.sqrt N*(Real.sqrt K+1)^(r-1))^2 :=
    he.trans (mul_le_mul hread' hdist (by positivity) (div_nonneg hK0 hn.le))
  have hcancel:(K/(N:ℝ))*((r:ℝ)*spectralRadius r K*Real.sqrt N*(Real.sqrt K+1)^(r-1))^2=
      ((r:ℝ)*spectralRadius r K*Real.sqrt K*(Real.sqrt K+1)^(r-1))^2 := by
    rw [mul_pow,mul_pow,mul_pow,mul_pow,mul_pow,mul_pow,Real.sq_sqrt hn.le,Real.sq_sqrt hK0]
    field_simp
  rw [hcancel] at hout
  have hscalar:(r:ℝ)*spectralRadius r K*Real.sqrt K*(Real.sqrt K+1)^(r-1)≤1/8 := by
    by_cases hr:r=0
    · simp [hr]
    · have he:(Real.sqrt K+1)^r=(Real.sqrt K+1)*(Real.sqrt K+1)^(r-1):=by
        rw [←pow_succ']
        congr 1
        omega
      have hl:Real.sqrt K*(Real.sqrt K+1)^(r-1)≤(Real.sqrt K+1)^r:=by
        rw [he]
        gcongr
        linarith
      calc
        _ ≤ (r:ℝ)*spectralRadius r K*(Real.sqrt K+1)^r := by nlinarith [mul_le_mul_of_nonneg_left hl (show 0≤(r:ℝ)*spectralRadius r K by positivity)]
        _ = (r:ℝ)/(8*((r:ℝ)+2)) := by unfold spectralRadius;field_simp
        _ ≤ 1/8 := by apply (div_le_iff₀ (by positivity : 0<8*((r:ℝ)+2))).mpr;linarith
  apply abs_le_of_sq_le_sq (hout.trans ((sq_le_sq₀ (by positivity) (by norm_num : (0:ℝ)≤1/8)).mpr hscalar)) (by norm_num)

/-- Actual same-width representative; rescaling only its readout gives the
exact (L+3)K energy bound used by the online appendix. -/
theorem truncated_energy_witness {d N r : ℕ} {K : ℝ} (hN : 0<N) (hK : 1≤K)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (w : Weights d N r) (hw : w∈marginEvent φ (1/2) f)
    (H : Fin r→Fin N→Fin N→ℝ)
    (hfirst : (d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)≤K)
    (hread : (N:ℝ)*(∑i,w (Sum.inr (Sum.inr i))^2)≤K)
    (hH : ∀s,(∑i,∑j,H s i j^2)≤K)
    (hres : ∀s,matrixActionBound (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-H s i j) (spectralRadius r K)) :
    ∃v : Weights d N r,v∈marginEvent φ (1/2) f ∧ weightedSquaredNorm v≤((r:ℝ)+5)*K := by
  let v:=rescaleReadout 2 (truncateInternal w H)
  refine ⟨v,?_,?_⟩
  · intro x
    have hm:=hw x
    have he:=truncated_output_paper hN hK φ hφ w H hH hres hread x
    have habs:|labelReal (f x)*(networkOutput φ w x-networkOutput φ (truncateInternal w H) x)|≤1/8 := by
      simpa only [abs_mul,abs_labelReal,one_mul] using he
    have hl:=(abs_le.mp habs).2
    change 1/2<labelReal (f x)*networkOutput φ (rescaleReadout 2 (truncateInternal w H)) x
    rw [rescaleReadout_output]
    nlinarith
  · have hi:(∑s,∑i,∑j,H s i j^2)≤(r:ℝ)*K:=by
      calc
        _ ≤ ∑_s:Fin r,K:=Finset.sum_le_sum (fun s _=>hH s)
        _ = _:=by simp
    change weightedSquaredNorm (rescaleReadout 2 (truncateInternal w H))≤_
    simp only [weightedSquaredNorm,rescaleReadout,truncateInternal,mul_pow,←Finset.mul_sum]
    nlinarith only [hfirst,hread,hi]

end NeuralGeneralization.BatchTwoOnlineSharp
