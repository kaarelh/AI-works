import NeuralGeneralization.NeuralPolynomialConditioningCost

/-! A polynomial-energy actual interpolant on the comparator sample event. -/
noncomputable section
set_option maxHeartbeats 800000
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel

def interpolantPolyConstant (k : ℕ) (A : ℝ) : ℝ :=
  8*A^2*(1/(2/Real.pi)^(k+1)+4*energyPolyConstant k+4)
lemma interpolantPolyConstant_nonneg (k : ℕ) (A : ℝ) : 0 ≤ interpolantPolyConstant k A := by
  have := energyPolyConstant_pos k
  unfold interpolantPolyConstant
  positivity

/-- One explicit globally separated interpolant for every sample labeling,
with polynomial energy and linear dependence on sample count. -/
theorem neural_polynomial_global_interpolant {d n : ℕ} (hd : 101 ≤ d)
    (k R : ℕ) (hR : 0 < R) (A : ℝ) (hA : 0 < A)
    (s : Fin n → ClippingCube d) (f : BooleanFunction d)
    (hsep : ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j))
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20)
    (hcross : offDiagonalSum (fun x y => |pairEnergy
      (walshCoefficients (arcsineProfile d (k+1))) x y|) s ≤ 1) :
    ∃ P : ClippingCube d → ℝ, (∀ x, A < |P x|) ∧
      (∀ i, A < labelReal (f (s i))*P (s i)) ∧
      featureEnergy (walshCoefficients (arcsineProfile d (k+1))) (walshCoefficients P) ≤
        interpolantPolyConstant k A*((n:ℝ)+1)*((d:ℝ)+1)^3 := by
  let w := walshCoefficients (arcsineProfile d (k+1))
  obtain ⟨P,hmargin,htrain,henergy⟩ := exists_global_interpolant_of_good_sample
    w (iterated_arcsine_coefficient_pos d k) A (energyPolyConstant k*((d:ℝ)+1)^3) 1 hA
    ((sharp_diagonalEnergy_bound hd k).trans (sharpEnergyBudget_polynomial_le d k))
    s R hR hsep hsmall hcross f
  refine ⟨P,hmargin,htrain,henergy.trans ?_⟩
  have hD : 1 ≤ (d:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) d]
  have hN : 1 ≤ (n:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) n]
  have hD3 : (d:ℝ)+1 ≤ ((d:ℝ)+1)^3 := by nlinarith [sq_nonneg (d:ℝ)]
  have hC := energyPolyConstant_pos k
  have hC0 : 0 < 1/(2/Real.pi)^(k+1) := by positivity
  have hconst : 1/w ∅ ≤ (1/(2/Real.pi)^(k+1))*((d:ℝ)+1) := by
    have h := one_div_le_one_div_of_le
      (by positivity : 0 < (2/Real.pi)^(k+1)/((d:ℝ)+1))
      (arcsineProfile_coefficient_empty_lower d (k+1))
    calc
      _ ≤ 1/((2/Real.pi)^(k+1)/((d:ℝ)+1)) := h
      _ = _ := by field_simp
  have hB : 1/w ∅+4*((n:ℝ)*(energyPolyConstant k*((d:ℝ)+1)^3)+1) ≤
      (1/(2/Real.pi)^(k+1)+4*energyPolyConstant k+4)*((n:ℝ)+1)*((d:ℝ)+1)^3 := by
    have he1 : (1/(2/Real.pi)^(k+1))*((d:ℝ)+1) ≤
      (1/(2/Real.pi)^(k+1))*((n:ℝ)+1)*((d:ℝ)+1)^3 := by
      calc
        _ ≤ (1/(2/Real.pi)^(k+1))*((d:ℝ)+1)^3 := mul_le_mul_of_nonneg_left hD3 hC0.le
        _ ≤ _ := by
          have hp0 : 0 ≤ (n:ℝ)*((1/(2/Real.pi)^(k+1))*((d:ℝ)+1)^3) := by positivity
          nlinarith only [hp0]
    have hcube : 1 ≤ ((n:ℝ)+1)*((d:ℝ)+1)^3 :=
      one_le_mul_of_one_le_of_one_le hN (one_le_pow₀ hD)
    nlinarith [hconst, mul_nonneg hC.le (show 0 ≤ ((d:ℝ)+1)^3 by positivity)]
  have hh := mul_le_mul_of_nonneg_left hB (show 0 ≤ 8*A^2 by positivity)
  convert hh using 1 <;> unfold interpolantPolyConstant <;> ring

end NeuralGeneralization.LocalizedCubeBump
