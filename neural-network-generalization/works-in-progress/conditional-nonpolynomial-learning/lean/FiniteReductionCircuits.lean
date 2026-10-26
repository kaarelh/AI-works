import FiniteReductionConverse
import CircuitOperations

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial

/-- Compile an already obtained exact majority using the explicit DAG
construction. Every constituent has its own concrete circuit witness. -/
theorem compile_exact_majority {d m : ℕ} (f : Input d → Bool)
    (gs : Fin m → (Input d → Bool))
    (hvote : ∀ x, 0 < ∑ i, signedVote f (gs i) x)
    (S D : ℕ)
    (hc : ∀ i, ∃ c : ThresholdCircuit d,
      c.size ≤ S ∧ c.depth ≤ D ∧ c.eval = gs i) :
    ∃ c : ThresholdCircuit d,
      c.size ≤ m*(S+1)+1 ∧ c.depth ≤ D+1 ∧ c.eval = f := by
  classical
  let cs : Fin m → ThresholdCircuit d := fun i => Classical.choose (hc i)
  have hsize (i : Fin m) : (cs i).size ≤ S := (Classical.choose_spec (hc i)).1
  have hdepth (i : Fin m) : (cs i).depth ≤ D := (Classical.choose_spec (hc i)).2.1
  have heval (i : Fin m) : (cs i).eval = gs i := (Classical.choose_spec (hc i)).2.2
  refine ⟨majorityCircuit (List.ofFn cs), majorityCircuit_ofFn_size_le cs S hsize,
    majorityCircuit_ofFn_depth_le cs D hdepth, ?_⟩
  apply majorityCircuit_ofFn_eval_eq cs f
  intro x
  simpa only [heval, signedVote] using hvote x

/-- A distribution-free weak class of small logarithmic-depth threshold
circuits yields one exact threshold circuit, with explicitly controlled size
and only one extra majority layer. -/
theorem weakClass_threshold_circuit {d : ℕ} (f : Input d → Bool)
    (H : Set (Input d → Bool)) (hweak : WeakClass f H)
    (S D : ℕ)
    (hcompile : ∀ g ∈ H, ∃ c : ThresholdCircuit d,
      c.size ≤ S ∧ c.depth ≤ D ∧ c.eval = g) :
    ∃ c : ThresholdCircuit d,
      c.size ≤ (400*(d+1))*(S+1)+1 ∧ c.depth ≤ D+1 ∧ c.eval = f := by
  classical
  obtain ⟨gs,hgs,hvote⟩ := weakClass_exact_majority f H hweak d (by simp [Input])
  exact compile_exact_majority f gs hvote S D (fun i => hcompile (gs i) (hgs i))

/-- Concrete finite posterior-to-circuit theorem. The posterior-class mass
hypothesis is explicit; proving it for the original Gaussian neural prior is
a separate analytic obligation. -/
theorem posterior_family_threshold_circuit {d : ℕ} {I : Type*} [Fintype I]
    (f : Input d → Bool) (g : I → (Input d → Bool))
    (H : I → Prop) [DecidablePred H]
    (hsuccess : ∀ P : Input d → ℝ, (∀ x, 0 ≤ P x) → (∑ x, P x = 1) →
      ∃ p : I → ℝ, (∀ i, 0 ≤ p i) ∧ (∑ i, p i = 1) ∧
        (5/6:ℝ) ≤ (∑ i, if H i then p i else 0) ∧
        confidenceFailureMass f g p P ≤ (1/16:ℝ))
    (S D : ℕ)
    (hcompile : ∀ i, H i → ∃ c : ThresholdCircuit d,
      c.size ≤ S ∧ c.depth ≤ D ∧ c.eval = g i) :
    ∃ c : ThresholdCircuit d,
      c.size ≤ (400*(d+1))*(S+1)+1 ∧ c.depth ≤ D+1 ∧ c.eval = f := by
  classical
  obtain ⟨gs,hgs,hvote⟩ := posterior_family_exact_majority f g H hsuccess d (by simp [Input])
  apply compile_exact_majority f gs hvote S D
  intro j
  obtain ⟨i,hi,heq⟩ := hgs j
  simpa only [heq] using hcompile i hi

#print axioms compile_exact_majority
#print axioms weakClass_threshold_circuit
#print axioms posterior_family_threshold_circuit
end ConditionalNonpolynomial
