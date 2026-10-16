import NeuralGeneralization.EmpiricalDualTests
import NeuralGeneralization.SparseDualNet
import NeuralGeneralization.ActualBoundedDual

/-! # The nonasymptotic bounded-dual entropy certificate
Combines the actual IID fixed-test tail with the deterministic sparse grid,
then constructs the promised exponential tilt outside the exceptional event.
-/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.DualCertificate
open BoundedDual BoundedTilt ActualBoundedDual CompressionSampling SparseDualNet
variable {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι] [DecidableEq ι] [Nonempty ι]
variable (μ : Measure Ω) [IsProbabilityMeasure μ]

omit [Nonempty ι] in
/-- The exact finite-grid form of the exponential entropy-certificate tail. -/
theorem bounded_dual_tail
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {N s : ℕ} (hN : 0 < N) (hs : 0 < s)
    {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (iidSamples μ N).real (badEvent μ T N G K) ≤
      (((2 * Fintype.card ι + 1) ^ s : ℕ) : ℝ) *
        Real.exp (-(N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) := by
  classical
  let V := SparseAtoms.grid (ι := ι) G s
  let t := K - G ^ 2 / (2 * (s : ℝ))
  let E : (ι → ℝ) → Set (Fin N → Ω) := fun v =>
    {a | t < objective μ T (empirical T a) v}
  have hsubset : badEvent μ T N G K ⊆ ⋃ v ∈ V, E v := by
    intro a ha
    obtain ⟨lam, hlam, hK⟩ := ha
    obtain ⟨v, hv, hcomp⟩ := exists_sparse_competitor μ T hT hbound hG
      (empirical T a) lam hlam hs
    exact Set.mem_iUnion.mpr ⟨v, Set.mem_iUnion.mpr ⟨hv, by dsimp [E, t]; linarith⟩⟩
  calc
    (iidSamples μ N).real (badEvent μ T N G K) ≤
        (iidSamples μ N).real (⋃ v ∈ V, E v) :=
      measureReal_mono hsubset (measure_ne_top _ _)
    _ ≤ ∑ v ∈ V, (iidSamples μ N).real (E v) := measureReal_biUnion_finset_le V E
    _ ≤ ∑ _v ∈ V, Real.exp (-(N : ℝ) * t) :=
      Finset.sum_le_sum (fun v _ => fixed_test_tail μ T hT hbound hN v t)
    _ = (V.card : ℝ) * Real.exp (-(N : ℝ) * t) := by simp
    _ ≤ (((2 * Fintype.card ι + 1) ^ s : ℕ) : ℝ) * Real.exp (-(N : ℝ) * t) := by
      apply mul_le_mul_of_nonneg_right _ (Real.exp_pos _).le
      exact_mod_cast SparseAtoms.grid_card_le (ι := ι) G s

omit [Nonempty ι] in
/-- The same certificate in the exponential form used in the paper. -/
theorem bounded_dual_tail_exp
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {N s : ℕ} (hN : 0 < N) (hs : 0 < s)
    {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (iidSamples μ N).real (badEvent μ T N G K) ≤
      Real.exp ((s : ℝ) * Real.log (2 * (Fintype.card ι : ℝ) + 1) -
        (N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) := by
  have hb : 0 < 2 * (Fintype.card ι : ℝ) + 1 := by positivity
  have heq :
      (((2 * Fintype.card ι + 1) ^ s : ℕ) : ℝ) *
        Real.exp (-(N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) =
      Real.exp ((s : ℝ) * Real.log (2 * (Fintype.card ι : ℝ) + 1) -
        (N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) := by
    rw [Real.exp_sub, Real.exp_nat_mul, Real.exp_log hb]
    push_cast
    rw [neg_mul, Real.exp_neg]
    rfl
  exact (bounded_dual_tail μ T hT hbound hN hs hG K).trans_eq heq

/-- On the complement of that event there is an actual tilt with both the
claimed entropy bound and maximum-coordinate moment approximation. -/
theorem exists_tilt_of_not_bad
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {N : ℕ} {G K : ℝ} (hG : 0 < G)
    (a : Fin N → Ω) (ha : a ∉ badEvent μ T N G K) :
    ∃ star : ι → ℝ, entryL1 star ≤ G ∧ entropy μ T star ≤ K ∧
      maxAbs (empirical T a - mean μ T star) ≤ K / G := by
  apply exists_bounded_dual_lift_of_rate_bound μ T hT hbound (empirical T a) hG
  intro v hv
  by_contra h
  exact ha ⟨v, hv, lt_of_not_ge h⟩

end NeuralGeneralization.DualCertificate

end
