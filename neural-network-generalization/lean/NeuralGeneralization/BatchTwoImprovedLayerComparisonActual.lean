import NeuralGeneralization.BatchTwoImprovedLayerAlignment
import NeuralGeneralization.BatchTwoImprovedSelectedRun
import NeuralGeneralization.RobustCompressionSelectedPathCost

/-! A concrete probability coupling for each step of the sharp selected run. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustStatistics RobustCompressionInduction
open RobustCompressionSelectedBank BatchTwoImprovedSelectedBank
variable {d N m q s k : ℕ} [NeZero N]
  [hFin : MeasurableSpace (Finset (Fin (Fintype.card (Cube d))))]
  [hFinS : MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube d))))]
  [hMsg : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [hMsgS : MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube d))) q)]

def sharpComparison {φ : ℝ → ℝ} (hφ : Continuous φ) (hq : 0<q) (t BH BG δ η : ℝ)
    (Γ : CanonicalStateLaw d N m s (k+1))
    (S : ActualPrefixSelection Γ φ hφ q t δ η) (x : Cube d) :
    ProbabilityCoupling Γ.law (sharpSelectedNext hφ hq t BH BG δ η Γ S).law := by
  let b := indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ
  let hb := measurable_indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) hφ
  let h := indexedPrefixHidden (d:=d) (N:=N) (m:=m) (s:=s) φ
  let hh := measurable_indexedPrefixHidden (d:=d) (N:=N) (m:=m) (s:=s) hφ
  let i := (Fintype.equivFin (Cube d)) x
  refine ⟨sharpLayerJoint hq Γ.law b hb S.queries S.measurable_queries h hh t BH BG i,?_,?_,?_⟩
  · exact sharpLayerJoint_probability hq Γ.law b hb S.queries S.measurable_queries h hh t BH BG i
  · exact sharpLayerJoint_left hq Γ.law b hb S.queries S.measurable_queries h hh t BH BG i
  · exact sharpLayerJoint_right hq Γ.law b hb S.queries S.measurable_queries h hh t BH BG i

theorem sharpComparison_future {φ : ℝ → ℝ} (hφ : Continuous φ) (hq : 0<q) (t BH BG δ η : ℝ)
    (Γ : CanonicalStateLaw d N m s (k+1))
    (S : ActualPrefixSelection Γ φ hφ q t δ η) (x : Cube d) :
    ∀ᵐ z ∂(sharpComparison hφ hq t BH BG δ η Γ S x).joint,
      z.2.2=(splitFuture N k z.1.2).2 := by
  have he := sharpLayerJoint_future hq Γ.law (indexedPrefixQueries φ) (measurable_indexedPrefixQueries hφ)
    S.queries S.measurable_queries (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ)
    t BH BG ((Fintype.equivFin (Cube d)) x)
  exact he.mono fun _ hz => hz.symm

theorem sharpComparison_alive {φ : ℝ → ℝ} (hφ : Continuous φ) (hq : 0<q) (t BH BG δ η : ℝ)
    (Γ : CanonicalStateLaw d N m s (k+1))
    (S : ActualPrefixSelection Γ φ hφ q t δ η) (x : Cube d) :
    ∀ᵐ z ∂(sharpComparison hφ hq t BH BG δ η Γ S x).joint,
      z.2.1.1=true → z.1.1.1=true := by
  exact sharpLayerJoint_alive_imp hq Γ.law (indexedPrefixQueries φ) (measurable_indexedPrefixQueries hφ)
    S.queries S.measurable_queries (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ)
    t BH BG ((Fintype.equivFin (Cube d)) x)
end NeuralGeneralization.BatchTwoImprovedInduction
