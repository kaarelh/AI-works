import NeuralGeneralization.OnlineLowerReluCoverageBalancing

/-! # Block balancing with arbitrary irrelevant input coordinates

Only blocks selected by at least one Fourier support need even size.
All remaining coordinates can form arbitrary nonempty blocks and are set
to zero in the restricted supremum.
-/
set_option maxHeartbeats 800000
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerRelu

variable {κ : Type*} [Fintype κ] [DecidableEq κ] {β : κ → Type*}
variable [∀ j,Fintype (β j)] [∀ j,Nonempty (β j)]

/-- A block is relevant exactly when some retained coefficient selects it. -/
def activeBlock {ν : Type*} (orientation : ν → κ → Bool) (j : κ) : Prop :=
  ∃ v,orientation v j = true

def activeBlockWeights {ν : Type*} (orientation : ν → κ → Bool)
    (u : (j : κ) → β j → ℝ) : (j : κ) → β j → ℝ :=
  fun j k => if activeBlock orientation j then |u j k| else 0

def activePhysicalSupport {d : ℕ} {ν : Type*}
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool) : Finset (Fin d) :=
  Finset.univ.filter (fun i => activeBlock orientation (e.symm i).1)

lemma activeBlockWeights_energy_le {ν : Type*} (orientation : ν → κ → Bool)
    (u : (j : κ) → β j → ℝ) : blockEnergy (activeBlockWeights orientation u) ≤ blockEnergy u := by
  apply Finset.sum_le_sum
  intro j _
  apply Finset.sum_le_sum
  intro k _
  dsimp [activeBlockWeights]
  split_ifs <;> simp [sq_abs,sq_nonneg]

lemma mass_le_active_potential {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v,0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v,(blockSupport e (orientation v)).card = 2*r v)
    (hsize : ∀ v,2 ≤ (blockSupport e (orientation v)).card)
    (bias : ℝ) (u : (j : κ) → β j → ℝ) :
    blockCodeMass e orientation weight bias u ≤
      blockCodePotential e orientation weight (activeBlockWeights orientation u) := by
  apply (blockCodeMass_le_potential e orientation weight hw r hcard hsize bias u).trans
  rw [← blockCodePotential_abs_weights e orientation weight u]
  apply Finset.sum_le_sum
  intro v _
  apply mul_le_mul_of_nonneg_left _ (hw v)
  have hsub : blockSupport e (orientation v) ⊆ activePhysicalSupport e orientation := by
    intro i hi
    simp only [blockSupport,Finset.mem_filter,Finset.mem_univ,true_and] at hi
    simp only [activePhysicalSupport,Finset.mem_filter,Finset.mem_univ,true_and]
    exact ⟨v,hi⟩
  have hne : blockSupport e (orientation v) ≠ ∅ := by
    intro h
    have := hsize v
    simp [h] at this
  have hdisjoint : Disjoint (blockSupport e (orientation v))
      (Finset.univ \ activePhysicalSupport e orientation) := by
    apply Finset.disjoint_left.mpr
    intro i hi hiout
    exact (Finset.mem_sdiff.mp hiout).2 (hsub hi)
  have h := supportPotential_zero_unused (blockSupport e (orientation v))
    (Finset.univ \ activePhysicalSupport e orientation) hne (hcard v) hdisjoint
    (blockWeights e (fun j k => |u j k|))
  have heq : zeroIncoming (Finset.univ \ activePhysicalSupport e orientation)
      (blockWeights e (fun j k => |u j k|)) = blockWeights e (activeBlockWeights orientation u) := by
    funext i
    simp [zeroIncoming,activePhysicalSupport,blockWeights,activeBlockWeights]
  rw [heq] at h
  exact h

lemma active_sample_potential_eq_mass {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (r : ν → ℕ)
    (hcard : ∀ v,(blockSupport e (orientation v)).card = 2*r v)
    (hsize : ∀ v,2 ≤ (blockSupport e (orientation v)).card)
    (heven : ∀ j,activeBlock orientation j → Even (Fintype.card (β j)))
    (u : (j : κ) → β j → ℝ) (pick : (j : κ) → β j) :
    blockCodePotential e orientation weight (sampledBlockWeights (activeBlockWeights orientation u) pick) =
      blockCodeMass e orientation weight 0 (sampledBlockWeights (activeBlockWeights orientation u) pick) := by
  apply Finset.sum_congr rfl
  intro v _
  rw [relu_walsh_abs_eq_potential_of_nonneg _ (hsize v) (hcard v) _]
  intro t
  unfold trigKernel
  rw [trigProduct_blocks]
  simp only [sampledBlockWeights,Finset.prod_const,Finset.card_univ]
  apply div_nonneg _ (sq_nonneg t)
  apply Finset.prod_nonneg
  intro j _
  by_cases hj : activeBlock orientation j
  · exact (heven j hj).pow_nonneg _
  · have ho : orientation v j = false := by
      apply Bool.eq_false_iff.mpr
      intro hv
      exact hj ⟨v,hv⟩
    simp [activeBlockWeights,hj,ho]

/-- Generalized balancing bound, allowing arbitrary-size unused blocks. -/
theorem block_balancing_uniform_bound_with_unused {d : ℕ} {ν : Type*} [Fintype ν]
    [MeasurableSpace ν] [MeasurableSingletonClass ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v,0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v,(blockSupport e (orientation v)).card = 2*r v)
    (hsize : ∀ v,2 ≤ (blockSupport e (orientation v)).card)
    (heven : ∀ j,activeBlock orientation j → Even (Fintype.card (β j)))
    (M : ℝ) (hM : 0 ≤ M)
    (hbalanced : ∀ a : κ → ℝ,(∀ j,0 ≤ a j) → (∀ j,¬activeBlock orientation j → a j = 0) →
      blockCodeMass e orientation weight 0 (fun j (_ : β j) => a j) ≤
        M * Real.sqrt (blockEnergy (fun j (_ : β j) => a j)))
    (bias : ℝ) (u : (j : κ) → β j → ℝ) :
    blockCodeMass e orientation weight bias u ≤ M * Real.sqrt (bias^2+blockEnergy u) := by
  let v := activeBlockWeights orientation u
  have hsq := blockCodePotential_square_le_sample_mean e orientation weight hw r hcard hsize v
  simp_rw [show v=activeBlockWeights orientation u from rfl,
    active_sample_potential_eq_mass e orientation weight r hcard hsize heven] at hsq
  change blockCodePotential e orientation weight v ^ 2 ≤
    uniformBlockAverage (fun pick => blockCodeMass e orientation weight 0 (sampledBlockWeights v pick)^2) at hsq
  have hsample (pick : (j : κ) → β j) :
      blockCodeMass e orientation weight 0 (sampledBlockWeights v pick)^2 ≤
        M^2 * blockEnergy (sampledBlockWeights v pick) := by
    have h := hbalanced (fun j => v j (pick j))
      (fun j => by dsimp [v,activeBlockWeights]; split_ifs <;> positivity)
      (fun j hj => by simp [v,activeBlockWeights,hj])
    change blockCodeMass e orientation weight 0 (sampledBlockWeights v pick) ≤
      M * Real.sqrt (blockEnergy (sampledBlockWeights v pick)) at h
    have hh := mul_self_le_mul_self (blockCodeMass_nonneg e orientation weight hw 0 _) h
    simpa only [← pow_two,mul_pow,Real.sq_sqrt (blockEnergy_nonneg _)] using hh
  have hmean := uniformBlockAverage_mono _ _ hsample
  rw [uniformBlockAverage_const_mul,blockEnergy_sample_average] at hmean
  have hG : blockCodePotential e orientation weight v ≤ M * Real.sqrt (blockEnergy v) := by
    have h := hsq.trans hmean
    have hs := Real.sq_sqrt (blockEnergy_nonneg v)
    have hpos := mul_nonneg hM (Real.sqrt_nonneg (blockEnergy v))
    nlinarith [blockCodePotential_nonneg e orientation weight hw v]
  have he : blockEnergy v ≤ bias^2+blockEnergy u :=
    (activeBlockWeights_energy_le orientation u).trans (le_add_of_nonneg_left (sq_nonneg bias))
  exact (mass_le_active_potential e orientation weight hw r hcard hsize bias u).trans
    (hG.trans (mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt he) hM))

/-- Restricted ratios also set every irrelevant input coordinate to zero. -/
def blockActiveBalancedRatios {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool) (weight : ν → ℝ) : Set ℝ :=
  {q | ∃ a : κ → ℝ,(∀ j,0 ≤ a j) ∧ (∀ j,¬activeBlock orientation j → a j = 0) ∧
    q = blockCodeMass e orientation weight 0 (fun j (_ : β j) => a j) /
      Real.sqrt (blockEnergy (fun j (_ : β j) => a j))}

/-- Literal block-balancing supremum equality even with arbitrary irrelevant
coordinates: evenness is imposed only on blocks used by a Fourier support. -/
theorem block_balancing_supremum_eq_with_unused {d : ℕ} {ν : Type*} [Fintype ν]
    [MeasurableSpace ν] [MeasurableSingletonClass ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v,0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v,(blockSupport e (orientation v)).card = 2*r v)
    (hsize : ∀ v,2 ≤ (blockSupport e (orientation v)).card)
    (heven : ∀ j,activeBlock orientation j → Even (Fintype.card (β j))) :
    sSup (blockAffineRatios e orientation weight) = sSup (blockActiveBalancedRatios e orientation weight) := by
  have hbA := blockAffineRatios_bddAbove e orientation weight hw
  have hsub : blockActiveBalancedRatios e orientation weight ⊆ blockAffineRatios e orientation weight := by
    rintro q ⟨a,ha,_,heq⟩
    exact blockBalancedRatios_subset e orientation weight ⟨a,ha,heq⟩
  have hbB := hbA.mono hsub
  have hz : 0 ∈ blockActiveBalancedRatios e orientation weight := by
    refine ⟨(fun _ => 0),(fun _ => le_rfl),(fun _ _ => rfl),?_⟩
    simp [blockEnergy]
  have hM : 0 ≤ sSup (blockActiveBalancedRatios e orientation weight) := le_csSup hbB hz
  apply le_antisymm
  · apply csSup_le ⟨0,hsub hz⟩
    rintro q ⟨b,u,rfl⟩
    by_cases hρ : Real.sqrt (b^2+blockEnergy u) = 0
    · simpa only [hρ,div_zero] using hM
    · apply (div_le_iff₀ (lt_of_le_of_ne (Real.sqrt_nonneg _) (Ne.symm hρ))).mpr
      apply block_balancing_uniform_bound_with_unused e orientation weight hw r hcard hsize heven _ hM
      intro a ha hzero
      have h := le_csSup hbB (show blockCodeMass e orientation weight 0 (fun j (_ : β j) => a j) /
        Real.sqrt (blockEnergy (fun j (_ : β j) => a j)) ∈ blockActiveBalancedRatios e orientation weight from
          ⟨a,ha,hzero,rfl⟩)
      by_cases hE : Real.sqrt (blockEnergy (fun j (_ : β j) => a j)) = 0
      · have hbound := blockCodeMass_le_totalWeight_norm e orientation weight hw 0 (fun j (_ : β j) => a j)
        simp only [zero_pow (by decide : 2 ≠ 0),zero_add,hE,mul_zero] at hbound ⊢
        exact hbound
      · exact (div_le_iff₀ (lt_of_le_of_ne (Real.sqrt_nonneg _) (Ne.symm hE))).mp h
  · exact csSup_le_csSup hbA ⟨0,hz⟩ hsub

end NeuralGeneralization.OnlineLowerRelu
