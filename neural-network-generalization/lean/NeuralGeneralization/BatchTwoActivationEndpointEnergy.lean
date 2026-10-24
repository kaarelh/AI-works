import NeuralGeneralization.BatchTwoActivationActualTower

/-! Actual weighted-energy budgets for the reconstructed heterogeneous network. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def rawAuxiliaryWeightedEnergy {d H : ℕ} {ℓ B:ℝ} (W:RawAuxiliaryNetwork d H ℓ B):ℝ:=
  (d:ℝ)/(W.width 0)*(∑j,‖W.rows 0 j‖^2)+
    (∑s∈Finset.range (H-1),∑j,‖W.rows (s+1) j‖^2)+(W.width (H-1):ℝ)*‖W.readout‖^2

def activationEndpointEnergyBudget (b d K H:ℕ):ℕ:=
  (d+H+activationFiniteWidth b d K H)*(activationRawBudget b d K H)^2

theorem activationEndpointEnergyBudget_polynomial (b H:ℕ):
    PolynomialGrowth2 (fun d K=>activationEndpointEnergyBudget b d K H):=by
  unfold activationEndpointEnergyBudget
  exact ((PolynomialGrowth2.left.add (PolynomialGrowth2.const H)).add
    (activationFiniteWidth_polynomial b H)).mul ((activationRawBudget_polynomial b H).pow 2)

theorem rawAuxiliaryWeightedEnergy_bound {d H F:ℕ} {ℓ B:ℝ}
    (W:RawAuxiliaryNetwork d H ℓ B) (hB:0≤B) (hw:∀s,W.width s=F):
    rawAuxiliaryWeightedEnergy W≤((d:ℝ)+H+F)*B^2:=by
  have hF:0<F:=by rw [←hw 0];exact W.width_pos 0
  have hFR:(1:ℝ)≤F:=by exact_mod_cast hF
  have hfirst:((d:ℝ)/F)*(∑j,‖W.rows 0 j‖^2)≤(d:ℝ)*B^2:=by
    calc
      _ ≤ ((d:ℝ)/F)*B^2:=mul_le_mul_of_nonneg_left (W.row_energy 0) (by positivity)
      _ ≤ (d:ℝ)*B^2:=mul_le_mul_of_nonneg_right (div_le_self (Nat.cast_nonneg _) hFR) (sq_nonneg B)
  have hhidden:(∑s∈Finset.range (H-1),∑j,‖W.rows (s+1) j‖^2)≤(H:ℝ)*B^2:=by
    calc
      _ ≤ ∑_s∈Finset.range (H-1),B^2:=Finset.sum_le_sum (fun s hs=>W.row_energy (s+1))
      _ = ((H-1:ℕ):ℝ)*B^2:=by simp
      _ ≤ (H:ℝ)*B^2:=mul_le_mul_of_nonneg_right (by exact_mod_cast Nat.sub_le H 1) (sq_nonneg B)
  have hread:‖W.readout‖^2≤B^2:=(sq_le_sq₀ (norm_nonneg _) hB).mpr W.readout_norm
  unfold rawAuxiliaryWeightedEnergy
  rw [hw 0,hw (H-1)]
  nlinarith [mul_le_mul_of_nonneg_left hread (Nat.cast_nonneg F: (0:ℝ)≤F)]

end NeuralGeneralization.BatchTwoActivation
