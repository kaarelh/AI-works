import NeuralGeneralization.BatchTwoActivationFullNetworkEventsMeasurable

/-! Actual layer tails at the shared finite-width threshold. -/
noncomputable section
set_option maxHeartbeats 1200000
set_option maxRecDepth 10000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open RobustCompressionBlockMoments NetworkLayerSplit TowerNetwork ProductFiberBound

variable {b d K H N r : ℕ} {σ ℓ B : ℝ} {φ : ℝ→ℝ}

theorem activationStageBad_tail (hb : 1≤b) (hK : 1≤K)
    {s n : ℕ} (hs : s≤H) (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ0 : 0≤ℓ) (hB0 : 0≤B) (hℓ : ℓ≤b) (hB : B≤b)
    (hder : ∀t,|deriv scalarCutoff t|≤B)
    (hder2 : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (hwidth : activationLearnerThreshold b d K H≤N)
    (c : Cube d→Fin n→ℝ) (hvar : ∀x,∑j,(c x j)^2≤(activationDiagonalBudget b d K s:ℝ)) :
    (iidSamples (standardLaw (Fin n)) N).real
      (polynomialLayerBad c φ (activationStageBudget H (activationBaseBudget b d K H) s) N
        (activationDiagonalBudget b d K s) (4*(K:ℝ)))≤2*Real.exp (-(N:ℝ)*(K:ℝ)) := by
  obtain ⟨hk,hℓk,hBk,_,_,_,_,hlog⟩:=activation_stage_budget_envelopes hb hK hs hℓ hB
  have hw : (activationStageBudget H (activationBaseBudget b d K H) s)^84≤N :=
    (Nat.pow_le_pow_left (activationStageBudget_le_max H (activationBaseBudget b d K H) s) 84).trans hwidth
  exact polynomialLayerBad_tail c _ hk hφ hℓ0 hB0
    (Nat.cast_pos.mpr (activationDiagonalBudget_pos hb)) hℓk hBk hlog hder hder2 hvar hw
    (by exact_mod_cast hK) le_rfl

theorem activationInputBad_tail (hd : 0<d) (hN : 0<N) (hb : 1≤b) (hK : 1≤K)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0≤ℓ) (hB0 : 0≤B)
    (hℓ : ℓ≤b) (hB : B≤b) (hder : ∀t,|deriv scalarCutoff t|≤B)
    (hder2 : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (hwidth : activationLearnerThreshold b d K H≤N) :
    (smallPrior d N 0 σ).real (activationInputBad b d K H N φ σ)≤2*Real.exp (-(N:ℝ)*(K:ℝ)) := by
  have hbad := (activationStageBad_joint_measurable (d:=d) (N:=N) hb hK (s:=0) (n:=d+1) (Nat.zero_le H)
    hφ hℓ0 hB0 hℓ hB hder hder2).preimage
      (f:=fun z : Fin N→Fin (d+1)→ℝ=>(activationInputSource d N σ,z))
      (measurable_const.prodMk measurable_id)
  change MeasurableSet (polynomialLayerBad (activationInputSource d N σ) φ
    (activationStageBudget H (activationBaseBudget b d K H) 0) N
    (activationDiagonalBudget b d K 0) (4*(K:ℝ))) at hbad
  have ht:=activationStageBad_tail hb hK (s:=0) (Nat.zero_le H)
    hφ hℓ0 hB0 hℓ hB hder hder2 hwidth
    (activationInputSource d N σ) (activationInputSource_energy hd hscale)
  rw [←activationInputRows_law (r:=0) hd hN hσ,Measure.real,
    Measure.map_apply (measurable_activationInputRows σ) hbad] at ht
  exact ht

def activationNewBad (b d K H N r : ℕ) (φ : ℝ→ℝ) (σ : ℝ) : Set (Weights d N (r+1)) :=
  {w | ActivationGoodHidden b d K H N φ σ r (previousWeights w) ∧
    w∈activationLastBad b d K H N r φ σ}

theorem activationNewBad_tail (hd : 0<d) (hN : 0<N) (hb : 1≤b) (hK : 1≤K)
    (hr : r+1≤H) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0≤ℓ) (hB0 : 0≤B)
    (hℓ : ℓ≤b) (hB : B≤b) (hder : ∀t,|deriv scalarCutoff t|≤B)
    (hder2 : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (hwidth : activationLearnerThreshold b d K H≤N) :
    (smallPrior d N (r+1) σ).real (activationNewBad b d K H N r φ σ)≤
      2*Real.exp (-(N:ℝ)*(K:ℝ)) := by
  have hgood:=measurableSet_ActivationGoodHidden (d:=d) (H:=H) (N:=N) (σ:=σ) hb hK hφ hℓ0 hB0 hℓ hB hder hder2 r (by omega)
  have hbad:=measurableSet_activationLastBad (d:=d) (H:=H) (N:=N) (r:=r) (σ:=σ) hb hK hr hφ hℓ0 hB0 hℓ hB hder hder2
  have hnew : MeasurableSet (activationNewBad b d K H N r φ σ) :=
    (hgood.preimage continuous_previousWeights.measurable).inter hbad
  have hp:=MeasurePreserving.symm (split d N r) (activationSmallPrior_split d N r σ)
  rw [←hp.map_eq,Measure.real,Measure.map_apply hp.measurable hnew]
  apply real_prod_le (smallPrior d N r σ) (activationMatrixPrior N σ)
    ((split d N r).symm ⁻¹' activationNewBad b d K H N r φ σ)
    (hnew.preimage hp.measurable) (by positivity)
  intro w
  by_cases hw : ActivationGoodHidden b d K H N φ σ r w
  · have hset : Prod.mk w ⁻¹' ((split d N r).symm ⁻¹' activationNewBad b d K H N r φ σ)=
        activationMatrixRows σ ⁻¹' polynomialLayerBad (activationLastSource φ σ w) φ
          (activationStageBudget H (activationBaseBudget b d K H) (r+1)) N
          (activationDiagonalBudget b d K (r+1)) (4*(K:ℝ)) := by
      ext a
      simp only [Set.mem_preimage,activationNewBad,Set.mem_setOf_eq,split_symm_apply,
        previousWeights_appendLayer,hw,true_and,activationLastBad,activationLastRows,
        lastMatrix_appendLayer,activationMatrixRows]
      have hrows : activationLastRows σ (appendLayer w (fun i j=>a (i,j)))=activationMatrixRows σ a := by
        funext i j
        simp only [activationLastRows,lastMatrix_appendLayer,activationMatrixRows]
      rw [hrows]
    rw [hset]
    have hvar:=activationLastSource_energy hN hscale w (activationDiagonalBudget b d K (r+1))
      (Nat.cast_nonneg _) (ActivationGoodHidden.diagonal hd hN hb hK hσ hscale hφ hℓ0 hℓ r w hw)
    have ht:=activationStageBad_tail hb hK hr hφ hℓ0 hB0 hℓ hB hder hder2 hwidth
      (activationLastSource φ σ w) hvar
    have hmeas := (activationStageBad_joint_measurable (d:=d) (N:=N) (n:=N) hb hK hr
      hφ hℓ0 hB0 hℓ hB hder hder2).preimage
      (f:=fun z : Fin N→Fin N→ℝ=>(activationLastSource φ σ w,z))
      (measurable_const.prodMk measurable_id)
    change MeasurableSet (polynomialLayerBad (activationLastSource φ σ w) φ
      (activationStageBudget H (activationBaseBudget b d K H) (r+1)) N
      (activationDiagonalBudget b d K (r+1)) (4*(K:ℝ))) at hmeas
    rw [←activationMatrixRows_law hσ,Measure.real,
      Measure.map_apply (measurable_activationMatrixRows σ) hmeas] at ht
    exact ht
  · have hset : Prod.mk w ⁻¹' ((split d N r).symm ⁻¹' activationNewBad b d K H N r φ σ)=∅ := by
      ext a
      simp only [Set.mem_preimage,activationNewBad,Set.mem_setOf_eq,split_symm_apply,
        previousWeights_appendLayer,hw,false_and,Set.mem_empty_iff_false]
    rw [hset,measureReal_empty]
    positivity

end NeuralGeneralization.BatchTwoActivation
