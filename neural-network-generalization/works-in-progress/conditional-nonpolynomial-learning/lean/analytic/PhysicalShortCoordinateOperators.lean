import ReindexedCanonicalProgram
import PhysicalShortDimensionResources
import MatrixCoordinates

noncomputable section
set_option maxHeartbeats 200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel
open ConditionalNonpolynomial.AnalyticLookup

noncomputable def coordinateIso (I : Type*) [Fintype I] :
    EuclideanSpace ℝ (Fin (Fintype.card I)) ≃ₗᵢ[ℝ] EuclideanSpace ℝ I :=
  reindexedVector (Fintype.equivFin I).symm

noncomputable def coordinatePairIso (I J : Type*) [Fintype I] [Fintype J] :
    EuclideanSpace ℝ (Fin (Fintype.card I+Fintype.card J)) ≃ₗᵢ[ℝ]
      WithLp 2 (EuclideanSpace ℝ I × EuclideanSpace ℝ J) :=
  ((reindexedVector finSumFinEquiv.symm).trans
    (PiLp.sumPiLpEquivProdLpPiLp 2 (fun _:Fin (Fintype.card I)⊕Fin (Fintype.card J)=>ℝ))).trans
      (LinearIsometryEquiv.withLpProdCongr 2 (coordinateIso I) (coordinateIso J))

lemma coordinatePairIso_encode {I J : Type*} [Fintype I] [Fintype J]
    (u : EuclideanSpace ℝ I) (v : EuclideanSpace ℝ J) :
    coordinatePairIso I J (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>u i))
      (realCoordinates (fun j=>v j))))=WithLp.toLp 2 (u,v) := by
  apply WithLp.ofLp_injective 2
  apply Prod.ext
  · ext i
    change (Fin.addCases (motive:=fun _=>ℝ) (realCoordinates (fun i=>u i)) (realCoordinates (fun j=>v j)))
      (Fin.castAdd (Fintype.card J) ((Fintype.equivFin I) i))=u i
    simp [realCoordinates]
  · ext j
    change (Fin.addCases (motive:=fun _=>ℝ) (realCoordinates (fun i=>u i)) (realCoordinates (fun j=>v j)))
      (Fin.natAdd (Fintype.card I) ((Fintype.equivFin J) j))=v j
    simp [realCoordinates]

abbrev canonicalAmbientDimension {d : ℕ} (states : ℕ → CanonicalProgramState d) (H : ℕ) :=
  Fintype.card (Σj:Fin (H+1),(states j).Index)

def canonicalAmbientIso {d : ℕ} (states : ℕ → CanonicalProgramState d) (H : ℕ) :
    EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H)) ≃ₗᵢ[ℝ] CanonicalAmbient states H :=
  (coordinateIso (Σj:Fin (H+1),(states j).Index)).trans
    (LinearIsometryEquiv.piLpCurry ℝ 2 (fun (j:Fin (H+1)) (_:(states j).Index)=>ℝ))

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

abbrev layerInputDimension (_M : FiniteCanonicalDynamics P S states) (j : Fin H) :=
  Fintype.card (states j).Index
abbrev layerCanonicalIndex (M : FiniteCanonicalDynamics P S states) (j : Fin H) :=
  CanonicalIndex (M.layer j).law (M.layer j).finiteKL (fun s:S=>t • (states j).feature s)

def residualPre (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H)) →L[ℝ]
      EuclideanSpace ℝ (Fin (M.layerInputDimension j)) :=
  (coordinateIso (states j).Index).symm.toContinuousLinearMap.comp
    (((t*normalizingScale M.linearGain j) •
      blockProjection (fun k:Fin (H+1)=>EuclideanSpace ℝ (states k).Index) j.castSucc).comp
        (canonicalAmbientIso states H).toContinuousLinearMap)

def residualPostCore (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    WithLp 2 (EuclideanSpace ℝ (Fin (M.layerInputDimension j)) ×
      EuclideanSpace ℝ (M.layerCanonicalIndex j)) →ₗ[ℝ]
      EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H)) where
  toFun z := (canonicalAmbientIso states H).symm
    ((normalizingScale M.linearGain (j+1))⁻¹ •
      blockEmbedding (fun k:Fin (H+1)=>EuclideanSpace ℝ (states k).Index) j.succ
        ((M.layer j).output z.snd-(M.layer j).linear (coordinateIso (states j).Index z.fst)))
  map_add' z w := by
    simp only [WithLp.fst,WithLp.snd,WithLp.ofLp_add,Prod.fst_add,Prod.snd_add,
      map_add,map_sub,smul_add,smul_sub]
    abel
  map_smul' c z := by
    simp only [WithLp.fst,WithLp.snd,WithLp.ofLp_smul,Prod.smul_fst,Prod.smul_snd,
      map_smul,map_sub,smul_sub,smul_smul,RingHom.id_apply,mul_comm]

lemma residualPre_norm (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    ‖M.residualPre j‖≤normalizingScale M.linearGain j := by
  have hs : 0≤normalizingScale M.linearGain j := by
    linarith [normalizingScale_one_le M.linearGain M.linearGain_one_le j]
  apply ContinuousLinearMap.opNorm_le_bound _ hs
  intro x
  change ‖(coordinateIso (states j).Index).symm
    ((t*normalizingScale M.linearGain j) •blockProjection _ j.castSucc (canonicalAmbientIso states H x))‖≤_
  rw [LinearIsometryEquiv.norm_map,norm_smul,Real.norm_eq_abs,abs_of_nonneg (mul_nonneg P.scale_positive.le hs)]
  have hp := (blockProjection_norm
    (fun k:Fin (H+1)=>EuclideanSpace ℝ (states k).Index) j.castSucc (canonicalAmbientIso states H x)).trans_eq
      ((canonicalAmbientIso states H).norm_map x)
  exact mul_le_mul (mul_le_of_le_one_left hs P.scale_le_one) hp (norm_nonneg _) hs

lemma residualPostCore_bound (M : FiniteCanonicalDynamics P S states) (j : Fin H)
    (z : WithLp 2 (EuclideanSpace ℝ (Fin (M.layerInputDimension j)) ×
      EuclideanSpace ℝ (M.layerCanonicalIndex j))) :
    ‖M.residualPostCore j z‖≤(1+M.linearGain j)*‖z‖ := by
  have hs : 0≤(normalizingScale M.linearGain (j+1))⁻¹ := inv_nonneg.mpr
    (by linarith [normalizingScale_one_le M.linearGain M.linearGain_one_le (j+1)])
  have hs1 : (normalizingScale M.linearGain (j+1))⁻¹≤1 :=
    inv_le_one_of_one_le₀ (normalizingScale_one_le M.linearGain M.linearGain_one_le (j+1))
  change ‖(canonicalAmbientIso states H).symm _‖≤_
  rw [LinearIsometryEquiv.norm_map,norm_smul,Real.norm_eq_abs,abs_of_nonneg hs,
    LinearIsometry.norm_map]
  apply (mul_le_mul_of_nonneg_right hs1 (norm_nonneg _)).trans
  rw [one_mul]
  apply (norm_sub_le _ _).trans
  rw [(M.layer j).output.norm_map]
  have hf : ‖z.fst‖≤‖z‖ := WithLp.norm_fst_le _ z
  have hg : ‖z.snd‖≤‖z‖ := WithLp.norm_snd_le _ z
  have hlin := (M.layer j).linear.le_opNorm (coordinateIso (states j).Index z.fst)
  rw [LinearIsometryEquiv.norm_map] at hlin
  have hl := (M.layer j).linear_norm_le
  have hgain : M.linearGain j=1+Real.sqrt (2*physicalLayerCost P j) := if_pos j.isLt
  rw [← hgain] at hl
  have hh := mul_le_mul hl hf (norm_nonneg _) (by linarith [M.linearGain_one_le j])
  nlinarith

def residualPost (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    EuclideanSpace ℝ (Fin (Fintype.card (Fin (M.layerInputDimension j))+
      Fintype.card (M.layerCanonicalIndex j))) →L[ℝ]
      EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H)) :=
  ((M.residualPostCore j).mkContinuous (1+M.linearGain j) (M.residualPostCore_bound j)).comp
    (coordinatePairIso (Fin (M.layerInputDimension j)) (M.layerCanonicalIndex j)).toContinuousLinearMap

lemma residualPost_norm (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    ‖M.residualPost j‖≤1+M.linearGain j := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by linarith [M.linearGain_one_le j])
  intro x
  exact (M.residualPostCore_bound j _).trans_eq
    (by congr 1; exact (coordinatePairIso (Fin (M.layerInputDimension j)) (M.layerCanonicalIndex j)).norm_map x)

def residualPreEncoded (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H)) →L[ℝ]
      EuclideanSpace ℝ (Fin (Fintype.card (Fin (M.layerInputDimension j)))) :=
  (coordinateIso (Fin (M.layerInputDimension j))).symm.toContinuousLinearMap.comp (M.residualPre j)

lemma residualPreEncoded_norm (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    ‖M.residualPreEncoded j‖≤normalizingScale M.linearGain j := by
  apply ContinuousLinearMap.opNorm_le_bound _
    (by linarith [normalizingScale_one_le M.linearGain M.linearGain_one_le j])
  intro x
  change ‖(coordinateIso (Fin (M.layerInputDimension j))).symm (M.residualPre j x)‖≤_
  rw [LinearIsometryEquiv.norm_map]
  exact ((M.residualPre j).le_opNorm x).trans
    (mul_le_mul_of_nonneg_right (M.residualPre_norm j) (norm_nonneg x))

lemma residualPreEncoded_eval (M : FiniteCanonicalDynamics P S states) (j : Fin H)
    (x : EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H))) :
    (fun i=>∑k,linearCoefficients (M.residualPreEncoded j) i k*x k)=
      realCoordinates (fun i=>M.residualPre j x i) := by
  funext i
  rw [linearCoefficients_eval]
  simp only [residualPreEncoded,ContinuousLinearMap.comp_apply,
    coordinateIso,reindexedVector,
    LinearIsometryEquiv.piLpCongrLeft_symm,Equiv.symm_symm]
  rfl

lemma residualPre_original (M : FiniteCanonicalDynamics P S states) (j : Fin H)
    (x : EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H))) :
    coordinateIso (states j).Index (M.residualPre j x)=
      (t*normalizingScale M.linearGain j) •
        blockProjection (fun k:Fin (H+1)=>EuclideanSpace ℝ (states k).Index) j.castSucc
          (canonicalAmbientIso states H x) := by
  change coordinateIso (states j).Index ((coordinateIso (states j).Index).symm _)=_
  exact LinearIsometryEquiv.apply_symm_apply _ _

lemma residualPost_encode (M : FiniteCanonicalDynamics P S states) (j : Fin H)
    (u : EuclideanSpace ℝ (Fin (M.layerInputDimension j)))
    (v : EuclideanSpace ℝ (M.layerCanonicalIndex j)) :
    M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>u i))
      (realCoordinates (fun k=>v k))))=M.residualPostCore j (WithLp.toLp 2 (u,v)) := by
  change M.residualPostCore j (coordinatePairIso _ _ _)=_
  rw [coordinatePairIso_encode]

lemma residualPost_perturb (M : FiniteCanonicalDynamics P S states) (j : Fin H)
    (u : EuclideanSpace ℝ (Fin (M.layerInputDimension j)))
    (v w : EuclideanSpace ℝ (M.layerCanonicalIndex j)) :
    ‖M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>u i))
      (realCoordinates (fun k=>v k))))-
     M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>u i))
      (realCoordinates (fun k=>w k))))‖≤(1+M.linearGain j)*‖v-w‖ := by
  rw [M.residualPost_encode,M.residualPost_encode,← map_sub]
  have hid : WithLp.toLp 2 (u,v)-WithLp.toLp 2 (u,w)=WithLp.toLp 2 (0,v-w) := by
    apply WithLp.ofLp_injective 2
    simp only [WithLp.ofLp_sub,WithLp.ofLp_toLp,Prod.mk_sub_mk,sub_self]
  rw [hid]
  exact (M.residualPostCore_bound j _).trans_eq (by rw [WithLp.norm_toLp_snd])

lemma residualPost_exact (M : FiniteCanonicalDynamics P S states) (η : ℝ) (j : Fin H)
    (x : EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H))) :
    let u := radialClip (canonicalRadius P η j) (M.residualPre j x)
    let v := canonicalGaussianMap (M.layer j).law (M.layer j).finiteKL
      (fun s:S=>t • (states j).feature s) (coordinateIso (states j).Index u)
    M.residualPost j (WithLp.toLp 2 (Fin.addCases (realCoordinates (fun i=>u i))
      (realCoordinates (fun k=>v k))))=
      (canonicalAmbientIso states H).symm (M.normResidual η j (canonicalAmbientIso states H x)) := by
  dsimp only
  change M.residualPostCore j (coordinatePairIso _ _ _)=_
  rw [coordinatePairIso_encode]
  have hrad : coordinateIso (states j).Index (radialClip (canonicalRadius P η j) (M.residualPre j x))=
      radialClip (canonicalRadius P η j)
        ((t*normalizingScale M.linearGain j) •
          blockProjection (fun k:Fin (H+1)=>EuclideanSpace ℝ (states k).Index) j.castSucc
            (canonicalAmbientIso states H x)) := by
    rw [radialClip,map_smul,← (coordinateIso (states j).Index).norm_map (M.residualPre j x),
      M.residualPre_original]
    rfl
  have he := M.normResidual_formula η j (canonicalAmbientIso states H x)
  simp only [smul_smul] at he
  rw [← hrad] at he
  have hh := congrArg (canonicalAmbientIso states H).symm he.symm
  exact hh


end FiniteCanonicalDynamics
#print axioms FiniteCanonicalDynamics.residualPost_norm
#print axioms coordinatePairIso_encode
#print axioms FiniteCanonicalDynamics.residualPost_exact
end ConditionalNonpolynomial.Analytic.PhysicalShort
