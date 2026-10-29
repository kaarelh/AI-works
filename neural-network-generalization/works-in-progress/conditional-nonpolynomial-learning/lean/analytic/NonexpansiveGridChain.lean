import UniformProgramGrid

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {I:ℕ→Type*} [∀j,Fintype (I j)]

def nonexpansiveGridChain (Q N:ℕ)
    (c:∀j,CircuitMap (Fintype.card (I j)*Fintype.card (ScalarGrid Q N))
      (Fintype.card (I (j+1))*Fintype.card (ScalarGrid Q N))) :
    (n:ℕ)→CircuitMap (Fintype.card (I 0)*Fintype.card (ScalarGrid Q N))
      (Fintype.card (I n)*Fintype.card (ScalarGrid Q N))
  | 0=>CircuitMap.identity _
  | n+1=>(nonexpansiveGridChain Q N c n).then (c n)

def nonexpansiveRealChain (F:∀j,EuclideanSpace ℝ (I j)→EuclideanSpace ℝ (I (j+1))) :
    (n:ℕ)→EuclideanSpace ℝ (I 0)→EuclideanSpace ℝ (I n)
  | 0=>id
  | n+1=>F n∘nonexpansiveRealChain F n

theorem nonexpansiveGridChain_approximates (Q N:ℕ)
    (c:∀j,CircuitMap (Fintype.card (I j)*Fintype.card (ScalarGrid Q N))
      (Fintype.card (I (j+1))*Fintype.card (ScalarGrid Q N)))
    (F:∀j,EuclideanSpace ℝ (I j)→EuclideanSpace ℝ (I (j+1))) (δ:ℕ→ℝ) (H:ℕ)
    (hc:∀j<H,GridApproximates Q N Q N (F j) (c j) (δ j))
    (hF:∀j<H,∀x y,‖F j x-F j y‖≤‖x-y‖) :
    ∀n≤H,GridApproximates Q N Q N (nonexpansiveRealChain F n)
      (nonexpansiveGridChain Q N c n) (∑j∈Finset.range n,δ j) := by
  intro n
  induction n with
  | zero =>
    intro _ a
    exact ⟨a,by simp [nonexpansiveGridChain],by simp [nonexpansiveRealChain]⟩
  | succ n ih =>
    intro hn
    have hh := (ih (by omega)).then (hc n (by omega)) (L:=1) (by norm_num)
      (fun x y=>by simpa only [one_mul] using hF n (by omega) x y)
    simpa only [one_mul,Finset.sum_range_succ,nonexpansiveGridChain,nonexpansiveRealChain] using hh

theorem nonexpansiveGridChain_resources (Q N:ℕ)
    (c:∀j,CircuitMap (Fintype.card (I j)*Fintype.card (ScalarGrid Q N))
      (Fintype.card (I (j+1))*Fintype.card (ScalarGrid Q N))) (H S D:ℕ)
    (hs:∀j<H,(c j).size≤S) (hd:∀j<H,(c j).depth≤D) :
    ∀n≤H,(nonexpansiveGridChain Q N c n).size≤n*S ∧
      (nonexpansiveGridChain Q N c n).depth≤n*D := by
  intro n
  induction n with
  | zero=>intro _;simp [nonexpansiveGridChain]
  | succ n ih=>
    intro hn
    obtain ⟨his,hid⟩:=ih (by omega)
    constructor
    · rw [nonexpansiveGridChain,CircuitMap.size_then]
      have hh:=add_le_add his (hs n (by omega))
      simpa only [Nat.add_mul,Nat.one_mul] using hh
    · have hh:=(CircuitMap.depth_then _ _).trans (add_le_add hid (hd n (by omega)))
      simpa only [nonexpansiveGridChain,Nat.add_mul,Nat.one_mul] using hh

theorem nonexpansiveRealChain_norm (F:∀j,EuclideanSpace ℝ (I j)→EuclideanSpace ℝ (I (j+1)))
    (H:ℕ) (hF:∀j<H,∀x y,‖F j x-F j y‖≤‖x-y‖) :
    ∀n≤H,∀x y,‖nonexpansiveRealChain F n x-nonexpansiveRealChain F n y‖≤‖x-y‖ := by
  intro n
  induction n with
  | zero=>intro _ x y;exact le_rfl
  | succ n ih=>intro hn x y;exact (hF n (by omega) _ _).trans (ih (by omega) x y)

#print axioms nonexpansiveGridChain_approximates
#print axioms nonexpansiveGridChain_resources
end ConditionalNonpolynomial.AnalyticLookup
