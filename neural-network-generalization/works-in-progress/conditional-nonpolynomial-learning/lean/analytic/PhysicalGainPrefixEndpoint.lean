import PhysicalGainPrefixEvaluator
import PhysicalLongPrecisionResources

noncomputable section
set_option maxHeartbeats 600000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort
namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

abbrev FullGridIndex (_M : GainPrefixDynamics P S states J) :=
  Fin (d+1)⊕(Fin (J+1)×CanonicalAmbientIndex states J)

def endpointProjection (M : GainPrefixDynamics P S states J) : (states J).Index→M.FullGridIndex :=
  fun i=>Sum.inr (Fin.last J,⟨Fin.last J,i⟩)

def normalizedEndpoint (M : GainPrefixDynamics P S states J) (x : Cube d) :
    EuclideanSpace ℝ (states J).Index := (physicalGainProduct P J)⁻¹ • (states J).feature x

lemma state_endpoint (M : GainPrefixDynamics P S states J) (x : Cube d) :
    blockProjection (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index) (Fin.last J) (M.state x J)=
      M.normalizedEndpoint x := by
  simp only [state,dif_pos le_rfl,normalizedEndpoint]
  exact blockProjection_embedding _ _ _

lemma endpoint_decode (M : GainPrefixDynamics P S states J) (Q N : ℕ)
    (a : Fin (d+1)→ScalarCode Q N)
    (u : (Fin (J+1)×CanonicalAmbientIndex states J)→ScalarCode Q N) :
    decodeCoordinates Q N (fun i=>Sum.elim a u (M.endpointProjection i))=
      blockProjection (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index) (Fin.last J)
        (M.coordinateTrajectory (decodeCoordinates Q N u) J) := by
  have hh := M.coordinateTrajectory_fin (decodeCoordinates Q N u) (Fin.last J)
  change M.coordinateTrajectory (decodeCoordinates Q N u) J=_ at hh
  rw [hh]
  ext i
  rfl

lemma endpoint_error (M : GainPrefixDynamics P S states J) (Q N : ℕ)
    (a : Fin (d+1)→ScalarCode Q N)
    (u : (Fin (J+1)×CanonicalAmbientIndex states J)→ScalarCode Q N) (x : Cube d) :
    ‖decodeCoordinates Q N (fun i=>Sum.elim a u (M.endpointProjection i))-M.normalizedEndpoint x‖≤
      ‖M.coordinateTrajectory (decodeCoordinates Q N u) J-M.state x J‖ := by
  rw [M.endpoint_decode,←M.state_endpoint x]
  simpa only [dist_eq_norm] using blockProjection_dist
    (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index) (Fin.last J)
    (M.coordinateTrajectory (decodeCoordinates Q N u) J) (M.state x J)

lemma normalizedEndpoint_norm (M : GainPrefixDynamics P S states J)
    (hinit : ∀x,‖(states 0).feature x‖≤2) (x : Cube d) : ‖M.normalizedEndpoint x‖≤2 :=
  M.normalized_feature_norm hinit x J le_rfl

theorem compiledPrefix_endpoint_eval (M : GainPrefixDynamics P S states J) (hd : 1≤d)
    (hinit : ∀x,‖(states 0).feature x‖≤2)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.state x 0)
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) (x : Cube d) :
    let G:=M.gridSystem T hT
    let Q:=G.mesh η
    let N:=G.stateRange
    ∃u:ℕ→G.InputIndex→ScalarCode Q N,
      (∀k,(M.compiledPrefix T hT η hη hη1 k).eval x=encodeCoordinateState Q N (u k)) ∧
      ∀k,‖decodeCoordinates Q N (fun i=>u k (M.endpointProjection i))-M.normalizedEndpoint x‖≤
        4*M.nonlinearBudget^k/(k.factorial:ℝ)+η*Real.exp M.nonlinearBudget := by
  intro G Q N
  obtain ⟨u,he,hh⟩ := M.compiledPrefix_eval hd hinit T hT hTx η hη hη1 x
  refine ⟨fun k=>Sum.elim (normalizedCodes d Q N x) (u k),he,?_⟩
  intro k
  exact (M.endpoint_error Q N _ _ x).trans (hh k)

def precisePrefix (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (ξ : ℝ) (hξ : 0<ξ) :=
  M.compiledPrefix T hT (longEvaluationRounding M.nonlinearBudget ξ)
    (longEvaluationRounding_pos hξ)
    ((longEvaluationRounding_small M.nonlinearBudget_nonneg hξ).trans (by norm_num))
    (longEvaluationIterations M.nonlinearBudget ξ)

lemma precisePrefix_depth (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (ξ : ℝ) (hξ : 0<ξ) :
    (M.precisePrefix T hT ξ hξ).depth≤90*longEvaluationIterations M.nonlinearBudget ξ+11 :=
  M.compiledPrefix_depth _ _ _ _ _ _

theorem precisePrefix_eval (M : GainPrefixDynamics P S states J) (hd : 1≤d)
    (hinit : ∀x,‖(states 0).feature x‖≤2)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.state x 0)
    (ξ : ℝ) (hξ : 0<ξ) (x : Cube d) :
    let G:=M.gridSystem T hT
    let Q:=G.mesh (longEvaluationRounding M.nonlinearBudget ξ)
    let N:=G.stateRange
    ∃a:G.InputIndex→ScalarCode Q N,
      (M.precisePrefix T hT ξ hξ).eval x=encodeCoordinateState Q N a ∧
      ‖decodeCoordinates Q N (fun i=>a (M.endpointProjection i))-M.normalizedEndpoint x‖≤ξ/32 := by
  intro G Q N
  obtain ⟨u,he,hh⟩:=M.compiledPrefix_endpoint_eval hd hinit T hT hTx
    (longEvaluationRounding M.nonlinearBudget ξ) (longEvaluationRounding_pos hξ)
    ((longEvaluationRounding_small M.nonlinearBudget_nonneg hξ).trans (by norm_num)) x
  refine ⟨u (longEvaluationIterations M.nonlinearBudget ξ),he _,?_⟩
  exact (hh _).trans (longEvaluation_error_budget M.nonlinearBudget_nonneg hξ)

#print axioms precisePrefix_eval
#print axioms endpoint_error
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
