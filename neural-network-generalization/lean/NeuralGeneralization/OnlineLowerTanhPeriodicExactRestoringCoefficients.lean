import NeuralGeneralization.OnlineLowerTanhPeriodicExactSmoothingGap
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Chebyshev.Basic

/-! Exact coefficient normalization for the finite restoring-curvature certificate. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma periodicRatio_mem_restoring_interval {a : ℝ} (ha1 : 1≤a) (ha2 : a≤2) :
    (1:ℝ)/256≤periodicRatio a ∧ periodicRatio a≤17/200 := by
  have ha : 0<a := by linarith
  refine ⟨?_,(periodicRatio_bound ha ha2).2.le⟩
  have hp : Real.pi^2<10 := by nlinarith [Real.pi_lt_d4,Real.pi_pos]
  have hd : 2*periodicDecay a<5 := by
    unfold periodicDecay
    rw [←mul_div_assoc]
    apply (div_lt_iff₀ (by positivity : 0<4*a)).mpr
    nlinarith
  have he : Real.exp (2*periodicDecay a)<256 := by
    have h5 : Real.exp (5:ℝ)<(3:ℝ)^5 := by
      rw [show (5:ℝ)=(5:ℕ)*1 by norm_num,Real.exp_nat_mul]
      exact pow_lt_pow_left₀ Real.exp_one_lt_three (Real.exp_pos _).le (by decide)
    exact ((Real.exp_lt_exp.mpr hd).trans h5).trans (by norm_num)
  unfold periodicRatio
  rw [show -2*periodicDecay a=-(2*periodicDecay a) by ring,Real.exp_neg]
  simpa only [one_div] using (one_div_le_one_div_of_le (Real.exp_pos _) he.le)

lemma sinh_exp_tail_identity (x : ℝ) :
    Real.sinh x=Real.exp x*(1-Real.exp (-2*x))/2 := by
  rw [Real.sinh_eq]
  have he : Real.exp x*Real.exp (-2*x)=Real.exp (-x) := by
    rw [←Real.exp_add]
    congr 1
    ring
  nlinarith

lemma periodicCoefficient_relative_exact {a : ℝ} (ha : 0<a) (j : ℕ) :
    periodicCoefficient a j = periodicCoefficient a 0 *
      (periodicRatio a^j*(1-periodicRatio a)/(1-periodicRatio a^(2*j+1))) := by
  let t := periodicDecay a
  have ht : 0<t := periodicDecay_pos ha
  have hq : 0<periodicRatio a ∧ periodicRatio a<1 := by
    refine ⟨Real.exp_pos _,?_⟩
    apply Real.exp_lt_one_iff.mpr
    change -2*t<0
    linarith
  have hd : 1-periodicRatio a^(2*j+1)≠0 := by
    have hpow := pow_lt_one₀ hq.1.le hq.2 (by omega : 2*j+1≠0)
    linarith
  have h0 : 1-periodicRatio a≠0 := by linarith [hq.2]
  have hexp : Real.exp ((2*(j:ℝ)+1)*t)*periodicRatio a^j=Real.exp t := by
    unfold periodicRatio
    rw [←Real.exp_nat_mul,←Real.exp_add]
    congr 1
    dsimp [t]
    ring
  have hpow : Real.exp (-2*((2*(j:ℝ)+1)*t))=periodicRatio a^(2*j+1) := by
    unfold periodicRatio
    rw [←Real.exp_nat_mul]
    congr 1
    dsimp [t]
    push_cast
    ring
  unfold periodicCoefficient
  simp only [Nat.cast_zero,mul_zero,zero_add,one_mul]
  change (Real.pi/a)/Real.sinh ((2*(j:ℝ)+1)*t) =
    (Real.pi/a)/Real.sinh t * (periodicRatio a^j*(1-periodicRatio a)/(1-periodicRatio a^(2*j+1)))
  rw [sinh_exp_tail_identity ((2*(j:ℝ)+1)*t),sinh_exp_tail_identity t,hpow]
  change (Real.pi/a)/(Real.exp ((2*(j:ℝ)+1)*t)*(1-periodicRatio a^(2*j+1))/2) =
    (Real.pi/a)/(Real.exp t*(1-periodicRatio a)/2)*
      (periodicRatio a^j*(1-periodicRatio a)/(1-periodicRatio a^(2*j+1)))
  field_simp
  nlinarith [hexp]

end NeuralGeneralization.OnlineLowerTanh
