import NeuralGeneralization.BatchTwoImprovedTargetMain
import NeuralGeneralization.BatchTwoMergingSharpGrowth

/-! Sharp width dependence of the original-support target cost. -/
noncomputable section
open Filter Asymptotics
namespace NeuralGeneralization.ConcreteModel
open NeuralGeneralization.BatchTwoMerging

private theorem target_log_argument_one (d:ℕ) {C:ℕ} (hC:0<C):
    1≤Real.exp 1*Real.sqrt (2*Real.pi)/(2*improvedRadius d C) := by
  have hr:=(improvedRadius_bounds d hC).1
  have hrE:=(improvedRadius_bounds d hC).2.1
  have he:=(improvedError_bounds hC).2
  have hs:1≤Real.sqrt (2*Real.pi) := by
    nlinarith [Real.sq_sqrt (show 0≤2*Real.pi by positivity),Real.sqrt_nonneg (2*Real.pi),Real.pi_gt_three]
  have hex:=Real.one_le_exp (show (0:ℝ)≤1 by norm_num)
  apply (le_div_iff₀ (by positivity : 0<2*improvedRadius d C)).mpr
  nlinarith [one_le_mul_of_one_le_of_one_le hex hs]

theorem improvedGain_width_growth (r:ℕ):WidthGrowth (fun C=>improvedGain C r) 0 1 := by
  have harg:=WidthGrowth.width.sqrt.const_mul 1024
  have hlog:=harg.log (by
    intro C hC
    have hs:1≤Real.sqrt C := by simpa using Real.sqrt_le_sqrt (show (1:ℝ)≤C by exact_mod_cast hC)
    nlinarith)
  exact ((WidthGrowth.const (128*(sharpBulkBound r+1))).mono (by omega) (by omega)).add (hlog.const_mul 2)

theorem improvedTeacherCost_width_growth (d r:ℕ) (c:ℝ):
    WidthGrowth (fun C=>improvedTeacherCost d C r c) 1 2 := by
  have hA:WidthGrowth (fun C=>improvedGain C r^2) 0 2 := by simpa using (improvedGain_width_growth r).pow 2
  have hfirst:= (hA.const_mul (9*d)).mono (show 0≤1 by omega) (show 2≤2 by omega)
  have hinner:= (WidthGrowth.width.mul hA).const_mul (18*r)
  have hout:= (WidthGrowth.width.const_mul (2*improvedReadout c^2)).mono (show 1≤1 by omega) (show 0≤2 by omega)
  exact ((hfirst.add hinner).add hout).congr (by intro C hC;unfold improvedTeacherCost;ring)

theorem improvedTargetCost_width_growth (d r:ℕ) (c:ℝ):
    WidthGrowth (fun C=>improvedTargetCost d C r c) 1 2 := by
  have hCplus:WidthGrowth (fun C=>(C:ℝ)+1) 1 0 := WidthGrowth.width.add
    ((WidthGrowth.const 1).mono (by omega) (by omega))
  have hinv:WidthGrowth (fun C=>(improvedRadius d C)⁻¹) 2 0 :=
    ((hCplus.mul WidthGrowth.width.sqrt).const_mul (4096*((d:ℝ)+1))).congr (by
      intro C hC
      unfold improvedRadius improvedError
      field_simp <;> ring)
  have harg:WidthGrowth (fun C=>Real.exp 1*Real.sqrt (2*Real.pi)/(2*improvedRadius d C)) 2 0 :=
    (hinv.const_mul (Real.exp 1*Real.sqrt (2*Real.pi)/2)).congr (by intro C hC;field_simp)
  have hl:=harg.log (fun C hC=>target_log_argument_one d hC)
  have hq:WidthGrowth (fun C=>(d:ℝ)+2+(r:ℝ)*((C:ℝ)+1)) 1 0 :=
    ((WidthGrowth.const ((d:ℝ)+2)).mono (by omega) (by omega)).add (hCplus.const_mul r)
  have hprod:WidthGrowth (fun C=>((d:ℝ)+2+(r:ℝ)*((C:ℝ)+1))*
      Real.log (Real.exp 1*Real.sqrt (2*Real.pi)/(2*improvedRadius d C))) 1 2 :=
    (hq.mul hl).mono (by omega) (by omega)
  exact ((improvedTeacherCost_width_growth d r c).add hprod).add
    ((WidthGrowth.const (Real.log 2)).mono (by omega) (by omega))

theorem improvedTargetCost_isBigO (d r:ℕ) (c:ℝ):
    (fun C=>improvedTargetCost d C r c) =O[atTop]
      (fun C=>(C:ℝ)*Real.log ((C:ℝ)+2)^2) := by
  simpa only [pow_one] using (improvedTargetCost_width_growth d r c).isBigO

end NeuralGeneralization.ConcreteModel
