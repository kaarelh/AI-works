import NeuralGeneralization.BatchTwoActivationSoftMaximum
import NeuralGeneralization.BatchTwoActivationScalarBump

/-! Global smooth row cutoffs. The derivative sums depend on the number of
coordinates only through `log (2 * card I)`. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential TanhDifferential
variable {I : Type*} [Fintype I] [Nonempty I] [DecidableEq I]

def smoothCutoff (a T : ℝ) (z : I→ℝ) : ℝ := scalarCutoff (softAbsMax a z/T)

def smoothCutoffFirst (a T : ℝ) (z : I→ℝ) (i : I) : ℝ :=
  deriv scalarCutoff (softAbsMax a z/T)/T*softFirst a z i

def smoothCutoffSecond (a T : ℝ) (z : I→ℝ) (i j : I) : ℝ :=
  deriv (deriv scalarCutoff) (softAbsMax a z/T)/T^2*softFirst a z i*softFirst a z j+
  deriv scalarCutoff (softAbsMax a z/T)/T*softSecond a z i j

theorem smoothCutoff_derivative {a : ℝ} (ha : a≠0) (T : ℝ) (z : I→ℝ) :
    HasFDerivAt (smoothCutoff a T) (gradientLinear (smoothCutoffFirst a T z)) z := by
  have hs := (softAbsMax_derivative ha z).mul_const T⁻¹
  have h := (scalarCutoff_hasDerivAt (softAbsMax a z/T)).comp_hasFDerivAt z hs
  simp only [div_eq_mul_inv] at h
  apply h.congr_fderiv
  ext v
  simp only [smul_apply,smul_eq_mul,gradientLinear_apply,smoothCutoffFirst,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  ring

theorem smoothCutoffFirst_derivative {a : ℝ} (ha : a≠0) (T : ℝ) (z : I→ℝ) (i : I) :
    HasFDerivAt (fun y=>smoothCutoffFirst a T y i)
      (gradientLinear (smoothCutoffSecond a T z i)) z := by
  have hs := (softAbsMax_derivative ha z).mul_const T⁻¹
  have h := (scalarCutoff_first_hasDerivAt (softAbsMax a z/T)).comp_hasFDerivAt z hs
  simp only [div_eq_mul_inv] at h
  apply ((h.mul_const T⁻¹).mul (softFirst_derivative a z i)).congr_fderiv
  ext v
  simp only [add_apply,smul_apply,smul_eq_mul,gradientLinear_apply,smoothCutoffSecond,
    Finset.mul_sum,add_mul,Finset.sum_add_distrib]
  simp only [←Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  simp only [Function.comp_apply,div_eq_mul_inv]
  ring

theorem smoothCutoffSecond_continuous {a : ℝ} (ha : a≠0) (T : ℝ) (i j : I) :
    Continuous (fun z=>smoothCutoffSecond a T z i j) := by
  have hs : Continuous (softAbsMax (I:=I) a) :=
    continuous_iff_continuousAt.mpr (fun z=>(softAbsMax_derivative ha z).continuousAt)
  have hf (k : I) : Continuous (fun z=>softFirst a z k) :=
    continuous_iff_continuousAt.mpr (fun z=>(softFirst_derivative a z k).continuousAt)
  have hh := softSecond_continuous a i j
  have hd := scalarCutoff_deriv_contDiff.continuous
  have hdd := scalarCutoff_second_contDiff.continuous
  unfold smoothCutoffSecond
  fun_prop

theorem smoothCutoff_bounds (a T : ℝ) (z : I→ℝ) :
    0≤smoothCutoff a T z ∧ smoothCutoff a T z≤1 :=
  ⟨scalarCutoff.nonneg,scalarCutoff.le_one⟩

theorem smoothCutoffFirst_sum {a T B : ℝ} (hT : 0<T) (hB : 0≤B)
    (hb : ∀t, |deriv scalarCutoff t|≤B) (z : I→ℝ) :
    (∑i,|smoothCutoffFirst a T z i|)≤B/T := by
  simp only [smoothCutoffFirst,abs_mul,abs_div,abs_of_pos hT,←Finset.mul_sum]
  apply le_trans (mul_le_mul (div_le_div_of_nonneg_right (hb _) hT.le)
    (softFirst_sum a z) (Finset.sum_nonneg fun i _=>abs_nonneg _) (div_nonneg hB hT.le))
  simp

theorem smoothCutoffSecond_sum {a T B : ℝ} (ha : 0≤a) (hT : 0<T) (hB : 0≤B)
    (hb : ∀t, |deriv scalarCutoff t|≤B)
    (hbb : ∀t, |deriv (deriv scalarCutoff) t|≤B) (z : I→ℝ) :
    (∑i,∑j,|smoothCutoffSecond a T z i j|)≤B/T^2+2*a*B/T := by
  calc
    _ ≤ ∑i,∑j,(|deriv (deriv scalarCutoff) (softAbsMax a z/T)|/T^2*
        |softFirst a z i| *|softFirst a z j|+
        |deriv scalarCutoff (softAbsMax a z/T)|/T*|softSecond a z i j|) := by
      apply Finset.sum_le_sum
      intro i hi
      apply Finset.sum_le_sum
      intro j hj
      apply (abs_add_le _ _).trans
      simp only [abs_mul,abs_div,abs_of_pos hT,abs_of_nonneg (sq_nonneg T)]
      exact le_rfl
    _ = (|deriv (deriv scalarCutoff) (softAbsMax a z/T)|/T^2)*
        (∑i,|softFirst a z i|)^2+
        (|deriv scalarCutoff (softAbsMax a z/T)|/T)*(∑i,∑j,|softSecond a z i j|) := by
      simp_rw [Finset.sum_add_distrib,←Finset.mul_sum,←Finset.sum_mul]
      ring_nf
      rw [←Finset.mul_sum]
      ring
    _ ≤ B/T^2*1+(B/T)*(2*a) := by
      apply add_le_add
      · apply mul_le_mul (div_le_div_of_nonneg_right (hbb _) (sq_nonneg T))
        · have hs := softFirst_sum a z
          have hs0 : 0≤∑i,|softFirst a z i| := Finset.sum_nonneg (fun i _=>abs_nonneg _)
          nlinarith
        · positivity
        · positivity
      · exact mul_le_mul (div_le_div_of_nonneg_right (hb _) hT.le) (softSecond_sum ha z)
          (Finset.sum_nonneg fun i _=>Finset.sum_nonneg fun j _=>abs_nonneg _) (by positivity)
    _ = _ := by ring

def smoothCutoffJet {a T B : ℝ} (ha : 0<a) (hT : 0<T) (hB : 0≤B)
    (hb : ∀t, |deriv scalarCutoff t|≤B)
    (hbb : ∀t, |deriv (deriv scalarCutoff) t|≤B) :
    BoundedJet I 1 (B/T) (B/T^2+2*a*B/T) where
  value := smoothCutoff a T
  grad := smoothCutoffFirst a T
  hess := smoothCutoffSecond a T
  derivative := smoothCutoff_derivative ha.ne' T
  grad_derivative := smoothCutoffFirst_derivative ha.ne' T
  hess_continuous := smoothCutoffSecond_continuous ha.ne' T
  value_bound := fun z=>by rw [abs_of_nonneg (smoothCutoff_bounds a T z).1]; exact (smoothCutoff_bounds a T z).2
  grad_bound := smoothCutoffFirst_sum hT hB hb
  hess_bound := smoothCutoffSecond_sum ha.le hT hB hb hbb


theorem smoothCutoff_eq_one {a T : ℝ} (ha : 0<a) (hT : 0<T)
    (hscale : Real.log (2*Fintype.card I)≤a*T) (z : I→ℝ) (hz : ∀i,|z i|≤T) :
    smoothCutoff a T z=1 := by
  apply scalarCutoff_eq_one
  have hs0 := softAbsMax_nonneg ha z
  rw [abs_of_nonneg (div_nonneg hs0 hT.le)]
  apply (div_le_iff₀ hT).2
  have hs := softAbsMax_le ha z hz
  have hdiv : Real.log (2*Fintype.card I)/a≤T := (div_le_iff₀ ha).2 (by simpa [mul_comm] using hscale)
  linarith

theorem smoothCutoff_eq_zero {a T : ℝ} (ha : 0<a) (hT : 0<T)
    (z : I→ℝ) (i : I) (hi : 4*T≤|z i|) : smoothCutoff a T z=0 := by
  apply scalarCutoff_eq_zero
  have hs := le_softAbsMax ha z i
  have hratio : 4≤softAbsMax a z/T := (le_div_iff₀ hT).2 (hi.trans hs)
  exact hratio.trans (le_abs_self _)

theorem smoothCutoff_jet_zero {a T : ℝ} (ha : 0<a) (hT : 0<T)
    (z : I→ℝ) (i : I) (hi : 4*T < |z i|) :
    smoothCutoff a T z=0 ∧ (∀j,smoothCutoffFirst a T z j=0) ∧
      (∀j k,smoothCutoffSecond a T z j k=0) := by
  have hs := le_softAbsMax ha z i
  have hratio : 4 < |softAbsMax a z/T| :=
    ((lt_div_iff₀ hT).2 (hi.trans_le hs)).trans_le (le_abs_self _)
  have hd := scalarCutoff_deriv_eq_zero hratio
  have hdd := scalarCutoff_second_eq_zero hratio
  refine ⟨smoothCutoff_eq_zero ha hT z i hi.le,?_,?_⟩
  · intro j; simp [smoothCutoffFirst,hd]
  · intro j k; simp [smoothCutoffSecond,hd,hdd]

def cutoffRate (I : Type*) [Fintype I] (T : ℝ) : ℝ := Real.log (2*Fintype.card I)/T

theorem cutoffRate_pos {T : ℝ} (hT : 0<T) : 0<cutoffRate I T := by
  apply div_pos _ hT
  apply Real.log_pos
  have hc : (1:ℝ)≤Fintype.card I := by exact_mod_cast Fintype.card_pos
  linarith

theorem cutoffRate_scale {T : ℝ} (hT : 0<T) :
    Real.log (2*Fintype.card I)≤cutoffRate I T*T := by
  unfold cutoffRate
  rw [div_mul_cancel₀ _ hT.ne']

theorem canonical_smoothCutoff_eq_one {T : ℝ} (hT : 0<T) (z : I→ℝ) (hz : ∀i,|z i|≤T) :
    smoothCutoff (cutoffRate I T) T z=1 :=
  smoothCutoff_eq_one (cutoffRate_pos hT) hT (cutoffRate_scale hT) z hz

end NeuralGeneralization.BatchTwoActivation
