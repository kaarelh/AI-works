import NeuralGeneralization.BatchTwoContinuousDepthChannelAnalysis

/-! Finite triangular schedules for the depth-varying channel. The reciprocal
square and adjacent-ratio costs are bounded independently of depth. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper

def tentHeight {k : ℕ} (i : Fin (k+1)) : ℕ := min (i.val+1) (k+1-i.val)

theorem tentHeight_pos {k : ℕ} (i : Fin (k+1)) : 0 < tentHeight i := by
  unfold tentHeight
  omega

@[simp] theorem tentHeight_zero (k : ℕ) : tentHeight (0 : Fin (k+1))=1 := by
  unfold tentHeight
  simp

@[simp] theorem tentHeight_last (k : ℕ) : tentHeight (Fin.last k)=1 := by
  unfold tentHeight
  simp

theorem tentHeight_rev {k : ℕ} (i : Fin (k+1)) : tentHeight (Fin.rev i)=tentHeight i := by
  simp only [tentHeight,Fin.val_rev]
  omega

theorem tentHeight_transition_rev_left {k : ℕ} (i : Fin k) :
    tentHeight (Fin.rev i).castSucc=tentHeight i.succ := by
  simp only [tentHeight,Fin.val_rev,Fin.val_castSucc,Fin.val_succ]
  omega

theorem tentHeight_transition_rev_right {k : ℕ} (i : Fin k) :
    tentHeight (Fin.rev i).succ=tentHeight i.castSucc := by
  simp only [tentHeight,Fin.val_rev,Fin.val_castSucc,Fin.val_succ]
  omega

theorem tentHeight_transition_difference {k : ℕ} (i : Fin k) :
    |(tentHeight i.castSucc : ℝ)-(tentHeight i.succ : ℝ)| ≤ 1 := by
  have h1 : tentHeight i.castSucc ≤ tentHeight i.succ+1 := by
    simp only [tentHeight,Fin.val_castSucc,Fin.val_succ]
    omega
  have h2 : tentHeight i.succ ≤ tentHeight i.castSucc+1 := by
    simp only [tentHeight,Fin.val_castSucc,Fin.val_succ]
    omega
  have h1r : (tentHeight i.castSucc : ℝ) ≤ (tentHeight i.succ : ℝ)+1 := by exact_mod_cast h1
  have h2r : (tentHeight i.succ : ℝ) ≤ (tentHeight i.castSucc : ℝ)+1 := by exact_mod_cast h2
  exact abs_le.mpr ⟨by linarith,by linarith⟩

theorem reciprocal_square_sum_sharp (k : ℕ) :
    (∑ i : Fin (k+1), (1/((i.val : ℝ)+1))^2) ≤ 2-1/((k : ℝ)+1) := by
  induction k with
  | zero => norm_num [Fin.sum_univ_succ]
  | succ k ih =>
    rw [Fin.sum_univ_castSucc]
    simp only [Fin.val_castSucc,Fin.val_last,Nat.cast_add,Nat.cast_one]
    have hstep : (1/((k : ℝ)+1+1))^2 ≤ 1/((k : ℝ)+1)-1/((k : ℝ)+1+1) := by
      have h1 : (0 : ℝ)<(k : ℝ)+1 := by positivity
      have h2 : (0 : ℝ)<(k : ℝ)+1+1 := by positivity
      have hid : 1/((k : ℝ)+1)-1/((k : ℝ)+1+1) =
          1/(((k : ℝ)+1)*((k : ℝ)+1+1)) := by field_simp; ring
      rw [hid,div_pow,one_pow]
      apply one_div_le_one_div_of_le (by positivity)
      nlinarith
    linarith

theorem reciprocal_square_sum (k : ℕ) :
    (∑ i : Fin (k+1), (1/((i.val : ℝ)+1))^2) ≤ 2 :=
  (reciprocal_square_sum_sharp k).trans (by
    have h : 0 ≤ 1/((k : ℝ)+1) := by positivity
    linarith)

theorem tentHeight_reciprocal_sum (k : ℕ) :
    (∑ i : Fin (k+1), (1/(tentHeight i : ℝ))^2) ≤ 4 := by
  have hp (i : Fin (k+1)) : (1/(tentHeight i : ℝ))^2 ≤
      (1/((i.val : ℝ)+1))^2+(1/(((Fin.rev i).val : ℝ)+1))^2 := by
    unfold tentHeight
    by_cases hi : i.val+1 ≤ k+1-i.val
    · rw [Nat.min_eq_left hi,Nat.cast_add,Nat.cast_one]
      exact le_add_of_nonneg_right (sq_nonneg _)
    · rw [Nat.min_eq_right (le_of_not_ge hi)]
      have he : k+1-i.val=(Fin.rev i).val+1 := by simp only [Fin.val_rev]; omega
      rw [he,Nat.cast_add,Nat.cast_one]
      exact le_add_of_nonneg_left (sq_nonneg _)
  have h := Finset.sum_le_sum (s:=Finset.univ) (fun i _ => hp i)
  rw [Finset.sum_add_distrib] at h
  have hr : (∑ i : Fin (k+1), (1/(((Fin.rev i).val : ℝ)+1))^2) =
      ∑ i : Fin (k+1), (1/((i.val : ℝ)+1))^2 :=
    (Equiv.sum_comp (Fin.revPerm : Equiv.Perm (Fin (k+1))) (fun i : Fin (k+1) => (1/((i.val : ℝ)+1))^2))
  rw [hr] at h
  linarith [reciprocal_square_sum k]

theorem adjacent_ratio_pair_bound {a b : ℝ} (ha : 0<a) (hb : 0<b)
    (hab : |a-b| ≤ 1) : (a/b)^2+(b/a)^2 ≤ 2+2*(1/a)^2+2*(1/b)^2 := by
  have hd : (a-b)^2 ≤ 1 := (sq_le_one_iff_abs_le_one _).mpr hab
  have hm := mul_le_mul_of_nonneg_right hd (sq_nonneg (1/a+1/b))
  have hs : (1/a+1/b)^2 ≤ 2*(1/a)^2+2*(1/b)^2 := by nlinarith [sq_nonneg (1/a-1/b)]
  have hid : (a/b)^2+(b/a)^2 = 2+(a-b)^2*(1/a+1/b)^2 := by
    field_simp
    <;> ring
  rw [hid]
  nlinarith

theorem tentHeight_ratio_sum (k : ℕ) :
    (∑ i : Fin k, ((tentHeight i.castSucc : ℝ)/(tentHeight i.succ : ℝ))^2) ≤ (k : ℝ)+8 := by
  have hpair (i : Fin k) := adjacent_ratio_pair_bound
    (by exact_mod_cast tentHeight_pos i.castSucc) (by exact_mod_cast tentHeight_pos i.succ)
    (tentHeight_transition_difference i)
  have h := Finset.sum_le_sum (s:=Finset.univ) (fun i _ => hpair i)
  simp only [Finset.sum_add_distrib,Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,
    ← Finset.mul_sum] at h
  have hrev : (∑ i : Fin k, ((tentHeight i.succ : ℝ)/(tentHeight i.castSucc : ℝ))^2) =
      ∑ i : Fin k, ((tentHeight i.castSucc : ℝ)/(tentHeight i.succ : ℝ))^2 := by
    have he := (Equiv.ofBijective Fin.rev (Function.bijective_iff_has_inverse.mpr
      ⟨Fin.rev,Fin.rev_rev,Fin.rev_rev⟩)).sum_comp
      (fun i : Fin k => ((tentHeight i.castSucc : ℝ)/(tentHeight i.succ : ℝ))^2)
    simpa only [Equiv.ofBijective_apply,tentHeight_transition_rev_left,tentHeight_transition_rev_right] using he
  rw [hrev] at h
  have hleft : (∑ i : Fin k, (1/(tentHeight i.castSucc : ℝ))^2) ≤ 4 := by
    have ht := tentHeight_reciprocal_sum k
    rw [Fin.sum_univ_castSucc] at ht
    linarith [sq_nonneg (1/(tentHeight (Fin.last k) : ℝ))]
  have hright : (∑ i : Fin k, (1/(tentHeight i.succ : ℝ))^2) ≤ 4 := by
    have ht := tentHeight_reciprocal_sum k
    rw [Fin.sum_univ_succ] at ht
    linarith [sq_nonneg (1/(tentHeight (0 : Fin (k+1)) : ℝ))]
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthPaper
