import NeuralGeneralization.CylinderGeometry
import NeuralGeneralization.NormCompression

/-!
# Actual network truncation outside a small operator-norm bulk

An internal matrix is replaced by a matrix of bounded Frobenius energy.
Its residual needs only a small operator norm. Bounded hidden activations make
the resulting approximation uniform over the entire Boolean cube.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
open NeuralGeneralization.Compression NeuralGeneralization.CompressionSampling

variable {d N r : ℕ}

def truncateInternal (w : Weights d N r) (H : Fin r → Fin N → Fin N → ℝ) :
    Weights d N r
  | Sum.inl ij => w (Sum.inl ij)
  | Sum.inr (Sum.inl (s,i,j)) => H s i j
  | Sum.inr (Sum.inr i) => w (Sum.inr (Sum.inr i))

@[simp] theorem truncateInternal_firstHidden (φ : ℝ → ℝ) (w : Weights d N r)
    (H : Fin r → Fin N → Fin N → ℝ) (x : Cube d) :
    firstHidden φ (truncateInternal w H) x = firstHidden φ w x := rfl

/-- The actual weighted cost of the truncated network is small. -/
theorem truncateInternal_cost_le (w : Weights d N r)
    (H : Fin r → Fin N → Fin N → ℝ) (K : ℝ)
    (hfirst : (d:ℝ)/N*(∑ i,∑ j,w (Sum.inl (i,j))^2) ≤ K)
    (hread : (N:ℝ)*(∑ i,w (Sum.inr (Sum.inr i))^2) ≤ K)
    (hH : ∀ s, (∑ i,∑ j,H s i j^2) ≤ K) :
    weightedSquaredNorm (truncateInternal w H) ≤ ((r:ℝ)+2)*K := by
  have hint : (∑ s,∑ i,∑ j,H s i j^2) ≤ (r:ℝ)*K := by
    calc
      _ ≤ ∑ _ : Fin r,K := Finset.sum_le_sum fun s _ => hH s
      _ = _ := by simp
  unfold weightedSquaredNorm
  simp only [truncateInternal]
  linarith

/-- One actual layer of the truncated network has a width-normalized error
recurrence driven by the residual operator norm. -/
theorem truncated_hiddenStep_error (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (H : Fin r → Fin N → Fin N → ℝ) (K a : ℝ)
    (hH : ∀ s, (∑ i,∑ j,H s i j^2) ≤ K)
    (hres : ∀ s, matrixActionBound
      (fun i j => w (Sum.inr (Sum.inl (s,i,j)))-H s i j) a)
    (u z : Fin N → ℝ) (hu : ∀ i, |u i| ≤ 1) (s : Fin r) :
    squaredDistance (hiddenStep φ w u s) (hiddenStep φ (truncateInternal w H) z s) ≤
      2*K*squaredDistance u z+2*a^2*N := by
  have hdiff (i : Fin N) :
      (∑ j,w (Sum.inr (Sum.inl (s,i,j)))*u j)-(∑ j,H s i j*z j) =
      (∑ j,H s i j*(u j-z j))+
      (∑ j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j) := by
    simp_rw [mul_sub,sub_mul]
    simp only [Finset.sum_sub_distrib]
    ring
  have hnormu : (∑ i,u i^2) ≤ (N:ℝ) := by
    calc
      _ ≤ ∑ _ : Fin N,(1:ℝ) := Finset.sum_le_sum fun i _ => by
        simpa only [sq_abs,one_pow] using
          (sq_le_sq₀ (abs_nonneg (u i)) (by norm_num : (0:ℝ) ≤ 1)).2 (hu i)
      _ = _ := by simp
  have hT := (matrix_action_squaredSum_le (H s) (fun i => u i-z i)).trans
    (mul_le_mul_of_nonneg_right (hH s) (by positivity))
  have hR := (hres s u).trans (mul_le_mul_of_nonneg_left hnormu (sq_nonneg a))
  calc
    _ ≤ ∑ i,((∑ j,w (Sum.inr (Sum.inl (s,i,j)))*u j)-(∑ j,H s i j*z j))^2 :=
      lipschitz_activation_squaredDistance φ hφ.2 _ _
    _ = ∑ i,((∑ j,H s i j*(u j-z j))+
      (∑ j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j))^2 := by simp_rw [hdiff]
    _ ≤ 2*(∑ i,(∑ j,H s i j*(u j-z j))^2)+
      2*(∑ i,(∑ j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j)^2) := by
      calc
        _ ≤ ∑ i, (2*(∑ j,H s i j*(u j-z j))^2+
          2*(∑ j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j)^2) := by
          apply Finset.sum_le_sum
          intro i hi
          nlinarith [sq_nonneg ((∑ j,H s i j*(u j-z j))-
            (∑ j,(w (Sum.inr (Sum.inl (s,i,j)))-H s i j)*u j))]
        _ = _ := by simp only [Finset.sum_add_distrib,Finset.mul_sum]
    _ ≤ _ := by unfold squaredDistance; nlinarith

/-- The full hidden-state error after any list of internal layers. -/
theorem truncated_hiddenFold_error (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (H : Fin r → Fin N → Fin N → ℝ) (K a : ℝ)
    (hK : 0 ≤ K) (hH : ∀ s, (∑ i,∑ j,H s i j^2) ≤ K)
    (hres : ∀ s, matrixActionBound
      (fun i j => w (Sum.inr (Sum.inl (s,i,j)))-H s i j) a)
    (ss : List (Fin r)) (x : Cube d) :
    squaredDistance
      (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
      (ss.foldl (hiddenStep φ (truncateInternal w H)) (firstHidden φ w x)) ≤
      (N:ℝ)*a^2*(2*K+3)^ss.length := by
  have hA : 1 ≤ 2*K+3 := by linarith
  have hQ : 0 ≤ (N:ℝ)*a^2 := by positivity
  induction ss using List.reverseRecOn with
  | nil => simp only [List.foldl_nil,List.length_nil,pow_zero,mul_one,squaredDistance,sub_self,zero_pow (by norm_num : 2 ≠ 0),Finset.sum_const_zero]; exact hQ
  | append_singleton ss s ih =>
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,
      List.length_append,List.length_singleton,pow_add,pow_one]
    have hs := truncated_hiddenStep_error φ hφ w H K a hH hres
      (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
      (ss.foldl (hiddenStep φ (truncateInternal w H)) (firstHidden φ w x))
      (fun i => hiddenFold_bounded φ hφ w ss x i) s
    have hp : 1 ≤ (2*K+3)^ss.length := one_le_pow₀ hA
    have hlarge : (N:ℝ)*a^2 ≤ (N:ℝ)*a^2*(2*K+3)^ss.length := by
      simpa only [mul_one] using mul_le_mul_of_nonneg_left hp hQ
    have hi := mul_le_mul_of_nonneg_left ih (by positivity : 0 ≤ 2*K)
    nlinarith

/-- No width factor remains in the output error. -/
theorem truncated_networkOutput_error_sq (hN : 0 < N)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (H : Fin r → Fin N → Fin N → ℝ) (K a : ℝ)
    (hK : 0 ≤ K) (hH : ∀ s, (∑ i,∑ j,H s i j^2) ≤ K)
    (hres : ∀ s, matrixActionBound
      (fun i j => w (Sum.inr (Sum.inl (s,i,j)))-H s i j) a)
    (hread : (N:ℝ)*(∑ i,w (Sum.inr (Sum.inr i))^2) ≤ K) (x : Cube d) :
    (networkOutput φ w x-networkOutput φ (truncateInternal w H) x)^2 ≤
      K*a^2*(2*K+3)^r := by
  have hNR : 0 < (N:ℝ) := by exact_mod_cast hN
  have hread' : (∑ i,w (Sum.inr (Sum.inr i))^2) ≤ K/(N:ℝ) := by
    apply (le_div_iff₀ hNR).2
    simpa only [mul_comm] using hread
  have hh := truncated_hiddenFold_error φ hφ w H K a hK hH hres (List.finRange r) x
  simp only [List.length_finRange] at hh
  have he := (readout_squaredDistance_le
    (fun i => w (Sum.inr (Sum.inr i))) (finalHidden φ w x)
      (finalHidden φ (truncateInternal w H) x)).trans
    (mul_le_mul hread' hh (by positivity) (div_nonneg hK hNR.le))
  have hcancel : (K/(N:ℝ))*((N:ℝ)*a^2*(2*K+3)^r) = K*a^2*(2*K+3)^r := by field_simp
  rw [hcancel] at he
  exact he

/-- The threshold has reciprocal polynomial complexity at every fixed depth. -/
def spectralTruncationRadius (r : ℕ) (K : ℝ) : ℝ :=
  (12*(K*(2*K+3)^r+1))⁻¹

theorem spectralTruncationRadius_pos (r : ℕ) {K : ℝ} (hK : 0 ≤ K) :
    0 < spectralTruncationRadius r K := by unfold spectralTruncationRadius; positivity

/-- A sufficiently small operator bulk changes the actual network by at most 1/12. -/
theorem truncated_networkOutput_error (hN : 0 < N)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (H : Fin r → Fin N → Fin N → ℝ) (K : ℝ)
    (hK : 0 ≤ K) (hH : ∀ s, (∑ i,∑ j,H s i j^2) ≤ K)
    (hres : ∀ s, matrixActionBound
      (fun i j => w (Sum.inr (Sum.inl (s,i,j)))-H s i j) (spectralTruncationRadius r K))
    (hread : (N:ℝ)*(∑ i,w (Sum.inr (Sum.inr i))^2) ≤ K) (x : Cube d) :
    |networkOutput φ (truncateInternal w H) x-networkOutput φ w x| ≤ 1/12 := by
  let P := K*(2*K+3)^r+1
  have hp : 0 ≤ K*(2*K+3)^r := by positivity
  have hP : 0 < P := by dsimp [P]; linarith
  have hnum : K*(spectralTruncationRadius r K)^2*(2*K+3)^r ≤ (1/12:ℝ)^2 := by
    change K*(12*P)⁻¹^2*(2*K+3)^r ≤ (1/12:ℝ)^2
    have heq : K*(12*P)⁻¹^2*(2*K+3)^r = (K*(2*K+3)^r)/(144*P^2) := by field_simp; ring
    rw [heq]
    apply (div_le_iff₀ (by positivity : 0 < 144*P^2)).2
    dsimp [P]
    nlinarith [sq_nonneg (K*(2*K+3)^r)]
  have hh := truncated_networkOutput_error_sq hN φ hφ w H K
    (spectralTruncationRadius r K) hK hH hres hread x
  rw [abs_sub_comm]
  exact abs_le_of_sq_le_sq (hh.trans hnum) (by norm_num)

/-- Norm compression applies to every function represented by a network whose
large singular-direction energy satisfies the stated finite bounds. -/
theorem spectral_truncation_compressed {K : ℕ} (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (w : Weights d N r) (hw : w ∈ marginEvent φ (1/2) f)
    (H : Fin r → Fin N → Fin N → ℝ)
    (hfirst : (d:ℝ)/N*(∑ i,∑ j,w (Sum.inl (i,j))^2) ≤ (K:ℝ))
    (hread : (N:ℝ)*(∑ i,w (Sum.inr (Sum.inr i))^2) ≤ (K:ℝ))
    (hH : ∀ s, (∑ i,∑ j,H s i j^2) ≤ (K:ℝ))
    (hres : ∀ s, matrixActionBound
      (fun i j => w (Sum.inr (Sum.inl (s,i,j)))-H s i j) (spectralTruncationRadius r K)) :
    ∃ v : Weights d (compressionWidth d r (9*(r+2)*K)) r,
      v ∈ marginEvent φ (1/2) f ∧ boundedWeights (compressionWidth d r (9*(r+2)*K)) v := by
  let v := truncateInternal w H
  have hv := rescaleReadout_preserves_margin φ f w v hw
    (truncated_networkOutput_error hN φ hφ w H K (Nat.cast_nonneg K) hH hres hread)
  have hcost : weightedSquaredNorm (rescaleReadout (3/2) v) ≤ (9*(r+2)*K:ℕ) := by
    have ht := truncateInternal_cost_le w H K hfirst hread hH
    have hs := rescaleReadout_cost_le (show (1:ℝ) ≤ 3/2 by norm_num) v
    have hnn := weightedSquaredNorm_nonneg v
    push_cast
    dsimp [v] at hs hnn
    nlinarith
  have hbudget : 1 ≤ 9*(r+2)*K := by nlinarith
  obtain ⟨u,hu,hbound,_⟩ := norm_compression hd hN hbudget φ hφ f
    (rescaleReadout (3/2) v) hcost hv
  exact ⟨u,hu,hbound⟩

end NeuralGeneralization.ConcreteModel
