import CanonicalReadout

noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel
open NeuralGeneralization.GaussianFieldTilt

lemma ControlledMarginPath.finiteKL_one {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (j : ℕ) (hj : j<H) :
    klDiv (P.law j) (fieldLaw (fun x i => P.feature j x i))≠∞ := by
  have hc : scaledFeatureCoefficients 1 (P.feature j)=(fun x i => P.feature j x i) := by
    funext x i
    exact one_mul _
  have hh := P.finiteKL j hj
  rwa [hc] at hh

lemma ControlledMarginPath.hidden_norm_le_one {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (j : ℕ) (hj : j<H) (x : Cube d) :
    ‖P.feature (j+1) x‖≤1 := by
  letI := P.probability j hj
  apply (sq_le_sq₀ (norm_nonneg _) zero_le_one).mp
  rw [← real_inner_self_eq_norm_sq,P.recursion j hj x x]
  calc
    _ ≤ ∫ _ : Cube d → ℝ,(1:ℝ) ∂P.law j := integral_mono_of_nonneg
      (Filter.Eventually.of_forall fun z => mul_self_nonneg _)
      (integrable_const _) (Filter.Eventually.of_forall fun z => by
        have hh := (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one (z x)).le
        simpa only [pow_two] using hh)
    _ = 1^2 := by simp

/-- A genuine controlled path supplies a small anchor set, an actual canonical
Gaussian program, and a single transported readout. All cardinality, dimension,
query-error and prediction-error conclusions are proved from the original
Gaussian path, rather than assumed as approximation certificates. -/
theorem critical_canonical_readout_program {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (hH : 0<H) (δ : ℕ → ℝ)
    (hδ : ∀j<H,0<δ j) {ρ : ℝ} (hρ : 0<ρ) :
    ∃S : Finset (Cube d), ∃states : ℕ → CanonicalProgramState d,
      ∃c : EuclideanSpace ℝ (states H).Index,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (S.card:ℝ)≤(∑j:Fin H,criticalLayerCost P j/δ j)+‖P.readout‖^2/ρ^2 ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      (∀j<H,CanonicalProgramStep P S j (states j) (states (j+1))) ∧
      (∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x
        (canonicalQueryError P δ j)) ∧
      ‖c‖≤‖P.readout‖ ∧
      ∀x,|inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x)|≤
        ρ+‖P.readout‖*canonicalQueryError P δ H := by
  have hterminal : ∀x,‖P.feature H x‖≤1 := by
    intro x
    have hh := P.hidden_norm_le_one (H-1) (by omega) x
    simpa only [Nat.sub_add_cancel hH] using hh
  obtain ⟨S,hcard,hgap,hreadout⟩ := joint_entropy_readout_anchors
    (fun j:Fin H => P.law j) (fun j:Fin H => fieldLaw (fun x i => P.feature j x i))
    (fun j => P.probability j j.isLt) (fun j => inferInstance)
    (fun j => P.finiteKL_one j j.isLt) (fun j:Fin H => δ j) (fun j => hδ j j.isLt)
    (P.feature H) P.readout hterminal hρ
  obtain ⟨states,hzero,hanchor,hdim,hstep,hquery⟩ := critical_canonical_query_program P S δ hδ
    (fun j hj x => hgap ⟨j,hj⟩ x)
  obtain ⟨c,hc,herror⟩ := transport_anchored_readout (P.feature H) (states H).feature
    P.readout S (canonicalQueryError_nonneg P δ H)
    (hanchor H le_rfl) (hquery H le_rfl) hreadout
  exact ⟨S,states,c,hzero,hcard,hdim,hstep,hquery,hc,herror⟩

#print axioms critical_canonical_readout_program
end ConditionalNonpolynomial.Analytic
