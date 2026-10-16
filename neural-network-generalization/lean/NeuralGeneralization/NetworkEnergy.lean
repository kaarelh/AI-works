import NeuralGeneralization.Cloning
import Mathlib.Algebra.Order.Archimedean.Real.Basic

/-!
# Actual finite-network energy and its low-energy class

The infimum is taken over the actual strict-margin parameter event. Empty
classes are tracked explicitly. No attainment of an open-set infimum is
assumed: a separate theorem supplies actual near-optimal witnesses.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.ConcreteModel

/-- The finite-width energy attached to a Boolean sign function. The value on
an empty margin event is irrelevant; emptiness is always tracked separately. -/
def networkEnergy {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (g : BooleanFunction d) : ℝ :=
  sInf (weightedSquaredNorm '' marginEvent (N := N) (r := r) φ a g) / 2

theorem weightedSquaredNorm_image_bddBelow {d N r : ℕ} (V : Set (Weights d N r)) :
    BddBelow (weightedSquaredNorm '' V) := by
  refine ⟨0, ?_⟩
  rintro q ⟨w, _, rfl⟩
  exact weightedSquaredNorm_nonneg w

theorem networkEnergy_nonneg {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (g : BooleanFunction d) (hne : (marginEvent (N := N) (r := r) φ a g).Nonempty) :
    0 ≤ networkEnergy (N := N) (r := r) φ a g := by
  apply div_nonneg _ (by norm_num)
  apply le_csInf (hne.image weightedSquaredNorm)
  rintro q ⟨w, _, rfl⟩
  exact weightedSquaredNorm_nonneg w

theorem networkEnergy_le_of_mem {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (g : BooleanFunction d) (w : Weights d N r) (hw : w ∈ marginEvent φ a g) :
    networkEnergy (N := N) (r := r) φ a g ≤ weightedSquaredNorm w / 2 := by
  exact div_le_div_of_nonneg_right
    (csInf_le (weightedSquaredNorm_image_bddBelow _) ⟨w, hw, rfl⟩) (by norm_num)

/-- The teacher-energy upper bound is polynomial and independent of the
larger student width; the factor two from cloning cancels the rate's half. -/
theorem networkEnergy_le_complexity_polynomial {d C N r : ℕ} (φ : ℝ → ℝ)
    (f : BooleanFunction d) (hc : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) :
    networkEnergy (N := N) (r := r) φ (1 / 2) f ≤
      (d : ℝ) * (d + 1) * C ^ 2 + (r + 1) * C ^ 4 := by
  obtain ⟨w, hw, hcost⟩ := realizesAtComplexity_larger_width φ f hc hCN
  have he := networkEnergy_le_of_mem φ (1 / 2) f w hw
  linarith

/-- Exactly the representable functions whose energy is no larger than the
target's; the finite Gaussian-rate argument concentrates on this class. -/
def lowEnergyFunctions {d N r : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d) :
    Finset (BooleanFunction d) := by
  classical
  exact Finset.univ.filter fun g =>
    (marginEvent (N := N) (r := r) φ (1 / 2) g).Nonempty ∧
      networkEnergy (N := N) (r := r) φ (1 / 2) g ≤
        networkEnergy (N := N) (r := r) φ (1 / 2) f

theorem mem_lowEnergyFunctions {d N r : ℕ} (φ : ℝ → ℝ) (f g : BooleanFunction d) :
    g ∈ lowEnergyFunctions (N := N) (r := r) φ f ↔
      (marginEvent (N := N) (r := r) φ (1 / 2) g).Nonempty ∧
        networkEnergy (N := N) (r := r) φ (1 / 2) g ≤
          networkEnergy (N := N) (r := r) φ (1 / 2) f := by
  classical
  simp [lowEnergyFunctions]

/-- Strict margins need not attain their energy infimum. This supplies an
actual parameter witness at any positive excess energy instead. -/
theorem exists_nearoptimal_margin_network {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (g : BooleanFunction d)
    (hne : (marginEvent (N := N) (r := r) φ a g).Nonempty)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ w : Weights d N r, w ∈ marginEvent φ a g ∧
      weightedSquaredNorm w < 2 * networkEnergy (N := N) (r := r) φ a g + ε := by
  have hlt : sInf (weightedSquaredNorm '' marginEvent (N := N) (r := r) φ a g) <
      2 * networkEnergy (N := N) (r := r) φ a g + ε := by
    unfold networkEnergy
    linarith
  obtain ⟨q, ⟨w, hw, rfl⟩, hq⟩ :=
    exists_lt_of_csInf_lt (hne.image weightedSquaredNorm) hlt
  exact ⟨w, hw, hq⟩

/-- Every member of the actual low-energy class has an actual strict-margin
witness with polynomial weighted norm, uniformly over all widths above the
teacher complexity. The positive excess avoids assuming the infimum attained. -/
theorem lowEnergyFunctions_polynomial_norm_witness {d C N r : ℕ} (φ : ℝ → ℝ)
    (f g : BooleanFunction d) (hc : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) (hg : g ∈ lowEnergyFunctions (N := N) (r := r) φ f) :
    ∃ w : Weights d N r, w ∈ marginEvent φ (1 / 2) g ∧
      weightedSquaredNorm w <
        2 * ((d : ℝ) * (d + 1) * C ^ 2 + (r + 1) * C ^ 4) + 1 := by
  obtain ⟨hgNonempty, hgEnergy⟩ := (mem_lowEnergyFunctions φ f g).mp hg
  obtain ⟨w, hw, hcost⟩ := exists_nearoptimal_margin_network φ (1 / 2) g
    hgNonempty 1 zero_lt_one
  refine ⟨w, hw, ?_⟩
  have hteacher := networkEnergy_le_complexity_polynomial φ f hc hCN
  linarith


end NeuralGeneralization.ConcreteModel
