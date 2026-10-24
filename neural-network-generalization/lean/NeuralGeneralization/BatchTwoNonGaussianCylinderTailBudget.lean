import NeuralGeneralization.BatchTwoNonGaussianCylinderEntropy

/-! Deterministic budget inequalities making the non-Gaussian cylinder positive.
These bounds choose the free-matrix norm threshold independently of learner width. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel

theorem matrixCylinder_tail_budget (ν : CoordinateLaw) (C : ℕ) {N : ℕ} (hN : 0 < N)
    {ρ b : ℝ} (hρ : 0 < ρ)
    (hbudget : 2*Real.log 9+(C : ℝ)*Real.log (1024/ρ^2)+2*Real.log 2 ≤
      b^2/(8*subGaussianVariance ν)) :
    2*(9 : ℝ)^(N+N)*Real.exp (-b^2*N/(8*subGaussianVariance ν)) ≤
      (1/2)*(ρ^2/1024)^(C*N) := by
  have hlog : Real.log (1024/ρ^2)= -Real.log (ρ^2/1024) := by
    rw [show 1024/ρ^2=(ρ^2/1024)⁻¹ by field_simp,Real.log_inv]
  have he : 2*(9 : ℝ)^(N+N)*Real.exp (-b^2*N/(8*subGaussianVariance ν)) =
      2*Real.exp ((N : ℝ)*(2*Real.log 9-b^2/(8*subGaussianVariance ν))) := by
    have h9 : (9 : ℝ)^(N+N)=Real.exp ((N+N : ℕ)*Real.log 9) := by
      rw [Real.exp_nat_mul,Real.exp_log (by norm_num)]
    rw [h9,mul_assoc,←Real.exp_add]
    congr 2
    push_cast
    ring
  have hpow : (1/4 : ℝ)^N ≤ 1/4 := by
    exact (pow_le_pow_of_le_one (by norm_num : (0 : ℝ) ≤ 1/4) (by norm_num : (1/4 : ℝ) ≤ 1)
      (by omega : 1 ≤ N)).trans_eq (pow_one _)
  have hlog4 : Real.log (1/4 : ℝ)= -2*Real.log 2 := by
    rw [show (1/4 : ℝ)=(2^2)⁻¹ by norm_num,Real.log_inv,Real.log_pow]
    norm_num
  rw [he]
  calc
    _ ≤ 2*Real.exp ((N : ℝ)*((C : ℝ)*Real.log (ρ^2/1024)+Real.log (1/4))) := by
      apply mul_le_mul_of_nonneg_left _ (by norm_num)
      apply Real.exp_le_exp.mpr
      apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg N)
      rw [hlog] at hbudget
      rw [hlog4]
      linarith
    _ = 2*((ρ^2/1024)^(C*N)*(1/4 : ℝ)^N) := by
      have hn : (N : ℝ)*((C : ℝ)*Real.log (ρ^2/1024))=
          (C*N : ℕ)*Real.log (ρ^2/1024) := by push_cast; ring
      rw [mul_add,Real.exp_add,hn,
        Real.exp_nat_mul,Real.exp_nat_mul,Real.exp_log (by positivity),Real.exp_log (by norm_num)]
    _ ≤ _ := by
      have hm := mul_le_mul_of_nonneg_left hpow
        (pow_nonneg (by positivity : 0 ≤ ρ^2/1024) (C*N))
      nlinarith

/-- A width-independent factor bounds the reciprocal radius after separating
its polynomial dependence on the operator threshold. -/
def inverseRadiusFactor (d r C : ℕ) (K : ℝ) : ℝ :=
  4*(K*cylinderInputFactor d*(3*K+12*((C : ℝ)+2)^2+3*C+1)^r+1)

theorem inverseRadiusFactor_pos (d r C : ℕ) {K : ℝ} (hK : 0 ≤ K) :
    0 < inverseRadiusFactor d r C K := by
  unfold inverseRadiusFactor cylinderInputFactor
  positivity

theorem inverseRadius_le_factor (d r C : ℕ) {K b : ℝ} (hK : 0 ≤ K) (hb : 0 ≤ b) :
    (cylinderRadius d r K C (2*(b+C+1)))⁻¹ ≤
      inverseRadiusFactor d r C K*(b+1)^(2*r) := by
  have hC : (0 : ℝ) ≤ C := Nat.cast_nonneg C
  have ht : b+C+1 ≤ ((C : ℝ)+2)*(b+1) := by nlinarith
  have hsq : (b+C+1)^2 ≤ (((C : ℝ)+2)*(b+1))^2 := by
    exact (sq_le_sq₀ (by positivity) (by positivity)).mpr ht
  have hb1 : 1 ≤ (b+1)^2 := by nlinarith
  have hA : cylinderAmplification K C (2*(b+C+1)) ≤
      (3*K+12*((C : ℝ)+2)^2+3*C+1)*(b+1)^2 := by
    unfold cylinderAmplification
    rw [mul_pow] at hsq
    nlinarith [mul_le_mul_of_nonneg_left hb1 (show 0 ≤ 3*K+3*C+1 by positivity)]
  have hA0 : 0 ≤ cylinderAmplification K C (2*(b+C+1)) := by
    unfold cylinderAmplification
    positivity
  have hp := pow_le_pow_left₀ hA0 hA r
  rw [mul_pow,←pow_mul] at hp
  have hD : 0 ≤ cylinderInputFactor d := by unfold cylinderInputFactor; positivity
  have hmul := mul_le_mul_of_nonneg_left hp (mul_nonneg hK hD)
  have hpow : 1 ≤ (b+1)^(2*r) := one_le_pow₀ (by linarith : 1 ≤ b+1)
  unfold cylinderRadius
  rw [inv_inv]
  unfold inverseRadiusFactor
  nlinarith

theorem log_inverseRadius_le (d r C : ℕ) {K b : ℝ} (hK : 0 ≤ K) (hb : 0 ≤ b) :
    Real.log ((cylinderRadius d r K C (2*(b+C+1)))⁻¹) ≤
      inverseRadiusFactor d r C K+2*(r : ℝ)*(b+1) := by
  have hρ := cylinderRadius_pos d r hK (Nat.cast_nonneg C) (B := 2*(b+C+1))
  have ha := inverseRadiusFactor_pos d r C hK
  have hb0 : 0 < b+1 := by linarith
  have hl := Real.log_le_log (inv_pos.mpr hρ) (inverseRadius_le_factor d r C hK hb)
  rw [Real.log_mul ha.ne' (pow_pos hb0 _).ne',Real.log_pow] at hl
  have hla : Real.log (inverseRadiusFactor d r C K) ≤ inverseRadiusFactor d r C K :=
    (Real.log_le_sub_one_of_pos ha).trans (by linarith)
  have hlb : Real.log (b+1) ≤ b+1 := (Real.log_le_sub_one_of_pos hb0).trans (by linarith)
  have hm := mul_le_mul_of_nonneg_left hlb (show (0 : ℝ) ≤ 2*r by positivity)
  push_cast at hl
  linarith

def cylinderTailCoefficient (d r C : ℕ) (K : ℝ) : ℝ :=
  22+1024*(C : ℝ)+2*C*inverseRadiusFactor d r C K+4*C*r

def cylinderNoiseBound (ν : CoordinateLaw) (d r C : ℕ) (K : ℝ) : ℝ :=
  1+16*subGaussianVariance ν*cylinderTailCoefficient d r C K

theorem cylinderTailCoefficient_pos (d r C : ℕ) {K : ℝ} (hK : 0 ≤ K) :
    0 < cylinderTailCoefficient d r C K := by
  have ha := inverseRadiusFactor_pos d r C hK
  unfold cylinderTailCoefficient
  positivity

theorem cylinderNoiseBound_pos (ν : CoordinateLaw) (d r C : ℕ) {K : ℝ} (hK : 0 ≤ K) :
    0 < cylinderNoiseBound ν d r C K := by
  have hv := subGaussianVariance_pos ν
  have hD := cylinderTailCoefficient_pos d r C hK
  unfold cylinderNoiseBound
  positivity

theorem cylinderNoiseBound_budget (ν : CoordinateLaw) (d r C : ℕ) {K : ℝ} (hK : 0 ≤ K) :
    let b := cylinderNoiseBound ν d r C K
    let ρ := cylinderRadius d r K C (2*(b+C+1))
    2*Real.log 9+(C : ℝ)*Real.log (1024/ρ^2)+2*Real.log 2 ≤
      b^2/(8*subGaussianVariance ν) := by
  let b := cylinderNoiseBound ν d r C K
  let ρ := cylinderRadius d r K C (2*(b+C+1))
  let D := cylinderTailCoefficient d r C K
  let a := inverseRadiusFactor d r C K
  have hb : 0 ≤ b := (cylinderNoiseBound_pos ν d r C hK).le
  have hρ : 0 < ρ := cylinderRadius_pos d r hK (Nat.cast_nonneg C)
  have hv := subGaussianVariance_pos ν
  have ha : 0 < a := inverseRadiusFactor_pos d r C hK
  have hD : 0 < D := cylinderTailCoefficient_pos d r C hK
  have hl : Real.log (ρ⁻¹) ≤ a+2*(r : ℝ)*(b+1) := log_inverseRadius_le d r C hK hb
  have hlog : Real.log (1024/ρ^2)=Real.log 1024+2*Real.log (ρ⁻¹) := by
    rw [Real.log_div (by norm_num) (sq_pos_of_pos hρ).ne',Real.log_pow,Real.log_inv]
    ring
  have hl9 : Real.log 9 ≤ 9 := (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 9)).trans (by norm_num)
  have hl2 : Real.log 2 ≤ 2 := (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)).trans (by norm_num)
  have hl1024 : Real.log 1024 ≤ 1024 :=
    (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 1024)).trans (by norm_num)
  have hcoef : 4*(C : ℝ)*r ≤ D := by
    dsimp [D,cylinderTailCoefficient]
    nlinarith [mul_nonneg (Nat.cast_nonneg C : (0 : ℝ) ≤ C) ha.le]
  have hlogbound : 2*Real.log 9+(C : ℝ)*Real.log (1024/ρ^2)+2*Real.log 2 ≤ D*(b+1) := by
    rw [hlog]
    have hh := mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg C : (0 : ℝ) ≤ C)
    have hconst := mul_le_mul_of_nonneg_left hl1024 (Nat.cast_nonneg C : (0 : ℝ) ≤ C)
    have hB := mul_le_mul_of_nonneg_right hcoef hb
    dsimp [D,cylinderTailCoefficient,a] at hB ⊢
    nlinarith
  apply hlogbound.trans
  apply (le_div_iff₀ (mul_pos (by norm_num) hv)).mpr
  change D*(b+1)*(8*subGaussianVariance ν) ≤ b^2
  have hbdef : b=1+16*subGaussianVariance ν*D := rfl
  rw [hbdef]
  nlinarith [sq_nonneg (subGaussianVariance ν*D),mul_nonneg hv.le hD.le]

end NeuralGeneralization.BatchTwoNonGaussian
