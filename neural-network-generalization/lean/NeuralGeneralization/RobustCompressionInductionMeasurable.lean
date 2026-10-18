import NeuralGeneralization.RobustCompressionInductionPrefix
import Mathlib.Probability.Kernel.Composition.Prod

/-! # Measurable actual-prefix updates

The source bank is a random finite tuple. The update is jointly measurable in
that bank and all continuous coefficients, so it may be applied to the actual
one-layer reconstruction kernel without pointwise measurable-choice premises.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel

variable {A : Type*} [MeasurableSpace A]

/-- Joint evaluation at a random finite index. -/
theorem measurable_finite_eval {I V : Type*} [Countable I]
    [MeasurableSpace I] [MeasurableSingletonClass I] [MeasurableSpace V]
    (f : A → I → V) (i : A → I) (hf : Measurable f) (hi : Measurable i) :
    Measurable (fun a => f a (i a)) := by
  have he : Measurable (fun p : (I → V) × I => p.1 p.2) :=
    measurable_from_prod_countable_left (fun j => measurable_pi_apply j)
  exact he.comp (hf.prodMk hi)

theorem measurable_appendWeights {d m s : ℕ} (w : A → Weights d m s)
    (a : A → Fin m → Fin m → ℝ) (hw : Measurable w) (ha : Measurable a) :
    Measurable (fun z => appendWeights (w z) (a z)) := by
  apply measurable_pi_lambda
  intro i
  rcases i with ij | i
  · exact hw.eval
  · rcases i with ⟨k,i,j⟩ | i
    · induction k using Fin.lastCases with
      | last => simpa using (ha.eval.eval : Measurable (fun z => a z i j))
      | cast k => simpa using (hw.eval : Measurable (fun z => w z (Sum.inr (Sum.inl (k,i,j)))))
    · exact hw.eval

theorem measurable_extendPrefix {d N m s : ℕ}
    (p : A → VirtualPrefix d N m s) (I : A → Fin m → Fin N)
    (rows : A → VirtualRows N m) (hp : Measurable p)
    (hI : Measurable I) (hrows : Measurable rows) :
    Measurable (fun z => extendPrefix (p z) (I z) (rows z)) := by
  apply Measurable.prodMk _ hrows
  apply measurable_appendWeights _ _ hp.fst
  apply measurable_pi_lambda
  intro i
  apply measurable_pi_lambda
  intro j
  have hsel := measurable_finite_eval (fun z => (p z).2) (fun z => I z i)
    hp.snd hI.eval
  exact hsel.eval

theorem measurable_firstPrefix {d N m r : ℕ}
    (w : A → Weights d N r) (I : A → Fin m → Fin N)
    (rows : A → VirtualRows N m) (hw : Measurable w)
    (hI : Measurable I) (hrows : Measurable rows) :
    Measurable (fun z => firstPrefix (w z) (I z) (rows z)) := by
  apply Measurable.prodMk _ hrows
  apply measurable_pi_lambda
  intro k
  rcases k with ⟨i,j⟩ | k
  · change Measurable (fun z => w z (Sum.inl (I z i,j)))
    have he : Measurable (fun z => fun k : Fin N => w z (Sum.inl (k,j))) :=
      measurable_pi_lambda _ (fun k => hw.eval)
    exact measurable_finite_eval (fun z k => w z (Sum.inl (k,j))) (fun z => I z i) he hI.eval
  · rcases k with ⟨s,i,j⟩ | i
    · exact Fin.elim0 s
    · exact measurable_const

theorem measurable_virtualHidden {d N m s : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x : Cube d) :
    Measurable (fun p : VirtualPrefix d N m s => virtualHidden φ p x) := by
  apply measurable_pi_lambda
  intro i
  unfold virtualHidden
  apply hφ.measurable.comp
  apply Finset.measurable_sum
  intro j hj
  apply Measurable.mul
  · exact measurable_snd.eval.eval
  · exact (continuous_finalHidden hφ x j).measurable.comp measurable_fst

abbrev PrefixDraw (N m : ℕ) := (Fin m → Fin N) × VirtualRows N m

/-- Push the actual layer reconstruction draw through the exact finite
network update. The resulting kernel has no dependence on the queried input. -/
def extendPrefixKernel {d N m s : ℕ}
    (p : A → VirtualPrefix d N m s) (hp : Measurable p)
    (κ : Kernel A (PrefixDraw N m)) : Kernel A (VirtualPrefix d N m (s+1)) :=
  (Kernel.id ×ₖ κ).map (fun z => extendPrefix (p z.1) z.2.1 z.2.2)

instance extendPrefixKernel_markov {d N m s : ℕ}
    (p : A → VirtualPrefix d N m s) (hp : Measurable p)
    (κ : Kernel A (PrefixDraw N m)) [IsMarkovKernel κ] :
    IsMarkovKernel (extendPrefixKernel p hp κ) := by
  unfold extendPrefixKernel
  apply Kernel.IsMarkovKernel.map
  exact measurable_extendPrefix _ _ _ (hp.comp measurable_fst)
    (measurable_fst.comp measurable_snd) (measurable_snd.comp measurable_snd)

end NeuralGeneralization.RobustCompressionInduction
