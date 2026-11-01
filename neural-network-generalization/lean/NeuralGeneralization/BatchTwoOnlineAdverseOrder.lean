import NeuralGeneralization.BatchTwoOnlineExponential
import Mathlib.Algebra.Field.GeomSum

/-! The point-exception counterexample for the abstract finite-class online
bound. The prior below is explicitly not a Gaussian neural-network prior. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
namespace NeuralGeneralization.BatchTwoOnline.AdverseOrder
open NeuralGeneralization.BatchTwoOnline

/-- Hypothesis zero is the constant positive target. Each other hypothesis
has exactly one exceptional input among 0,...,m-1. -/
def good (m : ℕ) (h : Fin (m+1)) (x : ℕ) : Prop := h.val=0 ∨ x+h.val≠m

def weight (m : ℕ) (R : ℝ) (h : Fin (m+1)) : ℝ := R^h.val

theorem history_iff {m n : ℕ} (hn : n≤m) (h : Fin (m+1)) :
    history (good m) id n h ↔ h.val≤m-n := by
  constructor
  · intro hh
    by_contra hh'
    have hpos : h.val≠0 := by omega
    have hi : m-h.val<n := by omega
    have hbad := hh (m-h.val) hi
    simp only [good,id_eq] at hbad
    rcases hbad with hbad | hbad <;> omega
  · intro hh i hi
    right
    change i+h.val≠m
    omega

theorem normalizer_eq {m n : ℕ} (hn : n≤m) (R : ℝ) :
    normalizer (weight m R) (history (good m) id n)=
      ∑ k∈Finset.range (m-n+1),R^k := by
  unfold normalizer weight
  simp only [history_iff hn]
  rw [Fin.sum_univ_eq_sum_range (fun k : ℕ => if k≤m-n then R^k else 0)]
  have he : (Finset.range (m+1)).filter (fun k => k≤m-n)=Finset.range (m-n+1) := by
    ext k
    simp only [Finset.mem_filter,Finset.mem_range]
    omega
  rw [← Finset.sum_filter,he]

theorem error_eq {m n : ℕ} (hn : n<m) (R : ℝ) :
    onlineError (weight m R) (good m) id n=
      R^(m-n)/(∑ k∈Finset.range (m-n+1),R^k) := by
  let h : Fin (m+1) := ⟨m-n,by omega⟩
  have hh : ¬ good m h n := by simp only [good,h]; omega
  have hhkeep : history (good m) id n h := (history_iff hn.le h).mpr (by rfl)
  unfold onlineError
  rw [Finset.sum_eq_single h]
  · simp only [id_eq,if_neg hh,onlinePosterior,posterior,if_pos hhkeep,normalizer_eq hn.le,weight,h]
  · intro b _ hbh
    have hgood : good m b n := by
      right
      intro he
      apply hbh
      apply Fin.ext
      dsimp [h]
      omega
    simp only [id_eq,if_pos hgood]
  · simp

/-- Every one of the m rounds has error strictly above 1-1/R. -/
theorem error_gt {m n : ℕ} (hn : n<m) {R : ℝ} (hR : 1<R) :
    1-1/R<onlineError (weight m R) (good m) id n := by
  rw [error_eq hn]
  let Z := ∑ k∈Finset.range (m-n+1),R^k
  have hp : 0<R := by linarith
  have hZ : 0<Z := Finset.sum_pos (fun k _ => pow_pos hp k) (by simp)
  have hg := geom_sum_mul R (m-n+1)
  rw [pow_succ] at hg
  change Z*(R-1)=R^(m-n)*R-1 at hg
  apply (lt_div_iff₀ hZ).mpr
  have hid : (1-1/R)*Z=(Z*(R-1))/R := by field_simp <;> ring
  rw [hid]
  apply (div_lt_iff₀ hp).mpr
  linarith

/-- The expected number of posterior-sampled mistakes is linear in m even
though the hypothesis class has only m+1 members. -/
theorem cumulative_error_gt {m : ℕ} (hm : 0<m) {R : ℝ} (hR : 1<R) :
    (1-1/R)*(m:ℝ)<cumulativeError (weight m R) (good m) id m := by
  unfold cumulativeError
  calc
    _ = ∑ _∈Finset.range m,(1-1/R) := by simp only [Finset.sum_const,Finset.card_range,nsmul_eq_mul]; ring
    _ < _ := Finset.sum_lt_sum_of_nonempty (Finset.nonempty_range_iff.mpr (Nat.ne_of_gt hm))
      (fun i hi => error_gt (Finset.mem_range.mp hi) hR)

/-- For R>3 every queried point is both a majority mistake and a strict
2/3-confidence failure; the correct-label probability is below 1/3. -/
theorem correct_probability_lt_third {m n : ℕ} (hn : n<m) {R : ℝ} (hR : 3<R) :
    1-onlineError (weight m R) (good m) id n<1/3 := by
  have he := error_gt hn (show 1<R by linarith)
  have hi : 1/R<(1/3:ℝ) := (div_lt_div_iff₀ (by linarith) (by norm_num)).mpr (by linarith)
  linarith

/-- The same lower bound for the literal finite product law of independent
posterior draws, rather than an informal expected-error interpretation. -/
theorem expected_sampled_mistakes_gt {m : ℕ} (hm : 0<m) {R : ℝ} (hR : 1<R) :
    (1-1/R)*(m:ℝ)<∑ draw : Fin m→Fin (m+1),
      sequentialDrawWeight (weight m R) (good m) id m draw *
      sequentialMistakes (good m) id m draw := by
  have hw : ∀ g,0≤weight m R g := fun g => pow_nonneg (by linarith) _
  have htarget : ∀ x,good m (0 : Fin (m+1)) x := fun _ => Or.inl rfl
  have hwt : 0<weight m R (0 : Fin (m+1)) := by simp [weight]
  have heq : (∑ draw : Fin m→Fin (m+1),
      sequentialDrawWeight (weight m R) (good m) id m draw *
      sequentialMistakes (good m) id m draw)=cumulativeError (weight m R) (good m) id m := by
    unfold sequentialDrawWeight sequentialMistakes
    rw [independent_expected_sum (fun i : Fin m => onlinePosterior (weight m R) (good m) id i.val) (fun i =>
      onlinePosterior_sum (weight m R) (good m) id hw 0 htarget hwt i.val)
      (fun (i : Fin m) g => if good m g (id i.val) then (0:ℝ) else 1)]
    have he (i : Fin m) : (∑ g,onlinePosterior (weight m R) (good m) id i.val g *
        (if good m g (id i.val) then (0:ℝ) else 1))=onlineError (weight m R) (good m) id i.val := by
      unfold onlineError
      apply Finset.sum_congr rfl
      intro g _
      split_ifs <;> simp
    simp_rw [he]
    exact Fin.sum_univ_eq_sum_range _ _
  rw [heq]
  exact cumulative_error_gt hm hR

#print axioms expected_sampled_mistakes_gt
#print axioms cumulative_error_gt
end NeuralGeneralization.BatchTwoOnline.AdverseOrder
