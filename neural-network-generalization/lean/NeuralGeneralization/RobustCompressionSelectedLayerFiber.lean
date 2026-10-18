import NeuralGeneralization.RobustCompressionSelectedLayerCoupling
import NeuralGeneralization.RobustCompressionSelectedStateTotalization

/-! # The selected comparison has the literal canonical new-state marginal -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory Classical
namespace NeuralGeneralization.RobustCompressionCanonicalLayer
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompression RobustCompressionLayerComparison RobustCompressionSelectedBank
open RobustCompressionLayerGaussian CompressionSampling
variable {d N m s r M q : ℕ} [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)]
  [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "P" => ActivePrefix d N m s
local notation "E" => EuclideanSpace ℝ (Fin N)
local notation "Rows" => Fin N → E
local notation "HRows" => Fin N → EuclideanSpace ℝ (Fin q)
local notation "Base" => P × FutureWeights N r
local notation "S" => Fin m → Fin N
local notation "Residual" => Fin N → Fin m → ℝ

def selectedNextHKernel {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH BG : ℝ) (i : Fin M) : Kernel (Base × HRows) (ActivePrefix d N m (s+1)) :=
  RobustCompression.parameterMap
    ((Kernel.const (Base × HRows) (iidSamples (uniformIndexLaw N) m)) ⊗ₖ
      ((selectedBankData b hb J hJ h hh).totalizedParameters a t T BH i).coefficientKernel)
    (fun z => selectedStateFromH φ b J a t T BH BG z.1.1 (z.1.2,z.2))
    (by
      have hm : Measurable (fun z : (Base × HRows) × (S × Residual) =>
          (z.1.1,(z.1.2,z.2))) := by fun_prop
      exact (measurable_selectedStateFromH hφ b hb J hJ a t T BH BG).comp hm)

instance selectedNextHKernel_markov {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH BG : ℝ) (i : Fin M) :
    IsMarkovKernel (selectedNextHKernel (q := q) hφ b hb J hJ h hh a t T BH BG i) := by
  unfold selectedNextHKernel
  infer_instance

/-- The entire decoded kernel agrees with the literal canonical layer after
substitution of the actual active coordinates. No success event is assumed. -/
theorem selectedNextHKernel_actual
    (e : Fin M ≃ Cube d) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (heq : ∀ p i, h p i = activeHidden φ p (e i))
    (a t T BH BG : ℝ) (i : Fin M) (θ : Base) (g : Rows) :
    selectedNextHKernel (q := q) hφ b hb J hJ h hh a t T BH BG i
      (θ,actualActiveH (selectedMessageBasis (q := q) b J θ) t g) =
      canonicalLayerKernel hφ b hb a t T BH BG (selectedCanonicalInput (q := q) J θ g) := by
  let H := actualActiveH (selectedMessageBasis (q := q) b J θ) t g
  have hd : Measurable (fun z : S × Residual => selectedStateFromH φ b J a t T BH BG θ (H,z)) := by
    have hm : Measurable (fun z : S × Residual => (θ,(H,z))) := by fun_prop
    exact (measurable_selectedStateFromH hφ b hb J hJ a t T BH BG).comp hm
  rw [canonicalLayerKernel_selected_factor hφ b hb J hJ a t T BH BG θ g,
    selectedNextHKernel,RobustCompression.parameterMap_apply]
  ext v hv
  rw [Measure.map_apply hd hv,Kernel.compProd_apply (hd hv),
    Measure.map_apply hd hv,Measure.compProd_apply (hd hv)]
  apply lintegral_congr
  intro I
  have hm : Measurable (fun ξ : Residual => selectedStateFromH φ b J a t T BH BG θ (H,(I,ξ))) := by
    have hz : Measurable (fun ξ : Residual => (I,ξ)) := measurable_prodMk_left
    exact hd.comp hz
  have he := congrArg (fun μ : Measure (ActivePrefix d N m (s+1)) => μ v)
    (selectedBank_totalized_state_map e φ b hb J hJ h hh heq a t T BH BG i θ H I)
  rw [Measure.map_apply hm hv,Measure.map_apply hm hv] at he
  exact he

end NeuralGeneralization.RobustCompressionCanonicalLayer
