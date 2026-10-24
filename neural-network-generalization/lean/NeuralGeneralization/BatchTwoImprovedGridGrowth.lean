import NeuralGeneralization.BatchTwoImprovedGrid
import NeuralGeneralization.BatchTwoMergingSharpGrowth

/-! The exact grid entropy preserves six powers of circuit width and thirteen
logarithms when compression uses width C³ log⁶ C. -/
noncomputable section
open Filter Asymptotics
namespace NeuralGeneralization.ConcreteModel
open NeuralGeneralization.BatchTwoMerging

theorem robustParameterCount_width_growth (d r:ℕ) {M:ℕ→ℕ} {p q:ℕ}
    (hM:WidthGrowth (fun C=>(M C:ℝ)) p q):
    WidthGrowth (fun C=>(robustParameterCount d (M C) r:ℝ)) (2*p) (2*q) := by
  have hlin:WidthGrowth (fun C=>(d+2:ℝ)*(M C:ℝ)) (2*p) (2*q) :=
    (hM.const_mul ((d:ℝ)+2)).mono (by omega) (by omega)
  have hquad:WidthGrowth (fun C=>(r:ℝ)*(M C:ℝ)^2) (2*p) (2*q) := by
    simpa [Nat.mul_comm] using (hM.pow 2).const_mul (r:ℝ)
  exact (hlin.add hquad).congr (by intro C hC;unfold robustParameterCount;push_cast;ring)

theorem improvedGridLogFactor_width_growth (d r:ℕ) {M B R:ℕ→ℕ} {p q u v a b:ℕ}
    (hM:WidthGrowth (fun C=>(M C:ℝ)) p q)
    (hB:WidthGrowth (fun C=>(B C:ℝ)) u v)
    (hR:WidthGrowth (fun C=>(R C:ℝ)) a b)
    (hBp:∀C,1≤C→0<B C) (hRp:∀C,1≤C→0<R C):
    WidthGrowth (fun C=>improvedGridLogFactor d (M C) r (B C) (R C)) 0 1 := by
  have hlogB:=hB.log (fun C hC=>by exact_mod_cast hBp C hC)
  have hlogR:=hR.log (fun C hC=>by exact_mod_cast hRp C hC)
  have hBplus:=hB.add ((WidthGrowth.const 1).mono (by omega) (by omega))
  have hbase:WidthGrowth (fun C=>(M C:ℝ)*((B C:ℝ)+1)+1) (p+u) (q+v) :=
    (hM.mul hBplus).add ((WidthGrowth.const 1).mono (by omega) (by omega))
  have hlogbase:=hbase.log (by
    intro C hC
    nlinarith [Nat.cast_nonneg (α:=ℝ) (M C),Nat.cast_nonneg (α:=ℝ) (B C)])
  have hc:WidthGrowth (fun _C:ℕ=>Real.log 3+Real.log ((d:ℝ)+1)) 0 1 :=
    (WidthGrowth.const _).mono (by omega) (by omega)
  exact (((hc.add hlogB).add hlogR).add (hlogbase.const_mul ((r:ℝ)+1))).congr
    (by intro C hC;unfold improvedGridLogFactor;ring)

theorem improvedGridEntropy_width_growth (d r:ℕ) {M B R:ℕ→ℕ} {p q u v a b:ℕ}
    (hM:WidthGrowth (fun C=>(M C:ℝ)) p q)
    (hB:WidthGrowth (fun C=>(B C:ℝ)) u v)
    (hR:WidthGrowth (fun C=>(R C:ℝ)) a b)
    (hBp:∀C,1≤C→0<B C) (hRp:∀C,1≤C→0<R C):
    WidthGrowth (fun C=>improvedGridEntropy d (M C) r (B C) (R C)) (2*p) (2*q+1) := by
  simpa only [add_zero,improvedGridEntropy] using (robustParameterCount_width_growth d r hM).mul
    (improvedGridLogFactor_width_growth d r hM hB hR hBp hRp)

theorem improvedGridEntropy_six_thirteen (d r:ℕ) {M B R:ℕ→ℕ} {u v a b:ℕ}
    (hM:WidthGrowth (fun C=>(M C:ℝ)) 3 6)
    (hB:WidthGrowth (fun C=>(B C:ℝ)) u v)
    (hR:WidthGrowth (fun C=>(R C:ℝ)) a b)
    (hBp:∀C,1≤C→0<B C) (hRp:∀C,1≤C→0<R C):
    (fun C=>improvedGridEntropy d (M C) r (B C) (R C)) =O[atTop]
      (fun C=>(C:ℝ)^6*Real.log ((C:ℝ)+2)^13) := by
  exact (improvedGridEntropy_width_growth d r hM hB hR hBp hRp).isBigO

end NeuralGeneralization.ConcreteModel
