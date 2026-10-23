import NeuralGeneralization.BatchTwoOnlineSharpCylinderContainment
import NeuralGeneralization.BatchTwoOnlineSharpCylinderRectangle

/-! The exact A_L(d,C) target-mass bound from the online manuscript, proved
for the actual Gaussian prior at every width above teacher complexity. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel MeasureTheory ProbabilityTheory

theorem smallPrior_target_mass_sharp {d C N r : ℕ} (hd : 0<d)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N)
    {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-targetCost d C r/(2*σ^2))≤functionMass φ (1/2) (smallPrior d N r σ) f := by
  classical
  have hC:1≤C:=hf.1
  have hN:0<N:=lt_of_lt_of_le (by omega : 0<C) hCN
  obtain ⟨v,b,J,hmargin,hcost,hlayers,hreadcost,hJ,hrows,hhidden⟩:=
    exists_sharp_adapted_teacher φ f hf hCN
  let ρ:=cylinderRadius d C r
  let D:ℝ:=(d:ℝ)+2+r*C
  have hρ:0<ρ:=cylinderRadius_pos _ _ _
  have hρhalf:ρ≤1/2:=cylinderRadius_le_half _ _ _
  let a : {q : WeightIndex d N r//constrainedIndex J q}→ℝ:=
    fun q=>rotateInternalRows b.repr (whiten v) q.val
  let T:=BatchTwoMerging.sharpCoordinateCylinder v b J ρ σ
  have hsub:T⊆marginEvent φ (1/2) f:=by
    intro w hw
    exact sharp_cylinder_containment hd hN hC φ hφ f w v b J hσ.le hscale hJ
      hmargin hlayers hreadcost hrows hhidden hw
  have hfree:=BatchTwoMerging.sharpFreeCoordinateEvent_real_ge_half (d:=d) (r:=r) hN J hσ hscale
  have hmass:=smallPrior_selected_cylinder_sharp hd hN hσ hρ hρhalf
    (internalRowIsometry b.repr) (constrainedIndex J) a
    (BatchTwoMerging.sharpFreeCoordinateEvent J (BatchTwoMerging.sharpBulkBound r)) hfree
  have htarget:(smallPrior d N r σ).real T≤functionMass φ (1/2) (smallPrior d N r σ) f:=
    measureReal_mono hsub (measure_ne_top _ _)
  have henergy:(∑q,a q^2)≤cylinderCenterBudget d C r:=
    (selected_rotated_center_energy_le hd hN b.repr (constrainedIndex J) v).trans hcost
  have hdim:(Fintype.card {q : WeightIndex d N r//constrainedIndex J q}:ℝ)≤2*(N:ℝ)*D:=by
    rw [card_constrainedIndex]
    push_cast
    have hJr:(J.card:ℝ)≤(C:ℝ)+1:=by exact_mod_cast hJ
    have hCr:1≤(C:ℝ):=by exact_mod_cast hC
    have hr:0≤(r:ℝ):=Nat.cast_nonneg _
    have hd0:0≤(d:ℝ):=Nat.cast_nonneg _
    have hcoeff:(d:ℝ)+2+r*J.card≤2*D:=by
      dsimp [D]
      nlinarith [mul_le_mul_of_nonneg_left hJr hr,mul_le_mul_of_nonneg_left hCr hr]
    have hh:=mul_le_mul_of_nonneg_left hcoeff (Nat.cast_nonneg N : (0:ℝ)≤N)
    nlinarith only [hh]
  have hNσ:(N:ℝ)≤1/σ^2:=(le_div_iff₀ (sq_pos_of_pos hσ)).mpr hscale
  have hsig:σ^2≤1:=by
    have hn:1≤(N:ℝ):=by exact_mod_cast hN
    nlinarith [sq_nonneg σ]
  have hD:0≤D:=by dsimp [D];positivity
  have hcenter:0≤cylinderCenterBudget d C r:=by unfold cylinderCenterBudget;positivity
  have hcostbound:(∑q,a q^2)/σ^2+(Fintype.card {q : WeightIndex d N r//constrainedIndex J q}:ℝ)/ρ+1≤
      targetCost d C r/(2*σ^2) := by
    have he:=div_le_div_of_nonneg_right henergy (sq_nonneg σ)
    have hd1:=div_le_div_of_nonneg_right hdim hρ.le
    have hd2:=mul_le_mul_of_nonneg_right hNσ (show 0≤2*D/ρ by positivity)
    have h1:1≤1/σ^2:=(one_le_div (sq_pos_of_pos hσ)).mpr hsig
    have hid:targetCost d C r/(2*σ^2)=
        cylinderCenterBudget d C r/σ^2+(1/σ^2)*(2*D/ρ)+1/σ^2:=by
      unfold targetCost
      dsimp [D,ρ]
      field_simp
      <;> ring
    rw [hid]
    have hd3:(Fintype.card {q : WeightIndex d N r//constrainedIndex J q}:ℝ)/ρ≤(1/σ^2)*(2*D/ρ):=
      hd1.trans (by convert hd2 using 1 <;> ring)
    exact add_le_add (add_le_add he hd3) h1
  have hhalf:Real.exp (-1)≤(1:ℝ)/2:=by
    have hh:(2:ℝ)≤Real.exp 1:=by linarith [Real.add_one_le_exp 1]
    have hi:=one_div_le_one_div_of_le (by norm_num : (0:ℝ)<2) hh
    simpa only [one_div,←Real.exp_neg] using hi
  calc
    _ ≤ Real.exp (-1)*Real.exp (-(∑q,a q^2)/σ^2-(Fintype.card {q : WeightIndex d N r//constrainedIndex J q}:ℝ)/ρ):=by
      rw [←Real.exp_add]
      apply Real.exp_le_exp.mpr
      simp only [neg_div]
      linarith only [hcostbound]
    _ ≤ (1/2)*Real.exp (-(∑q,a q^2)/σ^2-(Fintype.card {q : WeightIndex d N r//constrainedIndex J q}:ℝ)/ρ):=
      mul_le_mul_of_nonneg_right hhalf (Real.exp_nonneg _)
    _ ≤ (smallPrior d N r σ).real T:=hmass
    _ ≤ _:=htarget

theorem powerPrior_target_mass_sharp {d C N r : ℕ} (hd : 0<d)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) {γ : ℝ} (hγ : 1≤γ) :
    Real.exp (-targetCost d C r*(N:ℝ)^γ/2)≤functionMass φ (1/2) (powerPrior d N r γ) f := by
  have hN:0<N:=lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hh:=smallPrior_target_mass_sharp hd φ hφ f hf hCN (powerStandardDeviation_pos hN γ)
    (width_mul_powerStandardDeviation_sq_le_one hN hγ)
  rw [←powerPrior_eq_smallPrior_standardDeviation hN γ] at hh
  have he:-targetCost d C r/(2*(powerStandardDeviation N γ)^2)=-targetCost d C r*(N:ℝ)^γ/2:=by
    rw [powerStandardDeviation_sq hN,Real.rpow_neg (Nat.cast_nonneg N)]
    field_simp
  simpa only [he] using hh

end NeuralGeneralization.BatchTwoOnlineSharp
