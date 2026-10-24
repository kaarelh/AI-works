import NeuralGeneralization.BatchTwoActivationWeightedRows
import NeuralGeneralization.SamplingNetwork

/-!
# The original network is exactly a bounded normalized network

This is an algebraic change of variables for the capacity proof. It changes
neither the actual prior nor the learner activation. Dependence on learner
width disappears from the final readout scale.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel CompressionSampling

variable {d N r : ℕ}

abbrev concreteWidth (d N : ℕ) : ℕ → ℕ
  | 0 => d+1
  | _+1 => N

def concreteRows (w : Weights d N r) (K : ℝ) :
    ∀ s, Fin (concreteWidth d N (s+1)) → EuclideanSpace ℝ (Fin (concreteWidth d N s))
  | 0 => normalizedFirstRow w K
  | s+1 => if hs : s<r then normalizedInternalRow w K ⟨s,hs⟩ else fun _ => 0

def concreteActivation {φ : ℝ → ℝ} {ℓ K : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hK : 0<K) (N s : ℕ) :
    UnitActivation := normalizedUnitActivation hφ hℓ
      (show 0 ≤ Real.sqrt N*K*(ℓ*K)^s by positivity)

theorem concreteRows_frobenius (hd : 1≤d) (hN : 0<N)
    (w : Weights d N r) {K : ℝ} (hK : 1≤K) (hw : weightedSquaredNorm w≤K)
    (s : ℕ) : (∑ i, ‖concreteRows w K s i‖^2) ≤ 1 := by
  cases s with
  | zero => exact normalizedFirstRow_frobenius hd hN w hK hw
  | succ s =>
    dsimp [concreteRows]
    split_ifs with hs
    · exact normalizedInternalRow_frobenius w hK hw ⟨s,hs⟩
    · simp

def concreteInput (x : Cube d) : EuclideanSpace ℝ (Fin (d+1)) :=
  WithLp.toLp 2 (inputVector x)

theorem concreteInput_abs_le (x : Cube d) (i : Fin (d+1)) :
    |concreteInput x i|≤1 := by
  refine Fin.cases ?_ (fun j => ?_) i
  · norm_num [concreteInput, inputVector]
  · simp [concreteInput, inputVector]

theorem concreteInput_norm_le (x : Cube d) : ‖concreteInput x‖≤(d:ℝ)+1 := by
  have hs : ‖concreteInput x‖^2 ≤ (d:ℝ)+1 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    calc
      _ ≤ ∑ _i : Fin (d+1), (1:ℝ) := by
        apply Finset.sum_le_sum
        intro i _
        simpa only [sq_abs, one_pow] using
          pow_le_pow_left₀ (abs_nonneg _) (concreteInput_abs_le x i) 2
      _ = _ := by simp
  have hd : (0:ℝ)≤d := Nat.cast_nonneg _
  nlinarith [norm_nonneg (concreteInput x)]

theorem concrete_first_identity {φ : ℝ → ℝ} {ℓ K : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hK : 0<K) (hN : 0<N)
    (w : Weights d N r) (x : Cube d) (j : Fin N) :
    (concreteActivation hφ hℓ hK N 0).val
        ⟪normalizedFirstRow w K j, concreteInput x⟫ =
      firstHidden φ w x j/(Real.sqrt N*(ℓ*K)) := by
  have hs : Real.sqrt (N:ℝ)≠0 := (Real.sqrt_pos.mpr (by exact_mod_cast hN)).ne'
  change φ ((Real.sqrt N*K*(ℓ*K)^0)*
      ⟪normalizedFirstRow w K j, concreteInput x⟫)/
      (ℓ*(Real.sqrt N*K*(ℓ*K)^0)) = _
  have hi : ⟪normalizedFirstRow w K j, concreteInput x⟫ =
      (∑ k, w (Sum.inl (j,k))*inputVector x k)/(Real.sqrt N*K) := by
    simp only [PiLp.inner_apply, RCLike.inner_apply, normalizedFirstRow,
      concreteInput, PiLp.toLp_apply, conj_trivial]
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro k _
    ring
  rw [hi]
  simp only [pow_zero, mul_one]
  rw [mul_div_cancel₀ _ (mul_ne_zero hs hK.ne')]
  unfold firstHidden
  congr 1
  ring

theorem concrete_internal_identity {φ : ℝ → ℝ} {ℓ K : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hK : 0<K) (hN : 0<N)
    (w : Weights d N r) (s : Fin r) (v : Fin N→ℝ) (j : Fin N) :
    (concreteActivation hφ hℓ hK N (s.val+1)).val
      ⟪normalizedInternalRow w K s j,
        WithLp.toLp 2 (fun k => v k/(Real.sqrt N*(ℓ*K)^(s.val+1)))⟫ =
      hiddenStep φ w v s j/(Real.sqrt N*(ℓ*K)^(s.val+2)) := by
  have hs : Real.sqrt (N:ℝ)≠0 := (Real.sqrt_pos.mpr (by exact_mod_cast hN)).ne'
  have hp : (ℓ*K)^(s.val+1)≠0 := pow_ne_zero _ (mul_ne_zero hℓ.ne' hK.ne')
  change φ ((Real.sqrt N*K*(ℓ*K)^(s.val+1))*
      ⟪normalizedInternalRow w K s j,
        WithLp.toLp 2 (fun k => v k/(Real.sqrt N*(ℓ*K)^(s.val+1)))⟫)/
      (ℓ*(Real.sqrt N*K*(ℓ*K)^(s.val+1))) = _
  have hi : ⟪normalizedInternalRow w K s j,
        WithLp.toLp 2 (fun k => v k/(Real.sqrt N*(ℓ*K)^(s.val+1)))⟫ =
      (∑ k, w (Sum.inr (Sum.inl (s,j,k)))*v k)/
        (Real.sqrt N*K*(ℓ*K)^(s.val+1)) := by
    simp only [PiLp.inner_apply, RCLike.inner_apply, normalizedInternalRow,
      PiLp.toLp_apply, conj_trivial]
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro k _
    field_simp
    <;> ring
  rw [hi, mul_div_cancel₀ _ (mul_ne_zero (mul_ne_zero hs hK.ne') hp)]
  unfold hiddenStep
  congr 1
  rw [show s.val+2 = (s.val+1)+1 by omega, pow_succ]
  ring

end NeuralGeneralization.BatchTwoActivation
