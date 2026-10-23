import NeuralGeneralization.BatchTwoRelativeGrowthPairSwap

/-! A union bound over distinct pooled membership patterns, combined with
the exact invariance of the two IID samples under independent pair swaps. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoRelativeGrowth
open SquaredSampling CompressionSampling

variable {X H : Type*} [Fintype X] [MeasurableSpace X] [MeasurableSingletonClass X] [Fintype H]

def pairedPattern {n : ℕ} (a : X → Bool) (p : (Fin n → X) × (Fin n → X)) :
    (Fin n → Bool) × (Fin n → Bool) := (fun i => a (p.1 i), fun i => a (p.2 i))

def pairedPatterns {n : ℕ} (a : H → X → Bool) (p : (Fin n → X) × (Fin n → X)) :
    Finset ((Fin n → Bool) × (Fin n → Bool)) := Finset.univ.image (fun h => pairedPattern (a h) p)

theorem pairedPattern_swap {n : ℕ} (a : X → Bool)
    (p : (Fin n → X) × (Fin n → X)) (ε : Fin n → Bool) :
    pairedPattern a (signSwap ε p) = signSwap ε (pairedPattern a p) := by
  apply Prod.ext <;> funext i <;> cases he : ε i <;> simp [pairedPattern, signSwap, he]

theorem doubleSampleEvent_pattern {n : ℕ} (a : H → X → Bool)
    (p : (Fin n → X) × (Fin n → X)) (u : ℝ) :
    p ∈ doubleSampleEvent a n u ↔ ∃ q ∈ pairedPatterns a p, patternBad u q := by
  constructor
  · rintro ⟨h, hh⟩
    refine ⟨pairedPattern (a h) p, Finset.mem_image.mpr ⟨h, Finset.mem_univ _, rfl⟩, ?_⟩
    simpa [patternBad, patternCount, count, pairedPattern, hit] using hh
  · rintro ⟨q, hq, hh⟩
    obtain ⟨h, _, rfl⟩ := Finset.mem_image.mp hq
    refine ⟨h, ?_⟩
    simpa [patternBad, patternCount, count, pairedPattern, hit] using hh

theorem fixed_pair_class_tail {n : ℕ} (a : H → X → Bool)
    (p : (Fin n → X) × (Fin n → X)) (u : ℝ) :
    finiteMean (fun ε : Fin n → Bool =>
      if signSwap ε p ∈ doubleSampleEvent a n u then (1 : ℝ) else 0) ≤
      (pairedPatterns a p).card*Real.exp (-(6 : ℝ)/25*n*u) := by
  have hpoint (ε : Fin n → Bool) :
      (if signSwap ε p ∈ doubleSampleEvent a n u then (1 : ℝ) else 0) ≤
        ∑ q ∈ pairedPatterns a p, if patternBad u (signSwap ε q) then (1 : ℝ) else 0 := by
    by_cases hb : signSwap ε p ∈ doubleSampleEvent a n u
    · rw [if_pos hb]
      obtain ⟨h, hh⟩ := hb
      let q := pairedPattern (a h) p
      have hq : q ∈ pairedPatterns a p := Finset.mem_image.mpr ⟨h, Finset.mem_univ _, rfl⟩
      have hbad : patternBad u (signSwap ε q) := by
        rw [← pairedPattern_swap]
        simpa [patternBad, patternCount, count, pairedPattern, hit] using hh
      have hs := Finset.single_le_sum
        (f := fun q => if patternBad u (signSwap ε q) then (1 : ℝ) else 0)
        (s := pairedPatterns a p) (fun q _ => by split_ifs <;> norm_num) hq
      simpa only [if_pos hbad] using hs
    · rw [if_neg hb]
      apply Finset.sum_nonneg
      intro q _
      split_ifs <;> norm_num
  have hmean := finiteMean_mono hpoint
  have hcomm : finiteMean (fun ε : Fin n → Bool =>
      ∑ q ∈ pairedPatterns a p, if patternBad u (signSwap ε q) then (1 : ℝ) else 0) =
      ∑ q ∈ pairedPatterns a p, finiteMean (fun ε : Fin n → Bool =>
        if patternBad u (signSwap ε q) then (1 : ℝ) else 0) := by
    unfold finiteMean
    rw [Finset.sum_comm, Finset.sum_div]
  rw [hcomm] at hmean
  calc
    _ ≤ ∑ q ∈ pairedPatterns a p, finiteMean (fun ε : Fin n → Bool =>
        if patternBad u (signSwap ε q) then (1 : ℝ) else 0) := hmean
    _ ≤ ∑ _q ∈ pairedPatterns a p, Real.exp (-(6 : ℝ)/25*n*u) :=
      Finset.sum_le_sum (fun q _ => pattern_swap_tail q u)
    _ = _ := by simp

theorem double_sample_growth_bound (D : Measure X) [IsProbabilityMeasure D]
    (a : H → X → Bool) (n : ℕ) (u P : ℝ)
    (hP : ∀ p : (Fin n → X) × (Fin n → X), ((pairedPatterns a p).card : ℝ) ≤ P) :
    ((iidSamples D n).prod (iidSamples D n)).real (doubleSampleEvent a n u) ≤
      P*Real.exp (-(6 : ℝ)/25*n*u) := by
  let μ := (iidSamples D n).prod (iidSamples D n)
  let E := doubleSampleEvent a n u
  let F := fun p : (Fin n → X) × (Fin n → X) => if p ∈ E then (1 : ℝ) else 0
  have hmeasure : (∫ p, F p ∂μ) = μ.real E := by
    exact integral_indicator_one (Set.toFinite E).measurableSet
  have havg : (∫ p, finiteMean (fun ε : Fin n → Bool => F (signSwap ε p)) ∂μ) = ∫ p, F p ∂μ := by
    unfold finiteMean
    rw [integral_div, integral_finsetSum Finset.univ (fun _ _ => RobustStatistics.integrable_finite_domain μ _)]
    dsimp only [μ]
    simp_rw [paired_iid_integral_swap D F]
    simp
  rw [← hmeasure, ← havg]
  have hp (p : (Fin n → X) × (Fin n → X)) :
      finiteMean (fun ε : Fin n → Bool => F (signSwap ε p)) ≤
        P*Real.exp (-(6 : ℝ)/25*n*u) :=
    (fixed_pair_class_tail a p u).trans (mul_le_mul_of_nonneg_right (hP p) (Real.exp_pos _).le)
  calc
    _ ≤ ∫ _p, P*Real.exp (-(6 : ℝ)/25*n*u) ∂μ := integral_mono
      (RobustStatistics.integrable_finite_domain μ _) (integrable_const _) hp
    _ = _ := by simp

theorem relative_growth_tail (D : Measure X) [IsProbabilityMeasure D]
    (a : H → X → Bool) (n : ℕ) (hn : 0 < n) {u : ℝ}
    (hu : 32*Real.log 2 ≤ (n : ℝ)*u) (P : ℝ)
    (hP : ∀ p : (Fin n → X) × (Fin n → X), ((pairedPatterns a p).card : ℝ) ≤ P) :
    (iidSamples D n).real (badSample D a n u) ≤
      2*P*Real.exp (-(6 : ℝ)/25*n*u) := by
  have h := ghost_symmetrization D a n hn hu
  have ht := double_sample_growth_bound D a n u P hP
  nlinarith

end NeuralGeneralization.BatchTwoRelativeGrowth
