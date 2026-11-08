import NeuralGeneralization.OnlineLowerSamplerOrientation
import NeuralGeneralization.OnlineLowerSamplingRay

/-! # Actual balanced rays for the finite square-mean stability transfer -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

def railPairWeights {p : ℕ} (P r : Fin p → ℕ) (j : Fin p × Bool) : ℝ :=
  if j.2 then r j.1 + 2 else P j.1

def railPairAmplitudes {p : ℕ} (a b : Fin p → ℝ) (j : Fin p × Bool) : ℝ :=
  if j.2 then b j.1 else a j.1

/-- Every balanced physical neuron has a nonnegative balanced-ray witness
whose weighted squared distance is controlled by its norm slack. -/
theorem sampler_balanced_ray_exists {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i))
    (a b : Fin p → ℝ) (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hPmin : ∀ i, R ≤ (P i : ℝ)) (hQmin : ∀ i, R ≤ (r i + 2 : ℝ))
    (hdiff : ∀ i, |(r i + 2 : ℝ) - P i| ≤ Δ) :
    ∃ (θ : Fin p → Bool) (μ : ℝ), 0 ≤ μ ∧
      weightedRayError (railPairWeights P r) (fun j => |railPairAmplitudes a b j|) θ μ ≤
        weightedRailEnergy (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ)) a b -
          samplerWeightedPotential P r a b ^ 2 := by
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
    n hD a' b' hb' hab' R Δ hΔ hR hmin hinc).1
  have hmass : samplerWeightedPotential P' r' a' b' = samplerWeightedPotential P r a b := by
    rw [← sampler_weighted_orientation P r hPtwo (fun i => |a i|) (fun i => |b i|) ζ,
      sampler_weighted_abs]
  have henergy : weightedRailEnergy (fun i => (P' i : ℝ)) (fun i => (r' i + 2 : ℝ)) a' b' =
      weightedRailEnergy (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ)) a b := by
    rw [sampler_energy_orientation P r hPtwo (fun i => |a i|) (fun i => |b i|) ζ,
      sampler_energy_abs]
  rw [hmass, henergy] at hbound
  let θ : Fin p → Bool := fun i => decide (i ∈ ζ)
  let μ := weightedRailMean (fun i => (P' i : ℝ)) a' (2 * (n + 1 : ℝ))
  have hμ : 0 ≤ μ := weightedRailMean_nonneg _ _ _ (fun _ => Nat.cast_nonneg _)
    (fun i => (hb' i).trans (hab' i)) (by positivity)
  refine ⟨θ, μ, hμ, ?_⟩
  have herror : weightedRayError (railPairWeights P r)
      (fun j => |railPairAmplitudes a b j|) θ μ =
      balancedRaySquaredDistance (fun i => (P' i : ℝ)) (fun i => (r' i + 2 : ℝ))
        a' b' (2 * (n + 1 : ℝ)) := by
    unfold weightedRayError balancedRaySquaredDistance
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i _
    change _ = (P' i : ℝ) * (a' i - μ)^2 + (r' i + 2 : ℝ) * b' i ^2
    by_cases hi : i ∈ ζ <;>
      simp [railPairWeights, railPairAmplitudes, θ, hi, P', r', a', b',
        orientedSelectedSizes, orientedFreeSizes, orientedSelectedAmplitudes,
        orientedOppositeAmplitudes, hsizeR]
  rw [herror]
  exact hbound

end NeuralGeneralization.OnlineLowerRelu
