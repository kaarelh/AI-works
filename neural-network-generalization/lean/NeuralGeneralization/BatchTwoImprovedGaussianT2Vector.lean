import NeuralGeneralization.BatchTwoImprovedGaussianT2Sequential
import NeuralGeneralization.RobustCouplingVector

/-! # Dimension-free Gaussian T2 for measurable finite-vector kernels -/
noncomputable section
open MeasureTheory ProbabilityTheory Set InformationTheory
open scoped ENNReal ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedGaussianTransport
open RobustCoupling (RealPrefix referencePrefix probability_unit_eq_dirac)

def squaredCost : (n : ℕ) → RealPrefix n × RealPrefix n → ℝ≥0∞
  | 0, _ => 0
  | n + 1, p => squaredCost n (p.1.1, p.2.1) + scalarSquaredCost (p.1.2, p.2.2)

@[fun_prop] theorem measurable_squaredCost (n : ℕ) : Measurable (squaredCost n) := by
  induction n with
  | zero => exact measurable_const
  | succ n ih =>
    exact (ih.comp (measurable_fst.fst.prodMk measurable_snd.fst)).add
      (measurable_scalarSquaredCost.comp (measurable_fst.snd.prodMk measurable_snd.snd))

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

/-- Squared Euclidean transport cost is at most twice the full relative
entropy. All conditional costs are summed by the exact entropy chain rule. -/
theorem prefixCouplingKernel_squared_le
    (n : ℕ) (P : Kernel Θ (RealPrefix n)) [IsMarkovKernel P] (θ : Θ) :
    (∫⁻ p, squaredCost n p ∂prefixCouplingKernel (gaussianReal 0 1) n P θ) ≤
      2 * klDiv (P θ) (referencePrefix (gaussianReal 0 1) n) := by
  induction n with
  | zero => simp [squaredCost]
  | succ n ih =>
    rw [prefixCouplingKernel_succ, appendCouplingKernel_apply]
    have hh := lintegral_appendCoupling_cost_le
      (prefixCouplingKernel (gaussianReal 0 1) n P.fst θ) (P.condKernel.sectR θ)
      (squaredCost n) (measurable_squaredCost n)
    change (∫⁻ p, squaredCost (n + 1) p ∂appendCoupling
      (prefixCouplingKernel (gaussianReal 0 1) n P.fst θ)
      (P.condKernel.sectR θ) (gaussianReal 0 1)) ≤ _ at hh
    rw [prefixCouplingKernel_fst] at hh
    refine hh.trans ?_
    calc
      _ ≤ 2 * klDiv (P.fst θ) (referencePrefix (gaussianReal 0 1) n) +
          2 * (∫⁻ a, klDiv (P.condKernel (θ, a)) (gaussianReal 0 1) ∂P.fst θ) :=
        add_le_add (ih P.fst) le_rfl
      _ = _ := by rw [RobustCoupling.klDiv_prefix_succ, mul_add]

end NeuralGeneralization.BatchTwoImprovedGaussianTransport
