import NeuralGeneralization.BatchTwoOnlineFiniteLossCover
import NeuralGeneralization.BatchTwoOnlineSampledTail

/-! Sampled-error tails for arbitrary adapted cover processes. Conditional
on the input order, the independent error bits have their literal Bernoulli
probabilities. A subsequent module identifies this with actual posterior
network draws, rather than assuming that identification. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling
variable {H : Type*} [Fintype H] [DecidableEq H] {m : ℕ}
variable {A : Finset H} {good : H → Fin m → Prop} {β : ℝ}

def errorBitWeight (q : ℝ) (b : Bool) : ℝ := if b then q else 1-q

def errorCount (b : Fin m → Bool) : ℝ := ∑ i,if b i then 1 else 0

def sampledWeight (P : CoverProcess A good β) (π : Equiv.Perm (Fin m))
    (b : Fin m → Bool) : ℝ := independentWeight (fun i => errorBitWeight (P.risk i π)) b

lemma errorBitWeight_sum (q : ℝ) : ∑ b,errorBitWeight q b=1 := by
  simp [errorBitWeight,Fintype.sum_bool]

lemma errorBitWeight_nonneg {q : ℝ} (hq : 0 ≤ q ∧ q ≤ 1) (b : Bool) :
    0 ≤ errorBitWeight q b := by cases b <;> simp [errorBitWeight] <;> linarith [hq.1,hq.2]

lemma sampledWeight_nonneg (P : CoverProcess A good β) (π : Equiv.Perm (Fin m)) (b) :
    0 ≤ sampledWeight P π b :=
  independentWeight_nonneg _ (fun i => errorBitWeight_nonneg (P.range i π)) b

lemma sampledWeight_sum (P : CoverProcess A good β) (π : Equiv.Perm (Fin m)) :
    ∑ b,sampledWeight P π b=1 := independentWeight_sum _ (fun i => errorBitWeight_sum _)

lemma expected_errorCount (P : CoverProcess A good β) (π : Equiv.Perm (Fin m)) :
    (∑ b,sampledWeight P π b*errorCount b)=total P π := by
  simp only [sampledWeight,errorCount]
  rw [independent_expected_sum _ (fun i => errorBitWeight_sum _) (fun _ (b : Bool) => if b then (1:ℝ) else 0)]
  simp [errorBitWeight,Fintype.sum_bool,total]

def stoppedErrorCount (P : CoverProcess A good β) (a : ℝ)
    (π : Equiv.Perm (Fin m)) (b : Fin m → Bool) : ℝ :=
  ∑ i,if goodUpTo A good a i.val π then (if b i then 1 else 0) else 0

lemma stopped_error_moment (P : CoverProcess A good β) (a : ℝ) (π : Equiv.Perm (Fin m)) :
    (∑ b,sampledWeight P π b*Real.exp (stoppedErrorCount P a π b)) =
      ∏ i,(1+(Real.exp 1-1)*stopped P a i π) := by
  unfold sampledWeight stoppedErrorCount
  rw [independent_exp_sum (fun i => errorBitWeight (P.risk i π))
    (fun i (b : Bool) => if goodUpTo A good a i.val π then (if b then (1:ℝ) else 0) else 0)]
  apply Finset.prod_congr rfl
  intro i _
  by_cases hg : goodUpTo A good a i.val π
  · simp only [if_pos hg,stopped]
    simp [errorBitWeight,Fintype.sum_bool,hg]
    ring
  · simp [errorBitWeight,Fintype.sum_bool,stopped,hg]

lemma stopped_error_exponential (k : ℕ)
    {A : Finset H} {good : H → Fin (k+1) → Prop} {β : ℝ}
    (P : CoverProcess A good β) (a : ℝ) (ha : 0 ≤ a) (hβ : 0 ≤ β) :
    finiteMean (fun π => ∑ b,sampledWeight P π b*Real.exp (stoppedErrorCount P a π b)) ≤
      Real.exp ((Real.exp 1-1)*(1+2*a*harmonicSum k+(k+1:ℕ)*β)) := by
  let c := Real.exp 1-1
  have hc : 0 ≤ c := by dsimp [c]; linarith [Real.add_one_le_exp (1:ℝ)]
  let Y := stopped P a
  have hfpos (i : Fin (k+1)) (π) : 0 < 1+c*Y i π := by
    have hY := (stopped_range P a i π).1
    dsimp [Y] at *
    nlinarith [mul_nonneg hc hY]
  let L := fun i π => Real.log (1+c*Y i π)
  have hexp (i : Fin (k+1)) (π) : Real.exp (L i π)=1+c*Y i π := Real.exp_log (hfpos i π)
  have hadapt : ∀ i j t π,i.val < j.val → j.val ≤ t.val → L i (π*Equiv.swap j t)=L i π := by
    intro i j t π hij hjt
    dsimp [L,Y]
    rw [stopped_adapted P a i j t π hij hjt]
  have hstep (i : Fin (k+1)) (π) : remainingAverage (fun ρ => Real.exp (L i ρ)) i π ≤
      Real.exp (c*stoppingBudget (k+1) a β i) := by
    simp_rw [hexp]
    rw [remainingAverage_add,remainingAverage_const,remainingAverage_mul]
    calc
      _ ≤ 1+c*stoppingBudget (k+1) a β i := add_le_add le_rfl
        (mul_le_mul_of_nonneg_left (stopped_average_bound P a ha hβ i π) hc)
      _ ≤ _ := by linarith [Real.add_one_le_exp (c*stoppingBudget (k+1) a β i)]
  have hb := adapted_exp_bound_of_step L (fun i => c*stoppingBudget (k+1) a β i) hadapt hstep
  rw [← Finset.mul_sum,stoppingBudget_sum] at hb
  simp_rw [stopped_error_moment]
  convert hb using 1
  congr 1
  funext π
  rw [Real.exp_sum]
  simp_rw [hexp]
  rfl

lemma stoppedErrorCount_eq (P : CoverProcess A good β) (a : ℝ) (π : Equiv.Perm (Fin m))
    (hg : goodUpTo A good a (m-1) π) (b : Fin m → Bool) :
    stoppedErrorCount P a π b = errorCount b := by
  apply Finset.sum_congr rfl
  intro i _
  exact if_pos (goodUpTo_mono A good a (show i.val ≤ m-1 by omega) π hg)

/-- Exact sampled-mistake tail, with the same constants as the posterior-risk
bound. The count is under the joint uniform-order / conditional draw law. -/
theorem sampled_error_high_probability (k : ℕ)
    {A : Finset H} {good : H → Fin (k+1) → Prop} {β : ℝ}
    (P : CoverProcess A good β) (h δ : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β)
    (hδ : 0 < δ) (hδ1 : δ < 1) (hcard : (A.card:ℝ) ≤ Real.exp h) :
    let B := 1+2*(h+Real.log (2*(k+1:ℕ)/δ))*harmonicSum k+(k+1:ℕ)*β
    finiteMean (fun π => ∑ b,if (Real.exp 1-1)*B+Real.log (2/δ) < errorCount b
      then sampledWeight P π b else 0) ≤ δ := by
  dsimp only
  let a := h+Real.log (2*(k+1:ℕ)/δ)
  let B := 1+2*a*harmonicSum k+(k+1:ℕ)*β
  let U := (Real.exp 1-1)*B+Real.log (2/δ)
  have ha : 0 ≤ a := by
    apply add_nonneg hh
    apply Real.log_nonneg
    apply (one_le_div hδ).mpr
    have hm : (1:ℝ) ≤ (k+1:ℕ) := by exact_mod_cast Nat.succ_pos k
    linarith
  have hbad : finiteEvent (fun π : Equiv.Perm (Fin (k+1)) => ¬goodUpTo A good a k π) ≤ δ/2 := by
    have hb := bad_any_prefix_probability A good h a hcard
    simp only [Nat.add_sub_cancel] at hb
    apply hb.trans
    have harg : 0 < (2:ℝ)*(k+1:ℕ)/δ := by positivity
    have he : h-a = -Real.log ((2:ℝ)*(k+1:ℕ)/δ) := by dsimp [a]; ring
    rw [he,Real.exp_neg,Real.exp_log harg]
    have hm : ((k+1:ℕ):ℝ) ≠ 0 := by positivity
    field_simp
    norm_num
  have hstop : finiteMean (fun π => ∑ b,
      if U < stoppedErrorCount P a π b then sampledWeight P π b else 0) ≤ δ/2 := by
    have hb := mixed_exponential_tail_of_moment (sampledWeight P) (stoppedErrorCount P a)
      (sampledWeight_nonneg P) ((Real.exp 1-1)*B) (δ/2) (by linarith)
      (stopped_error_exponential k P a ha hβ)
    have he : 1/(δ/2)=2/δ := by ring
    simpa only [he] using hb
  have hp (π : Equiv.Perm (Fin (k+1))) :
      (∑ b,if U < errorCount b then sampledWeight P π b else 0) ≤
      (if ¬goodUpTo A good a k π then 1 else 0)+
      (∑ b,if U < stoppedErrorCount P a π b then sampledWeight P π b else 0) := by
    by_cases hg : goodUpTo A good a k π
    · have he (b) := stoppedErrorCount_eq P a π (by simpa using hg) b
      simp_rw [he]
      simp [hg]
    · simp only [hg,not_false_eq_true,if_true]
      have hle : (∑ b,if U < errorCount b then sampledWeight P π b else 0) ≤ 1 := by
        rw [← sampledWeight_sum P π]
        apply Finset.sum_le_sum
        intro b _
        split_ifs
        · exact le_rfl
        · exact sampledWeight_nonneg P π b
      have hnon : 0 ≤ ∑ b,if U < stoppedErrorCount P a π b then sampledWeight P π b else 0 := by
        apply Finset.sum_nonneg
        intro b _
        split_ifs
        · exact sampledWeight_nonneg P π b
        · exact le_rfl
      linarith
  apply (finiteMean_mono hp).trans
  rw [finiteMean_add]
  have hbad' : finiteMean (fun π : Equiv.Perm (Fin (k+1)) =>
      if ¬goodUpTo A good a k π then (1:ℝ) else 0) ≤ δ/2 := by
    convert hbad using 1
    unfold finiteEvent
    congr 1
    funext π
    split_ifs <;> simp_all
  exact (add_le_add hbad' hstop).trans_eq (by ring)

theorem sampled_error_tail (hm : 0 < m) (P : CoverProcess A good β)
    (h δ : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β) (hδ : 0 < δ) (hδ1 : δ < 1)
    (hcard : (A.card:ℝ) ≤ Real.exp h) :
    finiteMean (fun π => ∑ b,if (Real.exp 1-1)*
      (1+2*(h+Real.log (2*(m:ℝ)/δ))*harmonicSum (m-1)+m*β)+Real.log (2/δ) < errorCount b
      then sampledWeight P π b else 0) ≤ δ := by
  obtain ⟨k,rfl⟩ := Nat.exists_eq_succ_of_ne_zero hm.ne'
  simpa only [Nat.succ_eq_add_one,Nat.add_sub_cancel] using
    sampled_error_high_probability k P h δ hh hβ hδ hδ1 hcard

#print axioms sampled_error_tail
end NeuralGeneralization.BatchTwoOnlineRaw
