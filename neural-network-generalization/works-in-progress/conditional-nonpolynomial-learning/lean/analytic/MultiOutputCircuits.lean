import CircuitPipeline

/-! Parallel actual scalar circuits as one multi-output shared DAG. -/
namespace ConditionalNonpolynomial.AnalyticLookup

noncomputable def CircuitMap.ofCircuits {d k : ℕ} (cs : Fin k → ThresholdCircuit d) : CircuitMap d k :=
  let b := CircuitBank.ofList (List.ofFn cs)
  { gateCount := b.gateCount
    gates := b.gates
    outputs := fun i => b.outputs[i.val]'(by simpa only [b, CircuitBank.outputs_length_ofList, List.length_ofFn] using i.isLt) }

@[simp] theorem CircuitMap.eval_ofCircuits {d k : ℕ} (cs : Fin k → ThresholdCircuit d)
    (x : Input d) : (CircuitMap.ofCircuits cs).eval x = fun i => (cs i).eval x := by
  funext i
  have h := congrArg (fun bs : List Bool => bs[i.val]?)
    (CircuitBank.eval_ofList (List.ofFn cs) x)
  simpa [CircuitMap.ofCircuits, CircuitMap.eval, CircuitBank.eval] using h

@[simp] theorem CircuitMap.size_ofCircuits {d k : ℕ} (cs : Fin k → ThresholdCircuit d) :
    (CircuitMap.ofCircuits cs).size = ((List.ofFn cs).map ThresholdCircuit.size).sum := by
  exact CircuitBank.size_ofList (List.ofFn cs)

theorem CircuitMap.size_ofCircuits_le {d k : ℕ} (cs : Fin k → ThresholdCircuit d)
    (S : ℕ) (hs : ∀ i, (cs i).size ≤ S) : (CircuitMap.ofCircuits cs).size ≤ k*S := by
  rw [CircuitMap.size_ofCircuits]
  have hh := sum_sizes_le (List.ofFn cs) S (by
    intro c hc
    obtain ⟨i,rfl⟩ := List.mem_ofFn.mp hc
    exact hs i)
  simpa only [List.length_ofFn] using hh

theorem CircuitMap.depth_ofCircuits_le {d k : ℕ} (cs : Fin k → ThresholdCircuit d)
    (D : ℕ) (hd : ∀ i, (cs i).depth ≤ D) : (CircuitMap.ofCircuits cs).depth ≤ D := by
  apply CircuitBank.depth_ofList_le
  intro c hc
  obtain ⟨i,rfl⟩ := List.mem_ofFn.mp hc
  exact hd i

#print axioms CircuitMap.eval_ofCircuits
#print axioms CircuitMap.size_ofCircuits_le
#print axioms CircuitMap.depth_ofCircuits_le
end ConditionalNonpolynomial.AnalyticLookup
