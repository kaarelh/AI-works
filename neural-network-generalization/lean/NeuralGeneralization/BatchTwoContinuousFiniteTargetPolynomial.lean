import NeuralGeneralization.BatchTwoContinuousFiniteTargetMass
import NeuralGeneralization.BatchTwoContinuousStatements

/-! A literal polynomial envelope for the finite-scale target tube, with only
logarithmic dependence on the training tolerance. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteTarget
open ConcreteModel BatchTwoNonGaussian

def PolynomialBound4 (f : (Fin 4 → ℝ) → ℝ) : Prop :=
  ∃ A : ℝ, 0<A ∧ ∃ m : ℕ, ∀ x, (∀ i, 0≤x i) → |f x|≤A*(1+∑ i, x i)^m

namespace PolynomialBound4

theorem const (k : ℝ) : PolynomialBound4 (fun _ => k) := by
  refine ⟨|k|+1,by positivity,0,?_⟩
  intro x hx
  simp

theorem coordinate (j : Fin 4) : PolynomialBound4 (fun x => x j) := by
  refine ⟨1,by norm_num,1,?_⟩
  intro x hx
  rw [pow_one,one_mul,abs_of_nonneg (hx j)]
  have hh := Finset.single_le_sum (f := x) (fun i _ => hx i) (Finset.mem_univ j)
  linarith

theorem add {f g : (Fin 4 → ℝ) → ℝ} (hf : PolynomialBound4 f) (hg : PolynomialBound4 g) :
    PolynomialBound4 (fun x => f x+g x) := by
  obtain ⟨A,hA,m,hF⟩ := hf
  obtain ⟨B,hB,n,hG⟩ := hg
  refine ⟨A+B,add_pos hA hB,m+n,?_⟩
  intro x hx
  have hbase : (1 : ℝ)≤1+∑ i, x i := by have := Finset.sum_nonneg (fun i (_ : i ∈ Finset.univ) => hx i); linarith
  have hm := pow_le_pow_right₀ hbase (Nat.le_add_right m n)
  have hn := pow_le_pow_right₀ hbase (Nat.le_add_left n m)
  calc
    _ ≤ |f x|+|g x| := abs_add_le _ _
    _ ≤ A*(1+∑ i, x i)^m+B*(1+∑ i, x i)^n := add_le_add (hF x hx) (hG x hx)
    _ ≤ A*(1+∑ i, x i)^(m+n)+B*(1+∑ i, x i)^(m+n) :=
      add_le_add (mul_le_mul_of_nonneg_left hm hA.le) (mul_le_mul_of_nonneg_left hn hB.le)
    _ = _ := by ring

theorem mul {f g : (Fin 4 → ℝ) → ℝ} (hf : PolynomialBound4 f) (hg : PolynomialBound4 g) :
    PolynomialBound4 (fun x => f x*g x) := by
  obtain ⟨A,hA,m,hF⟩ := hf
  obtain ⟨B,hB,n,hG⟩ := hg
  refine ⟨A*B,mul_pos hA hB,m+n,?_⟩
  intro x hx
  have hb : 0≤1+∑ i, x i := by have := Finset.sum_nonneg (fun i (_ : i ∈ Finset.univ) => hx i); linarith
  rw [abs_mul]
  calc
    _ ≤ (A*(1+∑ i, x i)^m)*(B*(1+∑ i, x i)^n) :=
      mul_le_mul (hF x hx) (hG x hx) (abs_nonneg _) (by positivity)
    _ = _ := by rw [pow_add]; ring

theorem pow {f : (Fin 4 → ℝ) → ℝ} (hf : PolynomialBound4 f) (n : ℕ) :
    PolynomialBound4 (fun x => f x^n) := by
  obtain ⟨A,hA,m,hF⟩ := hf
  refine ⟨A^n,pow_pos hA _,m*n,?_⟩
  intro x hx
  rw [abs_pow]
  calc
    _ ≤ (A*(1+∑ i, x i)^m)^n := pow_le_pow_left₀ (abs_nonneg _) (hF x hx) _
    _ = _ := by rw [mul_pow,←pow_mul]

end PolynomialBound4

def teacherPolynomial (r : ℕ) (x : Fin 4 → ℝ) : ℝ :=
  (x 0*(x 0+1)+((r : ℝ)+1)*(x 1)^2)*(x 2)^2

def logPolynomial (ν : CoordinateLaw) (x : Fin 4 → ℝ) : ℝ :=
  |Real.log (radiusCap ν)|+(x 0+1)+x 3

def radiusPolynomial (r : ℕ) (x : Fin 4 → ℝ) : ℝ :=
  let K := 4*teacherPolynomial r x
  4*(K*((x 0+1)^2+1)*(3*K+12*(x 1+2)^2+3*x 1+1)^r+1)

def noisePolynomial (ν : CoordinateLaw) (r : ℕ) (x : Fin 4 → ℝ) : ℝ :=
  1+16*subGaussianVariance ν*(22+1024*x 1+2*x 1*radiusPolynomial r x+
    4*x 1*r+2*x 1*logPolynomial ν x)

def radiusLogPolynomial (ν : CoordinateLaw) (r : ℕ) (x : Fin 4 → ℝ) : ℝ :=
  logPolynomial ν x+radiusPolynomial r x+2*(r : ℝ)*(noisePolynomial ν r x+1)

def costPolynomial (ν : CoordinateLaw) (r : ℕ) (x : Fin 4 → ℝ) : ℝ :=
  ν.upperCurvature*teacherPolynomial r x+
    (x 0+2)*(|Real.log (1/coordinateBallConstant ν)|+radiusLogPolynomial ν r x)+
    (r : ℝ)*(x 1*(1024+2*radiusLogPolynomial ν r x)+2)

theorem teacherPolynomial_growth (r : ℕ) : PolynomialBound4 (teacherPolynomial r) := by
  unfold teacherPolynomial
  repeat' first | exact PolynomialBound4.const _ | exact PolynomialBound4.coordinate _ |
    apply PolynomialBound4.add | apply PolynomialBound4.mul | apply PolynomialBound4.pow

theorem logPolynomial_growth (ν : CoordinateLaw) : PolynomialBound4 (logPolynomial ν) := by
  unfold logPolynomial
  repeat' first | exact PolynomialBound4.const _ | exact PolynomialBound4.coordinate _ |
    apply PolynomialBound4.add | apply PolynomialBound4.mul | apply PolynomialBound4.pow

theorem radiusPolynomial_growth (r : ℕ) : PolynomialBound4 (radiusPolynomial r) := by
  have hK := (PolynomialBound4.const 4).mul (teacherPolynomial_growth r)
  unfold radiusPolynomial
  repeat' first | assumption | exact PolynomialBound4.const _ | exact PolynomialBound4.coordinate _ |
    apply PolynomialBound4.add | apply PolynomialBound4.mul | apply PolynomialBound4.pow

theorem noisePolynomial_growth (ν : CoordinateLaw) (r : ℕ) : PolynomialBound4 (noisePolynomial ν r) := by
  have hR := radiusPolynomial_growth r
  have hL := logPolynomial_growth ν
  unfold noisePolynomial
  repeat' first | assumption | exact PolynomialBound4.const _ | exact PolynomialBound4.coordinate _ |
    apply PolynomialBound4.add | apply PolynomialBound4.mul | apply PolynomialBound4.pow

theorem radiusLogPolynomial_growth (ν : CoordinateLaw) (r : ℕ) : PolynomialBound4 (radiusLogPolynomial ν r) := by
  have hR := radiusPolynomial_growth r
  have hL := logPolynomial_growth ν
  have hB := noisePolynomial_growth ν r
  unfold radiusLogPolynomial
  repeat' first | assumption | exact PolynomialBound4.const _ | exact PolynomialBound4.coordinate _ |
    apply PolynomialBound4.add | apply PolynomialBound4.mul | apply PolynomialBound4.pow

theorem costPolynomial_growth (ν : CoordinateLaw) (r : ℕ) : PolynomialBound4 (costPolynomial ν r) := by
  have hE := teacherPolynomial_growth r
  have hR := radiusLogPolynomial_growth ν r
  unfold costPolynomial
  repeat' first | assumption | exact PolynomialBound4.const _ | exact PolynomialBound4.coordinate _ |
    apply PolynomialBound4.add | apply PolynomialBound4.mul | apply PolynomialBound4.pow

theorem targetCost_eq_costPolynomial (ν : CoordinateLaw) (d C r : ℕ) (B ρ : ℝ) :
    targetCost ν d C r B ρ=costPolynomial ν r ![(d : ℝ),(C : ℝ),B,logInverseTolerance ρ] := by
  let x : Fin 4 → ℝ := ![(d : ℝ),(C : ℝ),B,logInverseTolerance ρ]
  have hE : teacherPolynomial r x=teacherEnergyBound d C r B := rfl
  have hL : logPolynomial ν x=targetLogBudget ν d ρ := rfl
  have hR : radiusPolynomial r x=inverseRadiusFactor d r C (4*teacherEnergyBound d C r B) := by
    dsimp only [radiusPolynomial]
    rw [hE]
    rfl
  have hB : noisePolynomial ν r x=noiseBound ν d r C (4*teacherEnergyBound d C r B)
      (targetLogBudget ν d ρ) := by
    unfold noisePolynomial
    rw [hR,hL]
    rfl
  have hRL : radiusLogPolynomial ν r x=logRadiusBound ν d r C (4*teacherEnergyBound d C r B)
      (targetLogBudget ν d ρ) := by
    unfold radiusLogPolynomial
    rw [hL,hR,hB]
    rfl
  change _=costPolynomial ν r x
  unfold costPolynomial
  rw [hE,hRL]
  unfold targetCost polynomialNoiseCost
  change _=ν.upperCurvature*teacherEnergyBound d C r B+
    ((d : ℝ)+2)*_+(r : ℝ)*((C : ℝ)*_+2)
  ring

/-- Polynomial in dimension, teacher width and coefficient bound, and log of
the inverse training tolerance. There is no inverse-tolerance power. -/
theorem targetCost_polynomial_envelope (ν : CoordinateLaw) (r : ℕ) :
    ∃ A : ℝ, 0<A ∧ ∃ m : ℕ, ∀ d C : ℕ, ∀ B ρ : ℝ, 0≤B → 0<ρ →
      targetCost ν d C r B ρ≤A*(1+(d : ℝ)+(C : ℝ)+B+logInverseTolerance ρ)^m := by
  obtain ⟨A,hA,m,hpoly⟩ := costPolynomial_growth ν r
  refine ⟨A,hA,m,?_⟩
  intro d C B ρ hB hρ
  have ht : 0≤logInverseTolerance ρ := by
    unfold logInverseTolerance
    exact Real.log_nonneg ((one_le_div (lt_min zero_lt_one hρ)).mpr (min_le_left _ _))
  have hx : ∀ i : Fin 4, 0≤(![(d : ℝ),(C : ℝ),B,logInverseTolerance ρ] i) := by
    intro i
    fin_cases i <;> simp [hB,ht]
  have hh := hpoly ![(d : ℝ),(C : ℝ),B,logInverseTolerance ρ] hx
  rw [←targetCost_eq_costPolynomial,abs_of_nonneg (targetCost_nonneg ν d C r hρ)] at hh
  simpa only [Fin.sum_univ_succ,Fin.sum_univ_zero,Matrix.cons_val_zero,Matrix.cons_val_succ,
    Matrix.cons_val_fin_one,add_zero,add_assoc] using hh

end NeuralGeneralization.BatchTwoContinuous.FiniteTarget
