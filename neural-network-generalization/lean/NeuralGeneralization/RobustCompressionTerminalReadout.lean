import NeuralGeneralization.RobustCompressionInductionStateMeasurable
import NeuralGeneralization.RobustCompressionInductionBlocks
import NeuralGeneralization.RobustCompressionReadout
import NeuralGeneralization.RobustCompressionResourceAllocations
import NeuralGeneralization.RobustCompressionObservableKernel
import NeuralGeneralization.RobustCompressionReconstruction

/-!
# The actual terminal readout sampling kernel

The terminal state contains the complete compact prefix and original
standardized readout. One common source sample produces an ordinary network
for every input simultaneously. Large readout energy aborts to the zero network.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustCompressionReadout RobustCompressionClipping
open CompressionSampling RobustCompression RobustEntropy RobustCompressionSampling
open RobustCompressionReconstruction

variable {d N m s : ℕ}

/-- A recursive bound on all stored ordinary and virtual coefficients. -/
def payloadBounded (d N m : ℕ) (B : ℝ) : (s : ℕ) → PrefixPayload d N m s → Prop
  | 0,a => ∀ i j, |a i j| ≤ B
  | _+1,p => boundedWeights B p.1 ∧ ∀ i j, |p.2 i j| ≤ B

def activePrefixBounded (B : ℝ) (p : ActivePrefix d N m s) : Prop :=
  p.1 = true → payloadBounded d N m B s p.2

theorem finishPayload_bounded (B : ℝ) (hB : 0 ≤ B)
    (p : PrefixPayload d N m s) (hp : payloadBounded d N m B s p)
    (I : Fin m → Fin N) (v : Fin m → ℝ) (hv : ∀ i, |v i| ≤ B) :
    boundedWeights B (finishPayload d N m s p I v) := by
  cases s with
  | zero =>
    intro z
    rcases z with ⟨i,j⟩ | (⟨k,i,j⟩ | i)
    · exact hp (I i) j
    · exact Fin.elim0 k
    · exact hv i
  | succ s => exact finishPrefix_bounded p I v hp.1 hp.2 hv

theorem finishActive_bounded (B : ℝ) (hB : 0 ≤ B)
    (p : ActivePrefix d N m s) (hp : activePrefixBounded B p)
    (I : Fin m → Fin N) (v : Fin m → ℝ) (hv : ∀ i, |v i| ≤ B) :
    boundedWeights B (finishActive p I v) := by
  unfold finishActive
  split_ifs with h
  · exact finishPayload_bounded B hB p.2 (hp h) I v hv
  · intro i
    simpa using hB

theorem activeHidden_bounded (φ : ℝ → ℝ) (hφ : ∀ z, |φ z| ≤ 1)
    (p : ActivePrefix d N m s) (x : Cube d) (i : Fin N) :
    |activeHidden φ p x i| ≤ 1 := by
  unfold activeHidden
  split_ifs
  · cases s <;> exact hφ _
  · norm_num

abbrev TerminalState (d N m s : ℕ) := ActivePrefix d N m s × FutureWeights N 0

def terminalCoefficients (t : ℝ) (z : FutureWeights N 0) : Fin N → ℝ :=
  fun i => t * z (Sum.inr i)

def terminalEnergy (t : ℝ) (z : FutureWeights N 0) : ℝ :=
  populationMean (fun i => terminalCoefficients t z i ^ 2)

theorem terminalEnergy_nonneg (t : ℝ) (z : FutureWeights N 0) : 0 ≤ terminalEnergy t z := by
  unfold terminalEnergy populationMean
  positivity

@[fun_prop] theorem measurable_terminalEnergy (t : ℝ) :
    Measurable (terminalEnergy (N := N) t) := by
  unfold terminalEnergy terminalCoefficients populationMean
  fun_prop

/-- The sampled readout coefficients include their actual averaging factor. -/
def terminalReadout (t B : ℝ) (z : FutureWeights N 0) (I : Fin m → Fin N) : Fin m → ℝ :=
  fun j => wholeClip B (terminalCoefficients t z (I j)) / (m : ℝ)

def terminalDraw (t B K : ℝ) (p : TerminalState d N m s) (I : Fin m → Fin N) :
    Weights d m s := by
  classical
  exact if terminalEnergy t p.2 ≤ K then finishActive p.1 I (terminalReadout t B p.2 I)
    else fun _ => 0

theorem measurable_terminalDraw (t B K : ℝ) :
    Measurable (fun p : TerminalState d N m s × (Fin m → Fin N) =>
      terminalDraw t B K p.1 p.2) := by
  classical
  have hv : Measurable (fun p : TerminalState d N m s × (Fin m → Fin N) =>
      terminalReadout t B p.1.2 p.2) := by
    apply measurable_pi_lambda
    intro j
    unfold terminalReadout terminalCoefficients
    apply Measurable.div_const
    apply (measurable_wholeClip B).comp
    apply Measurable.const_mul
    exact (measurable_finite_select
      (fun p : TerminalState d N m s × (Fin m → Fin N) => fun i : Fin N => p.1.2 (Sum.inr i))
      (fun p => p.2 j) (by fun_prop) (by fun_prop))
  have hh := measurable_finishActive
    (fun p : TerminalState d N m s × (Fin m → Fin N) => p.1.1)
    (fun p => p.2) (fun p => terminalReadout t B p.1.2 p.2)
    (by fun_prop) (by fun_prop) hv
  unfold terminalDraw
  exact hh.ite
    (measurableSet_le ((measurable_terminalEnergy t).comp (by fun_prop)) measurable_const)
    measurable_const

/-- The canonical terminal kernel is independent of the test input. -/
def terminalKernel [NeZero N] (t B K : ℝ) : Kernel (TerminalState d N m s) (Weights d m s) :=
  parameterMap (Kernel.const _ (iidSamples (uniformIndexLaw N) m))
    (fun p => terminalDraw t B K p.1 p.2) (measurable_terminalDraw t B K)

instance terminalKernel_markov [NeZero N] (t B K : ℝ) :
    IsMarkovKernel (terminalKernel (d := d) (N := N) (m := m) (s := s) t B K) := by
  unfold terminalKernel
  infer_instance

theorem terminalKernel_apply [NeZero N] (t B K : ℝ) (p : TerminalState d N m s) :
    terminalKernel t B K p =
      (iidSamples (uniformIndexLaw N) m).map (terminalDraw t B K p) := by
  rw [terminalKernel, parameterMap_apply, Kernel.const_apply]

theorem terminalReadout_bounded {t B : ℝ} (hB : 0 ≤ B) (hm : 0 < m)
    (z : FutureWeights N 0) (I : Fin m → Fin N) (j : Fin m) :
    |terminalReadout t B z I j| ≤ B := by
  have hm1 : (1 : ℝ) ≤ m := by exact_mod_cast hm
  unfold terminalReadout
  rw [abs_div, abs_of_nonneg (show (0 : ℝ) ≤ m from Nat.cast_nonneg m)]
  exact (div_le_div_of_nonneg_right
    (by simpa only [Real.norm_eq_abs] using wholeClip_norm_le B hB (terminalCoefficients t z (I j)))
    (Nat.cast_nonneg m)).trans (div_le_self hB hm1)

theorem terminalDraw_bounded {t B K W : ℝ} (hB : 0 ≤ B) (hW : 0 ≤ W)
    (hBW : B ≤ W) (hm : 0 < m) (p : TerminalState d N m s)
    (hp : activePrefixBounded W p.1) (I : Fin m → Fin N) :
    boundedWeights W (terminalDraw t B K p I) := by
  unfold terminalDraw
  split_ifs
  · exact finishActive_bounded W hW p.1 hp I _
      (fun j => (terminalReadout_bounded hB hm p.2 I j).trans hBW)
  · intro i
    simpa using hW

theorem terminalDraw_output (φ : ℝ → ℝ) (t B K : ℝ)
    (p : TerminalState d N m s) (I : Fin m → Fin N) (x : Cube d)
    (henergy : terminalEnergy t p.2 ≤ K) :
    networkOutput φ (terminalDraw t B K p I) x =
      sampledReadout (terminalCoefficients t p.2) (activeHidden φ p.1) B I x := by
  simp only [terminalDraw, if_pos henergy, finishActive_output]
  unfold sampledReadout terminalReadout empiricalMean
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- For each complete canonical terminal state, the one sampling law controls
all Boolean inputs. No independence between its prefix and readout is needed. -/
theorem terminalDraw_sampling_tail [NeZero N] (hm : 0 < m)
    (φ : ℝ → ℝ) (hφ : ∀ z, |φ z| ≤ 1) {t B K η : ℝ}
    (hB : 0 < B) (hη : 0 ≤ η) (p : TerminalState d N m s)
    (henergy : terminalEnergy t p.2 ≤ K) :
    (iidSamples (uniformIndexLaw N) m).real
      {I | ∃ x : Cube d, K/B+η ≤ |networkOutput φ (terminalDraw t B K p I) x -
        readoutValue (terminalCoefficients t p.2) (activeHidden φ p.1) x|} ≤
      (2 : ℝ)^d * (2*Real.exp (-(m : ℝ)*η^2/(2*B^2))) := by
  have hh := readout_sampling_tail N m hm (terminalCoefficients t p.2)
    (activeHidden φ p.1) (activeHidden_bounded φ hφ p.1) hB hη henergy
  simp only [← terminalDraw_output φ t B K p _ _ henergy] at hh
  simpa only [Cube, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin,
    Nat.cast_pow, Nat.cast_ofNat] using hh

/-- An actual energy expectation implies the exact terminal abort probability.
The moment will be supplied by the preserved original readout marginal. -/
theorem terminal_energy_abort_le
    (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q]
    {t M K : ℝ} (hK : 0 < K)
    (hi : Integrable (fun p => terminalEnergy t p.2) Q)
    (hM : (∫ p, terminalEnergy t p.2 ∂Q) ≤ M) :
    Q.real {p | K < terminalEnergy t p.2} ≤ M/K := by
  have hh := mul_meas_ge_le_integral_of_nonneg
    (μ := Q) (Filter.Eventually.of_forall (fun p => terminalEnergy_nonneg t p.2)) hi K
  have hsub : {p : TerminalState d N m s | K < terminalEnergy t p.2} ⊆
      {p | K ≤ terminalEnergy t p.2} := by
    intro p hp
    change K < terminalEnergy t p.2 at hp
    exact hp.le
  have hb := measureReal_mono (μ := Q) hsub
  apply hb.trans
  apply (le_div_iff₀ hK).mpr
  nlinarith

end NeuralGeneralization.RobustCompressionInduction
