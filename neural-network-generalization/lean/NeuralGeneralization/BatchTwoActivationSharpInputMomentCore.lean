import NeuralGeneralization.BatchTwoActivationInputMoment

/-! Literal finite-cube bounded-difference exponential moments. -/
noncomputable section
set_option maxHeartbeats 1400000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling

theorem two_point_exp_moment (a u v R : ℝ) (hR : 0≤R) (hdiff : |u-v|≤2*R) :
    (Real.exp (a*u)+Real.exp (a*v))/2≤Real.exp (a*((u+v)/2)+a^2*R^2/2) := by
  have hsq : (u-v)^2≤4*R^2 := by
    have hh := pow_le_pow_left₀ (abs_nonneg _) hdiff 2
    simpa only [sq_abs,mul_pow,show (2 : ℝ)^2=4 by norm_num] using hh
  have hcoef : (a*((u-v)/2))^2/2≤a^2*R^2/2 := by
    nlinarith only [mul_le_mul_of_nonneg_left hsq (sq_nonneg a)]
  have hcosh := (Real.cosh_le_exp_half_sq (a*((u-v)/2))).trans (Real.exp_le_exp.mpr hcoef)
  have he : Real.exp (a*((u+v)/2))*Real.cosh (a*((u-v)/2))=
      (Real.exp (a*u)+Real.exp (a*v))/2 := by
    rw [Real.cosh_eq,←mul_div_assoc,mul_add,←Real.exp_add,←Real.exp_add]
    congr 2 <;> congr 1 <;> ring
  rw [←he]
  exact (mul_le_mul_of_nonneg_left hcosh (Real.exp_nonneg _)).trans_eq (Real.exp_add _ _).symm

def CubeBoundedDifferences {n : ℕ} (F : (Fin n→Bool)→ℝ) (R : ℝ) : Prop :=
  ∀ i ε η, (∀j,j≠i→ε j=η j) → |F ε-F η|≤2*R

theorem finite_cube_bounded_difference_mgf (n : ℕ) (F : (Fin n→Bool)→ℝ)
    {R : ℝ} (hR : 0≤R) (hF : CubeBoundedDifferences F R) (a : ℝ) :
    finiteMean (fun ε=>Real.exp (a*F ε))≤
      Real.exp (a*finiteMean F+a^2*(n : ℝ)*R^2/2) := by
  induction n with
  | zero => simp [finiteMean]
  | succ n ih =>
    let f : Bool→(Fin n→Bool)→ℝ := fun b ε=>F (Fin.cons b ε)
    have hf (b : Bool) : CubeBoundedDifferences (f b) R := by
      intro i ε η hsame
      apply hF i.succ (Fin.cons b ε) (Fin.cons b η)
      intro j
      refine Fin.cases ?_ (fun k hj=>?_) j
      · intro; rfl
      · simp only [Fin.cons_succ]
        apply hsame k
        intro he
        exact hj (congrArg Fin.succ he)
    have hslice (b : Bool) := ih (f b) (hf b)
    have hdiff : |finiteMean (f false)-finiteMean (f true)|≤2*R := by
      rw [←finiteMean_sub]
      apply (abs_finiteMean_le _).trans
      apply (finiteMean_mono (fun ε=>?_)).trans_eq (finiteMean_const (2*R))
      apply hF 0 (Fin.cons false ε) (Fin.cons true ε)
      intro j
      refine Fin.cases ?_ (fun k hj=>?_) j
      · intro hj; exact (hj rfl).elim
      · rfl
    have houter := finiteMean_mono hslice
    rw [finiteMean_sign_succ] at ⊢
    change finiteMean (fun b : Bool=>finiteMean (fun ε=>Real.exp (a*f b ε)))≤_
    apply houter.trans
    have hmean : finiteMean F=(finiteMean (f false)+finiteMean (f true))/2 := by
      rw [finiteMean_sign_succ]
      simp [finiteMean,f,add_comm]
    have hpoint := two_point_exp_moment a (finiteMean (f false)) (finiteMean (f true)) R hR hdiff
    have he : finiteMean (fun b : Bool=>Real.exp (a*finiteMean (f b)+a^2*(n : ℝ)*R^2/2))=
        Real.exp (a^2*(n : ℝ)*R^2/2)*
          ((Real.exp (a*finiteMean (f false))+Real.exp (a*finiteMean (f true)))/2) := by
      simp [finiteMean,Real.exp_add,add_comm]
      ring
    rw [he,hmean]
    apply (mul_le_mul_of_nonneg_left hpoint (Real.exp_nonneg _)).trans_eq
    rw [←Real.exp_add]
    congr 1
    push_cast
    ring

end NeuralGeneralization.BatchTwoActivation
