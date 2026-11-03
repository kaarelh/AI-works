import NeuralGeneralization.RobustInputNeighborhood

/-! Sharp limitation of confident-center certificates in the unrestricted
postactivation-noise model: final hidden and output injections attain the
readout norm. No restriction to valid activation states is imposed here. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.RobustCertificates
open ConcreteModel
open BatchTwoContinuous (RealInput)
variable {d N r : ℕ}

def lastShift (h : Fin N → ℝ) (a : ℝ) : NetworkDisturbance N r :=
  (fun s i => if s.val = r then h i else 0,a)

lemma lastShift_budget (h : Fin N → ℝ) (a : ℝ) :
    noiseBudgetSq (lastShift (r := r) h a) = (∑ i,h i^2)/(N:ℝ)+a^2 := by
  unfold noiseBudgetSq lastShift
  rw [Fin.sum_univ_castSucc]
  have hn (i : Fin r) : i.val ≠ r := Nat.ne_of_lt i.isLt
  simp [hn]

lemma realNoisyOutput_lastShift (φ : ℝ → ℝ) (w : Weights d N r) (x : RealInput d)
    (h : Fin N → ℝ) (a : ℝ) :
    realNoisyOutput φ w x (lastShift h a) =
      BatchTwoContinuous.output φ w x+(∑ i,w (.inr (.inr i))*h i)+a := by
  have hf : (List.finRange r).foldl (noisyHiddenStep φ w (lastShift h a))
      (fun i => BatchTwoContinuous.firstHidden φ w x i+(lastShift (r := r) h a).1 0 i) =
      fun i => BatchTwoContinuous.finalHidden φ w x i+h i := by
    cases r with
    | zero => simp [BatchTwoContinuous.finalHidden,lastShift]
    | succ r =>
      have hs : (fun H (s : Fin r) => noisyHiddenStep φ w (lastShift h a) H s.castSucc) =
          (fun H (s : Fin r) => hiddenStep φ w H s.castSucc) := by
        funext H s i
        have hne : s.val ≠ r := Nat.ne_of_lt s.isLt
        simp [noisyHiddenStep,lastShift,hne]
      have hi : (fun i => BatchTwoContinuous.firstHidden φ w x i+(lastShift (r := r+1) h a).1 0 i) =
          BatchTwoContinuous.firstHidden φ w x := by
        funext i
        simp [lastShift]
      rw [hi]
      simp only [BatchTwoContinuous.finalHidden,List.finRange_succ_last,List.foldl_append,
        List.foldl_cons,List.foldl_nil,List.foldl_map]
      rw [hs]
      funext i
      simp [noisyHiddenStep,lastShift]
  unfold realNoisyOutput
  rw [hf]
  simp only [lastShift,mul_add,Finset.sum_add_distrib,BatchTwoContinuous.output]

/-- Explicit worst-direction disturbance; its norm is exactly R and its
signed output change is exactly -R sqrt(1+E_v). -/
def readoutAttack (w : Weights d N r) (p : Bool) (R : ℝ) : NetworkDisturbance N r :=
  lastShift (fun i => -labelReal p*R*(N:ℝ)*w (.inr (.inr i))/Real.sqrt (1+readoutEnergy w))
    (-labelReal p*R/Real.sqrt (1+readoutEnergy w))

lemma labelReal_sq (p : Bool) : (labelReal p)^2 = 1 := by cases p <;> norm_num

lemma readoutAttack_budget (hN : 0 < N) (w : Weights d N r) (p : Bool) (R : ℝ) :
    noiseBudgetSq (readoutAttack w p R) = R^2 := by
  have hden : 0 < 1+readoutEnergy w := by have hh := readoutEnergy_nonneg w; positivity
  have hN0 : (N:ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  unfold readoutAttack
  rw [lastShift_budget]
  simp only [div_pow,mul_pow,neg_sq,labelReal_sq,one_mul,Real.sq_sqrt hden.le]
  simp_rw [← Finset.sum_div,← Finset.mul_sum]
  unfold readoutEnergy
  field_simp
  ring

lemma readoutAttack_output (φ : ℝ → ℝ) (w : Weights d N r) (x : RealInput d)
    (p : Bool) (R : ℝ) :
    labelReal p*realNoisyOutput φ w x (readoutAttack w p R) =
      labelReal p*BatchTwoContinuous.output φ w x-R*Real.sqrt (1+readoutEnergy w) := by
  have hden : 0 < 1+readoutEnergy w := by have hh := readoutEnergy_nonneg w; positivity
  have hs := Real.sq_sqrt hden.le
  have hs0 : Real.sqrt (1+readoutEnergy w) ≠ 0 := (Real.sqrt_pos.mpr hden).ne'
  unfold readoutAttack
  rw [realNoisyOutput_lastShift]
  have hsum : (∑ i,w (.inr (.inr i)) *
      (-labelReal p*R*(N:ℝ)*w (.inr (.inr i))/Real.sqrt (1+readoutEnergy w))) =
      -labelReal p*R*readoutEnergy w/Real.sqrt (1+readoutEnergy w) := by
    calc
      _ = (-labelReal p*R*(N:ℝ)/Real.sqrt (1+readoutEnergy w)) *
          (∑ i,w (.inr (.inr i))^2) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro i _
        ring
      _ = _ := by unfold readoutEnergy; ring
  rw [hsum]
  field_simp
  have hR := congrArg (fun t : ℝ => R*t) hs
  cases p <;> simp only [labelReal_false,labelReal_true] at * <;> nlinarith only [hR]

/-- Any confident center certificate has the paper's radius upper bound
(in fact strictly, since the center premise uses a strict margin). -/
theorem confident_radius_upper (hN : 0 < N) (w : Weights d N r) (x : RealInput d)
    (p : Bool) (R : ℝ)
    (hcenter : ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ R^2 →
      (1/2:ℝ) < labelReal p*realNoisyOutput Real.tanh w x η) :
    R < (|BatchTwoContinuous.output Real.tanh w x|-1/2)/Real.sqrt (1+readoutEnergy w) := by
  have hh := hcenter (readoutAttack w p R) (by rw [readoutAttack_budget hN])
  rw [readoutAttack_output] at hh
  have hm : labelReal p*BatchTwoContinuous.output Real.tanh w x ≤
      |BatchTwoContinuous.output Real.tanh w x| := by
    calc
      _ ≤ |labelReal p*BatchTwoContinuous.output Real.tanh w x| := le_abs_self _
      _ = _ := by rw [abs_mul,abs_labelReal,one_mul]
  have hden : 0 < Real.sqrt (1+readoutEnergy w) := by
    apply Real.sqrt_pos.mpr
    have he := readoutEnergy_nonneg w
    positivity
  apply (lt_div_iff₀ hden).mpr
  linarith

#print axioms confident_radius_upper
end NeuralGeneralization.RobustCertificates
