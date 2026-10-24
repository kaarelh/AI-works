import NeuralGeneralization.BatchTwoImprovedReadoutTail
import NeuralGeneralization.RobustCompressionTerminalReadout

/-! The importance-sampled terminal reconstruction is a genuine measurable
Markov kernel on the full canonical state, independent of the test input. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoImprovedReadout
open ConcreteModel RobustCompressionInduction RobustCompression
open RobustCompressionReconstruction
open RobustCompressionReadout RobustCompressionSampling CompressionSampling Classical
variable {d N m s : ℕ}

@[fun_prop] theorem measurable_sampledCoefficient :
    Measurable (fun p : (Fin N → ℝ) × (Fin m → Fin N) => sampledCoefficient p.1 p.2) := by
  apply measurable_pi_lambda
  intro j
  unfold sampledCoefficient
  apply Measurable.div_const
  apply ((measurable_amplitude (N := N)).comp measurable_fst).mul
  apply measurable_coefficientSign.comp
  exact measurable_finite_select
    (fun p : (Fin N → ℝ) × (Fin m → Fin N) => p.1)
    (fun p => p.2 j) measurable_fst (by fun_prop)

def importanceTerminalDraw (t K : ℝ) (p : TerminalState d N m s)
    (I : Fin m → Fin N) : Weights d m s :=
  if terminalEnergy t p.2 ≤ K then
    finishActive p.1 I (sampledCoefficient (terminalCoefficients t p.2) I)
  else fun _ => 0

theorem measurable_importanceTerminalDraw (t K : ℝ) :
    Measurable (fun p : TerminalState d N m s × (Fin m → Fin N) =>
      importanceTerminalDraw t K p.1 p.2) := by
  have hv : Measurable (fun p : TerminalState d N m s × (Fin m → Fin N) =>
      sampledCoefficient (terminalCoefficients t p.1.2) p.2) := by
    have ha : Measurable (fun p : TerminalState d N m s × (Fin m → Fin N) =>
        terminalCoefficients t p.1.2) := by
      unfold terminalCoefficients
      fun_prop
    apply measurable_pi_lambda
    intro j
    unfold sampledCoefficient
    apply Measurable.div_const
    apply (measurable_amplitude.comp ha).mul
    apply measurable_coefficientSign.comp
    exact measurable_finite_select
      (fun p : TerminalState d N m s × (Fin m → Fin N) => terminalCoefficients t p.1.2)
      (fun p => p.2 j) ha (by fun_prop)
  have hh := measurable_finishActive
    (fun p : TerminalState d N m s × (Fin m → Fin N) => p.1.1)
    (fun p => p.2) (fun p => sampledCoefficient (terminalCoefficients t p.1.2) p.2)
    (by fun_prop) (by fun_prop) hv
  unfold importanceTerminalDraw
  exact hh.ite
    (measurableSet_le ((measurable_terminalEnergy t).comp (by fun_prop)) measurable_const)
    measurable_const

def terminalIndicesKernel (hN : 0 < N) (t : ℝ) :
    Kernel (TerminalState d N m s) (Fin m → Fin N) :=
  (indicesKernel hN m).comap (fun p => terminalCoefficients t p.2) (by
    unfold terminalCoefficients
    fun_prop)

instance terminalIndicesKernel_markov (hN : 0 < N) (t : ℝ) :
    IsMarkovKernel (terminalIndicesKernel (d := d) (m := m) (s := s) hN t) := by
  unfold terminalIndicesKernel
  infer_instance

def importanceTerminalKernel (hN : 0 < N) (t K : ℝ) :
    Kernel (TerminalState d N m s) (Weights d m s) :=
  parameterMap (terminalIndicesKernel hN t)
    (fun p => importanceTerminalDraw t K p.1 p.2) (measurable_importanceTerminalDraw t K)

instance importanceTerminalKernel_markov (hN : 0 < N) (t K : ℝ) :
    IsMarkovKernel (importanceTerminalKernel (d := d) (m := m) (s := s) hN t K) := by
  unfold importanceTerminalKernel
  infer_instance

theorem importanceTerminalKernel_apply (hN : 0 < N) (t K : ℝ)
    (p : TerminalState d N m s) :
    importanceTerminalKernel hN t K p =
      (indicesKernel hN m (terminalCoefficients t p.2)).map (importanceTerminalDraw t K p) := by
  rw [importanceTerminalKernel, parameterMap_apply, terminalIndicesKernel, Kernel.comap_apply]

theorem importanceTerminalDraw_output (φ : ℝ → ℝ) (t K : ℝ)
    (p : TerminalState d N m s) (I : Fin m → Fin N) (x : Cube d)
    (henergy : terminalEnergy t p.2 ≤ K) :
    networkOutput φ (importanceTerminalDraw t K p I) x =
      sampledOutput (terminalCoefficients t p.2) (activeHidden φ p.1) I x := by
  simp only [importanceTerminalDraw, if_pos henergy, finishActive_output]
  rfl

theorem importanceTerminalDraw_bounded (hN : 0 < N) {t K W : ℝ}
    (hK : 0 ≤ K) (hW : 0 ≤ W) (hKW : Real.sqrt K / m ≤ W)
    (p : TerminalState d N m s) (hp : activePrefixBounded W p.1)
    (I : Fin m → Fin N) : boundedWeights W (importanceTerminalDraw t K p I) := by
  unfold importanceTerminalDraw
  split_ifs with he
  · exact finishActive_bounded W hW p.1 hp I _
      (fun j => (sampledCoefficient_bound hN _ hK he I j).trans hKW)
  · intro i
    simpa using hW

theorem importanceTerminalDraw_sampling_budget (hN : 0 < N) (hm : 0 < m)
    (φ : ℝ → ℝ) (hφ : ∀ z, |φ z| ≤ 1) {t K r η : ℝ}
    (hK : 0 < K) (hr : 0 < r) (hη : 0 < η)
    (p : TerminalState d N m s) (henergy : terminalEnergy t p.2 ≤ K)
    (hbudget : 128*K/r^2 * Real.log (2*(2:ℝ)^d/η) ≤ (m : ℝ)) :
    (indicesKernel hN m (terminalCoefficients t p.2)).real
      {I | ∃ x : Cube d, r/8 ≤ |networkOutput φ (importanceTerminalDraw t K p I) x -
        readoutValue (terminalCoefficients t p.2) (activeHidden φ p.1) x|} ≤ η := by
  simp_rw [importanceTerminalDraw_output φ t K p _ _ henergy]
  apply importance_sampling_budget hN hm _ _ (activeHidden_bounded φ hφ p.1) hK hr hη henergy
  simpa only [Cube, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin,
    Nat.cast_pow, Nat.cast_ofNat] using hbudget

theorem importanceTerminalKernel_approximation (hN : 0 < N) (hm : 0 < m)
    (φ : ℝ → ℝ) (hφc : Continuous φ) (hφ : ∀ z, |φ z| ≤ 1) {t K r η : ℝ}
    (hK : 0 < K) (hr : 0 < r) (hη : 0 < η)
    (p : TerminalState d N m s) (henergy : terminalEnergy t p.2 ≤ K)
    (hbudget : 128*K/r^2 * Real.log (2*(2:ℝ)^d/η) ≤ (m : ℝ)) :
    (importanceTerminalKernel hN t K p).real
      {w | ∃ x : Cube d, r/8 ≤ |networkOutput φ w x -
        readoutValue (terminalCoefficients t p.2) (activeHidden φ p.1) x|} ≤ η := by
  have hmap : Measurable (importanceTerminalDraw (d := d) (N := N) (m := m) (s := s) t K p) :=
    measurable_of_finite _
  have hE : MeasurableSet {w : Weights d m s | ∃ x : Cube d, r/8 ≤ |networkOutput φ w x -
      readoutValue (terminalCoefficients t p.2) (activeHidden φ p.1) x|} := by
    simp only [Set.setOf_exists]
    apply MeasurableSet.iUnion
    intro x
    exact measurableSet_le measurable_const
      (((continuous_networkOutput hφc x).measurable.sub_const _).abs)
  rw [importanceTerminalKernel_apply, Measure.real, Measure.map_apply hmap hE]
  exact importanceTerminalDraw_sampling_budget hN hm φ hφ hK hr hη p henergy hbudget

end NeuralGeneralization.BatchTwoImprovedReadout
