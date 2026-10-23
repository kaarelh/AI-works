import NeuralGeneralization.BatchTwoOnlineHighProbability

/-!
# High-probability total mistakes for actual posterior sampling

The joint law is a uniform permutation followed by the explicit product of
its sequential consistency posteriors. The stopping flag depends only on
revealed inputs and labels, so it also controls the Bernoulli moment factors.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling

variable {Ω Z : Type*} [Fintype Ω] [Nonempty Ω] [Fintype Z]

theorem mixed_exponential_tail_of_moment (p Y : Ω → Z → ℝ)
    (hp : ∀ ω z, 0 ≤ p ω z) (B δ : ℝ) (hδ : 0 < δ)
    (hmgf : finiteMean (fun ω => ∑ z, p ω z*Real.exp (Y ω z)) ≤ Real.exp B) :
    finiteMean (fun ω => ∑ z, if B+Real.log (1/δ) < Y ω z then p ω z else 0) ≤ δ := by
  calc
    _ ≤ finiteMean (fun ω => (∑ z, p ω z*Real.exp (Y ω z))/Real.exp (B+Real.log (1/δ))) := by
      apply finiteMean_mono
      intro ω
      have hb := finite_markov (p ω) (fun z => Real.exp (Y ω z)) (hp ω)
        (fun z => (Real.exp_pos _).le) (Real.exp (B+Real.log (1/δ))) (Real.exp_pos _)
      simpa only [Real.exp_lt_exp] using hb
    _ = (finiteMean (fun ω => ∑ z, p ω z*Real.exp (Y ω z)))/Real.exp (B+Real.log (1/δ)) :=
      finiteMean_div _ _
    _ ≤ Real.exp B/Real.exp (B+Real.log (1/δ)) :=
      div_le_div_of_nonneg_right hmgf (Real.exp_pos _).le
    _ = δ := by
      rw [Real.exp_add, Real.exp_log (one_div_pos.mpr hδ)]
      field_simp

variable {H : Type*} [Fintype H] [DecidableEq H] {m : ℕ}

def stoppedSampledMistakes (A : Finset H) (good : H → Fin m → Prop) (a : ℝ)
    (π : Equiv.Perm (Fin m)) (draw : Fin m → H) : ℝ :=
  ∑ i, if goodUpTo A good a i.val π then pointLoss good (draw i) (π i) else 0

lemma stopped_sampled_moment_eq (w : H → ℝ) (hw : ∀ g, 0 ≤ w g)
    (good : H → Fin m → Prop) (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (a : ℝ) (π : Equiv.Perm (Fin m)) :
    (∑ draw, permutationDrawWeight w good π draw*Real.exp (stoppedSampledMistakes A good a π draw)) =
      ∏ i, (1+(Real.exp 1-1)*stoppedRound w A good a i π) := by
  simp only [permutationDrawWeight, stoppedSampledMistakes]
  rw [independent_exp_sum (fun i : Fin m => posterior w (prefixKeep good π i.val))
    (fun i g => if goodUpTo A good a i.val π then pointLoss good g (π i) else 0)]
  apply Finset.prod_congr rfl
  intro i _
  have hpsum := posterior_sum w (prefixKeep good π i.val) hw target (fun j _ => htarget (π j)) hwt
  by_cases hg : goodUpTo A good a i.val π
  · simp only [hg, if_true, stoppedRound]
    have he (g : H) : Real.exp (pointLoss good g (π i)) =
        1+(Real.exp 1-1)*pointLoss good g (π i) := by
      unfold pointLoss
      split_ifs <;> simp
    simp_rw [he, mul_add, mul_one]
    rw [Finset.sum_add_distrib, hpsum]
    unfold permutationRound
    rw [Finset.mul_sum]
    congr 1
    apply Finset.sum_congr rfl
    intro g _
    ring
  · simp [hg, stoppedRound, hpsum]

lemma stopped_sampled_exponential_bound (m : ℕ)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin (m+1) → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (a β : ℝ) (ha : 0 ≤ a) (hβ : 0 ≤ β)
    (htail : (∑ g∈Finset.univ \ A, w g)/w target ≤ β) :
    finiteMean (fun π => ∑ draw, permutationDrawWeight w good π draw*
      Real.exp (stoppedSampledMistakes A good a π draw)) ≤
      Real.exp ((Real.exp 1-1)*(1+2*a*harmonicSum m+(m+1 : ℕ)*β)) := by
  let c := Real.exp 1-1
  have hc : 0 ≤ c := by dsimp [c]; linarith [Real.add_one_le_exp (1 : ℝ)]
  let Y := stoppedRound w A good a
  have hfpos (i : Fin (m+1)) (π) : 0 < 1+c*Y i π := by
    have hY := (stoppedRound_range w hw good target htarget hwt A a i π).1
    dsimp [Y] at *
    nlinarith [mul_nonneg hc hY]
  let L := fun i π => Real.log (1+c*Y i π)
  have hexp (i : Fin (m+1)) (π) : Real.exp (L i π)=1+c*Y i π := Real.exp_log (hfpos i π)
  have hadapt : ∀ i k j π, i.val < k.val → k.val ≤ j.val →
      L i (π*Equiv.swap k j)=L i π := by
    intro i k j π hi hj
    dsimp [L, Y]
    rw [stoppedRound_adapted w A good a i k j π hi hj]
  have hstep (i : Fin (m+1)) (π) : remainingAverage (fun ρ => Real.exp (L i ρ)) i π ≤
      Real.exp (c*stoppingBudget (m+1) a β i) := by
    simp_rw [hexp]
    rw [remainingAverage_add, remainingAverage_const, remainingAverage_mul]
    calc
      _ ≤ 1+c*stoppingBudget (m+1) a β i := add_le_add le_rfl
        (mul_le_mul_of_nonneg_left
          (remainingAverage_stopped_le w hw good target htarget hwt A a β ha hβ htail i π) hc)
      _ ≤ _ := by linarith [Real.add_one_le_exp (c*stoppingBudget (m+1) a β i)]
  have hb := adapted_exp_bound_of_step L (fun i => c*stoppingBudget (m+1) a β i) hadapt hstep
  rw [← Finset.mul_sum, stoppingBudget_sum] at hb
  simp_rw [stopped_sampled_moment_eq w hw good target htarget hwt A a]
  convert hb using 1
  congr 1
  funext π
  rw [Real.exp_sum]
  simp_rw [hexp]
  rfl

lemma stoppedSampledMistakes_eq (A : Finset H) (good : H → Fin m → Prop)
    (a : ℝ) (π : Equiv.Perm (Fin m)) (hg : goodUpTo A good a (m-1) π)
    (draw : Fin m → H) :
    stoppedSampledMistakes A good a π draw = sampledMistakes good π draw := by
  apply Finset.sum_congr rfl
  intro i _
  have hgi := goodUpTo_mono A good a (show i.val ≤ m-1 by omega) π hg
  simp [hgi]

/-- Exact high-probability sampled-mistake statement, under the actual joint
uniform-permutation and sequential-posterior-draw law. -/
theorem sampledMistakes_high_probability (m : ℕ)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin (m+1) → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (h β δ : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β)
    (hδ : 0 < δ) (hδ1 : δ < 1) (hcard : (A.card : ℝ) ≤ Real.exp h)
    (htail : (∑ g∈Finset.univ \ A, w g)/w target ≤ β) :
    let a := h+Real.log (2*(m+1 : ℕ)/δ)
    let B := 1+2*a*harmonicSum m+(m+1 : ℕ)*β
    finiteMean (fun π : Equiv.Perm (Fin (m+1)) => ∑ draw,
      if (Real.exp 1-1)*B+Real.log (2/δ) < sampledMistakes good π draw
      then permutationDrawWeight w good π draw else 0) ≤ δ := by
  dsimp only
  let a := h+Real.log (2*(m+1 : ℕ)/δ)
  let B := 1+2*a*harmonicSum m+(m+1 : ℕ)*β
  let U := (Real.exp 1-1)*B+Real.log (2/δ)
  have ha : 0 ≤ a := by
    apply add_nonneg hh
    apply Real.log_nonneg
    apply (one_le_div hδ).mpr
    have hm : (1 : ℝ) ≤ (m+1 : ℕ) := by exact_mod_cast Nat.succ_pos m
    linarith
  have hbad : finiteEvent (fun π : Equiv.Perm (Fin (m+1)) =>
      ¬goodUpTo A good a m π) ≤ δ/2 := by
    have hb := bad_any_prefix_probability A good h a hcard
    simp only [Nat.add_sub_cancel] at hb
    apply hb.trans
    have harg : 0 < (2 : ℝ)*(m+1 : ℕ)/δ := by positivity
    have he : h-a = -Real.log ((2 : ℝ)*(m+1 : ℕ)/δ) := by dsimp [a]; ring
    rw [he, Real.exp_neg, Real.exp_log harg]
    have hm : ((m+1 : ℕ) : ℝ) ≠ 0 := by positivity
    field_simp
    norm_num
  have hp (π : Equiv.Perm (Fin (m+1))) (draw) : 0 ≤ permutationDrawWeight w good π draw :=
    independentWeight_nonneg _ (fun i g => posterior_nonneg w _ hw target
      (fun j _ => htarget (π j)) hwt g) draw
  have hstop : finiteMean (fun π : Equiv.Perm (Fin (m+1)) => ∑ draw,
      if U < stoppedSampledMistakes A good a π draw then permutationDrawWeight w good π draw else 0) ≤ δ/2 := by
    have hb := mixed_exponential_tail_of_moment (permutationDrawWeight w good)
      (stoppedSampledMistakes A good a) hp ((Real.exp 1-1)*B) (δ/2) (by linarith)
      (stopped_sampled_exponential_bound m w hw good target htarget hwt A a β ha hβ htail)
    have he : 1/(δ/2)=2/δ := by ring
    simpa only [he] using hb
  have hpoint (π : Equiv.Perm (Fin (m+1))) :
      (∑ draw, if U < sampledMistakes good π draw then permutationDrawWeight w good π draw else 0) ≤
      (if ¬goodUpTo A good a m π then 1 else 0)+
      (∑ draw, if U < stoppedSampledMistakes A good a π draw then permutationDrawWeight w good π draw else 0) := by
    by_cases hg : goodUpTo A good a m π
    · have he (draw) := stoppedSampledMistakes_eq A good a π (by simpa using hg) draw
      simp_rw [he]
      simp [hg]
    · simp only [hg, not_false_eq_true, if_true]
      have hle : (∑ draw, if U < sampledMistakes good π draw then permutationDrawWeight w good π draw else 0) ≤ 1 := by
        rw [← permutationDrawWeight_sum w hw good target htarget hwt π]
        apply Finset.sum_le_sum
        intro draw _
        split_ifs
        · exact le_rfl
        · exact hp π draw
      have hnon : 0 ≤ ∑ draw, if U < stoppedSampledMistakes A good a π draw then permutationDrawWeight w good π draw else 0 := by
        apply Finset.sum_nonneg
        intro draw _
        split_ifs
        · exact hp π draw
        · exact le_rfl
      linarith
  apply (finiteMean_mono hpoint).trans
  rw [finiteMean_add]
  have hbad' : finiteMean (fun π : Equiv.Perm (Fin (m+1)) =>
      if ¬goodUpTo A good a m π then (1 : ℝ) else 0) ≤ δ/2 := by
    convert hbad using 1
    unfold finiteEvent
    congr 1
    funext π
    by_cases hg : goodUpTo A good a m π <;> simp [hg]
  exact (add_le_add hbad' hstop).trans_eq (by ring)

end NeuralGeneralization.BatchTwoOnline
