import NeuralGeneralization.SpectralTruncation
import NeuralGeneralization.MatrixActionBound
import NeuralGeneralization.CapacityBound
import NeuralGeneralization.PolynomialGrowth
import NeuralGeneralization.FunctionPriorFacts

/-!
# The actual finite function class supplied by spectral truncation

The class below depends only on the input dimension, depth and energy budget.
Every strict-margin network with bounded first/readout energies and an actual
small-operator-norm internal remainder represents a member of this class.
Consequently its complement has at most the actual parameter mass of failure
of those matrix bounds. No capacity or tail certificate is assumed.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory

namespace NeuralGeneralization.ConcreteModel
open NeuralGeneralization.CompressionSampling

/-- Width of the common compressed representative of a spectrally good network. -/
def spectralCompressionWidth (d r K : ℕ) : ℕ :=
  compressionWidth d r (9 * (r + 2) * K)

/-- A width-independent finite class of actual globally strict-margin functions. -/
def spectralFunctions (d r K : ℕ) (φ : ℝ → ℝ) : Finset (BooleanFunction d) := by
  classical
  exact Finset.univ.filter fun f =>
    ∃ v : Weights d (spectralCompressionWidth d r K) r,
      v ∈ marginEvent φ (1 / 2) f ∧ boundedWeights (spectralCompressionWidth d r K) v

@[simp] theorem mem_spectralFunctions {d r K : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d) :
    f ∈ spectralFunctions d r K φ ↔
      ∃ v : Weights d (spectralCompressionWidth d r K) r,
        v ∈ marginEvent φ (1 / 2) f ∧ boundedWeights (spectralCompressionWidth d r K) v := by
  classical
  simp [spectralFunctions]

def spectralCapacity (d r K : ℕ) : ℕ :=
  parameterCapacityExponent d (spectralCompressionWidth d r K) r
    (spectralCompressionWidth d r K)

theorem spectralFunctions_card_le_exp (d r K : ℕ)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) :
    ((spectralFunctions d r K φ).card : ℝ) ≤ Real.exp (spectralCapacity d r K : ℝ) := by
  exact representedClass_card_le_exp (spectralFunctions d r K φ)
    (spectralCompressionWidth d r K) r (spectralCompressionWidth d r K) φ hφ
    (fun f hf => (mem_spectralFunctions φ f).mp hf)

/-- The class entropy is polynomial in dimension and energy at fixed depth. -/
theorem spectralCapacity_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d K => spectralCapacity d r K) := by
  have hK : PolynomialGrowth2 (fun _ K => 9 * (r + 2) * K) :=
    (PolynomialGrowth2.const (9 * (r + 2))).mul PolynomialGrowth2.right
  have hQ : PolynomialGrowth2 (fun _ K => compressionQ r (9 * (r + 2) * K)) := by
    unfold compressionQ
    exact ((PolynomialGrowth2.const 24).mul (PolynomialGrowth2.const (r + 1))).mul
      (((PolynomialGrowth2.const 4).mul hK).pow (r + 1))
  have hM : PolynomialGrowth2 (fun d K => spectralCompressionWidth d r K) := by
    unfold spectralCompressionWidth compressionWidth
    exact ((((PolynomialGrowth2.const 65536).mul (PolynomialGrowth2.const (r + 1))).mul
      (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).mul (hQ.pow 8)).add
        ((PolynomialGrowth2.const 9).mul hK)
  have hdim : PolynomialGrowth2 (fun d K =>
      spectralCompressionWidth d r K * (d + 1) +
      r * (spectralCompressionWidth d r K * spectralCompressionWidth d r K) +
      spectralCompressionWidth d r K) :=
    ((hM.mul (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).add
      ((PolynomialGrowth2.const r).mul (hM.mul hM))).add hM
  have hmesh : PolynomialGrowth2 (fun d K => (d + 1) *
      (spectralCompressionWidth d r K * (spectralCompressionWidth d r K + 1) + 1) ^ (r + 1)) :=
    (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)).mul
      (((hM.mul (hM.add (PolynomialGrowth2.const 1))).add
        (PolynomialGrowth2.const 1)).pow (r + 1))
  simpa only [spectralCapacity, parameterCapacityExponent_eq] using
    hdim.mul (((PolynomialGrowth2.const 2).mul (hM.mul hmesh)).add (PolynomialGrowth2.const 1))

/-- Actual parameter inequalities sufficient for spectral compression. -/
def goodSpectralWeights (d N r K : ℕ) : Set (Weights d N r) :=
  {w | (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2) ≤ (K : ℝ) ∧
    (N : ℝ) * (∑ i, w (Sum.inr (Sum.inr i)) ^ 2) ≤ (K : ℝ) ∧
    ∀ s : Fin r, ∃ H : Fin N × Fin N → ℝ,
      LowRankGrid.squaredSum H ≤ (K : ℝ) ∧
      ‖matrixOperator (fun ij => w (Sum.inr (Sum.inl (s,ij.1,ij.2)))) - matrixOperator H‖ ≤
        spectralTruncationRadius r K}

/-- The same parameter event at any specified operator-remainder scale. -/
def goodSpectralWeightsAtRadius (d N r K : ℕ) (a : ℝ) : Set (Weights d N r) :=
  {w | (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2) ≤ (K : ℝ) ∧
    (N : ℝ) * (∑ i, w (Sum.inr (Sum.inr i)) ^ 2) ≤ (K : ℝ) ∧
    ∀ s : Fin r, ∃ H : Fin N × Fin N → ℝ,
      LowRankGrid.squaredSum H ≤ (K : ℝ) ∧
      ‖matrixOperator (fun ij => w (Sum.inr (Sum.inl (s,ij.1,ij.2)))) - matrixOperator H‖ ≤ a}

theorem goodSpectralWeightsAtRadius_subset {d N r K : ℕ} {a : ℝ}
    (ha : a ≤ spectralTruncationRadius r K) :
    goodSpectralWeightsAtRadius d N r K a ⊆ goodSpectralWeights d N r K := by
  rintro w ⟨hfirst,hread,hmat⟩
  refine ⟨hfirst,hread,fun s => ?_⟩
  obtain ⟨H,hH,hres⟩ := hmat s
  exact ⟨H,hH,hres.trans ha⟩

/-- Spectral truncation and norm compression identify the exact function class. -/
theorem mem_spectralFunctions_of_goodSpectralWeights {d N r K : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (w : Weights d N r) (hw : w ∈ marginEvent φ (1 / 2) f)
    (hgood : w ∈ goodSpectralWeights d N r K) :
    f ∈ spectralFunctions d r K φ := by
  classical
  obtain ⟨hfirst, hread, hmat⟩ := hgood
  choose H hH hres using hmat
  apply (mem_spectralFunctions φ f).mpr
  exact spectral_truncation_compressed hd hN hK φ hφ f w hw
    (fun s i j => H s (i,j)) hfirst hread
    (fun s => by simpa only [LowRankGrid.squaredSum, Fintype.sum_prod_type] using hH s)
    (fun s x => matrix_residual_action_bound _ (H s) _
      (spectralTruncationRadius_pos r (Nat.cast_nonneg K)).le (hres s) x)

/-- The aggregate mass of all excluded functions is controlled by the actual
failure event in parameter space. This is valid even if the existential
operator-approximation event is not separately shown measurable. -/
theorem spectralFunctions_complement_mass_le {d N r K : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ] :
    (∑ f ∈ Finset.univ \ spectralFunctions d r K φ, functionMass φ (1 / 2) μ f) ≤
      μ.real (goodSpectralWeights d N r K)ᶜ := by
  classical
  let A := Finset.univ \ spectralFunctions d r K φ
  have heq : μ.real (⋃ f ∈ A, marginEvent φ (1 / 2) f) =
      ∑ f ∈ A, functionMass φ (1 / 2) μ f := by
    exact measureReal_biUnion_finset
      (fun f hf g hg hfg => marginEvents_disjoint φ (by norm_num) hfg)
      (fun f hf => (isOpen_marginEvent (admissibleActivation_continuous hφ) (1 / 2) f).measurableSet)
  rw [← heq]
  apply measureReal_mono _ (measure_ne_top μ _)
  intro w hw hgood
  obtain ⟨f, hf, hwf⟩ := Set.mem_iUnion₂.mp hw
  have hnot : f ∉ spectralFunctions d r K φ := (Finset.mem_sdiff.mp hf).2
  exact hnot (mem_spectralFunctions_of_goodSpectralWeights hd hN hK φ hφ f w hwf hgood)

/-- Variable-radius version for the decaying remainder supplied by Gaussian
matrix bounds in the strictly above-mean-field regime. -/
theorem spectralFunctions_complement_mass_le_radius {d N r K : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (a : ℝ) (ha : a ≤ spectralTruncationRadius r K) :
    (∑ f ∈ Finset.univ \ spectralFunctions d r K φ, functionMass φ (1 / 2) μ f) ≤
      μ.real (goodSpectralWeightsAtRadius d N r K a)ᶜ := by
  exact (spectralFunctions_complement_mass_le hd hN hK φ hφ μ).trans
    (measureReal_mono (Set.compl_subset_compl.mpr (goodSpectralWeightsAtRadius_subset ha))
      (measure_ne_top μ _))

end NeuralGeneralization.ConcreteModel
