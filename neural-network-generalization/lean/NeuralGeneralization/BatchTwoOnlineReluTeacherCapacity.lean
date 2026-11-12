import NeuralGeneralization.BatchTwoOnlineReluBalancing
import NeuralGeneralization.BatchTwoOnlineReluEnergyCount

/-! The teacher's literal v_* product-norm budget for the strong-prior class. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def reluTeacherCapacity (d r : ℕ) (P : ℝ) : ℕ :=
  ⌈4*Real.exp 1*((d:ℝ)+1)*P^2*(reluDepthFactor (r+1))^2⌉₊

theorem reluBalancedEnergy_pos {d r : ℕ} (hd : 0<d) {P : ℝ} (hP : 0<P) :
    0<reluBalancedEnergy d r P := by
  unfold reluBalancedEnergy
  exact mul_pos (by positivity) (Real.rpow_pos_of_pos (mul_pos (Nat.cast_pos.mpr hd) (sq_pos_of_pos hP)) _)

theorem one_add_inv_pow_le_e (L : ℕ) (hL : 0<L) :
    (1+1/(L:ℝ))^L≤Real.exp 1 := by
  have hLR : 0<(L:ℝ) := Nat.cast_pos.mpr hL
  have h := pow_le_pow_left₀ (by positivity : (0:ℝ)≤1+1/(L:ℝ))
    (by simpa only [add_comm] using Real.add_one_le_exp (1/(L:ℝ))) L
  rw [←Real.exp_nat_mul] at h
  simpa only [mul_one_div_cancel hLR.ne'] using h

theorem physicalProduct_le_sqrt_e_teacher {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (w : Weights d N r) {P : ℝ} (hP : 0<P)
    (hw : weightedSquaredNorm w≤(1+1/(r+2:ℝ))*reluBalancedEnergy d r P) :
    physicalProduct hN relu_zeroLipschitz w≤Real.sqrt (Real.exp 1)*P := by
  have hdR : 0<(d:ℝ) := Nat.cast_pos.mpr hd
  let q := ((d:ℝ)*P^2)^((r+2:ℝ)⁻¹)
  have hq : 0<q := Real.rpow_pos_of_pos (by positivity) _
  have hqpow : q^(r+2)=(d:ℝ)*P^2 := by
    convert Real.rpow_inv_natCast_pow (by positivity : 0≤(d:ℝ)*P^2) (by omega : r+2≠0) using 1 <;> push_cast <;> rfl
  have hK : 0<(1+1/(r+2:ℝ))*reluBalancedEnergy d r P :=
    mul_pos (by positivity) (reluBalancedEnergy_pos hd hP)
  have he := product_le_average_power (weightedLayerEnergy w) (weightedLayerEnergy_nonneg w) hK
    (by rwa [weightedLayerEnergy_sum])
  rw [weightedLayerEnergy_product hN relu_zeroLipschitz] at he
  simp only [Fintype.card_sum,Fintype.card_fin,Fintype.card_bool,Nat.cast_add,Nat.cast_ofNat] at he
  have hquot : (1+1/(r+2:ℝ))*reluBalancedEnergy d r P/(r+2:ℝ)=(1+1/(r+2:ℝ))*q := by
    unfold reluBalancedEnergy
    dsimp [q]
    field_simp
  rw [hquot,mul_pow,hqpow] at he
  have hexp := one_add_inv_pow_le_e (r+2) (by omega)
  simp only [Nat.cast_add,Nat.cast_ofNat] at hexp
  have hb := he.trans (mul_le_mul_of_nonneg_right hexp (by positivity))
  have hsq : (physicalProduct hN relu_zeroLipschitz w)^2≤Real.exp 1*P^2 := by
    apply (mul_le_mul_iff_right₀ hdR).mp
    convert hb using 1 <;> ring
  apply (sq_le_sq₀ (physicalProduct_nonneg hN relu_zeroLipschitz w) (by positivity)).mp
  simpa only [mul_pow,Real.sq_sqrt (Real.exp_pos 1).le] using hsq

theorem reluTeacherCapacity_eq_product (d r : ℕ) (P : ℝ) :
    reluTeacherCapacity d r P=reluProductCapacity d (r+1) (Real.sqrt (Real.exp 1)*P) := by
  unfold reluTeacherCapacity reluProductCapacity
  rw [mul_pow,Real.sq_sqrt (Real.exp_pos 1).le]
  congr 1
  ring

theorem margin_teacher_output_nonzero {d C r : ℕ} (w : Weights d C r)
    (f : BooleanFunction d) (hw : w∈marginEvent relu (1/2) f) :
    ∃x,networkOutput relu w x≠0 := by
  refine ⟨fun _=>false,?_⟩
  intro hz
  have h := hw (fun _=>false)
  rw [hz,mul_zero] at h
  norm_num at h

/-- Actual near-minimizers, without assuming any infimum is attained. -/
theorem lowEnergyFunctions_subset_relu_teacher {d C N r : ℕ} (hd : 0<d)
    (hC : 0<C) (hCN : C≤N) (w : Weights d C r) (f : BooleanFunction d)
    (hw : w∈marginEvent relu (1/2) f) :
    lowEnergyFunctions (N:=N) (r:=r) relu f⊆
      reluFunctions d (r+1) (Real.sqrt (Real.exp 1)*physicalProduct hC relu_zeroLipschitz w) := by
  have hne := margin_teacher_output_nonzero w f hw
  have hP := physical_relu_product_pos hC w hne
  let K := reluBalancedEnergy d r (physicalProduct hC relu_zeroLipschitz w)
  have hK : 0<K := reluBalancedEnergy_pos hd hP
  obtain ⟨v,hv,hev⟩ := exists_enlarged_balanced_relu_weights hd hC hCN w hne
  have hvm : v∈marginEvent relu (1/2) f := by intro x; rw [hv x]; exact hw x
  have hrate := networkEnergy_le_of_mem relu (1/2) f v hvm
  rw [hev] at hrate
  change networkEnergy (N:=N) (r:=r) relu (1/2) f≤K/2 at hrate
  intro g hg
  obtain ⟨hne',hge⟩ := (mem_lowEnergyFunctions relu f g).mp hg
  obtain ⟨u,hu,he⟩ := exists_nearoptimal_margin_network relu (1/2) g hne' (K/(r+2:ℝ)) (by positivity)
  have hcost : weightedSquaredNorm u≤(1+1/(r+2:ℝ))*K := by
    have he' := hge.trans hrate
    have heq : (1+1/(r+2:ℝ))*K=K+K/(r+2:ℝ) := by ring
    rw [heq]
    linarith
  exact physical_relu_mem_functions (hC.trans_le hCN) u (by positivity)
    (physicalProduct_le_sqrt_e_teacher hd (hC.trans_le hCN) u hP hcost) g (fun x=>(hu x).le)

theorem lowEnergyFunctions_relu_teacher_card {d C N r : ℕ} (hd : 0<d)
    (hC : 0<C) (hCN : C≤N) (w : Weights d C r) (f : BooleanFunction d)
    (hw : w∈marginEvent relu (1/2) f) :
    ((lowEnergyFunctions (N:=N) (r:=r) relu f).card:ℝ)≤
      Real.exp ((reluTeacherCapacity d r (physicalProduct hC relu_zeroLipschitz w):ℝ)*
        Real.log ((2:ℝ)^d+1)) := by
  have hP := physical_relu_product_pos hC w (margin_teacher_output_nonzero w f hw)
  have hc : ((lowEnergyFunctions (N:=N) (r:=r) relu f).card:ℝ)≤
      (reluFunctions d (r+1) (Real.sqrt (Real.exp 1)*physicalProduct hC relu_zeroLipschitz w)).card := by
    exact_mod_cast Finset.card_le_card (lowEnergyFunctions_subset_relu_teacher hd hC hCN w f hw)
  apply hc.trans
  rw [reluTeacherCapacity_eq_product]
  exact reluFunctions_card_le_exp (by omega) (by positivity)

end NeuralGeneralization.BatchTwoActivation
