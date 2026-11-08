import NeuralGeneralization.OnlineLowerSamplerEquiv
import NeuralGeneralization.OnlineLowerReluWalshIntegral

/-! # Literal affine scores and Walsh coefficients in sampler coordinates -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

def samplerWeights {p : ℕ} (P r : Fin p → ℕ) (a b : Fin p → ℝ)
    (j : Fin (railDimension (samplerSize P r))) : ℝ :=
  if ((railIndex (samplerSize P r)).symm j).2.1 then
    b (((railIndex (samplerSize P r)).symm j).1)
  else a (((railIndex (samplerSize P r)).symm j).1)

theorem samplerWeights_apply {p : ℕ} (P r : Fin p → ℕ) (a b : Fin p → ℝ)
    (i : Fin p) (side : Bool) (k : Fin (samplerSize P r i side)) :
    samplerWeights P r a b (railIndex (samplerSize P r) ⟨i,side,k⟩) =
      if side then b i else a i := by
  unfold samplerWeights
  rw [Equiv.symm_apply_apply]

def samplerRawScore {p : ℕ} (P r : Fin p → ℕ) (a b : Fin p → ℝ)
    (bias : ℝ) (state : RailSamplerState P r) : ℝ :=
  bias + ∑ i, (a i * ∑ k : Fin (P i), selectedSign state.1 ⟨i,k⟩) +
    ∑ i, b i * (railBit (state.2.1 i) + freeRailSum r state.2.2.1 i + railBit (state.2.2.2 i))

def samplerSelectedParity {p : ℕ} (P : Fin p → ℕ)
    (S : Finset (SelectedCoord P)) (i : Fin p) : ℝ :=
  ∏ k : Fin (P i), selectedSign S ⟨i,k⟩

def samplerSupport {p : ℕ} (P r : Fin p → ℕ) (τ : Finset (Fin p)) :
    Finset (Fin (railDimension (samplerSize P r))) :=
  Finset.univ.biUnion (fun i => physicalRail (samplerSize P r) i (decide (i ∈ τ)))

theorem sampler_opposite_sum {p : ℕ} (P r : Fin p → ℕ)
    (state : RailSamplerState P r) (i : Fin p) :
    (∑ k : Fin (r i + 2), cubeCoordinateSign ((railSamplerEquiv P r).symm state
      (railIndex (samplerSize P r) ⟨i,true,k⟩))) =
      railBit (state.2.1 i) + freeRailSum r state.2.2.1 i + railBit (state.2.2.2 i) := by
  simp_rw [sampler_inverse_opposite]
  rw [endBits_sum]
  rw [Equiv.apply_symm_apply]
  rfl

theorem sampler_opposite_prod {p : ℕ} (P r : Fin p → ℕ)
    (state : RailSamplerState P r) (i : Fin p) :
    (∏ k : Fin (r i + 2), cubeCoordinateSign ((railSamplerEquiv P r).symm state
      (railIndex (samplerSize P r) ⟨i,true,k⟩))) =
      oppositeRailParity r state.2.1 state.2.2.1 state.2.2.2 i := by
  simp_rw [sampler_inverse_opposite]
  rw [endBits_prod]
  rw [Equiv.apply_symm_apply]
  rfl

theorem sampler_selected_sign {p : ℕ} (P r : Fin p → ℕ)
    (state : RailSamplerState P r) (i : Fin p) (k : Fin (P i)) :
    cubeCoordinateSign ((railSamplerEquiv P r).symm state
      (railIndex (samplerSize P r) ⟨i,false,k⟩)) = selectedSign state.1 ⟨i,k⟩ := by
  rw [sampler_inverse_selected]
  simp [cubeCoordinateSign, selectedSign]

theorem sampler_affine_score {p : ℕ} (P r : Fin p → ℕ) (a b : Fin p → ℝ)
    (bias : ℝ) (state : RailSamplerState P r) :
    cubeAffine bias (samplerWeights P r a b) ((railSamplerEquiv P r).symm state) =
      samplerRawScore P r a b bias state := by
  unfold cubeAffine
  rw [← Equiv.sum_comp (railIndex (samplerSize P r))
    (fun j => samplerWeights P r a b j *
      cubeCoordinateSign ((railSamplerEquiv P r).symm state j))]
  rw [Fintype.sum_sigma]
  simp_rw [Fintype.sum_sigma, Fintype.sum_bool]
  simp_rw [samplerWeights_apply]
  simp only [Bool.false_eq_true, ↓reduceIte]
  simp_rw [← Finset.mul_sum]
  change bias + Finset.univ.sum (fun i : Fin p =>
    b i * Finset.univ.sum (fun k : Fin (r i + 2) =>
      cubeCoordinateSign ((railSamplerEquiv P r).symm state (railIndex (samplerSize P r) ⟨i,true,k⟩))) +
    a i * Finset.univ.sum (fun k : Fin (P i) =>
      cubeCoordinateSign ((railSamplerEquiv P r).symm state (railIndex (samplerSize P r) ⟨i,false,k⟩)))) = _
  simp_rw [sampler_opposite_sum P r state, sampler_selected_sign P r state]
  unfold samplerRawScore
  rw [Finset.sum_add_distrib]
  ring

theorem sampler_support_character {p : ℕ} (P r : Fin p → ℕ)
    (τ : Finset (Fin p)) (state : RailSamplerState P r) :
    walshCharacter (samplerSupport P r τ) ((railSamplerEquiv P r).symm state) =
      transversalCharacter τ (samplerSelectedParity P state.1)
        (oppositeRailParity r state.2.1 state.2.2.1 state.2.2.2) := by
  classical
  unfold walshCharacter samplerSupport
  rw [Finset.prod_biUnion]
  · have hi (i : Fin p) :
        (∏ j ∈ physicalRail (samplerSize P r) i (decide (i ∈ τ)),
          cubeCoordinateSign ((railSamplerEquiv P r).symm state j)) =
        if i ∈ τ then oppositeRailParity r state.2.1 state.2.2.1 state.2.2.2 i
        else samplerSelectedParity P state.1 i := by
      rw [physicalRail_eq_map, Finset.prod_map]
      by_cases h : i ∈ τ
      · have hd : decide (i ∈ τ) = true := decide_eq_true h
        rw [hd, if_pos h]
        exact sampler_opposite_prod P r state i
      · have hd : decide (i ∈ τ) = false := decide_eq_false h
        rw [hd, if_neg h]
        change (∏ k : Fin (P i), cubeCoordinateSign ((railSamplerEquiv P r).symm state
          (railIndex (samplerSize P r) ⟨i,false,k⟩))) = _
        simp_rw [sampler_selected_sign]
        rfl
    simp_rw [hi]
    unfold transversalCharacter
    rw [Finset.prod_ite]
    have hyes : (Finset.univ : Finset (Fin p)).filter (fun i => i ∈ τ) = τ := by
      ext i; simp
    have hno : (Finset.univ : Finset (Fin p)).filter (fun i => i ∉ τ) = Finset.univ \ τ := by
      ext i; simp
    rw [hyes, hno]
  · intro i _ j _ hij
    exact physicalRail_disjoint _ (Or.inl hij)

def samplerTransversalCoefficient {p : ℕ} (P r : Fin p → ℕ) (a b : Fin p → ℝ)
    (bias : ℝ) (τ : Finset (Fin p)) : ℝ :=
  physicalRailExpectation (Finset.univ : Finset (SelectedCoord P)) r
    (fun S y z last => transversalCharacter τ (samplerSelectedParity P S)
      (oppositeRailParity r y z last) * max (samplerRawScore P r a b bias (S,y,z,last)) 0)

/-- The nested finite physical coefficient is exactly the repository's
existing normalized Walsh coefficient of the actual affine ReLU neuron. -/
theorem samplerTransversalCoefficient_eq_walsh {p : ℕ}
    (P r : Fin p → ℕ) (a b : Fin p → ℝ) (bias : ℝ) (τ : Finset (Fin p)) :
    samplerTransversalCoefficient P r a b bias τ =
      walshCoefficients (fun x => max (cubeAffine bias (samplerWeights P r a b) x) 0)
        (samplerSupport P r τ) := by
  let f : RailSamplerState P r → ℝ := fun state =>
    transversalCharacter τ (samplerSelectedParity P state.1)
      (oppositeRailParity r state.2.1 state.2.2.1 state.2.2.2) *
        max (samplerRawScore P r a b bias state) 0
  have hpoint (x : ClippingCube (railDimension (samplerSize P r))) :
      max (cubeAffine bias (samplerWeights P r a b) x) 0 * walshCharacter (samplerSupport P r τ) x =
        f (railSamplerEquiv P r x) := by
    rw [← (railSamplerEquiv P r).symm_apply_apply x]
    rw [sampler_affine_score, sampler_support_character]
    dsimp [f]
    rw [Equiv.apply_symm_apply]
    ring
  unfold walshCoefficients uniformCubeMean
  simp_rw [hpoint]
  simp only [ClippingCube, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin,
    Nat.cast_pow, Nat.cast_ofNat]
  exact (actual_uniform_sampler P r f).symm

end NeuralGeneralization.OnlineLowerRelu
