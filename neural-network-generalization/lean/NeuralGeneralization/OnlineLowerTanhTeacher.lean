import NeuralGeneralization.OnlineLowerTanhTeacherGrid

/-! # An actual bounded shallow tanh teacher of width O(m d) -/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLower

theorem gridWeights_bounded {d m : ℕ} (hd : 3 ≤ d)
    (S : Fin (m+1) → Finset (Fin d)) (a : Fin (m+1) → ℝ)
    (ha : ∀ i, |a i| ≤ (m:ℝ)+1) :
    boundedWeights (teacherWidth d m) (gridWeights S a m) := by
  have hC : (teacherWidth d m : ℝ) = ((m:ℝ)+1)*((d:ℝ)+1) := by
    unfold teacherWidth
    push_cast
    rfl
  have hdR : (3:ℝ) ≤ d := by exact_mod_cast hd
  have hmR : (0:ℝ) ≤ m := Nat.cast_nonneg _
  have hconst : |(1+(-1:ℝ)^d)/2/Real.tanh 1| ≤ 2 := by
    have htp : 0 < Real.tanh 1 := lt_trans (by norm_num) ParityNetwork.tanh_one_gt_half
    rw [abs_div, abs_of_pos htp]
    apply (div_le_iff₀ htp).mpr
    have hab : |(1+(-1:ℝ)^d)/2| ≤ 1 := by
      rw [abs_div]
      norm_num only [abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2)]
      have hh := abs_add_le (1:ℝ) ((-1:ℝ)^d)
      simp only [abs_one,abs_neg_one_pow] at hh
      linarith
    linarith [ParityNetwork.tanh_one_gt_half]
  have hcoeff (j : Fin d) : |(((-1:ℝ)^(j.val+1)-(-1:ℝ)^j.val)/2)| ≤ 1 := by
    rw [abs_div]
    norm_num only [abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2)]
    have hh := abs_sub ((-1:ℝ)^(j.val+1)) ((-1:ℝ)^j.val)
    simp only [abs_neg_one_pow] at hh
    linarith
  intro z
  rcases z with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · let t := teacherIndex d m i
    have hSc : ((S t.1).card:ℝ) ≤ d := by exact_mod_cast (show (S t.1).card ≤ d from by simpa using Finset.card_le_univ (S t.1))
    have hSc0 : (0:ℝ) ≤ (S t.1).card := Nat.cast_nonneg _
    change |(Fin.cases (Fin.cases (1:ℝ) (fun _ => 0) j)
      (fun l => Fin.cases ((m:ℝ)*((S t.1).card/2-l-1/2))
        (fun h => if h∈S t.1 then -(m:ℝ)/2 else 0) j) : Fin (d+1) → ℝ) t.2| ≤ _
    refine Fin.cases ?_ (fun l => ?_) t.2
    · simp only [Fin.cases_zero]
      refine Fin.cases ?_ (fun h => ?_) j
      · simp only [Fin.cases_zero,abs_one]
        rw [hC]
        nlinarith
      · simp only [Fin.cases_succ,abs_zero]
        exact Nat.cast_nonneg _
    · simp only [Fin.cases_succ]
      have hl : (l:ℝ) < d := by exact_mod_cast l.isLt
      have hl0 : (0:ℝ) ≤ l.val := Nat.cast_nonneg _
      refine Fin.cases ?_ (fun h => ?_) j
      · simp only [Fin.cases_zero,abs_mul,abs_of_nonneg hmR]
        have hb : |((S t.1).card:ℝ)/2-l-1/2| ≤ (d:ℝ)+1 := by
          apply abs_le.mpr
          constructor <;> linarith
        calc
          _ ≤ (m:ℝ)*((d:ℝ)+1) := mul_le_mul_of_nonneg_left hb hmR
          _ ≤ _ := by rw [hC]; nlinarith
      · simp only [Fin.cases_succ]
        split_ifs
        · rw [abs_div,abs_neg,abs_of_nonneg hmR,hC]
          norm_num only [abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2)]
          nlinarith
        · simp only [abs_zero]
          exact Nat.cast_nonneg _
  · exact Fin.elim0 s
  · let t := teacherIndex d m i
    change |2*a t.1 * Fin.cases ((1+(-1:ℝ)^d)/2/Real.tanh 1)
      (fun j => (((-1:ℝ)^(j.val+1)-(-1:ℝ)^j.val)/2)) t.2| ≤ _
    rw [abs_mul,abs_mul]
    norm_num only [abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2)]
    have hb : |(Fin.cases ((1+(-1:ℝ)^d)/2/Real.tanh 1)
      (fun j => (((-1:ℝ)^(j.val+1)-(-1:ℝ)^j.val)/2)) : Fin (d+1) → ℝ) t.2| ≤ (2:ℝ) := by
      refine Fin.cases hconst (fun j => (hcoeff j).trans (by norm_num)) t.2
    calc
      _ ≤ (2*((m:ℝ)+1))*2 := mul_le_mul
        (mul_le_mul_of_nonneg_left (ha t.1) (by norm_num)) hb (abs_nonneg _) (by positivity)
      _ ≤ _ := by rw [hC]; nlinarith

theorem gridWeights_uniform_error {d m : ℕ}
    (S : Fin (m+1) → Finset (Fin d)) (a : Fin (m+1) → ℝ)
    (ha : ∀ i, |a i| ≤ (m:ℝ)+1) (x : Cube d) :
    |networkOutput Real.tanh (gridWeights S a m) x - 2*∑ i,a i*walshCharacter (S i) x| ≤
      4*((m:ℝ)+1)^2*(d:ℝ)*Real.exp (-(m:ℝ)) := by
  rw [gridWeights_output]
  have he (i : Fin (m+1)) :
      |gridInterpolant m (fun j => (-1:ℝ)^j) d (OnlineLower.falseCount (S i) x) -
        walshCharacter (S i) x| ≤ 2*(d:ℝ)*Real.exp (-(m:ℝ)) := by
    rw [OnlineLower.walsh_eq_falseCount]
    exact gridInterpolant_error m (Nat.cast_nonneg _) _ (fun j => by simp)
      (OnlineLower.falseCount_le (S i) x)
  rw [←mul_sub,abs_mul]
  norm_num only [abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2)]
  rw [←Finset.sum_sub_distrib]
  calc
    _ ≤ 2*∑ i, |a i*gridInterpolant m (fun j => (-1:ℝ)^j) d (OnlineLower.falseCount (S i) x) -
        a i*walshCharacter (S i) x| :=
      mul_le_mul_of_nonneg_left (Finset.abs_sum_le_sum_abs _ _) (by norm_num)
    _ ≤ 2*∑ _i : Fin (m+1), ((m:ℝ)+1)*(2*(d:ℝ)*Real.exp (-(m:ℝ))) := by
      apply mul_le_mul_of_nonneg_left _ (by norm_num)
      apply Finset.sum_le_sum
      intro i hi
      rw [←mul_sub,abs_mul]
      exact mul_le_mul (ha i) (he i) (abs_nonneg _) (by positivity)
    _ = _ := by simp; ring

def parityAndWeights {d m : ℕ} (A0 : Finset (Fin d)) (A : Fin m → Finset (Fin d)) :
    Weights d (teacherWidth d m) 0 :=
  gridWeights (Fin.cases A0 A) (Fin.cases (-((m:ℝ)-1)) (fun _ => 1)) m

/-- No parameter magnitude is hidden in this teacher bound. The explicit
exponential inequality is eventually satisfied whenever d is polynomial in m. -/
theorem parityAnd_boundedTeacher {d m : ℕ} (hd : 3 ≤ d)
    (hsmall : 4*((m:ℝ)+1)^2*(d:ℝ) ≤ Real.exp (m:ℝ))
    (A0 : Finset (Fin d)) (A : Fin m → Finset (Fin d)) :
    BoundedTeacher Real.tanh (parityAndTarget A0 A) (teacherWidth d m) := by
  have ha : ∀ i : Fin (m+1), |Fin.cases (-((m:ℝ)-1)) (fun _ => 1) i| ≤ (m:ℝ)+1 := by
    intro i
    refine Fin.cases ?_ (fun j => ?_) i
    · simp only [Fin.cases_zero,abs_neg]
      exact abs_le.mpr ⟨by linarith [Nat.cast_nonneg (α:=ℝ) m],by linarith⟩
    · simp only [Fin.cases_succ,abs_one]
      linarith [Nat.cast_nonneg (α:=ℝ) m]
  refine ⟨by unfold teacherWidth; exact Nat.mul_pos (Nat.succ_pos _) (Nat.succ_pos _), parityAndWeights A0 A, ?_, ?_⟩
  · intro x
    have herr := gridWeights_uniform_error (Fin.cases A0 A) (Fin.cases (-((m:ℝ)-1)) (fun _ => 1)) ha x
    have hs : (∑ i : Fin (m+1), Fin.cases (-((m:ℝ)-1)) (fun _ => 1) i *
        walshCharacter (Fin.cases A0 A i) x) = parityAndScore A0 A x := by
      simp [Fin.sum_univ_succ,parityAndScore]
      ring
    rw [hs] at herr
    have hb : 4*((m:ℝ)+1)^2*(d:ℝ)*Real.exp (-(m:ℝ)) ≤ 1 := by
      rw [Real.exp_neg,←div_eq_mul_inv]
      exact (div_le_one (Real.exp_pos _)).mpr hsmall
    have he := abs_le.mp (herr.trans hb)
    have hm := parityAndTarget_margin A0 A x
    cases hx : parityAndTarget A0 A x <;>
      simp only [hx,labelReal_false,labelReal_true] at * <;>
      change 1 ≤ _ <;> dsimp only [parityAndWeights] <;> nlinarith
  · exact gridWeights_bounded hd _ _ ha

end NeuralGeneralization.OnlineLowerTanh
