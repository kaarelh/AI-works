import NeuralGeneralization.BatchTwoContinuousFiniteTargetBudget
import NeuralGeneralization.BatchTwoContinuousCloning
import NeuralGeneralization.BatchTwoContinuousParameterGrid

/-! Uniform real-input stability of the actual non-Gaussian clone cylinder. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteTarget
open ConcreteModel BatchTwoNonGaussian

theorem cylinder_output_error_sq {d C k p N r : ℕ}
    (hd : 0<d) (hN : 0<N) (hk : 0<k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (teacher : Weights d C r)
    {K b σ η : ℝ} (hK : 0≤K) (hb : 0≤b) (hσ : 0≤σ) (hη : 0≤η) (hη1 : η≤1)
    (hscale : (N : ℝ)*σ^2≤1) (hv : weightedSquaredNorm (clonedWeights e teacher) ≤ K)
    (z : Weights d N r) (hz : z ∈ noiseCylinder d e η b r)
    (x : RealInput d) (hx : ∑ j, x j^2≤1) :
    (output Real.tanh (translatedNoise (clonedWeights e teacher) σ z) x-
      output Real.tanh (clonedWeights e teacher) x)^2 ≤
      (((d : ℝ)+1)*η)^2*(2*(2*K)*cylinderInputFactor d*
        (cylinderAmplification (2*K) C (2*(b+C+1)))^r+2) := by
  let v := clonedWeights e teacher
  let w := translatedNoise v σ z
  let δ := ((d : ℝ)+1)*η
  have hηδ : η≤δ := by dsimp [δ]; nlinarith [Nat.cast_nonneg d (α := ℝ)]
  obtain ⟨hfirst,hread,hmat⟩ := (noiseCylinder_iff d e η b r z).mp hz
  let Z := fun (s : Fin r) (i j : Fin N) => z (.inr (.inl (s,i,j)))
  let R := fun (s : Fin r) (i j : Fin N) => groupRow e σ (Z s i) j
  let E := fun (s : Fin r) (i j : Fin N) => σ*Z s i j-R s i j
  have hfst (i : Fin N) (j : Fin (d+1)) : |w (.inl (i,j))-v (.inl (i,j))|≤η := by
    change |v (.inl (i,j))+σ*Real.sqrt ((N : ℝ)/d)*z (.inl (i,j))-v (.inl (i,j))|≤η
    rw [add_sub_cancel_left,abs_mul,abs_of_nonneg (by positivity)]
    exact (mul_le_mul (smallScale_first_le_one hd hσ hscale) (hfirst i j)
      (abs_nonneg _) zero_le_one).trans_eq (one_mul _)
  have hfreeze (i : Fin N) (j : Fin (d+1)) :
      |freezeInput x w (.inl (i,j))-freezeInput x v (.inl (i,j))|≤δ := by
    refine Fin.cases ?_ (fun j => ?_) j
    · change |(∑ a, w (.inl (i,a))*augmentedInput x a)-
        (∑ a, v (.inl (i,a))*augmentedInput x a)|≤δ
      rw [←Finset.sum_sub_distrib]
      calc
        _ ≤ ∑ a, |w (.inl (i,a))*augmentedInput x a-v (.inl (i,a))*augmentedInput x a| :=
          Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _a : Fin (d+1), η := by
          apply Finset.sum_le_sum
          intro a _
          rw [←sub_mul,abs_mul]
          exact (mul_le_mul (hfst i a) (augmentedInput_abs_le_one x hx a) (abs_nonneg _) hη).trans (by simp)
        _ = δ := by simp [δ]
    · simpa [freezeInput] using (show 0≤δ by positivity)
  have hout := cylinder_networkOutput_error_sq hN Real.tanh tanh_admissible
    (freezeInput x w) (freezeInput x v) R E (2*K) C (2*(b+C+1)) δ
    (by positivity) (Nat.cast_nonneg C) (by positivity)
    (by intro s i j; dsimp [freezeInput,w,v,translatedNoise,smallScale,R,E,Z]; ring)
    ((energy_freeze_unit_ball x hx v).trans (mul_le_mul_of_nonneg_left hv (by norm_num)))
    (by
      intro s
      apply (groupRow_matrix_energy_le hk e σ (Z s) hη (hmat s).1 hscale).trans
      have hh := pow_le_pow_left₀ hη hηδ 2
      nlinarith [mul_le_mul_of_nonneg_right hh (Nat.cast_nonneg C : (0 : ℝ)≤C)])
    (by
      intro s
      exact groupResidual_action_bound hk e σ (Z s) hη hη1 hb (hmat s).1 hscale
        (scaled_matrix_action hσ hscale _ (hmat s).2)) hfreeze
    (by
      intro i
      change |v (.inr (.inr i))+σ/Real.sqrt N*z (.inr (.inr i))-v (.inr (.inr i))|≤δ/N
      rw [add_sub_cancel_left,abs_mul,abs_of_nonneg (by positivity)]
      have hs : 0<Real.sqrt (N : ℝ) := Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN)
      have hs2 := Real.sq_sqrt (Nat.cast_nonneg N : (0 : ℝ)≤N)
      have hcoeff : σ/Real.sqrt N≤1/(N : ℝ) := by
        apply (div_le_div_iff₀ hs (Nat.cast_pos.mpr hN)).mpr
        have hh := mul_le_mul_of_nonneg_right (sigma_sqrt_width_le_one hσ hscale) hs.le
        nlinarith
      apply (mul_le_mul hcoeff (hread i) (abs_nonneg _) (by positivity)).trans
      exact (show (1/(N : ℝ))*η=η/N by ring).le.trans
        (div_le_div_of_nonneg_right hηδ (Nat.cast_nonneg N)))
    (by
      intro y ss s i
      dsimp only [v]
      rw [freeze_clonedWeights,firstHidden_cloned,hiddenFold_cloned hk]
      exact groupRow_annihilation hk e σ (Z s i) _ Real.tanh (by simp))
    (fun _ => false)
  simpa only [output_freeze] using hout


theorem cylinder_output_error {d C k p N r : ℕ}
    (hd : 0<d) (hN : 0<N) (hk : 0<k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (teacher : Weights d C r)
    {K b σ η t : ℝ} (hK : 0≤K) (hb : 0≤b) (hσ : 0≤σ) (hη : 0≤η) (hη1 : η≤1)
    (ht : 0≤t) (hscale : (N : ℝ)*σ^2≤1)
    (hv : weightedSquaredNorm (clonedWeights e teacher) ≤ K)
    (hradius : ((d : ℝ)+1)*η ≤ t*cylinderRadius d r (2*K) C (2*(b+C+1)))
    (z : Weights d N r) (hz : z ∈ noiseCylinder d e η b r)
    (x : RealInput d) (hx : ∑ j, x j^2≤1) :
    |output Real.tanh (translatedNoise (clonedWeights e teacher) σ z) x-
      output Real.tanh (clonedWeights e teacher) x| ≤ t/2 := by
  let F := 2*(2*K)*cylinderInputFactor d*(cylinderAmplification (2*K) C (2*(b+C+1)))^r+2
  have hF : 1≤F := by
    have hh : 0≤2*(2*K)*cylinderInputFactor d*(cylinderAmplification (2*K) C (2*(b+C+1)))^r := by
      unfold cylinderInputFactor cylinderAmplification
      positivity
    dsimp only [F]
    linarith
  have hFp : 0<F := by linarith
  have hrad : (cylinderRadius d r (2*K) C (2*(b+C+1)))^2*F≤1/4 := by
    change (2*F)⁻¹^2*F≤1/4
    have he : (2*F)⁻¹^2*F=1/(4*F) := by field_simp; norm_num
    rw [he]
    apply (div_le_iff₀ (by positivity : 0<4*F)).mpr
    linarith
  have hh := cylinder_output_error_sq hd hN hk e teacher hK hb hσ hη hη1 hscale hv z hz x hx
  have hsq := pow_le_pow_left₀ (by positivity : 0≤((d : ℝ)+1)*η) hradius 2
  have hm := mul_le_mul_of_nonneg_right hsq hFp.le
  have hn := mul_le_mul_of_nonneg_left hrad (sq_nonneg t)
  apply abs_le_of_sq_le_sq _ (by positivity : 0≤t/2)
  change _ ≤ (((d : ℝ)+1)*η)^2*F at hh
  rw [mul_pow] at hm
  nlinarith

end NeuralGeneralization.BatchTwoContinuous.FiniteTarget
