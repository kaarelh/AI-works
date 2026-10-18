import NeuralGeneralization.RobustCompressionCanonicalLayerTotalization
import NeuralGeneralization.RobustEntropySelectedHObservation

/-! # Decoding the common next state from exposed H and residual coefficients -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped Classical
namespace NeuralGeneralization.RobustCompressionCanonicalLayer
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompressionReconstruction
variable {d N m s M q : ℕ} {Y : Type*} [MeasurableSpace Y]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)]
  [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "P" => ActivePrefix d N m s
local notation "E" => EuclideanSpace ℝ (Fin N)
local notation "Rows" => Fin N → E
local notation "HRows" => Fin N → EuclideanSpace ℝ (Fin q)
local notation "S" => Fin m → Fin N
local notation "R" => Fin N → Fin m → ℝ

def selectedCanonicalInput (J : P × Y → Finset (Fin M)) (θ : P × Y) (g : Rows) :
    CanonicalLayerInput d N m s q (Fin M) :=
  ((θ.1,flattenRows N g),abortQueryMessage q (J θ))

theorem measurable_selectedCanonicalInput
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J) :
    Measurable (fun p : (P × Y) × Rows => selectedCanonicalInput (q := q) J p.1 p.2) :=
  (measurable_fst.fst.prodMk ((measurable_flattenRows N).comp measurable_snd)).prodMk
    ((measurable_abortQueryMessage J hJ).comp measurable_fst)

/-- Neither the test input nor the unrevealed part of the original rows enters
this map. The success event is the same literal rank/source-bank test. -/
def selectedStateFromH (φ : ℝ → ℝ)
    (b : P → Fin M → E) (J : P × Y → Finset (Fin M))
    (a t T BH BG : ℝ) (θ : P × Y) (z : HRows × (S × R)) :
    ActivePrefix d N m (s+1) :=
  stepActive θ.1 (z.2.1,fixedSourceRowsDraw a t T BH BG
      ((sourceRows (selectedMessageBasis (q := q) b J θ),z.1),z.2.1) z.2.2)
    (canonicalLayerSuccess φ b a T (selectedCanonicalInput (q := q) J θ 0) (z.2.1,0))

theorem measurable_selectedStateFromH {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J) (a t T BH BG : ℝ) :
    Measurable (fun p : (P × Y) × (HRows × (S × R)) =>
      selectedStateFromH φ b J a t T BH BG p.1 p.2) := by
  have hs : Measurable (fun p : (P × Y) × (HRows × (S × R)) =>
      sourceRows (selectedMessageBasis (q := q) b J p.1)) :=
    measurable_sourceRows.comp ((measurable_selectedMessageBasis b hb J hJ).comp measurable_fst)
  have hi : Measurable (fun p : (P × Y) × (HRows × (S × R)) =>
      (((sourceRows (selectedMessageBasis (q := q) b J p.1),p.2.1),p.2.2.1),p.2.2.2)) :=
    ((hs.prodMk (by fun_prop)).prodMk (by fun_prop)).prodMk (by fun_prop)
  have hr := (measurable_fixedSourceRowsDraw a t T BH BG).comp hi
  have hz : Measurable (fun p : (P × Y) × (HRows × (S × R)) =>
      (selectedCanonicalInput (q := q) J p.1 0,(p.2.2.1,(0 : R)))) := by
    have hm : Measurable (fun p : (P × Y) × (HRows × (S × R)) => (p.1,(0 : Rows))) := by fun_prop
    exact ((measurable_selectedCanonicalInput J hJ).comp hm).prodMk (by fun_prop)
  have hI : Measurable (fun p : (P × Y) × (HRows × (S × R)) => p.2.2.1) := by fun_prop
  exact measurable_stepActive _ _ _ (by fun_prop) (hI.prodMk hr)
    ((measurable_canonicalLayerSuccess hφ b hb a T).comp hz)

/-- Plugging in the actual active observation gives exactly the canonical
update, retaining the same clipped coefficient rows on successful samples. -/
theorem selectedStateFromH_actual (φ : ℝ → ℝ)
    (b : P → Fin M → E) (J : P × Y → Finset (Fin M))
    (a t T BH BG : ℝ) (θ : P × Y) (g : Rows) (I : S) (ξ : R) :
    selectedStateFromH φ b J a t T BH BG θ
      (actualActiveH (selectedMessageBasis (q := q) b J θ) t g,(I,ξ)) =
    canonicalFixedStateDraw φ b a T (selectedCanonicalInput (q := q) J θ g) I
      (fixedSourceRowsDraw a t T BH BG
        (canonicalReconstructionInput b t (selectedCanonicalInput (q := q) J θ g),I) ξ) := by
  rfl

end NeuralGeneralization.RobustCompressionCanonicalLayer
