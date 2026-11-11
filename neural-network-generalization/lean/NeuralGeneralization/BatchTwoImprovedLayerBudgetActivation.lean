import NeuralGeneralization.BatchTwoImprovedLayerBudget
import NeuralGeneralization.BatchTwoImprovedLocalCostActivation
import NeuralGeneralization.BatchTwoImprovedLayerComparisonActual

/-! General bounded 1-Lipschitz activation extension.
 Width-independent numerical layer disturbance for the sharp compressor. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustStatistics RobustCompressionInduction
open BatchTwoImprovedSelectedBank

variable {d N m q s k : ℕ} [NeZero N]
  [hFin : MeasurableSpace (Finset (Fin (Fintype.card (Cube d))))]
  [hFinS : MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube d))))]
  [hMsg : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [hMsgS : MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube d))) q)]

theorem sharpComparison_cost_activation {φ : ℝ → ℝ} (hφ : LipschitzWith 1 φ) (hφb : ∀ z, |φ z| ≤ 1) (hq : 0<q) (hm : 0<m)
    {K t BH BG δ η : ℝ} (hK : 0≤K) (ht : 0<t) (ht1 : t≤1)
    (hBH : 0<BH) (hBG : 0<BG) (hδ : 0≤δ)
    (Γ : CanonicalStateLaw d N m s (k+1))
    (S : ActualPrefixSelection Γ φ hφ.continuous q t δ η)
    (hentropy : futureEntropy Γ.law (futurePrior N (k+1))≤ENNReal.ofReal (2*N*K/t^2))
    (x : Cube d) :
    (∫⁻ z,liveLocalCost (t/Real.sqrt (N:ℝ)) φ x z
      ∂(sharpComparison hφ.continuous hq t BH BG δ η Γ S x).joint) ≤
        ENNReal.ofReal (sharpLayerError K δ BH BG q m) := by
  have hc := sharpLayerJoint_liveLocalCost_le_activation hφ hφb hq hm Γ.law S.queries S.measurable_queries
    hK ht ht1 hBH hBG hentropy ((Fintype.equivFin (Cube d)) x) _
    (S.residual_bound ((Fintype.equivFin (Cube d)) x))
  rw [normalized_sharp_cost (Nat.pos_of_neZero N) hK ht hδ] at hc
  simpa only [sharpComparison,Equiv.symm_apply_apply] using hc
end NeuralGeneralization.BatchTwoImprovedInduction
