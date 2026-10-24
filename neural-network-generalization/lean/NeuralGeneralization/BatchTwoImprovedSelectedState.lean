import NeuralGeneralization.BatchTwoImprovedSelectedBank
import NeuralGeneralization.RobustCompressionSelectedStateDraw

/-! The common sharp next-state decoder, with no test input in its type. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped Classical
namespace NeuralGeneralization.BatchTwoImprovedSelectedBank
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompressionCanonicalLayer BatchTwoImprovedCanonicalLayer
open BatchTwoImprovedWeightedSampling RobustCompressionLayerGaussian
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

def sharpSelectedStateFromH (b : P → Fin M → E) (J : P × Y → Finset (Fin M))
    (t BH BG : ℝ) (θ : P × Y) (z : HRows × (S × R)) : ActivePrefix d N m (s+1) :=
  stepActive θ.1 (z.2.1,sharpSourceRowsDraw t BH BG ((selectedSources b J θ,z.1),z.2.1) z.2.2)
    (sharpCanonicalSuccess b (selectedCanonicalInput (q:=q) J θ 0) (z.2.1,0))

theorem measurable_sharpSelectedStateFromH
    (b : P → Fin M → E) (hb : Measurable b)
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J) (t BH BG : ℝ) :
    Measurable (fun p : (P × Y) × (HRows × (S × R)) =>
      sharpSelectedStateFromH b J t BH BG p.1 p.2) := by
  have hs := (measurable_selectedSources (q:=q) b hb J hJ).comp
    (measurable_fst : Measurable (Prod.fst : (P × Y) × (HRows × (S × R)) → P × Y))
  have hi : Measurable (fun p : (P × Y) × (HRows × (S × R)) =>
      (((selectedSources b J p.1,p.2.1),p.2.2.1),p.2.2.2)) :=
    ((hs.prodMk (by fun_prop)).prodMk (by fun_prop)).prodMk (by fun_prop)
  have hr := (measurable_sharpSourceRowsDraw t BH BG).comp hi
  have hz : Measurable (fun p : (P × Y) × (HRows × (S × R)) =>
      (selectedCanonicalInput (q:=q) J p.1 0,(p.2.2.1,(0:R)))) := by
    have hm : Measurable (fun p : (P × Y) × (HRows × (S × R)) => (p.1,(0:Rows))) := by fun_prop
    exact ((measurable_selectedCanonicalInput J hJ).comp hm).prodMk (by fun_prop)
  have hI : Measurable (fun p : (P × Y) × (HRows × (S × R)) => p.2.2.1) := by fun_prop
  exact measurable_stepActive _ _ _ (by fun_prop) (hI.prodMk hr)
    ((measurable_sharpCanonicalSuccess b hb).comp hz)

def sharpSelectedSourceMatrix (b : P → Fin M → E) (J : P × Y → Finset (Fin M))
    (p : (P × Y) × S) : Fin m → Fin q → ℝ :=
  sharpSourceMatrix ((selectedSources b J p.1,(0:HRows)),p.2)

theorem measurable_sharpSelectedSourceMatrix (b : P → Fin M → E) (hb : Measurable b)
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J) :
    Measurable (sharpSelectedSourceMatrix (m:=m) (q:=q) b J) := by
  exact measurable_sharpSourceMatrix.comp
    ((((measurable_selectedSources b hb J hJ).comp measurable_fst).prodMk measurable_const).prodMk
      measurable_snd)

def sharpSelectedResidualKernel (b : P → Fin M → E) (hb : Measurable b)
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J) : Kernel ((P × Y) × S) R :=
  residualRowsKernel (sharpSelectedSourceMatrix (m:=m) (q:=q) b J)
    (measurable_sharpSelectedSourceMatrix b hb J hJ)

instance sharpSelectedResidualKernel_markov (b : P → Fin M → E) (hb : Measurable b)
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J) :
    IsMarkovKernel (sharpSelectedResidualKernel (m:=m) (q:=q) b hb J hJ) := by
  unfold sharpSelectedResidualKernel
  infer_instance

theorem sharpSelectedResidualKernel_apply (b : P → Fin M → E) (hb : Measurable b)
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J) (p : (P × Y) × S) :
    sharpSelectedResidualKernel (q:=q) b hb J hJ p =
      Measure.pi (fun _ : Fin N => sourceResidualKernel (sharpSelectedSourceMatrix (q:=q) b J p)) :=
  residualRowsKernel_apply _ _ p

/-- The actual canonical next-prefix law factors through a common active-bank
observation and a residual coefficient law independent of the test query. -/
theorem sharpCanonicalLayerKernel_selected_factor (hN : 0 < N) (hq : 0 < q)
    (b : P → Fin M → E) (hb : Measurable b)
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J)
    (t BH BG : ℝ) (θ : P × Y) (g : Rows) :
    sharpCanonicalLayerKernel hN hq b hb t BH BG (selectedCanonicalInput (q:=q) J θ g) =
      ((sourceIndicesKernel hN hq m (selectedSources b J θ)) ⊗ₘ
        (sharpSelectedResidualKernel (q:=q) b hb J hJ).comap
          (fun I:S => (θ,I)) measurable_prodMk_left).map
        (fun z => sharpSelectedStateFromH b J t BH BG θ
          (actualActiveH (selectedMessageBasis (q:=q) b J θ) t g,z)) := by
  let z := selectedCanonicalInput (q:=q) J θ g
  let state : S × R → ActivePrefix d N m (s+1) :=
    fun draw => stepActive z.1.1 draw (sharpCanonicalSuccess b z draw)
  have hstate : Measurable state := by
    apply measurable_stepActive _ _ _ measurable_const measurable_id
    exact (measurable_sharpCanonicalSuccess b hb).comp (measurable_const.prodMk measurable_id)
  have hdecode : Measurable (fun draw:S × R =>
      sharpSelectedStateFromH b J t BH BG θ
        (actualActiveH (selectedMessageBasis (q:=q) b J θ) t g,draw)) :=
    (measurable_sharpSelectedStateFromH b hb J hJ t BH BG).comp
      (measurable_const.prodMk (measurable_const.prodMk measurable_id))
  rw [sharpCanonicalLayerKernel,RobustCompression.parameterMap_apply,
    sharpCanonicalDrawKernel,Kernel.comap_apply]
  change (sharpReconstructionKernel hN hq t BH BG (sharpCanonicalInput b t z)).map state = _
  rw [sharpReconstructionKernel_factor]
  ext T hT
  rw [Measure.map_apply hstate hT,Measure.compProd_apply (hstate hT),
    Measure.map_apply hdecode hT,Measure.compProd_apply (hdecode hT)]
  apply lintegral_congr
  intro I
  rw [Kernel.comap_apply,sharpSourceRowKernel_apply,
    Kernel.comap_apply,sharpSelectedResidualKernel_apply]
  have hrows : Measurable (sharpSourceRowsDraw t BH BG (sharpCanonicalInput b t z,I)) := by
    have hc := (measurable_sharpSourceRowsDraw (N:=N) (m:=m) (q:=q) t BH BG).comp
      (show Measurable (fun ξ:R => ((sharpCanonicalInput b t z,I),ξ)) from
        measurable_const.prodMk measurable_id)
    simpa only [Function.comp_def] using hc
  rw [Measure.map_apply hrows ((hstate hT).preimage measurable_prodMk_left)]
  congr 1

end NeuralGeneralization.BatchTwoImprovedSelectedBank
