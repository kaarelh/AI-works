import TargetProgramParameters
import Mathlib.Analysis.SpecialFunctions.Log.Deriv

noncomputable section
set_option maxHeartbeats 1000000
namespace ConditionalNonpolynomial.Analytic

def targetLogBudget (v : ℝ) (H : ℕ) : ℝ := 1+Real.log (1/v)+Real.log ((H:ℝ)+1)

theorem targetLogBudget_ge_one {v : ℝ} (hv : 0<v) (hv1 : v≤1) (H : ℕ) :
    1≤targetLogBudget v H := by
  have h1 : 1≤1/v := (le_div_iff₀ hv).mpr (by linarith)
  have hH : 1≤(H:ℝ)+1 := by linarith [Nat.cast_nonneg (α := ℝ) H]
  unfold targetLogBudget
  linarith [Real.log_nonneg h1,Real.log_nonneg hH]

theorem targetLogBudget_cooled_ratio {v w p K : ℝ} (H : ℕ)
    (hv : 0<v) (hv1 : v≤1) (hp : 0<p) (hp1 : p≤1) (hK : 0≤K)
    (hw : v*Real.exp (-K*(1+Real.log ((H:ℝ)+1)))≤w) :
    Real.log (p/w)≤(1+K)*targetLogBudget v H := by
  have hbase : 0<v*Real.exp (-K*(1+Real.log ((H:ℝ)+1))) := by positivity
  have hw0 : 0<w := hbase.trans_le hw
  have hlog := Real.log_le_log hbase hw
  rw [Real.log_mul hv.ne' (Real.exp_ne_zero _),Real.log_exp] at hlog
  have hpLog : Real.log p≤0 := Real.log_nonpos hp.le hp1
  have hHLog : 0≤Real.log ((H:ℝ)+1) := Real.log_nonneg (by linarith [Nat.cast_nonneg (α := ℝ) H])
  have hvLog : 0≤Real.log (1/v) := Real.log_nonneg ((le_div_iff₀ hv).mpr (by linarith))
  have he : Real.log (1/v) = -Real.log v := by rw [Real.log_div one_ne_zero hv.ne',Real.log_one]; ring
  rw [Real.log_div hp.ne' hw0.ne']
  unfold targetLogBudget
  rw [he] at hvLog
  rw [he]
  nlinarith [mul_nonneg hK hvLog,mul_nonneg hK hHLog]

theorem target_purification_residual {cPur T p : ℝ} (H : ℕ)
    (hPur : 0<cPur) (hp : 0<p) (hT : Real.log ((H:ℝ)+1)≤T) :
    Real.exp (-cPur*p*(targetPurificationLength cPur T p:ℝ))*p ≤ p/((H:ℝ)+1)^3 := by
  have hh := (div_le_iff₀ (mul_pos hPur hp)).mp
    (Nat.le_ceil (3*T/(cPur*p)))
  have harg : -cPur*p*(targetPurificationLength cPur T p:ℝ) ≤ -3*Real.log ((H:ℝ)+1) := by
    change 3*T≤(targetPurificationLength cPur T p:ℝ)*(cPur*p) at hh
    nlinarith
  have he := mul_le_mul_of_nonneg_right (Real.exp_le_exp.mpr harg) hp.le
  have hH : 0<(H:ℝ)+1 := by positivity
  have hexp : Real.exp (-3*Real.log ((H:ℝ)+1)) = 1/((H:ℝ)+1)^3 := by
    rw [show -3*Real.log ((H:ℝ)+1) = -Real.log (((H:ℝ)+1)^3) by rw [Real.log_pow]; norm_num]
    rw [Real.exp_neg,Real.exp_log (pow_pos hH 3)]
    simp only [one_div]
  rw [hexp] at he
  simpa only [one_div,inv_mul_eq_div] using he

theorem target_residual_positive {p : ℝ} (hp : 0<p) (H : ℕ) : 0<p/((H:ℝ)+1)^3 := by positivity

#print axioms targetLogBudget_cooled_ratio
#print axioms target_purification_residual
end ConditionalNonpolynomial.Analytic
