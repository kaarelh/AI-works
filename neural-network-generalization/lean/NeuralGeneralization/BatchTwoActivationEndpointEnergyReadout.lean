import NeuralGeneralization.BatchTwoActivationEndpointEnergy

/-! The covariance dual becomes the ordinary readout of the finite tower. -/
noncomputable section
set_option maxRecDepth 10000
set_option maxHeartbeats 1200000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem fixed_tower_readout_energy_witness {b d K H : ℕ} (hH : 0<H) {ℓ : ℝ} (hℓ : 0<ℓ)
    (W : FixedActivationNetwork d (activationFiniteWidth b d K H) ℓ (activationRawBudget b d K H))
    (v : Fin (fixedInputWidth d (activationFiniteWidth b d K H) H) → ℝ)
    (hv : ∀j,0≤v j ∧ v j≤1+56*(K:ℝ))
    (hs : ∀j x,|fixedActivationState W x H j|≤activationStateBudget b d K H)
    (β : Cube d → ℝ) (hβ : (∑x,|β x|)≤32*(K:ℝ)) (f : BooleanFunction d)
    (hpred : ∀x,(7/8:ℝ)≤labelReal (f x)*(∑y,β y*
      weightedFeatureGram (fun j x => fixedActivationState W x H j) v x y)) :
    ∃R:RawAuxiliaryNetwork d H ℓ (activationRawBudget b d K H),
      (∀s,R.width s=activationFiniteWidth b d K H) ∧
      (∀x,(7/8:ℝ)≤labelReal (f x)*rawAuxiliaryOutput R x) ∧
      rawAuxiliaryWeightedEnergy R≤(activationEndpointEnergyBudget b d K H:ℝ) := by
  classical
  let F := activationFiniteWidth b d K H
  let S : ℝ := activationStateBudget b d K H
  let V : ℝ := 1+56*(K:ℝ)
  have hdim : fixedInputWidth d F H=F := by cases H <;> simp_all [fixedInputWidth]
  let u : EuclideanSpace ℝ (Fin (fixedInputWidth d F H)) :=
    WithLp.toLp 2 (fun j => v j*(∑x,β x*fixedActivationState W x H j))
  have hu (j) : |u j|≤32*(K:ℝ)*V*S := by
    change |v j*(∑x,β x*fixedActivationState W x H j)|≤_
    have hsum : |∑x,β x*fixedActivationState W x H j|≤32*(K:ℝ)*S := by
      calc
        _ ≤ ∑x,|β x*fixedActivationState W x H j| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑x,|β x| *S := by
          apply Finset.sum_le_sum
          intro x _
          rw [abs_mul]
          exact mul_le_mul_of_nonneg_left (hs j x) (abs_nonneg _)
        _ = (∑x,|β x|)*S := by rw [Finset.sum_mul]
        _ ≤ _ := mul_le_mul_of_nonneg_right hβ (Nat.cast_nonneg _)
    rw [abs_mul,abs_of_nonneg (hv j).1]
    have hh := mul_le_mul (hv j).2 hsum (abs_nonneg _) (show 0≤V by dsimp [V]; positivity)
    nlinarith
  have hunorm : ‖u‖≤(activationRawBudget b d K H:ℝ) := by
    have hsq : ‖u‖^2≤(activationRawBudget b d K H:ℝ)^2 := by
      rw [EuclideanSpace.real_norm_sq_eq]
      apply le_trans _ activationRawBudget_readout
      calc
        _ ≤ ∑_j : Fin (fixedInputWidth d F H),(32*(K:ℝ)*V*S)^2 := by
          apply Finset.sum_le_sum
          intro j _
          exact sq_le_sq.mpr ((hu j).trans_eq (abs_of_nonneg (by dsimp [V,S]; positivity)).symm)
        _ = _ := by simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,hdim]; rfl
    exact (sq_le_sq₀ (norm_nonneg _) (Nat.cast_nonneg _)).mp hsq
  have houtput (x : Cube d) : ⟪u,fixedActivationState W x H⟫=
      ∑y,β y*weightedFeatureGram (fun j x => fixedActivationState W x H j) v x y := by
    simp only [u,PiLp.inner_apply,RCLike.inner_apply,conj_trivial,weightedFeatureGram]
    simp only [Finset.mul_sum]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro y _
    apply Finset.sum_congr rfl
    intro j _
    ring
  let R := W.toRaw (activationFiniteWidth_pos b d K H) H u hunorm
  refine ⟨R,fun _=>rfl,?_,?_⟩
  · intro x
    have ho : rawAuxiliaryOutput R x=⟪u,fixedActivationState W x H⟫ := by
      unfold rawAuxiliaryOutput
      rw [FixedActivationNetwork.toRaw_state]
      rfl
    rw [ho,houtput]
    exact hpred x
  · have he:=rawAuxiliaryWeightedEnergy_bound (F:=activationFiniteWidth b d K H) R (Nat.cast_nonneg _) (fun _=>rfl)
    simpa only [activationEndpointEnergyBudget,Nat.cast_mul,Nat.cast_add,Nat.cast_pow] using he

end NeuralGeneralization.BatchTwoActivation
