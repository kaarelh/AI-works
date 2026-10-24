import NeuralGeneralization.BatchTwoShallowMain

/-! Solving the sharper dimension bound's implicit sample-size inequality. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.BatchTwoShallow

theorem explicit_log_budget {A B x : ℝ} (hA : 0 ≤ A) (hB : 0 ≤ B)
    (hT : 1 ≤ A+B) (hx : 4*(A+B)*Real.log (8*Real.exp 1*(A+B)) ≤ x) :
    A*Real.log (2*Real.exp 1*x)+B ≤ x := by
  let T := A+B
  let L := Real.log (8*Real.exp 1*T)
  let x₀ := 4*T*L
  have hTp : 0 < T := by dsimp [T]; linarith
  have hL : 1 ≤ L := by
    have harg : Real.exp 1 ≤ 8*Real.exp 1*T := by
      have he := Real.exp_pos (1 : ℝ)
      change 1 ≤ T at hT
      nlinarith
    have h := Real.log_le_log (Real.exp_pos (1 : ℝ)) harg
    simpa only [Real.log_exp] using h
  have hLp : 0 < L := by linarith
  have hx₀ : 0 < x₀ := by positivity
  have hxx₀ : x₀ ≤ x := hx
  have hxp : 0 < x := hx₀.trans_le hxx₀
  have hAx₀ : A ≤ x₀ := by
    have hAT : A ≤ T := by dsimp [T]; linarith
    have hTL : T ≤ T*L := by nlinarith
    dsimp [x₀]
    nlinarith
  have hlogx₀ : Real.log (2*Real.exp 1*x₀) = L+Real.log L := by
    have he : 2*Real.exp 1*x₀ = (8*Real.exp 1*T)*L := by dsimp [x₀]; ring
    rw [he, Real.log_mul (by positivity : 8*Real.exp 1*T ≠ 0) hLp.ne']
  have hbase : A*Real.log (2*Real.exp 1*x₀)+B ≤ x₀ := by
    rw [hlogx₀]
    have hl0 := Real.log_nonneg hL
    have hlog := Real.log_le_sub_one_of_pos hLp
    have hAT : A ≤ T := by dsimp [T]; linarith
    have hBT : B ≤ T := by dsimp [T]; linarith
    have h1 : A*(L+Real.log L) ≤ T*(L+Real.log L) :=
      mul_le_mul_of_nonneg_right hAT (by linarith)
    have h2 : T*(L+Real.log L)+T ≤ 2*T*L := by nlinarith
    dsimp [x₀]
    nlinarith
  have hratio : 1 ≤ x/x₀ := (le_div_iff₀ hx₀).mpr (by simpa using hxx₀)
  have hratio0 : 0 < x/x₀ := by positivity
  have hlogratio0 := Real.log_nonneg hratio
  have hlogratio := Real.log_le_sub_one_of_pos hratio0
  have hmul := mul_le_mul_of_nonneg_left hlogratio hx₀.le
  have hcancel : x₀*(x/x₀-1)=x-x₀ := by field_simp
  rw [hcancel] at hmul
  have hAx := mul_le_mul_of_nonneg_right hAx₀ hlogratio0
  have hlogx : Real.log (2*Real.exp 1*x) =
      Real.log (2*Real.exp 1*x₀)+Real.log (x/x₀) := by
    rw [← Real.log_mul (by positivity : 2*Real.exp 1*x₀ ≠ 0) hratio0.ne']
    congr 1
    field_simp
  rw [hlogx, mul_add]
  linarith

end NeuralGeneralization.BatchTwoShallow
