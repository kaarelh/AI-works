import PhysicalShortDynamics
import PhysicalNormalizedLayer
import PhysicalGainProducts
import FeatureGramContraction
import StrictCausalPicardFinite

noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel

/-- Actual canonical dynamics restricted to a prefix and normalized by the
original physical gain products. The radius records an actual clipping ball. -/
structure GainPrefixDynamics {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (S : Finset (Cube d))
    (states : ℕ→CanonicalProgramState d) (J : ℕ) where
  model : PhysicalShort.FiniteCanonicalDynamics P S states
  length_le : J≤H
  radius : ℕ→ℝ
  radius_pos : ∀j<J,0<radius j
  radius_le : ∀j<J,radius j≤3
  contains : ∀j<J,∀x,‖(physicalGainProduct P j)⁻¹ • (states j).feature x‖≤radius j

abbrev PrefixAmbient {d : ℕ} (states : ℕ→CanonicalProgramState d) (J : ℕ) :=
  PiLp 2 (fun j:Fin (J+1)=>EuclideanSpace ℝ (states j).Index)

namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

def inputScale (_M : GainPrefixDynamics P S states J) (j : ℕ) : ℝ := t*physicalGainProduct P j

lemma inputScale_pos (M : GainPrefixDynamics P S states J) (j : ℕ) : 0<M.inputScale j :=
  mul_pos P.scale_positive (physicalGainProduct_pos P j)

lemma scale_next (M : GainPrefixDynamics P S states J) (j : ℕ) :
    physicalGainProduct P (j+1)=M.inputScale j*Real.sqrt (gaussianEntropyGain (physicalLayerCost P j)) := by
  classical
  rw [physicalGainProduct_succ,physicalLayerGain_eq]
  unfold inputScale
  ring

def linear (M : GainPrefixDynamics P S states J) (j : ℕ) :
    PrefixAmbient states J→L[ℝ]PrefixAmbient states J :=
  if hj:j<J then blockLiftLinear
    (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index)
    (i:=(⟨j,hj⟩:Fin J).castSucc) (j:=(⟨j,hj⟩:Fin J).succ)
    (M.model.layer ⟨j,lt_of_lt_of_le hj M.length_le⟩).gainLinear
  else 0

def residual (M : GainPrefixDynamics P S states J) (j : ℕ) :
    PrefixAmbient states J→PrefixAmbient states J :=
  if hj:j<J then blockLiftMap
    (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index)
    (i:=(⟨j,hj⟩:Fin J).castSucc) (j:=(⟨j,hj⟩:Fin J).succ)
    (fun u=>(M.model.layer ⟨j,lt_of_lt_of_le hj M.length_le⟩).gainResidual
      (M.inputScale j) (radialClip (M.radius j) u))
  else fun _=>0

def state (_M : GainPrefixDynamics P S states J) (x : Cube d) (j : ℕ) : PrefixAmbient states J :=
  if hj:j≤J then blockEmbedding (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index)
    ⟨j,Nat.lt_succ_of_le hj⟩ ((physicalGainProduct P j)⁻¹ • (states j).feature x)
  else 0

def nonlinearGain (M : GainPrefixDynamics P S states J) (j : ℕ) : ℝ :=
  if j<J then 224*((M.inputScale j*M.radius j)^2+Real.sqrt (physicalLayerCost P j)) else 0

def nonlinearBudget (M : GainPrefixDynamics P S states J) : ℝ :=
  ∑j∈Finset.range J,M.nonlinearGain j

lemma nonlinearGain_nonneg (M : GainPrefixDynamics P S states J) (j : ℕ) : 0≤M.nonlinearGain j := by
  classical
  unfold nonlinearGain
  split_ifs <;> positivity

lemma nonlinearBudget_nonneg (M : GainPrefixDynamics P S states J) : 0≤M.nonlinearBudget :=
  Finset.sum_nonneg fun j _=>M.nonlinearGain_nonneg j

lemma linear_contracts (M : GainPrefixDynamics P S states J) (j : ℕ) : ‖M.linear j‖≤1 := by
  classical
  unfold linear
  split_ifs with hj
  · apply (blockLiftLinear_opNorm _ _).trans
    apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
    intro u
    simpa only [one_mul] using (M.model.layer ⟨j,lt_of_lt_of_le hj M.length_le⟩).gainLinear_contraction u
  · simp

lemma residual_lipschitz (M : GainPrefixDynamics P S states J) (j : ℕ)
    (u v : PrefixAmbient states J) : ‖M.residual j u-M.residual j v‖≤M.nonlinearGain j*‖u-v‖ := by
  classical
  unfold residual nonlinearGain
  split_ifs with hj
  · simp only [blockLiftMap,←map_sub,LinearIsometry.norm_map]
    apply ((M.model.layer ⟨j,lt_of_lt_of_le hj M.length_le⟩).gainResidual_clipped
      (M.inputScale_pos j) (M.radius_pos j hj) _ _).trans
    have hp := blockProjection_norm (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index)
      (⟨j,hj⟩:Fin J).castSucc (u-v)
    rw [map_sub] at hp
    exact mul_le_mul_of_nonneg_left hp (by positivity)
  · simp

lemma residual_zero (M : GainPrefixDynamics P S states J) (j : ℕ) : M.residual j 0=0 := by
  classical
  unfold residual
  split_ifs with hj
  · apply blockLiftMap_zero
    rw [radialClip_zero,(M.model.layer ⟨j,lt_of_lt_of_le hj M.length_le⟩).gainResidual_zero]
  · rfl

lemma residual_range (M : GainPrefixDynamics P S states J) (j : ℕ)
    (u : PrefixAmbient states J) : ‖M.residual j u‖≤3*M.nonlinearGain j := by
  classical
  unfold residual nonlinearGain
  split_ifs with hj
  · rw [blockLiftMap,LinearIsometry.norm_map]
    let L := M.model.layer ⟨j,lt_of_lt_of_le hj M.length_le⟩
    have hh := L.gainResidual_ball (M.inputScale_pos j) (M.radius_pos j hj)
      (radialClip (M.radius j) (blockProjection _ (⟨j,hj⟩:Fin J).castSucc u)) 0
      (radialClip_norm_le (M.radius_pos j hj) _) (by simpa using (M.radius_pos j hj).le)
    rw [L.gainResidual_zero,sub_zero,sub_zero] at hh
    have hr := (radialClip_norm_le (M.radius_pos j hj)
      (blockProjection _ (⟨j,hj⟩:Fin J).castSucc u)).trans (M.radius_le j hj)
    dsimp only [L] at hh
    have hc : 0≤112*((M.inputScale j*M.radius j)^2+Real.sqrt (physicalLayerCost P j)) := by positivity
    have hb := mul_le_mul_of_nonneg_left hr hc
    nlinarith only [hh,hb,hc]
  · simp

lemma normalized_feature_recursion (M : GainPrefixDynamics P S states J)
    (j : ℕ) (hj : j<J) (x : Cube d) :
    (physicalGainProduct P (j+1))⁻¹ • (states (j+1)).feature x=
      (M.model.layer ⟨j,lt_of_lt_of_le hj M.length_le⟩).gainValue (M.inputScale j)
        ((physicalGainProduct P j)⁻¹ • (states j).feature x) := by
  classical
  rw [CanonicalLayerModel.gainValue,←M.scale_next,M.model.evaluate ⟨j,lt_of_lt_of_le hj M.length_le⟩ x]
  congr 2
  rw [inputScale,smul_smul]
  have hs : (t*physicalGainProduct P j)*(physicalGainProduct P j)⁻¹=t := by
    field_simp [(physicalGainProduct_pos P j).ne']
  rw [hs]

lemma recursion (M : GainPrefixDynamics P S states J) (x : Cube d) (j : ℕ) :
    M.state x (j+1)=M.linear j (M.state x j)+M.residual j (M.state x j) := by
  classical
  by_cases hj:j<J
  · have hj0 : j≤J := Nat.le_of_lt hj
    have hj1 : j+1≤J := by omega
    let L := M.model.layer ⟨j,lt_of_lt_of_le hj M.length_le⟩
    have he := L.gain_decomposition (M.inputScale_pos j).ne'
      ((physicalGainProduct P j)⁻¹ • (states j).feature x)
    rw [←M.normalized_feature_recursion j hj x] at he
    have hclip : radialClip (M.radius j) ((physicalGainProduct P j)⁻¹ • (states j).feature x)=
        (physicalGainProduct P j)⁻¹ • (states j).feature x :=
      radialClip_eq_self (M.radius_pos j hj) (M.contains j hj x)
    have hh := blockLift_recursion (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index)
      (i:=(⟨j,hj⟩:Fin J).castSucc) (j:=(⟨j,hj⟩:Fin J).succ) L.gainLinear
      (fun u=>L.gainResidual (M.inputScale j) (radialClip (M.radius j) u))
      ((physicalGainProduct P j)⁻¹ • (states j).feature x)
      ((physicalGainProduct P (j+1))⁻¹ • (states (j+1)).feature x) (by rw [hclip]; exact he)
    simpa only [state,linear,residual,dif_pos hj0,dif_pos hj1,dif_pos hj,
      Fin.castSucc_mk,Fin.succ_mk] using hh
  · have hn : ¬j+1≤J := by omega
    simp only [state,linear,residual,dif_neg hj,dif_neg hn,ContinuousLinearMap.zero_apply,add_zero]

#print axioms recursion
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
