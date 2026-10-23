import NeuralGeneralization.BatchTwoActivationBoundedJet
import Mathlib.Analysis.SpecialFunctions.Log.Deriv

/-! A smooth approximation to the coordinate maximum with dimension-free
first derivative and logarithmic-dimension second derivative bounds. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential TanhDifferential
variable {I : Type*} [Fintype I] [Nonempty I]

def softPartition (a : ℝ) (z : I→ℝ) : ℝ :=
  ∑i, (Real.exp (a*z i)+Real.exp (-a*z i))

def softFirst (a : ℝ) (z : I→ℝ) (i : I) : ℝ :=
  (Real.exp (a*z i)-Real.exp (-a*z i))/softPartition a z

def softMass (a : ℝ) (z : I→ℝ) (i : I) : ℝ :=
  (Real.exp (a*z i)+Real.exp (-a*z i))/softPartition a z

def softSecond [DecidableEq I] (a : ℝ) (z : I→ℝ) (i j : I) : ℝ :=
  a*((if j=i then softMass a z i else 0)-softFirst a z i*softFirst a z j)

def softAbsMax (a : ℝ) (z : I→ℝ) : ℝ := Real.log (softPartition a z)/a

theorem softPartition_pos (a : ℝ) (z : I→ℝ) : 0<softPartition a z := by
  classical
  exact Finset.sum_pos (fun i _=>add_pos (Real.exp_pos _) (Real.exp_pos _)) Finset.univ_nonempty

theorem softMass_nonneg (a : ℝ) (z : I→ℝ) (i : I) : 0≤softMass a z i := by
  exact div_nonneg (by positivity) (softPartition_pos a z).le

theorem softMass_sum (a : ℝ) (z : I→ℝ) : (∑i,softMass a z i)=1 := by
  simp only [softMass,←Finset.sum_div]
  exact div_self (softPartition_pos a z).ne'

theorem softFirst_abs_le_mass (a : ℝ) (z : I→ℝ) (i : I) :
    |softFirst a z i|≤softMass a z i := by
  unfold softFirst softMass
  rw [abs_div,abs_of_pos (softPartition_pos a z)]
  exact div_le_div_of_nonneg_right (by simpa only [Real.abs_exp] using abs_sub (Real.exp (a*z i)) (Real.exp (-a*z i)))
    (softPartition_pos a z).le

theorem softFirst_sum (a : ℝ) (z : I→ℝ) : (∑i,|softFirst a z i|)≤1 := by
  calc
    _ ≤ ∑i,softMass a z i := Finset.sum_le_sum (fun i _=>softFirst_abs_le_mass a z i)
    _ = 1 := softMass_sum a z

theorem softSecond_sum [DecidableEq I] {a : ℝ} (ha : 0≤a) (z : I→ℝ) :
    (∑i,∑j,|softSecond a z i j|)≤2*a := by
  calc
    _ ≤ a*((∑i,softMass a z i)+(∑i,|softFirst a z i|)^2) := by
      simp only [softSecond,abs_mul,abs_of_nonneg ha]
      simp_rw [←Finset.mul_sum]
      apply mul_le_mul_of_nonneg_left _ ha
      calc
        _ ≤ ∑i,∑j,(|if j=i then softMass a z i else 0|+|softFirst a z i*softFirst a z j|) :=
          Finset.sum_le_sum (fun i _=>Finset.sum_le_sum (fun j _=>abs_sub _ _))
        _ = _ := by
          simp_rw [abs_mul,Finset.sum_add_distrib,←Finset.mul_sum,←Finset.sum_mul]
          simp only [sq,add_left_inj]
          apply Finset.sum_congr rfl
          intro i hi
          simp [apply_ite abs,abs_of_nonneg (softMass_nonneg a z i)]
    _ ≤ a*(1+1) := by
      apply mul_le_mul_of_nonneg_left _ ha
      rw [softMass_sum]
      have h := softFirst_sum a z
      have h0 : 0≤∑i,|softFirst a z i| := Finset.sum_nonneg (fun i _=>abs_nonneg _)
      nlinarith
    _ = _ := by ring

theorem softPartition_derivative (a : ℝ) (z : I→ℝ) :
    HasFDerivAt (softPartition a)
      (gradientLinear (fun i=>a*(Real.exp (a*z i)-Real.exp (-a*z i)))) z := by
  classical
  have hp (i : I) := (ContinuousLinearMap.proj i : (I→ℝ)→L[ℝ] ℝ).hasFDerivAt (x:=z)
  have h i := ((hp i).const_mul a).exp.add (((hp i).const_mul (-a)).exp)
  have H := HasFDerivAt.sum fun i (_ : i∈Finset.univ)=>h i
  simp only [Finset.sum_apply,Pi.add_apply,ContinuousLinearMap.proj_apply] at H
  have hf : softPartition (I:=I) a = ∑i, ((fun y:I→ℝ=>Real.exp (a*y i)) + (fun y=>Real.exp (-a*y i))) := by
    ext y; simp [softPartition]
  rw [hf]
  apply H.congr_fderiv
  ext v
  simp only [ContinuousLinearMap.sum_apply,ContinuousLinearMap.add_apply,
    ContinuousLinearMap.smul_apply,ContinuousLinearMap.proj_apply,smul_eq_mul,
    gradientLinear_apply]
  apply Finset.sum_congr rfl
  intro i hi
  ring

theorem softAbsMax_derivative {a : ℝ} (ha : a≠0) (z : I→ℝ) :
    HasFDerivAt (softAbsMax a) (gradientLinear (softFirst a z)) z := by
  unfold softAbsMax
  simp_rw [div_eq_mul_inv,mul_comm (Real.log _) a⁻¹]
  apply (((softPartition_derivative a z).log (softPartition_pos a z).ne').const_mul a⁻¹).congr_fderiv
  ext v
  simp only [ContinuousLinearMap.smul_apply,smul_eq_mul,gradientLinear_apply,
    softFirst,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  field_simp [ha]


theorem softFirst_derivative [DecidableEq I] (a : ℝ) (z : I→ℝ) (i : I) :
    HasFDerivAt (fun y=>softFirst a y i) (gradientLinear (softSecond a z i)) z := by
  have hp := (ContinuousLinearMap.proj i : (I→ℝ)→L[ℝ] ℝ).hasFDerivAt (x:=z)
  have hn := (hp.const_mul a).exp.sub (hp.const_mul (-a)).exp
  unfold softFirst
  simp_rw [div_eq_mul_inv]
  have hi := (hasDerivAt_inv (softPartition_pos a z).ne').comp_hasFDerivAt z (softPartition_derivative a z)
  apply (hn.mul hi).congr_fderiv
  ext v
  simp only [ContinuousLinearMap.smul_apply,ContinuousLinearMap.sub_apply,
    ContinuousLinearMap.add_apply,
    ContinuousLinearMap.proj_apply,smul_eq_mul,gradientLinear_apply,softSecond,
    Finset.mul_sum,mul_sub,sub_mul,Finset.sum_sub_distrib,mul_ite,ite_mul,zero_mul,
    mul_zero,Function.comp_apply,Pi.sub_apply]
  simp only [Finset.sum_ite_eq',Finset.mem_univ,if_true]
  unfold softMass softFirst
  simp only [div_eq_mul_inv]
  simp_rw [mul_assoc,←Finset.mul_sum]
  have hs : (∑j,(Real.exp (a*z j)-Real.exp (-a*z j))*((softPartition a z)⁻¹*v j))=
      (softPartition a z)⁻¹*(∑j,(Real.exp (a*z j)-Real.exp (-a*z j))*v j) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    ring
  rw [hs]
  simp only [sub_mul,Finset.sum_sub_distrib]
  field_simp [(softPartition_pos a z).ne']
  ring

theorem softSecond_continuous [DecidableEq I] (a : ℝ) (i j : I) :
    Continuous (fun z=>softSecond a z i j) := by
  have hS : Continuous (softPartition (I:=I) a) := by unfold softPartition; fun_prop
  have hM (k : I) : Continuous (fun z=>softMass a z k) :=
    (by fun_prop : Continuous (fun z:I→ℝ=>Real.exp (a*z k)+Real.exp (-a*z k))).div hS
      (fun z=>(softPartition_pos a z).ne')
  have hF (k : I) : Continuous (fun z=>softFirst a z k) :=
    (by fun_prop : Continuous (fun z:I→ℝ=>Real.exp (a*z k)-Real.exp (-a*z k))).div hS
      (fun z=>(softPartition_pos a z).ne')
  unfold softSecond
  split_ifs <;> fun_prop

theorem le_softAbsMax {a : ℝ} (ha : 0<a) (z : I→ℝ) (i : I) :
    |z i|≤softAbsMax a z := by
  have hterm : Real.exp (a*|z i|)≤softPartition a z := by
    apply le_trans _ (Finset.single_le_sum
      (fun j _=>add_nonneg (Real.exp_nonneg _) (Real.exp_nonneg _)) (Finset.mem_univ i))
    rcases le_total 0 (z i) with h | h
    · rw [abs_of_nonneg h]; exact le_add_of_nonneg_right (Real.exp_nonneg _)
    · rw [abs_of_nonpos h,mul_neg,neg_mul]
      exact le_add_of_nonneg_left (Real.exp_nonneg _)
  have hlog := Real.log_le_log (Real.exp_pos _) hterm
  rw [Real.log_exp] at hlog
  exact (le_div_iff₀ ha).2 (by simpa only [mul_comm] using hlog)

theorem softAbsMax_nonneg {a : ℝ} (ha : 0<a) (z : I→ℝ) :
    0≤softAbsMax a z :=
  (abs_nonneg (z (Classical.arbitrary I))).trans (le_softAbsMax ha z _)

theorem softAbsMax_le {a T : ℝ} (ha : 0<a) (z : I→ℝ) (hT : ∀i,|z i|≤T) :
    softAbsMax a z≤T+Real.log (2*Fintype.card I)/a := by
  have hm : (0:ℝ)<2*Fintype.card I := by exact mul_pos (by norm_num) (Nat.cast_pos.mpr Fintype.card_pos)
  have hterm : softPartition a z≤(2*Fintype.card I)*Real.exp (a*T) := by
    calc
      _ ≤ ∑i:I,(Real.exp (a*T)+Real.exp (a*T)) := by
        apply Finset.sum_le_sum
        intro i hi
        apply add_le_add <;> apply Real.exp_le_exp.mpr
        · exact mul_le_mul_of_nonneg_left ((le_abs_self _).trans (hT i)) ha.le
        · rw [neg_mul,←mul_neg]
          exact mul_le_mul_of_nonneg_left ((neg_le_abs _).trans (hT i)) ha.le
      _ = _ := by simp; ring
  have hlog := Real.log_le_log (softPartition_pos a z) hterm
  rw [Real.log_mul hm.ne' (Real.exp_ne_zero _),Real.log_exp] at hlog
  unfold softAbsMax
  apply (div_le_iff₀ ha).2
  calc
    _ ≤ Real.log (2*Fintype.card I)+a*T := hlog
    _ = _ := by field_simp; ring

end NeuralGeneralization.BatchTwoActivation
