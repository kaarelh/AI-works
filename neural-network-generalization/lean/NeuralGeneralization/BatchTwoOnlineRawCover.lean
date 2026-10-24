import NeuralGeneralization.BatchTwoOnlineHighProbability

/-! Cumulative bounds for an adapted raw-posterior risk process controlled by
an actual finite comparison class. The comparison class need not be the
posterior's hypothesis space. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling

variable {H : Type*} [Fintype H] [DecidableEq H] {m : ℕ}

/-- The sole one-step transfer premise is a deterministic comparison-class
bound. Neural applications prove it from their actual posterior and grid. -/
structure CoverProcess (A : Finset H) (good : H → Fin m → Prop) (β : ℝ) where
  risk : Fin m → Equiv.Perm (Fin m) → ℝ
  range : ∀ i π, 0 ≤ risk i π ∧ risk i π ≤ 1
  adapted : ∀ i k j π, i.val < k.val → k.val ≤ j.val →
    risk i (π*Equiv.swap k j)=risk i π
  control : ∀ i π, 0 < i.val → ∀ u : ℝ, 0 ≤ u →
    (∀ g∈A, prefixKeep good π i.val g → domainError good g ≤ u) →
    remainingAverage (risk i) i π ≤ (m : ℝ)/(m-i.val : ℕ)*u+β

variable {A : Finset H} {good : H → Fin m → Prop} {β : ℝ}

def total (P : CoverProcess A good β) (π : Equiv.Perm (Fin m)) : ℝ := ∑ i,P.risk i π

theorem mean_risk (P : CoverProcess A good β) (h : ℝ) (hh : 0 ≤ h)
    (hcard : (A.card : ℝ)≤Real.exp h) (i : Fin m) (hi : 0 < i.val) :
    finiteMean (P.risk i) ≤ (m : ℝ)/(m-i.val : ℕ)*((h+1)/i.val)+β := by
  let p : Equiv.Perm (Fin m) → ℝ := fun _ => 1/Fintype.card (Equiv.Perm (Fin m))
  have hp : ∀ π,0 ≤ p π := by intro π; dsimp [p]; positivity
  have hpsum : ∑ π,p π=1 := by
    simp [p,ne_of_gt (Fintype.card_pos : 0 < Fintype.card (Equiv.Perm (Fin m)))]
  let E := survivorEnvelope A (fun π => prefixKeep good π i.val) (domainError good) h i.val
  have hE : finiteMean E ≤ (h+1)/i.val := by
    have hs (g : H) (_hg : g∈A) :
        (∑ π,if prefixKeep good π i.val g then p π else 0)≤Real.exp (-(i.val : ℝ)*domainError good g) := by
      have hb := prefix_survival good g i.val i.isLt.le (Nat.zero_lt_of_lt i.isLt)
      convert hb using 1
      unfold finiteEvent finiteMean p
      rw [Finset.sum_div]
      apply Finset.sum_congr rfl
      intro π _
      split_ifs <;> simp
    have hb := expected_survivorEnvelope_le p hp hpsum A (fun π => prefixKeep good π i.val)
      (domainError good) h i.val (by exact_mod_cast hi) hcard hs
    convert hb using 1
    unfold finiteMean p
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro π _
    ring
  have hav : finiteMean (P.risk i)=finiteMean (fun π => remainingAverage (P.risk i) i π) := by
    simpa only [one_mul] using weighted_remainingAverage (fun _ => (1 : ℝ)) (P.risk i) i (by intros; rfl)
  rw [hav]
  calc
    _ ≤ finiteMean (fun π => (m : ℝ)/(m-i.val : ℕ)*E π+β) := by
      apply finiteMean_mono
      intro π
      apply P.control i π hi (E π)
        (survivorEnvelope_nonneg A _ _ h i.val hh (by exact_mod_cast hi) π)
      intro g hg hk
      exact error_le_survivorEnvelope A _ _ h i.val (by exact_mod_cast hi) π g hg hk
    _ = (m : ℝ)/(m-i.val : ℕ)*finiteMean E+β := by
      rw [finiteMean_add,finiteMean_mul,finiteMean_const]
    _ ≤ _ := by gcongr

/-- The exact harmonic expectation bound also applies to raw posteriors. -/
theorem expected_total (k : ℕ) {A : Finset H} {good : H → Fin (k+1) → Prop} {β : ℝ}
    (P : CoverProcess A good β) (h : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β)
    (hcard : (A.card : ℝ)≤Real.exp h) :
    finiteMean (total P) ≤ 1+2*(h+1)*harmonicSum k+(k+1 : ℕ)*β := by
  have hfirst : finiteMean (P.risk 0)≤1 := by
    exact (finiteMean_mono (fun π => (P.range 0 π).2)).trans_eq (finiteMean_const 1)
  have hrest : (∑ i : Fin k,finiteMean (P.risk i.succ))≤2*(h+1)*harmonicSum k+k*β := by
    calc
      _ ≤ ∑ i : Fin k, (((k+1 : ℕ) : ℝ)/(k+1-i.succ.val : ℕ)*((h+1)/i.succ.val)+β) :=
        Finset.sum_le_sum (fun i _ => mean_risk P h hh hcard i.succ (by simp))
      _ = _ := by rw [Finset.sum_add_distrib,harmonic_decomposition]; simp
  unfold total
  rw [finiteMean_sum,Fin.sum_univ_succ]
  push_cast
  nlinarith

def stopped (P : CoverProcess A good β) (a : ℝ) (i : Fin m) (π : Equiv.Perm (Fin m)) : ℝ :=
  if goodUpTo A good a i.val π then P.risk i π else 0

theorem stopped_range (P : CoverProcess A good β) (a : ℝ) (i : Fin m) (π : Equiv.Perm (Fin m)) :
    0 ≤ stopped P a i π ∧ stopped P a i π ≤ 1 := by
  unfold stopped
  split_ifs
  · exact P.range i π
  · norm_num

theorem stopped_adapted (P : CoverProcess A good β) (a : ℝ) (i k j : Fin m) (π : Equiv.Perm (Fin m))
    (hik : i.val < k.val) (hkj : k.val ≤ j.val) :
    stopped P a i (π*Equiv.swap k j)=stopped P a i π := by
  simp only [stopped,goodUpTo_swap A good a i.val π k j hik.le hkj,P.adapted i k j π hik hkj]

theorem stopped_average (P : CoverProcess A good β) (a : ℝ) (i : Fin m) (π : Equiv.Perm (Fin m)) :
    remainingAverage (stopped P a i) i π=
      if goodUpTo A good a i.val π then remainingAverage (P.risk i) i π else 0 := by
  unfold remainingAverage
  by_cases hg : goodUpTo A good a i.val π
  · rw [if_pos hg]
    congr 1
    apply Finset.sum_congr rfl
    intro j _
    by_cases hj : i.val ≤ j.val
    · simp [hj,stopped,(goodUpTo_swap A good a i.val π i j le_rfl hj).mpr hg]
    · simp [hj]
  · rw [if_neg hg]
    have hz : (∑ j : Fin m, if i.val≤j.val then stopped P a i (π*Equiv.swap i j) else 0)=0 := by
      apply Finset.sum_eq_zero
      intro j _
      by_cases hj : i.val ≤ j.val
      · have hnot : ¬goodUpTo A good a i.val (π*Equiv.swap i j) :=
          fun hh => hg ((goodUpTo_swap A good a i.val π i j le_rfl hj).mp hh)
        simp [hj,stopped,hnot]
      · simp [hj]
    rw [hz,zero_div]

theorem stopped_average_bound (P : CoverProcess A good β) (a : ℝ) (ha : 0 ≤ a) (hβ : 0 ≤ β)
    (i : Fin m) (π : Equiv.Perm (Fin m)) :
    remainingAverage (stopped P a i) i π ≤ stoppingBudget m a β i := by
  by_cases hi : i.val=0
  · calc
      _ ≤ remainingAverage (fun _ => (1 : ℝ)) i π := remainingAverage_mono
        (fun ρ => (stopped_range P a i ρ).2) i π
      _ ≤ _ := by rw [remainingAverage_const]; simp [stoppingBudget,hi,hβ]
  · rw [stopped_average,stoppingBudget,if_neg hi]
    split_ifs with hg
    · exact P.control i π (Nat.pos_of_ne_zero hi) (a/i.val) (by positivity)
        (fun g hAg hk => hg i (Nat.pos_of_ne_zero hi) le_rfl g hAg hk)
    · positivity

theorem stopped_total_eq (P : CoverProcess A good β) (a : ℝ) (π : Equiv.Perm (Fin m))
    (hg : goodUpTo A good a (m-1) π) : (∑ i,stopped P a i π)=total P π := by
  apply Finset.sum_congr rfl
  intro i _
  simp [stopped,goodUpTo_mono A good a (show i.val≤m-1 by omega) π hg]

end NeuralGeneralization.BatchTwoOnlineRaw
