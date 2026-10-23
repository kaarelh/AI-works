import NeuralGeneralization.BatchTwoMergingSharpCompilation
import NeuralGeneralization.BatchTwoMergingSharpMass

/-! Exact manuscript target costs for the actual Gaussian prior, at every width. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d C N r k p:ℕ}

def sharpReluTeacherEnergy (d C r:ℕ):ℝ := d+10*r*C+160*C
def sharpGeluTeacherEnergy (d C r:ℕ):ℝ := d+100*r*C+1600*C
def sharpReluTargetCost (d C r:ℕ):ℝ :=
  sharpCylinderCost d r (sharpReluTeacherEnergy d C r) C
    (sharpRadius 1 10 C (sharpBulkBound r) d r)
def sharpGeluTargetCost (d C r:ℕ):ℝ :=
  sharpCylinderCost d r (sharpGeluTeacherEnergy d C r) C
    (sharpRadius 2 100 C (sharpBulkBound r) d r)

theorem sharpCylinderCost_nonneg (d r:ℕ) {K G ρ:ℝ} (hK:0≤K) (hG:0≤G)
    (hρ:0<ρ) (hρ16:ρ≤1/16):0≤sharpCylinderCost d r K G ρ := by
  have hroot:1≤Real.sqrt (2*Real.pi) := by
    have hs:=Real.sq_sqrt (by positivity : 0≤2*Real.pi)
    nlinarith [Real.sqrt_nonneg (2*Real.pi),Real.pi_gt_three]
  have he:1≤Real.exp (1:ℝ) := Real.one_le_exp (by norm_num)
  have harg:1≤Real.exp 1*Real.sqrt (2*Real.pi)/(2*ρ) := by
    apply (le_div_iff₀ (by positivity : 0<2*ρ)).mpr
    have hm:=one_le_mul_of_one_le_of_one_le he hroot
    nlinarith
  have hl:=Real.log_nonneg harg
  have hl2:0≤Real.log (2:ℝ) := Real.log_nonneg (by norm_num)
  unfold sharpCylinderCost
  positivity

theorem sharpReluTargetCost_nonneg (d r:ℕ) (hC:0<C):0≤sharpReluTargetCost d C r := by
  obtain ⟨hp,hb,_,_,_⟩:=sharpRadius_control d r (by norm_num : (1:ℝ)≤1)
    (by norm_num : (1:ℝ)≤10) (show (1:ℝ)≤C by exact_mod_cast hC) (sharpBulkBound_nonneg r)
  exact sharpCylinderCost_nonneg d r (by unfold sharpReluTeacherEnergy; positivity) (Nat.cast_nonneg C) hp hb

theorem sharpGeluTargetCost_nonneg (d r:ℕ) (hC:0<C):0≤sharpGeluTargetCost d C r := by
  obtain ⟨hp,hb,_,_,_⟩:=sharpRadius_control d r (by norm_num : (1:ℝ)≤2)
    (by norm_num : (1:ℝ)≤100) (show (1:ℝ)≤C by exact_mod_cast hC) (sharpBulkBound_nonneg r)
  exact sharpCylinderCost_nonneg d r (by unfold sharpGeluTeacherEnergy; positivity) (Nat.cast_nonneg C) hp hb

theorem sharp_relu_target_mass_cloned (hd:0<d) (hC:0<C) (hk:0<k)
    (hbelow:C*k≤N) (habove:N≤2*C*k)
    (e:((Fin C×Fin k)⊕Fin p)≃Fin N) (B:LayeredNorCircuit d C r)
    {σ:ℝ} (hσ:0<σ) (hscale:(N:ℝ)*σ^2≤1):
    Real.exp (-sharpReluTargetCost d C r/σ^2)≤
      (smallPrior d N r σ).real (mergingSupport relu ∩marginEvent relu (1/2) B.computes) := by
  have hN:0<N := (Nat.mul_pos hC hk).trans_le hbelow
  obtain ⟨b,J,hJ,hrows,hhidden⟩ := exists_adapted_active_clone hk relu relu_zero e (B.weights 4)
  have hc:weightedSquaredNorm (clonedWeights e (B.weights 4))≤sharpReluTeacherEnergy d C r := by
    have hh:=sharp_cloned_compiler_energy hC hk hbelow habove e B 4
    unfold sharpReluTeacherEnergy
    nlinarith [Nat.cast_nonneg (α:=ℝ) r,Nat.cast_nonneg (α:=ℝ) C]
  obtain ⟨hρ,hρ16,_,_,_⟩:=sharpRadius_control d r (by norm_num : (1:ℝ)≤1)
    (by norm_num : (1:ℝ)≤10) (show (1:ℝ)≤C by exact_mod_cast hC) (sharpBulkBound_nonneg r)
  have hm:=sharpCoordinateCylinder_mass hd hN (clonedWeights e (B.weights 4)) b J
    hρ hρ16 hσ hscale (show (J.card:ℝ)≤C by exact_mod_cast hJ) hc
  exact hm.trans (measureReal_mono (sharp_relu_clone_cylinder_containment hd hC hk hbelow habove
    e B b J hJ hrows hhidden hσ.le hscale) (measure_ne_top _ _))

theorem sharp_gelu_target_mass_cloned (hd:0<d) (hC:0<C) (hk:0<k)
    (hbelow:(2*C)*k≤N) (habove:N≤2*(2*C)*k)
    (e:((Fin (2*C)×Fin k)⊕Fin p)≃Fin N) (B:LayeredNorCircuit d C r)
    {σ:ℝ} (hσ:0<σ) (hscale:(N:ℝ)*σ^2≤1):
    Real.exp (-sharpGeluTargetCost d (2*C) r/σ^2)≤
      (smallPrior d N r σ).real (mergingSupport gelu ∩marginEvent gelu (1/2) B.computes) := by
  have hD:0<2*C := Nat.mul_pos (by omega) hC
  have hN:0<N := (Nat.mul_pos hD hk).trans_le hbelow
  obtain ⟨b,J,hJ,hrows,hhidden⟩ := exists_adapted_active_clone hk gelu gelu_zero e (B.geluWeights 4)
  have hc:weightedSquaredNorm (clonedWeights e (B.geluWeights 4))≤sharpGeluTeacherEnergy d (2*C) r := by
    have hh:=sharp_cloned_gelu_compiler_energy hC hk hbelow habove e B 4
    unfold sharpGeluTeacherEnergy
    push_cast
    nlinarith [Nat.cast_nonneg (α:=ℝ) r,Nat.cast_nonneg (α:=ℝ) C]
  obtain ⟨hρ,hρ16,_,_,_⟩:=sharpRadius_control d r (by norm_num : (1:ℝ)≤2)
    (by norm_num : (1:ℝ)≤100) (show (1:ℝ)≤(2*C:ℕ) by exact_mod_cast hD) (sharpBulkBound_nonneg r)
  have hm:=sharpCoordinateCylinder_mass hd hN (clonedWeights e (B.geluWeights 4)) b J
    hρ hρ16 hσ hscale (show (J.card:ℝ)≤(2*C:ℕ) by exact_mod_cast hJ) hc
  apply hm.trans
  apply measureReal_mono _ (measure_ne_top _ _)
  simpa only [Nat.cast_mul,Nat.cast_ofNat] using sharp_gelu_clone_cylinder_containment hd hC hk hbelow habove
    e B b J hJ hrows hhidden hσ.le hscale

theorem sharp_relu_target_mass_all_widths (hd:0<d) (hC:0<C) (hCN:C≤N)
    (B:LayeredNorCircuit d C r) {σ:ℝ} (hσ:0<σ) (hscale:(N:ℝ)*σ^2≤1):
    Real.exp (-sharpReluTargetCost d C r/σ^2)≤
      (smallPrior d N r σ).real (mergingSupport relu ∩marginEvent relu (1/2) B.computes) := by
  classical
  let k:=N/C
  have hk:0<k := Nat.div_pos hCN hC
  have hmod:N%C<C := Nat.mod_lt _ hC
  have hsplit:N%C+C*k=N := Nat.mod_add_div N C
  have hbelow:C*k≤N := by omega
  have hCk:C≤C*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove:N≤2*C*k := by nlinarith
  let e:((Fin C×Fin k)⊕Fin (N-C*k))≃Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  exact sharp_relu_target_mass_cloned hd hC hk hbelow habove e B hσ hscale

theorem sharp_gelu_target_mass_all_widths (hd:0<d) (hC:0<C) (hCN:2*C≤N)
    (B:LayeredNorCircuit d C r) {σ:ℝ} (hσ:0<σ) (hscale:(N:ℝ)*σ^2≤1):
    Real.exp (-sharpGeluTargetCost d (2*C) r/σ^2)≤
      (smallPrior d N r σ).real (mergingSupport gelu ∩marginEvent gelu (1/2) B.computes) := by
  classical
  let k:=N/(2*C)
  have hD:0<2*C := Nat.mul_pos (by omega) hC
  have hk:0<k := Nat.div_pos hCN hD
  have hmod:N%(2*C)<2*C := Nat.mod_lt _ hD
  have hsplit:N%(2*C)+(2*C)*k=N := Nat.mod_add_div N (2*C)
  have hbelow:(2*C)*k≤N := by omega
  have hCk:2*C≤(2*C)*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left (2*C) hk
  have habove:N≤2*(2*C)*k := by nlinarith
  let e:((Fin (2*C)×Fin k)⊕Fin (N-(2*C)*k))≃Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  exact sharp_gelu_target_mass_cloned hd hC hk hbelow habove e B hσ hscale

end NeuralGeneralization.BatchTwoMerging
