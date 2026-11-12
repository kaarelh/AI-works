import NeuralGeneralization.BatchTwoOnlineReluNormalized

/-! Exact per-layer energy of the enlarged, doubled, balanced ReLU teacher. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoActivation BatchTwoContinuousDepthPaper CompressionSampling
set_option maxHeartbeats 1400000
set_option backward.isDefEq.respectTransparency false

theorem exists_balanced_relu_layers {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (w : Weights d N r) (hne : ∃x,networkOutput relu w x≠0) :
    ∃v : Weights d N r,(∀x,networkOutput relu v x=networkOutput relu w x) ∧
      ∀i,weightedLayerEnergy v i=((d:ℝ)*(physicalProduct hN relu_zeroLipschitz w)^2)^((r+2:ℝ)⁻¹) := by
  obtain ⟨b,hb,hprod,henergy⟩ := exists_balancing_factors (weightedLayerEnergy w)
    (weightedLayerEnergy_pos_of_relu_output hd hN w hne)
  refine ⟨rescaleReluLayers b w,?_,?_⟩
  · intro x
    rw [rescaleReluLayers_output b (fun i=>(hb i).le) w x,hprod,one_mul]
  · intro i
    rw [rescaleReluLayers_energy,henergy,weightedLayerEnergy_product hN relu_zeroLipschitz]
    simp only [Fintype.card_sum,Fintype.card_fin,Fintype.card_bool,Nat.cast_add,Nat.cast_ofNat]

theorem whiten_coordinate_sq {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (w : Weights d N r) (i : WeightIndex d N r) :
    (whiten w i)^2=coordinatePrecision d N r i*(w i)^2 := by
  have hp := precision_mul_scale_sq hd hN i
  have hs : coordinateScale d N r i≠0 := (coordinateScale_pos hd hN i).ne'
  unfold whiten
  rw [div_pow]
  apply (div_eq_iff (pow_ne_zero 2 hs)).mpr
  nlinarith

theorem normalizedLayerNorm_whiten_first {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (w : Weights d N r) :
    (normalizedLayerNorm (whiten w) 0)^2=weightedLayerEnergy w (.inr true) := by
  simp only [normalizedLayerNorm_zero,firstBlockProjection,LinearMap.coe_mk,AddHom.coe_mk,
    EuclideanSpace.real_norm_sq_eq,PiLp.toLp_apply,whiten_coordinate_sq hd hN,
    coordinatePrecision,weightedLayerEnergy,Fintype.sum_prod_type,Finset.mul_sum]

theorem normalizedLayerNorm_whiten_internal {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (w : Weights d N r) (s : Fin r) :
    (normalizedLayerNorm (whiten w) s.castSucc.succ)^2=weightedLayerEnergy w (.inl s) := by
  simp only [normalizedLayerNorm_internal,internalFrobenius,EuclideanSpace.real_norm_sq_eq,
    PiLp.toLp_apply,whiten_coordinate_sq hd hN,coordinatePrecision,one_mul,weightedLayerEnergy,Fintype.sum_prod_type]

theorem normalizedLayerNorm_whiten_last {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (w : Weights d N r) :
    (normalizedLayerNorm (whiten w) (Fin.last (r+1)))^2=weightedLayerEnergy w (.inr false) := by
  simp only [normalizedLayerNorm_last,readoutEnergyVector,readoutBlockProjection,
    LinearMap.coe_mk,AddHom.coe_mk,EuclideanSpace.real_norm_sq_eq,PiLp.toLp_apply,
    whiten_coordinate_sq hd hN,coordinatePrecision,weightedLayerEnergy,Finset.mul_sum]

theorem balanced_whitened_layers {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (w : Weights d N r) {A : ℝ} (hA : 0≤A) (hw : ∀i,weightedLayerEnergy w i=A)
    (j : Fin (r+2)) : normalizedLayerNorm (whiten w) j=Real.sqrt A := by
  have hs : (normalizedLayerNorm (whiten w) j)^2=A := by
    refine Fin.cases ?_ (fun i=>?_) j
    · rw [normalizedLayerNorm_whiten_first hd hN,hw]
    · refine Fin.lastCases ?_ (fun s=>?_) i
      · rw [show (Fin.last r).succ=Fin.last (r+1) from rfl,normalizedLayerNorm_whiten_last hd hN,hw]
      · rw [normalizedLayerNorm_whiten_internal hd hN,hw]
  exact (sq_eq_sq₀ (normalizedLayerNorm_nonneg _ _) (Real.sqrt_nonneg _)).mp (hs.trans (Real.sq_sqrt hA).symm)

theorem physicalProduct_rescaleReadout {d N r : ℕ} (hN : 0<N) {a : ℝ} (ha : 0≤a)
    (w : Weights d N r) :
    physicalProduct hN relu_zeroLipschitz (rescaleReadout a w)=a*physicalProduct hN relu_zeroLipschitz w := by
  apply (sq_eq_sq₀ (physicalProduct_nonneg _ _ _) (mul_nonneg ha (physicalProduct_nonneg _ _ _))).mp
  rw [mul_pow,physicalProduct_sq,physicalProduct_sq]
  simp only [rescaleReadout,mul_pow,←Finset.mul_sum]
  ring

end NeuralGeneralization.BatchTwoOnlineReluFinite
