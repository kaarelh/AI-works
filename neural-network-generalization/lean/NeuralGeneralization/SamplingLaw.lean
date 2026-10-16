import NeuralGeneralization.SampledNetworkError
import NeuralGeneralization.IIDLaw
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.Probability.Distributions.Uniform
import Mathlib.Probability.ProbabilityMassFunction.Integrals
import Mathlib.Probability.Independence.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Lean.Elab.Tactic.Omega

/-! # The actual finite sampling laws and their exact expected costs -/
noncomputable section
open scoped BigOperators ENNReal NNReal
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.CompressionSampling
open ConcreteModel
variable {Ω α : Type*} [MeasurableSpace Ω] [MeasurableSpace α]

/-- The finite uniform distribution on the original neuron indices. -/
def uniformIndexLaw (N : ℕ) [NeZero N] : Measure (Fin N) :=
  (PMF.uniformOfFintype (Fin N)).toMeasure

instance uniformIndexLaw_probability (N : ℕ) [NeZero N] :
    IsProbabilityMeasure (uniformIndexLaw N) := by
  unfold uniformIndexLaw
  infer_instance

/-- Its integral is the literal arithmetic average over the neuron array. -/
theorem uniformIndex_integral (N : ℕ) [NeZero N] (f : Fin N → ℝ) :
    (∫ i, f i ∂uniformIndexLaw N) = (∑ i, f i) / (N : ℝ) := by
  unfold uniformIndexLaw
  rw [PMF.integral_eq_sum]
  simp only [PMF.uniformOfFintype_apply, Fintype.card_fin, ENNReal.toReal_inv,
    ENNReal.toReal_natCast, smul_eq_mul]
  rw [← Finset.mul_sum]
  ring


/-- Integrating a uniform section bound over an independent random row does not
    introduce a union bound over the original number of neurons. -/
theorem independent_row_mixture_le {β : Type*} [MeasurableSpace β]
    (ν : Measure β) (μ : Measure Ω) [IsProbabilityMeasure ν] [IsProbabilityMeasure μ]
    (E : Set (β × Ω)) (hE : MeasurableSet E) {p : ℝ} (hp : 0 ≤ p)
    (hsections : ∀ b, μ.real (Prod.mk b ⁻¹' E) ≤ p) :
    (ν.prod μ).real E ≤ p := by
  have hENN (b : β) : μ (Prod.mk b ⁻¹' E) ≤ ENNReal.ofReal p :=
    (ENNReal.le_ofReal_iff_toReal_le (measure_ne_top _ _) hp).2 (hsections b)
  have hbound : (ν.prod μ) E ≤ ENNReal.ofReal p := by
    calc
      (ν.prod μ) E = ∫⁻ b, μ (Prod.mk b ⁻¹' E) ∂ν := Measure.prod_apply hE
      _ ≤ ∫⁻ _b, ENNReal.ofReal p ∂ν := lintegral_mono hENN
      _ = _ := by simp
  exact (ENNReal.le_ofReal_iff_toReal_le (measure_ne_top _ _) hp).1 hbound


/-- Evaluating one position of the actual product sample has the original law. -/
theorem iid_uniform_eval_integral (N M : ℕ) [NeZero N] (i : Fin M)
    (f : Fin N → ℝ) :
    (∫ ω, f (ω i) ∂iidSamples (uniformIndexLaw N) M) =
      ∫ j, f j ∂uniformIndexLaw N := by
  have hmap : (iidSamples (uniformIndexLaw N) M).map (fun ω => ω i) = uniformIndexLaw N :=
    (measurePreserving_eval (fun _ : Fin M => uniformIndexLaw N) i).map_eq
  have h := integral_map
    (μ := iidSamples (uniformIndexLaw N) M) (measurable_pi_apply i).aemeasurable
    (measurable_of_finite f).aestronglyMeasurable
  rw [hmap] at h
  exact h.symm

/-- Exact expectation of the row-mass and first/readout sums. -/
theorem iid_uniform_sum_integral (N M : ℕ) [NeZero N] (f : Fin N → ℝ) :
    (∫ ω, ∑ b, f (ω b) ∂iidSamples (uniformIndexLaw N) M) =
      ((M : ℝ) / N) * ∑ i, f i := by
  rw [integral_finsetSum Finset.univ (fun _ _ => Integrable.of_finite)]
  simp only [iid_uniform_eval_integral, uniformIndex_integral, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  ring

/-- Two entries from independent adjacent-layer lists form a uniform pair.
    No independence between different sampled matrix entries is asserted. -/
theorem iid_pair_eval_integral (N M : ℕ) [NeZero N] (a b : Fin M)
    (F : Fin N → Fin N → ℝ) :
    (∫ z, F (z.1 a) (z.2 b) ∂
      (iidSamples (uniformIndexLaw N) M).prod (iidSamples (uniformIndexLaw N) M)) =
      (∑ i, ∑ j, F i j) / (N : ℝ) ^ 2 := by
  rw [integral_prod _ Integrable.of_finite]
  calc
    _ = ∫ I, (∑ j, F (I a) j) / (N : ℝ) ∂iidSamples (uniformIndexLaw N) M := by
      apply integral_congr_ae
      apply ae_of_all
      intro I
      exact (iid_uniform_eval_integral N M b (F (I a))).trans (uniformIndex_integral N (F (I a)))
    _ = (∑ i, (∑ j, F i j) / (N : ℝ)) / (N : ℝ) := by
      exact (iid_uniform_eval_integral N M a (fun i => (∑ j, F i j) / (N : ℝ))).trans
        (uniformIndex_integral N (fun i => (∑ j, F i j) / (N : ℝ)))
    _ = _ := by rw [← Finset.sum_div, div_div, pow_two]

/-- Exact expectation of the sampled internal squared Frobenius norm. -/
theorem sampled_internal_squaredNorm_integral (N M : ℕ) [NeZero N]
    (hM : 0 < M) (A : Fin N → Fin N → ℝ) :
    (∫ z, ∑ a, ∑ b, (((N : ℝ) / M) * A (z.1 a) (z.2 b)) ^ 2 ∂
      (iidSamples (uniformIndexLaw N) M).prod (iidSamples (uniformIndexLaw N) M)) =
      ∑ i, ∑ j, A i j ^ 2 := by
  have hNR : (N : ℝ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  have hMR : (M : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hM)
  rw [integral_finsetSum Finset.univ (fun _ _ => Integrable.of_finite)]
  simp_rw [integral_finsetSum Finset.univ (fun _ _ => Integrable.of_finite)]
  have hi (a b : Fin M) := iid_pair_eval_integral N M a b (fun i j => (((N : ℝ) / M) * A i j) ^ 2)
  simp_rw [hi]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  simp_rw [mul_pow, ← Finset.mul_sum]
  field_simp [hNR, hMR]

/-- The actual independent list for every hidden layer. -/
def allLayerLists (N M r : ℕ) [NeZero N] :
    Measure (Fin (r + 1) → Fin M → Fin N) :=
  Measure.pi (fun _ : Fin (r + 1) => iidSamples (uniformIndexLaw N) M)

instance allLayerLists_probability (N M r : ℕ) [NeZero N] :
    IsProbabilityMeasure (allLayerLists N M r) := by
  unfold allLayerLists
  infer_instance

theorem layer_eval_integral (N M r : ℕ) [NeZero N] (s : Fin (r + 1))
    (F : (Fin M → Fin N) → ℝ) :
    (∫ I, F (I s) ∂allLayerLists N M r) =
      ∫ J, F J ∂iidSamples (uniformIndexLaw N) M := by
  have hmap : (allLayerLists N M r).map (fun I => I s) = iidSamples (uniformIndexLaw N) M :=
    (measurePreserving_eval
      (fun _ : Fin (r + 1) => iidSamples (uniformIndexLaw N) M) s).map_eq
  have h := integral_map (μ := allLayerLists N M r)
    (measurable_pi_apply s).aemeasurable (measurable_of_finite F).aestronglyMeasurable
  rw [hmap] at h
  exact h.symm

/-- Exact joint law of two distinct hidden-layer lists. -/
theorem layer_pair_map (N M r : ℕ) [NeZero N]
    (s t : Fin (r + 1)) (hst : s ≠ t) :
    (allLayerLists N M r).map (fun I => (I s, I t)) =
      (iidSamples (uniformIndexLaw N) M).prod (iidSamples (uniformIndexLaw N) M) := by
  have hindep : iIndepFun
      (fun j : Fin (r + 1) => fun I : Fin (r + 1) → Fin M → Fin N => I j)
      (allLayerLists N M r) := iIndepFun_pi (fun _ => aemeasurable_id)
  have hmap := (hindep.indepFun hst).map_prod_eq_prod_map_map
    (measurable_pi_apply s).aemeasurable (measurable_pi_apply t).aemeasurable
  have hs : (allLayerLists N M r).map (fun I => I s) = iidSamples (uniformIndexLaw N) M :=
    (measurePreserving_eval (fun _ : Fin (r + 1) => iidSamples (uniformIndexLaw N) M) s).map_eq
  have ht : (allLayerLists N M r).map (fun I => I t) = iidSamples (uniformIndexLaw N) M :=
    (measurePreserving_eval (fun _ : Fin (r + 1) => iidSamples (uniformIndexLaw N) M) t).map_eq
  rw [hs, ht] at hmap
  exact hmap

/-- The actual adjacent layer lists are independent, even though entries within
    the sampled matrix share indices. -/
theorem layer_pair_integral (N M r : ℕ) [NeZero N]
    (s t : Fin (r + 1)) (hst : s ≠ t)
    (F : (Fin M → Fin N) × (Fin M → Fin N) → ℝ) :
    (∫ I, F (I s, I t) ∂allLayerLists N M r) =
      ∫ z, F z ∂(iidSamples (uniformIndexLaw N) M).prod
        (iidSamples (uniformIndexLaw N) M) := by
  have hmap := layer_pair_map N M r s t hst
  have h := integral_map (μ := allLayerLists N M r)
    ((measurable_pi_apply s).prodMk (measurable_pi_apply t)).aemeasurable
    (measurable_of_finite F).aestronglyMeasurable
  rw [hmap] at h
  exact h.symm

/-- An event depending on one layer's list has exactly its marginal probability. -/
theorem layer_event_probability (N M r : ℕ) [NeZero N] (s : Fin (r + 1))
    (E : Set (Fin M → Fin N)) :
    (allLayerLists N M r).real ((fun I => I s) ⁻¹' E) =
      (iidSamples (uniformIndexLaw N) M).real E := by
  have hmap : (allLayerLists N M r).map (fun I => I s) = iidSamples (uniformIndexLaw N) M :=
    (measurePreserving_eval
      (fun _ : Fin (r + 1) => iidSamples (uniformIndexLaw N) M) s).map_eq
  have hset := Measure.map_apply (μ := allLayerLists N M r)
    (f := fun I : Fin (r + 1) → Fin M → Fin N => I s)
    (measurable_pi_apply s) (Set.toFinite E).measurableSet
  rw [hmap] at hset
  exact congrArg ENNReal.toReal hset.symm

/-- A finite union bound stated without any independence assumption. -/
theorem finite_failure_union_le {β : Type*} [Fintype β]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (E : β → Set Ω) {p : ℝ}
    (h : ∀ b, μ.real (E b) ≤ p) :
    μ.real (⋃ b, E b) ≤ (Fintype.card β : ℝ) * p := by
  calc
    _ ≤ ∑ b, μ.real (E b) := measureReal_iUnion_fintype_le E
    _ ≤ ∑ _b : β, p := Finset.sum_le_sum (fun b _ => h b)
    _ = _ := by simp


/-- The first-layer sampled squared norm has exactly the expected width factor. -/
theorem sampled_first_squaredNorm_integral {d N r M : ℕ} [NeZero N]
    (w : Weights d N r) :
    (∫ I, ∑ a, ∑ j, sampledWeights (M := M) w I (Sum.inl (a, j)) ^ 2
      ∂allLayerLists N M r) =
      ((M : ℝ) / N) * ∑ i, ∑ j, w (Sum.inl (i, j)) ^ 2 := by
  change (∫ I, (fun J : Fin M → Fin N =>
    ∑ a, ∑ j, w (Sum.inl (J a, j)) ^ 2) (I 0) ∂allLayerLists N M r) = _
  exact (layer_eval_integral N M r 0 (fun J => ∑ a, ∑ j, w (Sum.inl (J a,j)) ^ 2)).trans
    (iid_uniform_sum_integral N M (fun i => ∑ j, w (Sum.inl (i, j)) ^ 2))

/-- Each internal layer has exactly its original expected Frobenius cost. -/
theorem sampled_one_internal_squaredNorm_integral {d N r M : ℕ} [NeZero N]
    (hM : 0 < M) (w : Weights d N r) (s : Fin r) :
    (∫ I, ∑ a, ∑ b,
      sampledWeights (M := M) w I (Sum.inr (Sum.inl (s, a, b))) ^ 2
      ∂allLayerLists N M r) =
      ∑ i, ∑ j, w (Sum.inr (Sum.inl (s, i, j))) ^ 2 := by
  have hst : s.succ ≠ s.castSucc := by
    intro he
    have hv := congrArg Fin.val he
    simp only [Fin.val_succ, Fin.val_castSucc] at hv
    omega
  change (∫ I, (fun z : (Fin M → Fin N) × (Fin M → Fin N) =>
    ∑ a, ∑ b, (((N : ℝ) / M) *
      w (Sum.inr (Sum.inl (s, z.1 a, z.2 b)))) ^ 2)
    (I s.succ, I s.castSucc) ∂allLayerLists N M r) = _
  exact (layer_pair_integral N M r s.succ s.castSucc hst
    (fun z => ∑ a, ∑ b, (((N : ℝ) / M) * w (Sum.inr (Sum.inl (s,z.1 a,z.2 b)))) ^ 2)).trans
    (sampled_internal_squaredNorm_integral N M hM
      (fun i j => w (Sum.inr (Sum.inl (s, i, j)))))

/-- Exact readout expectation under the full independent layer-list law. -/
theorem sampled_readout_squaredNorm_integral {d N r M : ℕ} [NeZero N]
    (hM : 0 < M) (w : Weights d N r) :
    (∫ I, ∑ a, sampledWeights (M := M) w I (Sum.inr (Sum.inr a)) ^ 2
      ∂allLayerLists N M r) =
      ((N : ℝ) / M) * ∑ i, w (Sum.inr (Sum.inr i)) ^ 2 := by
  have hNR : (N : ℝ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  have hMR : (M : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hM)
  change (∫ I, (fun J : Fin M → Fin N =>
    ∑ a, (((N : ℝ) / M) * w (Sum.inr (Sum.inr (J a)))) ^ 2)
    (I (Fin.last r)) ∂allLayerLists N M r) = _
  rw [layer_eval_integral N M r (Fin.last r)
    (fun J => ∑ a, (((N : ℝ) / M) * w (Sum.inr (Sum.inr (J a)))) ^ 2),
    iid_uniform_sum_integral N M (fun i => (((N : ℝ) / M) * w (Sum.inr (Sum.inr i))) ^ 2)]
  simp_rw [mul_pow, ← Finset.mul_sum]
  field_simp [hNR, hMR]

/-- The complete sampled network has exactly the original expected weighted norm.
    This theorem uses the actual global list law and actual network arrays. -/
theorem sampled_weightedSquaredNorm_integral {d N r M : ℕ} [NeZero N]
    (hM : 0 < M) (w : Weights d N r) :
    (∫ I, weightedSquaredNorm (sampledWeights (M := M) w I) ∂allLayerLists N M r) =
      weightedSquaredNorm w := by
  have hNR : (N : ℝ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  have hMR : (M : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hM)
  unfold weightedSquaredNorm
  rw [integral_add Integrable.of_finite Integrable.of_finite,
    integral_add Integrable.of_finite Integrable.of_finite,
    integral_const_mul, integral_const_mul]
  rw [sampled_first_squaredNorm_integral, sampled_readout_squaredNorm_integral hM]
  rw [integral_finsetSum Finset.univ (fun _ _ => Integrable.of_finite)]
  simp_rw [sampled_one_internal_squaredNorm_integral hM]
  field_simp [hNR, hMR]

/-- Markov's event C for the actual sampled weighted cost. -/
theorem sampled_cost_tail {d N r M : ℕ} [NeZero N]
    (hM : 0 < M) (w : Weights d N r) {K : ℝ}
    (hK : 0 < K) (hw : weightedSquaredNorm w ≤ K) :
    (allLayerLists N M r).real
      {I | 4 * K ≤ weightedSquaredNorm (sampledWeights (M := M) w I)} ≤ 1 / 4 := by
  have hn (I : Fin (r + 1) → Fin M → Fin N) :
      0 ≤ weightedSquaredNorm (sampledWeights (M := M) w I) := by
    unfold weightedSquaredNorm
    positivity
  have h := mul_meas_ge_le_integral_of_nonneg
    (μ := allLayerLists N M r) (ae_of_all _ hn) Integrable.of_finite (4 * K)
  rw [sampled_weightedSquaredNorm_integral hM] at h
  have hb : (allLayerLists N M r).real
      {I | 4 * K ≤ weightedSquaredNorm (sampledWeights (M := M) w I)} ≤ K / (4 * K) := by
    apply (le_div_iff₀ (by positivity : 0 < 4 * K)).2
    nlinarith
  have he : K / (4 * K) = (1 : ℝ) / 4 := by field_simp [ne_of_gt hK]
  rwa [he] at hb

theorem retainedRowMass_integral {d N r M : ℕ} [NeZero N]
    (w : Weights d N r) :
    (∫ I, retainedRowMass (M := M) w I ∂allLayerLists N M r) =
      (M : ℝ) * (∑ s, ∑ i, ∑ j, w (Sum.inr (Sum.inl (s, i, j))) ^ 2) +
      (N : ℝ) * ∑ j, w (Sum.inr (Sum.inr j)) ^ 2 := by
  have hNR : (N : ℝ) ≠ 0 := by exact_mod_cast (NeZero.ne N)
  unfold retainedRowMass
  rw [integral_add Integrable.of_finite Integrable.of_finite, integral_const_mul,
    integral_finsetSum Finset.univ (fun _ _ => Integrable.of_finite)]
  have hi (s : Fin r) :
      (∫ I, ∑ a : Fin M, ∑ j : Fin N,
        w (Sum.inr (Sum.inl (s, I s.succ a, j))) ^ 2 ∂allLayerLists N M r) =
      ((M : ℝ) / N) * ∑ i, ∑ j, w (Sum.inr (Sum.inl (s, i, j))) ^ 2 := by
    change (∫ I, (fun J : Fin M → Fin N => ∑ a, ∑ j,
      w (Sum.inr (Sum.inl (s, J a, j))) ^ 2) (I s.succ) ∂allLayerLists N M r) = _
    exact (layer_eval_integral N M r s.succ (fun J => ∑ a, ∑ j,
      w (Sum.inr (Sum.inl (s,J a,j))) ^ 2)).trans
      (iid_uniform_sum_integral N M (fun i => ∑ j, w (Sum.inr (Sum.inl (s,i,j))) ^ 2))
  simp_rw [hi]
  simp only [integral_const, probReal_univ, one_smul]
  rw [← Finset.mul_sum]
  field_simp [hNR]

theorem retainedRowMass_integral_le {d N r M : ℕ} [NeZero N]
    (hM : 0 < M) (w : Weights d N r) {K : ℝ}
    (hw : weightedSquaredNorm w ≤ K) :
    (∫ I, retainedRowMass (M := M) w I ∂allLayerLists N M r) ≤ (M : ℝ) * K := by
  rw [retainedRowMass_integral]
  have hMR : (1 : ℝ) ≤ M := by exact_mod_cast hM
  have hf : 0 ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i, j)) ^ 2) := by positivity
  have ho : 0 ≤ (N : ℝ) * ∑ j, w (Sum.inr (Sum.inr j)) ^ 2 := by positivity
  have hom : (N : ℝ) * ∑ j, w (Sum.inr (Sum.inr j)) ^ 2 ≤
      (M : ℝ) * ((N : ℝ) * ∑ j, w (Sum.inr (Sum.inr j)) ^ 2) :=
    le_mul_of_one_le_left ho hMR
  unfold weightedSquaredNorm at hw
  nlinarith

/-- Event B's actual probability bound under the global independent list law. -/
theorem retainedRowMass_tail {d N r M : ℕ} [NeZero N]
    (hM : 0 < M) (w : Weights d N r) {K : ℝ}
    (hK : 0 < K) (hw : weightedSquaredNorm w ≤ K) :
    (allLayerLists N M r).real {I | 8 * (M : ℝ) * K ≤ retainedRowMass w I} ≤
      1 / 8 := by
  have hMR : 0 < (M : ℝ) := by exact_mod_cast hM
  have hn (I : Fin (r + 1) → Fin M → Fin N) : 0 ≤ retainedRowMass w I := by
    unfold retainedRowMass
    positivity
  have h := mul_meas_ge_le_integral_of_nonneg
    (μ := allLayerLists N M r) (ae_of_all _ hn) Integrable.of_finite
    (8 * (M : ℝ) * K)
  have he := retainedRowMass_integral_le hM w hw
  have hb : (allLayerLists N M r).real {I | 8 * (M : ℝ) * K ≤ retainedRowMass w I} ≤
      ((M : ℝ) * K) / (8 * (M : ℝ) * K) := by
    apply (le_div_iff₀ (by positivity : 0 < 8 * (M : ℝ) * K)).2
    nlinarith
  have hc : ((M : ℝ) * K) / (8 * (M : ℝ) * K) = (1 : ℝ) / 8 := by
    field_simp [ne_of_gt hMR, ne_of_gt hK]
  rwa [hc] at hb

/-- The three good events need not be independent. A strict union bound is enough
    to choose a deterministic collection of lists satisfying all of them. -/
theorem exists_outside_three_events {μ : Measure Ω} [IsProbabilityMeasure μ]
    (A B C : Set Ω) {a b c : ℝ}
    (hA : μ.real A ≤ a) (hB : μ.real B ≤ b) (hC : μ.real C ≤ c)
    (hsum : a + b + c < 1) :
    ∃ ω, ω ∉ A ∧ ω ∉ B ∧ ω ∉ C := by
  by_contra hnone
  have hcover : A ∪ B ∪ C = Set.univ := by
    ext ω
    simp only [Set.mem_union, Set.mem_univ, iff_true]
    by_contra h
    obtain ⟨hab, hc⟩ := not_or.mp h
    obtain ⟨ha, hb⟩ := not_or.mp hab
    exact hnone ⟨ω, ha, hb, hc⟩
  have hu1 := measureReal_union_le (μ := μ) A B
  have hu2 := measureReal_union_le (μ := μ) (A ∪ B) C
  rw [hcover] at hu2
  simp only [probReal_univ] at hu2
  linarith



end NeuralGeneralization.CompressionSampling
