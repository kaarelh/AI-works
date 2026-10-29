import ExactUniformTargetProgram
import TargetPolynomialFloor

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
namespace ConditionalNonpolynomial.Analytic

/-- Universal coefficient in the logarithmic entropy occupation bound. -/
def targetEntropyConstant : ℝ :=
  Real.sqrt (526337*1024*targetProgramConstant^2+526336)+3*dyadicBlockConstant 526336

theorem targetEntropyConstant_nonneg : 0≤targetEntropyConstant := by
  unfold targetEntropyConstant dyadicBlockConstant
  positivity

theorem log2_successor_bound (H : ℕ) :
    ((Nat.log2 (H+1)+1:ℕ):ℝ)≤2*Real.log ((H:ℝ)+1)+1 := by
  have hpow : 2^(Nat.log2 (H+1))≤H+1 := (Nat.le_log2 (by omega)).mp le_rfl
  have hpowR : (2:ℝ)^(Nat.log2 (H+1))≤(H:ℝ)+1 := by exact_mod_cast hpow
  have hm := Real.log_le_log (by positivity : 0<(2:ℝ)^(Nat.log2 (H+1))) hpowR
  rw [Real.log_pow] at hm
  have hl : (1:ℝ)/2≤Real.log 2 := logarithm_half_le (by norm_num)
  norm_num only [Nat.cast_add,Nat.cast_one] at hm ⊢
  nlinarith [Nat.cast_nonneg (α:=ℝ) (Nat.log2 (H+1))]

theorem uniformTargetSqrtBudget_logarithmic {v : ℝ} (hv : 0<v) (hv1 : v≤1)
    (H : ℕ) (hH : 0<H) :
    uniformTargetSqrtBudget v H≤targetEntropyConstant*targetLogBudget v H := by
  let T := targetLogBudget v H
  let K := 526337*1024*targetProgramConstant^2+526336
  have hT : 1≤T := targetLogBudget_ge_one hv hv1 H
  have hH0 : (0:ℝ)<H := by exact_mod_cast hH
  have hK : 0≤K := by dsimp [K]; positivity
  have he : 526337*(H:ℝ)*uniformTargetSlack v H+526336=
      526337*1024*targetProgramConstant^2*T^2+526336 := by
    dsimp [uniformTargetSlack,T]
    field_simp
    try ring
  have hs : Real.sqrt (526337*(H:ℝ)*uniformTargetSlack v H+526336)≤Real.sqrt K*T := by
    apply Real.sqrt_le_iff.mpr ⟨by positivity,?_⟩
    rw [he,mul_pow,Real.sq_sqrt hK]
    dsimp [K]
    nlinarith [sq_nonneg (T-1)]
  have hlogv : 0≤Real.log (1/v) := Real.log_nonneg
    ((le_div_iff₀ hv).mpr (by simpa using hv1))
  have hlogH : Real.log ((H:ℝ)+1)≤T := by dsimp [T,targetLogBudget]; linarith
  have hcount : ((Nat.log2 (H+1)+1:ℕ):ℝ)≤3*T := by
    have hh := log2_successor_bound H
    linarith
  have hm := mul_le_mul_of_nonneg_right hcount
    (show 0≤dyadicBlockConstant 526336 by exact Real.sqrt_nonneg _)
  unfold uniformTargetSqrtBudget targetEntropyConstant
  dsimp only [K] at hs
  nlinarith

theorem uniformTargetPhysicalBudget_scaled {t v : ℝ} (ht : 0<t) (H : ℕ) :
    t^2*uniformTargetPhysicalBudget t v H=
      (H:ℝ)*t^2*subcriticalCostBaseline (t^2).toNNReal+
      uniformTargetCriticalBudget v H+
      (1-t^2)*Real.sqrt 2*uniformTargetSqrtBudget v H := by
  unfold uniformTargetPhysicalBudget
  have ht0 : t≠0 := ht.ne'
  field_simp
  ring

def uniformTargetErrorConstant : ℝ := 1024*targetProgramConstant^2+
  Real.sqrt 2*targetEntropyConstant

theorem uniformTargetErrorConstant_nonneg : 0≤uniformTargetErrorConstant := by
  unfold uniformTargetErrorConstant
  exact add_nonneg (by positivity) (mul_nonneg (Real.sqrt_nonneg _) targetEntropyConstant_nonneg)

/-- Normalized physical action has a coefficient-one baseline and only the
nearcritical and log-squared-over-depth corrections. -/
theorem uniformTargetPhysicalBudget_polynomial {t v : ℝ}
    (ht : 0<t) (ht1 : t≤1) (hv : 0<v) (hv1 : v≤1) (H : ℕ) (hH : 0<H) :
    t^2*uniformTargetPhysicalBudget t v H≤
      (H:ℝ)*t^2*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
      uniformTargetErrorConstant*((1-t^2)*targetLogBudget v H+
        (targetLogBudget v H)^2/(H:ℝ)) := by
  rw [uniformTargetPhysicalBudget_scaled ht H]
  have hS := uniformTargetSqrtBudget_logarithmic hv hv1 H hH
  have hfac : 0≤(1-t^2)*Real.sqrt 2 := by
    apply mul_nonneg _ (Real.sqrt_nonneg _)
    nlinarith
  have hm := mul_le_mul_of_nonneg_left hS hfac
  have hT := targetLogBudget_ge_one hv hv1 H
  have hH0 : (0:ℝ)<H := by exact_mod_cast hH
  have hx : 0≤(1-t^2)*targetLogBudget v H := by
    apply mul_nonneg _ (by linarith)
    nlinarith
  have hy : 0≤(targetLogBudget v H)^2/(H:ℝ) := by positivity
  have hC : 0≤1024*targetProgramConstant^2 := by positivity
  have hD : 0≤Real.sqrt 2*targetEntropyConstant :=
    mul_nonneg (Real.sqrt_nonneg _) targetEntropyConstant_nonneg
  have hcross1 := mul_nonneg hC hx
  have hcross2 := mul_nonneg hD hy
  unfold uniformTargetCriticalBudget uniformTargetSlack uniformTargetErrorConstant
  simp only [div_eq_mul_inv] at hcross2 ⊢
  nlinarith only [hm,hcross1,hcross2]

/-- Coefficient one on the critical baseline is retained even before dividing
by the physical variance; the harmless baseline difference is absorbed into
the nearcritical error. -/
theorem uniformTargetPhysicalBudget_polynomial_critical {t v : ℝ}
    (ht : 0<t) (ht1 : t≤1) (hv : 0<v) (hv1 : v≤1) (H : ℕ) (hH : 0<H) :
    t^2*uniformTargetPhysicalBudget t v H≤
      (H:ℝ)*t^2*subcriticalCostBaseline (t^2).toNNReal+t^2*scalarBaseline.toReal+
      (uniformTargetErrorConstant+257)*((1-t^2)*targetLogBudget v H+
        (targetLogBudget v H)^2/(H:ℝ)) := by
  have hh := uniformTargetPhysicalBudget_polynomial ht ht1 hv hv1 H hH
  have hT := targetLogBudget_ge_one hv hv1 H
  have hθ : 0≤1-t^2 := by nlinarith
  have hbase := mul_le_mul_of_nonneg_left scalarBaseline_le hθ
  have hθT := mul_le_mul_of_nonneg_left hT hθ
  have hy : 0≤(targetLogBudget v H)^2/(H:ℝ) := by positivity
  nlinarith

#print axioms uniformTargetSqrtBudget_logarithmic
#print axioms uniformTargetPhysicalBudget_polynomial
end ConditionalNonpolynomial.Analytic
