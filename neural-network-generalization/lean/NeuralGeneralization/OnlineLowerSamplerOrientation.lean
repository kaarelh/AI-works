import NeuralGeneralization.OnlineLowerSamplerWeighted

/-! # Choice of dominant physical rail for arbitrary balanced ReLU atoms -/

noncomputable section
open scoped BigOperators symmDiff
namespace NeuralGeneralization.OnlineLowerRelu

def orientedSelectedSizes {p : ℕ} (P r : Fin p → ℕ) (ζ : Finset (Fin p)) (i : Fin p) : ℕ :=
  if i ∈ ζ then r i + 2 else P i

def orientedFreeSizes {p : ℕ} (P r : Fin p → ℕ) (ζ : Finset (Fin p)) (i : Fin p) : ℕ :=
  if i ∈ ζ then P i - 2 else r i

def orientedSelectedAmplitudes {p : ℕ} (a b : Fin p → ℝ) (ζ : Finset (Fin p)) (i : Fin p) : ℝ :=
  if i ∈ ζ then b i else a i

def orientedOppositeAmplitudes {p : ℕ} (a b : Fin p → ℝ) (ζ : Finset (Fin p)) (i : Fin p) : ℝ :=
  if i ∈ ζ then a i else b i

def toggleRails {p : ℕ} (ζ : Finset (Fin p)) : Finset (Fin p) ≃ Finset (Fin p) where
  toFun τ := τ ∆ ζ
  invFun τ := τ ∆ ζ
  left_inv τ := by ext j; simp
  right_inv τ := by ext j; simp

/-- Exact covariance of the physical Fourier potential under any collection
of rail swaps. -/
theorem sampler_potential_orientation {p : ℕ} (P r : Fin p → ℕ)
    (hPtwo : ∀ i, 2 ≤ P i) (a b : Fin p → ℝ) (ζ τ : Finset (Fin p)) :
    supportFourierPotential (samplerSupport P r τ) (samplerWeights P r a b) =
    supportFourierPotential
      (samplerSupport (orientedSelectedSizes P r ζ) (orientedFreeSizes P r ζ) (toggleRails ζ τ))
      (samplerWeights (orientedSelectedSizes P r ζ) (orientedFreeSizes P r ζ)
        (orientedSelectedAmplitudes a b ζ) (orientedOppositeAmplitudes a b ζ)) := by
  unfold supportFourierPotential
  congr 1
  congr 1
  funext t
  rw [sampler_trigKernel_product, sampler_trigKernel_product]
  congr 2
  apply Finset.prod_congr rfl
  intro i _
  have hsize : P i - 2 + 2 = P i := by have := hPtwo i; omega
  by_cases hi : i ∈ ζ <;> by_cases ht : i ∈ τ <;>
    simp [orientedSelectedSizes, orientedFreeSizes, orientedSelectedAmplitudes,
      orientedOppositeAmplitudes, toggleRails, Finset.mem_symmDiff, hi, ht, hsize, mul_comm]

theorem sampler_halfDegree_orientation {p : ℕ} (P r : Fin p → ℕ)
    (hPtwo : ∀ i, 2 ≤ P i) (ζ τ : Finset (Fin p)) :
    samplerHalfDegree P r τ =
      samplerHalfDegree (orientedSelectedSizes P r ζ) (orientedFreeSizes P r ζ) (toggleRails ζ τ) := by
  unfold samplerHalfDegree
  apply Finset.sum_congr rfl
  intro i _
  have hsize : P i - 2 + 2 = P i := by have := hPtwo i; omega
  by_cases hi : i ∈ ζ <;> by_cases ht : i ∈ τ <;>
    simp [orientedSelectedSizes, orientedFreeSizes, toggleRails, Finset.mem_symmDiff, hi, ht, hsize]

theorem sampler_weighted_orientation {p : ℕ} (P r : Fin p → ℕ)
    (hPtwo : ∀ i, 2 ≤ P i) (a b : Fin p → ℝ) (ζ : Finset (Fin p)) :
    samplerWeightedPotential P r a b =
      samplerWeightedPotential (orientedSelectedSizes P r ζ) (orientedFreeSizes P r ζ)
        (orientedSelectedAmplitudes a b ζ) (orientedOppositeAmplitudes a b ζ) := by
  unfold samplerWeightedPotential
  rw [← Equiv.sum_comp (toggleRails ζ)
    (fun τ => samplerTransversalCost (orientedSelectedSizes P r ζ) (orientedFreeSizes P r ζ) τ *
      supportFourierPotential
        (samplerSupport (orientedSelectedSizes P r ζ) (orientedFreeSizes P r ζ) τ)
        (samplerWeights (orientedSelectedSizes P r ζ) (orientedFreeSizes P r ζ)
          (orientedSelectedAmplitudes a b ζ) (orientedOppositeAmplitudes a b ζ)))]
  apply Finset.sum_congr rfl
  intro τ _
  rw [sampler_potential_orientation P r hPtwo a b ζ τ]
  unfold samplerTransversalCost
  rw [sampler_halfDegree_orientation P r hPtwo ζ τ]

theorem sampler_weighted_abs {p : ℕ} (P r : Fin p → ℕ) (a b : Fin p → ℝ) :
    samplerWeightedPotential P r (fun i => |a i|) (fun i => |b i|) =
      samplerWeightedPotential P r a b := by
  have hw : samplerWeights P r (fun i => |a i|) (fun i => |b i|) =
      fun j => |samplerWeights P r a b j| := by
    funext j
    obtain ⟨⟨i,side,k⟩,rfl⟩ := (railIndex (samplerSize P r)).surjective j
    simp only [samplerWeights_apply]
    cases side <;> rfl
  unfold samplerWeightedPotential
  simp_rw [hw, supportPotential_abs_weights]

theorem sampler_energy_orientation {p : ℕ} (P r : Fin p → ℕ)
    (hPtwo : ∀ i, 2 ≤ P i) (a b : Fin p → ℝ) (ζ : Finset (Fin p)) :
    weightedRailEnergy (fun i => (orientedSelectedSizes P r ζ i : ℝ))
      (fun i => (orientedFreeSizes P r ζ i + 2 : ℝ))
      (orientedSelectedAmplitudes a b ζ) (orientedOppositeAmplitudes a b ζ) =
    weightedRailEnergy (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ)) a b := by
  unfold weightedRailEnergy
  rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  have hsize : P i - 2 + 2 = P i := by have := hPtwo i; omega
  have hsizeR : ((P i - 2 : ℕ) : ℝ) + 2 = (P i : ℝ) := by exact_mod_cast hsize
  by_cases hi : i ∈ ζ <;>
    simp [orientedSelectedSizes, orientedFreeSizes, orientedSelectedAmplitudes,
      orientedOppositeAmplitudes, hi, hsizeR, add_comm]

theorem sampler_energy_abs {p : ℕ} (P r : Fin p → ℕ) (a b : Fin p → ℝ) :
    weightedRailEnergy (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ))
      (fun i => |a i|) (fun i => |b i|) =
    weightedRailEnergy (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ)) a b := by
  simp only [weightedRailEnergy, sq_abs]

lemma nat_sub_cast_le_of_sub_le (u v : ℕ) (Δ : ℝ) (hΔ : 0 ≤ Δ)
    (h : (u : ℝ) - v ≤ Δ) : ((u - v : ℕ) : ℝ) ≤ Δ := by
  by_cases hv : v ≤ u
  · rwa [Nat.cast_sub hv]
  · rw [Nat.sub_eq_zero_of_le (by omega), Nat.cast_zero]
    exact hΔ

/-- The full balanced-atom norm bound applies to arbitrary signed rail
amplitudes: sign changes preserve the potential, and each pair can be
oriented toward its larger absolute amplitude. -/
theorem sampler_arbitrary_balanced_norm {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i))
    (a b : Fin p → ℝ) (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hPmin : ∀ i, R ≤ (P i : ℝ)) (hQmin : ∀ i, R ≤ (r i + 2 : ℝ))
    (hdiff : ∀ i, |(r i + 2 : ℝ) - P i| ≤ Δ) :
    samplerWeightedPotential P r a b ^ 2 ≤
      weightedRailEnergy (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ)) a b := by
  let ζ := Finset.univ.filter (fun i => |a i| < |b i|)
  let P' := orientedSelectedSizes P r ζ
  let r' := orientedFreeSizes P r ζ
  let a' := orientedSelectedAmplitudes (fun i => |a i|) (fun i => |b i|) ζ
  let b' := orientedOppositeAmplitudes (fun i => |a i|) (fun i => |b i|) ζ
  have hsize (i : Fin p) : P i - 2 + 2 = P i := by have := hPtwo i; omega
  have hsizeR (i : Fin p) : ((P i - 2 : ℕ) : ℝ) + 2 = (P i : ℝ) := by exact_mod_cast hsize i
  have hP'two (i : Fin p) : 2 ≤ P' i := by
    dsimp [P', orientedSelectedSizes]
    split_ifs <;> [omega; exact hPtwo i]
  have hP'even (i : Fin p) : Even (P' i) := by
    dsimp [P', orientedSelectedSizes]
    split_ifs
    · exact (hr i).add (by decide : Even 2)
    · exact hP i
  have hr'even (i : Fin p) : Even (r' i) := by
    dsimp [r', orientedFreeSizes]
    split_ifs
    · obtain ⟨v,hv⟩ := hP i
      refine ⟨v-1, ?_⟩
      have := hPtwo i
      omega
    · exact hr i
  have hb' (i : Fin p) : 0 ≤ b' i := by
    dsimp [b', orientedOppositeAmplitudes]
    split_ifs <;> exact abs_nonneg _
  have hab' (i : Fin p) : b' i ≤ a' i := by
    dsimp [b', a', orientedOppositeAmplitudes, orientedSelectedAmplitudes]
    split_ifs with hi
    · have h : |a i| < |b i| := by simpa [ζ] using hi
      exact h.le
    · have h : ¬ |a i| < |b i| := by simpa [ζ] using hi
      exact le_of_not_gt h
  have hmin (i : Fin p) : R ≤ (P' i : ℝ) := by
    dsimp [P', orientedSelectedSizes]
    split_ifs
    · exact_mod_cast hQmin i
    · exact hPmin i
  have hinc (i : Fin p) : (samplerPositiveIncrement P' r' i : ℝ) ≤ Δ := by
    apply nat_sub_cast_le_of_sub_le _ _ Δ hΔ
    have h := abs_le.mp (hdiff i)
    dsimp [P', r', orientedSelectedSizes, orientedFreeSizes]
    split_ifs <;> push_cast
    · rw [hsizeR]
      linarith
    · exact h.2
  have he : Even (∑ i, P' i) := Finset.even_sum P' (fun i _ => hP'even i)
  obtain ⟨k,hk⟩ := he
  have hsumtwo : 2 ≤ ∑ i, P' i := by
    let j : Fin p := ⟨0,by omega⟩
    exact (hP'two j).trans (Finset.single_le_sum (fun _ _ => Nat.zero_le _) (Finset.mem_univ j))
  let n := k - 1
  have hD : (∑ i, P' i) = 2 * n + 2 := by dsimp [n]; omega
  have hbound := (sampler_weighted_norm_and_stability hp P' r' hP'two hP'even hr'even
    n hD a' b' hb' hab' R Δ hΔ hR hmin hinc).2
  have hmass : samplerWeightedPotential P' r' a' b' = samplerWeightedPotential P r a b := by
    rw [← sampler_weighted_orientation P r hPtwo (fun i => |a i|) (fun i => |b i|) ζ,
      sampler_weighted_abs]
  have henergy : weightedRailEnergy (fun i => (P' i : ℝ)) (fun i => (r' i + 2 : ℝ)) a' b' =
      weightedRailEnergy (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ)) a b := by
    rw [sampler_energy_orientation P r hPtwo (fun i => |a i|) (fun i => |b i|) ζ,
      sampler_energy_abs]
  rwa [hmass, henergy] at hbound

end NeuralGeneralization.OnlineLowerRelu
