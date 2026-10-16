import NeuralGeneralization.OddCoefficientCuspTail

/-! Elementary monotone-density estimates for a nonnegative summable
sequence with two-sided polynomial tails. -/
noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

lemma coefficientTail_split {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m) (hs : Summable b)
    {n m : ℕ} (hnm : n ≤ m) :
    coefficientTail b n = (∑ i ∈ Finset.Ico n m,b i)+coefficientTail b m := by
  have hfinite : HasSum (fun i => if i ∈ Finset.Ico n m then b i else 0)
      (∑ i ∈ Finset.Ico n m,b i) := by
    have h := hasSum_sum_of_ne_finset_zero (s := Finset.Ico n m)
      (f := fun i => if i ∈ Finset.Ico n m then b i else 0)
      (L := SummationFilter.unconditional ℕ) (by intro i hi; simp [hi])
    simpa only [Finset.sum_ite_mem,Finset.inter_self] using h
  have h := hfinite.add (coefficientTail_summable hb hs m).hasSum
  have he : (fun i => (if i ∈ Finset.Ico n m then b i else 0)+(if m ≤ i then b i else 0)) =
      fun i => if n ≤ i then b i else 0 := by
    funext i
    simp only [Finset.mem_Ico]
    split_ifs <;> simp_all <;> omega
  rw [he] at h
  exact ((coefficientTail_summable hb hs n).hasSum.unique h)

lemma coefficient_le_tail {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m) (hs : Summable b) (n : ℕ) :
    b n ≤ coefficientTail b n := by
  rw [coefficientTail_split hb hs (Nat.le_succ n)]
  simpa using (show b n ≤ b n+coefficientTail b (n+1) from
    le_add_of_nonneg_right (coefficientTail_nonneg hb (n+1)))

lemma monotone_tail_interval_lower {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m) (hs : Summable b)
    (hmono : Antitone b) {n m : ℕ} (hnm : n ≤ m) :
    ((m-n : ℕ) : ℝ)*b m ≤ coefficientTail b n := by
  rw [coefficientTail_split hb hs hnm]
  have h := Finset.sum_le_sum (s := Finset.Ico n m)
    (fun i hi => hmono (Finset.mem_Ico.mp hi).2.le)
  simp only [Finset.sum_const,Nat.card_Ico,nsmul_eq_mul] at h
  exact h.trans (le_add_of_nonneg_right (coefficientTail_nonneg hb m))

lemma monotone_tail_interval_upper {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m) (hs : Summable b)
    (hmono : Antitone b) {n m : ℕ} (hnm : n ≤ m) :
    coefficientTail b n ≤ ((m-n : ℕ) : ℝ)*b n+coefficientTail b m := by
  rw [coefficientTail_split hb hs hnm]
  apply add_le_add _ le_rfl
  have h := Finset.sum_le_sum (s := Finset.Ico n m)
    (fun i hi => hmono (Finset.mem_Ico.mp hi).1)
  simpa only [Finset.sum_const,Nat.card_Ico,nsmul_eq_mul] using h

lemma exists_nat_rpow_neg_small {β ε : ℝ} (hβ : 0 < β) (hε : 0 < ε) :
    ∃ A : ℕ,2 ≤ A ∧ (A : ℝ)^(-β) ≤ ε := by
  obtain ⟨A,hA⟩ := exists_nat_gt (max (1 : ℝ) (ε^(-1/β)))
  have hA1 : (1 : ℝ) < A := (le_max_left _ _).trans_lt hA
  have hAge : 2 ≤ A := by exact_mod_cast hA1
  have hbase : 0 < ε^(-1/β) := Real.rpow_pos_of_pos hε _
  have hh := Real.rpow_le_rpow_of_nonpos hbase ((le_max_right _ _).trans hA.le)
    (neg_nonpos.mpr hβ.le)
  rw [← Real.rpow_mul hε.le,show (-1/β)*(-β)=1 by field_simp,Real.rpow_one] at hh
  exact ⟨A,hAge,hh⟩

/-- Two-sided tail powers force two-sided pointwise powers for every
positive index of a decreasing sequence. -/
theorem monotone_coefficient_power_bounds {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m)
    (hs : Summable b) (hmono : Antitone b) {β c C : ℝ} (hβ : 0 < β)
    (hc : 0 < c) (hC : 0 < C)
    (htail : ∀ n : ℕ,0 < n → c*(n : ℝ)^(-β) ≤ coefficientTail b n ∧
      coefficientTail b n ≤ C*(n : ℝ)^(-β)) :
    ∃ l U : ℝ,0 < l ∧ 0 < U ∧ ∀ n : ℕ,0 < n →
      l ≤ (n : ℝ)^(1+β)*b n ∧ (n : ℝ)^(1+β)*b n ≤ U := by
  obtain ⟨A,hA,hAsmall⟩ := exists_nat_rpow_neg_small hβ (div_pos hc (by positivity : 0 < 2*C))
  let l := c/(2*A : ℝ)
  let U := C*(3 : ℝ)^(1+β)
  have hA0 : 0 < (A : ℝ) := by exact_mod_cast (show 0 < A by omega)
  have hl : 0 < l := by dsimp [l]; positivity
  have hU : 0 < U := by dsimp [U]; positivity
  have hexp : 0 ≤ 1+β := by linarith
  refine ⟨l,U,hl,hU,?_⟩
  intro n hn
  have hn0 : 0 < (n : ℝ) := by exact_mod_cast hn
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hAn : 0 < A*n := Nat.mul_pos (by omega) hn
  have hnAn : n ≤ A*n := by nlinarith
  have hcoef : (n : ℝ)^(1+β)=(n : ℝ)*(n : ℝ)^β := by
    rw [Real.rpow_add hn0,Real.rpow_one]
  constructor
  · have hi := monotone_tail_interval_upper hb hs hmono hnAn
    have hlow := (htail n hn).1
    have hupper := (htail (A*n) hAn).2
    rw [Nat.cast_mul,Real.mul_rpow hA0.le hn0.le] at hupper
    have hsmall : C*(A : ℝ)^(-β) ≤ c/2 := by
      have hh := mul_le_mul_of_nonneg_left hAsmall hC.le
      have he : C*(c/(2*C))=c/2 := by field_simp
      rwa [he] at hh
    have hrem := mul_le_mul_of_nonneg_right hsmall (Real.rpow_nonneg hn0.le (-β))
    have hcount : ((A*n-n : ℕ) : ℝ) ≤ (A : ℝ)*n := by
      exact_mod_cast Nat.sub_le (A*n) n
    have hmul := mul_le_mul_of_nonneg_right hcount (hb n)
    have hh : (c/2)*(n : ℝ)^(-β) ≤ (A : ℝ)*n*b n := by nlinarith only [hi,hlow,hupper,hrem,hmul]
    have hh' := mul_le_mul_of_nonneg_right hh (Real.rpow_nonneg hn0.le β)
    have hcancel : (n : ℝ)^(-β)*(n : ℝ)^β=1 := by
      rw [← Real.rpow_add hn0,neg_add_cancel,Real.rpow_zero]
    have hfinal : c/2 ≤ (A : ℝ)*((n : ℝ)^(1+β)*b n) := by
      rw [mul_assoc (c/2),hcancel,mul_one] at hh'
      rw [hcoef]
      nlinarith only [hh']
    apply (div_le_iff₀ (show 0 < (2*A : ℝ) by positivity)).mpr
    nlinarith only [hfinal]
  · by_cases hn2 : n < 2
    · have hne : n=1 := by omega
      subst n
      have hh := (coefficient_le_tail hb hs 1).trans (htail 1 (by omega)).2
      norm_num only [Nat.cast_one,Real.one_rpow] at hh ⊢
      have hpow : (1 : ℝ) ≤ 3^(1+β) := Real.one_le_rpow (by norm_num) hexp
      simpa only [one_mul] using hh.trans (by simpa [U] using mul_le_mul_of_nonneg_left hpow hC.le)
    · let r := n/2
      have hr : 0 < r := by dsimp [r]; omega
      have hrn : r ≤ n := by dsimp [r]; omega
      have hrhalf : r ≤ n-r := by dsimp [r]; omega
      have hn3 : n ≤ 3*r := by dsimp [r]; omega
      have hr0 : 0 < (r : ℝ) := by exact_mod_cast hr
      have hi := monotone_tail_interval_lower hb hs hmono hrn
      have hu := (htail r hr).2
      have hcoun : (r : ℝ) ≤ (n-r : ℕ) := by exact_mod_cast hrhalf
      have hmul := mul_le_mul_of_nonneg_right hcoun (hb n)
      have hh : (r : ℝ)*b n ≤ C*(r : ℝ)^(-β) := hmul.trans (hi.trans hu)
      have hh' := mul_le_mul_of_nonneg_right hh (Real.rpow_nonneg hr0.le β)
      have hcancel : (r : ℝ)^(-β)*(r : ℝ)^β=1 := by
        rw [← Real.rpow_add hr0,neg_add_cancel,Real.rpow_zero]
      have hmid : (r : ℝ)^(1+β)*b n ≤ C := by
        rw [mul_assoc C,hcancel,mul_one] at hh'
        rw [Real.rpow_add hr0,Real.rpow_one]
        nlinarith only [hh']
      have hp : (n : ℝ)^(1+β) ≤ (3*(r : ℝ))^(1+β) := by
        apply Real.rpow_le_rpow hn0.le _ hexp
        exact_mod_cast hn3
      calc
        _ ≤ (3*(r : ℝ))^(1+β)*b n := mul_le_mul_of_nonneg_right hp (hb n)
        _ = (3 : ℝ)^(1+β)*((r : ℝ)^(1+β)*b n) := by rw [Real.mul_rpow (by norm_num : (0 : ℝ) ≤ 3) hr0.le]; ring
        _ ≤ (3 : ℝ)^(1+β)*C := mul_le_mul_of_nonneg_left hmid (by positivity)
        _ = U := by dsimp [U]; ring

end NeuralGeneralization
