import NeuralGeneralization.BatchTwoOnlineSampling
import Mathlib.Analysis.Convex.SpecificFunctions.Basic

/-!
# Exponential inequalities for actual posterior sampling
-/
noncomputable section
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling

lemma exp_unit_interval_le (x : ℝ) (hx : 0 ≤ x) (hx1 : x ≤ 1) :
    Real.exp x ≤ 1 + (Real.exp 1-1)*x := by
  have h := convexOn_exp.2 (Set.mem_univ (0 : ℝ)) (Set.mem_univ (1 : ℝ))
    (show 0 ≤ 1-x by linarith) hx (show (1-x)+x=1 by ring)
  norm_num at h
  nlinarith

/-- Finite exponential Markov inequality, for any literal nonnegative
probability weights. Normalization is not needed by this inequality. -/
theorem exponential_tail_of_moment {Ω : Type*} [Fintype Ω]
    (p Y : Ω → ℝ) (hp : ∀ ω, 0 ≤ p ω) (B δ : ℝ) (hδ : 0 < δ)
    (hmgf : (∑ ω, p ω * Real.exp (Y ω)) ≤ Real.exp B) :
    (∑ ω, if B+Real.log (1/δ) < Y ω then p ω else 0) ≤ δ := by
  have hb := finite_markov p (fun ω => Real.exp (Y ω)) hp
    (fun ω => (Real.exp_pos _).le) (Real.exp (B+Real.log (1/δ))) (Real.exp_pos _)
  simp_rw [Real.exp_lt_exp] at hb
  calc
    _ ≤ (∑ ω, p ω * Real.exp (Y ω)) / Real.exp (B+Real.log (1/δ)) := hb
    _ ≤ Real.exp B / Real.exp (B+Real.log (1/δ)) :=
      div_le_div_of_nonneg_right hmgf (Real.exp_pos _).le
    _ = δ := by
      rw [Real.exp_add, Real.exp_log (one_div_pos.mpr hδ)]
      field_simp

/-- The same tail statement expressed as the actual uniform finite law. -/
theorem finiteEvent_tail_of_moment {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (Y : Ω → ℝ) (B δ : ℝ) (hδ : 0 < δ)
    (hmgf : finiteMean (fun ω => Real.exp (Y ω)) ≤ Real.exp B) :
    finiteEvent (fun ω => B+Real.log (1/δ) < Y ω) ≤ δ := by
  have hb := exponential_tail_of_moment (fun _ : Ω => 1/(Fintype.card Ω : ℝ)) Y
    (fun _ => by positivity) B δ hδ
  have he : (∑ ω, (1/(Fintype.card Ω : ℝ))*Real.exp (Y ω)) =
      finiteMean (fun ω => Real.exp (Y ω)) := by
    simp only [finiteMean, Finset.sum_div, one_div_mul_eq_div]
  rw [he] at hb
  convert hb hmgf using 1
  unfold finiteEvent finiteMean
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro ω _
  split_ifs <;> simp

variable {I H : Type*} [Fintype I] [DecidableEq I] [Fintype H]

/-- Exact factorization of the exponential moment for independent posterior
draws at a fixed input sequence. -/
theorem independent_exp_sum (p : I → H → ℝ) (L : I → H → ℝ) :
    (∑ draw : I → H, independentWeight p draw * Real.exp (∑ i, L i (draw i))) =
      ∏ i, ∑ g, p i g * Real.exp (L i g) := by
  simp only [independentWeight, Real.exp_sum, ← Finset.prod_mul_distrib]
  exact (Fintype.prod_sum (fun i g => p i g * Real.exp (L i g))).symm

/-- Exponential moment bound for arbitrary bounded losses under the actual
product law. In the posterior application each loss is an error indicator. -/
theorem independent_exp_sum_le
    (p : I → H → ℝ) (hp : ∀ i g, 0 ≤ p i g) (hpsum : ∀ i, ∑ g, p i g = 1)
    (L : I → H → ℝ) (hL : ∀ i g, 0 ≤ L i g ∧ L i g ≤ 1) :
    (∑ draw : I → H, independentWeight p draw * Real.exp (∑ i, L i (draw i))) ≤
      Real.exp ((Real.exp 1-1)*(∑ i, ∑ g, p i g * L i g)) := by
  rw [independent_exp_sum, Finset.mul_sum, Real.exp_sum]
  apply Finset.prod_le_prod
  · intro i _
    exact Finset.sum_nonneg fun g _ => mul_nonneg (hp i g) (Real.exp_pos _).le
  · intro i _
    calc
      _ ≤ ∑ g, p i g * (1+(Real.exp 1-1)*L i g) :=
        Finset.sum_le_sum fun g _ => mul_le_mul_of_nonneg_left
          (exp_unit_interval_le (L i g) (hL i g).1 (hL i g).2) (hp i g)
      _ = 1+(Real.exp 1-1)*(∑ g, p i g*L i g) := by
        simp only [mul_add, mul_one, Finset.sum_add_distrib, hpsum, Finset.mul_sum]
        congr 1
        apply Finset.sum_congr rfl
        intro g _
        ring
      _ ≤ _ := by linarith [Real.add_one_le_exp ((Real.exp 1-1)*(∑ g, p i g*L i g))]

variable {X : Type*}

/-- Exact finite-horizon sampled-mistake law at an arbitrary fixed query
sequence. The posterior used at time `i` is conditioned on all earlier labels. -/
def sequentialDrawWeight (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (n : ℕ) : (Fin n → H) → ℝ :=
  independentWeight (fun i : Fin n => onlinePosterior w good query i.val)

def sequentialMistakes (good : H → X → Prop) (query : ℕ → X)
    (n : ℕ) (draw : Fin n → H) : ℝ :=
  ∑ i, if good (draw i) (query i.val) then 0 else 1

/-- Direct prior-mass exponential tail for actual posterior sampling at every
finite horizon and every fixed input sequence, with the manuscript's constant. -/
theorem sequentialMistakes_prior_tail
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (hwsum : ∑ g, w g ≤ 1)
    (good : H → X → Prop) (query : ℕ → X)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (n : ℕ) (δ : ℝ) (hδ : 0 < δ) :
    (∑ draw, if (Real.exp 1-1)*(-Real.log (w target))+Real.log (1/δ) <
      sequentialMistakes good query n draw then sequentialDrawWeight w good query n draw else 0) ≤ δ := by
  apply exponential_tail_of_moment _ _
    (independentWeight_nonneg _ (fun (i : Fin n) g => onlinePosterior_nonneg w good query hw target htarget hwt i.val g))
    _ δ hδ
  have he : (∑ i : Fin n, ∑ g, onlinePosterior w good query i.val g *
      (if good g (query i.val) then 0 else 1)) = cumulativeError w good query n := by
    have hpoint (i : Fin n) : (∑ g, onlinePosterior w good query i.val g *
        (if good g (query i.val) then 0 else 1)) = onlineError w good query i.val := by
      apply Finset.sum_congr rfl
      intro g _
      split_ifs <;> simp
    simp_rw [hpoint]
    exact Fin.sum_univ_eq_sum_range (onlineError w good query) n
  have hb := independent_exp_sum_le
    (fun i : Fin n => onlinePosterior w good query i.val)
    (fun i g => onlinePosterior_nonneg w good query hw target htarget hwt i g)
    (fun i => onlinePosterior_sum w good query hw target htarget hwt i)
    (fun i : Fin n => fun g => if good g (query i.val) then (0 : ℝ) else 1)
    (fun i g => by split_ifs <;> norm_num)
  rw [he] at hb
  apply hb.trans
  apply Real.exp_le_exp.mpr
  apply mul_le_mul_of_nonneg_left
    (cumulativeError_le_neg_log w good query hw target htarget hwt hwsum n)
  have := Real.add_one_le_exp (1 : ℝ)
  linarith

end NeuralGeneralization.BatchTwoOnline
