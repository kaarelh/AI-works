import NeuralGeneralization.BatchTwoImprovedLocalCost
import NeuralGeneralization.BatchTwoImprovedLayerComparisonActual

/-! Width-independent numerical layer disturbance for the sharp compressor. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustStatistics RobustCompressionInduction
open BatchTwoImprovedSelectedBank

def manuscriptLayerError (K δ BH BG : ℝ) (q m : ℕ) : ℝ :=
  4*(4*(8*K+2*q)/BH^2+2*δ^3+(2*(8*K+2*q)+16*((q:ℝ)+1))/m+6*(m:ℝ)*Real.exp (-(BG^2)/4))

theorem sharpLayerError_nonneg_exp {K δ : ℝ} (hK : 0≤K) (hδ : 0≤δ) (BH BG : ℝ) (q m : ℕ) :
    0≤manuscriptLayerError K δ BH BG q m := by unfold manuscriptLayerError; positivity

theorem normalized_sharp_cost_exp {N q m : ℕ} (hN : 0<N)
    {K t δ BH BG : ℝ} (hK : 0≤K) (ht : 0<t) (hδ : 0≤δ) :
    ENNReal.ofReal ((N:ℝ)⁻¹)*(4*(ENNReal.ofReal (4/BH^2)*ENNReal.ofReal (N*(8*K+2*q))+
      ENNReal.ofReal (2*t^2)*ENNReal.ofReal (N*δ^3/t^2)+
      (ENNReal.ofReal (2/(m:ℝ))*ENNReal.ofReal (N*(8*K+2*q))+
      ENNReal.ofReal (16*(N:ℝ)*((q:ℝ)+1)/m))+ENNReal.ofReal (6*(N:ℝ)*m*Real.exp (-(BG^2)/4)))) =
        ENNReal.ofReal (manuscriptLayerError K δ BH BG q m) := by
  have hv : 0≤8*K+2*q := by positivity
  have hs : (4*(ENNReal.ofReal (4/BH^2)*ENNReal.ofReal (N*(8*K+2*q))+
      ENNReal.ofReal (2*t^2)*ENNReal.ofReal (N*δ^3/t^2)+
      (ENNReal.ofReal (2/(m:ℝ))*ENNReal.ofReal (N*(8*K+2*q))+
      ENNReal.ofReal (16*(N:ℝ)*((q:ℝ)+1)/m))+ENNReal.ofReal (6*(N:ℝ)*m*Real.exp (-(BG^2)/4)))) =
      ENNReal.ofReal (4*((4/BH^2)*(N*(8*K+2*q))+(2*t^2)*(N*δ^3/t^2)+
      ((2/(m:ℝ))*(N*(8*K+2*q))+16*(N:ℝ)*((q:ℝ)+1)/m)+6*(N:ℝ)*m*Real.exp (-(BG^2)/4))) := by
    simp (disch := positivity) only [ENNReal.ofReal_add,ENNReal.ofReal_mul]
    norm_num
  rw [hs,←ENNReal.ofReal_mul (by positivity)]
  congr 1
  have hn : (N:ℝ)≠0 := by positivity
  have ht0 : t≠0 := ht.ne'
  unfold manuscriptLayerError
  field_simp
  <;> ring

end NeuralGeneralization.BatchTwoImprovedInduction
