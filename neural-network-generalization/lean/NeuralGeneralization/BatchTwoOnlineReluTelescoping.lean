import NeuralGeneralization.BatchTwoContinuousDepthFiniteTelescoping

/-! Sharp square-summed layer perturbations for a uniformly balanced network. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
set_option maxHeartbeats 1400000

theorem numerical_layerwise_chain (L : ℕ) (u e η : ℕ→ℝ) {R B : ℝ}
    (hR : 0≤R) (hB : 0<B) (hη : ∀j<L,0≤η j)
    (hu0 : u 0≤R) (he0 : e 0≤0)
    (hu : ∀j<L,u (j+1)≤B*u j)
    (he : ∀j<L,e (j+1)≤B*e j+η j*u j) :
    u L≤R*B^L ∧ B*e L≤R*B^L*(∑j∈Finset.range L,η j) := by
  induction L with
  | zero => simp only [pow_zero,mul_one,Finset.range_zero,Finset.sum_empty,mul_zero];
            exact ⟨hu0,mul_nonpos_of_nonneg_of_nonpos hB.le he0⟩
  | succ L ih =>
    have hh := ih (fun j hj=>hη j (by omega)) (fun j hj=>hu j (by omega)) (fun j hj=>he j (by omega))
    constructor
    · calc
        _ ≤ B*u L := hu L (by omega)
        _ ≤ B*(R*B^L) := mul_le_mul_of_nonneg_left hh.1 hB.le
        _ = _ := by rw [pow_succ]; ring
    · calc
        _ ≤ B*(B*e L+η L*u L) := mul_le_mul_of_nonneg_left (he L (by omega)) hB.le
        _ = B*(B*e L)+B*η L*u L := by ring
        _ ≤ B*(R*B^L*(∑j∈Finset.range L,η j))+B*η L*(R*B^L) :=
          add_le_add (mul_le_mul_of_nonneg_left hh.2 hB.le)
            (mul_le_mul_of_nonneg_left hh.1 (mul_nonneg hB.le (hη L (by omega))))
        _ = _ := by rw [pow_succ,Finset.sum_range_succ]; ring

theorem sum_layer_errors_le {L : ℕ} (η : ℕ→ℝ) {ρ : ℝ} (hρ : 0≤ρ)
    (hη : ∀j<L,0≤η j) (hsq : ∑j∈Finset.range L,(η j)^2≤ρ^2) :
    (∑j∈Finset.range L,η j)≤Real.sqrt (L:ℝ)*ρ := by
  have hh := Finset.sum_mul_sq_le_sq_mul_sq (Finset.range L) η (fun _=>(1:ℝ))
  simp only [mul_one,one_pow,Finset.sum_const,Finset.card_range,nsmul_eq_mul,mul_one] at hh
  have hs := mul_le_mul_of_nonneg_right hsq (Nat.cast_nonneg L : (0:ℝ)≤L)
  have hn : 0≤∑j∈Finset.range L,η j := Finset.sum_nonneg (fun j hj=>hη j (Finset.mem_range.mp hj))
  have he : (Real.sqrt (L:ℝ)*ρ)^2=(L:ℝ)*ρ^2 := by rw [mul_pow,Real.sq_sqrt (Nat.cast_nonneg L)]
  nlinarith [mul_nonneg (Real.sqrt_nonneg (L:ℝ)) hρ]

theorem numerical_square_sum_error {L : ℕ} (hL : 0<L) (u e η : ℕ→ℝ) {R B ρ : ℝ}
    (hR : 0≤R) (hB : 0<B) (hρ : 0≤ρ) (hη : ∀j<L,0≤η j)
    (hu0 : u 0≤R) (he0 : e 0≤0)
    (hu : ∀j<L,u (j+1)≤B*u j)
    (he : ∀j<L,e (j+1)≤B*e j+η j*u j)
    (hsq : ∑j∈Finset.range L,(η j)^2≤ρ^2) :
    e L≤R*Real.sqrt (L:ℝ)*ρ*B^(L-1) := by
  have hh := (numerical_layerwise_chain L u e η hR hB hη hu0 he0 hu he).2
  have hs := sum_layer_errors_le η hρ hη hsq
  have hm := mul_le_mul_of_nonneg_left hs (mul_nonneg hR (pow_nonneg hB.le L))
  have hp : B^L=B*B^(L-1) := by
    conv_lhs => rw [← Nat.sub_add_cancel hL,pow_succ]
    ring
  rw [hp] at hh hm
  apply (mul_le_mul_iff_right₀ hB).mp
  calc
    B*e L ≤ R*(B*B^(L-1))*(Real.sqrt (L:ℝ)*ρ) := hh.trans hm
    _ = B*(R*Real.sqrt (L:ℝ)*ρ*B^(L-1)) := by ring

end NeuralGeneralization.BatchTwoOnlineReluFinite
