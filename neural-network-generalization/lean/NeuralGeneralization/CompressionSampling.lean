import NeuralGeneralization.SamplingLaw
import NeuralGeneralization.CompressionWidth
import NeuralGeneralization.IIDHoeffding
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.Probability.Distributions.Uniform
import Mathlib.Probability.ProbabilityMassFunction.Integrals
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Lean.Elab.Tactic.Omega

/-!
# Concentration for the actual finite independent sampling construction

The sampling laws in this file are concrete products of probability measures.
The finite specialization samples uniformly with replacement from neuron indices.
-/

noncomputable section
open scoped BigOperators ENNReal NNReal
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.CompressionSampling

variable {Ω α : Type*} [MeasurableSpace Ω] [MeasurableSpace α]

/-- Concrete uniform sampling with replacement: no abstract independence
    hypothesis remains in this finite-neuron concentration statement. -/
theorem uniform_neuron_sum_tail (N M : ℕ) [NeZero N] (f : Fin N → ℝ)
    {B ε : ℝ} (hB : 0 ≤ B) (hbound : ∀ i, |f i| ≤ B) (hε : 0 ≤ ε) :
    (iidSamples (uniformIndexLaw N) M).real
      {ω | ε ≤ |(∑ b, f (ω b)) - ((M : ℝ) / N) * ∑ i, f i|} ≤
      2 * Real.exp (-ε ^ 2 / (2 * (M : ℝ) * B ^ 2)) := by
  have h := iid_bounded_sum_tail (uniformIndexLaw N) M f (measurable_of_finite f)
    hB hbound hε
  rw [uniformIndex_integral] at h
  have hmean : (M : ℝ) * ((∑ i, f i) / N) =
      ((M : ℝ) / N) * ∑ i, f i := by ring
  simpa only [hmean] using h

/-- The unnormalized Monte Carlo row estimator used in network compression. -/
theorem uniform_neuron_estimator_tail (N M : ℕ) [NeZero N] (hM : 0 < M)
    (f : Fin N → ℝ) {B t : ℝ} (hB : 0 < B)
    (hbound : ∀ i, |f i| ≤ B) (ht : 0 ≤ t) :
    (iidSamples (uniformIndexLaw N) M).real
      {ω | t ≤ |((N : ℝ) / M) * (∑ b, f (ω b)) - ∑ i, f i|} ≤
      2 * Real.exp (-(M : ℝ) * t ^ 2 / (2 * (N : ℝ) ^ 2 * B ^ 2)) := by
  have hNR : 0 < (N : ℝ) := by exact_mod_cast (NeZero.pos N)
  have hMR : 0 < (M : ℝ) := by exact_mod_cast hM
  have hratio : 0 < (M : ℝ) / N := div_pos hMR hNR
  have h := uniform_neuron_sum_tail N M f hB.le hbound
    (mul_nonneg hratio.le ht)
  have heq :
      {ω : Fin M → Fin N | (M : ℝ) / N * t ≤
        |(∑ b, f (ω b)) - ((M : ℝ) / N) * ∑ i, f i|} =
      {ω : Fin M → Fin N | t ≤
        |((N : ℝ) / M) * (∑ b, f (ω b)) - ∑ i, f i|} := by
    ext ω
    have hscale : (∑ b, f (ω b)) - ((M : ℝ) / N) * ∑ i, f i =
        ((M : ℝ) / N) * (((N : ℝ) / M) * (∑ b, f (ω b)) - ∑ i, f i) := by
      field_simp [ne_of_gt hNR, ne_of_gt hMR]
    simp only [Set.mem_setOf_eq, hscale, abs_mul, abs_of_pos hratio,
      mul_le_mul_iff_right₀ hratio]
  rw [heq] at h
  have hexp : -(((M : ℝ) / N) * t) ^ 2 / (2 * (M : ℝ) * B ^ 2) =
      -(M : ℝ) * t ^ 2 / (2 * (N : ℝ) ^ 2 * B ^ 2) := by
    field_simp [ne_of_gt hNR, ne_of_gt hMR, ne_of_gt hB]
  rwa [hexp] at h

/-- The exact exponent `rho^4*M/32` in the paper's retained-row estimate.
    `q` is the positive square root of the original width, specified without
    hiding any probabilistic assumption. Zero rows are handled deterministically. -/
theorem truncated_row_tail (N M : ℕ) [NeZero N] (hM : 0 < M)
    (w h : Fin N → ℝ) {ρ a q : ℝ} (hρ : 0 < ρ) (ha : 0 < a)
    (hq : 0 < q) (hq_sq : q ^ 2 = (N : ℝ))
    (hw : ∀ i, |w i| ≤ 2 * a / (ρ * q)) (hh : ∀ i, |h i| ≤ 1) :
    (iidSamples (uniformIndexLaw N) M).real
      {ω | ρ / 2 * q * a ≤
        |((N : ℝ) / M) * (∑ b, w (ω b) * h (ω b)) - ∑ i, w i * h i|} ≤
      2 * Real.exp (-ρ ^ 4 * (M : ℝ) / 32) := by
  have hB : 0 < 2 * a / (ρ * q) := by positivity
  have hf (i : Fin N) : |w i * h i| ≤ 2 * a / (ρ * q) := by
    rw [abs_mul]
    calc
      |w i| * |h i| ≤ |w i| * 1 :=
        mul_le_mul_of_nonneg_left (hh i) (abs_nonneg _)
      _ ≤ _ := by simpa only [mul_one] using hw i
  have ht : 0 ≤ ρ / 2 * q * a := by positivity
  have hb := uniform_neuron_estimator_tail N M hM (fun i => w i * h i) hB hf ht
  have he : -(M : ℝ) * (ρ / 2 * q * a) ^ 2 /
      (2 * (N : ℝ) ^ 2 * (2 * a / (ρ * q)) ^ 2) = -ρ ^ 4 * (M : ℝ) / 32 := by
    rw [← hq_sq]
    field_simp [ne_of_gt hρ, ne_of_gt ha, ne_of_gt hq]
    ring
  rwa [he] at hb

/-- Strict row-failure version, including the zero-row case. -/
theorem truncated_row_strict_tail (N M : ℕ) [NeZero N] (hM : 0 < M)
    (w h : Fin N → ℝ) {ρ a q : ℝ} (hρ : 0 < ρ) (ha : 0 ≤ a)
    (hq : 0 < q) (hq_sq : q ^ 2 = (N : ℝ))
    (hw : ∀ i, |w i| ≤ 2 * a / (ρ * q)) (hh : ∀ i, |h i| ≤ 1) :
    (iidSamples (uniformIndexLaw N) M).real
      {ω | ρ / 2 * q * a <
        |((N : ℝ) / M) * (∑ b, w (ω b) * h (ω b)) - ∑ i, w i * h i|} ≤
      2 * Real.exp (-ρ ^ 4 * (M : ℝ) / 32) := by
  by_cases hz : a = 0
  · have hwzero (i : Fin N) : w i = 0 := by
      have hb := hw i
      rw [hz] at hb
      simp only [mul_zero, zero_div] at hb
      exact abs_nonpos_iff.mp hb
    simp [hz, hwzero]
    positivity
  · have hb := truncated_row_tail N M hM w h hρ (lt_of_le_of_ne ha (Ne.symm hz)) hq hq_sq hw hh
    apply le_trans (measureReal_mono (μ := iidSamples (uniformIndexLaw N) M) ?_) hb
    intro ω hω
    simp only [Set.mem_setOf_eq] at hω ⊢
    exact le_of_lt hω

/-- A randomly retained row obeys the same estimate as a fixed row, including
    zero rows. The product law is an actual independent random row and sample list. -/
theorem randomly_retained_row_tail (R N M : ℕ) [NeZero R] [NeZero N]
    (hM : 0 < M) (w : Fin R → Fin N → ℝ) (h : Fin N → ℝ)
    (a : Fin R → ℝ) {ρ q : ℝ} (hρ : 0 < ρ) (hq : 0 < q)
    (hq_sq : q ^ 2 = (N : ℝ)) (ha : ∀ j, 0 ≤ a j)
    (hw : ∀ j i, |w j i| ≤ 2 * a j / (ρ * q)) (hh : ∀ i, |h i| ≤ 1) :
    ((uniformIndexLaw R).prod (iidSamples (uniformIndexLaw N) M)).real
      {z | ρ / 2 * q * a z.1 <
        |((N : ℝ) / M) * (∑ b, w z.1 (z.2 b) * h (z.2 b)) -
          ∑ i, w z.1 i * h i|} ≤
      2 * Real.exp (-ρ ^ 4 * (M : ℝ) / 32) := by
  classical
  apply independent_row_mixture_le _ _ _ ((Set.toFinite _).measurableSet) (by positivity)
  intro j
  change (iidSamples (uniformIndexLaw N) M).real
    {ω | ρ / 2 * q * a j < |((N : ℝ) / M) * (∑ b, w j (ω b) * h (ω b)) - ∑ i, w j i * h i|} ≤ _
  exact truncated_row_strict_tail N M hM (w j) h hρ (ha j) hq hq_sq (hw j) hh


open ConcreteModel

/-- A retained row event under the actual joint law of all hidden-layer lists.
    The output row is selected by one list and its inputs by a distinct list. -/
theorem layer_retained_row_tail (N M r : ℕ) [NeZero N] (hM : 0 < M)
    (s t : Fin (r + 1)) (hst : s ≠ t) (a : Fin M)
    (w : Fin N → Fin N → ℝ) (h : Fin N → ℝ) (R : Fin N → ℝ)
    {ρ q : ℝ} (hρ : 0 < ρ) (hq : 0 < q) (hq_sq : q ^ 2 = (N : ℝ))
    (hR : ∀ j, 0 ≤ R j) (hw : ∀ j i, |w j i| ≤ 2 * R j / (ρ * q))
    (hh : ∀ i, |h i| ≤ 1) :
    (allLayerLists N M r).real
      {I | ρ / 2 * q * R (I s a) <
        |((N : ℝ) / M) * (∑ b, w (I s a) (I t b) * h (I t b)) -
          ∑ i, w (I s a) i * h i|} ≤
      2 * Real.exp (-ρ ^ 4 * (M : ℝ) / 32) := by
  classical
  let E : Set ((Fin M → Fin N) × (Fin M → Fin N)) :=
    {z | ρ / 2 * q * R (z.1 a) <
      |((N : ℝ) / M) * (∑ b, w (z.1 a) (z.2 b) * h (z.2 b)) -
        ∑ i, w (z.1 a) i * h i|}
  have hE : MeasurableSet E := (Set.toFinite E).measurableSet
  have hprob : ((iidSamples (uniformIndexLaw N) M).prod
      (iidSamples (uniformIndexLaw N) M)).real E ≤
      2 * Real.exp (-ρ ^ 4 * (M : ℝ) / 32) := by
    apply independent_row_mixture_le _ _ E hE (by positivity)
    intro J
    change (iidSamples (uniformIndexLaw N) M).real
      {ω | ρ / 2 * q * R (J a) <
        |((N : ℝ) / M) * (∑ b, w (J a) (ω b) * h (ω b)) - ∑ i, w (J a) i * h i|} ≤ _
    exact truncated_row_strict_tail N M hM (w (J a)) h hρ (hR (J a)) hq hq_sq (hw (J a)) hh
  have hmap := layer_pair_map N M r s t hst
  have hset := Measure.map_apply (μ := allLayerLists N M r)
    (f := fun I : Fin (r + 1) → Fin M → Fin N => (I s, I t))
    ((measurable_pi_apply s).prodMk (measurable_pi_apply t)) hE
  rw [hmap] at hset
  change (allLayerLists N M r).real ((fun I => (I s, I t)) ⁻¹' E) ≤ _
  unfold Measure.real at hprob ⊢
  rw [← hset]
  exact hprob

/-- The actual bad-row event includes every Boolean input, every retained
    internal row, and one terminal readout row for each input. -/
def badRowEvent {d N M r : ℕ} (φ : ℝ → ℝ) (ρ q : ℝ) (w u : Weights d N r) :
    Set (Fin (r + 1) → Fin M → Fin N) :=
  {I | (∃ x s a, ρ / 2 * q * internalRowNorm w s (I s.succ a) <
      |rowSamplingError φ u I x s a|) ∨
    ∃ x, ρ / 2 * q * outputRowNorm w <
      |((N : ℝ) / M) * ∑ a,
        u (Sum.inr (Sum.inr (I (Fin.last r) a))) * finalHidden φ u x (I (Fin.last r) a) -
        networkOutput φ u x|}

/-- Uniformity over all inputs costs `2^d`; uniformity over internal rows costs
    only `r*M`, with no factor from the original width. -/
theorem badRowEvent_probability {d N M r : ℕ} [NeZero N] (hM : 0 < M)
    (φ : ℝ → ℝ) (hφ : ∀ t, |φ t| ≤ 1) {ρ q : ℝ}
    (hρ : 0 < ρ) (hq : 0 < q) (hqsq : q ^ 2 = (N : ℝ))
    (w u : Weights d N r)
    (hint : ∀ s i j, |u (Sum.inr (Sum.inl (s,i,j)))| ≤
      2 * internalRowNorm w s i / (ρ * q))
    (hout : ∀ j, |u (Sum.inr (Sum.inr j))| ≤ 2 * outputRowNorm w / (ρ * q)) :
    (allLayerLists N M r).real (badRowEvent φ ρ q w u) ≤
      ((r : ℝ) * M + 1) * 2 ^ d * (2 * Real.exp (-ρ ^ 4 * (M : ℝ) / 32)) := by
  classical
  let E : (Cube d × Fin r × Fin M) → Set (Fin (r + 1) → Fin M → Fin N) :=
    fun z => {I | ρ / 2 * q * internalRowNorm w z.2.1 (I z.2.1.succ z.2.2) <
      |rowSamplingError φ u I z.1 z.2.1 z.2.2|}
  let G : Cube d → Set (Fin (r + 1) → Fin M → Fin N) :=
    fun x => {I | ρ / 2 * q * outputRowNorm w <
      |((N : ℝ) / M) * ∑ a,
        u (Sum.inr (Sum.inr (I (Fin.last r) a))) * finalHidden φ u x (I (Fin.last r) a) -
        networkOutput φ u x|}
  have hE (z : Cube d × Fin r × Fin M) :
      (allLayerLists N M r).real (E z) ≤ 2 * Real.exp (-ρ ^ 4 * (M : ℝ) / 32) := by
    obtain ⟨x,s,a⟩ := z
    have hst : s.succ ≠ s.castSucc := by
      intro heq
      have hv := congrArg Fin.val heq
      simp only [Fin.val_succ, Fin.val_castSucc] at hv
      omega
    exact layer_retained_row_tail N M r hM s.succ s.castSucc hst a
      (fun i j => u (Sum.inr (Sum.inl (s,i,j)))) (hiddenPrefix φ u x s.val)
      (internalRowNorm w s) hρ hq hqsq (internalRowNorm_nonneg w s) (hint s)
      (fun j => hiddenPrefix_bounded φ hφ u x s.val j)
  have hG (x : Cube d) :
      (allLayerLists N M r).real (G x) ≤ 2 * Real.exp (-ρ ^ 4 * (M : ℝ) / 32) := by
    let H : Set (Fin M → Fin N) := {J | ρ / 2 * q * outputRowNorm w <
      |((N : ℝ) / M) * ∑ a,
        u (Sum.inr (Sum.inr (J a))) * finalHidden φ u x (J a) - networkOutput φ u x|}
    change (allLayerLists N M r).real ((fun I => I (Fin.last r)) ⁻¹' H) ≤ _
    rw [layer_event_probability N M r (Fin.last r) H]
    exact truncated_row_strict_tail N M hM (fun j => u (Sum.inr (Sum.inr j)))
      (finalHidden φ u x) hρ (outputRowNorm_nonneg w) hq hqsq hout
      (fun j => by simpa only [hiddenPrefix_last] using hiddenPrefix_bounded φ hφ u x r j)
  have heq : badRowEvent φ ρ q w u = (⋃ z, E z) ∪ (⋃ x, G x) := by
    ext I
    simp only [badRowEvent, E, G, Set.mem_setOf_eq, Set.mem_union, Set.mem_iUnion]
    constructor
    · rintro (⟨x,s,a,h⟩ | ⟨x,h⟩)
      · exact Or.inl ⟨(x,s,a),h⟩
      · exact Or.inr ⟨x,h⟩
    · rintro (⟨⟨x,s,a⟩,h⟩ | ⟨x,h⟩)
      · exact Or.inl ⟨x,s,a,h⟩
      · exact Or.inr ⟨x,h⟩
  rw [heq]
  have hu := measureReal_union_le (μ := allLayerLists N M r) (⋃ z, E z) (⋃ x, G x)
  have hi := finite_failure_union_le (allLayerLists N M r) E hE
  have ho := finite_failure_union_le (allLayerLists N M r) G hG
  have hcard : Fintype.card (Cube d) = 2 ^ d := by simp [Cube]
  simp only [Fintype.card_prod, Fintype.card_fin, hcard, Nat.cast_mul,
    Nat.cast_pow, Nat.cast_ofNat] at hi ho
  nlinarith

/-- The probabilistic method supplies actual lists satisfying every row event,
    the original retained-row mass bound, and the final sampled-cost bound. -/
theorem exists_good_sampling_lists {d N M r : ℕ} [NeZero N] (hM : 0 < M)
    (φ : ℝ → ℝ) (hφ : ∀ t, |φ t| ≤ 1) {ρ q K : ℝ}
    (hρ : 0 < ρ) (hq : 0 < q) (hqsq : q ^ 2 = (N : ℝ)) (hK : 0 < K)
    (w u : Weights d N r) (hw : weightedSquaredNorm w ≤ K) (hu : weightedSquaredNorm u ≤ K)
    (hint : ∀ s i j, |u (Sum.inr (Sum.inl (s,i,j)))| ≤
      2 * internalRowNorm w s i / (ρ * q))
    (hout : ∀ j, |u (Sum.inr (Sum.inr j))| ≤ 2 * outputRowNorm w / (ρ * q))
    (hwidth : (((r : ℝ) * M + 1) * 2 ^ d *
      (2 * Real.exp (-ρ ^ 4 * (M : ℝ) / 32))) ≤ 1 / 4) :
    ∃ I : Fin (r + 1) → Fin M → Fin N,
      weightedSquaredNorm (sampledWeights u I) ≤ 4 * K ∧
      retainedRowMass w I ≤ 8 * (M : ℝ) * K ∧
      (∀ x s a, |rowSamplingError φ u I x s a| ≤
        ρ / 2 * q * internalRowNorm w s (I s.succ a)) ∧
      ∀ x, |((N : ℝ) / M) * ∑ a,
        u (Sum.inr (Sum.inr (I (Fin.last r) a))) * finalHidden φ u x (I (Fin.last r) a) -
        networkOutput φ u x| ≤ ρ / 2 * q * outputRowNorm w := by
  let A := badRowEvent (M := M) φ ρ q w u
  let B : Set (Fin (r + 1) → Fin M → Fin N) := {I | 8 * (M : ℝ) * K ≤ retainedRowMass w I}
  let C : Set (Fin (r + 1) → Fin M → Fin N) := {I | 4 * K ≤ weightedSquaredNorm (sampledWeights u I)}
  have hA : (allLayerLists N M r).real A ≤ 1 / 4 :=
    (badRowEvent_probability hM φ hφ hρ hq hqsq w u hint hout).trans hwidth
  have hB : (allLayerLists N M r).real B ≤ 1 / 8 := retainedRowMass_tail hM w hK hw
  have hC : (allLayerLists N M r).real C ≤ 1 / 4 := sampled_cost_tail hM u hK hu
  obtain ⟨I,hnA,hnB,hnC⟩ := exists_outside_three_events A B C hA hB hC (by norm_num)
  refine ⟨I, (lt_of_not_ge hnC).le, (lt_of_not_ge hnB).le, ?_, ?_⟩
  · intro x s a
    exact le_of_not_gt (fun h => hnA (Or.inl ⟨x,s,a,h⟩))
  · intro x
    exact le_of_not_gt (fun h => hnA (Or.inr ⟨x,h⟩))

end NeuralGeneralization.CompressionSampling
