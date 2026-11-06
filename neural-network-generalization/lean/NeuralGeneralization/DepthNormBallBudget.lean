import NeuralGeneralization.DepthNormBallEnergy
import NeuralGeneralization.DepthNormBallSchedule
import NeuralGeneralization.DepthNormBallEmbedding
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-! The manuscript's full dimension/depth-dependent weighted-norm estimate. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.DepthNormBall
open Classical ConcreteModel BatchTwoNeuralConverse

lemma logarithmic_slope_bound {q : ℕ} (hq : 0 < q) :
    slope q ≤ 2*Real.log (2*(q:ℝ)) := by
  have hqR : (0:ℝ)<q := by exact_mod_cast hq
  have hq1 : (1:ℝ)≤q := by exact_mod_cast hq
  have hlog := Real.log_nonneg hq1
  have h16 : Real.log (16:ℝ)=4*Real.log 2 := by
    rw [show (16:ℝ)=2^4 by norm_num,Real.log_pow]
    norm_num
  unfold slope
  rw [Real.log_mul (by norm_num) hqR.ne',Real.log_mul (by norm_num) hqR.ne',h16]
  linarith

lemma first_energy_bound {q : ℕ} (hq : 0 < q) (d : ℕ) :
    (d:ℝ)/2*((slope q)^2*((q:ℝ)+(q-1:ℝ)^2)+1) ≤
      4*(d:ℝ)*(q:ℝ)^2*(Real.log (2*(q:ℝ)))^2 := by
  have hq1 : (1:ℝ)≤q := by exact_mod_cast hq
  have hqR : (0:ℝ)<q := by exact_mod_cast hq
  have hlog : (1/2:ℝ)≤Real.log (2*(q:ℝ)) := by
    have h := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    have hm := Real.log_le_log (by norm_num : (0:ℝ)<2) (show (2:ℝ)≤2*q by linarith)
    norm_num at h
    linarith
  have hshape : (q:ℝ)+(q-1:ℝ)^2 ≤ (q:ℝ)^2 := by nlinarith
  have hs := (sq_le_sq₀ (slope_pos hq).le (by linarith)).mpr (logarithmic_slope_bound hq)
  have hprod := mul_le_mul hs hshape (by positivity) (by positivity)
  have hunit : 1 ≤ 4*(q:ℝ)^2*(Real.log (2*(q:ℝ)))^2 := by
    have hq2 : (1:ℝ)≤(q:ℝ)^2 := by nlinarith
    have hlog2 : (1/4:ℝ)≤(Real.log (2*(q:ℝ)))^2 := by nlinarith
    nlinarith [mul_le_mul hq2 hlog2 (by norm_num) (sq_nonneg (q:ℝ))]
  have hh : (slope q)^2*((q:ℝ)+(q-1:ℝ)^2)+1 ≤ 8*(q:ℝ)^2*(Real.log (2*(q:ℝ)))^2 := by nlinarith
  have hm := mul_le_mul_of_nonneg_left hh (show 0≤(d:ℝ)/2 by positivity)
  nlinarith

lemma lifted_norm_eq {q d : ℕ} (m : ℕ) (e : Fin q ↪ Fin d) (v : Cube q → ℝ)
    (n : ℕ → ℕ) (t : ℕ → ℝ) (hn : ∀ j ≤ m, n j ≤ width q) :
    ConcreteModel.weightedSquaredNorm (liftInput e (weights m v n t)) =
      (d:ℝ)/2*((slope q)^2*((q:ℝ)+(q-1:ℝ)^2)+1)+
      ((∑ p, (bumpCoefficient v (t 0) p)^2)+(Fintype.card (Cube q):ℝ)*(constantCoefficient v (t 0))^2)+
      (∑ s : Fin m, (n (s.val+1):ℝ)*(n s.val:ℝ)*(Real.artanh (t (s.val+1))/((n s.val:ℝ)*t s.val))^2)+
      (width q:ℝ)*(n m:ℝ)*(1/((n m:ℝ)*t m))^2 := by
  rw [liftInput_norm,first_sq,Fin.sum_univ_succ,second_sq,readout_sq m v n t (hn m le_rfl)]
  simp_rw [relay_sq m v n t _ hn]
  have hM : (Fintype.card (Cube q):ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  simp only [width,Nat.cast_mul,Nat.cast_ofNat]
  field_simp
  <;> ring

lemma schedule_energy_bound (q : ℕ) {m : ℕ} (hm : 0 < m) (v : Cube q → ℝ)
    (hv : ∀ p, |v p| ≤ 4/3) :
      ((∑ p, (bumpCoefficient v (amplitude q m 0) p)^2)+
        (Fintype.card (Cube q):ℝ)*(constantCoefficient v (amplitude q m 0))^2)+
      (∑ s : Fin m, (population q m (s.val+1):ℝ)*(population q m s.val:ℝ)*
        (Real.artanh (amplitude q m (s.val+1))/((population q m s.val:ℝ)*amplitude q m s.val))^2)+
      (width q:ℝ)*(population q m m:ℝ)*(1/((population q m m:ℝ)*amplitude q m m))^2 ≤
      100*((m:ℝ)+1)*depthBudget q m := by
  have hi := second_energy_bound v hv (amplitude_pos q m 0).le (amplitude_le q hm (Nat.zero_le m))
  have hib : 45*(Fintype.card (Cube q):ℝ)*(amplitude q m 0)^2=(405/16:ℝ)*depthBudget q m := by
    have h := initial_balance q hm
    change (Fintype.card (Cube q):ℝ)*(amplitude q m 0)^2=(9/16:ℝ)*depthBudget q m at h
    nlinarith
  rw [hib] at hi
  have hrelay (s : Fin m) :
      (population q m (s.val+1):ℝ)*(population q m s.val:ℝ)*
        (Real.artanh (amplitude q m (s.val+1))/((population q m s.val:ℝ)*amplitude q m s.val))^2 ≤
      36*depthBudget q m := by
    have ha : (0:ℝ)<population q m s.val := by exact_mod_cast population_pos q m s.val
    have hb : (0:ℝ)≤population q m (s.val+1) := Nat.cast_nonneg _
    have h := relay_energy_bound ha hb (amplitude_pos q m s.val)
      (amplitude_pos q m (s.val+1)).le (amplitude_le q hm (by omega))
    have h' := schedule_relay_bound q hm s.val
    nlinarith
  have hs : (∑ s : Fin m, (population q m (s.val+1):ℝ)*(population q m s.val:ℝ)*
        (Real.artanh (amplitude q m (s.val+1))/((population q m s.val:ℝ)*amplitude q m s.val))^2) ≤
      (m:ℝ)*(36*depthBudget q m) := by
    simpa only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul] using
      Finset.sum_le_sum (s := Finset.univ) (fun s _ => hrelay s)
  have hr : (width q:ℝ)*(population q m m:ℝ)*(1/((population q m m:ℝ)*amplitude q m m))^2=(16/9:ℝ) := by
    rw [population_last q hm,amplitude_last]
    have hw : (width q:ℝ)≠0 := by exact_mod_cast (width_pos q).ne'
    field_simp
    <;> ring
  rw [hr]
  have hB := depthBudget_one_le q m
  have hmB : 0 ≤ (m:ℝ)*depthBudget q m := mul_nonneg (Nat.cast_nonneg _) (by linarith)
  nlinarith

lemma depthBudget_eq (q m : ℕ) : depthBudget q m=(2:ℝ)^(2*(q:ℝ)/(m+1)) := by
  have hM : vertices q=(2:ℝ)^q := by simp [vertices,Cube]
  rw [depthBudget,hM,Real.log_pow,Real.rpow_def_of_pos (by norm_num)]
  congr 1
  ring

/-- The bound has the manuscript's logarithmic first-layer cost and depth exponent. -/
theorem constructed_energy_bound {q d m : ℕ} (hq : 0 < q) (hm : 0 < m)
    (e : Fin q ↪ Fin d) (v : Cube q → ℝ) (hv : ∀ p, |v p| ≤ 4/3) :
    ConcreteModel.weightedSquaredNorm
      (liftInput e (weights m v (population q m) (amplitude q m))) ≤
      100*((d:ℝ)*(q:ℝ)^2*(Real.log (2*(q:ℝ)))^2+
        ((m:ℝ)+1)*(2:ℝ)^(2*(q:ℝ)/(m+1))) := by
  rw [lifted_norm_eq m e v _ _ (fun j hj => population_le q hm hj)]
  have hs := schedule_energy_bound q hm v hv
  have hf := first_energy_bound hq d
  rw [depthBudget_eq] at hs
  have hn : 0 ≤ (d:ℝ)*(q:ℝ)^2*(Real.log (2*(q:ℝ)))^2 := by positivity
  nlinarith

end NeuralGeneralization.DepthNormBall
