import PhysicalNormalizedSeparation

noncomputable section
set_option maxHeartbeats 1200000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort
namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

def representativeClassifier (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (Y : Finset (Cube d)) : ThresholdCircuit d := by
  classical
  exact representativeClassifierAfter
    (M.precisePrefix T hT (longEvaluationPrecision P) (longEvaluationPrecision_pos P))
    M.endpointProjection (fun y:Y=>M.normalizedEndpoint y) (fun y:Y=>f y)
    (1+‖P.readout‖*physicalGainProduct P H)

lemma representativeClassifier_depth (M : GainPrefixDynamics P S states J)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (Y : Finset (Cube d)) :
    (M.representativeClassifier T hT Y).depth≤
      90*longEvaluationIterations M.nonlinearBudget (longEvaluationPrecision P)+27 := by
  classical
  have hh:=representativeClassifierAfter_depth
    (M.precisePrefix T hT (longEvaluationPrecision P) (longEvaluationPrecision_pos P))
    M.endpointProjection (fun y:Y=>M.normalizedEndpoint y) (fun y:Y=>f y)
    (1+‖P.readout‖*physicalGainProduct P H)
  have hp:=M.precisePrefix_depth T hT (longEvaluationPrecision P) (longEvaluationPrecision_pos P)
  exact hh.trans (by omega)

/-- Actual representative-distance classification after the actual parallel
normalized-prefix evaluator. The only geometric input is an indexed cover
of the actual canonical states; labels are supplied by its representatives. -/
theorem representativeClassifier_correct (M : GainPrefixDynamics P S states J) (hd : 1≤d)
    (hinit : ∀x,‖(states 0).feature x‖≤2)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J) (hT : ‖T‖≤1)
    (hTx : ∀x,T (normalizedInputFeature d x)=M.state x 0)
    (c : EuclideanSpace ℝ (states H).Index) (hc : ‖c‖≤‖P.readout‖)
    (herr : ∀x,|inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x)|≤(1:ℝ)/8)
    (Y : Finset (Cube d))
    (hcover : ∀x,∃y∈Y,dist (M.normalizedEndpoint x) (M.normalizedEndpoint y)≤
      1/(64*(1+‖P.readout‖*physicalGainProduct P H))) :
    (M.representativeClassifier T hT Y).eval=f := by
  classical
  let A:=1+‖P.readout‖*physicalGainProduct P H
  have hA : 1≤A := by
    have hh:=mul_nonneg (norm_nonneg P.readout) (physicalGainProduct_pos P H).le
    dsimp [A]
    linarith
  have hAp : 0<A := by linarith
  have hsep (x y:Cube d) (hx:f x=false) (hy:f y=true) :
      3/(4*A)≤‖M.normalizedEndpoint x-M.normalizedEndpoint y‖ :=
    normalizedCanonicalFeature_opposite M.model J M.length_le c hc herr x y hx hy
  have hgap : 1/(64*A)<3/(4*A) := by
    apply (div_lt_div_iff₀ (by positivity : 0<64*A) (by positivity : 0<4*A)).mpr
    nlinarith
  apply representativeClassifierAfter_correct
    (M.precisePrefix T hT (longEvaluationPrecision P) (longEvaluationPrecision_pos P))
    M.endpointProjection (fun y:Y=>M.normalizedEndpoint y) (fun y:Y=>f y) A hA
    M.normalizedEndpoint f (M.normalizedEndpoint_norm hinit) (fun y=>M.normalizedEndpoint_norm hinit y)
  · intro x
    obtain ⟨a,ha,he⟩:=M.precisePrefix_eval hd hinit T hT hTx
      (longEvaluationPrecision P) (longEvaluationPrecision_pos P) x
    refine ⟨a,ha,he.trans ?_⟩
    change (1/(256*A))/32≤1/(256*A)
    have hp : 0≤1/(256*A) := by positivity
    linarith
  · intro x hx
    obtain ⟨y,hy,hxy⟩:=hcover x
    have hlabel:f y=true := by
      by_contra hn
      have hyf:f y=false:=Bool.eq_false_iff.mpr hn
      have hh:=hsep y x hyf hx
      rw [norm_sub_rev] at hh
      rw [dist_eq_norm] at hxy
      exact (not_le_of_gt hgap) (hh.trans hxy)
    exact ⟨⟨y,hy⟩,hlabel,by simpa only [dist_eq_norm] using hxy⟩
  · intro x hx y hy
    exact hsep x y hx hy

#print axioms representativeClassifier_correct
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
