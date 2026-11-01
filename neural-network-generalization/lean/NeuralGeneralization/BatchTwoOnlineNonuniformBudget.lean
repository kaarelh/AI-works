import NeuralGeneralization.BatchTwoOnlineNonuniformUnseen

/-! The manuscript's explicit logarithmic nonuniform IID expectation budget,
proved uniformly at every finite horizon. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnline
variable {X H : Type*} [Fintype X] [Nonempty X] [Fintype H] [DecidableEq H]

theorem iidExpectedRisk_nonneg (D : X→ℝ) (hD : ∀ x,0≤D x)
    (w : H→ℝ) (hw : ∀ g,0≤w g) (good : H→X→Prop)
    (target : H) (ht : ∀ x,good target x) (hwt : 0<w target) (n : ℕ) :
    0≤ iidExpectedRisk D w good n := by
  apply Finset.sum_nonneg
  intro s _
  apply mul_nonneg (iidWeight_nonneg D hD n s)
  exact Finset.sum_nonneg fun g _ => mul_nonneg
    (posterior_nonneg w _ hw target (fun i => ht (s i)) hwt g) (eventError_nonneg D hD (good g))

theorem nonuniform_expected_partial_sum
    (D : X→ℝ) (hD : ∀ x,0≤D x) (hDs : ∑ x,D x=1)
    {p : ℝ} (hp : 0<p) (hmin : ∀ x,p≤D x)
    (w : H→ℝ) (hw : ∀ g,0≤w g) (good : H→X→Prop)
    (target : H) (ht : ∀ x,good target x) (hwt : 0<w target)
    (A : Finset H) (h β : ℝ) (hh : 0≤h)
    (hcard : (A.card:ℝ)≤Real.exp h)
    (htail : (∑ g∈Finset.univ \ A,w g)/w target≤β) (M : ℕ) :
    (∑ n∈Finset.range M,iidExpectedRisk D w good n)≤
      3+(h+1)*(1+Real.log (nonuniformCutoff p))+(Fintype.card X:ℝ)*β := by
  classical
  let q := iidExpectedRisk D w good
  let T := nonuniformCutoff p
  have hD1 (x : X) : D x≤1 := by
    rw [← hDs]
    exact Finset.single_le_sum (fun y _ => hD y) (Finset.mem_univ x)
  have hp1 : p≤1 := (hmin (Classical.arbitrary X)).trans (hD1 _)
  have hT : 0<T := nonuniformCutoff_pos hp hp1
  have hβ : 0≤β := (div_nonneg (Finset.sum_nonneg (fun g _ => hw g)) hwt.le).trans htail
  have hq0 := iidExpectedRisk_nonneg D hD w hw good target ht hwt
  have hqU := iid_expected_risk_le_unseen D hD hDs w hw good target ht hwt
  have hqR (n : ℕ) (hn : 0<n) := iid_expected_risk_relevant_bound D hD hDs w hw good target ht hwt A h β hh hcard htail hn
  have hzero : q 0≤1 := by simpa [q,expectedUnseen,hDs] using hqU 0
  have hprefixU : (∑ i∈Finset.range T,expectedUnseen D (i+1))≤(Fintype.card X:ℝ) := by
    have hb := expectedUnseen_sum_le_card D hD1 (T+1)
    rw [Finset.sum_range_succ'] at hb
    have hz := expectedUnseen_nonneg D hD hD1 0
    linarith
  have hharm : (∑ i∈Finset.range T,1/((i:ℝ)+1))≤1+Real.log T := by
    simpa only [harmonic,Rat.cast_sum,Rat.cast_inv,Rat.cast_add,Rat.cast_one,Rat.cast_natCast,
      Nat.cast_add,Nat.cast_one,one_div] using harmonic_le_one_add_log T
  have hfirst : (∑ n∈Finset.range (T+1),q n)≤
      1+(h+1)*(1+Real.log T)+β*(Fintype.card X:ℝ) := by
    rw [Finset.sum_range_succ']
    have hs : (∑ i∈Finset.range T,q (i+1))≤
        (h+1)*(∑ i∈Finset.range T,1/((i:ℝ)+1))+β*(∑ i∈Finset.range T,expectedUnseen D (i+1)) := by
      calc
        _ ≤ ∑ i∈Finset.range T,((h+1)/(i+1:ℕ)+β*expectedUnseen D (i+1)) :=
          Finset.sum_le_sum fun i _ => hqR (i+1) (Nat.succ_pos i)
        _ = _ := by simp only [Finset.sum_add_distrib,Finset.mul_sum,Nat.cast_add,Nat.cast_one]; congr 1; apply Finset.sum_congr rfl; intro i _; ring
    have ha := mul_le_mul_of_nonneg_left hharm (show 0≤h+1 by linarith)
    have hb := mul_le_mul_of_nonneg_left hprefixU hβ
    linarith
  have hmass : (Fintype.card X:ℝ)*p≤1 := by
    calc
      _ = ∑ _x : X,p := by simp
      _ ≤ ∑ x,D x := Finset.sum_le_sum fun x _ => hmin x
      _ = 1 := hDs
  have htailq : (∑ i∈Finset.range M,q (T+1+i))≤(1/2:ℝ) := by
    calc
      _ ≤ ∑ i∈Finset.range M,expectedUnseen D (i+(T+1)) :=
        Finset.sum_le_sum fun i _ => by simpa [Nat.add_comm] using hqU (T+1+i)
      _ ≤ (Fintype.card X:ℝ)*Real.exp (-((T+1:ℕ):ℝ)*p) :=
        expectedUnseen_tail_le D hD hD1 hmin (T+1) M
      _ ≤ (Fintype.card X:ℝ)*Real.exp (-(T:ℝ)*p) :=
        mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr (by push_cast; nlinarith)) (Nat.cast_nonneg _)
      _ ≤ (Fintype.card X:ℝ)*(p/2) :=
        mul_le_mul_of_nonneg_left (nonuniformCutoff_tail hp) (Nat.cast_nonneg _)
      _ ≤ 1/2 := by linarith
  have hbig : (∑ n∈Finset.range M,q n)≤∑ n∈Finset.range (T+1+M),q n :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono (by omega)) (fun n _ _ => hq0 n)
  rw [Finset.sum_range_add] at hbig
  change (∑ n∈Finset.range M,q n)≤3+(h+1)*(1+Real.log T)+(Fintype.card X:ℝ)*β
  nlinarith

end NeuralGeneralization.BatchTwoOnline
