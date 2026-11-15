import NeuralGeneralization.OnlineLowerSoftplusTeacherGrid

/-! A bounded-width, bounded-weight softplus teacher for the parity-AND targets. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerSoftplus
open ConcreteModel OnlineLower

def softSplineWeights {d m : ℕ} (G : ℝ) (S : Fin (m+1) → Finset (Fin d))
    (a : Fin (m+1) → ℝ) : ShallowWeights d (teacherWidth d m)
  | Sum.inl (i,j) => G * splineWeights S a (Sum.inl (i,j))
  | Sum.inr (Sum.inl (s,_,_)) => Fin.elim0 s
  | Sum.inr (Sum.inr i) => (2/G) * splineWeights S a (Sum.inr (Sum.inr i))

lemma softSplineWeights_firstHidden {d m : ℕ} (G : ℝ)
    (S : Fin (m+1) → Finset (Fin d)) (a : Fin (m+1) → ℝ)
    (x : Cube d) (i : Fin (teacherWidth d m)) :
    firstHidden softplus (softSplineWeights G S a) x i =
      let z := teacherIndex d m i
      softplus (G*((falseCount (S z.1) x : ℝ)-z.2.1.val+1-z.2.2.val)) := by
  unfold firstHidden
  apply congrArg softplus
  change (∑j : Fin (d+1), G * _ * inputVector x j) = _
  simp_rw [mul_assoc]
  rw [← Finset.mul_sum]
  exact congrArg (G*·) (count_preactivation _ _ _ _)

lemma softSplineWeights_output {d m : ℕ} (G : ℝ)
    (S : Fin (m+1) → Finset (Fin d)) (a : Fin (m+1) → ℝ) (x : Cube d) :
    networkOutput softplus (softSplineWeights G S a) x =
      2 * ∑i : Fin (m+1), a i * softParitySpline G d (falseCount (S i) x) := by
  simp only [networkOutput,finalHidden,List.finRange_zero,List.foldl_nil]
  simp_rw [softSplineWeights_firstHidden]
  change (∑i, (fun z : TeacherNeuron d m =>
    (2/G)*(a z.1*(-1:ℝ)^z.2.1.val*hatCoefficient z.2.2)*
    softplus (G*((falseCount (S z.1) x : ℝ)-z.2.1.val+1-z.2.2.val)))
    (teacherIndex d m i)) = _
  have he := (teacherIndex d m).sum_comp (fun z : TeacherNeuron d m =>
    (2/G)*(a z.1*(-1:ℝ)^z.2.1.val*hatCoefficient z.2.2)*
    softplus (G*((falseCount (S z.1) x : ℝ)-z.2.1.val+1-z.2.2.val)))
  rw [he]
  rw [Fintype.sum_prod_type,Finset.mul_sum]
  apply Finset.sum_congr rfl;intro i _
  rw [Fintype.sum_prod_type]
  unfold softParitySpline softHat
  simp_rw [Finset.mul_sum]
  apply Finset.sum_congr rfl;intro j _
  apply Finset.sum_congr rfl;intro q _;ring

lemma softSplineWeights_error {d m : ℕ} (G : ℝ) (hG : 1 ≤ G)
    (S : Fin (m+1) → Finset (Fin d)) (a : Fin (m+1) → ℝ) (x : Cube d) :
    |networkOutput softplus (softSplineWeights G S a) x-
      2*∑i : Fin (m+1),a i*walshCharacter (S i) x| ≤ (24/G)*∑i,|a i| := by
  rw [softSplineWeights_output,←mul_sub,abs_mul,(abs_of_pos (by norm_num : (0:ℝ)<2))]
  rw [←Finset.sum_sub_distrib]
  have hh : |∑i : Fin (m+1),(a i*softParitySpline G d (falseCount (S i) x)-
      a i*walshCharacter (S i) x)| ≤ (12/G)*∑i,|a i| := by
    calc
      _ ≤ ∑i : Fin (m+1),|a i*softParitySpline G d (falseCount (S i) x)-
        a i*walshCharacter (S i) x| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑i : Fin (m+1),|a i| *(12/G) := by
        apply Finset.sum_le_sum;intro i _
        rw [←mul_sub,abs_mul,←paritySpline_falseCount]
        exact mul_le_mul_of_nonneg_left (softParitySpline_error G hG d _) (abs_nonneg _)
      _ = (12/G)*∑i,|a i| := by rw [←Finset.sum_mul];ring
  calc
    _ ≤ 2*((12/G)*∑i,|a i|) := mul_le_mul_of_nonneg_left hh (by norm_num)
    _ = _ := by ring

lemma softSplineWeights_bounded {d m : ℕ} (hm : 1 ≤ m)
    (S : Fin (m+1) → Finset (Fin d)) (a : Fin (m+1) → ℝ)
    (ha : ∀i,|a i| ≤ (m:ℝ)+1) :
    boundedWeights (24*teacherWidth d m) (softSplineWeights (64*m) S a) := by
  have hmr : (1:ℝ) ≤ m := by exact_mod_cast hm
  have hd : (0:ℝ) ≤ d := Nat.cast_nonneg _
  have hC : (teacherWidth d m : ℝ)=3*((m:ℝ)+1)*((d:ℝ)+1) := by
    rw [teacherWidth_eq];push_cast;ring
  intro z
  rcases z with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · let t := teacherIndex d m i
    have hn : ((S t.1).card : ℝ) ≤ d := by
      exact_mod_cast (show (S t.1).card ≤ d from by simpa using Finset.card_le_univ (S t.1))
    have hn0 : (0:ℝ) ≤ (S t.1).card := Nat.cast_nonneg _
    have hj : (t.2.1.val : ℝ) ≤ d := by exact_mod_cast Nat.le_of_lt_succ t.2.1.isLt
    have hj0 : (0:ℝ) ≤ t.2.1.val := Nat.cast_nonneg _
    have hq : (t.2.2.val : ℝ) ≤ 2 := by exact_mod_cast Nat.le_of_lt_succ t.2.2.isLt
    have hq0 : (0:ℝ) ≤ t.2.2.val := Nat.cast_nonneg _
    change |(64*(m:ℝ))*((Fin.cases (((S t.1).card : ℝ)/2-(t.2.1.val : ℝ)+1-(t.2.2.val : ℝ))
      (fun l => if l ∈ S t.1 then -(1/2:ℝ) else 0) : Fin (d+1) → ℝ) j)| ≤ _
    have hb : |((Fin.cases (((S t.1).card : ℝ)/2-(t.2.1.val : ℝ)+1-(t.2.2.val : ℝ))
      (fun l => if l ∈ S t.1 then -(1/2:ℝ) else 0) : Fin (d+1) → ℝ) j)| ≤ (d:ℝ)+1 := by
      refine Fin.cases ?_ (fun l => ?_) j
      · simp only [Fin.cases_zero];exact abs_le.mpr ⟨by linarith,by linarith⟩
      · simp only [Fin.cases_succ];split_ifs <;> norm_num <;> linarith
    rw [abs_mul,abs_of_nonneg (by positivity : 0 ≤ 64*(m:ℝ))]
    have hb' := mul_le_mul_of_nonneg_left hb (by positivity : 0 ≤ 64*(m:ℝ))
    rw [hC]
    nlinarith
  · exact Fin.elim0 s
  · change |(2/(64*(m:ℝ)))*(a (teacherIndex d m i).1*(-1:ℝ)^(teacherIndex d m i).2.1.val*
        hatCoefficient (teacherIndex d m i).2.2)| ≤ _
    rw [abs_mul,abs_of_nonneg (by positivity : 0 ≤ 2/(64*(m:ℝ))),abs_mul,abs_mul,abs_neg_one_pow,mul_one]
    have hcoef : |a (teacherIndex d m i).1| *|hatCoefficient (teacherIndex d m i).2.2| ≤ ((m:ℝ)+1)*2 :=
      mul_le_mul (ha _) (hatCoefficient_abs _) (abs_nonneg _) (by positivity)
    have hone : (2/(64*(m:ℝ)))*(((m:ℝ)+1)*2) ≤ 1 := by
      rw [div_mul_eq_mul_div]
      apply (div_le_iff₀ (by positivity : 0 < 64*(m:ℝ))).mpr
      nlinarith
    have hbound := mul_le_mul_of_nonneg_left hcoef (by positivity : 0 ≤ 2/(64*(m:ℝ)))
    rw [hC]
    nlinarith

lemma parityAnd_coefficients_abs_sum {m : ℕ} (hm : 1 ≤ m) :
    (∑i : Fin (m+1), |(Fin.cases (-((m:ℝ)-1)) (fun _ => 1) : Fin (m+1) → ℝ) i|) ≤ 2*m := by
  have hmr : (1:ℝ) ≤ m := by exact_mod_cast hm
  rw [Fin.sum_univ_succ]
  simp only [Fin.cases_zero,Fin.cases_succ,abs_neg,abs_one,Finset.sum_const,
    Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_one]
  rw [abs_of_nonneg (by linarith : 0 ≤ (m:ℝ)-1)]
  linarith

theorem softplus_parityAnd_bounded_teacher {d m : ℕ} (hm : 1 ≤ m)
    (A0 : Finset (Fin d)) (A : Fin m → Finset (Fin d)) :
    ∃w : ShallowWeights d (teacherWidth d m),
      (∀x : Cube d,1 < labelReal (parityAndTarget A0 A x)*networkOutput softplus w x) ∧
      boundedWeights (24*teacherWidth d m) w := by
  let S : Fin (m+1) → Finset (Fin d) := Fin.cases A0 A
  let a : Fin (m+1) → ℝ := Fin.cases (-((m:ℝ)-1)) (fun _ => 1)
  refine ⟨softSplineWeights (64*m) S a, ?_, ?_⟩
  · intro x
    have hmr : (1:ℝ) ≤ m := by exact_mod_cast hm
    have hg : (1:ℝ) ≤ 64*(m:ℝ) := by linarith
    have herr := softSplineWeights_error (64*m) hg S a x
    have he : (∑i : Fin (m+1), a i*walshCharacter (S i) x) = parityAndScore A0 A x := by
      simp [a,S,Fin.sum_univ_succ,parityAndScore]
      ring
    rw [he] at herr
    have habs := parityAnd_coefficients_abs_sum hm
    change (∑i : Fin (m+1),|a i|) ≤ 2*(m:ℝ) at habs
    have herr' : |networkOutput softplus (softSplineWeights (64*m) S a) x-
      2*parityAndScore A0 A x| ≤ 3/4 := by
      calc
        _ ≤ (24/(64*(m:ℝ)))*∑i,|a i| := herr
        _ ≤ (24/(64*(m:ℝ)))*(2*(m:ℝ)) :=
          mul_le_mul_of_nonneg_left habs (by positivity)
        _ = _ := by field_simp;ring
    have hmargin := parityAndTarget_margin A0 A x
    have hlo := (abs_le.mp herr').1
    have hhi := (abs_le.mp herr').2
    cases ht : parityAndTarget A0 A x <;> simp [ht,labelReal] at hmargin ⊢ <;> linarith
  · apply softSplineWeights_bounded hm
    intro i
    refine Fin.cases ?_ (fun j => ?_) i
    · dsimp [a]
      rw [abs_neg]
      apply abs_le.mpr
      constructor <;> have h := Nat.cast_nonneg (α:=ℝ) m <;> linarith
    · simp [a]


end NeuralGeneralization.OnlineLowerSoftplus
