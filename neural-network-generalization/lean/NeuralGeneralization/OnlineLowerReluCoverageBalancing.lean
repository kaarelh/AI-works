import NeuralGeneralization.OnlineLowerReluAtomClosure
import NeuralGeneralization.OnlineLowerReluLipschitz
import NeuralGeneralization.OnlineLowerGeometryWalsh

/-! # Equality of the two actual block-balancing supremums

Both supremums are over actual affine ReLU Fourier coefficient ratios.
The zero incoming vector contributes the continuously harmless value zero.
-/
set_option maxHeartbeats 800000
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu
open OnlineLowerGeometry

variable {κ : Type*} [Fintype κ] [DecidableEq κ] {β : κ → Type*}
variable [∀ j,Fintype (β j)] [∀ j,Nonempty (β j)]

lemma blockCodeMass_nonneg {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v,0 ≤ weight v) (b : ℝ) (u : (j : κ) → β j → ℝ) :
    0 ≤ blockCodeMass e orientation weight b u :=
  Finset.sum_nonneg (fun _ _ => mul_nonneg (hw _) (abs_nonneg _))

lemma affine_relu_coefficient_le_norm {d : ℕ} (b : ℝ) (u : Fin d → ℝ) (S : Finset (Fin d)) :
    |walshCoefficients (fun x => max (cubeAffine b u x) 0) S| ≤
      Real.sqrt (b^2 + ∑ i,u i^2) := by
  have h := relu_walsh_difference_sq_le b 0 u (fun _ => 0) S
  simp only [cubeAffine,zero_mul,Finset.sum_const_zero,add_zero,max_self,
    walshCoefficients_const,ite_self,sub_zero] at h
  apply Real.le_sqrt_of_sq_le
  simpa only [sq_abs,cubeAffine] using h

lemma blockCodeMass_le_totalWeight_norm {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v,0 ≤ weight v) (b : ℝ) (u : (j : κ) → β j → ℝ) :
    blockCodeMass e orientation weight b u ≤
      (∑ v,weight v) * Real.sqrt (b^2+blockEnergy u) := by
  unfold blockCodeMass
  rw [Finset.sum_mul]
  apply Finset.sum_le_sum
  intro v _
  have h := affine_relu_coefficient_le_norm b (blockWeights e u) (blockSupport e (orientation v))
  rw [blockWeights_energy] at h
  exact mul_le_mul_of_nonneg_left h (hw v)

/-- Extend a uniform bound over nonnegative block-constant atoms to every
signed affine atom, by the proved square-mean sampling inequality. -/
theorem block_balancing_uniform_bound {d : ℕ} {ν : Type*} [Fintype ν]
    [MeasurableSpace ν] [MeasurableSingletonClass ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v,0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v,(blockSupport e (orientation v)).card = 2*r v)
    (hsize : ∀ v,2 ≤ (blockSupport e (orientation v)).card)
    (heven : ∀ j,Even (Fintype.card (β j))) (M : ℝ) (hM : 0 ≤ M)
    (hbalanced : ∀ a : κ → ℝ,(∀ j,0 ≤ a j) →
      blockCodeMass e orientation weight 0 (fun j (_ : β j) => a j) ≤
        M * Real.sqrt (blockEnergy (fun j (_ : β j) => a j)))
    (bias : ℝ) (u : (j : κ) → β j → ℝ) :
    blockCodeMass e orientation weight bias u ≤ M * Real.sqrt (bias^2+blockEnergy u) := by
  let v : (j : κ) → β j → ℝ := fun j k => |u j k|
  have hsq := blockCodePotential_square_le_sample_mean e orientation weight hw r hcard hsize v
  simp_rw [blockCodePotential_sample_eq_mass e orientation weight r hcard hsize heven] at hsq
  change blockCodePotential e orientation weight v ^ 2 ≤
    uniformBlockAverage (fun pick => blockCodeMass e orientation weight 0 (sampledBlockWeights v pick)^2) at hsq
  have hsample (pick : (j : κ) → β j) :
      blockCodeMass e orientation weight 0 (sampledBlockWeights v pick)^2 ≤
        M^2 * blockEnergy (sampledBlockWeights v pick) := by
    have h := hbalanced (fun j => v j (pick j)) (fun j => abs_nonneg _)
    change blockCodeMass e orientation weight 0 (sampledBlockWeights v pick) ≤
      M * Real.sqrt (blockEnergy (sampledBlockWeights v pick)) at h
    have hh := mul_self_le_mul_self (blockCodeMass_nonneg e orientation weight hw 0 _) h
    simpa only [← pow_two,mul_pow,Real.sq_sqrt (blockEnergy_nonneg _)] using hh
  have hmean := uniformBlockAverage_mono _ _ hsample
  rw [uniformBlockAverage_const_mul,blockEnergy_sample_average] at hmean
  have hev : blockEnergy v = blockEnergy u := by simp [v,blockEnergy,sq_abs]
  rw [hev] at hmean
  dsimp only [v] at hsq
  rw [blockCodePotential_abs_weights] at hsq
  have hG : blockCodePotential e orientation weight u ≤ M * Real.sqrt (blockEnergy u) := by
    have h := hsq.trans hmean
    have hs := Real.sq_sqrt (blockEnergy_nonneg u)
    have hpos := mul_nonneg hM (Real.sqrt_nonneg (blockEnergy u))
    nlinarith [blockCodePotential_nonneg e orientation weight hw u]
  exact (blockCodeMass_le_potential e orientation weight hw r hcard hsize bias u).trans
    (hG.trans (mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt (le_add_of_nonneg_left (sq_nonneg bias))) hM))

/-- All affine coefficient-to-Euclidean-norm ratios. -/
def blockAffineRatios {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool) (weight : ν → ℝ) : Set ℝ :=
  {q | ∃ (b : ℝ) (u : (j : κ) → β j → ℝ),
    q = blockCodeMass e orientation weight b u / Real.sqrt (b^2+blockEnergy u)}

/-- The same ratios, restricted to zero bias and nonnegative constant blocks. -/
def blockBalancedRatios {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool) (weight : ν → ℝ) : Set ℝ :=
  {q | ∃ a : κ → ℝ,(∀ j,0 ≤ a j) ∧
    q = blockCodeMass e orientation weight 0 (fun j (_ : β j) => a j) /
      Real.sqrt (blockEnergy (fun j (_ : β j) => a j))}

lemma blockBalancedRatios_zero {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool) (weight : ν → ℝ) :
    0 ∈ blockBalancedRatios e orientation weight := by
  refine ⟨(fun _ => 0),(fun _ => le_rfl),?_⟩
  simp [blockEnergy]

lemma blockBalancedRatios_subset {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool) (weight : ν → ℝ) :
    blockBalancedRatios e orientation weight ⊆ blockAffineRatios e orientation weight := by
  rintro q ⟨a,ha,rfl⟩
  refine ⟨0,(fun j (_ : β j) => a j),?_⟩
  simp

lemma blockAffineRatios_bddAbove {d : ℕ} {ν : Type*} [Fintype ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v,0 ≤ weight v) :
    BddAbove (blockAffineRatios e orientation weight) := by
  refine ⟨∑ v,weight v,?_⟩
  rintro q ⟨b,u,rfl⟩
  by_cases hρ : Real.sqrt (b^2+blockEnergy u) = 0
  · rw [hρ,div_zero]
    exact Finset.sum_nonneg (fun v _ => hw v)
  · apply (div_le_iff₀ (lt_of_le_of_ne (Real.sqrt_nonneg _) (Ne.symm hρ))).mpr
    exact blockCodeMass_le_totalWeight_norm e orientation weight hw b u

/-- The literal supremum in the manuscript's block-balancing lemma is
unchanged by restricting to nonnegative block-constant, zero-bias neurons. -/
theorem block_balancing_supremum_eq {d : ℕ} {ν : Type*} [Fintype ν]
    [MeasurableSpace ν] [MeasurableSingletonClass ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v,0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v,(blockSupport e (orientation v)).card = 2*r v)
    (hsize : ∀ v,2 ≤ (blockSupport e (orientation v)).card)
    (heven : ∀ j,Even (Fintype.card (β j))) :
    sSup (blockAffineRatios e orientation weight) = sSup (blockBalancedRatios e orientation weight) := by
  have hbA := blockAffineRatios_bddAbove e orientation weight hw
  have hsub := blockBalancedRatios_subset e orientation weight
  have hbB := hbA.mono hsub
  have hz := blockBalancedRatios_zero e orientation weight
  have hM : 0 ≤ sSup (blockBalancedRatios e orientation weight) := le_csSup hbB hz
  apply le_antisymm
  · apply csSup_le ⟨0,hsub hz⟩
    rintro q ⟨b,u,rfl⟩
    by_cases hρ : Real.sqrt (b^2+blockEnergy u) = 0
    · simpa only [hρ,div_zero] using hM
    · apply (div_le_iff₀ (lt_of_le_of_ne (Real.sqrt_nonneg _) (Ne.symm hρ))).mpr
      apply block_balancing_uniform_bound e orientation weight hw r hcard hsize heven _ hM
      intro a ha
      have h := le_csSup hbB (show blockCodeMass e orientation weight 0 (fun j (_ : β j) => a j) /
        Real.sqrt (blockEnergy (fun j (_ : β j) => a j)) ∈ blockBalancedRatios e orientation weight from ⟨a,ha,rfl⟩)
      by_cases hE : Real.sqrt (blockEnergy (fun j (_ : β j) => a j)) = 0
      · have hzero := blockCodeMass_le_totalWeight_norm e orientation weight hw 0 (fun j (_ : β j) => a j)
        simp only [zero_pow (by decide : 2 ≠ 0),zero_add,hE,mul_zero] at hzero ⊢
        exact hzero
      · exact (div_le_iff₀ (lt_of_le_of_ne (Real.sqrt_nonneg _) (Ne.symm hE))).mp h
  · exact csSup_le_csSup hbA ⟨0,hz⟩ hsub

end NeuralGeneralization.OnlineLowerRelu
