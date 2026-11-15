import NeuralGeneralization.BatchTwoManuscriptResources

/-! Exact active, reconstruction and Gaussian-clipping allocations. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoManuscriptResources
open BatchTwoImprovedInduction

def selectionError (p : Input) : ℝ := (localError p)^((3:ℝ)⁻¹)
theorem selectionError_pos (p : Input) : 0<selectionError p :=
  Real.rpow_pos_of_pos (localError_pos p) _
theorem selectionError_cube (p : Input) : (selectionError p)^3=localError p :=
  Real.rpow_inv_natCast_pow (localError_pos p).le (by decide : (3:ℕ)≠0)

theorem activeBound_pos (p : Input) : 0<activeBound p := by
  unfold activeBound
  exact Real.sqrt_pos.mpr (div_pos (mul_pos (by norm_num) (activeEnergy_pos p)) (localError_pos p))
theorem active_allocation (p : Input) : 4*activeEnergy p/(activeBound p)^2=localError p := by
  have hV := activeEnergy_pos p
  have he := localError_pos p
  rw [activeBound,Real.sq_sqrt (by positivity : 0≤4*activeEnergy p/localError p)]
  field_simp

theorem reconstruction_allocation (p : Input) :
    (2*activeEnergy p+16*((rank p:ℝ)+1))/(bankSize p:ℝ)≤localError p/8 := by
  have hm : (0:ℝ)<bankSize p := Nat.cast_pos.mpr (bankSize_pos p)
  have he := localError_pos p
  have hV := activeEnergy_pos p
  have hq : (0:ℝ)≤rank p := Nat.cast_nonneg _
  have hh := (div_le_iff₀ he).mp (bankSize_first_allocation p)
  apply (div_le_iff₀ hm).mpr
  nlinarith

theorem gaussianBound_ge_two (p : Input) : 2≤gaussianBound p := le_max_left _ _
theorem gaussianBound_sq (p : Input) :
    4*Real.log (6*(bankSize p:ℝ)/localError p)≤(gaussianBound p)^2 := by
  have hh := le_max_right (2:ℝ) (2*Real.sqrt (Real.log (6*(bankSize p:ℝ)/localError p)))
  change 2*Real.sqrt (Real.log (6*(bankSize p:ℝ)/localError p))≤gaussianBound p at hh
  by_cases hl : 0≤Real.log (6*(bankSize p:ℝ)/localError p)
  · have hs := pow_le_pow_left₀ (by positivity : 0≤2*Real.sqrt (Real.log (6*(bankSize p:ℝ)/localError p))) hh 2
    simpa only [mul_pow,Real.sq_sqrt hl,show (2:ℝ)^2=4 by norm_num] using hs
  · nlinarith [sq_nonneg (gaussianBound p)]
theorem gaussian_allocation (p : Input) :
    6*(bankSize p:ℝ)*Real.exp (-((gaussianBound p)^2)/4)≤localError p := by
  have he := localError_pos p
  have hm : (0:ℝ)<bankSize p := Nat.cast_pos.mpr (bankSize_pos p)
  have hx : 0<6*(bankSize p:ℝ)/localError p := by positivity
  have hh : -((gaussianBound p)^2)/4≤ -Real.log (6*(bankSize p:ℝ)/localError p) := by
    linarith [gaussianBound_sq p]
  have hf := mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hh)
    (show 0≤6*(bankSize p:ℝ) by positivity)
  rw [Real.exp_neg (Real.log (6*(bankSize p:ℝ)/localError p)),Real.exp_log hx,inv_div] at hf
  exact hf.trans_eq (by field_simp)

theorem layer_allocation (p : Input) :
    manuscriptLayerError p.energy (selectionError p) (activeBound p) (gaussianBound p)
      (rank p) (bankSize p)≤20*localError p := by
  have hA := active_allocation p
  have hR := reconstruction_allocation p
  have hG := gaussian_allocation p
  have he := localError_pos p
  unfold manuscriptLayerError
  rw [selectionError_cube]
  change 4*(4*activeEnergy p/(activeBound p)^2+2*localError p+
    (2*activeEnergy p+16*((rank p:ℝ)+1))/(bankSize p:ℝ)+
    6*(bankSize p:ℝ)*Real.exp (-((gaussianBound p)^2)/4))≤_
  rw [hA]
  linarith

theorem firstBound_pos (p : Input) : 0<firstBound p := by
  unfold firstBound
  have := energy_pos p
  have := localError_pos p
  have hl : 0<Real.log 2 := Real.log_pos (by norm_num)
  positivity

theorem first_allocation (p : Input) :
    4*(4*p.energy+2*((p.dimension:ℝ)+1))/(firstBound p)^2≤2*localError p := by
  have he := localError_pos p
  have hK := energy_pos p
  have hl : (1/2:ℝ)≤Real.log 2 := by
    have hh := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at hh
    exact hh
  have hd : (0:ℝ)≤p.dimension := Nat.cast_nonneg _
  have hden : 0<4*(4*p.energy+2*((p.dimension:ℝ)+1)*Real.log 2) := by positivity
  rw [firstBound,Real.sq_sqrt (div_nonneg hden.le he.le)]
  apply (div_le_iff₀ (div_pos hden he)).mpr
  have heq : 2*localError p*(4*(4*p.energy+2*((p.dimension:ℝ)+1)*Real.log 2)/localError p)=
      8*(4*p.energy+2*((p.dimension:ℝ)+1)*Real.log 2) := by field_simp; ring
  rw [heq]
  nlinarith [mul_nonneg (show 0≤(p.dimension:ℝ)+1 by positivity) (show 0≤Real.log 2-1/2 by linarith)]

end NeuralGeneralization.BatchTwoManuscriptResources
