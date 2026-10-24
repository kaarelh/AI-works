import NeuralGeneralization.BatchTwoImprovedResources
import NeuralGeneralization.BatchTwoImprovedLayerBudget

/-! Allocation of the actual sharp layer costs and terminal errors. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoImprovedResources
open BatchTwoImprovedInduction
set_option maxHeartbeats 300000
set_option maxRecDepth 4000

theorem firstSquared_pos (p : Input) : 0<firstSquared p := by
  unfold firstSquared
  have := inverseError_pos p
  positivity

theorem activeSquared_pos (p : Input) : 0<activeSquared p := by
  unfold activeSquared
  have := inverseError_pos p
  have := rank_pos p
  positivity

theorem gaussianSquared_pos (p : Input) : 0<gaussianSquared p := by
  exact Nat.mul_pos (Nat.mul_pos (by norm_num) (bankSize_pos p)) (inverseError_pos p)

theorem first_cost_allocation (p : Input) :
    4*(4*(p.energy:ℝ)+2*(p.dimension+1))/(Real.sqrt (firstSquared p))^2=
      1/(inverseError p:ℝ) := by
  have hE : (inverseError p:ℝ)≠0 := (Nat.cast_pos.mpr (inverseError_pos p)).ne'
  have ha : 4*(p.energy:ℝ)+2*(p.dimension+1)≠0 := by positivity
  rw [Real.sq_sqrt (Nat.cast_nonneg _)]
  simp only [firstSquared,Nat.cast_mul,Nat.cast_add,Nat.cast_ofNat,Nat.cast_one]
  field_simp <;> norm_num

theorem active_cost_allocation (p : Input) :
    4*(8*(p.energy:ℝ)+2*rank p)/(Real.sqrt (activeSquared p))^2=
      1/(4*(inverseError p:ℝ)) := by
  have hE : (inverseError p:ℝ)≠0 := (Nat.cast_pos.mpr (inverseError_pos p)).ne'
  have hq : (0:ℝ)<rank p := Nat.cast_pos.mpr (rank_pos p)
  have ha : 8*(p.energy:ℝ)+2*rank p≠0 := by positivity
  rw [Real.sq_sqrt (Nat.cast_nonneg _)]
  simp only [activeSquared,Nat.cast_mul,Nat.cast_add,Nat.cast_ofNat]
  field_simp <;> norm_num

theorem gaussian_cost_allocation (p : Input) :
    128*(bankSize p:ℝ)/(Real.sqrt (gaussianSquared p))^2=
      1/(4*(inverseError p:ℝ)) := by
  have hE : (inverseError p:ℝ)≠0 := (Nat.cast_pos.mpr (inverseError_pos p)).ne'
  have hm : (bankSize p:ℝ)≠0 := (Nat.cast_pos.mpr (bankSize_pos p)).ne'
  rw [Real.sq_sqrt (Nat.cast_nonneg _)]
  simp only [gaussianSquared,Nat.cast_mul,Nat.cast_ofNat]
  field_simp <;> norm_num

theorem sample_cost_allocation (p : Input) :
    (2*(8*(p.energy:ℝ)+2*rank p)+16*(rank p+1))/(bankSize p:ℝ)≤
      1/(inverseError p:ℝ) := by
  have hE : (0:ℝ) < inverseError p := Nat.cast_pos.mpr (inverseError_pos p)
  have hm : (0:ℝ)<bankSize p := Nat.cast_pos.mpr (bankSize_pos p)
  apply (div_le_div_iff₀ hm hE).mpr
  have hbase : 64*((p.energy+rank p+1)*inverseError p)≤bankSize p := by
    unfold bankSize
    omega
  have hbaseR : 64*(((p.energy:ℝ)+rank p+1)*inverseError p)≤bankSize p := by
    exact_mod_cast hbase
  have hK : (0:ℝ)≤p.energy := Nat.cast_nonneg _
  have hq : (0:ℝ)≤rank p := Nat.cast_nonneg _
  nlinarith [mul_nonneg hE.le hK,mul_nonneg hE.le hq]

theorem layer_cost_allocation (p : Input) :
    sharpLayerError p.energy (selectionError p) (Real.sqrt (activeSquared p))
      (Real.sqrt (gaussianSquared p)) (rank p) (bankSize p)≤14/(inverseError p:ℝ) := by
  unfold sharpLayerError
  rw [active_cost_allocation,gaussian_cost_allocation,selectionError_cube]
  have hs := sample_cost_allocation p
  have he : 4*(1/(4*(inverseError p:ℝ))+2*(inverseError p:ℝ)⁻¹+
      1/(inverseError p:ℝ)+1/(4*(inverseError p:ℝ)))=14/(inverseError p:ℝ) := by ring
  rw [←he]
  linarith

theorem readoutMoment_pos (p : Input) : 0<readoutMoment p := by
  unfold readoutMoment
  have := inverseFailure_pos p
  positivity

theorem readoutClip_pos (p : Input) : 0<readoutClip p := by
  unfold readoutClip
  have := readoutMoment_pos p
  positivity

theorem terminal_threshold_allocation (p : Input) :
    (readoutMoment p:ℝ)/readoutClip p+1/(16*((p.inverseRadius:ℝ)+1))=
      (1/((p.inverseRadius:ℝ)+1))/8 := by
  have hv : (readoutMoment p:ℝ)≠0 := (Nat.cast_pos.mpr (readoutMoment_pos p)).ne'
  have hr : (p.inverseRadius:ℝ)+1≠0 := by positivity
  simp only [readoutClip,Nat.cast_mul,Nat.cast_add,Nat.cast_ofNat,Nat.cast_one]
  field_simp
  ring

theorem terminal_sampling_allocation (p : Input) :
    (readoutMoment p:ℝ)/((bankSize p:ℝ)*(1/(16*((p.inverseRadius:ℝ)+1)))^2)≤
      (inverseFailure p:ℝ)⁻¹ := by
  have hH : (0:ℝ) < inverseFailure p := Nat.cast_pos.mpr (inverseFailure_pos p)
  have hm : (0:ℝ)<bankSize p := Nat.cast_pos.mpr (bankSize_pos p)
  have hr : (0:ℝ)<(p.inverseRadius:ℝ)+1 := by positivity
  have hbase : 256*(readoutMoment p*inverseFailure p*(p.inverseRadius+1)^2)≤bankSize p := by
    unfold bankSize
    omega
  have hbaseR : 256*((readoutMoment p:ℝ)*inverseFailure p*((p.inverseRadius:ℝ)+1)^2)≤bankSize p := by
    exact_mod_cast hbase
  rw [inv_eq_one_div]
  apply (div_le_div_iff₀ (by positivity) hH).mpr
  have hb := (le_div_iff₀ (by positivity : (0:ℝ)<256*((p.inverseRadius:ℝ)+1)^2)).mpr
    (show (readoutMoment p:ℝ)*inverseFailure p*(256*((p.inverseRadius:ℝ)+1)^2)≤bankSize p by nlinarith only [hbaseR])
  convert hb using 1 <;> field_simp <;> ring

end NeuralGeneralization.BatchTwoImprovedResources
