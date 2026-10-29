import UniformTargetPolynomial

noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.Analytic

def uniformFinalActionConstant : ℝ := 676*(uniformTargetErrorConstant+258)
def uniformFinalWidthConstant : ℝ :=
  3000+702*uniformTargetErrorConstant+5537792*targetProgramConstant^2

theorem uniformFinalActionConstant_pos : 0<uniformFinalActionConstant := by
  unfold uniformFinalActionConstant
  have h := uniformTargetErrorConstant_nonneg
  positivity

theorem uniformFinalWidthConstant_ge_one : 1≤uniformFinalWidthConstant := by
  unfold uniformFinalWidthConstant
  nlinarith [uniformTargetErrorConstant_nonneg,sq_nonneg targetProgramConstant]

theorem scaled_subcriticalCostBaseline_le_half {t : ℝ} (ht : 0<t) (ht1 : t≤1) :
    t^2*subcriticalCostBaseline (t^2).toNNReal≤1/2 := by
  have hu : 0<t^2 := sq_pos_of_pos ht
  have hu1 : t^2≤1 := by nlinarith
  have hl : Real.log (t^2)≤0 := Real.log_nonpos hu.le hu1
  have hm := mul_nonpos_of_nonneg_of_nonpos hu.le hl
  have hid : t^2*subcriticalCostBaseline (t^2).toNNReal=
      (1-t^2+t^2*Real.log (t^2))/2 := by
    unfold subcriticalCostBaseline
    rw [Real.coe_toNNReal _ hu.le]
    field_simp
  rw [hid]
  linarith

theorem uniform_final_action_bound {t v R : ℝ} {H : ℕ}
    (ht : 0<t) (ht1 : t≤1) (hv : 0<v) (hv1 : v≤1) (hR : 2≤R) (hH : 1≤H)
    (hT : targetLogBudget v H≤26*Real.log R)
    (hlarge : 6656*targetProgramConstant*Real.log R≤(H:ℝ)) :
    uniformTargetPhysicalBudget t v H+2/((H:ℝ)*t^2)≤
      (H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
      uniformFinalActionConstant*(((t^2)⁻¹-1)*Real.log R+(Real.log R)^2/(H:ℝ)) := by
  let T := targetLogBudget v H
  let L := Real.log R
  let z := (t^2)⁻¹-1
  let E := uniformTargetErrorConstant+257
  have hu : 0<t^2 := sq_pos_of_pos ht
  have hz : 0≤z := by
    have hh : 1≤(t^2)⁻¹ := (one_le_inv₀ hu).mpr (by nlinarith)
    dsimp [z]
    linarith
  have hHr : (1:ℝ)≤H := by exact_mod_cast hH
  have hH0 : (0:ℝ)<H := by linarith
  have hL : 1/2≤L := logarithm_half_le hR
  have hT0 : 0≤T := by dsimp [T]; linarith [targetLogBudget_ge_one hv hv1 H]
  have hE : 0≤E := by dsimp [E]; linarith [uniformTargetErrorConstant_nonneg]
  have hA := targetProgramConstant_ge
  have hTH : T≤(H:ℝ) := by
    have hh := mul_le_mul_of_nonneg_right hA (show 0≤L by linarith)
    dsimp only [T,L] at *
    nlinarith only [hT,hlarge,hh]
  have hsq : T^2≤676*L^2 := by
    have hh := pow_le_pow_left₀ hT0 hT 2
    nlinarith
  have hdiv : T^2/(H:ℝ)≤676*(L^2/(H:ℝ)) := by
    have hh := div_le_div_of_nonneg_right hsq hH0.le
    simpa only [mul_div_assoc] using hh
  have hdivT : T^2/(H:ℝ)≤T := by
    apply (div_le_iff₀ hH0).mpr
    nlinarith
  have hzt := mul_le_mul_of_nonneg_left hT hz
  have hzdiv := mul_le_mul_of_nonneg_left hdivT hz
  have hinside : z*T+(1+z)*(T^2/(H:ℝ))≤52*(z*L)+676*(L^2/(H:ℝ)) := by
    nlinarith only [hzt,hzdiv,hdiv]
  have hpoly := uniformTargetPhysicalBudget_polynomial_critical ht ht1 hv hv1 H (by omega)
  have hphysical : uniformTargetPhysicalBudget t v H≤
      (H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
        E*(z*T+(1+z)*(T^2/(H:ℝ))) := by
    apply (mul_le_mul_iff_right₀ hu).mp
    apply hpoly.trans_eq
    dsimp only [z,T,E]
    field_simp
    ring
  have hscaled := mul_le_mul_of_nonneg_left hinside hE
  have hslack : 2/((H:ℝ)*t^2)=2/(H:ℝ)+z*(2/(H:ℝ)) := by
    dsimp [z]
    field_simp
    ring
  have hslack0 : 2/(H:ℝ)≤8*(L^2/(H:ℝ)) := by
    rw [←mul_div_assoc]
    apply (div_le_div_iff_of_pos_right hH0).mpr
    nlinarith
  have hslack1 : 2/(H:ℝ)≤4*L := by
    have hh : 2/(H:ℝ)≤2 := (div_le_self (by norm_num) hHr)
    linarith
  have hslackz := mul_le_mul_of_nonneg_left hslack1 hz
  have hx : 0≤z*L := mul_nonneg hz (by linarith)
  have hy : 0≤L^2/(H:ℝ) := by positivity
  have hcoeffx : 52*E+4≤uniformFinalActionConstant := by
    unfold uniformFinalActionConstant
    dsimp [E]
    linarith [uniformTargetErrorConstant_nonneg]
  have hcoeffy : 676*E+8≤uniformFinalActionConstant := by
    unfold uniformFinalActionConstant
    dsimp [E]
    linarith
  have hcx := mul_le_mul_of_nonneg_right hcoeffx hx
  have hcy := mul_le_mul_of_nonneg_right hcoeffy hy
  rw [hslack]
  change _≤(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
    uniformFinalActionConstant*(z*L+L^2/(H:ℝ))
  nlinarith only [hphysical,hscaled,hslack0,hslackz,hcx,hcy]

theorem uniform_final_width_bounds {t v R : ℝ} {H : ℕ}
    (ht : 0<t) (ht1 : t≤1) (hv : 0<v) (hv1 : v≤1) (hR : 2≤R) (hH : 1≤H)
    (hHR : (H:ℝ)+1≤R) (hT : targetLogBudget v H≤26*Real.log R) :
    t^2*uniformTargetPhysicalBudget t v H+2/(H:ℝ)+1≤uniformFinalWidthConstant*R^2 ∧
    8*uniformTargetCriticalBudget v H≤uniformFinalWidthConstant*R^2 := by
  have hHr : (1:ℝ)≤H := by exact_mod_cast hH
  have hH0 : (0:ℝ)<H := by linarith
  have hR0 : 0<R := by linarith
  have hRR : R≤R^2 := by nlinarith
  have hR2 : 1≤R^2 := by nlinarith
  have hlog : Real.log R≤R := by linarith [Real.log_le_sub_one_of_pos hR0]
  have hT0 : 0≤targetLogBudget v H := by linarith [targetLogBudget_ge_one hv hv1 H]
  have hT26 : targetLogBudget v H≤26*R := by linarith
  have hTsq : (targetLogBudget v H)^2≤676*R^2 := by
    have hh := pow_le_pow_left₀ hT0 hT26 2
    nlinarith
  have hdiv : (targetLogBudget v H)^2/(H:ℝ)≤676*R^2 :=
    (div_le_self (sq_nonneg _) hHr).trans hTsq
  have hE := uniformTargetErrorConstant_nonneg
  have hA2 := sq_nonneg targetProgramConstant
  have hEprod := mul_nonneg hE (sq_nonneg R)
  have hAprod := mul_nonneg hA2 (sq_nonneg R)
  have hu : 0≤1-t^2 := by nlinarith
  have hfac : (1-t^2)*targetLogBudget v H≤26*R^2 := by
    have hh : (1-t^2)*targetLogBudget v H≤targetLogBudget v H := by nlinarith [mul_nonneg (sq_nonneg t) hT0]
    nlinarith
  have herr := mul_le_mul_of_nonneg_left (show (1-t^2)*targetLogBudget v H+
    (targetLogBudget v H)^2/(H:ℝ)≤702*R^2 by linarith) hE
  have hpoly := uniformTargetPhysicalBudget_polynomial ht ht1 hv hv1 H (by omega)
  have hbase := mul_le_mul_of_nonneg_left (scaled_subcriticalCostBaseline_le_half ht ht1)
    (Nat.cast_nonneg (α:=ℝ) H)
  have htwo : 2/(H:ℝ)≤2 := div_le_self (by norm_num) hHr
  constructor
  · unfold uniformFinalWidthConstant
    nlinarith only [hpoly,hbase,herr,scalarBaseline_le,hHR,hRR,hR2,htwo,hAprod]
  · have hslack := mul_le_mul_of_nonneg_left hdiv
      (show 0≤1024*targetProgramConstant^2 by positivity)
    have hK : uniformTargetCriticalBudget v H≤257+692224*targetProgramConstant^2*R^2 := by
      unfold uniformTargetCriticalBudget uniformTargetSlack
      rw [mul_div_assoc]
      nlinarith only [hslack,scalarBaseline_le]
    unfold uniformFinalWidthConstant
    nlinarith only [hK,hR2,hEprod]

#print axioms uniform_final_width_bounds
#print axioms uniform_final_action_bound
end ConditionalNonpolynomial.Analytic
