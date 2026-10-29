import NetworkDenseCost
import AdaptiveProjectionCost
import NeuralGeneralization.BatchTwoContinuousDepthCriticalReadoutMass

noncomputable section
set_option linter.unusedSectionVars false
set_option maxHeartbeats 600000
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.BatchTwoActivation
open NeuralGeneralization.NetworkLayerSplit NeuralGeneralization.TanhDifferential
open NeuralGeneralization.TowerNetwork NeuralGeneralization.NetworkReadout
open NeuralGeneralization.RobustGaussianGeometry NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.BatchTwoContinuousDepthCritical
open NeuralGeneralization.BatchTwoContinuous.PairMoments

variable {d N r : ℕ}

@[simp] lemma previousWeights_withReadout (w : Weights d N (r+1)) (v : Fin N→ℝ) :
    previousWeights (withReadout w v)=withReadout (previousWeights w) v := by
  ext i
  rcases i with ij | (sij | j) <;> rfl

@[simp] lemma lastMatrix_withReadout (w : Weights d N (r+1)) (v : Fin N→ℝ) :
    lastMatrix (withReadout w v)=lastMatrix w := by
  ext i
  rfl

@[simp] theorem hiddenDenseCost_withReadout (d N : ℕ) (σ G : ℝ) (M : ℕ) :
    ∀ r (w : Weights d N r) (v : Fin N→ℝ),
      hiddenDenseCost d N σ G M r (withReadout w v)=hiddenDenseCost d N σ G M r w := by
  intro r
  induction r with
  | zero => intros; rfl
  | succ r ih =>
    intro w v
    simp only [hiddenDenseCost,previousWeights_withReadout,ih]
    congr 1

def readoutStandardize (σ : ℝ) (v : Fin N→ℝ) : Fin N→ℝ :=
  fun i => Real.sqrt N/σ*v i

@[fun_prop] lemma measurable_readoutStandardize (σ : ℝ) :
    Measurable (readoutStandardize (N:=N) σ) := by unfold readoutStandardize; fun_prop

lemma readoutStandardize_law (hN : 0<N) {σ : ℝ} (hσ : 0<σ) :
    (smallReadoutPrior N σ).map (readoutStandardize σ)=standardLaw (Fin N) := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  unfold smallReadoutPrior readoutStandardize standardLaw
  rw [Measure.pi_map_pi (f:=fun (_:Fin N) (z:ℝ)=>(Real.sqrt N/σ)*z)
    (fun _=>(show Measurable (fun z:ℝ=>(Real.sqrt N/σ)*z) by fun_prop).aemeasurable)]
  congr 1
  funext i
  rw [gaussianReal_map_const_mul,mul_zero]
  congr 1
  apply NNReal.coe_injective
  simp only [NNReal.coe_mul,NNReal.coe_mk,NNReal.coe_one,
    Real.coe_toNNReal _ (show 0≤σ^2/(N:ℝ) by positivity)]
  rw [div_pow,Real.sq_sqrt hn.le]
  field_simp [hσ.ne',hn.ne']

/-- All actual Boolean-cube hidden feature rows. Only their span matters. -/
def cubeHiddenFamily (w : Weights d N r) :
    Fin (Fintype.card (Cube d)) → EuclideanSpace ℝ (Fin N) :=
  fun i => WithLp.toLp 2 (finalHidden Real.tanh w ((Fintype.equivFin (Cube d)).symm i))

@[fun_prop] lemma measurable_cubeHiddenFamily :
    Measurable (cubeHiddenFamily (d:=d) (N:=N) (r:=r)) := by
  unfold cubeHiddenFamily
  apply measurable_pi_lambda
  intro i
  apply (WithLp.measurable_toLp 2 (Fin N→ℝ)).comp
  exact (continuous_pi (fun j=>continuous_finalHidden continuous_tanh
    ((Fintype.equivFin (Cube d)).symm i) j)).measurable

@[simp] lemma cubeHiddenFamily_withReadout (w : Weights d N r) (v : Fin N→ℝ) :
    cubeHiddenFamily (withReadout w v)=cubeHiddenFamily w := by rfl

def projectedReadoutSquared (σ : ℝ) (w : Weights d N r) : ℝ :=
  ‖activeProjection (cubeHiddenFamily w)
    (WithLp.toLp 2 (readoutStandardize σ (fun i=>w (.inr (.inr i)))))‖^2

@[fun_prop] lemma measurable_projectedReadoutSquared (σ : ℝ) :
    Measurable (projectedReadoutSquared (d:=d) (N:=N) (r:=r) σ) := by
  have hread : Measurable (fun w : Weights d N r =>
      WithLp.toLp 2 (readoutStandardize σ (fun i=>w (.inr (.inr i))))) :=
    (WithLp.measurable_toLp 2 (Fin N→ℝ)).comp
      ((measurable_readoutStandardize σ).comp (by fun_prop))
  have hpair := measurable_cubeHiddenFamily.prodMk hread
  have hp := (measurable_activeProjection (m:=Fintype.card (Cube d)) (N:=N)).comp hpair
  exact hp.norm.pow_const 2

def fullDenseCost (d N r : ℕ) (σ G s : ℝ) (M : ℕ) (w : Weights d N r) : ℝ :=
  hiddenDenseCost d N σ G M r w + ((1-s)/(2*N))*projectedReadoutSquared σ w

@[fun_prop] lemma measurable_fullDenseCost (d N r : ℕ) (σ G s : ℝ) (M : ℕ) :
    Measurable (fullDenseCost d N r σ G s M) :=
  (measurable_hiddenDenseCost d N σ G M r).add
    ((measurable_projectedReadoutSquared σ).const_mul _)

/-- Actual finite-network exponential moment of hidden entropy certificates
plus the projected readout cost. The readout overhead depends on the number
of inputs, never the ambient learner width. -/
theorem fullDenseCost_mgf (d N r : ℕ) (hd : 0<d) (hN : 0<N)
    (σ G s : ℝ) (hσ : 0<σ) (hs : 0<s) (hs1 : s≤1) (M : ℕ) :
    Integrable (fun w : Weights d N r => Real.exp ((N:ℝ)*fullDenseCost d N r σ G s M w))
      (smallPrior d N r σ) ∧
    (∫ w : Weights d N r,Real.exp ((N:ℝ)*fullDenseCost d N r σ G s M w)
      ∂smallPrior d N r σ) ≤
        denseOverhead d N M G^(r+1)*(Real.sqrt s)⁻¹^(Fintype.card (Cube d)) := by
  have hhidden := hiddenDenseCost_mgf d N hd hN σ G hσ M r
  obtain ⟨hi,hm⟩ := adaptive_projection_mgf
    (smallPrior d N r σ) (smallReadoutPrior N σ)
    cubeHiddenFamily measurable_cubeHiddenFamily
    (readoutStandardize σ) (measurable_readoutStandardize σ) (readoutStandardize_law hN hσ)
    (fun w=>Real.exp ((N:ℝ)*hiddenDenseCost d N σ G M r w))
    (Real.measurable_exp.comp (measurable_const.mul (measurable_hiddenDenseCost d N σ G M r)))
    (fun _=>(Real.exp_pos _).le) hhidden.1 s hs hs1
  let H : Weights d N r→ℝ := fun w=>Real.exp ((N:ℝ)*fullDenseCost d N r σ G s M w)
  have hH : Measurable H :=
    Real.measurable_exp.comp (measurable_const.mul (measurable_fullDenseCost d N r σ G s M))
  have hex (w : Weights d N r) (v : Fin N→ℝ) : H (withReadout w v)=
      Real.exp ((N:ℝ)*hiddenDenseCost d N σ G M r w)*
      Real.exp (((1-s)/2)*‖activeProjection (cubeHiddenFamily w)
        (WithLp.toLp 2 (readoutStandardize σ v))‖^2) := by
    dsimp [H,fullDenseCost]
    rw [hiddenDenseCost_withReadout,mul_add,Real.exp_add]
    congr 1
    congr 1
    simp only [projectedReadoutSquared,cubeHiddenFamily_withReadout,withReadout]
    have hn : (N:ℝ)≠0 := by exact_mod_cast hN.ne'
    field_simp
  have hp := smallPrior_withReadout_preserving (d:=d) (N:=N) (r:=r) σ
  have hcomp : Integrable (H ∘ (fun p : Weights d N r × (Fin N→ℝ)=>withReadout p.1 p.2))
      ((smallPrior d N r σ).prod (smallReadoutPrior N σ)) := by
    simpa only [Function.comp_def,hex] using hi
  have hInt : Integrable H (smallPrior d N r σ) :=
    (hp.integrable_comp hH.aestronglyMeasurable).mp hcomp
  refine ⟨hInt,?_⟩
  have heq : (∫ w,H w ∂smallPrior d N r σ)=
      ∫ p : Weights d N r × (Fin N→ℝ),H (withReadout p.1 p.2)
        ∂(smallPrior d N r σ).prod (smallReadoutPrior N σ) := by
    conv_lhs => rw [←hp.map_eq]
    rw [integral_map hp.measurable.aemeasurable hH.aestronglyMeasurable]
  change (∫ w,H w ∂smallPrior d N r σ)≤_
  rw [heq]
  simp_rw [hex]
  exact hm.trans_eq (by rw [hhidden.2])

/-- A realization of the original Gaussian neural network in every event
larger than the explicit exponential tail has bounded aggregate action. -/
theorem full_network_event_witness (d N r : ℕ) (hd : 0<d) (hN : 0<N)
    (σ G s B : ℝ) (hσ : 0<σ) (hs : 0<s) (hs1 : s≤1) (M : ℕ)
    (E : Set (Weights d N r))
    (hMass : (denseOverhead d N M G^(r+1)*(Real.sqrt s)⁻¹^(Fintype.card (Cube d))) /
      Real.exp ((N:ℝ)*B) < (smallPrior d N r σ).real E) :
    ∃ w∈E,fullDenseCost d N r σ G s M w≤B := by
  have hh := fullDenseCost_mgf d N r hd hN σ G s hσ hs hs1 M
  exact exists_mem_cost_le (smallPrior d N r σ) _ hN E B _ hh.1 hh.2 hMass

#print axioms fullDenseCost_mgf
#print axioms full_network_event_witness
#print axioms hiddenDenseCost_withReadout
#print axioms readoutStandardize_law
end ConditionalNonpolynomial.Analytic
