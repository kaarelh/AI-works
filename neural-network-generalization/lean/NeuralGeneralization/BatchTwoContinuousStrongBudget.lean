import NeuralGeneralization.BatchTwoContinuousStrongExplicit
import NeuralGeneralization.BatchTwoContinuousStatements

/-! Polynomial bookkeeping for the literal strong-prior regression theorem.
All resources below are independent of learner width and training tolerance. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel

def integerTeacherEnergy (d C r b : ℕ) : ℕ := (d*(d+1)+(r+1)*C^2)*b^2
def strongRegressionEnergy (k d C r : ℕ) (B : ℝ) : ℕ := 2*k*integerTeacherEnergy d C r ⌈B⌉₊+1
def regressionAccuracyWidth (u : ℝ) : ℕ := ⌈u⌉₊+1

theorem strongRegressionEnergy_pos (k d C r : ℕ) (B : ℝ) : 1 ≤ strongRegressionEnergy k d C r B := by
  unfold strongRegressionEnergy
  omega

theorem regressionAccuracyWidth_pos (u : ℝ) : 1 ≤ regressionAccuracyWidth u := by
  unfold regressionAccuracyWidth
  omega

theorem strongRegressionEnergy_gap (ν : BatchTwoNonGaussian.CoordinateLaw) {k d C r : ℕ}
    (hk : ν.upperCurvature ≤ ν.lowerCurvature*(k : ℝ)) {B : ℝ} (hB : 0 ≤ B) :
    ν.upperCurvature*teacherEnergyBound d C r B <
      ν.lowerCurvature*(strongRegressionEnergy k d C r B : ℝ)/2 := by
  have hceil : B ≤ (⌈B⌉₊ : ℝ) := Nat.le_ceil _
  have hE : teacherEnergyBound d C r B ≤ (integerTeacherEnergy d C r ⌈B⌉₊ : ℝ) := by
    unfold teacherEnergyBound integerTeacherEnergy
    push_cast
    gcongr
  have hm := mul_le_mul_of_nonneg_left hE ν.upperCurvature_pos.le
  have hm' := mul_le_mul_of_nonneg_right hk (Nat.cast_nonneg (integerTeacherEnergy d C r ⌈B⌉₊) : (0 : ℝ) ≤ _)
  unfold strongRegressionEnergy
  push_cast
  nlinarith [ν.lowerCurvature_pos]

theorem inverseGap_ge_one {ρ τ : ℝ} (hgap : ρ < τ) : 1 ≤ inverseGap ρ τ := by
  unfold inverseGap
  have hp : 0 < min 1 (τ-ρ) := lt_min zero_lt_one (by linarith)
  exact (one_le_div hp).mpr (min_le_left _ _)

theorem regressionAccuracyWidth_gap {ρ τ : ℝ} (hgap : ρ < τ) :
    ρ+2*(1/(3*(regressionAccuracyWidth (inverseGap ρ τ) : ℝ))) ≤ τ := by
  let u := inverseGap ρ τ
  let R := regressionAccuracyWidth u
  have hu : 1 ≤ u := inverseGap_ge_one hgap
  have hR : u ≤ (R : ℝ) := by
    have hh := Nat.le_ceil u
    dsimp [R,regressionAccuracyWidth]
    push_cast
    linarith
  have hRp : 0 < (R : ℝ) := by linarith
  have hminp : 0 < min 1 (τ-ρ) := lt_min zero_lt_one (by linarith)
  have hprod : 1 ≤ (R : ℝ)*min 1 (τ-ρ) := by
    have hh := mul_le_mul_of_nonneg_right hR hminp.le
    have hid : u*min 1 (τ-ρ)=1 := by dsimp [u,inverseGap]; field_simp
    rwa [hid] at hh
  have hinv : 1/(R : ℝ) ≤ min 1 (τ-ρ) := (div_le_iff₀ hRp).mpr (by nlinarith)
  have hmin := min_le_right (1 : ℝ) (τ-ρ)
  have hf : 2*(1/(3*(R : ℝ))) ≤ 1/(R : ℝ) := by
    field_simp
    norm_num
  linarith

theorem strongRegression_resources_bound (r k d C : ℕ) {B u : ℝ} (hB : 1 ≤ B) (hu : 1 ≤ u) :
    let T := 1+(d : ℝ)+(C : ℝ)+B+u
    1+(d : ℝ)+(strongRegressionEnergy k d C r B+regressionAccuracyWidth u : ℕ) ≤
      (2*(k : ℝ)*(r+2)+5)*T^4 := by
  let T := 1+(d : ℝ)+(C : ℝ)+B+u
  have hd0 : 0 ≤ (d : ℝ) := Nat.cast_nonneg _
  have hC0 : 0 ≤ (C : ℝ) := Nat.cast_nonneg _
  have hT : 1 ≤ T := by dsimp [T]; linarith
  have hd : (d : ℝ) ≤ T := by dsimp [T]; linarith
  have hd1 : (d : ℝ)+1 ≤ T := by dsimp [T]; linarith
  have hC : (C : ℝ) ≤ T := by dsimp [T]; linarith
  have hB' : B+1 ≤ T := by dsimp [T]; linarith
  have hu' : u+1 ≤ T := by dsimp [T]; linarith
  have hb : (⌈B⌉₊ : ℝ) ≤ T := (Nat.ceil_lt_add_one (by linarith : 0 ≤ B)).le.trans hB'
  have hr : (regressionAccuracyWidth u : ℝ) ≤ T+1 := by
    have hh := (Nat.ceil_lt_add_one (by linarith : 0 ≤ u)).le
    unfold regressionAccuracyWidth
    push_cast
    linarith
  have hdprod : (d : ℝ)*(d+1) ≤ T^2 := by nlinarith [mul_le_mul hd hd1 (by positivity : 0 ≤ (d : ℝ)+1) (by linarith : 0 ≤ T)]
  have hC2 : (C : ℝ)^2 ≤ T^2 := pow_le_pow_left₀ hC0 hC _
  have hb2 : (⌈B⌉₊ : ℝ)^2 ≤ T^2 := pow_le_pow_left₀ (Nat.cast_nonneg _) hb _
  have hE : (integerTeacherEnergy d C r ⌈B⌉₊ : ℝ) ≤ ((r : ℝ)+2)*T^4 := by
    have hfactor : (d : ℝ)*(d+1)+((r : ℝ)+1)*C^2 ≤ ((r : ℝ)+2)*T^2 := by
      have hm := mul_le_mul_of_nonneg_left hC2 (show 0 ≤ (r : ℝ)+1 by positivity)
      nlinarith
    have hm := mul_le_mul hfactor hb2 (sq_nonneg _) (by positivity : 0 ≤ ((r : ℝ)+2)*T^2)
    unfold integerTeacherEnergy
    push_cast
    nlinarith only [hm]
  have hK : (strongRegressionEnergy k d C r B : ℝ) ≤ 2*(k : ℝ)*((r : ℝ)+2)*T^4+1 := by
    have hh := mul_le_mul_of_nonneg_left hE (show 0 ≤ 2*(k : ℝ) by positivity)
    unfold strongRegressionEnergy
    push_cast
    nlinarith only [hh]
  have hT4 : T ≤ T^4 := le_self_pow₀ hT (by norm_num)
  have hT40 : 1 ≤ T^4 := one_le_pow₀ hT
  change 1+(d : ℝ)+((strongRegressionEnergy k d C r B+regressionAccuracyWidth u : ℕ) : ℝ) ≤ _
  push_cast
  change 1+(d : ℝ)+((strongRegressionEnergy k d C r B : ℝ)+(regressionAccuracyWidth u : ℝ)) ≤ _
  nlinarith only [hK,hr,hd,hT4,hT40]

theorem strongRegression_polynomial (r k : ℕ) :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ, ∀ d C : ℕ, ∀ B u : ℝ, 1 ≤ B → 1 ≤ u →
      (coverEntropy d r (strongRegressionEnergy k d C r B) (regressionAccuracyWidth u) : ℝ) ≤
        regressionEnvelope A m d C B u 0 0 := by
  obtain ⟨A,hA,m,hpoly⟩ := (coverEntropy_polynomial r).real_envelope
  let a : ℝ := 2*(k : ℝ)*(r+2)+5
  have ha : 0 < a := by dsimp [a]; positivity
  refine ⟨A*a^m,mul_pos hA (pow_pos ha _),4*m,?_⟩
  intro d C B u hB hu
  let K := strongRegressionEnergy k d C r B
  let R := regressionAccuracyWidth u
  have hmono : coverEntropy d r K R ≤ coverEntropy d r (K+R) (K+R) := coverEntropy_mono (by omega) (by omega)
  have hp := hpoly d (K+R)
  have hres := strongRegression_resources_bound r k d C hB hu
  have hm := pow_le_pow_left₀ (show 0 ≤ 1+(d : ℝ)+((K+R : ℕ) : ℝ) by positivity) hres m
  have hh := mul_le_mul_of_nonneg_left hm hA.le
  calc
    _ ≤ (coverEntropy d r (K+R) (K+R) : ℝ) := by exact_mod_cast hmono
    _ ≤ A*(1+(d : ℝ)+((K+R : ℕ) : ℝ))^m := hp
    _ ≤ A*(a*(1+(d : ℝ)+(C : ℝ)+B+u)^4)^m := hh
    _ = _ := by unfold regressionEnvelope; rw [mul_pow,← pow_mul]; ring

end NeuralGeneralization.BatchTwoContinuous
