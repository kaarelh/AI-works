import NeuralGeneralization.BatchTwoImprovedResourceBounds

/-! Allocation of the accumulated actual abort, path, and readout errors. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoImprovedResources
set_option maxHeartbeats 300000
set_option maxRecDepth 4000

theorem terminal_energy_allocation (p : Input) :
    (8*(p.energy:ℝ)+2)/(readoutMoment p:ℝ)≤(inverseFailure p:ℝ)⁻¹ := by
  have hH : (0:ℝ) < inverseFailure p := Nat.cast_pos.mpr (inverseFailure_pos p)
  have hV : (0:ℝ)<readoutMoment p := Nat.cast_pos.mpr (readoutMoment_pos p)
  rw [inv_eq_one_div]
  apply (div_le_div_iff₀ hV hH).mpr
  simp only [readoutMoment,Nat.cast_mul,Nat.cast_add,Nat.cast_ofNat,Nat.cast_one]
  nlinarith

theorem failure_allocation (p : Input) {r : ℕ} (hr : r≤p.depth) :
    2*(r:ℝ)/(inverseFailure p:ℝ)+
      8*((1+14*(r:ℝ))/(inverseError p:ℝ))/(1/((p.inverseRadius:ℝ)+1))^2+
      ((inverseFailure p:ℝ)⁻¹+(inverseFailure p:ℝ)⁻¹)≤
      1/((p.inverseFailure:ℝ)+1) := by
  have hD : (0:ℝ)<(p.depth:ℝ)+1 := by positivity
  have hA : (0:ℝ)<(p.inverseFailure:ℝ)+1 := by positivity
  have hR : (0:ℝ)<(p.inverseRadius:ℝ)+1 := by positivity
  have hrR : (r:ℝ)≤p.depth := by exact_mod_cast hr
  have he : 2*(r:ℝ)/(inverseFailure p:ℝ)+
      8*((1+14*(r:ℝ))/(inverseError p:ℝ))/(1/((p.inverseRadius:ℝ)+1))^2+
      ((inverseFailure p:ℝ)⁻¹+(inverseFailure p:ℝ)⁻¹)=
      (312*(r:ℝ)+208)/(10000*((p.depth:ℝ)+1)*((p.inverseFailure:ℝ)+1)) := by
    simp only [inverseFailure,inverseError,Nat.cast_mul,Nat.cast_add,Nat.cast_pow,Nat.cast_ofNat,Nat.cast_one]
    field_simp
    ring
  rw [he]
  apply (div_le_div_iff₀ (by positivity) hA).mpr
  have hm := mul_le_mul_of_nonneg_right hrR hA.le
  nlinarith

theorem small_weight_allocation (p : Input) :
    4*(widthBound p:ℝ)*p.energy+2*ConcreteModel.robustParameterCount p.dimension (widthBound p) (p.depth-2)≤
      (1/((p.inverseFailure:ℝ)+1))*(weightBound p:ℝ)^2 := by
  have hA : (0:ℝ)<(p.inverseFailure:ℝ)+1 := by positivity
  have hW : Nat.sqrt (smallSquared p)+1≤weightBound p := by unfold weightBound; omega
  have hs := (Nat.lt_succ_sqrt' (smallSquared p)).le.trans (Nat.pow_le_pow_left hW 2)
  have hsR : (smallSquared p:ℝ)≤(weightBound p:ℝ)^2 := by exact_mod_cast hs
  have hJ : (0:ℝ)≤4*(widthBound p:ℝ)*p.energy+
      2*ConcreteModel.robustParameterCount p.dimension (widthBound p) (p.depth-2) := by
    exact add_nonneg (mul_nonneg (mul_nonneg (by norm_num) (Nat.cast_nonneg _)) (Nat.cast_nonneg _))
      (mul_nonneg (by norm_num) (Nat.cast_nonneg _))
  have hscalar : (4*(widthBound p:ℝ)*p.energy+
      2*ConcreteModel.robustParameterCount p.dimension (widthBound p) (p.depth-2))*
        ((p.inverseFailure:ℝ)+1)≤(weightBound p:ℝ)^2 := by
    simp only [smallSquared,Nat.cast_mul,Nat.cast_add,Nat.cast_ofNat,Nat.cast_one] at hsR
    have hn := mul_nonneg hJ hA.le
    nlinarith only [hsR,hn]
  simpa only [div_eq_mul_inv,one_mul,mul_comm] using (le_div_iff₀ hA).mpr hscalar
end NeuralGeneralization.BatchTwoImprovedResources
