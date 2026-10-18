import NeuralGeneralization.CompressionSampling

/-!
# Finite feature-bank sampling for entropy compression

All probability bounds below use the actual independent uniform source-index
sampling law. The source width only occurs inside arithmetic averages, never
in the failure prefactor or sample-size exponent.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal NNReal

namespace NeuralGeneralization.RobustCompressionSampling
open CompressionSampling

/-- Empirical and population means of one finite source feature. -/
def empiricalMean {N M : ℕ} (f : Fin N → ℝ) (I : Fin M → Fin N) : ℝ :=
  (∑ j, f (I j)) / (M : ℝ)

def populationMean {N : ℕ} (f : Fin N → ℝ) : ℝ :=
  (∑ i, f i) / (N : ℝ)

theorem empiricalMean_tail (N M : ℕ) [NeZero N] (hM : 0 < M)
    (f : Fin N → ℝ) {B a : ℝ} (hB : 0 < B)
    (hf : ∀ i, |f i| ≤ B) (ha : 0 ≤ a) :
    (iidSamples (uniformIndexLaw N) M).real
      {I | a ≤ |empiricalMean f I - populationMean f|} ≤
      2 * Real.exp (-(M : ℝ) * a ^ 2 / (2 * B ^ 2)) := by
  have hm : 0 < (M : ℝ) := by exact_mod_cast hM
  have hb := uniform_neuron_sum_tail N M f hB.le hf (mul_nonneg hm.le ha)
  have hset :
      {I : Fin M → Fin N | (M : ℝ) * a ≤
        |(∑ j, f (I j)) - ((M : ℝ) / N) * ∑ i, f i|} =
      {I : Fin M → Fin N | a ≤ |empiricalMean f I - populationMean f|} := by
    ext I
    have heq : (∑ j, f (I j)) - ((M : ℝ) / N) * ∑ i, f i =
        (M : ℝ) * (empiricalMean f I - populationMean f) := by
      unfold empiricalMean populationMean
      field_simp
    simp only [Set.mem_setOf_eq, heq, abs_mul, abs_of_pos hm,
      mul_le_mul_iff_right₀ hm]
  rw [hset] at hb
  have hexp : -((M : ℝ) * a) ^ 2 / (2 * (M : ℝ) * B ^ 2) =
      -(M : ℝ) * a ^ 2 / (2 * B ^ 2) := by
    field_simp
  rwa [hexp] at hb

/-- Uniform concentration of any finite bank of bounded source features. -/
theorem finite_bank_tail {J : Type*} [Fintype J]
    (N M : ℕ) [NeZero N] (hM : 0 < M)
    (f : J → Fin N → ℝ) {B a : ℝ} (hB : 0 < B)
    (hf : ∀ j i, |f j i| ≤ B) (ha : 0 ≤ a) :
    (iidSamples (uniformIndexLaw N) M).real
      {I | ∃ j, a ≤ |empiricalMean (f j) I - populationMean (f j)|} ≤
      (Fintype.card J : ℝ) *
        (2 * Real.exp (-(M : ℝ) * a ^ 2 / (2 * B ^ 2))) := by
  let E : J → Set (Fin M → Fin N) :=
    fun j => {I | a ≤ |empiricalMean (f j) I - populationMean (f j)|}
  have heq : {I : Fin M → Fin N |
      ∃ j, a ≤ |empiricalMean (f j) I - populationMean (f j)|} = ⋃ j, E j := by
    ext I
    simp [E]
  rw [heq]
  exact finite_failure_union_le _ E (fun j => empiricalMean_tail N M hM (f j) hB (hf j) ha)

/-- One shared sample tests the active Gram matrix, all active feature means,
and every input-pair covariance. -/
abbrev FeatureTest (q : ℕ) (X : Type*) :=
  (Fin q × Fin q) ⊕ ((Fin q × X) ⊕ (X × X))

def featureBank {N q : ℕ} {X : Type*}
    (c : Fin N → Fin q → ℝ) (h : X → Fin N → ℝ) :
    FeatureTest q X → Fin N → ℝ
  | Sum.inl (j, k), i => c i j * c i k
  | Sum.inr (Sum.inl (j, x)), i => c i j * h x i
  | Sum.inr (Sum.inr (x, y)), i => h x i * h y i

theorem featureBank_bound {N q : ℕ} {X : Type*}
    (c : Fin N → Fin q → ℝ) (h : X → Fin N → ℝ) {T : ℝ}
    (hT : 1 ≤ T) (hc : ∀ i j, |c i j| ≤ T) (hh : ∀ x i, |h x i| ≤ 1) :
    ∀ j i, |featureBank c h j i| ≤ T ^ 2 := by
  intro j i
  rcases j with ⟨j,k⟩ | (⟨j,x⟩ | ⟨x,y⟩)
  · simp only [featureBank, abs_mul, pow_two]
    exact mul_le_mul (hc i j) (hc i k) (abs_nonneg _) (by linarith)
  · simp only [featureBank, abs_mul]
    have hb := mul_le_mul (hc i j) (hh x i) (abs_nonneg _) (by linarith : 0 ≤ T)
    nlinarith
  · simp only [featureBank, abs_mul]
    have hb := mul_le_mul (hh x i) (hh y i) (abs_nonneg _) (by norm_num : (0:ℝ) ≤ 1)
    nlinarith

theorem featureBank_tail {X : Type*} [Fintype X]
    (N M q : ℕ) [NeZero N] (hM : 0 < M)
    (c : Fin N → Fin q → ℝ) (h : X → Fin N → ℝ) {T a : ℝ}
    (hT : 1 ≤ T) (hc : ∀ i j, |c i j| ≤ T) (hh : ∀ x i, |h x i| ≤ 1)
    (ha : 0 ≤ a) :
    (iidSamples (uniformIndexLaw N) M).real
      {I | ∃ j : FeatureTest q X,
        a ≤ |empiricalMean (featureBank c h j) I - populationMean (featureBank c h j)|} ≤
      ((q : ℝ)^2 + q * Fintype.card X + (Fintype.card X : ℝ)^2) *
        (2 * Real.exp (-(M : ℝ) * a ^ 2 / (2 * T ^ 4))) := by
  have hT0 : 0 < T := by linarith
  have hb := finite_bank_tail N M hM (featureBank c h)
    (sq_pos_of_pos hT0) (featureBank_bound c h hT hc hh) ha
  have hpow : (T ^ 2) ^ 2 = T ^ 4 := by ring
  rw [hpow] at hb
  simpa only [Fintype.card_sum, Fintype.card_prod, Fintype.card_fin,
    Nat.cast_add, Nat.cast_mul, pow_two, add_assoc, mul_assoc] using hb

/-- The same finite-bank bound for arbitrary source probabilities. This is
used by leverage-biased source sampling; uniformity is not required. -/
theorem empiricalMean_tail_of_law (N M : ℕ) (hM : 0 < M)
    (ν : Measure (Fin N)) [IsProbabilityMeasure ν]
    (f : Fin N → ℝ) {B a : ℝ} (hB : 0 < B)
    (hf : ∀ i, |f i| ≤ B) (ha : 0 ≤ a) :
    (iidSamples ν M).real {I | a ≤ |empiricalMean f I - ∫ i, f i ∂ν|} ≤
      2 * Real.exp (-(M : ℝ) * a ^ 2 / (2 * B ^ 2)) := by
  have hm : 0 < (M : ℝ) := by exact_mod_cast hM
  have hb := iid_bounded_sum_tail ν M f (measurable_of_finite f) hB.le hf
    (mul_nonneg hm.le ha)
  have hset :
      {I : Fin M → Fin N | (M : ℝ) * a ≤
        |(∑ j, f (I j)) - (M : ℝ) * ∫ i, f i ∂ν|} =
      {I : Fin M → Fin N | a ≤ |empiricalMean f I - ∫ i, f i ∂ν|} := by
    ext I
    have heq : (∑ j, f (I j)) - (M : ℝ) * ∫ i, f i ∂ν =
        (M : ℝ) * (empiricalMean f I - ∫ i, f i ∂ν) := by
      unfold empiricalMean
      field_simp
    simp only [Set.mem_setOf_eq, heq, abs_mul, abs_of_pos hm,
      mul_le_mul_iff_right₀ hm]
  rw [hset] at hb
  have hexp : -((M : ℝ) * a) ^ 2 / (2 * (M : ℝ) * B ^ 2) =
      -(M : ℝ) * a ^ 2 / (2 * B ^ 2) := by field_simp
  rwa [hexp] at hb

theorem finite_bank_tail_of_law {J : Type*} [Fintype J]
    (N M : ℕ) (hM : 0 < M) (ν : Measure (Fin N)) [IsProbabilityMeasure ν]
    (f : J → Fin N → ℝ) {B a : ℝ} (hB : 0 < B)
    (hf : ∀ j i, |f j i| ≤ B) (ha : 0 ≤ a) :
    (iidSamples ν M).real
      {I | ∃ j, a ≤ |empiricalMean (f j) I - ∫ i, f j i ∂ν|} ≤
      (Fintype.card J : ℝ) * (2 * Real.exp (-(M : ℝ) * a ^ 2 / (2 * B ^ 2))) := by
  let E : J → Set (Fin M → Fin N) :=
    fun j => {I | a ≤ |empiricalMean (f j) I - ∫ i, f j i ∂ν|}
  have heq : {I : Fin M → Fin N |
      ∃ j, a ≤ |empiricalMean (f j) I - ∫ i, f j i ∂ν|} = ⋃ j, E j := by
    ext I
    simp [E]
  rw [heq]
  exact finite_failure_union_le _ E
    (fun j => empiricalMean_tail_of_law N M hM ν (f j) hB (hf j) ha)

end NeuralGeneralization.RobustCompressionSampling
