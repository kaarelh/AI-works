import NeuralGeneralization.BatchTwoOnlineRawCover

/-! Exact high-probability cumulative bounds for raw posterior risks. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling
variable {H : Type*} [Fintype H] [DecidableEq H]

theorem stopped_exponential (m : ℕ) {A : Finset H} {good : H → Fin (m+1) → Prop} {β : ℝ}
    (P : CoverProcess A good β) (a : ℝ) (ha : 0 ≤ a) (hβ : 0 ≤ β) :
    finiteMean (fun π => Real.exp (∑ i,stopped P a i π)) ≤
      Real.exp ((Real.exp 1-1)*(1+2*a*harmonicSum m+(m+1 : ℕ)*β)) := by
  have hb := adapted_exponential_bound (stopped P a) (stoppingBudget (m+1) a β)
    (stopped_range P a) (stopped_adapted P a) (stopped_average_bound P a ha hβ)
  simpa only [stoppingBudget_sum] using hb

/-- The constants are exactly those of the manuscript's finite-class theorem. -/
theorem total_high_probability (m : ℕ) {A : Finset H} {good : H → Fin (m+1) → Prop} {β : ℝ}
    (P : CoverProcess A good β) (h δ : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β)
    (hδ : 0 < δ) (hδ1 : δ < 1) (hcard : (A.card : ℝ) ≤ Real.exp h) :
    let a := h+Real.log (2*(m+1 : ℕ)/δ)
    let B := 1+2*a*harmonicSum m+(m+1 : ℕ)*β
    finiteEvent (fun π : Equiv.Perm (Fin (m+1)) =>
      (Real.exp 1-1)*B+Real.log (2/δ) < total P π) ≤ δ := by
  dsimp only
  let a := h+Real.log (2*(m+1 : ℕ)/δ)
  let B := 1+2*a*harmonicSum m+(m+1 : ℕ)*β
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
    rw [he,Real.exp_neg,Real.exp_log harg]
    have hm : ((m+1 : ℕ) : ℝ) ≠ 0 := by positivity
    field_simp
    norm_num
  have hstop : finiteEvent (fun π : Equiv.Perm (Fin (m+1)) =>
      (Real.exp 1-1)*B+Real.log (2/δ) < ∑ i,stopped P a i π) ≤ δ/2 := by
    have hb := finiteEvent_tail_of_moment (fun π => ∑ i,stopped P a i π)
      ((Real.exp 1-1)*B) (δ/2) (by linarith) (stopped_exponential m P a ha hβ)
    have he : 1/(δ/2)=2/δ := by ring
    simpa only [he] using hb
  have he (π : Equiv.Perm (Fin (m+1))) :
      (Real.exp 1-1)*B+Real.log (2/δ) < total P π →
      ¬goodUpTo A good a m π ∨
        (Real.exp 1-1)*B+Real.log (2/δ) < ∑ i,stopped P a i π := by
    intro hp
    by_cases hg : goodUpTo A good a m π
    · right
      rwa [BatchTwoOnlineRaw.stopped_total_eq P a π (by simpa using hg)]
    · exact Or.inl hg
  apply (finiteEvent_mono he).trans
  apply (finiteEvent_union _ _).trans
  linarith

end NeuralGeneralization.BatchTwoOnlineRaw
