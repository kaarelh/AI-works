import NeuralGeneralization.BatchTwoContinuousInputStability
import NeuralGeneralization.BatchTwoContinuousDepthSphere

/-! The product-of-layer-energy bound retains the depth dependence needed by
the expanding-target lower bound. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous CompressionSampling Compression

def layerEnergy {N r : ℕ} (w : Weights 2 N r) : Fin r ⊕ Bool → ℝ
  | Sum.inl s => ∑ i,∑ j,(w (Sum.inr (Sum.inl (s,i,j))))^2
  | Sum.inr true => (2 : ℝ)/N*(∑ i,∑ j,(w (Sum.inl (i,j)))^2)
  | Sum.inr false => (N : ℝ)*(∑ i,(w (Sum.inr (Sum.inr i)))^2)

theorem layerEnergy_nonneg {N r : ℕ} (w : Weights 2 N r) (a : Fin r ⊕ Bool) :
    0 ≤ layerEnergy w a := by cases a with
  | inl s => unfold layerEnergy; positivity
  | inr b => cases b <;> unfold layerEnergy <;> positivity

theorem layerEnergy_sum {N r : ℕ} (w : Weights 2 N r) :
    ∑ a,layerEnergy w a=weightedSquaredNorm w := by
  simp only [Fintype.sum_sum_type,Fintype.sum_bool,layerEnergy,weightedSquaredNorm,Nat.cast_ofNat]
  ring

theorem product_le_power_of_sum {ι : Type*} [Fintype ι] (e : ι → ℝ)
    (he : ∀ i, 0 ≤ e i) (hs : ∑ i,e i ≤ 4*(Fintype.card ι : ℝ)) :
    ∏ i,e i ≤ (4 : ℝ)^Fintype.card ι := by
  classical
  have hp (i : ι) : e i ≤ 4*Real.exp (e i/4-1) := by
    have h := Real.add_one_le_exp (e i/4-1)
    linarith
  calc
    _ ≤ ∏ i,4*Real.exp (e i/4-1) := Finset.prod_le_prod (fun i _ => he i) (fun i _ => hp i)
    _ = (4 : ℝ)^Fintype.card ι * Real.exp ((∑ i,e i)/4-(Fintype.card ι : ℝ)) := by
      rw [Finset.prod_mul_distrib,← Real.exp_sum]
      simp [Finset.sum_sub_distrib,← Finset.sum_div]
    _ ≤ (4 : ℝ)^Fintype.card ι*1 := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      rw [Real.exp_le_one_iff]
      linarith
    _ = _ := mul_one _

theorem energy_product_bound {N r : ℕ} (w : Weights 2 N r)
    (hw : weightedSquaredNorm w ≤ 4*((r : ℝ)+2)) :
    ∏ a,layerEnergy w a ≤ (4 : ℝ)^(r+2) := by
  have h := product_le_power_of_sum (layerEnergy w) (layerEnergy_nonneg w) (by
    simpa only [layerEnergy_sum,Fintype.card_sum,Fintype.card_fin,Fintype.card_bool,Nat.cast_add,
      Nat.cast_ofNat] using hw)
  simpa only [Fintype.card_sum,Fintype.card_fin,Fintype.card_bool] using h

theorem energy_product_suffix {N r : ℕ} (hN : 0 < N) (w : Weights 2 N r) :
    suffixSquaredGain w 0*(∑ i,∑ j,(w (Sum.inl (i,j)))^2)=
      (∏ a,layerEnergy w a)/2 := by
  have hNR : (N : ℝ)≠0 := by exact_mod_cast hN.ne'
  simp only [Fintype.prod_sum_type,Fintype.prod_bool,layerEnergy,suffixSquaredGain,List.drop_zero,
    ← Fin.prod_univ_def]
  field_simp
  <;> ring

/-- Actual Euclidean Lipschitz estimate for every finite-width network in the
linear-in-depth energy sublevel. -/
theorem output_energy_lipschitz {N r : ℕ} (hN : 0 < N) (w : Weights 2 N r)
    (hw : weightedSquaredNorm w ≤ 4*((r : ℝ)+2)) (x y : RealInput 2) :
    |output Real.tanh w x-output Real.tanh w y| ≤ (2 : ℝ)^(r+2)*inputDistance x y := by
  have hφ : ∀ t s, |Real.tanh t-Real.tanh s| ≤ |t-s| := tanh_admissible.2
  have hh := activated_matrix_squaredDistance_le Real.tanh hφ
    (fun i j => w (Sum.inl (i,j))) (augmentedInput x) (augmentedInput y)
  rw [augmented_difference_sq_sum] at hh
  have hs := suffix_readout_squaredDistance_le Real.tanh hφ w 0
    (BatchTwoContinuous.firstHidden Real.tanh w x) (BatchTwoContinuous.firstHidden Real.tanh w y)
  have hs' : (output Real.tanh w x-output Real.tanh w y)^2 ≤
      suffixSquaredGain w 0*squaredDistance (BatchTwoContinuous.firstHidden Real.tanh w x)
        (BatchTwoContinuous.firstHidden Real.tanh w y) := by
    simpa [output,BatchTwoContinuous.finalHidden,linearReadout,hiddenSuffix] using hs
  have hsum : 0 ≤ ∑ i,(x i-y i)^2 := by positivity
  have hh' : squaredDistance (BatchTwoContinuous.firstHidden Real.tanh w x)
      (BatchTwoContinuous.firstHidden Real.tanh w y) ≤
      (∑ i,∑ j,(w (Sum.inl (i,j)))^2)*(∑ i,(x i-y i)^2) := hh
  have hbound : (output Real.tanh w x-output Real.tanh w y)^2 ≤
      (4 : ℝ)^(r+2)*(∑ i,(x i-y i)^2) := by
    calc
      _ ≤ suffixSquaredGain w 0*((∑ i,∑ j,(w (Sum.inl (i,j)))^2)*(∑ i,(x i-y i)^2)) :=
        hs'.trans (mul_le_mul_of_nonneg_left hh' (suffixSquaredGain_nonneg w 0))
      _ = ((∏ a,layerEnergy w a)/2)*(∑ i,(x i-y i)^2) := by rw [← mul_assoc,energy_product_suffix hN]
      _ ≤ (4 : ℝ)^(r+2)*(∑ i,(x i-y i)^2) := by
        apply mul_le_mul_of_nonneg_right _ hsum
        have hp := energy_product_bound w hw
        have hp0 : 0 ≤ ∏ a,layerEnergy w a := Finset.prod_nonneg (fun i _ => layerEnergy_nonneg w i)
        linarith
  apply abs_le_of_sq_le_sq _ (by unfold inputDistance; positivity)
  unfold inputDistance
  rw [mul_pow,Real.sq_sqrt hsum,pow_right_comm]
  norm_num only [Nat.reducePow]
  exact hbound

end NeuralGeneralization.BatchTwoContinuousDepthLower
