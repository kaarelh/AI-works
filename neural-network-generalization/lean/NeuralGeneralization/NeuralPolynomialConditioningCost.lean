import NeuralGeneralization.NeuralDampedConditioningCost
import NeuralGeneralization.NeuralLowEigenvalues

/-! # A polynomial conditioning cost for the small-sample range

On the same exponentially probable separation and cross-energy event, the
undamped comparator gives a bound polynomial in dimension and linear in
sample count, simultaneously for all targets. This intentionally coarse
bound is used only where the sample count is subexponential.
-/
noncomputable section
set_option maxHeartbeats 800000
open MeasureTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel FieldPosteriorBridge GaussianFieldTilt CompressionSampling

def energyPolyConstant (k : ℕ) : ℝ := 40000/sharpLowConstant k+24/(2/Real.pi)^k
lemma energyPolyConstant_pos (k : ℕ) : 0 < energyPolyConstant k := by
  unfold energyPolyConstant
  have := sharpLowConstant_pos k
  positivity

def conditioningPolyConstant (k : ℕ) (a : ℝ) : ℝ :=
  1+4*(a+3)^2*(1/(2/Real.pi)^(k+1)+4*energyPolyConstant k+4)
lemma conditioningPolyConstant_pos (k : ℕ) (a : ℝ) : 0 < conditioningPolyConstant k a := by
  unfold conditioningPolyConstant
  have := energyPolyConstant_pos k
  positivity

lemma sharpEnergyBudget_polynomial_le (d k : ℕ) :
    sharpEnergyBudget d k ≤ energyPolyConstant k*((d:ℝ)+1)^3 := by
  have hD : 1 ≤ (d:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) d]
  have hc := sharpLowConstant_pos k
  have hp : 1 ≤ (2:ℝ)^(k+1) := one_le_pow₀ (by norm_num)
  have hβ : 1/(2:ℝ)^(k+1) ≤ (3:ℝ) := by
    have h1 : 1/(2:ℝ)^(k+1) ≤ 1 := (div_le_one (by positivity)).mpr hp
    linarith
  have hpow : ((d:ℝ)+1)^(1/(2:ℝ)^(k+1)) ≤ ((d:ℝ)+1)^3 := by
    convert Real.rpow_le_rpow_of_exponent_le hD hβ using 1 <;> norm_num
  have htail : (99/100:ℝ)^d ≤ 1 := pow_le_one₀ (by norm_num) (by norm_num)
  have he : (99/100:ℝ)^d/neuralFloor d k =
      (24/(2/Real.pi)^k)*(99/100:ℝ)^d*((d:ℝ)+1)^3 := by unfold neuralFloor; field_simp
  unfold sharpEnergyBudget energyPolyConstant
  rw [he]
  calc
    _ ≤ (40000/sharpLowConstant k)*((d:ℝ)+1)^3+
      (24/(2/Real.pi)^k)*1*((d:ℝ)+1)^3 := by gcongr
    _ = _ := by ring

lemma neural_strip_polynomial_buffer (d : ℕ) :
    4*(Fintype.card (ClippingCube d):ℝ)*Real.exp (-(2*((d:ℝ)+1))^2/(2*1)) ≤ 1 := by
  have he : (2:ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1:ℝ)]
  have h2 : (4:ℝ) ≤ Real.exp 2 := by
    rw [show (2:ℝ)=1+1 by norm_num, Real.exp_add]
    nlinarith [Real.exp_pos (1:ℝ)]
  have hd : (2:ℝ)^d ≤ Real.exp (d:ℝ) := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ) ≤ 2) he d
    simpa only [← Real.exp_nat_mul, mul_one] using hh
  have hg : 4*(2:ℝ)^d ≤ Real.exp (2*((d:ℝ)+1)^2) := by
    calc
      _ ≤ Real.exp 2*Real.exp (d:ℝ) := mul_le_mul h2 hd (by positivity) (Real.exp_pos _).le
      _ = Real.exp (2+(d:ℝ)) := (Real.exp_add _ _).symm
      _ ≤ _ := Real.exp_le_exp.mpr (by nlinarith [Nat.cast_nonneg (α:=ℝ) d])
  have hcard : (Fintype.card (ClippingCube d):ℝ)=(2:ℝ)^d := by simp [ClippingCube]
  rw [hcard]
  have harg : -(2*((d:ℝ)+1))^2/(2*1)=-(2*((d:ℝ)+1)^2) := by ring
  rw [harg, Real.exp_neg]
  rw [← div_eq_mul_inv]
  exact (div_le_one (Real.exp_pos _)).mpr hg

/-- The exact event cost is polynomial on the explicit good sample event. -/
theorem neural_polynomial_conditioning_cost {d n : ℕ} (hd : 101 ≤ d)
    (k R : ℕ) (hR : 0 < R) (a : ℝ) (ha : 0 ≤ a)
    (s : Fin n → ClippingCube d) (f : BooleanFunction d)
    (hsep : ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j))
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20)
    (hcross : offDiagonalSum (fun x y => |pairEnergy
      (walshCoefficients (arcsineProfile d (k+1))) x y|) s ≤ 1) :
    Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (k+1))))).real
      (conditioningEvent (fun z : ClippingCube d → ℝ => z) a f s)) ≤
      conditioningPolyConstant k a*((n:ℝ)+1)*((d:ℝ)+1)^5 := by
  let w := walshCoefficients (arcsineProfile d (k+1))
  have hw : 0 < w ∅ := iterated_arcsine_coefficient_pos d k ∅
  have hs : (∑ S, w S)=1 := by
    have h := walshExpansion_coefficients (arcsineProfile d (k+1)) (fun _ => true)
    simpa [w, walshExpansion, walshCharacter, cubeCoordinateSign, arcsineProfile_one] using h
  have hE := (sharp_diagonalEnergy_bound hd k).trans (sharpEnergyBudget_polynomial_le d k)
  have hh := conditioning_cost_of_pair_bound w (iterated_arcsine_coefficient_pos d k)
    (fun _ => (1:ℝ≥0)) (fun _ => by norm_num) (fun _ => le_refl 1)
    a (2*((d:ℝ)+1)) 1 (energyPolyConstant k*((d:ℝ)+1)^3) 1 ha (by positivity) (by norm_num)
    (by simpa using hs.le) (neural_strip_polynomial_buffer d) s f R hR hsep hsmall
    (by simpa only [NNReal.coe_one, mul_one] using hE)
    (by simpa only [NNReal.coe_one, mul_one, offDiagonalSum, w] using hcross)
  simp only [NNReal.coe_one, mul_one, Real.sqrt_one, Finset.prod_const_one, Real.log_one, sub_zero] at hh
  refine hh.trans ?_
  have hD : 1 ≤ (d:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) d]
  have hN : 1 ≤ (n:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) n]
  have hD3 : (d:ℝ)+1 ≤ ((d:ℝ)+1)^3 := by nlinarith [sq_nonneg (d:ℝ)]
  have hD50 : 1 ≤ ((d:ℝ)+1)^5 := one_le_pow₀ hD
  have hC := energyPolyConstant_pos k
  have hC0 : 0 < 1/(2/Real.pi)^(k+1) := by positivity
  have hconst : 1/w ∅ ≤ (1/(2/Real.pi)^(k+1))*((d:ℝ)+1) := by
    have hlo := arcsineProfile_coefficient_empty_lower d (k+1)
    have hpos : 0 < (2/Real.pi)^(k+1)/((d:ℝ)+1) := by positivity
    have h := one_div_le_one_div_of_le hpos hlo
    calc
      _ ≤ 1/((2/Real.pi)^(k+1)/((d:ℝ)+1)) := h
      _ = _ := by field_simp
  have hbuf : (a+2*((d:ℝ)+1)+1)^2 ≤ (a+3)^2*((d:ℝ)+1)^2 := by
    have hbase : a+2*((d:ℝ)+1)+1 ≤ (a+3)*((d:ℝ)+1) := by nlinarith
    calc
      _ ≤ ((a+3)*((d:ℝ)+1))^2 := pow_le_pow_left₀ (by positivity) hbase 2
      _ = _ := by ring
  have hB : 1/w ∅+4*((n:ℝ)*(energyPolyConstant k*((d:ℝ)+1)^3)+1) ≤
      (1/(2/Real.pi)^(k+1)+4*energyPolyConstant k+4)*((n:ℝ)+1)*((d:ℝ)+1)^3 := by
    have he1 : (1/(2/Real.pi)^(k+1))*((d:ℝ)+1) ≤
      (1/(2/Real.pi)^(k+1))*((n:ℝ)+1)*((d:ℝ)+1)^3 := by
      calc
        _ ≤ (1/(2/Real.pi)^(k+1))*((d:ℝ)+1)^3 := mul_le_mul_of_nonneg_left hD3 hC0.le
        _ ≤ _ := by
          have hp0 : 0 ≤ (n:ℝ)*((1/(2/Real.pi)^(k+1))*((d:ℝ)+1)^3) := by positivity
          nlinarith only [hp0]
    have hcube : 1 ≤ ((n:ℝ)+1)*((d:ℝ)+1)^3 := one_le_mul_of_one_le_of_one_le hN (one_le_pow₀ hD)
    nlinarith [hconst, mul_nonneg hC.le (show 0 ≤ ((d:ℝ)+1)^3 by positivity)]
  have hlarge : Real.log 2 ≤ ((n:ℝ)+1)*((d:ℝ)+1)^5 :=
    (by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)] : Real.log 2 ≤ 1).trans
      (one_le_mul_of_one_le_of_one_le hN hD50)
  have hprod := mul_le_mul hbuf hB (by positivity : 0 ≤ 1/w ∅+4*((n:ℝ)*(energyPolyConstant k*((d:ℝ)+1)^3)+1))
    (by positivity : 0 ≤ (a+3)^2*((d:ℝ)+1)^2)
  have hp4 := mul_le_mul_of_nonneg_left hprod (by norm_num : (0:ℝ)≤4)
  calc
    _ ≤ ((n:ℝ)+1)*((d:ℝ)+1)^5+
      4*((a+3)^2*((d:ℝ)+1)^2)*
        ((1/(2/Real.pi)^(k+1)+4*energyPolyConstant k+4)*((n:ℝ)+1)*((d:ℝ)+1)^3) := by
          linarith only [hlarge, hp4]
    _ = _ := by unfold conditioningPolyConstant; ring

end NeuralGeneralization.LocalizedCubeBump
