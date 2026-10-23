import NeuralGeneralization.BatchTwoImprovedLocalCost
import NeuralGeneralization.BatchTwoImprovedLayerComparisonActual

/-! Width-independent numerical layer disturbance for the sharp compressor. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustStatistics RobustCompressionInduction
open BatchTwoImprovedSelectedBank

def sharpLayerError (K δ BH BG : ℝ) (q m : ℕ) : ℝ :=
  4*(4*(8*K+2*q)/BH^2+2*δ^3+(2*(8*K+2*q)+16*((q:ℝ)+1))/m+128*(m:ℝ)/BG^2)

theorem sharpLayerError_nonneg {K δ : ℝ} (hK : 0≤K) (hδ : 0≤δ) (BH BG : ℝ) (q m : ℕ) :
    0≤sharpLayerError K δ BH BG q m := by unfold sharpLayerError; positivity

theorem normalized_sharp_cost {N q m : ℕ} (hN : 0<N)
    {K t δ BH BG : ℝ} (hK : 0≤K) (ht : 0<t) (hδ : 0≤δ) :
    ENNReal.ofReal ((N:ℝ)⁻¹)*(4*(ENNReal.ofReal (4/BH^2)*ENNReal.ofReal (N*(8*K+2*q))+
      ENNReal.ofReal (2*t^2)*ENNReal.ofReal (N*δ^3/t^2)+
      (ENNReal.ofReal (2/(m:ℝ))*ENNReal.ofReal (N*(8*K+2*q))+
      ENNReal.ofReal (16*(N:ℝ)*((q:ℝ)+1)/m))+ENNReal.ofReal (128*(N:ℝ)*m/BG^2))) =
        ENNReal.ofReal (sharpLayerError K δ BH BG q m) := by
  have hv : 0≤8*K+2*q := by positivity
  have hs : (4*(ENNReal.ofReal (4/BH^2)*ENNReal.ofReal (N*(8*K+2*q))+
      ENNReal.ofReal (2*t^2)*ENNReal.ofReal (N*δ^3/t^2)+
      (ENNReal.ofReal (2/(m:ℝ))*ENNReal.ofReal (N*(8*K+2*q))+
      ENNReal.ofReal (16*(N:ℝ)*((q:ℝ)+1)/m))+ENNReal.ofReal (128*(N:ℝ)*m/BG^2))) =
      ENNReal.ofReal (4*((4/BH^2)*(N*(8*K+2*q))+(2*t^2)*(N*δ^3/t^2)+
      ((2/(m:ℝ))*(N*(8*K+2*q))+16*(N:ℝ)*((q:ℝ)+1)/m)+128*(N:ℝ)*m/BG^2)) := by
    simp (disch := positivity) only [ENNReal.ofReal_add,ENNReal.ofReal_mul]
    norm_num
  rw [hs,←ENNReal.ofReal_mul (by positivity)]
  congr 1
  have hn : (N:ℝ)≠0 := by positivity
  have ht0 : t≠0 := ht.ne'
  unfold sharpLayerError
  field_simp
  <;> ring

variable {d N m q s k : ℕ} [NeZero N]
  [hFin : MeasurableSpace (Finset (Fin (Fintype.card (Cube d))))]
  [hFinS : MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube d))))]
  [hMsg : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [hMsgS : MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube d))) q)]

theorem sharpComparison_cost (hq : 0<q) (hm : 0<m)
    {K t BH BG δ η : ℝ} (hK : 0≤K) (ht : 0<t) (ht1 : t≤1)
    (hBH : 0<BH) (hBG : 0<BG) (hδ : 0≤δ)
    (Γ : CanonicalStateLaw d N m s (k+1))
    (S : ActualPrefixSelection Γ Real.tanh tanh_lipschitzWith.continuous q t δ η)
    (hentropy : futureEntropy Γ.law (futurePrior N (k+1))≤ENNReal.ofReal (2*N*K/t^2))
    (x : Cube d) :
    (∫⁻ z,liveLocalCost (t/Real.sqrt (N:ℝ)) Real.tanh x z
      ∂(sharpComparison tanh_lipschitzWith.continuous hq t BH BG δ η Γ S x).joint) ≤
        ENNReal.ofReal (sharpLayerError K δ BH BG q m) := by
  have hc := sharpLayerJoint_liveLocalCost_le hq hm Γ.law S.queries S.measurable_queries
    hK ht ht1 hBH hBG hentropy ((Fintype.equivFin (Cube d)) x) _
    (S.residual_bound ((Fintype.equivFin (Cube d)) x))
  rw [normalized_sharp_cost (Nat.pos_of_neZero N) hK ht hδ] at hc
  simpa only [sharpComparison,Equiv.symm_apply_apply] using hc
end NeuralGeneralization.BatchTwoImprovedInduction
