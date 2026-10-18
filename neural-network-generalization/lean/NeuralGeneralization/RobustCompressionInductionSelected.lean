import NeuralGeneralization.RobustCompressionCanonicalLayer
import NeuralGeneralization.RobustEntropySelectedCurrent
import NeuralGeneralization.RobustCompressionInductionProgram

/-! # Actual selected finite messages and canonical transitions

The selected query set is taken from the conditional law of the current
original block given both prefix and future. Its message is a deterministic
bounded query code. Reconstruction is the literal source/Gaussian kernel and
has no future or test-input argument.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy RobustCompressionCanonicalLayer
variable {d N m s r q M : ℕ} [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)] [MeasurableSingletonClass (QueryMessage (Fin M) q)]

abbrev PrefixCurrentLaw (d N m s r : ℕ) :=
  Measure (ActivePrefix d N m s × ((Fin N → EuclideanSpace ℝ (Fin N)) × FutureWeights N r))

def prefixCurrentLaw (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) :
    PrefixCurrentLaw d N m s r := Q.map (splitRowsState N r)

instance prefixCurrentLaw_probability
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q] :
    IsProbabilityMeasure (prefixCurrentLaw Q) :=
  Measure.isProbabilityMeasure_map (measurable_splitRowsState N r).aemeasurable

structure PrefixSelection
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (q : ℕ) (t δ η : ℝ) where
  queries : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M)
  measurable_queries : Measurable queries
  rank_bound : ∀ a, klDiv ((currentRowJoint (prefixCurrentLaw Q)).condKernel a)
      (rowGaussian N N) ≠ ∞ →
    (N*δ^3/t^2)*(queries a).card ≤
      (klDiv ((currentRowJoint (prefixCurrentLaw Q)).condKernel a) (rowGaussian N N)).toReal
  abort_bound : (currentRowJoint (prefixCurrentLaw Q)).fst.real
    {a | abortQueryMessage q (queries a) = none} ≤ η
  residual_bound : ∀ i, (∫⁻ p, klDiv
    ((safeQueryKernel (currentRowJoint (prefixCurrentLaw Q)).condKernel
      (fun a => b a.1) (hb.comp measurable_fst) queries measurable_queries i).condKernel p)
    (RobustCoupling.standardGaussianVector N)
    ∂(currentRowJoint (prefixCurrentLaw Q)).fst ⊗ₘ
      (safeQueryKernel (currentRowJoint (prefixCurrentLaw Q)).condKernel
        (fun a => b a.1) (hb.comp measurable_fst) queries measurable_queries i).fst) ≤
      ENNReal.ofReal (N*δ^3/t^2)

theorem exists_prefixSelection
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    {K t δ η : ℝ} (hq : 0 < q) (hN : 0 < N) (ht : 0 < t) (hδ : 0 < δ) (hη : 0 ≤ η)
    (hentropy : futureEntropy Q (futurePrior N (r+1)) ≤ ENNReal.ofReal (2*N*K/t^2))
    (hrank : 2*K ≤ η*δ^3*q) : Nonempty (PrefixSelection Q b hb q t δ η) := by
  obtain ⟨J,hJ,hr,ha,hc⟩ := exists_actual_current_queries (prefixCurrentLaw Q)
    (futurePrior N r) b hb hq hN ht hδ hη
      ((splitRowsState_futureEntropy_le Q).trans hentropy) hrank
  exact ⟨⟨J,hJ,hr,ha,hc⟩⟩

/-- The finite message records only the selected bounded subset (or abort).
It is allowed to depend on the entire future, and not on the realized current
block beyond the conditional-law choice. -/
def selectedMessageKernel
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M)) (hJ : Measurable J) :
    Kernel ((ActivePrefix d N m s × InternalBlock N) × FutureWeights N r)
      (QueryMessage (Fin M) q) :=
  Kernel.deterministic (fun z => abortQueryMessage q (J (z.1.1,z.2)))
    ((measurable_abortQueryMessage J hJ).comp (by fun_prop))

instance selectedMessageKernel_markov
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M)) (hJ : Measurable J) :
    IsMarkovKernel (selectedMessageKernel (q:=q) J hJ) := by
  unfold selectedMessageKernel
  infer_instance

/-- The actual transition used by the program. Both component kernels have
explicit formulas, and their only abstract data is the proven query choice. -/
def selectedTransition {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (a t T BH BG : ℝ)
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M)) (hJ : Measurable J) :
    CanonicalTransition d N m (QueryMessage (Fin M) q) s r where
  message := selectedMessageKernel J hJ
  message_markov := inferInstance
  reconstruct := canonicalLayerKernel hφ b hb a t T BH BG
  reconstruct_markov := inferInstance

end NeuralGeneralization.RobustCompressionInduction
