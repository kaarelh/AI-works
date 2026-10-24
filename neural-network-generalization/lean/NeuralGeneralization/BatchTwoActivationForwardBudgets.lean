import NeuralGeneralization.BatchTwoActivationBooleanBudgets
import NeuralGeneralization.BatchTwoActivationFixedNetwork

/-! Forward envelopes for the actual finite auxiliary layers. -/
noncomputable section
set_option maxRecDepth 10000
set_option maxHeartbeats 1200000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation

def activationStageStateBound (b d K H s : ℕ) : ℕ :=
  (1+b*activationFiniteWidth b d K H*activationRowBudget b d K H)^(3^s)

theorem activationFiniteWidth_pos (b d K H : ℕ) : 0<activationFiniteWidth b d K H := by
  unfold activationFiniteWidth
  omega

theorem activationStageStateBound_one_le (b d K H s : ℕ) :
    1≤activationStageStateBound b d K H s := by
  unfold activationStageStateBound
  exact Nat.one_le_pow _ _ (by omega)

theorem activationStageStateBound_le {b d K H s : ℕ} (hs : s≤H) :
    activationStageStateBound b d K H s≤activationStateBudget b d K H := by
  unfold activationStageStateBound activationStateBudget
  exact Nat.pow_le_pow_right (by omega) (Nat.pow_le_pow_right (by omega) hs)

theorem activationStageStateBound_step (b d K H s : ℕ) :
    b*activationFiniteWidth b d K H*activationRowBudget b d K H*
        (activationStageStateBound b d K H s)^2≤activationStageStateBound b d K H (s+1) := by
  let T := 1+b*activationFiniteWidth b d K H*activationRowBudget b d K H
  have hT : 1≤T := by dsimp [T]; omega
  have hTs : T≤T^(3^s) := Nat.le_pow (by positivity)
  change b*activationFiniteWidth b d K H*activationRowBudget b d K H*(T^(3^s))^2≤T^(3^(s+1))
  calc
    _ ≤ T*(T^(3^s))^2 := Nat.mul_le_mul_right _ (by dsimp [T]; omega)
    _ ≤ T^(3^s)*(T^(3^s))^2 := Nat.mul_le_mul_right _ hTs
    _ = _ := by rw [←pow_succ',←pow_mul,pow_succ]

theorem activation_layer_width_le {b d K H k : ℕ}
    (hk : k≤activationMaxBudget b d K H) :
    k^48+k^20≤activationFiniteWidth b d K H := by
  have h1 : k^48≤(activationMaxBudget b d K H)^48 := Nat.pow_le_pow_left hk _
  have h2 : k^20≤(activationMaxBudget b d K H)^48 :=
    (Nat.pow_le_pow_left hk 20).trans (Nat.pow_le_pow_right (by
      have hb : 1≤activationBaseBudget b d K H := by unfold activationBaseBudget; omega
      exact activationPrecisionGrow_ge_base hb H |>.trans' hb) (by omega))
  unfold activationFiniteWidth
  omega

theorem activation_step_weight_envelope {b d K H k r : ℕ}
    (hk : k≤activationMaxBudget b d K H) (hr : r≤activationFiniteWidth b d K H)
    {V S : ℝ} (hV0 : 0≤V) (hV : V≤1+56*(K:ℝ)) (hS : 1≤S) :
    polynomialStepWeightBound k r V S≤(activationRowBudget b d K H:ℝ)*S := by
  have hkR : (k:ℝ)≤activationMaxBudget b d K H := by exact_mod_cast hk
  have hrR : (r:ℝ)≤activationFiniteWidth b d K H := by exact_mod_cast hr
  have hsource : polynomialBulkSourceBound k r≤(activationSourceBudget b d K H:ℝ) := by
    simp only [polynomialBulkSourceBound,activationSourceBudget,Nat.cast_add,Nat.cast_mul,Nat.cast_pow,Nat.cast_ofNat,Nat.cast_one]
    gcongr
  have hkp : (k:ℝ)^10≤(activationMaxBudget b d K H:ℝ)^10 := by gcongr
  have hsource0 : (0:ℝ)≤activationSourceBudget b d K H := Nat.cast_nonneg _
  have hs0 : 0≤S := by linarith
  unfold polynomialStepWeightBound
  calc
    _ ≤ (2+56*(K:ℝ))*(activationSourceBudget b d K H:ℝ)+
          (2+56*(K:ℝ))*S*(activationMaxBudget b d K H:ℝ)^10 := by
      apply add_le_add
      · exact mul_le_mul (by linarith) hsource (by dsimp [polynomialBulkSourceBound]; positivity) (by positivity)
      · gcongr
        linarith
    _ ≤ ((2+56*(K:ℝ))*((activationSourceBudget b d K H:ℝ)+
        (activationMaxBudget b d K H:ℝ)^10))*S := by
      nlinarith [mul_nonneg (show 0≤2+56*(K:ℝ) by positivity) hsource0]
    _ = _ := by norm_cast

theorem finite_rows_energy_bound {m n : ℕ} {a K : ℝ}
    (hA : 0≤a) (W : Fin m → Fin n → ℝ) (hW : ∀i j,|W i j|≤a)
    (hbudget : (m:ℝ)*n*a^2≤K^2) :
    (∑i,‖(WithLp.toLp 2 (W i) : EuclideanSpace ℝ (Fin n))‖^2)≤K^2 := by
  apply le_trans _ hbudget
  simp only [EuclideanSpace.real_norm_sq_eq,PiLp.toLp_apply]
  calc
    _ ≤ ∑i : Fin m,∑j : Fin n,a^2 := by
      apply Finset.sum_le_sum
      intro i _
      apply Finset.sum_le_sum
      intro j _
      exact sq_le_sq.mpr ((hW i j).trans_eq (abs_of_nonneg hA).symm)
    _ = _ := by simp; ring

 theorem activationRawBudget_layer {b d K H s : ℕ} (hs : s≤H) :
    (activationFiniteWidth b d K H:ℝ)^2*
      ((activationRowBudget b d K H:ℝ)*(activationStageStateBound b d K H s:ℝ))^2≤
        (activationRawBudget b d K H:ℝ)^2 := by
  have hS : (activationStageStateBound b d K H s:ℝ)≤activationStateBudget b d K H := by
    exact_mod_cast activationStageStateBound_le hs
  have hmain : (activationFiniteWidth b d K H:ℝ)^2*
      ((activationRowBudget b d K H:ℝ)*(activationStateBudget b d K H:ℝ))^2≤
        (activationRawBudget b d K H:ℝ) := by
    unfold activationRawBudget
    push_cast
    nlinarith [sq_nonneg ((activationRowBudget b d K H:ℝ)*(activationStateBudget b d K H:ℝ)),
      sq_nonneg (32*(K:ℝ)*(1+56*(K:ℝ))*(activationStateBudget b d K H:ℝ))]
  have hraw : (1:ℝ)≤activationRawBudget b d K H := by
    exact_mod_cast (show 1≤activationRawBudget b d K H by unfold activationRawBudget; omega)
  apply le_trans _ (hmain.trans (by nlinarith))
  gcongr

 theorem fixedInputWidth_le {d F s : ℕ} (hd : d+1≤F) :
    fixedInputWidth d F s≤F := by cases s <;> simp only [fixedInputWidth] <;> omega

 theorem activationRawBudget_pos (b d K H : ℕ) : 0<activationRawBudget b d K H := by
  unfold activationRawBudget
  omega

 theorem activationRawBudget_readout {b d K H : ℕ} :
    (activationFiniteWidth b d K H:ℝ)*
      (32*(K:ℝ)*(1+56*(K:ℝ))*(activationStateBudget b d K H:ℝ))^2≤
        (activationRawBudget b d K H:ℝ)^2 := by
  have hmain : (activationFiniteWidth b d K H:ℝ)*
      (32*(K:ℝ)*(1+56*(K:ℝ))*(activationStateBudget b d K H:ℝ))^2≤
        (activationRawBudget b d K H:ℝ) := by
    unfold activationRawBudget
    push_cast
    nlinarith [sq_nonneg ((activationRowBudget b d K H:ℝ)*(activationStateBudget b d K H:ℝ)),
      sq_nonneg (32*(K:ℝ)*(1+56*(K:ℝ))*(activationStateBudget b d K H:ℝ))]
  have hraw : (1:ℝ)≤activationRawBudget b d K H := by
    exact_mod_cast (show 1≤activationRawBudget b d K H by unfold activationRawBudget; omega)
  exact hmain.trans (by nlinarith)

end NeuralGeneralization.BatchTwoActivation
