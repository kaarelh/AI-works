import NeuralGeneralization.BatchTwoActivationForwardBudgets

/-! One genuine finite-network extension, including zero padding, exact state
preservation, and global polynomial row-energy bounds. -/
noncomputable section
set_option maxRecDepth 10000
set_option maxHeartbeats 1600000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel GaussianAngularPrice GaussianAngularFields FiniteDifferential

theorem fixed_reconstruction_step {b d K H s n N : ℕ}
    (hb : 1≤b) (hK : 1≤K) (hs : s<H) (hN : 0<N)
    {ℓ B : ℝ} (hℓ0 : 0<ℓ) (hℓ : ℓ≤b) (hB0 : 0≤B) (hB : B≤b)
    {φ : ℝ → ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hb' : ∀t,|deriv scalarCutoff t|≤B) (hbb : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (c : Cube d → Fin n → ℝ) (z : Fin N → Fin n → ℝ)
    (hvar : ∀x,(∑j,(c x j)^2)≤activationDiagonalBudget b d K s)
    (hgood : z∉polynomialLayerBad c φ
      (activationStageBudget H (activationBaseBudget b d K H) s) N
      (activationDiagonalBudget b d K s) (4*K))
    (W : FixedActivationNetwork d (activationFiniteWidth b d K H) ℓ (activationRawBudget b d K H))
    (v : Fin (fixedInputWidth d (activationFiniteWidth b d K H) s) → ℝ)
    (hv : ∀j,0≤v j ∧ v j≤1+56*(K:ℝ))
    (hstate : ∀j x,|fixedActivationState W x s j|≤activationStageStateBound b d K H s)
    (hcov : ∀x y,|weightedFeatureGram (fun j x => fixedActivationState W x s j) v x y-
      gram c x y|≤1/((activationStageBudget H (activationBaseBudget b d K H) s:ℝ)^160)) :
    ∃(W' : FixedActivationNetwork d (activationFiniteWidth b d K H) ℓ (activationRawBudget b d K H))
      (v' : Fin (activationFiniteWidth b d K H) → ℝ),
      (∀j,0≤v' j ∧ v' j≤1+56*(K:ℝ)) ∧
      (∀j x,|fixedActivationState W' x (s+1) j|≤activationStageStateBound b d K H (s+1)) ∧
      (∀x t,t≤s → fixedActivationState W' x t=fixedActivationState W x t) ∧
      ∀x y,|weightedFeatureGram (fun j x => fixedActivationState W' x (s+1) j) v' x y-
        (∑j,φ (fieldLinear c (z j) x)*φ (fieldLinear c (z j) y))/(N:ℝ)|<
          1/(activationStageBudget H (activationBaseBudget b d K H) s:ℝ) := by
  classical
  let F := activationFiniteWidth b d K H
  let k := activationStageBudget H (activationBaseBudget b d K H) s
  let S : ℝ := activationStageStateBound b d K H s
  let V : ℝ := 1+56*(K:ℝ)
  let R : ℝ := activationRowBudget b d K H
  have hF : 0<F := activationFiniteWidth_pos _ _ _ _
  have hdF : d+1≤F := by dsimp [F,activationFiniteWidth]; omega
  have hrF : fixedInputWidth d F s≤F := fixedInputWidth_le hdF
  have hS : 1≤S := by dsimp [S]; exact_mod_cast activationStageStateBound_one_le b d K H s
  have hS0 : 0≤S := by linarith
  have hV0 : 0≤V := by dsimp [V]; positivity
  have hR0 : 0≤R := Nat.cast_nonneg _
  have hkmax : k≤activationMaxBudget b d K H := activationStageBudget_le_max _ _ _
  obtain ⟨hk,hℓk,hBk,hMk,hqk,hAk,hgauss,hlog⟩ :=
    activation_stage_budget_envelopes hb hK hs.le hℓ hB
  have hM0 : (0:ℝ)<activationDiagonalBudget b d K s := by
    exact_mod_cast activationDiagonalBudget_pos (d:=d) (K:=K) (H:=s) hb
  have hq0 : 0<4*(K:ℝ) := by exact_mod_cast (show 0<4*K by omega)
  obtain ⟨ψ,R₀,v₀,hψ,hv₀,hR₀,hs₀,hQ₀⟩ := polynomial_gaussian_one_step c z k hk
    hφ hℓ0 hM0 hB0 hq0 hℓk hMk hBk hqk hAk hgauss hlog hb' hbb hN hvar hgood
    (fun j x => fixedActivationState W x s j) v hV0 hS0 (fun j => (hv j).1)
    (fun j => (hv j).2) hstate hcov
  simp only [Fintype.card_fin] at hR₀ hs₀
  have hweight0 : 0≤polynomialStepWeightBound k (fixedInputWidth d F s) V S := by
    dsimp [polynomialStepWeightBound,polynomialBulkSourceBound]
    positivity
  have hweight : polynomialStepWeightBound k (fixedInputWidth d F s) V S≤R*S :=
    activation_step_weight_envelope hkmax hrF hV0 (le_refl _) hS
  have hcoef : max 1 (8*(4*(K:ℝ)+Real.log 3))≤V := by
    have hkR : (1:ℝ)≤K := by exact_mod_cast hK
    have hlog3 : Real.log 3≤2 := by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<3)]
    apply max_le <;> dsimp [V] <;> linarith
  have hstatemax : ℓ*(fixedInputWidth d F s:ℝ)*
      polynomialStepWeightBound k (fixedInputWidth d F s) V S*S≤
        (activationStageStateBound b d K H (s+1):ℝ) := by
    have hrFR : (fixedInputWidth d F s:ℝ)≤F := by exact_mod_cast hrF
    have hb0 : (0:ℝ)≤b := Nat.cast_nonneg _
    have hstep : (b:ℝ)*(F:ℝ)*R*S^2≤activationStageStateBound b d K H (s+1) := by
      dsimp [F,R,S]
      exact_mod_cast activationStageStateBound_step b d K H s
    apply le_trans _ hstep
    calc
      _ ≤ (b:ℝ)*(F:ℝ)*(R*S)*S := by gcongr
      _ = _ := by ring
  have hpad : Fintype.card (Fin (k^48) ⊕ Fin (k^20))≤F := by
    simpa only [Fintype.card_sum,Fintype.card_fin] using activation_layer_width_le hkmax
  obtain ⟨ψ',R',v',hψ',hv',hR',hs',hpadQ⟩ := pad_weighted_layer F hpad ψ R₀ v₀
    (fun j x => fixedActivationState W x s j) hℓ0.le hV0
    (mul_nonneg hR0 hS0) (Nat.cast_nonneg (activationStageStateBound b d K H (s+1))) hψ
    (fun j => ⟨(hv₀ j).1,(hv₀ j).2.trans hcoef⟩)
    (fun j l => (hR₀ j l).trans hweight) (fun j x => (hs₀ j x).trans hstatemax)
  let rows : Fin F → EuclideanSpace ℝ (Fin (fixedInputWidth d F s)) := fun j => WithLp.toLp 2 (R' j)
  have henergy : (∑j,‖rows j‖^2)≤(activationRawBudget b d K H:ℝ)^2 := by
    apply finite_rows_energy_bound (mul_nonneg hR0 hS0) R' hR'
    apply le_trans _ (activationRawBudget_layer hs.le)
    have hrFR : (fixedInputWidth d F s:ℝ)≤F := by exact_mod_cast hrF
    change (F:ℝ)*(fixedInputWidth d F s:ℝ)*(R*S)^2≤(F:ℝ)^2*(R*S)^2
    nlinarith [mul_nonneg (Nat.cast_nonneg F) (sq_nonneg (R*S))]
  let W' := W.update s ψ' rows hψ' henergy
  have hnew (x : Cube d) (j : Fin F) : fixedActivationState W' x (s+1) j=
      ψ' j (∑l,R' j l*fixedActivationState W x s l) := by
    rw [FixedActivationNetwork.update_state_succ]
    simp only [rows,PiLp.inner_apply,RCLike.inner_apply,conj_trivial,mul_comm]
    rfl
  refine ⟨W',v',hv',?_,?_,?_⟩
  · intro j x
    rw [hnew]
    exact hs' j x
  · intro x t ht
    exact W.update_state_le s ψ' rows hψ' henergy x t ht
  · intro x y
    have he : weightedFeatureGram (fun j x => fixedActivationState W' x (s+1) j) v' x y=
      weightedFeatureGram (fun j x => ψ' j (∑l,R' j l*fixedActivationState W x s l)) v' x y := by
      unfold weightedFeatureGram
      simp only [hnew]
      rfl
    rw [he,hpadQ]
    exact hQ₀ x y

end NeuralGeneralization.BatchTwoActivation
