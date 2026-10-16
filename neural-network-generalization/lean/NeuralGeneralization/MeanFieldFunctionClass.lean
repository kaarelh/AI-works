import NeuralGeneralization.MeanFieldBudgets
import NeuralGeneralization.TowerSamplingBudget
import NeuralGeneralization.CapacityBound
import NeuralGeneralization.FunctionPriorFacts

/-!
# A width-independent finite class for the mean-field argument

The class consists of actual bounded-weight tanh networks. Its explicit width
and weight bound are the polynomial choices in the finite tilted-tower
construction, using the proved backward budgets.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory
namespace NeuralGeneralization.MeanFieldFunctionClass
open ConcreteModel MeanFieldBudgets

def compressedWidth (d r K : ℕ) : ℕ :=
  TowerSamplingBudget.width d (towerPrecision r K)

def compressedBound (d r K : ℕ) : ℕ :=
  TowerSamplingBudget.rowBound d (towerPrecision r K) (maxTiltBudget r K)+4*K

def functions (d r K : ℕ) : Finset (BooleanFunction d) := by
  classical
  exact Finset.univ.filter fun f => ∃ w : Weights d (compressedWidth d r K) r,
    w ∈ marginEvent Real.tanh (1/2) f ∧ boundedWeights (compressedBound d r K) w

@[simp] theorem mem_functions {d r K : ℕ} (f : BooleanFunction d) :
    f ∈ functions d r K ↔ ∃ w : Weights d (compressedWidth d r K) r,
      w ∈ marginEvent Real.tanh (1/2) f ∧ boundedWeights (compressedBound d r K) w := by
  classical
  simp [functions]

def capacity (d r K : ℕ) : ℕ :=
  parameterCapacityExponent d (compressedWidth d r K) r (compressedBound d r K)

theorem functions_card_le_exp (d r K : ℕ) :
    ((functions d r K).card : ℝ) ≤ Real.exp (capacity d r K : ℝ) := by
  exact representedClass_card_le_exp (functions d r K) (compressedWidth d r K) r
    (compressedBound d r K) Real.tanh tanh_admissible
    (fun f hf => (mem_functions f).mp hf)

theorem compressedWidth_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d K => compressedWidth d r K) := by
  unfold compressedWidth TowerSamplingBudget.width
  exact ((PolynomialGrowth2.const 32).mul ((towerPrecision_polynomialGrowth r).pow 2)).mul
    (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))

theorem compressedBound_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d K => compressedBound d r K) := by
  unfold compressedBound TowerSamplingBudget.rowBound
  exact ((PolynomialGrowth2.const 32).mul
    (((maxTiltBudget_polynomialGrowth r).add
      ((compressedWidth_polynomialGrowth r).mul
        ((PolynomialGrowth2.left.add (compressedWidth_polynomialGrowth r)).add
          (PolynomialGrowth2.const 1)))).add (PolynomialGrowth2.const 1))).add
    ((PolynomialGrowth2.const 4).mul PolynomialGrowth2.right)

/-- Exact polynomial growth of the logarithmic cardinality bound at each depth. -/
theorem capacity_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d K => capacity d r K) := by
  have hN := compressedWidth_polynomialGrowth r
  have hB := compressedBound_polynomialGrowth r
  have hdim : PolynomialGrowth2 (fun d K =>
      compressedWidth d r K*(d+1)+r*(compressedWidth d r K*compressedWidth d r K)+
      compressedWidth d r K) :=
    ((hN.mul (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).add
      ((PolynomialGrowth2.const r).mul (hN.mul hN))).add hN
  have hmesh : PolynomialGrowth2 (fun d K =>
      (d+1)*(compressedWidth d r K*(compressedBound d r K+1)+1)^(r+1)) :=
    (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)).mul
      (((hN.mul (hB.add (PolynomialGrowth2.const 1))).add
        (PolynomialGrowth2.const 1)).pow (r+1))
  simpa only [capacity, parameterCapacityExponent_eq] using
    hdim.mul (((PolynomialGrowth2.const 2).mul (hB.mul hmesh)).add (PolynomialGrowth2.const 1))

/-- Once actual good draws have the displayed finite representatives, their
excluded function masses are bounded by the actual exceptional parameter mass.
The statement uses outer measure and needs no extra measurability assumption. -/
theorem complement_mass_le {d N r K : ℕ}
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ] (E : Set (Weights d N r))
    (hrep : ∀ f : BooleanFunction d, ∀ w : Weights d N r,
      w ∈ marginEvent Real.tanh (1/2) f → w ∈ E →
      ∃ v : Weights d (compressedWidth d r K) r,
        v ∈ marginEvent Real.tanh (1/2) f ∧ boundedWeights (compressedBound d r K) v) :
    (∑ f ∈ Finset.univ \ functions d r K, functionMass Real.tanh (1/2) μ f) ≤ μ.real Eᶜ := by
  classical
  let A := Finset.univ \ functions d r K
  have heq : μ.real (⋃ f ∈ A, marginEvent Real.tanh (1/2) f) =
      ∑ f ∈ A, functionMass Real.tanh (1/2) μ f := by
    exact measureReal_biUnion_finset
      (fun f hf g hg hfg => marginEvents_disjoint Real.tanh (by norm_num) hfg)
      (fun f hf => (isOpen_marginEvent tanh_continuous (1/2) f).measurableSet)
  rw [← heq]
  apply measureReal_mono _ (measure_ne_top μ _)
  intro w hw hgood
  obtain ⟨f,hf,hwf⟩ := Set.mem_iUnion₂.mp hw
  exact (Finset.mem_sdiff.mp hf).2 ((mem_functions f).mpr (hrep f w hwf hgood))

end NeuralGeneralization.MeanFieldFunctionClass
