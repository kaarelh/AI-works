import NeuralGeneralization.NeuralComparatorProbability

/-! Uniformly probable damped neural comparator events. The damping scale
may vary with the dimension and cutoff; only its explicit inverse bound
and the number of damped modes enter the proof. -/
noncomputable section
open MeasureTheory Filter
open scoped BigOperators Topology NNReal
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel CompressionSampling

private def coordinateConstant (k : ℕ) : ℝ := 24/(2/Real.pi)^k
private lemma coordinateConstant_pos (k : ℕ) : 0<coordinateConstant k := by
  unfold coordinateConstant
  positivity

lemma damped_coordinate_envelope (d k : ℕ) (tau : ℝ≥0)
    (hinv : 1/(tau:ℝ)≤(d:ℝ)+1) :
    neuralCoordinateBudget d k/(tau:ℝ) ≤
      (24/(2/Real.pi)^k)*((d:ℝ)+1)^4*Real.exp (-7*(d:ℝ)/25) := by
  have hc := neuralCoordinateBudget_exp_bound d k
  have hmul := mul_le_mul hc hinv (by positivity : (0:ℝ)≤1/(tau:ℝ))
    (by positivity : 0≤(24/(2/Real.pi)^k)*((d:ℝ)+1)^3*Real.exp (-7*(d:ℝ)/25))
  calc
    _ = neuralCoordinateBudget d k*(1/(tau:ℝ)) := by ring
    _ ≤ ((24/(2/Real.pi)^k)*((d:ℝ)+1)^3*Real.exp (-7*(d:ℝ)/25))*((d:ℝ)+1) := hmul
    _ = _ := by ring

lemma damped_energy_polynomial_envelope (d k r n : ℕ) (tau : ℝ≥0)
    (hinv : 1/(tau:ℝ)≤(d:ℝ)+1)
    (hmodes : (lowModes d r).card≤n)
    (hn : (n:ℝ)≤Real.exp ((d:ℝ)/1000)) :
    dampedEnergyBudget d k r tau ≤
      (energyPolyConstant k+24/(2/Real.pi)^k)*((d:ℝ)+1)^4 := by
  have hc := damped_coordinate_envelope d k tau hinv
  have hmc : ((lowModes d r).card:ℝ)≤n := by exact_mod_cast hmodes
  have hD : 1≤(d:ℝ)+1 := by have := Nat.cast_nonneg (α:=ℝ) d; linarith
  have hp : ((d:ℝ)+1)^3≤((d:ℝ)+1)^4 := by nlinarith [pow_nonneg (le_trans (by norm_num) hD) 3]
  have hcross : ((lowModes d r).card:ℝ)*(neuralCoordinateBudget d k/(tau:ℝ)) ≤
      (24/(2/Real.pi)^k)*((d:ℝ)+1)^4 := by
    calc
      _ ≤ Real.exp ((d:ℝ)/1000)*
        ((24/(2/Real.pi)^k)*((d:ℝ)+1)^4*Real.exp (-7*(d:ℝ)/25)) :=
        mul_le_mul (hmc.trans hn) hc (div_nonneg (neuralCoordinateBudget_pos d k).le tau.coe_nonneg)
          (Real.exp_pos _).le
      _ = (24/(2/Real.pi)^k)*((d:ℝ)+1)^4*
          Real.exp ((d:ℝ)/1000-7*(d:ℝ)/25) := by
        rw [show (d:ℝ)/1000-7*(d:ℝ)/25=(d:ℝ)/1000+(-7*(d:ℝ)/25) by ring,Real.exp_add]
        ring
      _ ≤ _ := by
        have he : Real.exp ((d:ℝ)/1000-7*(d:ℝ)/25)≤1 :=
          Real.exp_le_one_iff.mpr (by nlinarith [Nat.cast_nonneg (α:=ℝ) d])
        exact (mul_le_mul_of_nonneg_left he (by positivity)).trans_eq (mul_one _)
  have hen := (sharpEnergyBudget_polynomial_le d k).trans
    (mul_le_mul_of_nonneg_left hp (energyPolyConstant_pos k).le)
  unfold dampedEnergyBudget
  rw [mul_div_assoc]
  calc
    _ ≤ energyPolyConstant k*((d:ℝ)+1)^4+(24/(2/Real.pi)^k)*((d:ℝ)+1)^4 := add_le_add hen hcross
    _ = _ := by ring

lemma damped_cross_envelope (d k r n : ℕ) (tau : ℝ≥0)
    (hinv : 1/(tau:ℝ)≤(d:ℝ)+1) (hmodes : (lowModes d r).card≤n)
    (hn : (n:ℝ)≤Real.exp ((d:ℝ)/1000)) :
    (n:ℝ)^2*Real.sqrt ((neuralCoordinateBudget d k/(tau:ℝ))*dampedEnergyBudget d k r tau) ≤
      Real.sqrt (((24/(2/Real.pi)^k)*(energyPolyConstant k+24/(2/Real.pi)^k))*
        ((d:ℝ)+1)^8*Real.exp (-(d:ℝ)/4)) := by
  have hcoord := damped_coordinate_envelope d k tau hinv
  have henergy := damped_energy_polynomial_envelope d k r n tau hinv hmodes hn
  have hpos := dampedEnergyBudget_pos d k r tau
  have hn4 := pow_le_pow_left₀ (Nat.cast_nonneg n : (0:ℝ)≤n) hn 4
  rw [←Real.exp_nat_mul] at hn4
  norm_num only [Nat.cast_ofNat] at hn4
  have he : (n:ℝ)^4*((neuralCoordinateBudget d k/(tau:ℝ))*dampedEnergyBudget d k r tau) ≤
      ((24/(2/Real.pi)^k)*(energyPolyConstant k+24/(2/Real.pi)^k))*
        ((d:ℝ)+1)^8*Real.exp (-(d:ℝ)/4) := by
    calc
      _ ≤ Real.exp (4*((d:ℝ)/1000))*
        (((24/(2/Real.pi)^k)*((d:ℝ)+1)^4*Real.exp (-7*(d:ℝ)/25))*
          ((energyPolyConstant k+24/(2/Real.pi)^k)*((d:ℝ)+1)^4)) := by
        apply mul_le_mul hn4 _
          (mul_nonneg (div_nonneg (neuralCoordinateBudget_pos d k).le tau.coe_nonneg) hpos.le)
          (Real.exp_pos _).le
        exact mul_le_mul hcoord henergy hpos.le (by positivity)
      _ = ((24/(2/Real.pi)^k)*(energyPolyConstant k+24/(2/Real.pi)^k))*
        ((d:ℝ)+1)^8*Real.exp (4*((d:ℝ)/1000)-7*(d:ℝ)/25) := by
        rw [show 4*((d:ℝ)/1000)-7*(d:ℝ)/25=
          4*((d:ℝ)/1000)+(-7*(d:ℝ)/25) by ring,Real.exp_add]
        ring
      _ ≤ _ := by
        have hp := energyPolyConstant_pos k
        apply mul_le_mul_of_nonneg_left _ (by positivity)
        apply Real.exp_le_exp.mpr
        nlinarith [Nat.cast_nonneg (α:=ℝ) d]
  have hs := Real.sqrt_le_sqrt he
  rw [show (n:ℝ)^4=((n:ℝ)^2)^2 by ring,Real.sqrt_mul (sq_nonneg _),
    Real.sqrt_sq (sq_nonneg _)] at hs
  exact hs

end NeuralGeneralization.LocalizedCubeBump
