import NeuralGeneralization.BatchTwoManuscriptReadoutImportance

/-! A measurable input-independent importance readout kernel on the actual
canonical terminal states. The output is an ordinary bounded network. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoManuscriptReadout
open Classical ConcreteModel RobustCompressionInduction BatchTwoImprovedWeightedSampling
open RobustCompressionReconstruction RobustCompression RobustCompressionSampling CompressionSampling
variable {d N m s : ℕ}

@[fun_prop] theorem measurable_readoutSign : Measurable readoutSign := by
  exact Measurable.ite (measurableSet_le measurable_const measurable_id) measurable_const measurable_const

@[fun_prop] theorem measurable_absoluteSum : Measurable (absoluteSum (N:=N)) := by
  unfold absoluteSum
  fun_prop

@[fun_prop] theorem measurable_absoluteMean : Measurable (absoluteMean (N:=N)) := by
  unfold absoluteMean
  fun_prop

@[fun_prop] theorem measurable_probability : Measurable (probability (N:=N)) := by
  apply measurable_pi_lambda
  intro i
  unfold probability
  exact Measurable.ite (measurableSet_eq_fun measurable_absoluteSum measurable_const)
    measurable_const (((measurable_pi_apply i).abs).div measurable_absoluteSum)

def indicesKernel (hN : 0<N) (m : ℕ) : Kernel (Fin N→ℝ) (Fin m→Fin N) where
  toFun := fun a=>finiteLaw (iidWeight (probability a) m)
    (iidWeight_nonneg _ (probability_nonneg a) m) (iidWeight_mass _ (probability_mass hN a) m)
  measurable' := by
    apply measurable_finiteLaw
    unfold iidWeight
    apply measurable_pi_lambda
    intro I
    apply Finset.measurable_prod
    intro j _
    exact (measurable_pi_apply (I j)).comp measurable_probability

instance indicesKernel_markov (hN : 0<N) : IsMarkovKernel (indicesKernel hN m) where
  isProbabilityMeasure a := by
    change IsProbabilityMeasure (finiteLaw (iidWeight (probability a) m)
      (iidWeight_nonneg _ (probability_nonneg a) m) (iidWeight_mass _ (probability_mass hN a) m))
    infer_instance

theorem indicesKernel_eq_iid (hN : 0<N) (a : Fin N→ℝ) :
    indicesKernel hN m a=iidSamples (indexLaw hN a) m := by
  apply Measure.ext_of_singleton
  intro I
  change finiteLaw (iidWeight (probability a) m)
    (iidWeight_nonneg _ (probability_nonneg a) m) (iidWeight_mass _ (probability_mass hN a) m) {I}=_
  rw [finiteLaw_singleton,show iidSamples (indexLaw hN a) m=Measure.pi (fun _ : Fin m=>indexLaw hN a) from rfl,Measure.pi_singleton]
  change ENNReal.ofReal (∏j,probability a (I j))=_
  rw [ENNReal.ofReal_prod_of_nonneg (fun j _=>probability_nonneg a (I j))]
  apply Finset.prod_congr rfl
  intro j _
  exact (finiteLaw_singleton (probability a) (probability_nonneg a) (probability_mass hN a) (I j)).symm

@[fun_prop] theorem measurable_terminalCoefficients (t : ℝ) :
    Measurable (terminalCoefficients (N:=N) t) := by
  unfold terminalCoefficients
  fun_prop

def stateIndicesKernel (hN : 0<N) (t : ℝ) : Kernel (TerminalState d N m s) (Fin m→Fin N) :=
  (indicesKernel hN m).comap (fun p=>terminalCoefficients t p.2)
    ((measurable_terminalCoefficients t).comp measurable_snd)

instance stateIndicesKernel_markov (hN : 0<N) (t : ℝ) :
    IsMarkovKernel (stateIndicesKernel (d:=d) (m:=m) (s:=s) hN t) := by
  unfold stateIndicesKernel
  infer_instance

theorem stateIndicesKernel_apply (hN : 0<N) (t : ℝ) (p : TerminalState d N m s) :
    stateIndicesKernel hN t p=iidSamples (indexLaw hN (terminalCoefficients t p.2)) m := by
  rw [stateIndicesKernel,Kernel.comap_apply,indicesKernel_eq_iid]

def draw (t K : ℝ) (p : TerminalState d N m s) (I : Fin m→Fin N) : Weights d m s :=
  if terminalEnergy t p.2≤K then finishActive p.1 I (coefficient (terminalCoefficients t p.2) I)
  else fun _=>0

@[fun_prop] theorem measurable_coefficient :
    Measurable (fun p : (Fin N→ℝ)×(Fin m→Fin N)=>coefficient p.1 p.2) := by
  apply measurable_pi_lambda
  intro j
  unfold coefficient
  have hs : Measurable (fun p : (Fin N→ℝ)×(Fin m→Fin N)=>p.1 (p.2 j)) :=
    measurable_finite_select (fun p : (Fin N→ℝ)×(Fin m→Fin N)=>p.1) (fun p=>p.2 j) measurable_fst (by fun_prop)
  exact (((measurable_absoluteMean.comp measurable_fst).mul (measurable_readoutSign.comp hs)).div_const _)

@[fun_prop] theorem measurable_draw (t K : ℝ) :
    Measurable (fun p : TerminalState d N m s×(Fin m→Fin N)=>draw t K p.1 p.2) := by
  have hv : Measurable (fun p : TerminalState d N m s×(Fin m→Fin N)=>
      coefficient (terminalCoefficients t p.1.2) p.2) :=
    measurable_coefficient.comp (((measurable_terminalCoefficients t).comp (by fun_prop)).prodMk measurable_snd)
  have hf := measurable_finishActive
    (fun p : TerminalState d N m s×(Fin m→Fin N)=>p.1.1)
    (fun p=>p.2) (fun p=>coefficient (terminalCoefficients t p.1.2) p.2)
    (by fun_prop) measurable_snd hv
  exact hf.ite (measurableSet_le ((measurable_terminalEnergy t).comp (by fun_prop)) measurable_const) measurable_const

def terminalKernel (hN : 0<N) (t K : ℝ) : Kernel (TerminalState d N m s) (Weights d m s) :=
  parameterMap (stateIndicesKernel hN t) (fun p=>draw t K p.1 p.2) (measurable_draw t K)

instance terminalKernel_markov (hN : 0<N) (t K : ℝ) :
    IsMarkovKernel (terminalKernel (d:=d) (m:=m) (s:=s) hN t K) := by
  unfold terminalKernel
  infer_instance

theorem terminalKernel_apply (hN : 0<N) (t K : ℝ) (p : TerminalState d N m s) :
    terminalKernel hN t K p=(iidSamples (indexLaw hN (terminalCoefficients t p.2)) m).map (draw t K p) := by
  rw [terminalKernel,parameterMap_apply,stateIndicesKernel_apply]

theorem draw_bounded (hN : 0<N) {t K B : ℝ} (hB : 0≤B)
    (hb : Real.sqrt K/(m:ℝ)≤B) (p : TerminalState d N m s)
    (hp : activePrefixBounded B p.1) (I : Fin m→Fin N) : boundedWeights B (draw t K p I) := by
  unfold draw
  split_ifs with he
  · exact finishActive_bounded B hB p.1 hp I _ (fun j=>(coefficient_bound hN _ he I j).trans hb)
  · intro i
    simpa using hB

theorem draw_output (φ : ℝ→ℝ) (t K : ℝ) (p : TerminalState d N m s)
    (I : Fin m→Fin N) (x : Cube d) (he : terminalEnergy t p.2≤K) :
    networkOutput φ (draw t K p I) x=
      empiricalMean (observation (terminalCoefficients t p.2) (fun i=>activeHidden φ p.1 x i)) I := by
  rw [draw,if_pos he,finishActive_output]
  unfold empiricalMean coefficient observation
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem draw_sampling_tail (hN : 0<N) (hm : 0<m) (φ : ℝ→ℝ) (hφ : ∀z,|φ z|≤1)
    {t K radius : ℝ} (hK : 0<K) (hr : 0≤radius) (p : TerminalState d N m s)
    (he : terminalEnergy t p.2≤K) :
    (stateIndicesKernel hN t p).real {I | ∃x : Cube d,
      radius≤|networkOutput φ (draw t K p I) x-
        RobustCompressionReadout.readoutValue (terminalCoefficients t p.2) (activeHidden φ p.1) x|}≤
      (2:ℝ)^d*(2*Real.exp (-(m:ℝ)*radius^2/(2*K))) := by
  rw [stateIndicesKernel_apply]
  simp only [draw_output φ t K p _ _ he,RobustCompressionReadout.readoutValue]
  have ht := sampling_tail hN hm (terminalCoefficients t p.2) (activeHidden φ p.1)
    (activeHidden_bounded φ hφ p.1) hK he hr
  simpa only [Cube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin,Nat.cast_pow,Nat.cast_ofNat] using ht

end NeuralGeneralization.BatchTwoManuscriptReadout
