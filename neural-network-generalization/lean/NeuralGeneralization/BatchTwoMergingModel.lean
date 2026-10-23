import NeuralGeneralization.RobustPosterior
import Mathlib.Data.Fintype.Sigma

/-!
# Population merging and the actual restricted Gaussian posterior

This file defines the support restriction in the ReLU/GELU polynomial-depth
paper.  A population is a nonempty fibre of a surjective labelling map.  The
restriction quantifies over genuine partitions of the learner's neurons;
its averaging maps act on the actual finite Gaussian network weights.

The energy inequality is written separately for each layer and input.  For
nonempty layers this is equivalent to the paper's inequality
`(max_s q_s - 1) * (max_x |z(x)|)^2 ≤ 4 * E_v`.

No target-mass or compression assumption is made in the definitions.
-/

noncomputable section

open MeasureTheory ProbabilityTheory
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoMerging

open ConcreteModel

/-- A partition of `N` neurons into nonempty labelled populations. -/
def PopulationPartition (N : ℕ) :=
  {p : Σ q : Fin (N + 1), Fin N → Fin q.val // Function.Surjective p.2}

instance (N : ℕ) : Fintype (PopulationPartition N) := by
  unfold PopulationPartition
  infer_instance

def populationCount {N : ℕ} (p : PopulationPartition N) : ℕ := p.val.1.val

def populationLabel {N : ℕ} (p : PopulationPartition N) :
    Fin N → Fin (populationCount p) := p.val.2

theorem populationLabel_surjective {N : ℕ} (p : PopulationPartition N) :
    Function.Surjective (populationLabel p) := p.property

theorem populationCount_le {N : ℕ} (p : PopulationPartition N) :
    populationCount p ≤ N := Nat.le_of_lt_succ p.val.1.isLt

theorem populationCount_pos {N : ℕ} (hN : 0 < N) (p : PopulationPartition N) :
    0 < populationCount p :=
  (Nat.zero_le _).trans_lt (populationLabel p ⟨0, hN⟩).isLt

def populationMembers {N : ℕ} (p : PopulationPartition N)
    (a : Fin (populationCount p)) : Finset (Fin N) :=
  Finset.univ.filter (fun i => populationLabel p i = a)

@[simp] theorem mem_populationMembers {N : ℕ} (p : PopulationPartition N)
    (a : Fin (populationCount p)) (i : Fin N) :
    i ∈ populationMembers p a ↔ populationLabel p i = a := by
  simp [populationMembers]

theorem populationMembers_nonempty {N : ℕ} (p : PopulationPartition N)
    (a : Fin (populationCount p)) : (populationMembers p a).Nonempty := by
  obtain ⟨i, hi⟩ := populationLabel_surjective p a
  exact ⟨i, (mem_populationMembers p a i).mpr hi⟩

theorem populationMembers_card_pos {N : ℕ} (p : PopulationPartition N)
    (a : Fin (populationCount p)) : 0 < (populationMembers p a).card :=
  Finset.card_pos.mpr (populationMembers_nonempty p a)

/-- The matrix of orthogonal population averaging. -/
def populationProjection {N : ℕ} (p : PopulationPartition N)
    (i j : Fin N) : ℝ :=
  if populationLabel p i = populationLabel p j then
    ((populationMembers p (populationLabel p i)).card : ℝ)⁻¹ else 0

theorem populationProjection_nonneg {N : ℕ} (p : PopulationPartition N)
    (i j : Fin N) : 0 ≤ populationProjection p i j := by
  unfold populationProjection
  split_ifs <;> positivity

theorem populationProjection_symm {N : ℕ} (p : PopulationPartition N)
    (i j : Fin N) : populationProjection p i j = populationProjection p j i := by
  unfold populationProjection
  by_cases h : populationLabel p i = populationLabel p j
  · simp [h]
  · simp [h, Ne.symm h]

def populationAverage {N : ℕ} (p : PopulationPartition N)
    (h : Fin N → ℝ) : Fin N → ℝ :=
  fun i => ∑ j, populationProjection p i j * h j

/-- One partition for each of the `r+1` hidden layers. -/
abbrev LayerPartitions (N r : ℕ) := Fin (r + 1) → PopulationPartition N

/-- `P₁W₁`, `PₛWₛPₛ₋₁`, and `P_H v`, in the original finite-width architecture. -/
def mergedWeights {d N r : ℕ} (p : LayerPartitions N r)
    (w : Weights d N r) : Weights d N r
  | Sum.inl (i, j) => ∑ k, populationProjection (p 0) i k * w (Sum.inl (k, j))
  | Sum.inr (Sum.inl (s, i, j)) =>
      ∑ k, ∑ l, populationProjection (p s.succ) i k *
        w (Sum.inr (Sum.inl (s, k, l))) * populationProjection (p s.castSucc) l j
  | Sum.inr (Sum.inr i) =>
      ∑ j, populationProjection (p (Fin.last r)) i j * w (Sum.inr (Sum.inr j))

theorem continuous_mergedWeights {d N r : ℕ} (p : LayerPartitions N r) :
    Continuous (mergedWeights (d := d) p) := by
  apply continuous_pi
  intro a
  cases a with
  | inl a =>
      rcases a with ⟨i, j⟩
      exact continuous_finsetSum _ fun k _ =>
        continuous_const.mul (continuous_apply (Sum.inl (k, j)))
  | inr a =>
      cases a with
      | inl a =>
          rcases a with ⟨s, i, j⟩
          exact continuous_finsetSum _ fun k _ => continuous_finsetSum _ fun l _ =>
            (continuous_const.mul
              (continuous_apply (Sum.inr (Sum.inl (s, k, l))))).mul continuous_const
      | inr i =>
          exact continuous_finsetSum _ fun j _ =>
            continuous_const.mul (continuous_apply (Sum.inr (Sum.inr j)))

/-- The paper's two conditions for a fixed tuple of partitions. -/
def partitionSupport {d N r : ℕ} (φ : ℝ → ℝ) (p : LayerPartitions N r) :
    Set (Weights d N r) :=
  {w | (∀ (s : Fin (r + 1)) (x : Cube d),
      ((populationCount (p s) : ℝ) - 1) * (networkOutput φ w x) ^ 2 ≤
        4 * readoutEnergy w) ∧
    ∀ x : Cube d,
      |clippedScore (networkOutput φ w x) -
        clippedScore (networkOutput φ (mergedWeights p w) x)| ≤ (1 / 16 : ℝ)}

/-- The population-merging restriction is existential over actual partitions. -/
def mergingSupport {d N r : ℕ} (φ : ℝ → ℝ) : Set (Weights d N r) :=
  ⋃ p : LayerPartitions N r, partitionSupport φ p

theorem isClosed_partitionSupport {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (p : LayerPartitions N r) :
    IsClosed (partitionSupport (d := d) φ p) := by
  unfold partitionSupport
  simp only [Set.setOf_and, Set.setOf_forall]
  apply IsClosed.inter
  · apply isClosed_iInter
    intro s
    apply isClosed_iInter
    intro x
    exact isClosed_le
      (continuous_const.mul ((continuous_networkOutput hφ x).pow 2))
      (continuous_const.mul continuous_readoutEnergy)
  · apply isClosed_iInter
    intro x
    apply isClosed_le _ continuous_const
    apply Continuous.abs
    exact (continuous_clippedScore.comp (continuous_networkOutput hφ x)).sub
      (continuous_clippedScore.comp
        ((continuous_networkOutput hφ x).comp (continuous_mergedWeights p)))

theorem isClosed_mergingSupport {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) : IsClosed (mergingSupport (d := d) (N := N) (r := r) φ) :=
  isClosed_iUnion_of_finite (fun p => isClosed_partitionSupport hφ p)

theorem measurable_mergingSupport {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) : MeasurableSet (mergingSupport (d := d) (N := N) (r := r) φ) :=
  (isClosed_mergingSupport hφ).measurableSet

/-- The optional original all-input margin conditioning is explicit. -/
def restrictedSupport {d N r : ℕ} (φ : ℝ → ℝ) (globalMargin : Bool) :
    Set (Weights d N r) :=
  mergingSupport φ ∩ if globalMargin then globalMarginEvent φ (1 / 2) else Set.univ

theorem measurable_restrictedSupport {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (globalMargin : Bool) :
    MeasurableSet (restrictedSupport (d := d) (N := N) (r := r) φ globalMargin) := by
  unfold restrictedSupport
  apply (measurable_mergingSupport hφ).inter
  cases globalMargin
  · exact MeasurableSet.univ
  · rw [globalMarginEvent_eq_iUnion]
    exact (isOpen_iUnion fun f => isOpen_marginEvent hφ (1 / 2) f).measurableSet

def posteriorEvent {d N r n : ℕ} (φ : ℝ → ℝ) (globalMargin : Bool)
    (f : BooleanFunction d) (sample : Fin n → Cube d) : Set (Weights d N r) :=
  restrictedSupport φ globalMargin ∩ RobustPosterior.trainingMarginEvent φ f sample

/-- The actual finite Gaussian posterior, with `σ²=t²/N`. -/
def posterior {d N r n : ℕ} (φ : ℝ → ℝ) (globalMargin : Bool) (σ : ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (posteriorEvent φ globalMargin f sample)

theorem measurable_posteriorEvent {d N r n : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (globalMargin : Bool) (f : BooleanFunction d)
    (sample : Fin n → Cube d) :
    MeasurableSet (posteriorEvent (N := N) (r := r) φ globalMargin f sample) :=
  (measurable_restrictedSupport hφ globalMargin).inter
    (RobustPosterior.measurable_trainingMarginEvent hφ f sample)

theorem posterior_eq_two_stage {d N r n : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (globalMargin : Bool) (σ : ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) :
    posterior (N := N) (r := r) φ globalMargin σ f sample =
      cond (cond (smallPrior d N r σ) (restrictedSupport φ globalMargin))
        (RobustPosterior.trainingMarginEvent φ f sample) := by
  exact (cond_cond_eq_cond_inter (measurable_restrictedSupport hφ globalMargin)
    (RobustPosterior.measurable_trainingMarginEvent hφ f sample) _).symm

theorem target_subset_posteriorEvent {d N r n : ℕ} (φ : ℝ → ℝ)
    (globalMargin : Bool) (f : BooleanFunction d) (sample : Fin n → Cube d) :
    mergingSupport φ ∩ marginEvent (N := N) (r := r) φ (1 / 2) f ⊆
      posteriorEvent φ globalMargin f sample := by
  intro w hw
  refine ⟨⟨hw.1, ?_⟩, fun i => hw.2 (sample i)⟩
  cases globalMargin
  · trivial
  · exact marginEvent_subset_global φ (1 / 2) f hw.2

def largestPopulation {N r : ℕ} (p : LayerPartitions N r) : ℕ :=
  Finset.univ.sup (fun s => populationCount (p s))

def largestOutput {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun x => |networkOutput φ w x|)

/-- The layerwise support inequality is exactly the maximum-based condition
in the manuscript, not a weaker surrogate. -/
theorem population_budget_iff_maxima {d N r : ℕ} (hN : 0 < N)
    (φ : ℝ → ℝ) (w : Weights d N r) (p : LayerPartitions N r) :
    (∀ (s : Fin (r + 1)) (x : Cube d),
      ((populationCount (p s) : ℝ) - 1) * networkOutput φ w x ^ 2 ≤ 4 * readoutEnergy w) ↔
    ((largestPopulation p : ℝ) - 1) * largestOutput φ w ^ 2 ≤ 4 * readoutEnergy w := by
  classical
  obtain ⟨s, _, hs⟩ := Finset.exists_mem_eq_sup Finset.univ Finset.univ_nonempty
    (fun s => populationCount (p s))
  obtain ⟨x, _, hx⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty
    (fun x : Cube d => |networkOutput φ w x|)
  change largestPopulation p = populationCount (p s) at hs
  change largestOutput φ w = |networkOutput φ w x| at hx
  constructor
  · intro h
    rw [hs, hx, sq_abs]
    exact h s x
  · intro h t y
    have hc : populationCount (p t) ≤ largestPopulation p :=
      Finset.le_sup (f := fun s => populationCount (p s)) (Finset.mem_univ t)
    have hcR : (populationCount (p t) : ℝ) - 1 ≤ (largestPopulation p : ℝ) - 1 := by
      exact sub_le_sub_right (by exact_mod_cast hc) 1
    have hq : 1 ≤ largestPopulation p := by rw [hs]; exact populationCount_pos hN (p s)
    have hqR' : (1 : ℝ) ≤ largestPopulation p := by exact_mod_cast hq
    have hy : |networkOutput φ w y| ≤ largestOutput φ w :=
      Finset.le_sup' (fun x => |networkOutput φ w x|) (Finset.mem_univ y)
    have hM : 0 ≤ largestOutput φ w := by rw [hx]; exact abs_nonneg _
    have hsq : networkOutput φ w y ^ 2 ≤ largestOutput φ w ^ 2 := by
      nlinarith [abs_nonneg (networkOutput φ w y), sq_abs (networkOutput φ w y)]
    exact (mul_le_mul hcR hsq (sq_nonneg _) (by linarith)).trans h

theorem mem_partitionSupport_iff_manuscript {d N r : ℕ} (hN : 0 < N)
    (φ : ℝ → ℝ) (w : Weights d N r) (p : LayerPartitions N r) :
    w ∈ partitionSupport φ p ↔
      (((largestPopulation p : ℝ) - 1) * largestOutput φ w ^ 2 ≤ 4 * readoutEnergy w) ∧
      ∀ x, |clippedScore (networkOutput φ w x) -
        clippedScore (networkOutput φ (mergedWeights p w) x)| ≤ (1 / 16 : ℝ) := by
  exact and_congr (population_budget_iff_maxima hN φ w p) Iff.rfl

end NeuralGeneralization.BatchTwoMerging
