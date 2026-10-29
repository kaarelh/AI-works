import PhysicalGainPrefixPicard
import PhysicalShortCoordinateOperators
import GainNormalizedCanonicalModel

noncomputable section
set_option maxHeartbeats 2400000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort
namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

abbrev layer (M : GainPrefixDynamics P S states J) (j : Fin J) :=
  M.model.layer ⟨j,lt_of_lt_of_le j.isLt M.length_le⟩
abbrev layerInputDimension (_M : GainPrefixDynamics P S states J) (j : Fin J) := Fintype.card (states j).Index
abbrev layerCanonicalIndex (M : GainPrefixDynamics P S states J) (j : Fin J) :=
  CanonicalIndex (M.layer j).law (M.layer j).finiteKL (fun s:S=>t • (states j).feature s)
abbrev layerSpan (M : GainPrefixDynamics P S states J) (j : Fin J) :=
  actualCanonicalSpan (M.layer j).law (M.layer j).finiteKL (fun s:S=>t • (states j).feature s)
abbrev layerRank (M : GainPrefixDynamics P S states J) (j : Fin J) := Module.finrank ℝ (M.layerSpan j)

def residualPre (M : GainPrefixDynamics P S states J) (j : Fin J) :
    EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J))→L[ℝ]
      EuclideanSpace ℝ (Fin (M.layerInputDimension j)) :=
  (coordinateIso (states j).Index).symm.toContinuousLinearMap.comp
    ((blockProjection (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index) j.castSucc).comp
      (canonicalAmbientIso states J).toContinuousLinearMap)

lemma residualPre_norm (M : GainPrefixDynamics P S states J) (j : Fin J) : ‖M.residualPre j‖≤1 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro x
  change ‖(coordinateIso (states j).Index).symm
    (blockProjection _ j.castSucc (canonicalAmbientIso states J x))‖≤1*‖x‖
  rw [LinearIsometryEquiv.norm_map,one_mul]
  exact (blockProjection_norm _ _ _).trans_eq ((canonicalAmbientIso states J).norm_map x)

def residualPostCore (M : GainPrefixDynamics P S states J) (j : Fin J) :
    WithLp 2 (EuclideanSpace ℝ (Fin (M.layerInputDimension j))×
      EuclideanSpace ℝ (M.layerCanonicalIndex j))→ₗ[ℝ]
      EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J)) where
  toFun z := (canonicalAmbientIso states J).symm
    (blockEmbedding (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index) j.succ
      ((M.layer j).output z.snd-(M.layer j).gainLinear (coordinateIso (states j).Index z.fst)))
  map_add' z w := by
    simp only [WithLp.fst,WithLp.snd,WithLp.ofLp_add,Prod.fst_add,Prod.snd_add,map_add,map_sub]
    abel
  map_smul' c z := by
    simp only [WithLp.fst,WithLp.snd,WithLp.ofLp_smul,Prod.smul_fst,Prod.smul_snd,
      map_smul,map_sub,smul_sub,RingHom.id_apply]

lemma residualPostCore_bound (M : GainPrefixDynamics P S states J) (j : Fin J)
    (z : WithLp 2 (EuclideanSpace ℝ (Fin (M.layerInputDimension j))×
      EuclideanSpace ℝ (M.layerCanonicalIndex j))) : ‖M.residualPostCore j z‖≤2*‖z‖ := by
  classical
  change ‖(canonicalAmbientIso states J).symm _‖≤_
  rw [LinearIsometryEquiv.norm_map,LinearIsometry.norm_map]
  have hh := (norm_sub_le ((M.layer j).output z.snd) ((M.layer j).gainLinear (coordinateIso (states j).Index z.fst))).trans (add_le_add (le_refl _)
    ((M.layer j).gainLinear_contraction (coordinateIso (states j).Index z.fst)))
  rw [(M.layer j).output.norm_map,LinearIsometryEquiv.norm_map] at hh
  linarith [WithLp.norm_fst_le _ z,WithLp.norm_snd_le _ z]

def residualPost (M : GainPrefixDynamics P S states J) (j : Fin J) :
    EuclideanSpace ℝ (Fin (Fintype.card (Fin (M.layerInputDimension j))+
      Fintype.card (M.layerCanonicalIndex j)))→L[ℝ]
      EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J)) :=
  ((M.residualPostCore j).mkContinuous 2 (M.residualPostCore_bound j)).comp
    (coordinatePairIso (Fin (M.layerInputDimension j)) (M.layerCanonicalIndex j)).toContinuousLinearMap

lemma residualPost_norm (M : GainPrefixDynamics P S states J) (j : Fin J) : ‖M.residualPost j‖≤2 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro x
  exact (M.residualPostCore_bound j _).trans_eq
    (by congr 1; exact (coordinatePairIso (Fin (M.layerInputDimension j)) (M.layerCanonicalIndex j)).norm_map x)

def residualPreEncoded (M : GainPrefixDynamics P S states J) (j : Fin J) :
    EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J))→L[ℝ]
      EuclideanSpace ℝ (Fin (Fintype.card (Fin (M.layerInputDimension j)))) :=
  (coordinateIso (Fin (M.layerInputDimension j))).symm.toContinuousLinearMap.comp (M.residualPre j)

lemma residualPreEncoded_norm (M : GainPrefixDynamics P S states J) (j : Fin J) :
    ‖M.residualPreEncoded j‖≤1 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro x
  change ‖(coordinateIso (Fin (M.layerInputDimension j))).symm (M.residualPre j x)‖≤_
  rw [LinearIsometryEquiv.norm_map]
  exact ((M.residualPre j).le_opNorm x).trans
    (mul_le_mul_of_nonneg_right (M.residualPre_norm j) (norm_nonneg x))

lemma residualPreEncoded_eval (M : GainPrefixDynamics P S states J) (j : Fin J)
    (x : EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J))) :
    (fun i=>∑k,linearCoefficients (M.residualPreEncoded j) i k*x k)=
      realCoordinates (fun i=>M.residualPre j x i) := by
  funext i
  rw [linearCoefficients_eval]
  simp only [residualPreEncoded,ContinuousLinearMap.comp_apply,coordinateIso,reindexedVector,
    LinearIsometryEquiv.piLpCongrLeft_symm,Equiv.symm_symm]
  rfl

lemma residualPre_original (M : GainPrefixDynamics P S states J) (j : Fin J)
    (x : EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J))) :
    coordinateIso (states j).Index (M.residualPre j x)=
      blockProjection (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index) j.castSucc
        (canonicalAmbientIso states J x) := by
  exact LinearIsometryEquiv.apply_symm_apply _ _

lemma residualPost_encode (M : GainPrefixDynamics P S states J) (j : Fin J)
    (u : EuclideanSpace ℝ (Fin (M.layerInputDimension j)))
    (v : EuclideanSpace ℝ (M.layerCanonicalIndex j)) :
    M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>u i))
      (realCoordinates (fun k=>v k))))=M.residualPostCore j (WithLp.toLp 2 (u,v)) := by
  change M.residualPostCore j (coordinatePairIso _ _ _)=_
  rw [coordinatePairIso_encode]

lemma residualPost_perturb (M : GainPrefixDynamics P S states J) (j : Fin J)
    (u : EuclideanSpace ℝ (Fin (M.layerInputDimension j)))
    (v w : EuclideanSpace ℝ (M.layerCanonicalIndex j)) :
    ‖M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>u i)) (realCoordinates (fun k=>v k))))-
     M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>u i)) (realCoordinates (fun k=>w k))))‖≤2*‖v-w‖ := by
  rw [M.residualPost_encode,M.residualPost_encode,←map_sub]
  have hid : WithLp.toLp 2 (u,v)-WithLp.toLp 2 (u,w)=WithLp.toLp 2 (0,v-w) := by
    apply WithLp.ofLp_injective 2
    simp only [WithLp.ofLp_sub,WithLp.ofLp_toLp,Prod.mk_sub_mk,sub_self]
  rw [hid]
  exact (M.residualPostCore_bound j _).trans_eq (by rw [WithLp.norm_toLp_snd])

lemma residualPost_exact (M : GainPrefixDynamics P S states J) (j : Fin J)
    (x : EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J))) :
    let u := radialClip (M.radius j) (M.residualPre j x)
    let v := (M.layer j).gainCanonical (M.inputScale j) (coordinateIso (states j).Index u)
    M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>u i))
      (realCoordinates (fun k=>v k))))=
      (canonicalAmbientIso states J).symm (M.residual j (canonicalAmbientIso states J x)) := by
  classical
  dsimp only
  rw [M.residualPost_encode]
  have hrad : coordinateIso (states j).Index (radialClip (M.radius j) (M.residualPre j x))=
      radialClip (M.radius j)
        (blockProjection (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index) j.castSucc
          (canonicalAmbientIso states J x)) := by
    rw [radialClip,map_smul,←(coordinateIso (states j).Index).norm_map (M.residualPre j x),M.residualPre_original]
    rfl
  change (canonicalAmbientIso states J).symm (blockEmbedding _ j.succ
    ((M.layer j).output ((M.layer j).gainCanonical (M.inputScale j)
      (coordinateIso (states j).Index (radialClip (M.radius j) (M.residualPre j x))))-
      (M.layer j).gainLinear (coordinateIso (states j).Index (radialClip (M.radius j) (M.residualPre j x)))))=_
  rw [←(M.layer j).gainResidual_eq_sub (M.inputScale_pos j),hrad]
  simp only [residual,dif_pos j.isLt,blockLiftMap]

#print axioms residualPost_exact
#print axioms residualPost_norm
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
