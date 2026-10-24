import NeuralGeneralization.BatchTwoShallowGrowth
import NeuralGeneralization.BatchTwoRelativeGrowthStatistics

/-! The relative growth-function estimate for actual compressed halfspace votes. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel BatchTwoRelativeGrowth
open Classical

def voteBool {d : ℕ} (f : BooleanFunction d) (B : ℝ) (m : ℕ)
    (a : Fin m → Halfspace d) (x : Cube d) : Bool :=
  decide (labelReal (f x)*vote B m a x ≤ 3/8)

theorem voteBool_hit {d : ℕ} (f : BooleanFunction d) (B : ℝ) (m : ℕ)
    (a : Fin m → Halfspace d) (x : Cube d) :
    hit (voteBool f B m a) x = voteLoss f B m a x := by
  simp [hit, voteBool, voteLoss]

def splitPattern {n : ℕ} (A : Finset (Fin (n+n))) : (Fin n → Bool) × (Fin n → Bool) :=
  (fun i => decide (Fin.castAdd n i ∈ A), fun i => decide (Fin.natAdd n i ∈ A))

theorem paired_votePattern {d n m : ℕ} (f : BooleanFunction d) (B : ℝ)
    (p : (Fin n → Cube d) × (Fin n → Cube d)) (a : Fin m → Halfspace d) :
    pairedPattern (voteBool f B m a) p =
      splitPattern (votePattern f B (Fin.append p.1 p.2) a) := by
  apply Prod.ext <;> funext i <;>
    simp only [pairedPattern, voteBool, splitPattern, votePattern, Finset.mem_filter,
      Finset.mem_univ, true_and, Fin.append_left, Fin.append_right]

theorem paired_vote_growth_bound {d n m : ℕ} (hn : 0 < n) (f : BooleanFunction d) (B : ℝ)
    (p : (Fin n → Cube d) × (Fin n → Cube d)) :
    ((pairedPatterns (voteBool f B m) p).card : ℝ) ≤
      Real.exp ((m : ℝ)*(d+1)*Real.log (2*Real.exp 1*n)) := by
  have he : pairedPatterns (voteBool f B m) p =
      (Finset.univ.image (votePattern f B (Fin.append p.1 p.2) (m := m))).image splitPattern := by
    unfold pairedPatterns
    rw [Finset.image_image]
    apply Finset.image_congr
    intro a _
    exact paired_votePattern f B p a
  rw [he]
  have hc : (((Finset.univ.image (votePattern f B (Fin.append p.1 p.2) (m := m))).image splitPattern).card : ℝ) ≤
      (Finset.univ.image (votePattern f B (Fin.append p.1 p.2) (m := m))).card := by
    exact_mod_cast Finset.card_image_le
  have hg := vote_growth_bound_exp (by omega : 0 < n+n) f B (Fin.append p.1 p.2) (m := m)
  have harg : Real.exp 1*((n+n : ℕ) : ℝ)=2*Real.exp 1*n := by push_cast; ring
  rw [harg] at hg
  exact hc.trans hg

theorem vote_bad_compl_eq {d n m : ℕ} (D : Measure (Cube d))
    (f : BooleanFunction d) (B u : ℝ) :
    (badSample D (voteBool f B m) n u)ᶜ =
      BatchTwoRelativeStatistics.generalizationEvent D (voteLoss f B m) n u := by
  ext s
  simp only [badSample, mem_compl_iff, mem_setOf_eq, not_exists, not_lt,
    BatchTwoRelativeStatistics.generalizationEvent, population, count,
    voteBool_hit, RobustStatistics.empiricalLoss, mul_div_assoc]

theorem vote_relative_growth_probability {d n m : ℕ} (hn : 0 < n)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (f : BooleanFunction d) (B : ℝ)
    {u δ : ℝ} (hδ : 0 < δ) (hδ1 : δ < 1)
    (hbudget : 32*((m : ℝ)*(d+1)*Real.log (2*Real.exp 1*n)+Real.log (4/δ)) ≤ (n : ℝ)*u) :
    1-δ ≤ (CompressionSampling.iidSamples D n).real
      (BatchTwoRelativeStatistics.generalizationEvent D (voteLoss f B m) n u) := by
  rw [← vote_bad_compl_eq]
  apply relative_growth_good_probability_log D (voteBool f B m) n hn hδ hδ1
    (hP := paired_vote_growth_bound hn f B) (hbudget := hbudget)
  have hnR : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have he : (1 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
  have hl : 0 ≤ Real.log (2*Real.exp 1*n) := Real.log_nonneg (by nlinarith)
  positivity

end NeuralGeneralization.BatchTwoShallow
