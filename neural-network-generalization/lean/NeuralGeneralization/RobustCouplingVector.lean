import NeuralGeneralization.RobustCouplingSequential
import Mathlib.Probability.Kernel.Disintegration.StandardBorel

/-!
# Measurable coordinatewise coupling of finite real vectors

The recursive product is only an encoding of a finite real vector. Each new
reference coordinate is independent of the entire coupled past. Thus the
mismatch cost sums conditional divergences, rather than applying Pinsker to
one whole vector.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set InformationTheory
open scoped ENNReal ProbabilityTheory
namespace NeuralGeneralization.RobustCoupling

/-- Left-associated finite real vectors. -/
abbrev RealPrefix : ℕ → Type
  | 0 => Unit
  | n + 1 => RealPrefix n × ℝ

instance realPrefixMeasurable : (n : ℕ) → MeasurableSpace (RealPrefix n)
  | 0 => inferInstanceAs (MeasurableSpace Unit)
  | n + 1 => letI := realPrefixMeasurable n
             inferInstanceAs (MeasurableSpace (RealPrefix n × ℝ))

instance realPrefixNonempty : (n : ℕ) → Nonempty (RealPrefix n)
  | 0 => inferInstanceAs (Nonempty Unit)
  | n + 1 => letI := realPrefixNonempty n
             inferInstanceAs (Nonempty (RealPrefix n × ℝ))

instance realPrefixStandardBorel : (n : ℕ) → StandardBorelSpace (RealPrefix n)
  | 0 => inferInstanceAs (StandardBorelSpace Unit)
  | n + 1 => letI := realPrefixStandardBorel n
             inferInstanceAs (StandardBorelSpace (RealPrefix n × ℝ))

def referencePrefix (G : Measure ℝ) : (n : ℕ) → Measure (RealPrefix n)
  | 0 => Measure.dirac ()
  | n + 1 => (referencePrefix G n).prod G

instance referencePrefix_probability (G : Measure ℝ) [IsProbabilityMeasure G] :
    (n : ℕ) → IsProbabilityMeasure (referencePrefix G n)
  | 0 => by unfold referencePrefix; infer_instance
  | n + 1 => by
    letI := referencePrefix_probability G n
    change IsProbabilityMeasure ((referencePrefix G n).prod G)
    infer_instance

def mismatchCount : (n : ℕ) → RealPrefix n × RealPrefix n → ℝ≥0∞
  | 0, _ => 0
  | n + 1, p => mismatchCount n (p.1.1, p.2.1) + scalarMismatch (p.1.2, p.2.2)

@[fun_prop] theorem measurable_mismatchCount (n : ℕ) : Measurable (mismatchCount n) := by
  induction n with
  | zero => exact measurable_const
  | succ n ih =>
    exact (ih.comp (measurable_fst.fst.prodMk measurable_snd.fst)).add
      (measurable_scalarMismatch.comp (measurable_fst.snd.prodMk measurable_snd.snd))

variable {Θ : Type*} [MeasurableSpace Θ]

/-- Construction together with the Markov property, to make the recursive
construction available at every parameter, including infinite-divergence ones. -/
def prefixCouplingData (G : Measure ℝ) [IsProbabilityMeasure G] :
    (n : ℕ) → (P : Kernel Θ (RealPrefix n)) → [IsMarkovKernel P] →
    {K : Kernel Θ (RealPrefix n × RealPrefix n) // IsMarkovKernel K}
  | 0, P, _ => ⟨P.map (fun x => (x, x)), by
      apply Kernel.IsMarkovKernel.map
      fun_prop⟩
  | n + 1, P, hP =>
    letI := hP
    let prev := prefixCouplingData G n P.fst
    letI := prev.property
    ⟨appendCouplingKernel prev.val P.condKernel G, inferInstance⟩

def prefixCouplingKernel (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (RealPrefix n)) [IsMarkovKernel P] :
    Kernel Θ (RealPrefix n × RealPrefix n) := (prefixCouplingData G n P).val

instance prefixCouplingKernel_markov (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (RealPrefix n)) [IsMarkovKernel P] :
    IsMarkovKernel (prefixCouplingKernel G n P) := (prefixCouplingData G n P).property

theorem prefixCouplingKernel_zero (G : Measure ℝ) [IsProbabilityMeasure G]
    (P : Kernel Θ (RealPrefix 0)) [IsMarkovKernel P] :
    prefixCouplingKernel G 0 P = P.map (fun x => (x, x)) := rfl

theorem prefixCouplingKernel_succ (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (RealPrefix (n + 1))) [IsMarkovKernel P] :
    prefixCouplingKernel G (n + 1) P =
      appendCouplingKernel (prefixCouplingKernel G n P.fst) P.condKernel G := rfl

theorem prefixCouplingKernel_fst (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (RealPrefix n)) [IsMarkovKernel P] (θ : Θ) :
    (prefixCouplingKernel G n P θ).map Prod.fst = P θ := by
  induction n with
  | zero =>
    rw [prefixCouplingKernel_zero, Kernel.map_apply _ (by fun_prop),
      Measure.map_map measurable_fst (by fun_prop)]
    exact Measure.map_id
  | succ n ih =>
    rw [prefixCouplingKernel_succ, appendCouplingKernel_apply, appendCoupling_fst, ih]
    rw [← Kernel.compProd_apply_eq_compProd_sectR, Kernel.disintegrate]

theorem probability_unit_eq_dirac (μ : Measure Unit) [IsProbabilityMeasure μ] :
    μ = Measure.dirac () := by
  ext s hs
  by_cases h : () ∈ s
  · have heq : s = univ := Set.eq_univ_iff_forall.mpr (fun x => by cases x; exact h)
    simp [heq]
  · have heq : s = ∅ := Set.eq_empty_iff_forall_notMem.mpr (fun x => by cases x; exact h)
    simp [heq]

theorem prefixCouplingKernel_snd (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (RealPrefix n)) [IsMarkovKernel P] (θ : Θ) :
    (prefixCouplingKernel G n P θ).map Prod.snd = referencePrefix G n := by
  induction n with
  | zero =>
    rw [prefixCouplingKernel_zero, Kernel.map_apply _ (by fun_prop),
      Measure.map_map measurable_snd (by fun_prop)]
    change (P θ).map id = Measure.dirac ()
    rw [Measure.map_id]
    exact probability_unit_eq_dirac _
  | succ n ih =>
    rw [prefixCouplingKernel_succ, appendCouplingKernel_apply, appendCoupling_snd, ih]
    rfl

/-- The actual KL chain rule for the recursive reference product. -/
theorem klDiv_prefix_succ (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (RealPrefix (n + 1))) [IsMarkovKernel P] (θ : Θ) :
    klDiv (P θ) (referencePrefix G (n + 1)) =
      klDiv (P.fst θ) (referencePrefix G n) +
        ∫⁻ a, klDiv (P.condKernel (θ, a)) G ∂P.fst θ := by
  have hd : (P.fst θ) ⊗ₘ (P.condKernel.sectR θ) = P θ := by
    rw [← Kernel.compProd_apply_eq_compProd_sectR, Kernel.disintegrate]
  rw [← hd, referencePrefix, ← Measure.compProd_const,
    klDiv_compProd_eq_add,
    NeuralGeneralization.RobustEntropy.klDiv_compProd_same_left_eq_lintegral]
  rfl

/-- Sequential Pinsker: the expected number of unequal coordinates is at most
KL/s + n*s. This is a measurable kernel, with exact left law P and iid right law G. -/
theorem prefixCouplingKernel_mismatch_le (G : Measure ℝ) [IsProbabilityMeasure G]
    (n : ℕ) (P : Kernel Θ (RealPrefix n)) [IsMarkovKernel P] (θ : Θ)
    {s : ℝ} (hs : 0 < s) :
    (∫⁻ p, mismatchCount n p ∂prefixCouplingKernel G n P θ) ≤
      ENNReal.ofReal (1 / s) * klDiv (P θ) (referencePrefix G n) + n * ENNReal.ofReal s := by
  induction n with
  | zero => simp [mismatchCount]
  | succ n ih =>
    rw [prefixCouplingKernel_succ, appendCouplingKernel_apply]
    have hh := lintegral_appendCoupling_cost_le
      (prefixCouplingKernel G n P.fst θ) (P.condKernel.sectR θ) G
      (mismatchCount n) (measurable_mismatchCount n) hs
    change (∫⁻ p, mismatchCount (n + 1) p ∂appendCoupling
      (prefixCouplingKernel G n P.fst θ) (P.condKernel.sectR θ) G) ≤ _ at hh
    rw [prefixCouplingKernel_fst] at hh
    refine hh.trans ?_
    calc
      _ ≤ (ENNReal.ofReal (1 / s) * klDiv (P.fst θ) (referencePrefix G n) +
            n * ENNReal.ofReal s) + ENNReal.ofReal (1 / s) *
          (∫⁻ a, klDiv (P.condKernel (θ, a)) G ∂P.fst θ) + ENNReal.ofReal s :=
        add_le_add (add_le_add (ih P.fst) le_rfl) le_rfl
      _ = _ := by rw [klDiv_prefix_succ]; push_cast; ring

end NeuralGeneralization.RobustCoupling
