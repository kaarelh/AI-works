import NeuralGeneralization.OnlineLowerTeacherModel
import Mathlib.Algebra.BigOperators.Fin
import NeuralGeneralization.WalshLaplacian
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.FinCases
import Mathlib.Data.Fintype.EquivFin
import Mathlib.Analysis.SpecialFunctions.Pow.Real

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLower
open ConcreteModel

def relu (t : ℝ) : ℝ := max 0 t

def hat (j : ℕ) (t : ℝ) : ℝ :=
  relu (t - j + 1) - 2 * relu (t - j) + relu (t - j - 1)

theorem hat_nat (j k : ℕ) : hat j k = if k = j then 1 else 0 := by
  by_cases h : k = j
  · subst k
    simp [hat, relu]
  · rw [if_neg h]
    rcases lt_or_gt_of_ne h with hlt | hgt
    · have hle : (k : ℝ) + 1 ≤ j := by exact_mod_cast hlt
      simp only [hat, relu]
      rw [max_eq_left (by linarith), max_eq_left (by linarith),
        max_eq_left (by linarith)]
      ring
    · have hle : (j : ℝ) + 1 ≤ k := by exact_mod_cast hgt
      simp only [hat, relu]
      rw [max_eq_right (by linarith), max_eq_right (by linarith),
        max_eq_right (by linarith)]
      ring

def falseCount {d : ℕ} (S : Finset (Fin d)) (x : Cube d) : ℕ :=
  (S.filter (fun i => x i = false)).card

theorem falseCount_le {d : ℕ} (S : Finset (Fin d)) (x : Cube d) :
    falseCount S x ≤ d := by
  exact le_trans (Finset.card_filter_le _ _) (by simpa using Finset.card_le_univ S)

theorem walsh_eq_falseCount {d : ℕ} (S : Finset (Fin d)) (x : Cube d) :
    walshCharacter S x = (-1 : ℝ) ^ falseCount S x := by
  classical
  induction S using Finset.induction_on with
  | empty => simp [walshCharacter, falseCount]
  | @insert a S ha ih =>
    cases hx : x a <;>
      simp [walshCharacter, falseCount, Finset.prod_insert, ha, hx,
        cubeCoordinateSign, Finset.filter_insert, ih, pow_succ] at *
    · exact_mod_cast ih
    · exact_mod_cast ih

theorem falseCount_affine {d : ℕ} (S : Finset (Fin d)) (x : Cube d) :
    (falseCount S x : ℝ) = ∑ i ∈ S, (1 - labelReal (x i)) / 2 := by
  classical
  induction S using Finset.induction_on with
  | empty => simp [falseCount]
  | @insert a S ha ih =>
    cases hx : x a <;>
      simp [falseCount, Finset.filter_insert, ha, hx, Finset.sum_insert,
        labelReal] at * <;> linarith

def paritySpline (d : ℕ) (t : ℝ) : ℝ :=
  ∑ j : Fin (d + 1), (-1 : ℝ)^j.val * hat j.val t

theorem paritySpline_nat {d k : ℕ} (hk : k ≤ d) :
    paritySpline d k = (-1 : ℝ)^k := by
  classical
  unfold paritySpline
  rw [Finset.sum_eq_single (⟨k, by omega⟩ : Fin (d+1))]
  · simp [hat_nat]
  · intro j hj hne
    have hkj : k ≠ j.val := by
      intro h
      apply hne
      apply Fin.ext
      exact h.symm
    simp [hat_nat, hkj]
  · simp

theorem paritySpline_falseCount {d : ℕ} (S : Finset (Fin d)) (x : Cube d) :
    paritySpline d (falseCount S x) = walshCharacter S x := by
  rw [paritySpline_nat (falseCount_le S x), walsh_eq_falseCount]


abbrev TeacherNeuron (d m : ℕ) := Fin (m+1) × Fin (d+1) × Fin 3

def teacherWidth (d m : ℕ) : ℕ := Fintype.card (TeacherNeuron d m)

theorem teacherWidth_eq (d m : ℕ) :
    teacherWidth d m = 3 * (m+1) * (d+1) := by
  simp [teacherWidth, TeacherNeuron]
  ring

def teacherIndex (d m : ℕ) : Fin (teacherWidth d m) ≃ TeacherNeuron d m :=
  (Fintype.equivFin (TeacherNeuron d m)).symm

def hatCoefficient (q : Fin 3) : ℝ := if q.val = 1 then -2 else 1

theorem hat_sum (j : ℕ) (t : ℝ) :
    (∑ q : Fin 3, hatCoefficient q * relu (t - j + 1 - q.val)) = hat j t := by
  have he : t - (j : ℝ) + 1 - 2 = t - j - 1 := by ring
  simp [Fin.sum_univ_succ, hatCoefficient, hat, he]
  ring

def splineWeights {d m : ℕ} (S : Fin (m+1) → Finset (Fin d))
    (a : Fin (m+1) → ℝ) : ShallowWeights d (teacherWidth d m)
  | Sum.inl (i,j) =>
      let z := teacherIndex d m i
      Fin.cases ((S z.1).card / 2 - z.2.1.val + 1 - z.2.2.val)
        (fun l => if l ∈ S z.1 then -(1/2 : ℝ) else 0) j
  | Sum.inr (Sum.inl (s,_,_)) => Fin.elim0 s
  | Sum.inr (Sum.inr i) =>
      let z := teacherIndex d m i
      a z.1 * (-1 : ℝ)^z.2.1.val * hatCoefficient z.2.2

theorem count_preactivation {d : ℕ} (S : Finset (Fin d)) (x : Cube d)
    (j : ℕ) (q : Fin 3) :
    (∑ l : Fin (d+1),
      Fin.cases ((S.card : ℝ)/2 - j + 1 - q.val)
        (fun i => if i ∈ S then -(1/2 : ℝ) else 0) l * inputVector x l) =
      (falseCount S x : ℝ) - j + 1 - q.val := by
  classical
  simp only [Fin.sum_univ_succ, Fin.cases_zero, inputVector, Fin.cases_succ,
    one_mul, mul_one]
  have hs : (∑ i : Fin d, (if i ∈ S then -(1/2 : ℝ) else 0) * labelReal (x i)) =
      ∑ i ∈ S, -(1/2 : ℝ) * labelReal (x i) := by
    simp only [ite_mul, zero_mul]
    rw [Finset.sum_ite_mem]
    simp
  rw [hs, falseCount_affine]
  have hc : (S.card : ℝ)/2 = ∑ _i ∈ S, (1/2 : ℝ) := by simp; ring
  have hh : (∑ _i ∈ S, (1/2 : ℝ)) + (∑ i ∈ S, -(1/2 : ℝ) * labelReal (x i)) =
      ∑ i ∈ S, (1 - labelReal (x i))/2 := by
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i hi
    ring
  rw [hc]
  linarith

theorem splineWeights_firstHidden {d m : ℕ}
    (S : Fin (m+1) → Finset (Fin d)) (a : Fin (m+1) → ℝ)
    (x : Cube d) (i : Fin (teacherWidth d m)) :
    firstHidden relu (splineWeights S a) x i =
      let z := teacherIndex d m i
      relu ((falseCount (S z.1) x : ℝ) - z.2.1.val + 1 - z.2.2.val) := by
  unfold firstHidden
  exact congrArg relu (count_preactivation _ _ _ _)

theorem splineWeights_output {d m : ℕ}
    (S : Fin (m+1) → Finset (Fin d)) (a : Fin (m+1) → ℝ)
    (x : Cube d) :
    networkOutput relu (splineWeights S a) x =
      ∑ i : Fin (m+1), a i * walshCharacter (S i) x := by
  classical
  simp only [networkOutput, finalHidden, List.finRange_zero, List.foldl_nil]
  simp_rw [splineWeights_firstHidden]
  change (∑ i, (fun z : TeacherNeuron d m =>
    a z.1 * (-1 : ℝ)^z.2.1.val * hatCoefficient z.2.2 *
    relu ((falseCount (S z.1) x : ℝ) - z.2.1.val + 1 - z.2.2.val))
    (teacherIndex d m i)) = _
  have he := (teacherIndex d m).sum_comp (fun z : TeacherNeuron d m =>
    a z.1 * (-1 : ℝ)^z.2.1.val * hatCoefficient z.2.2 *
    relu ((falseCount (S z.1) x : ℝ) - z.2.1.val + 1 - z.2.2.val))
  exact he.trans (by
    rw [Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro i hi
    rw [Fintype.sum_prod_type]
    have hinner (j : Fin (d+1)) :
        (∑ q : Fin 3, a i * (-1 : ℝ)^j.val * hatCoefficient q *
          relu ((falseCount (S i) x : ℝ) - j.val + 1 - q.val)) =
        a i * ((-1 : ℝ)^j.val * hat j.val (falseCount (S i) x)) := by
      simp_rw [mul_assoc]
      rw [← Finset.mul_sum, ← Finset.mul_sum, hat_sum]
    simp_rw [hinner]
    rw [← Finset.mul_sum]
    exact congrArg (fun t => a i * t) (paritySpline_falseCount (S i) x))


theorem hatCoefficient_abs (q : Fin 3) : |hatCoefficient q| ≤ 2 := by
  fin_cases q <;> norm_num [hatCoefficient]

theorem splineWeights_bounded {d m : ℕ}
    (S : Fin (m+1) → Finset (Fin d)) (a : Fin (m+1) → ℝ)
    (ha : ∀ i, |a i| ≤ (m : ℝ)+1) :
    boundedWeights (teacherWidth d m) (splineWeights S a) := by
  classical
  have hC : (teacherWidth d m : ℝ) = 3*((m : ℝ)+1)*((d : ℝ)+1) := by
    rw [teacherWidth_eq]
    push_cast
    ring
  have hm : (0 : ℝ) ≤ m := Nat.cast_nonneg _
  have hd : (0 : ℝ) ≤ d := Nat.cast_nonneg _
  intro z
  rcases z with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · let t := teacherIndex d m i
    have hn : ((S t.1).card : ℝ) ≤ d := by
      exact_mod_cast (show (S t.1).card ≤ d from by simpa using Finset.card_le_univ (S t.1))
    have hn0 : (0 : ℝ) ≤ (S t.1).card := Nat.cast_nonneg _
    have hj : (t.2.1.val : ℝ) ≤ d := by exact_mod_cast Nat.le_of_lt_succ t.2.1.isLt
    have hj0 : (0 : ℝ) ≤ t.2.1.val := Nat.cast_nonneg _
    have hq : (t.2.2.val : ℝ) ≤ 2 := by exact_mod_cast Nat.le_of_lt_succ t.2.2.isLt
    have hq0 : (0 : ℝ) ≤ t.2.2.val := Nat.cast_nonneg _
    change |(Fin.cases (((S t.1).card : ℝ) / 2 - (t.2.1.val : ℝ) + 1 - (t.2.2.val : ℝ))
      (fun l => if l ∈ S t.1 then -(1/2 : ℝ) else 0) : Fin (d+1) → ℝ) j| ≤ _
    refine Fin.cases ?_ (fun l => ?_) j
    · simp only [Fin.cases_zero]
      rw [hC]
      apply abs_le.mpr
      constructor <;> nlinarith
    · simp only [Fin.cases_succ]
      split_ifs <;> norm_num <;> rw [hC] <;> nlinarith
  · exact Fin.elim0 s
  · change |a (teacherIndex d m i).1 * (-1 : ℝ)^(teacherIndex d m i).2.1.val *
        hatCoefficient (teacherIndex d m i).2.2| ≤ _
    rw [abs_mul, abs_mul, abs_neg_one_pow, mul_one]
    calc
      _ ≤ ((m : ℝ)+1)*2 := mul_le_mul (ha _) (hatCoefficient_abs _)
        (abs_nonneg _) (by positivity)
      _ ≤ (teacherWidth d m : ℝ) := by rw [hC]; nlinarith

def parityAndScore {d m : ℕ} (A0 : Finset (Fin d))
    (A : Fin m → Finset (Fin d)) (x : Cube d) : ℝ :=
  (∑ i, walshCharacter (A i) x) - ((m : ℝ)-1)*walshCharacter A0 x

def parityAndTarget {d m : ℕ} (A0 : Finset (Fin d))
    (A : Fin m → Finset (Fin d)) (x : Cube d) : Bool :=
  decide (0 ≤ parityAndScore A0 A x)

theorem square_one_abs {t : ℝ} (ht : t^2 = 1) : |t| = 1 := by
  have h : (t-1)*(t+1) = 0 := by nlinarith
  rcases mul_eq_zero.mp h with h | h
  · have : t = 1 := by linarith
    simp [this]
  · have : t = -1 := by linarith
    simp [this]

theorem parityAndScore_margin {d m : ℕ} (A0 : Finset (Fin d))
    (A : Fin m → Finset (Fin d)) (x : Cube d) :
    1 ≤ |parityAndScore A0 A x| := by
  classical
  let b := walshCharacter A0 x
  let y : Fin m → ℝ := fun i => b * walshCharacter (A i) x
  have hb : b^2 = 1 := walshCharacter_sq A0 x
  have hy (i : Fin m) : (y i)^2 = 1 := by
    dsimp [y]
    rw [mul_pow, hb, walshCharacter_sq, one_mul]
  have hyle (i : Fin m) : y i ≤ 1 := by nlinarith [hy i]
  have hs : b * parityAndScore A0 A x = (∑ i, y i) - ((m : ℝ)-1) := by
    dsimp only [parityAndScore, y]
    change b * ((∑ i, walshCharacter (A i) x) - ((m : ℝ)-1)*b) = _
    rw [mul_sub, Finset.mul_sum]
    have hb2 : b*b=1 := by nlinarith [hb]
    calc
      _ = (∑ i, b * walshCharacter (A i) x) - ((m : ℝ)-1)*(b*b) := by ring
      _ = _ := by rw [hb2, mul_one]
  have habs : |b| = 1 := square_one_abs hb
  have htotal : 1 ≤ |b * parityAndScore A0 A x| := by
    by_cases hall : ∀ i, y i = 1
    · rw [hs]
      simp [hall]
    · push_neg at hall
      obtain ⟨j,hj⟩ := hall
      have hjneg : y j = -1 := by
        have hprod : (y j-1)*(y j+1)=0 := by nlinarith [hy j]
        rcases mul_eq_zero.mp hprod with h | h
        · exact (hj (by linarith)).elim
        · linarith
      have hsum : (∑ i, y i) ≤ (m : ℝ)-2 := by
        calc
          (∑ i, y i) ≤ ∑ i : Fin m, (1 - 2*(if i=j then 1 else 0) : ℝ) := by
            apply Finset.sum_le_sum
            intro i hi
            by_cases h : i=j
            · subst i
              norm_num [hjneg]
            · simp [h]
              exact hyle i
          _ = (m : ℝ)-2 := by
            rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
            simp
      have hneg : b * parityAndScore A0 A x ≤ -1 := by rw [hs]; linarith
      exact le_trans (by linarith : (1 : ℝ) ≤ -(b * parityAndScore A0 A x)) (neg_le_abs _)
  simpa [abs_mul, habs] using htotal

theorem parityAndTarget_margin {d m : ℕ} (A0 : Finset (Fin d))
    (A : Fin m → Finset (Fin d)) (x : Cube d) :
    1 ≤ labelReal (parityAndTarget A0 A x) * parityAndScore A0 A x := by
  have h := parityAndScore_margin A0 A x
  by_cases hs : 0 ≤ parityAndScore A0 A x
  · simpa [parityAndTarget, labelReal, hs, abs_of_nonneg hs] using h
  · have hneg := lt_of_not_ge hs
    simpa [parityAndTarget, labelReal, hs, abs_of_neg hneg] using h

def parityAndWeights {d m : ℕ} (A0 : Finset (Fin d))
    (A : Fin m → Finset (Fin d)) : ShallowWeights d (teacherWidth d m) :=
  splineWeights (Fin.cases A0 A) (Fin.cases (-((m : ℝ)-1)) (fun _ => 1))

theorem parityAndWeights_output {d m : ℕ} (A0 : Finset (Fin d))
    (A : Fin m → Finset (Fin d)) (x : Cube d) :
    networkOutput relu (parityAndWeights A0 A) x = parityAndScore A0 A x := by
  rw [parityAndWeights, splineWeights_output]
  simp [Fin.sum_univ_succ, parityAndScore]
  ring

theorem parityAnd_boundedTeacher {d m : ℕ} (A0 : Finset (Fin d))
    (A : Fin m → Finset (Fin d)) :
    BoundedTeacher relu (parityAndTarget A0 A) (teacherWidth d m) := by
  refine ⟨?_, parityAndWeights A0 A, ?_, ?_⟩
  · rw [teacherWidth_eq]
    have : 0 < 3*(m+1)*(d+1) := by positivity
    omega
  · intro x
    rw [parityAndWeights_output]
    exact parityAndTarget_margin A0 A x
  · apply splineWeights_bounded
    intro i
    refine Fin.cases ?_ (fun j => ?_) i
    · simp only [Fin.cases_zero]
      rw [abs_neg]
      apply abs_le.mpr
      constructor <;> linarith [Nat.cast_nonneg (α := ℝ) m]
    · simp only [Fin.cases_succ, abs_one]
      linarith [Nat.cast_nonneg (α := ℝ) m]


/-- The literal padded teacher has quadratic width whenever physical dimension
is at most a fixed multiple of the logical dimension. -/
theorem teacherWidth_quadratic {d m K : ℕ} (hm : 1 ≤ m) (hd : d ≤ K*m) :
    teacherWidth d m ≤ 6*(K+1)*m^2 := by
  rw [teacherWidth_eq]
  have hm1 : m+1 ≤ 2*m := by omega
  have hd1 : d+1 ≤ (K+1)*m := by nlinarith
  calc
    3*(m+1)*(d+1) ≤ 3*(2*m)*((K+1)*m) :=
      Nat.mul_le_mul (Nat.mul_le_mul_left 3 hm1) hd1
    _ = 6*(K+1)*m^2 := by ring

/-- A finite, pointwise resource inversion; this contains no asymptotic or
network hypothesis in place of a conclusion. It is used after the concrete
construction supplies its quadratic width and exponential number of rounds. -/
theorem exponential_sqrt_resource {C A k b T : ℝ}
    (hC : 0 ≤ C) (hA : 0 < A) (hk : 0 ≤ k) (hb : 0 < b)
    (hwidth : C ≤ A*k^2) (hrounds : Real.exp (b*k) ≤ T) :
    Real.exp ((b/Real.sqrt A)*Real.sqrt C) ≤ T := by
  have hsA : 0 < Real.sqrt A := Real.sqrt_pos.2 hA
  have hsC : 0 ≤ Real.sqrt C := Real.sqrt_nonneg _
  have hprod : (Real.sqrt A*k)^2 = A*k^2 := by
    rw [mul_pow, Real.sq_sqrt hA.le]
  have hsprod : 0 ≤ Real.sqrt A*k := mul_nonneg hsA.le hk
  have hroot : Real.sqrt C ≤ Real.sqrt A*k := by
    nlinarith [Real.sq_sqrt hC]
  apply le_trans (Real.exp_le_exp.mpr ?_) hrounds
  calc
    (b/Real.sqrt A)*Real.sqrt C ≤ (b/Real.sqrt A)*(Real.sqrt A*k) :=
      mul_le_mul_of_nonneg_left hroot (div_nonneg hb.le hsA.le)
    _ = b*k := by field_simp

end NeuralGeneralization.OnlineLower
