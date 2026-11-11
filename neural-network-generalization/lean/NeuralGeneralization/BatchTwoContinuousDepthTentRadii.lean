import NeuralGeneralization.BatchTwoContinuousDepthTentSchedule
import NeuralGeneralization.BatchTwoContinuousDepthChannelSemantics

/-! Quantitative radii and their exact channel energy costs. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper

def tentRadius (k : ℕ) (q : ℝ) (i : Fin (k+1)) : ℝ :=
  q^(i.val+1)/(2*q^(k+2)*(tentHeight i : ℝ))

def channelReadoutBudget (k : ℕ) (q : ℝ) : ℝ := 4*(q^(k+2))^2

theorem tentRadius_pos {k : ℕ} {q : ℝ} (hq : 1 ≤ q) (i : Fin (k+1)) :
    0 < tentRadius k q i := by
  have hqp : 0 < q := by linarith
  have hi : (0 : ℝ) < tentHeight i := by exact_mod_cast tentHeight_pos i
  unfold tentRadius
  positivity

theorem tentRadius_upper {k : ℕ} {q : ℝ} (hq : 1 ≤ q) (i : Fin (k+1)) :
    tentRadius k q i ≤ 1/(2*q*(tentHeight i : ℝ)) := by
  have hqp : 0 < q := by linarith
  have hi : (0 : ℝ) < tentHeight i := by exact_mod_cast tentHeight_pos i
  calc
    _ ≤ q^(k+1)/(2*q^(k+2)*(tentHeight i : ℝ)) :=
      div_le_div_of_nonneg_right (pow_le_pow_right₀ hq (by omega)) (by positivity)
    _ = _ := by
      rw [show k+2=k+1+1 from rfl,pow_succ]
      field_simp
      simp [pow_succ,pow_two,mul_assoc]

theorem tentRadius_le_half {k : ℕ} {q : ℝ} (hq : 1 ≤ q) (i : Fin (k+1)) :
    tentRadius k q i ≤ 1/2 := by
  have hi : (1 : ℝ) ≤ tentHeight i := by exact_mod_cast tentHeight_pos i
  apply (tentRadius_upper hq i).trans
  apply one_div_le_one_div_of_le (by norm_num)
  nlinarith

theorem tentRadius_last {k : ℕ} {q : ℝ} (hq : 1 ≤ q) :
    tentRadius k q (Fin.last k)=1/(2*q) := by
  have hqp : 0 < q := by linarith
  unfold tentRadius
  rw [tentHeight_last]
  simp only [Fin.val_last,Nat.cast_one,mul_one]
  rw [show k+2=k+1+1 from rfl,pow_succ]
  field_simp
  simp [pow_succ,pow_two,mul_assoc]

theorem tentRadius_ratio {k : ℕ} {q : ℝ} (hq : 1 ≤ q) (i : Fin k) :
    tentRadius k q i.succ/tentRadius k q i.castSucc =
      q*((tentHeight i.castSucc : ℝ)/(tentHeight i.succ : ℝ)) := by
  have hqp : 0 < q := by linarith
  have ha : (0 : ℝ) < tentHeight i.castSucc := by exact_mod_cast tentHeight_pos i.castSucc
  have hb : (0 : ℝ) < tentHeight i.succ := by exact_mod_cast tentHeight_pos i.succ
  unfold tentRadius
  simp only [Fin.val_succ,Fin.val_castSucc]
  rw [pow_succ]
  field_simp
  <;> ring

theorem tentRadius_first_cost {k : ℕ} {q : ℝ} (hq : 1 ≤ q) :
    channelReadoutBudget k q * (Real.artanh (tentRadius k q 0))^2 ≤ q^2+1/4 := by
  have hqp : 0 < q := by linarith
  have hrp := tentRadius_pos hq (0 : Fin (k+1))
  have hrh := tentRadius_le_half hq (0 : Fin (k+1))
  have hupper : tentRadius k q 0 ≤ 1/(2*q) := by simpa using tentRadius_upper hq (0 : Fin (k+1))
  have hbase : channelReadoutBudget k q*(tentRadius k q 0)^2=q^2 := by
    simp only [channelReadoutBudget,tentRadius,Fin.val_zero,zero_add,pow_one,tentHeight_zero,Nat.cast_one,mul_one]
    field_simp
    norm_num
  have hsmall : q^2*(tentRadius k q 0)^2 ≤ 1/4 := by
    have hprod : q*tentRadius k q 0 ≤ 1/2 := by
      have h := mul_le_mul_of_nonneg_left hupper hqp.le
      have he : q*(1/(2*q))=1/2 := by field_simp
      simpa only [he] using h
    have hs := pow_le_pow_left₀ (mul_nonneg hqp.le hrp.le) hprod 2
    simpa only [mul_pow,div_pow,one_pow,show (2 : ℝ)^2=4 by norm_num] using hs
  have h := mul_le_mul_of_nonneg_left (artanh_sq_bound ⟨hrp.le,hrh⟩)
    (show 0 ≤ channelReadoutBudget k q by unfold channelReadoutBudget; positivity)
  have hid : channelReadoutBudget k q*((tentRadius k q 0)^2+(tentRadius k q 0)^4) =
      q^2+q^2*(tentRadius k q 0)^2 := by
    rw [mul_add,hbase,show (tentRadius k q 0)^4=(tentRadius k q 0)^2*(tentRadius k q 0)^2 by ring,
      ← mul_assoc,hbase]
  rw [hid] at h
  linarith

theorem tentHeight_ratio_le_two {k : ℕ} (i : Fin k) :
    (tentHeight i.castSucc : ℝ)/(tentHeight i.succ : ℝ) ≤ 2 := by
  have hb : (1 : ℝ) ≤ tentHeight i.succ := by exact_mod_cast tentHeight_pos i.succ
  have h := (abs_le.mp (tentHeight_transition_difference i)).2
  apply (div_le_iff₀ (by linarith : (0 : ℝ)<tentHeight i.succ)).mpr
  linarith


theorem tentRadius_transition_cost {k : ℕ} {q : ℝ} (hq : 1 ≤ q) (i : Fin k) :
    (Real.artanh (tentRadius k q i.succ)/tentRadius k q i.castSucc)^2 ≤
      q^2*((tentHeight i.castSucc : ℝ)/(tentHeight i.succ : ℝ))^2 +
      (1/(tentHeight i.succ : ℝ))^2 := by
  let a := tentRadius k q i.castSucc
  let b := tentRadius k q i.succ
  let R : ℝ := (tentHeight i.castSucc : ℝ)/(tentHeight i.succ : ℝ)
  have ha : 0 < a := tentRadius_pos hq _
  have hb : 0 < b := tentRadius_pos hq _
  have hbh : b ≤ 1/2 := tentRadius_le_half hq _
  have hqp : 0 < q := by linarith
  have ht : (0 : ℝ) < tentHeight i.succ := by exact_mod_cast tentHeight_pos i.succ
  have hR : R ≤ 2 := tentHeight_ratio_le_two i
  have hR0 : 0 ≤ R := by dsimp [R]; positivity
  have hratio : b/a=q*R := tentRadius_ratio hq i
  have hsmall : q*R*b ≤ 1/(tentHeight i.succ : ℝ) := by
    calc
      _ ≤ q*2*b := mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hR hqp.le) hb.le
      _ ≤ q*2*(1/(2*q*(tentHeight i.succ : ℝ))) :=
        mul_le_mul_of_nonneg_left (tentRadius_upper hq i.succ) (by positivity)
      _ = _ := by field_simp
  have hs := pow_le_pow_left₀ (by positivity : 0 ≤ q*R*b) hsmall 2
  have h := div_le_div_of_nonneg_right (artanh_sq_bound ⟨hb.le,hbh⟩) (sq_nonneg a)
  have hid : (b^2+b^4)/a^2 = (b/a)^2+((b/a)*b)^2 := by field_simp <;> ring
  rw [hid,hratio] at h
  change (Real.artanh b/a)^2 ≤ q^2*R^2+(1/(tentHeight i.succ : ℝ))^2
  rw [div_pow]
  apply h.trans
  rw [mul_pow q R]
  linarith

theorem tentRadius_internal_cost {k : ℕ} {q : ℝ} (hq : 1 ≤ q) :
    (∑ i : Fin k, (Real.artanh (tentRadius k q i.succ)/tentRadius k q i.castSucc)^2) ≤
      q^2*((k : ℝ)+8)+4 := by
  have h := Finset.sum_le_sum (s:=Finset.univ) (fun (i : Fin k) _ => tentRadius_transition_cost hq i)
  rw [Finset.sum_add_distrib,← Finset.mul_sum] at h
  have hr := mul_le_mul_of_nonneg_left (tentHeight_ratio_sum k) (sq_nonneg q)
  have ht := tentHeight_reciprocal_sum k
  rw [Fin.sum_univ_succ] at ht
  have hright : (∑ i : Fin k, (1/(tentHeight i.succ : ℝ))^2) ≤ 4 := by
    linarith [sq_nonneg (1/(tentHeight (0 : Fin (k+1)) : ℝ))]
  linarith

/-- The whole dense scalar channel, including the shallow first-layer budget
one, fits the manuscript's 2+(L+14)q^2 budget, where L=k+3. -/
theorem tentRadius_total_cost {k : ℕ} {q : ℝ} (hq : 1 ≤ q) :
    1+channelReadoutBudget k q*(Real.artanh (tentRadius k q 0))^2+
      (∑ i : Fin k, (Real.artanh (tentRadius k q i.succ)/tentRadius k q i.castSucc)^2)+
      (1/tentRadius k q (Fin.last k))^2 ≤ 2+((k : ℝ)+17)*q^2 := by
  have hfirst := tentRadius_first_cost (k:=k) hq
  have hmiddle := tentRadius_internal_cost (k:=k) hq
  have hlast : (1/tentRadius k q (Fin.last k))^2=4*q^2 := by
    rw [tentRadius_last hq]
    field_simp
    <;> ring
  rw [hlast]
  have hq2 : 1 ≤ q^2 := one_le_pow₀ hq
  nlinarith

end NeuralGeneralization.BatchTwoContinuousDepthPaper
