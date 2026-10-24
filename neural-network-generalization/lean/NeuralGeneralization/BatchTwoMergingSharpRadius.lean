import NeuralGeneralization.BatchTwoMergingSharpMerged

/-! The manuscript's radius, simultaneously parameterized for ReLU and GELU. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoMerging

def sharpAmplification (ℓ κ C b:ℝ) : ℝ := 2*ℓ+2*ℓ*Real.sqrt (κ*C)+ℓ*b
def sharpInputBudget (ℓ:ℝ) (d r:ℕ) (C:ℝ) : ℝ :=
  ℓ*((d:ℝ)+1)+ℓ*((r:ℝ)+1)*Real.sqrt C
def sharpRadius (ℓ κ C b:ℝ) (d r:ℕ) : ℝ :=
  min (1/16) (1/(256*Real.sqrt (κ*C)*sharpInputBudget ℓ d r C*
    sharpAmplification ℓ κ C b^(r+1)))

theorem sharpRadius_control {ℓ κ C b:ℝ} (d r:ℕ)
    (hℓ:1≤ℓ) (hκ:1≤κ) (hC:1≤C) (hb:0≤b) :
    0<sharpRadius ℓ κ C b d r ∧ sharpRadius ℓ κ C b d r≤1/16 ∧
    1≤sharpAmplification ℓ κ C b ∧
    ℓ*(Real.sqrt (κ*C)+b+sharpRadius ℓ κ C b d r*Real.sqrt C)≤sharpAmplification ℓ κ C b ∧
    (let e:=ℓ*sharpRadius ℓ κ C b d r*((d:ℝ)+1+r*Real.sqrt C)*
      sharpAmplification ℓ κ C b^r
     Real.sqrt (16*κ*C)*e+sharpRadius ℓ κ C b d r*(1+e)≤1/4) := by
  let S:=sharpAmplification ℓ κ C b
  let D:=sharpInputBudget ℓ d r C
  let ρ:=sharpRadius ℓ κ C b d r
  have hℓ0:0≤ℓ := by linarith
  have hC0:0≤C := by linarith
  have hkC:1≤κ*C := one_le_mul_of_one_le_of_one_le hκ hC
  have hkCp:0<κ*C := by linarith
  have hsK:1≤Real.sqrt (κ*C) := by simpa using Real.sqrt_le_sqrt hkC
  have hG:Real.sqrt C≤Real.sqrt (κ*C) := Real.sqrt_le_sqrt (by nlinarith)
  have hS:1≤S := by
    dsimp [S,sharpAmplification]
    have hx:0≤2*ℓ*Real.sqrt (κ*C) := by positivity
    have hy:0≤ℓ*b := mul_nonneg hℓ0 hb
    linarith
  have hD:0<D := by
    dsimp [D,sharpInputBudget]
    have hd:0<ℓ*((d:ℝ)+1) := mul_pos (by linarith) (by positivity)
    have hr:0≤ℓ*((r:ℝ)+1)*Real.sqrt C := by positivity
    linarith
  have hden:0<256*Real.sqrt (κ*C)*D*S^(r+1) := by positivity
  have hρ:0<ρ := by
    dsimp [ρ,sharpRadius]
    exact lt_min (by norm_num) (one_div_pos.mpr hden)
  have hρ16:ρ≤1/16 := min_le_left _ _
  have hρ1:ρ≤1 := by linarith
  have hsmall:ρ*(256*Real.sqrt (κ*C)*D*S^(r+1))≤1 :=
    (le_div_iff₀ hden).mp (min_le_right _ _)
  have hamp:ℓ*(Real.sqrt (κ*C)+b+ρ*Real.sqrt C)≤S := by
    have hh:=mul_le_mul_of_nonneg_right hρ1 (Real.sqrt_nonneg C)
    have hh':=mul_le_mul_of_nonneg_left (hh.trans_eq (one_mul _)) hℓ0
    have hg:=mul_le_mul_of_nonneg_left hG hℓ0
    dsimp [S,sharpAmplification]
    nlinarith
  refine ⟨hρ,hρ16,hS,hamp,?_⟩
  let e:=ℓ*ρ*((d:ℝ)+1+r*Real.sqrt C)*S^r
  have he0:0≤e := by dsimp [e]; positivity
  have hDb:ℓ*((d:ℝ)+1+r*Real.sqrt C)≤D := by
    dsimp [D,sharpInputBudget]
    have hh:0≤ℓ*Real.sqrt C := by positivity
    nlinarith
  have hp:S^r≤S^(r+1) := pow_le_pow_right₀ hS (by omega)
  have he: e≤ρ*D*S^(r+1) := by
    have hh:=mul_le_mul hDb hp (by positivity : 0≤S^r) hD.le
    have hh':=mul_le_mul_of_nonneg_left hh hρ.le
    dsimp [e]
    nlinarith
  have hek:Real.sqrt (κ*C)*e≤1/256 := by
    have hh:=mul_le_mul_of_nonneg_left he (Real.sqrt_nonneg (κ*C))
    nlinarith
  have he1:e≤1/256 := by
    have hh:=mul_le_mul_of_nonneg_right hsK he0
    nlinarith
  have hr:=mul_le_mul hρ16 (show 1+e≤1+1/256 by linarith) (by linarith) (by norm_num : (0:ℝ)≤1/16)
  have hroot:Real.sqrt (16*κ*C)=4*Real.sqrt (κ*C) := by
    rw [show 16*κ*C=16*(κ*C) by ring,Real.sqrt_mul (by norm_num : (0:ℝ)≤16)]
    rw [show Real.sqrt (16:ℝ)=4 by rw [show (16:ℝ)=4^2 by norm_num, Real.sqrt_sq (by norm_num)]]
  change Real.sqrt (16*κ*C)*e+ρ*(1+e)≤1/4
  rw [hroot]
  nlinarith

end NeuralGeneralization.BatchTwoMerging
