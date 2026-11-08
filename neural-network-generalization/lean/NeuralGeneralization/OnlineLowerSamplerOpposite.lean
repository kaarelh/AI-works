import NeuralGeneralization.OnlineLowerSamplerPhase
import NeuralGeneralization.OnlineLowerReluKappa

/-! # Opposite-rail marginal mass for actual even-rail ReLU atoms -/

noncomputable section
open scoped BigOperators symmDiff
namespace NeuralGeneralization.OnlineLowerRelu

theorem sampler_trigKernel_product {p : ℕ} (P r : Fin p → ℕ)
    (a b : Fin p → ℝ) (τ : Finset (Fin p)) (t : ℝ) :
    trigKernel (samplerSupport P r τ) (samplerWeights P r a b) t =
      (∏ i, if i ∈ τ then
        Real.cos (t * a i) ^ P i * Real.sin (t * b i) ^ (r i + 2)
      else Real.sin (t * a i) ^ P i * Real.cos (t * b i) ^ (r i + 2)) / t ^ 2 := by
  unfold trigKernel trigProduct
  congr 1
  rw [← Equiv.prod_comp (railIndex (samplerSize P r))
    (fun j => if j ∈ samplerSupport P r τ then Real.sin (t * samplerWeights P r a b j)
      else Real.cos (t * samplerWeights P r a b j))]
  rw [Fintype.prod_sigma]
  apply Finset.prod_congr rfl
  intro i _
  rw [Fintype.prod_sigma]
  simp_rw [mem_samplerSupport_index, samplerWeights_apply]
  by_cases hi : i ∈ τ <;>
    simp [hi, mul_comm] <;> dsimp [samplerSize] <;> ring

def swappedSelectedSizes {p : ℕ} (P r : Fin p → ℕ) (i : Fin p) (j : Fin p) : ℕ :=
  if j = i then r j + 2 else P j

def swappedFreeSizes {p : ℕ} (P r : Fin p → ℕ) (i : Fin p) (j : Fin p) : ℕ :=
  if j = i then P j - 2 else r j

def swappedSelectedAmplitudes {p : ℕ} (a b : Fin p → ℝ) (i : Fin p) (j : Fin p) : ℝ :=
  if j = i then b j else a j

def zeroAtRail {p : ℕ} (a : Fin p → ℝ) (i : Fin p) (j : Fin p) : ℝ :=
  if j = i then 0 else a j

def toggleRail {p : ℕ} (i : Fin p) : Finset (Fin p) ≃ Finset (Fin p) where
  toFun τ := τ ∆ {i}
  invFun τ := τ ∆ {i}
  left_inv τ := by ext j; simp
  right_inv τ := by ext j; simp

/-- Swapping one pair of physical rails preserves each positive potential,
with the transversal index toggled. The proof expands the literal physical
coordinate product, including every unused cosine factor. -/
theorem sampler_potential_swap {p : ℕ} (P r : Fin p → ℕ)
    (a b : Fin p → ℝ) (i : Fin p) (hPi : 2 ≤ P i) (τ : Finset (Fin p)) :
    supportFourierPotential (samplerSupport P r τ)
      (samplerWeights P r (zeroAtRail a i) b) =
    supportFourierPotential
      (samplerSupport (swappedSelectedSizes P r i) (swappedFreeSizes P r i) (toggleRail i τ))
      (samplerWeights (swappedSelectedSizes P r i) (swappedFreeSizes P r i)
        (swappedSelectedAmplitudes a b i) (zeroAtRail b i)) := by
  unfold supportFourierPotential
  congr 1
  congr 1
  funext t
  rw [sampler_trigKernel_product, sampler_trigKernel_product]
  congr 2
  apply Finset.prod_congr rfl
  intro j _
  by_cases hji : j = i
  · subst j
    have hsize : P i - 2 + 2 = P i := by omega
    by_cases hi : i ∈ τ <;>
      simp [swappedSelectedSizes, swappedFreeSizes, swappedSelectedAmplitudes,
        zeroAtRail, toggleRail, Finset.mem_symmDiff, hi, hsize, mul_comm]
  · by_cases hj : j ∈ τ <;>
      simp [swappedSelectedSizes, swappedFreeSizes, swappedSelectedAmplitudes,
        zeroAtRail, toggleRail, Finset.mem_symmDiff, hji, hj]

theorem sampler_zero_unused_weights {p : ℕ} (P r : Fin p → ℕ)
    (a b : Fin p → ℝ) (i : Fin p) :
    zeroIncoming (physicalRail (samplerSize P r) i false) (samplerWeights P r a b) =
      samplerWeights P r (zeroAtRail a i) b := by
  funext j
  obtain ⟨⟨k,side,v⟩,rfl⟩ := (railIndex (samplerSize P r)).surjective j
  simp only [zeroIncoming, mem_physicalRail, samplerWeights_apply]
  rw [Equiv.symm_apply_apply]
  cases side <;> by_cases hki : k = i <;> simp [hki, zeroAtRail]

theorem samplerSupport_disjoint_dominant {p : ℕ} (P r : Fin p → ℕ)
    (τ : Finset (Fin p)) (i : Fin p) (hi : i ∈ τ) :
    Disjoint (samplerSupport P r τ) (physicalRail (samplerSize P r) i false) := by
  apply Finset.disjoint_left.mpr
  intro j hj hji
  obtain ⟨⟨k,side,v⟩,rfl⟩ := (railIndex (samplerSize P r)).surjective j
  rw [mem_samplerSupport_index] at hj
  simp only [mem_physicalRail] at hji
  rw [Equiv.symm_apply_apply] at hji
  rcases hji with ⟨rfl,rfl⟩
  simpa [hi] using hj

/-- The opposite marginal is bounded by the total mass after removing the
unused dominant rail and swapping that pair. -/
theorem sampler_opposite_le_swapped_mass {p : ℕ} (hp : 0 < p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i))
    (a b : Fin p → ℝ) (i : Fin p) :
    (∑ τ : Finset (Fin p), if i ∈ τ then
      supportFourierPotential (samplerSupport P r τ) (samplerWeights P r a b) else 0) ≤
    ∑ τ : Finset (Fin p), supportFourierPotential
      (samplerSupport (swappedSelectedSizes P r i) (swappedFreeSizes P r i) τ)
      (samplerWeights (swappedSelectedSizes P r i) (swappedFreeSizes P r i)
        (swappedSelectedAmplitudes a b i) (zeroAtRail b i)) := by
  rw [← Equiv.sum_comp (toggleRail i)
    (fun τ => supportFourierPotential
      (samplerSupport (swappedSelectedSizes P r i) (swappedFreeSizes P r i) τ)
      (samplerWeights (swappedSelectedSizes P r i) (swappedFreeSizes P r i)
        (swappedSelectedAmplitudes a b i) (zeroAtRail b i)))]
  apply Finset.sum_le_sum
  intro τ _
  by_cases hi : i ∈ τ
  · rw [if_pos hi, ← sampler_potential_swap P r a b i (hPtwo i) τ]
    have hne : samplerSupport P r τ ≠ ∅ := by
      have hc := samplerSupport_two_le hp P r τ hPtwo
      intro h; simp [h] at hc
    have h := supportPotential_zero_unused (samplerSupport P r τ)
      (physicalRail (samplerSize P r) i false) hne
      (samplerSupport_card_half P r hP hr τ)
      (samplerSupport_disjoint_dominant P r τ i hi) (samplerWeights P r a b)
    rwa [sampler_zero_unused_weights] at h
  · rw [if_neg hi]
    exact supportFourierPotential_nonneg _ _

/-- A longer opposite rail has marginal mass at most the selected-degree
normalization times its own amplitude. No marginal inequality is assumed. -/
theorem sampler_opposite_mass_bound {p : ℕ} (hp : 0 < p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i))
    (n : ℕ) (hD : (∑ i, P i) = 2 * n + 2)
    (a b : Fin p → ℝ) (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i)
    (i : Fin p) (hlong : P i ≤ r i + 2) :
    (∑ τ : Finset (Fin p), if i ∈ τ then
      supportFourierPotential (samplerSupport P r τ) (samplerWeights P r a b) else 0) ≤
      evenReluKappa n * b i := by
  letI : Nonempty (Fin p) := ⟨⟨0,hp⟩⟩
  let P' := swappedSelectedSizes P r i
  let r' := swappedFreeSizes P r i
  let a' := swappedSelectedAmplitudes a b i
  let b' := zeroAtRail b i
  have hP'two (j : Fin p) : 2 ≤ P' j := by
    dsimp [P', swappedSelectedSizes]
    split_ifs <;> [omega; exact hPtwo j]
  have hP'even (j : Fin p) : Even (P' j) := by
    dsimp [P', swappedSelectedSizes]
    split_ifs
    · exact (hr j).add (by decide : Even 2)
    · exact hP j
  have hr'even (j : Fin p) : Even (r' j) := by
    dsimp [r', swappedFreeSizes]
    split_ifs
    · obtain ⟨v,hv⟩ := hP j
      refine ⟨v-1, ?_⟩
      have := hPtwo j
      omega
    · exact hr j
  have hb' (j : Fin p) : 0 ≤ b' j := by
    dsimp [b', zeroAtRail]; split_ifs <;> [rfl; exact hb j]
  have hab' (j : Fin p) : b' j ≤ a' j := by
    dsimp [b', a', zeroAtRail, swappedSelectedAmplitudes]
    split_ifs <;> [exact hb j; exact hab j]
  have hsum : (∑ j, P j) ≤ ∑ j, P' j := by
    apply Finset.sum_le_sum
    intro j _
    dsimp [P', swappedSelectedSizes]
    split_ifs with hji
    · subst j; exact hlong
    · rfl
  have he : Even (∑ j, P' j) := Finset.even_sum P' (fun j _ => hP'even j)
  obtain ⟨k,hk⟩ := he
  let m := k - 1
  have hD' : (∑ j, P' j) = 2 * m + 2 := by dsimp [m]; omega
  have hnm : n ≤ m := by omega
  have htotal := sampler_potential_mass_bound hp P' r' hP'two hP'even hr'even
    (2 * m) hD' a' b' hb' hab'
  rw [← evenReluKappa_eq_coefficient] at htotal
  have hmin := average_minimumRailAmplitude_le_unpaired a' b' i
    (by simp [b', zeroAtRail])
  have hai : a' i = b i := by simp [a', swappedSelectedAmplitudes]
  rw [hai] at hmin
  calc
    _ ≤ _ := sampler_opposite_le_swapped_mass hp P r hPtwo hP hr a b i
    _ ≤ evenReluKappa m * finiteAverage (minimumRailAmplitude a' b') := htotal
    _ ≤ evenReluKappa m * b i := mul_le_mul_of_nonneg_left hmin (le_of_lt (evenReluKappa_pos m))
    _ ≤ evenReluKappa n * b i := mul_le_mul_of_nonneg_right (evenReluKappa_antitone hnm) (hb i)

end NeuralGeneralization.OnlineLowerRelu
