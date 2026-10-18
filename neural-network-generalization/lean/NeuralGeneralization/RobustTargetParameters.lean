import NeuralGeneralization.RobustTargetProbability
import NeuralGeneralization.RobustCircuitStep

/-! # Explicit polynomial parameters for the robust digital cylinder -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel

def digitalError (C : ℕ) : ℝ := 1/(64*((C:ℝ)+1))
def digitalNoise (C : ℕ) : ℝ := digitalError C / 8
def digitalBulk (r : ℕ) : ℝ := 16*((r:ℝ)+1)
def digitalGain (C r : ℕ) : ℝ := 4096*((C:ℝ)+1)*(digitalBulk r+1)
def digitalReadout (C : ℕ) (c : ℝ) : ℝ := 4+4096*c*((C:ℝ)+1)
def digitalCylinderRadius (d C : ℕ) : ℝ :=
  digitalError C/(64*((d:ℝ)+1)*((C:ℝ)+1))
def digitalTeacherCost (d C r : ℕ) (c : ℝ) : ℝ :=
  9*(d:ℝ)*((d:ℝ)+1)*(digitalGain C r)^2+
  36*(r:ℝ)*(C:ℝ)^2*(digitalGain C r)^2+4*(C:ℝ)^2*(digitalReadout C c)^2

theorem digitalError_pos (C : ℕ) : 0 < digitalError C := by
  unfold digitalError
  positivity

theorem digitalError_le (C : ℕ) : digitalError C ≤ 1/64 := by
  unfold digitalError
  apply (div_le_div_iff₀ (by positivity) (by norm_num : (0:ℝ)<64)).mpr
  have : (0:ℝ) ≤ C := Nat.cast_nonneg C
  nlinarith

theorem digitalNoise_pos (C : ℕ) : 0 < digitalNoise C := by
  unfold digitalNoise
  exact div_pos (digitalError_pos C) (by norm_num)

theorem digitalBulk_nonneg (r : ℕ) : 0 ≤ digitalBulk r := by
  unfold digitalBulk
  positivity

theorem digitalGain_pos (C r : ℕ) : 0 < digitalGain C r := by
  unfold digitalGain digitalBulk
  positivity

theorem digitalCylinderRadius_pos (d C : ℕ) : 0 < digitalCylinderRadius d C := by
  unfold digitalCylinderRadius
  exact div_pos (digitalError_pos C) (by positivity)

/-- A reusable scalar verification of the depth-independent contraction. -/
theorem digital_contraction_of_bounds {ε τ A β ρ G : ℝ}
    (hε : 0 ≤ ε) (hε1 : ε ≤ 1) (hτ : 0 ≤ τ) (hτsmall : τ ≤ ε/8)
    (hA : 64 ≤ A) (hAε : 32 ≤ A*ε)
    (hβ : 0 ≤ β) (hβA : 64*β ≤ A)
    (hρG : 0 ≤ ρ^2*G) (hρsmall : ρ^2*G ≤ ε^2) :
    3*((4/A)^2+(8/A)^2*(4*ρ^2*G*(1+ε^2)+2*β^2*ε^2)+τ^2) ≤ ε^2 := by
  have hApos : 0 < A := by linarith
  have h4 : 4/A ≤ ε/8 := by apply (div_le_iff₀ hApos).mpr; nlinarith
  have h8 : 8/A ≤ 1/8 := by apply (div_le_iff₀ hApos).mpr; nlinarith
  have h8β : 8*β/A ≤ 1/8 := by apply (div_le_iff₀ hApos).mpr; nlinarith
  have h4sq := (sq_le_sq₀ (by positivity : 0 ≤ 4/A) (by positivity : 0 ≤ ε/8)).mpr h4
  have h8sq := (sq_le_sq₀ (by positivity : 0 ≤ 8/A) (by norm_num : (0:ℝ) ≤ 1/8)).mpr h8
  have h8βsq := (sq_le_sq₀ (by positivity : 0 ≤ 8*β/A) (by norm_num : (0:ℝ) ≤ 1/8)).mpr h8β
  have hτsq := (sq_le_sq₀ hτ (by positivity : 0 ≤ ε/8)).mpr hτsmall
  have hepssq : ε^2 ≤ 1 := by nlinarith
  have hR : 4*ρ^2*G*(1+ε^2) ≤ 8*ε^2 := by
    have hh := mul_le_mul hρsmall (by linarith : 1+ε^2 ≤ 2) (by positivity) (sq_nonneg ε)
    nlinarith
  have hRp : 0 ≤ 4*ρ^2*G*(1+ε^2) := by
    nlinarith [mul_nonneg hρG (by positivity : 0 ≤ 1+ε^2)]
  have hRR := mul_le_mul h8sq hR hRp (by norm_num : (0:ℝ) ≤ (1/8)^2)
  have hBB := mul_le_mul_of_nonneg_right h8βsq (by positivity : 0 ≤ 2*ε^2)
  have heq : (8/A)^2*(2*β^2*ε^2) = (8*β/A)^2*(2*ε^2) := by ring
  rw [← heq] at hBB
  nlinarith

end NeuralGeneralization.ConcreteModel
