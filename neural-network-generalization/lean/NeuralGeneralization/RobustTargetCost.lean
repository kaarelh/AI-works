import NeuralGeneralization.RobustTargetParameters

/-! # The cylinder cost has a universal polynomial upper bound -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel

def digitalMassPolynomial (d C r : ℕ) (c : ℝ) : ℝ :=
  digitalTeacherCost d C r c + ((d:ℝ)+2+(r:ℝ)*((C:ℝ)+1))*
    (1+8192*((d:ℝ)+1)*((C:ℝ)+1)^2)+1

theorem digitalTeacherCost_nonneg (d C r : ℕ) (c : ℝ) :
    0 ≤ digitalTeacherCost d C r c := by
  unfold digitalTeacherCost
  positivity

theorem digitalMassPolynomial_ge_one (d C r : ℕ) (c : ℝ) :
    1 ≤ digitalMassPolynomial d C r c := by
  have hk := digitalTeacherCost_nonneg d C r c
  unfold digitalMassPolynomial
  have hh : 0 ≤ ((d:ℝ)+2+(r:ℝ)*((C:ℝ)+1))*
    (1+8192*((d:ℝ)+1)*((C:ℝ)+1)^2) := by positivity
  linarith

theorem robustCylinderCost_le_polynomial {d r : ℕ} {K G ρ R : ℝ}
    (hG : 0 ≤ G) (hρ : 0 < ρ) (hρ1 : ρ ≤ 1) (hR : 1/ρ ≤ R) :
    robustCylinderCost d r K G ρ ≤ K+((d:ℝ)+2+(r:ℝ)*G)*(1+2*R)+1 := by
  have hsqrt : Real.sqrt (2*Real.pi) ≤ 4 := by
    apply (Real.sqrt_le_iff).mpr
    constructor
    · norm_num
    · nlinarith [Real.pi_le_four]
  have hfrac : Real.sqrt (2*Real.pi)/(2*ρ) ≤ 2*R := by
    calc
      _ ≤ 4/(2*ρ) := div_le_div_of_nonneg_right hsqrt (by positivity)
      _ = 2*(1/ρ) := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_left hR (by norm_num)
  have hs : ρ^2 ≤ 1 := by nlinarith
  have hterm : ρ^2+Real.sqrt (2*Real.pi)/(2*ρ) ≤ 1+2*R := by linarith
  have hh := mul_le_mul_of_nonneg_left hterm
    (by positivity : 0 ≤ (d:ℝ)+2+(r:ℝ)*G)
  unfold robustCylinderCost
  linarith

/-- Width and Gaussian scale do not occur in this polynomial. Its degree
is fixed even when the logical depth grows. -/
theorem digitalMassPolynomial_nonneg (d C r : ℕ) (c : ℝ) :
    0 ≤ digitalMassPolynomial d C r c := le_trans (by norm_num) (digitalMassPolynomial_ge_one d C r c)

end NeuralGeneralization.ConcreteModel
