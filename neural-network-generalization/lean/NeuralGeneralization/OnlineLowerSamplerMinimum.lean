import NeuralGeneralization.OnlineLowerSamplerWalsh
import NeuralGeneralization.OnlineLowerSelectedRails

/-! # The randomized-minimum inequality for actual affine ReLU Walsh coefficients -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

theorem samplerRawScore_eq_unconditioned {p : ℕ} (P r : Fin p → ℕ)
    (hP : ∀ i, 0 < P i) (a b : Fin p → ℝ) (bias : ℝ) (state : RailSamplerState P r) :
    samplerRawScore P r a b bias state =
      unconditionedRailScore (nativeBlocks P hP) (nativeDistinguished P hP)
        r a b state.2.1 state.2.2.1 state.2.2.2 bias state.1 := by
  unfold samplerRawScore unconditionedRailScore
  simp_rw [nativeBlocks_sum]
  rw [Finset.sum_add_distrib]
  ring

theorem samplerSelectedParity_eq_native {p : ℕ} (P : Fin p → ℕ)
    (hP : ∀ i, 0 < P i) (S : Finset (SelectedCoord P)) (i : Fin p) :
    samplerSelectedParity P S i = selectedRailParity (nativeBlocks P hP)
      (nativeDistinguished P hP) S i := by
  unfold samplerSelectedParity selectedRailParity
  exact (nativeBlocks_prod P hP i (selectedSign S)).symm

theorem samplerTransversalCoefficient_eq_physical {p : ℕ}
    (P r : Fin p → ℕ) (hP : ∀ i, 0 < P i) (a b : Fin p → ℝ)
    (bias : ℝ) (τ : Finset (Fin p)) :
    samplerTransversalCoefficient P r a b bias τ =
      physicalTransversalCoefficient Finset.univ (nativeBlocks P hP)
        (nativeDistinguished P hP) r τ
        (fun S y z last => max (unconditionedRailScore (nativeBlocks P hP)
          (nativeDistinguished P hP) r a b y z last bias S) 0) := by
  unfold samplerTransversalCoefficient physicalTransversalCoefficient
  have hparity (S : Finset (SelectedCoord P)) : samplerSelectedParity P S =
      selectedRailParity (nativeBlocks P hP) (nativeDistinguished P hP) S := by
    funext i
    exact samplerSelectedParity_eq_native P hP S i
  simp_rw [samplerRawScore_eq_unconditioned P r hP, hparity]

theorem nativeDistinguished_injective {p : ℕ} (P : Fin p → ℕ) (hP : ∀ i, 0 < P i) :
    Function.Injective (nativeDistinguished P hP) := by
  intro i j h
  exact congrArg Sigma.fst h

theorem nativeDistinguished_disjoint_all_blocks {p : ℕ} (P : Fin p → ℕ)
    (hP : ∀ i, 0 < P i) (i j : Fin p) :
    nativeDistinguished P hP i ∉ nativeBlocks P hP j := by
  intro h
  have he : i = j := by
    have hh := (mem_nativeSelectedRail P j (nativeDistinguished P hP i)).mp
      (Finset.mem_erase.mp h).2
    exact hh
  subst j
  exact nativeDistinguished_not_mem_blocks P hP i h

theorem samplerSupport_card {p : ℕ} (P r : Fin p → ℕ) (τ : Finset (Fin p)) :
    (samplerSupport P r τ).card = ∑ i, if i ∈ τ then r i + 2 else P i := by
  unfold samplerSupport
  rw [Finset.card_biUnion]
  · apply Finset.sum_congr rfl
    intro i _
    rw [physicalRail_card]
    by_cases h : i ∈ τ <;> simp [h, samplerSize]
  · intro i _ j _ hij
    exact physicalRail_disjoint _ (Or.inl hij)

theorem samplerSupport_even {p : ℕ} (P r : Fin p → ℕ) (τ : Finset (Fin p))
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i)) : Even (samplerSupport P r τ).card := by
  rw [samplerSupport_card]
  apply Finset.even_sum
  intro i _
  split_ifs
  · exact (hr i).add (by decide : Even 2)
  · exact hP i

theorem samplerSupport_two_le {p : ℕ} (hp : 0 < p) (P r : Fin p → ℕ)
    (τ : Finset (Fin p)) (hP : ∀ i, 2 ≤ P i) : 2 ≤ (samplerSupport P r τ).card := by
  rw [samplerSupport_card]
  let i : Fin p := ⟨0,hp⟩
  have hsum := Finset.single_le_sum
    (f := fun i : Fin p => if i ∈ τ then r i + 2 else P i)
    (fun _ _ => Nat.zero_le _) (Finset.mem_univ i)
  have htwo : 2 ≤ if i ∈ τ then r i + 2 else P i := by
    have := hP i
    split_ifs <;> omega
  exact htwo.trans hsum

/-- All quantities in this inequality use the existing physical cube,
the actual block-constant weight vector, and the existing Walsh transform. -/
theorem actual_relu_randomized_minimum {p : ℕ} (hp : 0 < p)
    (P r : Fin p → ℕ) (hP : ∀ i, 0 < P i) (n : ℕ)
    (hD : (∑ i, P i) = n + 2) (hDeven : Even (∑ i, P i))
    (a b : Fin p → ℝ) (η : Fin p → Bool) (bias : ℝ)
    (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i) :
    |∑ τ : Finset (Fin p), (∏ i ∈ τ, railBit (η i)) *
      walshCoefficients (fun x => max (cubeAffine bias (samplerWeights P r a b) x) 0)
        (samplerSupport P r τ)| ≤
      (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) *
        @finiteAverage (Fin p → Bool) inferInstance
          (@minimumRailAmplitude (Fin p) inferInstance ⟨⟨0,hp⟩⟩ a b) := by
  letI : Nonempty (Fin p) := ⟨⟨0,hp⟩⟩
  have hcard : (Finset.univ : Finset (SelectedCoord P)).card = n + 2 := by
    simpa [SelectedCoord, Fintype.card_sigma] using hD
  have heven : Even (Finset.univ : Finset (SelectedCoord P)).card := by
    simpa [SelectedCoord, Fintype.card_sigma] using hDeven
  have hpair : ∀ i j, i ≠ j → Disjoint
      (insert (nativeDistinguished P hP i) (nativeBlocks P hP i))
      (insert (nativeDistinguished P hP j) (nativeBlocks P hP j)) := by
    intro i j hij
    simp_rw [nativeBlocks_insert]
    exact nativeSelectedRail_disjoint P hij
  have hcover : Finset.univ.biUnion (fun i =>
      insert (nativeDistinguished P hP i) (nativeBlocks P hP i)) = Finset.univ := by
    simp_rw [nativeBlocks_insert]
    exact nativeSelectedRail_cover P
  have h := signed_transversal_randomized_minimum Finset.univ n hcard
    (nativeBlocks P hP) (nativeDistinguished P hP) (nativeDistinguished_injective P hP)
    (nativeDistinguished_disjoint_all_blocks P hP) (fun i => Finset.mem_univ _)
    hpair hcover heven r a b η bias hb hab
  simp_rw [← samplerTransversalCoefficient_eq_physical P r hP a b bias,
    samplerTransversalCoefficient_eq_walsh] at h
  exact h

end NeuralGeneralization.OnlineLowerRelu
